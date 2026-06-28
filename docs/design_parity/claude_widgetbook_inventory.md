---
doc_id: claude_widgetbook_inventory
version: 0.1.11
updated: 2026-06-23
owner: product_design_parity
status: active
---

# Claude Design vs Widgetbook Inventory

## Purpose

This tracker compares inventory only. It does not judge visual fidelity,
interaction quality, copy, layout, or pixel parity yet.

The goal of this pass is to answer:

1. What reusable primitives and foundation tokens exist in the Claude Design
   export?
2. What primitives are represented in local Widgetbook?
3. What primitives or token specimen pages exist in one side but not the other?
4. Which names are direct matches, which are aliases, and which need product
   decisions before implementation work starts?

## Source Snapshot

| Source | Path | Role |
|---|---|---|
| Claude Design manifest | `/Users/suvratgarg/Downloads/Catch Design System (2)/_ds_manifest.json` | Canonical exported Claude component, token, template, font, theme, and card inventory. |
| Claude reusable components | `/Users/suvratgarg/Downloads/Catch Design System (2)/components/` | Primary reusable design component layer. The Claude README names this folder as the single source for UI primitives. |
| Claude foundation CSS | `/Users/suvratgarg/Downloads/Catch Design System (2)/colors_and_type.css` | CSS variables, spacing, radius, shadows, typography roles, font roles, photo grade, and dark theme. |
| Claude templates | `/Users/suvratgarg/Downloads/Catch Design System (2)/templates/` | Screen blueprints composed from components. Not treated as primitive inventory unless a reusable component is exported in the manifest. |
| Local Widgetbook | `widgetbook/lib/main.directories.g.dart` | Generated source of truth for currently visible Widgetbook entries. |
| Local Widgetbook sources | `widgetbook/lib/primitives/core_catalog_use_cases.dart`, `widgetbook/lib/primitives/primitive_contract_use_cases.dart` | Annotated use cases for broad catalog and formal contract previews. |
| Local component contracts | `design/components/catch.components.json` | Current allowed cross-tool component contract registry. |
| Local design tokens | `design/tokens/catch.tokens.json` | DTCG-shaped token source mirrored into generated Dart/CSS. |
| Local Dart token/style sources | `lib/core/theme/catch_tokens.dart`, `lib/core/theme/catch_spacing.dart`, `lib/core/theme/catch_text_styles.dart`, `lib/core/theme/catch_icons.dart`, `lib/core/theme/activity_palette.dart` | Runtime token, gap, style, icon, and activity palette implementations. |

## Inventory Counts

| Inventory | Count | Notes |
|---|---:|---|
| Claude exported manifest symbols | 107 | Includes reusable components plus exported constants/nested components such as `TONES`, `ACTIVITY_KINDS`, `FieldGroup`, `StatCard`, and `RosterRow`. |
| Claude component directories | 97 | Directory count under `components/`; some directories export multiple symbols. |
| Claude templates | 27 | Screen blueprints, not primitive inventory for this pass. |
| Claude CSS token entries in manifest | 132 | 91 color, 20 spacing, 14 radius, 3 shadow, 4 font. Typography roles are CSS classes, not token entries in the manifest count. |
| Local Widgetbook entries | 216 | Generated use-case builders in `widgetbook/lib/main.directories.g.dart`; includes broad catalog entries, formal primitive contracts, foundation specimens, async loading helpers, and feature/screen previews. |
| Local Widgetbook unique component names | 201 | Generated component names in `widgetbook/lib/main.directories.g.dart`; 211 component occurrences before duplicate names collapse. |
| Local formal component contracts | 18 | `design/components/catch.components.json`. |
| Local DTCG token leaves | 93 | 56 color, 2 gradient, 28 dimension, and 7 fontFamily leaves when inheriting parent `$type` values. |

## Foundation Inventory

### Claude Foundation Tokens

Claude foundation source: `colors_and_type.css`.

Color variables:

- Base light/dark: `--bg`, `--surface`, `--raised`, `--overlay`, `--ink`,
  `--ink2`, `--ink3`, `--line`, `--line2`, `--primary`, `--primary-ink`,
  `--primary-soft`, `--like`, `--pass`.
