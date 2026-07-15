---
doc_id: ui_elevation_implementation
version: 2.2.1
updated: 2026-07-15
owner: ui_elevation_initiative
status: active — mechanical execution checklist for implementing agents
---

# UI Elevation — Implementation TODO (self-contained)

Execution-ready checklist for implementing the locked Catch design language, written so an
agent with **no prior conversation context** can do the work. Read top-to-bottom before
touching code. Pairs with [`design_language.md`](design_language.md) (the *why*); this doc is
the *how*.

## Current state (2026-05-31)

| Phase | Status |
|---|---|
| **Phase 0** — encode identity (tokens, fonts, B&W palette) | ✅ **DONE** |
| **Typography fidelity** (2026-05-30) — bundled variable fonts + optical-sizing engine (`CatchFonts` drives `FontVariation('opsz'/'wght')` from point size); type scale consolidated 59→~30 with w600 display, zero tracking, uppercase mono labels, and matte-duotone grade | ✅ **DONE** |
| **Phase 1a** — `ActivityPalette` + palette-owner routing + photo grade | ✅ **DONE** — palette-owners re-derived from tokens, `context:` dark-threading complete, raw-color sweep now covered by Catch UI analyzer lints |
| **Phase 1b** — sizing/constraint doctrine + Dynamic Type | ✅ **DONE** — scanners green; capture walk completed at text scale 1.0/1.5/2.0; ticket/notch visual spot-check passed |
| **Phase 1c** — motion spec | ✅ **DONE** — shared CatchMotion transition/haptic helpers extracted and routed through live surfaces |
| **Phase 1d** — anti-drift token gate | ✅ **DONE** — Catch UI analyzer lints cover raw `Color`/`Colors.*`/`TextStyle(`/`GoogleFonts` drift with `// token:allow:` continuity |
| **Phase 2** — flagship Profile | ✅ **DONE** — `ProfileSurface` is shared by Catches, profile preview, and public profile; `CatchProfileView` has golden coverage; legacy tests reconciled; `relationshipGoal` restored as "Looking for"; preview-tab nested scroll targets the flagship `CustomScrollView`. |
| **Phase 3** — rollout to par | ✅ **DONE** — onboarding, dashboard/profile, clubs, chat/matches, settings/payments/calendar, image uploads, and event-success surfaces were rolled forward; `explore_concept` retired |

Phase-0 deferral resolved: optical sizing **is** wired — the three identity fonts are bundled
(`assets/fonts/`) and `CatchFonts` drives `FontVariation('opsz'/'wght')` (auto optical size from
point size). `eventDisplay` still keeps `FontStyle.italic` by default (the ticket-metaphor look).

**Reusable agent prompts** for the mechanical sweeps (hand to a cheaper model; the matching
gate is the deterministic definition of done): [`sizing_migration_prompt.md`](sizing_migration_prompt.md)
(→ `check_sizing.sh`) and [`design_token_migration_prompt.md`](design_token_migration_prompt.md)
(→ Catch UI analyzer lints / `check_catch_ui_lint_drift.sh`).

**Visual QA + regression:** the [UI capture pipeline](plans/ui_capture_pipeline_plan.md) — one
deterministic harness, two consumers (raw review PNGs + curated marketing media) — reuses the
golden harness (`matchCatchGolden` in `test/goldens/support/golden_pump.dart`) and is the path to
per-screen visual review. It pairs with [`marketing_app_media_pipeline.md`](marketing_app_media_pipeline.md)
(website sync).

## 0. Read first (in this order)

1. [`docs/design_language.md`](design_language.md) — locked identity. **Source of truth.**
2. [`PROJECT_CONTEXT.md`](../PROJECT_CONTEXT.md) — architecture, routes, gotchas.
3. [`docs/app_architecture.md`](app_architecture.md) — layout/spacing/sliver/scroll rules.
4. [`docs/widget_catalog.md`](widget_catalog.md) — existing primitives (large; read per-surface).

## 1. Hard guardrails (do not break these)

- **Do NOT rename `CatchTokens` / `ActivityPalette` roles.** ~483 call sites read
  `CatchTokens.of(context).<role>`. Change **values**, never field names.
- **Do NOT add `custom_lint`**; the package is archived and Catch UI rules belong in the
  local `analysis_server_plugin` package at `packages/catch_ui_lints`.
