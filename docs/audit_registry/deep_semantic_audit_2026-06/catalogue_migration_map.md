---
doc_id: catalogue_migration_map
version: 1.0.0
updated: 2026-06-16
owner: recursive_audit_loop
status: active
---

# Catalogue Migration Map

Single-seam inventory to support the in-flight component redesign. Every core
primitive is now `Catch`-prefixed and semantically named. Each row's **call sites**
is the blast radius of redesigning that primitive — because feature code composes
these seams, a redesigned component swaps in with no call-site churn.

Current status note: this June snapshot is retained as audit history. Active
field-like rows have since converged on `CatchField` and `CatchSection`;
`CatchSettingsRow`, `CatchDesignSection`, and `CatchFieldGroup` are no longer
active app primitives.

## Established single seams (redesign these in place; usage already routed through them)

| Primitive | File | Call sites |
|---|---|---:|
| `CatchSurface` | core/widgets/catch_surface.dart | 222 |
| `CatchBadge` | core/widgets/catch_badge.dart | 162 |
| `CatchButton` | core/widgets/catch_button.dart | 130 |
| `CatchField` | core/widgets/catch_field.dart | 77 |
| `CatchLoadingIndicator` | core/widgets/catch_loading_indicator.dart | 53 |
| `CatchSettingsRow` | core/widgets/settings_row.dart | 48 |
| `CatchEmptyState` | core/widgets/catch_empty_state.dart | 26 |
| `CatchSelectChip` | core/widgets/select_chip.dart | 26 |
| `CatchTopBar` | core/widgets/catch_top_bar.dart | 25 |
| `CatchIconButton` | core/widgets/icon_btn.dart | 22 |
| `CatchErrorBanner` | core/widgets/error_banner.dart | 21 |
| `CatchDesignSection` | core/widgets/catch_section_layout.dart | 19 |
| `CatchToggle` | core/widgets/catch_toggle.dart | 19 |
| `CatchMutationErrorListener` | core/widgets/mutation_error_snackbar_listener.dart | 19 |
| `CatchBottomSheetScaffold` | core/widgets/catch_bottom_sheet.dart | 15 |
| `CatchNetworkImage` | core/widgets/catch_network_image.dart | 14 |
| `CatchTopBarIconAction` | core/widgets/catch_top_bar.dart | 14 |
| `CatchFormFieldLabel` | core/widgets/catch_form_field_label.dart | 11 |
| `CatchErrorScaffold` | core/widgets/catch_error_state.dart | 10 |
| `CatchIconTile` | core/widgets/catch_icon_tile.dart | 10 |
| `CatchTextButton` | core/widgets/catch_text_button.dart | 10 |
| `CatchBottomCta` | core/widgets/bottom_cta.dart | 9 |
| `CatchPersonAvatar` | core/widgets/person_avatar.dart | 9 |
| `CatchSectionHeader` | core/widgets/section_header.dart | 9 |
| `CatchControlShell` | core/widgets/catch_control_shell.dart | 8 |
| `CatchErrorState` | core/widgets/catch_error_state.dart | 8 |
| `CatchMonoLabel` | core/widgets/catch_mono_label.dart | 8 |
| `CatchBottomSheetGrabber` | core/widgets/bottom_sheet_grabber.dart | 6 |
| `CatchGradedImage` | core/widgets/graded_image.dart | 6 |
| `CatchNumberStepper` | core/widgets/catch_number_stepper.dart | 5 |
| `CatchDetailRow` | core/widgets/detail_row.dart | 5 |
| `CatchStatColumn` | core/widgets/stat_column.dart | 5 |
| `CatchBottomDock` | core/widgets/catch_bottom_dock.dart | 4 |
| `CatchChip` | core/widgets/catch_chip.dart | 4 |
| `CatchSectionList` | core/widgets/catch_section_layout.dart | 4 |
| `CatchStartupLoadingScreen` | core/widgets/catch_startup_loading_screen.dart | 4 |
| `CatchEventTicketCard` | core/widgets/catch_event_activity_cards.dart | 3 |
| `CatchEventSpotlightCard` | core/widgets/catch_event_activity_cards.dart | 3 |
| `CatchHorizontalRail` | core/widgets/catch_horizontal_rail.dart | 3 |
| `CatchKicker` | core/widgets/catch_kicker.dart | 3 |
| `CatchRangeSlider` | core/widgets/catch_range_slider.dart | 3 |
| `CatchSectionStack` | core/widgets/catch_section_layout.dart | 3 |
| `CatchSkeletonList` | core/widgets/catch_skeleton.dart | 3 |
| `CatchStatusDot` | core/widgets/catch_status_dot.dart | 3 |
| `CatchStepFlowHeader` | core/widgets/catch_step_flow_header.dart | 3 |
| `CatchPersonRow` | core/widgets/person_row.dart | 3 |
| `CatchBrowseHeader` | core/widgets/catch_browse_header.dart | 2 |
| `CatchCountPill` | core/widgets/catch_count_pill.dart | 2 |
| `CatchDetailHeroBackdrop` | core/widgets/catch_detail_hero_backdrop.dart | 2 |
| `CatchErrorIcon` | core/widgets/catch_error_icon.dart | 2 |
| `CatchInlineErrorState` | core/widgets/catch_error_state.dart | 2 |
| `CatchEventThumbnail` | core/widgets/catch_event_thumbnail.dart | 2 |
| `CatchExpandingSearch` | core/widgets/catch_expanding_search.dart | 2 |
| `CatchMetaDotRow` | core/widgets/catch_meta_row.dart | 2 |
| `CatchNoticeHost` | core/widgets/catch_notice.dart | 2 |
| `CatchSearchField` | core/widgets/catch_search_field.dart | 2 |
| `CatchCollapsedSliverTitle` | core/widgets/catch_top_bar.dart | 2 |
| `CatchPersonAvatarStack` | core/widgets/person_avatar.dart | 2 |
| `CatchShareCardSheet` | core/widgets/rich_share_card_sheet.dart | 2 |
| `CatchActivityChip` | core/widgets/activity_chip.dart | 1 |
| `CatchActivityMapPin` | core/widgets/activity_map_pin.dart | 1 |
| `CatchIconBadge` | core/widgets/catch_badge.dart | 1 |
| `CatchCornerSash` | core/widgets/catch_corner_sash.dart | 1 |
| `CatchDraggableSheetShell` | core/widgets/catch_draggable_sheet_shell.dart | 1 |
| `CatchFrameworkErrorView` | core/widgets/catch_framework_error_view.dart | 1 |
| `CatchMetricStrip` | core/widgets/catch_metric_strip.dart | 1 |
| `CatchOtpCodeField` | core/widgets/catch_otp_code_field.dart | 1 |
| `CatchPageDots` | core/widgets/catch_page_dots.dart | 1 |
| `CatchPanel` | core/widgets/catch_panel.dart | 1 |
| `CatchDetailSliverSectionList` | core/widgets/catch_section_layout.dart | 1 |
| `CatchTopBarTextAction` | core/widgets/catch_top_bar.dart | 1 |
| `CatchMetricStrip` | core/widgets/stat_strip.dart | 1 |

