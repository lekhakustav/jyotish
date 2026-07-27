const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const MAX_BODY_BYTES = 128_000;
const MAX_REQUESTS_PER_WINDOW = 20;
const RATE_WINDOW_MS = 60_000;
const rateBuckets = new Map<string, { startedAt: number; count: number }>();

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const auth = await authenticate(req);
    if (auth instanceof Response) return auth;

    const retryAfter = takeRateLimit(auth.userId);
    if (retryAfter !== null) {
      return json({ error: "Too many requests" }, 429, { "Retry-After": String(retryAfter) });
    }

    const payload = await readPayload(req);
    if (req.headers.get("accept")?.includes("text/event-stream")) {
      return streamPanditReply(payload);
    }
    const reply = await generatePanditReply(payload);
    return json({ reply, usedLocalFallback: false });
  } catch (error) {
    if (error instanceof RequestError) return json({ error: error.message }, error.status);
    console.error("[jyotish-agent] request failed", error);
    return json({ error: "Agent request failed" }, 500);
  }
});

class RequestError extends Error {
  constructor(public readonly status: number, message: string) {
    super(message);
  }
}

async function authenticate(req: Request): Promise<{ userId: string } | Response> {
  const authorization = req.headers.get("authorization");
  const bearer = authorization?.match(/^Bearer\s+(\S+)$/i)?.[1];
  if (!bearer) return json({ error: "Authentication required" }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !anonKey) {
    console.error("[jyotish-agent] Supabase auth verification is not configured");
    return json({ error: "Authentication is unavailable" }, 503);
  }

  const response = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: { apikey: anonKey, authorization: `Bearer ${bearer}` },
  });
  if (!response.ok) return json({ error: "Invalid session" }, 401);
  const user = await response.json();
  if (typeof user?.id !== "string" || !user.id) return json({ error: "Invalid session" }, 401);
  return { userId: user.id };
}

async function readPayload(req: Request): Promise<Record<string, unknown>> {
  const contentLength = Number(req.headers.get("content-length") || 0);
  if (contentLength > MAX_BODY_BYTES) throw new RequestError(413, "Request body too large");

  const raw = await req.text();
  if (raw.length > MAX_BODY_BYTES) throw new RequestError(413, "Request body too large");

  let payload: unknown;
  try {
    payload = JSON.parse(raw);
  } catch {
    throw new RequestError(400, "Request body must be valid JSON");
  }
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    throw new RequestError(400, "Request body must be an object");
  }
  const record = payload as Record<string, unknown>;
  if (typeof record.message !== "string" || !record.message.trim()) {
    throw new RequestError(400, "message is required");
  }
  if (record.message.length > 4_000) throw new RequestError(400, "message is too long");
  return record;
}

function takeRateLimit(userId: string): number | null {
  const now = Date.now();
  const bucket = rateBuckets.get(userId);
  if (!bucket || now - bucket.startedAt >= RATE_WINDOW_MS) {
    rateBuckets.set(userId, { startedAt: now, count: 1 });
    return null;
  }
  if (bucket.count >= MAX_REQUESTS_PER_WINDOW) {
    return Math.max(1, Math.ceil((RATE_WINDOW_MS - (now - bucket.startedAt)) / 1000));
  }
  bucket.count += 1;
  return null;
}

async function generatePanditReply(payload: Record<string, unknown>): Promise<string> {
  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) throw new Error("OPENAI_API_KEY is missing");

  const message = typeof payload.message === "string" ? payload.message.trim() : "";
  if (!message) throw new Error("message is required");

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("OPENAI_JYOTISH_AGENT_MODEL") || "gpt-5.4-mini",
      input: [
        {
          role: "system",
          content: [{ type: "input_text", text: systemPrompt(payload) }],
        },
        {
          role: "user",
          content: [{ type: "input_text", text: userPrompt(payload) }],
        },
      ],
      max_output_tokens: 900,
    }),
  });

  const text = await response.text();
  if (!response.ok) {
    console.error("[jyotish-agent] OpenAI request failed", response.status);
    throw new Error("OpenAI request failed");
  }

  const data = JSON.parse(text);
  const reply = extractText(data).trim();
  if (!reply) throw new Error("OpenAI returned an empty reply");
  return reply;
}

