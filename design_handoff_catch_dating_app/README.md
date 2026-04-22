# Handoff: Catch — full app UI

## Overview

**Catch** is a dating app for runners. Matching is gated behind shared IRL runs: users join group runs hosted by Run Clubs, and only after showing up do they get access to swipe on other attendees of that same run. This bundle contains hi-fi designs for the entire app — onboarding through messaging — plus a Create Run flow for club hosts, calendar views, and three variants of the Clubs-first home tab.

The target codebase is a **Flutter app** (`catch_dating_app`). It already has a feature-first structure with `go_router`, Riverpod, and Firebase. Models exist for `AppUser`, `Run`, `RunClub`. The designs below should be re-implemented as Flutter widgets following that codebase's patterns.

## About the design files

The files in this bundle are **design references created in HTML + React (JSX)**. They are prototypes showing intended look, layout, typography, color, and interaction — **not production code to copy**. Your task is to recreate them as **Flutter widgets** inside the existing `catch_dating_app` codebase, using its existing theme system, routing (`app_router.dart`), and Riverpod state patterns.

If a design element doesn't map cleanly to an existing Flutter package the codebase already uses, ask before introducing a new dependency.

## Fidelity

**High-fidelity.** Colors, typography, spacing, radii, and component proportions are intentional and should be recreated pixel-accurately. Three palettes and two type systems are defined in `tokens.jsx` — pick **Sunset + Sporty** as the launch defaults unless told otherwise.

## Product primitives (read this first)

Three concentric loops drive the UI. Every screen belongs to one:

1. **Discovery** — browse clubs, follow, see upcoming runs
2. **Commitment** — pick a run, pay, show up, get checked in
3. **Catch** — 24h post-run swipe window → match → chat

Dating functionality is *always* gated behind 1 and 2. The empty-dashboard state and "catches unlock after your first run" copy reinforce this — preserve it.

## Screens (37 total)

All screens are designed at **iPhone 390 × 844**. They render inside a `<Phone>` frame in `index.html`.

### Onboarding (01–07)
- **01 Welcome** — full-bleed hero, tagline, "Get started" CTA
- **02 Phone** — country code + phone, IN +91 default
- **03 OTP** — 6-digit code entry
- **04 Name + DOB** — minimum age 18 copy
- **05 Gender + Interest** — male/female + interested in
- **06 Photos** — 6-slot grid, first is primary
- **07 Pace & preferred distances** — slider 4:00–8:00/km, distance chips

### Home / Dashboard (25, 26)
- **25 Dashboard** — next-run hero with embedded map background, live catches strip (orange callout, closing soon), stride card with weekly bar chart, horizontal "because you ran the 7K" recommendations
- **26 Dashboard empty** — first-open state. Gradient hero CTA + 4-step "how Catch works" list. Profile avatar is dashed outline until first run.

### Home / Runs (08–12)
- **08 Home feed** — vertical list of run cards, filter chips above
- **09 Home map** — full-screen map with pinned runs + bottom card peek
- **10 Run detail** — hero photo, title, stats, roster preview, host bio, join CTA
- **11 Run clubs directory** — list of clubs
- **12 Club detail** — club hero, next runs, members

### Clubs tab — 3 variants (27, 28, 29)
- **27 Variant A — Rows** (Spotify-style): Your clubs scroll · For you scroll · Nearby list. Broad discovery.
- **28 Variant B — Feed**: Avatar chip row (club filter) + chronological runs feed. "What's on this week?"
- **29 Variant C — Directory**: Large cards with cover photo, vibe tags, member count, rating, recent-activity avatars. Best for exploring new clubs.

Pick one as primary; the others can live behind a feature flag.

### Create Run — host stepper (30–35)
Role-gated to club admins. 4 steps + success + manage.
- **30 Step 1 — Basics**: cover upload, title, description, difficulty segmented control, vibe-tag chips
- **31 Step 2 — Route**: map with "Draw route" CTA, distance/elevation readout, meet-point field, pace range dual-slider
- **32 Step 3 — When**: date card with recurring toggle, capacity stepper with waitlist toggle, price pill row (Free/₹199/₹299/₹499/Custom) + Razorpay math
- **33 Step 4 — Review**: summary card + 5-row detail list + "Notify 420 followers" toggle
- **34 Live**: full-bleed gradient success, "3 people already tapped" real-time badge
- **35 Host manage**: booked/waitlist/revenue stat trio, FULL banner, roster with paid/pending chips, waitlist section with avatar stack

