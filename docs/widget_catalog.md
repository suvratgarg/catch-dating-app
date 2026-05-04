# Widget Catalog

Every StatefulWidget, StatelessWidget, ConsumerWidget, and ConsumerStatefulWidget in `lib/`, grouped by feature area with a short description of what each widget does.

Generated 2026-05-05.

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

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `AppShell` | `lib/core/presentation/app_shell.dart:26` | Main tab shell with a `NavigationBar` (Home, Clubs, Catches, Chats, You). Initializes FCM, watches connectivity for an offline banner, pre-warms the clubs list stream, and keeps Crashlytics user ID synced with auth state. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ConnectivityBanner` | `lib/core/presentation/app_shell.dart:173` | Inline `MaterialBanner` shown at the top of the shell when the device goes offline. |
| `_RouterLoadingScreen` | `lib/routing/go_router.dart:438` | Minimal scaffold with `CatchLoadingIndicator` shown during route-level async data resolution. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunRouteScreen` | `lib/routing/go_router.dart:447` | Route wrapper that fetches a `RunClub` by ID and delegates to `CreateRunScreen`. Shows a loading screen or error text while the club resolves. |
| `EditRunClubRouteScreen` | `lib/routing/go_router.dart:475` | Route wrapper that fetches a `RunClub` by ID and delegates to `CreateRunClubScreen` for editing. Same loading/error pattern. |

---

