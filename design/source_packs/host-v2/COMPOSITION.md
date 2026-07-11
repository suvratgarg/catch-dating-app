# Catch Design System — Composition Map

> A component-by-component breakdown of what every catalogue component is **built from** — referencing only other design-system components, constants, and shared helpers. Type classes (`t-*`) and tokens (`--*`) are the shared foundation under *everything* and are not re-listed per entry.
>
> **Purpose:** a single place to see how the system fits together, and to catch any screen or component that hand-rolls something the catalogue already provides. Findings from this pass are at the bottom.

## Legend

- **Composes:** — the DS components this one renders internally.
- **Uses:** — DS constants / shared helpers it calls (not components).
- **Primitive** — composes no other DS component; built directly from tokens + type classes (+ Phosphor glyphs). These are the leaves of the system.

---

## Foundation — constants & shared helpers

These are the non-component internals everything else is keyed to. They are bundle-internal (lowercase / data), not `window`-exposed components.

| Internal | Source | What it is |
|---|---|---|
| `ACTIVITY_KINDS` | `activity/kinds.js` | The registry: each activity → label, glyph, `accent` / `deep` / `soft` pigments. The single source of activity truth. |
| `ACTIVITY_ORDER` | `activity/kinds.js` | Canonical ordering of the activity kinds. |
| `getActivity(id)` | `activity/kinds.js` | Resolver → an activity descriptor from `ACTIVITY_KINDS`. The one sanctioned way to pull pigment/glyph. |
| `initialsOf(name)` | `core/avatar.js` | Derive 1–2 uppercase initials from a name. |
| `avatarGradient(activity)` | `core/avatar.js` | The `linear-gradient(150deg, accent, deep)` avatar fill. **Uses** `getActivity`. |
| `avatarBox({…})` | `core/avatar.js` | The shared avatar circle (photo under `.catch-grade`, or initials on a fill). **Uses** `initialsOf`. |
| `TONES` / `toneColor(tone)` | `core/tones.js` | Functional tone → CSS-var color (success / warning / danger / gold / neutral / solid). Shared by `Badge` and `RosterTiles`. |

---

## Activity

| Component | Composition |
|---|---|
| **ActivityArt** — generative art-first activity backdrop | **Uses** `getActivity`. Primitive otherwise. |
| **ActivityAvatar** — initials on the activity gradient (chroma counterpart to PersonAvatar) | **Uses** `getActivity`. |
| **ActivityChip** — typed activity tag (glyph + pigment) | **Uses** `getActivity`. |
| **MapPin** — activity-pigmented map marker | **Uses** `getActivity`. |
| **DistanceRing** — concentric distance viz | **Primitive.** |

---

## Core

| Component | Composition |
|---|---|
| **Button** — pill action control | **Primitive.** |
| **IconButton** — circular glyph target | **Primitive.** |
| **Chip** — static tag | **Primitive.** |
| **Badge** — status pill (functional tones; `size="action"`, optional `icon`) | **Uses** `toneColor`. |
| **Kicker** — tracked mono eyebrow | **Primitive.** |
| **SearchField** — pill search input | **Primitive.** |
| **ExpandingSearch** — magnifier that animates into a search field | **Primitive.** |
| **TextField** — labelled form input | **Primitive.** |
| **CodeInput** — OTP digit row | **Primitive.** |
| **OptionGroup** — segmented selector (+ built-in filter affordance) | **Primitive.** |
| **Menu** — anchored dropdown list | **Primitive.** |
| **InfoRow** — on-surface list row | **Primitive.** |
| **InfoGroup** — on-surface row group | **Composes** Kicker. |
| **StatStrip** — flat data pairs | **Primitive.** |
| **Section** — codified section rhythm (kicker + body) | **Composes** Kicker. **Uses** `getActivity`. |
| **SectionStack** — page-body gutter wrapper | **Primitive.** |
| **SectionLabel** — activity-accent eyebrow (glyph + mono) | **Primitive** (accent passed in). |
| **ScreenBody** — scroll region with standard gutters | **Primitive.** |
| **AppBar** — screen header (compact + large) | **Composes** IconButton, ExpandingSearch. |
| **StepHeader** — wizard header (back + step + progress) | **Composes** AppBar. |
| **TabDock** — bottom navigation | **Primitive.** |
| **StatusBar** — phone status row | **Primitive.** |
| **Sheet** — bottom-sheet scaffold (grab handle + header) | **Composes** Badge. |
| **ConfirmDialog** — centered confirm modal (owns scrim) | **Composes** Button. |
| **Panel** — surface card (bounded counterpart to hairlines) | **Primitive.** |
| **SoftBand** — quiet tinted inset row | **Primitive.** |
| **SelectChip** — selectable pill (stateful Chip) | **Primitive.** |
| **PrivacyBadge** — outlined who-can-see pill | **Primitive.** |
| **EmptyState** — centered no-results placeholder | **Primitive.** |
| **PhotoGrid** — photo upload grid | **Primitive.** |
| **Toggle** *(settings)* — switch | **Primitive.** |
| **RangeSlider** *(settings)* — range control | **Primitive.** |

