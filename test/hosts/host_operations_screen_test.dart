import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_skeletonized.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tabbed_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_date_rail_card.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_club_edit_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_memory.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_row.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_events_timeline_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../clubs/clubs_test_helpers.dart';
import '../test_pump_helpers.dart';

part 'host_operations_state_events_tests.dart';
part 'host_operations_club_workspace_tests.dart';
part 'host_operations_customers_tests.dart';
part 'host_operations_customers_test_support.dart';
part 'host_operations_customer_state_tests.dart';
part 'host_operations_analytics_team_tests.dart';
part 'host_operations_team_failures_tests.dart';
part 'support/host_operations_screen_test_support.dart';

const _hostUid = 'host-1';

void main() {
  setUp(() {
    AppConfig.configureEntrypointRole(AppRole.host);
  });

  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  _registerHostOperationsStateEventsTests();
  _registerHostOperationsClubWorkspaceTests();
  _registerHostOperationsCustomersTests();
  _registerHostOperationsCustomerStateTests();
  _registerHostOperationsAnalyticsTeamTests();
  _registerHostOperationsTeamFailuresTests();
}

Future<void> _editHostTeamProfileField(
  WidgetTester tester, {
  required String title,
  required String value,
}) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == title,
  );
  await tester.ensureVisible(field);
  await tester.tap(field);
  await pumpFeatureUi(tester);
  final input = find.descendant(of: field, matching: find.byType(TextField));
  expect(input, findsOneWidget);
  await tester.enterText(input, value);
  await tester.tap(find.byKey(const ValueKey('catch-field-done')));
  await pumpFeatureUi(tester);
}

Club _hostTeamClub() => buildClub(
  id: 'owned-club',
  name: 'Saket Run Club',
  ownerUserId: _hostUid,
  hostProfiles: const [
    ClubHostProfile(
      uid: _hostUid,
      displayName: 'Catch Host',
      role: ClubHostRole.owner,
    ),
  ],
);

ClubDetailViewModel _previewViewModel(
  Club club, {
  List<Event> events = const [],
}) {
  return ClubDetailViewModel(
    club: club,
    isHost: true,
    isMember: true,
    upcomingEvents: events,
    reviews: const [],
    userProfile: buildUser(uid: _hostUid),
    uid: _hostUid,
    isAuthenticated: true,
  );
}

Future<void> _pumpHostScreen(
  WidgetTester tester,
  Widget child, {
  List overrides = const [],
  bool settle = true,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => child),
      GoRoute(
        path: Routes.hostOrganizerScreen.path,
        name: Routes.hostOrganizerScreen.name,
        builder: (_, _) => const Text('Organizer route'),
      ),
      GoRoute(
        path: Routes.hostCreateClubScreen.path,
        name: Routes.hostCreateClubScreen.name,
        builder: (_, _) => const Text('Create club route'),
      ),
      GoRoute(
        path: Routes.hostCreateEventScreen.path,
        name: Routes.hostCreateEventScreen.name,
        builder: (_, state) => switch (state.extra) {
          final HostCreateEventRouteArguments arguments
              when arguments.initialPrefill != null =>
            Text('Repeat ${arguments.initialPrefill!.sourceEventId}'),
          final HostCreateEventRouteArguments arguments
              when arguments.initialDraft != null =>
            Text('Draft ${arguments.initialDraft!.id}'),
          _ => Text('Create ${state.pathParameters['clubId']}'),
        },
      ),
      GoRoute(
        path: Routes.hostClubTeamScreen.path,
        name: Routes.hostClubTeamScreen.name,
        builder: (_, state) => HostClubTeamScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostInboxScreen.path,
        name: Routes.hostInboxScreen.name,
        builder: (_, state) => Text(
          'Messaging ${state.uri.queryParameters['workspace']} '
          '${state.uri.queryParameters['segment']}',
        ),
      ),
      GoRoute(
        path: Routes.hostClubDetailScreen.path,
        name: Routes.hostClubDetailScreen.name,
        builder: (_, state) => Text('Club ${state.pathParameters['clubId']}'),
      ),
      GoRoute(
        path: Routes.hostClubEventDefaultsScreen.path,
        name: Routes.hostClubEventDefaultsScreen.name,
        builder: (_, state) => HostClubEventDefaultsScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostClubLiveGuideScreen.path,
        name: Routes.hostClubLiveGuideScreen.name,
        builder: (_, state) => HostClubLiveGuideScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostClubPaymentsScreen.path,
        name: Routes.hostClubPaymentsScreen.name,
        builder: (_, state) => HostClubPaymentsScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostAppEventManageScreen.path,
        name: Routes.hostAppEventManageScreen.name,
        builder: (_, state) => Column(
          children: [
            Text('Manage ${state.pathParameters['eventId']}'),
            Text('Section ${state.uri.queryParameters['section'] ?? 'setup'}'),
          ],
        ),
      ),
      GoRoute(
        path: Routes.hostAppEventDetailScreen.path,
        name: Routes.hostAppEventDetailScreen.name,
        builder: (_, state) => Text(
          'Event ${state.pathParameters['clubId']} '
          '${state.pathParameters['eventId']}',
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  if (settle) {
    await pumpFeatureUi(tester);
  } else {
    await tester.pump();
    await tester.pump();
  }
}
