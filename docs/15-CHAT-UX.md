# Chat and Kundli UX contract

This document describes the native iOS chat behavior implemented in `ChatView`.

## Brief answers and responsive suggestions

Jyotish Baje defaults to two to four short sentences. Every completed answer ends
with one practical opt-in question (for example, whether to connect the reading to
a dasha or auspicious time). The chat renders that exact final question as the
first chip above the composer, followed by two contextual fallbacks. Android follows
the same contract, so a person can continue without retyping the offered choice.
Keep it aligned with the code when changing response rendering, assistant naming,
or chart navigation.

## Response rendering

The agent request is sent through `AgentService.streamReply`, which consumes the
backend's Server-Sent Events response. `AppState.sendChat` appends the assistant
message immediately, then applies incoming deltas to that message while the
request is still running. If the backend is unavailable, the local
`PanditToolPlanner` answer follows the same incremental path.

`ChatView` must render an in-progress assistant message through
`PanditRichText`, just like a completed message. This keeps headings, emphasis,
lists, tables, and line breaks formatted as the answer arrives. Do not replace
the live branch with a plain `Text` view; that makes Markdown appear only after
the final response is received.

The app buffers network deltas and drains them at a stable cadence in small chunks instead
of committing every irregular network packet. `ChatView` follows the newest content only
while the reader remains at the bottom. A user drag disables follow mode without stopping
generation, and the floating down-arrow resumes it. Preserve this ownership rule when
changing streaming or scroll behavior.

## Kundli navigation

The chat only renders Kundli evidence after its assistant message has completed, and only
when the assistant's actions include a
`seeKundli` action with a family-member ID and that member has a computed
Kundali. The ID can point to the account holder or any child/relative included
in the household.

The compact chart is separated from the prose by a hairline and caption, making it part of
the answer flow rather than a premature elevated card. Tapping it or its `See Kundli` action pushes the shared
`MemberDetailView` into the chat's `NavigationStack`. This intentionally reuses
the same complete page reached from Family/Parivar: identity, chart, reading,
dasha timeline, and supporting details. The native Back action pops that page
and reveals the existing conversation without dismissing the chat.

The old full-screen chart preview is not used. Do not add instructional copy
such as “Opens the Kundli full screen” to the chat card; the chart itself is the
affordance.

## Assistant naming and settings

Visible assistant surfaces use **Jyotish Baje**, including the Home entry point,
chat title, placeholder, typing state, reminders, and notification permission
copy. “Pandit” remains valid as a cultural/product-role term in explanatory and
legal copy, but the assistant label shown to users is Jyotish Baje.

There is no separate global chat settings screen. Language and theme continue
to live in Settings; voice input and optional speak-a-reply actions remain
contextual controls inside Chat. The simulator may not provide speech services,
so the microphone control must stay disabled when `VoiceAgent` reports it is
unavailable.

## Verification

Regenerate the project and run the focused contract tests:

```sh
xcodegen generate
xcodebuild test -project Jyotish.xcodeproj -scheme Jyotish \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:JyotishTests/PerformanceOptimizationTests \
  -only-testing:JyotishTests/PanditDiscoveryTests \
  -only-testing:JyotishTests/AppNavigationTests
```

For a simulator smoke run, build, install, and launch `com.sodhera.jyotishbaje`
on the explicitly selected booted simulator. Verify a chat response visibly
changes while streaming, open a child or account-holder Kundli from a chat
card, and use Back to return to the same chat.