### Calendar (36, 37)
- **36 Timeline (day)**: week-strip day picker, vertical hour grid, now-line, event blocks with overflow status (JOINED / INTERESTED / solo dashed)
- **37 Agenda (week)**: stat strip (booked/distance/catches), days stacked with event cards, rest-day dashed placeholder, waitlist position chips

### Catches — post-run (13–16)
- **13 Catches intro** — introduces the 24h window. Shown once per run.
- **14 Swipe card** — photo stack, pace/distance overlay, like/pass buttons
- **15 Match modal** — "It's a catch!" celebration, both photos, CTA to message
- **16 Run recap** — shareable stats, "met someone?" nudge at bottom

### Messaging (17–18b)
- **17 Inbox** — threads list, each opens with run context header
- **18a Chat — bubbles** — standard chat bubbles
- **18b Chat — minimal** — SMS-style inline. A/B candidate.

### Profile (19–21)
- **19 Profile (self)** — your view, pace stats lead
- **20 Profile (other)** — viewing someone else
- **21 Edit profile** — field list

### Settings & utilities (22–24)
- **22 Filters** — pace, distance, gender, age
- **23 Notifications** — activity feed
- **24 Settings** — account, safety, payments

## Component inventory

These are the reusable widgets the codebase needs. Build these **first**; screens assemble from them.

### Cards & rows
- **RunCard** — appears 7+ times in different densities. Props: `density: compact | standard | hero`, `showPrice`, `showRoster`, `state: open | full | waitlist | joined`.
- **ClubCard** — 4 shapes (row tile, horizontal-scroll card, directory card with activity, avatar chip). Same data, variant prop.
- **PersonRow** — roster / waitlist / catches preview / chat list. Avatar + name + meta + optional chip.
- **PersonAvatar** — circular, with optional border ring (match), status dot, stacked overflow ("+7").

### Layout primitives
- **StatusBar** — 390-wide iOS status bar, light/dark aware
- **TopBar** — title + left/right icon slots
- **TabBar** — bottom nav, 5 items: Home · Clubs · Catches · Chats · You
- **IconBtn** — circular 40px icon container
- **Stepper / Progress** — thin orange bar, used in Create Run AND Onboarding (same component)
- **SegmentedControl** — Day/Agenda, Grid/List, pill variants
- **BottomCTA** — sticky footer with one primary button and a white bg

### Content blocks
- **ContextHeader** — "you both ran the Sunrise 7K" — shown at top of chat, match, swipe
- **StatTrio** — 3-column stat row (booked/waitlist/revenue, or runs/distance/catches)
- **MiniMap** — stylized route graphic, not a real map. Use a real map package in the actual app.
- **VibeTag** — uppercase tiny pill, `primarySoft` bg + `primary` text
- **StatusChip** — JOINED / WAITLIST #3 / PENDING / PAID / FULL / INTERESTED

### Form components
- **TextField** (with label above, hint below)
- **StepperControl** (− number +)
- **Toggle**
- **DualRangeSlider** (pace range)
- **PhotoUploadGrid** (6 slots, first is primary)

## Design tokens

All tokens live in `tokens.jsx`. Port these to Flutter `ThemeExtension<CatchTokens>`.

### Palette — Sunset (launch default)
```
bg          #FBF3E9   (warm cream)
surface     #FFFFFF
raised      #FFF8EE
ink         #1A1410   (near-black, warm)
ink2        #5C4A3A   (secondary text)
ink3        #9C8775   (tertiary/placeholder)
line        rgba(26,20,16,0.08)
line2       rgba(26,20,16,0.14)

primary     #FF4E1F   (Catch orange)
primaryInk  #FFFFFF
primarySoft #FFE2D4

accent      #0B3B3C   (deep teal)
gold        #E9A43A

heroGrad    linear-gradient(135deg, #FF4E1F 0%, #FF9A5C 60%, #FFC78A 100%)
```

Dark mode + two other palettes (Street, Editorial) included in `tokens.jsx`.

