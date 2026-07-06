# 06 — Backend Agent

## Current state
Jyotish chat is backend-first with a local fallback:

1. `ChatView.send(_:)` starts an async send and disables duplicate sends while waiting.
2. `AppState.sendChat(_:)` appends the user's message and computes a deterministic
   `PanditBrain` fallback reply.
3. `AgentService` builds an `AgentChatRequest` with the user's profile, family kundlis,
   local readings, current dasha, daily rashifal, saved events, recent chat history, and
   the local fallback answer.
4. `HTTPAgentService` posts that context to `JYOTISH_AGENT_BASE_URL`
   (`http://127.0.0.1:8788` by default).
5. `server/jyotish-agent.mjs` keeps the OpenAI key server-side and calls OpenAI.
6. If the backend fails or returns an empty reply, `AppState` appends the local
   `PanditBrain` answer so the chat still works offline.
7. `VoiceAgent` only handles speech-to-text and text-to-speech. It does not call OpenAI.

This means the OpenAI key belongs in a backend process, not in the iOS target.

## Local environment
Create `.env.local` at the repo root:

```sh
OPENAI_API_KEY=...
OPENAI_JYOTISH_AGENT_MODEL=gpt-5-mini
OPENAI_JYOTISH_AGENT_PLANNER_MODEL=gpt-5-nano
JYOTISH_AGENT_PORT=8788
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
`project.yml` and `Jyotish/Info.plist` define `JYOTISH_AGENT_BASE_URL`, defaulting to the
simulator-friendly loopback URL. For a physical device, override this setting to a reachable
LAN or deployed HTTPS backend. Do not read `.env.local` from the iOS app and do not ship the
OpenAI key in source code, asset catalogs, `Info.plist`, or build settings.