- **`flutter analyze` is authoritative.** Don't hand-edit generated `*.g.dart`/`*.freezed.dart`.
- **`build_runner` only after annotation/model changes.** Token/font/color/widget edits don't need it.
- **Preserve the sophisticated atoms — re-grade, don't replace:** ticket perforation + notch
  clipper, `EventClockMark`, rotated activity stamp, club hero viewport clipping, collapsing
  sliver headers, Hero card→detail transitions. These are the quality bar.
- **Keep the activity-visual API stable:** `EventActivityVisualSpec`, `EventActivityBackdrop`,
  `eventActivityVisual(kind, {context})`. Change colors/source, not shape.
- **Theming is centralized.** Colors in `catch_tokens.dart`/`activity_palette.dart`/`app_theme.dart`;
  fonts in `catch_fonts.dart`/`catch_text_styles.dart`. Fix at source, not call sites.
- **Both light and dark correct at every step** (`ThemeMode.system`).
- Branch hygiene before committing: `docs/release_operations.md`.

## 2. How to run / verify

```bash
flutter analyze                                       # must stay clean
flutter test --concurrency=1                          # serialized (documented isolation issue)
./tool/flutter_with_env.sh dev run                    # run the app (dev env)
cd widgetbook && flutter run -d chrome                # canonical re-skin proof surfaces
```
Visual QA every touched screen in **light + dark** at **text scale 1.0 / 1.5 / 2.0**.

**Automated visual gate:** `flutter test test/goldens` runs the golden harness (deterministic
light/dark renders of the design system; regen with `--update-goldens`). See
[`test/goldens/README.md`](../test/goldens/README.md). Add component goldens as surfaces stabilize.

---

# PHASE 0 — ENCODE THE IDENTITY ✅ DONE

As-built reference (already in the tree; do not redo):

- **`CatchTokens`** (`lib/core/theme/catch_tokens.dart`): `sunsetLight`/`sunsetDark` now hold the
  B&W base. Light: `bg #F4F4F1`, `surface #FFFFFF`, `ink #16140F`, `primary #16140F` (ink action),
  `line` ink@8%. Dark: `bg #0F0E10`, `ink #F4F0E8`, `primary #F4F0E8`. No brand accent; `heroGrad`
  deprecated (ink gradient).
- **`app_theme.dart`**: `_seedColor #16140F`; ink/paper button pills; `appBarTheme`/`_textTheme`
  stay platform system font (functional fallbacks).
- **Type** (`catch_fonts.dart`/`catch_text_styles.dart`): display/titles → **Archivo**;
  data/kickers/numerics → **IBM Plex Mono**; functional UI + `bodyL/bodyM` → **platform system font**; new
  **`proseL`/`proseM`** (Archivo) for editorial reading text. `bodyL/M` stayed platform system font so
  functional controls (`CatchField`, `CatchSelectMenu`, `city_picker.dart`) don't go serif —
  Phase 3 migrations swap editorial copy to `proseL/M`.
- **Removed** the standalone identity/card executable labs. Re-skin review now
  lives in Widgetbook foundation and component-contract surfaces;
  `lib/labs/design_fixtures/**` remains an actively imported fixture library,
  not a pending lab application.
- `EventPolicyLabScreen` and `EventSuccessLabScreen` remain active dev/staging
  routes with Widgetbook and test coverage. They live in their owning feature
  folders and are not retired standalone lab applications.
- Native/brand surfaces (Android splash, web manifest/index, Razorpay theme) updated off the old
  orange.

---

# PHASE 1 — FOUNDATION (re-skin proof + scaling + anti-drift)

## Task 1a — `ActivityPalette` + route palette-owners + photo grade  🟡 PARTIAL

**Goal:** flipping `CatchTokens`/`ActivityPalette` re-skins the *entire* app — zero stranded hex
outside a documented allowlist.

### ✅ Already landed (in tree, compiles clean)
- **`lib/core/theme/activity_palette.dart`** — `ActivityPalette` `ThemeExtension` + `ActivitySwatch`.
  Single editable `pigments` map (16 mid-tones); light/dark `ActivitySwatch` derived via HSL
  (`deep` = −13% lightness, `soft` = mode-aware tint, dark `accent` lifted +7%). `forKind(kind)` +
  `ActivityPalette.of(context)` (falls back to `light` if extension missing — safe for bare tests).
