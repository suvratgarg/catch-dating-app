---
doc_id: widget_catalog
version: 2.5.278
updated: 2026-06-15
owner: recursive_audit_loop
status: active
---

# Widget Catalog

## Read Policy

Use this as inventory, not as the primary process prompt. For process rules,
start with `docs/audit_registry/README.md`,
`docs/audit_registry/rules.json`, and `docs/audit_registry/backlog.json`. Read
a feature section here only when auditing that feature's widget surface.

## Rule Changelog

### 2.5.278

- Added `CatchErrorIcon` as the shared branded error medallion primitive.
  `CatchErrorState` and `CatchFrameworkErrorView` now compose it instead of
  carrying duplicate private `_ErrorIcon` helpers.
- Added `CatchMonoLabel` as the shared one-line mono metadata primitive for
  ticket/event-card chrome, replacing duplicate private `_MonoLabel` helpers.
- Moved the remaining core widget color literals for photo grading and floating
  icon chrome into token-owned static color roles.

### 2.5.277

- `BottomCTA` now forwards an optional `buttonAccentColor` into its underlying
  primary `CatchButton`, allowing event booking docks to use activity pigment
  without per-screen button styling.
- `EventDetailCta` now resolves the current event activity and applies that
  accent to booking, request-to-join, and accept-spot actions while preserving
  neutral treatment for waitlist, cancel, past, and ineligible states.

### 2.5.276

- `EventDetailPhotoStrip` now renders the handoff three-tile strip for
  non-empty event photo sets: uploaded photos fill leading slots, remaining
  slots render activity-soft placeholders, and all tiles use the 108px strip
  height with the caption/data row below.

### 2.5.275

- `PersonAvatarStack` now matches the handoff `AvatarStack` contract more
  closely: photo-less people render initials over the existing activity-derived
  avatar gradient, stacks can render activity-tinted veiled placeholder circles,
  and the overflow `+N` circle uses the quiet raised surface treatment.
- `EventHypeAvatarStack` now uses veiled activity placeholders for obscured
  event-detail attendee rows instead of fetching and blurring profile photos;
  revealed stacks keep the public-profile thumbnail provider path.

### 2.5.274

- `CatchButton` now exposes the handoff primary activity accent shortcut through
  `accentColor`, pairing pigment fills with white ink while preserving explicit
  `backgroundColor` / `foregroundColor` overrides for legacy custom buttons.

### 2.5.273

- `CatchChip` selected state now follows the handoff rule: transparent fill
  with the 1.5px ink selection outline. Resting chips keep the surface fill,
  and activity-tinted chips still use their supplied activity soft/deep colors.

### 2.5.272

- `CatchTextField` now carries more of the handoff `TextField` contract:
  `CatchTextFieldVariant.underline`, centered text alignment, tabular numeric
  figures through `mono`, forced focus styling for static/mock compositions,
  and a quiet trailing widget slot. Existing boxed editable fields keep their
  default shell, sizing, validation, and clear-button behavior.

### 2.5.271

- `CatchScreenBody` now maps the handoff `ScreenBody` composition directly:
  it owns the vertical scroll region, app-wide horizontal gutter, top/bottom
  padding overrides, full-bleed gutter opt-out, and a non-scroll escape hatch
  for screens whose parent already owns scrolling.

### 2.5.270

- Added `CatchStepHeader`, the Flutter port of the handoff `StepHeader`: large
  `CatchTopBar` anatomy with inline back/close-compatible leading behavior,
  optional kicker/subtitle, top-right `STEP n OF m` mono counter or custom
  trailing status, gutter ownership, and a 2px ink progress hairline.
  `CatchStepFlowHeader` remains as the existing zero-based compatibility
  wrapper for onboarding/create flows.

### 2.5.269

- Added `CatchTabDock`, the Flutter port of the handoff `TabDock`: translucent
  blur surface, top hairline, 10/12/18 padding, 22px active filled glyphs,
  uppercase mono 8.5px labels, selected/idle ink roles, and badge support.
  `AppShellNavigationBar` now uses it for non-iOS authenticated bottom
  navigation while keeping the existing native `CupertinoTabBar` branch on iOS.

### 2.5.268

- `CatchTopBar` now carries the handoff `AppBar` API: compact and large
  editorial headers, `kicker` / `subtitle` text roles, back / close / none
  leading modes, surface/divider/gutter ownership, text/icon/trailing action
  shortcuts, and declarative `CatchExpandingSearch` composition that hides the
  title while search is open. Existing `actions`, custom `leading`,
  `showBackButton`, and tab-bottom behavior remain supported.

### 2.5.267

- `IconBtn` now matches the handoff `IconButton` primitive: 44px default
  circular target, bordered / float / plain variants, surface + line2 bordered
  chrome, translucent floating photo/map chrome with soft shadow, active accent
  tinting through `IconTheme`, disabled opacity, and a 40px `navSize` constant
  for app-bar back/actions.

### 2.5.266

- Added `CatchCodeInput`, the Flutter port of the handoff `CodeInput`: 6-cell
  default row, controlled `value`, optional active cell override, 64px cell
  height, 10px gap, surface fill, interactive-tile radius, ink active rule, and
  optional caret. `CatchOtpCodeField` now composes the same visual primitive
  over one hidden platform `TextField` for SMS autofill, paste, digit filtering,
  length limiting, and auth form tests.

### 2.5.265

- Added `CatchStatusBar`, the Flutter port of the handoff `StatusBar` for
  phone-frame/mock surfaces: 14px bold mono time, Phosphor fill signal/wifi/
  battery glyphs, light/dark tone support, and optional surface band fill.

### 2.5.264

- `CatchSectionStack` now matches the handoff `SectionStack` ownership model:
  it owns only the 24/20/20 page gutter and no longer inserts an extra
  inter-section gap by default. `CatchDesignSection` remains the single owner
  of the 24px hairline delimiter rhythm and 12px kicker/body gap.
- `CatchDetailSliverSectionList` now also defaults to no inserted gap so
  sliver-native detail pages can use the same section-owned rhythm.

### 2.5.263

- `CatchBottomSheetScaffold` now matches the handoff `Sheet` scaffold: surface
  panel with overlay shadow, `26px/30px` bottom-sheet radii, 10/22/26 padding,
  optional grabber, plain title/subtitle header, branded glyph-tile header,
  and badge/trailing right-side header slots.

### 2.5.262

- `CatchEmptyState` now defaults to the handoff `EmptyState` presentation:
  cardless centered content, optional quiet 34px ink3 glyph, section-title
  headline, body-small message, 24px horizontal padding, and optional action
  slot. Explicit `surface`, `bubble`, and `inline` modes remain for embedded
  legacy contexts that need them.

### 2.5.261

- Added `CatchExpandingSearch`, the Flutter port of the handoff
  `ExpandingSearch`: collapsed magnifier affordance, controlled animated growth
  into the shared raised-pill `CatchSearchField`, and clear-first-then-close
  trailing behavior.
- `CatchBrowseHeader` now composes `CatchExpandingSearch` directly and accepts
  controlled search value/change callbacks, so Clubs and Chats bind provider
  query state through the shared app-bar search primitive.

### 2.5.260

- Added `CatchMenu`, the Flutter port of the handoff `Menu`: overlay surface,
  line2 border, radius-md corners, row hairlines, optional icon/sublabel,
  selected check mark, and danger row tone.
- `CatchActionMenu` now anchors the shared `CatchMenu` panel instead of native
  `MenuItemButton` rows, and supports sublabels plus selected rows for club
  pickers and overflow actions.

### 2.5.259

- Added `CatchSearchField`, the Flutter port of the handoff `SearchField`:
  raised pill input, 15px magnifier, quiet x-circle clear target, controlled
  value sync, and submit/focus callbacks for browse headers.
- Chats and Explore search wrappers now bind their query providers to
  `CatchSearchField` instead of configuring the heavier form-oriented
  `CatchTextField` for browse search.

### 2.5.258

- Added `CatchPanel`, the Flutter port of the handoff `Panel`: bounded
  `surface` card, hairline border, `radius-md`, 20px default padding, and soft
  card shadow for self-contained groups and flow stages.
- `CatchSectionCard` now composes `CatchPanel` instead of restating the card
  surface contract directly.

### 2.5.257

- Reintroduced `CatchKicker` as the handoff `Kicker` leaf primitive, replacing
  the old legacy helper with the current contract: uppercase mono eyebrow,
  optional color override, and `md` / `lg` sizes.
- `InfoGroup` and `CatchDesignSection` now compose the shared kicker primitive
  instead of rendering local uppercase kicker `Text` directly.

### 2.5.256

- Promoted the Material confirm-card implementation to public
  `CatchConfirmDialog<T>` and added `showCatchConfirmDialog` for the handoff
  two-action confirm API with default Cancel/Confirm labels and danger-filled
  destructive commits.
- Confirm dialogs now use centralized handoff tokens for the 46% ink scrim,
  320px max card width, 28px overlay inset, and `24px 22px 18px` card padding
  while preserving Cupertino alert chrome on iOS.

### 2.5.255

- Added shared `InfoRow` and `InfoGroup`, Flutter ports of the handoff
  on-surface row/group grammar. They cover inline and stacked rows, add and
  danger affordances, chevrons, toggles, and injected quiet dividers inside
  kicker-delimited groups.

### 2.5.254

- Added shared `StatStrip`, the Flutter port of the handoff flat
  hairline-bordered stat row. Club detail stats now use it instead of the more
  general `CatchMetricStrip`, with uppercase mono labels and numeric figures.

### 2.5.253

- Added shared `ActivityArt`, the Flutter port of the handoff generated
  activity-art surface with activity pigment, screen-print texture, faint glyph
  motif, optional dim layer, radius/height controls, and overlay child slot.

### 2.5.252

- Added shared `DistanceRing`, the Flutter port of the handoff map radius ring:
  default 170px ring, 1.2px ink stroke, and optional tappable mono label for
  static map canvases and previews.

### 2.5.251

- Added shared `ActivityMapPin`, the Flutter port of the handoff `MapPin`.
  Event-detail map cards now use the activity-pigment pin mark instead of a
  local rounded activity-glyph badge, with optional selected flag support for
  map surfaces.

### 2.5.250

- Added shared `ActivityAvatar`, the Flutter port of the handoff activity
  avatar. It resolves activity pigment through `ActivityPalette`, supports
  initials, explicit size, selected/live ring, dim veil, and the screen-print
  texture used by activity-register people surfaces.

### 2.5.249

- Added shared `ActivityChip`, the Flutter port of the handoff activity tag.
  It resolves `ActivityKind` through `ActivityPalette`, supports soft and
  primary registers, optional label override/tap behavior, and replaces the
  host-only activity-chip helper in `HostOperationsHomeScreen`.

### 2.5.248

- `CatchBadge` now matches the handoff `Badge` API more closely with
  `CatchBadgeSize.action` for 33px button-aligned outcome pills, explicit
  leading-icon coverage, a `gold` functional tone, and activity-accent tinting
  via `accentColor`. Existing compact/live badge behavior is unchanged.

### 2.5.247

- `CatchFrameworkErrorView` debug details now use a tokenized `CatchSurface`
  disclosure row with animated chevron/content instead of Material
  `ExpansionTile`, leaving the framework-error fallback dependency-light while
  aligning with the handoff disclosure pattern.

### 2.5.246

- `EventSuccessSetupBody` setup disclosure sections now use a handoff-style
  tokenized `CatchSurface` row with animated chevron and `AnimatedSize` content
  instead of Material `ExpansionTile`. Existing Guide notes / Advanced
  expansion behavior, module toggles, and draft updates are unchanged.

### 2.5.245

- Retired the unused `ListTileMaterial` compatibility wrapper now that app
  surfaces no longer need native `ListTile` rows inside custom sheet/surface
  chrome. Use shared row/surface primitives such as `SettingsRow`,
  `CatchSurface`, `PersonRow`, or feature-specific rows instead.

### 2.5.244

- `SuvbotActionBar` is now cataloged, and its reset-demo sheet uses
  `CatchBottomSheetScaffold` plus tokenized `CatchSurface` action rows instead
  of raw Material `ListTile` rows. Existing demo action routing, pending
  disablement, and text-action behavior are unchanged.

### 2.5.243

- `LocationPickerScreen` autocomplete suggestions now render with a tokenized
  local suggestion row inside the existing `CatchSurface` overlay instead of a
  raw Material `ListTile`. Search, selection, and map-confirm behavior are
  unchanged.

### 2.5.242

- `PublicProfileScreen` now uses branded `CatchErrorState` and
  `CatchEmptyState` surfaces for profile load failures and unavailable profiles
  instead of raw centered text, and the report reason sheet now uses shared
  `SettingsRow` action rows. The shared `ProfileSurface` body and report/block
  mutations are unchanged.

### 2.5.241

- `CatchChip` now matches the handoff `Chip` selection rule: active chips keep a
  surface fill with a 1.5px inset ink rule instead of an inverted ink fill. The
  primitive also exposes optional tint/ink colors for activity-tagged fact
  pills while preserving tap and remove behavior.

### 2.5.240

- `ProfileSurface` / `CatchProfileView` now renders passive compatibility and
  running-identity labels with `CatchBadge` instead of generic `CatchChip`.
  Editable chip fields remain on `ChipField`, and reaction controls are
  unchanged.

### 2.5.239

- `LaunchAccessApplicationScreen` now uses handoff `CatchToggle` row
  composition for the `I might host` binary setting instead of an adaptive
  Material switch tile. The Remote Config gate, signed-in guard, editable
  application draft, and submit mutation behavior are unchanged.

### 2.5.238

- `EventSuccessFeedbackForm` now uses handoff `CatchToggle` row composition for
  the private safety/comfort review flag instead of a Material checkbox tile.
  Feedback ratings, private note copy, and repository submission semantics are
  unchanged.

### 2.5.237

- `EventSuccessLabScreen` playbook module metadata now uses shared
  `CatchBadge` labels instead of generic `CatchChip` tags. The dev/staging WIP
  route, preview-only guardrails, and feature-block composition are unchanged.

### 2.5.236

- `EventSuccessDefaultsPanel` and `EventSuccessSetupBody` setup switches now
  use handoff `CatchToggle` row composition instead of adaptive Material switch
  tiles. Existing draft/default update callbacks and progressive disclosure are
  unchanged.

### 2.5.235

- `EventSuccessManualQaScreen` fixture controls now use handoff `SelectChip`
  choices for the scenario selector and `CatchToggle` rows for attendee opt-out
  settings. The existing side-by-side host/attendee fixture wiring and
  `CatchTopBar` chrome are unchanged.

### 2.5.234

- `EventSuccessHostPanel` now uses the handoff `CatchOptionGroup` primitive for
  its standalone Setup / Live / Report lifecycle picker instead of generic
  chips. Host Manage already supplies its fixed lifecycle section externally.

### 2.5.233

- `EventSuccessHostSetupFlow` is now cataloged and uses the handoff
  `SelectChip` primitive for the playbook/format selector. The setup draft,
  structure editor, module switches, and readiness issue behavior are
  unchanged.

### 2.5.232

- `EventSuccessSetupBody` is now cataloged and uses the handoff `SelectChip`
  primitive for rotation cadence, reveal countdown, and match-clue mode
  choices. Stage cards, recommendation toggles, guide-note fields, and draft
  update semantics are unchanged.

### 2.5.231

- `EventSuccessQuestionnaireConfigEditor` is now cataloged and uses the handoff
  `SelectChip` primitive for reusable/custom questionnaire template choices.
  Preview badges, custom-question editing, and bottom-sheet custom editing stay
  unchanged.

### 2.5.230

- `EventSuccessStructureConfigEditor` now uses the handoff `SelectChip`
  primitive for flow type, auto/fixed count, repeat policy, and assignment-goal
  choices. Badge summaries and numeric steppers remain unchanged.

### 2.5.229

- Explore filter-sheet distance and joined-club choices now use the handoff
  `SelectChip` primitive for choosy filters. The visible time-scope
  `CatchOptionGroup`, trailing `CatchCountPill`, active-count badge, and filter
  controller wiring are unchanged.

### 2.5.228

- Swipe Filters interested-in choices now use the handoff `SelectChip`
  primitive for choosy filters instead of the generic `CatchChip`. Age range,
  reset/apply actions, save payload mapping, and pop-on-success behavior are
  unchanged.

### 2.5.227

- Host Edit Event policy toggles now use the handoff `CatchToggle` row
  composition for cohort caps and demand pricing instead of adaptive
  `SwitchListTile` rows. Existing lock rules, validators, and save payload
  mapping are unchanged.

### 2.5.226

- Host Edit Event selectors now use the handoff `SelectChip` for pace,
  admission format, and cancellation policy choices. Schedule/location fields,
  policy-lock behavior, cohort-cap and demand-pricing toggles, and save payload
  mapping are unchanged.

### 2.5.225

- Host Create Club host-default selectors now use the handoff `SelectChip` for
  default activity, admission format, and cancellation policy. Default activity
  choices carry their own activity pigment; cohort-cap and demand-pricing
  switches remain on `CatchToggle`.

### 2.5.224

- Host Create Event policy selectors now use the handoff `SelectChip` for
  admission format and cancellation policy choices. Capacity, invite-code,
  cohort-cap, demand-pricing, age, and payout controls keep their existing
  field/toggle composition.

### 2.5.223

- Host Create Event basics now uses the handoff `SelectChip` for activity type,
  custom format structure, and pace choices. Activity chips carry their own
  activity pigment, while format/pace choices inherit the selected activity
  accent.

### 2.5.222

- Added `SelectChip`, the Flutter port of the handoff tactile selectable pill
  for questionnaire answers, mission choices, and choosy filters. It uses an
  accent selected fill, active glow/scale, pressed scale-down, selected
  semantics, and shared `CatchSurface` pill chrome.

### 2.5.221

- Added `SectionLabel`, the Flutter port of the handoff activity-accent
  eyebrow. It keeps the optional leading glyph and mono kicker label on the same
  accent color, with bounded ellipsis behavior for panel and section headers.

### 2.5.220

- Added `SoftBand`, the Flutter port of the handoff quiet tinted inset row for
  privacy notes, tips, and secondary details. It delegates primary-soft fill,
  small radius, and no-elevation surface behavior to `CatchSurface` instead of
  creating a parallel decoration primitive.

### 2.5.219

- Added `PrivacyBadge`, the Flutter port of the handoff privacy pill for
  `PRIVATE TO YOU`, `CATCH PRIVATE`, and `HOST CAN SEE` visibility hints. It
  uses shared surface, icon, spacing, and mono badge text primitives instead of
  local outlined-pill styling.

### 2.5.218

- Added `BookingConflictSheet`, the Flutter counterpart to the Booking
  handoff's `ConflictSheet`: warning sheet chrome, activity-colored existing /
  incoming event rows, and replace / keep-both / keep-existing action slots.
  The component is presentation-ready for a future booking-overlap flow without
  inventing backend replacement behavior in this pass.

### 2.5.217

- Host Account profile rows now open `_HostProfileEditorSheet` with
  `CatchBottomSheetScaffold` on the Account route instead of navigating to
  `HostProfileScreen`, matching the handoff's no-nested-editor composition
  while preserving the full-screen route for direct entry.

### 2.5.216

- Host Clubs now uses the handoff selected-club shell instead of rendering all
  operated clubs in grouped sections. The top bar title is the selected club,
  the shared top-bar menu switches clubs when needed, and a handoff
  `OptionGroup` exposes Edit / Preview. Edit mode now shows Identity,
  Contact, Event defaults, Public profile, Payouts, and Host team sections
  using on-surface `SettingsRow` composition.

### 2.5.215

- Notifications day groups now use a compact handoff screen wrapper instead of
  `CatchDesignSection`: first group starts flush under the Activity AppBar,
  later groups get an 8px section offset, top hairline, and 18px inset before
  the kicker and `NotificationRow` stack.

### 2.5.214

- Host Events now matches the handoff's single-club operations shell: owned
  clubs sort before co-hosted clubs, the top bar title is the selected club,
  the shared top-bar menu switches clubs only when multiple clubs are present,
  and the body shows that club's meta row, Upcoming rows, and Add event row.

### 2.5.213

- Host Inbox now exposes the handoff `All` / `Unread · n` `OptionGroup` below
  the pinned chats browse header. `ChatsListScreen` owns only the transient
  host filter state, while `ChatsList` applies the unread filter to the
  existing `ChatsListViewModel` and shows the host-specific no-unread empty
  state when needed.

### 2.5.212

- `profileViewFromCardContent` now follows the Profile handoff body sequence:
  compatibility, prompts, running rhythm, all inset photos, `Details`, then
  `Lifestyle`. Relationship intent is preserved as the first `Details` fact
  instead of creating a standalone `Looking for` section, keeping the public
  profile surface on the template's `FactList` composition.

### 2.5.211

- `AppShellNavigationBar` is now a shared destination-driven bottom navigation
  primitive. The consumer shell keeps its default Home / Explore / Catches /
  Chats / Profile destinations, while `HostAppShell` supplies Events / Clubs /
  Inbox / Account through the same Material/Cupertino chrome and fixed unread
  badge treatment.

### 2.5.210

- `CatchPolaroid` now uses named DS polaroid defaults for the tighter club-card
  material: 6px outer radius, 3px media radius, 24px upright Archivo title, and
  a title-row arrow affordance. Footer-heavy Explore/directory club cards can
  suppress the arrow to avoid duplicating their footer action row.

### 2.5.209

- `PhotoGrid` now matches the handoff core component contract more closely:
  filled profile photos render through the shared display-time `GradedImage`,
  pending upload slots use striped photo-placeholder material, empty slots draw
  dashed hairline targets with the plus glyph, and the leading filled slot gets
  a hideable mono `MAIN` badge.

### 2.5.208

- `OrderedPhotoPicker` is now cataloged and covered as the shared ordered media
  picker for host club/event forms. Photo and add tiles render through
  `CatchSurface`, keep stable add/remove keys, preserve semantic labels and
  tooltips, and show the shared broken-image affordance for failed network
  previews.

### 2.5.207

- `EventHypeAvatarStack` is now cataloged as the event-detail attendee-hype
  composition. It keeps the handoff path on shared `PersonAvatarStack` chrome,
  derives eligible signed-up/attended participants from the participation edge,
  joins public profile names/thumbnails, and uses deterministic obscured
  fallback avatars while async profile data loads.
- Riverpod generated companions for `EventHypeAvatarStack` and `WhoIsGoing`
  were reviewed as generated output paired to their source providers.

### 2.5.206

- Removed unused dashboard visual helpers `DashedAvatar` and `StaticMapDark`.
  Empty-dashboard composition now stays on the active `DashboardEmptySliverBody`,
  `EmptyHeroCard`, and `CatchDesignSection` path instead of retaining legacy
  standalone placeholder art widgets.

### 2.5.205

- Previously unreviewed core display atoms are now covered in
  `catch_primitives_test.dart`: `CatchCornerSash`, `CatchMetaDotRow`,
  `DetailRow`, `StatColumn`, `GradedImage`, and `CatchStartupLoadingScreen`.
- Core catalog rows now document the remaining compact atom roles, including
  startup loading, corner sashes, inline dot metadata, non-destructive photo
  grading, and dense metadata rows.

### 2.5.204

- `CatchTextStyles` now follows the handoff zero-tracking typography rule across
  display, condensed head, kicker, mono-label, and badge roles; style docs and
  active design-language docs now describe zero tracking instead of the previous
  negative/tracked rule.
- Design-system and profile golden baselines were regenerated for the intended
  central typography visual change.
- The cleanup scan now reports no app-facing design-system buckets for
  positional widget finders, raw controls, raw text styles, token prop-drilling,
  raw surfaces, low-level typography roles, or nonzero letter spacing. Remaining
  timing matches are the known manual QA/golden/capture helpers.

### 2.5.203

- `EventPinsMap` no-network placeholder now resolves token-derived colors in
  the widget and passes concrete `Color` values into its `CustomPainter`
  instead of prop-drilling `CatchTokens` through the painter boundary.
- The cleanup scan now reports no feature-widget `CatchTokens` prop-drilling
  candidates.

### 2.5.202

- `RichShareCardSheet` now exposes stable preview and share-action keys while
  keeping the shared sheet composition unchanged: grabber, captured card,
  footnote, and full-width platform share `CatchButton`.
- Club, event-detail, standalone event, and payment confirmation share-card
  coverage now targets `RichShareCardSheetKeys` and the shared pump helper, so
  the cleanup scan no longer reports share-card raw timing waits or positional
  `CatchButton.last` finders.

### 2.5.201

- Empty match threads now use the Messaging handoff's event-grounded prompt
  copy: when the latest shared event is loaded, `ChatMessageList` says what both
  people did at that event before the `Say hi` prompt; null event contexts keep
  the previous neutral fallback.
- `chat_event_context_copy.dart` now owns chat thread stamps, share-card titles,
  and empty-thread event-context copy so `ChatEventContextHeader`,
  `ChatShareCard`, and `ChatMessageList` stay aligned.

### 2.5.200

- `showBlockUserDialog` is now documented and covered as a thin safety dialog
  adapter over the shared handoff `showConfirmDangerDialog` /
  `showCatchAdaptiveDialog` confirm-card stack.
- Core adaptive-dialog tests now open the block-user helper directly and assert
  the Material `Dialog` + `CatchButton` destructive action composition.

### 2.5.199

- Removed unused legacy core widgets `AppFormLayout`, `CatchKicker`, and
  `StatusChip`. Active form/auth/onboarding surfaces now use the handoff
  `OnboardingStepFrame`, `CatchStepFlowHeader`, and feature-owned layout
  frames, while badge/status metadata routes through `CatchBadge`.
- `PersonRow` documentation now points trailing status examples at the active
  badge primitive instead of the deleted `StatusChip` wrapper.

### 2.5.198

- Event requirements chips now render directly through `CatchBadge` instead of
  the one-line `VibeTag` wrapper, keeping event-detail requirement metadata on
  the shared badge primitive used elsewhere in the handoff.
- Removed the unused `VibeTag` component after the final production call site
  migrated to `CatchBadge`.

### 2.5.197

- Auth entry has been audited against the Onboarding v2 handoff. `AuthScreen`
  remains a state-only shell, while `PhonePage` and `OtpPage` own the visible
  `OnboardingStepFrame` / `OnboardingStepHeader` composition, sticky
  `CatchButton` footers, country/phone row, OTP code field, and resend/change
  actions.
- Auth widget coverage now asserts the shared onboarding frame/header
  composition on the initial phone step in addition to the existing controller
  transition and Firebase auth behavior.

### 2.5.196

- Explore feed now renders the handoff result-count cue above the content
  stream (`1 PLAN` / `10 PLANS · JUN 11-17`) using the same filtered
  `ExploreFeedViewModel` items as the list and map.
- The count/date cue is skipped for club-only fallback content, preserving
  honest event counts while keeping the existing mixed club recommendation
  fallback intact.

### 2.5.195

- Host Create Club host-defaults now uses shared `CatchChip` primitives for
  admission, cancellation, and default-activity choices instead of local
  `VibeTag` wrappers.
- Club default cohort caps and demand pricing now render with the handoff
  `CatchToggle` control inside the existing policy card instead of adaptive
  `SwitchListTile` chrome.
- Create-club coverage now asserts the visible host-defaults chip/toggle
  composition in the successful create flow and verifies the embedded edit-mode
  defaults section still renders.

### 2.5.194

- Host Create Event now uses shared `CatchChip` primitives for activity,
  custom-format structure, pace, admission, and cancellation selections instead
  of local `VibeTag` wrappers.
- Event policy cohort caps and demand pricing now render with the handoff
  `CatchToggle` control inside the existing policy surfaces instead of adaptive
  `SwitchListTile` chrome.
- Create-event widget coverage now asserts the shared chip/toggle composition
  across the primary wizard path and keeps the custom activity-format path
  stable with chip-level taps.

### 2.5.193

- Host Create Event Success now explicitly uses the handoff's seal-check
  celebration mark via `CatchIcons.verifiedRounded`, while retaining the shared
  full-screen `CatchCelebrationScreen` composition for `StatusBar`,
  `ScreenBody`, details, note, and actions.
- Invite-only success coverage now asserts the handoff detail grid (`When`,
  `Where`, `Event`, `Capacity`, `Invite code`, `Private link`), the
  bookings/waitlist/attendance note, and Manage event / Back to club actions.

### 2.5.192

- `showCatchAdaptiveDialog` now renders a handoff-style Material confirm card:
  token scrim, centered overlay `CatchSurface`, title/supporting copy, and
  paired `CatchButton` actions with danger-filled destructive commits, while
  preserving native Cupertino alerts on iOS.
- Host cancel-event and create-event unsaved-changes dialogs now match the
  host-dialogs handoff copy and action labels (`Cancel this event?`, `Cancel
  event`, `Save draft`).
- Dialog coverage now asserts the Material confirm card composition and the
  host manage cancel/delete dialog flows through the new action buttons.

### 2.5.191

- Host Add Host is now covered as a handoff sheet flow: the test opens the
  host-team bottom sheet, verifies `CatchBottomSheetScaffold`,
  `CatchTextField`, and `CatchButton` composition plus the template copy, then
  submits a phone number through the repository-backed mutation.
- The existing `_AddHostSheet` implementation remains on the shared sheet,
  text-field, error-banner, and button primitives, so no production code change
  was needed for this template beyond coverage.

### 2.5.190

- Host Edit Event now uses shared `CatchChip` primitives for pace, admission,
  and cancellation selections in the flattened edit form instead of local
  `VibeTag` tap wrappers.
- The edit-event save action now sits in a handoff-style persistent footer with
  a top hairline, matching the Host Edit Event template's save chrome while
  keeping the existing update and locked-state behavior.
- Host Edit Event tests now assert the visible handoff structure and shared
  chip primitive in addition to update-event persistence and schedule locking.

### 2.5.189

- Host Edit Club now follows the handoff's flattened edit composition instead
  of reusing the create wizard: `CatchTopBar`, logo/photos, Identity, Contact,
  Event defaults, inline mutation errors, and a persistent full-width `Save
  changes` footer.
- Club defaults steps can now render embedded non-scrollable content for edit
  mode while preserving the existing scrollable create-flow behavior.
- `CreateClubContactFields` can suppress its internal optional section label
  when a parent handoff section already provides the `Contact` kicker.

### 2.5.188

- Host Draft Picker now matches the handoff sheet copy and composition:
  `Resume a draft?`, `Start a fresh event`, a single bordered draft row group,
  file icon, saved-time mono meta, delete `IconBtn`, and chevron affordance.
- Draft row taps now go through `CatchSurface.onTap` so the sheet keeps shared
  semantics and avoids feature-local raw tappables.

### 2.5.187

- Host payout setup now opens a handoff bottom sheet before Stripe: shared
  `CatchBottomSheetScaffold`, status badge, Stripe explanation, country and
  default-currency rows, return-here note, and a full-width `Continue to
  Stripe` action.
- `HostPaymentAccountCard` keeps the existing card entry point and refresh
  behavior while moving external onboarding behind the handoff sheet described
  by the host-payouts template.

### 2.5.186

- Host Inbox copy now follows the handoff's attendee-query framing: header
  subtitle, search labels, empty state, new-query rail, and section kicker no
  longer use consumer match/chat language in host mode.
- Added host-mode chat-list coverage so the inbox keeps `Inbox`, `Attendee
  queries`, and `ATTENDEE QUERIES` labels while hiding consumer match copy.

### 2.5.185

- Shared async error copy and event activity card supporting copy now use the
  semantic `supporting` text role, clearing the remaining low-level typography
  scanner candidates from shared core widgets.

### 2.5.184

- Host Account now follows the handoff composition: `CatchTopBar` with sign-out
  action, an Edit / Preview `CatchOptionGroup`, and flat Profile / Bio / Clubs
  info-row sections instead of the previous card stack.
- `SettingsRow` now supports opt-in multi-line values so handoff-style taller
  InfoRows such as the host bio can stay on the shared row primitive without
  affecting existing one-line settings rows.

### 2.5.183

