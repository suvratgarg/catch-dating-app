import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chat_inbox_screen.dart'; // ChatsListScreen
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/host_app_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
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
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_screen.dart';
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
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_operator_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_screen.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_messaging_setup_screen.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_screen.dart';
import 'package:catch_dating_app/launch_access/presentation/launch_access_application_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/start_welcome_route_screen.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_screen.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'route_contract.dart';

part 'go_router.g.dart';

HostEventManageSection _hostManageSectionFromState(GoRouterState state) {
  return switch (state.uri.queryParameters['section']) {
    'guests' => HostEventManageSection.guests,
    'live' => HostEventManageSection.live,
    'report' => HostEventManageSection.report,
    _ => HostEventManageSection.setup,
  };
}

@visibleForTesting
HostClubsScreen hostOrganizerScreenForUri(Uri uri) {
  return HostClubsScreen(
    initialClubId: uri.queryParameters['clubId'],
    initialExpandedEditField: uri.queryParameters['editField'],
    initialTab: HostClubTab.values.firstWhere(
      (tab) => tab.name == uri.queryParameters['tab'],
      orElse: () => HostClubTab.edit,
    ),
  );
}

@visibleForTesting
HostInboxScreen hostInboxScreenForUri(Uri uri, {String? initialOrganizerId}) {
  final eventId = uri.queryParameters['eventId']?.trim();
  final general = uri.queryParameters['scope'] == 'general';
  final initialScope = eventId != null && eventId.isNotEmpty
      ? HostInboxScope.event(eventId)
      : general
      ? const HostInboxScope.general()
      : null;
  final initialWorkspace = HostMessagingWorkspace.values.firstWhere(
    (workspace) => workspace.name == uri.queryParameters['workspace'],
    orElse: () => HostMessagingWorkspace.inbox,
  );
  final requestedAudienceId = uri.queryParameters['audienceId']?.trim();
  return HostInboxScreen(
    initialScope: initialScope,
    initialWorkspace: initialWorkspace,
    initialSavedAudienceId:
        uri.queryParameters['compose'] == '1' &&
            requestedAudienceId != null &&
            requestedAudienceId.isNotEmpty
        ? requestedAudienceId
        : null,
    initialOrganizerId:
        initialOrganizerId ?? uri.queryParameters['organizerId'],
    initialThreadId: uri.queryParameters['threadId'],
  );
}

@visibleForTesting
Widget hostAudienceScreenForUri(Uri uri, {String? initialContactDisplayName}) {
  final view = hostAudienceViewFromName(uri.queryParameters['view']);
  return switch (view) {
    HostAudienceView.forms || HostAudienceView.responses => HostFormsScreen(
      initialOrganizerId: uri.queryParameters['organizerId'],
      initialResponses: view == HostAudienceView.responses,
      initialFormId: uri.queryParameters['formId'],
    ),
    HostAudienceView.people ||
    HostAudienceView.audiences => HostCustomersScreen(
      initialOrganizerId: uri.queryParameters['organizerId'],
      initialView: view,
      initialContactId: uri.queryParameters['contactId'],
      initialContactDisplayName: initialContactDisplayName,
    ),
  };
}

@visibleForTesting
String? hostOrganizerAudienceRedirect(Uri uri) {
  if (uri.queryParameters['tab'] != 'audience') return null;
  final clubId = uri.queryParameters['clubId']?.trim();
  return Uri(
    path: Routes.hostAudienceScreen.path,
    queryParameters: {
      if (clubId != null && clubId.isNotEmpty) 'organizerId': clubId,
    },
  ).toString();
}

@visibleForTesting
String hostApplicationsLegacyRedirect(Uri uri, {String? applicationId}) {
  final path = applicationId == null
      ? Routes.hostApplicationsScreen.path
      : Routes.hostApplicationDetailScreen.path.replaceFirst(
          ':applicationId',
          applicationId,
        );
  return uri.replace(path: path).toString();
}

