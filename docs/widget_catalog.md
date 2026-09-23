---
doc_id: widget_catalog
version: 4.9.1
updated: 2026-09-23
owner: recursive_audit_loop
status: active
---

# Widget Catalog

## Canonical Usage Decisions

Independent measurements use `CatchMetricSection.grid`; source-completeness
states use `.dataQuality` with the same adaptive tile geometry. Do not recreate
organizer summary strips or wrap the tile grid in a second surface. Large text
uses one column and natural-height labels. See the containment doctrine in
`docs/design_language.md` for the metric-only exception.

`CatchFieldStatus` is the single save-state input for all field recipes. Saving
locks disclosure controls and commit actions and supplies progress and
accessibility feedback. Direct text-input edit permissions remain caller-owned.

Disclosure controls use `CatchFieldMode` to distinguish local expansion from
caller-controlled expansion. Switching back to local ownership preserves the
last expansion. `inputActions` remains a caller-owned explicit-save editor.

Direct input completion uses Flutter's keyboard-action behavior. Callers that
need to retain focus, such as message composers, supply `onEditingComplete`;
`onSubmitted` receives the value afterward. Numeric typography uses native
`fontFeatures` instead of a separate typography flag.
`inputMode` reuses native text-input permissions for editing, focus and
selection. Display-only values stay outside the focus order; read-only inputs
can support selection or an explicit picker action.

`CatchFieldLabelTextMode` owns label visibility and optional wording. Content
and disclosure rows keep a visible label; direct inputs may hide it while
retaining one accessible native input name, including optional wording. The
mode does not change validation requirements or selection clearing.

L0 token definitions live in `packages/catch_tokens` and are consumed through
`package:catch_tokens/catch_tokens.dart`. Widgetbook foundation specimens in
`widgetbook/lib/foundation/specimens/` mount those same
production values. Theme wiring, typography, icons, motion, and bundled font assets now live
in `packages/catch_ui/lib/src/foundations`, consumed through
`package:catch_ui/catch_ui.dart`. `AppTheme` retains the app-specific activity
palette. Provider-free text/icon atoms, gaps, surfaces, image renderers and
interaction/layout primitives live in `catch_ui/src/primitives`.
Shared component and pattern widgets live in `catch_ui/src/components` and
`catch_ui/src/patterns`; domain and provider adapters remain app-owned.

`CatchBanner.statuses` (`packages/catch_ui/lib/src/components/catch_banner.dart`) owns durable
offline/rehearsal header anatomy, wrapping and 44 pt actions.
`CatchBannerStatusScope` publishes context without rendering it; canonical
screen owners consume it once below the complete title/tab header, preserve
the 16 pt standard body start and clear it for nested content. Features pass
`CatchBannerStatus` and `CatchBannerAction`, not a renderer or padding.
`CatchNoticeOverlay` now renders only the queued transient notice, never the
persistent context stack.

| Family | Use | Do not use |
|---|---|---|
| Screen composition | Every full-screen composition terminates in `CatchScaffold.standalone`, `.stepFlow`, or `.workspace`; only that primitive constructs Material `Scaffold`. Root title destinations use `.standard`, `.fullBleed`, or `.sections` on `CatchRootScreenScaffold` / `CatchRootScreenScrollView`; `.sections` keeps full-width rows and the 16 pt title-to-body rhythm. Roots with pinned peer navigation use `.withPrimaryRail` plus `CatchRootScreenPageScrollView`; pushed routes use `CatchRouteScaffold`. Select one root owner outside async state branches so loading, error, empty, and loaded content share its geometry. The composition gate verifies constructor role and branch-universal ownership. | Do not compose a feature-local `Scaffold` + `SafeArea` + `CustomScrollView` + title padding + terminal spacer, override a root title style, or choose a different root recipe for loading and loaded states. |
| Root and route headers | `CatchTopBar.route`, `.identity`, `.screen` and `.primaryRail` share one renderer and the platform function family. Task title precedes optional entity context; root titles use the headline scale. Search is a typed capability. The primitive owns wrapping, scaled heights and alignment. | No eyebrow, kicker, custom title widget/style, typography variant, size, mode, height, padding, gutter or alignment inputs. Translate invalid configurations and review fresh renders before updating goldens. |
| Browse search | A permanently expanded browse input renders no empty trailing control and shows its clear control only while the query is non-empty. `onCloseSearch` belongs only to morphing `expanding` chrome where an empty expanded search can collapse. | Do not pass `onCloseSearch` to a fixed Customers-style expanded search merely to occupy the trailing slot. |
| `CatchSection.divided` | Default for flat page-subject content and ordered detail groups. Typography, spacing, and hairlines carry hierarchy. Callers may supply a theme-resolved `titleColor`, including activity accents; omission uses the neutral section title. | Do not add a surrounding card or a surfaced empty state inside it. |
| `CatchSection.fieldRows` | Use for a titled divided group of sibling fields. The section owns its leading/header rule, text-lane sibling rules, and one interaction policy: responsive compact pages default to full bleed, while a section may explicitly request `roundedTile`. | Do not configure divider color/inset/role, give individual fields different interaction geometry, or use it as a headerless lane. |
| `CatchSection.controls` | Use for sort/filter controls above a collection. The Section owns the readable gutter and both full content-width rules; callers supply sort/filter labels and callbacks. Ordering is leading, Filters trailing, with an optional shared active-filter summary and Clear action. | Do not inject arbitrary children, reverse sort/filter placement, or draw screen-local boundary rules. |
| `CatchSection.loadingRows` / `.sliverLoadingRows` | Supply representative `CatchFieldLayout` values for the eventual row anatomy. Field and Section retain the loaded row's width, text lane, sibling rules, disclosure slot, and disabled loading semantics. | Do not substitute `CatchSkeleton.rows`, `.mediaRows`, or `.iconRows` for a known collection layout or add a loading-only outer card. |
| `CatchSection.containedFieldRows` | Use for one outlined group of sibling fields. A supplied title, count, or trailing action forms an outside kicker row by default; use `CatchSectionHeaderPlacement.inside` when that header belongs to the bounded group itself. Inside headers own the same inset end-to-end section rule as divided field sections. | Do not hand-roll a parallel kicker-plus-card shell, place an inside header without its section-owned rule, or round active child rows. |
| `CatchSection.dependentFieldRows` | A controlling Field and its applicable typed dependents share one rounded perimeter. The child area attaches through tint, without additional outlines or peer dividers. The section owns exact hit bounds; the form owns applicability and serialization. | Do not wrap only the children, accumulate indentation, or hide applicable fields when the control editor collapses. |
| `CatchSection.containedFieldGroups` | Use when one outlined collection contains one or more labelled groups of related field choices. Supply semantic `CatchSectionFieldGroup` descriptors; the section owns every internal kicker, boundary, sibling rule, clip, and active band. | Do not assemble subsection kickers and field dividers in feature code or use separate outlined sections for groups that form one choice set. |
| `CatchFieldLanes` | Use `.divided` for headerless sibling fields, `.single` for one ungrouped field, and `.custom` for a non-field body. Divided lanes inherit the responsive interaction policy and own canonical gutter and separators. | Do not override gutters or make a field paint its sibling divider. |
| `CatchSection.contained` | Fixed, shadowless frame around a related collection; semantic boundary, focus and error treatment belong to the section. | No paint or spacing overrides; ordinary information stays flat. |
| `CatchSection.action` | One bounded task: title, optional facts, explanation and a full-width primary, secondary or destructive CTA. | No arbitrary surface knobs, field lists in details, or card merely for an empty state. |
| `CatchSection.plain` | Flat information in an existing content lane, including Public reviews; enclosing composition owns section spacing. | Do not add a frame merely because information is empty or explanatory. |
| `CatchSliverEmptyState` | `packages/catch_ui/lib/src/patterns/catch_sliver_empty_state.dart:8` | Sliver placement of the canonical empty-state content and shared bottom-overlay accounting. |
| `CatchEmptyState` | It is content, not a section decision. Inside a section, leave `surface: false` and let the enclosing section own padding and chrome. A standalone route/pane may opt into `surface: true` only when that bounded region itself is the approved surface. | Do not change containment because data is absent; empty state must inherit the same owner as loaded content. |
| Semantic borders | Choose `CatchBorderRole.separator`, `boundary`, `control`, `selected`, `focus`, `danger`, or `warning`; higher-level primitives own interaction mapping. Focus is 2 px, selected/status is 1.5 px, and resting lines are 1 px with theme-aware contrast. | Do not pair raw border colors and widths in product UI, change outline geometry for hover/press, or make an error/loading branch invent containment. |

The inventory below is generated from public production Widget declarations,
class documentation and `design/components/catch.components.json`. Edit those
sources and run `node tool/design/generate_widget_catalog.mjs --write`;
`--check` detects stale output and hand edits. Undocumented and unreviewed
feature widgets remain visible. The new-widget gate checks source, registry
and Widgetbook identities without requiring a separate hand-authored table.