## Core — Design System Widgets

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchTextField` | `lib/core/widgets/catch_text_field.dart:12` | Canonical text input. Wraps `FormField<String>` + `TextField` in a token-driven shell with label, helper/error copy, prefix/suffix icons, clear button, and theming via `CatchTextFieldSize`, `CatchTextFieldShape`, and `CatchTextFieldTone` enums. |
| `CatchButton` | `lib/core/widgets/catch_button.dart:13` | Canonical button. Supports `primary`, `secondary`, `ghost`, and `danger` variants; `sm`, `md`, `lg` sizes; loading state with animated dots; hover/press feedback; and an optional leading icon. |
| `CatchDropdownField<T>` | `lib/core/widgets/catch_dropdown_field.dart:8` | Token-driven single-select dropdown for `Labelled` enum-like values. Wraps `FormField<T>` + `DropdownButton<T>` with focus-ring styling and label decoration. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CatchSurface` | `lib/core/widgets/catch_surface.dart:9` | Canonical surface/card primitive. Supports `surface`, `raised`, `primarySoft`, and `transparent` tones; `none`, `raised`, and `overlay` elevations; optional border, gradient background, corner radius, and tap handling via `InkWell`. |
| `CatchTopBar` | `lib/core/widgets/catch_top_bar.dart:11` | Canonical top-bar. Renders a surface-fill bar with an optional back button (auto-detected from `Navigator.canPop`), title, leading widget, and action slots. Also supports a `bottom` `PreferredSizeWidget` (e.g., `TabBar`). Implements `PreferredSizeWidget` for use as an `AppBar`. |
| `CatchTopBarTabBar` | `lib/core/widgets/catch_top_bar.dart:132` | Catch-styled `TabBar` for use inside `CatchTopBar.bottom`. Uses `primary` indicator color and `labelL` text styles. Implements `PreferredSizeWidget`. |
| `CatchTopBarMenuAction<T>` | `lib/core/widgets/catch_top_bar.dart:156` | Overflow menu action for `CatchTopBar`. Renders a `PopupMenuButton<T>` wrapped in an `IconBtn`. |
| `CatchTopBarIconAction` | `lib/core/widgets/catch_top_bar.dart:189` | Icon-only action button for `CatchTopBar` actions. Renders a tooltip-wrapped `IconBtn`. |
| `CatchTopBarTextAction` | `lib/core/widgets/catch_top_bar.dart:222` | Text action button for `CatchTopBar` (e.g., "Save", "Done"). Renders a `TextButton` in primary color. |
| `CatchSegmentedControl<T>` | `lib/core/widgets/catch_segmented_control.dart:44` | Pill-style segmented control. Active segment gets dark background with light text; inactive segments are transparent. Used for Day/Agenda calendar switching and Grid/List view toggling. |
| `CatchSkeleton` | `lib/core/widgets/catch_skeleton.dart:20` | Shimmer-based loading placeholder. Named constructors: `.card()`, `.text()`, `.textBlock()`, `.circle()`, `.custom()`. Uses the `shimmer` package with Catch-themed colors. |
| `CatchSkeletonList` | `lib/core/widgets/catch_skeleton.dart:127` | Convenience widget rendering a vertical column of `count` skeleton cards with configurable spacing. |
| `CatchHorizontalRail` | `lib/core/widgets/catch_horizontal_rail.dart:12` | Section with a `SectionHeader` title and a horizontally-scrolling `ListView.separated` of items. Optionally accepts a trailing widget at the end of the rail. |
| `CatchVerticalSection` | `lib/core/widgets/catch_vertical_section.dart:25` | Section with a `SectionHeader` title and a vertical `ListView.separated` of items (non-scrollable, meant for embedding in a parent scroll view). |
| `CatchLoadingIndicator` | `lib/core/widgets/catch_loading_indicator.dart:3` | Simple centered `CircularProgressIndicator` for use during async loading states. |
| `CatchErrorText` | `lib/core/widgets/catch_error_text.dart:4` | Minimal error display widget — renders error text centered with error color. |
| `ErrorMessageWidget` | `lib/core/widgets/async_value_widget.dart:77` | Simple centered error message text widget used as the default error builder inside `AsyncValueWidget`. |
| `AsyncValueWidget<T>` | `lib/core/widgets/async_value_widget.dart:16` | Generic widget handling `AsyncValue` states: loading (defaults to `CatchLoadingIndicator`), error (defaults to `ErrorMessageWidget`), and data (custom builder). |
| `AsyncValueSliverWidget<T>` | `lib/core/widgets/async_value_widget.dart:47` | Sliver equivalent of `AsyncValueWidget`. Renders loading/error states inside `SliverToBoxAdapter`. |
| `CatchFormFieldLabel` | `lib/core/widgets/catch_form_field_label.dart:5` | Styled form field label with an optional badge (e.g., "Optional"). |
| `_OptionalBadge` | `lib/core/widgets/catch_form_field_label.dart:49` | Small "(optional)" badge rendered next to form labels. |
| `CatchChip` | `lib/core/widgets/catch_chip.dart:6` | Tag/chip widget. Supports active/inactive states, an optional remove button, and Catch-themed coloring. Used in `ChipField` and independently for vibe tags. |
| `_RemoveButton` | `lib/core/widgets/catch_chip.dart:104` | Small X button rendered inside `CatchChip` when removable. |
| `CatchBadge` | `lib/core/widgets/catch_badge.dart:10` | Small label badge used for spots-left indicators, distance/pace pills, etc. Supports `solid`, `neutral`, and `outline` tones. |
| `IconBtn` | `lib/core/widgets/icon_btn.dart:22` | Circular 40x40 icon button used as the base for `CatchTopBar*Action` widgets. Renders `Material` + `InkWell` with a center-aligned child. |
| `BottomCTA` | `lib/core/widgets/bottom_cta.dart:38` | Sticky bottom action footer. Renders a full-width `CatchButton` in a surface-colored bar separated from content by a hairline divider, with optional leading content and bottom safe-area padding. |
| `ChipField<T>` | `lib/core/widgets/chip_field.dart:14` | Multi/single-select chip selector wrapping `FormField<Set<T>>`. Uses `CatchChip` children inside a `Wrap`. Parent owns the `selected` set. |
| `DetailRow` | `lib/core/widgets/detail_row.dart:5` | Simple row with a label and value, used in detail/read-only views. |
| `ErrorBanner` | `lib/core/widgets/error_banner.dart:12` | Styled inline error banner for mutation/async errors within page content. Optionally includes a "Try again" button. |
| `SectionHeader` | `lib/core/widgets/section_header.dart:4` | Section header with uppercase or mixed-case title, optional heavy weight. |
| `StatusChip` | `lib/core/widgets/status_chip.dart:14` | Colored chip displaying run status (open, booked, full, cancelled, attending, waitlisted, not-going, attended, missed). |
| `StatColumn` | `lib/core/widgets/stat_column.dart:5` | Vertical stat display — value on top, label below. Used in run stats grids and profile sections. |
| `AppFormLayout` | `lib/core/widgets/app_form_layout.dart:3` | Form layout wrapper with consistent padding and spacing for form screens. |
| `BottomSheetGrabber` | `lib/core/widgets/bottom_sheet_grabber.dart:4` | Small drag handle/grabber bar shown at the top of bottom sheets. |
| `PersonRow` | `lib/core/widgets/person_row.dart:77` | Multipurpose person row. In chat-thread mode (when `lastMessage` is non-null), renders name, timestamp, context line, last message, and unread badge. In roster mode, renders name, meta line, context line, and an optional trailing widget. Used in chat inbox, rosters, waitlists, and catches previews. |
| `_ChatLayout` | `lib/core/widgets/person_row.dart:136` | Internal chat-thread layout for `PersonRow` — name + timestamp row, run-context row, last-message + unread-badge row. |
| `_RosterLayout` | `lib/core/widgets/person_row.dart:228` | Internal roster layout for `PersonRow` — name + meta line + context line (run icon). |
| `PersonAvatar` | `lib/core/widgets/person_avatar.dart:33` | Circular avatar with deterministic gradient fallback derived from name hash. Supports image URL, colored border ring (for match state or stacking), and an online status dot. Named constructor `PersonAvatar.count` shows a "+N" overflow bubble. |
| `_GradientPlaceholder` | `lib/core/widgets/person_avatar.dart:162` | Deterministic gradient placeholder for avatars without a photo. Picks from 12 palettes based on a hash of the name. |
| `ResponsiveBuilder` | `lib/core/responsive/responsive_builder.dart:22` | Thin wrapper around `LayoutBuilder` that maps available width to `ScreenSize` (compact/medium/expanded) and calls the appropriate builder. Falls back gracefully when tablet/desktop builders are absent. |
| `RunCard` | `lib/core/widgets/run_card.dart:94` | Versatile run card rendered at three densities: `compact` (small row with distance badge), `standard` (vertical card with photo/map header and roster strip), and `hero` (full-bleed card with large photo, title, vibe tags, and roster strip). |
| `_CompactCard` | `lib/core/widgets/run_card.dart:136` | Compact RunCard variant — distance badge + when/location + price. |
| `_StandardCard` | `lib/core/widgets/run_card.dart:195` | Standard RunCard variant — photo header, club name, location, time, roster strip with Join CTA. |
| `_HeroCard` | `lib/core/widgets/run_card.dart:291` | Hero RunCard variant — large photo, club name, vibe tags, location, time, roster strip. |
| `_PhotoHeader` | `lib/core/widgets/run_card.dart:389` | Map/photo header shared by standard + hero cards. Renders a custom map widget, hero image, or stylized map placeholder. Overlays spot-left badge, dist/pace pill, status chip, and stacked attendee avatars. |
| `_StackedAvatars` | `lib/core/widgets/run_card.dart:456` | Horizontally stacked circular avatars with overlap and an overflow "+N" bubble. |
| `_RosterRow` | `lib/core/widgets/run_card.dart:503` | Roster strip at the bottom of standard + hero cards showing "N/M runners" and a "Join →" CTA pill. |
| `_MapPlaceholder` | `lib/core/widgets/run_card.dart:547` | Stylized faux map painted with `CustomPaint` — land, water, roads, city blocks, a park, and a primary-colored route overlay. |
| `_ButtonLabel` | `lib/core/widgets/catch_button.dart:141` | Internal label+icon row for `CatchButton`. |
| `_LoadingDots` | `lib/core/widgets/catch_button.dart:193` | Three animated dots shown during `CatchButton`'s loading state. |
| `SettingsRow` | `lib/core/widgets/settings_row.dart:25` | Settings-style row with icon, label, optional value, optional trailing widget (e.g., `Switch`), and a danger mode (primary-colored text). |

---