- Functional: `--success`, `--warning`, `--danger`, `--gold`.
- Activity pigments: `--act-social-run-accent/deep/soft`,
  `--act-running-accent/deep/soft`, `--act-walking-accent/deep/soft`,
  `--act-pickleball-accent/deep/soft`, `--act-padel-accent/deep/soft`,
  `--act-tennis-accent/deep/soft`, `--act-badminton-accent/deep/soft`,
  `--act-cycling-accent/deep/soft`, `--act-spin-accent/deep/soft`,
  `--act-yoga-accent/deep/soft`, `--act-strength-accent/deep/soft`,
  `--act-pub-quiz-accent/deep/soft`, `--act-bar-crawl-accent/deep/soft`,
  `--act-dinner-accent/deep/soft`, `--act-singles-accent/deep/soft`,
  `--act-open-accent/deep/soft`.

Spacing and layout variables:

- Scale: `--s0`, `--s1`, `--s2`, `--s3`, `--s4`, `--s5`, `--s6`, `--s7`,
  `--s8`, `--s9`, `--s10`, `--s11`, `--s12`, `--s16`.
- Micro: `--micro2`, `--micro3`, `--micro6`, `--micro10`, `--micro14`,
  `--micro18`.
- Screen gutter: `--screen-px`, `--screen-pt`, `--screen-pb`.

Radius variables:

- Base: `--radius-none`, `--radius-xs`, `--radius-sm`, `--radius-md`,
  `--radius-lg`, `--radius-pill`.
- Role-specific: `--radius-info-tile`, `--radius-interactive-tile`,
  `--radius-segmented-inner`, `--radius-segmented-outer`,
  `--radius-hero-card`, `--radius-profile-hero-bottom`,
  `--radius-profile-photo-bottom`, `--radius-attended-tile`.

Stroke, elevation, and media variables:

- Stroke: `--stroke-hairline`, `--stroke-underline`, `--stroke-selection`,
  `--stroke-club-seal`.
- Shadows: `--shadow-card`, `--shadow-raised`, `--shadow-overlay`.
- Media classes: `.catch-grade`, `.catch-grade-warm`.

Font variables:

- `--font-voice`, `--font-function`, `--font-data`, `--font-head`.
- Fonts present in manifest: Archivo variable, IBM Plex Mono 400/500/600/700.

Typography roles:

- Voice/head: `.t-display`, `.t-headline`, `.t-headline-s`, `.t-title-l`,
  `.t-profile-answer`, `.t-prose-l`, `.t-prose-m`, `.t-event-display`,
  `.t-event-title`, `.t-console-title`, `.t-hint`, `.t-name`.
- Function: `.t-section-title`, `.t-title-s`, `.t-label-l`,
  `.t-body-lead`, `.t-body-l`, `.t-body-m`, `.t-body-s`, `.t-field-label`,
  `.t-button`, `.t-chat`.
- Data: `.t-kicker`, `.t-kicker-lg`, `.t-mono-label`, `.t-mono`,
  `.t-numeric-l`, `.t-stat-display`, `.t-meta`, `.t-badge`, `.t-code`.

Claude foundation preview pages:

- `preview/activity-emblems.html`
- `preview/checklist.html`
- `preview/club-polaroid.html`
- `preview/color-activity-anatomy.html`
- `preview/color-activity.html`
- `preview/color-dark.html`
- `preview/color-paper-ink.html`
- `preview/color-semantic.html`
- `preview/data-pair.html`
- `preview/elevation.html`
- `preview/photo-grade.html`
- `preview/radius.html`
- `preview/spacing-scale.html`
- `preview/type-body.html`
- `preview/type-data.html`
- `preview/type-function.html`
- `preview/type-voice.html`
- `preview/wordmark.html`

### Local Foundation Tokens

Local token and style sources:

- DTCG token roots: `theme`, `activity`, `space`, `radius`, `font`,
  `website`.
- Runtime theme/token classes: `CatchTokens`, `CatchSpacing`, `CatchGaps`,
  `CatchInsets`, `CatchRadius`, `CatchElevation`, `CatchOpacity`,
  `CatchStroke`, `CatchMotion`, `CatchLayout`, `CatchAspectRatio`,
  `CatchIcon`, `CatchMapPinColors`, `CatchStaticMapColors`,
  `CatchPaceColors`, `CatchClubColors`, `CatchPhotoGradeColors`,
  `CatchIconButtonColors`, `CatchWelcomeColors`,
  `CatchEventSuccessColors`, `CatchCelebrationColors`.
- Font and icon classes: `CatchFonts`, `CatchIcons`.
- Activity palette classes/constants: `ActivitySwatch`, `CatchActivity`,
  `ActivityPalette`, `activityOrder`, `glyphs`, `pigments`.

Local DTCG token leaves:

