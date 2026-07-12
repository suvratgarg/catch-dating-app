# Catch Marketing Website — Copy Deck v2 (2026-07-11)

Replacement copy for every public surface of catchdates.com. Grounded in the
shipped product (verified against `lib/`, `functions/src/`, and the live site)
and in owner decisions from the 2026-07-11 session:

- **The member app is live on stores in India.** The site must stop reading as
  pre-launch. Hero CTA = download; waitlist survives only for unopened cities.
- **Founding host offer leads**: manual approval, 0% Catch platform fee for 24
  months from first published event, public Founding Host badge, boosted
  discovery placement.
- **Vocabulary**: *organizer* = the entity (parent set); *club* = one organizer
  type; *host* = the individual who owns/represents the organizer (sometimes
  the organizer *is* just the host); *guest* = event attendee; *member* = club
  member specifically. *Catch* (verb/noun) = the private post-event pick;
  *match* = a mutual catch; *the window* = the 24 hours after an event.
- **Geography**: India-first examples (real cities, ₹), language globally
  legible. Architect content for locale injection (see §9).

## 0. Voice rules

1. Describe the night, not the system. If a sentence explains how the platform
   is architected, delete it and say what the reader gets.
2. Short declarative sentences. Concrete nouns: the door, the table, the room,
   the guest list, the night.
3. Each section owns exactly one claim. Never re-explain the whole model.
4. Every claim must be checkable in the product.
5. Consumer pages: warm, direct, second person. Host pages: operator to
   operator — name the tools they actually juggle today (Instagram, WhatsApp,
   Google Forms, UPI screenshots, spreadsheets).
6. **Banned on public pages**: loop, surface(s), aggregate-safe, cohort,
   signal(s), projection/projected, roster (consumer pages; "guest list"),
   module (consumer pages), format-aware, interaction model, attendance-gated,
   demand (as a noun for people), mechanic, claim state, source ledger,
   "lead packet", any sentence about mockups/prototypes/callables.
7. Dating-app clichés banned everywhere: "meaningful connections",
   "find your person", "spark", "journey".

---

## 1. HOME PAGE (/) — consumer

### Nav
How it works · Events · Safety · Organizers · **For organizers** (separated) ·
CTA button: **Get the app**

### 1.1 Hero
- Eyebrow (geo-adaptive slot): `LIVE IN MUMBAI · DELHI · BANGALORE · PUNE · HYDERABAD`
- H1: **Meet first. Match after.**
- Body: Catch is dating built around real events — dinners, social runs, game
  nights, mixers — run by hosts in your city. Book a spot, show up, and hit it
  off in person. Afterwards, privately *catch* the people you met. If they
  catch you back, it's a match.
- Primary CTA: **Get the app** (App Store + Google Play badges, live links)
- Secondary CTA: **Browse events near you**
- Ticket panel: label `THIS WEEK IN MUMBAI` (geo slot) · heading **Events with
  a reason to talk** · status line **Catching opens only after you've met** ·
  chips: Dinner · Social run · Quiz night · Mixer

H1 alternates (pick one, retire the rest):
- "The event comes first. The match comes after."
- "Stop swiping. Start showing up."
- "Real nights out. Real matches."

### 1.2 How it works (replaces "member loop")
- Title: **How Catch works**
- Body: Four steps. One night.

1. **Pick your night** — Dinners, runs, quizzes, mixers: hosted events near
   you, with reviews you can trust. Book in the app.
2. **Show up** — The host runs the room and breaks the ice. Your only job is
   to be there.
3. **Catch, privately** — For 24 hours after the event, pick the people you
   clicked with. Nobody sees your picks.
4. **Match with a memory** — If someone you caught also caught you, a chat
   opens. You're not starting from "hey" — you already met.

### 1.3 Why Catch (replaces "Not another swipe feed" / formats mashup)
- Title: **Everything a swipe can't tell you.**
- Body: Chemistry doesn't screenshot well. Catch puts the meeting before the
  match, so every conversation starts with something real.

Cards:
- **You've already met** — Every match is someone you met in person.
  Their laugh, their timing, their height — verified live.
- **No rejection on display** — Your picks stay private unless they're mutual.
  Shoot your shot with zero audience.
- **A window, not a feed** — Catching lasts 24 hours after each event, and
  only with people who were in the room. When it ends, it ends.
- **Real people, provably** — You can only match with guests who actually
  checked in. Nobody gets catfished by someone they had dinner with.

### 1.4 The night is designed (Event Success — guest view)

