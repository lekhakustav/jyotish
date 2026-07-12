# 14 — Product, UX, and User-Intent Review

Date: 2026-07-10

## Executive verdict

Jyotish Baje already has a stronger foundation than most early astrology apps. It has a
recognisable Hindu/Nepali identity, a real calculation layer, family profiles, a useful
Patro, a warm bilingual voice, and a restrained three-tab shell. The family model is the
clearest product moat. This is not a generic horoscope template.

The current weakness is that the app still asks people to understand its feature map.
Users have to decide whether their concern belongs in Rashifal, Patro, Family, a member's
Kundali, or Jyotish Baje chat. Real people do not arrive with feature-shaped intentions. They
arrive with questions:

- Is today good for this work?
- When should we do the puja, wedding, trip, purchase, or house entry?
- What is happening with my child?
- Are these two people compatible?
- What should I do about this difficult period?
- What does today's tithi or vrat mean for my family?

The product should therefore become **Jyotish Baje with trusted tools**, not a collection
of astrology pages with a chatbot attached. The agent should be the front door. Patro,
Kundali, Dasha, family profiles, Rashifal, Vastu, and future ritual content should become
the tools and evidence behind the answer.

This is the key product decision:

> If Jyotish Baje is the product, it cannot remain a large floating button that opens a
> separate chat room. It should be the primary Home experience, with the rest of the app
> acting as inspectable detail, proof, and direct-access utilities.

## Review method

This review used:

- The current SwiftUI implementation and product documentation.
- A clean Simulator build on iPhone 17 / iOS 26.5 using the QA household and Nepali mode.
- Current Home, Rashifal, Family, Patro, member Kundali, Settings, and Pandit screenshots.
- The current agent request, prompt, streaming, and fallback implementation.
- Current product pages and App Store listings for major Vedic, consultation,
  devotional, and global astrology products.

The market comparison is directional. "Popular features" below means features that recur
across leading products and/or receive prominent placement in products with strong public
rating or usage signals. It does not claim access to private feature-level usage data.

## What the current app gets right

### 1. It has a point of view

The cream canvas, sindoor/marigold palette, Fraunces/Inter pairing, custom rashi marks,
Devanagari-first presentation, and quiet use of ornament feel culturally specific. It
does not look like a Western horoscope app with Hindu labels pasted onto it.

The strongest visual decisions are:

- A calm, warm palette instead of neon mysticism.
- Custom vector rashi marks instead of unreliable emoji or zodiac glyphs.
- Three primary tabs instead of a marketplace-style grid of dozens of tools.
- Visible controls and large targets appropriate for the stated 40–80 audience.
- A Kundali reveal ceremony that gives birth-data entry an emotional payoff.
- Minimal surfaces around prose, charts, and panchanga data.

### 2. The family is a real product advantage

Most astrology apps are individual-first. Jyotish Baje already models family members,
relationships, their Kundalis, Dasha, and relational language. That is much closer to how
Jyotish is actually used in Hindu households: parents ask about children, grandparents
check family timing, and marriage or naming questions involve more than one chart.

The family tree is not yet the most efficient screen, but the underlying product model is
excellent. It gives Jyotish Baje a durable memory and a reason to become more valuable over
time without resorting to manipulative streaks.

### 3. The calculation layer gives the agent something trustworthy to stand on

The current app supplies the backend with birth data, family Kundalis, planetary rashi,
current Dasha, local readings, daily Rashifal, events, and recent history. The server prompt
also already forbids fear-based predictions and medical, legal, or financial certainty.
This is the right philosophical foundation.

### 4. Patro is unusually clean

The month grid is legible, uses Nepali dates and tithis, marks Saturdays, supports direct
date selection, and allows yearly events. Compared with the overwhelming density of many
Panchang products, this is approachable.

### 5. The app respects language and age better than most competitors

Nepali is available before account creation, type is large, interaction targets are
generous, and voice input exists. Those are important advantages for the intended user.

## General UI and UX review

### Overall scorecard