## Dashboard

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `DashboardScreen` | `lib/dashboard/presentation/dashboard_screen.dart:9` | Home tab. Watches the user's profile and signed-up runs. Renders `DashboardFull` when there are runs, `DashboardEmpty` when there aren't, and loading/error screens while async data resolves. |
| `DashboardFull` | `lib/dashboard/presentation/widgets/dashboard_full.dart:20` | Full dashboard content: greeting header with avatar, next-run hero, attended-run section (StrideCard + CatchesCallout), QuickActions, recommended runs section, and ActivitySection. |
| `ActivitySection` | `lib/dashboard/presentation/widgets/activity_section.dart:18` | Scroll of past activities (runs + swipes) with tiles showing date, run info, participant avatars, and match count. |
| `CatchesCallout` | `lib/dashboard/presentation/widgets/catches_callout.dart:11` | Dashboard card promoting the active catch window — shows the run name, remaining time, roster count, and a "Start catching" CTA. |
| `NextRunHero` | `lib/dashboard/presentation/widgets/next_run_hero.dart:11` | Hero card showing the user's next upcoming run with location, time, price, and a "View run" CTA. |
| `Recommendations` | `lib/dashboard/presentation/widgets/recommendations.dart:7` | Horizontal rail of `RecommendCard` widgets for recommended runs. |
| `RecommendCard` | `lib/dashboard/presentation/widgets/recommend_card.dart:11` | Compact recommended-run card with club name, location, date, and price. |
| `StrideCard` | `lib/dashboard/presentation/widgets/stride_card.dart:8` | Dashboard card showing stride (weekly run count) stats with bar columns and a "Keep it up" message. |
| `StrideBarColumn` | `lib/dashboard/presentation/widgets/stride_card.dart:105` | Single bar column for the stride card — day label and filled bar. |
| `QuickActions` | `lib/dashboard/presentation/widgets/quick_actions.dart:8` | Row of quick-action buttons (e.g., "Find a Run", "Join a Club"). |
| `DashboardEmpty` | `lib/dashboard/presentation/widgets/dashboard_empty.dart:10` | Empty state shown when the user has no booked runs — prompts them to find their first run. |
| `EmptyHeroCard` | `lib/dashboard/presentation/widgets/empty_hero_card.dart:10` | Hero card variant shown on the empty dashboard prompting the user to book their first run. |
| `DashedAvatar` | `lib/dashboard/presentation/widgets/dashed_avatar.dart:7` | Dashed-border circular avatar placeholder used in empty-state layouts. |
| `StaticMapDark` | `lib/dashboard/presentation/widgets/static_map_dark.dart:3` | Static map image widget with dark mode support. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_DashboardLoadingScreen` | `lib/dashboard/presentation/dashboard_screen.dart:39` | Loading scaffold for the dashboard. |
| `_DashboardMessageScreen` | `lib/dashboard/presentation/dashboard_screen.dart:48` | Error message scaffold for the dashboard. |
| `_DashboardSectionStateCard` | `lib/dashboard/presentation/widgets/dashboard_full.dart:189` | Inline loading/error card for a dashboard section (e.g., "Loading your recent runs..."). |
| `_ActivityTile` | `lib/dashboard/presentation/widgets/activity_section.dart:142` | Single row in the activity section — shows run date, club name, participant avatars, match count, and participant list. |
| `_ActivityMessage` | `lib/dashboard/presentation/widgets/activity_section.dart:211` | Empty or error message inside the activity section. |
| `_ActivityStateLabel` | `lib/dashboard/presentation/widgets/activity_section.dart:250` | Status label shown on past activity tiles (e.g., "You attended", "You missed"). |

---

## Swipes

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeScreen` | `lib/swipes/presentation/swipe_screen.dart:18` | Main swipe screen. Manages a `CardSwiperController`, watches the swipe queue provider, and renders swipeable profile cards with pass/like action buttons. Handles swipe direction logic (right = like, left = pass). |
| `FiltersScreen` | `lib/swipes/presentation/filters_screen.dart:17` | Swipe filters screen. Lets users filter the swipe queue by vibe, run, gender, and age range. |
| `RunRecapScreen` | `lib/swipes/presentation/run_recap_screen.dart:21` | Post-run recap screen showing the run details, swipe stats (likes, matches, passes), and the full attendee roster with photo grid and swipable profile cards. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `SwipeHubScreen` | `lib/swipes/presentation/swipe_hub_screen.dart:19` | "Catches" tab. Lists all attended runs with open catch windows (24h post-check-in swiping). Shows an intro card for the featured run with countdown timer, and a list of all active runs with `AttendedRunTile` widgets. |
| `ScrollableProfile` | `lib/swipes/presentation/widgets/scrollable_profile.dart:17` | Full-length scrollable profile card used on the swipe screen. Renders running identity, bio, photos, attributes, running/lifestyle sections. |
| `ProfileCard` | `lib/swipes/presentation/profile_card.dart:7` | The primary swipe card. Shows the user's photos (via `CardPhotoSection`), name overlay, and attribute chips in a card layout. |
| `_VibeTile` | `lib/swipes/presentation/run_recap_screen.dart:218` | Single vibe/filter chip tile on the recap screen. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CatchesHubContent` | `lib/swipes/presentation/swipe_hub_screen.dart:56` | Content body for the catches hub — header, intro card for the featured run, and list of active catch windows. |
| `_CatchesHeader` | `lib/swipes/presentation/swipe_hub_screen.dart:116` | Header row for the catches hub: "CATCHES" section header + "After the run" title + heart icon. |
| `_CatchesIntroCard` | `lib/swipes/presentation/swipe_hub_screen.dart:151` | Gradient hero card promoting the 24-hour catch window with countdown timer, roster count, and "Start catching" CTA. |
| `_PillStat` | `lib/swipes/presentation/swipe_hub_screen.dart:255` | Semi-transparent stat pill inside the catches intro card — label + value. |
| `_CatchesEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:296` | Empty state when no active catch windows exist. Prompts the user to book a run. |
| `CardPhotoSection` | `lib/swipes/presentation/widgets/card_photo_section.dart:3` | Photo carousel section inside the swipe `ProfileCard`. |
| `NameOverlay` | `lib/swipes/presentation/widgets/name_overlay.dart:7` | Name + age overlay at the bottom of the swipe card photo with goal pill. |
| `GoalPill` | `lib/swipes/presentation/widgets/name_overlay.dart:56` | Small chip showing the user's running goal. |
| `ProfileAttributesSection` | `lib/swipes/presentation/widgets/profile_attributes_section.dart:5` | Section of attribute chips (pace, distance, club) on the swipe card. |
| `ProfileSectionCard` | `lib/swipes/presentation/widgets/profile_section_card.dart:5` | Reusable section card wrapper for profile detail sections. |
| `ProfileBioSection` | `lib/swipes/presentation/widgets/profile_bio_section.dart:4` | Bio text section on the swipe card / profile. |
| `ProfileRunningSection` | `lib/swipes/presentation/widgets/profile_running_section.dart:6` | Running preferences section (pace, distance, days, etc.). |
| `ProfileLifestyleSection` | `lib/swipes/presentation/widgets/profile_lifestyle_section.dart:6` | Lifestyle section (occupation, education, drinking, smoking, etc.). |
| `ProfileInfoChip` | `lib/swipes/presentation/widgets/profile_info_chip.dart:3` | Single info chip on the profile card — icon + label. |
| `SwipeActionButtons` | `lib/swipes/presentation/widgets/swipe_action_buttons.dart:4` | Pass and Like action buttons at the bottom of the swipe screen. |
| `SwipeCircleButton` | `lib/swipes/presentation/widgets/swipe_action_buttons.dart:43` | Individual circular swipe action button (pass = X, like = heart). |
| `SwipeStamp` | `lib/swipes/presentation/widgets/swipe_stamp.dart:15` | "LIKE" or "NOPE" stamp overlay that appears during swipe gestures. |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart:7` | Empty state shown when the swipe queue is exhausted. |
| `AttendedRunTile` | `lib/swipes/presentation/widgets/attended_run_tile.dart:14` | Row tile for an attended run in the catches hub list — shows run title, date, location, and a CTA arrow. |
| `_RunningIdentityCard` | `lib/swipes/presentation/widgets/scrollable_profile.dart:72` | Card inside `ScrollableProfile` showing the user's running identity (pace, distance, frequency). |
| `_RunStatPill` | `lib/swipes/presentation/widgets/scrollable_profile.dart:137` | Small stat pill inside the running identity card. |
| `_RecapHero` | `lib/swipes/presentation/run_recap_screen.dart:126` | Hero section of the run recap screen — run name, date, location, and a CTA. |
| `_RecapStat` | `lib/swipes/presentation/run_recap_screen.dart:182` | Single stat counter on the recap screen (e.g., "12 Likes", "4 Matches"). |
| `_ProfilePhoto` | `lib/swipes/presentation/run_recap_screen.dart:295` | Single profile photo in the recap attendee grid. |
| `_EmptyRoster` | `lib/swipes/presentation/run_recap_screen.dart:316` | Empty state when the recap roster has no one. |
| `_FilterSection` | `lib/swipes/presentation/filters_screen.dart:264` | Collapsible section in the filters screen (header + expandable body). |
| `_FilterValue` | `lib/swipes/presentation/filters_screen.dart:296` | Single selectable filter value tile. |