@visibleForTesting
String hostCustomersLegacyRedirect(Uri uri) {
  final suffix = uri.path.substring(
    Routes.hostCustomersLegacyScreen.path.length,
  );
  final path = switch (suffix) {
    '' => Routes.hostAudienceScreen.path,
    '/new' => Routes.hostAddCustomerScreen.path,
    '/audiences/new' => Routes.hostCreateSavedAudienceScreen.path,
    final value when value.startsWith('/audiences/') =>
      '${Routes.hostAudienceScreen.path}$value',
    final value when value.startsWith('/applications') =>
      '${Routes.hostAudienceScreen.path}$value',
    final value => '${Routes.hostAudienceScreen.path}/people$value',
  };
  return uri.replace(path: path).toString();
}

@visibleForTesting
String hostFormsLegacyRedirect(Uri uri) {
  final suffix = uri.path.substring(Routes.hostFormsLegacyScreen.path.length);
  if (suffix.isEmpty) {
    final requestedView = uri.queryParameters['view'] == 'responses'
        ? HostAudienceView.responses
        : HostAudienceView.forms;
    return uri
        .replace(
          path: Routes.hostAudienceScreen.path,
          queryParameters: {...uri.queryParameters, 'view': requestedView.name},
        )
        .toString();
  }
  final path = switch (suffix) {
    '/new' => Routes.hostFormTemplatesScreen.path,
    final value when value.startsWith('/responses/') =>
      '${Routes.hostAudienceScreen.path}$value',
    final value when value.startsWith('/applications') =>
      '${Routes.hostAudienceScreen.path}$value',
    final value => '${Routes.hostAudienceScreen.path}/forms$value',
  };
  return uri.replace(path: path).toString();
}

Event? _eventDetailInitialEvent(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final initialEvent) => initialEvent,
    final Event event => event,
    _ => null,
  };
}

EventDetailRouteTransition _eventDetailTransition(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final transition) => transition,
    _ => EventDetailRouteTransition.platform,
  };
}

EventDetailPresentationMode _eventDetailPresentationMode(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final presentationMode) => presentationMode,
    _ => EventDetailPresentationMode.standard,
  };
}

Object? _eventDetailHeroTag(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final heroTag) => heroTag,
    _ => null,
  };
}

EventDetailAttribution? _eventDetailAttribution(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final attribution) => attribution,
    _ => null,
  };
}

EventDetailScreen _eventDetailScreen(GoRouterState state) {
  return EventDetailScreen(
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
}

Club? _clubDetailInitialClub(GoRouterState state) {
  return switch (state.extra) {
    final Club club => club,
    _ => null,
  };
}

ClubDetailScreen _clubDetailScreen(GoRouterState state) {
  return ClubDetailScreen(
    clubId: state.pathParameters['clubId']!,
    initialClub: _clubDetailInitialClub(state),
  );
}

Page<void> _clubDetailPage(BuildContext _, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: _clubDetailScreen(state),
    transitionDuration: CatchMotion.calendarScroll,
    reverseTransitionDuration: CatchMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CatchFadeScaleViewport(animation: animation, child: child),
  );
}

Page<void> _exploreMapPage(BuildContext _, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: const ExploreMapScreen(),
    transitionDuration: CatchMotion.slow,
    reverseTransitionDuration: CatchMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return CatchMapRevealViewport(animation: animation, child: child);
    },
  );
}

Page<void> _eventDetailPage(BuildContext _, GoRouterState state) {
  final child = _eventDetailScreen(state);
  if (_eventDetailTransition(state) == EventDetailRouteTransition.platform) {
    return MaterialPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
    );
  }

  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: CatchMotion.slow,
    reverseTransitionDuration: CatchMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CatchFadeScaleViewport(animation: animation, child: child),
  );
}