- Event Detail design primitives now route bounded map pins, map pills, hint
  dots, and itinerary dots through `CatchSurface` instead of feature-local
  decorated boxes or containers.
- Event Detail mechanism and itinerary rows now use semantic text roles
  (`infoRowTitle`, `supporting`, `monoLabelS`) so the screen's DS primitives no
  longer show up in low-level typography or non-token letter-spacing scanner
  buckets.

### 2.5.182

- Create/Edit Club contact fields now use the shared `CatchFormFieldLabel`
  optional badge for the Contact form section instead of a local low-level
  title style, aligning the club form stack with existing field semantics and
  clearing the host form typography scanner hit.

### 2.5.181

- Host Event Manage now mounts the event title and Setup / Live / Report switch
  in shared `CatchTopBar` chrome, with the mode switch rendered through
  `CatchOptionGroup` instead of the older segmented surface control.
- The full-event apron now uses the handoff copy (`FULL - CAPACITY REACHED` and
  `WAITLIST OPEN`) inside a compact ink panel under the top bar.
- The New invite link dialog title now uses `CatchTextStyles.sectionTitle`,
  clearing the scanner's remaining raw app-facing `Text` candidate.

### 2.5.180

- Host Events now follows the handoff's flatter operations grammar: shared
  `CatchTopBar`, club meta row with role badge and activity chip, Upcoming
  kicker, `SettingsRow` event rows, and an Add event row instead of a card-heavy
  club panel.
- Host Clubs now uses the same host meta/activity row and on-surface Edit /
  Preview action rows while keeping payouts and host-team management in their
  existing functional sections.
- Added host-local `_HostOperationsTopBar` and `_HostMetaRow` helpers so host
  tabs pull role presentation from shared Catch tokens. Activity presentation
  now routes through the shared `ActivityChip` primitive.

### 2.5.179

- Onboarding v2 composition is now reflected in Flutter: the welcome screen uses
  the dark editorial handoff register, auth/profile steps share
  `OnboardingStepFrame`, and primary actions sit in sticky footers rather than
  inside long scroll bodies.
- Phone and OTP entry now use the handoff layout stack: `OnboardingStepHeader`,
  compact country/phone row, OTP resend/change actions, and a bottom `Verify`
  button while preserving existing auto-submit and controller behavior.
- Name/DOB, gender, Instagram, photos, prompts, and running preferences now use
  handoff-aligned labels, spacing, footer actions, prompt cards, photo tip band,
  and the raised pace-range panel backed by existing Catch primitives.

### 2.5.178

- Payment pending external checkout now ports the booking `CheckoutSheet`
  handoff: dimmed activity event backdrop, bottom sheet with grabber,
  receipt/warning medallion, event/price summary with Pending/Failed badge, and
  checkout / payment history / back-to-event actions.
- Added `CatchOpacity.paymentCheckoutScrim` for the Booking handoff's dimmed
  event backdrop instead of reusing unrelated scrim or border opacities.
- Added a pending Stripe checkout widget test so the Booking handoff state is
  covered separately from the confirmed "You're in." celebration path. The
  designed `ConflictSheet` had no repository flow for booking-overlap
  replacement at that point; the presentation component was added in 2.5.218
  and remains unmounted until a real overlap signal exists.

### 2.5.177

- Messaging thread composition now follows the handoff `ConversationTopBar` /
  `ChatThreadHeader` / `ChatBubble` / `ChatComposer` stack: surface top bar with
  hairline, activity-grounded context band, centered day separators, mono
  message timestamps, and Catch-owned composer icon controls.
- Added `CatchTextStyles.chatThreadContext` so the event-context band can use a
  semantic thread title role instead of a feature-local low-level body style.
- `ChatMessageList` now inserts day separators and splits same-sender bubble
  runs across day boundaries while preserving variable-height bubble rendering.
- `ChatInputBar` replaces raw Material icon buttons with a local composer action
  that keeps quiet image, filled send, disabled opacity, loading color, and
  tooltips consistent with the handoff.

### 2.5.176

- Added `CatchCountPill`, the handoff CountPill control for floating Explore
  map/filter affordances: raised surface, optional icon/mono label, optional
  count badge, and explicit semantics.
- `CatchOptionGroup<T>` now protects tight mobile rails by flexing labels with
  ellipsis while keeping the selected underline and trailing action pinned.
- `ExploreFilterRail` now matches the Explore handoff composition: visible
  OptionGroup time scopes for Tonight / Weekend / This week / Anytime, a
  trailing filter CountPill, and secondary filters in a bottom sheet instead of
  chip-heavy chrome.
- Explore's sheet exclusion now uses the rendered handoff filter rail height so
  the closed feed starts below the status/header/filter chrome on compact
  devices.

### 2.5.175

- Added `CatchToggle`, the Flutter port of the handoff settings switch: primary
  pill track when on, quiet line track when off, and a surface knob.
- `SettingsRow` now matches the handoff `InfoRow` shape for settings: on-surface
  rows, optional inset hairline divider, 20px icon lane, `infoRowTitle` labels,
  mono right-hand values, chevrons only for navigational rows, and `danger`
  mapped to the functional danger tone.
- `SettingsScreen` now uses the handoff Settings/Filters composition: compact
  `CatchTopBar`, page gutters, Account / Notifications / Privacy & safety /
  About / Log out sections on the page surface, `CatchToggle` notification rows,
  and the existing `CatchRangeSlider`/chip/apply dock filter sheet behavior.

### 2.5.174

- Added `PersonAvatarShape` support so shared avatars can render the handoff's
  circular person treatment and rounded-square host treatment through one
  primitive.
- Added `CatchTextStyles.chatPreview` for `ChatListTile` secondary inbox copy,
  keeping unread/new color changes on a semantic text role.
- Chat inbox composition now follows the handoff list model: new matches and
  conversations are folded into one `CONVERSATIONS` section, rows sit directly
  on the page surface with inset hairline dividers, unread/new state is carried
  by avatar rings, text color, timestamp color, and the trailing unread/new
  indicator rather than by card fills.

### 2.5.173

- Added `CatchOptionGroup<T>`, the Flutter port of the handoff `OptionGroup`
  underline selector. Profile now uses it for the pinned Edit/Preview row
  instead of adaptive Material/Cupertino tab chrome.
- Added `CatchTextStyles.infoRowTitle` for the handoff `InfoRow` primary row
  value (`.t-title-s`) so edit rows can use a semantic typography role without
  low-level style leakage.
- Profile edit now follows the handoff section composition: Photos, Prompts,
  About you, Running, and Lifestyle as on-surface `CatchDesignSection` /
  `ProfileInfoTile` groups. The old Profile strength card and split Location /
  Background / Intentions buckets are no longer part of this screen.
- Profile preview now renders the shared `ProfileSurface` full-bleed under the
  option group, with the profile renderer owning the body gutter. The shared
  public/profile/catches renderer applies the social-run activity pigment to the
  hero fallback and Running Rhythm block.

### 2.5.172

- The Notifications route now follows the handoff Activity composition:
  `CatchTopBar(title: 'Activity')`, manual top-bar "Mark all read", page-body
  gutters, and day-grouped notification rows.
- `ActivitySection` is notification-only on this route. It groups backend-owned
  notifications by Today, Yesterday, This week, and Earlier through the compact
  notifications day-group wrapper, and no longer prepends signed-up event rows.
- `NotificationRow` ports the handoff row contract directly: on-surface row,
  type-colored glyph, inset hairline dividers, relative time, and unread state
  through title/time color instead of card fills, icon chips, and badges.

### 2.5.171

- Dashboard full-state content now composes through `CatchSectionStack` in the
  handoff order: Event Focus, weekly stride, QuickActions, the personal clubs
  rail when available, and the recommendation rail.
- Dashboard recommendations now use the handoff heading "Recommended for you"
  while keeping the shared activity-art ticket cards and recommendation reasons.
- Dashboard empty-state body now narrows to the cover-story hero plus a
  `CatchDesignSection` "How Catch works" journey. The first-run hero copy
  matches the handoff and no longer carries the old decorative glyph.

### 2.5.170

- Club detail's pre-schedule body now composes through `CatchDesignSection`:
  Your hosts, About, What we do, From the club, Get in touch, Membership, and
  Join Catch. The route keeps the existing hero, stats apron, schedule sliver,
  read-only reviews, membership mutations, and host-message behavior.
- Club detail now renders club tags and optional club photo strips inside the
  handoff section rhythm while preserving the current public-profile behavior
  for host-app viewers.

### 2.5.169

- Added `CatchDesignSection`, the Flutter counterpart to the handoff `Section`
  primitive: it owns the kicker/count row, the 12 px kicker-to-body gap, and the
  24 px hairline section rhythm. Lead sections can pull their one accent from
  `ActivityPalette.resolve`.
- Event detail now seats `EventDetailTicketStubBand` directly under the hero and
  composes the body as handoff-style sections: The plan, Why you might click,
  Itinerary, Photos when available, Where, How sign-ups work, Good to know,
  Who's going, and Reviews. Existing booking, invite, companion, map, and review
  ownership stays in the current controllers/routes.
- Added Flutter event-detail design primitives for the stub band, hint list,
  itinerary, map preview, sign-up mechanism list, and photo strip, all sourced
  from the existing `Event` model plus the centralized activity resolver.

### 2.5.168

- Ported the Flutter foundation toward the implementation handoff: Archivo is
  now the voice/head face, the platform system font is the function/body face,
  and IBM Plex Mono remains the data face. `CatchFonts.serifFamily` and
  `CatchFonts.sansFamily` remain as compatibility aliases while feature code
  moves to the voice/function/data vocabulary.
- Added `CatchScreenBody` and `CatchSectionStack` as design-system aliases over
  the audited page-body and section-list primitives, so new screen migrations can
  compose with the handoff names without forking layout behavior.
- Added a centralized activity resolver in `ActivityPalette`: `CatchActivity`
  carries kind, label, regular Phosphor glyph, and accent/deep/soft swatch. The
  legacy event-activity glyph helper now reads from that registry.

### 2.5.167

- Host create/edit club and create-event implementation files now live under
  `lib/hosts/presentation/...`; consumer club/event feature folders no longer
  own host form screens, wizard controllers, or payout UI.
- Public club host messaging is split into `ClubHostContactController`, while
  add/remove/transfer host-team mutations live in `HostTeamManagementController`.

### 2.5.166

- Host app tab ownership is now explicit: Events owns event creation and event
  management rows, while Clubs owns club profile, payout, and host-team
  management. The Host Events header no longer exposes create-club chrome once a
  host is operating inside the app.
- Club detail is presentation-only again for host-app viewers. Host management
  controls such as Add event, Edit club, payouts, and host-team editing live in
  Host Operations surfaces instead of the public club profile.
- Professional host identity management stays separate from dating profile
  editing; Host Account owns the current profile-row edit entry point.

### 2.5.165

- Added the semantic spacing contracts `CatchGaps` and `CatchInsets`.
  Feature screens should use these role names, or a layout primitive that embeds
  them, instead of composing repeated `EdgeInsets` from primitive
  `CatchSpacing` values.
- Expanded `CatchInsets` with content, tile, list, pill/control, and one-axis
  roles, plus page body/header variants for repeated `fromLTRB(...)` shapes.
  Repeated presentation-level `EdgeInsets.all(...)`, one-axis
  `EdgeInsets.symmetric(...)`, and high-confidence page/header
  `EdgeInsets.fromLTRB(...)` shapes now use those roles.
- Added `CatchPageBody`, `CatchFormStepBody`, and `CatchSliverPageBody` as
  reusable body-padding primitives. `CatchSectionList` now defaults to the
  semantic `CatchGaps.section` value, preserving the existing 24 px detail
  section rhythm while naming the relationship directly.
- Added `CatchIconBadge` so feature UI can show notification/count overlays
  without using Material's raw `Badge` directly.
- Added chat bubble inset contracts so live message bubbles and generated share
  cards keep identical internal padding and sender-group rhythm.
- `catch_prefer_semantic_insets` now surfaces inline feature-level
  `EdgeInsets.*(CatchSpacing...)` at info severity while allowing named local
  inset contracts, so the remaining direct inset debt can be reviewed and
  migrated role-by-role.

### 2.5.164

- Catch UI lints now run across handwritten `lib/**` instead of only the first
  audited detail screens. The lint package exempts theme-token definitions and
  generated code, permits core widget primitives to wrap raw platform controls,
  and otherwise requires feature UI to use named spacing/layout constants plus
  Catch control primitives.
- The first wide pass cleared all surfaced diagnostics by moving inline token
  arithmetic into semantic `CatchLayout` constants, replacing feature-level raw
  Material controls with `CatchActionMenu`/`CatchButton`, and converting raw
  form/list insets to `CatchSpacing` values.

### 2.5.163

- `CatchSectionList` and `CatchDetailSliverSectionList` centralize audited
  detail-screen section composition so adjacent semantic sections use one named
  gap contract instead of hand-inserted `SizedBox` rows. Event detail now uses
  these primitives for the page body and overview section.
- Catch UI lints now live in `packages/catch_ui_lints` as an
  `analysis_server_plugin` package loaded by `analysis_options.yaml`, with
  CI smoke checks for both Catch UI diagnostics and Riverpod diagnostics.

### 2.5.162

- Event detail now shares the `CatchLayout.detailScreen*` rhythm used by club
  detail for sliver body padding, content gaps, section gaps, supporting-copy
  gaps, and dense card rows. Standard event heroes use semantic responsive
  height constants, while ticket/spotlight detail heroes use named ticket
  height/visual/title constants instead of local magic numbers.
- Event detail heroes now prefer uploaded event photos when a `photoUrl` is
  present and fall back to activity artwork only for no-photo or failed-photo
  states, including ticket and spotlight presentation modes. UI capture
  coverage includes standard, ticket, and spotlight event detail variants.

### 2.5.161

- Club detail layout now routes hero, body, and agenda rhythm through semantic
  `CatchLayout.detailScreen*`, `agenda*`, and `clubDetailHero*` constants.
  `ClubHeroAppBar` keeps the viewport-curve clipping on media only, with the
  title/location caption on the page surface so long names cannot crop the
  location row.
- `EventAgendaSliverList` exposes padding plus day/item/group gap parameters
  and no longer emits trailing per-card/per-group spacers. `EventDateRailCard`
  paints its ticket shadow explicitly with `CatchElevation.physicalShadow`
  behind the clipped ticket shape.

### 2.5.160

- Typography is now **bundled + optically sized**: `CatchFonts` drives the variable
  `Newsreader` / `Inter` / `IBM Plex Mono` via `FontVariation('opsz'/'wght')` (auto
  optical size from point size) instead of runtime `google_fonts`. Build text through
  `CatchFonts.serif/sans/mono` (or a named `CatchTextStyles.*`); never raw `TextStyle(`
  or `GoogleFonts` in production — enforced by the Catch UI analyzer lints.
- `CatchTextStyles` consolidated **59 → ~33** named styles onto one principled scale.
  Removed names (`heroImpact`, `displayXL/L/M/S`, `screenHeadline`, `heroHeadline`,
  `cardTitle`, `formQuestion`, `titleM`, `kickerCaps`/`kickerCapsLg`, `ticketMeta`,
  `arrivalMissionTitle`, …) are gone — use the canonical set: serif
  `display`/`headline`/`headlineS`/`titleL`/`profileAnswer`/`proseL`/`proseM`, sans
  `sectionTitle`/`titleS`/`infoRowTitle`/`chatPreview`/`body*`/`label*`/`supporting`/`button*`, mono
  `kicker`/`kickerLg`/`monoLabel`/`monoLabelS`/`numeric*`/`mono`.
- `GradedImage` / `CatchGrade` is now a tunable, brightness-aware **matte duotone**
  (desaturate + black-lift + warm shadow/highlight split-tone, optional grain).
- **Flagship profile:** `CatchProfileView`
  (`lib/swipes/presentation/profile_redesign/`) renders a section-based `ProfileView`
  in the editorial language with per-section reaction controls;
  `profileViewFromCardContent` maps the existing `ProfileCardContent`, and
  `ProfileSurface` routes Catches + preview + public profile through it. The legacy
  `ScrollableProfile` + section widgets are superseded.
- New anti-drift analyzer rules (`catch_no_raw_color`, `catch_no_raw_text_style`,
  `catch_no_raw_font_drift`) join `check_sizing.sh` +
  `check_ui_local_constant_wrappers.sh` in CI.

### 2.5.159

- Event detail routes now carry a source-aware presentation mode. Explore
  date-rail/ticket cards open the detail screen in a light ticket presentation,
  while featured/spotlight event cards open a dark spotlight presentation that
  preserves the black lower-card body after navigation.
- Added shared event-ticket transition primitives in
  `event_ticket_surface.dart`: full-card Hero wrapping, ticket clipping
  constants, and the reusable perforated divider. `CatchEventTicketCard`,
  `CatchEventSpotlightCard`, and `EventDateRailCard` can now participate in
  full-surface card-to-detail transitions.
- Event detail sections now accept an `EventDetailSurfaceStyle` so the same
  overview, stats, when/where, invite, and roster widgets can render on the
  standard light page or the spotlight-dark page without inverting the global
  app theme.

### 2.5.158

- Added the missing event depiction primitives: `EventActionCard` for booked
  event and host-operation lifecycle cards, `EventCompactRow` for dense
  tappable event rows, and `EventDateMarker` for calendar day/week event
  markers.
- `EventFocusRail`, `HostEventToolCard`, `ActivitySection` upcoming-event rows,
  and the Calendar date header now render through those shared primitives
  instead of private one-off card/date-cell widgets.
- Retired `EventHeroTile`, `EventTileStatusBadge`, and `EventTileFactWrap`.
  Spotlight events stay on `CatchEventSpotlightCard`, ticket surfaces stay on
  `CatchEventTicketCard`, and agenda/list rows stay on `EventDateRailCard`.

### 2.5.157

- Retired `CatchEventCardHero`. The full-bleed photo hero card was a
  pre-spotlight Explore refactor artifact with no remaining production callers;
  featured events now use `CatchEventSpotlightCard` and map/rail events use
  `CatchEventTicketCard`.

### 2.5.156

- Retired `CatchEventCardPeek`. The Explore map sheet now uses
  `CatchEventTicketCard` for the nearby rail and for selected non-spotlight
  pins, while preserving `CatchEventSpotlightCard` only when the selected pin
  is the feed's actual featured event.

### 2.5.155

- Removed the obsolete standalone `/map` nearby-events route and deleted
  `EventMapSheet`. Event detail directions continue through
  `EventLocationMapScreen`, while Explore keeps using `EventMapView` as a
  sheetless map canvas behind its own draggable browse sheet.

### 2.5.154

- Consolidated the shared atoms behind club and event card variants. Club list,
  Explore mixed-feed clubs, and club-detail host rows now reuse
  `club_identity_atoms.dart`; event cards and agenda rows share
  `EventCapacityPresenter`, `EventActivityStamp`, `EventClockMark`,
  `EventCapacityProgress`, and `EventStatusPill` instead of duplicating
  member labels, host rows, status pills, going/left copy, clocks, and progress
  bars.

### 2.5.153

- Retired the redundant event-card variants `CatchEventCardCompact`,
  `EventRailTile`, and `EventMapTile`. Agenda and Explore list rows now use
  `EventDateRailCard`; the map bottom sheet dropped its separate `EventMapTile`
  and `EventRailTile` family before the later ticket-card rail consolidation.

### 2.5.152

- Extracted the Explore mixed-feed event row into `EventDateRailCard`.
  `EventAgendaTile` now renders Calendar, Saved Events, and club schedules
  through the same date-rail card instead of the older agenda-only layout.

### 2.5.151

- Consolidated the agenda-card wrapper. `EventAgendaSliverList` now renders
  `EventAgendaTile` directly from `EventTileData.fromEvent(...)`; there is no
  separate `EventAgendaCard` variation to catalog or modernize.

### 2.5.150

- Event detail's hero app bar is now title-only in the expanded state. Date,
  time, location, and current-viewer booking state stay in the overview cards
  and bottom CTA instead of being repeated over the activity artwork.

### 2.5.149

- Explore's closed/list state now paints an explicit top lid across the
  status-bar/notch area plus header/filter chrome. The map can remain mounted
  behind the sheet for continuity, but it is only allowed to show through the
  safe area after the map reveal starts and that lid fades away.

### 2.5.148

- Production Explore now uses a mixed discovery feed instead of separate
  personal-club, event, spotlight, and club-directory blocks. The full sheet
  interleaves compact activity-coded event rows, an Instax-like club
  recommendation, the editor spotlight event, and compact club rows before the
  bottom `ExploreEventTypeBrowseGrid`; the personal `Your clubs` rail now
  lives on Home through `DashboardClubsRail`.

### 2.5.147

- Dashboard recommended events now use the production `CatchEventTicketCard`
  activity-art ticket instead of the older compact event rail tile. The ticket
  keeps the recommendation reason in the media label and folds distance, pace,
  booked count, and remaining spots into the bottom mono line.

### 2.5.146

- Explore's floating chrome now owns the top safe-area boundary separately from
  the map canvas. The map remains full-bleed, while the closed draggable sheet
  starts below the header/filter chrome so feed cards cannot scroll behind the
  Dynamic Island or status bar.

### 2.5.145

- Explore club directory cards now formalize the production media contract:
  `Club.imageUrl` is the cover photo, `Club.profileImageUrl` is the circular
  logo crest from the first club profile image, and club ratings render beside
  the title without restoring the old reviews/meta row.

### 2.5.144

- Production Explore club directory cards now adopt the concept-lab club
  spotlight direction. `ClubListTile` dispatches image-backed clubs to a
  photo card and no-image clubs to an identity card that reuses
  `CatchPolaroid`, `ClubPolaroidArtwork`, and `ClubCoverVisualPalette`,
  keeping the no-cover colors and fallback imagery in one iterable schema.

### 2.5.143

- Explore concept lab now includes a compact `This week` mixed-list primitive:
  dense event rows for chronological listings and a club recommendation row for
  non-hero discovery slots, so the lab covers more than spotlight/ticket cards.

### 2.5.142

- Explore's wrist-lift map reveal now uses a distinct momentum animation: a
  quick light-impact drop past the map detent, then a short spring settle back
  to the designed map size. The visible `Map` pill keeps the calmer direct
  ease-out reveal so the experimental physical gesture can be tuned separately.

### 2.5.141

- Explore can now reveal the map through a subtle wrist-lift motion gesture.
  `DeviceMotionSource` wraps `sensors_plus`, `ExploreMapMotionRevealRecognizer`
  keeps the thresholds testable, and `ExploreScreen` listens only while the
  full/list sheet state is active.

### 2.5.140

- Production Explore now uses the activity-coded event-card direction from the
  concept lab. `EventActivityVisualSpec` centralizes the mutable `ActivityKind`
  palette/backdrop/icon mapping, `CatchEventTicketCard` and
  `CatchEventSpotlightCard` render the production feed and selected-pin cards,
  `EventPhotoHeader` prefers the same activity artwork, and
  `ExploreEventTypeBrowseGrid` adds bottom-of-page activity filtering.

### 2.5.139

- Explore concept club spotlight cards now support two equal-size variants:
  a cover-photo card where the whole card reads as an Instax-like club snapshot,
  and a restrained no-cover identity card that keeps the existing crest,
  member seal, hosted-by row, tags, and CTA without duplicating member count.

### 2.5.138

- Explore concept ticket event-card side cutouts are now shallower, offset bites
  so the transparent notch reads as a ticket edge instead of a circular badge
  pasted onto the rail card.

### 2.5.137

- Explore concept ticket event cards now use a clipped ticket shape for truly
  transparent side notches, extend the media band slightly closer to the
  perforation line, and show the capacity label without tally dots.

### 2.5.136

- Removed the Explore concept timeline/evening-arc widget from the lab. The
  prototype now focuses on event tickets, spotlight/detail treatments, club
  spotlight, map pin treatment, and browse-by-type tiles.

### 2.5.135

- Explore concept browse-by-type tiles now render as compact horizontal cards
  with a small activity color cue instead of large category blocks. The club
  spotlight concept now uses a clean sharp-corner surface without the dotted
  paper background so it reads separately from event tickets.

### 2.5.134

- Explore concept lab now exposes an activity color-system board and shared
  activity-coded backdrop primitive. Ticket event cards, spotlight event cards,
  detail-header mocks, and browse-by-type tiles can reuse the same `ActivityKind`
  gradient, motif, and icon mapping while production Explore data adapters stay
  untouched.

### 2.5.133

- Explore's soft sheet settling now runs from a short controller debounce, not
  only scroll-end notifications, so native sheet drags near the compact bottom
  state reliably settle to the shorter closed height.

### 2.5.132

- Explore's draggable map sheet now uses soft settling zones: releases near the
  shorter bottom extent, map detent, or full/list state animate into those
  anchors, while the middle range remains free-resizable.

### 2.5.131

- Explore map mode is now open-only from the floating action pill: the `Map`
  pill appears in the full/list state, disappears after opening, and users
  close or resize the sheet by dragging the handle instead of tapping a `List`
  pill.
- The Explore sheet no longer snaps on user release. Programmatic open still
  lands on the designed map detent and the bottom state is bounded by a shorter
  min extent, but intermediate drag positions can now rest naturally.

### 2.5.130

- Explore map opening now snaps to a higher map detent just below the quick
  filter strip, uses a slower ease-out open motion, and rounds/fades in the
  draggable sheet edge as the chrome spacer collapses for a lid-opening feel.
- `CatchDraggableSheetShell` now lets callers control handle opacity and top
  corner radius so persistent sheets can animate their edge treatment without
  replacing the shared shell.

### 2.5.129

- Explore map reveal now lets `EventMapView` fill the full viewport, including
  the status-bar/notch area, while the Explore chrome remains safe-area aligned
  over the map and the full/list sheet preserves its safe top spacer.

### 2.5.128

- Explore's list-first state now uses a full-height draggable sheet with a
  chrome-height internal spacer, so no idle map sliver appears below the
  filter rail. Opening the map collapses that spacer while the sheet drops to
  the medium detent.
- `ExploreBrowseHeaderContent`, `ExploreFilterRail`, and `CatchBrowseHeader` now
  accept parent-supplied background colors so Explore can fade the outer chrome
  away while keeping the city, search, and filter controls floating over the
  map.

### 2.5.127

- Explore map browsing now renders app-owned dense-event clusters, a user
  location mark, and a distance filter ring. Tapping the ring cycles the
  distance filter, and the peek rail re-sorts from the latest map camera center.
- Explore's day-grouped feed now uses flat slivers with pinned
  `CatchDaySectionHeaderDelegate` headers in the primary sheet, while the
  compatibility `ExploreEventsSection` wrapper keeps inline headers when nested
  under `SliverMainAxisGroup`.
- The Explore map sheet lead is now `buildExploreMapSheetLeadSlivers`: selected
  pin cards share their photo into event detail, collapsed summaries switch from
  city label to `Map area` after a meaningful pan, and the sheet chrome uses the
  shared `CatchDraggableSheetShell` primitive instead of a feature-local shell.
- Event discovery now avoids eager signed/saved event-detail watches by loading
  missing personal events through the batched `watchEventsByIdsProvider` seam.

### 2.5.126

- Explore discovery now passes the viewer's event-policy cohort into the
  direct event query, allowing the backend index to pre-filter open slots for
  standard cohort-cap and ratio policies before the client resolves saved,
  joined, hosted, invite, membership, and manual-approval state.
- Explore cards and the peek rail now emit non-PII analytics for event opens
  and map/rail event selection so release smoke testing can measure discovery
  engagement instead of only screen views.

### 2.5.125

- Explore event discovery now queries the `events` collection directly through
  backend-owned discovery projection fields instead of resolving city clubs
  before asking for events. Club reads remain in the view model only for card
  metadata, club-directory rows, and club-specific secondary filters.
- Added a dry-run-first event discovery backfill tool so older event docs can
  be repaired before launching the direct index in shared environments.

### 2.5.124

- `ExplorePeekRail` now uses a semantic `InkWell` action for the compact
  "See all" control, with a stable widget key and tooltip. The change clears
  the widget cleanup scanner's only Explore tappable hit while preserving the
  compact peek-state layout.

### 2.5.123

- Added `EventDiscoveryRepository` and `EventDiscoveryQuery` as the Explore
  event data seam. The first implementation is a compatibility adapter over
  club-scoped upcoming event fetches, but the UI/view-model boundary now names
  city-scoped event discovery explicitly so a future backend index can replace
  the adapter without changing Explore cards, map pins, or sheet state.

### 2.5.122

- Explore's production provider seam is now `ExploreFeedViewModel`, with
  `ExploreFeedViewModel` retained as a compatibility alias for existing clubs
  imports. The model carries event, club, map status, distance, and viewer
  availability instead of treating saved/signed-up/full as a local widget
  shortcut.
- Added `ViewerEventAvailability` as the reusable event availability primitive
  for Explore cards. It combines event policy, current profile, participation,
  saved edge, hosted club state, and club membership so cards can distinguish
  open, saved, joined, waitlisted, invite-required, request-required, full, and
  full-for-viewer states.

### 2.5.121

- Explore quick filters now include real distance windows (`Within 1 km`,
  `Within 3 km`, `Within 5 km`, `Within 10 km`) backed by
  `deviceLocationProvider` and event starting-point coordinates.
- Explore map pin selection now updates parent sheet state: tapping a pin snaps
  to the half-open sheet and shows a selected-event lead. The lowest peek snap
  now stays map-first with only aggregate result summary copy instead of a
  horizontal card rail.
- The event-map placeholder used in tests/offline map mode now lays pins out
  spatially and labels them by meeting point so selected-pin flows can be
  exercised without network map tiles.

### 2.5.120

- Explore now derives the map's `EventMapViewModel` from
  `ExploreFeedViewModel`, so the draggable map, pin empty states, and peek rail
  all reflect the same filtered event set as the feed.
- `EventMapView` accepts an optional parent-supplied
  `AsyncValue<EventMapViewModel>` and falls back to
  `eventMapViewModelProvider` only for standalone map routes. Parent surfaces
  can also supply their own retry callback so refresh ownership stays with the
  provider that produced the view model.

### 2.5.119

- Explore now uses a persistent `EventMapView` behind a snapping
  `DraggableScrollableSheet` instead of swapping between separate list and map
  bodies. The cold-open sheet stays at the full feed snap; the Map and List
  buttons animate between full and half snaps.
- Added a compact peek-state event rail for the lowest Explore sheet snap so
  map-first browsing can show nearby event context without reintroducing the
  old static nearby-events sheet inside the Explore surface.
- Historical note, superseded by 2.5.155: `EventMapView` briefly had an
  optional built-in nearby-events sheet for the standalone map route. That
  route/sheet pair has now been retired.

### 2.5.118

- Explore filters now model time as an explicit `ExploreTimeFilter` instead of
  a single club-era `thisWeekOnly` flag. Tonight, Tomorrow, Weekend, and This
  week chips share one provider state across the event feed and club directory.
- `ExploreFilterRail` has a stable scroll key so widget tests and future UI
  automation can target the horizontal filter rail without positional finders.

### 2.5.117

- The bottom navigation and Explore browse header now present the branch as
  Explore while preserving `/clubs` routes and existing club detail paths.
- `ExploreFeedViewModel` derives an event-first feed from the selected city's
  clubs, current club filters, signed-up/saved state, and upcoming event
  queries so list mode starts with events before the club directory.
- Added `ExploreEventsSection` above the club directory. It renders a featured
  upcoming event, horizontal event rail, loading skeleton, inline empty state,
  and event-detail navigation through existing event tile/data primitives.

### 2.5.116

- Host Manage participation filters now render as one compact four-item strip
  instead of a two-row nested surface grid; filter labels keep larger count
  text and drop the secondary meta copy.
- Roster search rows no longer carry trailing non-action badges such as
  Roster, Live, or Export.
- The Event Success Live Now console no longer repeats a checked-in progress
  meter when Host Manage already embeds the editable check-in roster below it.

### 2.5.115

- Host Manage Report now exports real CSV files through the shared
  `ExternalShareController` seam instead of disabled placeholder buttons.
