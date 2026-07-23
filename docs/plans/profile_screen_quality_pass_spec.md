---
doc_id: profile_screen_quality_pass_spec
version: 1.0.1
updated: 2026-07-23
owner: app
status: active
---

# Profile Screen Quality Pass — UX, Visual Craft & Surface Coherence Spec

Uses the same code-audit, rendered-capture, and design-language method whose
current Explore evidence is compiled by `design/features/explore.feature.json`;
this pass applies it across the four profile surfaces.

## 0. Context

Scope — the profile feature is **four surfaces sharing one flagship widget**:

| Surface | Route / entry | Widget |
|---|---|---|
| Own-profile tab (Edit / Preview / Insights) | app-shell branch 3, `/you` | `ProfileScreen` (`lib/user_profile/presentation/profile_screen.dart:29`) |
| Public profile (other users) | `/profiles/:uid` | `PublicProfileScreen` (`lib/public_profile/presentation/public_profile_screen.dart:24`) |
| Catches deck (reactable) | swipe flow | `ProfileSurface` mode `catches` (`lib/swipes/presentation/swipe_screen.dart:267-276`) |
| Preview tab | tab 2 of `/you` | `ProfileSurface` mode `preview` |

The shared shell is `ProfileSurface` (`lib/swipes/shared/profile_surface/profile_surface.dart:21`)
over the flagship `CatchProfileView` (`catch_profile_view.dart:27`). The Edit tab
is a one-off inline-editor surface; Insights is `UserAnalyticsPanel`.

Data-layer note: profile reads are healthy relative to the systemic findings in
the explore spec §3 — single-doc realtime streams (`user_profile_repository.dart:148-161`,
`public_profile_repository.dart:31-41`), callable-owned writes, no pagination
concerns. The deliberate per-doc `fetchPublicProfiles` N+1 (`:56-83`) is
documented and rules-driven; leave it.

Sources: audit of `lib/user_profile/**`, `lib/swipes/shared/profile_surface/**`,
`lib/public_profile/**`, `lib/image_uploads/**`, profile domain models;
`design/reference_screens/screen.profile.self/{edit_tab,preview_tab}.png`;
current captures `artifacts/ui-captures/host-profile-tabbed-shell-20260716/`;
baselines `artifacts/ui-captures/non-host-reference-baseline-20260625/`;
`docs/ui_elevation_implementation.md` (Phase 2); `docs/design_language.md`.

---

## 1. Executive summary

The flagship `CatchProfileView` is genuinely good — it is the proof that the
design language works. The problems are around it: the tab you actually live on
is a form, the preview doesn't promise the truth, photo management has
destructive one-tap paths, and there is no trust layer at all.

| # | Finding | Layer | § |
|---|---|---|---|
| 1 | Your own tab is an editor, not a profile — no hero, no share, no identity; a finished /100 quality-coaching engine exists and is **dark** | UX | 2.1 |
| 2 | The Preview tab projects `UserProfile → PublicProfile` client-side instead of reading the served `publicProfiles` doc — "how others see you" can drift from what others see | UX/honesty | 2.2 |
| 3 | Photo grid delete is one-tap destructive with no confirmation (the editor has one — asymmetric), the delete target is 28px, and reorder is undiscoverable drag-only with no accessibility alternative | UX/a11y | 2.3 |
| 4 | No verification system and no pronouns field exist anywhere in the domain — table-stakes trust features for a dating product | Product | 2.4 |
| 5 | Catches deck repeats identical heart+comment chrome under every section — 5+ times per profile — and the hero reaction control likely collides with the top overlay | UX | 2.5 |
| 6 | Flagship photos bypass `CatchNetworkImage` (raw `Image.network`) — no decode cap, no branded fallback | Craft | 3.1 |
| 7 | Hardcoded English across hero kicker, semantic hints, reaction labels, compatibility copy, and the MAIN badge | Craft | 3.2 |
| 8 | Dead weight: `ProfileInfoChip`, 8 of 14 `ProfileCardPalette` fields, 5 dead opacity tokens, `PhotoPromptAnswer.caption` end-to-end, `ProfileInlineTextValue`, empty `profile_redesign/` dir | Hygiene | 4.4 |
| 9 | Design baselines and catalog are stale again: `screen.profile.self` reference PNGs show the retired serif identity and a 2-tab rail (current is 3); 5 catalog entries point at classes that no longer exist | Hygiene | 4.5 |
| 10 | Vibe forks on the catches deck: neo-brutalist thick-bordered floating controls and a full-bleed activity-pigment fallback hero sit uneasily next to the hairline editorial language | Aesthetic | 5 |