### Typography — Sporty (launch default)
- **Display**: Space Grotesk, weight 700, tracking -0.02em
- **Text**: Inter, weights 400/500/600/700
- **Mono**: JetBrains Mono (timers, distances)

Editorial variant: Fraunces + Inter. Both should be available as swappable theme.

### Spacing & radii
- Standard padding: 20px horizontal on screens, 16px on cards
- Card radius: 14–18 depending on prominence
- Button radius: 999 (pill)
- Status bar height: 47, tab bar height: 84

## Interactions & behavior

- **Swipe window**: catches for a given run are live for exactly 24h post-run, countdown shown on dashboard callout
- **Run states**: `open` → `filling` → `full` → `waitlist` → `live` (during run) → `recap` (24h post) → `archived`. UI behavior differs per state.
- **Role gating**: `canHostRuns` (club admin) → shows Create FAB + host tools. Not visible to regular runners.
- **Recurring runs**: generate instances; UI shows each instance, not the recurring template.
- **Real-time**: roster count, waitlist position, and catches-remaining should update live (Firestore streams).

## State management

Each feature folder needs:
- A Riverpod provider exposing the data
- A `state` value object (e.g., `RunInstance`, `CatchWindow`, `UserCapabilities`) so widgets render state but never compute it
- Loading / empty / error variants for every list

## Files in this bundle

- `index.html` — main canvas, assembles all screens
- `tokens.jsx` — colors, typography, theme resolver
- `primitives.jsx` — reusable widgets (cards, icons, buttons, etc.)
- `frames/design-canvas.jsx` — design canvas wrapper
- `frames/ios-frame.jsx` — iOS device bezel helper
- `screens/auth.jsx` — onboarding (01–07)
- `screens/home.jsx` — feed, map, run detail, clubs list, club detail (08–12)
- `screens/match.jsx` — post-run catches flow (13–16)
- `screens/messages.jsx` — inbox + two chat variants (17–18b)
- `screens/profile.jsx` — self + other + edit (19–21)
- `screens/misc.jsx` — filters, notifications, settings (22–24)
- `screens/dashboard.jsx` — home/dashboard + empty state (25–26)
- `screens/clubs.jsx` — 3 Clubs-tab variants (27–29)
- `screens/create.jsx` — Create Run stepper + success + host manage (30–35)
- `screens/calendar.jsx` — timeline + agenda (36–37)

## Suggested Flutter folder structure

```
lib/
├── core/
│   ├── theme/            CatchTokens (ThemeExtension), text styles, palettes
│   ├── widgets/          RunCard, ClubCard, PersonRow, Stepper, ContextHeader
│   └── formatters/       pace, distance, relative time, price
├── features/
│   ├── auth/             (existing)
│   ├── onboarding/       split from profile/sign_up
│   ├── dashboard/        new
│   ├── clubs/            rename from runClubs
│   ├── runs/
│   │   ├── browse/       feed + map
│   │   ├── detail/
│   │   ├── calendar/     timeline + agenda
│   │   └── host/         create flow + manage (role-gated)
│   ├── catches/          post-run only
│   ├── messages/
│   └── profile/
├── routing/              (existing)
└── data/
    ├── models/
    ├── repositories/
    └── providers/
```

## Open questions for the implementer

- Which Clubs variant (A/B/C) ships first? Others behind feature flag.
- Calendar: top-level tab or modal from Home? Designs assume modal.
- Mid-run behavior: the app shows nothing during the run. Confirm or design a "quiet mode" tracker screen.
- Host FAB vs. entry-in-tab — pick one before building.

## Implementation order (suggested)

1. Tokens + typography (`core/theme/`)
2. Core widgets (`core/widgets/`) — especially RunCard, ClubCard, PersonRow, TabBar
3. Dashboard (25, 26) — exercises most of the primitives
4. Clubs tab variant A (27) — picks up horizontal scrolls
5. Run detail (10) → Create Run (30–33) → Host manage (35)
6. Onboarding flow (01–07)
7. Post-run: Catches intro (13) → Swipe (14) → Match (15)
8. Messaging (17, 18)
9. Profile + Settings (19–24)
10. Calendar (36, 37) — nice-to-have, last