_Primitives with 0 external call sites (composed only internally or pending adoption):_ `CatchActivityArt`, `CatchActivityAvatar`, `CatchDaySectionHeader`, `CatchSliverErrorState`, `CatchNotice`, `CatchCodeInput`, `CatchSectionCard`, `CatchPageBody`, `CatchScreenBody`, `CatchFormStepBody`, `CatchSliverPageBody`, `CatchSkeleton`, `CatchStatusBar`, `CatchStepHeader`, `CatchStepProgress`, `CatchTopBarTabBar`, `CatchVerticalSection`, `CatchDistanceRing`, `CatchFieldGroup`, `CatchField`, `CatchPrivacyBadge`, `CatchSectionLabel`, `CatchSoftBand`

## Remaining non-catalogue surface to fold in

### Ad-hoc `BoxDecoration` surfaces (candidates for `CatchSurface`)

29 sites across 25 feature files. Some are legitimately bespoke (gradients/scrims); review per-site when the surface component is redesigned:

- lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart — 3
- lib/clubs/presentation/shared/catch_polaroid.dart — 2
- lib/events/presentation/widgets/event_tiles/event_date_marker.dart — 2
- lib/calendar/presentation/calendar_screen.dart — 1
- lib/clubs/presentation/discovery/widgets/club_list_tile_parts/avatar_chip.dart — 1
- lib/dashboard/presentation/widgets/activity_section.dart — 1
- lib/dashboard/presentation/widgets/stride_card.dart — 1
- lib/event_success/presentation/companion_parts/event_success_companion_arrival_mission.dart — 1
- lib/event_success/presentation/companion_parts/event_success_companion_live_cards.dart — 1
- lib/event_success/presentation/live_reveal_parts/event_success_live_reveal_widgets.dart — 1
- lib/events/presentation/event_activity_visuals.dart — 1
- lib/events/presentation/widgets/event_detail_design_primitives.dart — 1
- lib/events/presentation/widgets/event_detail_hero_app_bar.dart — 1
- lib/events/presentation/widgets/event_pins_map.dart — 1
- lib/explore/presentation/widgets/explore_event_type_browse_grid.dart — 1
- lib/hosts/presentation/club_management/create/create_club_screen.dart — 1
- lib/hosts/presentation/edit_hosted_event_screen.dart — 1
- lib/hosts/presentation/widgets/host_club_tools.dart — 1
- lib/payments/presentation/payment_confirmation_screen.dart — 1
- lib/swipes/presentation/event_recap_screen.dart — 1
- lib/swipes/presentation/filters_screen.dart — 1
- lib/swipes/presentation/profile_redesign/catch_profile_view.dart — 1
- lib/swipes/presentation/swipe_screen.dart — 1
- lib/user_profile/presentation/widgets/profile_inline_editors.dart — 1
- lib/user_profile/presentation/widgets/profile_sliver_header.dart — 1

### Feature-local widget classes by area (composition + consolidation candidates)

| Area | Feature widget classes |
|---|---:|
| event_success | 175 |
| hosts | 101 |
| events | 88 |
| clubs | 43 |
| explore | 42 |
| swipes | 42 |
| dashboard | 34 |
| user_profile | 29 |
| chats | 27 |
| event_policies | 14 |
| reviews | 13 |
| matches | 12 |
| onboarding | 12 |
| payments | 12 |
| image_uploads | 9 |
| calendar | 8 |
| launch_access | 5 |
| auth | 4 |
| safety | 4 |
| public_profile | 3 |
| force_update | 1 |
| locations | 0 |

Total feature-local widget classes: 678. These are the screens/widgets that compose the catalogue; as primitives are redesigned, audit each area for bespoke UI that should become (or already has) a catalogue equivalent.