- **`app_theme.dart`** — registers `ActivityPalette.light/dark` in `_build` `extensions` per `colorScheme.brightness`.
- **`event_activity_visuals.dart`** — `eventActivityVisual(kind, {BuildContext? context})` sources
  colors from `ActivityPalette` (light fallback when no context); label/pattern via `_activityMeta`;
  `EventActivityBackdrop` gradient is now a duotone (`accent → deep`), candy 3-stop removed.

### ⬜ 1a-i — Thread `context:` into production callers (dark-awareness)
Each call below currently uses the light fallback; add `context: context` (all are in a
`build(context)`). The `explore_concept` sandbox wrapper stays context-free (retired in Phase 3).

| File | approx line | change |
|---|---|---|
| `lib/core/widgets/catch_event_activity_cards.dart` | 49, 206 | `eventActivityVisual(activityKind, context: context)` |
| `lib/core/widgets/catch_event_thumbnail.dart` | 81 (`_ActivityFallback.build`) | add `context: context` |
| `lib/events/presentation/widgets/event_tiles/event_date_rail_card.dart` | 51 | add `context: context` |
| `lib/events/presentation/widgets/event_tiles/event_compact_row.dart` | 35 | add `context: context` |
| `lib/events/presentation/widgets/event_detail_hero_app_bar.dart` | 196 | add `context: context` |
| `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart` | 136 | add `context: context` |

**DoD:** event/club cards show dark-aware activity colors when the system theme is dark.

### ⬜ 1a-ii — Re-derive the remaining palette-owners from tokens/`ActivityPalette`

**(a) `lib/swipes/presentation/widgets/profile_card_style.dart`** — biggest offender (warm-cream
hexes `#FFF7EC`, `#120F0C`, …). Rewrite `ProfileCardPalette.of` to derive **entirely** from
`CatchTokens.of(context)` (already brightness-aware — drop the `isDark` hex branches):

```dart
static ProfileCardPalette of(BuildContext context) {
  final t = CatchTokens.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return ProfileCardPalette(
    background: t.bg,
    surface: t.surface,
    surfaceRaised: t.raised,
    border: t.line2,
    textPrimary: t.ink,
    textSecondary: t.ink2,
    textMuted: t.ink3,
    chipFill: t.raised,
    chipBorder: t.line2,
    accent: t.primary,                       // ink/paper; activity context may override
    accentSoft: t.primarySoft,
    shadow: Colors.black.withValues(alpha: isDark ? 0.34 : 0.10), // sanctioned shadow
    photoPlaceholder: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [t.raised, t.surface],         // neutral; no warm cream
    ),
  );
}
```

**(b) `lib/events/domain/pace_level_theme.dart`** — pastel traffic-light, not dark-aware. Convert
to a brightness-aware function `paceLevelColors(BuildContext, PaceLevel)` that maps to muted,
dark-aware tones from `CatchTokens` semantics: easy→`success`, moderate→a token blue
(`Color(0xFF3A6FD0)` light / lighter on dark), fast→`warning`, competitive→`danger`; `bg` = the
tone at ~12% over `t.surface` (light) or ~22% (dark), `fg` = the tone (lifted on dark). Keep it
semantic (pace is meaningful), just muted + dark-aware. Update the ~4 call sites (`rg -n "\.colors\b" ` near `PaceLevel`).

**(c) `lib/events/presentation/widgets/event_detail_surface_style.dart`** — `.light()` already
tokenized. Fix `.dark()`: replace the hardcoded `surfaceBackground: const Color(0xFF1D1814)`,
`raisedBackground/borderColor/dividerColor: Colors.white.withValues(...)` with the **dark token
instance** (this surface forces dark regardless of system theme, so read `sunsetDark` directly):
`surfaceBackground: CatchTokens.sunsetDark.surface`, `raisedBackground: CatchTokens.sunsetDark.raised`,
`borderColor`/`dividerColor: CatchTokens.sunsetDark.line`/`line2`, heading/body/muted from
`sunsetDark.ink`/`ink2`/`ink3`.

**(d) `lib/clubs/presentation/shared/club_cover_fallback.dart`** (`ClubCoverVisualPalette`, ~40
raw colors) — the generated club-cover art. Read the file; map each bespoke color to either an
`ActivityPalette` swatch (when the club has an activity) or `CatchTokens` neutrals. Keep the
generated-art structure; only swap the color source. This is the largest single file — budget time.

