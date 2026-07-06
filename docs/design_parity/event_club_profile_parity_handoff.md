---
doc_id: event_club_profile_parity_handoff
version: 1.0.0
updated: 2026-07-05
owner: design_parity_review
status: ready-for-implementation
supersedes: explore_map_view_spec, club_design_parity_spec, profile_design_parity_spec
---

# Event / Club / Profile Design Parity — Combined Handoff

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`
Design SoT: `~/Downloads/Catch Design System (2)/` (the 2026-06 ratified
round; `explorations/archived-templates/**` is DROPPED direction — never
implement from it).

This document supersedes and fully replaces `explore_map_view_spec.md`,
`club_design_parity_spec.md`, and `profile_design_parity_spec.md` (now
stubs). All review decisions are made, including the three former club
confirms (resolved 2026-07-05 under the presentation-tier doctrine below).
Do not re-litigate; escalate in receipts only where an item says to.

## Goal-mode contract

Loop until the completion checklist at the bottom is fully checked. Work
parts in order (1 → 2 → 3); within a part, items in order; one commit per
item (pathspecs). Flip each checklist box with the commit hash as you land
it. If an item's precondition fails verification (`rg` first, always),
record an escalation in the receipt, check the box as `[escalated]`, and
continue — never force, never stall the loop.

## Sequencing note — the home/dashboard reorg lands first

`docs/plans/home_live_layer_product_spec.md` is being executed before this
document and touches the same Explore surfaces. Consequences you must
expect (re-read every referenced file fresh; line numbers in this doc are
advisory):

- The dashboard recommended rail moves INTO the Explore feed ("For you"
  cluster). Where this doc says `CatchEventCard.ticket`'s consumer is "the
  dashboard recommended rail," read: the For-you cluster (same
  `RecommendCard`, new home). The variant still stays.
- `buildExploreBodySlivers` gains the For-you cluster and followed-club
  boost; `EventDateRailCard` now receives `FROM A CLUB YOU FOLLOW` kickers
  in the feed; the Explore browse header gains a bookmark action. None of
  this changes the items below, but merge conflicts and moved helpers are
  expected — re-verify before editing, and reuse (do not duplicate) any
  kicker/grouping helpers the home work may have extracted.

## Ratified doctrine for this handoff — presentation tiers

Owner-ratified 2026-07-05 (`design_language.md` §6): every entity material
ships in at least two tiers — a **hero** form (attention, detail, vertical
space) and a **condensed** form (long lists, date-grouped rails). More
tiers where justified; never mix tiers within one list. For this handoff:

- Events: hero = detail ticket surface / `CatchEventCard.ticket` /
  CoverStory; condensed = `EventDateRailCard` (the DS DateTicket).
- Clubs: hero = polaroid hero + `ExploreClubPolaroidCard`; condensed = the
  polaroid **index row** built in item 2.3.

## Required workflow (all parts)

`git status --short` first; read `AGENTS.md`. Per item: verify claims with
`rg`; focused tests + `flutter analyze --no-fatal-infos` on touched files;
widgetbook hand-edits (never regex across `@UseCase` blocks) + build_runner
regen; sequential Flutter runs. Contract changes: `widget_catalog.md`
changelog + version + `doc_versions.json`. Widget deletions: ledger entries
in `docs/design_parity/widget_consolidation/decisions.json` (existing
schema, `decidedBy: "claude-review -> codex"`, status `executed-parity-
handoff`). Finish the whole handoff with full analyze,
`node tool/agent/check_agent_readiness.mjs` (100/100), relevant scanners
(`design:section-headers`, `design:screen-gutters`, `design:rail-contracts`,
sizing), and one `passes.jsonl` stamp per part. Never edit
`packages/catch_ui_lints`.

---

# Part 1 — Events: map view consolidation + build

Why: the map crossed three design rounds. The ratified direction (DS):
"the map answers 'where, relative to my life?' — it doesn't browse… map
becomes a clean full-screen mode behind the pill. Pins carry activity
color, the tappable distance ring stays." And DateTicket: "List form of
the ticket metaphor… Use in date-grouped rails and **the map's
selected-event card**." The app has the ratified skeleton
(`ExploreMapScreen` → full-screen `EventMapView`, activity pins, distance
ring, back float); missing is the selection step, and left over is the
dropped peek-rail direction's machinery.

## 1.A Retire the dropped-direction widgets

Verify each with `rg` before deleting; unexpected production users → stop
that item, escalate in receipt, continue the loop.

- **1.A1 Peek-rail system** (`lib/explore/presentation/widgets/explore_peek_rail.dart`):
  `ExploreMapSheetLead`, `ExploreSelectedEventLead`, `ExploreEventTicketCard`
  + file-local support widgets. No screen mounts them (remaining references:
  `explore.dart` barrel + state types in `explore_screen_state.dart`).
  Delete widgets + file; MOVE still-referenced state/view-model types into
  `explore_screen_state.dart` (e.g. `ExploreMapEventTicketState` — if
  nothing references a moved type, delete it too). Update barrel +
  widgetbook.
- **1.A2 `CatchEventCard.spotlight`**: only production consumer is the peek
  rail. Delete variant + fields + widgetbook states. (`CatchEventCard
  .ticket` STAYS — DS EventTicket, consumed by the For-you cluster.)
- **1.A3 `CatchEventCard.compact`**: zero production users (widgetbook
  only); the condensed-map role belongs to DateTicket. Delete.
- **1.A4 `EventCompactRow`**: zero production users. Delete;
  `EventCompactDatePill` in the same file — delete too if the row was its
  only consumer, else leave + receipt note.
- **1.A5 Ledger** entries for all of the above.

Expected: −5 to −7 public widgets; zero visual change (nothing deleted is
mounted).

## 1.B Build the map selection step

Target anatomy:

```
ExploreMapScreen (route, owns selection)
├── EventMapView (full-screen; loading/error/empty states unchanged)
│     └── EventPinsMap (pins + distance ring + camera)
├── Back float (top-left, unchanged)
└── Selected-event card (NEW — bottom overlay, only while a pin is selected)
      └── EventDateRailCard (the DS DateTicket; condensed tier)
```

- **1.B1 Split selection from navigation.** `EventMapView._selectEvent`
  currently sets `_selectedEventId` AND fires `onEventSelected` (which
  `ExploreMapScreen` uses to navigate immediately). New contract:
  `onEventSelected` fires on pin tap, callers decide; add
  `onSelectionCleared` (VoidCallback?) on background tap while selected
  (add a map-layer `onTap` to `EventPinsMap` if none exists; pin taps must
  not double-fire). `initialSelectedEventId` deep-link behavior (preselect
  + center) is preserved and now ALSO shows the card on first frame. Other
  `EventMapView` consumers (`EventLocationMapScreen`, any others — `rg`)
  keep their current navigate-on-tap behavior at THEIR call sites.
- **1.B2 The selected-event card = `EventDateRailCard`.** In
  `ExploreMapScreen`, on selection render a bottom overlay:
  `Positioned(left/right: 0, bottom: 0)` → `SafeArea(top: false)` → padding
  `CatchInsets.pageBody.copyWith(top: 0)`. Card args: `kicker` =
  `'{CLUB NAME} · {distance}'` when `distanceFromUserLabel` exists else
  club name — REUSE the feed's kicker helper (post-home-reorg location may
  have moved; extract to `lib/events/shared/event_tiles/` if it still
  lives in explore, don't duplicate). `heroTag` =
  `eventTicketHeroTag(event.id, 'map')`. `onTap` = existing `_openEvent`.
  Overlay treatment: the card's own surface + overlay-class shadow; if the
  perforation notches need a background against the map, add ONE optional
  `notchBg`-style param mirroring the DS DateTicket contract — do not fork
  the widget. Motion: in/out via standard tokens (`CatchMotion.fast`,
  match the sheet/dock pattern, respect `disableAnimations`); selecting a
  different pin swaps content; background tap dismisses.
- **1.B3 Pin parity with DS MapPin** (`components/activity/MapPin`):
  resting 26 / selected 38 with an ink flag carrying an uppercase mono
  label (`'{ACTIVITY} · {TIME}'`). Compare
  `lib/events/shared/map_pin_tile.dart`; tokenize raw extents (D1), align
  the flag label format if it differs. Pins remain the only chroma on the
  canvas.
- **1.B4 States.** Loading/error/no-mapped-events/no-pins in `EventMapView`
  are correct — do not change copy or composition. If the selected event
  disappears on feed refresh, clear selection gracefully (card animates
  out, no crash).
- **1.B5 Tests + widgetbook.** Widget tests: pin tap shows card without
  navigating; card tap navigates with the map hero tag; background tap
  dismisses; deep-link preselect shows card on first frame; vanishing
  selection clears. Widgetbook: content, content+selected, both empties;
  delete retired peek-rail/spotlight/compact states. Run explore + events
  suites; strict captures if they cover the map.

Acceptance: pin tap = select (flagged pin + DateTicket card); card tap =
navigate with hero transition; background tap = dismiss; no peek rail or
spotlight anywhere; the map card is byte-identical to the feed's
`EventDateRailCard` (modulo `notchBg`); net widget count negative.

Status: B1/B2/B3/B4/B5 are implemented and covered by focused widget tests,
Widgetbook route states, and DS pin parity checks. B3 closed in `7f6294d04`:
deterministic placeholders render `CatchActivityMapPin`, native Google Map
markers render byte-backed DS pin bitmaps, selected pins use the uppercase
activity/time flag, and selected native markers own z-order.

Out of scope (recorded): dashboard CoverStory moment; the companion
ticket-tear animation (design gap, companion exercise).

---

# Part 2 — Clubs: detail + discovery parity

DS composition (`templates/catch-club-detail`): `ClubHero · ClubDock ·
HostRow · ReviewRow · ContactRow · PhotoStrip · DateTicket · ActivityChip ·
StatStrip · Section · SectionStack · Chip`; contracts under
`components/clubs/*`.

## Verified ALIGNED — no work, do not touch

- `ClubDetailDock` = DS ClubDock (visitor/member/owner states, the one
  sanctioned activity-pigment Join, bell mirroring).
- `StarRating` = DS star rule (filled `ink`, empty `line2`, pigment never
  touches ratings).
- `CatchPolaroid`/`ClubPolaroidArtwork` = DS ClubPolaroid/ClubArt.
- `CatchMetricStrip` = DS StatStrip. One verify: compare against
  `components/core/StatStrip/StatStrip.prompt.md` for divider/typography
  deltas; record "aligned" or a one-line delta — change nothing without an
  exact contract quote.

## Ratified deviations — keep, record in receipt

- `ClubNextRunBanner` (app addition): KEPT — answers "when do I show up
  next" above the fold. Do not remove or propagate without review.
- `ClubContactSection` on `CatchField.nav` rows instead of DS ContactRow
  micro-anatomy: KEPT (the field-row grammar is its own ratified system).
  Carry-over requirements to VERIFY (fix if broken): values render verbatim
  from domain; rows act as real links (Instagram deep link / `tel:` /
  `mailto:`); rows stay ink-only.

## 2.0 Verification Receipt

- `CatchMetricStrip` vs DS `StatStrip`: aligned on the flat bordered row,
  no-ticket treatment, `t.line` border/dividers, mono value role, 2-4 item
  range, and Club Detail's zero-rating em dash. Recorded delta: app labels use
  `CatchTextStyles.supporting` while the DS prompt specifies a 9px mono kicker.
  Leave unchanged here; treat as a future component-contract decision, not a
  Club Detail spot fix.
- `ClubNextRunBanner`: kept as a ratified app addition above the fold; current
  code keeps it as a `CatchSurface` activity-pigment event tile with injected
  navigation and Widgetbook coverage.
- `ClubContactSection`: kept on `CatchField.nav` rows. Verified current code
  renders typed `ClubContactAction` labels verbatim, keeps link side effects at
  the route edge, launches Instagram externally through
  `https://instagram.com/{handle}`, and launches phone/email through `tel:` and
  `mailto:` URIs. Row chrome remains field grammar with ink icons and no
  chevron.

## Work items

- **2.1 Club hero variants (approved 2026-07-05).** DS ClubHero has three
  variants; the app renders only edge-to-edge `full` for every club. New
  default selection in `ClubHeroAppBar`/`ClubHeroModule`:
  - photos → **polaroid** hero (cover photo in the white-mat frame — reuse
    `CatchPolaroid`'s mat construction, do not build a second mat; caption
    slot carries the existing location label);
  - no photos + `logoPhoto` → **masthead** (no media, club name large in
    the voice face, circular logo seal);
  - neither → polaroid with `ClubPolaroidArtwork` media.
  The current full-bleed treatment stays in code as the `full` variant but
  is UNREACHABLE (no domain flag yet) — one-line comment pointing at the DS
  variant + receipt note that wiring it needs a product decision. Keep the
  SliverAppBar mechanics (pinned, expandedHeight math, float actions) —
  content change only. Skeleton mimics the polaroid variant. Before/after
  appshots in the receipt.
- **2.2 Club schedule rows become DateTickets (approved).** Migrate
  `ClubScheduleSection`'s list from `EventAgendaSliverList`/`EventAgendaTile`
  to `EventDateRailCard` rows in the feed's date-rail form (same widget,
  same strip grouping; reuse the feed's grouping/kicker helpers —
  post-home-reorg, re-locate them first; extract shared helpers to
  `lib/events/shared/event_tiles/` if they still live in explore).
  Preserve: host badge behavior (`HOSTED`/`VIEW`, `statusBuilder`), empty
  state, section title, `onEventSelected`. Agenda widgets keep their other
  consumers (calendar, saved events) — do NOT touch those surfaces; if club
  schedule was the only sliver consumer, receipt-note it, don't delete
  shared widgets here.
- **2.3 Discovery rows: condensed polaroid index row (amended
  2026-07-05).** Two-tier resolution of the old "polaroids everywhere"
  item: the directory is a LONG LIST and gets the condensed tier, not tall
  cards. Build ONE condensed club row — working name `ClubIndexRow` — that
  carries the polaroid material cues in dense row anatomy: small white-mat
  polaroid thumbnail (mini `CatchPolaroid` mat or a matted thumb derived
  from it — no third mat implementation), name, activity chip, mono meta
  line. Replace `ClubListTile` in the directory with it (inventory every
  `ClubDiscoverList`/`ClubListTile`/`buildClubDirectorySlivers` mount
  first). `ExploreClubPolaroidCard` remains the club HERO tier for
  featured/spotlight contexts — untouched. Never mix tiers in one list.
  Skeletons (`ClubDirectorySkeletonCard/List`) mimic the new row. If
  `ClubListTile` ends up orphaned, delete + ledger.
- **2.4 Host row seal color.** `ClubHostSection` seals the owner with
  `t.primary`; DS HostRow: owner seals with the **activity accent**. Use
  `ActivityPalette.resolve(context, club.hostDefaults.primaryActivityKind)
  .accent` (match the club's other accent resolutions). Verify the meta
  line is mono, pre-uppercased, middot-separated (`"OWNER · EST. JAN
  2025"`); align the formatter if it differs (reuse the established-label
  helper from club_detail_body).
- **2.5 Drift crumbs.** `reviews_section.dart` `StarRating(rating: …,
  size: 14)` raw 14 → nearest token (D1; escalate a name if none exact);
  check the file for sibling raw star sizes. NOTE: the reviews surface may
  have been flattened by the containment work (N1) by the time you get
  here — re-locate the star sizes wherever review rows now live.
  `create_club_photos_picker.dart` vs DS ClubPhotos: verify cover
  affordance on first photo, camera badge on the logo square, add tile
  exists; fix only concrete contract gaps.

Tests + widgetbook: hero variant selection tests (photos → polaroid;
logo-only → masthead; neither → art polaroid) + per-variant widgetbook
states + skeleton; schedule renders date-rail rows with preserved
badge/status/empty behavior; directory renders the index row; K4/K5
focused assertions where cheap. Run clubs + explore + reviews suites.

Acceptance: club detail composes the DS list with the two recorded
deviations; clubs ship exactly two tiers (hero polaroid card + index row);
one polaroid system, one ticket system; all gates green.

Out of scope: calendar/saved-events agenda surfaces; the `full` hero
variant's product trigger; the dense-list escalation path (resolved by 2.3).

## 2.1 Verification Receipt

- `ClubHeroAppBar` now resolves ClubHero defaults from domain media state:
  `club.primaryClubPhotoUrl` (including legacy `imageUrl`) → polaroid,
  logo-only (`logoPhotoUrl`) → masthead, neither → polaroid artwork. The
  resolver never returns `ClubHeroVariant.full`.
- `ClubHeroModule` owns the explicit `ClubHeroVariant` rendering contract.
  The polaroid path delegates the mat to `CatchPolaroid`; the masthead path
  uses the large club name plus circular `CatchPersonAvatar` logo seal; the
  retained `full` path preserves the prior curved `CatchDetailHeroBackdrop`
  treatment for Widgetbook review only until product defines a domain trigger.
- `ClubHeroLoadingSkeleton` now mimics the polaroid/card shape instead of the
  old full-bleed block.
- Widgetbook coverage now includes default sliver states for photo polaroid,
  logo masthead, and art polaroid, plus module states for those three and the
  unreachable full review variant.
- Appshot proof (local capture artifacts; `artifacts/ui-captures/` is ignored
  by git): before capture
  `artifacts/ui-captures/full-catalog/club_detail_member/light.png` shows the
  old full-bleed hero. After captures are stored under
  `artifacts/ui-captures/club-hero-2-1/` for `club_detail_member` and
  `club_detail_loading` in light/dark.
- Verification: `flutter test test/clubs/club_hero_app_bar_test.dart
  --reporter expanded`; `flutter test test/clubs/club_share_card_test.dart
  --reporter expanded`; `flutter test test/clubs/clubs_flow_test.dart
  --plain-name "detail screen shows club-shaped skeleton while live data
  loads" --reporter expanded`; focused app/test analyzer; Widgetbook analyzer;
  `node tool/ui_capture/run_captures.mjs --ids
  club_detail_member,club_detail_loading --device design-phone --output-dir
  /tmp/catch-club-hero-2-1-captures`; `node tool/run.mjs check --category
  design`.
- Aggregate design-gate cleanup: the check exposed stale generated/registry
  state outside this slice. `catch.activity_map_pin` design-token contracts were
  added to the DTCG token source and regenerated; the Explore map no-exact-pin
  branch was downgraded from captured to implemented because it has Widgetbook
  coverage but no pixel capture; Dashboard Home's screen contract was updated to
  match the current full-body sections; route inventory and the design context
  pack were regenerated.

## 2.2 Verification Receipt

- `ClubScheduleSection` no longer routes its upcoming-event list through
  `EventAgendaSliverList` / `EventAgendaTile`. It groups schedule rows by day
  and renders direct `EventDateRailCard` DateTickets with the same strip
  position semantics used by Explore's weekly rail.
- Shared event tile atoms now own the reusable mapping rules:
  kicker/supporting labels, badge-to-status mapping, day grouping/labels, and
  strip-position calculation. Explore and agenda surfaces call those helpers
  instead of duplicating private rules.
- Preserved behavior: the `CatchSection.divided` Schedule title still renders;
  empty club schedules still use the compact inline empty state; consumer
  schedule rows still suppress the old `VIEW` badge; host schedules still show
  `HOSTED`; `onEventSelected` still receives the tapped event.
- Agenda widgets were intentionally kept for their other consumers. Calendar
  and Saved Events still use `EventAgendaSliverList` / `EventAgendaTile`, with
  their grouping/status logic delegated to the shared helpers.
- Widgetbook now has `ClubScheduleSection` coverage for upcoming events,
  same-day strip grouping, hosted events, member empty, and host empty states.
- Verification: `flutter test test/clubs/club_schedule_section_test.dart
  --reporter expanded`; `flutter test test/explore/explore_widgets_test.dart
  --plain-name "ExploreEventsSection shows enough top recommendations by day"
  --reporter expanded`; `flutter test test/events/events_widgets_test.dart
  --plain-name "agenda list sorts events and forwards selected-event taps"
  --reporter expanded`; `flutter test test/events/events_widgets_test.dart
  --plain-name "agenda list renders provided club names in global context"
  --reporter expanded`; focused app analyzer; Widgetbook club-use-case
  analyzer; widget variant/classification/new-widget scanners; widget cleanup
  scanner.

## 2.3 Verification Receipt

- Explore club directories now render one condensed `ClubIndexRow` tier rather
  than the retired tall `ClubListTile`/directory-card family. The row keeps the
  approved polaroid material cue as a small white-mat `ClubImage` thumbnail,
  then renders club name, activity `CatchBadge`, uppercase mono
  location/member meta, and membership trailing state.
- `ExploreClubPolaroidCard` remains untouched as the high-emphasis spotlight
  tier; no long-list directory mixes tall polaroid cards with dense rows.
- `ClubDiscoverList` / `buildClubDirectorySlivers` now own detail-route
  navigation explicitly and render `ClubIndexRow` entries. `ClubAvatarRail`
  now composes `AvatarChip` directly instead of routing through
  `ClubListTile`.
- `ClubListTile`, `ClubListTileVariant`, and the tall directory-card internals
  were deleted from live code and Widgetbook: `DirectoryCard`,
  `DirectoryClubCard`, `ClubPhotoMediaOverlay`, `ClubPhotoChrome`,
  `ClubLogoCrest`, `ClubLogoFallback`, `ClubDirectoryFooter`,
  `ClubHostActionRow`, and `ClubRule`. The consolidation ledger records those
  deletes while keeping `AvatarChip`, `ClubImage`,
  `MembershipTrailingController`, and `MembershipTrailing`.
- `ClubDirectorySkeletonCard` / `ClubDirectorySkeletonList` now mimic the
  condensed row skeleton. Joined directory state is visible as a compact
  `Joined` badge instead of relying on a tall-card sash.
- Widgetbook replaced the old tile-state use case with `ClubIndexRow` states
  for photo/joined, fallback/joinable, and logo-backed clubs; generated
  Widgetbook refs were refreshed.
- Verification: focused app analyzer for the changed club/explore/test files;
  `flutter test test/explore/explore_widgets_test.dart --plain-name
  "ClubIndexRow" --reporter expanded`; `flutter test
  test/explore/explore_widgets_test.dart --plain-name "club index row"
  --reporter expanded`; `flutter test test/clubs/clubs_flow_test.dart
  --plain-name "club taps navigate with the required route param" --reporter
  expanded`; Widgetbook club-use-case analyzer; widget variant inventory +
  check; Widgetbook contract refs; widget classification + check; new-widget
  inventory check; widget cleanup scanner.

## 2.4 Verification Receipt

- `ClubHostSection` now resolves the club's primary activity through
  `ActivityPalette.resolve(context, club.hostDefaults.primaryActivityKind)` and
  passes that accent into `ClubHostRow` as the owner seal color. The owner seal
  no longer uses `t.primary`.
- Club established-date formatting moved into the shared
  `clubEstablishedLabel` helper. Club stats and host rows now reuse the same
  `JAN 2025` style label instead of keeping a private stats-only formatter.
- `ClubHostRow` remains provider-free: standalone callers pass
  `ownerSealColor` and `establishedLabel` explicitly. Its meta lane is now the
  mono, pre-uppercased, middot-separated role/date copy (`OWNER · EST. JAN
  2025`, `HOST · EST. JAN 2025`); profile viewing and messaging stay separate
  affordances.
- Widgetbook `ClubHostRow` states were updated to pass the explicit activity
  accent and established label, and catalog version `2.5.600` records the API
  contract change.
- Verification: focused analyzer for changed club-detail/test/Widgetbook files;
  `flutter test test/clubs/club_host_section_test.dart --reporter expanded`;
  `flutter test test/explore/explore_widgets_test.dart --plain-name
  "ClubDetailBody shows host identity without opening a dating profile"
  --reporter expanded`; `flutter test test/explore/explore_widgets_test.dart
  --plain-name "ClubDetailBody shows multiple hosts and messages a host"
  --reporter expanded`; `flutter test test/explore/explore_widgets_test.dart
  --plain-name "ClubDetailBody host view stays a public club profile"
  --reporter expanded`; `flutter test test/explore/explore_widgets_test.dart
  --plain-name "HostClubManagementPanel and metric strip show computed values"
  --reporter expanded`; Widgetbook club-use-case analyzer; widget
  classification/check; new-widget inventory check; widget cleanup scanner.

## 2.5 Verification Receipt

- Review aggregate stars and per-review card stars now use the design-system
  `CatchIcon.rating` role instead of raw `12` / `14` icon sizes. The sibling
  `StarRatingPicker` remains intentionally large and tappable.
- `CreateClubPhotosPicker` already routed through `OrderedPhotoPicker` for the
  needed club photo contract: standard empty add tile, edit-strip first-photo
  `COVER` affordance, edit-strip add tile while under max photos, and
  `CreateClubProfileImagePicker.editLogo` bottom-right add/edit badge.
  No picker implementation delta was needed.
- Added focused contract coverage in
  `test/clubs/create_club_photos_picker_test.dart` for the standard
  `Add club photos` tile, edit-strip `COVER` + `Add photos` affordances, and
  logo-square add badge semantics.
- Verification: `flutter analyze --no-fatal-infos
  lib/reviews/shared/reviews_section.dart
  lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart
  test/clubs/create_club_photos_picker_test.dart`;
  `flutter test test/clubs/create_club_photos_picker_test.dart --reporter
  expanded`; `flutter test test/explore/explore_widgets_test.dart
  --plain-name "CreateClubScreen picks and previews club photos" --reporter
  expanded`; raw review-star-size `rg` scan; widget classification/check;
  new-widget inventory check; widget cleanup scanner; full `node tool/run.mjs
  check --category design`.

---

# Part 3 — Profiles: verification pass + token rename

Context: the DS profile components were distilled FROM the app's flagship
surface — the app leads, the DS follows. This is a verification pass, not
a redesign. Contracts: `components/profile/*/{*.d.ts,*.jsx}` (doc comments
in the `.d.ts` files are the contract; no prompt.md in this family).

## Verified ALIGNED — no work, do not touch

`ProfileHeroWidget` = DS ProfileHero (dark 4x5 graded photo +
`CatchScrim.heroTint`, activity-pigmented uppercase kicker, name block,
activity-art fallback). `ProfilePhoto` = graded photo. Sections map 1:1:
`ProfilePrompt`, `ProfileCompatibility` ("Why you might click" + accent),
`ProfileRunning` (accent), `ProfileFacts`. `ProfileTabBar` composes
CatchOption/OptionGroup. One shared surface serves preview/public/catches.
Both registers ship.

## Recorded deviations — keep

Insights tab (app addition; product surface, not drift). Edit tab (the
app's ratified field-row grammar; DS covers the view surface only).

## Work items

- **3.1 Retire the `sunsetDark` token-set name.** The Sunset palette is
  retired but the dark-register token set is still named
  `CatchTokens.sunsetDark` (`rg` the usages: profile hero, event detail
  dark style, more). FIRST verify the set's VALUES are the current dark
  register (B&W editorial) — if any value looks like legacy cream/orange,
  STOP and escalate with the value list. Then rename →
  `CatchTokens.editorialDark` (pair with `editorialLight` if it exists —
  check; else propose the pairing in the receipt), keep a
  `@Deprecated('Use editorialDark')` alias for one release, migrate all
  usages, catalog changelog entry.
- **3.2 Contract verification checklist** — verify each against the
  `.d.ts`; fix only concrete deltas; receipt one line per row
  (aligned/fixed):
  - Hero meta strip: mono `"DESIGNER · BANDRA"` line + `"{displayName},
    {age}"` format.
  - Hero kicker no-activity fallback stays ink.
  - RunningRhythm: stats via `CatchMetricStrip` (or receipt why bespoke) +
    tags as accent chips.
  - CompatibilityList: reasons as activity-pigmented markers + confidence
    chips when data provides them.
  - FactList: icon-per-fact rows, section titles ("DETAILS", "LIFESTYLE").
  - PhotoGrid vs `components/core/PhotoGrid` (cover affordance, reorder,
    add tile) — the grid also serves onboarding; fix only clear contract
    gaps.