function streamPanditReply(payload: Record<string, unknown>): Response {
  const encoder = new TextEncoder();
  const body = new ReadableStream({
    async start(controller) {
      try {
        for await (const delta of generatePanditReplyStream(payload)) {
          controller.enqueue(encoder.encode(`data: ${JSON.stringify({ delta })}\n\n`));
        }
        controller.enqueue(encoder.encode(`data: ${JSON.stringify({ done: true })}\n\n`));
        controller.enqueue(encoder.encode("data: [DONE]\n\n"));
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        controller.enqueue(encoder.encode(`data: ${JSON.stringify({ error: message })}\n\n`));
      } finally {
        controller.close();
      }
    },
  });
  return new Response(body, {
    headers: {
      ...corsHeaders,
      "Content-Type": "text/event-stream; charset=utf-8",
      "Cache-Control": "no-cache, no-transform",
    },
  });
}

async function* generatePanditReplyStream(payload: Record<string, unknown>): AsyncGenerator<string> {
  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) throw new Error("OPENAI_API_KEY is missing");

  const message = typeof payload.message === "string" ? payload.message.trim() : "";
  if (!message) throw new Error("message is required");

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("OPENAI_JYOTISH_AGENT_MODEL") || "gpt-5.4-mini",
      input: [
        {
          role: "system",
          content: [{ type: "input_text", text: systemPrompt(payload) }],
        },
        {
          role: "user",
          content: [{ type: "input_text", text: userPrompt(payload) }],
        },
      ],
      max_output_tokens: 900,
      stream: true,
    }),
  });

  if (!response.ok || !response.body) {
    await response.text();
    console.error("[jyotish-agent] OpenAI stream request failed", response.status);
    throw new Error("OpenAI request failed");
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

function systemPrompt(payload: Record<string, unknown>): string {
  const language = payload.language === "ne" ? "Nepali" : "English";
  return [
    "You are Pandit-ji inside the Jyotish baje app.",
    `Answer primarily in ${language}. If Nepali, use respectful तपाईं language, never तिमी.`,
    "Use the complete app context provided: the user's own kundli, family kundlis, birth data, dasha, rashifal, saved events, and chat history.",
    "Interpret like a careful Nepali family pandit: warm, practical, specific, and devotional without being theatrical.",
    "The toolEvidence field is authoritative output from deterministic Kundali, Dasha, Panchang, Muhurta, compatibility, festival, and devotional tools.",
    "Your job is interpretation. Never recalculate, override, or invent astrology facts, dates, scores, festival claims, or Muhurta. If the required tool evidence is absent, say what is needed.",
    "Use the supplied localFallbackReply as the factual answer draft. Improve clarity and warmth without changing its facts or uncertainty.",
    payload.requestedFeature ? "This is a feature-report launch. Preserve every supplied date and requested life-area section; return a complete, scannable report rather than collapsing it into a brief answer." : "",
    "Keep the answer concise and use exactly these bold section labels: Direct answer; Why Baje says this; What to do; Optional practice; Uncertainty. Translate the labels into Nepali when answering in Nepali.",
    "Ground every confident chart claim in supplied tool evidence or context. State missing or uncertain birth time plainly and give a softer reading.",
    "Do not claim medical, legal, or financial certainty. Avoid fear-based predictions.",
  ].join("\n");
}

function userPrompt(payload: Record<string, unknown>): string {
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
      localFallbackReply: payload.localFallbackReply || "",
    }, null, 2),
  ].join("\n");
}

function extractText(data: any): string {
  if (typeof data.output_text === "string") return data.output_text;
  const chunks: string[] = [];
  for (const item of data.output || []) {
    for (const content of item.content || []) {
      if (typeof content.text === "string") chunks.push(content.text);
    }
  }
  return chunks.join("\n");
}

function extractStreamingDelta(event: string): string {
  for (const line of event.split(/\r?\n/)) {
    if (!line.startsWith("data:")) continue;
    const raw = line.slice(5).trim();
    if (!raw || raw === "[DONE]") continue;
    try {
      const data = JSON.parse(raw);
      if (data.type === "response.output_text.delta" && typeof data.delta === "string") return data.delta;
      if (typeof data.delta === "string") return data.delta;
    } catch {
      // Ignore malformed upstream stream fragments.
    }
  }
  return "";
}

function json(body: unknown, status = 200, extraHeaders: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json", ...extraHeaders },
  });
}