- Revenue CSV exports one row per roster/customer record plus summary rows for
  estimated active revenue, no-shows, and cancellations. Amount columns are
  explicitly marked as event-price estimates when only roster-visible
  participation/payment-id data is available.
- Ops CSV is justified as an operational ledger for attendance reconciliation:
  roster status, check-in status, approval state, arrival order, timestamps,
  cohort/gender-at-signup, and payment-id context.

### 2.5.114

- Host Manage keeps the Setup / Live / Report segmented lifecycle control at
  the top of the body and removes the duplicated booked/waitlist/revenue stat
  strip.
- `HostEventParticipantsPanel` now owns the participant counts as compact
  filter tiles for each lifecycle: Setup filters All, Booked,
  Requests-or-Waitlist, and Slots; Live filters All, Due, In, and
  Requests-or-Waitlist; Report filters All, Attended, No-show, and Waitlist.
- Live and Report participation surfaces now use the same dense table shell for
  filtered empty, zero, loading, and error states instead of separate summary
  cards above the roster.

### 2.5.113

- `EventSuccessManualQaScreen` now embeds the canonical
  `HostEventManageScreen` as its host pane with fixture-backed provider
  overrides, so Setup, Live, Report, and participation table changes are tested
  through the same host controls used in production instead of a duplicate QA
  host fixture.

### 2.5.112

- Added `CatchBottomDock`, `CatchIconTile`, `CatchStatusDot`, and
  `CatchPageDots` so bottom action docks, icon badges, tiny status markers, and
  carousel/page indicators use shared primitives instead of local decorated
  shells.
- `CatchSurface` now accepts a custom border radius, allowing shaped surfaces
  such as chat bubbles to keep their silhouette while still inheriting shared
  surface behavior.
- Widget cleanup scanning now covers typography regressions, spacing gaps,
  low-level spacing helper drift, raw app-facing `TextStyle`, and reviewed
  surface exceptions for media, chart, Event Success stage, and animation
  surfaces.

### 2.5.111

- `HostEventParticipantsPanel` now keeps true zero-participant states inside
  the lifecycle-specific board/table surfaces instead of rendering a standalone
  empty block above Host Manage setup content. Loading, event-not-found, and
  data-load errors remain branded outer states because the lifecycle board
  cannot be built until the event context is available.

### 2.5.110

- Catch typography now exposes expressive semantic roles for hero, screen
  headline, form question, card title, section title, body lead, supporting
  copy, kicker/status labels, chat messages, profile answers, and tabular stats.
- Material fallback text, menus, snackbars, buttons, inputs, chips, badges,
  rows, empty states, and profile/event/event-success surfaces now use semantic
  text roles instead of ad hoc `bodyS`, `bodyM`, or `titleS` calls.
- App-facing raw text, raw Material button, raw text input, and nonzero
  letter-spacing typography scanner findings are cleared for this pass.

### 2.5.109

- `HostEventParticipantsPanel` now renders lifecycle-specific participation
  boards instead of a single card-list roster: Setup focuses profile/request
  review, Live focuses dense check-in operations, and Report focuses
  attendance/payment reconciliation with export placeholders.
- `AttendanceSheetViewModel` now exposes the visible participation records by
  user id so roster rows can render timestamps, payment presence, and active
  participation status without presentation widgets reaching around the view
  model.

### 2.5.108

- Explore now owns the list/map mode switch. List mode remains a club
  directory with quick filters, while map mode embeds the reusable event map so
  pins represent upcoming events rather than clubs.
- Historical note, superseded by 2.5.155: the old standalone map route once
  delegated its body to reusable `EventMapView`, before that route was retired.
- Dashboard quick actions no longer expose Map view; dashboard keeps Calendar
  and Saved events while spatial discovery lives under Explore.

### 2.5.107

- Notifications now separate signed-up upcoming events from durable recent
  notification history. `ActivitySection` renders upcoming event tiles first,
  then groups backend-owned notification updates with typed badges and compact
  icon chips.
- The old vertical Activity timeline connector has been removed from the
  Notifications screen; rows now use `CatchSurface` and `CatchBadge` so the
  route matches the current Catch design primitives.

### 2.5.106

- Explore browse now keeps search reachable even when the selected city has no
  clubs, adds a sliver-native quick-filter rail for upcoming, rating, joined,
  hosted, activity, and neighborhood filters, and clears city-local filters
  when the city changes.
- Club directory cards now surface next-event and review-count context in the
  card body, and the Explore list loading state uses card-shaped skeletons that
  match the loaded directory layout.
- Explore empty states now distinguish empty city, no-search-result, and
  no-filter-result cases with clearer recovery copy and inline clear actions.

### 2.5.105

- Host Manage Live now embeds the editable roster inside the event-success Live
  now flow. The old standalone live-attendance summary is hidden in that
  context, and the arrival control becomes a QR-only check-in tool so roster
  status, current stage, and next action do not repeat across separate cards.

### 2.5.104

- Event Success now catalogs the optional First Hello arrival ritual. The
  manual QA harness can toggle it from the shared host controls and drive the
  attendee mission through completion without desynchronizing host and attendee
  state.
- Added `_FirstHelloCheckInCard` for the attendee companion's server/manual-QA
  provided arrival mission surface.

### 2.5.101

- Explore `ExploreCityPicker` closed state is now an icon-only circular control. The
  full city name stays in tooltip, semantics, and the selection sheet so long
  city labels cannot push the browse title across the header.
- `CatchBrowseHeader` now morphs the circular search action into the full
  search field from the same right-aligned control. It no longer renders an
  in-app keyboard-hide button; search dismissal uses the field's platform Done
  action, clear button, and focus loss.
- Explore and Chats search fields both request `TextInputAction.done`, so the
  platform keyboard owns the dismissal affordance while the pinned browse row
  stays visually consistent across tabs.

### 2.5.100

- Chats now reuses `CatchBrowseHeader` in the pinned sliver slot. The header
  owns title/subtitle plus a top-right search action; search expands into the
  full row with the same animated behavior as Explore.
- Removed the chat-count badge from the Chats header. Conversation counts stay
  in list/body context instead of competing with the primary header action.

### 2.5.99

- Explore keeps the consolidated browse header in the pinned sliver slot so the
  city picker, title/subtitle, search action, and expanded search field remain
  sticky while the club list scrolls.

### 2.5.98

- Explore browse now uses a compact city-code picker (`IDR`, `HYD`, etc.) with a
  location icon so short and long city names reserve the same header width.
- `CatchBrowseHeader` search opens with a shared motion transition and uses a
  same-height keyboard-dismiss control instead of a back button beside the
  search field.
- `CatchTextField` now defaults to a platform done action and unfocuses on
  submit/tap-outside so app keyboards have a shared dismissal path.
- `ClubPolaroidArtwork` no longer renders generated initials artwork. No-photo
  club tiles use a quieter map-style fallback with a location mark.

### 2.5.97

- Added `CatchBrowseHeader` as a shared self-contained browse-tab header for
  title, scope picker, search expansion, and actions in one module.
- Explore now uses the browse header instead of a separate title row plus pinned
  city/search row; search opens into the full header row and city selection uses
  a bottom sheet picker.
- Club directory and avatar tiles now pass explicit no-photo fallback chrome so
  list cards do not repeat location labels already rendered below the cover.

### 2.5.96

- Dashboard host event tools are now self-contained cards: the parent adapter no
  longer renders a Host tools header, event-count badge, Active/Past buckets, or
  explanatory rail text.
- `HostEventToolCard` owns its Host event identity chip, attendance lifecycle
  chip, fixed-width in-card progress rail, and one contextual CTA: Manage event,
  Take attendance, or View report.
- `HostEventToolsPageIndicator` uses a constant-width progress rail plus
  `N of total` text instead of rendering one dot per hosted event.

### 2.5.95

- Host Manage Setup now surfaces the participant roster before event details,
  live-guide setup, and lower-priority admin/destructive actions. Cancel/delete
  copy distinguishes cancelled published events from permanently deleted unused
  events.
- Event-success host loading now waits for the saved plan first and skips
  roster, assignment, preference, wingman, and report streams while no live
  guide exists, so unsaved events render the unavailable guide state instead of
  an indefinite loading indicator.

### 2.5.94

- Widget cleanup status now lives in `docs/audit_registry/backlog.json`; the
  old short Markdown pointer was removed during docs consolidation.

### 2.5.93

- Split event-success host, companion, and live-reveal presentation surfaces
  into focused `part` files for setup, live controls, report, reveal actions,
  attendee cards, wingman requests, feedback, and shared widgets while keeping
  the public import points stable.
- Host setup now uses progressive disclosure for advanced event structure,
  tool, and delivery controls.

### 2.5.92

- Added `EventSuccessManualQaScreen`, a dev/staging side-by-side harness for
  inspecting host and attendee event-success surfaces from shared fixture state.
- Settings Development now links to the event-success manual QA harness.

### 2.5.91

- Host report now includes a signal-quality grid built from already-loaded
  feedback, assignment, opt-out, and wingman-request data.
- `EventSuccessPostEventReport` now renders `Working well` strengths before
  coach recommendations so the report can call out successful event patterns.

### 2.5.90

- Added the attendee compatibility questionnaire surface to event companion,
  using `CatchSurface`, `CatchChip`, `CatchBadge`, and `CatchButton`.
- Host setup now exposes the explicit compatibility-ranking switch; host Live
  mode shows whether questionnaire answers are clues-only or ranking-enabled.

### 2.5.89

- Event-success setup now includes the Live reveal product layer for structured
  formats, with persisted reveal countdown state on the plan.
- Added `EventSuccessLiveRevealHostCard` for host-controlled countdown,
  round-reveal, reset, and reveal-queue status in Live mode.
- Added `EventSuccessLiveRevealAttendeeCard` for companion-side pod/rotation
  reveal gating, countdown clues, and revealed assignment details.

### 2.5.88

- Shared public profile cards now follow the Edit Profile section treatment:
  sentence-case titles, calmer title weight, tighter card padding, and less
  crowded prompt/running text.
- `ProfileInlineTextEntryEditor` now requests focus after the expansion frame
  instead of using immediate `EditableText.autofocus`, preventing first-tap
  keyboard/focus flicker while the row opens.
- Edit Profile row icons stay on the muted field-icon color even when the row
  is an add affordance; only the add value text uses primary color.

### 2.5.88

- Club detail now supports multi-host presentation. `ClubDetailBody` renders
  every `ClubHostProfile` and exposes host-message actions for signed-in
  non-host viewers; owner-only add/remove/transfer controls backed by
  `HostTeamManagementController` now live in the Host app Clubs tab.
- Club create/edit now separates event-success defaults into
  `ClubEventSuccessDefaultsStep`, making the club wizard four steps for owners
  while co-host edit mode narrows to media updates only.
- Added `FormStepSpec` helpers in `form_step_flow.dart` so create-club and
  create-event flows share step title/key lookup instead of hand-written
  switch statements.

### 2.5.87

- Added `CatchSectionCard` as the shared polished content-section wrapper:
  sentence-case title, optional subtitle/trailing context, `CatchSurface`
  border, and tokenized spacing.
- Edit Profile now renders Profile strength, Photos, Profile prompts, About,
  Location, Background, Intentions, Lifestyle, and Running details as coherent
  section cards instead of external uppercase labels plus grouped rows.
- `SectionHeader` now defaults to sentence-case label styling. Explicit
  uppercase remains available for badges, status labels, and intentional
  metadata/eyebrow treatments.

### 2.5.86

- Club create/edit now includes a host-defaults step for event policy and
  event-success defaults. `ClubHostDefaultsStep` owns admission, cohort caps,
  cancellation, and dynamic-pricing controls; event-success defaults now live on
  the dedicated `ClubEventSuccessDefaultsStep`.
- Create event applies club host defaults to the policy step and lets hosts
  override them per event before publishing. Optional event-success setup is
  saved when enabled.
- Edit hosted event now supports pre-activity policy edits for capacity, price,
  admission format, invite code, cohort/age limits, dynamic pricing, and
  cancellation policy. These controls become read-only once the event has
  started or has booking, waitlist, or attendance activity.

### 2.5.85

- Host Manage now uses `HostEventParticipantsPanel` as the single participant
  surface across Setup, Live, and Report. Setup shows booked/waitlisted people
  read-only, Live owns check-in mutation, and Report shows the attendance
  summary. Event-success Live remains unavailable until setup has been saved, so
  unsaved default plans cannot trigger Firestore live-step writes.

### 2.5.84

- `CatchSegmentedControl` now supports expanded icon+label segments and a
  raised-surface selected style. Host Manage uses it for the Setup / Live /
  Report lifecycle switcher instead of separate chips.

### 2.5.83

- Host Manage now uses one lifecycle picker with Setup, Live, and Report sections.
  Setup combines the prior event overview/admin surface with event-success setup,
  Live combines host attendance with event-success live mode, and Report opens
  the post-event host report directly. The nested event-success tab picker is
  hidden inside Host Manage.

### 2.5.82

- Host Manage moved fully into the `hosts` feature at
  `lib/hosts/presentation/host_event_manage_screen.dart`; the canonical route is
  now `/clubs/:clubId/events/:eventId/manage`, with the old dashboard-shaped
  path kept as an alias.
- Added `EditHostedEventScreen` at `/clubs/:clubId/events/:eventId/edit` for
  backend-supported operational edits. Schedule edits lock once an event has
  started or has booking, waitlist, or attendance activity.
- Removed the standalone `AttendanceSheetScreen`, `EventSuccessHostScreen`,
  `HostClubToolsPanel`, and `HostStatsStrip` wrappers. Screens now import the
  host widgets they use directly.
- Host attendance-window state now lives in
  `lib/hosts/domain/host_attendance_window.dart`, and Dashboard host tools split
  active and past hosted events into a segmented Host operations rail.

### 2.5.81

- `HostEventManageScreen` is now the canonical per-event host workspace with
  lifecycle sections: Setup, Live, and Report. The old event-success and
  attendance route paths remain as aliases that open Host Manage with the
  relevant lifecycle section selected.
- Club detail no longer owns host-operation CTAs. Host app Events owns Add
  event and event management rows, while Host app Clubs owns profile, payouts,
  and host-team management. The old `HostStatsBar` compatibility wrapper was
  removed.
- `CreateEventScreen` no longer embeds Host Manage after the celebration; its
  Manage event action routes to the canonical Host Manage route.
- Event-success lab/preview/companion surfaces share reusable prompt, dark-pill,
  metric-pill, and recommendation-tile widgets from
  `event_success_feature_blocks.dart`.

### 2.5.80

- Event detail no longer renders a host-only sticky bottom footer. Host
  operations stay on Dashboard and Host Manage so the detail page does not have
  two competing host-tool sections.
- Dashboard host tools now retain non-cancelled past hosted events after
  attendance closes, with open attendance first, upcoming events next, and
  recently closed past events last.

### 2.5.79

- Shared host tooling now lives under the feature-owned
  `lib/hosts/presentation/widgets` folder instead of the standalone
  `lib/host_tools/presentation` utility module. Existing host surfaces import
  the widgets directly from that feature folder.

### 2.5.79

- Create event now separates `Event policy` from `Live event guide`.
  Capacity, admission, price, age, cancellation, and payout controls stay on
  policy; event-success defaults move to their own final step before scheduling.

### 2.5.78

- Event detail now includes a `What to expect` section ahead of booking,
  cancellation, and settlement policy details. It is derived from the already
  loaded event snapshot, so the listing/detail policy copy does not add another
  Firestore read.
- Live event-success host setup now exposes target attendance, host goal,
  attendee prompt, module selection, private follow-up, contextual openers, and
  a start-time freeze notice on the production host success screen.
- The attendee companion private follow-up action now feeds the post-event
  feedback/report aggregate while private-crush target identities remain
  attendee-private.

### 2.5.77

- Home run-state actions are consolidated into `RunFocusRail`. The old
  dashboard-only `UpcomingRunsHero`, `RunArrivalActionCard`, `CatchesCallout`,
  and `ReviewPromptCard` widgets have been deleted; committed-run state now
  flows through one full-width snapping rail with check-in, directions,
  calendar, catch-window, and review actions.
- Profile photo editing is now grouped-photo first. `PhotoGrid` renders
  `ProfilePhoto` objects, supports guarded delete and long-press reorder, and
  routes add/replace/edit work through `ProfilePhotoEditorScreen`.
- Host event management now includes guarded Cancel event and Delete event actions
  on `HostEventManageScreen`; unused events can be deleted, while events with visible
  activity are cancelled and retain history.

### 2.5.76

- `CreateEventScreen` now uses an `Event policy` step for capacity, base price,
  admission format, age bounds, cohort caps, cancellation policy, and host
  payout timing. The old event details step now stays focused on distance, pace,
  photo, and description.
- `EventDetailCta` prices the current viewer through the event policy
  snapshot, and `EventDetailOverviewSection` shows booking, cancellation, and
  settlement policy details.

### 2.5.75

- `EventPolicyLabScreen` now previews cancellation outcomes alongside
  admission and pricing. The lab shows bounded attendee cancellation policies,
  host-cancellation make-complete behavior, and host payout timing held until
  event completion.

### 2.5.74

- `EventPolicyLabScreen` is the dev/staging-only visual lab for the parallel
  event-policy engine. It lives under `lib/event_policies/presentation`, is
  reachable at `/dev/event-policy-lab` when `AppConfig.enableEventPolicyLab` is
  true, and renders static preview fixtures without touching live booking,
  Firestore, Functions, drafts, or payments.
- Settings shows an `Event policy lab` row only under the same dev/staging gate.

### 2.5.73

- Home no longer has `Dashboard` / `Activity` tabs. `DashboardScreen` is a
  single sliver-owned Home surface with a top-right Notifications bell and red
  unread badge.
- The former Activity tab is now a `Notifications` screen opened from the Home
  header. It remains inside the Home shell route so the bottom navigation stays
  visible, and it marks unread activity notifications read when the screen
  opens.
- `ActivitySection` remains the reusable timeline body, but callers can hide
  the manual `Mark all read` action when the route owns automatic read state.
- `DashboardSliverHeader` now exposes action slots instead of a pinned tab row.

### 2.5.72

- Profile Preview now bridges both scroll directions while preserving the
  shared `ProfileSurface`: upward drags on the preview card collapse the
  Profile header until the Edit/Preview tabs pin, and leading overscroll at
  the card top expands the header again.
- `ScrollableProfile` can accept route-provided scroll physics when embedded
  inside a parent sliver route that needs coordinated header behavior.

### 2.5.71

- Host tooling now has shared primitives under `lib/hosts/presentation/widgets`:
  `HostEventToolsCarousel`, `HostEventToolCard`, `HostClubManagementPanel`,
  `HostTeamManagementSection`, `HostEventAttendancePanel`, `HostStatChip`, and
  `HostToolPalette`.
- Dashboard host tools use full-width snapping cards with stacked Manage /
  Attendance actions instead of a clipped horizontal partial-card rail.
- Club host tools and attendance headers share the host palette, and hosted
  club schedule rows use the `HOSTED` event-tile state.

### 2.5.70

- The shared profile display is now `ProfileSurface`, a cardless renderer used
  by Catches, Profile Preview, and Public Profile. Reaction controls are
  mode-gated: Catches can pass section like/comment callbacks, while Preview
  and Public Profile render the same content without reaction overlays.
- `SwipeScreen` no longer uses `flutter_card_swiper`, deck gestures, generic
  like/pass bottom buttons, or swipe stamps. It renders the first candidate as a
  full structured profile and uses a floating lower-left pass X.

### 2.5.69

- `PreferredRunTime` is now part of `UserProfile` and `PublicProfile`.
  Onboarding and Edit Profile collect favorite run times alongside pace,
  distances, and reasons.
- Shared profile-card insights use preferred run times for morning/evening
  emotional tags, time-of-day compatibility reasons, and profile-quality
  scoring.

### 2.5.68

- Shared `ProfileSurface` rendering now derives contextual profile insights:
  confidence signals, emotional running tags, and viewer-aware compatibility
  reasons. Swipe, Preview, and Public Profile pass viewer/run context into the
  same rendering path instead of forking presentation logic.
- `ProfileMatchSignalsSection` is the first-class "Why you might click" /
  "Profile signals" block and is individually reactionable through the
  `compatibility` reaction target type.
- Edit Profile now shows profile-quality guidance above photos, backed by the
  same pure profile-insights scoring used by public profile confidence signals.

### 2.5.67

- Event card architecture now uses a small tile catalog under
  `lib/events/presentation/widgets/event_tiles/`: `EventTileData`,
  `EventDateRailCard`, `EventAgendaTile`, `EventActionCard`,
  `EventCompactRow`, and `EventDateMarker`.
- Calendar, Saved events, club schedules, Explore list rows, and Map browse
  cards now render through shared card primitives while their providers/view
  models own club-name and relationship-state lookup.
- The obsolete generic `RunCard` in `lib/core/widgets/run_card.dart` was
  removed because it was not used by production surfaces and had a stale
  one-size-fits-many API.

### 2.5.66

- Map surfaces use chromeless full-screen layouts with floating
  `MapOverlayControls` instead of a `CatchTopBar`, so map tiles extend to the
  top corners while back/confirm actions remain available above the map.

### 2.5.65

- `EventPinsMap` accepts a selected event camera target from map-browse screens.
  Tapping a nearby-event tile now animates the map to that event's exact starting
  point instead of only changing card and pin selection state.

### 2.5.64

- Map browse centering is now strictly device location unless the user manually
  selected a city or denied/unavailable location access, then selected city.
  Run pins never choose the browse-map camera center.
- Dashboard Map View's `View run` action routes to the dashboard run-detail
  path, not the Clubs branch route, so it opens details from the top-level map
  surface without branch mismatch.
- Map form previews use human state copy (`Starting point pinned`) instead of
  raw latitude/longitude display.

### 2.5.63

- App-wide ambient notices now use `CatchNoticeHost` / `CatchNotice` instead
  of the shell-level offline `MaterialBanner`. Offline state is a persistent
  safe-area-aware notice; foreground events such as matches can use the same
  queued notice host with dedupe and auto-dismiss behavior.

### 2.5.62

- Dashboard host actions are consolidated into `HostToolsRail`: each hosted event
  gets one horizontally scrollable card with both Manage and Attendance actions.
  Attendance is enabled only inside the host attendance window, while Manage
  stays available for actionable hosted events.
- `DashboardFullViewModel` now exposes `DashboardHostEventTool` items instead of
  a raw hosted-event manage list, so attendance-open events can sort ahead of
  later upcoming hosted events without rendering a separate arrival card.

### 2.5.61

- Hosts can reopen `HostEventManageScreen` from the Dashboard through
  `HostToolsRail`; active and past hosted events remain reachable instead of
  relying on the post-create success screen.
- Host manage summary rows reserve a right-aligned value lane, and roster /
  waitlist empty states use compact title/icon styling instead of oversized
  display empty states.

### 2.5.60

- Event detail descriptions render under an explicit "About this event" heading, so
  backend description text cannot look like stray body copy.
- `EventDetailSocialSection` unlocks review writing only after an attended event has
  ended, and it does not render the reviews divider for guest-only social
  prompts.
- `WhoIsGoing` uses a neutral empty roster surface and suppresses swipe-window
  messaging when no one has booked the event.

### 2.5.59

- `CatchEmptyState` expands across bounded parent widths before centering its
  icon, title, message, and optional action. Do not repair empty-state
  alignment in feature screens with local `Center`/`SizedBox` wrappers; fix the
  shared primitive contract instead.

### 2.5.58

- `SwipeScreen` uses the `swipes` error context and the swipe queue now
  converts stalled candidate loads into a retryable error, so the Discover
  screen does not show an indefinite spinner when profile/candidate loading
  fails to resolve.

### 2.5.57

- `ProfileInfoTile` keeps one fixed-width chevron slot across collapsed and
  expanded inline editing states. Do not swap the closed affordance for a wider
  `IconButton`; it shifts the arrow inward and resets the rotation animation.
- Text-only Profile inline drawers use compact action padding so `Cancel` and
  `Done` stay visually attached to the edited value. Editors with validation
  errors or extra controls keep the roomier panel spacing.
- `RunHypeAvatarStack` now reads `PublicProfile.primaryPhotoThumbnailUrl`, so
  existing profiles with full photos render blurred imagery while thumbnail
  backfills are still catching up. Demo seed data must write
  `profilePhotos.thumbnailUrl` so tiny social-proof avatars do not depend on
  full-size images in normal dev fixtures.

### 2.5.56

- Platform chrome is now adaptive for the high-visibility native surfaces:
  `AppShell` uses `CupertinoTabBar` with Cupertino icons on iOS and Material
  `NavigationBar` elsewhere; `CatchTopBarTabBar` uses
  `CupertinoSlidingSegmentedControl` on iOS and Material `TabBar` elsewhere.
- Shell unread badges must reserve their own icon-box space instead of using
  negative offsets; Cupertino tab bars clip overflow above destination icons.
- Date/time selection must go through `showCatchDatePicker` and
  `showCatchTimePicker` so iOS gets bottom-wheel Cupertino pickers while
  Android keeps Material calendar/clock pickers.
- Confirmation dialogs must go through `showCatchAdaptiveDialog` or wrappers
  such as `showConfirmDangerDialog` so iOS gets `CupertinoAlertDialog` and
  Android keeps Material dialogs. Snackbars, app-wide `CatchNotice` overlays,
  and content-heavy Catch bottom sheets remain separate
  app-notification/sheet conventions.

### 2.5.55

- `CatchCelebrationScreen` is now a consistent white-on-orange celebration
  surface. Detail cards, note cards, dividers, icons, close affordances, and
  hero checkmarks use white/white-alpha content instead of the older dark ink
  treatment. Keep celebration CTAs as explicit action controls on the orange
  surface, but do not reintroduce dark text inside celebration content panels.

### 2.5.54

- `CatchSelectMenu` separates trigger radius from popup radius. Pill triggers
  may stay pill-shaped, but opened menus must use normal rounded panel corners
  so first/last rows are not clipped by a giant pill radius. This fixes the Run
  Clubs city picker dropdown and applies to future dropdowns that use the
  shared select primitive.

### 2.5.53

- `StepperFooter` blends into the create-event page background instead of using
  a separate surface band and top divider. Its draft and primary actions share
  the row width directly; do not reintroduce `Spacer` between the actions,
  because it can starve the primary button lane and cause label overflow.

### 2.5.52

- `ProfileInlineEditableText` supports multiline row-owned editing. Bio edits
  directly in the `ProfileInfoTile` value slot with a multiline `EditableText`;
  the inline drawer below the row is reserved for validation/save feedback and
  `Cancel`/`Done`, not a second boxed text field.
- Compact `CatchButton` labels scale down inside tight non-full-width action
  rows so inline editor actions do not produce right-edge overflow on narrow
  devices.

### 2.5.51

- `UpcomingRunsHero` no longer renders one pagination dot per booked run. Its
  carousel affordance is a fixed-width progress rail, while the in-card
  `N/total` pill remains the exact position indicator. Keep unbounded dashboard
  run counts out of width-growing rows.

### 2.5.50

- Chats tab header title is `Chats`, not `Your catches`, so it no longer wraps
  or conflicts with the separate Catches tab. The shared `CatchSliverHeader`
  keeps explicit long-title support through `wrappedTitleHeight`; short-title
  screens should use `twoLineTitleHeight`.
- `CatchSliverHeader` now exposes shared search-row spacing constants for the
  control top padding and the gap to first content. Use these before adding
  local search/list spacing math.
- `ChatListTile` unread state is row-level and conversation-level: warm surface
  tint, primary border, avatar ring, stronger text, and a visible unread chat
  pill by the timestamp. Do not show per-message counts or mark the user's own
  latest message as unread.

### 2.5.49

- Edit Profile bio now uses the same row-owned inline disclosure contract as
  other profile fields. `ProfileInlineTextEntryEditor` supports multiline
  row-owned editing for long text such as Bio.
- The signed-in Bio edit flow no longer uses `ProfilePromptCard` or the
  standalone `ProfileInlineTextEditor`; keep prompt-style bio presentation in
  read-only profile-card widgets.

### 2.5.48

- `PersonAvatar` now supports obscured rendering for tiny hype/social avatars,
  and `PersonAvatarStack` is the shared overlap/overflow primitive. Use the
  stack instead of feature-local circular-avatar stacks.
- `RunHypeAvatarStack` owns the run participant thumbnail row used by Dashboard
  upcoming-run cards and Run detail. It selects recent signed-up/attended
  `runParticipations`, filters toward the viewer's interested-in genders, reads
  `publicProfiles`, and prefers `profilePhotos.thumbnailUrl` so tiny hype
  avatars do not load full profile photos once profile thumbnail backfill is
  complete.
- Chat and match celebration avatars should use non-obscured `PersonAvatar`
  with `PublicProfile.primaryPhotoThumbnailUrl`.

### 2.5.47

- `EventPinsMap` is the shared event-pin map canvas for both the browse map and
  single-run location map. Keep map centering outside the pin widget through
  `resolveEventMapInitialCenter`: device location wins until the user manually
  selects a city; selected city is the no-permission/manual-override fallback.
- Event pins must not choose the browse-map camera center.
- `EventMapViewModel` filters to upcoming, non-cancelled events before rendering
  the browse map. Events without exact coordinates may remain in the sheet, but
  they must not produce pins.

### 2.5.46

- `ChatThreadPreview` is the inbox rendering contract. The chats list view
  model collapses duplicate active match documents by other participant,
  separates no-message matches into the horizontal rail, and feeds complete
  preview rows to the tile widgets. Chat list tiles and rails should not
  re-fetch public profiles or raw match documents.
- `Match.runIds` replaces the old single `runId` contract. Dart remains
  backward-compatible with legacy `runId` documents, while Functions and demo
  data now write `runIds`. Keep merged run IDs ordered oldest-to-newest so
  `latestRunId` points at the newest shared run.
- Chat messages may temporarily have a null `sentAt` while Firestore resolves a
  server timestamp. Message bubbles must render that as a pending/sending state
  instead of assuming a non-null timestamp.

### 2.5.45

- Event detail location rows are map affordances only when the event has both
  `startingPointLat` and `startingPointLng`. `WhenWhereCard` owns the
  conditional chevron/tappable row, while `EventDetailBody` owns navigation to
  the neutral `/events/:eventId/location` route-backed
  `EventLocationMapRouteScreen`; do not show chevrons for address-only events.

### 2.5.44

- `DashboardFull` header avatar now uses the current user's
  `primaryPhotoThumbnailUrl` with full-photo fallback and is an explicit button
  to the Profile tab. Tiny avatar-scale surfaces should prefer thumbnail URLs;
  backend thumbnail generation/backfill landed in 2.5.48.

### 2.5.43

- `ChatsListScreen` remains a `CustomScrollView` with a shared
  `CatchSliverHeader`, but the populated body is now sliver-native too:
  `ChatsListBody` returns a `SliverMainAxisGroup`, `ChatNewMatchesRail` is a
  one-off `SliverToBoxAdapter`, and `ChatConversationsList` owns a real
  `SliverList`. Do not reintroduce a shrink-wrapped vertical `ListView` for the
  inbox.
- `ChatListTile` is a full-width `CatchSurface` row using `PersonAvatar` and
  `CatchBadge`; keep chat tile visual changes inside that reusable row instead
  of styling raw `ListTile` instances.

### 2.5.42

- `ChatMessageList` must allow each `MessageBubble` to measure its own height.
  Do not use a one-line `prototypeItem` or fixed item extent for chat messages:
  multi-line bubbles and image bubbles need variable height so timestamps stay
  inside their bubble and do not overlap the next row.

### 2.5.41

- `ChatsListViewModel` is the inbox grouping boundary. It must collapse
  duplicate active match documents by the other participant before rendering,
  keeping the latest message preview/timestamp and deriving a 0/1 unread
  conversation flag for the visible row. Do not sum unread message counts.
- The chats header count is a match/person count, not live presence. Do not
  label it `active` unless the data model adds real presence or activity
  tracking.
- `ChatConversationsList` renders chat rows directly; do not reintroduce a
  redundant `Messages` section title under the screen title.

### 2.5.40

