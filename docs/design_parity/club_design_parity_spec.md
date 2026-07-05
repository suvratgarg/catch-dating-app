---
doc_id: club_design_parity_spec
version: 1.0.0
updated: 2026-07-05
owner: design_parity_review
status: ready-for-implementation
---

# Clubs — Design Parity Review + Implementation Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`
Design SoT: `~/Downloads/Catch Design System (2)/` — `templates/catch-club-detail`
composes `ClubHero · ClubDock · HostRow · ReviewRow · ContactRow · PhotoStrip ·
DateTicket · ActivityChip · StatStrip · Section · SectionStack · Chip`;
component contracts under `components/clubs/*`.

Same review protocol as the map spec: decisions below are made; verify claims
with `rg` before changing; escalate in receipts only where instructed. Same
required workflow (AGENTS.md, pathspec commits, sequential Flutter runs,
focused tests + analyzer per item, widgetbook hand-edits + regen, catalog/
doc_versions/passes stamps, readiness gate at the end).

## Verified ALIGNED — no work, do not touch

- **`ClubDetailDock`** = DS `ClubDock` (visitor/member/owner states, the one
  sanctioned activity-pigment Join, bell mirroring notifications) — the 2026-07
  rebuild already encodes the contract.
- **`StarRating`** = DS ReviewRow star rule (filled `ink`, empty `line2`,
  pigment never touches ratings) — the rule is even in the code comment.
- **`CatchPolaroid` / `ClubPolaroidArtwork`** = DS `ClubPolaroid`/`ClubArt`
  (the DS documents ClubArt as matching these app widgets).
- **`CatchMetricStrip`** = DS `StatStrip` (core). One verify: compare the
  app's strip against `components/core/StatStrip/StatStrip.prompt.md` for
  divider/typography deltas; record "aligned" or a one-line delta in the
  receipt — change nothing without an exact contract quote.

## Ratified deviations — keep, record in the receipt (review decisions)

- **`ClubNextRunBanner`** is an app-side addition (not in the DS club-detail
  composition). KEPT: it answers "when do I show up next" above the fold and
  the DS hero already leans on next-event location for its label. Do not
  remove; do not propagate further without review.
- **`ClubContactSection` on `CatchField.nav` rows** instead of the DS
  ContactRow micro-anatomy (mono channel eyebrow over value). KEPT: the
  app's field-row grammar is its own ratified system; forcing the DS row
  anatomy here is churn without user value. Requirement that DOES carry
  over from the DS contract: values render verbatim from the domain, rows
  act as real links (Instagram deep link / `tel:` / `mailto:`), and rows
  stay ink-only. Verify those three hold; fix if not.

---

## Work items

### K1. Club hero variants `[confirm]` — polaroid default + masthead

DS `ClubHero`: three variants — **`polaroid`** (default; white-matted inset
frame, the club material), **`full`** (edge-to-edge media, "photography-
forward clubs"), **`masthead`** (no media; optional circular logo seal from
`Club.logoPhoto` — "the quietest cut"). The app's `ClubHeroAppBar`/
`ClubHeroModule` renders ONE treatment: edge-to-edge
`CatchDetailHeroBackdrop` — i.e. only the `full` variant, applied to every
club.

Decision (pending owner confirm — visible change): the DEFAULT becomes the
DS default:

- Club has photos → **polaroid** hero: the cover photo inside the white-mat
  polaroid frame (reuse `CatchPolaroid`'s mat construction — do not build a
  second mat), caption slot carrying the existing location label.
- No photos, has `logoPhoto` → **masthead**: no media, club name set large
  in the voice face, circular logo seal.