/// Navigator identity belongs to one [GoRouter] lifecycle. Keeping these keys
/// beside the provider instance prevents disposed test/app containers from
/// retaining navigators that block a fresh router from mounting.
class _RouterNavigatorKeys {
  final root = GlobalKey<NavigatorState>();
  final dashboard = GlobalKey<NavigatorState>();
  final explore = GlobalKey<NavigatorState>();
  final chats = GlobalKey<NavigatorState>();
  final profile = GlobalKey<NavigatorState>();
  final hostToday = GlobalKey<NavigatorState>();
  final hostEvents = GlobalKey<NavigatorState>();
  final hostAudience = GlobalKey<NavigatorState>();
  final hostInbox = GlobalKey<NavigatorState>();
  final hostOrganizer = GlobalKey<NavigatorState>();
}

const _fromQueryParam = 'from';
const _onboardingIntentQueryParam = 'intent';
const _completeProfileIntent = 'complete-profile';
const _completeRunPreferencesIntent = 'complete-run-preferences';
const _initialRouteOverride = String.fromEnvironment('CATCH_INITIAL_ROUTE');

@visibleForTesting
// keepalive: initial app location is startup routing state consumed by the
// app-wide keepAlive GoRouter provider.
@Riverpod(keepAlive: true)
String initialAppLocation(Ref ref) => _initialLocationFromPlatform();

// keepalive: GoRouter is the app-wide navigation graph and owns route refresh
// listeners for auth/update state.
@Riverpod(keepAlive: true)
GoRouter consumerGoRouter(Ref ref) => _buildGoRouter(ref, isHostApp: false);

// keepalive: Host navigation is the app-wide route graph for the Host root.
@Riverpod(keepAlive: true)
GoRouter hostGoRouter(Ref ref) => _buildGoRouter(ref, isHostApp: true);

/// Compatibility provider for test harnesses that intentionally exercise both
/// role graphs in one Dart process. Installable app roots use one of the two
/// compile-time role providers above.
// keepalive: compatibility tests need one stable role-selected router graph.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return _buildGoRouter(ref, isHostApp: AppConfig.appRole.isHost);
}

GoRouter _buildGoRouter(Ref ref, {required bool isHostApp}) {
  final notifier = _RouterRefreshNotifier();
  final analytics = ref.read(appAnalyticsProvider);
  final keys = _RouterNavigatorKeys();

  ref.listen(uidProvider, (_, _) => notifier.notify());
  ref.listen(authControllerProvider, (previous, next) {
    if (previous?.hasPendingVerification != next.hasPendingVerification) {
      notifier.notify();
    }
  });
  if (!isHostApp) {
    ref.listen(watchUserProfileProvider, (_, _) => notifier.notify());
  }

  ref.onDispose(notifier.dispose);

  final router = GoRouter(
    navigatorKey: keys.root,
    initialLocation: ref.watch(initialAppLocationProvider),
    refreshListenable: notifier,
    observers: [AnalyticsRouteObserver(analytics)],
    redirect: (context, state) {
      return appRedirect(
        uidAsync: ref.read(uidProvider),
        userProfileAsync: isHostApp
            ? const AsyncData<UserProfile?>(null)
            : ref.read(watchUserProfileProvider),
        hasPendingAuthVerification: ref
            .read(authControllerProvider)
            .hasPendingVerification,
        matchedLocation: state.matchedLocation,
        uri: state.uri,
      );
    },
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
          builder: (context, state) {
            final data = state.extra! as PaymentConfirmationData;
            return PaymentConfirmationScreen(data: data);
          },
        ),
      ],
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
      if (isHostApp) ..._hostUtilityRoutes(keys.root),
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
                                    initialEvent: switch (state.extra) {
                                      final Event event => event,
                                      _ => null,
                                    },
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

class _RouteLoadingScreen extends StatelessWidget {
  const _RouteLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchScreenScaffold.standalone(
      backgroundColor: t.bg,
      body: CatchScreenBody(
        scrollable: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchSkeleton.text(width: CatchLayout.skeletonTextPageTitleWidth),
            const SizedBox(height: CatchSpacing.s5),
            const CatchSkeletonRows(
              leading: CatchSkeletonRowLeading.mediaTile,
              divided: true,
            ),
          ],
        ),
      ),
    );
  }
}