| Dimension | Current | Direction |
| --- | ---: | --- |
| Cultural identity and visual taste | 8/10 | Preserve and refine |
| Navigation simplicity | 7/10 | Good shell, wrong centre of gravity |
| Home hierarchy | 5/10 | Too many competing heroes |
| Readability and tap accessibility | 8/10 | Strong baseline |
| Nepali localisation completeness | 6/10 | First-class intent, incomplete execution |
| Chat presentation | 4/10 | Functional, not yet polished or agentic |
| Trust and explainability | 5/10 | Good prompt rules, weak visible evidence |
| User-intent fit | 5/10 | Features are strong; orchestration is weak |
| Delight | 6/10 | Good ceremony and haptics; inconsistent art/content |
| Agent capability | 4/10 | Context-aware text generation, no actions or tools |

### Highest-priority UI issues

#### P0 — AI answers expose raw Markdown

The current Pandit answer screen displays literal markers such as `**हरियो**` and
`**चन्द्र राशि मिथुन**`. `ChatView` renders agent output as plain `Text`, while the model
is free to emit Markdown. This immediately makes a supposedly wise, premium answer feel
unfinished.

The response should use a strict structured schema or a renderer that supports the small
approved subset of formatting. Structured sections are preferable because they also make
answers easier for older users to scan.

#### P0 — The Home chat control covers content

The orange "Jyotish Baje chat" capsule is visually heavier than the daily reading and overlaps
the Temple of the Day description. It also competes with the large floating tab bar. This
is not only a spacing bug; it reveals that Pandit is bolted onto Home instead of being the
organising experience.

#### P1 — Home has four competing product ideas

Home currently presents:

1. Personal Rashifal.
2. BS date and Patro entry.
3. Temple of the Day.
4. Jyotish Baje chat.

All are potentially valuable, but none clearly owns the page. The large image makes the
temple story feel like the product, while the floating orange button insists chat is the
product. The user has to decide where to go before the app has understood why they came.

#### P1 — The visual hierarchy relies too much on size

Large type is appropriate for the audience, but several screens use oversized titles plus
large controls plus generous blank space. On Rashifal, the title, period control, rashi
picker, hero sign, long reading, five score rows, and lucky facts create a tall page before
the user reaches an actionable conclusion. Large type should improve comprehension, not
simply make every section occupy more screen.

#### P1 — Information is presented, but decisions are not

The app displays tithi, scores, Dasha, charts, lucky colour, and readings. It rarely closes
the loop with a specific user action. For example:

- A tithi appears without "what this means for you today."
- Five score rows appear without "focus here" or "avoid this."
- Dasha appears without a time-bound next step.
- The Patro shows tithis but does not answer "is this a good time for my task?"

The right unit of UX is **answer + reason + action**, not fact + more facts.

#### P1 — The Rashifal scores weaken trust

In the reviewed daily state, career, family, health, wealth, and love all show five stars.
When every category is perfect, the score system reads as decorative rather than
diagnostic. Replace five repeated star rows with a ranked summary such as:

- Strong today: family, learning
- Take care: spending
- Best window: 10:20–11:45

If the calculation cannot create meaningful variation, remove the score UI.

#### P1 — Nepali mode still leaks English and implementation language

The reviewed Patro detail uses English values such as "Shobhana" and "Bava" inside an
otherwise Nepali page. Accessibility labels such as Close, Back, Send, and Ask by voice
are also hard-coded in English in several views. Names may reasonably remain in the
script entered by the household, but computed terms and assistive labels should not.

#### P2 — Temple art and the app's trust tone do not yet match

Temple of the Day can be a lovely daily devotional layer. The current pixel-art-like
image treatment is much louder and more illustrative than the quiet, carefully drawn
rest of the UI. It risks making a serious spiritual companion feel like a content feed.
Use one consistent, reverent art direction and keep the image secondary to today's
meaning, festival, or action.

#### P2 — The family screen duplicates structure without adding an intent

The family tree is emotionally useful and the list is operationally useful, but the
screen currently shows both with substantial empty space. The more important missing
piece is not another layout refinement; it is a family question surface:

- Ask about Aarav
- Compare Priya and [person]
- See this month's family dates
- Add a birth detail

The family list should become a fast person selector for Jyotish Baje as well as a chart
browser.

### Onboarding review

The one-question-per-screen birth flow and Kundali ceremony are strong. "Birth time
unknown" is essential and already present. The problem is the order before that flow:
users meet Create Account / Sign In before receiving personalised value.