[CatchField doctrine](design_language.md#73-catchfield-doctrine) owns labelled
field behavior. [App architecture](app_architecture.md) owns layering and
naming; the [consolidation worklog](design_parity/widget_consolidation/codex_worklog.md)
owns active keep, replace and delete decisions. Git preserves former inventory
and candidate discussions; this document has no parallel status ledger.

<!-- BEGIN GENERATED WIDGET INVENTORY -->
<!-- Generated by tool/design/generate_widget_catalog.mjs. Do not edit this region. -->
## Production Widget Inventory

1166 public production Widgets. Source discovery determines membership; the component registry supplies reviewed identity and ladder metadata.

Purpose comes from the first class documentation paragraph, then the registry summary. 832 declarations have neither and remain visible as undocumented. Unreviewed feature Widgets use the existing screen-name boundary for L5/L6; that source classification is not a semantic conformance verdict.

### L2 (24)

| Widget | Source | Role | Canonical concept | Purpose |
|---|---|---|---|---|
| <code>CatchClockIndicator</code> | <code>packages/catch_ui/lib/src/primitives/catch_clock_indicator.dart:6</code> | <code>Indicator</code> | <code>catch.event_card</code> | Event-card time glyph member used by ticket and agenda compositions. |
| <code>CatchCodeCaretIndicator</code> | <code>packages/catch_ui/lib/src/primitives/catch_code_caret_indicator.dart:5</code> | <code>Indicator</code> | <code>catch.code_input</code> | Token-styled insertion caret used inside code input cells. |
| <code>CatchCodeDigitSurface</code> | <code>packages/catch_ui/lib/src/primitives/catch_code_digit_surface.dart:8</code> | <code>Surface</code> | <code>catch.code_input</code> | Token-styled verification-code cell. |
| <code>CatchControlSurface</code> | <code>packages/catch_ui/lib/src/primitives/catch_control_surface.dart:79</code> | <code>Surface</code> | <code>catch.control_shell</code> | Token-backed control containment with stable geometry across visual states. |
| <code>CatchDivider</code> | <code>packages/catch_ui/lib/src/primitives/catch_divider.dart:10</code> | <code>Divider</code> | <code>catch.section</code> | One token-backed separator for sections, field rows and metric columns. |
| <code>CatchFractionalViewport</code> | <code>packages/catch_ui/lib/src/primitives/catch_fractional_viewport.dart:8</code> | <code>Viewport</code> | <code>catch.screen_body</code> | Sizes a child to a fraction of its local lane, capped at an absolute width. |
| <code>CatchGradedImage</code> | <code>packages/catch_ui/lib/src/primitives/catch_graded_image.dart:119</code> | <code>Image</code> | <code>catch.graded_image</code> | Wraps a photo [child] in the shared [CatchGrade] for the current brightness. Non-destructive: the source image is untouched. Set [enabled] `false` to show the raw photo (e.g. the user viewing their own upload). |
| <code>CatchHeroViewport</code> | <code>packages/catch_ui/lib/src/primitives/catch_hero_viewport.dart:6</code> | <code>Viewport</code> | <code>catch.motion_viewport</code> | Shared Hero viewport for card flights with transparent Material chrome. |
| <code>CatchIconTile</code> | <code>packages/catch_ui/lib/src/primitives/catch_icon_tile.dart:10</code> | <code>Tile</code> | <code>catch.icon_tile</code> | Non-interactive icon presentation with tiled, empty and error recipes. |
| <code>CatchImageFallbackSurface</code> | <code>packages/catch_ui/lib/src/primitives/catch_image_fallback_surface.dart:5</code> | <code>Surface</code> | <code>catch.network_image</code> | Missing-image paint with neutral-glyph and branded hero recipes; source loading and errors stay with the image owner. |
| <code>CatchKickerText</code> | <code>packages/catch_ui/lib/src/primitives/catch_kicker_text.dart:8</code> | <code>Text</code> | <code>catch.typography</code> | Handoff `Kicker`: uppercase mono eyebrow for section starts and editorial labels. |
| <code>CatchLoadingIndicator</code> | <code>packages/catch_ui/lib/src/primitives/catch_loading_indicator.dart:8</code> | <code>Indicator</code> | <code>catch.loading_indicator</code> | Indeterminate activity feedback with circular, dots and inline recipes. |
| <code>CatchMediaOverlay</code> | <code>packages/catch_ui/lib/src/primitives/catch_media_overlay.dart:9</code> | <code>Overlay</code> | <code>catch.detail_media</code> | Photo scrim gradients for readable text and chrome over media. |
| <code>CatchMetadataText</code> | <code>packages/catch_ui/lib/src/primitives/catch_metadata_text.dart:5</code> | <code>Text</code> | <code>catch.typography</code> | Single-line mono label for compact metadata in cards and rails. |
| <code>CatchNetworkImage</code> | <code>packages/catch_ui/lib/src/primitives/catch_network_image.dart:18</code> | <code>Image</code> | <code>catch.network_image</code> | Canonical network-image primitive — the single seam every remote image in the app renders through. |
| <code>CatchPageIndicator</code> | <code>packages/catch_ui/lib/src/primitives/catch_page_indicator.dart:4</code> | <code>Indicator</code> | <code>catch.page_dots</code> | Compact page/progress dot indicator with selected-width emphasis, semantic label support, and motion-token transitions. |
| <code>CatchPagerFocusViewport</code> | <code>packages/catch_ui/lib/src/primitives/catch_pager_focus_viewport.dart:6</code> | <code>Viewport</code> | <code>catch.screen_body</code> | Stops descendant focus/caret reveal requests at a horizontal pager page. |
| <code>CatchRevealViewport</code> | <code>packages/catch_ui/lib/src/primitives/catch_reveal_viewport.dart:10</code> | <code>Viewport</code> | <code>catch.motion_viewport</code> | Presents content from an external transition clock with owned curve lifetime. |
| <code>CatchRowPressSurface</code> | <code>packages/catch_ui/lib/src/primitives/catch_row_press_surface.dart:10</code> | <code>Surface</code> | <code>catch.field</code> | Full-row interaction layer for list and field rows. |
| <code>CatchSectionHeaderTitle</code> | <code>packages/catch_ui/lib/src/primitives/catch_section_header_title.dart:7</code> | <code>HeaderTitle</code> | <code>catch.section</code> | Handoff `CatchSectionHeaderTitle`: an activity-accent eyebrow with an optional leading glyph and mono label. |
| <code>CatchSheetDragIndicator</code> | <code>packages/catch_ui/lib/src/primitives/catch_sheet_drag_indicator.dart:4</code> | <code>Indicator</code> | <code>catch.sheet</code> | Centered passive drag affordance for the owning sheet surface. |
| <code>CatchStatusIndicator</code> | <code>packages/catch_ui/lib/src/primitives/catch_status_indicator.dart:4</code> | <code>Indicator</code> | <code>catch.badge</code> | Dot-only status marker used inside rows, badges, and presence-style metadata. |
| <code>CatchSurface</code> | <code>packages/catch_ui/lib/src/primitives/catch_surface.dart:10</code> | <code>Surface</code> | <code>catch.surface</code> | Canonical Catch surface primitive for cards, panels, and tappable tiles. |
| <code>CatchTextInput</code> | <code>packages/catch_ui/lib/src/primitives/catch_text_input.dart:42</code> | <code>Input</code> | <code>catch.field</code> | Canonical low-level text-entry primitive. |

### L3 (96)

| Widget | Source | Role | Canonical concept | Purpose |
|---|---|---|---|---|
| <code>CatchActionMenu</code> | <code>packages/catch_ui/lib/src/components/catch_action_menu.dart:9</code> | <code>Menu</code> | <code>catch.menu</code> | Anchored overflow trigger for at most five commands; selected or informational status rows are structurally excluded. |
| <code>CatchAttributionRow</code> | <code>packages/catch_ui/lib/src/components/catch_attribution_row.dart:7</code> | <code>Row</code> | <code>catch.sheet</code> | Brand attribution and context for exported media. |
| <code>CatchAvatar</code> | <code>packages/catch_ui/lib/src/components/catch_avatar.dart:19</code> | <code>Avatar</code> | <code>catch.person_avatar</code> | Canonical avatar for photos, initials, activity identity, counts and veils. Callers own names, image URLs, count copy and activity colors. This component owns fallback selection, the clipping frame, ring and optional online dot. |
| <code>CatchAvatarInitialsSurface</code> | <code>packages/catch_ui/lib/src/components/catch_avatar_initials_surface.dart:14</code> | <code>Surface</code> | <code>catch.person_avatar</code> | The initials layer of an avatar; its parent owns clipping, photos and status. People use quiet paper/ink. The activity recipe uses caller-resolved pigment. |
| <code>CatchAvatarRow</code> | <code>packages/catch_ui/lib/src/components/catch_avatar_row.dart:11</code> | <code>Row</code> | <code>catch.person_avatar</code> | An overlapping row of avatars, anonymous slots and caller-formatted overflow. |
| <code>CatchAvatarViewport</code> | <code>packages/catch_ui/lib/src/components/catch_avatar_viewport.dart:11</code> | <code>Viewport</code> | <code>catch.person_avatar</code> | Shared avatar clipping, obscuring and label allocation. Labels fit inside the inscribed content square so larger text cannot wrap behind a circle. |
| <code>CatchBadge</code> | <code>packages/catch_ui/lib/src/components/catch_badge.dart:29</code> | <code>Badge</code> | <code>catch.badge</code> | Canonical small badge for compact, non-interactive metadata and status. |
| <code>CatchBanner</code> | <code>packages/catch_ui/lib/src/components/catch_banner.dart:20</code> | <code>Banner</code> | <code>catch.banner</code> | Persistent feedback with one icon, copy and action renderer. |
| <code>CatchBannerStatusScope</code> | <code>packages/catch_ui/lib/src/components/catch_banner_status_scope.dart:8</code> | <code>Scope</code> | <code>catch.banner</code> | Publishes context without drawing it. Canonical screen owners consume this scope once, below their title and optional primary rail, and clear it for nested content. The app publishes connectivity above the route navigator; route-specific rehearsal context is supplied to its scaffold's typed slot. |
| <code>CatchBarIndicator</code> | <code>packages/catch_ui/lib/src/components/catch_bar_indicator.dart:8</code> | <code>Indicator</code> | <code>catch.mini_bar_chart</code> | One quantitative bar, including empty stubs and bounded fractional values. |
| <code>CatchBarSeriesIndicator</code> | <code>packages/catch_ui/lib/src/components/catch_bar_series_indicator.dart:6</code> | <code>Indicator</code> | <code>catch.mini_bar_chart</code> | Compact quantitative bar series with one shared scale, explicit empty-value treatment and a shared single-bar renderer. |
| <code>CatchButton</code> | <code>packages/catch_ui/lib/src/components/catch_button.dart:37</code> | <code>Button</code> | <code>catch.button</code> | Canonical labelled action with command, selection and floating recipes. |
| <code>CatchButtonContentRow</code> | <code>packages/catch_ui/lib/src/components/catch_button_content_row.dart:4</code> | <code>Row</code> | <code>catch.button</code> | Button content row with optional leading media, centered label and natural-height wrapping; interaction and busy state remain Button-owned. |
| <code>CatchChip</code> | <code>packages/catch_ui/lib/src/components/catch_chip.dart:24</code> | <code>Chip</code> | <code>catch.chip</code> | Canonical compact-label primitive for facts, choices, activities, and removable values. |
| <code>CatchChoiceButton</code> | <code>packages/catch_ui/lib/src/components/catch_choice_button.dart:9</code> | <code>Button</code> | <code>catch.chip.field</code> | Direct option renderer with platform-sized activation, selected/disabled semantics, and preserved custom spoken-label actions. Underline and operational labels retain a defensive one-line ellipsis fallback; CatchChoiceInput.segmented measures full content and enables scrolling before that fallback is needed. Summary labels wrap. |
| <code>CatchChoiceInput</code> | <code>packages/catch_ui/lib/src/components/catch_choice_input.dart:27</code> | <code>Input</code> | <code>catch.chip.field</code> | Checked choices with caller-owned values and shared selection policy. |
| <code>CatchChoiceTile</code> | <code>packages/catch_ui/lib/src/components/catch_choice_tile.dart:12</code> | <code>Tile</code> | <code>catch.chip.field</code> | One mutually exclusive choice with optional explanatory copy. |
| <code>CatchCodeInput</code> | <code>packages/catch_ui/lib/src/components/catch_code_input.dart:16</code> | <code>Input</code> | <code>catch.code_input</code> | Canonical editable one-time-code input with synchronized visual digits. |
| <code>CatchCodeInputRow</code> | <code>packages/catch_ui/lib/src/components/catch_code_input_row.dart:8</code> | <code>Row</code> | <code>catch.code_input</code> | Token-styled row of verification-code cells. |
| <code>CatchCollapsedHeaderTitle</code> | <code>packages/catch_ui/lib/src/components/catch_collapsed_header_title.dart:6</code> | <code>HeaderTitle</code> | <code>catch.top_bar</code> | Toolbar title that appears only after a flexible sliver header collapses. |
| <code>CatchContentSection</code> | <code>packages/catch_ui/lib/src/components/catch_content_section.dart:44</code> | <code>Section</code> | <code>catch.section</code> | Non-row content has a readable inset and no shared row recognizer. |
| <code>CatchContentSectionHeader</code> | <code>packages/catch_ui/lib/src/components/catch_content_section.dart:14</code> | <code>Header</code> | <code>catch.section</code> | Internal header boundary shared by row and non-row section recipes. |
| <code>CatchCountBadge</code> | <code>packages/catch_ui/lib/src/components/catch_count_badge.dart:13</code> | <code>Badge</code> | <code>catch.badge</code> | Canonical integer count marker. |
| <code>CatchCountText</code> | <code>packages/catch_ui/lib/src/components/catch_count_text.dart:6</code> | <code>Text</code> | <code>catch.section</code> | Animated, uncapped numeric text for count-bearing headers. |
| <code>CatchDataQualityMetricTile</code> | <code>packages/catch_ui/lib/src/components/catch_data_quality_metric_tile.dart:10</code> | <code>Tile</code> | <code>catch.analytics_metric</code> | Summary surface for a caller-formatted metric and its data-quality status. |
| <code>CatchDaySectionHeader</code> | <code>packages/catch_ui/lib/src/components/catch_day_section_header.dart:12</code> | <code>Header</code> | <code>catch.section</code> | Sticky day-section header for chronologically grouped feeds. |
| <code>CatchDependentRowSection</code> | <code>packages/catch_ui/lib/src/components/catch_dependent_row_section.dart:13</code> | <code>Section</code> | <code>catch.section</code> | Internal renderer for Section's conditional configuration recipe. The leading and descendants share geometry; tint signals attachment without adding another perimeter or claiming that a dependency is an equal peer. |
| <code>CatchDialog</code> | <code>packages/catch_ui/lib/src/components/catch_dialog.dart:81</code> | <code>Dialog</code> | <code>catch.confirm_dialog</code> | Shared modal frame for slotted content and typed confirmation choices. |
| <code>CatchDistanceOverlay</code> | <code>packages/catch_ui/lib/src/components/catch_distance_overlay.dart:12</code> | <code>Overlay</code> | <code>catch.distance_ring</code> | Map radius annotation with fixed or available-space geometry. |
| <code>CatchDividedFieldInteractionScope</code> | <code>packages/catch_ui/lib/src/components/catch_divided_field_interaction_scope.dart:5</code> | <code>Scope</code> | <code>catch.field</code> | Internal responsive policy scope published by section-page composition. |
| <code>CatchDockSurface</code> | <code>packages/catch_ui/lib/src/components/catch_dock_surface.dart:31</code> | <code>Surface</code> | <code>catch.bottom_action</code> | Persistent control surface with utility and primary-action recipes. |
| <code>CatchEmptyState</code> | <code>packages/catch_ui/lib/src/components/catch_empty_state.dart:10</code> | <code>EmptyState</code> | <code>catch.empty_state</code> | Canonical successful-empty content with bounded and inline layout. |
| <code>CatchErrorBackButton</code> | <code>packages/catch_ui/lib/src/components/catch_error_back_button.dart:7</code> | <code>Button</code> | <code>catch.error_state</code> | Canonical exit affordance for terminal error states where retry is not a truthful action (for example a deleted event or an unauthorized route). |
| <code>CatchErrorDetailsAccordion</code> | <code>packages/catch_ui/lib/src/components/catch_error_details_accordion.dart:8</code> | <code>Accordion</code> | <code>catch.error_state</code> | Tokenized debug-only framework error disclosure used by CatchFrameworkErrorState. |
| <code>CatchErrorState</code> | <code>packages/catch_ui/lib/src/components/catch_error_state.dart:11</code> | <code>ErrorState</code> | <code>catch.error_state</code> | Canonical error content with full-region, inline and compact placement. |
| <code>CatchField</code> | <code>packages/catch_ui/lib/src/components/catch_field.dart:35</code> | <code>Field</code> | <code>catch.field</code> | Design-system `Field`: the unified field primitive for row, text-entry, navigation, toggle, disclosure-control, add, validation, and helper states. Stack fields in a CatchSection when the surrounding section owns box or divider chrome. |
| <code>CatchFieldActionRow</code> | <code>packages/catch_ui/lib/src/components/catch_field_action_row.dart:6</code> | <code>Row</code> | <code>catch.field</code> | Trailing Cancel/Done group used by explicit-save field drawers. |
| <code>CatchFieldCommitButton</code> | <code>packages/catch_ui/lib/src/components/catch_field_commit_button.dart:10</code> | <code>Button</code> | <code>catch.field</code> | Exact Cancel/Done action used by a disclosed `CatchField` editor. |
| <code>CatchFieldContentRow</code> | <code>packages/catch_ui/lib/src/components/catch_field_content_row.dart:16</code> | <code>Row</code> | <code>catch.field</code> | Field content with two explicit hierarchies: title/description and caption/value. The enclosing field owns interaction; this member owns text lanes and support. |
| <code>CatchFieldDrawer</code> | <code>packages/catch_ui/lib/src/components/catch_field_drawer.dart:8</code> | <code>Drawer</code> | <code>catch.field</code> | Full-row disclosure below a field header, including its supporting content. |
| <code>CatchFieldGeometryScope</code> | <code>packages/catch_ui/lib/src/components/catch_field_geometry_scope.dart:23</code> | <code>Scope</code> | <code>catch.field</code> | Ambient contract for field-row content and interaction geometry. |
| <code>CatchFieldInput</code> | <code>packages/catch_ui/lib/src/components/catch_field_input.dart:58</code> | <code>Input</code> | <code>catch.field</code> | Native input, validation, and text-entry chrome owned by a CatchField. |
| <code>CatchFieldInteractionPlaneScope</code> | <code>packages/catch_ui/lib/src/components/catch_field_interaction_plane_scope.dart:10</code> | <code>Scope</code> | <code>catch.field</code> | Internal page/lane paint extent published by semantic body primitives. |
| <code>CatchFieldLabelText</code> | <code>packages/catch_ui/lib/src/components/catch_field_label_text.dart:22</code> | <code>Text</code> | <code>catch.field</code> | Field-owned visible label and localized optional accessibility description. |
| <code>CatchFieldLanes</code> | <code>packages/catch_ui/lib/src/components/catch_field_lanes.dart:17</code> | <code>FieldLanes</code> | <code>catch.field</code> | Explicit composition boundary for reusable Field rows that do not own a titled or surfaced `CatchSection`. |
| <code>CatchFieldRow</code> | <code>packages/catch_ui/lib/src/components/catch_field_row.dart:6</code> | <code>Row</code> | <code>catch.field</code> | Field row anatomy with leading, body and trailing lanes; the parent owns geometry. |
| <code>CatchFieldStatusIndicator</code> | <code>packages/catch_ui/lib/src/components/catch_field_status_indicator.dart:14</code> | <code>Indicator</code> | <code>catch.field</code> | Animated saving/saved feedback for the `CatchField` trailing lane. |
| <code>CatchFieldSupportRow</code> | <code>packages/catch_ui/lib/src/components/catch_field_support_row.dart:8</code> | <code>Row</code> | <code>catch.field</code> | Field helper/error and optional counter row. |
| <code>CatchFieldSurface</code> | <code>packages/catch_ui/lib/src/components/catch_field_surface.dart:15</code> | <code>Surface</code> | <code>catch.field</code> | Field state paint: row backgrounds and the focus ring of a small target. |
| <code>CatchFieldTrailingRow</code> | <code>packages/catch_ui/lib/src/components/catch_field_trailing_row.dart:13</code> | <code>Row</code> | <code>catch.field</code> | Public trailing-slot member used by CatchField for value text, chevrons, toggles, clear actions, validation, and custom trailing content. CatchField composes non-centered trailing content into one lane after a single 18 px caption reserve and centers it within the 18.9 px value line. Saving progress appears here only when no explicit commit bar is visible. Its inputSuffix recipe preserves native text-entry clear and custom fallback behavior, including the close glyph and action/icon spacing; the field retains null allocation for an absent suffix. |
| <code>CatchFieldVisibilityScope</code> | <code>packages/catch_ui/lib/src/components/catch_field_visibility_scope.dart:11</code> | <code>Scope</code> | <code>catch.field</code> | Ambient visibility contract for disclosure fields inside obstructed scroll surfaces. |
| <code>CatchFrameworkErrorState</code> | <code>packages/catch_ui/lib/src/components/catch_framework_error_state.dart:27</code> | <code>ErrorState</code> | <code>catch.error_state</code> | Branded fallback for Flutter framework build errors. |
| <code>CatchHeroImage</code> | <code>packages/catch_ui/lib/src/components/catch_hero_image.dart:7</code> | <code>Image</code> | <code>catch.detail_media</code> | Hero image assembly with shared source loading, photo grading, a branded missing-image surface and optional readability overlay. |
| <code>CatchHorizontalScrollView</code> | <code>packages/catch_ui/lib/src/components/catch_horizontal_scroll_view.dart:29</code> | <code>ScrollView</code> | <code>catch.section</code> | Horizontal item viewport with lazy bounded-height and intrinsic-height forms. |
| <code>CatchIconAction</code> | <code>packages/catch_ui/lib/src/components/catch_icon_action.dart:35</code> | <code>IconAction</code> | <code>catch.icon_button</code> | Canonical icon-only action with one focus, feedback and count owner. |
| <code>CatchIndexRow</code> | <code>packages/catch_ui/lib/src/components/catch_index_row.dart:8</code> | <code>Row</code> | <code>catch.index_row</code> | Canonical hairline index row for compact directories and browse lists. |
| <code>CatchMenu</code> | <code>packages/catch_ui/lib/src/components/catch_menu.dart:19</code> | <code>Menu</code> | <code>catch.menu</code> | Canonical menu panel, optionally anchored to a caller-owned trigger. |
| <code>CatchMenuRow</code> | <code>packages/catch_ui/lib/src/components/catch_menu_row.dart:7</code> | <code>Row</code> | <code>catch.menu</code> | Direct menu-row renderer with explicit action or mutually-exclusive choice semantics. |
| <code>CatchMetaRow</code> | <code>packages/catch_ui/lib/src/components/catch_meta_row.dart:15</code> | <code>Row</code> | <code>catch.meta_row</code> | Compact factual metadata, from a single icon/label to a separated group. |
| <code>CatchMetricSection</code> | <code>packages/catch_ui/lib/src/components/catch_metric_section.dart:19</code> | <code>Section</code> | <code>catch.metric_strip</code> | Local arrangement of metric values or data-quality-aware metric tiles. |
| <code>CatchMetricTile</code> | <code>packages/catch_ui/lib/src/components/catch_metric_tile.dart:18</code> | <code>Tile</code> | <code>catch.metric_strip</code> | One caller-formatted value and its label, with an optional icon or unit. |
| <code>CatchNavigationButton</code> | <code>packages/catch_ui/lib/src/components/catch_navigation_button.dart:13</code> | <code>Button</code> | <code>catch.tab_bar</code> | A navigation destination with bottom-bar and side-rail layout recipes. |
| <code>CatchNotice</code> | <code>packages/catch_ui/lib/src/components/catch_notice.dart:12</code> | <code>Notice</code> | <code>catch.notice</code> | Configurable ambient notice family with one app-level safe-area overlay. Arrival notices open from the whole card and support swipe dismissal; ordinary notifications use explicit action and dismiss controls. Features own copy, identity, tone and routing; the shared renderer owns readable geometry and interaction. |
| <code>CatchPageTabBar</code> | <code>packages/catch_ui/lib/src/components/catch_page_tab_bar.dart:16</code> | <code>TabBar</code> | <code>catch.chip.field</code> | Page-level peer navigation in the canonical scaled app-bar shell. |
| <code>CatchPolaroid</code> | <code>packages/catch_ui/lib/src/components/catch_polaroid.dart:14</code> | <code>Polaroid</code> | <code>catch.person_polaroid</code> | Canonical person material: a portrait-first instant photograph with a quiet handwritten-note lane rendered in Catch's editorial typography. |
| <code>CatchPrivacyBadge</code> | <code>packages/catch_ui/lib/src/components/catch_privacy_badge.dart:21</code> | <code>Badge</code> | <code>catch.badge</code> | Privacy/visibility adapter with caller-resolved labels and fixed mode-to-icon pairing in CatchBadge.privacy. |
| <code>CatchRangeInput</code> | <code>packages/catch_ui/lib/src/components/catch_range_input.dart:12</code> | <code>Input</code> | <code>catch.range_slider</code> | Edits an ordered numeric interval through two independently movable ends. |
| <code>CatchRowSection</code> | <code>packages/catch_ui/lib/src/components/catch_row_section.dart:24</code> | <code>Section</code> | <code>catch.section</code> | Internal renderer for the typed Field collection recipes on CatchSection. |
| <code>CatchSearchField</code> | <code>packages/catch_ui/lib/src/components/catch_search_field.dart:18</code> | <code>Field</code> | <code>catch.search_field</code> | Handoff `SearchField`: raised pill input with search glyph and quiet clear target. |
| <code>CatchSection</code> | <code>packages/catch_ui/lib/src/components/catch_section.dart:44</code> | <code>Section</code> | <code>catch.section</code> | Design-system `Section`: the canonical primitive for grouping information. |
| <code>CatchSectionHeader</code> | <code>packages/catch_ui/lib/src/components/catch_section_header.dart:9</code> | <code>Header</code> | <code>catch.section</code> | Section heading, count and trailing-action layouts, selected by recipe. |
| <code>CatchSectionRowList</code> | <code>packages/catch_ui/lib/src/components/catch_section_row_list.dart:13</code> | <code>RowList</code> | <code>catch.section</code> | Section-owned child stack and separators, without header or surface chrome. |
| <code>CatchSectionSurface</code> | <code>packages/catch_ui/lib/src/components/catch_section_surface.dart:12</code> | <code>Surface</code> | <code>catch.section</code> | Contained section perimeter, including explicit error/focus chrome. |
| <code>CatchSelectionField</code> | <code>packages/catch_ui/lib/src/components/catch_selection_field.dart:24</code> | <code>Field</code> | <code>catch.field</code> | Field-owned selection menu, validation state, and labelled value row. |
| <code>CatchSelectionMenu</code> | <code>packages/catch_ui/lib/src/components/catch_selection_menu.dart:12</code> | <code>Menu</code> | <code>catch.menu</code> | Mutually-exclusive selection with anchored, adaptive and button-trigger recipes. |
| <code>CatchSelectionSheet</code> | <code>packages/catch_ui/lib/src/components/catch_selection_sheet.dart:10</code> | <code>Sheet</code> | <code>catch.menu</code> | Phone-friendly selection surface with mutually-exclusive row semantics. |
| <code>CatchShareCardSheet</code> | <code>packages/catch_ui/lib/src/components/catch_share_card_sheet.dart:13</code> | <code>Sheet</code> | <code>catch.sheet</code> | Presentation-only card preview and share action. |
| <code>CatchSheet</code> | <code>packages/catch_ui/lib/src/components/catch_sheet.dart:49</code> | <code>Sheet</code> | <code>catch.sheet</code> | Canonical sheet surface, header and terminal safe region. |
| <code>CatchSheetHeader</code> | <code>packages/catch_ui/lib/src/components/catch_sheet_header.dart:8</code> | <code>Header</code> | <code>catch.sheet</code> | Sheet heading with plain or branded glyph presentation and a trailing slot. |
| <code>CatchStatusRow</code> | <code>packages/catch_ui/lib/src/components/catch_status_row.dart:10</code> | <code>Row</code> | <code>catch.badge</code> | Quiet, unboxed status made from a semantic dot and supporting copy. |
| <code>CatchStepHeader</code> | <code>packages/catch_ui/lib/src/components/catch_step_header.dart:11</code> | <code>Header</code> | <code>catch.step_header</code> | Handoff `StepHeader`: wizard header built from the shared large AppBar plus a 2px progress hairline. |
| <code>CatchStepRowList</code> | <code>packages/catch_ui/lib/src/components/catch_step_row_list.dart:13</code> | <code>RowList</code> | <code>catch.journey_steps</code> | Ordered instructional rows with automatic numbering and a connecting trace. |
| <code>CatchStepper</code> | <code>packages/catch_ui/lib/src/components/catch_stepper.dart:11</code> | <code>Stepper</code> | <code>catch.number_stepper</code> | Bounded numeric adjustment with accelerated hold-to-repeat controls. |
| <code>CatchStepperRepeatButton</code> | <code>packages/catch_ui/lib/src/components/catch_stepper_repeat_button.dart:12</code> | <code>Button</code> | <code>catch.number_stepper</code> | Hold-to-repeat platform-sized target used by `CatchStepper`. |
| <code>CatchTabBar</code> | <code>packages/catch_ui/lib/src/components/catch_tab_bar.dart:16</code> | <code>TabBar</code> | <code>catch.tab_bar</code> | Bottom navigation with one shared selection/contact indicator, drag-to- select behavior, and platform-adaptive chrome. |
| <code>CatchTabBarIndicator</code> | <code>packages/catch_ui/lib/src/components/catch_tab_bar_indicator.dart:4</code> | <code>Indicator</code> | <code>catch.tab_bar</code> | Shared selection and contact-preview fill with an optional focus border and reduced-motion handling. |
| <code>CatchTicket</code> | <code>packages/catch_ui/lib/src/components/catch_ticket.dart:12</code> | <code>Ticket</code> | <code>catch.ticket</code> | Ticket material with a hero recipe for a bounded, collapsing surface. |
| <code>CatchTicketDivider</code> | <code>packages/catch_ui/lib/src/components/catch_ticket_divider.dart:8</code> | <code>Divider</code> | <code>catch.ticket</code> | Ticket perforation aligned to the notch geometry of its containing ticket. |
| <code>CatchTimestampedMessageText</code> | <code>packages/catch_ui/lib/src/components/catch_timestamped_message_text.dart:8</code> | <code>Text</code> | <code>catch.timestamped_message</code> | Lays out a chat timestamp on the final message line when it fits, otherwise directly below it. |
| <code>CatchToggleInput</code> | <code>packages/catch_ui/lib/src/components/catch_toggle_input.dart:12</code> | <code>Input</code> | <code>catch.toggle</code> | Catch settings toggle. |
| <code>CatchToolbarButton</code> | <code>packages/catch_ui/lib/src/components/catch_toolbar_button.dart:10</code> | <code>Button</code> | <code>catch.top_bar</code> | Labelled action or current-value selector button in canonical app chrome. |
| <code>CatchToolbarScope</code> | <code>packages/catch_ui/lib/src/components/catch_toolbar_scope.dart:4</code> | <code>Scope</code> | <code>catch.top_bar</code> | Internal chrome boundary: generic body controls must not restyle app bars. |
| <code>CatchTopBar</code> | <code>packages/catch_ui/lib/src/components/catch_top_bar.dart:29</code> | <code>TopBar</code> | <code>catch.top_bar</code> | Canonical app chrome. Recipes own typography, hierarchy and geometry. |
| <code>CatchTopBarActionRow</code> | <code>packages/catch_ui/lib/src/components/catch_top_bar_action_row.dart:10</code> | <code>Row</code> | <code>catch.top_bar</code> | Canonical trailing-action layout for Catch top bars and screen headers. |
| <code>CatchTopBarPrimaryButton</code> | <code>packages/catch_ui/lib/src/components/catch_top_bar_primary_button.dart:12</code> | <code>Button</code> | <code>catch.top_bar</code> | Primary root-screen action that preserves canonical top-bar geometry. |
| <code>CatchWheelPickerSheet</code> | <code>packages/catch_ui/lib/src/components/catch_wheel_picker_sheet.dart:10</code> | <code>Sheet</code> | <code>catch.sheet</code> | Shared wheel-picker sheet with caller-resolved copy and actions. |

### L4 (26)

| Widget | Source | Role | Canonical concept | Purpose |
|---|---|---|---|---|
| <code>CatchBottomActionOverlay</code> | <code>packages/catch_ui/lib/src/patterns/catch_bottom_action_overlay.dart:14</code> | <code>Overlay</code> | <code>catch.bottom_action</code> | Scroll-aware layout for actions that should stay pinned without a dock. |
| <code>CatchErrorScaffold</code> | <code>packages/catch_ui/lib/src/patterns/catch_error_scaffold.dart:7</code> | <code>Scaffold</code> | <code>catch.error_state</code> | Route/root-tab placement adapter for full-screen app data-load failures. |
| <code>CatchFormChoiceField</code> | <code>packages/catch_ui/lib/src/patterns/catch_form_choice_field.dart:8</code> | <code>Field</code> | <code>catch.field</code> | Form-owned choice drafts, explicit commits and save feedback. Single and multiple selection share one lifecycle; descriptors retain types. |
| <code>CatchFormRangeField</code> | <code>packages/catch_ui/lib/src/patterns/catch_form_range_field.dart:6</code> | <code>Field</code> | <code>catch.field</code> | Form-owned bounded range draft with explicit confirmation and patch saves. |
| <code>CatchFormReviewPageBody</code> | <code>packages/catch_ui/lib/src/patterns/catch_form_review_page_body.dart:10</code> | <code>PageBody</code> | <code>catch.screen_body</code> | Final review page with summary fields and one resumable form-step list. |
| <code>CatchFormRowList</code> | <code>packages/catch_ui/lib/src/patterns/catch_form_row_list.dart:9</code> | <code>RowList</code> | <code>catch.field</code> | Maps typed form descriptors to canonical CatchField rows inside one CatchSection, with one accordion and one per-field patch save delegate. |
| <code>CatchFormStepRowList</code> | <code>packages/catch_ui/lib/src/patterns/catch_form_step_row_list.dart:32</code> | <code>RowList</code> | <code>catch.screen_body</code> | Navigable form sections with completion status and caller-owned selection. |
| <code>CatchFormTextField</code> | <code>packages/catch_ui/lib/src/patterns/catch_form_text_field.dart:9</code> | <code>Field</code> | <code>catch.field</code> | Form-owned text draft, normalization and validation with list-owned commit policy. |
| <code>CatchMasterDetailViewport</code> | <code>packages/catch_ui/lib/src/patterns/catch_master_detail_viewport.dart:10</code> | <code>Viewport</code> | <code>catch.screen_body</code> | Index/detail pane geometry with explicit or local-width split selection. |
| <code>CatchPageBody</code> | <code>packages/catch_ui/lib/src/patterns/catch_page_body.dart:14</code> | <code>PageBody</code> | <code>catch.screen_body</code> | Page insets and field paint geometry, with form, screen and sliver recipes. |
| <code>CatchRootScreenPageScrollView</code> | <code>packages/catch_ui/lib/src/patterns/catch_root_screen_page_scroll_view.dart:15</code> | <code>ScrollView</code> | <code>catch.screen_body</code> | Inner scroll owner for one page of `CatchRootScreenScaffold`. |
| <code>CatchRootScreenScaffold</code> | <code>packages/catch_ui/lib/src/patterns/catch_root_screen_scaffold.dart:18</code> | <code>Scaffold</code> | <code>catch.screen_body</code> | Full-screen owner for a root destination with scroll-content title chrome. |
| <code>CatchRootScreenScrollView</code> | <code>packages/catch_ui/lib/src/patterns/catch_root_screen_scroll_view.dart:25</code> | <code>ScrollView</code> | <code>catch.screen_body</code> | Root-screen scroll composition for a pane whose parent already owns the [Scaffold], such as an adaptive master-detail workspace. |
| <code>CatchRouteScaffold</code> | <code>packages/catch_ui/lib/src/patterns/catch_route_scaffold.dart:359</code> | <code>Scaffold</code> | <code>catch.screen_body</code> | Canonical shell for pushed utility, list, and identity routes. |
| <code>CatchRowViewport</code> | <code>packages/catch_ui/lib/src/patterns/catch_row_viewport.dart:5</code> | <code>Viewport</code> | <code>catch.screen_body</code> | Internal boundary published only by page and pane owners. A section may inset its content, but cannot quietly shrink the row interaction perimeter. |
| <code>CatchRowViewportScope</code> | <code>packages/catch_ui/lib/src/patterns/catch_row_viewport.dart:23</code> | <code>Scope</code> | <code>catch.screen_body</code> | Internal inherited width value owned by CatchRowViewport; consumers cannot publish a fabricated row perimeter. |
| <code>CatchScaffold</code> | <code>packages/catch_ui/lib/src/patterns/catch_scaffold.dart:17</code> | <code>Scaffold</code> | <code>catch.screen_body</code> | Canonical surface owner for full-screen compositions. |
| <code>CatchScrollTerminalGap</code> | <code>packages/catch_ui/lib/src/patterns/catch_scroll_terminal_gap.dart:9</code> | <code>Gap</code> | <code>catch.screen_body</code> | Terminal breathing room plus the space obstructed by shell or safe area. |
| <code>CatchScrollView</code> | <code>packages/catch_ui/lib/src/patterns/catch_scroll_view.dart:9</code> | <code>ScrollView</code> | <code>catch.screen_body</code> | Scrolls overflow while short content fills the local viewport height. |
| <code>CatchSectionList</code> | <code>packages/catch_ui/lib/src/patterns/catch_section_list.dart:24</code> | <code>SectionList</code> | <code>catch.section_stack</code> | Ordered section rhythm with inset, sliver, responsive and page recipes. |
| <code>CatchSkeleton</code> | <code>packages/catch_ui/lib/src/patterns/catch_skeleton.dart:12</code> | <code>Skeleton</code> | <code>catch.skeleton</code> | Derives loading paint from real content or a single unresolved leaf shape. |
| <code>CatchSliverEmptyState</code> | <code>packages/catch_ui/lib/src/patterns/catch_sliver_empty_state.dart:9</code> | <code>EmptyState</code> | <code>catch.empty_state</code> | Canonical sliver placement for a full-region empty success state. |
| <code>CatchSliverErrorState</code> | <code>packages/catch_ui/lib/src/patterns/catch_sliver_error_state.dart:6</code> | <code>ErrorState</code> | <code>catch.error_state</code> | Sliver placement adapter for branded load failures inside CustomScrollView routes. |
| <code>CatchStateViewport</code> | <code>packages/catch_ui/lib/src/patterns/catch_state_viewport.dart:10</code> | <code>Viewport</code> | <code>catch.empty_state</code> | Removes the floating shell obstruction from state placement. |
| <code>CatchTabViewportScope</code> | <code>packages/catch_ui/lib/src/patterns/catch_tab_viewport_scope.dart:8</code> | <code>Scope</code> | <code>catch.screen_body</code> | Route-neutral active-page and bottom-obstruction metrics for shared layouts. |
| <code>CatchViewport</code> | <code>packages/catch_ui/lib/src/patterns/catch_viewport.dart:13</code> | <code>Viewport</code> | <code>catch.viewport</code> | Local viewport measurement and caller-owned layout selection. |

### L4a (7)

| Widget | Source | Role | Canonical concept | Purpose |
|---|---|---|---|---|
| <code>CatchAsyncBoundary</code> | <code>lib/core/riverpod_ui/catch_async_boundary.dart:21</code> | <code>AsyncBoundary</code> | <code>catch.async_value</code> | Exhaustive async-state selection with one timeout and recovery lifecycle. |
| <code>CatchExternalShareSheet</code> | <code>lib/core/riverpod_ui/catch_external_share_sheet.dart:17</code> | <code>Sheet</code> | <code>catch.sheet</code> | UI adapter for the app's Riverpod-backed external share controller. |
| <code>CatchLocalizedErrorBanner</code> | <code>lib/core/riverpod_ui/catch_localized_error_banner.dart:8</code> | <code>Banner</code> | <code>catch.banner</code> | Resolves app errors and retry copy at the caller's localization boundary. |
| <code>CatchLocalizedErrorScaffold</code> | <code>lib/core/riverpod_ui/catch_localized_error_scaffold.dart:7</code> | <code>Scaffold</code> | <code>catch.error_state</code> | Resolves app errors and inherited-locale copy for [CatchErrorScaffold]. |
| <code>CatchLocalizedErrorState</code> | <code>lib/core/riverpod_ui/catch_localized_error_state.dart:7</code> | <code>ErrorState</code> | <code>catch.error_state</code> | Resolves app errors and inherited-locale copy for [CatchErrorState]. |
| <code>CatchLocalizedSliverErrorState</code> | <code>lib/core/riverpod_ui/catch_localized_sliver_error_state.dart:7</code> | <code>ErrorState</code> | <code>catch.error_state</code> | Resolves app errors and inherited-locale copy for [CatchSliverErrorState]. |
| <code>CatchNoticeOverlay</code> | <code>lib/core/riverpod_ui/catch_notice_overlay.dart:11</code> | <code>Overlay</code> | <code>catch.notice</code> | One MyApp-owned safe-area overlay above the router, with a real overlay ancestor for tooltips. Owns entry motion, gesture/keyboard dismissal, F6 focus transfer and interaction-aware timers for every notice; persistent context remains with CatchBanner.statuses below tabs. |

### L5 (900)

| Widget | Source | Role | Canonical concept | Purpose |
|---|---|---|---|---|
| <code>ForceUpdateGate</code> | <code>lib/app.dart:113</code> | — | — | No class documentation or registry summary. |
| <code>HostAuthFlowFrame</code> | <code>lib/auth/presentation/auth_screen.dart:82</code> | — | — | Host auth frame whose top brand stage is geometrically identical to the Flutter startup surface. Only the lower content is animated. |
| <code>HostAuthCard</code> | <code>lib/auth/presentation/host_auth_widgets.dart:6</code> | — | — | The outlined lower-stage container shared by every Catch Host auth state. |
| <code>HostAuthHeader</code> | <code>lib/auth/presentation/host_auth_widgets.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>HostAuthProgressButton</code> | <code>lib/auth/presentation/host_auth_widgets.dart:52</code> | — | — | A non-interactive primary action surface that preserves the button's geometry while an authentication request is in flight. |
| <code>CountryCodeSelector</code> | <code>lib/auth/presentation/phone_page.dart:298</code> | — | — | No class documentation or registry summary. |
| <code>EventChatParticipantsRowList</code> | <code>lib/chats/presentation/event_chat_participants_screen.dart:110</code> | — | — | No class documentation or registry summary. |
| <code>EventChatPageBody</code> | <code>lib/chats/presentation/event_chat_screen.dart:308</code> | — | — | No class documentation or registry summary. |
| <code>EventChatDirectoryRowList</code> | <code>lib/chats/presentation/inbox/event_chat_directory_section.dart:46</code> | — | — | Sliver directory of currently admitted events, including rooms not open yet. |
| <code>EventChatDirectorySection</code> | <code>lib/chats/presentation/inbox/event_chat_directory_section.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>ChatConversationsList</code> | <code>lib/chats/presentation/inbox/widgets/chat_conversations_list.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>ChatsEmptyState</code> | <code>lib/chats/presentation/inbox/widgets/chats_empty_state.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>ChatPersonRowSkeleton</code> | <code>lib/chats/presentation/inbox/widgets/chats_list.dart:122</code> | — | — | No class documentation or registry summary. |
| <code>ChatsList</code> | <code>lib/chats/presentation/inbox/widgets/chats_list.dart:20</code> | — | — | No class documentation or registry summary. |
| <code>ChatsListSkeleton</code> | <code>lib/chats/presentation/inbox/widgets/chats_list.dart:98</code> | — | — | No class documentation or registry summary. |
| <code>ChatsListBody</code> | <code>lib/chats/presentation/inbox/widgets/chats_list_body.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>ChatsBrowseHeader</code> | <code>lib/chats/presentation/inbox/widgets/chats_sliver_header.dart:33</code> | — | — | No class documentation or registry summary. |
| <code>ChatEventContextHeader</code> | <code>lib/chats/presentation/widgets/chat_event_context_header.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>ChatInputBar</code> | <code>lib/chats/presentation/widgets/chat_input_bar.dart:14</code> | — | <code>catch.chat_composer</code> | Canonical chat composer. |
| <code>ChatMessageList</code> | <code>lib/chats/presentation/widgets/chat_message_list.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>ChatShareCard</code> | <code>lib/chats/presentation/widgets/chat_share_card.dart:49</code> | — | — | No class documentation or registry summary. |
| <code>ShareCardBubble</code> | <code>lib/chats/presentation/widgets/chat_share_card.dart:170</code> | — | — | No class documentation or registry summary. |
| <code>ShareCardHeader</code> | <code>lib/chats/presentation/widgets/chat_share_card.dart:114</code> | — | — | No class documentation or registry summary. |
| <code>EventChatEntrySection</code> | <code>lib/chats/presentation/widgets/event_chat_entry_section.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>EventChatMessageTile</code> | <code>lib/chats/presentation/widgets/event_chat_message_tile.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventChatReactionSection</code> | <code>lib/chats/presentation/widgets/event_chat_message_tile.dart:199</code> | — | — | No class documentation or registry summary. |
| <code>EventProfileAnswerField</code> | <code>lib/chats/presentation/widgets/event_profile_answer_field.dart:7</code> | — | — | An entire reviewed answer, never an ellipsized summary of what will be shared. The optional toggle uses the same interaction and tokens as CatchField. |
| <code>EventProfileEditorSection</code> | <code>lib/chats/presentation/widgets/event_profile_editor_section.dart:13</code> | — | — | Explicit sharing choices for eligible core values and one claimed organizer card. |
| <code>EventProfileIdentitySection</code> | <code>lib/chats/presentation/widgets/event_profile_identity_section.dart:11</code> | — | — | Renders the protected event projection with an ephemeral in-memory photo. |
| <code>EventProfilePhotoField</code> | <code>lib/chats/presentation/widgets/event_profile_photo_field.dart:9</code> | — | — | An owned photo choice that stays disabled until its current preview decodes. |
| <code>MediaMessageBody</code> | <code>lib/chats/presentation/widgets/message_bubble.dart:104</code> | — | — | No class documentation or registry summary. |
| <code>MessageBubble</code> | <code>lib/chats/presentation/widgets/message_bubble.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>MatchTesterSheet</code> | <code>lib/chats/presentation/widgets/suvbot_action_bar.dart:419</code> | — | — | No class documentation or registry summary. |
| <code>SuvbotActionBar</code> | <code>lib/chats/presentation/widgets/suvbot_action_bar.dart:23</code> | — | — | No class documentation or registry summary. |
| <code>SuvbotResetActionRow</code> | <code>lib/chats/presentation/widgets/suvbot_action_bar.dart:333</code> | — | — | No class documentation or registry summary. |
| <code>ClubDetailReadOnlyPreviewSliver</code> | <code>lib/clubs/presentation/detail/club_detail_read_only_preview.dart:15</code> | — | — | Live, consumer-facing Club Detail composition for an owner-facing read-only preview. The selected [initialClub] renders immediately while live detail data hydrates, matching the consumer route's initial-club fallback policy. |
| <code>ClubContactSection</code> | <code>lib/clubs/presentation/detail/widgets/club_contact_section.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>ClubActivitySection</code> | <code>lib/clubs/presentation/detail/widgets/club_detail_body.dart:322</code> | — | — | No class documentation or registry summary. |
| <code>ClubDetailBody</code> | <code>lib/clubs/presentation/detail/widgets/club_detail_body.dart:31</code> | — | — | No class documentation or registry summary. |
| <code>ClubDetailSliverBody</code> | <code>lib/clubs/presentation/detail/widgets/club_detail_body.dart:78</code> | — | — | Sliver-native form of the canonical Club Detail composition. |
| <code>ClubNextRunBanner</code> | <code>lib/clubs/presentation/detail/widgets/club_detail_body.dart:269</code> | — | — | No class documentation or registry summary. |
| <code>ClubDetailDock</code> | <code>lib/clubs/presentation/detail/widgets/club_detail_dock.dart:27</code> | — | — | Design-system `ClubDock` (`components/clubs/ClubDock`): the persistent bottom bar of a club detail screen, stateful over membership role — BookingDock's club sibling. `visitor` shows the member count + an **activity-pigmented** Join CTA (the one sanctioned use of the club pigment on an action); `member` shows the count + a notifications bell + a quiet "Joined" control; `owner` shows Manage + a New-event pair; `guest` shows an ink "Sign in to join". The mono [footnote] carries the state's quiet facts. |
| <code>ClubMembershipDock</code> | <code>lib/clubs/presentation/detail/widgets/club_detail_dock.dart:305</code> | — | — | Provider-backed [ClubDetailDock] for the consumer club-detail screen. Computes the membership state and wires Join / Leave / notification mutations and the guest sign-in route. (Owner state is host-app territory and not rendered here.) |
| <code>DockBell</code> | <code>lib/clubs/presentation/detail/widgets/club_detail_dock.dart:253</code> | — | — | Member notifications bell — the active state fills with the club's activity accent (not the raw Material color scheme). |
| <code>DockCount</code> | <code>lib/clubs/presentation/detail/widgets/club_detail_dock.dart:219</code> | — | — | No class documentation or registry summary. |
| <code>ClubHeroAppBar</code> | <code>lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart:48</code> | — | — | No class documentation or registry summary. |
| <code>ClubHeroModule</code> | <code>lib/clubs/presentation/detail/widgets/club_hero_app_bar.dart:273</code> | — | — | No class documentation or registry summary. |
| <code>ClubHostRow</code> | <code>lib/clubs/presentation/detail/widgets/club_host_section.dart:82</code> | — | — | No class documentation or registry summary. |
| <code>ClubHostSection</code> | <code>lib/clubs/presentation/detail/widgets/club_host_section.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>ClubPhotoStrip</code> | <code>lib/clubs/presentation/detail/widgets/club_photo_strip.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>ClubScheduleSection</code> | <code>lib/clubs/presentation/detail/widgets/club_schedule_section.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>ClubShareArtwork</code> | <code>lib/clubs/presentation/detail/widgets/club_share_card.dart:122</code> | — | — | No class documentation or registry summary. |
| <code>ClubShareCard</code> | <code>lib/clubs/presentation/detail/widgets/club_share_card.dart:41</code> | — | — | No class documentation or registry summary. |
| <code>ClubAvatarRail</code> | <code>lib/clubs/presentation/discovery/widgets/club_avatar_rail.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>ClubDiscoverList</code> | <code>lib/clubs/presentation/discovery/widgets/club_discover_list.dart:46</code> | — | — | Compatibility wrapper — kept so the `ClubDiscoverList()` constructor call remains a valid sliver expression at existing call sites. |
| <code>AvatarChip</code> | <code>lib/clubs/presentation/discovery/widgets/club_list_tile_parts/avatar_chip.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>ClubImage</code> | <code>lib/clubs/presentation/discovery/widgets/club_list_tile_parts/club_image.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>ClubIndexRow</code> | <code>lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>MembershipTrailing</code> | <code>lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:183</code> | — | — | No class documentation or registry summary. |
| <code>MembershipTrailingController</code> | <code>lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart:103</code> | — | — | No class documentation or registry summary. |
| <code>CatchClubCover</code> | <code>lib/clubs/shared/catch_club_cover.dart:7</code> | — | <code>catch.club_cover</code> | Shared club-cover resolver for editorial cards and detail heroes. |
| <code>CatchOrganizerPoster</code> | <code>lib/clubs/shared/catch_organizer_poster.dart:17</code> | — | <code>catch.organizer_poster</code> | Canonical organizer material. |
| <code>OrganizerPosterArtwork</code> | <code>lib/clubs/shared/catch_organizer_poster.dart:247</code> | — | <code>catch.organizer_poster</code> | Deterministic no-photo organizer artwork used by poster and compact cover states. |
| <code>ClubHostIdentityLine</code> | <code>lib/clubs/shared/club_identity_atoms.dart:113</code> | — | — | No class documentation or registry summary. |
| <code>ClubHostRoleBadge</code> | <code>lib/clubs/shared/club_identity_atoms.dart:163</code> | — | — | No class documentation or registry summary. |
| <code>ClubMemberSeal</code> | <code>lib/clubs/shared/club_identity_atoms.dart:37</code> | — | — | No class documentation or registry summary. |
| <code>ClubTagWrap</code> | <code>lib/clubs/shared/club_identity_atoms.dart:89</code> | — | — | No class documentation or registry summary. |
| <code>CatchConsumerBootstrap</code> | <code>lib/consumer_bootstrap.dart:23</code> | — | — | Consumer-only process bootstrap. |
| <code>CelebrationDetailRow</code> | <code>lib/core/celebration/catch_celebration_screen.dart:533</code> | — | — | No class documentation or registry summary. |
| <code>CelebrationDetailsCard</code> | <code>lib/core/celebration/catch_celebration_screen.dart:496</code> | — | — | No class documentation or registry summary. |
| <code>CelebrationIcon</code> | <code>lib/core/celebration/catch_celebration_screen.dart:476</code> | — | — | No class documentation or registry summary. |
| <code>CelebrationNote</code> | <code>lib/core/celebration/catch_celebration_screen.dart:576</code> | — | — | No class documentation or registry summary. |
| <code>PaperCelebrationDetailRow</code> | <code>lib/core/celebration/catch_celebration_screen.dart:438</code> | — | — | No class documentation or registry summary. |
| <code>PaperCelebrationDetailsCard</code> | <code>lib/core/celebration/catch_celebration_screen.dart:407</code> | — | — | No class documentation or registry summary. |
| <code>PaperCelebrationIcon</code> | <code>lib/core/celebration/catch_celebration_screen.dart:389</code> | — | — | No class documentation or registry summary. |
| <code>PaperCelebrationScaffold</code> | <code>lib/core/celebration/catch_celebration_screen.dart:233</code> | — | — | No class documentation or registry summary. |
| <code>AppShell</code> | <code>lib/core/presentation/app_shell.dart:55</code> | — | — | No class documentation or registry summary. |
| <code>AppShellNavigationBar</code> | <code>lib/core/presentation/app_shell.dart:209</code> | — | — | No class documentation or registry summary. |
| <code>AppShellSideNavigation</code> | <code>lib/core/presentation/app_shell.dart:281</code> | — | — | Labelled vertical destination plane for medium and expanded app shells. |
| <code>GuestAuthCtaBar</code> | <code>lib/core/presentation/app_shell.dart:161</code> | — | — | No class documentation or registry summary. |
| <code>CatchAdaptiveTabScaffold</code> | <code>lib/core/presentation/catch_adaptive_tab_scaffold.dart:12</code> | — | — | Shared adaptive placement contract for consumer and host tab shells. |
| <code>HostAppShell</code> | <code>lib/core/presentation/host_app_shell.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>CatchStartupAnimationScope</code> | <code>lib/core/startup/catch_startup_animation_scope.dart:7</code> | — | — | Session-scoped startup state shared with route-owned welcome surfaces. |
| <code>CatchActivityArt</code> | <code>lib/core/widgets/catch_activity_art.dart:9</code> | — | <code>catch.activity_art</code> | Generated activity art: pigment gradient, motif glyph, and print texture. |
| <code>CatchActivityMapPin</code> | <code>lib/core/widgets/catch_activity_map_pin.dart:8</code> | — | <code>catch.activity_map_pin</code> | Activity-pigment map pin with an optional selected data flag. |
| <code>CatchEventCard</code> | <code>lib/core/widgets/catch_event_activity_cards.dart:12</code> | — | <code>catch.event_card</code> | Production event card backed by the shared activity visual schema. |
| <code>CatchEventThumbnail</code> | <code>lib/core/widgets/catch_event_thumbnail.dart:16</code> | — | <code>catch.event_card</code> | Shared image/fallback primitive for any event-card surface. |
| <code>CatchEventThumbnailActivityFallback</code> | <code>lib/core/widgets/catch_event_thumbnail.dart:90</code> | — | <code>catch.event_card</code> | Direct event-thumbnail activity fallback renderer for no-photo states. |
| <code>CatchStartupBrandStage</code> | <code>lib/core/widgets/catch_startup_loading_screen.dart:41</code> | — | — | The shared role-specific brand anchor used by Host startup and auth. |
| <code>EventActivityBackdrop</code> | <code>lib/core/widgets/event_activity_visuals.dart:181</code> | — | <code>catch.event_card</code> | Shared activity artwork backdrop used by event cards, thumbnails, and no-photo event media states. |
| <code>EventActivityStamp</code> | <code>lib/core/widgets/event_visual_atoms.dart:6</code> | — | <code>catch.event_card</code> | Circular activity glyph stamp used by event cards, agenda rows, and ticket compositions. |
| <code>OrderedPhotoAddTile</code> | <code>lib/core/widgets/ordered_photo_picker.dart:716</code> | — | — | No class documentation or registry summary. |
| <code>OrderedPhotoPicker</code> | <code>lib/core/widgets/ordered_photo_picker.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>OrderedPhotoTile</code> | <code>lib/core/widgets/ordered_photo_picker.dart:477</code> | — | — | No class documentation or registry summary. |
| <code>CrossPathsEventConsentSection</code> | <code>lib/cross_paths/presentation/cross_paths_event_consent_section.dart:8</code> | — | — | Provider-free Event Detail renderer for hidden, loading, enabled, disabled, pending, and unavailable event-consent states resolved by the route. |
| <code>CrossPathsEventContextCard</code> | <code>lib/cross_paths/presentation/cross_paths_explore_card.dart:132</code> | — | — | No class documentation or registry summary. |
| <code>CrossPathsExploreCard</code> | <code>lib/cross_paths/presentation/cross_paths_explore_card.dart:26</code> | — | — | No class documentation or registry summary. |
| <code>CrossPathsProfilePreviewSheet</code> | <code>lib/cross_paths/presentation/cross_paths_explore_card.dart:237</code> | — | — | No class documentation or registry summary. |
| <code>ActivityScreenBody</code> | <code>lib/dashboard/presentation/activity_screen.dart:181</code> | — | — | No class documentation or registry summary. |
| <code>ActivityScreenLoading</code> | <code>lib/dashboard/presentation/activity_screen.dart:169</code> | — | — | No class documentation or registry summary. |
| <code>DashboardFocusLoadingCard</code> | <code>lib/dashboard/presentation/dashboard_screen.dart:221</code> | — | — | No class documentation or registry summary. |
| <code>DashboardLoadingHeader</code> | <code>lib/dashboard/presentation/dashboard_screen.dart:190</code> | — | — | No class documentation or registry summary. |
| <code>NotificationsAction</code> | <code>lib/dashboard/presentation/dashboard_screen.dart:146</code> | — | — | No class documentation or registry summary. |
| <code>ActivitySection</code> | <code>lib/dashboard/presentation/widgets/activity_section.dart:31</code> | — | — | No class documentation or registry summary. |
| <code>ActivitySectionSkeleton</code> | <code>lib/dashboard/presentation/widgets/activity_section.dart:186</code> | — | — | No class documentation or registry summary. |
| <code>ActivitySignedOutState</code> | <code>lib/dashboard/presentation/widgets/activity_section.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>NotificationDayGroups</code> | <code>lib/dashboard/presentation/widgets/activity_section.dart:144</code> | — | — | No class documentation or registry summary. |
| <code>NotificationRow</code> | <code>lib/dashboard/presentation/widgets/activity_section.dart:259</code> | — | — | Activity notification list row with type glyph, read/unread emphasis, timestamp, optional body, divider, and tap semantics. |
| <code>NotificationRowSkeleton</code> | <code>lib/dashboard/presentation/widgets/activity_section.dart:204</code> | — | — | No class documentation or registry summary. |
| <code>ClubPostHomeCard</code> | <code>lib/dashboard/presentation/widgets/club_posts_home_section.dart:55</code> | — | — | No class documentation or registry summary. |
| <code>ClubPostsHomeSection</code> | <code>lib/dashboard/presentation/widgets/club_posts_home_section.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>DashboardEmptySliverBody</code> | <code>lib/dashboard/presentation/widgets/dashboard_empty.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>DashboardFullSliverBody</code> | <code>lib/dashboard/presentation/widgets/dashboard_full.dart:32</code> | — | — | No class documentation or registry summary. |
| <code>EmptyHeroCard</code> | <code>lib/dashboard/presentation/widgets/empty_hero_card.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EmptyHeroContent</code> | <code>lib/dashboard/presentation/widgets/empty_hero_card.dart:54</code> | — | — | No class documentation or registry summary. |
| <code>EventFocusCard</code> | <code>lib/dashboard/presentation/widgets/event_focus_rail.dart:314</code> | — | — | No class documentation or registry summary. |
| <code>EventFocusRail</code> | <code>lib/dashboard/presentation/widgets/event_focus_rail.dart:48</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalEntryStateScaffold</code> | <code>lib/event_rehearsal/presentation/host_event_rehearsal_start_screen.dart:202</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalCheckpointRequestSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_checkpoint_request_sheet.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalCheckpointSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_checkpoint_sheet.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalCheckpointVisitSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_checkpoint_visit_sheet.dart:22</code> | — | — | Reuses the live atomic visit UI with original-departure practice evidence. |
| <code>EventRehearsalChoiceTile</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_choice_tile.dart:7</code> | — | — | A destination with its explanation attached, rather than a field value squeezed into a trailing lane. All copy wraps at its natural height. |
| <code>EventRehearsalConfigInput</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_customise_sheet.dart:345</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalCustomiseSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_customise_sheet.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalDeliveryQueueSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_delivery_queue_sheet.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalDeliverySection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_delivery_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalDeliverySheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_delivery_sheet.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalDepartureHistorySheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_departure_history_sheet.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalDepartureSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_departure_sheet.dart:20</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalEntryPageBody</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_entry_page_body.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalEntryScaffold</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_entry_scaffold.dart:10</code> | — | — | The rehearsal entry view, with a single start action and optional editors. The route controller supplies source loading, persistence and navigation. |
| <code>EventRehearsalGroupsSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_groups_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalHelpQueueSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_help_queue_sheet.dart:25</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalHelpSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_help_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalHelpSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_help_sheet.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalGuestLinkSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_link_and_run.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalRunSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_link_and_run.dart:93</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalMembershipSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_membership_sheet.dart:19</code> | — | — | Synthetic adapter for the same group controls, fixed to the original run. |
| <code>EventRehearsalMovementSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_movement_section.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalPracticeRoleSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_practice_role_section.dart:13</code> | — | — | Chooses the identity used for guest/group assistance, never rehearsal control. |
| <code>EventRehearsalRuntimePreviewSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_runtime_preview_section.dart:11</code> | — | — | Practice choices carry route kinds and synthetic receipts, never sender IDs. |
| <code>EventRehearsalRuntimeSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_runtime_section.dart:15</code> | — | — | A compact simulation form; advanced timing and receipt scripts open on demand. |
| <code>EventRehearsalSettingsSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_settings_section.dart:12</code> | — | — | Uses the actual runtime's settings slot and only discloses current groups. |
| <code>EventRehearsalSettingsSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_settings_sheet.dart:21</code> | — | — | The retained owner decides which form is shown while a save is unresolved. |
| <code>EventRehearsalSetupSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_setup_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalRecapSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_simulator.dart:314</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalRosterSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_simulator.dart:260</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalSimulator</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_simulator.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalSourceSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_source_sheet.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>EventRehearsalStaffEditSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_staff_edit_section.dart:17</code> | — | — | Inline explicit-save duty editor; the controller retains uncertain saves. |
| <code>EventRehearsalStaffSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_staff_section.dart:18</code> | — | — | Optional synthetic staff configuration within the rehearsal's practice tools. |
| <code>EventRehearsalStartSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_start_sheet.dart:10</code> | — | — | Chooses the rehearsal starting point before the configurable setup screen. |
| <code>EventRehearsalSweepSection</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_sweep_section.dart:12</code> | — | — | Uses the runtime's latest roster; opening a visit deliberately fetches authority. |
| <code>EventRehearsalVisitSheet</code> | <code>lib/event_rehearsal/presentation/widgets/event_rehearsal_visit_sheet.dart:18</code> | — | — | Practice transport adapter; the run/guest pending owner cannot follow a reset. |
| <code>EventSuccessAssignmentReasonNotice</code> | <code>lib/event_success/presentation/assignments/event_success_assignment_reason_notice.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessGroupMemberField</code> | <code>lib/event_success/presentation/assignments/event_success_group_override_round_section.dart:187</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessGroupOverrideFieldLanes</code> | <code>lib/event_success/presentation/assignments/event_success_group_override_round_section.dart:91</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessGroupOverrideRoundSection</code> | <code>lib/event_success/presentation/assignments/event_success_group_override_round_section.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessGroupOverrideSheet</code> | <code>lib/event_success/presentation/assignments/event_success_group_override_sheet.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostPodSection</code> | <code>lib/event_success/presentation/assignments/event_success_host_pod_section.dart:17</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostRotationSection</code> | <code>lib/event_success/presentation/assignments/event_success_host_rotation_section.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessPodSummaryRow</code> | <code>lib/event_success/presentation/assignments/event_success_pod_summary_row.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRotationOverrideRoundSection</code> | <code>lib/event_success/presentation/assignments/event_success_rotation_override_round_section.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRotationPairFieldLanes</code> | <code>lib/event_success/presentation/assignments/event_success_rotation_override_round_section.dart:84</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRotationOverrideSheet</code> | <code>lib/event_success/presentation/assignments/event_success_rotation_override_sheet.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCompanionLoadingPageBody</code> | <code>lib/event_success/presentation/companion/event_success_companion_loading_page_body.dart:6</code> | — | — | The companion stage and its actions depend on the resolved plan. Keep the route's real header while that structure is unknown. |
| <code>AfterglowBeatGrid</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart:166</code> | — | — | Beats land in sequence, 1.4s apart, each sliding up from below with a fade. Counter values animate from 0 to their final number over 600ms once the row has finished entering. Gives the afterglow recap a Spotify-Wrapped style paced reveal instead of dumping all three rows at once. |
| <code>AfterglowBeatRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart:197</code> | — | — | No class documentation or registry summary. |
| <code>PrivateAfterglowRecapCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_afterglow.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>FirstHelloCheckInCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>CompanionActionsEmptyState</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_arrival_section.dart:149</code> | — | — | No class documentation or registry summary. |
| <code>CompanionArrivalProgressIndicator</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_arrival_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CompanionArrivalSection</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_arrival_section.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>CompanionOthersInRoomText</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_arrival_section.dart:139</code> | — | — | Compact co-presence indicator. Tells the attendee they're not in here alone, with a brief alpha-pulse the moment the count climbs. Used on solo-feeling surfaces (questionnaire, eventually First Hello / wingman). |
| <code>EventCheckInQrScannerSheet</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_check_in_qr_scanner_sheet.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CounterRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart:244</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessFeedbackForm</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>RatingRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_feedback.dart:203</code> | — | — | No class documentation or registry summary. |
| <code>GroupRotationSlotRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_group_rotation_slot_row.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>IncludeMeToggle</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:406</code> | — | — | No class documentation or registry summary. |
| <code>LiveStepContextCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:247</code> | — | — | No class documentation or registry summary. |
| <code>MicroPodCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:32</code> | — | — | No class documentation or registry summary. |
| <code>PreCheckInPlanningCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:294</code> | — | — | Informational preview of what the host will guide the attendee through once check-in opens. Opt-out controls live on the at-event cards instead. |
| <code>PreviewLine</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:383</code> | — | — | No class documentation or registry summary. |
| <code>RotationScheduleCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:145</code> | — | — | No class documentation or registry summary. |
| <code>SelfCheckInCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:450</code> | — | — | No class documentation or registry summary. |
| <code>StageConversationCueCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:581</code> | — | — | No class documentation or registry summary. |
| <code>StageCueLine</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:623</code> | — | — | No class documentation or registry summary. |
| <code>StagePromptCard</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:555</code> | — | — | No class documentation or registry summary. |
| <code>StageSectionLabel</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart:700</code> | — | — | No class documentation or registry summary. |
| <code>CompanionBouncyChip</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_motion_viewport.dart:91</code> | — | — | No class documentation or registry summary. |
| <code>CompanionBouncySurface</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_motion_viewport.dart:65</code> | — | — | Gives the wrapped widget a kinetic press response: scale down on tap-down, brief glow flare, then a spring-back to rest. Drop-in replacement for InkWell-style affordances on the stage where Material's ink ripple feels out of place against the gradient + motif backdrop. |
| <code>CompanionStageMotifImage</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_motion_viewport.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CompanionStageTransitionViewport</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_motion_viewport.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>CompanionExpectationRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:476</code> | — | — | No class documentation or registry summary. |
| <code>CompanionExpectationSection</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:425</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperNavigationRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:75</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperProgressIndicator</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:135</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperScaffold</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperTicket</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:169</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperTicketDivider</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:374</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperTicketHeader</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:271</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperTicketImage</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:409</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperTicketRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:340</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPaperTicketText</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:389</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPrivacySection</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:501</code> | — | — | No class documentation or registry summary. |
| <code>CompanionSelfCheckInSection</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_paper_section.dart:535</code> | — | — | No class documentation or registry summary. |
| <code>PeopleTokenRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_people_token_row.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CompatibilityQuestionnaireSection</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>QuestionProgressRail</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_questionnaire.dart:252</code> | — | — | No class documentation or registry summary. |
| <code>RevealCinematicOverlay</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_reveal_cinematic.dart:8</code> | — | — | Server-clocked reveal cinematic composed from the same portable assets and deterministic geometry used by the guest-web runtime. |
| <code>RotationSlotRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_rotation_slot_row.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CompanionHeroSection</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:281</code> | — | — | No class documentation or registry summary. |
| <code>CompanionMomentPageBody</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:416</code> | — | — | No class documentation or registry summary. |
| <code>CompanionMomentViewport</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:93</code> | — | — | No class documentation or registry summary. |
| <code>CompanionPrivacyText</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:370</code> | — | — | No class documentation or registry summary. |
| <code>CompanionStageActionSection</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:448</code> | — | — | No class documentation or registry summary. |
| <code>CompanionStageBanner</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:467</code> | — | — | No class documentation or registry summary. |
| <code>CompanionStageImage</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:360</code> | — | — | Animates a one-shot entry on first build, then breathes the glyph continuously so the hero element never reads as static between moments. |
| <code>CompanionStageNavigationRow</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:223</code> | — | — | No class documentation or registry summary. |
| <code>CompanionStageScaffold</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CompanionStageSurface</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_stage_viewport.dart:439</code> | — | — | Ambient stage card. The border alpha breathes on a 6s sine so the surface never reads as static — even when no content is changing. |
| <code>WingmanRequestSection</code> | <code>lib/event_success/presentation/companion_parts/event_success_companion_wingman.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceCheckpointRequestSection</code> | <code>lib/event_success/presentation/event_assistance_checkpoint_request_section.dart:13</code> | — | — | Closing a request resolves the obligation, without inventing arrival evidence. |
| <code>EventAssistanceCheckpointRequestSheet</code> | <code>lib/event_success/presentation/event_assistance_checkpoint_request_sheet.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceCheckpointGuestRow</code> | <code>lib/event_success/presentation/event_assistance_checkpoint_roster_section.dart:135</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceCheckpointRosterSection</code> | <code>lib/event_success/presentation/event_assistance_checkpoint_roster_section.dart:10</code> | — | — | The immutable departure remains the denominator, including missing records. |
| <code>EventAssistanceCheckpointSection</code> | <code>lib/event_success/presentation/event_assistance_checkpoint_section.dart:47</code> | — | — | One observation form for live and simulated checkpoint reporting. |
| <code>EventAssistanceCheckpointSheet</code> | <code>lib/event_success/presentation/event_assistance_checkpoint_sheet.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceCheckpointVisitsSection</code> | <code>lib/event_success/presentation/event_assistance_checkpoint_visits_section.dart:12</code> | — | — | Original departure members without an arrival observation, including resolved visits. A visit outcome never removes a person from this denominator. |
| <code>EventAssistanceDeliveryDecisionSection</code> | <code>lib/event_success/presentation/event_assistance_delivery_decision_section.dart:18</code> | — | — | Evidence, scheduled work and manual ownership remain independent facts. |
| <code>EventAssistanceDeliveryEntrySection</code> | <code>lib/event_success/presentation/event_assistance_delivery_entry_section.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceDeliveryQueueSection</code> | <code>lib/event_success/presentation/event_assistance_delivery_queue_section.dart:8</code> | — | — | A bounded list of message evidence, shared by live and practice adapters. |
| <code>EventAssistanceDeliveryQueueSheet</code> | <code>lib/event_success/presentation/event_assistance_delivery_queue_sheet.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceDeliverySheet</code> | <code>lib/event_success/presentation/event_assistance_delivery_sheet.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceDepartureHistorySection</code> | <code>lib/event_success/presentation/event_assistance_departure_history_section.dart:16</code> | — | — | Saved records use readable record rows, with disclosure only for report detail. |
| <code>EventAssistanceDepartureHistorySheet</code> | <code>lib/event_success/presentation/event_assistance_departure_history_sheet.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceDepartureRosterSection</code> | <code>lib/event_success/presentation/event_assistance_departure_roster_section.dart:10</code> | — | — | Searchable, bounded observation choices. Nothing is selected by attendance. |
| <code>EventAssistanceDepartureSection</code> | <code>lib/event_success/presentation/event_assistance_departure_section.dart:26</code> | — | — | One departure form shared by real and synthetic transports. |
| <code>EventAssistanceDepartureSheet</code> | <code>lib/event_success/presentation/event_assistance_departure_sheet.dart:20</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceGroupRosterSection</code> | <code>lib/event_success/presentation/event_assistance_group_roster_section.dart:10</code> | — | — | A compact entry to one guest's group action, shared by both runtimes. |
| <code>EventAssistanceHelpDecisionSection</code> | <code>lib/event_success/presentation/event_assistance_help_decision_section.dart:25</code> | — | — | One deliberate practical-help decision, with the same recovery in both modes. |
| <code>EventAssistanceHelpEntrySection</code> | <code>lib/event_success/presentation/event_assistance_help_entry_section.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceHelpQueueSection</code> | <code>lib/event_success/presentation/event_assistance_help_queue_section.dart:34</code> | — | — | Page controls and readable request records shared by live and practice. |
| <code>EventAssistanceHelpQueueSheet</code> | <code>lib/event_success/presentation/event_assistance_help_queue_sheet.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceHelpSheet</code> | <code>lib/event_success/presentation/event_assistance_help_sheet.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceLateJoinDestinationField</code> | <code>lib/event_success/presentation/event_assistance_late_join_destination_field.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceLateJoinRulesSection</code> | <code>lib/event_success/presentation/event_assistance_late_join_rules_section.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceLateJoinSection</code> | <code>lib/event_success/presentation/event_assistance_late_join_section.dart:24</code> | — | — | The configuration form is shared; its caller supplies live or practice authority. |
| <code>EventAssistanceLateJoinSheet</code> | <code>lib/event_success/presentation/event_assistance_late_join_sheet.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceLiveDeliverySection</code> | <code>lib/event_success/presentation/event_assistance_live_delivery_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceLiveGroupsSection</code> | <code>lib/event_success/presentation/event_assistance_live_groups_section.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceLiveHelpSection</code> | <code>lib/event_success/presentation/event_assistance_live_help_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceLiveMovementSection</code> | <code>lib/event_success/presentation/event_assistance_live_movement_section.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>EventAssistanceLiveSettingsSection</code> | <code>lib/event_success/presentation/event_assistance_live_settings_section.dart:18</code> | — | — | A compact event default with group overrides disclosed only on request. |
| <code>EventAssistanceLiveSweepSection</code> | <code>lib/event_success/presentation/event_assistance_live_sweep_section.dart:14</code> | — | — | Connects the shared sweep roster to live visit reviews. |
| <code>EventAssistanceMembershipSection</code> | <code>lib/event_success/presentation/event_assistance_membership_section.dart:25</code> | — | — | Shared live/practice controls. A proposal never displays as accepted membership. |
| <code>EventAssistanceMembershipSheet</code> | <code>lib/event_success/presentation/event_assistance_membership_sheet.dart:16</code> | — | — | Live transport adapter; the original per-guest owner survives a sheet refresh. |
| <code>EventAssistanceMovementSection</code> | <code>lib/event_success/presentation/event_assistance_movement_section.dart:9</code> | — | — | Capability-specific entry to the same group controls in both runtimes. |
| <code>EventAssistanceRuntimeChannelsSection</code> | <code>lib/event_success/presentation/event_assistance_runtime_channels_section.dart:11</code> | — | — | Explicit channel order with named, server-reviewed sender choices. |
| <code>EventAssistanceRuntimeLimitsSection</code> | <code>lib/event_success/presentation/event_assistance_runtime_limits_section.dart:11</code> | — | — | Optional timing and delivery limits preserve the rest of the configuration. |
| <code>EventAssistanceRuntimeSection</code> | <code>lib/event_success/presentation/event_assistance_runtime_section.dart:23</code> | — | — | Event-scoped configuration with progressive limits and a frozen pending decision. |
| <code>EventAssistanceRuntimeSheet</code> | <code>lib/event_success/presentation/event_assistance_runtime_sheet.dart:20</code> | — | — | The live settings boundary keeps an unresolved command across sheet closure. |
| <code>EventAssistanceSweepSection</code> | <code>lib/event_success/presentation/event_assistance_sweep_section.dart:20</code> | — | — | The same compact roster opens one guest's visit in live and practice modes. |
| <code>EventAssistanceVisitSection</code> | <code>lib/event_success/presentation/event_assistance_visit_section.dart:55</code> | — | — | An atomic observation. The caller owns review, authority and exact retries. |
| <code>EventAssistanceVisitSheet</code> | <code>lib/event_success/presentation/event_assistance_visit_sheet.dart:16</code> | — | — | Live transport adapter for the shared atomic visit controls. |
| <code>EventMessageChannelAccordion</code> | <code>lib/event_success/presentation/event_message_channel_accordion.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>EventMessagePreferenceSection</code> | <code>lib/event_success/presentation/event_message_preference_section.dart:34</code> | — | — | Read-only presentation facts. Only the channel's retained controller owns a reviewed permission and can supply the corresponding action callbacks. |
| <code>EventMessagePreferencesNavigationSection</code> | <code>lib/event_success/presentation/event_message_preferences_navigation_section.dart:8</code> | — | — | Consumer event-detail entry. No identity or preference reads until opened. |
| <code>EventMessagePreferencesSheet</code> | <code>lib/event_success/presentation/event_message_preferences_sheet.dart:17</code> | — | — | Resolves only the signed-in attendee. Opening this sheet cannot enroll a phone or choose an attendee, and refresh never carries an old identity. |
| <code>EventMessageSenderSection</code> | <code>lib/event_success/presentation/event_message_sender_section.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>EventMessageSmsSection</code> | <code>lib/event_success/presentation/event_message_sms_section.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessAttendeeSpatialRow</code> | <code>lib/event_success/presentation/event_success_attendee_spatial_row.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>BlockHeader</code> | <code>lib/event_success/presentation/event_success_block_header.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CompanionError</code> | <code>lib/event_success/presentation/event_success_companion_screen.dart:129</code> | — | — | No class documentation or registry summary. |
| <code>CompanionLoading</code> | <code>lib/event_success/presentation/event_success_companion_screen.dart:118</code> | — | — | No class documentation or registry summary. |
| <code>CompanionMessage</code> | <code>lib/event_success/presentation/event_success_companion_screen.dart:159</code> | — | — | No class documentation or registry summary. |
| <code>CompanionScaffold</code> | <code>lib/event_success/presentation/event_success_companion_screen.dart:92</code> | — | — | No class documentation or registry summary. |
| <code>ConversationCueRow</code> | <code>lib/event_success/presentation/event_success_conversation_cue_row.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessDefaultsPanel</code> | <code>lib/event_success/presentation/event_success_defaults_panel.dart:16</code> | — | — | Create-event panel that lets the host enable the live event guide and tune the saved defaults inline. The configuration UI is shared with the Host Manage Setup tab via [EventSuccessSetupBody]. |
| <code>EventSuccessAttendeeCompanionPreview</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:266</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessConversationCueCard</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:595</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostSetupFlow</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:40</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessLiveHostMode</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:157</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessMetricPill</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:750</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessPostEventReport</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:350</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessPromptCard</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:557</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRecommendationTile</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:727</code> | — | — | No class documentation or registry summary. |
| <code>IssueList</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:520</code> | — | — | No class documentation or registry summary. |
| <code>PlaybookSummaryCard</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:461</code> | — | — | No class documentation or registry summary. |
| <code>WingmanCandidateRow</code> | <code>lib/event_success/presentation/event_success_feature_blocks.dart:675</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHeroSurface</code> | <code>lib/event_success/presentation/event_success_hero_surface.dart:6</code> | — | — | Accent-to-ink diagonal gradient hero shell for event_success surfaces. |
| <code>EventSuccessHostSection</code> | <code>lib/event_success/presentation/event_success_host_screen.dart:54</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostWorkspacePageBody</code> | <code>lib/event_success/presentation/event_success_host_workspace_page_body.dart:30</code> | — | — | No class documentation or registry summary. |
| <code>LiveStepRow</code> | <code>lib/event_success/presentation/event_success_live_step_row.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>ModuleToggleRow</code> | <code>lib/event_success/presentation/event_success_module_toggle_row.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>ProgressRow</code> | <code>lib/event_success/presentation/event_success_progress_row.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CustomQuestionnaireFields</code> | <code>lib/event_success/presentation/event_success_questionnaire_config_editor.dart:157</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessQuestionnaireConfigEditor</code> | <code>lib/event_success/presentation/event_success_questionnaire_config_editor.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRoomMap</code> | <code>lib/event_success/presentation/event_success_room_map.dart:37</code> | — | — | Shared normalized room map used by Host and attendee runtimes. |
| <code>EventSuccessRoomSetupSection</code> | <code>lib/event_success/presentation/event_success_room_setup_section.dart:16</code> | — | — | Shared room-layout setup used by Create Event and post-creation Host Setup. |
| <code>EventSuccessModuleRows</code> | <code>lib/event_success/presentation/event_success_setup_body.dart:326</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessSetupBody</code> | <code>lib/event_success/presentation/event_success_setup_body.dart:23</code> | — | — | Compact Event Success setup shared by create-event defaults and Host Manage. |
| <code>EventSuccessSkeletonSurface</code> | <code>lib/event_success/presentation/event_success_skeletons.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessStructureConfigEditor</code> | <code>lib/event_success/presentation/event_success_structure_config_editor.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessActivityFieldLanes</code> | <code>lib/event_success/presentation/host_components/event_success_activity_field_lanes.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCompatibilitySection</code> | <code>lib/event_success/presentation/host_components/event_success_compatibility_section.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostHelpSection</code> | <code>lib/event_success/presentation/host_components/event_success_host_help_section.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostResourceErrorState</code> | <code>lib/event_success/presentation/host_components/event_success_host_resource_error_state.dart:26</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostSectionLoadingPageBody</code> | <code>lib/event_success/presentation/host_components/event_success_host_section_loading_page_body.dart:7</code> | — | — | The tabs are known before the plan resolves; their content is not. |
| <code>EventSuccessHostTabBar</code> | <code>lib/event_success/presentation/host_components/event_success_host_tab_bar.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostTabPageBody</code> | <code>lib/event_success/presentation/host_components/event_success_host_tab_page_body.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessLiveWorkspaceTabBar</code> | <code>lib/event_success/presentation/host_components/event_success_live_workspace_tab_bar.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessPlanFieldLanes</code> | <code>lib/event_success/presentation/host_components/event_success_plan_field_lanes.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessAccountabilitySection</code> | <code>lib/event_success/presentation/host_live/event_success_accountability_section.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessControlRoomPageBody</code> | <code>lib/event_success/presentation/host_live/event_success_control_room_page_body.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessControlRoomStageSection</code> | <code>lib/event_success/presentation/host_live/event_success_control_room_stage_section.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessControlRoomSyncBadge</code> | <code>lib/event_success/presentation/host_live/event_success_control_room_sync_badge.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessExclusionAlertBanner</code> | <code>lib/event_success/presentation/host_live/event_success_exclusion_alert_banner.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostLivePageBody</code> | <code>lib/event_success/presentation/host_live/event_success_host_live_page_body.dart:47</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessPresenceSection</code> | <code>lib/event_success/presentation/host_live/event_success_presence_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRoomSummarySection</code> | <code>lib/event_success/presentation/host_live/event_success_room_summary_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessStepActionRow</code> | <code>lib/event_success/presentation/host_live/event_success_step_action_row.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessFunnelSection</code> | <code>lib/event_success/presentation/host_report/event_success_funnel_section.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostReportPageBody</code> | <code>lib/event_success/presentation/host_report/event_success_host_report_page_body.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessReportEmptyState</code> | <code>lib/event_success/presentation/host_report/event_success_report_empty_state.dart:4</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessReportQualitySection</code> | <code>lib/event_success/presentation/host_report/event_success_report_quality_section.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostSetupPageBody</code> | <code>lib/event_success/presentation/host_setup/event_success_host_setup_page_body.dart:24</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessReadinessField</code> | <code>lib/event_success/presentation/host_setup/event_success_readiness_field.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessSetupNoticeBanner</code> | <code>lib/event_success/presentation/host_setup/event_success_setup_notice_banner.dart:4</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessTargetAttendeesField</code> | <code>lib/event_success/presentation/host_setup/event_success_target_attendees_field.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessAssignmentSurface</code> | <code>lib/event_success/presentation/reveal/event_success_assignment_surface.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessAttendeeRevealSurface</code> | <code>lib/event_success/presentation/reveal/event_success_attendee_reveal_surface.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCountdownIndicator</code> | <code>lib/event_success/presentation/reveal/event_success_countdown_indicator.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCountdownNotice</code> | <code>lib/event_success/presentation/reveal/event_success_countdown_notice_row_list.dart:37</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCountdownNoticeRowList</code> | <code>lib/event_success/presentation/reveal/event_success_countdown_notice_row_list.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCountdownStepper</code> | <code>lib/event_success/presentation/reveal/event_success_countdown_stepper.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCountdownSurface</code> | <code>lib/event_success/presentation/reveal/event_success_countdown_surface.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCountdownText</code> | <code>lib/event_success/presentation/reveal/event_success_countdown_text.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessGroupRotationRow</code> | <code>lib/event_success/presentation/reveal/event_success_group_rotation_row_list.dart:49</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessGroupRotationRowList</code> | <code>lib/event_success/presentation/reveal/event_success_group_rotation_row_list.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostRevealSurface</code> | <code>lib/event_success/presentation/reveal/event_success_host_reveal_surface.dart:29</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessHostRevealViewport</code> | <code>lib/event_success/presentation/reveal/event_success_host_reveal_viewport.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessOutcomeSection</code> | <code>lib/event_success/presentation/reveal/event_success_outcome_section.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessPodAssignmentSection</code> | <code>lib/event_success/presentation/reveal/event_success_pod_assignment_section.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRevealActionRow</code> | <code>lib/event_success/presentation/reveal/event_success_reveal_action_row.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRevealHeader</code> | <code>lib/event_success/presentation/reveal/event_success_reveal_header.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRevealProgressIndicator</code> | <code>lib/event_success/presentation/reveal/event_success_reveal_progress_indicator.dart:4</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRevealRoundRow</code> | <code>lib/event_success/presentation/reveal/event_success_reveal_round_row_list.dart:70</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRevealRoundRowList</code> | <code>lib/event_success/presentation/reveal/event_success_reveal_round_row_list.dart:15</code> | — | — | Design-system `RotationCard` round list, dark-adapted for the reveal stage: a config mono line over one row per round — `R{n}`, the pairings (or "Hidden until reveal" while masked), and a Done / Now / Hidden state badge. Pairings only render for rounds the host has already released. |
| <code>EventSuccessRevealRoundStepper</code> | <code>lib/event_success/presentation/reveal/event_success_reveal_round_stepper.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRevealWaitingNotice</code> | <code>lib/event_success/presentation/reveal/event_success_reveal_waiting_notice.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRotationRow</code> | <code>lib/event_success/presentation/reveal/event_success_rotation_row_list.dart:53</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessRotationRowList</code> | <code>lib/event_success/presentation/reveal/event_success_rotation_row_list.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessStandingsSection</code> | <code>lib/event_success/presentation/reveal/event_success_standings_section.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>CalendarAgendaSliverSection</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:288</code> | — | — | No class documentation or registry summary. |
| <code>CalendarDateHeader</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:428</code> | — | — | No class documentation or registry summary. |
| <code>CalendarDateHeaderSkeleton</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:483</code> | — | — | No class documentation or registry summary. |
| <code>CalendarMonthGrid</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:653</code> | — | — | No class documentation or registry summary. |
| <code>CalendarStatDivider</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:739</code> | — | — | No class documentation or registry summary. |
| <code>CalendarStatSkeleton</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:593</code> | — | — | No class documentation or registry summary. |
| <code>CalendarStatsHeaderSkeleton</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:556</code> | — | — | No class documentation or registry summary. |
| <code>CalendarWeekStrip</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:609</code> | — | — | No class documentation or registry summary. |
| <code>CalendarWeekStripSkeleton</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:495</code> | — | — | No class documentation or registry summary. |
| <code>CalendarStatsHeader</code> | <code>lib/events/presentation/calendar/calendar_stats_header.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>ChromelessMapScaffold</code> | <code>lib/events/presentation/event_location_map_screen.dart:178</code> | — | — | No class documentation or registry summary. |
| <code>EventLocationMapLoadingBody</code> | <code>lib/events/presentation/event_location_map_screen.dart:113</code> | — | — | No class documentation or registry summary. |
| <code>EventMapLoadingBody</code> | <code>lib/events/presentation/event_map_screen.dart:197</code> | — | — | No class documentation or registry summary. |
| <code>EventMapView</code> | <code>lib/events/presentation/event_map_screen.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>MapPickerSearchRow</code> | <code>lib/events/presentation/location_picker_screen.dart:380</code> | — | — | No class documentation or registry summary. |
| <code>PlaceSearchPanel</code> | <code>lib/events/presentation/location_picker_screen.dart:412</code> | — | — | No class documentation or registry summary. |
| <code>PlaceSuggestionRow</code> | <code>lib/events/presentation/location_picker_screen.dart:500</code> | — | — | No class documentation or registry summary. |
| <code>SelectedPointPanel</code> | <code>lib/events/presentation/location_picker_screen.dart:567</code> | — | — | No class documentation or registry summary. |
| <code>SavedEventsAgendaSliver</code> | <code>lib/events/presentation/saved_events_screen.dart:145</code> | — | — | No class documentation or registry summary. |
| <code>SavedEventsClubNamesErrorSliver</code> | <code>lib/events/presentation/saved_events_screen.dart:207</code> | — | — | No class documentation or registry summary. |
| <code>SavedEventsError</code> | <code>lib/events/presentation/saved_events_screen.dart:191</code> | — | — | No class documentation or registry summary. |
| <code>SavedEventsLoading</code> | <code>lib/events/presentation/saved_events_screen.dart:182</code> | — | — | No class documentation or registry summary. |
| <code>BookingConflictEventRow</code> | <code>lib/events/presentation/widgets/booking_conflict_sheet.dart:150</code> | — | — | No class documentation or registry summary. |
| <code>BookingConflictSheet</code> | <code>lib/events/presentation/widgets/booking_conflict_sheet.dart:28</code> | — | — | No class documentation or registry summary. |
| <code>EventCompanionEntry</code> | <code>lib/events/presentation/widgets/event_detail_body.dart:279</code> | — | — | Provider-free companion prompt adapter for hidden, loading, error, and available Event Success plan states. |
| <code>EventDetailBody</code> | <code>lib/events/presentation/widgets/event_detail_body.dart:25</code> | — | — | Event Detail screen-section contract that groups the event-specific hero, ticket facts, overview primitives, host/social sections, consent-safe Cross Paths control, companion prompt, and booking dock under one Catch-owned handoff boundary. |
| <code>EventDetailCalloutCard</code> | <code>lib/events/presentation/widgets/event_detail_body.dart:207</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailHostsSection</code> | <code>lib/events/presentation/widgets/event_detail_body.dart:340</code> | — | — | Compact host identity, with all affordances derived from available actions. |
| <code>GuestBookCta</code> | <code>lib/events/presentation/widgets/event_detail_body.dart:318</code> | — | — | No class documentation or registry summary. |
| <code>EventBookingDock</code> | <code>lib/events/presentation/widgets/event_detail_cta.dart:23</code> | — | — | Provider-free booking dock renderer for eligible, paid, booked, waitlist, waitlist-offer, attended, past, disabled, pending, and error states. |
| <code>EventCtaStatusLeading</code> | <code>lib/events/presentation/widgets/event_detail_cta.dart:468</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailCta</code> | <code>lib/events/presentation/widgets/event_detail_cta.dart:78</code> | — | — | No class documentation or registry summary. |
| <code>PriceLeading</code> | <code>lib/events/presentation/widgets/event_detail_cta.dart:388</code> | — | — | No class documentation or registry summary. |
| <code>WaitlistOfferLeading</code> | <code>lib/events/presentation/widgets/event_detail_cta.dart:425</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailFactList</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:347</code> | — | — | Flat Event Detail fact rows with structural stacked and inline modes. |
| <code>EventDetailGoodToKnowList</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:314</code> | — | — | Good-to-know list for requirements, expectations, booking, cancellation, and settlement rows. |
| <code>EventDetailHintList</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:77</code> | — | — | Why-you-might-click hint list derived from event format and activity context. |
| <code>EventDetailItinerary</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:127</code> | — | — | Timed event itinerary rail for route plan, meet, run, and post-event moments. |
| <code>EventDetailMapCard</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:164</code> | — | — | Event detail map preview card with exact or morning-of pin states and optional route-owned tap action. |
| <code>EventDetailMechanismList</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:286</code> | — | — | How-sign-ups-work list for open signup, approval, waitlist, and demand-pricing mechanics. |
| <code>EventDetailPhotoStrip</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:485</code> | — | — | Canonical event-detail photo proof strip with uploaded photos and activity-soft placeholders. |
| <code>EventDetailPhotoStripTile</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:536</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailTicketStubBand</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:18</code> | — | — | Flush ticket fact band for when, where, pace, and activity facts below the hero. |
| <code>HairlineList</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:652</code> | — | — | No class documentation or registry summary. |
| <code>ItineraryRow</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:685</code> | — | — | No class documentation or registry summary. |
| <code>TicketStubCell</code> | <code>lib/events/presentation/widgets/event_detail_design_primitives.dart:579</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailHeroAppBar</code> | <code>lib/events/presentation/widgets/event_detail_hero_app_bar.dart:12</code> | — | — | Event detail hero section with standard, ticket, and spotlight-dark media treatments plus route-owned top actions. |
| <code>EventDetailTicketHeroSurface</code> | <code>lib/events/presentation/widgets/event_detail_hero_app_bar.dart:237</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailTicketSurface</code> | <code>lib/events/presentation/widgets/event_detail_hero_app_bar.dart:261</code> | — | — | No class documentation or registry summary. |
| <code>EventPhotoHeroSurface</code> | <code>lib/events/presentation/widgets/event_detail_hero_app_bar.dart:191</code> | — | — | No class documentation or registry summary. |
| <code>HeroActivityBadge</code> | <code>lib/events/presentation/widgets/event_detail_hero_app_bar.dart:376</code> | — | — | No class documentation or registry summary. |
| <code>HeroTimeChip</code> | <code>lib/events/presentation/widgets/event_detail_hero_app_bar.dart:410</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailCompanionSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:365</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailHeroSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:52</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailHintSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:225</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailHostsSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:403</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailItinerarySkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:258</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailLoadingCta</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:434</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailMapSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:299</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailMechanismSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:311</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailPlanSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:205</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailSocialSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:340</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailTicketStubSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:139</code> | — | — | No class documentation or registry summary. |
| <code>TicketStubCellSkeleton</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:182</code> | — | — | No class documentation or registry summary. |
| <code>EventDescription</code> | <code>lib/events/presentation/widgets/event_detail_overview_section.dart:139</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailOverviewSection</code> | <code>lib/events/presentation/widgets/event_detail_overview_section.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailSocialSection</code> | <code>lib/events/presentation/widgets/event_detail_social_section.dart:14</code> | — | — | Who's-going and reviews section composition for guest lock, member roster, review visibility, and attended review action states. |
| <code>GuestWhoIsGoing</code> | <code>lib/events/presentation/widgets/event_detail_social_section.dart:82</code> | — | — | No class documentation or registry summary. |
| <code>EventHypeAvatarStack</code> | <code>lib/events/presentation/widgets/event_hype_avatar_stack.dart:50</code> | — | — | Event-detail attendee-hype avatar stack that composes the shared Catch person-avatar stack for hidden and revealed roster states. |
| <code>EventPhotoHeader</code> | <code>lib/events/presentation/widgets/event_photo_header.dart:10</code> | — | — | Hero visual for the event detail screen. |
| <code>EventPinsMap</code> | <code>lib/events/presentation/widgets/event_pins_map.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>EventPinsMapPlaceholder</code> | <code>lib/events/presentation/widgets/event_pins_map.dart:639</code> | — | — | No class documentation or registry summary. |
| <code>EventStatsGrid</code> | <code>lib/events/presentation/widgets/event_stats_grid.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>MapOverlayControls</code> | <code>lib/events/presentation/widgets/map_overlay_controls.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>RequirementsRow</code> | <code>lib/events/presentation/widgets/requirements_row.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>EmptyRosterMessage</code> | <code>lib/events/presentation/widgets/who_is_going.dart:185</code> | — | — | No class documentation or registry summary. |
| <code>SwipeWindowBanner</code> | <code>lib/events/presentation/widgets/who_is_going.dart:242</code> | — | — | No class documentation or registry summary. |
| <code>WhoIsGoing</code> | <code>lib/events/presentation/widgets/who_is_going.dart:34</code> | — | — | No class documentation or registry summary. |
| <code>WhoIsGoingContent</code> | <code>lib/events/presentation/widgets/who_is_going.dart:80</code> | — | — | No class documentation or registry summary. |
| <code>AgendaDayGroup</code> | <code>lib/events/shared/event_agenda_list.dart:317</code> | — | — | No class documentation or registry summary. |
| <code>EventAgendaList</code> | <code>lib/events/shared/event_agenda_list.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>EventAgendaSliverList</code> | <code>lib/events/shared/event_agenda_list.dart:76</code> | — | — | No class documentation or registry summary. |
| <code>EventAgendaSliverSkeleton</code> | <code>lib/events/shared/event_agenda_list.dart:186</code> | — | — | No class documentation or registry summary. |
| <code>EventAgendaTileSkeleton</code> | <code>lib/events/shared/event_agenda_list.dart:223</code> | — | — | No class documentation or registry summary. |
| <code>EventCheckInQrScanner</code> | <code>lib/events/shared/event_check_in_qr_scanner.dart:54</code> | — | — | No class documentation or registry summary. |
| <code>EventShareCard</code> | <code>lib/events/shared/event_share_card.dart:89</code> | — | — | No class documentation or registry summary. |
| <code>EventSharePill</code> | <code>lib/events/shared/event_share_card.dart:257</code> | — | — | No class documentation or registry summary. |
| <code>EventActionCard</code> | <code>lib/events/shared/event_tiles/event_action_card.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>EventActionCardActions</code> | <code>lib/events/shared/event_tiles/event_action_card.dart:204</code> | — | — | No class documentation or registry summary. |
| <code>EventActionCardHeader</code> | <code>lib/events/shared/event_tiles/event_action_card.dart:165</code> | — | — | No class documentation or registry summary. |
| <code>EventAgendaTile</code> | <code>lib/events/shared/event_tiles/event_agenda_tile.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventDateMarker</code> | <code>lib/events/shared/event_tiles/event_date_marker.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>MonthMarker</code> | <code>lib/events/shared/event_tiles/event_date_marker.dart:128</code> | — | — | No class documentation or registry summary. |
| <code>WeekMarker</code> | <code>lib/events/shared/event_tiles/event_date_marker.dart:55</code> | — | — | No class documentation or registry summary. |
| <code>DateRail</code> | <code>lib/events/shared/event_tiles/event_date_rail_card.dart:525</code> | — | — | No class documentation or registry summary. |
| <code>EventDateRailCard</code> | <code>lib/events/shared/event_tiles/event_date_rail_card.dart:31</code> | — | <code>catch.event_card</code> | Compact list and map DateTicket with an activity rail, organizer and event identity hierarchy, one optional context block, and a trailing price decision row. |
| <code>EventTicketStub</code> | <code>lib/events/shared/event_tiles/event_date_rail_card.dart:241</code> | — | <code>catch.event_card</code> | Canonical decision row used by date-rail and agenda ticket compositions. |
| <code>PerforationLine</code> | <code>lib/events/shared/event_tiles/event_date_rail_card.dart:484</code> | — | — | No class documentation or registry summary. |
| <code>MapPinTile</code> | <code>lib/events/shared/map_pin_tile.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>CatchCoverStory</code> | <code>lib/explore/presentation/widgets/catch_cover_story.dart:18</code> | — | <code>catch.cover_story</code> | Design-system `CoverStory` (`components/explore/CoverStory`): the dark "wow" cover that opens Explore — tonight's headline event as a magazine cover. A near-black ground, an activity-pigment radial glow, a faint diagonal scrim, a giant ghosted activity glyph, a condensed Archivo headline, and a paper CTA + mono data block. Also serves as a neutral masthead (omit [activityKind] for the brand glow, set [showGhostGlyph] false, pass [body] for a hook line). |
| <code>CoverStoryChrome</code> | <code>lib/explore/presentation/widgets/catch_cover_story.dart:165</code> | — | — | No class documentation or registry summary. |
| <code>CoverStoryContent</code> | <code>lib/explore/presentation/widgets/catch_cover_story.dart:259</code> | — | — | No class documentation or registry summary. |
| <code>CityOptionTile</code> | <code>lib/explore/presentation/widgets/explore_city_picker.dart:181</code> | — | — | No class documentation or registry summary. |
| <code>CityTrigger</code> | <code>lib/explore/presentation/widgets/explore_city_picker.dart:87</code> | — | — | No class documentation or registry summary. |
| <code>ExploreCityPicker</code> | <code>lib/explore/presentation/widgets/explore_city_picker.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>ExploreCityPickerSheet</code> | <code>lib/explore/presentation/widgets/explore_city_picker.dart:131</code> | — | — | No class documentation or registry summary. |
| <code>ExploreClearButton</code> | <code>lib/explore/presentation/widgets/explore_clear_button.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>ExploreClubTags</code> | <code>lib/explore/presentation/widgets/explore_club_cards.dart:171</code> | — | — | No class documentation or registry summary. |
| <code>ExploreFeedClubRow</code> | <code>lib/explore/presentation/widgets/explore_club_cards.dart:88</code> | — | — | No class documentation or registry summary. |
| <code>ExploreOrganizerPosterCard</code> | <code>lib/explore/presentation/widgets/explore_club_cards.dart:13</code> | — | <code>catch.organizer_poster</code> | Explore spotlight adopter that composes organizer authority, rating, host identity, and tags into the canonical poster. |
| <code>ExploreExternalEventRow</code> | <code>lib/explore/presentation/widgets/explore_event_rows.dart:58</code> | — | — | No class documentation or registry summary. |
| <code>ExploreFeedEventRow</code> | <code>lib/explore/presentation/widgets/explore_event_rows.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>ThisWeekRecommendationsSection</code> | <code>lib/explore/presentation/widgets/explore_event_rows.dart:160</code> | — | — | No class documentation or registry summary. |
| <code>ActivitySlotView</code> | <code>lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:164</code> | — | — | No class documentation or registry summary. |
| <code>ActivityTypeRow</code> | <code>lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:195</code> | — | — | No class documentation or registry summary. |
| <code>ActivityTypeRows</code> | <code>lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:98</code> | — | — | No class documentation or registry summary. |
| <code>EventTypeBrowseContent</code> | <code>lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:46</code> | — | — | No class documentation or registry summary. |
| <code>EventTypeBrowseSkeleton</code> | <code>lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:273</code> | — | — | No class documentation or registry summary. |
| <code>ExploreEventTypeBrowseGrid</code> | <code>lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>MoreActivityTypesRow</code> | <code>lib/explore/presentation/widgets/explore_event_type_browse_grid.dart:239</code> | — | — | No class documentation or registry summary. |
| <code>ExploreEventsSection</code> | <code>lib/explore/presentation/widgets/explore_events_section.dart:139</code> | — | — | Compatibility shim — earlier call sites used `const ExploreEventsSection()` as a single sliver. New call sites should prefer [buildExploreEventsSlivers] so the slivers are spread into the parent flat slivers list. |
| <code>ExploreFeedContentSliver</code> | <code>lib/explore/presentation/widgets/explore_events_section.dart:195</code> | — | — | No class documentation or registry summary. |
| <code>ExploreEventsEmptySliver</code> | <code>lib/explore/presentation/widgets/explore_events_status_slivers.dart:36</code> | — | — | No class documentation or registry summary. |
| <code>ExploreEventsLoadingSliver</code> | <code>lib/explore/presentation/widgets/explore_events_status_slivers.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>ExploreFeedSkeleton</code> | <code>lib/explore/presentation/widgets/explore_feed_skeleton.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>ExploreAppliedFilterChips</code> | <code>lib/explore/presentation/widgets/explore_filter_rail.dart:109</code> | — | — | Removable Explore filters that scroll beneath the pinned time-scope rail. |
| <code>ExploreFilterRail</code> | <code>lib/explore/presentation/widgets/explore_filter_rail.dart:16</code> | — | — | Explore's pinned primary time-scope rail. |
| <code>ExploreFilterSheet</code> | <code>lib/explore/presentation/widgets/explore_filter_rail.dart:207</code> | — | — | No class documentation or registry summary. |
| <code>ExploreBrowseHeaderContent</code> | <code>lib/explore/presentation/widgets/explore_header.dart:18</code> | — | — | Non-sliver browse header embeddable in [CatchSliverHeader.bottom] or a regular column. Uses [CatchTopBar] with built-in search support instead of a custom animated search morph. |
| <code>ExploreDiscoveryCoverHeader</code> | <code>lib/explore/presentation/widgets/explore_header.dart:77</code> | — | — | No class documentation or registry summary. |
| <code>ClubDirectorySkeletonCard</code> | <code>lib/explore/presentation/widgets/explore_list.dart:205</code> | — | — | No class documentation or registry summary. |
| <code>ClubDirectorySkeletonList</code> | <code>lib/explore/presentation/widgets/explore_list.dart:188</code> | — | — | No class documentation or registry summary. |
| <code>ExploreList</code> | <code>lib/explore/presentation/widgets/explore_list.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>ExploreListEmptyState</code> | <code>lib/explore/presentation/widgets/explore_list.dart:91</code> | — | — | No class documentation or registry summary. |
| <code>ExploreScreenEmptyState</code> | <code>lib/explore/presentation/widgets/explore_screen_empty_state.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>RecommendCard</code> | <code>lib/explore/presentation/widgets/recommend_card.dart:19</code> | — | — | Explore recommendation card. |
| <code>Recommendations</code> | <code>lib/explore/presentation/widgets/recommendations.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>UpdateRequiredContent</code> | <code>lib/force_update/presentation/update_required_screen.dart:55</code> | — | — | Provider-free full-screen update prompt rendered by [UpdateRequiredScreen]. |
| <code>HostEventEntrySheet</code> | <code>lib/hosts/events/presentation/host_event_entry_sheet.dart:23</code> | — | — | No class documentation or registry summary. |
| <code>HostEventsRouteScaffold</code> | <code>lib/hosts/events/presentation/host_events_screen.dart:97</code> | — | — | No class documentation or registry summary. |
| <code>HostEventsClubCard</code> | <code>lib/hosts/events/presentation/widgets/host_events_list.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>HostEventsClubSection</code> | <code>lib/hosts/events/presentation/widgets/host_events_list.dart:93</code> | — | — | No class documentation or registry summary. |
| <code>ClubBasicsStep</code> | <code>lib/hosts/presentation/club_management/create/widgets/club_basics_step.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>ClubDetailsStep</code> | <code>lib/hosts/presentation/club_management/create/widgets/club_details_step.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>ClubEventSuccessDefaultsStep</code> | <code>lib/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>ClubHostDefaultsStep</code> | <code>lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>ClubPolicyDefaultsCard</code> | <code>lib/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart:77</code> | — | — | No class documentation or registry summary. |
| <code>CreateClubContactFields</code> | <code>lib/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>ClubProfileImageTile</code> | <code>lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart:191</code> | — | — | No class documentation or registry summary. |
| <code>CreateClubPhotosPicker</code> | <code>lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>CreateClubProfileImagePicker</code> | <code>lib/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart:103</code> | — | — | No class documentation or registry summary. |
| <code>CreateClubStepHeader</code> | <code>lib/hosts/presentation/club_management/create/widgets/create_club_step_header.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>HostContactMergeCandidateCard</code> | <code>lib/hosts/presentation/customers/host_contact_merge_review.dart:156</code> | — | — | No class documentation or registry summary. |
| <code>HostContactMergeReviewSheet</code> | <code>lib/hosts/presentation/customers/host_contact_merge_review.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerApplicationSnapshot</code> | <code>lib/hosts/presentation/customers/host_customer_applications_panel.dart:148</code> | — | — | Displays the same grant-filtered answers as the application detail route. These remain a dated submission rather than becoming editable CRM fields. |
| <code>HostCustomerApplicationsPanel</code> | <code>lib/hosts/presentation/customers/host_customer_applications_panel.dart:17</code> | — | — | Loads organizer-scoped submissions only when the Details tab is mounted. |
| <code>HostCustomerDetailBody</code> | <code>lib/hosts/presentation/customers/host_customer_detail_body.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerDetailOverview</code> | <code>lib/hosts/presentation/customers/host_customer_detail_body.dart:176</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerAttendanceCard</code> | <code>lib/hosts/presentation/customers/host_customer_detail_cards.dart:388</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerDetailsSection</code> | <code>lib/hosts/presentation/customers/host_customer_detail_cards.dart:454</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerIdentityCard</code> | <code>lib/hosts/presentation/customers/host_customer_detail_cards.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerRecentEvents</code> | <code>lib/hosts/presentation/customers/host_customer_detail_cards.dart:528</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerRevenueBreakdown</code> | <code>lib/hosts/presentation/customers/host_customer_detail_cards.dart:659</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerRevenueCard</code> | <code>lib/hosts/presentation/customers/host_customer_detail_cards.dart:572</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerActiveMergesSection</code> | <code>lib/hosts/presentation/customers/host_customer_detail_screen.dart:724</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerDetailTabs</code> | <code>lib/hosts/presentation/customers/host_customer_detail_tabs.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerIdentityInputSection</code> | <code>lib/hosts/presentation/customers/host_customer_editor.dart:187</code> | — | — | No class documentation or registry summary. |
| <code>HostSaveAudienceSheet</code> | <code>lib/hosts/presentation/customers/host_customer_editor_sheets.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerHistoryPanel</code> | <code>lib/hosts/presentation/customers/host_customer_history_panel.dart:4</code> | — | — | Mounted only by the History tab, so operational joins cannot block Overview. |
| <code>HostCustomerMemoryPreview</code> | <code>lib/hosts/presentation/customers/host_customer_memory.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerMemorySection</code> | <code>lib/hosts/presentation/customers/host_customer_memory.dart:51</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerNoteSheet</code> | <code>lib/hosts/presentation/customers/host_customer_memory.dart:145</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerTagsSheet</code> | <code>lib/hosts/presentation/customers/host_customer_memory.dart:243</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerSourcesSection</code> | <code>lib/hosts/presentation/customers/host_customer_sources_section.dart:4</code> | — | — | Contact provenance is independent of current communication availability. |
| <code>HostCustomerSubmissionsSection</code> | <code>lib/hosts/presentation/customers/host_customer_submissions_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerHistoryFilters</code> | <code>lib/hosts/presentation/customers/host_customer_timeline.dart:310</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerReachSection</code> | <code>lib/hosts/presentation/customers/host_customer_timeline.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerTimelineSection</code> | <code>lib/hosts/presentation/customers/host_customer_timeline.dart:365</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerDirectoryControls</code> | <code>lib/hosts/presentation/customers/host_customers_directory.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerFilterSheet</code> | <code>lib/hosts/presentation/customers/host_customers_directory.dart:194</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerFilterSummary</code> | <code>lib/hosts/presentation/customers/host_customers_directory.dart:89</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomersDirectory</code> | <code>lib/hosts/presentation/customers/host_customers_directory.dart:345</code> | — | — | Sliver-native directory. The page owns scrolling; the section builds only visible people and preserves each contact's identity across filter changes. |
| <code>HostCustomersNoOrganizer</code> | <code>lib/hosts/presentation/customers/host_customers_directory.dart:57</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomersSummary</code> | <code>lib/hosts/presentation/customers/host_customers_directory.dart:459</code> | — | — | No class documentation or registry summary. |
| <code>HostSavedAudienceOverview</code> | <code>lib/hosts/presentation/customers/host_saved_audience_overview.dart:33</code> | — | — | No class documentation or registry summary. |
| <code>HostSavedAudienceWorkspace</code> | <code>lib/hosts/presentation/customers/host_saved_audience_overview.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostAudienceSourceRuleFields</code> | <code>lib/hosts/presentation/customers/host_saved_audience_source_rules.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>HostSavedAudiencesDirectory</code> | <code>lib/hosts/presentation/customers/host_saved_audiences_workspace.dart:37</code> | — | — | No class documentation or registry summary. |
| <code>HostSavedAudiencesWorkspace</code> | <code>lib/hosts/presentation/customers/host_saved_audiences_workspace.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>HostStaticAudienceMembersEditor</code> | <code>lib/hosts/presentation/customers/host_static_audience_members_editor.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>EditHostedEventScopeNotice</code> | <code>lib/hosts/presentation/edit_hosted_event_scope_notice.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventUnsavedChangesDialog</code> | <code>lib/hosts/presentation/event_management/create/create_event_screen.dart:65</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventLoadingBody</code> | <code>lib/hosts/presentation/event_management/host_create_event_route_loading_screen.dart:39</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventLoadingFooter</code> | <code>lib/hosts/presentation/event_management/host_create_event_route_loading_screen.dart:92</code> | — | — | No class documentation or registry summary. |
| <code>LoadingChipRow</code> | <code>lib/hosts/presentation/event_management/host_create_event_route_loading_screen.dart:70</code> | — | — | No class documentation or registry summary. |
| <code>HostCreateEventRouteStateView</code> | <code>lib/hosts/presentation/event_management/host_create_event_screen.dart:125</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventAdaptiveWorkspace</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_adaptive_workspace.dart:14</code> | — | — | Route-owned adaptive composition for Create Event. |
| <code>CreateEventConsequencePane</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_adaptive_workspace.dart:233</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventFormLane</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_adaptive_workspace.dart:156</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventSplitWorkspace</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_adaptive_workspace.dart:95</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventStepRail</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_adaptive_workspace.dart:178</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventWorkspaceFrame</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_adaptive_workspace.dart:72</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventGuestsSection</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_guests_section.dart:10</code> | — | — | Guest source and runtime access; ticketing rules belong to EventPolicyStep. |
| <code>CreateEventPhotoPicker</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_photo_picker.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventStepHeader</code> | <code>lib/hosts/presentation/event_management/widgets/create_event_step_header.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>DraftCard</code> | <code>lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart:199</code> | — | — | No class documentation or registry summary. |
| <code>DraftDeleteConfirmationDialog</code> | <code>lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart:60</code> | — | — | No class documentation or registry summary. |
| <code>DraftPickerSheet</code> | <code>lib/hosts/presentation/event_management/widgets/draft_picker_sheet.dart:87</code> | — | — | No class documentation or registry summary. |
| <code>EventAgeRangeField</code> | <code>lib/hosts/presentation/event_management/widgets/event_age_range_field.dart:14</code> | — | — | Canonical Host event age selector. |
| <code>EventDetailsStep</code> | <code>lib/hosts/presentation/event_management/widgets/event_details_step.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>EventItineraryEditor</code> | <code>lib/hosts/presentation/event_management/widgets/event_itinerary_editor.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>EventPolicyStep</code> | <code>lib/hosts/presentation/event_management/widgets/event_policy_step.dart:28</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessStep</code> | <code>lib/hosts/presentation/event_management/widgets/event_success_step.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>RouteEventPlanEditor</code> | <code>lib/hosts/presentation/event_management/widgets/route_event_plan_editor.dart:19</code> | — | — | Composes route operations independently from the event's broader format. |
| <code>WhenStep</code> | <code>lib/hosts/presentation/event_management/widgets/when_step.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>HostSavedPlacesSection</code> | <code>lib/hosts/presentation/event_management/widgets/where_step.dart:210</code> | — | — | No class documentation or registry summary. |
| <code>WhereStep</code> | <code>lib/hosts/presentation/event_management/widgets/where_step.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>HostAutomationRuleEditor</code> | <code>lib/hosts/presentation/forms/host_automation_rule_editor.dart:4</code> | — | — | Explicit approval of a versioned rule; no customer actions run in the editor. |
| <code>HostFormAvailabilityField</code> | <code>lib/hosts/presentation/forms/host_form_availability_field.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>HostFormEditorNotice</code> | <code>lib/hosts/presentation/forms/host_form_editor_notice.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>HostFormEditorViewport</code> | <code>lib/hosts/presentation/forms/host_form_editor_viewport.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>HostFormInspectorSection</code> | <code>lib/hosts/presentation/forms/host_form_editor_viewport.dart:241</code> | — | — | No class documentation or registry summary. |
| <code>HostFormOutlineMenu</code> | <code>lib/hosts/presentation/forms/host_form_editor_viewport.dart:176</code> | — | — | No class documentation or registry summary. |
| <code>HostFormSectionField</code> | <code>lib/hosts/presentation/forms/host_form_editor_viewport.dart:97</code> | — | — | No class documentation or registry summary. |
| <code>HostFormMetrics</code> | <code>lib/hosts/presentation/forms/host_form_metrics.dart:5</code> | — | — | Form-workspace statistics composed from the canonical unboxed stat primitive. |
| <code>HostFormNumberField</code> | <code>lib/hosts/presentation/forms/host_form_number_field.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>HostFormOverviewSectionList</code> | <code>lib/hosts/presentation/forms/host_form_overview_section_list.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>HostFormPaymentDetailSheet</code> | <code>lib/hosts/presentation/forms/host_form_payment_detail_sheet.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>HostFormPaymentSection</code> | <code>lib/hosts/presentation/forms/host_form_payment_section.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>HostFormPaymentSetupSection</code> | <code>lib/hosts/presentation/forms/host_form_payment_section.dart:48</code> | — | — | No class documentation or registry summary. |
| <code>HostFormPaymentSheet</code> | <code>lib/hosts/presentation/forms/host_form_payment_sheet.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>HostFormPaymentsSectionList</code> | <code>lib/hosts/presentation/forms/host_form_payments_section_list.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>HostFormQuestionSection</code> | <code>lib/hosts/presentation/forms/host_form_question_section.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>HostFormPublishText</code> | <code>lib/hosts/presentation/forms/host_form_questions_page_body.dart:173</code> | — | — | No class documentation or registry summary. |
| <code>HostFormQuestionRowList</code> | <code>lib/hosts/presentation/forms/host_form_questions_page_body.dart:298</code> | — | — | No class documentation or registry summary. |
| <code>HostFormQuestionSectionList</code> | <code>lib/hosts/presentation/forms/host_form_questions_page_body.dart:78</code> | — | — | No class documentation or registry summary. |
| <code>HostFormQuestionsPageBody</code> | <code>lib/hosts/presentation/forms/host_form_questions_page_body.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>HostFormSectionAccordion</code> | <code>lib/hosts/presentation/forms/host_form_questions_page_body.dart:204</code> | — | — | No class documentation or registry summary. |
| <code>HostFormSettingsMenu</code> | <code>lib/hosts/presentation/forms/host_form_questions_page_body.dart:135</code> | — | — | No class documentation or registry summary. |
| <code>HostFormRenderer</code> | <code>lib/hosts/presentation/forms/host_form_renderer.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>HostFormResponsesPanel</code> | <code>lib/hosts/presentation/forms/host_form_responses_panel.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>HostFormSettingsSectionList</code> | <code>lib/hosts/presentation/forms/host_form_settings_section_list.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>HostFormValidationFieldLanes</code> | <code>lib/hosts/presentation/forms/host_form_validation_field_lanes.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>HostFormValidationTextField</code> | <code>lib/hosts/presentation/forms/host_form_validation_text_field.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>HostFormWorkspaceHeader</code> | <code>lib/hosts/presentation/forms/host_form_workspace_header.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>HostFormsNoOrganizer</code> | <code>lib/hosts/presentation/forms/host_forms_screen.dart:751</code> | — | — | No class documentation or registry summary. |
| <code>HostResponseAnswerRow</code> | <code>lib/hosts/presentation/forms/host_response_answer_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostResponseMetadataSection</code> | <code>lib/hosts/presentation/forms/host_response_answer_section.dart:35</code> | — | — | No class documentation or registry summary. |
| <code>HostResponseContactSection</code> | <code>lib/hosts/presentation/forms/host_response_detail_section.dart:382</code> | — | — | No class documentation or registry summary. |
| <code>HostResponseDetailSection</code> | <code>lib/hosts/presentation/forms/host_response_detail_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostResponsePrimaryAction</code> | <code>lib/hosts/presentation/forms/host_response_detail_section.dart:464</code> | — | — | No class documentation or registry summary. |
| <code>HostResponseStartReviewAction</code> | <code>lib/hosts/presentation/forms/host_response_detail_section.dart:344</code> | — | — | No class documentation or registry summary. |
| <code>HostAudienceHeader</code> | <code>lib/hosts/presentation/host_audience_header.dart:6</code> | — | — | Shared Audience header; the canonical root scaffold owns each tab's body. |
| <code>HostAudienceStateScaffold</code> | <code>lib/hosts/presentation/host_audience_view.dart:23</code> | — | — | Canonical Audience destination owner for route-level loading, auth, error, and no-organizer states. |
| <code>HostAudienceTabRail</code> | <code>lib/hosts/presentation/host_audience_view.dart:65</code> | — | — | No class documentation or registry summary. |
| <code>HostAnalyticsDualBar</code> | <code>lib/hosts/presentation/host_operations/host_analytics.dart:587</code> | — | — | No class documentation or registry summary. |
| <code>HostAnalyticsEventList</code> | <code>lib/hosts/presentation/host_operations/host_analytics.dart:692</code> | — | — | No class documentation or registry summary. |
| <code>HostAnalyticsReportView</code> | <code>lib/hosts/presentation/host_operations/host_analytics.dart:267</code> | — | — | No class documentation or registry summary. |
| <code>HostAnalyticsReviewsPanel</code> | <code>lib/hosts/presentation/host_operations/host_analytics.dart:762</code> | — | — | No class documentation or registry summary. |
| <code>HostAnalyticsTrendPanel</code> | <code>lib/hosts/presentation/host_operations/host_analytics.dart:464</code> | — | — | No class documentation or registry summary. |
| <code>HostClubInsightsPane</code> | <code>lib/hosts/presentation/host_operations/host_analytics.dart:17</code> | — | — | No class documentation or registry summary. |
| <code>HostAnalyticsPeriodInput</code> | <code>lib/hosts/presentation/host_operations/host_analytics_period_input.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostWhatsappSetupPane</code> | <code>lib/hosts/presentation/host_operations/host_audience.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostClubEditTab</code> | <code>lib/hosts/presentation/host_operations/host_club_edit_tab.dart:25</code> | — | — | No class documentation or registry summary. |
| <code>HostClubMediaSummary</code> | <code>lib/hosts/presentation/host_operations/host_club_edit_tab.dart:899</code> | — | — | No class documentation or registry summary. |
| <code>HostClubDefaultsEditor</code> | <code>lib/hosts/presentation/host_operations/host_club_spoke_screens.dart:201</code> | — | — | No class documentation or registry summary. |
| <code>HostClubReadOnlyEventDefaults</code> | <code>lib/hosts/presentation/host_operations/host_club_spoke_screens.dart:287</code> | — | — | No class documentation or registry summary. |
| <code>HostClubSpokeResolver</code> | <code>lib/hosts/presentation/host_operations/host_club_spoke_screens.dart:48</code> | — | — | No class documentation or registry summary. |
| <code>HostClubSpokeScaffold</code> | <code>lib/hosts/presentation/host_operations/host_club_spoke_screens.dart:170</code> | — | — | No class documentation or registry summary. |
| <code>HostTeamProfessionalProfilePreview</code> | <code>lib/hosts/presentation/host_operations/host_club_team_screen.dart:338</code> | — | — | Read-only projection of the professional identity edited in Host team. This intentionally consumes [HostTeamProfileState] rather than the dating profile collection: a host can have a valid organizer identity without a discoverable consumer profile. |
| <code>HostTeamProfileRows</code> | <code>lib/hosts/presentation/host_operations/host_club_team_screen.dart:528</code> | — | — | No class documentation or registry summary. |
| <code>HostTeamProfileSection</code> | <code>lib/hosts/presentation/host_operations/host_club_team_screen.dart:455</code> | — | — | No class documentation or registry summary. |
| <code>HostClubsScaffold</code> | <code>lib/hosts/presentation/host_operations/host_clubs_scaffold.dart:64</code> | — | — | No class documentation or registry summary. |
| <code>HostOrganizerStateScaffold</code> | <code>lib/hosts/presentation/host_operations/host_clubs_scaffold.dart:24</code> | — | — | Organizer route-state adapter that preserves the loaded workspace chrome. |
| <code>HostClubOrganizerOverview</code> | <code>lib/hosts/presentation/host_operations/host_organizer.dart:182</code> | — | — | No class documentation or registry summary. |
| <code>HostClubOrganizerOverviewController</code> | <code>lib/hosts/presentation/host_operations/host_organizer.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostOrganizerMetricGrid</code> | <code>lib/hosts/presentation/host_operations/host_organizer.dart:208</code> | — | — | No class documentation or registry summary. |
| <code>HostOrganizerMetricRow</code> | <code>lib/hosts/presentation/host_operations/host_organizer.dart:258</code> | — | — | No class documentation or registry summary. |
| <code>HostTeamHostedClubsSection</code> | <code>lib/hosts/presentation/host_operations/host_team_hosted_clubs_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostedEventPolicySection</code> | <code>lib/hosts/presentation/hosted_event_policy_section.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>HostedEventScheduleSection</code> | <code>lib/hosts/presentation/hosted_event_schedule_section.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>HostBroadcastComposerSheet</code> | <code>lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart:57</code> | — | — | No class documentation or registry summary. |
| <code>HostCampaignComposer</code> | <code>lib/hosts/presentation/inbox/host_campaign_composer.dart:46</code> | — | — | No class documentation or registry summary. |
| <code>HostCampaignReport</code> | <code>lib/hosts/presentation/inbox/host_campaign_composer.dart:589</code> | — | — | No class documentation or registry summary. |
| <code>HostEventAnnouncementField</code> | <code>lib/hosts/presentation/inbox/host_event_announcement_field.dart:26</code> | — | — | No class documentation or registry summary. |
| <code>HostFollowerUpdateComposerSheet</code> | <code>lib/hosts/presentation/inbox/host_follower_update_composer.dart:43</code> | — | — | No class documentation or registry summary. |
| <code>HostInboxPersonPageBody</code> | <code>lib/hosts/presentation/inbox/host_inbox_person_page_body.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>HostInboxScopeMenu</code> | <code>lib/hosts/presentation/inbox/host_inbox_scope_menu.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>HostInboxAudienceInput</code> | <code>lib/hosts/presentation/inbox/host_inbox_workspace_section.dart:256</code> | — | — | No class documentation or registry summary. |
| <code>HostInboxEmptyState</code> | <code>lib/hosts/presentation/inbox/host_inbox_workspace_section.dart:401</code> | — | — | No class documentation or registry summary. |
| <code>HostInboxPeopleSection</code> | <code>lib/hosts/presentation/inbox/host_inbox_workspace_section.dart:310</code> | — | — | No class documentation or registry summary. |
| <code>HostInboxWorkspaceSection</code> | <code>lib/hosts/presentation/inbox/host_inbox_workspace_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostMessagingWorkspaceTabBar</code> | <code>lib/hosts/presentation/inbox/host_inbox_workspace_section.dart:224</code> | — | — | No class documentation or registry summary. |
| <code>HostManualSendQueue</code> | <code>lib/hosts/presentation/inbox/host_manual_send_queue.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>HostNewMessageRouteSection</code> | <code>lib/hosts/presentation/inbox/host_new_message_screen.dart:255</code> | — | — | No class documentation or registry summary. |
| <code>HostPersonConversationMenu</code> | <code>lib/hosts/presentation/inbox/host_person_conversation_menu.dart:15</code> | — | — | Keeps the existing Catch conversation actions available in the shared pane. The parent supplies only a currently authorized source and its messages. |
| <code>HostPersonConversationPageBody</code> | <code>lib/hosts/presentation/inbox/host_person_conversation_page_body.dart:24</code> | — | — | Embedded presentation: the route/workspace owns Scaffold and keyboard insets. |
| <code>HostSendIntentMenu</code> | <code>lib/hosts/presentation/inbox/host_send_intent_menu.dart:17</code> | — | — | No class documentation or registry summary. |
| <code>HostSendsBackButton</code> | <code>lib/hosts/presentation/inbox/host_sends_back_button.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>HostSendsWorkspaceSliver</code> | <code>lib/hosts/presentation/inbox/host_sends_workspace.dart:29</code> | — | — | No class documentation or registry summary. |
| <code>HostWhatsappThreadSheet</code> | <code>lib/hosts/presentation/inbox/host_whatsapp_thread_sheet.dart:17</code> | — | — | No class documentation or registry summary. |
| <code>HostPaymentAccountCard</code> | <code>lib/hosts/presentation/payments/host_payment_account_card.dart:34</code> | — | — | No class documentation or registry summary. |
| <code>HostPaymentAccountErrorCard</code> | <code>lib/hosts/presentation/payments/host_payment_account_card.dart:676</code> | — | — | No class documentation or registry summary. |
| <code>HostPaymentAccountLoadingCard</code> | <code>lib/hosts/presentation/payments/host_payment_account_card.dart:647</code> | — | — | No class documentation or registry summary. |
| <code>HostPaymentAccountControllerCard</code> | <code>lib/hosts/presentation/payments/host_payment_account_controller_card.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>HostPaymentAccountSection</code> | <code>lib/hosts/presentation/payments/host_payment_account_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CatchRosterActionCell</code> | <code>lib/hosts/presentation/widgets/catch_roster_board.dart:287</code> | — | — | No class documentation or registry summary. |
| <code>CatchRosterDecideTarget</code> | <code>lib/hosts/presentation/widgets/catch_roster_board.dart:362</code> | — | — | No class documentation or registry summary. |
| <code>CatchRosterRow</code> | <code>lib/hosts/presentation/widgets/catch_roster_board.dart:194</code> | — | <code>catch.roster_row</code> | Design-system `RosterRow` (`components/hosting/RosterBoard`): one participant — avatar, condensed name over a mono meta line, a signal [CatchBadge], and a spec-driven [action] cell. Columns are fixed 5/3/3 to match [CatchRosterTable]. |
| <code>CatchRosterTable</code> | <code>lib/hosts/presentation/widgets/catch_roster_board.dart:397</code> | — | <code>catch.roster_table</code> | Design-system `RosterTable` (`components/hosting/RosterBoard`): the hairline table shell — three mono column headers (identity / signal / action) at fixed 5/3/3 proportions, [CatchRosterRow] children, and a built-in empty state. |
| <code>CatchRosterTileCell</code> | <code>lib/hosts/presentation/widgets/catch_roster_board.dart:68</code> | — | — | No class documentation or registry summary. |
| <code>CatchRosterTiles</code> | <code>lib/hosts/presentation/widgets/catch_roster_board.dart:35</code> | — | <code>catch.roster_tiles</code> | Design-system `RosterTiles` (`components/hosting/RosterTiles`): the selectable count-tile row that filters a roster board. Each tile is a labelled count in a functional tone; the selected tile flips to the ink fill. |
| <code>HostAnalyticsReportLoadingIndicator</code> | <code>lib/hosts/presentation/widgets/host_analytics_report_loading_indicator.dart:5</code> | — | — | Analytics recommendations, events, and quality panels depend on the report. |
| <code>HostAttendanceOutboxNotice</code> | <code>lib/hosts/presentation/widgets/host_attendance_outbox_notice.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostBookingProviderSection</code> | <code>lib/hosts/presentation/widgets/host_booking_provider_section.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>HostClubManagementPanel</code> | <code>lib/hosts/presentation/widgets/host_club_tools.dart:17</code> | — | — | No class documentation or registry summary. |
| <code>HostStatChip</code> | <code>lib/hosts/presentation/widgets/host_club_tools.dart:211</code> | — | — | No class documentation or registry summary. |
| <code>HostDraftExitDialog</code> | <code>lib/hosts/presentation/widgets/host_draft_exit_dialog.dart:26</code> | — | — | No class documentation or registry summary. |
| <code>HostEmptyActionCard</code> | <code>lib/hosts/presentation/widgets/host_empty_action_card.dart:10</code> | — | — | Compatibility adapter for cataloged host empty states. |
| <code>HostEventAttendancePanel</code> | <code>lib/hosts/presentation/widgets/host_event_attendance_panel.dart:47</code> | — | — | No class documentation or registry summary. |
| <code>HostEventParticipantsPanel</code> | <code>lib/hosts/presentation/widgets/host_event_attendance_panel.dart:73</code> | — | — | No class documentation or registry summary. |
| <code>HostEventCheckInQrSection</code> | <code>lib/hosts/presentation/widgets/host_event_check_in_qr_section.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostEventLiveLocationControl</code> | <code>lib/hosts/presentation/widgets/host_event_live_location_control.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>HostActionRow</code> | <code>lib/hosts/presentation/widgets/host_event_manage_section.dart:221</code> | — | — | No class documentation or registry summary. |
| <code>HostCapacitySection</code> | <code>lib/hosts/presentation/widgets/host_event_manage_section.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>HostEventActionsSection</code> | <code>lib/hosts/presentation/widgets/host_event_manage_section.dart:121</code> | — | — | No class documentation or registry summary. |
| <code>HostEventSummaryRow</code> | <code>lib/hosts/presentation/widgets/host_event_manage_section.dart:401</code> | — | — | No class documentation or registry summary. |
| <code>HostEventSummarySection</code> | <code>lib/hosts/presentation/widgets/host_event_manage_section.dart:347</code> | — | — | No class documentation or registry summary. |
| <code>HostFullCapacityBanner</code> | <code>lib/hosts/presentation/widgets/host_event_manage_section.dart:90</code> | — | — | No class documentation or registry summary. |
| <code>HostPublicRegistrationField</code> | <code>lib/hosts/presentation/widgets/host_event_manage_section.dart:250</code> | — | — | No class documentation or registry summary. |
| <code>HostEventParticipantsSectionList</code> | <code>lib/hosts/presentation/widgets/host_event_participants_section_list.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>HostParticipationLifecycleSection</code> | <code>lib/hosts/presentation/widgets/host_event_participants_section_list.dart:110</code> | — | — | No class documentation or registry summary. |
| <code>HostInviteLinkRow</code> | <code>lib/hosts/presentation/widgets/host_event_private_access_section.dart:368</code> | — | — | No class documentation or registry summary. |
| <code>HostInviteLinksSection</code> | <code>lib/hosts/presentation/widgets/host_event_private_access_section.dart:247</code> | — | — | No class documentation or registry summary. |
| <code>HostPrivateAccessAsyncBoundary</code> | <code>lib/hosts/presentation/widgets/host_event_private_access_section.dart:27</code> | — | — | No class documentation or registry summary. |
| <code>HostPrivateAccessSection</code> | <code>lib/hosts/presentation/widgets/host_event_private_access_section.dart:133</code> | — | — | No class documentation or registry summary. |
| <code>HostPrivateAccessSurface</code> | <code>lib/hosts/presentation/widgets/host_event_private_access_section.dart:117</code> | — | — | No class documentation or registry summary. |
| <code>HostEventReviewsPanel</code> | <code>lib/hosts/presentation/widgets/host_event_reviews_panel.dart:17</code> | — | — | Host-owned review workspace for one event. |
| <code>HostEventRosterDrawer</code> | <code>lib/hosts/presentation/widgets/host_event_roster_drawer.dart:14</code> | — | — | An overlay drawer for the event roster, with an optional edge affordance. |
| <code>HostEventRosterHandle</code> | <code>lib/hosts/presentation/widgets/host_event_roster_drawer.dart:145</code> | — | — | Counted edge control used to reveal or dismiss the host event roster. |
| <code>HostEventRosterPanel</code> | <code>lib/hosts/presentation/widgets/host_event_roster_drawer.dart:218</code> | — | — | Overlay panel chrome for roster content supplied by Host Event Manage. |
| <code>HostEventStaffSection</code> | <code>lib/hosts/presentation/widgets/host_event_staff_section.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>HostEventToolCard</code> | <code>lib/hosts/presentation/widgets/host_event_tools.dart:211</code> | — | — | No class documentation or registry summary. |
| <code>HostEventToolsCarousel</code> | <code>lib/hosts/presentation/widgets/host_event_tools.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>HostEventToolsPageIndicator</code> | <code>lib/hosts/presentation/widgets/host_event_tools.dart:159</code> | — | — | No class documentation or registry summary. |
| <code>HostInlineSkeletonIcon</code> | <code>lib/hosts/presentation/widgets/host_loading_skeletons.dart:8</code> | — | — | A leaf placeholder used where only an inline icon is unresolved. |
| <code>HostLumaConnectionSheet</code> | <code>lib/hosts/presentation/widgets/host_luma_connection_sheet.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>HostLumaEventChoiceSheet</code> | <code>lib/hosts/presentation/widgets/host_luma_connection_sheet.dart:128</code> | — | — | No class documentation or registry summary. |
| <code>HostManualAttendeeSheet</code> | <code>lib/hosts/presentation/widgets/host_manual_attendee_sheet.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostGuestIntakeDisclosure</code> | <code>lib/hosts/presentation/widgets/host_operational_roster_panel.dart:68</code> | — | — | No class documentation or registry summary. |
| <code>HostGuestIntakeField</code> | <code>lib/hosts/presentation/widgets/host_operational_roster_panel.dart:42</code> | — | — | No class documentation or registry summary. |
| <code>HostOperationalRosterPanel</code> | <code>lib/hosts/presentation/widgets/host_operational_roster_panel.dart:189</code> | — | — | No class documentation or registry summary. |
| <code>HostOrganizerAvatar</code> | <code>lib/hosts/presentation/widgets/host_organizer_switcher.dart:23</code> | — | — | No class documentation or registry summary. |
| <code>HostOrganizerSwitcherSheet</code> | <code>lib/hosts/presentation/widgets/host_organizer_switcher.dart:54</code> | — | — | No class documentation or registry summary. |
| <code>HostRosterFilterHeader</code> | <code>lib/hosts/presentation/widgets/host_roster_filter_header.dart:30</code> | — | — | No class documentation or registry summary. |
| <code>HostRosterSearchField</code> | <code>lib/hosts/presentation/widgets/host_roster_filter_header.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostWaitlistBulkOfferNotice</code> | <code>lib/hosts/presentation/widgets/host_roster_filter_header.dart:92</code> | — | — | No class documentation or registry summary. |
| <code>HostRosterHandoffSheet</code> | <code>lib/hosts/presentation/widgets/host_roster_handoff_sheet.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostRosterImportSheet</code> | <code>lib/hosts/presentation/widgets/host_roster_import_sheet.dart:25</code> | — | — | No class documentation or registry summary. |
| <code>HostRosterMappingField</code> | <code>lib/hosts/presentation/widgets/host_roster_mapping_field.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>HostTeamAddHostSheet</code> | <code>lib/hosts/presentation/widgets/host_team_management_section.dart:364</code> | — | — | No class documentation or registry summary. |
| <code>HostTeamHostActionDialog</code> | <code>lib/hosts/presentation/widgets/host_team_management_section.dart:261</code> | — | — | No class documentation or registry summary. |
| <code>HostTeamManagementSection</code> | <code>lib/hosts/presentation/widgets/host_team_management_section.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>HostTeamOwnerHostRow</code> | <code>lib/hosts/presentation/widgets/host_team_management_section.dart:276</code> | — | — | No class documentation or registry summary. |
| <code>StepperFooter</code> | <code>lib/hosts/presentation/widgets/stepper_footer.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayFocusPageBody</code> | <code>lib/hosts/today/personalization/presentation/host_today_focus_page_body.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayPersonalizationSection</code> | <code>lib/hosts/today/personalization/presentation/host_today_personalization_section.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayPersonalizedLayout</code> | <code>lib/hosts/today/personalization/presentation/host_today_personalized_layout.dart:23</code> | — | — | Owns quiet-day personalization only. The existing Today projection retains its complete loading, error, event and attention presentation unchanged. |
| <code>HostTodayOrganizerEmptyState</code> | <code>lib/hosts/today/presentation/host_today_screen.dart:392</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayBody</code> | <code>lib/hosts/today/presentation/widgets/host_today_body.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayHeader</code> | <code>lib/hosts/today/presentation/widgets/host_today_body.dart:77</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayQuietState</code> | <code>lib/hosts/today/presentation/widgets/host_today_body.dart:99</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayEventMetadataRow</code> | <code>lib/hosts/today/presentation/widgets/host_today_event_section.dart:127</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayEventMetricTile</code> | <code>lib/hosts/today/presentation/widgets/host_today_event_section.dart:157</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayEventSection</code> | <code>lib/hosts/today/presentation/widgets/host_today_event_section.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayAttentionSection</code> | <code>lib/hosts/today/presentation/widgets/host_today_overview.dart:284</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayOverview</code> | <code>lib/hosts/today/presentation/widgets/host_today_overview.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>PhotoGrid</code> | <code>lib/image_uploads/shared/photo_grid.dart:31</code> | — | — | A 3×2 grid of photo slots for displaying and editing a user's profile photos. |
| <code>PhotoSlot</code> | <code>lib/image_uploads/shared/photo_slot.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>StripedPhotoPlaceholder</code> | <code>lib/image_uploads/shared/photo_slot.dart:252</code> | — | — | No class documentation or registry summary. |
| <code>ProfilePhotoEditorPreview</code> | <code>lib/image_uploads/shared/profile_photo_editor_screen.dart:388</code> | — | — | No class documentation or registry summary. |
| <code>LaunchAccessApplicationForm</code> | <code>lib/launch_access/presentation/launch_access_application_screen.dart:171</code> | — | — | No class documentation or registry summary. |
| <code>LaunchAccessChoiceSkeleton</code> | <code>lib/launch_access/presentation/launch_access_application_screen.dart:137</code> | — | — | No class documentation or registry summary. |
| <code>LaunchAccessLoadingBody</code> | <code>lib/launch_access/presentation/launch_access_application_screen.dart:92</code> | — | — | No class documentation or registry summary. |
| <code>CatchGoogleMap</code> | <code>lib/locations/shared/catch_google_map.dart:205</code> | — | — | No class documentation or registry summary. |
| <code>CatchMapPreview</code> | <code>lib/locations/shared/catch_map_preview.dart:13</code> | — | <code>catch.map_preview</code> | A read-only, attribution-safe Google Maps viewport for compact previews. |
| <code>MatchCelebrationDialog</code> | <code>lib/matches/shared/match_celebration_dialog.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>ForegroundNotificationListener</code> | <code>lib/notifications/presentation/foreground_notification_listener.dart:12</code> | — | — | App-level presentation adapter. Delivery never reads BuildContext; the shared notice never parses FCM, authenticates a user or chooses a route. |
| <code>OnboardingStepContent</code> | <code>lib/onboarding/presentation/onboarding_screen.dart:132</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingTopBar</code> | <code>lib/onboarding/presentation/onboarding_screen.dart:165</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingGenderInterestStep</code> | <code>lib/onboarding/presentation/pages/gender_interest_page.dart:103</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingInstagramStep</code> | <code>lib/onboarding/presentation/pages/instagram_page.dart:68</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingNameDobStep</code> | <code>lib/onboarding/presentation/pages/name_dob_page.dart:129</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingPhotosStep</code> | <code>lib/onboarding/presentation/pages/photos_page.dart:90</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingProfilePromptsStep</code> | <code>lib/onboarding/presentation/pages/profile_prompts_page.dart:126</code> | — | — | No class documentation or registry summary. |
| <code>PromptField</code> | <code>lib/onboarding/presentation/pages/profile_prompts_page.dart:189</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingRunningPrefsStep</code> | <code>lib/onboarding/presentation/pages/running_prefs_page.dart:161</code> | — | — | No class documentation or registry summary. |
| <code>ReelBand</code> | <code>lib/onboarding/presentation/pages/welcome_page.dart:558</code> | — | — | No class documentation or registry summary. |
| <code>ReelRow</code> | <code>lib/onboarding/presentation/pages/welcome_page.dart:637</code> | — | — | No class documentation or registry summary. |
| <code>RevealEntrance</code> | <code>lib/onboarding/presentation/pages/welcome_page.dart:769</code> | — | — | No class documentation or registry summary. |
| <code>WelcomeFocusLockup</code> | <code>lib/onboarding/presentation/pages/welcome_page.dart:414</code> | — | — | The fixed grammatical focus slot shared by the Consumer boot handoff and the moving Welcome reel. |
| <code>WelcomeScene</code> | <code>lib/onboarding/presentation/pages/welcome_page.dart:224</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingStepLayout</code> | <code>lib/onboarding/shared/onboarding_step_layout.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>OrganizerAuthorityBadge</code> | <code>lib/organizers/presentation/organizer_authority_badge.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>PaymentCheckoutEventBackdrop</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:183</code> | — | — | No class documentation or registry summary. |
| <code>PaymentCheckoutSheet</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:246</code> | — | — | No class documentation or registry summary. |
| <code>PaymentConfirmationBody</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:480</code> | — | — | No class documentation or registry summary. |
| <code>PaymentConfirmationBodyController</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:431</code> | — | — | No class documentation or registry summary. |
| <code>PaymentConfirmationHeadsUp</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:610</code> | — | — | No class documentation or registry summary. |
| <code>PaymentPendingCheckoutBody</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:125</code> | — | — | No class documentation or registry summary. |
| <code>PaymentPendingCheckoutController</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:71</code> | — | — | No class documentation or registry summary. |
| <code>PaymentReferralBanner</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:660</code> | — | — | No class documentation or registry summary. |
| <code>PaymentReferralBannerController</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:639</code> | — | — | No class documentation or registry summary. |
| <code>PaymentHistoryList</code> | <code>lib/payments/presentation/payment_history_screen.dart:96</code> | — | — | No class documentation or registry summary. |
| <code>PaymentHistoryListController</code> | <code>lib/payments/presentation/payment_history_screen.dart:65</code> | — | — | No class documentation or registry summary. |
| <code>PaymentHistorySkeleton</code> | <code>lib/payments/presentation/payment_history_screen.dart:146</code> | — | — | No class documentation or registry summary. |
| <code>PaymentHistoryTile</code> | <code>lib/payments/presentation/payment_history_screen.dart:214</code> | — | — | No class documentation or registry summary. |
| <code>PaymentHistoryTileSkeleton</code> | <code>lib/payments/presentation/payment_history_screen.dart:168</code> | — | — | No class documentation or registry summary. |
| <code>PaymentReceiptSheet</code> | <code>lib/payments/presentation/payment_history_screen.dart:325</code> | — | — | No class documentation or registry summary. |
| <code>ProgramArrivalActionMenu</code> | <code>lib/programs/presentation/program_arrivals_screen.dart:415</code> | — | — | No class documentation or registry summary. |
| <code>ProgramArrivalReadinessBadge</code> | <code>lib/programs/presentation/program_arrivals_screen.dart:376</code> | — | — | No class documentation or registry summary. |
| <code>ProgramArrivalRow</code> | <code>lib/programs/presentation/program_arrivals_screen.dart:261</code> | — | — | No class documentation or registry summary. |
| <code>ProgramDispatchGroupTile</code> | <code>lib/programs/presentation/program_dispatch_screen.dart:240</code> | — | — | No class documentation or registry summary. |
| <code>ProgramDispatchSheet</code> | <code>lib/programs/presentation/program_dispatch_screen.dart:311</code> | — | — | Plate capture + vendor + class override. The dispatch write is queued through the operations outbox so a dead zone cannot lose a departure. |
| <code>ProgramHotelInboundTripTile</code> | <code>lib/programs/presentation/program_hotel_desk_screen.dart:243</code> | — | — | No class documentation or registry summary. |
| <code>ProgramArrivalsOutboxBanner</code> | <code>lib/programs/presentation/program_operations_notice.dart:191</code> | — | — | No class documentation or registry summary. |
| <code>ProgramJournalRecoverySheet</code> | <code>lib/programs/presentation/program_operations_notice.dart:101</code> | — | — | Exports preserved local program operations through an account-fenced share flow. |
| <code>ProgramOperationReviewSheet</code> | <code>lib/programs/presentation/program_operations_notice.dart:239</code> | — | — | No class documentation or registry summary. |
| <code>ProgramOperationsNotice</code> | <code>lib/programs/presentation/program_operations_notice.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>ProgramTripLedgerRow</code> | <code>lib/programs/presentation/program_trips_screen.dart:154</code> | — | — | No class documentation or registry summary. |
| <code>ProgramTripVoidSheet</code> | <code>lib/programs/presentation/program_trips_screen.dart:302</code> | — | — | No class documentation or registry summary. |
| <code>ProgramWorkPageBody</code> | <code>lib/programs/presentation/program_work_screen.dart:148</code> | — | — | No class documentation or registry summary. |
| <code>PublicProfileBody</code> | <code>lib/public_profile/presentation/public_profile_screen.dart:226</code> | — | — | No class documentation or registry summary. |
| <code>PublicProfileReportReasonTile</code> | <code>lib/public_profile/presentation/public_profile_screen.dart:330</code> | — | — | No class documentation or registry summary. |
| <code>PublicProfileReportSheet</code> | <code>lib/public_profile/presentation/public_profile_screen.dart:268</code> | — | — | No class documentation or registry summary. |
| <code>PublicProfileScreenBody</code> | <code>lib/public_profile/presentation/public_profile_screen.dart:186</code> | — | — | No class documentation or registry summary. |
| <code>ReviewHistoryItem</code> | <code>lib/reviews/presentation/reviews_history_screen.dart:158</code> | — | — | No class documentation or registry summary. |
| <code>ReviewHistoryItemSkeleton</code> | <code>lib/reviews/presentation/reviews_history_screen.dart:209</code> | — | — | No class documentation or registry summary. |
| <code>ReviewsHistoryBody</code> | <code>lib/reviews/presentation/reviews_history_screen.dart:91</code> | — | — | No class documentation or registry summary. |
| <code>ReviewsHistoryList</code> | <code>lib/reviews/presentation/reviews_history_screen.dart:134</code> | — | — | No class documentation or registry summary. |
| <code>ReviewsHistorySkeleton</code> | <code>lib/reviews/presentation/reviews_history_screen.dart:192</code> | — | — | No class documentation or registry summary. |
| <code>ClubReviewsSection</code> | <code>lib/reviews/shared/reviews_section.dart:21</code> | — | — | Read-only club review aggregate. |
| <code>EventReviewsSection</code> | <code>lib/reviews/shared/reviews_section.dart:48</code> | — | — | Event-scoped reviews with write/edit CTA for attended attendees. |
| <code>ReviewCard</code> | <code>lib/reviews/shared/reviews_section.dart:310</code> | — | — | No class documentation or registry summary. |
| <code>ReviewOwnerResponseBlock</code> | <code>lib/reviews/shared/reviews_section.dart:401</code> | — | — | No class documentation or registry summary. |
| <code>ReviewResponseSheet</code> | <code>lib/reviews/shared/reviews_section.dart:460</code> | — | — | No class documentation or registry summary. |
| <code>ReviewsPreviewSection</code> | <code>lib/reviews/shared/reviews_section.dart:142</code> | — | — | No class documentation or registry summary. |
| <code>StarRating</code> | <code>lib/reviews/shared/star_rating.dart:7</code> | — | — | Read-only star row. [rating] is 1-5 (integers for filled stars). |
| <code>StarRatingPicker</code> | <code>lib/reviews/shared/star_rating.dart:37</code> | — | — | Tappable star row for picking a rating. |
| <code>WriteReviewSheet</code> | <code>lib/reviews/shared/write_review_sheet.dart:36</code> | — | — | No class documentation or registry summary. |
| <code>BlockedAccountsSection</code> | <code>lib/safety/presentation/blocked_account_tile.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>MessagingPermissionsPageBody</code> | <code>lib/safety/presentation/messaging_permissions_screen.dart:45</code> | — | — | No class documentation or registry summary. |
| <code>AccountProfileStatus</code> | <code>lib/safety/presentation/settings_screen.dart:663</code> | — | — | No class documentation or registry summary. |
| <code>BlockedAccountsSkeleton</code> | <code>lib/safety/presentation/settings_screen.dart:707</code> | — | — | No class documentation or registry summary. |
| <code>EventRecapLoadingBody</code> | <code>lib/swipes/presentation/event_recap_screen.dart:277</code> | — | — | No class documentation or registry summary. |
| <code>EventRecapReadyBody</code> | <code>lib/swipes/presentation/event_recap_screen.dart:135</code> | — | — | No class documentation or registry summary. |
| <code>RecapHero</code> | <code>lib/swipes/presentation/event_recap_screen.dart:411</code> | — | — | No class documentation or registry summary. |
| <code>RecapHeroSkeleton</code> | <code>lib/swipes/presentation/event_recap_screen.dart:317</code> | — | — | No class documentation or registry summary. |
| <code>RecapProfilePhoto</code> | <code>lib/swipes/presentation/event_recap_screen.dart:602</code> | — | — | No class documentation or registry summary. |
| <code>RecapStat</code> | <code>lib/swipes/presentation/event_recap_screen.dart:474</code> | — | — | No class documentation or registry summary. |
| <code>RecapStatSkeleton</code> | <code>lib/swipes/presentation/event_recap_screen.dart:350</code> | — | — | No class documentation or registry summary. |
| <code>VibeGrid</code> | <code>lib/swipes/presentation/event_recap_screen.dart:214</code> | — | — | No class documentation or registry summary. |
| <code>VibeGridSkeleton</code> | <code>lib/swipes/presentation/event_recap_screen.dart:369</code> | — | — | No class documentation or registry summary. |
| <code>VibeTile</code> | <code>lib/swipes/presentation/event_recap_screen.dart:512</code> | — | — | No class documentation or registry summary. |
| <code>FiltersContent</code> | <code>lib/swipes/presentation/filters_screen.dart:218</code> | — | — | No class documentation or registry summary. |
| <code>FiltersSection</code> | <code>lib/swipes/presentation/filters_screen.dart:363</code> | — | — | No class documentation or registry summary. |
| <code>FiltersValue</code> | <code>lib/swipes/presentation/filters_screen.dart:390</code> | — | — | No class documentation or registry summary. |
| <code>CatchesHubContent</code> | <code>lib/swipes/presentation/swipe_hub_screen.dart:101</code> | — | — | No class documentation or registry summary. |
| <code>CatchesHubEmptyState</code> | <code>lib/swipes/presentation/swipe_hub_screen.dart:276</code> | — | — | No class documentation or registry summary. |
| <code>CatchesHubStateView</code> | <code>lib/swipes/presentation/swipe_hub_screen.dart:61</code> | — | — | No class documentation or registry summary. |
| <code>CatchesIntroCard</code> | <code>lib/swipes/presentation/swipe_hub_screen.dart:154</code> | — | — | No class documentation or registry summary. |
| <code>PillStat</code> | <code>lib/swipes/presentation/swipe_hub_screen.dart:238</code> | — | — | No class documentation or registry summary. |
| <code>CatchesBottomScrim</code> | <code>lib/swipes/presentation/swipe_screen.dart:438</code> | — | — | No class documentation or registry summary. |
| <code>CatchesPassButtonSkeleton</code> | <code>lib/swipes/presentation/swipe_screen.dart:348</code> | — | — | No class documentation or registry summary. |
| <code>CatchesProfileReview</code> | <code>lib/swipes/presentation/swipe_screen.dart:219</code> | — | — | No class documentation or registry summary. |
| <code>CatchesProfileReviewSkeleton</code> | <code>lib/swipes/presentation/swipe_screen.dart:173</code> | — | — | No class documentation or registry summary. |
| <code>CatchesTopOverlay</code> | <code>lib/swipes/presentation/swipe_screen.dart:357</code> | — | — | No class documentation or registry summary. |
| <code>CatchesTopOverlaySkeleton</code> | <code>lib/swipes/presentation/swipe_screen.dart:298</code> | — | — | No class documentation or registry summary. |
| <code>OverlayIconSkeleton</code> | <code>lib/swipes/presentation/swipe_screen.dart:339</code> | — | — | No class documentation or registry summary. |
| <code>AttendedEventTile</code> | <code>lib/swipes/presentation/widgets/attended_event_tile.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>CatchesPassButton</code> | <code>lib/swipes/presentation/widgets/catches_pass_button.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>SwipeEmptyState</code> | <code>lib/swipes/presentation/widgets/swipe_empty_state.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>CatchProfileView</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:20</code> | — | — | PHASE 2 — the flagship profile surface, in the locked editorial language: a person-polaroid hero on a graded photo, Archivo voice, IBM Plex Mono data, proseL reading text, hairlines over boxes. Color = activity (the kicker + reaction affordances borrow the meeting activity's pigment). |
| <code>PhotoCaption</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:527</code> | — | — | No class documentation or registry summary. |
| <code>ProfileCompatibility</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:284</code> | — | — | No class documentation or registry summary. |
| <code>ProfileFacts</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:432</code> | — | — | No class documentation or registry summary. |
| <code>ProfileHeroWidget</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:120</code> | — | — | No class documentation or registry summary. |
| <code>ProfilePhoto</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:177</code> | — | — | Real photo (graded at display time) or the activity-art fallback when absent. |
| <code>ProfilePhotoBlock</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:476</code> | — | — | No class documentation or registry summary. |
| <code>ProfilePrompt</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:350</code> | — | — | No class documentation or registry summary. |
| <code>ProfileRule</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:550</code> | — | — | No class documentation or registry summary. |
| <code>ProfileRunning</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:374</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSectionKicker</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:266</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSectionView</code> | <code>lib/swipes/shared/profile_surface/catch_profile_view.dart:206</code> | — | — | No class documentation or registry summary. |
| <code>ProfileInfoChip</code> | <code>lib/swipes/shared/profile_surface/profile_info_chip.dart:6</code> | — | — | No class documentation or registry summary. |
| <code>ProfileReactionCommentSheet</code> | <code>lib/swipes/shared/profile_surface/profile_reaction_controls.dart:99</code> | — | — | No class documentation or registry summary. |
| <code>ProfileReactionControls</code> | <code>lib/swipes/shared/profile_surface/profile_reaction_controls.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>ReactionControlButton</code> | <code>lib/swipes/shared/profile_surface/profile_reaction_controls.dart:217</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSurface</code> | <code>lib/swipes/shared/profile_surface/profile_surface.dart:19</code> | — | — | The single shared profile shell. Renders the flagship [CatchProfileView] for all three modes; only [ProfileSurfaceMode.catches] is reactable (per-section like + comment), so preview / public profile read calm and affordance-free. |
| <code>ProfileSurfaceFactsSkeleton</code> | <code>lib/swipes/shared/profile_surface/profile_surface.dart:291</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSurfaceHeroSkeleton</code> | <code>lib/swipes/shared/profile_surface/profile_surface.dart:159</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSurfacePhotoSkeleton</code> | <code>lib/swipes/shared/profile_surface/profile_surface.dart:269</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSurfaceRule</code> | <code>lib/swipes/shared/profile_surface/profile_surface.dart:323</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSurfaceRunningSkeleton</code> | <code>lib/swipes/shared/profile_surface/profile_surface.dart:234</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSurfaceSectionSkeleton</code> | <code>lib/swipes/shared/profile_surface/profile_surface.dart:200</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSurfaceSkeleton</code> | <code>lib/swipes/shared/profile_surface/profile_surface.dart:94</code> | — | — | Content-shaped placeholder for the shared public/preview profile surface. |
| <code>UserAnalyticsDataCoveragePanel</code> | <code>lib/user_analytics/shared/user_analytics_panel.dart:409</code> | — | — | No class documentation or registry summary. |
| <code>UserAnalyticsEmptyState</code> | <code>lib/user_analytics/shared/user_analytics_panel.dart:111</code> | — | — | No class documentation or registry summary. |
| <code>UserAnalyticsPanel</code> | <code>lib/user_analytics/shared/user_analytics_panel.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>UserAnalyticsReportSkeleton</code> | <code>lib/user_analytics/shared/user_analytics_panel.dart:147</code> | — | — | No class documentation or registry summary. |
| <code>UserAnalyticsReportView</code> | <code>lib/user_analytics/shared/user_analytics_panel.dart:75</code> | — | — | No class documentation or registry summary. |
| <code>UserAnalyticsTipRow</code> | <code>lib/user_analytics/shared/user_analytics_panel.dart:391</code> | — | — | No class documentation or registry summary. |
| <code>UserAnalyticsTipsPanel</code> | <code>lib/user_analytics/shared/user_analytics_panel.dart:377</code> | — | — | No class documentation or registry summary. |
| <code>UserAnalyticsTrendPanel</code> | <code>lib/user_analytics/shared/user_analytics_panel.dart:301</code> | — | — | No class documentation or registry summary. |
| <code>FormProfilePhotoField</code> | <code>lib/user_profile/presentation/form_profile_photo_field.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>FormProfilePhotoSelectionField</code> | <code>lib/user_profile/presentation/form_profile_photo_field.dart:54</code> | — | — | Keep the private image in memory only and evict its decoder entry on leave. The selection remains disabled until the actual image has rendered. |
| <code>FormProfileReviewPageBody</code> | <code>lib/user_profile/presentation/form_profile_review_screen.dart:86</code> | — | — | No class documentation or registry summary. |
| <code>FormProfilesAsyncBoundary</code> | <code>lib/user_profile/presentation/form_profiles_screen.dart:35</code> | — | — | The authenticated form directory can render inside the account pager before the applicant has a Consumer profile. It owns its independent async state. |
| <code>FormProfilesSectionList</code> | <code>lib/user_profile/presentation/form_profiles_screen.dart:57</code> | — | — | No class documentation or registry summary. |
| <code>PreviewTabSkeletonSliverBody</code> | <code>lib/user_profile/presentation/profile_screen.dart:261</code> | — | — | No class documentation or registry summary. |
| <code>PreviewTabSliverBody</code> | <code>lib/user_profile/presentation/profile_screen.dart:298</code> | — | — | No class documentation or registry summary. |
| <code>FormProfileValueField</code> | <code>lib/user_profile/presentation/widgets/form_profile_value_field.dart:11</code> | — | — | A typed field in the participant's explicit profile review. The parent owns draft changes, text controllers and claim acknowledgement. |
| <code>ProfileInlineMultiChoiceEntryEditor</code> | <code>lib/user_profile/presentation/widgets/inline_editor_choice.dart:174</code> | — | — | No class documentation or registry summary. |
| <code>ProfileInlineSingleChoiceEntryEditor</code> | <code>lib/user_profile/presentation/widgets/inline_editor_choice.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>ProfileInlineHeightEditor</code> | <code>lib/user_profile/presentation/widgets/inline_editor_height.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>ProfileInlinePromptEntryEditor</code> | <code>lib/user_profile/presentation/widgets/inline_editor_prompt.dart:21</code> | — | — | One contained prompt card: a staged question selector followed by a separate multiline answer that saves implicitly on blur. |
| <code>ProfileInlineRangeEditor</code> | <code>lib/user_profile/presentation/widgets/inline_editor_range.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>ProfileDirectTextEntryField</code> | <code>lib/user_profile/presentation/widgets/inline_editor_text.dart:17</code> | — | — | No class documentation or registry summary. |
| <code>ProfileInlineTextValue</code> | <code>lib/user_profile/presentation/widgets/inline_editor_text.dart:208</code> | — | — | Shared legacy inline-value adapter retained for host editor compatibility. |
| <code>PreviewTab</code> | <code>lib/user_profile/presentation/widgets/preview_tab.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>ProfileInsightsTabSliverBody</code> | <code>lib/user_profile/presentation/widgets/profile_insights_tab.dart:4</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSettingsButton</code> | <code>lib/user_profile/presentation/widgets/profile_sliver_header.dart:48</code> | — | — | No class documentation or registry summary. |
| <code>ProfileTabBar</code> | <code>lib/user_profile/presentation/widgets/profile_sliver_header.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>ProfileFieldRow</code> | <code>lib/user_profile/presentation/widgets/profile_tab.dart:327</code> | — | — | No class documentation or registry summary. |
| <code>ProfileMultiEnumEntry</code> | <code>lib/user_profile/presentation/widgets/profile_tab.dart:469</code> | — | — | No class documentation or registry summary. |
| <code>ProfilePhotosSection</code> | <code>lib/user_profile/presentation/widgets/profile_tab.dart:576</code> | — | — | No class documentation or registry summary. |
| <code>ProfilePromptEntry</code> | <code>lib/user_profile/presentation/widgets/profile_tab.dart:536</code> | — | — | No class documentation or registry summary. |
| <code>ProfileSingleEnumEntry</code> | <code>lib/user_profile/presentation/widgets/profile_tab.dart:409</code> | — | — | No class documentation or registry summary. |
| <code>ProfileTab</code> | <code>lib/user_profile/presentation/widgets/profile_tab.dart:26</code> | — | — | No class documentation or registry summary. |
| <code>ProfileTabContent</code> | <code>lib/user_profile/presentation/widgets/profile_tab.dart:86</code> | — | — | No class documentation or registry summary. |
| <code>ProfileTabSliverBody</code> | <code>lib/user_profile/presentation/widgets/profile_tab.dart:55</code> | — | — | No class documentation or registry summary. |
| <code>ProfileInfoSkeletonSection</code> | <code>lib/user_profile/presentation/widgets/profile_tab_skeleton.dart:85</code> | — | — | No class documentation or registry summary. |
| <code>ProfileInfoSkeletonTile</code> | <code>lib/user_profile/presentation/widgets/profile_tab_skeleton.dart:107</code> | — | — | No class documentation or registry summary. |
| <code>ProfilePhotosSkeletonSection</code> | <code>lib/user_profile/presentation/widgets/profile_tab_skeleton.dart:53</code> | — | — | No class documentation or registry summary. |
| <code>ProfileTabSkeletonSliverBody</code> | <code>lib/user_profile/presentation/widgets/profile_tab_skeleton.dart:9</code> | — | — | No class documentation or registry summary. |

### L6 (113)

| Widget | Source | Role | Canonical concept | Purpose |
|---|---|---|---|---|
| <code>ConsumerPlatformApp</code> | <code>apps/consumer/lib/consumer_platform_app.dart:11</code> | — | — | Consumer-owned native capability bindings around the shared Consumer UI. |
| <code>HostPlatformApp</code> | <code>apps/host/lib/host_platform_app.dart:6</code> | — | — | Host-owned app root selecting only the Host router and default capabilities. |
| <code>ForceUpdateCheckErrorScreen</code> | <code>lib/app.dart:224</code> | — | — | No class documentation or registry summary. |
| <code>MyApp</code> | <code>lib/app.dart:42</code> | — | — | No class documentation or registry summary. |
| <code>AuthScreen</code> | <code>lib/auth/presentation/auth_screen.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>OtpPage</code> | <code>lib/auth/presentation/otp_page.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>PhonePage</code> | <code>lib/auth/presentation/phone_page.dart:23</code> | — | — | No class documentation or registry summary. |
| <code>ChatScreen</code> | <code>lib/chats/presentation/chat_screen.dart:36</code> | — | — | No class documentation or registry summary. |
| <code>EventChatParticipantsScreen</code> | <code>lib/chats/presentation/event_chat_participants_screen.dart:13</code> | — | — | No class documentation or registry summary. |
| <code>EventChatScreen</code> | <code>lib/chats/presentation/event_chat_screen.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>EventProfileScreen</code> | <code>lib/chats/presentation/event_profile_screen.dart:16</code> | — | — | Account-bound editor and protected participant view for one event chat. |
| <code>ChatsListScreen</code> | <code>lib/chats/presentation/inbox/chat_inbox_screen.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>ClubDetailScreen</code> | <code>lib/clubs/presentation/detail/club_detail_screen.dart:31</code> | — | — | No class documentation or registry summary. |
| <code>ConsumerApp</code> | <code>lib/consumer_app.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>CatchConsumerBootScreen</code> | <code>lib/consumer_bootstrap.dart:167</code> | — | — | The animated Consumer cold-start surface shown above auth and routing. |
| <code>CatchCelebrationScreen</code> | <code>lib/core/celebration/catch_celebration_screen.dart:41</code> | — | — | No class documentation or registry summary. |
| <code>CatchStartupLoadingScreen</code> | <code>lib/core/widgets/catch_startup_loading_screen.dart:9</code> | — | — | Branded app-start composition with the Catch logo and a delayed bounded loading indicator. |
| <code>OrderedPhotoManagerScreen</code> | <code>lib/core/widgets/ordered_photo_picker.dart:166</code> | — | — | Full-screen editor for long ordered galleries. It keeps a local mirror so dozens of items can be reordered or removed without collapsing the route; every operation is also forwarded to the owning draft/controller. |
| <code>CrossPathsInvitationScreen</code> | <code>lib/cross_paths/presentation/cross_paths_invitation_screen.dart:28</code> | — | — | No class documentation or registry summary. |
| <code>ActivityScreen</code> | <code>lib/dashboard/presentation/activity_screen.dart:23</code> | — | — | No class documentation or registry summary. |
| <code>DashboardEmptyHomeScreen</code> | <code>lib/dashboard/presentation/dashboard_empty_home_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>DashboardErrorScreen</code> | <code>lib/dashboard/presentation/dashboard_error_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>DashboardHomeScreen</code> | <code>lib/dashboard/presentation/dashboard_home_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>DashboardLoadingScreen</code> | <code>lib/dashboard/presentation/dashboard_loading_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>DashboardScreen</code> | <code>lib/dashboard/presentation/dashboard_screen.dart:25</code> | — | — | No class documentation or registry summary. |
| <code>HostEventRehearsalScreen</code> | <code>lib/event_rehearsal/presentation/host_event_rehearsal_screen.dart:38</code> | — | — | No class documentation or registry summary. |
| <code>HostEventRehearsalStartScreen</code> | <code>lib/event_rehearsal/presentation/host_event_rehearsal_start_screen.dart:20</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCompanionScreen</code> | <code>lib/event_success/presentation/event_success_companion_body_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>EventSuccessCompanionRouteScreen</code> | <code>lib/event_success/presentation/event_success_companion_screen.dart:201</code> | — | — | No class documentation or registry summary. |
| <code>CalendarLoadingScreen</code> | <code>lib/events/presentation/calendar/calendar_loading_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>CalendarScreen</code> | <code>lib/events/presentation/calendar/calendar_screen.dart:25</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailScreen</code> | <code>lib/events/presentation/event_detail_screen.dart:53</code> | — | — | No class documentation or registry summary. |
| <code>EventLocationMapScreen</code> | <code>lib/events/presentation/event_location_map_body_screen.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>EventLocationMapRouteScreen</code> | <code>lib/events/presentation/event_location_map_screen.dart:20</code> | — | — | No class documentation or registry summary. |
| <code>LocationPickerScreen</code> | <code>lib/events/presentation/location_picker_screen.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>SavedEventsScreen</code> | <code>lib/events/presentation/saved_events_screen.dart:20</code> | — | — | No class documentation or registry summary. |
| <code>EventDetailLoadingScreen</code> | <code>lib/events/presentation/widgets/event_detail_loading_skeleton.dart:8</code> | — | — | No class documentation or registry summary. |
| <code>EventCheckInCelebrationScreen</code> | <code>lib/events/shared/event_check_in_celebration_screen.dart:9</code> | — | — | No class documentation or registry summary. |
| <code>EventJoinedCelebrationScreen</code> | <code>lib/events/shared/event_joined_celebration_screen.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>ExploreMapScreen</code> | <code>lib/explore/presentation/explore_map_screen.dart:40</code> | — | — | Full-screen event map opened from the Explore feed's map pill. |
| <code>ExploreScreen</code> | <code>lib/explore/presentation/explore_screen.dart:53</code> | — | — | Explore — the supply-side feed (design-system Explore). |
| <code>UpdateRequiredScreen</code> | <code>lib/force_update/presentation/update_required_screen.dart:15</code> | — | — | Blocking screen shown when the running app version is below [minVersion]. |
| <code>HostApp</code> | <code>lib/host_app.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>HostEventsScreen</code> | <code>lib/hosts/events/presentation/host_events_screen.dart:24</code> | — | — | No class documentation or registry summary. |
| <code>HostEventsTimelinePage</code> | <code>lib/hosts/events/presentation/widgets/host_events_list.dart:211</code> | — | — | One lifecycle page. The root owns tabs and scrolling chrome; this adapter selects data/state only, and the shared page/section/record owners lay it out. |
| <code>HostApplicationDetailScreen</code> | <code>lib/hosts/presentation/applications/host_application_detail_screen.dart:5</code> | — | — | Compatibility entry for saved application URLs; all detail UI has one owner. |
| <code>CreateClubScreen</code> | <code>lib/hosts/presentation/club_management/create/create_club_screen.dart:34</code> | — | — | No class documentation or registry summary. |
| <code>HostClubEditorLoadingScreen</code> | <code>lib/hosts/presentation/club_management/create/widgets/host_club_editor_loading_screen.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>HostCreateClubScreen</code> | <code>lib/hosts/presentation/club_management/host_create_club_screen.dart:4</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomerDetailScreen</code> | <code>lib/hosts/presentation/customers/host_customer_detail_screen.dart:43</code> | — | — | No class documentation or registry summary. |
| <code>HostAddCustomerScreen</code> | <code>lib/hosts/presentation/customers/host_customer_editor.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>HostCustomersScreen</code> | <code>lib/hosts/presentation/customers/host_customers_screen.dart:64</code> | — | — | No class documentation or registry summary. |
| <code>HostSavedAudienceEditorScreen</code> | <code>lib/hosts/presentation/customers/host_saved_audience_editor.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>EditHostedEventRouteScreen</code> | <code>lib/hosts/presentation/edit_hosted_event_route_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>EditHostedEventScreen</code> | <code>lib/hosts/presentation/edit_hosted_event_screen.dart:59</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventScreen</code> | <code>lib/hosts/presentation/event_management/create/create_event_screen.dart:78</code> | — | — | No class documentation or registry summary. |
| <code>CreateEventSuccessScreen</code> | <code>lib/hosts/presentation/event_management/create/create_event_success_screen.dart:15</code> | — | — | No class documentation or registry summary. |
| <code>HostCreateEventRouteLoadingScreen</code> | <code>lib/hosts/presentation/event_management/host_create_event_route_loading_screen.dart:7</code> | — | — | No class documentation or registry summary. |
| <code>HostCreateEventRouteScreen</code> | <code>lib/hosts/presentation/event_management/host_create_event_screen.dart:43</code> | — | — | No class documentation or registry summary. |
| <code>RoutePathBuilderScreen</code> | <code>lib/hosts/presentation/event_management/widgets/route_path_builder_screen.dart:10</code> | — | — | Tap-to-build route geometry used by moving event formats. |
| <code>HostFormAnalyticsScreen</code> | <code>lib/hosts/presentation/forms/host_form_analytics_screen.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>HostFormAutomationsScreen</code> | <code>lib/hosts/presentation/forms/host_form_automations_screen.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>HostFormBuilderScreen</code> | <code>lib/hosts/presentation/forms/host_form_builder_screen.dart:31</code> | — | — | No class documentation or registry summary. |
| <code>HostFormPreviewScreen</code> | <code>lib/hosts/presentation/forms/host_form_preview_screen.dart:10</code> | — | — | No class documentation or registry summary. |
| <code>HostFormResponseDetailScreen</code> | <code>lib/hosts/presentation/forms/host_form_response_detail_screen.dart:36</code> | — | — | One detail surface for submitted forms and imported application records. |
| <code>HostFormShareScreen</code> | <code>lib/hosts/presentation/forms/host_form_share_screen.dart:20</code> | — | — | No class documentation or registry summary. |
| <code>HostFormTemplatesScreen</code> | <code>lib/hosts/presentation/forms/host_form_templates_screen.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>HostFormsScreen</code> | <code>lib/hosts/presentation/forms/host_forms_screen.dart:46</code> | — | — | No class documentation or registry summary. |
| <code>HostEventManageRouteScreen</code> | <code>lib/hosts/presentation/host_event_manage_route_screen.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>HostEventManageScreen</code> | <code>lib/hosts/presentation/host_event_manage_screen.dart:54</code> | — | — | No class documentation or registry summary. |
| <code>HostEventOperatorScreen</code> | <code>lib/hosts/presentation/host_event_operator_screen.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>HostClubLiveGuideScreen</code> | <code>lib/hosts/presentation/host_operations/host_club_live_guide_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostClubPaymentsScreen</code> | <code>lib/hosts/presentation/host_operations/host_club_payments_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostClubEventDefaultsScreen</code> | <code>lib/hosts/presentation/host_operations/host_club_spoke_screens.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostClubTeamScreen</code> | <code>lib/hosts/presentation/host_operations/host_club_team_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostClubsScreen</code> | <code>lib/hosts/presentation/host_operations/host_clubs_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostLoadingScreen</code> | <code>lib/hosts/presentation/host_operations/host_loading_screen.dart:3</code> | — | — | No class documentation or registry summary. |
| <code>HostInboxScreen</code> | <code>lib/hosts/presentation/inbox/host_inbox_screen.dart:40</code> | — | — | No class documentation or registry summary. |
| <code>HostMessagingSetupScreen</code> | <code>lib/hosts/presentation/inbox/host_messaging_setup_screen.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>HostNewMessageScreen</code> | <code>lib/hosts/presentation/inbox/host_new_message_screen.dart:33</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayFocusScreen</code> | <code>lib/hosts/today/personalization/presentation/host_today_focus_screen.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayLoadedRoute</code> | <code>lib/hosts/today/presentation/host_today_screen.dart:264</code> | — | — | No class documentation or registry summary. |
| <code>HostTodayScreen</code> | <code>lib/hosts/today/presentation/host_today_screen.dart:33</code> | — | — | No class documentation or registry summary. |
| <code>ProfilePhotoEditorScreen</code> | <code>lib/image_uploads/shared/profile_photo_editor_screen.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>LaunchAccessApplicationScreen</code> | <code>lib/launch_access/presentation/launch_access_application_screen.dart:17</code> | — | — | No class documentation or registry summary. |
| <code>OnboardingScreen</code> | <code>lib/onboarding/presentation/onboarding_screen.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>GenderInterestPage</code> | <code>lib/onboarding/presentation/pages/gender_interest_page.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>InstagramPage</code> | <code>lib/onboarding/presentation/pages/instagram_page.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>NameDobPage</code> | <code>lib/onboarding/presentation/pages/name_dob_page.dart:12</code> | — | — | No class documentation or registry summary. |
| <code>PhotosPage</code> | <code>lib/onboarding/presentation/pages/photos_page.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>ProfilePromptsPage</code> | <code>lib/onboarding/presentation/pages/profile_prompts_page.dart:17</code> | — | — | No class documentation or registry summary. |
| <code>RunningPrefsPage</code> | <code>lib/onboarding/presentation/pages/running_prefs_page.dart:16</code> | — | — | No class documentation or registry summary. |
| <code>WelcomePage</code> | <code>lib/onboarding/presentation/pages/welcome_page.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>StartWelcomeRouteScreen</code> | <code>lib/onboarding/presentation/start_welcome_route_screen.dart:9</code> | — | — | Route-level surface owner for the logged-out Welcome experience. |
| <code>PaymentConfirmationLoadingScreen</code> | <code>lib/payments/presentation/payment_confirmation_loading_screen.dart:5</code> | — | — | No class documentation or registry summary. |
| <code>PaymentConfirmationScreen</code> | <code>lib/payments/presentation/payment_confirmation_screen.dart:32</code> | — | — | No class documentation or registry summary. |
| <code>PaymentHistoryScreen</code> | <code>lib/payments/presentation/payment_history_screen.dart:20</code> | — | — | No class documentation or registry summary. |
| <code>ProgramArrivalsScreen</code> | <code>lib/programs/presentation/program_arrivals_screen.dart:28</code> | — | — | The greeter's live arrivals roster for one pickup station. |
| <code>ProgramDispatchScreen</code> | <code>lib/programs/presentation/program_dispatch_screen.dart:26</code> | — | — | The dispatcher's desk for one pickup station: the deterministic batch suggestions plus the dispatch sheet that captures plate, vendor and class at the moment the vehicle departs — the act that generates the reconciliation record. |
| <code>ProgramHotelDeskScreen</code> | <code>lib/programs/presentation/program_hotel_desk_screen.dart:16</code> | — | — | The hotel welcome team's inbound view: vehicles on the way with their manifest names and plates, plus parties still expected at the airport. Deliberately narrow — no contact fields, no other hotels. |
| <code>ProgramTripsScreen</code> | <code>lib/programs/presentation/program_trips_screen.dart:16</code> | — | — | The trip ledger: every dispatch as a reconciliation record — plate, vendor, class, manifest and outcome. Voided trips keep their row so the vendor invoice can be checked line by line. |
| <code>ProgramWorkScreen</code> | <code>lib/programs/presentation/program_work_screen.dart:23</code> | — | — | Scoped entry point for private program staff. |
| <code>PublicProfileScreen</code> | <code>lib/public_profile/presentation/public_profile_screen.dart:19</code> | — | — | No class documentation or registry summary. |
| <code>ReviewsHistoryScreen</code> | <code>lib/reviews/presentation/reviews_history_screen.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>MessagingPermissionsScreen</code> | <code>lib/safety/presentation/messaging_permissions_screen.dart:11</code> | — | — | No class documentation or registry summary. |
| <code>SettingsScreen</code> | <code>lib/safety/presentation/settings_screen.dart:31</code> | — | — | No class documentation or registry summary. |
| <code>EventRecapScreen</code> | <code>lib/swipes/presentation/event_recap_screen.dart:21</code> | — | — | No class documentation or registry summary. |
| <code>FiltersScreen</code> | <code>lib/swipes/presentation/filters_screen.dart:25</code> | — | — | No class documentation or registry summary. |
| <code>SwipeHubScreen</code> | <code>lib/swipes/presentation/swipe_hub_screen.dart:18</code> | — | — | No class documentation or registry summary. |
| <code>SwipeScreen</code> | <code>lib/swipes/presentation/swipe_screen.dart:29</code> | — | — | No class documentation or registry summary. |
| <code>FormProfileReviewScreen</code> | <code>lib/user_profile/presentation/form_profile_review_screen.dart:22</code> | — | — | No class documentation or registry summary. |
| <code>FormProfilesScreen</code> | <code>lib/user_profile/presentation/form_profiles_screen.dart:14</code> | — | — | No class documentation or registry summary. |
| <code>ProfileScreen</code> | <code>lib/user_profile/presentation/profile_screen.dart:24</code> | — | — | No class documentation or registry summary. |

<!-- END GENERATED WIDGET INVENTORY -->
