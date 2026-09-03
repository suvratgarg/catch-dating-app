---
doc_id: design_language
version: 1.9.0
updated: 2026-09-02
owner: ui_elevation_initiative
status: active # identity locked; Phase 0–1 complete (bundled optical-sized fonts, B&W tokens, ActivityPalette routing, matte grade, anti-drift gates); Phase 2 flagship Profile built
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
> and the zero-diagnostic Catch UI gate) and the **Phase 2 flagship Profile** is built — see
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
**dark is reserved for "wow" surfaces** (event spotlight and celebration) and is
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
| **Voice / display** | **Archivo** (variable grotesque, locked to a single **78% width** — the "78% system") | brand moments, root headlines, compact route titles, event/club display titles, and the welcome reel |
| **Function / reading** | **Platform system font** (SF on iOS, Roboto on Android) | prose, bios, descriptions, user-authored names, buttons, navigation controls, inputs, and dense UI controls |
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

Route hierarchy is size and composition, not a competing font family. Root-screen
titles use `CatchTextStyles.headline` (Archivo, 32/600/1.04); compact pushed-route
labels use `CatchTextStyles.routeTitle` (Archivo, 20/700/1.16). A route whose title
becomes a user-authored person name selects the semantic identity title role and
stays in the platform family. Feature screens do not restate these styles.

---

## 6. Metaphors

**Presentation tiers (ratified 2026-08-05):** every entity material (event
ticket, organizer poster, person polaroid) ships in at least two tiers — a **hero**
form for surfaces where the entity earns attention, detail, and vertical
space (detail heroes, featured cards, cover moments), and a **condensed**
form for long lists and date-grouped rails (DateTicket rows, index rows).
More tiers are allowed when a surface justifies them; a surface never mixes
tiers within one list.

- **Ticket → events: keep & refine.** `event_ticket_surface.dart` (real `CustomClipper`
  notches, perforation, Hero card→detail) is strong, award-adjacent craft. Refine: the
  fixed `eventTicketMediaHeight = 136` → aspect-ratio/constraint (Dynamic Type); push
  the ticket-stub typography (serial/time treatment).
- **Poster → organizers: canonical.** Organizers announce a recurring scene;
  `CatchOrganizerPoster` is the shared material for Explore spotlight and Club
  Detail identity. Its bounded recipe exposes four layouts (`editorial`,
  `photo`, `split`, `minimal`) and three treatments (`paper`, `ink`, `signal`).
  Consumer surfaces use `editorial` + `paper` until a persisted host recipe is
  approved. Real cover photography or deterministic `OrganizerPosterArtwork`
  fills the media lane, while provenance/authority remains explicit overlay
  state rather than being implied by visual polish.
- **Polaroid → people: canonical.** `CatchPersonPolaroid` reserves the instant
  photograph for a person: portrait media, quiet identity caption, and optional
  context overlay. The shared Profile hero is the reference adopter. A future
  Cross Paths rail may attach the relevant event-ticket stub, but it must not
  expose identifiable attendees until its relationship and consent source is
  approved.

---

## 7. Surfaces, layout, motion, scope

- **Light + dark, used intentionally** — light for browse/forms, dark for wow surfaces.
- **Hairlines over boxes; generous whitespace; grid discipline.**

### 7.1 Containment doctrine — when a surface earns a border

Containers mark **objects and actions, never information**. A bordered or
filled surface in product UI must pass at least one of:

- **R1 · Collection object** — a peer in a set you browse or choose among
  (feed tickets, organizer posters, person polaroids, photo slots). The
  container is the object's material; material marks type (events are
  tickets, organizers are posters, people are polaroids).
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

### 7.1.1 Semantic line system — how an earned line looks

Containment decides whether a line exists. `CatchBorder` decides how every UI
separator, boundary, and interactive outline looks once that line has earned a
place. Callers choose a semantic reason through `CatchBorderRole`; they do not
pair a color and width independently.