- `theme.light.color.*`, `theme.dark.color.*`, and `theme.*.gradient.heroGrad`.
- Activity accent leaves for `badminton`, `barCrawl`, `cycling`, `dinner`,
  `openActivity`, `padel`, `pickleball`, `pubQuiz`, `running`,
  `singlesMixer`, `socialRun`, `spinClass`, `strengthTraining`, `tennis`,
  `walking`, `yoga`.
- Space leaves: `space.s0`, `space.s1`, `space.s2`, `space.s3`, `space.s4`,
  `space.s5`, `space.s6`, `space.s7`, `space.s8`, `space.s9`, `space.s10`,
  `space.s11`, `space.s12`, `space.s16`, `space.micro2`, `space.micro3`,
  `space.micro6`, `space.micro10`, `space.micro14`, `space.micro18`.
- Radius leaves: `radius.none`, `radius.xs`, `radius.sm`, `radius.md`,
  `radius.lg`, `radius.pill`.
- Font leaves: `font.family.voice`, `font.family.function`,
  `font.family.data`, `font.family.head`, plus compatibility aliases.

Local gap constants:

- Height: `gapH2`, `gapH3`, `gapH4`, `gapH6`, `gapH8`, `gapH10`,
  `gapH12`, `gapH14`, `gapH16`, `gapH18`, `gapH20`, `gapH24`, `gapH28`,
  `gapH32`, `gapH36`, `gapH40`, `gapH44`, `gapH48`, `gapH64`.
- Width: `gapW2`, `gapW3`, `gapW4`, `gapW6`, `gapW8`, `gapW10`,
  `gapW12`, `gapW14`, `gapW16`, `gapW20`, `gapW24`, `gapW28`, `gapW32`,
  `gapW36`, `gapW40`, `gapW44`, `gapW48`, `gapW64`.

Local typography methods:

- Voice/head: `display`, `headline`, `headlineS`, `titleL`,
  `profileAnswer`, `proseL`, `proseM`, `clubDisplay`, `eventDisplay`,
  `eventTitle`, `consoleTitle`, `hint`, `name`.
- Function: `sectionTitle`, `titleS`, `fieldRowTitle`, `bodyLead`, `bodyL`,
  `bodyM`, `bodyS`, `appBarSubtitle`, `supporting`, `labelL`,
  `fieldLabel`, `labelM`, `labelS`, `statusLabel`, `buttonSm`, `buttonMd`,
  `button`, `buttonLg`, `avatarCount`, `otpDigit`, `chatMessage`, `chat`,
  `chatPreview`, `chatThreadContext`, `statCompact`, `transparentInput`.
- Data/special: `mapPinTime`, `mapPinCluster`, `kicker`, `kickerLg`,
  `monoLabel`, `monoLabelS`, `mono`, `numericLarge`, `numericMeta`, `meta`,
  `badge`, `code`, `statDisplay`, `clubMemberSeal`, `debugDetails`.

Foundation inventory gaps:

- Claude has standalone preview pages for spacing, radius, elevation, colors,
  typography roles, data pairs, photo grade, wordmark, and activity emblems.
- Widgetbook now has dedicated foundation specimen pages for semantic light/dark
  color roles, activity pigments and glyphs, spacing scale, semantic gaps,
  inset roles, radius, elevation/shadows, opacity roles, typography roles, icon
  scale, media aspect ratios, stroke widths, motion durations/curves, data-pair
  examples, photo-grade decisions, and the typographic Archivo wordmark under
  `[Foundation tokens]/Core`.
- `check_widgetbook_contract_refs.mjs` now gates the eight required foundation
  specimen pages so token-family review surfaces cannot silently disappear from
  generated Widgetbook output.
- No standalone foundation specimen page is currently missing from Widgetbook;
  the remaining foundation work is detailed value/visual comparison and
  local-only token classification.
- Local Dart has many role-specific radius/layout constants that are not present
  in `design/tokens/catch.tokens.json`; Claude CSS has role-specific radius
  variables such as `--radius-info-tile` and `--radius-hero-card` that are also
  not represented as first-class DTCG leaves.

## Claude Design Component Inventory

### Activity

- `ACTIVITY_KINDS`
- `ACTIVITY_ORDER`
- `ActivityArt`
- `ActivityAvatar`
- `ActivityChip`
- `DistanceRing`
- `MapPin`

### Booking

- `Celebration`
- `CheckoutSheet`
- `ConflictSheet`

### Clubs

- `ClubArt`
- `ClubDock`
- `ClubHero`
- `ClubPhotos`
- `ClubPolaroid`
- `ContactRow`
- `HostRow`
- `ReviewRow`

### Core