**(e) Map pins** — `lib/events/presentation/widgets/event_pin_renderer.dart` (~21 raw colors) and
`lib/dashboard/presentation/widgets/static_map_dark.dart`: route pin fill/stroke to
`ActivityPalette.of(context).forKind(kind)` + tokens. The Google-map style JSON (tiles) is a
**sanctioned exception** — leave it.

### ⬜ 1a-iii — Photo grade (`GradedImage`)
New widget `lib/core/widgets/graded_image.dart` — display-time, non-destructive, tunable:

```dart
// Tunable in one place (design_language §4).
class CatchGrade {
  static const double saturation = 0.82;     // warm-desaturate
  static const Color warmth = Color(0x14C9542F);   // low-alpha warm multiply
}

// 4x5 saturation matrix (luma 0.2126/0.7152/0.0722), s = CatchGrade.saturation.
List<double> _saturationMatrix(double s) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  return <double>[
    lr*(1-s)+s, lg*(1-s),   lb*(1-s),   0, 0,
    lr*(1-s),   lg*(1-s)+s, lb*(1-s),   0, 0,
    lr*(1-s),   lg*(1-s),   lb*(1-s)+s, 0, 0,
    0,0,0,1,0,
  ];
}
```
`GradedImage` = `Stack`[ `ColorFiltered(ColorFilter.matrix(_saturationMatrix(...)), child: image)`,
then a `Positioned.fill(IgnorePointer(DecoratedBox(BoxDecoration(color: CatchGrade.warmth,
backgroundBlendMode: BlendMode.multiply))))` ]. Expose an `enabled` flag (default true).
**Apply at** the photo branches of: `lib/core/widgets/catch_event_thumbnail.dart`,
`lib/core/widgets/catch_detail_hero_backdrop.dart`, club cover image (`club_list_tile_parts/club_image.dart`),
profile photos (`lib/swipes/presentation/widgets/card_photo_section.dart`). Keep originals untouched.
**DoD:** every displayed user photo shares one grade; a mixed feed reads as one family.

### ⬜ 1a-iv — Raw-color sweep
Route remaining raw colors to tokens. Priority targets (counts from `rg -c "Color\(0x|Colors\.(white|black|...)"`):
`event_detail_hero_app_bar.dart` (18), `directory_card.dart` (3 — `Colors.white` crest borders →
`t.surface`), `scrollable_profile.dart` (1), `public_profile_screen.dart` (`Color(0x66000000)` →
`t.overlay`), `name_overlay.dart` (8), `swipe_hub_screen.dart` (8), `image_uploads/**`, `onboarding/**`.
**Sanctioned exceptions (leave; add to the 1d allowlist):** photo scrims (`Colors.black.withValues`
in `_Scrim`/club photo scrim), `CustomPainter` pattern white in `event_activity_visuals.dart`, the
map-style JSON, and `card`/`raised`/`overlay` shadow colors in `CatchElevation`. **Skip
`explore_concept/**`** (33 in `explore_concept_cards.dart` etc.) — that sandbox is retired in Phase 3.

**Task 1a DoD (re-skin proof):** add a temporary debug palette toggle (or tweak one `CatchTokens`
value), run the Widgetbook foundation/component contract surfaces plus the live app → the whole
app re-skins in light + dark with no stranded color outside the allowlist. `flutter analyze`
clean; tests green.

## Task 1b — Sizing/constraint doctrine + Dynamic Type  🟡 doctrine + scanner + migration DONE (`check_sizing.sh` green, wired in CI); remaining: ticket-rail overflow fix + Dynamic-Type spot-check ⬜

**✅ Already landed:**
- **Doctrine written** — `docs/app_architecture.md` → "Sizing And Constraints" (allowed-constant
  allowlist, banned→preferred table, `CatchLayout.maxContentWidth` clamp, Dynamic-Type rule, and a
  numbered **deterministic conversion algorithm**).
- **Scanner written** — `tool/check_sizing.sh` (portable `perl`+`find`; no ripgrep/GNU-grep needed).
  Flags fixed `height`/`width`/`dimension`, `Size(...)`, `BoxConstraints.tight*/expand`, and
  dimension-like `const double` decls under `lib/` (auto-exempts `1`px/`0`, `lib/core/theme/**`,
  generated code, `lib/labs/**`, `explore_concept`). Escape hatch: `// sizing:allow: <reason>`.