| Role | Stroke | Contrast and state policy |
|---|---:|---|
| `separator` | 1 px | Quiet internal division; resolves from `line`. |
| `boundary` | 1 px | Passive object/list perimeter; resolves from `line2`. |
| `control` | 1 px | Resting interactive perimeter; resolves to at least 3:1 against both `bg` and `surface` in light and dark themes. |
| `selected` | 1.5 px | Selected/active perimeter in the semantic action color. |
| `danger` / `warning` | 1.5 px | Validation or status perimeter in the corresponding semantic color. |
| `focus` | 2 px | Keyboard-focus perimeter; deliberately thicker than rest and selection. |

Hover and press use fill feedback while retaining the resting border's color
and width, so pointer interaction never shifts layout. Keyboard focus always
uses the 2 px focus role and may add the shared focus halo. Disabled controls
fall back to the passive boundary role plus disabled opacity.

`CatchSurface.borderRole` is the normal low-level adapter;
`CatchSurface.borderSpec` is reserved for a role with a justified color
override. Raw `borderColor`/`borderWidth` remain deprecated migration shims.
Higher-level controls (`CatchButton`, `CatchIconButton`, `CatchChip`,
`CatchControlShell`, `CatchOptionCard`, search, tabs, and field sections) own
their state-to-role mapping. Decorative `CustomPainter` illustration strokes
are outside the UI-boundary system, but repeated artwork and progress geometry
still uses named `CatchStroke` roles instead of feature-local literals.

### 7.2 Geometry is owned by the primitive

Persistent offline/rehearsal context uses `CatchStatusStrip`: full-width,
square-edged bands with a shared icon, label-over-detail and trailing action
anatomy. The screen owner places them **below the complete primary tab rail**,
or below the title when there are no tabs; they never split title from tabs.
Tabs and strips stay pinned together as the title scrolls away. Regular body
content begins 24 pt after the last strip. Strips share 20 pt side gutters,
a 64 pt minimum band height and 44 pt action targets; wrapping content may grow
the band. At large text or narrow widths, actions reflow below the text.
These are durable context, not floating `CatchNotice` notifications or local
mutation errors. Existing semantic palettes and localized copy remain in use;
neither fixture sync timestamps nor unimplemented global Retry actions ship.

When a component family has shared placement geometry, the canonical primitive
owns that geometry along with safe-area, platform, focus, and disabled/loading
behavior. Callers provide semantic state, content slots, and callbacks; they do
not rebuild the family as local `Row`, `Stack`, padding, or divider recipes.

- Notice identity is supplied by its feature adapter through `CatchNoticeData`:
  localized title/message, semantic tone, optional icon, optional
  `CatchPersonAvatarItem`, and an optional theme-derived `accentColor`. A person
  replaces the status glyph and reuses `CatchPersonAvatar` for circular photos
  and initials fallback. The shared notice still owns typography, icon/avatar
  extent, spacing, surface and tint derivation. Do not create separate visual
  match/message widgets merely to change copy, identity or color. A color
  override does not waive contrast review in both themes.
- Primary screen CTA placement routes through the `CatchBottomAction` family.
  `CatchBottomAction` owns one floating Cupertino or anchored Material action;
  `CatchBottomActionOverlay` owns pinned multi-action form controls over a soft
  fade and blur while the form remains visible and scrollable beneath them.
  `CatchBottomDock` is a required-child utility plane for chat inputs and
  compact action strips, not a second CTA family.
- Top-bar action grouping routes through `CatchTopBarActionGroup`; callers do
  not compose parallel header rows. A primary root-screen action uses
  `CatchTopBarPrimaryAction`, which owns the compact 40 px bordered icon and
  wider labelled-button variants. Semantic text, icon-only, and overflow
  actions use `CatchTopBarTextAction`, `CatchIconAction`, and
  `CatchTopBarMenuAction`. Do not pass a body-style `CatchButton` directly into
  any top-bar `actions` slot.
