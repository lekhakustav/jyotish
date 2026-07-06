# 06 — Backend Agent

## Current state
Jyotish chat is backend-first with a local fallback:

1. `ChatView.send(_:)` starts an async send and disables duplicate sends while waiting.
2. `AppState.sendChat(_:)` appends the user's message and computes a deterministic
   `PanditBrain` fallback reply.
3. `AgentService` builds an `AgentChatRequest` with the user's profile, family kundlis,
   local readings, current dasha, daily rashifal, saved events, recent chat history, and
   the local fallback answer.
4. `HTTPAgentService` posts that context to `JYOTISH_AGENT_ENDPOINT_URL`
   (`https://ghfcssxptpazfbtiwshz.supabase.co/functions/v1/jyotish-agent` by default).
5. The local dev backend (`server/jyotish-agent.mjs`) or production Supabase Edge Function
   (`supabase/functions/jyotish-agent`) keeps the OpenAI key server-side and calls OpenAI.
6. If the backend fails or returns an empty reply, `AppState` appends the local
   `PanditBrain` answer so the chat still works offline.
7. `HTTPAgentService.streamReply(...)` requests `text/event-stream` and appends assistant
   characters as they arrive. The UI shows a typing indicator until the first delta lands.
8. `VoiceAgent` captures the user's spoken question and keeps the transcript visible before
   send. Server-side ElevenLabs credentials are reserved for higher quality voice agents,
   speech-to-text, and TTS; they are not shipped in the iOS target.

This means the OpenAI key belongs in a backend process, not in the iOS target.

## Local environment
Create `.env.local` at the repo root:

```sh
OPENAI_API_KEY=...
OPENAI_JYOTISH_AGENT_MODEL=gpt-5.4-mini
OPENAI_JYOTISH_AGENT_PLANNER_MODEL=gpt-5-nano
JYOTISH_AGENT_PORT=8788
JYOTISH_AGENT_ENDPOINT_URL=https://ghfcssxptpazfbtiwshz.supabase.co/functions/v1/jyotish-agent
ELEVENLABS_API_KEY=...
ELEVENLABS_TTS_MODEL=eleven_multilingual_v2
ELEVENLABS_STT_MODEL=scribe_v2
ELEVENLABS_FEMALE_AGENT_ID=...
ELEVENLABS_MALE_AGENT_ID=...
```

`.env.local` is intentionally ignored by git.

To import the OpenAI key from the user's Desktop/Sodhera checkout without printing it:

```sh
src=/Users/sirishjoshi/Desktop/sodhera/.env.local
dst=.env.local
key=$(awk -F= '$1=="OPENAI_API_KEY" {sub(/^[^=]*=/, ""); print; exit}' "$src")
awk -v key="$key" 'BEGIN { done=0 } /^OPENAI_API_KEY=/ { print "OPENAI_API_KEY=" key; done=1; next } { print } END { if (!done) print "OPENAI_API_KEY=" key }' "$dst" > "$dst.tmp"
mv "$dst.tmp" "$dst"
git check-ignore -v .env.local
```

Never echo the key, commit `.env.local`, place it in `Info.plist`, or put it in Xcode build
settings.

## Run the backend
### Local development

```sh
npm run agent
```

Expected startup:

```text
Jyotish agent backend listening on http://127.0.0.1:8788
```

Smoke test from the repo root:

```sh
curl -sS http://127.0.0.1:8788/api/jyotish-agent/chat \
  -H 'Content-Type: application/json' \
  -d '{"language":"en","message":"Namaste, how is my day?","family":[],"events":[],"chatHistory":[],"localFallbackReply":"Namaste."}'
```

### Production without a dedicated server
Use the Supabase Edge Function in `supabase/functions/jyotish-agent`:

```sh
supabase secrets set OPENAI_API_KEY=... OPENAI_JYOTISH_AGENT_MODEL=gpt-5.4-mini
supabase functions deploy jyotish-agent
```

Production builds use:

```sh
JYOTISH_AGENT_ENDPOINT_URL=https://ghfcssxptpazfbtiwshz.supabase.co/functions/v1/jyotish-agent
```

Keep Supabase function JWT verification enabled for production. The app includes the
publishable `apikey` header and the user's Supabase Auth bearer token when a session exists.
That prevents placing the OpenAI key in the app and avoids running a separate server.

## Backend contract
The backend exposes one narrow chat endpoint:

```http
POST /api/jyotish-agent/chat
Content-Type: application/json
```

Request:

```json
{
  "language": "en",
  "message": "How is my dasha now?",
  "nowISO": "2026-07-06T12:00:00.000Z",
  "selfMemberID": "...",
  "family": [],
  "events": [],
  "chatHistory": [],
  "localFallbackReply": "Today's rashifal..."
}
```

Response:

```json
{
  "reply": "Namaste...",
  "usedLocalFallback": false
}
```

Streaming response:

```http
POST /api/jyotish-agent/chat
Accept: text/event-stream
Content-Type: application/json
```

Each event is a small JSON payload:

```text
data: {"delta":"Namaste"}
data: {"delta":"..."}
data: {"done":true}
data: [DONE]
```

## Prompting rules
The server prompt tells OpenAI to:

- answer as Pandit-ji inside the Jyotish app,
- match the app language (`Language.en` or `Language.ne`),
- use respectful `तपाईं` in Nepali,
- ground chart claims in supplied kundli/context,
- soften the answer when birth data is missing,
- include practical upaya when useful,
- avoid fear-based predictions and medical/legal/financial certainty.

## iOS integration
`project.yml` and `Jyotish/Info.plist` define `JYOTISH_AGENT_ENDPOINT_URL`, defaulting to the
deployed Supabase Edge Function. For local development, override this setting to
`http://127.0.0.1:8788/api/jyotish-agent/chat`. Do not read `.env.local` from the iOS app
and do not ship the OpenAI key in source code, asset catalogs, `Info.plist`, or build settings.