The anti-awkwardness section. This answers the biggest unspoken objection to
singles events ("I'll show up and stand in a corner") and carries the core
USP: Catch doesn't just get people into a room — it engineers interactions
once they're in it. Consumer copy uses no brand name for this layer; the
*host* pages brand it as **the Playbook** (naming decision in §2.7 — "Event
Success" is internal-only and never renders publicly).

- Title: **No one stands in the corner.**
- Body: Walking into a room of strangers is the hard part. So every Catch
  event runs on a live playbook the host follows — from the moment you check
  in to the last round — designed so you actually meet people. Not left to
  luck.

Cards (guest point of view):
- **First Hello** — Check in and get pointed straight into your first
  conversation. You're talking to a real person within minutes of arriving.
- **Rotations do the work** — Pairs, tables, and teams reshuffle through the
  night — new faces each round, no cliques, no working the room yourself.
- **Something to talk about** — Prompts, missions, and small-team games give
  every table an easy way in. Small talk gets skipped, not survived.
- **"Help me say hi"** — Spotted someone across the room? Ask the host for an
  introduction from your phone. Only you and the host ever know you asked.

Closing line: Runs stay light — the run itself is the icebreaker. Dinners and
mixers get the full program. The host picks what fits; you just show up.

Title alternates:
- "Showing up is the hard part. We designed the rest."
- "Awkward is a design flaw. We fixed it."

### 1.5 Formats
- Title: **There's an event you'd actually enjoy.**
- Body: Hosts on Catch run all kinds of rooms. Pick your kind of night.

- **Dinners** — One long table, good prompts, a host keeping the conversation
  moving.
- **Social runs** — Easy pace, easy talk. The run is the icebreaker.
- **Quiz & game nights** — Be teammates before you're anything else. The
  fastest way past small talk.
- **Racket socials** — Padel and pickleball with rotating pairs, so you play
  with everyone.
- **Mixers** — Meet everyone in the room in one night, with enough structure
  that it never gets awkward.
- **New formats** — Hosts keep inventing: supper clubs, walks, sunset treks.
  If it gets people talking, it belongs on Catch.

### 1.6 Events near you (discovery section)
- Eyebrow: `THIS WEEK`
- Title: **See what's on in your city.**
- Body: Real events, real hosts, real reviews. Book in the app.
- **Data rule**: only render real, *future* events from the projection feed in
  the visitor's market. If none exist, show: **"New events drop every week.
  Get the app to see what's on in {city}."** with store CTAs — never fixture
  data, never past dates.

### 1.7 Organizer directory teaser
- Eyebrow: `ORGANIZER DIRECTORY`
- Title: **Know your host before you book.**
- Body: Every event on Catch is run by a real organizer — a club, a venue, or
  an independent host — with a public profile, verified guest reviews, and an
  event track record.
- CTA: **Browse organizers**

### 1.8 For-organizers teaser
- Title: **You host the night. Catch handles the rest.**
- Body: Bookings, payments, balanced guest lists, check-in, a live playbook
  that makes the room mix, and proof your event worked. Founding hosts pay 0%
  platform fee for 24 months.
- CTA: **Host on Catch**

### 1.9 App captures
- Title: **One night on Catch.**
- Captions:
  - Discover — "Browse hosted events near you and book in two taps."
  - Catch — "After the event, pick who you'd like to see again. Privately."
  - Host — "Hosts run the room from one screen."

### 1.10 Download
- Eyebrow: `THE CATCH APP` ("member" stays reserved for club membership per
  the taxonomy)
- Title: **Catch is live in India.**
- Body: Download the app to see this week's events in Mumbai, Delhi,
  Bangalore, Pune, and Hyderabad. More cities soon.
- Store badges (live links) + QR code on desktop.
- Missing-link fallback status (build-time only): "Coming to {store} soon."

### 1.11 Safety
- Title: **Built so you can relax.**
- Body: The best nights happen when nobody's on guard. Catch is designed for
  that.

- **Private until mutual** — Nobody ever learns you caught them unless they
  caught you too.
- **Verified by the room** — Every account is phone-verified, and you can only
  match with people who checked in at the event.
- **Balanced, hosted rooms** — Hosts set age ranges and keep the mix balanced,
  and every event has a named host responsible for the room.
- **One tap to block** — Blocking removes someone from your matches, chats,
  and any future event pairings. Reports go to real humans.

### 1.11b Consumer FAQ (added 2026-07-11, Codex review — sits between
Safety and Waitlist)

- Title: **Fair questions.**

- **Is Catch free?** Free to download, browse, catch, and match. You only
  pay for tickets to paid events.
- **Who can see who I catch?** No one. Not the host, not the person — unless
  they catch you too. Then you both find out at once.
- **How long do I have?** 24 hours after the event ends. After that, the
  window closes — there's always another event.
- **What if I don't catch anyone?** Then it was a good dinner. Or a good
  run. No pressure, no streaks, no guilt.