- `AppBar`
- `Badge`
- `Button`
- `Callout`
- `Chip`
- `CodeInput`
- `ConfirmDialog`
- `DateRangePicker`
- `EmptyState`
- `ExpandingSearch`
- `FacePile`
- `Field`
- `FieldGroup`
- `IconButton`
- `FieldGroup`
- `FieldRow`
- `Kicker`
- `MapPicker`
- `Menu`
- `OptionCard`
- `OptionGroup`
- `Panel`
- `PhotoGrid`
- `PhotoStripField`
- `PrivacyBadge`
- `ScreenBody`
- `SearchField`
- `Section`
- `SectionLabel`
- `SectionStack`
- `SegPill`
- `SelectChip`
- `Sheet`
- `SoftBand`
- `MetricStrip`
- `StatusBar`
- `StepHeader`
- `Stepper`
- `TabDock`
- `TextField`
- `TONES`

### Dashboard

- `DashboardEventCard`
- `EventLifecycleRow`
- `MetricGrid`
- `NeedsYouCard`
- `NeedsYouQueue`
- `NextUpHero`
- `QuickActions`
- `StatCard`
- `StrideCard`
- `TrendStrip`

### Events

- `AvatarStack`
- `BookingDock`
- `DateTicket`
- `EventHero`
- `EventTicket`
- `HintList`
- `HostCard`
- `Itinerary`
- `JourneySteps`
- `MapCard`
- `MechanismList`
- `PhotoStrip`
- `TicketStub`

### Explore

- `CountPill`
- `CoverStory`
- `CrossPathsCard`

### Hosting

- `LiveConsole`
- `OrganizerHeader`
- `RosterRow`
- `RosterTable`
- `RosterTiles`
- `RotationCard`

### Messaging

- `BlastComposer`
- `ChatBubble`
- `ChatComposer`
- `ChatListTile`
- `ChatThreadHeader`
- `ConversationTopBar`
- `PersonAvatar`

### Notifications

- `NotificationRow`

### Profile

- `CompatibilityList`
- `FactList`
- `ProfileHero`
- `ProfilePhoto`
- `ProfilePrompt`
- `RunningRhythm`

### Settings

- `RangeSlider`
- `Toggle`

## Claude Template Inventory

Templates are screen blueprints, not primitive inventory in this pass.

- `Booking`
- `Club Detail v2`
- `Dashboard`
- `Event Detail`
- `Explore`
- `Feature Drop`
- `Feature Drop Hosts`
- `Host Add Host`
- `Host App Events`
- `Host App Inbox`
- `Host App Insights`
- `Host App Manage`
- `Host App Organizer`
- `Host App Today`
- `Host Create Club`
- `Host Create Event`
- `Host Create Event Success`
- `Host Dialogs`
- `Host Draft Picker`
- `Host Edit Club`
- `Host Edit Event`
- `Host Payouts Handoff`
- `Messaging`
- `Notifications`
- `Onboarding v2`
- `Profile`
- `Settings and Filters`

## Local Widgetbook Inventory

### Core Catalog

Actions:

- `CatchTextButton`

Activity:

- `CatchActivityArt`
- `CatchPersonAvatar` activity variant
- `CatchActivityChip`
- `CatchActivityMapPin`
- `CatchDistanceRing`

Data display:

- `CatchMetaDotRow`
- `CatchMetricStrip`
- `CatchStatColumn`
- `CatchMetricStrip`

Device frames:

- `CatchStatusBar`

Event cards:

- `CatchEventSpotlightCard`
- `CatchEventTicketCard`
- `EventActivityBackdrop`
- `EventActivityStamp`
- `EventTicketPerforatedDivider`

Feedback:

- `CatchSurface.message`
- `CatchEmptyState`
- `CatchErrorBanner`
- `CatchErrorState`
- `CatchFrameworkErrorView`
- `CatchMutationErrorListener`
- `CatchNotice`
- `CatchNoticeHost`

Icon atoms:

- `CatchIconTile`

Inputs:

- `CatchCodeInput`
- `CatchControlShell`
- `CatchField.select`
- `CatchFormFieldLabel`
- `CatchNumberStepper`
- `CatchOtpCodeField`
- `CatchRangeSlider`

Layout:

- `ResponsiveBuilder`

Loading:

- `CatchAsyncValueSliver`
- `CatchAsyncValueView`
- `CatchLoadingIndicator`
- `CatchSkeleton`
- `CatchSkeletonList`
- `CatchStartupLoadingScreen`

Media:

- `CatchDetailHeroBackdrop`
- `CatchEventThumbnail`
- `CatchGradedImage`