- **Scanner written** — `tool/check_ui_local_constant_wrappers.sh`. Flags the scanner-bypass pattern
  where feature/presentation files move raw UI values into private file-local constants such as
  `_cardHeight = 120`, `_pillRadius = 12`, `_shadowColor = Color(...)`, or `_motionDuration =
  Duration(...)`. These must route through `CatchSpacing`, `CatchRadius`, `CatchIcon`,
  `CatchOpacity`, `CatchElevation`, `CatchMotion`, `CatchLayout`, `CatchStroke`, or a shared
  primitive/token. Current baseline after the event-tile cleanup: **0 findings**.

**⬜ The migration (mechanical):**
1. **Add `CatchLayout.maxContentWidth`** (≈ 600) to `lib/core/theme/catch_tokens.dart` (it lives in
   the allowlisted theme dir).
2. **Baseline:** `./tool/check_sizing.sh` currently reports **~186 candidates**. Work the list with
   the doctrine's 8-step algorithm — convert each, or annotate `// sizing:allow: <reason>` for
   genuinely fixed art. Re-run until it exits `0`.
   Also run `./tool/check_ui_local_constant_wrappers.sh`; a zero sizing count is not clean if raw
   dimensions/colors/durations were hidden in private constants.
3. **Flagship fix — the ticket:** in `event_ticket_surface.dart` the consts
   `eventTicketMediaHeight = 136`, `eventTicketDividerHeight`, `eventTicketNotchRadius`,
   `eventTicketNotchDepth` drive both the media `SizedBox` **and**
   `EventTicketShapeClipper.notchCenterY` (`= eventTicketMediaHeight + eventTicketDividerHeight/2`,
   used in `catch_event_activity_cards.dart`). Convert media to `AspectRatio` (≈16/10) and compute
   the notch center from the **laid-out** media height via `LayoutBuilder` so the perforation stays
   aligned. Verify the notch visually in light + dark.
4. **Dynamic Type:** after the scanner is clean, walk every touched screen at text scale
   **1.0/1.5/2.0** — no clip/overflow.
5. **Wire `tool/check_sizing.sh` into CI** next to the other gates (see Task 1d / `release_operations.md`).

**DoD:** `tool/check_sizing.sh` exits `0` (every fixed dim converted or annotated); ticket media is
constraint-based with an aligned notch; no overflow at text scale 2.0; scanner runs in CI.

## Task 1c — Motion spec  ⬜
Document `CatchMotion` usage rules in `design_language.md` §7. Create
`lib/core/motion/catch_transitions.dart` extracting the Explore haptics + the event-ticket `Hero`
(`eventHeroSurface`) into a reusable page-transition + tap-feedback helper. **DoD:** the helper is
used by ≥2 surfaces (e.g. club detail + event detail).

## Task 1d — Anti-drift CI gate  ✅
Historical shell-scanner sketch superseded by the Catch UI analyzer plugin
(`packages/catch_ui_lints`) plus `tool/check_catch_ui_lint_drift.sh`:
```bash
bash tool/check_catch_ui_lints.sh
bash tool/check_catch_ui_lint_drift.sh --count
flutter analyze --no-fatal-infos
```
The analyzer rules flag raw `Color`/`Colors.*`/`CupertinoColors.*`,
`TextStyle(`, `GoogleFonts.*`/`getFont`, and font-family strings in
`fontFamily:` slots. **DoD:** the seeded smoke probe fails if a planted raw value
stops producing its Catch UI lint code.

---

# PHASE 2 — FLAGSHIP: PROFILE  ✅ DONE
Rebuild the shared profile surface to the locked language; it uplifts the **swipe deck**, the
**profile preview**, and the **Profile tab** at once (shared surface).

As-built: `ProfileSurface` maps `PublicProfile` into the section-based flagship
`CatchProfileView` for Catches, profile preview, and public profile. Catches mode keeps
per-section like/comment controls; preview/public modes render calm. `relationshipGoal` is
restored as a non-reactable "Looking for" facts section, the preview tab targets the flagship
`CustomScrollView`, and the profile golden covers the finished visual contract.

**Files & roles**
- `lib/swipes/presentation/profile_surface.dart` — the shared shell (wraps swipe + preview).
- `lib/swipes/presentation/profile_redesign/catch_profile_view.dart` — the scroll body; orchestrates sections.
- Sections: `card_photo_section.dart` (hero photo), `name_overlay.dart` (name/age over photo),
  `profile_bio_section.dart`, `profile_attributes_section.dart`, `profile_lifestyle_section.dart`,
  `profile_match_signals_section.dart`, `profile_section_card.dart`, `profile_reaction_controls.dart`.
