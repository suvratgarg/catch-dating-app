---
doc_id: design_language
version: 1.5.0
updated: 2026-07-11
owner: ui_elevation_initiative
status: active — identity locked; Phase 0–1 complete (bundled optical-sized fonts, B&W tokens, ActivityPalette routing, matte grade, anti-drift gates); Phase 2 flagship Profile built
---

# Catch Design Language

Source of truth for Catch's **visual identity**: palette, typography, photographic
treatment, metaphors, surfaces, and motion. Pairs with `docs/app_architecture.md`
(layout/scroll/sizing architecture) and `docs/widget_catalog.md` (component inventory). The
multi-phase rollout + **live status** lives in
[`docs/ui_elevation_implementation.md`](ui_elevation_implementation.md).

> **Status (2026-05-31):** The "Sunset" cream+orange palette is **retired**; the direction
> below is **locked** (see §9). Phases 0–1 are implemented (fonts bundled + optically sized,
> B&W tokens, ActivityPalette routing, matte-duotone grade, Catch UI analyzer lints,
> and `check_sizing.sh`) and the **Phase 2 flagship Profile** is built — see
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

**Catch = editorial restraint + a typographic voice + meaningful color.** We borrow their
discipline (grid, whitespace, hairlines, tracked labels, muted grading) but our
*voice* is Archivo, and our *only* color is meaningful — it tells you the activity.

### The seven principles (the bar every screen must meet)

1. **Type carries personality; color carries meaning.** If a screen needs decorative
   color to look good, the type/layout isn't done.
2. **Whitespace is a feature.** Generous, slightly asymmetric margins.
3. **Hairlines, not boxes.** 1px rules + negative space over filled cards/shadows.
4. **Photography is graded and framed, never raw filler.** One grade on every photo.
5. **Color = activity.** No decorative brand accent; chroma appears only where an
   activity gives it (§3).
6. **Tracked uppercase mono** for kickers/labels/data; **Archivo** for voice/head;
   the platform system font for function.
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
| **Voice / display** | **Archivo** (variable grotesque, locked to a single **78% width** — the "78% system") | brand moments, screen/event/club display titles, and the welcome reel |
| **Function / reading** | **Platform system font** (SF on iOS, Roboto on Android) | prose, bios, descriptions, names, buttons, nav, inputs, and dense UI controls |
| **Data** | **IBM Plex Mono** | time, price, counts, OTP digits, kickers, and explicit uppercase labels |

**Why Archivo:** the current direction is typographic, restrained, and non-serif. Archivo
gives Catch a deliberate display voice without reintroducing a decorative brand accent.
Reading text and user-authored names stay native to the platform for legibility and
Dynamic Type behavior.

> The old serif/custom-sans direction is retired. Keep the swap centralized in
> `CatchFonts`, `CatchTextStyles`, and `design/tokens/catch.tokens.json`.

**Legibility-first craft:**
- **Single Archivo width — 78% (ratified 2026-07-06).** The DS
  `colors_and_type.css` renders every voice/headline/prose style at
  `font-stretch: 78%`; the app matches it. Archivo's `wdth` axis (62–125) is
  NOT a per-style knob — `CatchFonts.archivoWidth` is the one width, enforced
  at the engine (`voice`/`head` take no width param). The earlier mixed
  90/92/94/100 widths were pre-decision drift and are retired. This is the
  Archivo half of the identity migration; the Newsreader→Archivo family swap
  completed earlier.
- **Dramatic scale jumps** — a large display over a small mono kicker; avoid many mid sizes.
- **Zero tracking by default.** Only explicit uppercase kicker/mono/badge roles add
  tracking. `welcomeReelHeadline` owns the ratified `-0.5px` welcome exception.
- **Near-1.0 display leading** and **generous body leading (~1.5–1.6)**.
- **Archivo is roman-only in the app.** Do not request Archivo italics or add ignored
  `fontStyle` parameters.
- Flutter native bundles `Archivo-Roman-VF.ttf`; web surfaces keep the WOFF2 build.
  Both formats are covered by the bundled Archivo OFL license.