---

## Matches / Chats

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsListScreen` | `lib/matches/presentation/matches_list_screen.dart:8` | "Chats" tab. Renders the chat conversations list with a sliver header (search + new matches rail) and the list of `ChatListTile` widgets. |
| `ChatsList` | `lib/matches/presentation/widgets/chats_list.dart:12` | The scrollable list body of chat conversations fed from `ChatsListViewModel`. |
| `ChatListTile` | `lib/matches/presentation/chat_list_tile.dart:9` | Single chat thread row in the inbox. Shows `PersonRow` in chat-thread mode with name, last message, timestamp, unread badge, and on-tap navigation to `ChatScreen`. |
| `ChatNewMatchesRail` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:10` | Horizontal rail of new match avatars at the top of the chats list. |
| `_NewMatchAvatar` | `lib/matches/presentation/widgets/chat_new_matches_rail.dart:40` | Single new-match avatar in the rail — circular photo with name. |
| `ChatSearchField` | `lib/matches/presentation/widgets/chat_search_field.dart:6` | Search text field for filtering chats list. |
| `ChatConversationsList` | `lib/matches/presentation/widgets/chat_conversations_list.dart:8` | The actual `ListView` of chat tiles, driven by `ChatsListViewModel`. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatsEmptyState` | `lib/matches/presentation/widgets/chats_empty_state.dart:6` | Empty state shown when there are no chat conversations. |
| `ChatsListBody` | `lib/matches/presentation/widgets/chats_list_body.dart:7` | Body wrapper for the chats list (manages scroll controller, etc.). |
| `_TitleRow` | `lib/matches/presentation/widgets/chats_sliver_header.dart:16` | "Chats" title row in the chats sliver header. |
| `_SearchRow` | `lib/matches/presentation/widgets/chats_sliver_header.dart:68` | Search field row in the chats sliver header. Implements `PreferredSizeWidget` for use in `SliverAppBar.bottom`. |

---

## Chat Screen

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `ChatScreen` | `lib/chats/presentation/chat_screen.dart:26` | Full chat thread screen. Manages a `TextEditingController` for the message input, a `ScrollController` for auto-scrolling to latest messages, and handles message sending (text + image), read-receipt reset, and block/report actions. Renders a `StreamBuilder` of `ChatMessage` widgets with a `ChatInputBar` at the bottom. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_RunContextHeader` | `lib/chats/presentation/chat_screen.dart:348` | Header inside the chat showing the shared run context — run icon, run name, and date. |
| `ChatInputBar` | `lib/chats/presentation/widgets/chat_input_bar.dart:7` | Message input bar with text field, image picker button, and send button. |
| `MessageBubble` | `lib/chats/presentation/widgets/message_bubble.dart:6` | Single chat message bubble. Renders differently for sent vs. received messages (alignment, color, corner rounding). Shows timestamp and optional image attachment. |

---

## Public Profile

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `PublicProfileScreen` | `lib/public_profile/presentation/public_profile_screen.dart:14` | Full-screen public profile view. Fetches `PublicProfile` by UID, renders `ProfileCard`, running stats, bio, lifestyle sections, and report/block actions. Manages block submission state. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_ProfileBody` | `lib/public_profile/presentation/public_profile_screen.dart:171` | Scrollable body of the public profile — stacked profile sections. |
| `_ReportReasonTile` | `lib/public_profile/presentation/public_profile_screen.dart:197` | Single selectable report reason row. |

---

## User Profile (My Profile)

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `ProfileScreen` | `lib/my_profile/presentation/profile_screen.dart:13` | "You" tab. Renders the user's own profile with a sliver header (avatar, name, city), tab bar (Profile / Preview), and tab content. |
| `ProfileTab` | `lib/my_profile/presentation/widgets/profile_tab.dart:17` | Editable profile tab content — info sections, prompt cards, and edit sheets for each field. |
| `_OverflowMenu` | `lib/my_profile/presentation/widgets/profile_sliver_header.dart:52` | Overflow menu in the profile sliver header (settings, etc.). |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PreviewTab` | `lib/my_profile/presentation/widgets/preview_tab.dart:5` | Preview tab showing how the user's profile looks to others (renders `ProfileCard` + sections). |
| `ProfileInfoSection` | `lib/my_profile/presentation/widgets/profile_info_section.dart:24` | Grouped section of `ProfileInfoTile` rows with a section header. |
| `ProfileInfoTile` | `lib/my_profile/presentation/widgets/profile_info_tile.dart:6` | Single tappable info row — icon, label, value, chevron. Opens the corresponding edit sheet on tap. |
| `_ProfileTitle` | `lib/my_profile/presentation/widgets/profile_sliver_header.dart:22` | Name + city title in the profile sliver header. |
| `_SettingsButton` | `lib/my_profile/presentation/widgets/profile_sliver_header.dart:39` | Settings gear button in the profile header. |
| `_PromptCard` | `lib/my_profile/presentation/widgets/profile_tab.dart:449` | Editable prompt card (e.g., "My ideal run...") on the profile tab. |