List<RouteBase> _hostUtilityRoutes(GlobalKey<NavigatorState> rootNavigatorKey) {
  return [
    GoRoute(
      path: Routes.hostHomeScreen.path,
      name: Routes.hostHomeScreen.name,
      redirect: (context, state) => hostHomeLegacyRedirect(),
    ),
    GoRoute(
      path: Routes.hostOperatorEventScreen.path,
      name: Routes.hostOperatorEventScreen.name,
      builder: (context, state) =>
          HostEventOperatorScreen(eventId: state.pathParameters['eventId']!),
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
      builder: (context, state) => HostClubEventDefaultsScreen(
        clubId: state.uri.queryParameters['clubId'] ?? '',
      ),
    ),
    GoRoute(
      path: Routes.hostClubLiveGuideScreen.path,
      name: Routes.hostClubLiveGuideScreen.name,
      builder: (context, state) => HostClubLiveGuideScreen(
        clubId: state.uri.queryParameters['clubId'] ?? '',
      ),
    ),
    GoRoute(
      path: Routes.hostClubTeamScreen.path,
      name: Routes.hostClubTeamScreen.name,
      builder: (context, state) =>
          HostClubTeamScreen(clubId: state.uri.queryParameters['clubId'] ?? ''),
    ),
    GoRoute(
      path: Routes.hostClubPaymentsScreen.path,
      name: Routes.hostClubPaymentsScreen.name,
      builder: (context, state) => HostClubPaymentsScreen(
        clubId: state.uri.queryParameters['clubId'] ?? '',
      ),
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
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: _clubDetailPage,
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
                  initialDraft: switch (extra) {
                    final HostCreateEventRouteArguments arguments =>
                      arguments.initialDraft,
                    _ => null,
                  },
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
                  promptForDrafts: switch (extra) {
                    final HostCreateEventRouteArguments arguments =>
                      arguments.promptForDrafts,
                    _ => true,
                  },
                );
              },
            ),
            GoRoute(
              path: 'rehearsals/new',
              name: Routes.hostEventRehearsalStartScreen.name,
              builder: (context, state) => HostEventRehearsalStartScreen(
                clubId: state.pathParameters['clubId']!,
                sourceEventId: state.uri.queryParameters['eventId'],
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
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: _eventDetailPage,
            ),
            GoRoute(
              path: 'events/:eventId/manage',
              name: Routes.hostAppEventManageScreen.name,
              builder: (context, state) => HostEventManageRouteScreen(
                clubId: state.pathParameters['clubId']!,
                eventId: state.pathParameters['eventId']!,
                initialEvent: switch (state.extra) {
                  final Event event => event,
                  _ => null,
                },
                initialSection: _hostManageSectionFromState(state),
              ),
            ),
            GoRoute(
              path: 'events/:eventId/edit',
              name: Routes.hostAppEditEventScreen.name,
              builder: (context, state) => EditHostedEventRouteScreen(
                clubId: state.pathParameters['clubId']!,
                eventId: state.pathParameters['eventId']!,
                initialEvent: switch (state.extra) {
                  final Event event => event,
                  _ => null,
                },
              ),
            ),
            GoRoute(
              path: 'events/:eventId/attendance',
              name: Routes.hostAppAttendanceSheet.name,
              builder: (context, state) => HostEventManageRouteScreen(
                clubId: state.pathParameters['clubId']!,
                eventId: state.pathParameters['eventId']!,
                initialEvent: switch (state.extra) {
                  final Event event => event,
                  _ => null,
                },
                initialSection: HostEventManageSection.live,
              ),
            ),
            GoRoute(
              path: 'events/:eventId/success',
              name: Routes.hostAppEventSuccessScreen.name,
              builder: (context, state) => HostEventManageRouteScreen(
                clubId: state.pathParameters['clubId']!,
                eventId: state.pathParameters['eventId']!,
                initialEvent: switch (state.extra) {
                  final Event event => event,
                  _ => null,
                },
                initialSection: _hostManageSectionFromState(state),
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}

@visibleForTesting
String hostHomeLegacyRedirect() => Routes.hostTodayScreen.path;

@visibleForTesting
String? hostOrganizerIndexRedirect(Uri uri) {
  if (uri.path != Routes.hostClubsScreen.path) return null;
  return Uri(
    path: Routes.hostOrganizerScreen.path,
    queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
  ).toString();
}

GoRoute _hostAudienceRoute(_RouterNavigatorKeys keys) {
  return GoRoute(
    path: Routes.hostAudienceScreen.path,
    name: Routes.hostAudienceScreen.name,
    builder: (context, state) => hostAudienceScreenForUri(
      state.uri,
      initialContactDisplayName: switch (state.extra) {
        HostCustomerDetailRouteArguments(:final displayName) => displayName,
        _ => null,
      },
    ),
    routes: [
      GoRoute(
        path: 'applications',
        name: Routes.hostApplicationsScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostApplicationsScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.uri.queryParameters['formId'],
          contactId: state.uri.queryParameters['contactId'],
        ),
        routes: [
          GoRoute(
            path: ':applicationId',
            name: Routes.hostApplicationDetailScreen.name,
            parentNavigatorKey: keys.root,
            builder: (context, state) => HostApplicationDetailScreen(
              organizerId: state.uri.queryParameters['organizerId'] ?? '',
              applicationId: state.pathParameters['applicationId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'people/new',
        name: Routes.hostAddCustomerScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostAddCustomerScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
        ),
      ),
      GoRoute(
        path: 'audiences/new',
        name: Routes.hostCreateSavedAudienceScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostSavedAudienceEditorScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
        ),
      ),
      GoRoute(
        path: 'audiences/:audienceId',
        name: Routes.hostSavedAudienceDetailScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostSavedAudienceEditorScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          audienceId: state.pathParameters['audienceId'],
          initialAudience: switch (state.extra) {
            HostSavedAudience audience => audience,
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: 'forms/new',
        name: Routes.hostFormTemplatesScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostFormTemplatesScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
        ),
      ),
      GoRoute(
        path: 'responses/:responseId',
        name: Routes.hostFormResponseDetailScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostFormResponseDetailScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          responseId: state.pathParameters['responseId']!,
        ),
      ),
      GoRoute(
        path: 'forms/:formId/preview',
        name: Routes.hostFormPreviewScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostFormPreviewScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
        ),
      ),
      GoRoute(
        path: 'forms/:formId/share',
        name: Routes.hostFormShareScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostFormShareScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
        ),
      ),
      GoRoute(
        path: 'forms/:formId/analytics',
        name: Routes.hostFormAnalyticsScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostFormAnalyticsScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
        ),
      ),
      GoRoute(
        path: 'automations',
        name: Routes.hostAudienceAutomationsScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostFormAutomationsScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
        ),
      ),
      GoRoute(
        path: 'forms/:formId/automations',
        name: Routes.hostFormAutomationsScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostFormAutomationsScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
        ),
      ),
      GoRoute(
        path: 'forms/:formId',
        name: Routes.hostFormBuilderScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostFormBuilderScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          formId: state.pathParameters['formId']!,
          initialView: HostFormWorkspaceView.values
              .where((view) => view.name == state.uri.queryParameters['view'])
              .firstOrNull,
        ),
      ),
      GoRoute(
        path: 'people/:contactId',
        name: Routes.hostCustomerDetailScreen.name,
        parentNavigatorKey: keys.root,
        builder: (context, state) => HostCustomerDetailScreen(
          organizerId: state.uri.queryParameters['organizerId'] ?? '',
          contactId: state.pathParameters['contactId']!,
          initialDisplayName: switch (state.extra) {
            HostCustomerDetailRouteArguments(:final displayName) => displayName,
            _ => null,
          },
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
      GoRoute(
        path: 'new',
        redirect: (context, state) => hostCustomersLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: 'audiences/new',
        redirect: (context, state) => hostCustomersLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: 'audiences/:audienceId',
        redirect: (context, state) => hostCustomersLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: 'applications',
        redirect: (context, state) => hostCustomersLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: 'applications/:applicationId',
        redirect: (context, state) => hostCustomersLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: ':contactId',
        redirect: (context, state) => hostCustomersLegacyRedirect(state.uri),
      ),
    ],
  );
}