- **Which cities is Catch in?** {live cities from the market pack}. Not
  yours yet? Join the waitlist below and we'll tell you the moment it opens.
- **What if I can't make it after booking?** Every event shows its
  cancellation policy before you book. Cancel in the app; refunds follow
  that policy automatically.
- **What if someone makes me uncomfortable?** Block them in one tap — they
  disappear from your matches, chats, and any future event pairings. Reports
  go to a human. And at the event itself, there's a named host responsible
  for the room.

### 1.12 Waitlist (unopened cities only)
- Title: **Not in your city yet?**
- Body: Tell us where you are. When your city opens, you're first in the door.
- Form: Full name · Email · City · Joining as (*I want to attend events* /
  *I want to host events* / *Both*) · Instagram or community link (optional)
- Button: **Join the list**
- Success: "You're on the list. We'll email you when {city} opens."

### 1.13 Footer
- Tagline: **The event before the match.**
- Product: How it works · Events · Download · Safety
- Organizers: Host on Catch · Directory · Claim your page · Founding offer
- Company: About · Contact · Privacy · Terms · Community guidelines · Refunds

### 1.14 Meta
- Title: `Catch — Meet at real events. Match after.`
- Description: `Catch is the dating app built around real events. Book a
  hosted dinner, run, quiz night, or mixer in your city, meet in person, then
  match with the people you actually met. Live in India.`
- Twitter: `Meet at real events. Match after.`

---

## 2. HOST/ORGANIZER PAGE (/host) — single page

**Consolidation decision**: merge `/host` and `/host/preview` into one page
(this deck). Two near-duplicate host pages split SEO authority and A/B-test
nothing. Keep `/host/preview` as a 301 to `/host/`.

### Nav
How it works · Fill the room · The Playbook · Proof · FAQ · Directory ·
CTA button: **Apply to host**

### 2.1 Hero
- Eyebrow: `FOR CLUBS, VENUES & INDEPENDENT HOSTS`
- H1: **You bring the night. Catch fills it, runs it, and proves it worked.**
- Body: One place for bookings, payments, balanced guest lists, waitlists,
  door check-in — and the Playbook, the live run-of-show that works the room
  with you and proves real connections happened. Founding hosts pay 0%
  platform fee for 24 months.
- CTAs: **Apply as a founding host** · **See how it works**

H1 alternates:
- "Run singles events like it's your full-time job. Even if it isn't."
- "Host singles events people actually follow through on." (current preview
  H1 — acceptable fallback)

### 2.2 Founding offer (directly after hero)
- Title: **Founding hosts pay 0% Catch platform fee for 24 months.**
- Body: Apply for manual approval. Your 24 months start the day your first
  Catch event goes live — not the day you're approved. You keep a public
  Founding Host badge and priority placement in discovery. Payment processor
  fees (Razorpay, Stripe) still apply.
- Steps: Apply → Get approved → Publish your first event → Your 24 months begin

### 2.3 The problem (comparison summary, moved up)
- Eyebrow: `THE HONEST COMPARISON`
- Title: **Announcing an event is solved. Running one is not.**
- Body: You can post the event on Instagram and collect UPI screenshots on
  WhatsApp. What's still hard: keeping the guest list balanced, working the
  waitlist when someone drops, checking people in, warming up a cold room —
  and knowing, actually knowing, whether anyone hit it off.

Cards:
- Label: `Luma · Eventbrite · District · BookMyShow · Instagram + WhatsApp · Forms`
  Title: **They help you publish, sell, or get discovered.**
  Body: Then you're back in DMs and spreadsheets — juggling the ratio, the
  waitlist, the door, and the follow-up.
- Label: `Catch`
  Title: **Catch fills it, runs it, and proves it.**
  Body: The right mix at the door, a run-of-show in your hand, and a report
  that shows attendance, catches, matches, and verified reviews.

### 2.4 How it works (host loop)
- Title: **From draft to debrief.**
1. **Publish in five steps** — Name it, place it, schedule it, set the rules,
   pick your run-of-show. Live with its own booking page.
2. **Fill it, on your terms** — Open booking, invite links, request-to-join,
   age ranges, balanced admission, and waitlists with timed offers. One guest
   list.
3. **Run the night with the Playbook** — Check guests in at the door, then
   let the run-of-show direct the room: welcome script, rotations,
   introductions, countdown reveals — with safety controls one tap away.
4. **See what it created** — Attendance, catches, matches, reviews, repeat
   guests. Numbers, not vibes.

### 2.5 Create-event walkthrough
- Eyebrow: `FROM THE HOST APP`
- Title: **Your event, live in five steps.**
- Body: This is the real create flow: details, venue, schedule — then the two
  steps no ticketing tool has: admission rules and a live run-of-show.