Menus:

- `CatchActionMenu`
- `CatchMenu`

Moments:

- `CatchCelebrationScreen`

Navigation:

- `CatchPageDots`
- `CatchSliverHeader`
- `CatchStepHeader`
- `CatchStepProgress`
- `CatchTabDock`
- `CatchTopBarMenuAction`
- `CatchTopBarTabBar`

People:

- `CatchPersonAvatar`
- `CatchPersonAvatarStack`
- `CatchPersonRow`

Profile:

- `ProfileInfoTile`

Rows:

- `CatchDetailRow`
- `CatchSection`
- `CatchField`
- `CatchField`

Search:

- `CatchBrowseHeader`
- `CatchSearchField` expanding mode
- `CatchSearchField`

Sections:

- `CatchDaySectionHeader`
- `CatchSection`
- `CatchHorizontalRail`
- `CatchSection`
- `CatchSectionHeader`
- `CatchVerticalSection`

Selection:

- `CatchChipField<Labelled>`
- `CatchOptionGroup`
- `CatchSelectChip`
- `CatchToggle`

Sheets and footers:

- `CatchBottomCta`
- `CatchBottomDock`
- `CatchBottomSheetGrabber`
- `CatchBottomSheetScaffold`
- `CatchDraggableSheetShell`
- `CatchShareCardSheet`

Status extras:

- `CatchBadge`

Surfaces:

- `CatchSurface.card`
- `CatchSurface.tinted`

Typography:

- `CatchKicker`
- `CatchMonoLabel`
- `CatchSectionLabel`

### Core Primitives Contract Section

Actions:

- `CatchButton`
- `CatchIconButton`

Inputs:

- `CatchField`
- `CatchField`

Navigation:

- `CatchTopBar`

Selection:

- `CatchChip`
- `CatchOptionCard`
- `CatchSegmentedControl`

Status:

- `CatchBadge`

Surfaces:

- `CatchSurface`

### Local Formal Component Contracts

Current formal contract registry entries:

- `CatchBadge`
- `CatchButton`
- `CatchChip`
- `CatchField`
- `CatchIconButton`
- `CatchOptionCard`
- `CatchSegmentedControl`
- `CatchSurface`
- `CatchField`
- `CatchTopBar`

Claude handoff names in the formal contract registry:

- `Badge`
- `Button`
- `Chip`
- `Field`
- `IconButton`
- `OptionCard`
- `SegmentedControl`
- `Surface`
- `TextField`
- `TopBar`

## Component Match Table

These are inventory matches only. A row marked "alias" still needs visual and
state-by-state review before we call it aligned.

| Claude Design | Local Widgetbook | Match type |
|---|---|---|
| `ActivityArt` | `CatchActivityArt` | direct prefix |
| `ActivityAvatar` | `CatchPersonAvatar` activity variant | direct prefix |
| `ActivityChip` | `CatchActivityChip` | direct prefix |
| `AppBar` | `CatchTopBar` | alias |
| `AvatarStack` | `CatchPersonAvatarStack` | alias |
| `Badge` | `CatchBadge` | direct prefix |
| `Button` | `CatchButton` | direct prefix |
| `Callout` | `CatchSurface.message` | direct prefix |
| `Celebration` | `CatchCelebrationScreen` | alias |
| `Chip` | `CatchChip` | direct prefix |
| `CodeInput` | `CatchCodeInput` | direct prefix |
| `DistanceRing` | `CatchDistanceRing` | direct prefix |
| `EmptyState` | `CatchEmptyState` | direct prefix |
| `EventTicket` | `CatchEventTicketCard` | alias |
| `ExpandingSearch` | `CatchSearchField` expanding mode | direct prefix |
| `FacePile` | `CatchPersonAvatarStack` | alias |
| `Field` | `CatchField` | direct prefix |
| `IconButton` | `CatchIconButton` | direct prefix |
| `FieldGroup` | `CatchSection` | direct prefix |
| `FieldRow` | `CatchField` | direct prefix |
| `Kicker` | `CatchKicker` | direct prefix |
| `MapPin` | `CatchActivityMapPin` | alias |
| `Menu` | `CatchMenu` | direct prefix |
| `OptionCard` | `CatchOptionCard` | direct prefix |
| `OptionGroup` | `CatchOptionGroup` | direct prefix |
| `Panel` | `CatchSurface.card` | direct prefix |
| `PersonAvatar` | `CatchPersonAvatar` | direct prefix |
| `RangeSlider` | `CatchRangeSlider` | direct prefix |
| `SearchField` | `CatchSearchField` | direct prefix |
| `Section` | `CatchSection` | alias |
| `SectionLabel` | `CatchSectionLabel` | direct prefix |
| `SegPill` | `CatchSegmentedControl` | alias |
| `SelectChip` | `CatchSelectChip` | direct prefix |
| `Sheet` | `CatchBottomSheetScaffold` | alias |
| `SoftBand` | `CatchSurface.tinted` | direct prefix |
| `MetricStrip` | `CatchMetricStrip` | direct prefix |
| `StatusBar` | `CatchStatusBar` | direct prefix |
| `StepHeader` | `CatchStepHeader` | direct prefix |
| `Stepper` | `CatchNumberStepper` | alias |
| `TabDock` | `CatchTabDock` | direct prefix |
| `TextField` | `CatchField` | direct prefix |
| `Toggle` | `CatchToggle` | direct prefix |