- Screen hierarchy follows one control per level. Shell destinations express
  product-level navigation; pinned `CatchTabRail` / `CatchTabbedScreenScaffold`
  tabs switch peer views within one destination. A small fixed set of terse,
  mutually-exclusive filters uses `CatchOptionGroup`; longer, numerous, or
  dynamic mutually-exclusive filters use `CatchAdaptiveSelectionControl` so
  options do not disappear beyond the viewport. Selectable chips express
  independent binary or multi-select values, not scalar scope or lifecycle
  rails. A query that searches the whole active view belongs to that screen's
  top bar through expanding `CatchTopBarSearch`, while a permanently visible
  `CatchSearchField.expanded` is reserved for a search-first browse toolbar.
  Feature-local pill groups do not substitute for peer-view tabs.
- Pushed utility/list and identity chrome routes through
  `CatchRouteScaffold`; it owns the page surface and shows a divider only when
  vertical content has actually scrolled beneath the compact bar. Root tab
  titles are scroll content rather than fixed app bars.
- Root title screens route through `CatchRootScreenScaffold` (or its
  parent-scaffold `CatchRootScreenScrollView` variant), and pinned peer-tab
  screens route through `CatchTabbedScreenScaffold` plus
  `CatchTabbedPageScrollView`. Every body declares the one regular `standard`
  geometry (20 pt phone gutter, 24 pt body start) or explicitly edge-owned
  `fullBleed` geometry through `CatchScreenBodyLayout`; feature screens do not
  reconstruct title gaps, page gutters, terminal navigation clearance,
  responsive content lanes, or state-viewport placement. Tabbed roots use a
  4 pt title-to-rail handoff, 44 pt rail, and the same 24 pt body start.
  `CatchInsets.pageBody`, `CatchInsets.tabbedScreenTitleBlock`, and
  `CatchLayout.tabRailHeight` own those values. Full bleed removes only the
  outer inset; named nested lanes such as `CatchInsets.chatListGutter` keep
  Consumer Chats and Host Inbox on the same 20 pt horizontal rhythm.
- Every full-screen composition terminates in
  `CatchScreenScaffold.standalone`, `.stepFlow`, or `.workspace`; higher-level
  root, tabbed, and pushed-route owners delegate to that role. Only the
  canonical primitive may construct a Material `Scaffold`. The composition gate
  reconciles route, coverage, and registry membership; resolves declared
  owners; verifies an allowed family expression and selected explicit body and
  top-edge arguments; rejects unauthorized raw `Scaffold` construction; and
  proves analyzer-resolved reachability from every rendered
  `builder`/`pageBuilder` target to each registered owner declaration and
  requires branch-universal static proof across every statically reachable
  widget-producing terminal. The checker does not execute conditions; it treats
  every reachable branch as possible, so every build/return arm, approved
  widget-builder callback, local helper/value, and registered same-family
  delegate must terminate in the declared layout family. It also discovers all
  full-screen `PageRoute` forms globally. Only direct `MaterialPageRoute`
  construction is supported and generated into the imperative route inventory;
  aliases, tear-offs, factories, `CupertinoPageRoute`, `PageRouteBuilder`, and
  subclasses fail closed. Other geometry/top-edge metadata remains review
  policy, while focused tests prove runtime state and redirect behavior.
- Widget names share one namespace across `lib/**`, `apps/consumer/lib/**`, and
  `apps/host/lib/**`. Source discovery resolves widget subclassing transitively,
  then rejects exact public-class duplicates and ungoverned normalized-name
  collisions across all three production roots. Only `.g.dart`,
  `.freezed.dart`, and the named localization outputs are excluded as generated
  source; a hand-authored file is not exempt merely because it lives below a
  directory named `generated`.
- Compact route bars use the default `CatchTopBar` geometry. Feature screens do
  not override height, safe-area, alignment, gutter, or content padding. A
  detail route whose title is loaded asynchronously carries the known subject
  label through navigation so loading and error states never fall back to a
  parent collection title.
- Section titles and trailing actions route through `CatchSection` or the
  reviewed contained/content owner. A feature-local header-plus-card shell is
  scanner-visible debt. Loading, empty, and error children inherit their
  section's divided, contained, or plain surface decision; state changes do not
  introduce a second border or switch a peer module to a different variant.
  `CatchErrorBody` is therefore cardless in full-screen, inline, and compact
  modes; its placement adapter supplies spacing while the parent owns any
  justified containment.
