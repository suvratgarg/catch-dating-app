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
export 'presentation/club_management/create/create_club_controller.dart';
export 'presentation/club_management/create/create_club_draft_controller.dart';
export 'presentation/club_management/create/create_club_screen.dart';
export 'presentation/club_management/host_club_edit_controller.dart';
export 'presentation/club_management/host_create_club_screen.dart';
export 'presentation/club_management/host_team_management_controller.dart';
export 'presentation/edit_hosted_event_screen.dart';
export 'presentation/event_management/create/create_event_controller.dart';
export 'presentation/event_management/create/create_event_draft_controller.dart';
export 'presentation/event_management/create/create_event_form_keys.dart';
export 'presentation/event_management/create/create_event_screen.dart';
export 'presentation/event_management/create/create_event_success_screen.dart';
export 'presentation/event_management/host_create_event_screen.dart';
export 'presentation/event_management/widgets/event_policy_step.dart';
export 'presentation/host_event_manage_controller.dart';
export 'presentation/host_event_manage_screen.dart';
export 'presentation/host_operations_screen.dart';
export 'presentation/host_profile_controller.dart';
export 'presentation/host_settings_state.dart';
export 'presentation/payments/host_payment_account_card.dart';
export 'presentation/payments/host_payment_account_controller.dart';
export 'presentation/validators.dart';
export 'presentation/widgets/catch_roster_board.dart';
export 'presentation/widgets/host_club_tools.dart';
export 'presentation/widgets/host_event_attendance_panel.dart';
export 'presentation/widgets/host_event_tools.dart';
export 'presentation/widgets/host_loading_skeletons.dart';
export 'presentation/widgets/host_team_management_section.dart';