## Claude Components Requiring Widgetbook Reconciliation

These are Claude exported manifest symbols that either still lack a Widgetbook
component entry by direct name/conservative alias, or were recently matched
through a source-backed Widgetbook entry. Rows marked source-backed are
represented in `widgetbook/lib/main.directories.g.dart`; remaining rows need
implementation search, product-scope decisions, or new local primitives.

### Likely Source Exists Or Source-Backed Entry Added

These have plausible Dart symbols in the repo or likely local equivalents, but
they still need inventory tracking until the direct/alias mapping is settled.

| Claude Design | Likely local source candidate | Current status |
|---|---|---|
| `BookingDock` | `EventBookingDock` | Source-backed Widgetbook entry added under `[Event detail]/Sections`; broad core catalog also exposes `EventDetailCta` dock states under `[Core catalog]/Event detail`. |
| `ConfirmDialog` | `CatchConfirmDialog` | Source-backed Widgetbook entry added under `[P3 utility]/Settings`. |
| `CountPill` | `CatchCountPill` | Source-backed Widgetbook entry added under `[Explore]/Sections`. |
| `CoverStory` | `CatchCoverStory` | Source-backed Widgetbook entry added under `[Explore]/Sections`. |
| `CrossPathsCard` | `CatchCrossPathsCard` | Source-backed Widgetbook entry added under `[Explore]/Sections`. |
| `FieldGroup` | `CatchSection` | Merged into the formal `catch.section` contract under `[Core primitives]/Sections`; no separate field-group Widgetbook page remains. |
| `HintList` | `EventDetailHintList` | Source-backed Widgetbook entry added under `[Core catalog]/Event detail`. |
| `HostCard` | `EventDetailHostCard` | Source-backed Widgetbook entry added under `[Core catalog]/Event detail`. |
| `Itinerary` | `EventDetailItinerary` | Source-backed Widgetbook entry added under `[Core catalog]/Event detail`. |
| `JourneySteps` | `CatchJourneySteps` | Formal `catch.journey_steps` contract under `[Core primitives]/Sections`; no duplicate catalog page remains. |
| `MapCard` | `EventDetailMapCard` | Source-backed Widgetbook entry added under `[Core catalog]/Event detail`. |
| `MechanismList` | `EventDetailMechanismList` | Source-backed Widgetbook entry added under `[Core catalog]/Event detail`. |
| `NotificationRow` | `NotificationRow` | Source-backed Widgetbook entry added under `[P3 utility]/Notifications`. |
| `PhotoStrip` | `EventDetailPhotoStrip` | Source-backed Widgetbook entry added under `[Core catalog]/Event detail`. |
| `PrivacyBadge` | `CatchPrivacyBadge` | Formal `catch.privacy_badge` contract under `[Core primitives]/Status`; no duplicate catalog page remains. |
| `ChatBubble` | `MessageBubble` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Matches and chat/Primitives`; alias still needs formal component-contract decision. |
| `ChatComposer` | `ChatInputBar` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Matches and chat/Primitives`; alias still needs formal component-contract decision. |
| `ChatListTile` | `ChatListTile` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Matches and chat/Primitives`; alias still needs formal component-contract decision. |
| `ChatThreadHeader` | `ChatEventContextHeader` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Matches and chat/Primitives`; alias still needs formal component-contract decision. |
| `CheckoutSheet` | `_CheckoutSheet` | Private source-backed candidate in `lib/payments/presentation/payment_confirmation_screen.dart`; currently covered through Payment Confirmation route states, not a standalone component entry. |
| `ClubDock` | `CatchClubDock` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Club detail`; code comment explicitly maps the design-system `ClubDock`. |
| `ClubHero` | `ClubHeroAppBar` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Club detail`; direct hero-vs-app-bar naming remains an alias decision. |
| `ClubPolaroid` | `ClubPolaroidArtwork` / `CatchPolaroid` | Source-backed local candidate used by club directory/share visuals; standalone Widgetbook entry still pending. |
| `ContactRow` | `_ContactRow` | Private source-backed candidate in `lib/clubs/presentation/detail/widgets/club_detail_body.dart`; reusable contract decision pending because the current widget is club-detail private. |
| `ConflictSheet` | `BookingConflictSheet` | Source-backed Widgetbook entry added under `[Event Detail]/Sheets`; capacity/sold-out is not part of the current primitive API. |
| `ConversationTopBar` | `CatchTopBar.identity` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Matches and chat/Primitives`; alias still needs formal component-contract decision. |
| `LiveConsole` | event-success host live widgets | Source-backed candidate in `lib/event_success/presentation/host_parts/event_success_host_live.dart`; direct reusable boundary still pending because the implementation is screen/section-level. |
| `MetricGrid` | `_HostAnalyticsMetricGrid` / `_UserAnalyticsMetricGrid` | Private source-backed candidates exist in host and user analytics panels; needs shared analytics-grid extraction before formal component coverage. |
| `PhotoGrid` | `PhotoGrid` | Source-backed widget exists in `lib/image_uploads/presentation/photo_grid.dart` and is embedded in profile Widgetbook states; standalone component entry still pending. |
| `ProfilePhoto` | `ProfilePhoto` / `ProfilePhotoEditorScreen` | Domain model and editor route exist; design component boundary likely belongs to photo slot/grid rather than the data model. |
| `ProfilePrompt` | `ProfilePromptsPage` / profile inline prompt editors | Source-backed flow exists, but no standalone prompt-card primitive is currently exposed. |
| `QuickActions` | `QuickActions` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Dashboard primitives`; direct component-contract decision still pending. |
| `RosterRow` | `CatchRosterRow` | Formal `catch.roster_row` contract under `[Core primitives]/Host operations`; no duplicate catalog page remains. |
| `RosterTable` | `CatchRosterTable` | Formal `catch.roster_table` contract under `[Core primitives]/Host operations`; no duplicate catalog page remains. |
| `RosterTiles` | `CatchRosterTiles` | Formal `catch.roster_tiles` contract under `[Core primitives]/Host operations`; no duplicate catalog page remains. |
| `RotationCard` | event-success live reveal widgets | Source-backed candidate in `lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart`; code comment explicitly maps the design-system `RotationCard` round list. |
| `ScreenBody` | `CatchScreenBody` | Formal `catch.screen_body` contract under `[Core primitives]/Sections`; no duplicate catalog page remains. |
| `SectionStack` | `CatchSectionStack` | Formal `catch.section_stack` contract under `[Core primitives]/Sections`; no duplicate catalog page remains. |
| `StrideCard` | `DashboardStrideSection` / `StrideCard` | Source-backed Widgetbook entry added under `[P1 product surfaces]/Dashboard primitives`; direct card-vs-section contract split remains a design decision. |
| `TicketStub` | `EventDetailTicketStubBand` | Source-backed Widgetbook entry added under `[Core catalog]/Event detail`. |