---

## Events

| Component | Composition |
|---|---|
| **EventTicket** — event card | **Composes** ActivityArt. **Uses** `getActivity`. |
| **EventHero** — event detail hero | **Composes** IconButton, ActivityArt. **Uses** `getActivity`. |
| **DateTicket** — date-rail list form | **Uses** `getActivity`. |
| **TicketStub** — torn-stub confirmation | **Primitive.** |
| **MapCard** — map block | **Composes** MapPin. |
| **BookingDock** — sticky book bar | **Composes** Button. **Uses** `getActivity`. |
| **HostCard** — single-host surface | **Composes** Button. **Uses** `getActivity`. |
| **AvatarStack** — "who's going" row | **Uses** `avatarBox`, `avatarGradient`, `getActivity`. |
| **HintList** — what-to-expect list | **Uses** `getActivity`. |
| **MechanismList** — how-it-works list | **Uses** `getActivity`. |
| **Itinerary** — timed run-of-show | **Uses** `getActivity`. |
| **JourneySteps** — numbered step flow | **Primitive.** |
| **PhotoStrip** — horizontal photo rail | **Uses** `getActivity`. |

---

## Clubs

| Component | Composition |
|---|---|
| **ClubArt** — generated club cover | **Uses** `getActivity`, `ACTIVITY_KINDS`, `ACTIVITY_ORDER`. |
| **ClubHero** — club detail hero (chrome optional) | **Composes** ClubArt, IconButton. |
| **ClubPolaroid** — feed-level club card | **Composes** ClubArt. |
| **ClubDock** — stateful membership dock | **Composes** Button, IconButton. **Uses** `getActivity`. |
| **ClubPhotos** — logo + cover-photo uploader | **Primitive.** |
| **HostRow** — multi-host roster row | **Composes** IconButton. **Uses** `avatarBox`, `avatarGradient`, `getActivity`. |
| **ContactRow** — club contact channel row | **Primitive.** |
| **ReviewRow** — member review row | **Uses** `avatarBox`, `avatarGradient`, `getActivity`. |

---

## Profile

| Component | Composition |
|---|---|
| **ProfileHero** — profile header | **Uses** `getActivity`. |
| **ProfilePhoto** — graded profile photo | **Uses** `getActivity`. |
| **ProfilePrompt** — prompt + answer block | **Primitive.** |
| **FactList** — labelled fact rows | **Primitive.** |
| **CompatibilityList** — shared-signal list | **Composes** HintList, Chip. |
| **RunningRhythm** — cadence stat panel | **Composes** StatStrip, Chip. **Uses** `getActivity`. |

---

## Messaging

| Component | Composition |
|---|---|
| **PersonAvatar** — photo / mono-initials avatar | **Uses** `initialsOf`. |
| **ChatBubble** — message bubble | **Primitive.** |
| **ChatComposer** — message input bar | **Primitive.** |
| **ChatThreadHeader** — event-context band | **Uses** `getActivity`. |
| **ConversationTopBar** — thread app bar | **Composes** PersonAvatar. |
| **ChatListTile** — inbox row | **Composes** PersonAvatar. |

---

## Hosting

| Component | Composition |
|---|---|
| **RosterRow** — roster board row | **Composes** Badge, Button. **Uses** `avatarBox`. |
| **RosterTable** — roster board shell (3-col, empty state) | **Composes** RosterRow *(passed as children)*. |
| **RosterTiles** — selectable count-tile filter row | **Uses** `toneColor`. |
| **RotationCard** — live rotation card | **Composes** Badge, Button. |
| **LiveConsole** — host run console | **Composes** Badge, Button. |

