import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/event_chat_participants_screen.dart';
import 'package:catch_dating_app/chats/presentation/event_chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/event_profile_screen.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chat_inbox_screen.dart'; // ChatsListScreen
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/host_app_shell.dart';
import 'package:catch_dating_app/cross_paths/presentation/cross_paths_invitation_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/host_event_rehearsal_screen.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/host_event_rehearsal_start_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/calendar/calendar_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/saved_events_screen.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/explore/presentation/explore_map_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/presentation/phone_import_screen.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience.dart';
import 'package:catch_dating_app/hosts/events/domain/organizer_moment.dart';
import 'package:catch_dating_app/hosts/events/presentation/moments/organizer_moments_screen.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_application_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_route_arguments.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_analytics_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_automations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_builder_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_preview_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_share_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_templates_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_workspace_state.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_operator_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_screen.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_messaging_setup_screen.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_focus_screen.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_screen.dart';
import 'package:catch_dating_app/hosts/work/presentation/host_work_screen.dart';
import 'package:catch_dating_app/launch_access/presentation/launch_access_application_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/start_welcome_route_screen.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_screen.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_arrivals_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_attendance_report_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_attention_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_create_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_dispatch_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_door_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_guest_desk_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_guests_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_hotel_desk_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_hotel_rooms_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_import_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_lodging_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_now_next_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_stakeholder_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_team_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_trips_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_work_screen.dart';
import 'package:catch_dating_app/programs/presentation/program_workspace_screen.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/routing/host_legacy_redirects.dart';
import 'package:catch_dating_app/routing/host_navigation_workspace.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_dating_app/safety/presentation/messaging_permissions_screen.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/form_profile_review_screen.dart';
import 'package:catch_dating_app/user_profile/presentation/form_profiles_screen.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'route_contract.dart';

part 'detail_route_pages.dart';
part 'go_router.g.dart';
part 'host_route_extras.dart';
part 'host_inbox_route.dart';
part 'host_response_review_routes.dart';
part 'route_destinations.dart';

@visibleForTesting
String hostProgramsLegacyRedirect(Uri uri) =>
    uri.replace(path: Routes.hostEventsScreen.path).toString();

@visibleForTesting
HostClubsScreen hostOrganizerScreenForUri(Uri uri) => HostClubsScreen(
  initialClubId: uri.queryParameters['clubId'],
  initialExpandedEditField: uri.queryParameters['editField'],
  settingsRoute: Routes.values
      .where(
        (route) =>
            const {
              Routes.hostClubEventDefaultsScreen,
              Routes.hostClubLiveGuideScreen,
              Routes.hostClubTeamScreen,
              Routes.hostClubPaymentsScreen,
            }.contains(route) &&
            route.name == uri.queryParameters['setting'],
      )
      .firstOrNull,
  initialTab: HostClubTab.values.firstWhere(
    (tab) => tab.name == uri.queryParameters['tab'],
    orElse: () => HostClubTab.edit,
  ),
);

@visibleForTesting
Widget hostAudienceScreenForUri(Uri uri, {String? initialContactDisplayName}) {
  final view = hostAudienceViewFromName(uri.queryParameters['view']);
  return switch (view) {
    HostAudienceView.forms || HostAudienceView.responses => HostFormsScreen(
      initialOrganizerId: uri.queryParameters['organizerId'],
      initialResponses: view == HostAudienceView.responses,
      initialFormId: uri.queryParameters['formId'],
      initialContactId: uri.queryParameters['contactId'],
    ),
    HostAudienceView.people ||
    HostAudienceView.audiences => HostCustomersScreen(
      initialOrganizerId: uri.queryParameters['organizerId'],
      initialView: view,
      initialContactId: uri.queryParameters['contactId'],
      initialContactDisplayName: initialContactDisplayName,
      responseId: uri.queryParameters['responseId'],
      applicationId: uri.queryParameters['applicationId'],
    ),
  };
}