GoRoute _hostFormsLegacyRoute() {
  return GoRoute(
    path: Routes.hostFormsLegacyScreen.path,
    name: Routes.hostFormsLegacyScreen.name,
    redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
    routes: [
      GoRoute(
        path: 'new',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: 'responses/:responseId',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: 'applications',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: 'applications/:applicationId',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: ':formId/preview',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: ':formId/share',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: ':formId/analytics',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: ':formId/automations',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
      GoRoute(
        path: ':formId',
        redirect: (context, state) => hostFormsLegacyRedirect(state.uri),
      ),
    ],
  );
}

StatefulShellRoute _hostShellRoute(
  AppAnalytics analytics,
  _RouterNavigatorKeys keys,
) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => HostAppShell(
      navigationShell: navigationShell,
      requestedOrganizerId:
          state.uri.queryParameters['organizerId'] ??
          state.uri.queryParameters['clubId'],
    ),
    branches: [
      StatefulShellBranch(
        navigatorKey: keys.hostToday,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          GoRoute(
            path: Routes.hostTodayScreen.path,
            name: Routes.hostTodayScreen.name,
            builder: (context, state) => HostTodayScreen(
              initialOrganizerId:
                  state.uri.queryParameters['organizerId'] ??
                  state.uri.queryParameters['clubId'],
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: keys.hostEvents,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          GoRoute(
            path: Routes.hostEventsScreen.path,
            name: Routes.hostEventsScreen.name,
            builder: (context, state) => HostEventsScreen(
              initialOrganizerId:
                  state.uri.queryParameters['organizerId'] ??
                  state.uri.queryParameters['clubId'],
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: keys.hostAudience,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          _hostAudienceRoute(keys),
          _hostCustomersLegacyRoute(),
          _hostFormsLegacyRoute(),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: keys.hostInbox,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          GoRoute(
            path: Routes.hostInboxScreen.path,
            name: Routes.hostInboxScreen.name,
            builder: (context, state) => hostInboxScreenForUri(
              state.uri,
              initialOrganizerId: switch (state.extra) {
                final Club club => club.id,
                _ => null,
              },
            ),
            routes: [
              GoRoute(
                path: ':matchId',
                name: Routes.hostChatScreen.name,
                parentNavigatorKey: keys.root,
                builder: (context, state) => ChatScreen(
                  matchId: state.pathParameters['matchId']!,
                  otherProfile: switch (state.extra) {
                    final PublicProfile profile => profile,
                    _ => null,
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: keys.hostOrganizer,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          GoRoute(
            path: Routes.hostOrganizerScreen.path,
            name: Routes.hostOrganizerScreen.name,
            redirect: (context, state) =>
                hostOrganizerAudienceRedirect(state.uri),
            builder: (context, state) => hostOrganizerScreenForUri(state.uri),
          ),
        ],
      ),
    ],
  );
}

String _initialLocationFromPlatform() {
  if (_initialRouteOverride.startsWith('/')) {
    return _initialRouteOverride;
  }

  final defaultRouteName =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  if (defaultRouteName.isNotEmpty &&
      defaultRouteName != Navigator.defaultRouteName) {
    if (AppConfig.appRole.isHost) {
      final routePath = Uri.tryParse(defaultRouteName)?.path;
      if (_isHostRoute(routePath) ||
          routePath == Routes.authScreen.path ||
          routePath == Routes.loadingScreen.path) {
        return defaultRouteName;
      }
      return Routes.hostTodayScreen.path;
    }
    return defaultRouteName;
  }
  return AppConfig.appRole.isHost
      ? Routes.hostTodayScreen.path
      : Routes.startScreen.path;
}

/// Routes that unauthenticated users may access for read-only browsing.
///
/// Keep this matcher explicit: nested account-only routes must not become public
/// merely because their parent organizer route is public.
@visibleForTesting
bool isGuestPublicRoute(String matchedLocation) {
  if (matchedLocation == Routes.startScreen.path) return true;
  if (matchedLocation == Routes.authScreen.path) return true;
  if (matchedLocation == Routes.exploreScreen.path) return true;
  if (matchedLocation == Routes.exploreMapScreen.path) return true;

  final segments = Uri.parse(matchedLocation).pathSegments;
  if (segments.length == 2 &&
      segments.first == 'organizers' &&
      segments.last != 'map') {
    return true;
  }

  if (segments.length == 4 &&
      segments[0] == 'organizers' &&
      segments[2] == 'events') {
    return true;
  }

  if (segments.length == 3 &&
      segments.first == 'events' &&
      segments.last == 'location') {
    return true;
  }

  return false;
}

String? appRedirect({
  required AsyncValue<String?> uidAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required bool hasPendingAuthVerification,
  required String matchedLocation,
  required Uri uri,
}) {
  final onLoading = matchedLocation == Routes.loadingScreen.path;
  final onStart = matchedLocation == Routes.startScreen.path;
  final onOnboarding = matchedLocation == Routes.onboardingScreen.path;
  final onAuth = matchedLocation == Routes.authScreen.path;
  final isHostApp = AppConfig.appRole.isHost;

  final isWaitingOnAuth = uidAsync.isLoading;
  final isWaitingOnProfile =
      !isHostApp &&
      uidAsync.hasValue &&
      uidAsync.value != null &&
      userProfileAsync.isLoading;

  if (isWaitingOnAuth || isWaitingOnProfile) {
    if (!isHostApp &&
        isGuestPublicRoute(matchedLocation) &&
        !_isTransientRoute(matchedLocation)) {
      return null;
    }
    if (onLoading) return null;
    return _locationWithFrom(
      Routes.loadingScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  final uid = uidAsync.value;
  final userProfile = userProfileAsync.value;

  if (uid == null) {
    if (isHostApp) {
      if (onAuth) return null;
      return _locationWithFrom(
        Routes.authScreen.path,
        from: _hostPendingDestination(
          uri: uri,
          matchedLocation: matchedLocation,
        ),
      );
    }

    if (hasPendingAuthVerification && !onAuth) {
      if (!isGuestPublicRoute(matchedLocation) ||
          _isTransientRoute(matchedLocation)) {
        return _locationWithFrom(
          Routes.authScreen.path,
          from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
        );
      }
    }
    if (isGuestPublicRoute(matchedLocation)) return null;
    return _locationWithFrom(
      Routes.startScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  if (isHostApp) {
    if (onLoading || onStart || onAuth || onOnboarding) {
      return _resumeDestination(uri);
    }
    return null;
  }

  final onProfileCompletionOnboarding =
      onOnboarding &&
      uri.queryParameters[_onboardingIntentQueryParam] ==
          _completeProfileIntent;
  final onRunPreferencesOnboarding =
      onOnboarding &&
      uri.queryParameters[_onboardingIntentQueryParam] ==
          _completeRunPreferencesIntent;
  final today = DateTime.now();

  if (userProfile == null || !userProfile.hasBookingReadyIdentityOn(today)) {
    if (onOnboarding) return null;
    // Public discovery remains readable for a signed-in viewer whose profile
    // is incomplete. Only the action that needs profile data is gated.
    if (!isHostApp &&
        isGuestPublicRoute(matchedLocation) &&
        !_isTransientRoute(matchedLocation)) {
      return null;
    }
    return _locationWithFrom(
      Routes.onboardingScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  if (onProfileCompletionOnboarding) {
    if (!userProfile.hasSocialReadyProfileOn(today)) return null;
    return _resumeDestination(uri);
  }

  if (onRunPreferencesOnboarding) {
    if (!userProfile.hasCurrentRunPreferences) return null;
    return _resumeDestination(uri);
  }

  if (_requiresSocialProfile(matchedLocation) &&
      !userProfile.hasSocialReadyProfileOn(today)) {
    return profileCompletionLocation(
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  if (onLoading || onStart || onAuth || onOnboarding) {
    return _resumeDestination(uri);
  }

  return null;
}

bool _requiresSocialProfile(String matchedLocation) {
  return matchedLocation == Routes.filtersScreen.path ||
      matchedLocation.startsWith('/catches/');
}

String? _pendingDestination({
  required Uri uri,
  required String matchedLocation,
}) {
  final from = _sanitizeFrom(uri.queryParameters[_fromQueryParam]);
  if (from != null) return from;
  if (_isTransientRoute(matchedLocation)) return null;
  return uri.toString();
}

String _resumeDestination(Uri uri) {
  final from = _sanitizeFrom(uri.queryParameters[_fromQueryParam]);
  final defaultPath = AppConfig.appRole.isHost
      ? Routes.hostTodayScreen.path
      : Routes.dashboardScreen.path;
  if (from == null) return defaultPath;

  final targetPath = Uri.parse(from).path;
  if (_isTransientRoute(targetPath)) {
    return defaultPath;
  }
  if (AppConfig.appRole.isHost && !_isHostRoute(targetPath)) {
    return defaultPath;
  }
  return from;
}

String? _hostPendingDestination({
  required Uri uri,
  required String matchedLocation,
}) {
  final from = _sanitizeFrom(uri.queryParameters[_fromQueryParam]);
  if (from != null && _isHostRoute(Uri.parse(from).path)) return from;
  if (_isTransientRoute(matchedLocation)) return null;
  if (_isHostRoute(uri.path)) return uri.toString();
  return null;
}

String _locationWithFrom(String path, {String? from}) {
  final safeFrom = _sanitizeFrom(from);
  if (safeFrom == null || Uri.parse(safeFrom).path == path) {
    return path;
  }
  return Uri(
    path: path,
    queryParameters: {_fromQueryParam: safeFrom},
  ).toString();
}

String profileCompletionLocation({String? from}) {
  final safeFrom = _sanitizeFrom(from);
  return Uri(
    path: Routes.onboardingScreen.path,
    queryParameters: {
      _onboardingIntentQueryParam: _completeProfileIntent,
      if (safeFrom != null &&
          Uri.parse(safeFrom).path != Routes.onboardingScreen.path)
        _fromQueryParam: safeFrom,
    },
  ).toString();
}

String runPreferencesCompletionLocation({String? from}) {
  final safeFrom = _sanitizeFrom(from);
  return Uri(
    path: Routes.onboardingScreen.path,
    queryParameters: {
      _onboardingIntentQueryParam: _completeRunPreferencesIntent,
      if (safeFrom != null &&
          Uri.parse(safeFrom).path != Routes.onboardingScreen.path)
        _fromQueryParam: safeFrom,
    },
  ).toString();
}

String? _sanitizeFrom(String? from) {
  if (from == null || from.isEmpty || !from.startsWith('/')) return null;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  return uri.toString();
}

bool _isTransientRoute(String path) =>
    path == Routes.loadingScreen.path ||
    path == Routes.startScreen.path ||
    path == Routes.authScreen.path ||
    path == Routes.onboardingScreen.path;

bool _isHostRoute(String? path) =>
    path == Routes.hostHomeScreen.path ||
    (path?.startsWith('${Routes.hostHomeScreen.path}/') ?? false);

// Minimal ChangeNotifier used as GoRouter's refreshListenable.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