- `CatchSection.containedFieldRows` treats its title, count, and trailing action
  as an external label by default, so the outline begins with the first field.
  When that header belongs to the bounded field group itself, opt into
  `CatchSectionHeaderPlacement.inside`; the header moves inside the
  outline and owns the same padded section rule used by uncontained field
  sections. Omit the label when the page or step title already supplies the
  same context. `CatchSection.contained` keeps its sentence-case title inside
  only when the bounded surface is itself one actionable content module.
- `CatchSection.containedFieldGroups` is the one-perimeter form for a single
  collection with labelled internal choice groups. Callers supply
  `CatchSectionFieldGroup` labels and rows; the section owns the group kickers,
  inset boundaries, sibling dividers, clip, and rectangular active bands. Do
  not represent those groups as separate outlined sections or rebuild their
  headers and rules in feature or Widgetbook code.
- `CatchSection.fieldRows` owns one interaction policy for all of its fields.
  Compact single-column pages default to a rectangular full-bleed tint that
  reaches the page interaction plane; split panes default to an inset rounded
  perimeter. A complete section may choose the other semantic policy, but an
  individual field cannot select radii, gutter, bleed, dividers, or perimeter.
  `CatchSection.containedFieldRows` keeps rectangular active bands inside one
  section-owned clip, with their vertical edges aligned to the single outline.
  Pointer-down, open, active, and keyboard-focus states use the same selected
  policy, and their transition replaces adjacent divider visibility instead of
  painting a second line across it.
- `CatchFieldLanes.divided` is the headerless sibling-row owner. It supplies the
  canonical gutter, derived separators, and inherited interaction policy. Use
  `.single` only for one ungrouped field and `.custom` for content that is not a
  field list; feature code does not configure lane gutters or field dividers.
- A typed form section owns one text-commit model for all of its sibling rows.
  Explicit confirmation with Cancel and Done is the default for new
  `CatchFormRowList` sections. An existing surface may opt the complete section
  into on-blur commit while it awaits a reviewed product migration; individual
  row descriptors cannot mix policies or choose their own commit chrome.

The API boundary is the first enforcement layer: duplicate placement variants
are deleted rather than kept as aliases. Component contracts, Widgetbook
states, and the section/top-bar scanners provide the review and regression
layers.

The reviewed Flutter library surface is `package:catch_dating_app/catch_ui.dart`.
It exports semantic tokens, fields, sections, page composition, responsive
policies, and typed form orchestration while excluding renderer scopes and
focus-surface implementation members. Analyzer diagnostics reject feature-level
construction of those internal geometry objects and reject field-owned sibling
dividers or lane-gutter overrides that still type-check.

#### Living component geometry review

Cross-family geometry is reviewed code-first in Widgetbook under
`[Geometry system]`. Those pages render the production primitives and compare
only the states that reveal shared silhouette, edge, spacing, alignment, plane,
safe-area, and viewport rules. They complement rather than replace each
component's exhaustive `Contract states` page.

The review source hierarchy is:

1. Flutter runtime behavior and semantic roles own exact geometry.
2. `design/components/catch.components.json` owns legal component identity,
   states, slots, and token dependencies.
3. Widgetbook's geometry matrices make relationships between component families
   inspectable at compact and adaptive viewports.
4. Approved captures or Figma components may document the reviewed result, but
   do not override runtime behavior without a corresponding code and contract
   change.

When a geometry review identifies drift, classify it as a token, primitive,
composition, consumer-override, unsupported-state, or responsive/accessibility
problem. Fix the lowest shared owner, update its contract states when the legal
API changes, and update the relevant geometry matrix when the relationship
between families changes. Do not copy exhaustive component states into the
matrix or create a second geometry registry.

### 7.3 CatchField doctrine

`CatchField`/`CatchSection` are the canonical surface for *entering and
managing data*: edit tabs, settings, configuration, onboarding forms, and
admin-ish host tooling. They are forbidden as storytelling surfaces — browse,
discovery, celebration, and insight/scorecard moments compose expressive
components (polaroid, ticket, hero, stat/chart kit) instead. If a screen is
something a user *reads for meaning* rather than *operates*, it should not be
built from field rows.