- `lib/public_profile/presentation/public_profile_screen.dart` — public projection; keep parity.
- Palette: `ProfileCardPalette` (tokenized in Task 1a-ii-a).

**Apply**
1. **Dark "wow" hero:** full-bleed **graded** photo (`GradedImage`) + bottom scrim; name in
   **Archivo** (large, upright, italic only as accent), meta in **IBM Plex Mono** (tracked caps).
2. **Bios/prompts:** `proseL` (Archivo) for prompt answers/bio; prompt labels in mono.
3. **Reactions** (`profile_reaction_controls.dart`): ink-default like/pass; optionally inherit the
   activity color of the shared event (design §2).
4. **Constraints:** photo blocks → `AspectRatio`; no fixed text-row heights. Validate Dynamic Type 2.0.
5. **Ticket/polaroid vocabulary** where the profile references an event/club (e.g. "was at" chip,
   shared-club polaroid).
6. **Tests:** add golden/widget tests under `test/swipes/` for the surface in light + dark + text
   scale 1.5; assert tokenized colors (no raw hex). **DoD:** Profile is the reference of record —
   fully tokenized, constraint-based, light+dark, Dynamic-Type-safe, golden-covered.

---

# PHASE 3 — ROLL OUT TO PAR (by gap)  ✅ DONE
Per screen: tokens-only, `proseL/M` for editorial copy, constraint-based, light+dark, Dynamic-Type
checked, anti-drift gate green, and update `docs/widget_catalog.md` or
`docs/app_architecture.md` when a surface changes a reusable component or
architecture rule. Historical rollout order by gap:

As-built: the listed production surfaces have been brought to parity and the
`explore_concept` sandbox has been retired. The checklist below is retained as
historical implementation detail.

1. **Onboarding** (`lib/onboarding/**`) — still leans on Material `textTheme`; move headings to
   Archivo, copy to `proseM`, CTAs to ink pills; sweep raw colors.
2. **Dashboard** (`lib/dashboard/**`) + **Profile tab** — re-skin tiles/sections; `static_map_dark.dart`
   pins via `ActivityPalette`; `activity_section.dart` already reads `visual.accent` (now tokenized).
3. **Clubs** — extract a **`CatchPolaroid`** primitive from `_DirectoryPhotoCard`
   (`club_list_tile_parts/directory_card.dart`): white inset frame + framed (graded) photo + mono
   caption + Archivo italic name + member seal. Then give the **no-cover** variant
   (`_DirectoryIdentityCard`) the polaroid treatment (caption + `EventActivityBackdrop` art in the
   frame) and **retire `club_cover_fallback.dart`**'s bespoke palette. Add `CatchPolaroid` to
   `widget_catalog.md`.
4. **Chat / matches** (`lib/chats/**`, matches surfaces) — tokens, mono timestamps, serif headers.
5. **Settings / safety / payments / calendar / image_uploads** — functional screens; tokens + platform system font.
6. **event_success** (`lib/event_success/**` + `docs/event_success.md`) — preserve the
   ceremony; re-grade to tokens.

**Then retire dead sandboxes:** verify no `explore_concept/**` sandbox remains under the Explore
feature and no dev route remains in `lib/routing/` (`rg -n "explore_concept|ExploreConcept" lib/routing`).
Do not delete `lib/labs/design_fixtures/**`; those fixtures are consumed by Widgetbook and tests.
No standalone executable lab should remain. **DoD:** modernization backlog cleared; no
placeholder-era screens; anti-drift gate green repo-wide.

---

# Deferred (tracked, non-blocking)
- **Bespoke activity emblem set (~16 symbols)** — symbolic marks (route/plate/paddle/lotus/martini)
  replacing abstract patterns + generic Phosphor glyphs. SVG drafts in
  `docs/visual_references/catch_activity_grading.html`. Ship on Phosphor glyphs first.
- **Activity pigment fine-tuning** — edit only `ActivityPalette.pigments`.
- **Display-face revisit** — Archivo is a "for now" pick (centralized in `catch_fonts.dart`).
- ~~**Optical sizing**~~ — ✅ **DONE (2026-05-30)**: all three fonts bundled in `assets/fonts/`; `CatchFonts` drives `FontVariation('opsz'/'wght')` with auto optical sizing.

