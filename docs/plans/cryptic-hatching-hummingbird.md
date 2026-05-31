# SUPERSEDED — see docs/design_language.md for the locked identity and docs/ui_elevation_implementation.md for the current implementation checklist.

# Catch UI Elevation — Editorial Identity + System-wide Consistency

## Context

The app's frontend has evolved unevenly: features built in different months follow
different conventions, dimensions are often hardcoded, and the visual identity
(the "Sunset" cream+orange palette) was always a placeholder. The goal is a
**state-of-the-art, award-caliber UI** that is *visually finalized*, *consistently
applied everywhere*, and *scales fluidly* on phones (including large text /
accessibility).

**The key reframe from exploring the code:** this is *not* a "build a design system"
problem. A mature, actively-governed system already exists:

- Full token set — `CatchTokens` (semantic color roles, light **and** dark), `CatchSpacing`
  (4-pt scale), `CatchRadius` / `CatchElevation` / `CatchMotion` / `CatchIcon`,
  `CatchTextStyles` + `CatchFonts` (Instrument Serif editorial + Inter).
- ~70 `Catch*` primitives and a governed `docs/widget_catalog.md` (v2.5.159) with a
  long consolidation changelog.
- Genuinely high adoption: **1,116** `CatchSpacing` refs, **733** `CatchTextStyles`, only
  **3** raw `TextStyle`, only **18** Material `textTheme` fallbacks. Typography and
  spacing are already disciplined.
- The late-May Explore / event-card refresh reached real craft: Hero ticket→detail
  transitions, perforated ticket clipping, light/dark spotlight surfaces, spring + haptic
  motion, map pin clustering.

**So the real gaps are four, and this plan targets exactly them:**

1. **Placeholder identity.** Sunset is being retired. We must finalize a bolder
   *editorial-magazine* direction (references: **Roadbook**, **Wallpaper**) and re-skin.
2. **Token-routing tail blocks the re-skin.** ~454 raw color refs remain. Most are
   *legitimate palette-owner* files (`profile_card_style.dart`, `club_cover_fallback.dart`,
   `pace_level_theme.dart`, `event_activity_visuals.dart`, `event_detail_surface_style.dart`),
   but they hardcode parallel palettes that will *strand the re-skin* unless routed
   through tokens first.
3. **Constant dimensions, no constraint discipline.** ~289 raw `height:`/`width:` literals;
   `ConstrainedBox` 22, `LayoutBuilder` 30, `AspectRatio` 9. Fixed heights (e.g.
   `eventTicketMediaHeight = 136`) silently clip under Dynamic Type.
4. **Era drift.** Newest screens are award-caliber; laggards (onboarding typography,
   `image_uploads`, `matches`, `public_profile`, settings) trail the bar.

### Decisions locked in (from planning Q&A)

| Decision | Choice |
|---|---|
| Scale target | **Phone + Dynamic Type** — fluid on all phones, resilient to large text. No tablet/web adaptive work. |
| Direction | **Retire Sunset.** Finalize a **bolder editorial-serif identity** (Roadbook / Wallpaper). |
| Identity owner | **Claude drives candidates** — synthesize refs, render 2–3 directions in the existing lab, user picks. |
| Dark mode | **First-class** — every treatment validated in light **and** dark. |
| Flagship | **Profile / public profile** (shared `ProfileSurface`, so it also uplifts the swipe deck). |
| Sequencing | **Foundation → flagship → rollout.** |

### Metaphor verdict (you asked me to judge)

- **Ticket → events: keep & refine.** Genuinely well-built — `event_ticket_surface.dart`
  has a real `CustomClipper` cutting ticket notches, a dashed perforation painter, and Hero
  card→detail transitions. Award-adjacent. Only caveat: the fixed `eventTicketMediaHeight = 136`
  must become constraint/aspect-ratio based for Dynamic Type.
- **Polaroid → clubs: strong idea, essentially unbuilt.** "Polaroid" exists *only* in the
  `explore_concept` lab. Production clubs render a generated gradient/pattern cover
  (`club_cover_fallback.dart`) + avatar rings (`borderColor: Colors.white`). Recommendation:
  **commit to the polaroid treatment properly** in Phase 0 — a real white-frame + captioned
  + subtly-rotated photographic object. It is *very* Roadbook/Wallpaper and gives clubs a
  distinct identity against ticket-events.

