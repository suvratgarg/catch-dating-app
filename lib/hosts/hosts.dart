/// Hosts feature barrel.
///
/// Aggregates the main public API of the hosts feature so consumers can import
/// a single file instead of deep paths into the feature. Not every file in
/// `lib/hosts/` is exported — only the entry points intended for cross-feature
/// consumption.
///
/// Feature-internal widgets used only inside `lib/hosts/presentation/` are not
/// exported here; import them by their direct path.
library;

export 'data/host_analytics_repository.dart';
export 'data/host_profile_repository.dart';
export 'domain/host_attendance_window.dart';
export 'domain/host_profile.dart';
export 'domain/host_report_export.dart';
export 'presentation/club_management/create/create_club_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/club_management/create/create_club_draft_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/club_management/create/create_club_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/club_management/host_club_edit_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/club_management/host_create_club_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/club_management/host_team_management_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/edit_hosted_event_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/event_management/create/create_event_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/event_management/create/create_event_draft_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/event_management/create/create_event_draft_snapshot.dart'; // public-api: presentation value/helper API used across feature boundaries
export 'presentation/event_management/create/create_event_form_keys.dart'; // public-api: presentation value/helper API used across feature boundaries
export 'presentation/event_management/create/create_event_location_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/event_management/create/create_event_photo_draft_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/event_management/create/create_event_policy_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/event_management/create/create_event_schedule_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/event_management/create/create_event_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/event_management/create/create_event_success_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/event_management/create/create_event_wizard_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/event_management/host_create_event_route_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/event_management/host_create_event_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/event_management/widgets/event_policy_step.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/host_event_booking_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/host_event_manage_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/host_event_manage_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/host_event_manage_screen_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/host_home_screen_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/host_operations_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/host_profile_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/host_team_workspace_state.dart'; // public-api: provider-free display state reused by tests and routes
export 'presentation/payments/host_payment_account_card.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/payments/host_payment_account_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/validators.dart'; // public-api: presentation value/helper API used across feature boundaries
export 'presentation/widgets/catch_roster_board.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/host_club_tools.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/host_event_attendance_panel.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/host_event_tools.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/host_loading_skeletons.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/host_team_management_section.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/stepper_footer.dart'; // public-api: shared presentation component used outside this feature