What is solid (do not regress): the §7.3 CatchField doctrine is correctly
applied in **both** directions (edit = field rows, storytelling = expressive
components, zero crossover); containment R1–R5 has no violations; zero raw
`GestureDetector` in `lib/user_profile` / `lib/public_profile`; Widgetbook
coverage is essentially complete; the edit-tab state adapter is provider-free
and tested; saves are serialized through a proper queue
(`profile_edit_controller.dart:64-115`); 14 deterministic capture states cover
loading/error/offline/upload/inline-save/text-scale/reduced-motion.

---

## 2. Product & UX critique

### 2.1 The tab you live on has no you in it

The Edit tab is a well-built form — and nothing else. No hero, no photo of you
larger than a 3:4 thumbnail, no stats, no share CTA, no "view as others" deep
link (the public surface is unreachable from your own tab). Meanwhile a
finished coaching engine computes a weighted /100 quality score with top-3
suggestions (`profile_insights/quality.dart:35-105` + `profile_quality_copy.dart`)
and **nothing renders it** — only `isStrong` gates one confidence chip shown to
*other* viewers (`helpers.dart:9-16`). The router hard-redirects incomplete
profiles to onboarding (`go_router.dart:1042-1076`), so the users who most need
guidance never see any.

**Recommendations:** surface the quality score + top suggestion as a
completeness module on the Edit tab (the engine exists — wire it); add a share/
"view as others" action; fix the "Profile not available" empty state, which is
currently a dead end with recovery copy but no action
(`profile_screen.dart:219-229`) — same anti-pattern as Explore's no-clubs empty.

### 2.2 The preview can lie

Preview renders a **client-side projection** (`publicProfileFromUserProfile`,
`public_profile.dart:53-77`), not the server-owned `publicProfiles/{uid}` doc
that other members actually receive. Any drift between the projection logic and
the server projection (field allowlists, grading, ordering) means the one
screen whose entire job is "show me what others see" does not. This is the same
honesty class as Explore's "Claim a seat".

**Recommendation:** render the preview from the persisted `publicProfiles` doc
(a server-preview callable if rules forbid self-reads), and label the state
when the served doc is stale ("others may still see an older version").

### 2.3 Photo management is the riskiest interaction on the surface

- The grid's inline ✕ deletes **immediately, no confirmation**
  (`profile_tab.dart:223-232`) while the photo editor's delete has a confirm
  dialog (`profile_photo_editor_screen.dart:152-178`) — the cheap path is the
  destructive one. On a dating app, photos are the product; an accidental tap
  costs a re-upload and re-crop.
- The ✕ target is **28×28** (`photoSlotDeleteExtent = s7`,
  `catch_tokens.dart:1889`) — well under the 44px floor.
- Reorder is long-press drag only, with `enableAnimations: false`
  (`photo_grid.dart:69-90`): no handle, no hint, no semantic/keyboard
  alternative — undiscoverable for everyone and impossible for screen-reader
  users.
- Each filled slot carries four pieces of chrome (MAIN badge, ✕, pencil tile,
  truncated prompt pill like "Proof I actu…") on a ~110px thumb — the pills
  truncate to uselessness at this size; consider caption-on-detail only.
- The crop editor (`InteractiveViewer`) has no semantics, and
  `PhotoPromptAnswer.caption` exists in the domain but **no input renders it
  anywhere** — dead end-to-end; ship a caption input or drop the field.

**Recommendation:** confirm-before-delete on the grid (or an undo snackbar),
44px targets, a discoverable reorder affordance plus semantic move actions, and
either ship or delete the caption.

### 2.4 No trust layer

There is **no verification state** anywhere in `UserProfile`/`PublicProfile`
and no badge UI — photo verification is table stakes in dating and its absence
shapes everything the surface can't say. There is **no pronouns field** in the
domain at all; gender is collected and read-only but never rendered on any
surface. If these are deliberate omissions, they should be recorded as product
decisions; if not, they are the roadmap. (Report/block on the public profile is
well done: 4-reason sheet + block dialog + auto-pop,
`public_profile_screen.dart:49-116,267-331`. One fragility: the menu selection
compares **localized display strings** at `:132-144` — route on ids.)

### 2.5 Reaction chrome is noise, and may collide