- `CatchRangeSlider` now accepts optional `minLabel` / `maxLabel` endpoint
  labels. Use endpoint labels for fixed slider bounds; do not repeat the
  currently selected range above the slider when the row already shows it.
- Profile inline multi-choice selected chips keep the multi-select check icon
  when rendered in the row value slot.
- Expanded profile row editors use a slightly larger label-to-value gap, while
  the shared inline panel keeps `Cancel`/`Done` closer to the editor controls.

### 2.5.39

- Added `ProfileInlineEditableText` for row-owned Profile text editing. It uses
  `EditableText` directly so the active value keeps the closed row style and
  position while adding only cursor, selection, validation, and a text-width
  underline.
- `ProfileInlineTextEntryEditor` now uses that inline editable value instead
  of embedding a boxed text-field primitive in the row. Long text row variants
  such as Bio now use the same row-owned editable value contract.
- The scroll-away Profile title header now owns only the Settings action. Review
  history, payment history, and sign out moved to `SettingsScreen` Account rows.

### 2.5.38

- `ProfileInlineAnimatedBody` now keeps collapsed and expanded drawers
  full-width and uses fade-only body content transitions while `AnimatedSize`
  owns the vertical reveal. This prevents profile inline action rows from
  sliding sideways during text/chip drawer open/close.
- Profile inline editors now share one internal panel for save errors,
  vertical padding, and `Cancel`/`Done` actions. Field-specific editors should
  provide only their controls and draft-state logic.
- Bio editing uses `ProfileInlineAnimatedBody` too, so edits follow the same
  drawer motion contract as grouped profile rows.
- Removed stale catalog references to the deleted profile bottom-sheet editor
  classes. Normal profile field editing is inline; future exceptions should be
  explicit route/dialog flows, not a resurrected generic field sheet.

### 2.5.37

- Added `ProfileInlineDisclosure` and `ProfileInlineAnimatedBody` as the shared
  animated shell for Edit Profile inline drawers. Text and enum row editors now
  route through the shell, and legacy `ProfileInfoEntry.editor` bodies are
  wrapped by `ProfileInfoSection`, so height/range drawers use the same
  open/close motion.
- `ProfileInfoTile` now animates row-height changes, row value swaps, and
  chevron rotation with `CatchMotion.base`, which covers text-field entry,
  selected chip wrapping, and dynamic chip list changes without custom
  animation controllers.

### 2.5.36

- `SettingsRow` value text now gets a real right-hand value lane when no custom
  trailing widget is supplied. Label/value rows therefore keep the primary
  label pinned left and the secondary value pinned right, while switch/trailing
  rows keep their existing trailing-widget behavior.

### 2.5.35

- Added `ProfileInlineSingleChoiceEntryEditor` and
  `ProfileInlineMultiChoiceEntryEditor` for Profile enum rows. These editors
  render selected `CatchChip` values inside the `ProfileInfoTile.valueEditor`
  slot, exclude selected values from the option list below the row, and keep
  `Cancel`/`Done` as the commit boundary.
- `ProfileInlineSingleChoiceEditor` and `ProfileInlineMultiChoiceEditor` were
  removed from Profile row usage so chip fields follow the same in-row editing
  model as text fields.

### 2.5.34

- `ProfileInfoTile` now supports an optional `valueEditor` slot for in-row
  editing. When present, the tile replaces its value text with the supplied
  control and shows a small collapse icon button instead of wrapping the whole
  row in an `InkWell`, so the embedded field can receive focus.
- Added `ProfileInlineTextEntryEditor`, which renders text Profile rows with a
  compact label-less `CatchTextField` in the value position and keeps
  error/actions below the row. This was superseded by 2.5.49 for long text,
  which uses the same row contract with a multiline body editor.

### 2.5.33

- `ChipField` now enforces required-vs-optional empty selection rules at the
  primitive boundary. `allowEmptySingleSelection` only clears on second tap when
  `isOptional` is true; required single-choice fields keep the selected value.
  Required multi-choice fields do not allow the last selected chip to be
  removed.

### 2.5.32

- `ChipField` now supports `allowEmptySingleSelection`, defaulting to `false`.
  Profile inline single-choice editors enable it so an already-selected chip can
  be tapped again to clear the local draft selection before `Done` saves.
- Profile inline single-choice editors no longer save immediately on chip tap
  and no longer render a separate `Clear` action. They now use the same
  `Cancel`/`Done` footer as text, range, height, and multi-choice editors.

### 2.5.31

- `ChipField` now supports `showLabel`, defaulting to `true` for standalone
  form usage. Expanded Profile inline editors opt out because the parent
  `ProfileInfoTile` already provides the visible field label.

### 2.5.30

- Create/Edit Club now uses the shared step-flow form pattern instead of a
  single long form. `CreateClubScreen` owns a four-step owner wizard
  (`Club basics`, `Club details`, `Host defaults`, and
  `Event success defaults`), reuses
  `CatchStepFlowHeader`/`StepperFooter`, and keeps finite form pages fully
  mounted so validation covers offscreen fields.
- Added local create-club draft support through `ClubDraft`,
  `ClubDraftRepository`, and `CreateClubDraftController`. Drafts are
  create-only, user-scoped, local to the device, and deleted after successful
  club creation.
- Club creation affordances now derive from `canCreateClubProvider`.
  The UI hides plus/create controls after the signed-in user already hosts a
  club; the `createClub` callable enforces the invariant with the
  server-owned `clubHostClaims/{uid}` lock.
- Added `CatchStepFlowHeader` as the shared app-bar-level step primitive so
  Create Run, Create Run Club, and Onboarding keep the step count aligned with
  the title row instead of adding a separate vertical counter row.

### 2.5.29

- Edit Profile field editing now uses inline expansion as the default pattern.
  `ProfileInfoSection`/`ProfileInfoEntry` can host an expanded editor below a
  row, and `ProfileInfoTile` shows expanded state instead of always implying a
  route or sheet drill-in.
- Added the Profile inline editor family in
  `lib/user_profile/presentation/widgets/profile_inline_editors.dart` for text,
  nullable single-choice chips, multi-choice chips, height, and range edits.
  These widgets own transient input state and save through
  `ProfileEditController`, leaving repository and Firestore contracts
  unchanged.
- Removed the old profile field bottom-sheet editor file. Complex future flows
  such as photo management may still use focused routes/dialogs, but ordinary
  profile fields should not use bottom sheets.
- `CatchChip` now constrains long labels inside the chip row so inline editors
  and other narrow surfaces can reuse the primitive without feature-local
  overflow fixes.

### 2.5.28

- Reviews are now explicitly split by write contract. Club detail uses a
  read-only review summary below the upcoming events schedule and shows only
  the latest three reviews. Event detail is the page-level review surface that
  can open `WriteReviewSheet` for attended participants.
- Dashboard now derives a post-event review prompt from attended events and the
  current user's existing reviews, then opens the existing event-scoped review
  sheet. The review prompt is a normal dashboard card, not a second mutation
  path.
- Added `ReviewsHistoryScreen` under `/you/reviews`, reachable from the Profile
  overflow menu, so users can see and edit their previous event reviews.

### 2.5.27

- Added `CatchTextButton` as the canonical primitive for inline, dialog,
  banner, and top-bar text-only actions. Raw feature `TextButton` usages were
  migrated to this primitive; `CatchButton` remains the pill CTA primitive.
- Added `CatchOtpCodeField` as the canonical one-time-code input primitive.
  `OtpPage` now delegates its visible digit boxes and hidden platform input to
  that core primitive instead of owning a screen-local raw `TextField`.
- `tool/widget_cleanup_scan.sh` now scans broad primitive-bypass classes:
  raw Material/Cupertino buttons, raw text inputs, literal `SizedBox` spacing,
  decorated feature-local surface shells, and app-facing unstyled `Text`
  candidates. Treat the broad `SizedBox`/surface/text queues as triage lists
  for focused feature batches.

### 2.5.26

- Numeric +/- controls now route through `CatchNumberStepper`. The former
  run-local `DurationStepper` was removed, Create Run duration now uses the core
  primitive directly, and Edit Profile height uses the same primitive for its
  bounded centimeter picker. Distance and capacity fields remain unchanged.
- `tool/widget_cleanup_scan.sh` now flags raw paired add/remove `IconButton`
  steppers outside the core primitive so future one-off numeric controls are
  caught before screenshots expose the drift.

### 2.5.25

- Range sliders now route through the shared `CatchRangeSlider` primitive,
  which hides tick marks centrally while preserving discrete divisions. The
  widget cleanup scanner flags raw `RangeSlider`/`SliderTheme` usage outside
  the primitive.
- Swipe Filters now expose only age and interested-in preferences. Pace range
  and run type are no longer client-editable filters, and the filter save
  controller persists only discovery age plus interested-in genders.
- Edit Profile no longer exposes private discovery preferences (`Interested in`
  and `Age range`). It remains focused on fields that render on the public
  profile/preview surfaces.
- Dark-theme primary CTA foreground is now white via `CatchTokens.primaryInk`,
  so screens using `CatchButton` defaults do not need per-screen foreground
  overrides.

### 2.5.25

- Settings notification toggles are now category-specific: matches/catches,
  messages, run reminders, run changes/cancellations, club announcements, and
  weekly digest. Club announcements are global; the per-club bell is stored on
  the membership edge.
- Run club detail now has a two-tier notification affordance: joining a club
  enrolls the user in durable Activity updates, while the bell next to the
  membership action opts into push notifications for non-critical club updates.
- Upcoming run reminders now have a backend scheduled producer. `ActivitySection`
  suppresses local derived reminder rows when a durable backend `runReminder`
  item already exists for the run.

### 2.5.24

- Activity timeline now also receives backend-owned `eventUpdated` and
  `eventCancelled` items. `updateEvent` creates schedule/location change
  notifications for signed-up and waitlisted participants; `cancelEvent` creates
  cancellation notifications. Event cancellation host UI and policy remain queued
  before exposing the action end to end.

### 2.5.23

- Activity timeline now also receives backend-owned `clubUpdate` items when a
  followed club posts a new run. These rows route to run detail through
  `runId`/`runClubId`, matching run signup and waitlist-promotion rows.

### 2.5.22

- Activity timeline now receives backend-owned run booking notifications as
  durable items too. `runSignup` and `waitlistPromotion` rows route to run
  detail through their `runId`/`runClubId` metadata, while upcoming run
  reminders remain local derived rows until the reminder producer exists.

### 2.5.21

- Home activity/notifications now has a durable notification seam.
  `ActivitySection` reads
  `watchActivityNotificationsProvider(uid)` from
  `notifications/{uid}/items`, renders match/message activity from backend-owned
  timeline items, keeps upcoming run reminders as local derived items for now,
  and uses `ActivityController.markAllRead` to mark notification docs read
  before resetting message unread counters.

### 2.5.20

- Event participation roster/count reads are migrated off compatibility arrays.
  `EventParticipationRoster` centralizes edge-derived booked, checked-in, and
  waitlisted ID lists; `WhoIsGoing` and `HostEventManageScreen` use it for exact
  rosters. List/stat surfaces use `Event` count projections instead of hidden
  participant arrays.

### 2.5.19

- Catches/swipes participation reads now use `eventParticipations` for
  candidate generation, exhausted-queue empty-state attendance copy, and event
  recap attendee/checked-in state. `EventRecapViewModel` owns the recap data
  seam.

### 2.5.18

- Host attendance now uses `AttendanceSheetViewModel` to combine the event
  stream with `eventParticipations` and derive roster/check-in state from
  participation statuses instead of legacy event participant arrays.

### 2.5.17

- Event detail now treats `EventParticipation` as the source of truth for the
  current viewer's booking, waitlist, attendance, CTA, and review eligibility
  state. `EventDetailViewModel` watches `eventParticipations/{eventId_uid}`,
  `EventDetailBody` passes that edge to detail sections, and `EventDetailCta`
  ignores stale compatibility arrays for current-viewer status.

### 2.5.16

- Relationship-document read migration: Dashboard recommendations, Run Clubs
  list/detail membership state, and Run Map recommendations now read
  `runClubMemberships` instead of profile/club membership arrays.
  `DashboardFull` takes explicit `followedClubIds`, and runs
  recommendations use `RecommendedRunsQuery` so provider keys are stable when
  IDs are derived from membership streams.

### 2.5.15

- Completed the next profile-card polish pass. `RUN PROFILE` is now the only
  running identity section on the shared Swipes/Profile Preview/Public Profile
  card; the redundant lower `RUNNING` chip section and its widget were removed.
  Additional non-hero photos are now inset inside the card with consistent
  margins and rounded corners, while the hero photo remains full-bleed.

### 2.5.14

- Added the shared celebration primitive family for high-emotion completion
  moments. `CatchCelebrationScreen` owns the full-screen branded surface,
  `CelebrationEffectsController` owns haptics, and feature screens supply
  moment-specific copy/details/actions. Haptics are enabled by default for host
  run creation, user run signup/payment confirmation, user self-check-in, and
  match creation. Sound is intentionally deferred under
  `CELEBRATION-SOUND-001` and should be added through the same effects
  controller rather than feature widgets.

### 2.5.13

- Historical note, superseded by 2.5.73: Home mirrored the Profile tab
  architecture. `DashboardScreen` owned a
  route-local `TabController`, `NestedScrollView`, collapsible greeting/empty
  header, pinned `Dashboard`/`Activity` tab row, and native `TabBarView`
  paging. The Dashboard tab renders the existing dashboard widgets as sliver
  bodies, while the Activity tab owns notifications and run/message updates in
  a timeline-style activity feed.

### 2.5.12

- Profile-card follow-up guidance after visual review: Catches, Profile
  Preview, and Public Profile must keep one identical `ProfileSurface` rendering
  path. The canonical running identity should be a single dark `RUN PROFILE`
  card; do not also render duplicate pace/distance chips in a lower `RUNNING`
  card. Additional photo sections should be inset inside the card with
  consistent margins, rounded corners, and spacing instead of edge-to-edge
  blocks unless they are the hero photo.

### 2.5.11

- The shared swipe/profile-preview profile surface received its first polish
  pass while preserving one rendering path for Swipes, Profile Preview, and
  Public Profile. The card remains dark and immersive in both light and dark
  app themes, now uses a local `ProfileCardPalette`, shows only display name,
  age, and optional city on the hero photo, moves relationship goal into detail
  chips, promotes the bio prompt ahead of running stats, and uses a branded
  missing-photo fallback.

### 2.5.10

- Edit Profile now exposes `Display name` as the first About field. It is the
  editable public-facing name used by profile preview/public profile surfaces,
  initializes from onboarding first name, trims on save, and rejects blank or
  whitespace-only values. Legal identity fields from onboarding remain
  separate: date of birth and gender stay readonly, and last name is private.

### 2.5.9

- Profile range edit sheets keep discrete slider divisions for valid age/pace
  values, but hide RangeSlider tick marks so the track reads as a continuous
  control instead of a broken/dotted line.

### 2.5.8

- Profile Preview now bridges the inner `ProfileSurface` leading overscroll back
  to the route-owned `NestedScrollView` controller, so dragging down from the
  top of the preview card reveals the Profile header continuously.

### 2.5.7

- Profile Edit and Preview tabs now share `profileTabBodyPadding`: 20 px
  horizontal, 8 px top, and 32 px bottom. Preview applies that inset inside its
  filled body so the card gap is persistent when its internal scroll returns to
  the top.

### 2.5.6

- Profile preview keeps its card inset inside the `SliverFillRemaining` child
  instead of as outer `SliverPadding`, so the top gap under the pinned tab bar
  returns after the user scrolls the preview card down and back to top.

### 2.5.5

- Profile tab labels are now `Edit` and `Preview`. The screen title already
  says `Profile`, so the tab row no longer repeats the word profile.

### 2.5.4

- `ChipField<T>` now gives multi-select sheets an explicit selected-state
  affordance by rendering a leading check icon on selected chips. Single-select
  chip fields keep the previous selected-chip treatment without a checkmark.

### 2.5.3

- `ProfileScreen` now explicitly preserves the `NestedScrollView` overlap
  contract: the scroll-away title remains a normal outer sliver, the pinned
  Edit/Preview tab row is wrapped in `SliverOverlapAbsorber`, and each tab
  `CustomScrollView` starts with a matching `SliverOverlapInjector`.

### 2.5.2

- `_SingleEnumEditSheet<T>` now separates persisted selection from a temporary
  pending chip tap. Immediate-save single-choice sheets show an inline saving
  indicator while the mutation is pending, and failed saves clear the pending
  highlight instead of making an unsaved nullable field look selected.

### 2.5.1

- `AppShellActiveTab` moved from `app_shell.dart` to
  `app_shell_active_tab.dart` and is now the shared retained-tab lifecycle
  primitive.
- `AppShell` no longer prewarms the Explore stream. Explore, Catches, Chats,
  and Profile tab roots use the active-tab lifecycle signal to avoid watching
  screen-owned streams while their indexed-stack branch is inactive.

### 2.5.0

- Removed `CatchErrorText` instead of retaining it as a compatibility layer.
  Migrated remaining call sites to `CatchErrorState`, `CatchErrorScaffold`, or
  `CatchInlineErrorState` with feature context and retry callbacks where the
  provider seam is obvious.

### 2.4.9

- Added the canonical app-facing error primitive family: `CatchErrorState`,
  `CatchErrorScaffold`, `CatchSliverErrorState`, `CatchInlineErrorState`, and
  `showCatchErrorSnackBar`.
- `AsyncValueWidget` / `AsyncValueSliverWidget` now default to branded error
  states.

### 2.4.8

- Profile edit sheets now save before dismissing, show loading/error state while
  `ProfileEditController.saveFieldsMutation` is pending, and optional
  single-choice sheets open with no selected chip when the profile field is
  empty.
- `ChipField` now supports disabled state so modal choices can be locked while
  profile edits are saving.

### 2.4.7

- The old signed-in profile prompt card used the same label/value typography
  hierarchy as Edit Profile before being retired from the edit flow in 2.5.49.

### 2.4.6

- Profile safe-area ownership moved to the route boundary so the pinned
  Edit/Preview row stays below the Dynamic Island without reserving a visible
  top-inset gap while the title header is expanded.

### 2.4.5

- Profile's pinned Edit/Preview tab row now reserves the top safe area when it
  sticks, and the route uses native `TabBarView` paging instead of manually
  swapping tab bodies at the end of a horizontal drag.

### 2.4.4

- Profile edit surfaces now keep signup identity fields readonly after
  onboarding, expose Instagram editing, and treat public profile names as
  first-name-only projections.

### 2.4.3

- `ProfileSurface`/`ScrollableProfile` now accept an explicit preview scroll
  controller and keep the internal card scroll view non-primary so sliver route
  parents do not steal or share its vertical offset.

### 2.4.2

- Profile edit sheets now route text validation, keyboard/autofill behavior,
  bounded height edits, and open-ended age display/storage through shared
  profile validation helpers.

### 2.4.1

- `AppShell` now exposes the active bottom-tab index through
  `AppShellActiveTab` so retained indexed-stack branches can pause expensive
  screen-level listeners while inactive.
- Historical note: `DashboardScreen` briefly became a `ConsumerStatefulWidget`
  so Home could invalidate the booked-runs stream when the Home tab was no
  longer active. The current Home screen is a stateless single-surface route;
  provider gating remains owned by the route/view-model layer.

### 2.4.0

- Home/Dashboard now owns run-arrival actions. Participant `Check in` and host
  `Take Attendance` render as the first dashboard content card when their time
  windows are active.
- Event detail bottom CTAs keep booking lifecycle actions only; arrival actions
  have moved to Home.

### 2.3.0

- Calendar is now a single sliver-native scroll surface. Its header and agenda
  scroll together instead of using a fixed header plus nested agenda scroll.
- `EventAgendaList` / `EventAgendaSliverList` now support `preserveInputOrder` for
  callers that need a precomputed semantic order, such as upcoming-first
  calendar agendas.

### 2.2.0

- Dashboard full and empty states are now sliver-native.
- Added `DashboardSliverHeader` to the inventory as the dashboard-specific
  wrapper around the shared `CatchSliverHeader` contract.

### 2.1.0

- Added `WIDGET-CATALOG-001` to the recursive audit rules.
- Future passes must update this catalog when they add, delete, move, rename, or
  materially change a widget, primitive API, screen ownership model,
  sliver/tab structure, or reusable design-system role.
- Tiny implementation-only edits do not require catalog changes when inventory
  and usage guidance stay the same.

### 2.0.0

- Widget inventory is versioned under the recursive audit loop.
- Active workflow rules moved to the audit registry and widget cleanup tracker
  so future passes can read deltas instead of the full catalog.

## Widget Cleanup Operating Instructions

### User Request

The user wants an ongoing architecture and widget-system cleanup of the Flutter
app. The goal is to make screens and widgets easier to maintain, easier to test,
and easier to apply a brand/design system to by reducing duplicate local UI
implementations and consolidating reusable patterns into appropriate shared
primitives.

The user specifically wants this work to proceed incrementally:

- Keep a single source of truth for active cleanup status in
  `docs/audit_registry/backlog.json`.
- Keep appending newly discovered work, recommendations, and bug fixes to that
  tracker even when they are outside the current pass.
- Prefer controller-owned business logic and repository writes, while allowing
  widgets to own local UI concerns such as focus, scroll, animations, navigation,
  and temporary input state.
- Standardize nomenclature around `user_profile`, not `my_profile`.
- Clean up heavily duplicated widgets and screens in small verified batches.
- Expand scope to adjacent widgets, repositories, controllers, or tests when
  needed to make the cleanup coherent.
- Treat tests as design feedback, not just verification. Whenever a feature,
  repository, controller, provider, widget, or primitive is tested and the loop
  is closed, use the test structure, complexity, and brittleness to decide
  whether the implementation should be reshaped toward better readability,
  composability, performance, and testability.
- Treat documentation as part of the architecture. Prefer updating
  `docs/README.md`, `docs/audit_registry/backlog.json`, this catalog, or another
  existing source-of-truth doc over creating a new markdown file. If a temporary
  audit/report produces durable guidance, migrate that guidance into the owning
  doc and delete the stale report.
- Ask questions only when the answer cannot be inferred safely from the repo or
  when a product/design decision would materially affect the implementation.

### How To Proceed

1. Start every pass by reading this section and
   `docs/audit_registry/backlog.json`.
2. For broad cleanup passes, run `bash tool/widget_cleanup_scan.sh` before
   editing and again before wrapping up. Treat the output as a triage report,
   not a lint gate: inspect each match, fix high-signal repeated smells, and
   refine the scanner when it becomes noisy.
3. Inspect the target feature plus adjacent shared widgets, controllers, and
   tests before editing.
4. Identify duplicated local UI implementations that block design-system work:
   cards, empty states, bottom sheets, rows, rails, section scaffolds, loading
   states, mutation feedback, and one-off action surfaces.
5. Prefer existing primitives before creating new ones. Important current
   primitives include `CatchSurface`, `CatchButton`, `CatchTextField`,
   `CatchTopBar`, `CatchBottomSheetScaffold`, `CatchEmptyState`,
   `CatchHorizontalRail`, `CatchVerticalSection`, `PersonRow`, `PersonAvatar`,
   event tile variants, `SettingsRow`, `CatchSkeleton`, `CatchBadge`,
   `CatchFormFieldLabel`, `ChipField`, `EventAgendaList`,
   `EventAgendaSliverList`, `MutationErrorSnackbarListener`, and
   `showConfirmDangerDialog`.
6. Add a new primitive only when at least one of these is true:
   repeated UI shells are already present, a primitive removes meaningful
   complexity, the API is likely to be reused soon, or the component expresses a
   durable design-system concept.
7. Keep feature-specific content local. Consolidate shells and patterns, not
   every line of UI copy or layout.
8. Do not over-abstract early. If only one surface needs a helper, use a private
   helper first and promote it later after a second concrete use appears.
9. Name shared primitives by their durable semantic role, not by a temporary
   feature use or purely visual treatment. The name should make the widget easy
   to search for and easy to reason about in future cleanup passes.
10. Keep business logic, repository writes, and product decisions in controllers
   unless there is a clear reason for local widget ownership.
11. Keep screens thin by default. A screen should usually compose feature
   content, route parameters, scaffold/top-bar structure, and local Flutter UI
   mechanics. Move provider state dispatch, repository writes, mutation
   callbacks, and product behavior into feature widgets, providers, or
   controllers unless the local screen ownership is explicit and justified.
12. Put state dispatch in a semantic feature content widget when the screen would
   otherwise become a large `AsyncValue.when` switch. The content widget should
   own loading, error, empty, and data composition for that feature surface.
13. Keep feature widgets single-purpose. A search field should be a search field;
   the parent layout should decide whether it sits next to a city picker,
   filter, or action.
14. Put side-effect feedback close to the trigger. For mutation snackbars and
   banners, wrap the widget that starts the mutation rather than the whole
   screen when feasible.
15. Do not pass `WidgetRef` through helper methods. If a helper needs `ref`,
   make it a `ConsumerWidget`, `ConsumerStatefulWidget`, controller method, or
   provider.
16. Feature-specific sliver headers should wrap generic primitives with feature
   configuration baked in, while keeping layout-only private helper widgets in
   the header file.
17. Keep platform and plugin side effects behind provider/controller seams where
   feasible. Current examples include `ExternalLinkController`,
   `ExternalShareController`, `PaymentConfirmationController`,
   `UpdateRequiredController`, `CreateClubController`, and app-shell
   provider seams.
18. Keep status out of this catalog. Pending, completed, next-up, and scanner
   snapshots belong in `docs/audit_registry/backlog.json`; this file should
   describe reusable instructions, anti-patterns, widget inventory, and durable
   consolidation guidance.
19. After each meaningful batch, update `docs/audit_registry/backlog.json` with
   completed items, newly discovered backlog items, current findings, and the
   recommended next step.
20. After tests pass, inspect how the tests had to be written. If they required
   fragile finders, excessive provider overrides, private implementation
   knowledge, awkward setup, timing hacks, or broad integration scaffolding for
   narrow behavior, treat that as architecture feedback. Refactor or add a
   backlog item so future passes move the code toward clearer seams, smaller
   units, stable user-visible assertions, and easier dependency injection.
21. Update this catalog in the same pass when adding, deleting, moving,
   renaming, or materially changing widgets, primitive APIs, screen ownership
   models, sliver/tab structures, or reusable design-system roles. Skip catalog
   edits only for tiny implementation-only changes that do not affect inventory
   or usage guidance.
22. Verify with focused commands over touched files and relevant tests. Fix
   analyzer errors and warnings. Do not spend cleanup time on analyzer
   info-level issues unless they block the task, mask a real bug, or are already
   being edited for another reason.

### Recurring Anti-Patterns

Use this list as an active checklist during each pass. It should grow as more
patterns are discovered.

- Prop drilling theme tokens. Prefer `CatchTokens.of(context)` inside leaf
  widgets instead of passing `CatchTokens` through constructors.
- Hand-built bottom-sheet shells instead of `CatchBottomSheetScaffold`.
- Hand-built empty states instead of `CatchEmptyState`.
- Hand-built rails/sections instead of `CatchHorizontalRail` or
  `CatchVerticalSection`.
- General-purpose helpers stranded in feature folders instead of `core/widgets`.
- Widgets calling repositories or owning product behavior that belongs in a
  controller.
- Feature screens owning provider state dispatch, mutation callbacks, or
  mutation error feedback that would be clearer in semantic feature content
  widgets.
- Passing `WidgetRef` through helper methods instead of introducing a provider,
  controller method, or `ConsumerWidget` boundary.
- Nesting unrelated widgets together because they share a row or section. Layout
  belongs to the parent; single-purpose widgets should stay single-purpose.
- Duplicating feature-specific sliver header setup instead of baking feature
  configuration into a small wrapper around the shared header primitive.
- Hiding location/GPS or other product behavior in broad screen shells instead
  of putting it in the widget/controller/provider that actually needs it.
- Screen files mixing composition with repeated row/sheet/card plumbing.
- One-off `Container`/`BoxDecoration` card shells where `CatchSurface`, a run
  tile variant, `PersonRow`, `SettingsRow`, or another existing primitive fits.
- Bypassing feature-owned provider/view-model seams to call lower-level
  providers directly.
- Tests coupled to incidental nested-scroll implementation details instead of
  stable user-visible behavior.
- Passing tests that are hard to write, hard to read, slow, broad, flaky, or
  tightly coupled to private implementation details. These are signals that the
  feature may need better seams, clearer controller/provider boundaries, smaller
  widgets, or more semantic primitives.
- Split design-system ownership across `lib/constants`, top-level `lib/theme`,
  and `lib/core/theme`. New design tokens, spacing helpers, typography, app
  theme, motion, radii, and icon sizing should live under `lib/core/theme`.
- Direct Material `Icons.*` imports in feature widgets or widget tests. Route
  icon choices through `CatchIcons.*`; transitional Material-compatible aliases
  are centralized in `lib/core/theme/catch_icons.dart` while semantic names
  remain the preferred API for new surfaces.
- Declared controller mutations that the UI does not actually use. If a
  controller exposes a `Mutation`, the triggering widget should normally run the
  action through that mutation so loading/error/success behavior is observable
  and testable.
- Custom interactive widgets without semantic keys, tooltips, or labels. Any
  button-like tile, photo slot, swipe action, segmented action, or grid cell
  that users tap should have a stable semantic target before tests are written
  around it.
- Platform or plugin side effects embedded directly in widgets. Store launches,
  connectivity subscriptions, FCM initialization, and similar runtime effects
  should sit behind providers/controllers so they can be tested and replaced in
  harnesses.
- Share sheets, external URL launches, image pickers, and platform/store
  actions called directly from presentation widgets. Put these behind a small
  provider/controller seam so tests can replace the side effect and the widget
  only chooses when the action is requested.
- No local feedback loop for recurring cleanup smells. When the same
  anti-pattern appears repeatedly, add or refine a lightweight repo-local
  scanner/checklist, then keep it high-signal enough that future passes will
  actually use it.
- Scanner output that cannot distinguish real widget smells from valid
  controller/provider seams. Cleanup scans should exclude generated files,
  controllers, notifiers, and data layers where appropriate so they point at
  surfaces that actually need design-system attention.

### Catalog Ownership

This catalog is the durable widget inventory and cleanup playbook. It should
not carry the active backlog; use `docs/audit_registry/backlog.json` for
pending, completed, next-up, scanner snapshots, and findings. Keep this file current
when widgets are added, deleted, moved, renamed, or when a shared primitive or
controller seam becomes part of the standard operating model.

Current durable direction:

- Theme, typography, spacing compatibility helpers, radii, and app theme belong
  under `lib/core/theme`; club identity serif/display treatments route through
  `CatchFonts`/`CatchTextStyles` instead of local `GoogleFonts.getFont` calls.
- Run-club detail uses the shared agenda UI instead of a two-dimensional
  schedule grid.
- Normal leaf widgets should read `CatchTokens.of(context)` locally instead of
  receiving token objects through constructors.
- URL/share/store/image-picking side effects should go through controller or
  provider seams before reaching plugins.
- Broad cleanup passes should use `tool/widget_cleanup_scan.sh` as a triage
  aid, then update the tracker with what was fixed or intentionally deferred.

---

Every StatefulWidget, StatelessWidget, ConsumerWidget, and ConsumerStatefulWidget in `lib/`, grouped by feature area with a short description of what each widget does.

Generated 2026-05-06.

---

## App Entry Point

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `MyApp` | `lib/app.dart:17` | Root widget. Watches `goRouterProvider`, `forceUpdateRequiredProvider`, and `locationInitializerProvider`. Renders `MaterialApp.router` with Catch-theming, localization, and a force-update gate that shows `UpdateRequiredScreen` when the app version is below the remote minimum. Also renders an environment `Banner` in non-prod builds. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_ForceUpdateLifecycleWrapper` | `lib/app.dart:93` | Re-fetches Firebase Remote Config when the app is foregrounded so the force-update gate stays fresh during long-running sessions. Uses `WidgetsBindingObserver` to listen to `AppLifecycleState.resumed`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ForceUpdateCheckLoadingScreen` | `lib/app.dart:141` | Scaffold with centered `CatchLoadingIndicator` shown while the force-update check is loading. |
| `_ForceUpdateCheckErrorScreen` | `lib/app.dart:150` | Error screen shown when the force-update check fails. Displays a "Could not verify app version" message with a retry button and optional diagnostic info. |