# Global verification before any PR
- `flutter analyze` clean; `flutter test --concurrency=1` green (add golden/widget tests).
- App runs in dev; each touched screen screenshotted **light + dark** at text scale **1.0/1.5/2.0**.
- Re-skin proof passes (1a DoD); anti-drift gate green (1d DoD).

---

# Codex review notes

These are read-only review notes from Codex after comparing this checklist against the current
working tree on 2026-05-29. Directionally, the plan is strong: foundation first, then Profile as
the flagship, then feature rollout. The main issues are source-of-truth drift and gates that need
more precision before CI enforcement.

## Highest-priority critiques

1. **Superseded plan cleanup is complete.**
   The old exploratory plan was deleted after its single remaining map-pin
   policy decision moved to `docs/design_language.md`.

2. **`design_language.md` needs its status / remaining-work section refreshed.**
   It still says encoding into tokens/fonts is the next step and lists Phase 0 closeout as remaining.
   This implementation doc says those tasks are done. Keep `design_language.md` as the why/source of
   identity truth, but update its state so no one redoes completed work.

3. **`tool/check_sizing.sh` is useful but too noisy to wire into CI unchanged.**
   It currently reports the documented 186 findings, but several are false positives or allowed
   cases: text-style `height: 0.98`, `copyWith(height:)`, border widths, stroke widths, and fractional
   sheet-size constants. The doctrine says stroke/border widths are allowed, so the scanner should
   exempt them before becoming a failing CI gate. Otherwise it will create annotation churn instead
   of enforcing real responsive-layout improvements.

4. **The ticket sizing task is partly stale.**
   `eventTicketMediaHeight = 136` is already removed from code; the remaining ticket constants are
   visual-metaphor constants with `sizing:allow` comments. Rephrase the ticket item as "finish and
   visually verify the ticket conversion" rather than "convert the old media-height const."

## Implementation risks / improvements

5. **The anti-drift gate should catch direct font APIs too.**
   Task 1d flags raw colors and `TextStyle(`, but the current tree still has direct `GoogleFonts.*`
   and `GoogleFonts.getFont(...)` calls outside `catch_fonts.dart`, including a production
   `Instrument Serif` use in `explore_event_type_browse_grid.dart`. If typography is centralized,
   the gate should also flag `GoogleFonts.` / `getFont(` outside `catch_fonts.dart`, `app_theme.dart`
   fallbacks, and explicitly sanctioned sandboxes.

6. **Map pin palette routing needs cache-key design.**
   `EventPinRenderer` rasterizes and caches bitmap descriptors by status and DPR. If pin colors
   become activity-, theme-, or palette-aware, the cache key must include activity kind and brightness
   or a palette version/signature. Otherwise map pins can reuse stale colors after dark-mode or
   palette changes.

7. **Decide whether the app icon remains an orange exception.**
   Native splash/web/Razorpay surfaces are described as updated off orange, but
   `assets/branding/catch_icon.svg` still contains the old orange gradient. That may be an intentional
   legacy app-icon exception, but this doc should call it out explicitly so future color sweeps do
   not debate it again.

8. **Font delivery should be made explicit before release.**
   Archivo and IBM Plex Mono are now load-bearing identity pieces, but `pubspec.yaml` still does
   not bundle font assets. Runtime `google_fonts` is fine for iteration, but the release plan should
   either bundle the fonts or explicitly accept runtime/fallback behavior.
   **✅ Resolved 2026-05-30:** the three fonts are now bundled in `assets/fonts/` (variable
   Archivo roman+italic, variable platform system font, static IBM Plex Mono) and declared in `pubspec.yaml`;
   production no longer uses runtime `google_fonts` (only the retired `explore_concept/**` sandbox).

9. **Golden tests need a tooling decision.**
   The doc asks for golden tests, but the repo does not appear to have existing golden-test tooling.
   Either add a concrete golden framework/font-loading plan or phrase this as focused widget tests
   plus screenshot QA until golden infrastructure is chosen.

## Smaller accuracy fixes

- Phase 3 says `lib/chat/**`; the repo uses `lib/chats/**`.
- Phase 3 says `lib/events/.../event_success`; the feature lives under `lib/event_success/**`.
- The plan should keep `explore_concept/**` excluded from cleanup gates until the Phase 3 sandbox
  retirement, otherwise scanners will report obsolete prototype code that should not be polished.
