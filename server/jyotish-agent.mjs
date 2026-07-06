#!/usr/bin/env node
import { createServer } from "node:http";
import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";

const root = process.cwd();
loadEnv(resolve(root, ".env.local"));

const port = Number(process.env.JYOTISH_AGENT_PORT || 8788);
const model = process.env.OPENAI_JYOTISH_AGENT_MODEL || "gpt-5-mini";
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
      max_output_tokens: 900
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

function systemPrompt(payload) {
  const language = payload.language === "ne" ? "Nepali" : "English";
  return [
    "You are Pandit-ji inside the Jyotish baje app.",
    `Answer primarily in ${language}. If Nepali, use respectful तपाईं language, never तिमी.`,
    "Use the complete app context provided: the user's own kundli, family kundlis, birth data, dasha, rashifal, saved events, and chat history.",
    "Interpret like a careful Nepali family pandit: warm, practical, specific, and devotional without being theatrical.",
    "Ground every confident chart claim in the supplied context. If birth data is missing or uncertain, say what is missing and give a softer reading.",
    "Prefer concise answers with a clear reading, one practical upaya when useful, and an invitation to ask a focused follow-up.",
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

function setCors(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
}

function sendJSON(res, status, body) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(body));
}