For a trust-sensitive audience, especially older users, start with language and a warm
promise, then ask only the birth details needed to reveal something accurate. Let people
experience their first reading or first Baje answer locally before asking them to save or
link an account. Astrotalk currently advertises a 30-second birth-details start with no
signup wall; Jyotish Baje can offer the same low friction without adopting its marketplace
model.

Recommended sequence:

1. Choose language.
2. "Who should Baje read for?" — Me / family member.
3. Name, date, time (or unknown), place.
4. Kundali reveal.
5. Immediate first answer: "Here is what matters for you today."
6. Ask one question.
7. Offer to save the household with Apple/email/phone after value is clear.

## User-intent review

### The six moments the product should own

#### 1. Daily orientation

"How is today for me?" is the retention loop. The answer should be short enough to use
every morning: one theme, one caution, one favourable action or time, and one optional
upaya. This combines the best of daily Rashifal, Panchang, current Dasha, and transit
context without making the user open four screens.

#### 2. Decision timing

"When should I do this?" is one of the most distinctively useful Hindu/Jyotish intents.
It includes marriage, griha pravesh, vehicle or property purchase, travel, business start,
naamkaran, puja, study, interviews, and ordinary household tasks. Drik Panchang's extensive
Muhurat catalogue shows how large this intent family is.

#### 3. Family concern

"What is happening with my son/daughter/partner/parent?" is where this app can be better
than individual-first competitors. Baje should resolve the referenced family member,
confirm whom the user means when ambiguous, and answer from that person's chart and
current period.

#### 4. Compatibility and relationships

Kundli matching, 36-guna compatibility, relationship dynamics, and communication guidance
are common across Vedic and Western products. The user should not have to understand
matching terminology. They should select or add two people and ask a normal question.

#### 5. Difficulty, uncertainty, and remedy

Users often arrive anxious about career, marriage, health, money, children, exams, or
travel. The product must be comforting without exploiting vulnerability. It should never
manufacture doshas, sell fear, or imply that a paid remedy is required. A good answer
should separate:

- What the chart suggests.
- What is uncertain.
- What practical action is in the user's control.
- A modest optional spiritual practice.

#### 6. Ritual and devotional rhythm

The Hindu market also wants Panchang, vrat and festival meaning, puja vidhi, mantras,
aarti, darshan, and temple connection. These are visible in Drik Panchang and Sri Mandir.
They should be added selectively as answers and timely actions, not as a giant content
library on Home.

### What users are not asking for

Most users are not asking to browse a Kundali chart, inspect a Dasha table, or compare
five star scores. Those are supporting artefacts. They should remain available because
they create trust and depth, but the agent should translate them into ordinary language.

## Global feature landscape

### Vedic/Jyotish leaders

#### Astrotalk — instant access and high-intent consultations

Astrotalk's current App Store listing shows 224K ratings, 4.7 stars, and a No. 2 Lifestyle
ranking in India. It foregrounds instant chat/call/live sessions, Kundli, matchmaking,
daily through yearly horoscope, and a remedy shop. The listing's own topic taxonomy is
revealing: career, relationships, marriage obstacles, education, child naming,
matchmaking, foreign settlement, remedies, and gemstones.

Product lesson: people pay for answers to emotionally specific questions, not for chart
data alone. The negative review examples also expose a pain Jyotish Baje can avoid:
per-minute incentives, slow conversations, inconsistent practitioner quality, and unclear
value. An instant agent with transparent reasoning can be a meaningful alternative.