---

## Core — Presentation (AppShell & Routing)

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `AppShell` | `lib/core/presentation/app_shell.dart:34` | Main tab shell with adaptive bottom navigation (Home, Explore, Catches, Chats, You): handoff `CatchTabDock` on Android/non-iOS platforms and native `CupertinoTabBar` on iOS. Watches provider-backed connectivity for the offline app notice, initializes FCM through `appShellFcmInitializationProvider`, exposes active-tab state through `AppShellActiveTab`, and keeps Crashlytics/Analytics user IDs synced with auth state. Shell-level streams stay limited to shell-wide UI such as auth, connectivity, FCM, and unread badges. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `AppShellActiveTab` | `lib/core/presentation/app_shell_active_tab.dart:9` | Inherited lifecycle signal for indexed-stack tabs. Lets retained tab branches detect whether they are currently selected without coupling feature screens directly to `StatefulNavigationShell`. |
| `AppShellNavigationBar` / `AppShellNavigationItem` | `lib/core/presentation/app_shell.dart:210` | Shared adaptive bottom-navigation primitive with stable key, destination-driven labels/icons, and unread badge handling. Consumer shell uses the default Home / Explore / Catches / Chats / Profile set; `HostAppShell` supplies Events / Clubs / Inbox / Account through the same Cupertino tab-bar chrome on iOS and Material 3 navigation chrome elsewhere. |
| `AppShellNavigationBadge` | `lib/core/presentation/app_shell.dart:333` | Shell unread badge. Reserves a fixed icon box and positions the pill inside it so Cupertino and Material bottom nav containers cannot clip the count. |
| `_RouterLoadingScreen` | `lib/routing/go_router.dart:438` | Minimal scaffold with `CatchLoadingIndicator` shown during route-level async data resolution. Host create/edit wrappers live in the host feature folders, not in the shared router. |

---

## Core — Design System Widgets

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchTextField` | `lib/core/widgets/catch_text_field.dart:12` | Canonical text input. Wraps `FormField<String>` + `TextField` with label, helper/error copy, prefix/suffix icons, clear button, initial-value syncing, default keyboard done/dismiss behavior, tap-outside unfocus, and handoff composition knobs for boxed vs underline chrome, centered alignment, tabular numeric figures, forced focus styling, and quiet trailing content. `floating` is for map/hero overlay chrome, `compact` for dense search/filter rows, and `md` for regular forms. |
| `CatchButton` | `lib/core/widgets/catch_button.dart:13` | Canonical button. Supports `primary`, `secondary`, `ghost`, `danger`, and `light` variants; activity-accent primary fills via `accentColor`; `sm`, `md`, `lg` sizes; loading state with animated dots; hover/press feedback; optional leading icons; and `isInteractive: false` for button-looking labels inside an already tappable parent. Use `light` for solid-white pill CTAs so foreground/background colors stay paired across light and dark themes. |
| `CatchActionMenu<T>` | `lib/core/widgets/catch_action_menu.dart:24` | Anchored overflow trigger for action menus. Opens the shared handoff `CatchMenu` panel from an `IconBtn`, supports icons, sublabels, selected rows, disabled rows, destructive rows, and typed selected values. |
| `CatchSelectMenu<T>` | `lib/core/widgets/catch_select_menu.dart:9` | Token-driven menu-anchor select primitive. Supports compact/md heights, rounded or pill triggers, optional prefix icons, disabled/error states, and a separately rounded popup panel so pill triggers do not clip opened menu rows. |
| `CatchDropdownField<T>` | `lib/core/widgets/catch_dropdown_field.dart:8` | Token-driven single-select dropdown field for `Labelled` enum-like values. Wraps `FormField<T>` + `CatchFormFieldLabel` + `CatchSelectMenu<T>`, keeps initial-value syncing centralized, and reports validation errors with the shared supporting text role. |
| `CatchSearchField` | `lib/core/widgets/catch_search_field.dart:8` | Handoff `SearchField`: raised pill browse input with search glyph, controlled value sync, quiet clear target when non-empty, optional empty-state trailing action for composed search chrome, platform Done submit, focus callbacks, and semantic labeling. Use instead of `CatchTextField` for label-less browse/search affordances. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchSurface` | `lib/core/widgets/catch_surface.dart:9` | Canonical surface/card primitive. Supports `surface`, `raised`, `primarySoft`, and `transparent` tones; `none`, `raised`, and `overlay` elevations; optional border, gradient background, corner radius, and tap handling via `InkWell`. |
| `CatchPanel` | `lib/core/widgets/catch_panel.dart:7` | Handoff `Panel`: bounded surface card for self-contained groups and flow stages. Wraps `CatchSurface` with surface fill, hairline border, `radius-md`, card shadow, and 20px default padding. |
| `CatchMenu<T>` | `lib/core/widgets/catch_menu.dart:27` | Handoff `Menu`: anchored dropdown panel with overlay surface, line2 border, radius-md corners, row hairlines, optional leading icon, mono sublabel, selected check mark, danger tone, and typed selection callbacks. |
| `CatchExpandingSearch` | `lib/core/widgets/catch_expanding_search.dart:8` | Handoff `ExpandingSearch`: app-bar search primitive that starts as a single magnifier target, expands to fill the available header width, composes `CatchSearchField`, clears non-empty queries first, and exposes a close target for empty expanded search. Used by `CatchBrowseHeader` for Clubs and Chats search chrome. |
| `CatchKicker` | `lib/core/widgets/catch_kicker.dart:5` | Handoff `Kicker` leaf: uppercase mono eyebrow for section starts and editorial labels, with optional color override and `md` / `lg` sizes. Used by shared section and info-group composition. |
| `CatchMonoLabel` | `lib/core/widgets/catch_mono_label.dart:5` | Single-line mono text leaf for compact metadata in dense cards and rails. Use when a small metadata string needs the shared mono label style and ellipsis behavior without restating local `Text` setup. |
| `SoftBand` | `lib/core/widgets/soft_band.dart:7` | Handoff quiet tinted inset row for privacy notes, tips, and secondary details inside panels or sections. Uses `CatchSurfaceTone.primarySoft`, small-radius chrome, compact inset padding, and no border/elevation by default. |
| `SectionLabel` | `lib/core/widgets/section_label.dart:7` | Handoff activity-accent eyebrow for section starts inside panels. Carries one accent color through an optional leading glyph and mono kicker label, with bounded ellipsis behavior for long labels. |
| `CatchDetailHeroBackdrop` | `lib/core/widgets/catch_detail_hero_backdrop.dart:4` | Shared photo-or-branded-fallback backdrop for detail-page heroes. Used by club and event detail headers so no-photo states share the same dark branded gradient and scrim treatment. |
| `CatchMetricStrip` | `lib/core/widgets/catch_metric_strip.dart:17` | Shared detail-page metric rail for compact value-over-label stats. Owns the white surface, border, spacing, dividers, mono value styling, optional unit styling, and label truncation so club and event detail stats cannot drift. |
| `StatStrip` | `lib/core/widgets/stat_strip.dart:13` | Handoff flat hairline-bordered row of 2-4 labeled data pairs. Renders numeric mono figures above uppercase mono labels and is used by club detail stats. |
| `CatchTextButton` | `lib/core/widgets/catch_text_button.dart:6` | Canonical text-only action primitive for inline actions, dialog actions, retry links, and top-bar text actions. Uses Catch tokens and text styles while preserving Material `TextButton` semantics. Use `CatchButton` for pill CTAs. |
| `CatchCodeInput` | `lib/core/widgets/catch_otp_code_field.dart:9` | Handoff `CodeInput`: static controlled verification-code row with 6-cell default, mono digits, 64px surface cells, 10px gaps, interactive-tile radius, ink active rule, and optional caret. |
| `CatchOtpCodeField` | `lib/core/widgets/catch_otp_code_field.dart:50` | Canonical OTP input primitive. Composes `CatchCodeInput` visuals over one hidden platform `TextField` so SMS autofill, paste, keyboard input, tests, digit-only filtering, and length limiting stay centralized. |
| `CatchNumberStepper` | `lib/core/widgets/catch_number_stepper.dart:6` | Canonical numeric +/- stepper. Renders the shared raised `CatchControlShell`, compact add/remove buttons, centered mono value, optional min/max/step clamping, and feature-specific value formatting. Used by event duration and profile height controls. |
| `CatchRangeSlider` | `lib/core/widgets/catch_range_slider.dart:7` | Canonical range slider. Wraps `RangeSlider` in the shared tickless slider theme so age/pace sliders keep discrete values without rendering dashed tick marks. Supports optional min/max endpoint labels for fixed slider bounds. |
| `CatchTopBar` | `lib/core/widgets/catch_top_bar.dart:16` | Handoff `AppBar`: compact or large screen header with shared title/subtitle/kicker text roles, back/close/none leading modes, surface/divider/gutter ownership, text/icon/trailing actions, optional tab bottom, and declarative `CatchExpandingSearch` composition. Implements `PreferredSizeWidget` for use as a Flutter `appBar`. |
| `CatchTopBarTabBar` | `lib/core/widgets/catch_top_bar.dart:133` | Adaptive top-tab primitive for use inside `CatchTopBar.bottom` or sticky sliver headers. Uses Material `TabBar` with primary indicator on Android/non-iOS platforms and `CupertinoSlidingSegmentedControl` on iOS. Implements `PreferredSizeWidget` and accepts an optional explicit `TabController` for sliver-native tab rows that are not inside a `DefaultTabController`. |
| `showCatchAdaptiveDialog<T>` | `lib/core/widgets/catch_adaptive_dialog.dart:24` | Shared platform-adaptive confirmation/dialog helper. Renders `CupertinoAlertDialog` on iOS and the handoff `CatchConfirmDialog` card on Material platforms, with typed action values plus default/destructive action metadata. |
| `showCatchConfirmDialog` / `CatchConfirmDialog<T>` | `lib/core/widgets/catch_adaptive_dialog.dart:62` | Handoff confirm-dialog API and Material card primitive. Provides default Cancel/Confirm labels, optional danger-filled commit action, centered `CatchSurface` card, 46% ink scrim, 320px max width, and tokenized card padding. |
| `showCatchDatePicker` / `showCatchTimePicker` | `lib/core/widgets/catch_adaptive_picker.dart:7` | Shared platform-adaptive date/time picker helpers. iOS renders bottom-wheel `CupertinoDatePicker` sheets with Cancel/Done toolbar; Android/non-iOS platforms keep Flutter's Material calendar and clock pickers. |
| `CatchSliverHeader` | `lib/core/widgets/catch_top_bar.dart:290` | Shared sliver header primitive. Builds a scroll-away title and optional pinned bottom row; the title translates upward as it collapses so sticky search/filter/tab rows do not visually cover it. Use `twoLineTitleHeight` for short title/subtitle headers, `wrappedTitleHeight` only when long titles need the extra space, and the shared search-row spacing constants before adding feature-local search/list gap math. Used by Run Clubs, Chats, and Profile. |
| `CatchBrowseHeader` | `lib/core/widgets/catch_browse_header.dart:9` | Self-contained browse-tab header for a scope picker, title/subtitle, optional actions, controlled provider-backed search value, and an optional parent-supplied background color in one composable module. Composes `CatchExpandingSearch` for the right-aligned app-bar search affordance. Use for Clubs/Chats-style tabs that should not split scope/search chrome into separate rail headers. |
| `CatchTopBarMenuAction<T>` | `lib/core/widgets/catch_top_bar.dart:272` | Overflow menu action for `CatchTopBar`. Delegates to `CatchActionMenu`, so top-bar overflow actions open the shared handoff `CatchMenu` panel from an `IconBtn`. |
| `CatchTopBarIconAction` | `lib/core/widgets/catch_top_bar.dart:189` | Icon-only action button for `CatchTopBar` actions. Renders a tooltip-wrapped `IconBtn`; accepts an optional explicit size for overlay rows that must align with floating controls without changing the default app-bar button size. |
| `CatchTopBarTextAction` | `lib/core/widgets/catch_top_bar.dart:222` | Text action button for `CatchTopBar` (e.g., "Save", "Done"). Delegates to `CatchTextButton` so top-bar text actions share the same token-driven text-action primitive as dialogs and inline retry links. |
| `CatchStepHeader` | `lib/core/widgets/catch_step_flow_header.dart:8` | Handoff `StepHeader`: wizard scaffold header composed from large `CatchTopBar`, optional kicker/subtitle, top-right mono step counter or custom trailing status, and a 2px progress hairline. |
| `CatchStepFlowHeader` | `lib/core/widgets/catch_step_flow_header.dart:85` | Backward-compatible zero-based wrapper over `CatchStepHeader` for existing onboarding, create-club, and create-event flows. |
| `CatchSegmentedControl<T>` | `lib/core/widgets/catch_segmented_control.dart:48` | Pill-style segmented control. Supports compact or full-width expanded layouts, icon-only, label-only, or icon+label segments, and filled or raised-surface selected styles. Used for lifecycle/workspace switching where tapping a segment changes the content below. |
| `CatchOptionGroup<T>` | `lib/core/widgets/catch_option_group.dart:16` | Design-system `OptionGroup` port: an underline selection row for tabs, lenses, and inline scope controls. Supports label or mono typography variants, optional selected-rule accent, optional trailing content, semantic selected state, tokenized gap/underline spacing, and tight-width label flex/ellipsis so floating rails do not overflow. Use when the handoff calls for `OptionGroup`; use `CatchSegmentedControl` only for pill-style segmented controls. |
| `CatchSkeleton` | `lib/core/widgets/catch_skeleton.dart:20` | Shimmer-based loading placeholder. Named constructors: `.card()`, `.text()`, `.textBlock()`, `.circle()`, `.custom()`. Uses the `shimmer` package with Catch-themed colors. |
| `CatchSkeletonList` | `lib/core/widgets/catch_skeleton.dart:127` | Convenience widget rendering a vertical column of `count` skeleton cards with configurable spacing. |
| `CatchSectionCard` | `lib/core/widgets/catch_section_card.dart:10` | Shared polished section-card primitive. Wraps a body in `CatchPanel` with a sentence-case title, optional subtitle, optional trailing context, tokenized padding, and the same restrained hierarchy used by profile-strength guidance. |
| `CatchHorizontalRail` | `lib/core/widgets/catch_horizontal_rail.dart:12` | Section with a `SectionHeader` title and a horizontally-scrolling `ListView.separated` of items. Supports optional trailing content and custom header/list padding for embedded layouts. |
| `CatchVerticalSection` | `lib/core/widgets/catch_vertical_section.dart:25` | Section with a `SectionHeader` title and a vertical `ListView.separated` of items (non-scrollable, meant for embedding in a parent scroll view). |
| `CatchLoadingIndicator` | `lib/core/widgets/catch_loading_indicator.dart:3` | Simple centered `CircularProgressIndicator` for use during async loading states. |
| `CatchStartupLoadingScreen` | `lib/core/widgets/catch_startup_loading_screen.dart:6` | Branded startup/loading scaffold used before router or host-create route data is ready. Centers the Catch icon asset on the primary fill and uses a bounded `CatchLoadingIndicator` so launch/loading states share one composition. |
| `CatchFrameworkErrorView` | `lib/core/widgets/catch_framework_error_view.dart:11` | Branded fallback view used by `ErrorWidget.builder` for Flutter framework/build errors. Shows user-safe recovery copy and keeps debug exception details behind a tokenized `CatchSurface` disclosure in debug builds rather than Material expansion chrome. |
| `CatchErrorIcon` | `lib/core/widgets/catch_error_icon.dart:7` | Shared branded error medallion used by framework and app-facing error surfaces. Owns the soft circular danger-icon treatment so new error surfaces do not repeat private icon shells. |
| `CatchErrorState` | `lib/core/widgets/catch_error_state.dart:12` | Canonical branded app-facing error content. Supports full-screen, inline, and compact modes, mapped title/message copy, optional retry, and optional secondary action. |
| `CatchErrorScaffold` | `lib/core/widgets/catch_error_state.dart:118` | Full-screen/root-tab wrapper for load failures. Keeps framework crashes separate from app data-load failures. |
| `CatchSliverErrorState` | `lib/core/widgets/catch_error_state.dart:171` | Sliver-native branded error state. Uses `SliverFillRemaining` by default and supports retry callbacks for provider invalidation. |
| `CatchInlineErrorState` | `lib/core/widgets/catch_error_state.dart:227` | Compact branded error surface for sections/cards that fail while the rest of the screen remains usable. |
| `ErrorMessageWidget` | `lib/core/widgets/async_value_widget.dart:99` | Deprecated compatibility widget. Prefer `CatchErrorState`. |
| `AsyncValueWidget<T>` | `lib/core/widgets/async_value_widget.dart:17` | Generic widget handling `AsyncValue` states: loading (defaults to `CatchLoadingIndicator`), branded error state by default, and data (custom builder). |
| `AsyncValueSliverWidget<T>` | `lib/core/widgets/async_value_widget.dart:56` | Sliver equivalent of `AsyncValueWidget`. Defaults to `CatchSliverErrorState` for errors. |
| `CatchFormFieldLabel` | `lib/core/widgets/catch_form_field_label.dart:5` | Styled form field label with an optional badge (e.g., "Optional"). |
| `CatchControlShell` | `lib/core/widgets/catch_control_shell.dart:50` | Shared single-line control shell for fields, select triggers, picker tiles, map pin tiles, and steppers. Owns the fill, border, focus ring, radius, and size metrics. Use `floating` for overlay chrome, `compact` for dense header/search controls, and `md` for regular form controls. |
| `_OptionalBadge` | `lib/core/widgets/catch_form_field_label.dart:49` | Small "(optional)" badge rendered next to form labels. |
| `CatchChip` | `lib/core/widgets/catch_chip.dart:6` | Handoff `Chip` fact/filter pill. Supports resting surface fill, selected transparent fill with a 1.5px ink rule, optional activity tint/ink colors, tap behavior, and an optional remove button. Used in `ChipField` and independently for static or interactive fact tags. |
| `_RemoveButton` | `lib/core/widgets/catch_chip.dart:104` | Small X button rendered inside `CatchChip` when removable. |
| `SelectChip` | `lib/core/widgets/select_chip.dart:8` | Handoff tactile selectable pill for questionnaire answers, mission choices, and choosy filters. Supports accent selected fill, active glow/scale, pressed scale-down, selected semantics, and tokenized pill surface chrome. |
| `ActivityArt` | `lib/core/widgets/activity_art.dart:10` | Handoff generated activity-art surface. Resolves activity pigment and glyph through `ActivityPalette`, renders the gradient, screen-print texture, faint motif glyph, optional dim layer, radius/height controls, and overlay child slot. |
| `ActivityAvatar` | `lib/core/widgets/activity_avatar.dart:10` | Handoff activity-register avatar for people shown in activity-grounded surfaces. Resolves activity pigment through `ActivityPalette`, renders mono initials over an activity gradient with screen-print texture, and supports explicit size, selected/live ring, and dim veil states. |
| `ActivityChip` | `lib/core/widgets/activity_chip.dart:8` | Handoff activity tag for typed `ActivityKind` values. Resolves label/glyph/pigment through `ActivityPalette`, supports soft and primary registers, optional label override, and optional tap semantics. Use for registry-backed activity labels instead of feature-local colored chip helpers. |
| `ActivityMapPin` | `lib/core/widgets/activity_map_pin.dart:8` | Handoff map pin for activity-colored map marks. Resolves pigment through `ActivityPalette`, supports resting/selected sizing, optional selected flag text, and the subtle pin shadow used on map canvases. |
| `DistanceRing` | `lib/core/widgets/distance_ring.dart:7` | Handoff map radius ring for static map canvases and previews. Renders a 170px default circular ink ring with 1.2px stroke and an optional tappable mono label pill anchored to the top edge. |
| `CatchBadge` | `lib/core/widgets/catch_badge.dart:10` | Handoff `Badge` status pill used for spots-left indicators, distance/pace pills, event requirement chips, status labels, compact metadata, and action-column outcomes. Supports functional tones including `gold`, `size.action` 33px alignment, optional leading icons, optional uppercase labels, and activity-accent tinting. |
| `PrivacyBadge` | `lib/core/widgets/privacy_badge.dart:10` | Quiet outlined handoff privacy pill for visibility hints. Supports `Private to you`, `Catch private`, and `Host can see` modes with lock/eye glyphs, transparent `CatchSurface` chrome, and the shared mono badge text role. |
| `CatchCornerSash` | `lib/core/widgets/catch_corner_sash.dart:10` | Single status sash for event/club hero cards when one dominant state should read before supporting metadata. Uses token palettes, optional icon, and asymmetric pill corners instead of competing chip clusters. |
| `CatchCountPill` | `lib/core/widgets/catch_count_pill.dart:12` | Handoff CountPill control for floating Explore affordances. Renders a raised pill with optional icon, optional mono label, optional active-count badge, shared surface/border tokens, and explicit semantic labels. Use for map/list toggles and compact filter entry points instead of feature-local floating pill decorations. |
| `CatchTabDock<T>` | `lib/core/widgets/catch_tab_dock.dart:25` | Handoff `TabDock`: bottom navigation dock with translucent blur surface, top hairline, uppercase mono labels, selected filled glyph, idle ink3 glyphs, typed tab IDs, and optional per-tab badges. Used by non-iOS `AppShellNavigationBar`. |
| `CatchMetaDotRow` | `lib/core/widgets/catch_meta_row.dart:13` | Inline dot-separated metadata row for event/club cards. Keeps icon/text entries and optional strong trailing meta in one line with ellipsis behavior, so cards can show time, place, distance, and status without bolting on multiple badges. |
| `IconBtn` | `lib/core/widgets/icon_btn.dart:5` | Handoff `IconButton`: circular glyph target with 44px default, 40px top-bar `navSize`, bordered / float / plain variants, active accent tinting, disabled opacity, and legacy child/custom-background escape hatches for existing app surfaces. |
| `BottomCTA` | `lib/core/widgets/bottom_cta.dart:38` | Sticky bottom action footer. Renders a full-width `CatchButton` in a surface-colored bar separated from content by a hairline divider, with optional leading content, optional activity button accent, optional dark/custom footer colors, and bottom safe-area padding. |
| `CatchBottomSheetScaffold` | `lib/core/widgets/catch_bottom_sheet.dart:8` | Handoff `Sheet`: surface bottom-sheet panel with overlay shadow, grabber toggle, plain title/subtitle header, branded glyph-tile header, optional badge/trailing slot, keyboard-safe body padding, content, and optional action slot. |
| `RichShareCardSheet` | `lib/core/widgets/rich_share_card_sheet.dart:20` | Shared visual-card share sheet. Renders a keyboard-safe bottom sheet with `BottomSheetGrabber`, a bounded `RepaintBoundary` card preview, footnote copy, and a full-width platform-share `CatchButton` that exports the captured card through `ExternalShareController`. `RichShareCardSheetKeys.cardPreview` and `.shareButton` are the stable hooks for tests and future automation. |
| `CatchDraggableSheetShell` | `lib/core/widgets/catch_draggable_sheet_shell.dart:6` | Shared shell for persistent `DraggableScrollableSheet` surfaces. Owns the rounded top edge, border, optional raised shadow, and grabber slot while leaving snap state and scroll content to feature screens. Callers can tune handle opacity and top radius for sheet reveal animations without forking the shell. |
| `CatchViewportCurveFrame` | `lib/core/widgets/catch_viewport_curve_frame.dart:11` | Device-aware top-frame clipper for immersive headers. It keeps caller-provided base padding, derives the active viewport's top corner radius from `MediaQuery` safe-area/size, and clips the inset child with Flutter's native `RSuperellipse`/save-layer antialiasing so media follows rounded phone glass with a continuous curve instead of becoming a jagged rectangular inset. |
| `CatchCelebrationScreen` | `lib/core/celebration/catch_celebration_screen.dart:37` | Shared full-screen celebration surface for high-emotion completion moments. Feature screens provide moment kind, copy, details, optional supplemental children, and primary/secondary actions; the primitive dispatches celebration effects once after first frame. Solid-white primary actions use `CatchButtonVariant.light` instead of per-screen white/foreground overrides. |
| `CelebrationEffectsController` | `lib/core/celebration/celebration_effects_controller.dart:10` | Central haptic/sound boundary for celebration moments. Currently dispatches haptics by `CelebrationMomentKind`; future sound work should be added here instead of directly in feature widgets. |
| `CatchEmptyState` | `lib/core/widgets/catch_empty_state.dart:9` | Handoff `EmptyState`: centered cardless placeholder with optional quiet 34px ink3 glyph, section-title headline, body-small message, 24px horizontal padding, and optional action. It still supports explicit surface/bubble presentation and compact inline layout for embedded contexts, and expands to bounded parent widths before centering content. |
| `CatchDaySectionHeader` | `lib/core/widgets/catch_day_section_header.dart:11` | Sticky day-section header for chronological feeds. Use `CatchDaySectionHeaderDelegate` when the parent owns a flat `CustomScrollView` and pinned day headers are needed; the delegate binds the child height to its sliver extent so pinned geometry stays valid under constrained sheets. |
| `CatchStatusBar` | `lib/core/widgets/catch_status_bar.dart:8` | Handoff `StatusBar`: phone-frame iOS status row with bold mono time, Phosphor fill signal/wifi/battery glyphs, light/dark tone support, and optional surface fill for mock frames and design previews. |
| `CatchEventTicketCard` | `lib/core/widgets/catch_event_activity_cards.dart:17` | Ticket-style production event card backed by `EventActivityVisualSpec`. Used by Dashboard recommendations, Explore selected non-spotlight map pins, and the Explore nearby map rail so each event type shares the same activity-coded backdrop, shared `EventClockMark`, shared `EventStatusPill`, centralized capacity copy, and optional full-card Hero transition into event detail. |
| `CatchEventSpotlightCard` | `lib/core/widgets/catch_event_activity_cards.dart:133` | Large activity-art production event card for featured Explore items and selected map pins only when the selected pin is the feed's actual featured event. Reuses `EventActivityBackdrop`, supports optional visual or full-card Hero tags for card-to-detail transitions, and keeps non-open states in the kicker slot. |
| `CatchEventThumbnail` | `lib/core/widgets/catch_event_thumbnail.dart:10` | Shared event image primitive. Renders uploaded photos by default, falls back to `EventActivityBackdrop`, supports `preferActivityArtwork` for surfaces that should stay color-coded by event type even when a photo exists, and exposes fallback icon/pattern tuning for large hero bands. |
| `GradedImage` / `CatchGrade` | `lib/core/widgets/graded_image.dart:21` | Non-destructive display-time photo grade. Applies the shared brightness-aware matte duotone through color filters at render time, leaving uploaded images untouched while keeping mixed UGC and generated activity art inside one editorial visual family. |
| `CatchPageBody` / `CatchScreenBody` / `CatchSectionStack` / `CatchSectionList` / `CatchDesignSection` / `CatchDetailSliverSectionList` | `lib/core/widgets/catch_section_layout.dart:9` | Semantic body and section composition primitives. `CatchScreenBody` maps the handoff scrolling body with `screenPx` gutter, `pt`/`pb` overrides, full-bleed gutter opt-out, and optional non-scroll mode; `CatchSectionStack` maps the handoff `SectionStack` gutter and defaults to no inserted section gap; `CatchDesignSection` maps the handoff `Section` contract with kicker/count text, optional lead activity accent, 12 px body gap, and the 24 px hairline separator rhythm; `CatchDetailSliverSectionList` provides sliver-native page gutters with the same section-owned rhythm by default. |
| `EventActivityVisualSpec` / `EventActivityBackdrop` | `lib/events/presentation/event_activity_visuals.dart:17` | Mutable presentation schema for `ActivityKind` imagery. Centralizes activity label, icon, gradient palette, pattern, and browse-order choices so Explore cards, spotlight cards, thumbnails, browse tiles, and event detail headers do not fork color decisions. |
| `EventTicketPerforatedDivider` / `EventTicketShapeClipper` | `lib/events/presentation/widgets/event_ticket_surface.dart:17` | Shared event-ticket transition primitives. Own the horizontal perforation, ticket notch constants, ticket clipper, and full-card Hero wrapper used by ticket cards, spotlight cards, date-rail cards, and ticket-mode event detail headers. |
| `EventCapacityPresenter` | `lib/events/presentation/widgets/event_tiles/event_capacity_presenter.dart:4` | Shared event-capacity display helper. Owns signed-up/spots/progress values plus "going · left/full", activity summary, attendee-confirmed, and join-CTA availability copy so cards and CTAs do not fork booking language. |
| `EventActivityStamp` / `EventClockMark` / `EventCapacityProgress` / `EventStatusPill` | `lib/events/presentation/widgets/event_tiles/event_visual_atoms.dart:8` | Shared visual atoms for activity-coded event rows and tickets. Use these for circular activity marks, analog time marks, capacity progress bars, and compact status pills before adding card-local painters or badges. |
| `ChipField<T>` | `lib/core/widgets/chip_field.dart:14` | Multi/single-select chip selector wrapping `FormField<Set<T>>`. Uses `CatchChip` children inside a `Wrap`, lets callers attach semantic chip keys, keeps the parent-owned `selected` set, supports disabled state for pending mutation sheets, and shows a leading check icon on selected chips only in multi-select mode. |
| `DetailRow` | `lib/core/widgets/detail_row.dart:5` | Compact label/value row for detail and payment-history sheets. Uses supporting text roles, fixed label lane, and expanded value copy so dense read-only metadata aligns without a new local table layout. |
| `InfoRow` | `lib/core/widgets/info_row.dart:9` | Handoff on-surface list row. Supports inline label/value rows, stacked caption/value rows, add and danger treatments, optional chevron or toggle trailing controls, and quiet inset dividers. |
| `InfoGroup` | `lib/core/widgets/info_group.dart:7` | Handoff on-surface group of `InfoRow`s. Renders an optional mono kicker, full-strength group separator/air for non-first groups, and injects row dividers after the first row. |
| `ErrorBanner` | `lib/core/widgets/error_banner.dart:12` | Styled inline error banner for mutation/async errors within page content. Optionally includes a "Try again" button. |
| `showCatchErrorSnackBar` | `lib/core/widgets/catch_error_snackbar.dart:4` | Snackbar helper for transient action failures. Maps errors through `appErrorMessage` before display. |
| `CatchNoticeHost` | `lib/core/widgets/catch_notice.dart:84` | App-wide overlay host for ambient notices. Renders persistent notices such as offline state below the safe area and queues ephemeral event notices through `appNoticeControllerProvider`. |
| `CatchNotice` | `lib/core/widgets/catch_notice.dart:184` | Reusable floating notice primitive with tone, icon, optional message, optional action, and optional dismiss control. Use for ambient app status/events, not inline form errors. |
| `SectionHeader` | `lib/core/widgets/section_header.dart:4` | Lightweight section header with sentence-case styling by default, optional heavy weight, and opt-in uppercase for intentional metadata/eyebrow labels. Prefer `CatchSectionCard` for carded content sections. |
| `StatColumn` | `lib/core/widgets/stat_column.dart:5` | Vertical stat display: value on top, label below. Used by profile and host surfaces that need local surface ownership; detail-page rails should use `CatchMetricStrip`. |
| `BottomSheetGrabber` | `lib/core/widgets/bottom_sheet_grabber.dart:4` | Small drag handle/grabber bar shown at the top of bottom sheets and draggable sheet shells. Supports caller-owned width/height while keeping tokenized color and radius. |
| `PersonRow` | `lib/core/widgets/person_row.dart:77` | Multipurpose person row. In chat-thread mode (when `lastMessage` is non-null), renders name, timestamp, context line, last message, and unread badge. In roster mode, renders name, meta line, context line, and an optional trailing widget. Used in chat inbox, rosters, waitlists, and catches previews. |
| `_ChatLayout` | `lib/core/widgets/person_row.dart:136` | Internal chat-thread layout for `PersonRow` — name + timestamp row, run-context row, last-message + unread-badge row. |
| `_RosterLayout` | `lib/core/widgets/person_row.dart:228` | Internal roster layout for `PersonRow` — name + meta line + context line (run icon). |
| `PersonAvatar` | `lib/core/widgets/person_avatar.dart:49` | Shared person/host avatar with deterministic gradient fallback derived from name hash. Supports image URL, colored border ring (for match state or stacking), online status dot, obscured/blurred rendering for privacy-preserving hype avatars, and `PersonAvatarShape.circle` / `.square` so inbox host inquiries can use the handoff's rounded-square treatment without forking the avatar widget. Named constructor `PersonAvatar.count` shows a "+N" overflow bubble. |
| `PersonAvatarStack` | `lib/core/widgets/person_avatar.dart:218` | Shared handoff `AvatarStack`: overlapping avatars with photo or initials fallback, optional activity-tinted veiled placeholders for hidden rosters, quiet raised `+N` overflow count, configurable size/overlap/ring, and optional obscured photo rendering for legacy surfaces. Use this instead of feature-local stacked circular-avatar widgets. |
| `_GradientPlaceholder` | `lib/core/widgets/person_avatar.dart:162` | Deterministic gradient placeholder for avatars without a photo. Picks from 12 palettes based on a hash of the name. |
| `ResponsiveBuilder` | `lib/core/responsive/responsive_builder.dart:22` | Thin wrapper around `LayoutBuilder` that maps available width to `ScreenSize` (compact/medium/expanded) and calls the appropriate builder. Falls back gracefully when tablet/desktop builders are absent. |
| `_ButtonLabel` | `lib/core/widgets/catch_button.dart:141` | Internal label+icon row for `CatchButton`. |
| `_LoadingDots` | `lib/core/widgets/catch_button.dart:193` | Three animated dots shown during `CatchButton`'s loading state. |
| `SettingsRow` | `lib/core/widgets/settings_row.dart:26` | Handoff `InfoRow`-style settings row: on-surface row with 20px icon lane, optional inset hairline divider, `infoRowTitle` label, optional mono right-hand value, optional trailing widget, chevron only when explicitly navigational, and functional-danger treatment for destructive rows. |
| `CatchToggle` | `lib/core/widgets/catch_toggle.dart:8` | Handoff settings toggle primitive. Renders a 46x28 pill track, primary fill when on, line2 fill when off, a surface knob, semantics toggled state, disabled opacity, and emits the next boolean value on tap. Use in settings rows instead of raw `Switch` when matching the design-system Settings templates. |
| `ProfileInfoTile` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:9` | Profile row primitive with icon, label, value/valueEditor slot, animated row-height/value swap, consistent label/value spacing, a fixed-width animated chevron slot, and stable collapsed/expanded row geometry. |
| `ProfileInlineDisclosure` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:113` | Animated profile inline-editor shell that pairs a row header with a drawer body. Use for row-owned edit interactions instead of manually inserting/removing editor widgets. |
| `ProfileInlineAnimatedBody` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:137` | Animated open/close body used by profile disclosures, prompt-card editors, and legacy `ProfileInfoEntry.editor` bodies. Keeps body width stable while height/fade animates with Catch motion tokens. |

---

## Dashboard

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `DashboardScreen` | `lib/dashboard/presentation/dashboard_screen.dart:21` | Home tab. Watches the user's profile, active club memberships, signed-up events, and Home unread notification count only while Home is active. Renders one `CustomScrollView` with a scroll-away greeting/empty header, top-right Notifications bell, red unread badge, and dashboard sliver body; it no longer owns a route-local tab controller or Dashboard/Activity tab row. |
| `DashboardFull` | `lib/dashboard/presentation/widgets/dashboard_full.dart:21` | Standalone full-dashboard wrapper used by focused tests/non-tab embedding. Takes explicit `followedClubIds` from the membership-edge seam and renders the full dashboard header plus `DashboardFullSliverBody`. The header avatar is a Profile-tab button and must use thumbnail-scale profile imagery through `UserProfile.primaryPhotoThumbnailUrl`. |
| `DashboardFullSliverBody` | `lib/dashboard/presentation/widgets/dashboard_full.dart:84` | Sliver body for the populated Home dashboard. Uses `CatchSectionStack` for the handoff rhythm and orders the body as `EventFocusRail`, `StrideCard`, `QuickActions`, the personal `DashboardClubsRail` when available, and the "Recommended for you" rail. It joins club names for committed events through `clubNameLookupProvider`; notifications are intentionally routed to the dedicated Notifications screen. |
| `EventFocusRail` | `lib/dashboard/presentation/widgets/event_focus_rail.dart:33` | Consolidated Home rail for attendee committed-event actions. Builds full-width snapping `EventActionCard` pages for upcoming, check-in, catch-window, and review states; stacks actions such as View event, Check in, Directions, Add to calendar, Start catching, and Write review so labels do not clip on narrow screens. |
| `DashboardClubsRail` | `lib/dashboard/presentation/widgets/dashboard_clubs_rail.dart:10` | Home-owned personal club rail. Resolves followed club IDs through `watchClubProvider`, reuses `ClubAvatarRail` without create/directory chrome, and stays hidden when no club data is available so Explore can keep club recommendations discovery-oriented instead of user-owned. |
| `ActivityScreen` | `lib/dashboard/presentation/activity_screen.dart:19` | Route-level Activity screen opened from the Home header bell. Uses `CatchTopBar(title: 'Activity')`, keeps the bottom nav visible by living under the Home shell branch, renders `ActivitySection`, and owns the manual top-bar `Mark all read` action through `ActivityController.markAllRead`. |
| `ActivitySection` | `lib/dashboard/presentation/widgets/activity_section.dart:34` | Reusable notification body for the Activity route. Reads backend-owned notifications, keeps loading/empty/error states branded, and groups visible notifications by Today, Yesterday, This week, and Earlier through compact top-hairline day groups; signed-up event rows are intentionally not part of this handoff screen. |
| `Recommendations` | `lib/dashboard/presentation/widgets/recommendations.dart:7` | Intrinsic-height "Recommended for you" horizontal rail of `RecommendCard` widgets for recommended events from the user's followed clubs. |
| `RecommendCard` | `lib/dashboard/presentation/widgets/recommend_card.dart:8` | Dashboard recommended-event adapter around `CatchEventTicketCard`. It uses the shared activity-art ticket shape, keeps the recommender reason in the media label, and preserves price, title, club, date/time, meeting point, distance/pace, booked count, and remaining spots. |
| `StrideCard` | `lib/dashboard/presentation/widgets/stride_card.dart:8` | Dashboard card showing stride (weekly run count) stats with bar columns and a "Keep it up" message. |
| `StrideBarColumn` | `lib/dashboard/presentation/widgets/stride_card.dart:105` | Single bar column for the stride card — day label and filled bar. |
| `QuickActions` | `lib/dashboard/presentation/widgets/quick_actions.dart:8` | Responsive dashboard quick-action grid for Calendar and Saved events. Spatial discovery lives under Clubs, so the dashboard no longer exposes Map view. Avoids hardcoded tile heights so labels can wrap without clipping on narrow screens. |
| `DashboardEmpty` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:10` | Standalone empty-dashboard wrapper used by focused tests/non-tab embedding. Renders the empty dashboard header plus `DashboardEmptySliverBody`. |
| `DashboardEmptySliverBody` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:56` | Sliver body for the empty Home dashboard. Uses `CatchSectionStack` with the cover-story `EmptyHeroCard` followed by a `CatchDesignSection` journey for "How Catch works"; weekly activity, quick actions, and personal clubs stay out of the first-run composition. |
| `EmptyHeroCard` | `lib/dashboard/presentation/widgets/empty_hero_card.dart:10` | Cover-story hero shown on the empty dashboard prompting the user to book their first event. Its copy matches the handoff first-run story, omits the old decorative glyph, and uses `CatchButtonVariant.light` so the CTA stays legible in dark mode. |

### Sliver Helpers

| Helper | File | Purpose |
|---|---|---|
| `DashboardSliverHeader` | `lib/dashboard/presentation/widgets/dashboard_sliver_header.dart:7` | Dashboard-specific wrapper around `CatchSliverHeader`. Keeps the home greeting/onboarding header visually consistent while allowing it to scroll away with the dashboard content, and exposes trailing action slots such as the Notifications bell. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_DashboardLoadingScreen` | `lib/dashboard/presentation/dashboard_screen.dart:220` | Loading scaffold for Home while profile/booked-run data resolves. |
| `_DashboardErrorScreen` | `lib/dashboard/presentation/dashboard_screen.dart:229` | Branded error scaffold for Home profile/booked-run load failures. |
| `_DashboardSectionStateCard` | `lib/dashboard/presentation/widgets/dashboard_full.dart:161` | Inline loading/error card for a dashboard section (e.g., "Loading your recent runs..."). |
| `_NotificationDayGroups` | `lib/dashboard/presentation/widgets/activity_section.dart:112` | Notifications screen day-group wrapper. Matches the handoff's tight Activity composition with first group flush, later groups separated by an 8px offset, top hairline, 18px inset, uppercase kicker, then `NotificationRow` children. |
| `NotificationRow` | `lib/dashboard/presentation/widgets/activity_section.dart:158` | Handoff-style row for backend-owned activity notifications. It exposes the design contract (`type`, `title`, `time`, `body`, `unread`, `divider`, optional tap), renders on-surface with a type-colored glyph, optional inset divider, relative time, unread title/time color, and optional route navigation, and deliberately does not render card fills, badges, or icon chips. |
| `_NotificationGroup` | `lib/dashboard/presentation/widgets/activity_section.dart:227` | Small adapter that renders a group of notification rows and injects row dividers after the first item. |
| `_ActivityStateLabel` | `lib/dashboard/presentation/widgets/activity_section.dart:422` | Status label shown for the loading activity state. |

