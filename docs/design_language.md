---
doc_id: design_language
version: 1.1.0
updated: 2026-05-31
owner: ui_elevation_initiative
status: active — identity locked; Phase 0–1 complete (bundled optical-sized fonts, B&W tokens, ActivityPalette routing, matte grade, anti-drift gates); Phase 2 flagship Profile built
---

# Catch Design Language

Source of truth for Catch's **visual identity**: palette, typography, photographic
treatment, metaphors, surfaces, and motion. Pairs with `docs/ui_architecture.md`
(layout/scroll/sizing) and `docs/widget_catalog.md` (component inventory). The
multi-phase rollout + **live status** lives in
[`docs/ui_elevation_implementation.md`](ui_elevation_implementation.md) (the original
exploration plan [`docs/plans/cryptic-hatching-hummingbird.md`](plans/cryptic-hatching-hummingbird.md)
is **superseded**).

> **Status (2026-05-31):** The "Sunset" cream+orange palette is **retired**; the direction
> below is **locked** (see §9). Phases 0–1 are implemented (fonts bundled + optically sized,
> B&W tokens, ActivityPalette routing, matte-duotone grade, `check_design_tokens.sh`/`check_sizing.sh`
> gates) and the **Phase 2 flagship Profile** is built — see
> [`ui_elevation_implementation.md`](ui_elevation_implementation.md) for the per-phase status.
> Some choices stay **tunable** (activity pigments, photo grade, the display face). Visual
> studies live in [`docs/visual_references/`](visual_references/) as runnable HTML.

---

## 1. North star

Two references anchor the direction: **Wallpaper\*** (clean luxury minimalism —
near-monochrome, grid discipline, generous whitespace, color used as an event not a
default) and **Roadbook** (warm editorial soul — confident type, captioned
photography, **warm-desaturated color grading**, restraint). Both are, in fact,
restrained and mostly sans/monochrome.

**Catch = editorial restraint + a serif voice + meaningful color.** We borrow their
discipline (grid, whitespace, hairlines, tracked labels, muted grading) but our
*voice* is a serif, and our *only* color is meaningful — it tells you the activity.

### The seven principles (the bar every screen must meet)

1. **Type carries personality; color carries meaning.** If a screen needs decorative
   color to look good, the type/layout isn't done.
2. **Whitespace is a feature.** Generous, slightly asymmetric margins.
3. **Hairlines, not boxes.** 1px rules + negative space over filled cards/shadows.
4. **Photography is graded and framed, never raw filler.** One grade on every photo.
5. **Color = activity.** No decorative brand accent; chroma appears only where an
   activity gives it (§3).
6. **Tracked uppercase mono** for kickers/labels/data; **serif** for voice; **Inter**
   for function.
7. **It must hold at text-scale 2.0 and in dark mode.** Editorial layouts live on type;
   if Dynamic Type breaks it, it isn't done.

---

## 2. Color — base is black & white

The base system is **paper + ink**. Neutral surfaces (profile, chat, onboarding,
settings, forms) use **no decorative color at all**. Light is the browse/forms register;
**dark is reserved for "wow" surfaces** (event spotlight, profile hero) and is
first-class.

| Role (`CatchTokens`) | Light | Dark (wow) | Notes |
|---|---|---|---|
| `bg` | `#F4F4F1` | `#0F0E10` | cooler gallery off-white — **never cream** |
| `surface` | `#FFFFFF` | `#18171A` | |
| `raised` | `#FAFAF8` | `#211F23` | input/raised fills |
| `overlay` | ink @ 55% | `#000` @ 72% | scrims |
| `ink` / `ink2` / `ink3` | `#16140F` / `#544F47` / `#9C958A` | `#F4F0E8` / `#BAB2A7` / `#7E776D` | primary/secondary/tertiary text |
| `line` / `line2` | ink @ 8% / 14% | paper @ 13% / 22% | hairlines |
| `primary` (default action) | `#16140F` (ink) | `#F4F0E8` (paper) | **actions are ink/paper**, not a brand hue |
| `primaryInk` | `#F4F4F1` | `#16140F` | text on a primary fill |
| `success`/`warning`/`danger` | `#2F7D55` / `#B9770F` / `#C2261A` | lighter variants | functional only |

**Token model change:** there is **no brand accent**. `primary` becomes the
default *action* color (ink in light, paper in dark). On activity surfaces the action
color is overridden by the activity pigment (§3). The old `heroGrad` brand gradient is
**deprecated** — hero/wow gradients derive from the activity pigment or ink instead.
`like`/`pass`: `like` defaults to ink (bold); optional systematic flourish — a "Like"
may inherit the activity color of the event where the two people would cross paths.

---

