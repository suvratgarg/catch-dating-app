---
doc_id: profile_design_parity_spec
version: 1.0.0
updated: 2026-07-05
owner: design_parity_review
status: ready-for-implementation
---

# Profiles — Design Parity Review + Implementation Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`
Design SoT: `~/Downloads/Catch Design System (2)/` — `templates/catch-profile`
composes `ProfileHero · ProfilePhoto · ProfilePrompt · CompatibilityList ·
RunningRhythm · FactList · InfoRow · OptionGroup · PhotoGrid · AppBar`
("the flagship dark hero + sectioned body; preview / public / catches").
Component contracts: `components/profile/*/{*.d.ts,*.jsx}` (no prompt.md
files in this family — the `.d.ts` doc comments are the contract).

Context that shapes this spec: the DS profile components were distilled FROM
the app's flagship surface (the context-pack gallery is app captures), so
parity is already high. This is a verification pass plus one token rename —
not a redesign. Same required workflow as the map/club specs.

## Verified ALIGNED — no work, do not touch

- **`ProfileHeroWidget`** = DS `ProfileHero`: dark register over the 4x5
  graded photo (`ProfilePhoto` + `CatchScrim.heroTint`), activity-pigmented
  uppercase kicker, name block, photo-less fallback through the activity
  art. (P2 verifies the two sub-details below; the architecture stands.)
- **`ProfilePhoto`** = DS "graded profile photo" (CatchGradedImage +
  activity-art fallback).
- **Section widgets** map 1:1: `ProfilePrompt` (mono question + voice
  answer), `ProfileCompatibility` (= CompatibilityList; "Why you might
  click" title with 'Profile signals' fallback, accent-pigmented),
  `ProfileRunning` (= RunningRhythm, accent-pigmented), `ProfileFacts`
  (= FactList).
- **`ProfileTabBar`** composes `CatchOption`/OptionGroup = DS OptionGroup.
- **One shared surface, three contexts**: preview tab, public profile, and
  the catches/swipe view all compose `profile_surface`/`catch_profile_view`
  — matching the DS's single template covering preview/public/catches.
- Both registers exist (light/dark app captures are what the DS gallery
  ships).

## Recorded deviations — keep (review decisions)

- **Insights tab**: app addition beyond the DS's preview/public/catches
  scope. Kept — it is a product surface, not drift. Record in the receipt.
- **Edit tab**: the DS template covers the VIEW surface only; the edit form
  runs on the app's ratified field-row grammar (the flush-contract
  reference implementation). No DS parity work applies.

---

## Work items

### P1. Retire the `sunsetDark` token-set name `[codex]`

The Sunset palette is retired ("do not use beige/cream, a global orange
accent…" — DS README), but the dark-register token set is still named
`CatchTokens.sunsetDark` (used by `ProfileHeroWidget`,
`EventDetailSurfaceStyle.dark`, and others — inventory with `rg`).

1. FIRST verify the set's VALUES are the current dark register (B&W
  editorial), not legacy Sunset values — if any value looks like legacy
  cream/orange, STOP and escalate with the value list; do not rename a
  wrong palette into a right-sounding name.
2. Then rename `CatchTokens.sunsetDark` → `CatchTokens.editorialDark`
  (matching the existing `CatchTokens.editorialLight` naming if present —
  check; otherwise propose the pairing in the receipt), keep a
  `@Deprecated('Use editorialDark')` static alias for one release, migrate
  all usages now, and note the rename in the widget catalog changelog.

### P2. Contract verification checklist `[codex]`

Verify each against the `.d.ts` contract; fix only concrete deltas, and
record "aligned" per line in the receipt:

- **Hero meta strip**: DS ProfileHero renders a mono meta line
  (`"DESIGNER · BANDRA"`) and `"{displayName}, {age}"`. Confirm the app
  hero's name/age/meta lines match (format + mono treatment for meta).
- **Hero kicker**: pigmented by activity, uppercase, mono — confirmed in
  code; just confirm the no-activity fallback stays ink.
- **RunningRhythm**: DS composes StatStrip + Chip with activity pigment on
  title + tag chips. Confirm `ProfileRunning` renders its stats via
  `CatchMetricStrip` (or records why a bespoke layout is used) and its tags
  as chips with the accent.
- **CompatibilityList**: DS composes HintList + Chip — reasons as
  activity-pigmented markers, confidence signals as calm chips. Confirm
  `ProfileCompatibility` matches (markers pigmented, confidence chips
  present when data provides them).
- **FactList**: icon-per-fact rows with section titles ("DETAILS",
  "LIFESTYLE") — confirm `ProfileFacts` titles and glyph usage line up.
- **PhotoGrid**: compare `lib/image_uploads/shared/photo_grid.dart` against
  `components/core/PhotoGrid` (cover affordance, reorder, add tile) — this
  grid also serves onboarding, so fix only clear contract gaps.

### P3. Drift crumbs `[codex]`

While executing P1/P2, apply D1 to any raw dimensions/alphas encountered in
`catch_profile_view.dart` / `profile_surface.dart` (none were flagged in
review, but the files are large; report finds in the receipt).

### Tests + widgetbook

- P1 is rename-only: analyzer + full test suite green; no visual change.
- P2 fixes get focused assertions only where a delta was actually fixed.
- Widgetbook: profile surface states already exist; update names touched by
  P1.

### Acceptance criteria

- No `sunsetDark` references outside the deprecated alias.
- P2 checklist fully receipted (aligned / fixed per line).
- Zero visual changes except P2 deltas explicitly fixed and listed.

### Out of scope

- Any restructuring of the profile surface (it is the flagship and the DS
  source — it leads, the DS follows).
- Edit-tab work (covered by the composition audit + flush contract).