---

## Host Tools

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `HostEventToolsCarousel` | `lib/hosts/presentation/widgets/host_event_tools.dart:22` | Shared full-width host-event carousel for unbounded hosted events, including closed past hosted events retained for host operations. It renders self-contained cards with swipe snapping and no external section header, event-count badge, or footer chrome. |
| `_HostEventsScaffold` | `lib/hosts/presentation/host_operations_screen.dart:588` | Host Events selected-club operations shell. Owns only the transient selected club index, renders the selected club name in the host AppBar, hides the switcher for a single club, and supplies the selected club to the flattened operations body. |
| `_HostClubsScaffold` | `lib/hosts/presentation/host_operations_screen.dart:662` | Host Clubs selected-club operations shell. Owns transient selected club and Edit/Preview tab state, renders the selected club in the host AppBar, hides the switcher for a single club, and keeps owner-only edit/payout/team mutations out of co-host selections. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_HostClubTabRail` | `lib/hosts/presentation/host_operations_screen.dart:743` | Host Clubs Edit / Preview rail. Reuses `CatchOptionGroup` in the AppBar bottom slot so the host clubs screen follows the handoff tab composition without custom segmented chrome. |
| `_HostOperationsTopBar` | `lib/hosts/presentation/host_operations_screen.dart:776` | Host app top bar used by Events and Clubs. Wraps `CatchTopBar` with a mono kicker, title, optional shared action slots, and optional bottom content so host tabs can expose club pickers and tab rails without custom chrome. |
| `_HostMetaRow` | `lib/hosts/presentation/host_operations_screen.dart:897` | Host club metadata row: uppercase area/location, role badge, and activity chip. Keeps host tab color usage tied to activity meaning. |
| `_HostClubProfileCard` | `lib/hosts/presentation/host_operations_screen.dart:972` | Host Clubs Edit tab body. Shows selected club metadata plus Identity, Contact, Event defaults, Public profile, Payouts, and Host team sections using `SettingsRow`, `HostPaymentAccountCard`, and `HostTeamManagementSection`; owner-only rows route to the edit-club flow. |
| `_HostClubPreviewPane` | `lib/hosts/presentation/host_operations_screen.dart:1131` | Interim Host Clubs Preview tab body. Shows the selected club description and a route-backed public preview action until the public club preview components are made embeddable inside the host tab. |
| `_HostEventRow` | `lib/hosts/presentation/host_operations_screen.dart:1177` | Flattened host event row. Uses `SettingsRow` with date icon, event title, time value, divider, and chevron tap target to route to Host Manage. |
| `HostEventToolsPageIndicator` | `lib/hosts/presentation/widgets/host_event_tools.dart:164` | In-card hosted-event position indicator. Shows `N of total` plus a bounded progress rail so unbounded hosted-event counts do not grow the rendered indicator. |
| `HostEventToolCard` | `lib/hosts/presentation/widgets/host_event_tools.dart:208` | Shared operational card for one hosted event. Adapts host event lifecycle, bounded in-card progress, date/time, meet point, booked/waitlist counts, and one contextual CTA into `EventActionCard` using the host palette. |
| `HostToolPalette` | `lib/hosts/presentation/widgets/host_event_tools.dart:304` | Token-backed host-tool color helper for default host panels and attendance states. Use this instead of local orange-tinted containers for host chrome. |
| `HostClubManagementPanel` | `lib/hosts/presentation/widgets/host_club_tools.dart:15` | Reusable combined host-club tools panel for surfaces that intentionally need Add event, Edit club, and upcoming booked/waitlist/base-revenue stats in one section. Public `ClubDetailBody` no longer embeds this panel; Host app tab surfaces own those actions. |
| `HostStatChip` | `lib/hosts/presentation/widgets/host_club_tools.dart:161` | Single reusable host stat chip used by the consolidated club host management panel and host event management stats. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `HostOperationsHomeScreen` | `lib/hosts/presentation/host_operations_screen.dart:35` | Host app Events tab. Watches clubs the signed-in host can operate, sorts owned clubs before hosted clubs, and delegates the selected-club operations shell to `_HostEventsScaffold`. |
| `HostClubsScreen` | `lib/hosts/presentation/host_operations_screen.dart:57` | Host app Clubs tab. Watches clubs the signed-in host can operate and delegates selected-club Edit/Preview composition to `_HostClubsScaffold` instead of rendering every operated club in one grouped scroll. |
| `HostAccountScreen` | `lib/hosts/presentation/host_operations_screen.dart:85` | Host app Account tab for professional host identity and sign-out. Active profiles render handoff Edit / Preview info-row sections and open `_HostProfileEditorSheet` for profile edits without leaving Account. |
| `HostTeamManagementSection` | `lib/hosts/presentation/widgets/host_team_management_section.dart:22` | Host-owned club-team editor rendered from the Host app Clubs tab. It lists host profiles and runs add, remove, and transfer mutations through `HostTeamManagementController`. |
| `HostEventAttendancePanel` | `lib/hosts/presentation/widgets/host_event_attendance_panel.dart:34` | Shared host attendance panel. Watches `AttendanceSheetViewModel`, renders loading/error/event-not-found outer states, and delegates zero-participant, filtered-empty, profile-backed roster rows, and attendance toggle mutations to the lifecycle-specific Host Manage board/table surfaces. Lifecycle participation counts are compact filter tiles, not a separate stat strip, so Setup, Live, and Report each expose the statuses hosts need without repeating top-level metrics. Report mode exports Revenue and Ops CSV files through shared external sharing; revenue uses roster-visible payment ids plus event-price estimates until a backend host payment-report callable exposes actual settled/refunded amounts. |
| `HostCreateClubScreen` | `lib/hosts/presentation/club_management/host_create_club_screen.dart:10` | Host route-facing create-club entry. Delegates to the host-owned create/edit club wizard while keeping the router free of form implementation imports. |
| `HostEditClubRouteScreen` | `lib/hosts/presentation/club_management/host_create_club_screen.dart:17` | Host route-facing edit-club entry. Resolves a club by id, handles loading/not-found/error states, and delegates to the host-owned create/edit club wizard. |
| `HostCreateEventRouteScreen` | `lib/hosts/presentation/event_management/host_create_event_screen.dart:10` | Host route-facing create-event entry. Resolves the host-owned club and delegates to the host-owned create-event wizard. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_HostProfileEditorSheet` | `lib/hosts/presentation/host_operations_screen.dart:384` | Route-local Host Account editor sheet. Reuses the professional profile field set and saves display name, role title, and bio without pushing the full-screen editor route. |
| `HostProfileScreen` | `lib/hosts/presentation/host_operations_screen.dart:490` | Direct professional host profile editor route kept for compatibility. Saves display name, role title, and bio through `HostProfileRepository.saveHostProfile` so host identity management stays separate from dating-profile editing. |

---

## Swipes

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeScreen` | `lib/swipes/presentation/swipe_screen.dart:22` | Catches decision screen. Watches the swipe queue provider, renders the first candidate as a full `ProfileSurface`, submits section likes/comments through `SwipeQueueNotifier.swipe`, and exposes a floating lower-left pass X instead of deck gestures. Empty-state attendance copy uses the viewer's `EventParticipation` edge instead of compatibility arrays, and stuck queue loads now surface a retryable `Catches unavailable` error instead of spinning forever. |
| `FiltersScreen` | `lib/swipes/presentation/filters_screen.dart:23` | Swipe filters screen. Owns local age and interested-in draft state, uses `CatchTopBar`, handoff top body inset, `CatchRangeSlider` for the 18-60+ age range, en-dash range copy, handoff `SelectChip` gender choices, and a full-width `CatchButton` in `CatchBottomDock`; saves through `FiltersController.saveFiltersMutation` and pops on successful save. Pace range and run type are intentionally not exposed as filters. |
| `EventRecapScreen` | `lib/swipes/presentation/event_recap_screen.dart:27` | Post-event recap screen showing event details and a checked-in attendee vibe grid. Watches `EventRecapViewModel`, uses keyed vibe tiles, `CatchSurface` for the recap hero, and `CatchEmptyState` for an empty attendee roster. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeHubScreen` | `lib/swipes/presentation/swipe_hub_screen.dart:21` | "Catches" tab. Gates screen-owned streams while the retained tab branch is inactive, lists edge-backed attended events with open catch windows, uses leaf widgets to read theme tokens locally, shows a `CatchSurface` intro card with projected checked-in count for the featured event, and lists active events with `AttendedEventTile` widgets. |
| `ScrollableProfile` | `lib/swipes/presentation/widgets/scrollable_profile.dart:19` | Full-length scrollable profile body used inside `ProfileSurface`. Keeps the shared rendering path identical across Catches, Profile Preview, and Public Profile, renders the hero photo first, then contextual profile insights, profile prompts, one canonical `RUN PROFILE` running identity card, detail chips, inset photos, and lifestyle. Its internal vertical scroll view is non-primary, can accept an explicit controller and route-provided physics when embedded in a sliver route, and can report leading overscroll to a parent route for collapsible-header coordination. |
| `ProfileSurface` | `lib/swipes/presentation/profile_surface.dart:9` | Shared cardless public profile renderer. Maps `ProfileCardContent` into the handoff-aligned `CatchProfileView`, passes optional viewer/event context for compatibility insights, renders passive compatibility and running-identity labels as `CatchBadge` metadata, applies the social-run activity pigment to the hero fallback and Running Rhythm block, and mode-gates reaction controls so Catches can show section like/comment affordances while Preview/Public Profile remain passive. |
| `EventRecapViewModel` | `lib/swipes/presentation/event_recap_view_model.dart:11` | Recap data seam. Combines the event, current uid, and `eventParticipations` to derive checked-in count and the attendee IDs shown in the vibe grid without reading compatibility arrays. |
| `_VibeTile` | `lib/swipes/presentation/run_recap_screen.dart:236` | Keyed attendee tile on the recap screen. Fetches its public profile, exposes tooltip/semantic selected state, and toggles local recap selection. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CatchesHubContent` | `lib/swipes/presentation/swipe_hub_screen.dart:56` | Content body for the catches hub: header, intro card for the featured event, and list of active catch windows. |
| `_CatchesHeader` | `lib/swipes/presentation/swipe_hub_screen.dart:116` | Header row for the catches hub: "CATCHES" section header + "After the event" title + heart icon. |
| `_CatchesIntroCard` | `lib/swipes/presentation/swipe_hub_screen.dart:151` | Gradient hero card promoting the 24-hour catch window with countdown timer, roster count, and "Start catching" CTA. The parent `CatchSurface` owns tap handling; the solid-white CTA is a non-interactive `CatchButtonVariant.light` display label so accessibility and color pairing stay correct. |
| `_PillStat` | `lib/swipes/presentation/swipe_hub_screen.dart:255` | Semi-transparent stat pill inside the catches intro card — label + value. |
| `_CatchesEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:296` | Empty state when no active catch windows exist. Prompts the user to book an event. |
| `CardPhotoSection` | `lib/swipes/presentation/widgets/card_photo_section.dart:3` | Photo section inside the shared `ProfileSurface`. The hero photo may be edge-to-edge with the dark gradient and name overlay; additional photos should be inset with consistent margins, rounded corners, and spacing. Shows a branded "Photo coming soon" fallback when the user has no usable image. |
| `NameOverlay` | `lib/swipes/presentation/widgets/name_overlay.dart:7` | Hero overlay for public display name, age, and optional city. Keep relationship goal, distance, and runner metadata out of the hero and in lower profile sections. |
| `GoalPill` | `lib/swipes/presentation/widgets/name_overlay.dart:61` | Legacy/specialized goal chip styling retained for profile-card contexts that need a pill, but the default shared card now renders relationship goal as a detail chip rather than hero overlay text. |
| `ProfileCardPalette` | `lib/swipes/presentation/widgets/profile_card_style.dart:4` | Local palette helper for the shared public profile surface. It adapts accent, border, chip, fallback, and shadow colors to the active app light/dark theme while keeping sections coherent across Catches, Preview, and Public Profile. |
| `ProfileAttributesSection` | `lib/swipes/presentation/widgets/profile_attributes_section.dart:6` | Section of detail chips on the shared profile surface. Relationship goal lives here; city stays on the hero overlay, and distance appears here only when current/profile locations are available. |
| `ProfileSectionCard` | `lib/swipes/presentation/widgets/profile_section_card.dart:8` | Reusable section card wrapper for profile detail sections. Uses `ProfileCardPalette` rather than raw app surface colors, sentence-case `labelL` headers, and compact tokenized padding so sections stay coherent inside the shared public profile surface. |
| `ProfileBioSection` | `lib/swipes/presentation/widgets/profile_bio_section.dart:6` | Prompt section on the shared surface. Uses the prompt text as a sentence-case section label and restrained title typography for answers so long prompt copy stays readable before running stats. |
| `ProfileMatchSignalsSection` | `lib/swipes/presentation/widgets/profile_match_signals_section.dart:9` | Contextual signals section near the top of the shared profile surface. Shows profile confidence pills and viewer-aware "Why you might click" reasons, and exposes the section as one reactionable `compatibility` target. |
| `ProfileLifestyleSection` | `lib/swipes/presentation/widgets/profile_lifestyle_section.dart:6` | Lifestyle section (occupation, education, drinking, smoking, etc.). |
| `ProfileInfoChip` | `lib/swipes/presentation/widgets/profile_info_chip.dart:3` | Single compact info chip on the profile surface — muted icon + label. |
| `CatchesPassButton` | `lib/swipes/presentation/widgets/catches_pass_button.dart:5` | Floating lower-left pass button used on the Catches decision screen after removing generic deck action buttons. Uses the shared pass key, tooltip, and semantic label. |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart:7` | Empty state shown when the swipe queue is exhausted. |
| `AttendedEventTile` | `lib/swipes/presentation/widgets/attended_event_tile.dart:14` | Row tile for an attended event in the catches hub list: event title, date, projected checked-in count, recap CTA, and swipe badge. |
| `_RunningIdentityCard` | `lib/swipes/presentation/widgets/scrollable_profile.dart:72` | Canonical dark `RUN PROFILE` summary card inside `ScrollableProfile`. Retain this as the single first-class running identity section; it should use `ProfileCardPalette` in light and dark app themes and own the high-signal pace/distance summary. |
| `_RunStatPill` | `lib/swipes/presentation/widgets/scrollable_profile.dart:137` | Small stat pill inside the running identity card. |
| `_RecapHero` | `lib/swipes/presentation/event_recap_screen.dart:144` | `CatchSurface` hero section of the event recap screen: event name, activity metadata, checked-in count, and catch-window status. |
| `_RecapStat` | `lib/swipes/presentation/event_recap_screen.dart:200` | Single stat counter on the recap screen (for example, "12 Likes", "4 Matches"). |
| `_ProfilePhoto` | `lib/swipes/presentation/event_recap_screen.dart:295` | Single profile photo in the recap attendee grid. |
| `_EmptyRoster` | `lib/swipes/presentation/run_recap_screen.dart:316` | Empty state when the recap roster has no one. |
| `_FilterSection` | `lib/swipes/presentation/filters_screen.dart:221` | Static handoff filter section with mono kicker, tokenized vertical padding, bottom hairline, and body content. |
| `_FilterValue` | `lib/swipes/presentation/filters_screen.dart:250` | Large range-value text shown above the age `CatchRangeSlider`. |

---

## Matches / Chats

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsListScreen` | `lib/matches/presentation/matches_list_screen.dart:10` | "Chats" / Host "Inbox" tab shell. Renders the pinned composable chats browse header plus the chat conversations body, and owns only transient host inbox filter state for the handoff `All` / `Unread · n` option row. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsList` | `lib/matches/presentation/widgets/chats_list.dart:14` | Sliver body for chat conversations fed from `ChatsListViewModel`. Uses a padded skeleton loading sliver, empty/error states, applies the host unread option filter when supplied, and delegates populated data to `ChatsListBody`. |
| `MatchCelebrationDialog` | `lib/matches/presentation/widgets/match_celebration_dialog.dart:41` | Compatibility-named full-screen match celebration route. Uses `CatchCelebrationScreen` with match haptics, then routes the primary action into `ChatScreen` or dismisses back to swiping. |
| `ChatListTile` | `lib/matches/presentation/chat_list_tile.dart:10` | Single inbox row. Receives a `ChatThreadPreview`, renders directly on the page surface with an optional inset hairline divider, `PersonAvatar` (rounded square for host inquiries), display name, semantic `chatPreview` secondary text, timestamp, and row-level unread/new treatment through avatar ring, text color, timestamp color, unread badge, or a trailing new-match dot. Routes to `ChatScreen`. |
| `ChatNewMatchesRail` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:10` | Legacy horizontal rail of no-message `ChatThreadPreview` matches. The handoff inbox no longer renders this rail from `ChatsListBody`; new matches are folded into the conversations list unless a future screen intentionally needs a separate rail. |
| `_NewMatchAvatar` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:31` | Single new-match avatar in the rail — circular photo with name. |
| `ChatSearchField` | `lib/matches/presentation/widgets/chat_search_field.dart:6` | Chats query adapter over `CatchSearchField` for standalone chat search placements. `ChatsSliverHeader` now binds `chatSearchQueryProvider` directly through `CatchBrowseHeader` and the shared `CatchExpandingSearch` primitive. |
| `ChatConversationsList` | `lib/matches/presentation/widgets/chat_conversations_list.dart:8` | Headerless `SliverList` of chat previews driven by `ChatsListViewModel`. Renders contiguous on-surface `ChatListTile` rows with row dividers instead of spacing between card surfaces; callers decide whether the input list includes new matches, conversations, or both. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsEmptyState` | `lib/matches/presentation/widgets/chats_empty_state.dart:6` | Empty state shown when there are no chat conversations, no search results, or no unread host queries. |
| `ChatsListBody` | `lib/matches/presentation/widgets/chats_list_body.dart:7` | Body wrapper for the chats list. Folds `viewModel.newMatches` and `viewModel.conversations` into one handoff `CONVERSATIONS` section, then delegates contiguous rows to `ChatConversationsList` without rendering the old new-match rail. |
| `ChatsSliverHeader` | `lib/matches/presentation/widgets/chats_sliver_header.dart:12` | Chats-specific wrapper around `CatchBrowseHeader`. It is rendered in the pinned sliver slot, expands its fixed bottom height for the host `OptionGroup`, wires search, and keeps query state in `chatSearchQueryProvider`. |
| `_ChatsBrowseHeader` | `lib/matches/presentation/widgets/chats_sliver_header.dart:34` | Stateful chats browse-header adapter that removes the old count badge, animates search expansion through `CatchExpandingSearch`, binds `chatSearchQueryProvider`, and renders the host inbox `All` / `Unread · n` option row when supplied. |

---

## Chat Screen

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatScreen` | `lib/chats/presentation/chat_screen.dart:21` | Thin route-facing wrapper for a chat thread. Accepts the route match id and optional routed profile, then delegates thread state and composition to `_ChatContent`. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_ChatContent` | `lib/chats/presentation/chat_screen.dart:33` | Stateful chat-thread content. Owns local text/scroll controllers and mounted lifecycle effects, watches match/run/profile/message providers, and routes send/image/report/block actions through `ChatController` mutations. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ChatMutationListeners` | `lib/chats/presentation/chat_screen.dart:288` | Mutation snackbar boundary for chat send/send-image/report/block errors. Keeps mutation feedback out of the rendering widgets. |
| `ChatTopBar` | `lib/chats/presentation/widgets/chat_top_bar.dart:12` | Handoff `ConversationTopBar` for chat threads: surface top bar, hairline bottom rule, tappable avatar/name title, and overflow actions for share/report/block. Navigation stays in the top-bar action because it is route UI, while safety actions are callbacks into the controller layer. |
| `ChatEventContextHeader` | `lib/chats/presentation/widgets/chat_event_context_header.dart:20` | Handoff `ChatThreadHeader` event-context band. Grounds the thread in the latest shared event with activity soft fill, accent hairline/glyph, mono activity stamp, and event title/date copy; falls back to the neutral "MATCHED THROUGH CATCH" state while event context loads. |
| `chat_event_context_copy` helpers | `lib/chats/presentation/widgets/chat_event_context_copy.dart:3` | Shared Messaging copy source for event-context stamps, chat share-card titles, and empty-thread prompts. Keeps thread header, share card, and empty state language aligned with the latest shared event and preserves neutral fallbacks while event context is unavailable. |
| `ChatMessageList` | `lib/chats/presentation/widgets/chat_message_list.dart:14` | Message-list renderer for loading, error, empty, and populated states. Inserts centered day separators, splits same-sender bubble runs across day boundaries, uses `CatchEmptyState` for empty threads, and now receives the latest shared event so the empty prompt can match the Messaging handoff's event-grounded copy before the `Say hi` CTA. It keeps variable-height `MessageBubble` rows for individual messages; do not add `prototypeItem`/fixed item extents because chat bubbles can wrap or contain images. |
| `ChatInputBar` | `lib/chats/presentation/widgets/chat_input_bar.dart:10` | Handoff `ChatComposer`: bottom dock with quiet circular image action, raised pill text field, filled circular send action, disabled opacity, loading indicators, and real send/image callbacks. |
| `SuvbotActionBar` | `lib/chats/presentation/widgets/suvbot_action_bar.dart:27` | Demo-only chat bottom dock for Suvbot conversations. Groups check/refresh, warm-state, reset, help, and match-tester actions without rendering the normal chat composer. Reset actions open a handoff `CatchBottomSheetScaffold` with tokenized `CatchSurface` action rows instead of raw Material list tiles; text-required match tester actions keep their focused input sheet. |
| `MessageBubble` | `lib/chats/presentation/widgets/message_bubble.dart:10` | Handoff `ChatBubble`: end/start alignment by sender, primary vs surface fills, fused corners inside sender groups, quiet mono timestamps, pending timestamp state, and optional image attachment. |

---

## Public Profile

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PublicProfileScreen` | `lib/public_profile/presentation/public_profile_screen.dart:18` | Full-screen public profile view. Fetches `PublicProfile` by UID, passes the current viewer profile into the shared `ProfileSurface` when viewing someone else, renders branded `CatchErrorState` / `CatchEmptyState` fallbacks for load failures and unavailable profiles, and routes report/block actions through `PublicProfileController` mutations. Report reasons render as shared `SettingsRow` action rows inside `CatchBottomSheetScaffold`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ProfileBody` | `lib/public_profile/presentation/public_profile_screen.dart:192` | Body of the public profile with a shared cardless profile surface and pending-action overlay. |
| `_ReportReasonTile` | `lib/public_profile/presentation/public_profile_screen.dart:218` | Single selectable report reason row. |