New `CatchField` modes or slots require a `docs/widget_catalog.md` entry, a
Widgetbook contract story, and a behavior-contract test under
`test/core/widgets/catch_field/` in the same PR.

The cross-stack vocabulary is machine-readable at
`design/components/catch.components.json#interactionContracts`. Flutter owns
the exact mode, slot, save-state, and section-variant names; React surfaces map
native components onto those semantics rather than sharing implementation.
The optional `build/reports/field_facade_inventory.json` report is generated
from the live Flutter API and carries this doctrine's forbidden storytelling
surfaces for review. Run `npm run design:fields:facades:check` after changing
the field or section API.

Field-local terse binary and multi-select labels use `CatchField.choices` and
selectable chips. Page-level scalar filters follow the option-group/adaptive
selection rule above.
Mutually exclusive options with per-option guidance use
`CatchField.optionCards`: the selected title owns the collapsed value, and
each expanded title plus description stays inside one clickable
`CatchOptionCard`. Do not put only the selected description in the field body;
that detaches the explanation from the options it describes.

- **Sizing:** constraints over constant heights/widths; min/max constraints, intrinsics,
  `Flexible`/`Expanded`, `AspectRatio`, content max-width clamp. Resilient to **Dynamic
  Type** (validate at text scale 1.0/1.5/2.0).
- **Scale targets:** Host covers phone, tablet, and desktop web/Mac windows plus
  Dynamic Type; other product surfaces remain phone + Dynamic Type until their
  owner adopts an explicit adaptive contract. Larger Host classes recompose
  navigation, panes, task concurrency, and density; they do not proportionally
  enlarge phone components. The canonical Host contract lives in
  [`app_architecture.md#host-adaptive-workspace-specification`](app_architecture.md#host-adaptive-workspace-specification).
- **Motion:** route motion through `CatchMotion` and
  `lib/core/motion/catch_transitions.dart`. Use `catchSelectionHaptic()` for
  discrete choices, `catchTransitionHaptic()` for map/sheet state changes,
  `catchFadeScalePageTransition` for calm card-to-detail routes, and
  `catchHeroSurface`/`CatchTicketHero` for ticket or polaroid flights. Avoid
  raw `Duration(...)`, ad-hoc `Hero`, and direct `HapticFeedback` in product UI
  unless a new named motion primitive is being introduced.

---

## Cross-stack component lexicon

`design/components/catch.components.json` is the binding semantic lexicon for
Flutter, website, admin, and the shared web UI package. Implementation remains
stack-native; the registry shares identity and contract ownership, not widget
or component code.

Each component declares a `surfaces` map. Every declared symbol must exist in
its owning source tree. Entries in `design/website/components.json`,
`design/admin/components.json`, and `design/web-ui/components.json` opt into the
binding with `lexicon: true` plus a `lexiconId`; the symbol must exactly match
the corresponding surface link. New or moved design-system components must add
the link in the same change.

Run `node tool/run.mjs check design:component-lexicon`. The checker remains a
repo-level JavaScript gate, including for Flutter symbol existence; do not move
this contract into the `catch_ui_lints` analyzer plugin.

Every component contract also carries either an `enforcement` decision or an
expiring `waiver`. Enforcement metadata is executable: it generates raw-widget
steering tables and seeded probes for the Catch analyzer plugin, while a
bidirectional coverage gate rejects catalog components without a decision and
implemented `catch_*` diagnostics without a catalog owner. Screen composition
is registered separately with shell, top-bar, and state policies and validated
with analyzer resolution.

Structural labels and status badges are separate semantic families. Use
`catch.ui_label` (`CatchSectionLabel`, website `UiLabel`, admin
`AdminEyebrow`, web-ui `UiLabel`) for eyebrows and compact hierarchy context.
Use `catch.badge` (`CatchBadge`, `StatusBadge`, `StatusChip`, `BadgeControl`)
for status, state, counts, and alerts. The lexicon gate pins these mappings so a
shared visual treatment cannot erase their different meanings.

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