---

## Dashboard

| Component | Composition |
|---|---|
| **DashboardEventCard** — next-event card | **Composes** Badge. **Uses** `getActivity`. |
| **QuickActions** — shortcut tile grid | **Primitive.** |
| **StrideCard** — running-stride stat card | **Primitive.** |

---

## Explore

| Component | Composition |
|---|---|
| **CoverStory** — dark tonight cover (carries status bar) | **Composes** StatusBar. **Uses** `getActivity`. |
| **CrossPathsCard** — "crossed paths" card | **Uses** `getActivity`. |
| **CountPill** — count chip | **Primitive.** |

---

## Booking

| Component | Composition |
|---|---|
| **CheckoutSheet** — payment handoff sheet | **Composes** Sheet, Badge. |
| **ConflictSheet** — time-conflict sheet | **Composes** Sheet. **Uses** `getActivity`. |
| **Celebration** — confirmation "moment" surface | **Primitive.** |

---

## Notifications

| Component | Composition |
|---|---|
| **NotificationRow** — activity feed row | **Primitive** (type → glyph + accent, self-contained). |

---

## Findings — deviations & cleanup candidates

This pass confirmed the catalogue is consistent — every composite sources its avatars, pigments, headers, and actions from the shared components/helpers. Notes:

1. **`RosterTiles` tone map — FIXED.** It previously re-declared the same `{ success, warning, danger, gold, neutral, solid } → CSS var` object that lived inside `Badge`. Extracted to a shared `toneColor(tone)` / `TONES` helper (`core/tones.js`, sibling to `getActivity`); both `Badge` and `RosterTiles` now use it — the same consolidation move as `avatarBox`. No tone map is duplicated anymore.

2. **Leaf components verified, not hand-rolling.** `QuickActions` (shortcut grid), `ContactRow` (contact-fact row), `RosterTiles` (count tiles), `StrideCard`, `JourneySteps`, `FactList`, `ProfilePrompt`, and `NotificationRow` each render bespoke `<button>`/row markup, but each is a genuinely distinct pattern with no existing catalogue equivalent — correct to keep as primitives, not deviations.

No *component* was found hand-rolling another component. The screen-level audit below surfaced two screens hand-rolling `StatusBar` (one fixed, one flagged).

---

## Templates — per-screen composition

Every template (`templates/<slug>/`), the DS components it composes, and any hand-rolling caught. `StatusBar` + the 390×812 bezel are on every screen and assumed; only deviations are flagged.

> **Reflects the 2026-06 reorg slugs.** Surface prefixes: `catch-*` consumer · `hosts-*` host · `social-*` media. Superseded screens are archived to `explorations/archived-templates/` (listed at the end). The full feature → screen → widget map is **`APPS.md`**.

### Catch (consumer) — `templates/catch-*`

| Template | DS components composed |
|---|---|
| **catch-explore** | CoverStory, ClubPolaroid, CrossPathsCard, DateTicket, CountPill, OptionGroup, TabDock |
| **catch-dashboard** | AppBar, CoverStory, DashboardEventCard, EventTicket, JourneySteps, QuickActions, StrideCard, StatusBar, TabDock |
| **catch-event-detail** | EventHero, TicketStub, Itinerary, HostCard, AvatarStack, MapCard, HintList, MechanismList, PhotoStrip, BookingDock, Section, SectionStack |
| **catch-club-detail** *(was club-detail-v2)* | ClubHero, ClubDock, HostRow, ReviewRow, ContactRow, PhotoStrip, DateTicket, ActivityChip, StatStrip, Section, SectionStack, Chip |
| **catch-profile** | AppBar, ProfileHero, ProfilePhoto, ProfilePrompt, CompatibilityList, RunningRhythm, FactList, InfoRow, OptionGroup, PhotoGrid, StatusBar |
| **catch-messaging** | AppBar, ConversationTopBar, ChatThreadHeader, ChatBubble, ChatComposer, ChatListTile, StatusBar |
| **catch-notifications** | AppBar, NotificationRow, StatusBar |
| **catch-settings** | AppBar, InfoRow, RangeSlider, Chip, Button, StatusBar |
| **catch-booking** | ConflictSheet, CheckoutSheet, Celebration, StatusBar |
| **catch-onboarding** *(was onboarding-v2)* | StepHeader, TextField, CodeInput, PhotoGrid, Chip, Button, StatusBar |