On the catches deck, **every** body section gets an identical heart+comment row
(compatibility, prompt, running, details, lifestyle…). Five-plus identical
action pairs per profile dilutes the signal they exist to create ("which thing
did they like?") and visually taxes every hairline section. The hero reaction
control sits at `top: s4, right: s4` (`catch_profile_view.dart:160-171`) — the
same top-right band as the deck's filter overlay
(`swipe_screen.dart:381-447`); current captures are inconclusive, so verify
interactively, but the geometry is a collision by construction. Also: reaction
and comment-sheet labels are hardcoded English (§3.2), and the compatibility
copy is **run-centric** ("You both run to make friends",
`compatibility.dart:125`) in a product that now sells dinners, quizzes, and
pickleball.

**Recommendation:** one anchored reaction per content block (on the photo or
prompt, Hinge-style) instead of repeated rows; resolve the hero/overlay zone;
broaden the compatibility vocabulary beyond running.

### 2.6 The implicit-save model is mostly right — finish it

Save-on-blur with `saving → saved` status is the correct mobile pattern, and
the serialized queue is proper engineering. Gaps: no retry affordance on save
failure (edit again to retry); no undo; read-only rows (DOB, gender, phone) are
interleaved with editable ones in the same "About you" section without a
visual/semantic distinction — users will tap them and learn by failure.

---

## 3. Visual correctness (pixel-peep)

### 3.1 Token bypasses & primitive bypasses

| File:line | Literal | Should be |
|---|---|---|
| `profile_reaction_controls.dart:260` | `Duration(milliseconds: 120)` | `CatchMotion.fast` |
| `profile_reaction_controls.dart:274` | spinner `strokeWidth: 2.2` | named spinner-stroke token |
| `catches_pass_button.dart:35,54` | `Duration(120)`, spinner `2.6` | same |
| `photo_slot.dart:270` | stripe tint `ink @ 0.05` | named opacity token |
| `photo_slot.dart:243` | `CatchStroke.selection - 1` | named reorder-stroke token (no token arithmetic) |
| `profile_info_chip.dart:27` | `BoxConstraints(maxWidth: 260)` | layout token (moot — widget is dead, §4.4) |
| `catch_person_avatar.dart:130,393,518` | initials/icon scale literals (0.30/0.34/0.38), blur 3.5, veil alpha 0.75 | named scale tokens (only the activity variant has one) |
| `swipe_screen.dart:328` | `CatchSpacing.s16 * 3` skeleton width | named skeleton extent |

More consequential than any literal: hero and inset photos use raw
`Image(image: NetworkImage(url))` (`profile_view_mapper.dart:204-210`,
`catch_profile_view.dart:238-240`), bypassing `CatchNetworkImage`'s decode-size
cap and branded error state — the edit grid's `PhotoSlot` does it correctly
(`photo_slot.dart:71-88`). The flagship should not be the surface that skips
the primitive.

### 3.2 Localization bypasses (user-facing)

`'Was at · $title'` hero kicker (`profile_surface.dart:344`); all three
per-mode semantic hints (`:362-370`); reaction tooltips and comment-sheet
strings — `'second profile photo'`, `'Photo $ordinal'`, `"$name's $ordinalLabel"`,
`'Pace …'`, `'Distance …'`, `'Any event'` (`profile_view_mapper.dart:177-236`);
all compatibility-reason copy (`compatibility.dart:22-135`); the photo-grid
`mainLabel = 'MAIN'` badge (`photo_grid.dart:40`). Same systemic l10n gap as
Explore §2.10 — fix as one sweep.

### 3.3 Tap handling

Clean overall (all edit rows through `CatchField.*`; reaction buttons 44px+;
pass button 64px). Exceptions: the 28px delete (§2.3), drag-only reorder
(§2.3), and the semantics-less crop view (§2.3).

### 3.4 Hero grade question

`CatchGradedImage` applies the grade by **theme brightness**, so the
"always-dark wow hero" receives the *light* grade under a light theme
(`catch_profile_view.dart:127-214`). The heavy `CatchScrim.heroTint` rescues the
contrast in current captures, but the grade contradicts the ratified
always-dark intent (`design_language.md:59`). Confirm intent; if the hero is
meant to be dark-first, grade it dark-first.

---

## 4. Widget reviews, duplication, primitives, hygiene

### 4.1 `CatchProfileView` / hero — the flagship earns its status

Graded 4:5 hero, bottom-radius 28 component token, 4-stop scrim, mono kicker,
Archivo display name, `numericMeta` line, hairline-separated body sections with
correct type roles (system-sans `profileAnswer` for user-authored prompts — the
right call), `CatchMetricStrip` running stats. This is the best-realized
surface in the app. Improvements: adopt `CatchNetworkImage`; decide the grade
question (§3.4); map a mutual-clubs/shared-context meta line — the `ProfileView`
doc comment promises "`2 MUTUAL CLUBS`" (`profile_view.dart:43`) and nothing
renders it, which is also the cheapest people-signal for Explore's §2.2 gap.

### 4.2 Duplication inventory

- Three hairline rules: `ProfileRule` (`catch_profile_view.dart:590`),
  `ProfileSurfaceRule` (`profile_surface.dart:326`), core `CatchDivider`.
- `ProfileSectionKicker` (`catch_profile_view.dart:306-320`) hand-rolls
  `CatchKicker`; the hero kicker is a third copy.
- `_trimToNull` × 3; `_migrateActivityPreferences` + `_stringKeyedMap` verbatim
  in both `user_profile.dart:358-380` and `public_profile.dart:120-142`.
- Skeleton grid re-declares the 3×2 delegate inline (`profile_tab_skeleton.dart:86-91`)
  despite `ProfilePhotoGridLayout` existing for exactly this (`photo_grid.dart:14`).
- Two diagonal-stripe painters; two dark caption pills (`PhotoCaption` proseM vs
  slot prompt pill labelS); hero shell geometry built twice (loaded + skeleton).
- Three hand-rolled circular overlay actions (reaction, pass, photo delete)
  with per-widget spinner strokes (2.2 / 2.6 / —).

### 4.3 Primitive promotions

| Proposed primitive | Configures | Adopting call sites |
|---|---|---|
| `CatchCircularOverlayAction` | fill/border alphas, extent, icon, spinner stroke, elevation | reaction controls, pass button, photo-slot delete |
| `CatchMediaCaption` | dark-scrim caption pill (style + radius params) | `PhotoCaption`, slot prompt pill |
| `CatchHeroFrame` | bottom radius + aspect + scrim + content/action slots | `ProfileHeroWidget` + its skeleton; later the event hero |
| `CatchKicker` adoption | (exists — use it) | `ProfileSectionKicker`, hero kicker |
| `CatchProfileRule` merge | one hairline rule | both Profile rules → or `CatchDivider` |
| `CatchNetworkImage` adoption | (exists — use it) | hero + inset photos |

### 4.4 Dead code to retire

`ProfileInfoChip` (zero call sites, keeps `ProfileCardPalette` alive); 8 of 14
`ProfileCardPalette` fields + 5 dead `CatchOpacity` tokens; `ProfileInlineTextValue`
(exported, no call sites); `PhotoPromptAnswer.caption` (end-to-end); the empty
`lib/swipes/presentation/profile_redesign/` directory; the deprecated `value`
param on `ProfileInlinePromptEntryEditor`; the dark quality-suggestion path
(unless §2.1 wires it).

### 4.5 Catalog & baseline staleness

`docs/widget_catalog.md`: 5 entries name classes that no longer exist
(`:6769-6773`), 4 point at pre-move paths (`:6724,6768,6774-6778`), and symbol
drift throughout (`:6881` `ProfileDirectTextEntry`, `initialTabIndex` vs actual
`initialTab`). `design/screens/catch.screens.json` self-profile notes reference
a renamed controller. The `screen.profile.self` **design reference PNGs are
pre-Archivo** (serif "Your profile", 2-tab rail vs the current 3-tab
Edit/Preview/Insights) — same vintage rot as Explore §4.4; fold the fix into
that spec's W7 so all baselines regenerate once.

---

## 5. Design-language assessment (subjective)

The flagship is the strongest argument that the locked language works: warm
graded photography, one typographic voice, mono data, hairlines, restraint. The
taste problems are two vibe forks and one absence:

1. **Neo-brutalist chrome on an editorial canvas.** The catches deck's floating
   controls — thick black-bordered white circles with hard shadows (back,
   filter, and the big red ✕ pass button) — belong to a different, gamified
   language. `CatchElevation.physicalPassControl` makes them deliberate, but
   deliberation doesn't make them coherent: nothing else in the app draws 3px
   outlined circles. Either they become a ratified grammar with a written
   rationale (a "play" register, used only in the deck), or they move toward
   the floating-pill language (`floatingPillFill`) used elsewhere.
2. **The pigment-slab fallback hero.** When a profile has no photo, the hero
   becomes a full-bleed activity-pigment gradient with a ghost glyph — the
   largest single chroma surface in the app, on the screen where "color =
   activity" is least able to carry it (a person, not an event). The explore
   spec's "keep pigment off big fills" rule applies doubly here; a quieter
   ink/paper fallback with a small activity mark would age better.
3. **The absent middle.** The edit tab is 100% function and the preview is
   100% story; there is no surface where your own identity is *presented* to
   you (quality, completeness, share-worthiness). That's why the dark quality
   engine feels like the missing room in the house.

Net: unlike Explore (hierarchy inflation), Profile's language problem is
**register control** — one screen borrowing from a comic/gaming register and
one giant decorative pigment fill, against an otherwise disciplined editorial
system.

---

## 6. Prioritized workstreams

| WS | Scope | Size |
|---|---|---|
| **P1** | Trust & safety a11y: delete confirmation/undo, 44px targets, reorder alternative + discoverability, crop semantics, menu-selection by id | S |
| **P2** | Own-tab identity: wire the dark quality score/suggestions as completeness coaching, share / view-as-others, actionable unavailable state | M |
| **P3** | Preview honesty: render the served `publicProfiles` doc, staleness label, hero-grade intent decision | M |
| **P4** | Reaction economics: anchored-per-block reactions, hero/overlay collision fix, reaction l10n, de-run-centric compatibility vocabulary | M |
| **P5** | Craft fixes: §3.1 token table, `CatchNetworkImage` adoption, MAIN badge + hints l10n, caption ship-or-drop, skeleton grid reuse, read-only row distinction | S |
| **P6** | Primitives (§4.3) + dead-code retirement (§4.4) + catalog/screens-registry refresh; capture regeneration folds into explore-spec W7 | M |

Product decisions to record regardless of implementation order: verification
system (§2.4), pronouns field (§2.4), whether gender renders on any surface,
the long-term reaction model (§2.5), and whether "Insights" is host-only or
universal.

---

## 7. Open questions

1. Is the own tab meant to be a management surface or an identity surface?
   (Sizes P2.)
2. Photo verification: on the roadmap? Its absence constrains what any profile
   surface can claim.
3. Pronouns and displayed gender: deliberate omissions or gaps?
4. May the preview read the served doc, or do rules require a server-preview
   callable? (P3 implementation fork.)
5. Is the catches-deck control style a ratified "play" register or drift?

---

## 8. Evidence index

- Own tab: `lib/user_profile/presentation/profile_screen.dart:98-314`,
  `widgets/profile_tab.dart:116-311,186-232`,
  `self_profile_edit_tab_state.dart:279-303,584,615-649`,
  `profile_edit_controller.dart:64-115`, `inline_editor_*.dart`.
- Photos: `lib/image_uploads/shared/photo_grid.dart:14-134`,
  `photo_slot.dart:42-287`, `profile_photo_editor_screen.dart:45-178,248-287`,
  `photo_upload_controller.dart:153-331`; `catch_tokens.dart:1889`.
- Surface: `lib/swipes/shared/profile_surface/profile_surface.dart:96-159,326-370`,
  `catch_profile_view.dart:89-240,306-320,534,567,590`,
  `profile_view_mapper.dart:27-236`, `profile_reaction_controls.dart:252-291`,
  `profile_info_chip.dart` (dead), `profile_card_style.dart` (half-dead).
- Public: `lib/public_profile/presentation/public_profile_screen.dart:49-144,267-331`,
  `domain/profile_insights/compatibility.dart:22-135`, `quality.dart:35-105`,
  `helpers.dart:9-16`, `public_profile.dart:53-77,120-142`.
- Data: `user_profile_repository.dart:76-98,148-161`,
  `public_profile_repository.dart:31-83`; router readiness
  `go_router.dart:1042-1076,1138-1148`.
- Captures viewed: `design/reference_screens/screen.profile.self/{edit_tab,preview_tab}.png`
  (**stale — retired serif identity, 2-tab rail**);
  `artifacts/ui-captures/host-profile-tabbed-shell-20260716/light/profile_self_{edit,preview}_tab.png`
  (current); `artifacts/ui-captures/non-host-reference-baseline-20260625/light/public_profile_member.png`;
  `artifacts/ui-captures/full-catalog/post_run_catch_window/light.png` (stale copy,
  current code verified at `compatibility.dart:125`).