---

## User Profile

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileScreen` | `lib/user_profile/presentation/profile_screen.dart:16` | Profile tab destination. Gates screen-owned streams while the retained tab branch is inactive, owns the route-level top safe area, uses `NestedScrollView` for a scroll-away "Your profile" title plus a pinned handoff `CatchOptionGroup` Edit/Preview row, and keeps native `TabBarView` paging for smooth horizontal tab swipes. The pinned option row is wrapped in `SliverOverlapAbsorber`; each tab body starts with `SliverOverlapInjector`. Owns the `TabController` locally because tab selection is route UI state. Preview renders full-bleed below the option row, with the shared `ProfileSurface` owning the inner body gutter. |
| `ProfileTab` | `lib/user_profile/presentation/widgets/profile_tab.dart:19` | Standalone signed-in edit tab content. Wraps the edit form in a `ListView` for isolated/non-sliver usage and renders the handoff sections Photos, Prompts, About you, Running, and Lifestyle through `CatchDesignSection`/`ProfileInfoSection` on-surface groups. `Display name` is the first editable About field and is the only public-facing profile name; onboarding identity fields such as date of birth and gender are readonly, and last name is not shown publicly. Profile prompt rows use catalog-backed pickers that hide prompt IDs already selected in other rows. Optional/profile-detail fields, including Instagram, remain editable. Running is always visible and owns pace, distances, reasons, and favorite run times. Discovery-only preferences such as interested-in genders and match age range live in Filters, not Edit Profile. Optional single-choice edit sheets open unselected when the underlying field is empty. |
| `ProfileTabSliverBody` | `lib/user_profile/presentation/widgets/profile_tab.dart:69` | Sliver-native profile edit body. Reuses the same handoff sections as `ProfileTab` but contributes a padded sliver adapter for parent `CustomScrollView` usage. Uses `profileTabBodyPadding` for the edit body; Preview is full-bleed and no longer shares this inset. |
### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PreviewTab` | `lib/user_profile/presentation/widgets/preview_tab.dart:5` | Preview tab showing how the user's profile looks to others by rendering the shared handoff `ProfileSurface`, with owner-provided scroll controller, physics, bottom padding, and leading-overscroll callback when mounted inside ProfileScreen. |
| `ProfileInfoSection` | `lib/user_profile/presentation/widgets/profile_info_section.dart:24` | Grouped section of `ProfileInfoTile` rows. Titled grouped sections render through `CatchDesignSection` with optional count context and quiet inset row dividers, matching the handoff `InfoGroup`. Untitled grouped sections keep the compact legacy surface shell for embedded callers. |
| `ProfileInfoTile` | `lib/user_profile/presentation/widgets/profile_info_tile.dart:6` | Handoff-style stacked `InfoRow` for edit-profile fields: muted 20px icon, quiet `fieldLabel` caption, `infoRowTitle` value or in-row value editor, primary add affordance, and animated chevron/row-height for row-owned inline edits. |
| `_ProfileUnavailableBody` | `lib/user_profile/presentation/profile_screen.dart:103` | Missing-profile state. Prevents the profile route from rendering a blank body when the signed-in user profile is unavailable. |
| `_PreviewTabSliverBody` | `lib/user_profile/presentation/profile_screen.dart:120` | Sliver-native preview body. Gives the shared `ProfileSurface` bounded remaining viewport height inside the profile route's preview tab scroll view, passes a dedicated profile scroll controller, leaves the hero full-bleed with only the template's 8px option-row breathing room, and bridges upward scroll plus leading overscroll to the outer Profile header. |
| `_ProfileTitle` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:25` | Scroll-away "Your profile" title row with one Settings action. Account actions live inside Settings, not in a second header overflow menu. |
| `_ProfileTabBar` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:58` | Pinned Edit/Preview `CatchOptionGroup` surface for the sliver-native profile route. The route-level `SafeArea` keeps it below device cutouts without adding an expanded-header gap. |
| `_SettingsButton` | `lib/user_profile/presentation/widgets/profile_sliver_header.dart:82` | Settings gear button in the scroll-away profile title header. |
| `ProfileInlineEditableText` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:105` | Row-value editable text primitive built on `EditableText`. Preserves the closed row value style/position, supports multiline row-owned editing for Bio, and signals focus with cursor, selection, and a text-width underline instead of a boxed field. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileInlineTextEntryEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:221` | Row-owned text editor that turns `ProfileInfoTile` values into `ProfileInlineEditableText`, including multiline Bio editing in the row value slot, delayed post-expansion focus, and validation plus trailing `Cancel`/`Done` actions in the shared inline panel. |
| `ProfileInlinePromptEntryEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:616` | Row-owned profile-prompt editor. Combines the inline prompt answer text primitive with a `CatchSelectMenu` catalog picker, filters out prompt IDs used by sibling prompt rows, and saves ordered `profilePrompts` patches so prompt slots stay unique. |
| `ProfileInlineHeightEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:473` | Inline bounded height editor using `CatchNumberStepper` and the shared inline editor panel. |
| `ProfileInlineSingleChoiceEntryEditor<T>` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:533` | Row-owned nullable single-choice editor. Selected value renders in the row slot, available alternatives render below, and `Cancel`/`Done` owns commit/discard. |
| `ProfileInlineMultiChoiceEntryEditor<T>` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:656` | Row-owned multi-choice editor. Selected chips stay in the row slot with check icons, available alternatives render below, and optional fields allow deselecting row chips. |
| `ProfileInlineRangeEditor` | `lib/user_profile/presentation/widgets/profile_inline_editors.dart:912` | Inline range editor using `CatchRangeSlider`, local draft range state, endpoint labels for slider bounds, and the shared inline editor panel. The row owns the selected range display, so the editor does not repeat it above the slider. |

---

## Onboarding

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `OnboardingScreen` | `lib/onboarding/presentation/onboarding_screen.dart:17` | Multi-step onboarding shell. Initializes the correct entry point for full, profile-completion-only, and run-preferences-only flows, owns back-step boundaries, renders the shared top bar, and delegates body composition to step pages. |
| `NameDobPage` | `lib/onboarding/presentation/pages/name_dob_page.dart:13` | Handoff Name + DOB step: headline/subtitle, FIRST NAME / LAST NAME / DATE OF BIRTH / verified PHONE fields, date picker, private-last-name and birth-year helper copy, and sticky Continue footer through `OnboardingStepFrame`. |
| `GenderInterestPage` | `lib/onboarding/presentation/pages/gender_interest_page.dart:13` | Handoff Gender step using uppercase section labels, `ChipField` selections, validation, stable semantic chip keys, and sticky Continue footer. |
| `InstagramPage` | `lib/onboarding/presentation/pages/instagram_page.dart:10` | Handoff Instagram step with verification/privacy copy, HANDLE field, sticky Continue action, and secondary Skip for now action that advances without saving a handle. |
| `ProfilePromptsPage` | `lib/onboarding/presentation/pages/profile_prompts_page.dart:20` | Handoff Prompts step: three prompt cards, duplicate-prompt filtering through `CatchSelectMenu`, inline answer fields, footer progress label, and disabled Continue until all prompt slots are answered. |
| `RunningPrefsPage` | `lib/onboarding/presentation/pages/running_prefs_page.dart:19` | Handoff Running prefs step: TYPICAL PACE range panel on `CatchSurface`, `CatchRangeSlider`, favorite distance/reason/time chip groups, and sticky Save/Continue booking footer. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `WelcomePage` | `lib/onboarding/presentation/pages/welcome_page.dart:10` | Dark editorial welcome screen from the handoff: Catch wordmark, RUN CLUB DATING kicker, large arrival headline, body copy, primary Continue with phone CTA, and secondary Explore events CTA. |
| `PhotosPage` | `lib/onboarding/presentation/pages/photos_page.dart:19` | Handoff Photos step with header copy, `PhotoGrid`, divider-backed photo tip band, disabled-state continue hint, and sticky Continue footer. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_OnboardingTopBar` | `lib/onboarding/presentation/onboarding_screen.dart:143` | Top bar for non-welcome onboarding screens. Computes compact progress totals for full/profile-only/run-preferences-only modes and delegates back/progress chrome to `CatchStepFlowHeader`. |
| `OnboardingStepHeader` | `lib/onboarding/presentation/widgets/onboarding_step_header.dart:6` | Handoff step title + subtitle header using the shared headline/prose roles. |
| `OnboardingStepFrame` | `lib/onboarding/presentation/widgets/onboarding_step_header.dart:32` | Shared onboarding/auth step frame. Centers scroll content to the max content width and optionally pins a SafeArea-aware footer for primary actions and progress summaries. |
| `_PromptField` | `lib/onboarding/presentation/pages/profile_prompts_page.dart:208` | Prompt-card row for onboarding prompts. Wraps prompt selection and answer entry in a `CatchSurface` while preserving duplicate prompt filtering and character count helper copy. |
| `OnboardingFormKeys` | `lib/onboarding/presentation/onboarding_form_keys.dart:4` | Stable semantic keys for onboarding form controls whose visible labels repeat across sections. |

---

## Auth

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `AuthScreen` | `lib/auth/presentation/auth_screen.dart:7` | Phone-auth flow shell. Watches `AuthController.step` and switches between phone entry and OTP entry without owning visible handoff layout state; `PhonePage` and `OtpPage` provide the shared onboarding frame/header and sticky footer composition. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `PhonePage` | `lib/auth/presentation/phone_page.dart:24` | Handoff phone entry step. Uses `OnboardingStepFrame`, `OnboardingStepHeader`, country selector + phone input row, sticky Send code footer, and stable auth form keys while keeping `AuthController.sendOtpMutation` behavior. |
| `OtpPage` | `lib/auth/presentation/otp_page.dart:19` | Handoff OTP entry step. Uses `CatchOtpCodeField`, resend countdown, Resend/Change number actions, sticky Verify footer, and existing auto-submit plus auth mutation behavior. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `AuthFormKeys` | `lib/auth/presentation/auth_form_keys.dart:3` | Stable semantic keys for auth form controls and actions. |
| `_CountryCodeSelector` | `lib/auth/presentation/phone_page.dart:143` | Country-code picker shell used by `PhonePage`; keeps the flag selector in the handoff's fixed-width control lane and applies Catch dialog/search styling. |
| `CatchCodeInput` | `lib/core/widgets/catch_otp_code_field.dart:9` | Shared handoff `CodeInput` visual row used by `CatchOtpCodeField` and static OTP/code mocks. |
| `CatchOtpCodeField` | `lib/core/widgets/catch_otp_code_field.dart:50` | Shared OTP primitive used by `OtpPage`; owns hidden platform input and delegates six visual cells to `CatchCodeInput` styling. |

---

## Launch Access

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `LaunchAccessApplicationScreen` | `lib/launch_access/presentation/launch_access_application_screen.dart:25` | Remote-Config-gated access application route. Shows disabled, signed-out, locked-status, or editable application states; the editable form collects city, role, event types, availability, host interest, invite/referral details, and reason copy before submitting through `LaunchAccessController.submitMutation`. Host-interest uses handoff `CatchToggle` row composition, while choice groups stay on `ChipField`. |

---

## Image Uploads

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfilePhotoEditorScreen` | `lib/image_uploads/presentation/profile_photo_editor_screen.dart:14` | Add/edit profile-photo flow opened by onboarding and Edit Profile. It picks or replaces the image, shows a crop preview, lets the user choose an optional catalog photo prompt that is not already used by another profile photo, supports guarded deletion, and saves through `PhotoUploadController.savePhoto` so grouped `profilePhotos` stay synchronized and duplicate prompts are cleared. |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `OrderedPhotoPicker` | `lib/image_uploads/presentation/widgets/ordered_photo_picker.dart:31` | Shared ordered media picker for host club/event forms. Filters to previews with image data, renders add/photo tiles on `CatchSurface`, preserves semantic labels/tooltips, exposes stable add/remove keys, supports optional removal and reorder callbacks, and keeps callers responsible for upload/persistence state. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PhotoGrid` | `lib/image_uploads/presentation/photo_grid.dart:10` | Dense 3x2 profile photo grid over normalized `ProfilePhoto` objects. Uses `maximumProfilePhotoCount`, keyed slots, guarded delete callbacks, optional reorder, and a hideable leading `MAIN` label; callers own opening `ProfilePhotoEditorScreen` and enforcing the completed-profile minimum. |
| `PhotoSlot` | `lib/image_uploads/presentation/widgets/photo_slot.dart:6` | Single keyed profile-photo slot. Renders through `CatchSurface`, grades filled photos with `GradedImage`, shows DS striped material for pending uploads, dashed hairline targets for empty slots, semantic labels/tooltips for add/edit/delete/uploading/unavailable states, optional prompt and main-label overlays, reorder target affordance, and blocked taps while inactive or loading. |

---

## Run Clubs

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateClubScreen` | `lib/hosts/presentation/club_management/create/create_club_screen.dart:18` | Host-owned create/edit club form. Uses shared `FormStepSpec` metadata with `CatchStepFlowHeader`, `StepperFooter`, create-only local drafts, cover/profile photo picking, host defaults, a dedicated event-success defaults step, and submit mutation feedback. Host-default controls use shared `SelectChip` and `CatchToggle` primitives. Owner edit keeps the full wizard; co-host edit narrows to media-only updates. |
| `ClubBasicsStep` | `lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart:11` | First club form step. Keeps cover/profile media, club name, city, and area fields in one fully mounted scroll body so validation sees all required fields. In co-host media edit mode, non-media fields render disabled. |
| `ClubDetailsStep` | `lib/hosts/presentation/club_management/create/widgets/club_details_step.dart:7` | Second club form step. Holds required description plus optional contact fields. |
| `ClubHostDefaultsStep` | `lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart:17` | Third club form step. Configures club-level host defaults for admission, cohort caps, dynamic pricing, age range, cancellation policy, and default activity inherited by new events. Uses handoff `SelectChip` selectors and `CatchToggle` switches in both create-flow and embedded edit-mode layouts. |
| `ClubEventSuccessDefaultsStep` | `lib/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart:6` | Fourth club form step. Wraps `EventSuccessDefaultsPanel` for the club's primary activity so event-success run-of-show defaults are edited separately from booking policy defaults. |
| `ExploreCityPicker` | `lib/explore/presentation/widgets/explore_city_picker.dart:12` | Compact city scope picker for the Explore browse header. The closed trigger is a fixed-size circular `CatchControlShell` with a location icon only, while the full city label stays in tooltip/semantics and the token-styled bottom sheet. It updates `selectedExploreCityProvider`, clears Explore search on city changes through the provider seam, listens for GPS/profile auto-selection, and keeps the selected city while the remote city list is loading or unavailable. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ClubDetailScreen` | `lib/clubs/presentation/detail/club_detail_screen.dart:16` | Club detail screen. Fetches the club, current user profile, active membership edge, upcoming events, and reviews; join/leave mutations stay in `ClubMembershipController`. Renders `ClubDetailBody`. |
| `ExploreList` | `lib/explore/presentation/widgets/explore_list.dart:14` | Sliver state-dispatch widget for the Explore tab's club directory state. Renders directory-card skeletons, error, city-empty, search-empty, filter-empty, and data slivers from `ExploreViewModel`, which partitions joined/discover clubs from active membership edges, and owns join-mutation feedback. |
| `ExploreSearchField` | `lib/explore/presentation/widgets/explore_search_field.dart:6` | Explore query adapter over `CatchSearchField` for standalone Explore search placements. `ExploreSliverHeader` now binds `exploreSearchQueryProvider` directly through `CatchBrowseHeader` and the shared `CatchExpandingSearch` primitive. |
| `ExploreFilterRail` | `lib/explore/presentation/widgets/explore_filter_rail.dart:18` | Handoff Explore scope/filter rail. Uses `CatchOptionGroup<ExploreTimeFilter>` for the visible time scopes (Tonight, Weekend, This week, Anytime), pins a trailing `CatchCountPill` filter affordance with an active-count badge, and moves secondary distance/joined filters into a tokenized `CatchBottomSheetScaffold` with handoff `SelectChip` choices. The rail stays backed by `exploreFiltersProvider`, can receive transparent/opaque background colors from the floating map chrome, and keeps search/filter composition compact enough for compact mobile widths. |
| `MembershipButton` | `lib/clubs/presentation/detail/widgets/membership_button.dart:7` | Join/Leave/Request membership button on the club detail screen. Calls `ClubMembershipController`. |
| `MutationErrorSnackbarListener` | `lib/core/widgets/mutation_error_snackbar_listener.dart:13` | Watches a Riverpod `Mutation` and shows a `SnackBar` on error transition. Used for transient mutation errors such as join/leave club failures. |
| `_DirectoryCard` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:3` | Directory-style club card router for Explore. Chooses the concept-lab-inspired photo card when cover/profile imagery exists and the no-cover identity card otherwise, while preserving host-before-joined role precedence and keeping only discoverable clubs eligible for the `Join` CTA. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ExploreScreen` | `lib/explore/presentation/explore_screen.dart:31` | Explore tab route. Owns the persistent sheet-over-map browse surface: `EventMapView` stays mounted behind a draggable sheet and receives its map view model from the same filtered event discovery feed used by the list. The map can fill the full viewport, but the full/list state paints an opaque top lid over the status-bar/notch area and header/filter chrome while the sheet begins below that chrome, so the closed page does not show map content in the safe area. The floating `Map` control uses shared `CatchCountPill` and appears only in this full/list state; after opening, users close or resize by dragging the handle. Programmatic map open lands on a higher detent just under the filter strip, fades the top lid/header/filter backgrounds transparent, and keeps the city/search/filter controls floating over the map while the sheet edge rounds and selected map pins render a full-width ticket card unless the selected pin is the feed's actual featured event, in which case the spotlight card remains. User drags use soft settling zones: releases near the shorter bottom extent, map detent, or full/list state animate into those anchors, while the middle range can rest naturally. The peek state renders only aggregate result summary copy. Selecting a map pin stores the selected event id and snaps to the map selected-card state. The screen also listens for map camera-center changes so nearby event ordering can remain spatial, and a distance-ring tap cycles the active distance filter. |
| `ExploreBody` | `lib/explore/presentation/widgets/explore_body.dart:10` | Sliver-native data body for the Explore tab. Production `ExploreScreen` disables the old personal rail and directory stack, then composes the mixed `ExploreEventsSection` with the bottom-of-page `ExploreEventTypeBrowseGrid` without embedding a vertical `ListView` inside the parent `CustomScrollView`. Legacy callers can still opt into the joined-club rail or club directory through explicit flags. |
| `ExploreEventsSection` | `lib/explore/presentation/widgets/explore_events_section.dart:101` | Mixed Explore discovery section. Watches the event discovery feed, accepts candidate clubs from `ExploreBody`, and renders a handoff result-count line above the feed from the same visible `ExploreFeedViewModel` items (`1 PLAN` / `10 PLANS · JUN 11-17`), skipping that cue for club-only fallback content. It leads the default This week filter with a no-gap ticket strip only when there are at least five day-level `EventDateRailCard` recommendations. Weekly-strip events are excluded from the remaining mixed feed, which interleaves leftover compact event rows, an Instax-like club spotlight, the editor-pick event spotlight, and compact club rows. Event taps route to `Routes.eventDetailScreen`, club taps route to `Routes.clubDetailScreen`, club cards use shared club identity atoms, and event rows use `EventCapacityPresenter` for going/left copy. Skeleton/error/empty states still belong to the event discovery feed; debug builds can opt into non-tappable synthetic visual fill with `ENABLE_EXPLORE_SYNTHETIC_VISUAL_FILL`. |
| `ExploreEventTypeBrowseGrid` | `lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:13` | Bottom-of-page Browse by event type surface. Reads the current Explore feed and `exploreFiltersProvider`, renders `primaryBrowseActivityKinds` with the shared activity palette and visible-feed counts, and toggles `activityTag` filters from each tile. |
| `ExplorePeekRail` | `lib/explore/presentation/widgets/explore_peek_rail.dart:13` | Lead sliver builder for the Explore map sheet. `buildExploreMapSheetLeadSlivers` renders aggregate count/scope copy in collapsed mode, a selected-pin lead that branches between `CatchEventTicketCard` and `CatchEventSpotlightCard` based on the feed's featured event id, and the nearby horizontal rail with `CatchEventTicketCard` items, spatial reordering, and a semantic "See all" action in unselected half/full mode. |
| `ClubDiscoverList` | `lib/clubs/presentation/discovery/widgets/club_discover_list.dart:8` | Club directory section of Explore with a real `SliverList` of directory cards. Passes joined and hosted club IDs separately so host-owned clubs are not mislabeled as ordinary joined clubs. |
| `ClubIdentityAtoms` | `lib/clubs/presentation/shared/club_identity_atoms.dart:11` | Shared club-card identity helpers and widgets: member-count label, tag filtering, member seal, tag wrap, hosted-by line, host avatar, host role badge, and rating pill. Use this before adding club-card-local member labels, tag wraps, host rows, or rating chips. |
| `ClubListTile` | `lib/clubs/presentation/discovery/widgets/club_list_tile.dart:33` | Club tile rendered as directory card or avatar chip. Directory cards now use the productionized concept-lab club language and shared club identity atoms: image-backed clubs get a bounded photo card with member seal, centrally themed `CatchTextStyles.clubDisplay` title, tags, host row, and role sash; no-image clubs get an identity card that reuses the shared fallback palette. Display-only tile rendering does not watch provider state; only the join button owns the mutation provider. |
| `ExploreEmptyState` | `lib/explore/presentation/widgets/explore_empty_state.dart:4` | Empty state for empty-city, search-empty, filter-empty, and combined search/filter-empty cases. Uses `CatchEmptyState` with recovery copy and optional clear actions owned by `ExploreList`. |
| `ClubAvatarRail` | `lib/clubs/presentation/discovery/widgets/club_avatar_rail.dart:12` | Horizontal rail of the user's joined clubs plus an optional create-club tile. Uses larger rounded image chips so no-photo fallback marks and live badges remain legible, and exposes padding/divider controls so Home can reuse the rail without Explore-specific chrome. |
| `_CreateClubButton` | `lib/clubs/presentation/discovery/widgets/club_avatar_rail.dart:36` | Rounded-square create tile at the end of the avatar rail to create a new club. |
| `ExploreBrowseHeaderContent` | `lib/explore/presentation/widgets/explore_header.dart:23` | Explore-specific wrapper around `CatchBrowseHeader`. It can render in the pinned sliver slot or inside Explore's floating chrome layer, owns temporary search-open state, wires city picker and search actions, accepts an optional background color, and keeps query state in `exploreSearchQueryProvider` for event and club search. |
| `ClubHeroAppBar` | `lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart:16` | Club detail identity hero with cover-photo support, shared branded fallback, name, area/city, back, and share. The hero uses `clubInteractionHeroTag` and the same base `clubInteractionMediaPadding` as the Explore Polaroid club card, while `CatchViewportCurveFrame` clips only the media frame to the device-derived top viewport curve. The title/location caption sits outside that clipped frame on the page surface and uses `CatchLayout.clubDetailHero*` sizing constants, so long two-line club names do not crop the location row. Expanded and collapsed titles use the central `CatchTextStyles.clubDisplay` treatment. Rating and host-only ownership cues stay out of the hero, and no-photo headers use a shorter height. |
| `ClubDetailBody` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:21` | Scrollable public club detail body on a white page surface: hero, stats apron, then handoff-style `CatchDesignSection`s for Your hosts, About, What we do, From the club, Get in touch, Membership, and Join Catch before the existing schedule sliver and read-only club review aggregate. Host-app viewers see the same public schedule presentation as consumer viewers; host operation controls such as Add event, Edit club, payouts, and host-team editing live in Host Operations rather than this public profile body. Host rows keep owner/host badges, profile affordances, and signed-in viewer message buttons backed by the host-inquiry conversation flow. |
| `ClubShareCard` | `lib/clubs/presentation/detail/widgets/club_share_card.dart:46` | Shareable club card rendered inside `RichShareCardSheet`. Uses `CatchSurface`, bounded rich-card aspect ratio constants, cover-photo or `ClubPolaroidArtwork`, shared club identity atoms for member/tag copy, and `clubShareText` for the public club deep link. |
| `ClubScheduleSection` | `lib/clubs/presentation/detail/widgets/club_schedule_section.dart:9` | Sliver-native agenda section for a club's upcoming events. Reuses `EventAgendaSliverList` with detail-screen padding and agenda gap constants, shows the compact inline empty state when no events exist, routes selected events to detail, and marks host-owned schedules with the `HOSTED` event-tile status. |
| `_ClubContactSection` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:148` | Contact info section: Instagram, website, WhatsApp, email rows. |
| `_ContactRow` | `lib/clubs/presentation/detail/widgets/club_detail_body.dart:201` | Single contact row: icon, label, and value. |
| `StatsStrip` | `lib/clubs/presentation/detail/widgets/stats_strip.dart:6` | Club detail stats wrapper. Adapts club metrics into the shared handoff `StatStrip` so club stats use the flat hairline-bordered data-pair row with uppercase mono labels. |
| `CatchPolaroid` | `lib/clubs/presentation/shared/catch_polaroid.dart:12` | Shared club polaroid primitive: tight white framed media, mono caption, upright Archivo club title, optional title-row arrow, editorial supporting copy, and optional footer/actions. Used by Explore club cards and directory club cards so image-backed and no-cover states share one named metaphor. |
| `ClubPolaroidArtwork` | `lib/clubs/presentation/shared/catch_polaroid.dart:115` | Map-style no-photo artwork for club polaroids and compact club crests. It avoids generated initials, uses a quiet location mark, and derives deterministic accents from `ClubCoverVisualPalette`. |
| `ClubCoverVisualPalette` | `lib/clubs/presentation/shared/catch_polaroid.dart:175` | Deterministic club visual palette derived from `ActivityPalette` and tokens for production cards that need matching no-cover accents. |
| `CreateClubPhotosPicker` | `lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart:9` | Ordered photo picker for the host create/edit club form. |
| `CreateClubContactFields` | `lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart:6` | Contact fields (Instagram, WhatsApp, website, email) for the host create/edit club form. |
| `_DirectoryPhotoCard` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:43` | Image-backed Explore club directory card. Uses `CatchPolaroid` with real club imagery through `_ClubImage`, adds a compact member seal/rating badge, keeps the serif identity band below the media, and renders tags plus hosted-by/action affordances without moving join mutation state into display-only card code. |
| `_DirectoryIdentityCard` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:109` | No-cover Explore club directory card. Uses `CatchPolaroid` with `ClubPolaroidArtwork`, then renders metadata, tags, hosted-by context, and the role-aware action row without generated initials. |
| `_ClubPhotoMedia` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:239` | Bounded responsive media block for image-backed directory cards. Preserves a 16:9 feel on normal phone widths while capping wide layouts so the list tile does not overflow in tablet/test surfaces. |
| `_ClubImage` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/club_image.dart:3` | Club cover image for list tiles. Selects cover/profile image order by variant and passes explicit fallback chrome flags for directory cards versus avatar rail chips. |
| `_HostAvatar` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:721` | Host avatar shown on directory cards, with configurable radius for the newer hosted-by row density. |
| `_AvatarChip` | `lib/clubs/presentation/discovery/widgets/club_list_tile_parts/avatar_chip.dart:3` | Joined-club rail tile with a rounded image/fallback chip, optional live badge, and truncated club name. |

---