### Catch Hosts — the lifecycle app — `templates/hosts-*`

These compose the redesign widgets promoted in the 2026-06 round (`NextUpHero`, `NeedsYouQueue`, `EventLifecycleRow`, `MetricGrid`/`StatCard`, `TrendStrip`, `OrganizerHeader`, `BlastComposer`, `FacePile`, `SegPill`, `DateRangePicker`). `(→ X)` = mounted inside the preceding widget.

| Template | DS components composed |
|---|---|
| **hosts-today** | StatusBar, NextUpHero (→ FacePile), NeedsYouQueue, EventLifecycleRow, TabDock |
| **hosts-events** | StatusBar, SegPill, EventLifecycleRow, Button, EmptyState, TabDock |
| **hosts-inbox** | StatusBar, SegPill, ChatListTile, Sheet (→ BlastComposer), TabDock |
| **hosts-organizer** | StatusBar, OrganizerHeader, Callout (→ Button), MetricGrid, StatCard, TrendStrip, InfoGroup, InfoRow, PersonAvatar, Badge, TabDock |
| **hosts-manage** | StatusBar, SegPill, MetricGrid, StatCard, InfoGroup, InfoRow, RosterTable, RosterRow, LiveConsole |
| **hosts-insights** | StatusBar, MetricGrid, StatCard, SegPill, EventLifecycleRow, Callout (→ Button), Sheet (→ DateRangePicker) |

### Catch Hosts — flows (re-homed) — `templates/hosts-*`

| Template | DS components composed |
|---|---|
| **hosts-create-event** | StepHeader, TextField, PhotoGrid, Toggle, Chip, Badge, Button, IconButton, Celebration, StatusBar |
| **hosts-create-event-success** | Celebration, ScreenBody, StatusBar |
| **hosts-edit-event** | AppBar, InfoGroup, InfoRow, TextField, Chip, Badge, Button, StatusBar |
| **hosts-create-club** | StepHeader, TextField, ClubPhotos, Toggle, Chip, Button, StatusBar |
| **hosts-edit-club** | AppBar, ClubPhotos, InfoRow, Button, StatusBar |
| **hosts-add-host** | Sheet, TextField, Button, StatusBar |
| **hosts-draft-picker** | Sheet, IconButton, Button, StatusBar |
| **hosts-payouts-handoff** | Sheet, Button, StatusBar |
| **hosts-dialogs** | ConfirmDialog, StatusBar |

### Social media — `templates/social-*`

| Template | Notes |
|---|---|
| **social-feature-drop** · **social-feature-drop-hosts** | Export-true 1080×1350 Instagram carousels on Catch tokens/type — frame-composed marketing media, not app screens. See `SOCIAL.md`. |

### Archived (superseded → `explorations/archived-templates/`)

The old club-shaped host tabs — **host-events** (AppBar, Menu, ActivityChip, Badge, InfoRow, ScreenBody, TabDock), **host-clubs** (AppBar, Menu, ClubHero, HostRow, ActivityChip, Badge, Button, DateTicket, InfoRow, OptionGroup, ScreenBody, Section, StatStrip, TabDock), **host-event-manage** (AppBar, LiveConsole, RosterTable, RosterRow, RosterTiles, RotationCard, ContactRow, OptionGroup, SearchField, Badge, Button, IconButton, Section, SectionStack), **host-account** (AppBar, InfoRow, OptionGroup, TabDock), **host-inbox** (AppBar, ChatListTile, EmptyState, OptionGroup, TabDock) — plus **club-detail** (ClubHero, HostCard, DateTicket, StatStrip, Section, Button, Chip), **onboarding** (StepHeader, TextField, CodeInput, PhotoGrid, Chip, Button), **explore-redesign** (⚠️ composes no catalogue component), and the **host-create-event-v2** / **host-create-club-v2** redesign studies. Reasons in `explorations/archived-templates/README.md`.

### Findings — template level

3. **`booking` hand-rolled `StatusBar` ×4 — FIXED.** Each screen (conflict / payment / confirmation) inlined the `9:41` + signal/wifi/battery row instead of composing `StatusBar`. Swapped all to `<StatusBar>` (z-index preserved on the two over-hero screens). The per-screen audit is what surfaced this — the component-level pass couldn't.