---

## Onboarding

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `OnboardingScreen` | `lib/onboarding/presentation/onboarding_screen.dart:16` | Multi-step onboarding flow shell. Manages step navigation via `PageController`, renders the step progress bar, and delegates to individual step pages. |
| `PhonePage` | `lib/onboarding/presentation/pages/phone_page.dart:17` | Phone number entry page — country code picker + phone input + "Send OTP" button. |
| `OtpPage` | `lib/onboarding/presentation/pages/otp_page.dart:17` | OTP verification page — 6-digit input with auto-focus, resend timer, and verification via Firebase Auth. |
| `NameDobPage` | `lib/onboarding/presentation/pages/name_dob_page.dart:11` | Name and date-of-birth entry page — text field + date picker. |
| `GenderInterestPage` | `lib/onboarding/presentation/pages/gender_interest_page.dart:12` | Gender identity and interest selection page using `ChipField`. |
| `RunningPrefsPage` | `lib/onboarding/presentation/pages/running_prefs_page.dart:15` | Running preferences page — pace, distance, days, goals, and experience level. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `WelcomePage` | `lib/onboarding/presentation/pages/welcome_page.dart:10` | Landing/welcome page shown at the start of onboarding — app logo, tagline, and "Get started" button. |
| `PhotosPage` | `lib/onboarding/presentation/pages/photos_page.dart:13` | Photo upload page — renders `PhotoGrid` for the user to add/remove profile photos. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_OnboardingTopBar` | `lib/onboarding/presentation/onboarding_screen.dart:94` | Top bar for onboarding screens — back button (when applicable) + optional "Skip" text action. |
| `_ProgressBar` | `lib/onboarding/presentation/onboarding_screen.dart:138` | Horizontal progress bar showing current step in the onboarding flow. |
| `OnboardingStepHeader` | `lib/onboarding/presentation/widgets/onboarding_step_header.dart:5` | Title + subtitle header for each onboarding step page. |
| `_TrackPattern` | `lib/onboarding/presentation/pages/welcome_page.dart:81` | Decorative track/route pattern shown on the welcome page background. |
| `_OtpDigitField` | `lib/onboarding/presentation/pages/otp_page.dart:204` | 6-digit OTP input row — renders 6 `_OtpDigitBox` widgets with auto-focus management. |
| `_OtpDigitBox` | `lib/onboarding/presentation/pages/otp_page.dart:280` | Single OTP digit box — shows the digit, cursor, and focus ring. |

---

## Image Uploads

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `PhotoGrid` | `lib/image_uploads/presentation/photo_grid.dart:9` | Grid of photo slots for profile photo management. Handles add, remove, and reorder. |
| `PhotoSlot` | `lib/image_uploads/presentation/widgets/photo_slot.dart:5` | Single photo slot — shows the image, an add button for empty slots, and a remove button for filled slots. |

---

## Run Clubs

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunClubScreen` | `lib/run_clubs/presentation/create/create_run_club_screen.dart:22` | Create/edit run club form. Multi-section form with cover photo picker, details fields, contact fields, and a submit CTA. Handles both create and edit flows (initialized via `initialRunClub`). |
| `CityPicker` | `lib/run_clubs/presentation/list/widgets/city_picker.dart:11` | City selector dropdown at the top of the clubs list. Watches and updates `selectedRunClubCityProvider`. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `RunClubDetailScreen` | `lib/run_clubs/presentation/detail/run_club_detail_screen.dart:16` | Run club detail screen. Fetches the club, current user profile, upcoming runs, reviews, and handles membership state via `RunClubMembershipController`. Renders `ClubDetailBody`. |
| `RunClubsList` | `lib/run_clubs/presentation/list/widgets/run_clubs_list.dart:11` | The scrollable list body of run club tiles, fed from `RunClubsListViewModel`. |
| `RunClubsSearchField` | `lib/run_clubs/presentation/list/widgets/run_clubs_search_field.dart:6` | Search text field for filtering the clubs list. |
| `_SearchRow` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:66` | Search row inside the clubs sliver header. |
| `MembershipButton` | `lib/run_clubs/presentation/detail/widgets/membership_button.dart:6` | Join/Leave/Request membership button on the club detail screen. Calls `RunClubMembershipController`. |
| `MutationErrorSnackbarListener` | `lib/run_clubs/presentation/shared/run_clubs_mutation_feedback.dart:22` | Watches a Riverpod `Mutation` and shows a `SnackBar` on error transition. Used to surface join/leave club errors. |
| `_DirectoryCard` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/directory_card.dart:3` | Directory-style club card — larger layout with cover image, host avatar, stats strip, and "Join Club" CTA. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `RunClubsListScreen` | `lib/run_clubs/presentation/list/run_clubs_list_screen.dart:6` | "Clubs" tab. Renders the clubs sliver header (city picker, search, create button) + `RunClubsList` body. |
| `RunClubsListBody` | `lib/run_clubs/presentation/list/widgets/run_clubs_list_body.dart:7` | Body wrapper for the clubs list — manages scroll behavior and empty/loading states. |
| `RunClubDiscoverList` | `lib/run_clubs/presentation/list/widgets/run_club_discover_list.dart:6` | Discovery section of the clubs list — header + horizontally-scrolling rail of featured clubs. |
| `RunClubListTile` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile.dart:26` | Single club row tile — club image, name, location, member count, and distance. |
| `RunClubsEmptyState` | `lib/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart:5` | Empty state when no clubs are found. |
| `RunClubAvatarRail` | `lib/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart:9` | Horizontal avatar rail of the user's joined clubs + a create-club button. |
| `_CreateClubButton` | `lib/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart:34` | "+" button at the end of the avatar rail to create a new club. |
| `_TitleRow` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:22` | "Clubs" title row in the clubs sliver header. |
| `_AddButton` | `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:50` | "+" button next to the title to create a new club. |
| `ClubHeroAppBar` | `lib/run_clubs/presentation/detail/widgets/club_hero_app_bar.dart:15` | Hero-style app bar for the club detail screen — large cover image, club name, location, and back button. |
| `ClubDetailBody` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:21` | Scrollable club detail body — about section, stats, upcoming runs list, reviews section, and host action panel. |
| `_HostActionPanel` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:119` | Action panel shown when the current user is the club host — create run, edit club, etc. |
| `_ClubContactSection` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:177` | Contact info section — Instagram, website, WhatsApp, email rows. |
| `_ContactRow` | `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:228` | Single contact row (icon + label + value). |
| `HostStatsBar` | `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart:7` | Host stats bar — member count, run count, founding date. |
| `HostStatChip` | `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart:83` | Single stat chip in the host stats bar. |
| `StatsStrip` | `lib/run_clubs/presentation/detail/widgets/stats_strip.dart:6` | Horizontal strip of stats — runs hosted, members, location — shown on club cards. |
| `RunClubCoverFallback` | `lib/run_clubs/presentation/shared/run_club_cover_fallback.dart:6` | Gradient + chip fallback shown when a club has no cover photo. |
| `_CoverChip` | `lib/run_clubs/presentation/shared/run_club_cover_fallback.dart:98` | Small distance/location chip overlaid on the cover fallback. |
| `CreateRunClubDetailsFields` | `lib/run_clubs/presentation/create/widgets/create_run_club_details_fields.dart:7` | Club name, description, and location fields for the create/edit form. |
| `CreateRunClubCoverPicker` | `lib/run_clubs/presentation/create/widgets/create_run_club_cover_picker.dart:9` | Cover photo picker for the create/edit club form. |
| `CreateRunClubContactFields` | `lib/run_clubs/presentation/create/widgets/create_run_club_contact_fields.dart:6` | Contact fields (Instagram, WhatsApp, website, email) for the create/edit form. |
| `_ClubImage` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/club_image.dart:3` | Club cover image for list tiles. |
| `_HostAvatar` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/directory_card.dart:163` | Host avatar shown on directory cards. |
| `_AvatarChip` | `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/avatar_chip.dart:3` | Small avatar chip with member photo and count. |

---

## Runs

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunScreen` | `lib/runs/presentation/create_run_screen.dart:31` | Multi-step run creation flow (When → Where → Details → Eligibility → Review). Manages `PageController`, draft auto-save/restore, and the create-run mutation. On success transitions to `CreateRunSuccessScreen` or `HostRunManageScreen`. |
| `RunMapScreen` | `lib/runs/presentation/run_map_screen.dart:20` | Map view showing all upcoming runs as pins. Users can tap a pin to see a bottom sheet with run details. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `RunDetailScreen` | `lib/runs/presentation/run_detail_screen.dart:8` | Run detail screen (public view). Fetches `RunDetailViewModel` and renders `RunDetailBody`. |
| `RunDetailBody` | `lib/runs/presentation/widgets/run_detail_body.dart:27` | Scrollable run detail body — hero header, stats grid, route map, roster section, and `RunDetailCta`. |
| `RunDetailCta` | `lib/runs/presentation/widgets/run_detail_cta.dart:25` | Bottom CTA bar for run detail. Shows different states: price + "Join" button, "You're booked" badge, "You attended" label, or disabled (full/cancelled). |
| `AttendanceSheetScreen` | `lib/runs/presentation/attendance_sheet_screen.dart:20` | Host-facing attendance sheet. Shows a list of booked users with check-in/absent toggles and the attendee count. |
| `_AttendanceList` | `lib/runs/presentation/attendance_sheet_screen.dart:59` | List body of attendance rows. |
| `_AttendeeRow` | `lib/runs/presentation/attendance_sheet_screen.dart:146` | Single attendance row — avatar, name, and check-in/absent toggle. |
| `_RunsMap` | `lib/runs/presentation/run_map_screen.dart:118` | The actual Flutter map widget rendering run pins (used inside `RunMapScreen`). |

### StatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `LocationPickerScreen` | `lib/runs/presentation/location_picker_screen.dart:8` | Map-based location picker. Lets users long-press or search for a location and returns the selected `LatLng` + address. |
| `_DraftPickerSheet` | `lib/runs/presentation/widgets/draft_picker_sheet.dart:32` | Bottom sheet listing saved run drafts. Users can tap to resume or swipe to delete. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `CreateRunSuccessScreen` | `lib/runs/presentation/create_run_screen.dart:665` | Success confirmation screen after creating a run — shows run summary, share button, and "Manage Run" CTA. |
| `HostRunManageScreen` | `lib/runs/presentation/create_run_screen.dart:791` | Host run management screen — shows run stats, roster list, and actions (edit, cancel, view attendance). |
| `_StatCard` | `lib/runs/presentation/create_run_screen.dart:915` | Single stat card on the manage screen (e.g., "12 / 20 Booked"). |
| `_HostRunSummaryCard` | `lib/runs/presentation/create_run_screen.dart:944` | Summary card showing run details on the host manage screen. |
| `_HostSummaryRow` | `lib/runs/presentation/create_run_screen.dart:992` | Single key-value row in the host summary card. |
| `_HostUserList` | `lib/runs/presentation/create_run_screen.dart:1037` | Scrollable list of booked users on the host manage screen. |
| `RunScheduleGrid` | `lib/runs/presentation/run_schedule_grid.dart:11` | Grid of scheduled runs for a club — shows day headers and `ScheduleRunCard` tiles. |
| `ScheduleRunCard` | `lib/runs/presentation/widgets/schedule_run_card.dart:9` | Compact run card for the schedule grid — time, location, distance badge, and price. |
| `ScheduleDayHeader` | `lib/runs/presentation/widgets/schedule_day_header.dart:7` | Day-of-week + date header in the schedule grid. |
| `WhenStep` | `lib/runs/presentation/widgets/when_step.dart:7` | "When" form step in create run — date + time pickers. |
| `WhereStep` | `lib/runs/presentation/widgets/where_step.dart:8` | "Where" form step — location picker, address display, and map preview. |
| `RunDetailsStep` | `lib/runs/presentation/widgets/run_details_step.dart:9` | "Details" form step — distance, pace, price, capacity, and vibe tags. |
| `EligibilityStep` | `lib/runs/presentation/widgets/eligibility_step.dart:9` | "Eligibility" form step — gender, age, and experience requirements. |
| `StepProgressBar` | `lib/runs/presentation/widgets/step_progress_bar.dart:4` | Horizontal step indicator showing current step out of total. |
| `StepperFooter` | `lib/runs/presentation/widgets/stepper_footer.dart:5` | Footer with Back/Next buttons for the create-run stepper. |
| `WhenWhereCard` | `lib/runs/presentation/widgets/when_where_card.dart:8` | Read-only card showing when/where info (used on draft previews and recap). |
| `RunStatsGrid` | `lib/runs/presentation/widgets/run_stats_grid.dart:8` | Grid of stat cells (distance, pace, elevation, etc.) for run detail. |
| `RunStatCell` | `lib/runs/presentation/widgets/run_stats_grid.dart:39` | Single stat cell with value + label. |
| `RunStatDivider` | `lib/runs/presentation/widgets/run_stats_grid.dart:81` | Vertical divider between stat cells. |
| `RunPhotoHeader` | `lib/runs/presentation/widgets/run_photo_header.dart:6` | Photo/map header for the run detail screen. |
| `MapPinTile` | `lib/runs/presentation/widgets/map_pin_tile.dart:7` | Route map + pin display tile. |
| `PickerTile` | `lib/runs/presentation/widgets/picker_tile.dart:6` | Tappable tile that opens a picker (date, time, etc.) — shows label + selected value. |
| `DurationStepper` | `lib/runs/presentation/widgets/duration_stepper.dart:6` | +/- stepper for selecting duration. |
| `RequirementsRow` | `lib/runs/presentation/widgets/requirements_row.dart:7` | Read-only row showing eligibility requirements. |
| `FieldLabel` | `lib/runs/presentation/widgets/field_label.dart:4` | Styled label for form fields in the create-run flow. |
| `_DraftCard` | `lib/runs/presentation/widgets/draft_picker_sheet.dart:185` | Single draft card in the draft picker sheet — shows run summary + delete swipe action. |
| `PriceLeading` | `lib/runs/presentation/widgets/run_detail_cta.dart:246` | Price display widget shown as leading content in `RunDetailCta` (price + "incl. coffee"). |
| `BookedLeading` | `lib/runs/presentation/widgets/run_detail_cta.dart:270` | "You're booked" badge shown when the user already booked. |
| `AttendedLeading` | `lib/runs/presentation/widgets/run_detail_cta.dart:287` | "You attended" badge shown for past attended runs. |
| `_MapRunSheet` | `lib/runs/presentation/run_map_screen.dart:192` | Bottom sheet shown when tapping a map pin — run name, location, date, and "View details" CTA. |
| `_RunMapChip` | `lib/runs/presentation/run_map_screen.dart:264` | Date pill chip on the map sheet. |
| `_MapEmptyState` | `lib/runs/presentation/run_map_screen.dart:320` | Empty state when no runs are on the map. |