- Keep the existing step fields (Sunday Table Club / Pali Village Cafe / ₹ —
  on-strategy for India). Replace step "outcome" lines:
  - Basics: "A rough idea becomes an event you can reuse."
  - Location: "Guests see the area now, the exact address after booking."
  - Schedule: "Timing drives reminders and check-in automatically."
  - Policy: "Your room, your rules — set before demand shows up."
  - Live guide: "The night has a plan before anyone arrives."

### 2.6 Fill the room (3 modules)
- Eyebrow: `FILL THE ROOM`
- Title: **The guest list runs itself.**

**Balanced admission — "The ratio problem, solved."**
Set the mix you want and Catch enforces it at booking. Straight men and women
stay within one spot of each other — no manual gatekeeping, no "girls free
before 9". Running a queer or mixed-format night? Set the balance that fits
your room — binary ratios are one option, not the rule.
Facts: Preview the room's balance before you publish · Request-to-join when
you want final say on every guest · Age ranges and capacity built in.

**Paid bookings — "Ticket money without screenshot forensics."**
Guests pay in the app. Refunds follow your cancellation policy automatically.
Every payment is attached to a guest on your list — nothing to reconcile.
Facts: Paid, pending, and refunded at a glance · Cancellations release the
spot automatically · Payouts settle after the event completes.

**Waitlists with timed offers — "A waitlist that moves itself."**
When a spot opens, the next guest gets a timed offer. If they pass, it moves
on. No DMs, no double payments, no "is this still available?"
Facts: Offers expire on their own · Movement shows up in your report · The
public count stays honest.

### 2.7 The Playbook (flagship section — keep the stage rail component)

This is the core USP and gets the biggest treatment on the page: Catch
doesn't just fill the room, it creates the interactions and connections
inside it. Keep the existing stage-rail + dual guest/host line component from
`EventSuccessShowcase` — the structure is right; only the copy changes.

**Naming decision (owner-ratified 2026-07-11):** the public name for the
during-event facilitation layer is **the Playbook** (per-format: "the Dinner
Playbook", "the Run Playbook" — this maps 1:1 to the playbook library that
already exists in code). "Event Success" never appears on public surfaces or
in-app UI strings. The internal code name (`lib/event_success/**`,
`eventSuccessPlans`, BigQuery exports, contracts) stays as-is — renaming
storage/contracts is churn with no user value. Consumer surfaces use no brand
name at all; they describe outcomes ("a live playbook the host follows").

**Narrative pyramid (owner-ratified 2026-07-11):** Level 1 = the story below
(provenance → two value modes → control). Level 2 = the stage rail and module
cards. Level 3 = the expanded module details (§2.7a). Elevate/liberate is the
*narrative* axis; chronology (Before → Debrief) stays the *visible* axis
because hosts think in the arc of a night.

- Eyebrow: `THE PLAYBOOK`
- Title: **What the best hosts do by hand, your event does by default.**
- Body (Level-1 story, two short paragraphs):

  Great hosts already know the moves: split runners into pace pods so nobody
  gets dropped, reshuffle the tables between courses, walk a shy guest over
  and make the introduction. They also know the cost — a night spent managing
  the room instead of hosting it.

  The Playbook takes the practices that measurably work — drawn from the best
  hosts on Catch and tested against outcomes we can actually see: check-ins,
  catches, matches, guests who come back — and turns them into modules you
  can drop into any event. Every module is optional — except the safety
  layer. Your format stays yours.

- Two mode cards (directly under the body, before the stage rail):

  **Things you couldn't do by hand.**
  A synchronized countdown reveal. Match clues. A live balance preview. A
  private introduction request. New moments and new information — possible
  only because the whole room is on Catch.

  **Things you shouldn't have to do by hand.**
  Check-in, pace pods, table shuffles, rotations, prompts. The clipboard work
  runs itself, so you're free to do the one thing only a host can: work the
  room.

- Positioning pull-quote: **Anyone can sell twenty tickets. The Playbook is
  how twenty strangers leave having actually met.**

- Title alternates: "Getting people in the room is half the job. Catch does
  the other half too." (previous lead — still strong; usable as the After
  section kicker or in ads.)