4. **`explore-redesign` composes zero catalogue components ⚠️.** It hand-rolls the status bar across all 7 frames and builds its cards/heroes inline rather than from `CoverStory` / `EventTicket` / `DateTicket` / etc. It predates most of the system and reads as a stale redesign exploration. **Recommendation:** either recompose it onto the catalogue (sizeable — ~1200 lines, 7 frames) or retire it (the shipping Explore is `templates/explore`). Flagging for your call rather than rewriting unasked.

5. **`host-flatten` is leftover scratch.** The flatten exploration was folded into the real `host-events` / `host-clubs` templates; it can be deleted.

---

## React app — `catch-website` type audit

The marketing/host website (`catch-website/`) is a React app: pages (`home`, `directory`, `listing`, `claim`, `host`, `host-create`, `host-success`, `notes`) + shared components (`shared.jsx`). It already **consumes** the DS bundle (`Button`, `Chip`, `Badge`, `ActivityArt`, `EventTicket`, `ReviewRow`) and loads `colors_and_type.css` — so the full `t-*` scale + tokens are available. But `site/site.css` hand-rolls a **parallel type scale** in bespoke classes instead of using `t-*`. That's the variation to clean.

### Finding A — a dozen+ mono/data labels duplicate one role at drifting sizes

Every one of these is `var(--font-data)`, weight 600–700, uppercase — i.e. the `t-kicker` / `t-mono-label` / `t-meta` / `t-badge` role — but each re-declares it at a slightly different size/tracking:

| Class | size / tracking | DS equivalent |
|---|---|---|
| `.kick` | 11 / 0.16em | **exactly `t-kicker`** |
| `.see-all` | 11 / 0.12em | `t-kicker` |
| `.org-card .next` | 11 / 0.04em | `t-kicker` |
| `.org-card .statline` | 11 / — | `t-mono-label` |
| `.searchbar .city-btn` | 12 / 0.08em | `t-kicker` |
| `.sr-row .sr-meta` / `.footer .fm` | 10.5 | `t-meta` |
| `.badge` `.claim-link` `.or-head` `.cmp-table th` `.mock-bar .t` `.step-node .sl` `.field label` `.spec-row .k` | 10 / 0.1–0.12em | `t-mono-label` (9px) / `t-badge` |
| `.stat-cell .l` / `.diag-item .fix` | 9.5 | `t-meta` / `t-badge` |
| `.mock-pill` | 9 / 0.08em | **exactly `t-badge`** |

That's **six distinct sizes (9 · 9.5 · 10 · 10.5 · 11 · 12)** for what is really two roles (an 11px kicker + a ~9px micro-label).

### Finding B — voice headings off the DS scale

DS voice scale is 44 · 32 · 26 · 20 · 18. The site adds: `.section-head h2` **30** (mobile **24**), `.note-block h3` **21**, `.org-card .name` **19**. (`.wordmark` 26 = `t-headline-s` ✓, `.org-mono` 20 = `t-title-l` ✓.)

### Finding C — body sizes off the 13/14/16 scale

`12.5px` (`.org-card .cat`, `.mock`, `.mr-name`, `.cc-s`) and `13.5px` (`.or-text`) — should snap to 13/14.

### Consolidation — DONE
1. **Mono labels → two sizes.** The six label sizes (9 · 9.5 · 10 · 10.5 · 11 · 12) are collapsed to **two**: 11px (kicker tier) and 10px (micro tier). `.city-btn` 12→11; `.sr-meta` / `.footer .fm` 10.5→10; `.stat-cell .l` / `.diag-item .fix` 9.5→10; `.mock-pill` 9→10. Class names kept (no JSX churn), specs normalized in `site.css`.
2. **Voice headings snapped** to the scale: `.section-head h2` 30→32 (mobile 24→26), `.note-block h3` 21→20, `.org-card .name` 19→20.
3. **Body snapped** to 13/14: `12.5`→13 (×4), `13.5`→14.

Done entirely within `site.css` (class names preserved), so the eight page `.jsx` files needed no edits and nothing broke. Remaining `font-size` values in the file are icon glyphs (19/21px) and the mobile bottom-tab label (9px) — not type roles. Net: the website's type scale went from ~6 mono sizes + 3 off-scale headings + 2 off-scale body values down to the DS-aligned scale.