### No Clear Widgetbook Or Source Match Yet

These need implementation search, product-scope decisions, or new local
primitives before sync work begins.

- `ACTIVITY_KINDS`
- `ACTIVITY_ORDER`
- `BlastComposer`
- `ClubArt`
- `ClubPhotos`
- `CompatibilityList`
- `DashboardEventCard`
- `DateRangePicker`
- `DateTicket`
- `EventHero`
- `EventLifecycleRow`
- `FactList`
- `HostRow`
- `MapPicker`
- `NeedsYouCard`
- `NeedsYouQueue`
- `NextUpHero`
- `OrganizerHeader`
- `PhotoStripField`
- `ProfileHero`
- `ReviewRow`
- `RunningRhythm`
- `StatCard`
- `TONES`
- `TrendStrip`

## Widgetbook Entries Without A Claude Component Match

These local Widgetbook entries do not map to an exported Claude component name
under the current conservative alias map. Some are app-runtime helpers, grouped
adapters, loading/error states, or implementation details that Claude may not
model as separate primitives.

- `CatchActionMenu`
- `CatchAsyncValueSliver`
- `CatchAsyncValueView`
- `CatchBottomCta`
- `CatchBottomDock`
- `CatchBottomSheetGrabber`
- `CatchBrowseHeader`
- `CatchChipField<Labelled>`
- `CatchControlShell`
- `CatchDaySectionHeader`
- `CatchDetailHeroBackdrop`
- `CatchDetailRow`
- `CatchDraggableSheetShell`
- `CatchField.select`
- `CatchErrorBanner`
- `CatchErrorState`
- `CatchEventSpotlightCard`
- `CatchEventThumbnail`
- `CatchFormFieldLabel`
- `CatchFrameworkErrorView`
- `CatchGradedImage`
- `CatchHorizontalRail`
- `CatchIconTile`
- `CatchLoadingIndicator`
- `CatchMetaDotRow`
- `CatchMetricStrip`
- `CatchMonoLabel`
- `CatchMutationErrorListener`
- `CatchNotice`
- `CatchNoticeHost`
- `CatchOtpCodeField`
- `CatchPageDots`
- `CatchPersonRow`
- `CatchSection`
- `CatchSectionHeader`
- `CatchField`
- `CatchShareCardSheet`
- `CatchSkeleton`
- `CatchSkeletonList`
- `CatchSliverHeader`
- `CatchStartupLoadingScreen`
- `CatchStatColumn`
- `CatchStepProgress`
- `CatchSurface`
- `CatchTextButton`
- `CatchTopBarMenuAction`
- `CatchTopBarTabBar`
- `CatchVerticalSection`
- `EventActivityBackdrop`
- `EventActivityStamp`
- `EventTicketPerforatedDivider`
- `ProfileInfoTile`
- `ResponsiveBuilder`

