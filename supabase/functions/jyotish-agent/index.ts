const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const payload = await req.json();
    const reply = await generatePanditReply(payload);
    return json({ reply, usedLocalFallback: false });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return json({ error: message }, 500);
  }
});

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
      model: Deno.env.get("OPENAI_JYOTISH_AGENT_MODEL") || "gpt-5-mini",
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
    throw new Error(`OpenAI ${response.status}: ${text.slice(0, 600)}`);
  }

  const data = JSON.parse(text);
  const reply = extractText(data).trim();
  if (!reply) throw new Error("OpenAI returned an empty reply");
  return reply;
}

function systemPrompt(payload: Record<string, unknown>): string {
  const language = payload.language === "ne" ? "Nepali" : "English";
  return [
    "You are Pandit-ji inside the Jyotish baje app.",
    `Answer primarily in ${language}. If Nepali, use respectful तपाईं language, never तिमी.`,
    "Use the complete app context provided: the user's own kundli, family kundlis, birth data, dasha, rashifal, saved events, and chat history.",
    "Interpret like a careful Nepali family pandit: warm, practical, specific, and devotional without being theatrical.",
    "Ground every confident chart claim in the supplied context. If birth data is missing or uncertain, say what is missing and give a softer reading.",
    "Prefer concise answers with a clear reading, one practical upaya when useful, and an invitation to ask a focused follow-up.",
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

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
