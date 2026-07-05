# 06 — Backend Agent

## Current state
Jyotish is still local-first. The chat path is:

1. `ChatView.send(_:)` appends the user's message.
2. `AppState.sendChat(_:)` calls `PanditBrain.reply(to:)`.
3. `PanditBrain` answers with deterministic local astrology, vastu, city, color, dasha, and rashifal logic.
4. `VoiceAgent` only handles speech-to-text and text-to-speech. It does not call OpenAI.

This means the OpenAI key belongs in a backend process, not in the iOS target.

## Local environment
Create `.env.local` at the repo root:

```sh
OPENAI_API_KEY=...
OPENAI_JYOTISH_AGENT_MODEL=gpt-5-mini
OPENAI_JYOTISH_AGENT_PLANNER_MODEL=gpt-5-nano
```

`.env.local` is intentionally ignored by git.

## Intended backend contract
The backend Jyotish agent should expose a narrow chat endpoint, for example:

```http
POST /api/jyotish-agent/chat
Content-Type: application/json
```

Request:

```json
{
  "language": "en",
  "message": "How is my dasha now?",
  "family": [],
  "events": [],
  "chatHistory": []
}
```

Response:

```json
{
  "reply": "Namaste...",
  "usedLocalFallback": false
}
```

The backend should keep the OpenAI API key server-side, call OpenAI with `OPENAI_API_KEY`,
and preserve the existing local `PanditBrain` behavior as either:

- a fallback when the backend is unreachable, or
- a tool/context layer that supplies deterministic jyotish facts to the model.

## iOS integration plan
When the backend exists, add an `AgentService` protocol beside the existing service layer:

```swift
protocol AgentService {
    func reply(to message: String, context: AgentContext) async throws -> String
}
```

Then update `AppState.sendChat(_:)` to append the user message immediately, request the
backend reply asynchronously, and fall back to `PanditBrain.reply(to:)` on network failure.
Do not read `.env.local` from the iOS app and do not ship the OpenAI key in `Info.plist`,
source code, asset catalogs, or build settings.