Source: [Astrotalk on the India App Store](https://apps.apple.com/in/app/astrotalk-talk-to-astrologer/id1208433822)

#### AstroSage — breadth and calculator depth

AstroSage exposes a very broad feature set: Kundli, matching, daily/weekly/monthly
horoscope, Panchang, Muhurat, Dasha, transit, dosha reports, Vastu, numerology, baby names,
gemstones, mantra/aarti content, live astrologers, and AI astrologers. It is the clearest
example of an all-in-one Jyotish utility suite.

Product lesson: the underlying tool breadth is valuable, but its menu density is exactly
what Jyotish Baje should hide behind intent-based conversation.

Source: [AstroSage](https://www.astrosage.com/)

#### Drik Panchang — timing, location, ritual depth, and accuracy

Drik Panchang includes daily/monthly Panchang, regional calendars including Nepali Patro,
Muhurat categories, vrat/upavas, festivals, Puja Vidhi, devotional lyrics, planetary
events, Kundli, matching, dosha and gemstone utilities. It states that calculations and
festival/vrat dates are localised for more than 100,000 cities and adjusted for DST.

Product lesson: Hindu time is local. Panchang and Muhurat answers should always use the
user's current or chosen place and should expose the calculation basis.

Source: [Drik Panchang](https://www.drikpanchang.com/)

#### Sri Mandir — devotional services and family ritual

Sri Mandir combines Panchang, horoscope and festivals with devotional music, Hindu
literature, temples, online darshan, Puja and Chadhava booking, and delivery of blessing
items. The company currently self-reports 30M+ devotees, 3M+ services, and use across 30+
countries.

Product lesson: astrology is often a doorway into a broader devotional job. However,
commerce should follow trust. Jyotish Baje should first guide and organise; paid Puja or
offerings should only appear when genuinely relevant and clearly optional.

Source: [Sri Mandir](https://www.srimandir.com/)

### Global astrology leaders

#### Co–Star — relationships and social relevance

Co–Star foregrounds a complete birth chart, real-time insights, friends, compatibility,
and checking what may be happening with another person. Its strongest idea is not its
calculation claim; it is that astrology becomes socially useful.

Product lesson: Jyotish Baje's family graph can deliver this value more naturally and with
greater cultural relevance than a friend-feed clone.

Source: [Co–Star](https://www.costarastrology.com/)

#### CHANI — reflection, audio, and wellbeing

CHANI combines personalised birth-chart and transit readings with daily content, guided
meditations, audio and written affirmations, personalised journal prompts, Moon-phase
readings, and a weekly personalised reading.

Product lesson: an interpretation becomes more useful when it supports reflection and a
small practice. Jyotish Baje can adapt this carefully through "listen," "save this
guidance," and optional mantra/upaya actions without copying Western wellness language.

Source: [The CHANI App](https://www.chani.com/app)

#### The Pattern — plain-language relationship analysis and AI conversation

The Pattern deliberately hides complicated astrology terms. It offers personal patterns,
transits, relationship bonds, historical/future date exploration, and an AI conversation
feature for romantic, friendship, family, and work dynamics.

Product lesson: this validates the agent-as-interpreter direction. The differentiator for
Jyotish Baje should be deterministic Vedic tools, household context, Nepali/Hindu ritual
knowledge, and visible reasons—not simply another open-ended chat.

Source: [The Pattern](https://www.thepattern.com/)

## The most important feature categories

Ranked by recurring market presence, user intent, retention potential, and fit with this
product:

| Priority | Feature family | Why it matters | Current state |
| --- | --- | --- | --- |
| 1 | Personal daily guidance | Highest-frequency habit and easiest first value | Present, fragmented across Home/Rashifal/Patro |
| 2 | Ask a trusted astrologer/agent | Converts anxiety or curiosity into direct value | Present as chat, not yet an action-taking agent |
| 3 | Panchang, festivals, vrat, Muhurat | Distinctive Hindu utility; drives real decisions | Panchang/Patro present; Muhurat and ritual guidance missing |
| 4 | Kundli and life-period interpretation | Core trust and personalisation layer | Strong foundation present |
| 5 | Family profiles | Repeated household value and long-term context | Strong differentiator present |
| 6 | Compatibility and matchmaking | High-intent episodic use | Missing as a guided flow |
| 7 | Remedies and spiritual practices | Gives guidance an action | Basic upaya exists; no structured or safety-reviewed system |
| 8 | Voice, audio, reminders, sharing | Accessibility and return behaviour | Voice input present; audio/reminders/sharing underdeveloped |
| 9 | Devotional content and festival rituals | Broadens Hindu relevance | Temple of Day present; ritual content mostly missing |
| 10 | Human Pandit escalation | Trust for complex or ceremonial needs | Missing |
| 11 | Puja/offerings/store | Monetisation and fulfilment | Do not prioritise before trust and guidance quality |

## Recommended product: Jyotish Baje as the single trusted front door

### Recommended information architecture

Use three destinations:

1. **Baje / Today** — the agent-led Home, daily guidance, and conversation.
2. **Patro** — direct calendar access for people who already know what they need.
3. **Parivar** — people, Kundalis, relationships, and family events.

Rashifal should remain a rich detail view, but it no longer needs to be a primary tab. It
is an answer type inside Baje and a detail reached from the daily reading. Settings remains
in the profile/gear entry.

This is intentionally different from the current contract. Keeping Pandit contextual was
a good simplification when the product was feature-led. A single-point agent direction
changes the premise: Jyotish Baje becomes Home itself, not another tab or modal.

### The new Home

The first screen should contain only:

- Greeting and household/person selector.
- One short personalised daily guidance block.
- A persistent prompt: **"What would you like Baje's help with?"**
- Four contextual intent choices, not feature names:
  - My day
  - Choose a good time
  - My family
  - A remedy or ritual
- One timely item when relevant: today's vrat/festival, a saved family event, or a strong
  Muhurat window.

Temple of the Day can appear below as a quiet optional story or become part of the timely
item. It should not compete with the agent and daily answer above the fold.

### The answer contract

Every answer should follow a predictable, scan-friendly shape:

1. **Direct answer** — one or two sentences.
2. **Why Baje says this** — the relevant chart/Panchang factors in plain language.
3. **What to do** — one practical action and one optional spiritual practice.
4. **Actions** — buttons such as Add to Patro, Remind me, See Kundli, Compare, Listen,
   or Ask a follow-up.
5. **Uncertainty** — shown clearly when birth time, place, or calculation context is
   incomplete.

Example:

> **Friday morning is the better window for the house puja.**
>
> Your family's selected date avoids Rahu Kaal, and the Moon is supportive for a home
> ritual. Because Aarav's birth time is unknown, his personal part of this reading is
> approximate.
>
> Keep the sankalpa simple. If you would like, I can add the time to your Patro and remind
> the family the evening before.

Actions: `Add to Patro` `Why this time?` `Check another date`

### The agent must use tools, not invent astrology

The current backend receives a large JSON context and generates prose. That is a good
prototype, but it is not a safe or scalable agent. The next version should have a planner
that calls deterministic, typed tools and then explains their results.

Core read tools:

- `get_household_context`
- `get_kundli(member)`
- `get_current_dasha(member, date)`
- `get_gochar(member, date)`
- `get_rashifal(member, period)`
- `get_panchang(date, place)`
- `find_muhurta(intent, date_range, place, people)`
- `compare_kundli(person_a, person_b)`
- `get_festival_or_vrat(date, place, tradition)`
- `get_vastu_guidance(room_or_direction)`
- `get_safe_upaya(context)`

Action tools, always requiring confirmation:

- `add_family_member`
- `update_birth_details`
- `save_patro_event`
- `set_reminder`
- `save_guidance`
- `share_family_summary`
- `start_human_pandit_handoff`

The agent should cite its internal evidence in ordinary language, for example:

- Based on Sita's Mithun Moon and current Shukra/Rahu period.
- Based on Kathmandu Panchang for 18 Shrawan.
- Birth time is unknown, so Lagna-dependent guidance was excluded.

### Safety and trust rules

The existing no-fear prompt should become a product policy enforced before and after the
model call:

- Never predict death, disaster, infertility, divorce, illness, or financial outcome as
  certainty.
- Never pressure the user into gemstones, Puja, donations, or paid consultation.
- Never let a ritual substitute for medical, legal, safety, or financial help.
- Separate calculation, interpretation, and optional faith practice.
- Mark missing or uncertain birth data.
- Keep an inspectable history of which tools and chart facts produced the answer.
- Offer a human Pandit handoff for complex ceremonies or disputed traditions.

## Making it minimal, accessible, and fun

### Minimal

- Use intent labels, not astrology taxonomy.
- Show one daily conclusion, not five equal score rows.
- Keep charts behind "Why" or "See Kundli."
- Use one fixed agent composer instead of a floating button plus a separate chat room.
- Never show a feature grid on Home.
- Ask one clarification at a time.
- Remember the user's person, place, language, and family context with consent.

### Accessible

- Keep 48pt+ targets and dynamic type.
- Add "Listen" to every Baje answer; voice is especially valuable for older users and
  users with lower literacy.
- Use Nepali first and support Hindi plus major Indian languages after the core Nepali
  experience is complete.
- Localise assistive labels and computed Jyotish terms, not only visible navigation text.
- Never require a hidden swipe or long press.
- Provide "I don't know my birth time" and explain what remains accurate.
- Support a simple family-assisted setup where a younger relative can prepare profiles.

### Fun without becoming frivolous

- Keep the Kundali reveal ceremony.
- Give each morning a tiny "Baje says" ritual that can be read in 20–30 seconds.
- Use subtle seasonal/festival colour, haptics, and one consistent art style.
- Let users share a tasteful blessing, Muhurat card, or family date to WhatsApp.
- Use visible family chips so asking about different people feels immediate.
- Celebrate useful completion: "Added to your Patro" or "The family is reminded."
- Avoid casino-style streaks, spinning wheels, fear alerts, fake urgency, or excessive
  confetti around sacred content.

## What not to build yet

- A live-astrologer marketplace with per-minute pricing.
- A gemstone or remedy store.
- Tarot, psychic reading, Reiki, numerology, and every adjacent occult category.
- A giant Aarti/mantra content library before the daily agent loop is excellent.
- A social feed.
- Generic AI summaries that are not backed by calculation tools.
- More decorative cards, mandalas, or Home modules.

These features may be commercially common, but copying the entire category would destroy
the product's taste and differentiation. The goal is not to out-menu AstroSage or
out-marketplace Astrotalk. It is to become the most trusted household Jyotish companion.

## Recommended delivery order

### Phase 0 — Fix visible trust breaks

- Render or eliminate raw Markdown in answers.
- Remove the overlapping Home chat capsule.
- Complete Nepali localisation of Panchang terms and accessibility labels.
- Replace non-diagnostic all-five-star score states with meaningful prioritisation.
- Tighten Home safe-area and bottom-navigation spacing.

### Phase 1 — Make Baje the Home experience

- Embed the agent prompt and daily answer on Home.
- Add person/family context selection.
- Adopt the structured answer contract.
- Make Rashifal a detail destination rather than the centre tab.
- Add visible "Why this?" evidence from current deterministic calculations.

### Phase 2 — Add the highest-value missing tools

- Muhurat finder for common household intents.
- Kundli comparison and compatibility.
- Festival/vrat meaning with local place and family relevance.
- Structured, safety-reviewed upaya library.
- Save to Patro and reminder actions.

### Phase 3 — Accessibility and return behaviour

- Spoken answers with a clear opt-in play button.
- Notifications for user-saved events, chosen vrats, and agent-confirmed Muhurat.
- WhatsApp-friendly share cards.
- Family-assisted setup and account recovery.

### Phase 4 — Trusted human and devotional extensions

- Human Pandit escalation for ceremonies and complex questions.
- Curated Puja Vidhi, mantra, and aarti only where they complete an agent-guided task.
- Carefully vetted temple or Puja fulfilment partners, with transparent pricing and no
  fear-based upsell.

## Success measures

Measure whether the app reduces uncertainty and effort, not just whether people open
screens:

- Time from install to first personalised value.
- Percentage of sessions that begin with an intent and end with a clear answer.
- Percentage of answers grounded in deterministic tools without unsupported claims.
- Completion rate for Add to Patro, reminder, family profile, or comparison actions.
- Repeat weekly use of daily guidance.
- Voice/listen usage among older users.
- Follow-up rate after an answer, separated from confusion-driven rephrasing.
- User trust rating: "Did Baje explain why?"
- Safety incidents and fear/certainty violations, with a target of zero.

## Final recommendation

Do not win by having the most features. Win by making a Hindu household feel that one
patient, familiar, careful Jyotish Baje already knows the family, understands the calendar,
shows his reasoning, and can quietly take the next useful action.

The current app already owns most of the hard primitives. The next step is not a broad
feature expansion. It is a product re-centering:

**from pages that contain Jyotish information to one trusted agent that uses Jyotish tools
for the family.**