These map onto the existing `CatchTextStyles` roles — display/title styles move to
Archivo, sentence/data roles to untracked IBM Plex Mono, explicit caps roles to tracked
IBM Plex Mono, and names/controls/prose to the platform system font. App UI calls semantic
`CatchTextStyles` roles; `CatchFonts` is an internal theme implementation detail.

---

## 6. Metaphors

**Presentation tiers (ratified 2026-07-05):** every entity material (event
ticket, club polaroid, person card) ships in at least two tiers — a **hero**
form for surfaces where the entity earns attention, detail, and vertical
space (detail heroes, featured cards, cover moments), and a **condensed**
form for long lists and date-grouped rails (DateTicket rows, index rows).
More tiers are allowed when a surface justifies them; a surface never mixes
tiers within one list.

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

### 7.1 Containment doctrine — when a surface earns a border

Containers mark **objects and actions, never information**. A bordered or
filled surface in product UI must pass at least one of:

- **R1 · Collection object** — a peer in a set you browse or choose among
  (feed tickets, club polaroids, recommendation cards, photo slots). The
  container is the object's material; material marks type (events are
  tickets, clubs are polaroids, people are plain cards).
- **R2 · Actionable module** — tappable as a whole, or carrying a CTA
  cluster owned by exactly this content (booking dock, callout card, task
  card, QR panel).
- **R3 · Plane change** — sheets, menus, overlays, docks, floating
  controls. Elevation resets the rules; content inside starts flat again.
- **R4 · Status tone** — the fill/border carries semantic state
  (warning/error/success notices, primarySoft signal cards).
- **R5 · List frame** — ONE hairline container around a stack of
  divider-separated rows (the ReviewRow/ContactRow/HostRow pattern).
  Never card-per-row.

Everything else is an **attribute of the page's subject** and renders flat:
kicker + typography + hairlines + spacing carry hierarchy.

Additional rules:

- **Depth ≤ 1.** A bordered surface never contains another bordered
  surface; only a plane change (R3) resets the count.
- **Exempt material classes:** chips/pills/badges (data-chip anatomy
  includes its border), skeletons (mimics follow whatever their subject
  does), and the immersive stage/paper/celebration grammars (their own
  ratified languages).

The audited application of this doctrine lives in
`docs/design_parity/containment_audit.md`.
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
- **Activity emblem set** — bespoke symbols remain deferred; ship on regular Phosphor
  glyphs first.

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
- **Typography:** earlier serif studies (Instrument Serif, Playfair/Bodoni,
  Source Serif 4, Literata) were retired. The current locked stack is Archivo for voice/head,
  platform system for function/body, and IBM Plex Mono for data.
- **References studied:** Roadbook (warm-desaturated editorial, sans-leaning) + Wallpaper
  (monochrome restraint). Catch = their restraint + a typographic voice + meaningful color.
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
3. ✅ Wire **Archivo / platform system / IBM Plex Mono** into `CatchFonts` +
   `CatchTextStyles` (upright titles, condensed head roles, scale/zero
   tracking/leading).
4. ✅ Refresh or delete the superseded `identity_candidate_lab_app.dart`.

**Implemented rollout phases:**
- **Phase 1** — route palette-owners (`event_activity_visuals.dart`,
  `profile_card_style.dart`, `club_cover_fallback.dart`, …) through tokens → **re-skin
  proof**; sizing/constraint doctrine + Dynamic Type; motion spec; anti-drift CI gate.
- **Phase 2** — flagship **Profile** (shared `ProfileSurface` → uplifts swipe + preview).
- **Phase 3** — rollout to par: onboarding, **Dashboard + Profile tabs**, clubs (land the
  named polaroid; retire `club_cover_fallback`), chat/matches, settings/payments/calendar,
  event_success. Retire dead sandboxes (`labs/`, `explore_concept/`).

**Remaining policy decision:** map pins still need an explicit art-vs-token
decision. Either route `CatchMapPinColors` through `ActivityPalette`/tokens, or
document the map-pin palette as a sanctioned expressive-art exception here.