---

## Calendar

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `CalendarScreen` | `lib/calendar/presentation/calendar_screen.dart:15` | Calendar tab showing the user's booked runs. Manages view mode state (`agenda` vs `timeline`) and renders the appropriate view. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_CalendarHeader` | `lib/calendar/presentation/calendar_screen.dart:74` | Calendar header — "Calendar" title + `CatchSegmentedControl` for Agenda/Timeline toggle. |
| `_WeekStrip` | `lib/calendar/presentation/calendar_screen.dart:185` | Horizontal week strip showing 7 days with date indicators. |
| `_WeekDay` | `lib/calendar/presentation/calendar_screen.dart:219` | Single day cell in the week strip — day name, date number, and active indicator. |
| `_AgendaView` | `lib/calendar/presentation/calendar_screen.dart:276` | Agenda (list) view of booked runs grouped by date. |
| `_AgendaRunCard` | `lib/calendar/presentation/calendar_screen.dart:316` | Single run card in the agenda view — time, distance badge, club name, location. |
| `_TimelineView` | `lib/calendar/presentation/calendar_screen.dart:383` | Timeline (week) view of booked runs. |
| `_TimelineRun` | `lib/calendar/presentation/calendar_screen.dart:410` | Single run block in the timeline view — positioned by time of day. |
| `_StatDivider` | `lib/calendar/presentation/calendar_screen.dart:481` | Dashed divider between stat items. |
| `_CalendarMessage` | `lib/calendar/presentation/calendar_screen.dart:497` | Empty/error message for the calendar. |

---

