#!/usr/bin/env node
import { createServer } from "node:http";
import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";

const root = process.cwd();
loadEnv(resolve(root, ".env.local"));

const port = Number(process.env.JYOTISH_AGENT_PORT || 8788);
const model = process.env.OPENAI_JYOTISH_AGENT_MODEL || "gpt-5.4-mini";
const apiKey = process.env.OPENAI_API_KEY;

if (!apiKey) {
  console.error("OPENAI_API_KEY is missing. Copy it into ignored .env.local before starting the backend.");
  process.exit(1);
}

createServer(async (req, res) => {
  setCors(res);
  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  if (req.method !== "POST" || req.url !== "/api/jyotish-agent/chat") {
    sendJSON(res, 404, { error: "Not found" });
    return;
  }

  try {
    const payload = JSON.parse(await readBody(req));
    if (wantsEventStream(req)) {
      await streamPanditReply(payload, res);
      return;
    }
    const reply = await generatePanditReply(payload);
    sendJSON(res, 200, { reply, usedLocalFallback: false });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    sendJSON(res, 500, { error: message });
  }
}).listen(port, "127.0.0.1", () => {
  console.log(`Jyotish agent backend listening on http://127.0.0.1:${port}`);
});

function loadEnv(path) {
  if (!existsSync(path)) return;
  const raw = readFileSync(path, "utf8");
  for (const line of raw.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    let value = trimmed.slice(eq + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    if (!process.env[key]) process.env[key] = value;
  }
}

async function readBody(req) {
  let body = "";
  for await (const chunk of req) {
    body += chunk;
    if (body.length > 1_000_000) throw new Error("Request body too large");
  }
  return body;
}

async function streamPanditReply(payload, res) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream; charset=utf-8",
    "Cache-Control": "no-cache, no-transform",
    "Connection": "keep-alive",
    "Access-Control-Allow-Origin": "*"
  });

  try {
    for await (const delta of generatePanditReplyStream(payload)) {
      res.write(`data: ${JSON.stringify({ delta })}\n\n`);
    }
    res.write(`data: ${JSON.stringify({ done: true })}\n\n`);
    res.write("data: [DONE]\n\n");
    res.end();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    res.write(`data: ${JSON.stringify({ error: message })}\n\n`);
    res.end();
  }
}

async function generatePanditReply(payload) {
  if (!payload || typeof payload.message !== "string" || !payload.message.trim()) {
    throw new Error("message is required");
  }

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model,
      input: [
        {
          role: "system",
          content: [
            {
              type: "input_text",
              text: systemPrompt(payload)
            }
          ]
        },
        {
          role: "user",
          content: [
            {
              type: "input_text",
              text: userPrompt(payload)
            }
          ]
        }
      ],
      max_output_tokens: 420
    })
  });

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`OpenAI ${response.status}: ${text.slice(0, 600)}`);
  }

  const data = JSON.parse(text);
  const reply = extractText(data).trim();
  if (!reply) throw new Error("OpenAI returned an empty reply");
  return reply;
}

async function* generatePanditReplyStream(payload) {
  if (!payload || typeof payload.message !== "string" || !payload.message.trim()) {
    throw new Error("message is required");
  }

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model,
      input: [
        {
          role: "system",
          content: [{ type: "input_text", text: systemPrompt(payload) }]
        },
        {
          role: "user",
          content: [{ type: "input_text", text: userPrompt(payload) }]
        }
      ],
      max_output_tokens: 420,
      stream: true
    })
  });

  if (!response.ok || !response.body) {
    const text = await response.text();
    throw new Error(`OpenAI ${response.status}: ${text.slice(0, 600)}`);
  }

  const decoder = new TextDecoder();
  let buffer = "";
  for await (const chunk of response.body) {
    buffer += decoder.decode(chunk, { stream: true });
    const parts = buffer.split("\n\n");
    buffer = parts.pop() || "";
    for (const part of parts) {
      const delta = extractStreamingDelta(part);
      if (delta) yield delta;
    }
  }
}

function systemPrompt(payload) {
  const language = payload.language === "ne" ? "Nepali" : "English";
  return [
    "You are Pandit-ji inside the Jyotish baje app.",
    `Answer primarily in ${language}. If Nepali, use respectful तपाईं language, never तिमी.`,
    "Use the complete app context provided: the user's own kundli, family kundlis, birth data, dasha, rashifal, saved events, and chat history.",
    "Interpret like a careful Nepali family pandit: warm, practical, specific, and devotional without being theatrical.",
    "The toolEvidence field is authoritative output from deterministic Kundali, Dasha, Panchang, Muhurta, compatibility, festival, and devotional tools.",
    "Your job is interpretation. Never recalculate, override, or invent astrology facts, dates, scores, festival claims, or Muhurta. If the required tool evidence is absent, say what is needed.",
    "Use the supplied localFallbackReply as the factual answer draft. Improve clarity and warmth without changing its facts or uncertainty.",
    payload.requestedFeature ? "This is a feature-report launch. Preserve every supplied date and requested life-area section; return a complete, scannable report rather than collapsing it into the default brief answer." : "",
    "Default to a brief answer: 2–4 short sentences or at most three bullets. Expand only when the user explicitly asks for depth.",
    "End every answer with one short, concrete opt-in question that starts with 'Would you like…' in English or 'के तपाईं…' in Nepali. It must offer the most useful next detail, such as timing, a simple remedy, a dasha connection, or another date.",
    "Do not use rigid section labels unless the user asks for a detailed explanation. The final opt-in question is rendered as a one-tap suggestion in the app, so phrase it as a complete useful question.",
    "Ground every confident chart claim in supplied tool evidence or context. State missing or uncertain birth time plainly and give a softer reading.",
    "Do not claim medical, legal, or financial certainty. Avoid fear-based predictions."
  ].join("\n");
}

function userPrompt(payload) {
  return [
    `Question: ${payload.message}`,
    "",
    "App context JSON:",
    JSON.stringify({
      nowISO: payload.nowISO,
      selfMemberID: payload.selfMemberID,
      family: payload.family || [],
      events: payload.events || [],
      chatHistory: payload.chatHistory || [],
      toolEvidence: payload.toolEvidence || [],
      requestedFeature: payload.requestedFeature || null,
      sourceKey: payload.sourceKey || null,
      localFallbackReply: payload.localFallbackReply || ""
    }, null, 2)
  ].join("\n");
}

function extractText(data) {
  if (typeof data.output_text === "string") return data.output_text;
  const chunks = [];
  for (const item of data.output || []) {
    for (const content of item.content || []) {
      if (typeof content.text === "string") chunks.push(content.text);
    }
  }
  return chunks.join("\n");
}

function extractStreamingDelta(event) {
  for (const line of event.split(/\r?\n/)) {
    if (!line.startsWith("data:")) continue;
    const raw = line.slice(5).trim();
    if (!raw || raw === "[DONE]") continue;
    try {
      const data = JSON.parse(raw);
      if (data.type === "response.output_text.delta" && typeof data.delta === "string") return data.delta;
      if (typeof data.delta === "string") return data.delta;
    } catch {}
  }
  return "";
}

function wantsEventStream(req) {
  return String(req.headers.accept || "").includes("text/event-stream");
}

function setCors(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
}

function sendJSON(res, status, body) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(body));
}