## Events

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateEventScreen` | `lib/hosts/presentation/event_management/create/create_event_screen.dart:34` | Host-owned multi-step event creation flow for details, location, schedule, event policy, and event-success defaults. Uses shared `FormStepSpec` metadata, `CatchStepFlowHeader`, handoff-aligned step bodies, `StepperFooter`, and shared `SelectChip`/`CatchToggle` controls for selections and switches. It seeds policy and event-success defaults from `club.hostDefaults`, manages draft save/restore, saves optional event-success setup, and routes Manage event to canonical Host Manage after success. |
| `EditHostedEventScreen` | `lib/hosts/presentation/edit_hosted_event_screen.dart:107` | Host-only published-event edit form for backend-supported operational fields: schedule when unlocked, meeting point, pinned starting point, extra directions, distance, pace, description, capacity, price, admission format, invite code, cohort/age limits, dynamic pricing, and cancellation policy. Uses handoff `SelectChip` for editable pace/admission/cancellation selectors and `CatchToggle` for editable cohort-cap/demand-pricing switches; schedule and booking-policy edits lock once the event has started or has booking, waitlist, or attendance activity. |
| `EventMapView` | `lib/events/presentation/event_map_screen.dart:19` | Reusable full-screen event map body. Uses a parent-supplied `AsyncValue<EventMapViewModel>` and retry callback when provided, otherwise can watch and invalidate `eventMapViewModelProvider` for tests/dev callers. It centers on device location unless the selected club city was manually overridden or location is unavailable, owns selected-event state, and composes `EventPinsMap`, map empty states, optional overlay controls, camera-center callbacks, and optional distance-ring taps. Explore mounts it behind its own draggable browse sheet; event-detail directions use `EventLocationMapScreen` instead. |
| `HostEventManageScreen` | `lib/hosts/presentation/host_event_manage_screen.dart:114` | Canonical per-event host workspace. Mounts `HOST MANAGE`, event title, and Setup / Live / Report `CatchOptionGroup` in shared `CatchTopBar` chrome; lets the participation panel own roster counts as filter tiles instead of repeating booked, waitlist, and revenue stat cards. Setup leads with participants before event details, event-success setup, private links, and lower-priority admin/destructive actions; Live embeds the editable roster inside the event-success Live now flow; Report leads with the filtered event-report table before the post-event host report. Private-link sharing uses shared event-invite copy, and the full-event apron uses compact capacity/waitlist copy under the top bar. |
| `LocationPickerScreen` | `lib/events/presentation/location_picker_screen.dart:16` | Chromeless map-based location picker. Lets hosts tap or search for a location and returns the selected `LocationCoordinate`; keeps confirm/search controls floating above the map. Autocomplete results render in a `CatchSurface` overlay with tokenized local suggestion rows rather than raw Material list tiles. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `EditHostedEventRouteScreen` | `lib/hosts/presentation/edit_hosted_event_screen.dart:44` | Route-facing edit entry. Loads the host-owned club and event, rejects non-host viewers, and delegates to `EditHostedEventScreen` with optional route-provided event data. |
| `HostEventManageRouteScreen` | `lib/hosts/presentation/host_event_manage_screen.dart:44` | Route-facing host manage entry used from the canonical `/clubs/:clubId/events/:eventId/manage` route plus dashboard, attendance, and event-success aliases. Loads the event and club by id, gates access to the club host, and delegates the loaded state plus optional lifecycle section to `HostEventManageScreen`. |
| `_HostManageSectionPicker` | `lib/hosts/presentation/host_event_manage_screen.dart:317` | Setup / Live / Report mode picker for Host Event Manage. Renders the handoff `OptionGroup` labels and calls back into the screen's section state. |
| `EventDetailScreen` | `lib/events/presentation/event_detail_screen.dart:17` | Route-facing event detail entry. Fetches `EventDetailViewModel`, renders scaffolded loading/error/not-found states, preserves optional route-provided event data plus source presentation mode/Hero tag, and delegates the loaded screen to `EventDetailBody` without nesting scaffolds. |
| `EventLocationMapRouteScreen` | `lib/events/presentation/event_location_map_screen.dart:20` | Route-facing single-event map entry. Reuses `EventDetailViewModel` by `eventId`, renders chromeless load/error/not-found states with floating back controls, and delegates mapped events to `EventLocationMapScreen`. |
| `EventDetailBody` | `lib/events/presentation/widgets/event_detail_body.dart:33` | Scrollable event detail body. Composes the source-aware hero app bar, a flush ticket-stub band, the handoff-ordered overview stack, optional saved-plan companion entry, booked-attendee invite card, social sections, and a non-host bottom CTA. Uses `CatchDesignSection`/`CatchDetailSliverSectionList` for the body rhythm and preserves `EventDetailSurfaceStyle` for ticket/spotlight modes without changing booking state ownership. |
| `EventDetailHeroAppBar` | `lib/events/presentation/widgets/event_detail_hero_app_bar.dart:10` | Event detail hero app bar. Uses the shared event photo header for standard routes and a full-bleed ticket-mode visual band for card-opened routes; both paths prefer uploaded photos and fall back to activity artwork. Standard and ticket/spotlight expanded heights resolve through named `CatchLayout.eventDetailHero*` constants; ticket mode keeps the perforated ticket seam, shares the event display font with cards, and owns floating back/share/save/calendar actions without adding the club-detail viewport-curve inset. |
| `EventDetailTicketStubBand` / `EventDetailHintList` / `EventDetailItinerary` / `EventDetailMapCard` / `EventDetailMechanismList` / `EventDetailPhotoStrip` | `lib/events/presentation/widgets/event_detail_design_primitives.dart:10` | Flutter event-detail counterparts to the handoff primitives: ticket counter-foil, why-click hints, timed itinerary rail, activity-pigmented map preview, sign-up mechanics, and the canonical three-tile photo strip with activity-soft placeholders. They resolve pigment/glyph through `ActivityPalette` and derive copy from the current `Event` model. |
| `EventPhotoHeader` | `lib/events/presentation/widgets/event_photo_header.dart:5` | Visual-only standard event hero wrapper. Delegates rendering to `CatchEventThumbnail` so uploaded event photos lead when present and activity artwork remains the no-photo/failure fallback; exposes the stable event-photo Hero tag for standard photo-header transitions and intentionally does not duplicate event title, location, stats, or activity copy. |
| `EventStatsGrid` | `lib/events/presentation/widgets/event_stats_grid.dart:7` | Event detail stats adapter. Converts event facts into `CatchMetricStrip` items so event stats share the same rail, dividers, value styling, and responsive truncation as club detail stats, with optional dark surface colors for spotlight detail. |
| `EventDetailCta` | `lib/events/presentation/widgets/event_detail_cta.dart:22` | Bottom CTA bar for non-host event detail viewers. Owns booking, cancellation, waitlist, eligibility, attended/past, free-booking celebration, and paid booking handoff states from the current viewer's `EventParticipation` edge; booking-like actions use the event activity accent through `BottomCTA`, and spotlight detail can render the footer on a dark surface. |
| `AttendanceSheetViewModel` | `lib/events/presentation/attendance_sheet_view_model.dart:10` | Attendance data seam. Combines the event stream with `eventParticipations` and derives attendee IDs plus checked-in state from participation statuses. |
| `EventHypeAvatarStack` | `lib/events/presentation/widgets/event_hype_avatar_stack.dart:68` | Shared attendee-hype avatar stack for event detail and roster surfaces. Obscured mode renders local activity-tinted veiled placeholders without fetching profile photos; revealed mode derives eligible signed-up/attended participants through `eventHypeAvatarsProvider`, applies the viewer gender-preference filter, joins public profile names/thumbnails, and renders `PersonAvatarStack`. |
| `WhoIsGoing` | `lib/events/presentation/widgets/who_is_going.dart:36` | Event detail social roster. Watches `EventParticipationRoster` for booked counts and renders activity-tinted veiled `EventHypeAvatarStack` placeholders until roster visibility is allowed, using `event.activityKind` for the handoff tint. Standalone callers keep the local title/count header; `EventDetailSocialSection` suppresses it so the design-system section owns the label. |
| `EventPinsMap` | `lib/events/presentation/widgets/event_pins_map.dart:10` | Shared Flutter map canvas for event pins. Used by Explore and `EventLocationMapScreen`; renders only events with exact coordinates and keeps map centering outside the pin widget. It reports camera-center changes on idle, draws optional user-location and distance-ring circles, clusters dense low-zoom pins with app-rendered count markers, and expands clusters by zooming in. Its no-network placeholder lays markers out spatially, exposes meeting-point selection labels so widget tests can exercise selected-pin flows without network map tiles, and keeps the painter boundary to concrete token-derived colors rather than prop-drilling `CatchTokens`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateEventSuccessScreen` | `lib/hosts/presentation/event_management/create/create_event_success_screen.dart:9` | Host event-created success screen backed by `CatchCelebrationScreen`. Matches the handoff celebration composition with the `verifiedRounded` seal-check mark, event confirmation details, invite-only code/private-link rows, the Manage event tracking note, and Manage event / Back to club actions. |
| `EventJoinedCelebrationScreen` | `lib/events/presentation/event_joined_celebration_screen.dart:8` | User event-signup celebration surface shared by free bookings and post-payment confirmation. Shows event details, optional payment details, haptics, and View event / Back home actions. |
| `EventCheckInCelebrationScreen` | `lib/events/presentation/event_check_in_celebration_screen.dart:7` | Participant self-check-in celebration surface. Used only after user self-check-in from Home succeeds; host attendance remains an operational flow. |
| `BookingConflictSheet` | `lib/events/presentation/widgets/booking_conflict_sheet.dart:32` | Booking handoff conflict-warning sheet. Renders the already-booked and incoming events as activity-colored rows, keeps warning copy and sheet chrome on Catch primitives, and exposes replace / keep-both / keep-existing callbacks for a future overlap-resolution flow. |
| `EventCheckInLocationService` | `lib/events/presentation/event_check_in_location_service.dart:16` | Provider-backed location seam for self-check-in. Production uses Geolocator with high accuracy and a timeout; tests can inject coordinates without invoking platform plugins. |
| `EventLocationMapScreen` | `lib/events/presentation/event_location_map_screen.dart:63` | Chromeless full-screen single-event map with one pinned exact starting point, floating back controls, and a bottom location summary. Reuses `EventPinsMap`; use only when `Event.hasExactStartingPoint` is true. |
| `EventShareCard` | `lib/events/presentation/widgets/event_share_card.dart:42` | Shareable event invite card rendered inside `RichShareCardSheet`. Uses the activity visual palette, `EventActivityBackdrop`, tokenized info rows, price/spots pills, and `EventInviteShareCopy` so event detail, payment confirmation, and referral invite surfaces share the same visual card and link payload. |
| `CreateEventStepHeader` | `lib/hosts/presentation/event_management/widgets/create_event_step_header.dart:4` | Header for the host create-event wizard: back action, step title, club name, step count, and progress bar. |
| `CreateEventFormKeys` | `lib/hosts/presentation/event_management/create/create_event_form_keys.dart:3` | Stable semantic keys for host create/edit event form fields so widget tests target fields by purpose rather than layout order. |
| `SavedEventsScreen` | `lib/events/presentation/saved_events_screen.dart:15` | Saved-events route. Streams the current user's saved event details, orders future saved events before past saved events, joins club names, and opens saved-event detail routes from shared agenda tiles. |
| `EventTileData` | `lib/events/presentation/widgets/event_tiles/event_tile_data.dart:19` | Shared display model for event tile variants. Wraps an `Event` plus relationship status, optional club name, recommendation reason, and carousel position label, and exposes `EventCapacityPresenter`-backed copy for capacity labels. |
| `EventActionCard` | `lib/events/presentation/widgets/event_tiles/event_action_card.dart:11` | Shared full-width lifecycle/action event card. Renders status badges, optional carousel position/accessory, title/subtitle, structured `CatchMetaDotRow` lines, and full-width action buttons for attendee focus and host-operation cards without owning routing or mutations. |
| `EventCompactRow` | `lib/events/presentation/widgets/event_tiles/event_compact_row.dart:14` | Dense tappable event row with date pill, event title, location subtitle, shared meta row, optional status badge, and chevron. Used where an event needs to be represented inside compact activity/notification surfaces. |
| `EventDateMarker` | `lib/events/presentation/widgets/event_tiles/event_date_marker.dart:9` | Shared calendar week/month day marker with selected, today, disabled, and has-event-dot states. Calendar date cells use this instead of local one-off day widgets. |
| `EventDateRailCard` | `lib/events/presentation/widgets/event_tiles/event_date_rail_card.dart:18` | Shared date-rail event card extracted from the Explore mixed-feed row. Renders a clipped ticket silhouette with seam cutouts, activity-colored weekday/day/month tear-off stub, subtle perforation seam, compact activity stamp, optional supporting label, themed event-display title, time/price line, single capacity copy line, optional full-card Hero transition, and optional shared status pill for non-full states across Explore event rows plus agenda surfaces. `stripPosition` lets This week rows join into a continuous ticket strip while preserving the outer notches only on the first/last card, and single tickets paint a custom `CatchElevation.physicalShadow` behind an elevation-zero `PhysicalShape` so debug/golden rendering stays aligned with the intended soft lift rather than showing Flutter's shadow-debug outline. |
| `EventAgendaTile` | `lib/events/presentation/widgets/event_tiles/event_agenda_tile.dart:6` | Agenda/list adapter for Calendar, Saved events, and club schedules. It maps `EventTileData` into `EventDateRailCard`, preferring club name in global contexts and meeting point in club-local schedules, while suppressing the old redundant `VIEW` and `OPEN` badge language through `eventTileCardStatusLabel`. |
| `EventAgendaList` | `lib/events/presentation/widgets/event_agenda_list.dart:9` | Box-facing agenda list for events grouped by day. Sorts by start time by default, with `preserveInputOrder` for callers that precompute semantic order plus optional club-name/status builders, and renders `EventAgendaTile` directly. |
| `EventDetailOverviewSection` | `lib/events/presentation/widgets/event_detail_overview_section.dart:10` | Handoff-ordered event-detail body stack: The plan, Why you might click, Itinerary, Photos when available, Where, How sign-ups work, and Good to know. Uses `CatchDesignSection` plus event-detail primitives while retaining requirements, expectation, cancellation, and settlement policy copy from the existing event policy model. |
| `EventDetailSocialSection` | `lib/events/presentation/widgets/event_detail_social_section.dart:10` | Social context sections for the loaded event detail body: Who's going and Reviews, both composed with `CatchDesignSection`. The roster supports a guest lock prompt and signed-in roster view; review writing requires an attended `EventParticipation` and an event end time that has passed. |
| `MapOverlayControls` | `lib/events/presentation/widgets/map_overlay_controls.dart:5` | Floating safe-area controls for chromeless map surfaces. Provides rounded back affordance plus optional trailing/below content for map actions such as create-event confirm/search. |
| `EventDetailsStep` | `lib/hosts/presentation/event_management/widgets/event_details_step.dart:16` | First host create-event step. Renders event photos, activity type, optional custom format/structure, distance, pace, and description with handoff `SelectChip` choices and `CatchTextField` inputs. Activity type choices carry their own activity pigment; format and pace choices inherit the selected activity accent. |
| `EventPolicyStep` | `lib/hosts/presentation/event_management/widgets/event_policy_step.dart:50` | Host create/edit event policy step for capacity, base price, admission preset, invite code, dynamic pricing, cancellation policy, eligibility bounds, and host payout copy. Uses handoff `SelectChip` selectors for admission/cancellation and `CatchToggle` for cohort caps and demand pricing. |
| `EventSuccessStep` | `lib/hosts/presentation/event_management/widgets/event_success_step.dart:9` | Final host create-event live-guide step. Wraps `EventSuccessDefaultsPanel`, passing the current event capacity so structure defaults can estimate pods/teams from the booking policy while keeping live-guide setup separate from policy editing. |
| `StepperFooter` | `lib/hosts/presentation/widgets/stepper_footer.dart:5` | Host form bottom action footer. Blends into the page background, renders draft as a ghost action when supplied, and gives the primary action a full-width lane so long labels scale within available width. |
| `HostPaymentAccountCard` | `lib/hosts/presentation/payments/host_payment_account_card.dart:22` | Host-only payout readiness card for the Host app Clubs tab. Watches the signed-in host payment account, opens the provider setup/refresh flow through the payment repository seam, and stays out of public club detail. |

---

## Event Success

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessManualQaScreen` | `lib/event_success/presentation/event_success_manual_qa_screen.dart:38` | Dev/staging manual QA harness. Uses handoff `SelectChip` choices for the fixture event-format selector and `CatchToggle` rows for attendee opt-out settings while rendering the canonical `HostEventManageScreen` beside the production attendee companion from one synchronized in-memory fixture store. The host pane overrides the exact Host Manage providers for event, roster, profile, event-success, and attendance-table state so Setup, Live, Report, and participation table changes stay covered without a duplicate host QA fixture. |
| `_FirstHelloCheckInCard` | `lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart:3` | Attendee companion First Hello mission card. Renders a server/manual-QA-provided target, one short question, private answer chips, completion, and a fallback action without leaking broader attendee data. |
| `EventSuccessHostPanel` | `lib/event_success/presentation/event_success_host_screen.dart:249` | Reusable host event-success panel with Setup, Live, and Report bodies. Setup derives recommendations from the event activity profile, keeps the editor visible for QA even when an unsaved started event is locked, and hides unsupported tools behind progressive disclosure. Live mode opens with one Live now console that combines the active stage, progress, attendee-facing state, optional embedded editable roster, current-step controls, and previous/next navigation before lower-priority supporting controls for wingman requests, reveal clues, conversation cues, assignments, and reveal controls. When Host Manage embeds the roster, the arrival control becomes a QR-only card instead of repeating attendance totals already shown by Live now plus the roster. Report mode summarizes signal quality from feedback response, assignment coverage, opt-outs, and wingman requests. Standalone uses `CatchOptionGroup` for its Setup / Live / Report picker; Host Manage passes a fixed lifecycle section and hides the inner picker. |
| `EventSuccessDefaultsPanel` | `lib/event_success/presentation/event_success_defaults_panel.dart:14` | Shared event-success defaults form. Used by club create/edit and create event to toggle setup with a handoff `CatchToggle`, normalize activity-specific recommendations against an optional target attendee count, and show a preset-review card before advanced controls. Guide notes, match clue questions, structure, and tools are progressively disclosed; questionnaire ownership is separate from tool switches, and wingman/openers are derived from module selection instead of repeated booleans. |
| `EventSuccessHostSetupFlow` | `lib/event_success/presentation/event_success_feature_blocks.dart:36` | Event-success concept-lab setup flow. Lets product iterate across playbooks, shows the selected playbook summary, embeds `EventSuccessStructureConfigEditor`, and toggles modules/readiness issues from an in-memory draft. Uses handoff `SelectChip` choices for the format selector. |
| `EventSuccessSetupBody` | `lib/event_success/presentation/event_success_setup_body.dart:52` | Shared event-success setup body used by create-event defaults and Host Manage setup. Renders preset review, guide notes, lifecycle stage cards, structure, advanced match-clue questions, and safety footer while emitting draft changes to its owner. Uses handoff `CatchToggle` rows for module recommendations, `SelectChip` choices for rotation cadence / reveal countdown / match-clue mode, and tokenized `CatchSurface` disclosure rows for Guide notes and Advanced sections instead of Material `ExpansionTile`. |
| `EventSuccessFeedbackForm` | `lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart:3` | Attendee companion post-event feedback form. Captures private welcome/structure ratings, people-met count, private note, and a Catch-private safety/comfort review flag. The safety/comfort flag uses handoff `CatchToggle` row composition, and submissions continue through `EventSuccessController.feedbackMutation`. |
| `_SetupTab` | `lib/event_success/presentation/host_parts/event_success_host_setup.dart:3` | Event-success setup form for playbook selection, target attendee count, host goal, attendee prompt, structure config, module toggles, reveal-clue opt-in, wingman requests, and setup save/ensure mutations. Essentials render first; advanced structure, tool, and delivery controls are progressively disclosed, with multiline guide-note fields and host-facing group/team/table language. |

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessCompanionScreen` | `lib/event_success/presentation/event_success_companion_screen.dart:444` | Attendee companion surface that resolves the runtime-selected live moment into a full-screen stage with moment-specific color, motif, privacy copy, keyed transitions, native live effects, optional First Hello arrival missions, reveal-safe assignment display, and a private post-event afterglow recap. Keeps the single-moment runtime model intact rather than restoring a stacked dashboard. |
| `_CompatibilityQuestionnaireSection` | `lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart:3` | Attendee companion quick-question clue ritual for event-scoped reveal clues. Focuses one question at a time, uses selected answer chips and progress, then saves through the stage action dock while preserving questionnaire privacy language. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessHostSection` | `lib/event_success/presentation/event_success_host_screen.dart:42` | Host Manage section loader for event-success data. It resolves the plan first, synthesizes a default plan until setup is saved, and skips roster/report/assignment/preference/wingman streams while no saved guide exists so Live and Report can render unavailable-guide states immediately. Host Manage can pass an embedded live roster so check-in correction remains available inside the Live now flow, including unavailable-guide states. |
| `EventSuccessLiveRevealHostCard` | `lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_host.dart:3` | Host Live-mode reveal console for structured assignment flows. Shows a kinetic countdown, round queue, assignment clues, and host actions to start countdown, reveal now, or reset reveal state. |
| `EventSuccessLiveRevealAttendeeCard` | `lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_attendee.dart:3` | Companion-side reveal surface for pods and rotations. Hides assignment details until the host reveal state unlocks the round, uses a stronger countdown/waiting/unlocked presentation, then shows partners or podmates with opt-out controls intact. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `EventSuccessLabScreen` | `lib/event_success/presentation/event_success_lab_screen.dart:34` | Dev/staging-only event-success product lab. Labels the route as preview-only WIP, renders playbook cards, the module grid, actual feature blocks, and host-coach samples without Firestore writes or booking changes. Playbook module metadata uses shared `CatchBadge` labels while interactive setup choices remain on their own handoff controls. |
| `_PrivateAfterglowRecapCard` | `lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart:3` | Private attendee-only post-event recap artifact. Summarizes the event, opener availability, and optional saved feedback while explicitly avoiding public share pressure or host-visible personal details. |
| `EventSuccessPromptCard` | `lib/event_success/presentation/event_success_feature_blocks.dart:616` | Shared prompt card used by event-success preview and attendee companion surfaces. |
| `EventSuccessQuestionnaireConfigEditor` | `lib/event_success/presentation/event_success_questionnaire_config_editor.dart:15` | Shared questionnaire-template editor for host setup and create-event defaults. Lets hosts choose reusable question packs or switch to custom questions with handoff `SelectChip` choices, then previews the active pack with badges and question rows. Can open the custom-question builder inline or in a bottom sheet depending on the owning surface. |
| `EventSuccessStructureConfigEditor` | `lib/event_success/presentation/event_success_structure_config_editor.dart:10` | Shared structure editor for host setup and create-event defaults. Keeps internal unit modeling out of copy by exposing flow type, people-per-team/table/pod labels, auto versus fixed counts, and optional cadence/countdown controls supplied by the owning surface. Uses handoff `SelectChip` choices for flow type, count mode, repeat policy, and assignment goals. |
| `EventSuccessConversationCueCard` | `lib/event_success/presentation/event_success_feature_blocks.dart:655` | Shared conversation cue card used by host Live mode and preview surfaces for live prompts and post-match opener suggestions. The staged attendee companion uses its own copyable cue rows. |
| `EventSuccessPostEventReport` | `lib/event_success/presentation/event_success_feature_blocks.dart:266` | Shared post-event report surface. Shows report metric pills, `Working well` strengths, and coach recommendation tiles while host-facing report copy stays aggregate and avoids personal attendee intelligence. |
| `_HostReportSignalGrid` | `lib/event_success/presentation/host_parts/event_success_host_report.dart:114` | Host report signal-quality summary using `EventSuccessMetricPill` and `CatchBadge` primitives for feedback response, assignment coverage, opt-outs, and wingman requests. |
| `EventSuccessMetricPill` | `lib/event_success/presentation/event_success_feature_blocks.dart:865` | Shared percentage pill for event-success reports and lab/preview metrics. |
| `EventSuccessRecommendationTile` | `lib/event_success/presentation/event_success_feature_blocks.dart:817` | Shared recommendation tile for post-event reports and the event-success lab coach sample. |
| `EventSuccessDarkPill` | `lib/event_success/presentation/event_success_feature_blocks.dart:894` | Shared dark hero pill for event-success lab and contextual preview heroes. |

---

## Calendar

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CalendarScreen` | `lib/calendar/presentation/calendar_screen.dart:21` | Calendar route for planned events. Merges booked events with future saved events, labels mixed agenda rows as JOINED/SAVED, uses one sliver-native scroll surface, and anchors the header to the next upcoming event or current week. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CalendarDateHeader` | `lib/calendar/presentation/calendar_screen.dart:265` | Calendar header inside the route's sliver scroll surface: month label, collapsible week/month date selector, and `CatchSurface` stats row. |
| `_CalendarTitleRow` | `lib/calendar/presentation/calendar_screen.dart:366` | Header title row with the current month/year label and compact Today action. |
| `_CalendarDateHeaderDelegate` | `lib/calendar/presentation/calendar_screen.dart:400` | Fixed-height sliver delegate that pins the calendar date header and adds a bottom divider while content overlaps. |
| `_CalendarStatsHeader` | `lib/calendar/presentation/calendar_screen.dart:439` | Compact planned/distance/next summary row rendered under the date selector. |
| `_WeekStrip` | `lib/calendar/presentation/calendar_screen.dart:490` | Horizontal week strip showing seven `EventDateMarker.weekStrip` cells. Anchors to the next upcoming event, or to the current week when there is no upcoming event. |
| `_MonthGrid` | `lib/calendar/presentation/calendar_screen.dart:534` | Expanded month selector that renders six rows of `EventDateMarker.monthGrid` cells with selected, today, disabled, and has-event states. |
| `_StatDivider` | `lib/calendar/presentation/calendar_screen.dart:611` | Divider between stat items. |
| `_CalendarMessage` | `lib/calendar/presentation/calendar_screen.dart:626` | Calendar empty/error state rendered through `CatchEmptyState`. |
| `_CalendarEventSummary` | `lib/calendar/presentation/calendar_screen.dart:649` | Private view model for calendar display order and header stats. De-duplicates signed-up/saved events, keeps only future saved-only events, puts upcoming events first, uses current week as the fallback anchor, and exposes `nextEvent`. |

---

## Payments

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PaymentConfirmationScreen` | `lib/payments/presentation/payment_confirmation_screen.dart:32` | Post-payment route for the Booking handoff. Loads event context, branches pending external checkout into the handoff checkout sheet, and delegates completed payments to `EventJoinedCelebrationScreen` with payment quick actions, heads-up copy, stronger friend-invite sharing, and the stable Back home key. |
| `_PendingCheckoutBody` | `lib/payments/presentation/payment_confirmation_screen.dart:68` | Pending external-checkout adapter. Watches the payment record so a completed provider return auto-promotes into confirmation; otherwise renders the dimmed event backdrop plus `_CheckoutSheet` pending/failed state with checkout, payment-history, and back-to-event actions. |
| `_CheckoutEventBackdrop` | `lib/payments/presentation/payment_confirmation_screen.dart:146` | Booking checkout backdrop behind the pending sheet. Uses the event activity pigment gradient, event title, basic date/location/price summary, and `CatchOpacity.paymentCheckoutScrim` overlay from the route. |
| `_CheckoutSheet` | `lib/payments/presentation/payment_confirmation_screen.dart:203` | Flutter counterpart to the handoff `CheckoutSheet`: bottom-sheet surface with grabber, receipt/warning medallion, headline/body copy, event + price summary, Pending/Failed `CatchBadge`, provider checkout CTA when available, payment-history action, and back-to-event ghost action. |
| `_ConfirmationBody` | `lib/payments/presentation/payment_confirmation_screen.dart:371` | Thin payment confirmation adapter that composes `EventJoinedCelebrationScreen` with paid-event supplemental children and router actions. |
| `PaymentConfirmationKeys` | `lib/payments/presentation/payment_confirmation_keys.dart:3` | Stable semantic keys for confirmation quick actions, referral share, and sticky back-home CTA. |
| `PaymentHistoryScreen` | `lib/payments/presentation/payment_history_screen.dart:20` | List of past payment transactions. Watches `watchPaymentsForUserProvider`, renders `_PaymentTile` items, and shows transaction details in `CatchBottomSheetScaffold`. |
| `_PaymentList` | `lib/payments/presentation/payment_history_screen.dart:42` | The list view of payment tiles. |
| `_PaymentTile` | `lib/payments/presentation/payment_history_screen.dart:74` | Single semantic payment transaction row — amount, date, run name, and status. Tapping opens the detail bottom sheet. |
| `PaymentHistoryKeys` | `lib/payments/presentation/payment_history_keys.dart:3` | Stable semantic payment-history tile keys for tests and future automation. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_QuickActions` | `lib/payments/presentation/payment_confirmation_screen.dart:86` | Row of quick-action tiles (add to calendar, directions, invite a friend) shown inside the run-joined celebration. |
| `_ActionTile` | `lib/payments/presentation/payment_confirmation_screen.dart:124` | Private icon-based `CatchSurface` quick-action tile. Keep private until this semantic component has a second concrete use. |
| `_HeadsUp` | `lib/payments/presentation/payment_confirmation_screen.dart:166` | `CatchSurface` info box about arrival/run-day expectations. |
| `_ReferralBanner` | `lib/payments/presentation/payment_confirmation_screen.dart:197` | Tappable `CatchSurface` referral banner shown inside the run-joined celebration. |

---

## Safety / Settings

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SettingsScreen` | `lib/safety/presentation/settings_screen.dart:31` | Full settings screen. Manages optimistic notification toggle state, wraps settings and sign-out mutations in shared snackbar error feedback, delegates preference/deletion/unblock writes to `SettingsController`, owns sign out through `AuthSessionController`, and composes the handoff Account / Notifications / Privacy & safety / About / Log out page-surface sections with `SettingsRow` and `CatchToggle` while retaining real history, host-app, blocked-user, and delete-account actions. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `_BlockedAccountsSection` | `lib/safety/presentation/settings_screen.dart:575` | Privacy & safety footer listing blocked accounts under the handoff `Blocked users` row. Uses `CatchLoadingIndicator` for loading, `CatchEmptyState` for empty/error states, and renders `_BlockedAccountTile` rows for blocked users. |
| `_BlockedAccountTile` | `lib/safety/presentation/settings_screen.dart:642` | Single blocked account row. Resolves the blocked user's public profile, renders a `PersonRow`, and routes the semantic unblock button through `SettingsController.unblockUserMutation`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_SettingsSection` | `lib/safety/presentation/settings_screen.dart:529` | Private Settings template section helper. Injects the first-row/no-divider and subsequent-row/inset-divider contract into `SettingsRow`, draws section hairlines directly on the page surface, and optionally renders a footer for blocked-account content. |
| `SettingsKeys` | `lib/safety/presentation/settings_keys.dart:3` | Stable semantic keys for account action rows, settings switches, delete-account row, and blocked-user unblock buttons. |
| `showConfirmDangerDialog` | `lib/core/widgets/confirm_danger_dialog.dart:4` | Shared destructive confirmation dialog helper used by safety/account actions such as block and delete-account confirmations. Delegates to `showCatchAdaptiveDialog` so iOS gets Cupertino alert chrome and Android/non-iOS platforms keep Material alert chrome. |
| `showBlockUserDialog` | `lib/core/widgets/block_user_dialog.dart:4` | Safety-specific block confirmation helper. Supplies block copy and delegates to `showConfirmDangerDialog`, so public profile and chat block actions share the handoff confirm-card composition and platform-adaptive destructive action behavior. |

---

## Force Update

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `UpdateRequiredScreen` | `lib/force_update/presentation/update_required_screen.dart:15` | Blocking full-screen prompting the user to update the app. Reads store URLs from `AppVersionConfig`, delegates store URL selection/launching to `UpdateRequiredController`, and shows a snackbar if launch fails. The user cannot dismiss this screen. |
| `UpdateRequiredController` | `lib/force_update/presentation/update_required_controller.dart:18` | Provider-backed controller for choosing the platform store URL and launching it through an injectable `StoreLauncher`. |

---

## Reviews

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_WriteReviewSheet` | `lib/reviews/presentation/write_review_sheet.dart:39` | Bottom sheet for writing, editing, or deleting an event review. Requires a concrete `eventId`, uses `CatchBottomSheetScaffold`, semantic star/action keys, inline mutation errors, and `WriteReviewController` submit/delete mutations. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ClubReviewsSection` | `lib/reviews/presentation/reviews_section.dart:19` | Read-only club review aggregate. Shows the latest three reviews, uses the compact inline empty state, and never opens the write/edit sheet. |
| `EventReviewsSection` | `lib/reviews/presentation/reviews_section.dart:44` | Event-scoped reviews with write/edit CTA for attended participants. Uses the same compact inline empty-state primitive as club reviews; this is the only page-level review section that should open `WriteReviewSheet`. |
| `ReviewsPreviewSection` | `lib/reviews/presentation/reviews_section.dart:121` | Shared read-only preview list: header, aggregate rating, compact/stacked empty-state configuration, top-N review cards, and optional see-all sheet. Callers supply edit callbacks only when the parent surface is event-scoped. |
| `ReviewsHistoryScreen` | `lib/reviews/presentation/reviews_history_screen.dart:19` | Profile-owned review history screen. Lists the current user's reviews newest-first and opens the shared edit review sheet for event-backed reviews. |
| `ReviewCard` | `lib/reviews/presentation/reviews_section.dart:226` | Single tokenized review surface with reviewer avatar/name, star rating, optional comment, and optional edit action for the current user's own review. |
| `StarRating` | `lib/reviews/presentation/star_rating.dart:5` | Read-only token-colored 5-star display. Clamps rating values into the valid visual range. |
| `StarRatingPicker` | `lib/reviews/presentation/star_rating.dart:31` | Semantic/tappable 5-star picker. Supports caller-provided keys for stable widget tests and exposes tooltip/semantics labels per rating. |
| `ReviewKeys` | `lib/reviews/presentation/review_keys.dart:3` | Stable semantic keys for review write/edit/delete/submit actions, comment field, see-all button, and rating stars. |

---

## Summary

| Type | Count |
|---|---|
| `ConsumerStatefulWidget` | 19 |
| `ConsumerWidget` | 42 |
| `StatefulWidget` | 4 |
| `StatelessWidget` | ~150 |

---

## Consolidation Candidates

Keep this section current and conservative. It is for durable consolidation
ideas that still appear valid after the widget cleanup passes, not for active
status. Move any selected item into `docs/audit_registry/backlog.json` before
implementing it.

### High Signal

| Candidate | Current State | Recommended Direction |
|---|---|---|
| `FieldLabel` | Thin create-event wrapper around `CatchFormFieldLabel(large: true)`. | Delete only if call sites stay clearer with direct `CatchFormFieldLabel`; otherwise keep as a create-event semantic wrapper. |
| `_DashboardLoadingScreen`, `_RouterLoadingScreen`, route-level loading scaffolds | Several screens still create a full-screen loading scaffold by hand. | Consider `CatchLoadingScreen` only if another pass touches two or more route-level loading screens together. |
| `_DashboardMessageScreen`, route-level error/message scaffolds | Message screens are similar but not identical. | Consider `CatchMessageScreen` with optional title/body/action if repeated route-level message screens continue to grow. |
| `ChatsSliverHeader`, `ExploreSliverHeader` | Feature-specific pinned wrappers around `CatchBrowseHeader` still share structure. | Parameterize a shared browse-sliver wrapper only if a third feature needs the same title/search/action pattern. |
| `ProfileInfoChip` | Swipe profile chip overlaps conceptually with `CatchChip`, but has overlay styling needs. | Extend `CatchChip` only if overlay-style info chips recur outside swipes. |

### Watch, Do Not Force

| Candidate | Reason To Wait |
|---|---|
| Feature empty-state wrappers | Most now delegate to `CatchEmptyState`. Keep wrappers when they encode feature-specific copy/content semantics; inline only when the wrapper adds no meaning. |
| `StatColumn`, `RunStatCell`, `HostStatChip` | They share a value-over-label concept, but host/profile/local chips still have different surface ownership. Detail-page metric rails should use `CatchMetricStrip` instead of new one-off stat rows. |