## Payments

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `PaymentConfirmationScreen` | `lib/payments/presentation/payment_confirmation_screen.dart:20` | Post-payment confirmation screen. Shows hero animation, run summary card, quick actions (add to calendar, share, view club), and a referral banner. Also manages a "Back to Home" sticky CTA. |
| `_ConfirmationBody` | `lib/payments/presentation/payment_confirmation_screen.dart:47` | Scrollable body of the confirmation screen. |
| `PaymentHistoryScreen` | `lib/payments/presentation/payment_history_screen.dart:19` | List of past payment transactions. Watches `watchPaymentsProvider` and renders `_PaymentTile` items. |
| `_PaymentList` | `lib/payments/presentation/payment_history_screen.dart:42` | The list view of payment tiles. |
| `_PaymentTile` | `lib/payments/presentation/payment_history_screen.dart:73` | Single payment transaction row — amount, date, run name, and status. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_HeroSection` | `lib/payments/presentation/payment_confirmation_screen.dart:104` | Animated hero section with checkmark and "Payment confirmed" text. |
| `_RunSummaryCard` | `lib/payments/presentation/payment_confirmation_screen.dart:207` | Card summarizing the booked run — club name, location, date, distance, pace, and price. |
| `_QuickActions` | `lib/payments/presentation/payment_confirmation_screen.dart:304` | Row of quick-action tiles (Add to Calendar, Share, View Club). |
| `_ActionTile` | `lib/payments/presentation/payment_confirmation_screen.dart:387` | Single quick-action tile. |
| `_HeadsUp` | `lib/payments/presentation/payment_confirmation_screen.dart:429` | Info box about cancellation policy. |
| `_ReferralBanner` | `lib/payments/presentation/payment_confirmation_screen.dart:462` | Referral banner — "Invite friends, earn credit". |
| `_StickyBackToHome` | `lib/payments/presentation/payment_confirmation_screen.dart:519` | Sticky "Back to Home" button at the bottom of the confirmation screen. |

---

## Safety / Settings

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `SettingsScreen` | `lib/safety/presentation/settings_screen.dart:21` | Full settings screen. Manages notification toggle state (`showOnMap`, `newCatches`, `runReminders`, `weeklyDigest`), account deletion flow, and blocked accounts section. |

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `_BlockedAccountsSection` | `lib/safety/presentation/settings_screen.dart:302` | Section listing blocked accounts — fetches blocked profiles and renders `_BlockedAccountTile` rows with unblock action. |
| `_BlockedAccountTile` | `lib/safety/presentation/settings_screen.dart:351` | Single blocked account row — avatar, name, and "Unblock" button. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `_SettingsCard` | `lib/safety/presentation/settings_screen.dart:286` | Card wrapper for settings sections. |

---

## Force Update

### ConsumerWidget

| Widget | File | Purpose |
|---|---|---|
| `UpdateRequiredScreen` | `lib/force_update/presentation/update_required_screen.dart:13` | Blocking full-screen prompting the user to update the app. Reads store URLs from `AppVersionConfig` and opens the appropriate store on tap. The user cannot dismiss this screen. |

---

## Reviews

### ConsumerStatefulWidget

| Widget | File | Purpose |
|---|---|---|
| `_WriteReviewSheet` | `lib/reviews/presentation/write_review_sheet.dart:37` | Bottom sheet for writing a review. Manages star rating, text input, and the submit review mutation. |

### StatelessWidget

| Widget | File | Purpose |
|---|---|---|
| `ReviewsSection` | `lib/reviews/presentation/reviews_section.dart:17` | Section header + list of `ReviewCard` widgets for a club's reviews. |
| `ReviewCard` | `lib/reviews/presentation/reviews_section.dart:172` | Single review card — star rating, text, author name, and relative timestamp. |

---

## Summary

| Type | Count |
|---|---|
| `ConsumerStatefulWidget` | 19 |
| `ConsumerWidget` | 42 |
| `StatefulWidget` | 4 |
| `StatelessWidget` | ~150 |

---

## Consolidation Opportunities

### High impact — clear duplicates, should be merged

#### 1. `FieldLabel` (runs) is a useless wrapper around `CatchFormFieldLabel`

`lib/runs/presentation/widgets/field_label.dart` is a one-line pass-through:

```dart
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, this.isOptional = false});
  @override
  Widget build(BuildContext context) =>
      CatchFormFieldLabel(label: label, isOptional: isOptional, large: true);
}
```

It exists solely to pass `large: true`. **Fix**: delete `FieldLabel` and have its 2 call sites pass `large: true` to `CatchFormFieldLabel` directly.

#### 2. `_DashboardLoadingScreen` and `_RouterLoadingScreen` are identical

Both are `Scaffold(body: CatchLoadingIndicator())`. **Fix**: extract a shared `CatchLoadingScreen` in `lib/core/widgets/` and reuse from both places.

#### 3. `_DashboardMessageScreen` and `_CalendarMessage` are near-identical

Both render a centered text message on a scaffold. `_CalendarMessage` adds a title + body column; `_DashboardMessageScreen` is body-only. **Fix**: unify into a single `CatchMessageScreen` widget with optional title.

#### 4. Six different empty-state widgets duplicate the same layout

| Widget | File | Pattern |
|---|---|---|
| `ChatsEmptyState` | `lib/matches/presentation/widgets/chats_empty_state.dart` | Icon in circle → title → body text |
| `RunClubsEmptyState` | `lib/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart` | Icon → title → body text |
| `_CatchesEmptyState` | `lib/swipes/presentation/swipe_hub_screen.dart:296` | Icon in circle → title → body text → CTA |
| `SwipeEmptyState` | `lib/swipes/presentation/widgets/swipe_empty_state.dart` | Icon → title → body text |
| `_EmptyRoster` | `lib/swipes/presentation/run_recap_screen.dart:316` | Similar empty pattern |
| `_MapEmptyState` | `lib/runs/presentation/run_map_screen.dart:320` | Body text only |

`SwipeEmptyState` already has the right architecture — it takes a `SwipeEmptyContent` data class. **Fix**: create a single `CatchEmptyState` widget in core accepting `icon`, `title`, `message`, and optional `cta` (label + onPressed). Replace all six. Feature-specific content data classes stay where they are; only the layout widget is shared.

#### 5. `ChatsSliverHeader` and `RunClubsSliverHeader` share the same skeleton

Both extend `CatchSliverHeader` with identical structure:

- `_TitleRow`: displayL title + bodyS subtitle + right-side action widget
- `_SearchRow`: horizontal padding + search/action content

Only the text strings and action widget differ. **Fix**: add `title`, `subtitle`, `actions`, and `search` parameters to `CatchSliverHeader` so the two subclasses can be deleted. The base already accepts `title` and `bottom` widgets — the change is making the title-building pattern reusable instead of duplicated.

#### 6. `ProfileInfoChip` (swipes) duplicates `CatchChip` (core)

`lib/swipes/presentation/widgets/profile_info_chip.dart` renders an icon + label chip with hardcoded white-transparent colors. `CatchChip` already supports icon + label with token-driven theming. **Fix**: add optional `backgroundColor`/`foregroundColor` overrides to `CatchChip` (matching the pattern already used in `CatchBadge` and `CatchButton`), then delete `ProfileInfoChip` and use `CatchChip` instead.

---

### Medium impact — worth considering

#### 7. Stat display widgets overlap

| Widget | File | Layout |
|---|---|---|
| `StatColumn` | `lib/core/widgets/stat_column.dart` | Value + label vertically, optional icon, highlight, mono/center |
| `RunStatCell` | `lib/runs/presentation/widgets/run_stats_grid.dart` | Value + unit on baseline row, label below, always centered |
| `HostStatChip` | `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart` | Already wraps `StatColumn` in a surface container |

`RunStatCell` could become a variant of `StatColumn` by accepting a Widget for the "value" slot instead of a String. Low urgency since the baseline-aligned layout is unique to `RunStatCell`, but the 3 widgets share the same value-above-label conceptual model.

#### 8. `StatusChip` and `CatchBadge` both render status labels

`StatusChip` is enum-driven (run status → color mapping). `CatchBadge` is a general-purpose label badge with 7 tone variants. `StatusChip` could be rebuilt to use `CatchBadge` internally. Optional — they serve different semantic purposes and the dedup win is small.

---

### Low impact — OK as-is

- **`_DashboardSectionStateCard`** and **`_ActivityMessage`** — slightly different layouts for section-level loading/error states. Could share a widget but the payoff is small.
- **`VibeTag`** vs **`CatchChip`** — different visual design. Vibe tags are softer accent tags; `CatchChip` is a binary active/inactive selector chip. Different use cases.

---

### Consolidation scorecard

| Category | Widgets eliminated | Replaced by |
|---|---|---|
| Useless wrapper | 1 (`FieldLabel`) | `CatchFormFieldLabel` with `large: true` |
| Identical loading screens | 2 (`_DashboardLoadingScreen`, `_RouterLoadingScreen`) | 1 `CatchLoadingScreen` |
| Near-identical message screens | 2 (`_DashboardMessageScreen`, `_CalendarMessage`) | 1 `CatchMessageScreen` |
| Near-identical empty states | 6 (all empty state widgets) | 1 `CatchEmptyState` |
| Near-identical sliver headers | 2 (`ChatsSliverHeader`, `RunClubsSliverHeader`) | Parameterized `CatchSliverHeader` |
| Feature chip duplicates core | 1 (`ProfileInfoChip`) | Extended `CatchChip` |
| **Total** | **14 widgets → 5 shared** | |