- No photos, no logo → polaroid with `ClubPolaroidArtwork` (ClubArt) media.
- The current full-bleed treatment remains as the `full` variant in code but
  becomes UNREACHABLE for now (no domain flag distinguishes "photography-
  forward"); leave a one-line comment pointing at the DS variant and record
  in the receipt that wiring it needs a domain/product decision.

Keep the existing SliverAppBar mechanics (pinned, expandedHeight math,
float actions) — this changes the flexible-space CONTENT, not the app-bar
architecture. Update the club hero skeleton to mimic whichever variant the
loading state assumes (polaroid). Capture before/after appshots for the
receipt.

### K2. Club schedule rows become DateTickets `[confirm]`

DS composes `DateTicket` for the club-detail schedule; DateTicket's own
prompt: "List form of the ticket metaphor… Use in date-grouped rails."
The app renders `EventAgendaSliverList`/`EventAgendaTile` instead.

Migrate `ClubScheduleSection`'s event list to `EventDateRailCard` rows in
the date-rail form the Explore feed uses (same widget, same strip grouping —
reuse the feed's grouping/kicker helpers from `explore_event_rows.dart`
rather than duplicating them; extract shared helpers to
`lib/events/shared/event_tiles/` if they currently live in explore).
Preserve: the schedule's host badge behavior (`HOSTED`/`VIEW`,
`statusBuilder`), empty state, section title, and `onEventSelected`
navigation. `EventAgendaTile`/`EventAgendaSliverList` keep their other
consumers (calendar, saved events) — this spec does NOT touch those
surfaces; if the club schedule was `EventAgendaSliverList`'s only sliver
consumer, note it in the receipt but do not delete shared widgets here.

### K3. Discovery club rows — polaroids everywhere `[confirm]`

DS ClubPolaroid: "Clubs keep the polaroid material everywhere… events are
tickets, clubs are polaroids, people are plain cards." The discovery
directory renders `ClubListTile` rows (non-polaroid). First inventory where
`ClubDiscoverList`/`ClubListTile`/`buildClubDirectorySlivers` actually
mount (explore directory; anywhere else?). Then migrate the directory rows
to `ClubPolaroid`-material cards (reuse `ExploreClubPolaroidCard` or
compose `CatchPolaroid` directly — do not create a third polaroid wrapper).
If a surface genuinely needs a dense index row (long lists), STOP on that
surface and record an escalation proposing a "polaroid index row" hybrid
instead of shipping a mixed treatment. Skeletons
(`ClubDirectorySkeletonCard/List`) update to mimic the polaroid shape.

### K4. Host row seal color `[codex]`

`ClubHostSection` seals the owner with `color: t.primary`; DS HostRow:
"`role="owner"` seals the name with the **activity accent**." Change the
seal color to the club's primary activity accent
(`ActivityPalette.resolve(context, club.hostDefaults.primaryActivityKind)
.accent` — match how the club's other accent usages resolve it). While
there, verify the meta line matches the DS format
(mono, pre-uppercased, middot-separated: `"OWNER · EST. JAN 2025"`); align
the formatter if it differs, reusing the club-established label helper from
club_detail_body if applicable.

### K5. Drift crumbs `[codex]`

- `reviews_section.dart:210` — `StarRating(rating: …, size: 14)`: raw 14.
  Use the nearest CatchIcon/size token (escalate a token name per D1 if
  none is exact); check the file for sibling raw star sizes.
- `create_club_photos_picker.dart` vs DS `ClubPhotos`: verify the first
  photo carries a visible COVER affordance (chip/label), the logo square
  carries the camera badge, and an add tile exists. Fix only concrete gaps
  against the prompt contract; record "aligned" otherwise.

### Tests + widgetbook

- K1: hero variant selection tests (photos → polaroid; logo-only →
  masthead; neither → art polaroid); widgetbook states per variant;
  skeleton mimic updated.
- K2: schedule renders date-rail rows with preserved badge/status/empty
  behavior; club-detail tests updated.
- K3: directory renders polaroid material; explore tests updated.
- K4/K5: focused assertions where cheap; otherwise covered by suites.
- Run clubs + explore + reviews focused suites; strict captures if they
  cover club detail.

### Acceptance criteria

- Club detail composes exactly the DS list (hero variant + dock + host rows
  + review rows + contact rows + photo strip + DateTicket schedule + stat
  strip + sections), with the two recorded deviations.
- One polaroid system, one ticket system — no new wrappers introduced.
- All gates green; receipts, catalog changelog, ledger entries for any
  widget deletions.

### Out of scope

- Calendar/saved-events agenda surfaces (K2 explicitly excludes them).
- The `full` hero variant's product trigger (recorded, needs domain input).
- Profiles — next exercise after clubs lands.
