# 09 - Transcript Goals

Date: 2026-07-05

Source: critique transcript from Sita Sharan and Utsav about the Jyotish app, including the second audio transcript reviewed on 2026-07-05.

## Product Goals

1. Make the app quieter and less duplicated.
   - Remove small Devanagari echo titles when the screen already has a title.
   - Remove AD date noise from Home and the Patro grid.
   - Use a simple Hindu-style Home greeting with the user's name instead of generic "Good morning" copy.

2. Make astrology marks feel like icons, not text badges.
   - Do not show rashi monograms inside double circles.
   - Use unframed, vector-style rashi marks wherever the app shows a sign.
   - Replace flame-based ratings with a quieter sacred star mark.
   - Make the star marks darker and a little larger so they are visible.

3. Keep empty states out of the Home dashboard.
   - Hide the family quick row until relatives exist.
   - Hide upcoming events until the user has events.

4. Make Patro reachable, but not a primary tab.
   - Bottom navigation has Home, Rashifal, and Family only.
   - Home's date block exposes an Open Patro action.
   - Patro supports jumping directly to a month/year/day instead of repeated chevrons.
   - Make the Open Patro action feel tappable.
   - Make the go-to-date sheet larger with clearer spacing between month, day, and year.

5. Make Pandit-ji reachable contextually, but not a primary tab.
   - Home has a floating Pandit entry point.
   - Rashifal has an in-context ask action.
   - Chat opens as a modal with a visible close control.
   - Chat keeps typed input primary; voice is optional and does not auto-speak typed replies by default.
   - Chat exposes a simple history drawer.

6. Keep the AI implementation secure.
   - The transcript asks for an OpenAI-backed chatbot.
   - Do not ship the OpenAI key in the iOS target.
   - Use the backend-agent contract in `docs/06-BACKEND-AGENT.md`; until that backend exists,
     iOS keeps using local `PanditBrain`.

7. Polish the second transcript's screen-specific details.
   - Home: keep the date strong, but make tithi/paksha/nakshatra smaller and lighter.
   - Rashifal: keep Read More behavior, but remove the small lucky color/number/day pictorial icons.
   - Family: arrange people like a real family tree, with parents above and children below.
   - Family: keep connector lines away from names so the icon/name block reads as one unit.

## Implemented In This Pass

- Typed app navigation contract: `AppTab` is Home/Rashifal/Family; Patro is pushed; Pandit is modal.
- Test coverage for the new navigation contract in `JyotishTests/AppNavigationTests.swift`.
- Home simplification, Open Patro action, floating Pandit action, and hidden empty sections.
- Rashifal title cleanup, unframed rashi picker, lucky-things layout, and ask action.
- Patro title/date cleanup, no AD day numbers in cells, subtle today highlight, and jump-date sheet.
- Family title cleanup and name/relation-driven tree labels.
- Chat modal close button, history drawer, and typed-first voice behavior.
- Vector-style hand-drawn rashi marks and star score indicators.
- Second transcript pass: Home greeting/name, smaller panchanga text, stronger Open Patro affordance, larger spaced date picker, darker/larger star marks, simpler lucky facts, and a top-to-bottom Family tree.

## Deferred

- Real OpenAI chatbot responses require the backend endpoint from `docs/06-BACKEND-AGENT.md`.
- More polished chat-session grouping can replace the current simple history drawer once backend chat IDs exist.