GoRouter _buildGoRouter(Ref ref, {required bool isHostApp}) {
  final notifier = _RouterRefreshNotifier();
  final analytics = ref.read(appAnalyticsProvider);
  final keys = _RouterNavigatorKeys();

  _wireRouterRefresh(ref, notifier, isHostApp: isHostApp);

  final router = GoRouter(
    navigatorKey: keys.root,
    initialLocation: ref.watch(initialAppLocationProvider),
    refreshListenable: notifier,
    observers: [AnalyticsRouteObserver(analytics)],
    redirect: (context, state) =>
        _appRedirectFor(ref, state, isHostApp: isHostApp),
    routes: [
      GoRoute(
        path: Routes.loadingScreen.path,
        name: Routes.loadingScreen.name,
        builder: (context, state) => const _RouteLoadingScreen(),
      ),
      GoRoute(
        path: Routes.startScreen.path,
        name: Routes.startScreen.name,
        builder: (context, state) => const StartWelcomeRouteScreen(),
      ),
      GoRoute(
        path: Routes.authScreen.path,
        name: Routes.authScreen.name,
        builder: (context, state) => const AuthScreen(),
      ),
      if (!isHostApp) ...[
        GoRoute(
          path: Routes.crossPathsInvitationScreen.path,
          name: Routes.crossPathsInvitationScreen.name,
          builder: (context, state) => CrossPathsInvitationScreen(
            invitationId: state.pathParameters['invitationId']!,
          ),
        ),
        GoRoute(
          path: Routes.onboardingScreen.path,
          name: Routes.onboardingScreen.name,
          builder: (context, state) => OnboardingScreen(
            profileCompletionOnly:
                state.uri.queryParameters[_onboardingIntentQueryParam] ==
                _completeProfileIntent,
            runPreferencesOnly:
                state.uri.queryParameters[_onboardingIntentQueryParam] ==
                _completeRunPreferencesIntent,
          ),
        ),
        GoRoute(
          path: Routes.calendarScreen.path,
          name: Routes.calendarScreen.name,
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: Routes.calendarEventDetailScreen.path,
          name: Routes.calendarEventDetailScreen.name,
          builder: (context, state) => _eventDetailScreen(state),
        ),
        GoRoute(
          path: Routes.savedEventsScreen.path,
          name: Routes.savedEventsScreen.name,
          builder: (context, state) => const SavedEventsScreen(),
        ),
        GoRoute(
          path: Routes.savedEventDetailScreen.path,
          name: Routes.savedEventDetailScreen.name,
          builder: (context, state) => _eventDetailScreen(state),
        ),
        GoRoute(
          path: Routes.filtersScreen.path,
          name: Routes.filtersScreen.name,
          builder: (context, state) => const FiltersScreen(),
        ),
        GoRoute(
          path: Routes.swipeHubScreen.path,
          name: Routes.swipeHubScreen.name,
          redirect: (context, state) => Routes.dashboardScreen.path,
        ),
        GoRoute(
          path: Routes.dashboardEventDetailScreen.path,
          name: Routes.dashboardEventDetailScreen.name,
          builder: (context, state) => _eventDetailScreen(state),
        ),
        GoRoute(
          path: Routes.paymentHistoryScreen.path,
          name: Routes.paymentHistoryScreen.name,
          builder: (context, state) => const PaymentHistoryScreen(),
        ),
        GoRoute(
          path: Routes.reviewsHistoryScreen.path,
          name: Routes.reviewsHistoryScreen.name,
          builder: (context, state) => const ReviewsHistoryScreen(),
        ),
        GoRoute(
          path: Routes.paymentConfirmationScreen.path,
          name: Routes.paymentConfirmationScreen.name,
          builder: (context, state) => PaymentConfirmationScreen(
            data: state.extra! as PaymentConfirmationData,
          ),
        ),
      ],
      GoRoute(
        path: Routes.eventProfileSharingScreen.path,
        name: Routes.eventProfileSharingScreen.name,
        builder: (context, state) =>
            EventProfileScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: Routes.eventChatParticipantsScreen.path,
        name: Routes.eventChatParticipantsScreen.name,
        builder: (context, state) => EventChatParticipantsScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: Routes.eventParticipantProfileScreen.path,
        name: Routes.eventParticipantProfileScreen.name,
        builder: (context, state) => EventProfileScreen(
          eventId: state.pathParameters['eventId']!,
          participantUid: state.pathParameters['participantUid']!,
        ),
      ),
      GoRoute(
        path: Routes.eventChatScreen.path,
        name: Routes.eventChatScreen.name,
        builder: (context, state) =>
            EventChatScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: Routes.eventLocationMapScreen.path,
        name: Routes.eventLocationMapScreen.name,
        builder: (context, state) => EventLocationMapRouteScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      if (!isHostApp) ...[
        GoRoute(
          path: Routes.settingsScreen.path,
          name: Routes.settingsScreen.name,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: Routes.messagingPermissionsScreen.path,
          name: Routes.messagingPermissionsScreen.name,
          builder: (context, state) => const MessagingPermissionsScreen(),
        ),
        GoRoute(
          path: Routes.launchAccessScreen.path,
          name: Routes.launchAccessScreen.name,
          builder: (context, state) => const LaunchAccessApplicationScreen(),
        ),
        GoRoute(
          path: Routes.publicProfileScreen.path,
          name: Routes.publicProfileScreen.name,
          builder: (context, state) => PublicProfileScreen(
            uid: state.pathParameters['uid']!,
            initialProfile: switch (state.extra) {
              final PublicProfile p => p,
              _ => null,
            },
          ),
        ),
      ],
      if (isHostApp)
        _hostShellRoute(analytics, keys)
      else
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            // ── Branch 0: Home / Dashboard ───────────────────────────────
            StatefulShellBranch(
              navigatorKey: keys.dashboard,
              observers: [AnalyticsRouteObserver(analytics)],
              routes: [
                GoRoute(
                  path: Routes.dashboardScreen.path,
                  name: Routes.dashboardScreen.name,
                  builder: (context, state) => const DashboardScreen(),
                  routes: [
                    GoRoute(
                      path: 'notifications',
                      name: Routes.notificationsScreen.name,
                      parentNavigatorKey: keys.root,
                      builder: (context, state) => const ActivityScreen(),
                    ),
                    GoRoute(
                      path: 'catches/:eventId/recap',
                      name: Routes.eventRecapScreen.name,
                      parentNavigatorKey: keys.root,
                      builder: (context, state) => EventRecapScreen(
                        eventId: state.pathParameters['eventId']!,
                      ),
                    ),
                    GoRoute(
                      path: 'catches/:eventId',
                      name: Routes.swipeEventScreen.name,
                      parentNavigatorKey: keys.root,
                      builder: (context, state) => SwipeScreen(
                        eventId: state.pathParameters['eventId']!,
                        vibeIds: switch (state.extra) {
                          final Set<String> ids => ids,
                          _ => const {},
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Branch 1: Explore ────────────────────────────────────────
            StatefulShellBranch(
              navigatorKey: keys.explore,
              observers: [AnalyticsRouteObserver(analytics)],
              routes: [
                GoRoute(
                  path: Routes.exploreScreen.path,
                  name: Routes.exploreScreen.name,
                  builder: (context, state) => const ExploreScreen(),
                  routes: [
                    GoRoute(
                      path: 'map',
                      name: Routes.exploreMapScreen.name,
                      parentNavigatorKey: keys.root,
                      pageBuilder: _exploreMapPage,
                    ),
                    GoRoute(
                      path: ':clubId',
                      name: Routes.clubDetailScreen.name,
                      parentNavigatorKey: keys.root,
                      pageBuilder: _clubDetailPage,
                      routes: [
                        GoRoute(
                          path: 'events/:eventId',
                          name: Routes.eventDetailScreen.name,
                          parentNavigatorKey: keys.root,
                          pageBuilder: _eventDetailPage,
                          routes: [
                            GoRoute(
                              path: 'companion',
                              name: Routes.eventSuccessCompanionScreen.name,
                              parentNavigatorKey: keys.root,
                              builder: (context, state) =>
                                  EventSuccessCompanionRouteScreen(
                                    clubId: state.pathParameters['clubId']!,
                                    eventId: state.pathParameters['eventId']!,
                                    initialEvent: _routeEventExtra(state),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // ── Branch 2: Chats ──────────────────────────────────────────
            StatefulShellBranch(
              navigatorKey: keys.chats,
              observers: [AnalyticsRouteObserver(analytics)],
              routes: [
                GoRoute(
                  path: Routes.matchesListScreen.path,
                  name: Routes.matchesListScreen.name,
                  builder: (context, state) => const ChatsListScreen(),
                  routes: [
                    GoRoute(
                      path: ':matchId',
                      name: Routes.chatScreen.name,
                      parentNavigatorKey: keys.root,
                      builder: (context, state) => ChatScreen(
                        matchId: state.pathParameters['matchId']!,
                        otherProfile: switch (state.extra) {
                          final PublicProfile p => p,
                          _ => null,
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Branch 3: Profile ────────────────────────────────────────
            StatefulShellBranch(
              navigatorKey: keys.profile,
              observers: [AnalyticsRouteObserver(analytics)],
              routes: [
                GoRoute(
                  path: Routes.profileScreen.path,
                  name: Routes.profileScreen.name,
                  builder: (context, state) => const ProfileScreen(),
                  routes: [
                    GoRoute(
                      path: 'forms',
                      name: Routes.formProfilesScreen.name,
                      builder: (context, state) => const FormProfilesScreen(),
                      routes: [
                        GoRoute(
                          path: ':responseId',
                          name: Routes.formProfileReviewScreen.name,
                          builder: (context, state) => FormProfileReviewScreen(
                            responseId: state.pathParameters['responseId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

List<RouteBase> _hostWorkspaceDestinationRoutes() {
  return [
    GoRoute(
      path: Routes.hostHomeScreen.path,
      name: Routes.hostHomeScreen.name,
      redirect: (context, state) => hostHomeLegacyRedirect(),
    ),
    GoRoute(
      path: Routes.hostOperatorEventScreen.path,
      name: Routes.hostOperatorEventScreen.name,
      redirect: _operatorEventUriRedirect,
    ),
    GoRoute(
      path: Routes.hostWorkScreen.path,
      name: Routes.hostWorkScreen.name,
      builder: (context, state) => const HostWorkScreen(),
    ),
    GoRoute(
      path: Routes.hostWorkEventScreen.path,
      name: Routes.hostWorkEventScreen.name,
      builder: (context, state) =>
          HostEventOperatorScreen(eventId: state.pathParameters['eventId']!),
    ),
    GoRoute(
      path: Routes.hostWorkProgramScreen.path,
      name: Routes.hostWorkProgramScreen.name,
      builder: (context, state) => ProgramWorkScreen(
        programId: state.pathParameters['programId']!,
        inviteId: state.uri.queryParameters['invite'],
      ),
    ),
    GoRoute(
      path: Routes.hostWorkArrivalsScreen.path,
      name: Routes.hostWorkArrivalsScreen.name,
      builder: (context, state) => ProgramArrivalsScreen(
        programId: state.pathParameters['programId']!,
        pickupPointId: state.pathParameters['pickupPointId'],
        stationLabel: state.uri.queryParameters['station'] ?? 'Arrivals',
      ),
    ),
    GoRoute(
      path: Routes.hostWorkDispatchScreen.path,
      name: Routes.hostWorkDispatchScreen.name,
      builder: (context, state) => ProgramDispatchScreen(
        programId: state.pathParameters['programId']!,
        pickupPointId: state.pathParameters['pickupPointId']!,
        stationLabel: state.uri.queryParameters['station'] ?? 'Dispatch',
      ),
    ),
    GoRoute(
      path: Routes.hostWorkHotelScreen.path,
      name: Routes.hostWorkHotelScreen.name,
      builder: (context, state) => ProgramHotelDeskScreen(
        programId: state.pathParameters['programId']!,
        hotelId: state.pathParameters['hotelId']!,
      ),
    ),
    GoRoute(
      path: Routes.hostWorkHotelRoomsScreen.path,
      name: Routes.hostWorkHotelRoomsScreen.name,
      builder: (context, state) => ProgramHotelRoomsScreen(
        programId: state.pathParameters['programId']!,
        hotelId: state.pathParameters['hotelId']!,
      ),
    ),
    GoRoute(
      path: Routes.hostWorkDoorScreen.path,
      name: Routes.hostWorkDoorScreen.name,
      builder: (context, state) => ProgramFunctionDoorScreen(
        programId: state.pathParameters['programId']!,
        functionId: state.pathParameters['functionId']!,
        functionName: state.uri.queryParameters['function'],
      ),
    ),
    GoRoute(
      path: Routes.hostWorkNowScreen.path,
      name: Routes.hostWorkNowScreen.name,
      builder: (context, state) =>
          ProgramNowNextScreen(programId: state.pathParameters['programId']!),
    ),
    GoRoute(
      path: Routes.hostWorkAttentionScreen.path,
      name: Routes.hostWorkAttentionScreen.name,
      builder: (context, state) =>
          ProgramAttentionScreen(programId: state.pathParameters['programId']!),
    ),
    GoRoute(
      path: Routes.hostWorkTripsScreen.path,
      name: Routes.hostWorkTripsScreen.name,
      builder: (context, state) =>
          ProgramTripsScreen(programId: state.pathParameters['programId']!),
    ),
    GoRoute(
      path: Routes.hostWorkGuestsScreen.path,
      name: Routes.hostWorkGuestsScreen.name,
      builder: (context, state) =>
          ProgramGuestDeskScreen(programId: state.pathParameters['programId']!),
    ),
    GoRoute(
      path: Routes.hostWorkPhoneImportScreen.path,
      name: Routes.hostWorkPhoneImportScreen.name,
      builder: (context, state) =>
          PhoneImportScreen(programId: state.pathParameters['programId']!),
    ),
    GoRoute(
      path: Routes.hostWorkImportScreen.path,
      name: Routes.hostWorkImportScreen.name,
      builder: (context, state) =>
          ProgramImportScreen(programId: state.pathParameters['programId']!),
    ),
    GoRoute(
      path: Routes.hostWorkAttendanceReportScreen.path,
      name: Routes.hostWorkAttendanceReportScreen.name,
      builder: (context, state) => ProgramAttendanceReportScreen(
        programId: state.pathParameters['programId']!,
      ),
    ),
    GoRoute(
      path: Routes.hostWorkCountsScreen.path,
      name: Routes.hostWorkCountsScreen.name,
      builder: (context, state) => ProgramStakeholderScreen(
        programId: state.pathParameters['programId']!,
      ),
    ),
    GoRoute(
      path: Routes.hostProgramsScreen.path,
      name: Routes.hostProgramsScreen.name,
      redirect: (context, state) => hostProgramsLegacyRedirect(state.uri),
    ),
    GoRoute(
      path: Routes.hostCreateProgramScreen.path,
      name: Routes.hostCreateProgramScreen.name,
      builder: (context, state) =>
          ProgramCreateScreen(organizerId: state.pathParameters['clubId']!),
    ),
    GoRoute(
      path: Routes.hostProgramLodgingScreen.path,
      name: Routes.hostProgramLodgingScreen.name,
      builder: (context, state) =>
          ProgramLodgingScreen(programId: state.pathParameters['programId']!),
    ),
    GoRoute(
      path: Routes.hostProgramWorkspaceScreen.path,
      name: Routes.hostProgramWorkspaceScreen.name,
      builder: (context, state) =>
          ProgramWorkspaceScreen(programId: state.pathParameters['programId']!),
      routes: [
        GoRoute(
          path: 'guests',
          name: Routes.hostProgramGuestsScreen.name,
          builder: (context, state) => ProgramGuestsScreen(
            programId: state.pathParameters['programId']!,
          ),
        ),
        GoRoute(
          path: 'team',
          name: Routes.hostProgramTeamScreen.name,
          builder: (context, state) =>
              ProgramTeamScreen(programId: state.pathParameters['programId']!),
        ),
        GoRoute(
          path: 'import',
          name: Routes.hostProgramImportScreen.name,
          builder: (context, state) => ProgramImportScreen(
            programId: state.pathParameters['programId']!,
          ),
        ),
        GoRoute(
          path: 'moments',
          name: Routes.hostProgramMomentsScreen.name,
          builder: (context, state) => OrganizerMomentsScreen(
            scope: _programMomentScope(state),
            scopeTitle: state.uri.queryParameters['title'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: Routes.hostOrganizerMessagingScreen.path,
      name: Routes.hostOrganizerMessagingScreen.name,
      builder: (context, state) =>
          HostMessagingSetupScreen(clubId: state.pathParameters['clubId']!),
    ),
    GoRoute(
      path: Routes.hostClubEventDefaultsScreen.path,
      name: Routes.hostClubEventDefaultsScreen.name,
      redirect: (context, state) => hostOrganizerWorkspaceRedirect(
        state,
        Routes.hostClubEventDefaultsScreen,
      ),
    ),
    GoRoute(
      path: Routes.hostClubLiveGuideScreen.path,
      name: Routes.hostClubLiveGuideScreen.name,
      redirect: (context, state) =>
          hostOrganizerWorkspaceRedirect(state, Routes.hostClubLiveGuideScreen),
    ),
    GoRoute(
      path: Routes.hostClubTeamScreen.path,
      name: Routes.hostClubTeamScreen.name,
      redirect: (context, state) =>
          hostOrganizerWorkspaceRedirect(state, Routes.hostClubTeamScreen),
    ),
    GoRoute(
      path: Routes.hostClubPaymentsScreen.path,
      name: Routes.hostClubPaymentsScreen.name,
      redirect: (context, state) =>
          hostOrganizerWorkspaceRedirect(state, Routes.hostClubPaymentsScreen),
    ),
    GoRoute(
      path: Routes.hostClubsScreen.path,
      name: Routes.hostClubsScreen.name,
      redirect: (context, state) => hostOrganizerIndexRedirect(state.uri),
      routes: [
        GoRoute(
          path: 'create-organizer',
          name: Routes.hostCreateClubScreen.name,
          builder: (context, state) => const HostCreateClubScreen(),
        ),
        GoRoute(
          path: ':clubId',
          name: Routes.hostClubDetailScreen.name,
          builder: (context, state) => _clubDetailScreen(state),
          routes: [
            GoRoute(
              path: 'create-event',
              name: Routes.hostCreateEventScreen.name,
              builder: (context, state) {
                final extra = state.extra;
                return HostCreateEventRouteScreen(
                  clubId: state.pathParameters['clubId']!,
                  initialClub: switch (extra) {
                    final HostCreateEventRouteArguments arguments =>
                      arguments.initialClub,
                    final Club club => club,
                    _ => null,
                  },
                  initialPrefill: switch (extra) {
                    final HostCreateEventRouteArguments arguments =>
                      arguments.initialPrefill,
                    _ => null,
                  },
                  initialDraft: extra is HostCreateEventRouteArguments
                      ? extra.initialDraft
                      : null,

                  initialSavedEventId: extra is HostCreateEventRouteArguments
                      ? extra.initialSavedEventId
                      : null,
                  externalBookingMode: switch (extra) {
                    final HostCreateEventRouteArguments arguments =>
                      arguments.externalBookingMode,
                    _ => false,
                  },
                  initialRosterImportPlan: switch (extra) {
                    final HostCreateEventRouteArguments arguments =>
                      arguments.initialRosterImportPlan,
                    _ => null,
                  },
                  promptForDrafts: extra is HostCreateEventRouteArguments
                      ? extra.promptForDrafts
                      : true,
                  returnToResponsesOnSave:
                      extra is HostCreateEventRouteArguments
                      ? extra.returnToResponsesOnSave
                      : false,
                );
              },
            ),
            GoRoute(
              path: 'rehearsals/new',
              name: Routes.hostEventRehearsalStartScreen.name,
              builder: (context, state) => HostEventRehearsalStartScreen(
                clubId: state.pathParameters['clubId']!,
                sourceEventId: state.uri.queryParameters['eventId'],
                startFromOrganizerDefaults:
                    state.uri.queryParameters['source'] == 'custom',
              ),
            ),
            GoRoute(
              path: 'rehearsals/:sessionId',
              name: Routes.hostEventRehearsalScreen.name,
              builder: (context, state) => HostEventRehearsalScreen(
                clubId: state.pathParameters['clubId']!,
                sessionId: state.pathParameters['sessionId']!,
              ),
            ),
            GoRoute(
              path: 'events/:eventId',
              name: Routes.hostAppEventDetailScreen.name,
              builder: (context, state) => _eventDetailScreen(state),
            ),
            GoRoute(
              path: 'events/:eventId/manage',
              name: Routes.hostAppEventManageScreen.name,
              redirect: (context, state) => hostEventWorkspaceRedirect(state),
            ),
            GoRoute(
              path: 'events/:eventId/edit',
              name: Routes.hostAppEditEventScreen.name,
              builder: (context, state) => EditHostedEventRouteScreen(
                clubId: state.pathParameters['clubId']!,
                eventId: state.pathParameters['eventId']!,
                initialEvent: _routeEventExtra(state),
              ),
            ),
            GoRoute(
              path: 'events/:eventId/attendance',
              name: Routes.hostAppAttendanceSheet.name,
              builder: (context, state) => HostEventManageRouteScreen(
                clubId: state.pathParameters['clubId']!,
                eventId: state.pathParameters['eventId']!,
                initialEvent: _routeEventExtra(state),
                initialSection: HostEventManageSection.live,
              ),
            ),
            GoRoute(
              path: 'events/:eventId/success',
              name: Routes.hostAppEventSuccessScreen.name,
              builder: (context, state) => HostEventManageRouteScreen(
                clubId: state.pathParameters['clubId']!,
                eventId: state.pathParameters['eventId']!,
                initialEvent: _routeEventExtra(state),
                initialSection: _hostManageSectionFromState(state),
              ),
            ),
            GoRoute(
              path: 'events/:eventId/moments',
              name: Routes.hostAppEventMomentsScreen.name,
              builder: (context, state) => OrganizerMomentsScreen(
                scope: _eventMomentScope(state),
                scopeTitle: _routeEventExtra(state)?.title,
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}

GoRoute _hostAudienceRoute() {
  return GoRoute(
    path: Routes.hostAudienceScreen.path,
    name: Routes.hostAudienceScreen.name,
    builder: (context, state) => hostAudienceScreenForUri(
      state.uri,
      initialContactDisplayName: _routeContactNameExtra(state),
    ),
    routes: [
      GoRoute(
        path: 'applications',
        name: Routes.hostApplicationsScreen.name,
        redirect: (context, state) => hostApplicationsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: 'applications/:applicationId',
        name: Routes.hostApplicationDetailScreen.name,
        builder: (context, state) => HostApplicationDetailScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          applicationId: state.pathParameters['applicationId']!,
          queue: _responseReviewQueue(state.extra),
        ),
      ),
      GoRoute(
        path: 'people/new',
        name: Routes.hostAddCustomerScreen.name,
        builder: (context, state) => HostAddCustomerScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
        ),
      ),
      GoRoute(
        path: 'audiences/new',
        name: Routes.hostCreateSavedAudienceScreen.name,
        builder: (context, state) => HostSavedAudienceEditorScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
        ),
      ),
      GoRoute(
        path: 'audiences/:audienceId',
        name: Routes.hostSavedAudienceDetailScreen.name,
        builder: (context, state) => HostSavedAudienceEditorScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          audienceId: state.pathParameters['audienceId'],
          initialAudience: _routeAudienceExtra(state),
        ),
      ),
      GoRoute(
        path: 'forms/new',
        name: Routes.hostFormTemplatesScreen.name,
        builder: (context, state) => HostFormTemplatesScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
        ),
      ),
      GoRoute(
        path: 'responses/:responseId',
        name: Routes.hostFormResponseDetailScreen.name,
        builder: (context, state) => HostFormResponseDetailScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          responseId: state.pathParameters['responseId']!,
          queue: _responseReviewQueue(state.extra),
        ),
      ),
      GoRoute(
        path: 'forms/:formId/preview',
        name: Routes.hostFormPreviewScreen.name,
        builder: (context, state) => HostFormPreviewScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
        ),
      ),
      GoRoute(
        path: 'forms/:formId/share',
        name: Routes.hostFormShareScreen.name,
        builder: (context, state) => HostFormShareScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
        ),
      ),
      GoRoute(
        path: 'forms/:formId/analytics',
        name: Routes.hostFormAnalyticsScreen.name,
        builder: (context, state) => HostFormAnalyticsScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
        ),
      ),
      GoRoute(
        path: 'automations',
        name: Routes.hostAudienceAutomationsScreen.name,
        builder: (context, state) => HostFormAutomationsScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
        ),
      ),
      GoRoute(
        path: 'forms/:formId/automations',
        name: Routes.hostFormAutomationsScreen.name,
        builder: (context, state) => HostFormAutomationsScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
        ),
      ),
      GoRoute(
        path: 'forms/:formId',
        name: Routes.hostFormBuilderScreen.name,
        builder: (context, state) => HostFormBuilderScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
          initialView: hostFormViewFromQuery(state.uri.queryParameters['view']),
        ),
      ),
      GoRoute(
        path: 'people/:contactId',
        name: Routes.hostCustomerDetailScreen.name,
        builder: (context, state) => HostCustomerDetailScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          contactId: state.pathParameters['contactId']!,
          initialDisplayName: _routeContactNameExtra(state),
        ),
      ),
    ],
  );
}

GoRoute _hostCustomersLegacyRoute() {
  return GoRoute(
    path: Routes.hostCustomersLegacyScreen.path,
    name: Routes.hostCustomersLegacyScreen.name,
    redirect: (context, state) => hostCustomersLegacyRedirect(state.uri),
    routes: [
      GoRoute(path: 'new', redirect: _customersUriRedirect),
      GoRoute(path: 'audiences/new', redirect: _customersUriRedirect),
      GoRoute(path: 'audiences/:audienceId', redirect: _customersUriRedirect),
      GoRoute(path: 'applications', redirect: _customersUriRedirect),
      GoRoute(
        path: 'applications/:applicationId',
        redirect: _customersUriRedirect,
      ),
      GoRoute(path: ':contactId', redirect: _customersUriRedirect),
    ],
  );
}

GoRoute _hostFormsLegacyRoute() {
  return GoRoute(
    path: Routes.hostFormsLegacyScreen.path,
    name: Routes.hostFormsLegacyScreen.name,
    redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
    routes: [
      GoRoute(path: 'new', redirect: _formsUriRedirect),
      GoRoute(path: 'responses/:responseId', redirect: _formsUriRedirect),
      GoRoute(path: 'applications', redirect: _formsUriRedirect),
      GoRoute(path: 'applications/:applicationId', redirect: _formsUriRedirect),
      GoRoute(path: ':formId/preview', redirect: _formsUriRedirect),
      GoRoute(path: ':formId/share', redirect: _formsUriRedirect),
      GoRoute(path: ':formId/analytics', redirect: _formsUriRedirect),
      GoRoute(path: ':formId/automations', redirect: _formsUriRedirect),
      GoRoute(path: ':formId', redirect: _formsUriRedirect),
    ],
  );
}

// One route graph for all Host destinations. Utility routes are flattened into
// their owning branch, so a named push keeps its result contract while its
// content appears beside the existing index instead of covering the shell.
List<GoRoute> _hostWorkspaceRoutes(
  List<RouteBase> routes, [
  String prefix = '',
]) {
  return [
    for (final route in routes.whereType<GoRoute>()) ...[
      GoRoute(
        path: prefix.isEmpty ? route.path : '$prefix/${route.path}',
        name: route.name,
        redirect: route.redirect,
        builder: route.builder,
      ),
      ..._hostWorkspaceRoutes(
        route.routes,
        prefix.isEmpty ? route.path : '$prefix/${route.path}',
      ),
    ],
  ];
}

Routes _hostWorkspaceOwner(GoRoute route) {
  final path = route.path;
  if (path.startsWith('/host/audience') ||
      path.startsWith('/host/forms') ||
      path.startsWith('/host/customers')) {
    return Routes.hostAudienceScreen;
  }
  if (path.startsWith('/host/inbox')) return Routes.hostInboxScreen;
  if (path.startsWith('/host/today') ||
      path.startsWith('/host/work') ||
      path.contains('/rehearsals/') ||
      path == Routes.hostHomeScreen.path ||
      path.startsWith('/host/operator/')) {
    return Routes.hostTodayScreen;
  }
  if (path.startsWith('/host/programs') ||
      path.startsWith('/host/events') ||
      path.contains('/events/') ||
      path.endsWith('/create-event') ||
      path.endsWith('/create-program')) {
    return Routes.hostEventsScreen;
  }
  return Routes.hostOrganizerScreen;
}

GoRoute? _hostWorkspaceParent(GoRoute leaf, List<GoRoute> routes) {
  final parent = switch (leaf.name) {
    'hostAppEditEventScreen' ||
    'hostAppEventMomentsScreen' => Routes.hostAppEventManageScreen,
    'hostProgramLodgingScreen' ||
    'hostProgramGuestsScreen' ||
    'hostProgramTeamScreen' ||
    'hostProgramImportScreen' ||
    'hostProgramMomentsScreen' => Routes.hostProgramWorkspaceScreen,
    'hostFormPreviewScreen' ||
    'hostFormShareScreen' ||
    'hostFormAnalyticsScreen' ||
    'hostFormAutomationsScreen' => Routes.hostFormBuilderScreen,
    'hostWorkArrivalsScreen' ||
    'hostWorkDispatchScreen' ||
    'hostWorkHotelScreen' ||
    'hostWorkHotelRoomsScreen' ||
    'hostWorkDoorScreen' ||
    'hostWorkNowScreen' ||
    'hostWorkAttentionScreen' ||
    'hostWorkTripsScreen' ||
    'hostWorkGuestsScreen' ||
    'hostWorkImportScreen' ||
    'hostWorkPhoneImportScreen' ||
    'hostWorkAttendanceReportScreen' ||
    'hostWorkCountsScreen' => Routes.hostWorkProgramScreen,
    _ => null,
  };
  return routes.where((route) => route.name == parent?.name).firstOrNull;
}

String _hostWorkspaceRouteLocation(GoRoute route, GoRouterState state) => state
    .uri
    .replace(
      path: route.path.replaceAllMapped(
        RegExp(r':([A-Za-z][A-Za-z0-9]*)'),
        (match) => Uri.encodeComponent(state.pathParameters[match[1]]!),
      ),
    )
    .toString();

@visibleForTesting
StatefulShellRoute hostWorkspaceRouteGraph(AppAnalytics analytics) =>
    _hostShellRoute(analytics, _RouterNavigatorKeys());

StatefulShellRoute _hostShellRoute(
  AppAnalytics analytics,
  _RouterNavigatorKeys keys,
) {
  final audience = _hostAudienceRoute();
  final destinations = _hostWorkspaceRoutes([
    ..._hostWorkspaceDestinationRoutes(),
    ...audience.routes,
    _hostCustomersLegacyRoute(),
    _hostFormsLegacyRoute(),
    GoRoute(
      path: Routes.hostTodayFocusScreen.path,
      name: Routes.hostTodayFocusScreen.name,
      builder: (context, state) => HostTodayFocusScreen(
        organizerId: state.uri.queryParameters['organizerId'] ?? '',
      ),
    ),
    GoRoute(
      path: Routes.hostChatScreen.path,
      name: Routes.hostChatScreen.name,
      builder: (context, state) => ChatScreen(
        matchId: state.pathParameters['matchId']!,
        otherProfile: _routePublicProfileExtra(state),
      ),
    ),
  ]);
  // Audience children were authored relative to their former parent.
  final routes = [
    for (final route in destinations)
      if (route.path.startsWith('/'))
        route
      else
        GoRoute(
          path: '${Routes.hostAudienceScreen.path}/${route.path}',
          name: route.name,
          builder: route.builder,
          redirect: route.redirect,
        ),
  ];

  ShellRoute workspaceRoute(Routes root, String name) => ShellRoute(
    builder: (context, state, child) {
      final selected = routes
          .where((route) => route.path == state.fullPath)
          .firstOrNull;
      final parent = selected == null
          ? null
          : _hostWorkspaceParent(selected, routes);
      final uri = state.uri.replace(
        path: root.path,
        queryParameters: {
          ...state.uri.queryParameters,
          if (_routeOrganizerQueryId(state) == null &&
              state.pathParameters['clubId'] != null)
            'organizerId': state.pathParameters['clubId']!,
          if (root == Routes.hostAudienceScreen && selected != null)
            'view': selected.path.contains('/forms/')
                ? 'forms'
                : selected.path.contains('/responses/') ||
                      selected.path.contains('/applications/')
                ? 'responses'
                : selected.path.contains('/audiences/')
                ? 'audiences'
                : 'people',
        },
      );
      final index = switch (root) {
        Routes.hostTodayScreen => HostNavigationWorkspace.event(
          uri: uri,
          initialEvent: _routeEventExtra(state),
          index: HostTodayScreen(
            initialOrganizerId: uri.queryParameters['organizerId'],
          ),
        ),
        Routes.hostEventsScreen => HostNavigationWorkspace.event(
          uri: uri,
          initialEvent: _routeEventExtra(state),
          index: HostEventsScreen(
            initialOrganizerId: uri.queryParameters['organizerId'],
            initialProgramId: uri.queryParameters['programId'],
            initialProgramAnchor: state.extra is OrganizerProgramListAnchor
                ? state.extra as OrganizerProgramListAnchor
                : null,
          ),
        ),
        Routes.hostAudienceScreen => switch (hostAudienceViewFromName(
          uri.queryParameters['view'],
        )) {
          HostAudienceView.forms ||
          HostAudienceView.responses => HostNavigationWorkspace(
            uri: uri,
            index: hostAudienceScreenForUri(uri),
          ),
          _ => hostAudienceScreenForUri(
            uri,
            initialContactDisplayName: _routeContactNameExtra(state),
          ),
        },
        Routes.hostInboxScreen => hostInboxScreenForUri(
          uri,
          initialOrganizerId: _routeClubIdExtra(state),
        ),
        _ => hostOrganizerScreenForUri(uri),
      };
      return HostNavigationWorkspace.route(
        index: index,
        navigator: child,
        selectedRoute: selected?.name,
        ancestors: [
          if (parent?.name == Routes.hostAppEventManageScreen.name)
            CatchWorkspacePane(
              id: parent!.name!,
              child: CatchWorkspaceBackScope(
                onBack: () => context.go(hostWorkspaceIndexUri(uri).toString()),
                child: HostEventManageRouteScreen(
                  clubId: state.pathParameters['clubId']!,
                  eventId: state.pathParameters['eventId']!,
                  initialEvent: _routeEventExtra(state),
                ),
              ),
            ),
          if (parent?.builder != null)
            CatchWorkspacePane(
              id: parent!.name!,
              child: CatchWorkspaceBackScope(
                onBack: () => context.go(hostWorkspaceIndexUri(uri).toString()),
                child: parent.builder!(context, state),
              ),
            ),
        ],
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(
              parent == null
                  ? hostWorkspaceIndexUri(uri).toString()
                  : _hostWorkspaceRouteLocation(parent, state),
            );
          }
        },
      );
    },
    routes: [
      GoRoute(
        path: root.path,
        name: name,
        redirect: root == Routes.hostOrganizerScreen
            ? _organizerAudienceUriRedirect
            : null,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      ...routes.where((route) => _hostWorkspaceOwner(route) == root),
    ],
  );
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => HostAppShell(
      navigationShell: navigationShell,
      requestedOrganizerId:
          _routeOrganizerQueryId(state) ?? state.pathParameters['clubId'],
    ),
    branches: [
      StatefulShellBranch(
        navigatorKey: keys.hostToday,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          workspaceRoute(Routes.hostTodayScreen, Routes.hostTodayScreen.name),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: keys.hostEvents,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          workspaceRoute(Routes.hostEventsScreen, Routes.hostEventsScreen.name),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: keys.hostAudience,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          workspaceRoute(
            Routes.hostAudienceScreen,
            Routes.hostAudienceScreen.name,
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: keys.hostInbox,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          workspaceRoute(Routes.hostInboxScreen, Routes.hostInboxScreen.name),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: keys.hostOrganizer,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          workspaceRoute(
            Routes.hostOrganizerScreen,
            Routes.hostOrganizerScreen.name,
          ),
        ],
      ),
    ],
  );
}

EventDetailScreen _eventDetailScreen(GoRouterState state) => EventDetailScreen(
  clubId: state.pathParameters['clubId']!,
  eventId: state.pathParameters['eventId']!,
  inviteCode: state.uri.queryParameters['invite'],
  inviteLinkId:
      state.uri.queryParameters['il'] ??
      state.uri.queryParameters['inviteLinkId'],
  initialEvent: _eventDetailInitialEvent(state),
  presentationMode: _eventDetailPresentationMode(state),
  heroTag: _eventDetailHeroTag(state),
  attribution: _eventDetailAttribution(state),
);

ClubDetailScreen _clubDetailScreen(GoRouterState state) => ClubDetailScreen(
  clubId: state.pathParameters['clubId']!,
  initialClub: _clubDetailInitialClub(state),
);

class _RouteLoadingScreen extends StatelessWidget {
  const _RouteLoadingScreen();

  @override
  Widget build(BuildContext context) => CatchScaffold.standalone(
    backgroundColor: CatchTokens.of(context).bg,
    body: const CatchStateViewport.loading(accountForBottomOverlay: false),
  );
}