## 3. Activity color system — the only chroma (keep + refine)

`event_activity_visuals.dart` already keys every `ActivityKind` to a color set + a
`CustomPaint` pattern + a glyph (`EventActivityBackdrop`). This is the **correct answer
to user-generated photography** — events are *art-first, photo-optional* — and it is
the single most systematic asset in the app. **Keep it.** Three refinements:

1. **Candy → pigment.** Replace the bright pastel 3-stop gradients with **confident
   mid-tone pigments** (one screen-printed ink per activity). Bolder where it counts
   (the symbol), calmer elsewhere. Starting values (light context — **editable/tunable**,
   each needs a dark variant + a soft tint):

   | Activity | Pigment | Activity | Pigment |
   |---|---|---|---|
   | social run | `#D85A3C` | dinner | `#C44D6A` |
   | walking | `#6E9A5A` | pub quiz | `#4356A8` |
   | pickleball | `#2F9E7A` | bar crawl | `#B14488` |
   | padel | `#2E9AA0` | singles mixer | `#D85A6E` |
   | tennis | `#4E9A4E` | yoga | `#8A5FB0` |
   | badminton | `#4F70C8` | strength | `#B0573C` |
   | cycling | `#3A6FD0` | open format | `#7A7166` |

2. **Bespoke emblems** (deferred — see §8/task). Replace abstract patterns + generic
   Phosphor glyphs with a **symbolic mark per activity** (route, plate, paddle, lotus,
   martini…). SVG drafts in `catch_activity_grading.html`. Ship on Phosphor glyphs now,
   swap emblems in later.

3. **Formalize as a token-keyed, dark-aware `ThemeExtension`** (the sanctioned
   "expressive palette" layer). This satisfies the Phase-1a token-routing requirement
   without abandoning the expressive system. Make it **editable in one place.**

---

## 4. Photography — one grade, at display time

User photos are inconsistent and low-quality. We **do not edit them on upload** — we
**grade them at display time** (non-destructive, reversible, tunable):

- A single **warm-desaturated duotone grade** (≈ saturation 0.78, slight contrast lift,
  subtle warm multiply + gentle darken) applied via `ColorFiltered`/shader/overlay.
- The grade matches the activity pigments, so a graded UGC photo and a generated
  activity backdrop read as **one editorial family**.