## Immediate Inventory Findings

1. Widgetbook currently covers the formal core contract set plus the host
   roster and core composition composites, but most Claude feature-level
   component families still need contract decisions: clubs, dashboard,
   messaging, notifications, profile, and broader host operations are only
   partly represented.
2. Widgetbook has many runtime helpers that Claude does not export as design
   components: async wrappers, skeletons, error surfaces, section headers,
   bottom docks, generated event visual atoms, and responsive helpers.
3. Claude and Widgetbook now both have foundation specimen coverage for
   spacing, radius, elevation, color, typography, photo grade, wordmark,
   activity emblems, stroke, motion, icon scale, and data-pair examples.
4. The formal component contract registry has 18 primitives/composites. Claude
   has 41 exported `core` symbols alone, so the contract registry is still
   behind the Claude primitive vocabulary.
5. Several likely aliases need confirmation before implementation:
   `AppBar` vs `CatchTopBar`, `Sheet` vs `CatchBottomSheetScaffold`,
   `SegPill` vs `CatchSegmentedControl`, `Stepper` vs `CatchNumberStepper`,
   `FacePile`/`AvatarStack` vs `CatchPersonAvatarStack`, and `Section` vs
   `CatchSection`.

## Follow-Up Work Queue

### Phase 1: Inventory Closure

- Decide whether Claude feature components are all "primitives" for Widgetbook
  purposes or whether some should become screen/feature previews instead.
- Confirm or reject the alias table above.
- Add source searches for the "No clear Widgetbook or source match yet" list.
- Add Widgetbook entries for source-backed missing components where they are
  genuinely reusable primitives.
- Use the foundation specimen pages for visual/value comparison, and keep the
  required Widgetbook foundation-specimen gate active as token families change.

### Phase 2: Contract Registry Sync

- Expand `design/components/catch.components.json` beyond the current 18 formal
  primitives after the alias decisions are settled.
- Add contract states for each accepted Claude primitive.
- Keep generated Widgetbook use cases aligned to contract state names.

### Phase 3: Visual Parity

- Compare each matched component against Claude screenshots/cards one by one.
- Capture Widgetbook screenshots at fixed review viewports.
- Add pixel-diff baselines after dynamic regions and non-deterministic content
  have masks.
- Track visual divergences in the design parity matrix rather than scattering
  notes across source comments.

## Open Questions

1. Should Claude dashboard, messaging, profile, club, and host components be
   treated as reusable primitives in Widgetbook, or as screen-level feature
   previews?
2. Should local runtime-only helpers like `CatchAsyncValueView`,
   `CatchErrorState`, and `CatchSkeleton` be added to Claude/contract inventory,
   or intentionally remain app implementation primitives?
3. Should token specimen pages live in Widgetbook, or should they be generated
   from `design/tokens/catch.tokens.json` separately and linked from
   Widgetbook?
4. Should `CatchStatusBar` remain a local preview, given that it models device
   chrome rather than a product component?
5. Should `CatchMetricStrip` and `CatchMetricStrip` be consolidated before visual
   parity work starts?