---

## Phase 0 — Finalize the editorial identity (Claude-driven)

**Goal:** Replace the placeholder Sunset direction with one finalized, bolder, editorial
identity, expressed as concrete token values + a written design-language doc, chosen by
looking at real renders — not in the abstract.

**Work:**
1. **Reference synthesis → moodboard.** Distill Roadbook (refined travel-editorial: serif
   headlines, photography-forward, muted-sophisticated palette, captions) and Wallpaper
   (grid discipline, confident type, generous whitespace, restrained color + one bold accent)
   into 4–6 concrete principles for Catch.
2. **Produce 2–3 candidate directions**, each specifying:
   - **Palette** (replacing Sunset) — paper/ink editorial base + one confident accent;
     full semantic-role mapping for `CatchTokens` light **and** dark.
   - **Type system** — Instrument Serif as expressive display (big/italic editorial moments)
     paired with the working sans for body; finalize scale, weights, and serif-vs-sans rules.
   - **Surface & card language** — magazine grid, margins, hairlines/rules, captioned imagery;
     finalize the **ticket** (events) and **polaroid** (clubs) treatments.
   - **Motion personality** — extend the Explore spring/haptic vocabulary into named rules.
3. **Render candidates on real screens** using the existing lab harness
   (`lib/labs/card_variation_lab_app.dart`, `lib/clubs/.../explore_concept/`) on Profile,
   Explore, and event detail, in light + dark, for side-by-side judgment.
4. **User picks the winner.** Lock values into `CatchTokens` (new palette), `CatchTextStyles`
   /`CatchFonts`, and a new **`docs/design_language.md`** (the single source of visual truth).

**Exit criteria:** one approved direction; `docs/design_language.md` written; new token/type
values staged (not yet rolled out app-wide).

**Critical files:** `lib/core/theme/catch_tokens.dart`, `catch_text_styles.dart`,
`catch_fonts.dart`, `app_theme.dart`; lab harness above; new `docs/design_language.md`.

---

## Phase 1 — Foundation hardening (makes the re-skin one-and-done + makes layout scale)

**Goal:** Finish the plumbing so the Phase 0 identity propagates from a single source, and
so layouts are constraint-based and Dynamic-Type-safe.

**1a. Token-routing completeness (load-bearing — unblocks the re-skin).**
Resolve every palette-owner / straggler so color flows from `CatchTokens`:
- **Re-derive** parallel palettes from tokens: `profile_card_style.dart` (`ProfileCardPalette`),
  `club_cover_fallback.dart` (`ClubCoverVisualPalette`), `pace_level_theme.dart`,
  `event_activity_visuals.dart`, `event_detail_surface_style.dart`, `event_pin_renderer.dart`.
- **Sweep stragglers:** raw `Colors.white/black` and `Color(0x…)` in
  `directory_card.dart`, `scrollable_profile.dart`, `public_profile_screen.dart`
  (`Color(0x66000000)` → `t.overlay`), `image_uploads/**`, `onboarding/**`.
- Where a bespoke expressive palette is *intentional* (activity art), formalize it as a
  sanctioned `ThemeExtension` keyed to tokens — not scattered hex.

**1b. Sizing & constraint doctrine (your "I hate constant heights" fix).**
- Write the rule (in `docs/ui_architecture.md`): fixed dimensions allowed **only** for
  icons (`CatchIcon`), hairlines, and true fixed art; everything else uses
  **min/max constraints, intrinsics, `Flexible`/`Expanded`, `AspectRatio`**, and a
  **content max-width clamp** for large phones/foldables.
- Convert worst offenders, starting with `eventTicketMediaHeight = 136` → aspect-ratio,
  and the per-screen fixed heights surfaced in the audit.
- **Dynamic Type resilience:** validate at text scale 1.3–2.0; replace clipping fixed-height
  containers with min-height + padding. Adopt `MediaQuery.textScaler` consciously.

**1c. Motion spec.** Promote `CatchMotion` (already has fast/base/slow + standard/spring) into
named app-wide rules; generalize the Explore haptics + the event-ticket Hero into a reusable
transition helper so signature motion isn't Explore-only.