- Keep the original (moderation, the user's own view, re-grading). The grade is a
  **tunable token** — dial intensity globally in one place.

---

## 5. Typography

Three roles, no competition:

| Role | Family | Use |
|---|---|---|
| **Voice** (display + long-form body) | **Newsreader** (optical-sized serif) | screen titles, event/club/profile names, hero moments, **and** reading text (bios, descriptions) |
| **Function** | **Inter** | buttons, nav, inputs, dense UI controls |
| **Data** | **IBM Plex Mono** | time, price, counts, kickers, tracked uppercase labels |

**Why Newsreader:** purpose-built for on-screen editorial reading — moderate contrast +
generous x-height (legible at 15px) with a true optical axis (commanding at 50px) and
real character. Chosen over Instrument Serif (too light/casual at display) and the
Didones — Playfair/Bodoni — which **sacrifice legibility** at text sizes.

> The display face is a **"for now" pick** — owned centrally in `CatchFonts`, so it's a
> contained, tunable swap if we revisit it.

**Legibility-first craft (applies regardless of face):**
- **Optical sizing** — text cut (sturdier) small, display cut (finer) large.
- **Dramatic scale jumps** — a large display over a small mono kicker; avoid many mid sizes.
- **Tight display tracking + near-1.0 leading**; **generous body leading (~1.55–1.62)**.
- **Upright titles; italic reserved as a single accent** (not italic-by-default).
- Moderate stroke contrast everywhere but the very largest display.

These map onto the existing `CatchTextStyles` roles — display/title styles move to
Newsreader, body styles to Newsreader text optical size, labels/numerics to IBM Plex
Mono, with Inter for control text.

---

## 6. Metaphors

- **Ticket → events: keep & refine.** `event_ticket_surface.dart` (real `CustomClipper`
  notches, perforation, Hero card→detail) is strong, award-adjacent craft. Refine: the
  fixed `eventTicketMediaHeight = 136` → aspect-ratio/constraint (Dynamic Type); push
  the ticket-stub typography (serial/time treatment).
- **Polaroid → clubs: already built, needs naming + extending.** The cover-photo club
  tile (`_DirectoryPhotoCard`) *is* a polaroid — white inset frame, framed photo, IBM
  Plex Mono caption, italic serif name. Extract a `CatchPolaroid` primitive, and give the
  **no-cover** variant (`_DirectoryIdentityCard`) the polaroid treatment too (caption +
  activity art in the frame) so "no photo" looks intentional.

---

## 7. Surfaces, layout, motion, scope

- **Light + dark, used intentionally** — light for browse/forms, dark for wow surfaces.
- **Hairlines over boxes; generous whitespace; grid discipline.**
- **Sizing:** constraints over constant heights/widths; min/max constraints, intrinsics,
  `Flexible`/`Expanded`, `AspectRatio`, content max-width clamp. Resilient to **Dynamic
  Type** (validate at text scale 1.0/1.5/2.0).
- **Scale target:** phone + Dynamic Type. **No** tablet/web adaptive work for now.
- **Motion:** route motion through `CatchMotion` and
  `lib/core/motion/catch_transitions.dart`. Use `catchSelectionHaptic()` for
  discrete choices, `catchTransitionHaptic()` for map/sheet state changes,
  `catchFadeScalePageTransition` for calm card-to-detail routes, and
  `catchHeroSurface`/`CatchTicketHero` for ticket or polaroid flights. Avoid
  raw `Duration(...)`, ad-hoc `Hero`, and direct `HapticFeedback` in product UI
  unless a new named motion primitive is being introduced.

---

## 8. Open / deferred (tunable, not blockers)

- **Activity pigment exact lightness** — current mid-tones are "fine for now"; build the
  system so they're **editable** and tune later.
- **Bespoke activity emblem set** (~16 symbols) — design task; ship on Phosphor glyphs first.
- **Display face** — Newsreader is a "for now" pick; revisit possible (centralized swap).

---

## 9. Exploration log (persisted context)

What we tried and why, so we don't relitigate it:

- **Sunset retired** as a placeholder; beige/cream specifically rejected as "dull and dated."
- **Three flat palette candidates** (Newsprint / Warm-beige / Ink-cobalt) — rejected:
  too abstract to judge, and beige was a hard no.
- **Pivoted to high-fidelity HTML mocks** (real fonts/photos) — this worked. Landed
  "bold editorial, light browse + dark wow."
- **Accent tuner** (coral/magenta/cobalt/acid/tangerine) → conclusion: **no global accent
  at all**; color should *mean* activity, so the per-activity palette is the only chroma.
- **Activity art re-grade:** candy gradients → deep duotone (too dark) → **confident
  mid-tone pigments**; abstract patterns → **bespoke emblems** (deferred); grading decided
  **display-time, non-destructive**.
- **Typography:** Instrument Serif too delicate at display; Didones (Playfair/Bodoni)
  rejected for **poor legibility**; shortlisted screen-reading serifs (Newsreader / Source
  Serif 4 / Literata); **Newsreader** chosen (legible body + commanding display).
- **References studied:** Roadbook (warm-desaturated editorial, sans-leaning) + Wallpaper
  (monochrome restraint). Catch = their restraint + a serif voice + meaningful color.
- **Visual studies (runnable):** `visual_references/catch_identity_mock.html` (light+dark
  direction), `catch_activity_grading.html` (pigment + emblems + grading), `catch_typography.html`
  (type specimen). `lib/labs/identity_candidate_lab_app.dart` is **superseded** (old
  A/B/C palettes) and should be refreshed or removed in Phase-0 closeout.

---

## 10. What's left to do

**Phase 0 closeout (bridge to code):** ✅ DONE
1. ✅ Encode this into `CatchTokens` (B&W light + dark base, no brand accent).
2. ✅ Build the `ActivityPalette` expressive-layer `ThemeExtension` (mid-tone pigments,
   dark-aware, editable) + the display-time photo grade as a tunable token.
3. ✅ Wire **Newsreader / Inter / IBM Plex Mono** into `CatchFonts` + `CatchTextStyles`
   (upright titles, italic accent, optical sizing, scale/tracking/leading).
4. ✅ Refresh or delete the superseded `identity_candidate_lab_app.dart`.

**Then the plan's phases** ([`docs/plans/cryptic-hatching-hummingbird.md`](plans/cryptic-hatching-hummingbird.md)):
- **Phase 1** — route palette-owners (`event_activity_visuals.dart`,
  `profile_card_style.dart`, `club_cover_fallback.dart`, …) through tokens → **re-skin
  proof**; sizing/constraint doctrine + Dynamic Type; motion spec; anti-drift CI gate.
- **Phase 2** — flagship **Profile** (shared `ProfileSurface` → uplifts swipe + preview).
- **Phase 3** — rollout to par: onboarding, **Dashboard + Profile tabs**, clubs (land the
  named polaroid; retire `club_cover_fallback`), chat/matches, settings/payments/calendar,
  event_success. Retire dead sandboxes (`labs/`, `explore_concept/`).