- **3.3 Drift crumbs.** D1 on any raw dimensions/alphas encountered in
  `catch_profile_view.dart`/`profile_surface.dart` while executing;
  receipt the finds.

Acceptance: no `sunsetDark` references outside the deprecated alias; 3.2
fully receipted; zero visual changes except explicitly fixed deltas.

Out of scope: restructuring the profile surface (it is the flagship and
the DS source); edit-tab work (composition audit + flush contract own it).

## 3.1 Verification Receipt

- Verified the retired `sunsetDark` alias already pointed at the current B&W
  dark register, not a legacy cream/orange palette. Current dark token values:
  `bg #0F0E10`, `surface #18171A`, `raised #211F23`, `overlay black@72%`,
  `ink #F4F0E8`, `ink2 #BAB2A7`, `ink3 #7E776D`, `line paper@13%`,
  `line2 paper@22%`, `primary #F4F0E8`, and `primaryInk #16140F`.
- Resolved the API naming conflict by moving fixed absolute overlay colors from
  `CatchTokens.editorialDark` / `CatchTokens.editorialLight` to
  `CatchTokens.editorialBlack` / `CatchTokens.editorialWhite`. The token-set
  names are now `CatchTokens.editorialLight` and `CatchTokens.editorialDark`.
- Deprecated `CatchTokens.sunsetLight` / `CatchTokens.sunsetDark` for one
  release and migrated production, test, and Widgetbook callers to the
  editorial token-set names. Source audit now finds `sunsetLight` /
  `sunsetDark` only in the deprecated alias definitions.