**1d. Governance / anti-drift gate.** Add a CI grep gate (mirroring `tool/check_data_contract.sh`)
that fails on new raw `Color(0x…)`/`Colors.*`/raw `TextStyle(`/off-scale `EdgeInsets` outside an
allowlist of sanctioned palette-owner files; wire it into the recursive-audit loop and
`docs/widget_catalog.md`. (Custom analyzer lints are impractical — `custom_lint` conflicts with
`riverpod_generator`; the grep gate is the pragmatic enforcement.)

**Exit criteria:** flipping the `CatchTokens` palette re-skins the whole app with no stranded
colors, in light + dark; the constraint doctrine is documented and the worst fixed-dim
offenders are converted; the CI gate is green and blocks regressions.

---

## Phase 2 — Flagship: Profile to the finalized bar

**Goal:** Prove the finalized identity + constraint discipline end-to-end on one high-value
surface. Profile is ideal: it's the heart of a dating product, currently the thinnest-styled
major surface, and renders through the **shared `ProfileSurface`**, so the work simultaneously
uplifts the **swipe deck** and **profile-preview** modes.

**Work:**
- Rebuild `lib/swipes/presentation/profile_surface.dart` + `widgets/scrollable_profile.dart` and
  its sections (`profile_bio_section`, `profile_attributes_section`, `profile_lifestyle_section`,
  `profile_match_signals_section`, `card_photo_section`, `name_overlay`, `profile_section_card`,
  `profile_reaction_controls`) to the new editorial language.
- Apply the polaroid/ticket vocabulary where profiles reference clubs/events.
- Replace `ProfileCardPalette`'s bespoke hex with the token-derived palette from Phase 1a.
- Make photo blocks aspect-ratio / constraint-driven; verify Dynamic Type + dark mode.
- Land golden/widget tests as the visual contract; this screen becomes the "reference of record."

**Exit criteria:** Profile (public + swipe + preview) is demonstrably award-caliber, fully
tokenized, constraint-based, light+dark, Dynamic-Type-safe — and signed off as the bar the
rest of the app must meet.

---

## Phase 3 — Rollout to par (feature-by-feature)

**Goal:** Bring every remaining surface to the flagship bar, prioritized by traffic × current gap
(per the per-feature health audit).

**Order (highest gap first):**
1. **Onboarding** — first impression; still on Material `textTheme` (only 5 `CatchTextStyles`/15 files).
2. **Clubs** — land the real **polaroid** treatment; retire `club_cover_fallback.dart` and the
   `explore_concept` lab once production adopts the finalized primitive.
3. **Chat / matches** — editorial pass; close token gaps.
4. **Settings / safety, payments, calendar, image_uploads** — consistency + constraint sweep.
5. **Event success / wingman** — adopt shared primitives (already in `ui_modernization_backlog.md`).

Each screen: tokens-only, constraint-based, light+dark, Dynamic-Type-checked, CI gate green,
backlog item ticked. Retire dead sandboxes (`labs/`, `explore_concept/`, its dev route in
`go_router.dart`) at the end.

**Exit criteria:** `docs/ui_modernization_backlog.md` cleared; every feature passes the CI gate;
no remaining placeholder-era screens.

---

## Verification

- **Per phase:** `flutter analyze` clean; `flutter test --concurrency=1` (the documented serialized
  run) incl. new golden/widget tests for flagship + migrated screens.
- **Visual:** run all three envs via `./tool/flutter_with_env.sh dev run`; screenshot each migrated
  screen in **light + dark** and at **text scale 1.0 / 1.5 / 2.0**; verify no overflow/clipping and
  that the identity is consistent.
- **Re-skin proof (Phase 1 gate):** changing only `CatchTokens` values visibly re-skins every screen
  with zero stranded raw colors.
- **Anti-drift:** the new CI grep gate fails a deliberately-introduced raw `Color(0x…)` and passes once
  routed through tokens.

## Risks / notes

- **Phase 1a is the linchpin** — if palette owners aren't routed through tokens first, the re-skin
  becomes a 100-file slog and the identity drifts again. Do not start Phase 2 until the re-skin proof passes.
- **Dynamic Type** will surface latent layout bugs in fixed-height widgets; budget for it — it's the
  real cost behind "retire constant heights."
- **Dark mode first-class** ~doubles visual QA per screen; the CI gate + golden tests in both palettes
  keep it honest.
- Scope is deliberately **phone-only**; the dormant `ResponsiveBuilder`/`ScreenSize` infra stays unused
  except for the large-phone/foldable content max-width clamp.