- Data-claim calibration: claim the *mechanism* ("tested against outcomes we
  can actually see"), never a volume/statistics claim, until the dataset
  supports it. When it does, graduate to explicit stat callouts — pattern:
  "Rooms that run rotations see __% more mutual matches." Gate every such
  stat on a data pull that can be defended publicly ("auditable" is the
  internal bar; the public sees the number, not the adjective).

Stage rail (Before → Debrief), each with a guest line and a host line.
Presentation rule: guest lines are *designed-experience outcomes*, not
testimonials — render them under a label like "The guest experience", never
in quotation marks with attribution or avatars, so they cannot be mistaken
for customer quotes.

**Before — The room takes shape**
- Guest: "The room feels put together, not random."
- Host: The balance preview shows gaps in mix, pace, and group size while
  there's still time to fix them.

**Arrival — First Hello**
- Guest: "I was in a conversation within minutes of walking in."
- Host: Check-in lands each guest with a real person, not a drink in a
  corner — and you know exactly who's in the room.

**Opening — Welcome script**
- Guest: "Someone gave the room permission to talk."
- Host: A simple script that opens the night well. Written for humans, not
  MCs — you don't need to be a professional to sound like one.

**Mixing — Missions, starter pods, and "help me say hi"**
- Guest: "I could ask the host to introduce me — and nobody knew I asked."
- Host: Small teams with a shared job break the ice without the cringe, and
  quiet, consented requests become your smooth introductions.

**Activity — Rotations & reveals**
- Guest: "I met everyone without working the room."
- Host: Timed partner rotations with no back-to-back repeats, and
  synchronized reveals that give the night its moments. Overrides one tap
  away.

**After — The catch window**
- Guest: "I picked privately. My match started from the night we shared."
- Host: Guests catch privately for 24 hours; matches open with suggested
  openers from the event. Zero admin for you.

**Debrief — The recap**
- Guest: "The next event was better because of this one."
- Host: Check-in rates, mixing coverage, catches, matches, and reviews come
  back as concrete advice for your next event.

Closing guardrail strip (keep the existing `PrivacyGuardrail` component):
**Guardrails are part of the product.** You see coaching, never who caught
whom. Guests can opt out of any live module. Blocked pairs are never assigned
together.

Format note (one line under the rail): Social runs stay light — movement is
the icebreaker. Dinners and mixers can run the full program. Every module is
optional, per event.

#### 2.7a Playbook module catalog — the double-click layer

Hosts must be able to expand any module and understand exactly what it does.
IA: keep the stage rail as the overview, then render this catalog as
expandable cards (the `ProductModuleGrid` facts-card pattern already used in
"Fill the room" supports this) — card front = name + one-liner; expanded =
the "More" body + "Fits" line. Give each card an anchor
(`#playbook-first-hello`) so modules are directly linkable from ads, DMs, and
host onboarding. No separate pages per module (thin-content SEO, maintenance
drag).

Source of truth: `lib/event_success/domain/event_success_playbooks/modules.dart`
(14 modules). Public names below are de-jargoned; internal ids in parens.

Optional mode chips on cards (editorial, from the Level-1 story; several
modules are honestly both — chip the dominant mode, and leave the Safety
layer unchipped, it's the floor):
- `NEW POWER` (couldn't do by hand): Balance preview, Match clues, First
  Hello, Countdown reveals, "Help me say hi", Openers, Guest feedback, The
  recap.
- `OFF YOUR PLATE` (shouldn't have to do by hand): Door check-in, Starter
  pods, Missions, Rotations, Welcome script.

**Balance preview** (`crowd_balance` · Before)
- One-liner: See who the room is missing — while you can still fix it.
- More: As bookings come in, the Playbook shows the shape of the room: the
  mix, age spread, pace and skill gaps, group sizes. You see balance risk
  before approving more guests, and you can point the waitlist at exactly
  what's missing instead of silently rejecting people. Guests never see any
  of these numbers — the room just feels put together.
- Fits: every format.

**Door check-in** (`qr_check_in` · Arrival)
- One-liner: Know who's actually in the room.
- More: Guests check in by QR or with a tap from you at the door. It all
  feeds one attendance record — the same one that unlocks catching, verified
  reviews, and your report. Phones die and people forget; you can always mark
  someone in manually. Check-in is what makes everything after the event
  provable.
- Fits: every format.

**First Hello** (`first_hello_check_in` · Arrival)
- One-liner: Nobody spends their first five minutes alone.
- More: When a guest arrives at the venue, the app hands them one small
  arrival mission: a person to find and a short question to ask. One guided
  first interaction before the room gets moving. Guests can skip or ask for a
  different mission, and you can always check someone in yourself. Blocked
  pairs are never assigned to each other, and nobody's answers or location
  are shown to anyone.
- Fits: dinners, mixers, quiz nights, pickleball. Off by default — turn it on
  when you want arrivals handled.

**Welcome script** (`host_script` · Opening)
- One-liner: Open the night like you've done this fifty times.
- More: A welcome line, a safety note, and a first prompt — short enough to
  deliver from your phone without sounding like you're reading. It's the
  thirty seconds that gives the whole room permission to talk.
- Fits: every format.

**Starter pods** (`micro_pods` · Opening)
- One-liner: Small groups first. Cold-approaching strangers, never.
- More: Guests land in groups of four to six, built on pace, interests, or
  who-came-with-whom — not on hidden matchmaking scores. On runs these are
  **pace pods**, so nobody gets dropped in the first kilometre. If arrivals
  don't match signups, reshuffle in one tap. Guests who came with friends can
  choose to stay together.
- Fits: every format; the default opener for runs and big mixers.

**Missions** (`social_missions` · Mixing)
- One-liner: An easy excuse to start one more conversation.
- More: Three light prompts, specific to your event, that run while the room
  mixes. Optional and deliberately un-performative — no icebreaker theatre —
  and each one hands the conversation back to the night.
- Fits: every format.

**Rotations** (`guided_rotations` · Activity)
- One-liner: Everyone meets everyone. No logistics, no repeats.
- More: Set the round length and number of rounds; the Playbook reshuffles
  pairs, tables, or teams — never back-to-back repeats — and each guest sees
  only where they're going next. You keep override control the whole time.
- Fits: dinners, mixers, quiz nights, racket socials. Movement-heavy events
  save rotations for the pauses.

**Countdown reveals** (`live_reveal` · Activity)
- One-liner: Give the night its moments.
- More: Instead of a buried schedule, the next round lands as a shared
  moment: a synchronized countdown on every phone, an optional clue about the
  person they're about to meet, then the reveal — and the whole room moves at
  once. You run it round by round from the live screen, so the night keeps
  its tension instead of leaking it.
- Fits: dinners, mixers, quiz nights, pickleball.

**Match clues** (`compatibility_questionnaire` · Before)
- One-liner: A reason to talk beyond looks.
- More: An optional, under-ten-question quiz tied to the night's vibe.
  Answers become the clues in countdown reveals and light pairing context —
  presented as conversation starters, never as a chemistry score. Answers
  stay private unless both people chose to share.
- Fits: mixers, dinners, quiz nights. Off by default.

**"Help me say hi"** (`wingman_requests` · Mixing)
- One-liner: Your guests can ask for an introduction. Quietly.
- More: A guest who's spotted someone can ask you for an intro from their
  phone. You see only explicit, opted-in requests, only between checked-in,
  compatible guests — and the other person is never notified. You just do
  what good hosts have always done: walk over and introduce two people.
- Fits: every stationary format.

**Openers** (`contextual_openers` · After)
- One-liner: The first message writes itself.
- More: When a match forms, Catch suggests openers built from the night you
  both had — the team name, the quiz answer, the route, the table debate.
  Either person can ignore them. Zero work for you; better chats for them.
- Fits: every format (automatic).

**Guest feedback** (`decomposed_feedback` · After)
- One-liner: Find out what the night was actually like.
- More: Instead of one blunt star rating, guests answer short private
  questions on the things you can act on: the welcome, the balance, the
  structure, safety, the spark. Individual answers stay private; you see the
  pattern.
- Fits: every format.

**The recap** (`host_analytics` · Debrief)
- One-liner: One or two changes. Not a dashboard.
- More: Check-in rate, how thoroughly the room mixed, catches, matches,
  reviews, repeat guests — condensed into one short brief with a concrete
  recommendation or two. Run events regularly and it tracks your improvement
  over time.
- Fits: every format (automatic).

**Safety layer** (`safety_controls` · always on)
- One-liner: Not a module. The floor.
- More: Blocks and reports are respected in every assignment, reveal, and
  introduction. Guests can opt out of any live module or of visibility
  entirely. Help and report actions are one tap away all night, no drama.
  This is the one part of the Playbook you can't turn off.

Copy-accuracy guardrails for this catalog:
- V1 assignment engines are **pair rotations and starter pods** (per
  `docs/event_success.md`): true seating-chart, team-balancing, and
  court-aware engines are documented future work. Say "pairs, tables, and
  pods" — never "seating charts" or "court scheduling" — until those engines
  ship.
- Never use the internal word "crushes" publicly (it appears in internal
  module promises); the public word is always *catch*.

### 2.8 After the event
- Eyebrow: `AFTER`
- Title: **The part no ticketing tool has.**
- Body: For 24 hours after your event, guests privately catch the people they
  met. Mutual catches become chats. You see what your event created —
  bookings, attendance, catches, matches, reviews — without ever seeing who
  caught whom.
- Pull-quote line: **Your guests' picks stay private. Your results don't.**

### 2.9 Proof (report + ledger)
- Eyebrow: `THE REPORT`
- Title: **Finally, proof your event worked.**
- Body: Every event ends with a report you'd actually screenshot: where demand
  came from, who showed up, and the number no other platform can give you —
  how many guests met someone they want to see again.

Ledger rows:
- **Invite links** — See which channel — Instagram bio, WhatsApp group, a
  friend's share — actually produced paid, checked-in guests.
- **Waitlist** — Watch offers go out, get claimed, or expire, right beside
  your bookings.
- **The night** — Check-ins, rotations completed, and how the room mixed.
- **Outcomes** — Catches, matches, chats, reviews, and who came back for your
  next one.

Example funnel (replace `hostEvidenceMetrics`; numbers must stay coherent —
matches can never exceed what catchers could produce):
`240 link taps → 38 requests → 20 booked → 18 checked in → 12 caught someone →
7 matches → ★4.8 from 15 verified reviews`
Labeling rule: this is sample data and must carry a visible, accessible
label — "Illustrative example — sample data, not observed results" — until
replaced by real anonymized numbers with an evidence record.

### 2.10 Comparison table
Keep the expandable table. Intro line:
"District and BookMyShow are great at discovery and ticket sales in India.
Luma and Eventbrite are great at pages and payments. Catch is built for what
happens between 'sold out' and 'see you at the next one'."

Row labels in plain language:
Publish and sell tickets · Get discovered in an app · Control who gets in
(requests, invites) · Waitlists that fill themselves · Balanced gender ratios ·
Door check-in + live host screen · **In-event facilitation (rotations,
missions, introductions)** · Proof of who actually attended · Private
post-event matching · Reviews only from verified guests · Public organizer
profile · Post-event report

(The facilitation row is new — it's the Playbook row, and it's a clean
sweep: every other column is "No". Add it to `hostComparisonRows`.)

Evidence rule: the expanded table carries a visible "As of {Month Year}"
line, and each non-obvious cell verdict gets a dated internal evidence note
(file: `docs/marketing/comparison_evidence.md`, owner-maintained). Re-verify
before each republish; soften any "No" that a competitor ships.

### 2.11 Trust for hosts
- Title: **Guardrails are part of the product.**
- **Privacy you can promise guests** — You never see who caught whom.
  Aggregate outcomes only — a promise you can make from the mic.
- **Reviews with receipts** — Verified reviews come only from checked-in
  guests. No drive-by reviews from people who never came.
- **Disputes handled where the event lives** — Refunds, cancellations,
  reports, and review disputes sit beside the event — not in your DMs.

### 2.12 FAQ
- **What does founding host access include?** Manual approval, 0% Catch
  platform fee for 24 months from your first published event, a public
  Founding Host badge, and priority placement in discovery.
- **When does the 24-month clock start?** The day your first Catch event is
  published — not the day you're approved.
- **Are there other fees?** Payment processors (Razorpay, Stripe) charge their
  standard rates on paid tickets. Catch adds nothing on top during your
  founding period.
- **What kinds of events can I host?** Dinners, social runs, mixers, quiz and
  game nights, racket socials, walks, venue nights. If it gets singles
  talking, it fits.
- **Can I control who gets in?** Yes: open booking, invite links,
  request-to-join, age ranges, capacity, balanced ratios, and waitlists with
  timed offers.
- **What is the Playbook?** The live run-of-show inside every Catch event:
  check-in that starts conversations, welcome scripts, starter pods, timed
  rotations, countdown reveals, consented introductions, and a recap that
  makes your next event better. You choose how much structure fits your
  format — runs stay light, mixers can run the full program.
- **Do I need to be a professional facilitator?** No — that's the point.
  The Playbook gives you the run-of-show a professional would improvise:
  what to say at the open, when to rotate, how to introduce people. First
  event or fiftieth, the room mixes.
- **Won't guests be on their phones all night?** No. Playbook phone moments
  are short and synchronized — a check-in, a thirty-second countdown, a
  glance at the next table — and then the phones go away. You choose which
  modules run; a dinner can be phone-free from the starter until the reveal,
  and runs keep phone use to check-in and nothing else while you're moving.
- **I already run my events my own way. Will the Playbook get in the way?**
  No — it's built *from* the way good hosts already run things. Pace pods
  scribbled on paper, table shuffles shouted over music: the moves stay
  yours, the frantic part goes away. Every module is optional, per event.
  And if you have a move that works, tell us — the library grows from hosts
  like you.
- **Do I have to run the "dating" part?** No. Catching happens privately in
  the app, after the event, guest to guest. You just host a great night.
- **I already run a club or community. Do I have to move everything?** Start
  with one event. Your Instagram and WhatsApp audience books through your
  Catch page, and your public profile and reviews build from there. Already
  listed in our directory? Claim your page.

### 2.13 Apply
- Title: **Apply once. Publish when approved.**
- Body: Tell us about you and the first event you'd run. We review every
  application by hand — expect a reply within a few days.
- Microcopy fixes in the application flow:
  - "Submit host packet" → **Submit application**
  - Received-state body → "Application received. We review by hand and reply
    by email — usually within a few days."
  - Delete the backend explainer ("…backend callables are host-authenticated")
    → "Once you're approved, you'll get host tools and can publish your first
    event."
  - Keep the current field placeholders (they're good).

### 2.14 Meta
- Title: `Host singles events on Catch | 0% platform fee for founding hosts`
- Description: `Publish your event, balance the guest list, take payments, run
  the night from one screen, and get proof people connected. Catch gives
  clubs, venues, and independent hosts everything after the Instagram post.`

---

## 3. ORGANIZER DIRECTORY (/organizers)

- Title: **Every club, venue, and host running real events.**
- Body: Search by name, city, or format. See verified guest reviews, upcoming
  events, and which organizers are live on Catch.
- Search placeholder: `Search clubs, venues, hosts…`
- Category labels must be humanized (map raw values): `eventOrganizer` →
  "Event organizer", `brand` → "Brand", etc.
- Profile-strength percentages: either label them ("Profile 96% complete") or
  hide them from the public directory. An unexplained "39%" reads as a rating.
- Meta title: `Organizer directory | Catch`
- Meta description: `Find singles-event organizers across India — clubs,
  venues, and independent hosts — with verified guest reviews and upcoming
  events.`

## 4. ORGANIZER LISTING PAGES (/organizers/:listing)

Hero status checklist labels:
- Claimed: Verified owner · Events on Catch · Guest reviews · Event report
  available
- Unclaimed: Built from public sources · Owner not yet verified · No Catch
  events yet · No verified reviews yet

Sections:
- **Events run on Catch** — "Booked, checked in, and reviewed in the app.
  This is {name}'s verified track record."
- **Events from public sources** — "Listed for reference from public pages.
  Catch doesn't handle booking or attendance for these, so they don't count
  toward verified history."
- **Verified guest reviews** — "From guests who checked in at {name}'s Catch
  events."
- **Public reviews** — "Submitted on this page. Useful, but not proof of
  attendance."
- Owner-reply note (claimed): "Owner replies appear beside the review."
  (unclaimed): "Claim this page to reply to reviews."

Claim CTA (unclaimed pages):
- Title: **Is this your page?**
- Body: This profile was assembled from public sources. Claim it to correct
  the facts, reply to reviews, add photos — and publish bookable events with
  Catch host tools.
- Button: **Claim this page**

Claim-unlocks list: Reply to reviews · Correct facts and contact details ·
Add official photos · Publish bookable events with check-in · Show verified
guest reviews · See page views and search stats

Meta (template): `{name} | {city} events & reviews | Catch`

## 5. CLAIM (/claim, /claim/:listing)

- Title: **Claim your organizer page.**
- Body: If you run events, your club or venue may already be listed. Find your
  page, verify you own it, and unlock host tools — including the founding host
  offer.
- Steps: Find your page → Verify ownership → Get host tools
- Meta title: `Claim your organizer page | Catch`

## 6. 404

- Title: **This page never checked in.**
- Body: The link may be old, or the page may have moved.
- Links: Browse events · Organizer directory · Host on Catch
- Meta title: `Page not found | Catch`

## 7. GLOBAL MICROCOPY

- Form validation: human, specific. "That email doesn't look right." /
  "Pick a city so we know where to reach you."
- Waitlist duplicate: "You're already on the list — we'll be in touch."
- Consent banner: "We use a few cookies to see what's working. No ad tracking.
  [Okay] [No thanks]" (verify against actual analytics behavior before
  shipping the "no ad tracking" claim).

## 8. FIXTURE / DEMO-DATA RULES

These caused live embarrassments; enforce as content rules:
1. No internal descriptions in public fixtures (a live card read "…enough
   feedback and matches for the sales report").
2. No past-dated events in "this week" sections; no impossible times
   (a live card showed a 4:30 AM mixer — timezone bug).
3. Demo metrics must be arithmetically coherent (live site showed 11 people
   caught someone but 18 mutual matches).
4. Examples are India-real by default: Indian cities, ₹, Indian venue names.
   No "West Village mixer" next to a Mumbai waitlist.
5. Raw enum values never render (e.g. `eventOrganizer`).

## 9. GEO-ADAPTIVE CONTENT ARCHITECTURE (build note)

`content.ts` already centralizes copy. Split it:
- `content/base.ts` — market-neutral copy (this deck's language).
- `content/markets/in.ts` — market pack: live-city list, currency, store
  links, example events/venues, comparison columns (District/BookMyShow are
  India-pack entries), waitlist city options.
- Every slot marked "geo-adaptive" above reads from the market pack. Adding a
  country later = adding a pack + hreflang, not rewriting pages.
- City landing pages (`/in/mumbai` style) are the natural next SEO surface and
  reuse the same packs.