- Catalog version `2.5.601` records the token-set rename and fixed-color split.
- Verification: `dart run tool/design_tokens.dart --check`; focused app/test
  analyzer for renamed call sites (`--no-fatal-infos`, no errors/warnings; 61
  pre-existing Event Success infos); Widgetbook analyzer for changed use cases;
  `flutter test test/core/catch_primitives_test.dart --reporter expanded`;
  small token-expectation test files for top bar, dashboard, payments, safety,
  and swipes; EventPhotoHeader named tests; and the passing
  `ClubDetailBody host view stays a public club profile` token case. Three
  exploratory Explore hero/layout tests fail before the token assertions on
  stale hero keys/layout expectations, so they were not used as proof for this
  rename.

---

# Completion checklist (goal mode — flip with commit hashes)

Part 1 — Events/Map
- [x] 1.A1 peek-rail system deleted (types re-homed) (3e4274430)
- [x] 1.A2 spotlight variant deleted (3e4274430)
- [x] 1.A3 compact variant deleted (3e4274430)
- [x] 1.A4 EventCompactRow (+DatePill if orphaned) deleted (3e4274430)
- [x] 1.A5 ledger entries recorded (3e4274430)
- [x] 1.B1 selection/navigation split (other consumers preserved) (6254440c8)
- [x] 1.B2 DateTicket selected card (kicker helper reused, notchBg if needed) (6254440c8)
- [x] 1.B3 pin parity vs DS MapPin (tokens, flag label) (7f6294d04)
- [x] 1.B4 refresh-safe selection (6254440c8)
- [x] 1.B5 tests + widgetbook states (selected-card/no-exact-pin coverage; DS pin parity covered by 1.B3) (6254440c8, 7f6294d04)
Part 2 — Clubs
- [x] 2.0 aligned/deviation verifies receipted (StatStrip delta, contact links) (0747b0021)
- [x] 2.1 hero variants (polaroid default, masthead, unreachable full) + skeleton + appshots (`0b39a5793`)
- [x] 2.2 schedule DateTickets (badges/empty/nav preserved) (`257b52d8a`)
- [x] 2.3 ClubIndexRow condensed tier + directory migration + skeletons (+ ClubListTile ledger if orphaned) (`04c213d50`)
- [x] 2.4 owner seal = activity accent + meta format (`8e3958b71`)
- [x] 2.5 star-size token + ClubPhotos contract check (`0e24e097f`)
Part 3 — Profiles
- [ ] 3.1 sunsetDark → editorialDark (values verified first)
- [ ] 3.2 verification checklist receipted line-by-line
- [ ] 3.3 D1 crumbs receipted
Finish
- [ ] full analyze clean; readiness 100/100; scanners green
- [ ] widget_catalog + doc_versions + passes.jsonl stamps per part
- [ ] consolidation ledger updated for every widget deletion
