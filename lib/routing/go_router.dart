import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chat_inbox_screen.dart'; // ChatsListScreen
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/host_app_shell.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/event_policies/presentation/event_policy_lab_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_event_preview_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_lab_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_manual_qa_screen.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/calendar/calendar_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/saved_events_screen.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/explore/presentation/explore_map_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_screen.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_router.g.dart';

enum Routes {
  loadingScreen('/loading'),
  startScreen('/start'),
  authScreen('/auth'),
  onboardingScreen('/onboarding'),
  calendarScreen('/calendar'),
  calendarEventDetailScreen('/calendar/clubs/:clubId/events/:eventId'),
  savedEventsScreen('/saved-events'),
  savedEventDetailScreen('/saved-events/clubs/:clubId/events/:eventId'),
  filtersScreen('/filters'),
  dashboardEventDetailScreen('/dashboard/clubs/:clubId/events/:eventId'),
  eventLocationMapScreen('/events/:eventId/location'),
  // Home / Dashboard branch (index 0)
  dashboardScreen('/'),
  notificationsScreen('/notifications'),
  // Explore branch (index 1). The root path remains `/clubs` because club
  // detail and event detail deep links still live under that URL namespace.
  exploreScreen('/clubs'),
  exploreMapScreen('/clubs/map'),
  clubDetailScreen('/clubs/:clubId'),
  eventDetailScreen('/clubs/:clubId/events/:eventId'),
  eventSuccessCompanionScreen('/clubs/:clubId/events/:eventId/companion'),
  // Catch flow paths stay stable for push/deep links, but the hub tab is
  // retired and the immersive flow is parented under Home.
  catchesRedirect('/catches'),
  swipeEventScreen('/catches/:eventId'),
  eventRecapScreen('/catches/:eventId/recap'),
  // Chats branch (index 2)
  matchesListScreen('/chats'),
  chatScreen('/chats/:matchId'),
  // Profile branch (index 3)
  profileScreen('/you'),
  reviewsHistoryScreen('/you/reviews'),
  publicProfileScreen('/profiles/:uid'),
  settingsScreen('/settings'),
  paymentHistoryScreen('/payment-history'),
  paymentConfirmationScreen('/payment-confirmation'),
  hostHomeScreen('/host'),
  hostClubsScreen('/host/clubs'),
  hostClubDetailScreen('/host/clubs/:clubId'),
  hostCreateClubScreen('/host/clubs/create-club'),
  hostEditClubScreen('/host/clubs/:clubId/edit'),
  hostCreateEventScreen('/host/clubs/:clubId/create-event'),
  hostAppEventDetailScreen('/host/clubs/:clubId/events/:eventId'),
  hostAppEventManageScreen('/host/clubs/:clubId/events/:eventId/manage'),
  hostAppEditEventScreen('/host/clubs/:clubId/events/:eventId/edit'),
  hostAppAttendanceSheet('/host/clubs/:clubId/events/:eventId/attendance'),
  hostAppEventSuccessScreen('/host/clubs/:clubId/events/:eventId/success'),
  hostInboxScreen('/host/inbox'),
  hostChatScreen('/host/inbox/:matchId'),
  hostSettingsScreen('/host/settings'),
  hostProfileScreen('/host/settings/profile'),
  eventPolicyLabScreen('/dev/event-policy-lab'),
  eventSuccessLabScreen('/dev/event-success-lab'),
  eventSuccessManualQaScreen('/dev/event-success-manual-qa'),
  eventSuccessPreviewScreen('/dev/event-success-preview/:clubId/:eventId');

  const Routes(this.path);
  final String path;
}

const Set<Routes> _hostOnlyRoutes = {
  Routes.hostHomeScreen,
  Routes.hostClubsScreen,
  Routes.hostClubDetailScreen,
  Routes.hostCreateClubScreen,
  Routes.hostEditClubScreen,
  Routes.hostCreateEventScreen,
  Routes.hostAppEventDetailScreen,
  Routes.hostAppEventManageScreen,
  Routes.hostAppEditEventScreen,
  Routes.hostAppAttendanceSheet,
  Routes.hostAppEventSuccessScreen,
  Routes.hostInboxScreen,
  Routes.hostChatScreen,
  Routes.hostSettingsScreen,
  Routes.hostProfileScreen,
};

@visibleForTesting
bool routeAvailableForAppRole(Routes route, AppRole role) {
  if (_hostOnlyRoutes.contains(route)) return role.isHost;
  return true;
}

HostEventManageSection _hostManageSectionFromState(GoRouterState state) {
  return switch (state.uri.queryParameters['section']) {
    'live' => HostEventManageSection.live,
    'report' => HostEventManageSection.report,
    _ => HostEventManageSection.setup,
  };
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
    transitionDuration: CatchMotion.slow,
    reverseTransitionDuration: CatchMotion.base,
    transitionsBuilder: catchFadeScalePageTransition,
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
    transitionsBuilder: catchFadeScalePageTransition,
  );
}

// Navigator keys are file-level so they are created once for the app lifetime.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardShellKey = GlobalKey<NavigatorState>();
final _exploreShellKey = GlobalKey<NavigatorState>();
final _chatsShellKey = GlobalKey<NavigatorState>();
final _profileShellKey = GlobalKey<NavigatorState>();
final _hostEventsShellKey = GlobalKey<NavigatorState>();
final _hostClubsShellKey = GlobalKey<NavigatorState>();
final _hostInboxShellKey = GlobalKey<NavigatorState>();
final _hostSettingsShellKey = GlobalKey<NavigatorState>();

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
GoRouter goRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier();
  final analytics = ref.read(appAnalyticsProvider);

  ref.listen(uidProvider, (_, _) => notifier.notify());
  ref.listen(authControllerProvider, (previous, next) {
    if (previous?.hasPendingVerification != next.hasPendingVerification) {
      notifier.notify();
    }
  });
  if (!AppConfig.appRole.isHost) {
    ref.listen(watchUserProfileProvider, (_, _) => notifier.notify());
  }

  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ref.watch(initialAppLocationProvider),
    refreshListenable: notifier,
    observers: [AnalyticsRouteObserver(analytics)],
    redirect: (context, state) {
      return appRedirect(
        uidAsync: ref.read(uidProvider),
        userProfileAsync: AppConfig.appRole.isHost
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
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: Routes.authScreen.path,
        name: Routes.authScreen.name,
        builder: (context, state) => const AuthScreen(),
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
        path: Routes.eventLocationMapScreen.path,
        name: Routes.eventLocationMapScreen.name,
        builder: (context, state) => EventLocationMapRouteScreen(
          eventId: state.pathParameters['eventId']!,
        ),
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
      if (AppConfig.enableEventPolicyLab)
        GoRoute(
          path: Routes.eventPolicyLabScreen.path,
          name: Routes.eventPolicyLabScreen.name,
          builder: (context, state) => const EventPolicyLabScreen(),
        ),
      if (AppConfig.enableEventSuccessPreview)
        GoRoute(
          path: Routes.eventSuccessLabScreen.path,
          name: Routes.eventSuccessLabScreen.name,
          builder: (context, state) => const EventSuccessLabScreen(),
        ),
      if (AppConfig.enableEventSuccessPreview)
        GoRoute(
          path: Routes.eventSuccessManualQaScreen.path,
          name: Routes.eventSuccessManualQaScreen.name,
          builder: (context, state) => const EventSuccessManualQaScreen(),
        ),
      if (AppConfig.enableEventSuccessPreview)
        GoRoute(
          path: Routes.eventSuccessPreviewScreen.path,
          name: Routes.eventSuccessPreviewScreen.name,
          builder: (context, state) => EventSuccessEventPreviewRouteScreen(
            clubId: state.pathParameters['clubId']!,
            eventId: state.pathParameters['eventId']!,
            initialEvent: switch (state.extra) {
              final Event event => event,
              _ => null,
            },
          ),
        ),
      GoRoute(
        path: Routes.settingsScreen.path,
        name: Routes.settingsScreen.name,
        builder: (context, state) => const SettingsScreen(),
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
      if (routeAvailableForAppRole(Routes.hostHomeScreen, AppConfig.appRole))
        _hostShellRoute(analytics)
      else
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            // ── Branch 0: Home / Dashboard ───────────────────────────────
            StatefulShellBranch(
              navigatorKey: _dashboardShellKey,
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
                      builder: (context, state) => const ActivityScreen(),
                    ),
                    GoRoute(
                      path: 'catches',
                      name: Routes.catchesRedirect.name,
                      redirect: (context, state) => Routes.dashboardScreen.path,
                    ),
                    GoRoute(
                      path: 'catches/:eventId/recap',
                      name: Routes.eventRecapScreen.name,
                      builder: (context, state) => EventRecapScreen(
                        eventId: state.pathParameters['eventId']!,
                      ),
                    ),
                    GoRoute(
                      path: 'catches/:eventId',
                      name: Routes.swipeEventScreen.name,
                      parentNavigatorKey: _rootNavigatorKey,
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
              navigatorKey: _exploreShellKey,
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
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const ExploreMapScreen(),
                    ),
                    GoRoute(
                      path: ':clubId',
                      name: Routes.clubDetailScreen.name,
                      pageBuilder: _clubDetailPage,
                      routes: [
                        GoRoute(
                          path: 'events/:eventId',
                          name: Routes.eventDetailScreen.name,
                          pageBuilder: _eventDetailPage,
                          routes: [
                            GoRoute(
                              path: 'companion',
                              name: Routes.eventSuccessCompanionScreen.name,
                              parentNavigatorKey: _rootNavigatorKey,
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
              navigatorKey: _chatsShellKey,
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
              navigatorKey: _profileShellKey,
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
}

class _RouteLoadingScreen extends StatelessWidget {
  const _RouteLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: CatchInsets.pageBody,
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
      ),
    );
  }
}

StatefulShellRoute _hostShellRoute(AppAnalytics analytics) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        HostAppShell(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(
        navigatorKey: _hostEventsShellKey,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          GoRoute(
            path: Routes.hostHomeScreen.path,
            name: Routes.hostHomeScreen.name,
            builder: (context, state) => const HostOperationsHomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _hostClubsShellKey,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          GoRoute(
            path: Routes.hostClubsScreen.path,
            name: Routes.hostClubsScreen.name,
            builder: (context, state) => const HostClubsScreen(),
            routes: [
              GoRoute(
                path: 'create-club',
                name: Routes.hostCreateClubScreen.name,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const HostCreateClubScreen(),
              ),
              GoRoute(
                path: ':clubId',
                name: Routes.hostClubDetailScreen.name,
                pageBuilder: _clubDetailPage,
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: Routes.hostEditClubScreen.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => HostEditClubRouteScreen(
                      clubId: state.pathParameters['clubId']!,
                      initialClub: switch (state.extra) {
                        final Club club => club,
                        _ => null,
                      },
                    ),
                  ),
                  GoRoute(
                    path: 'create-event',
                    name: Routes.hostCreateEventScreen.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => HostCreateEventRouteScreen(
                      clubId: state.pathParameters['clubId']!,
                      initialClub: switch (state.extra) {
                        final Club club => club,
                        _ => null,
                      },
                    ),
                  ),
                  GoRoute(
                    path: 'events/:eventId',
                    name: Routes.hostAppEventDetailScreen.name,
                    pageBuilder: _eventDetailPage,
                  ),
                  GoRoute(
                    path: 'events/:eventId/manage',
                    name: Routes.hostAppEventManageScreen.name,
                    parentNavigatorKey: _rootNavigatorKey,
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
                    parentNavigatorKey: _rootNavigatorKey,
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
                    parentNavigatorKey: _rootNavigatorKey,
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
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => HostEventManageRouteScreen(
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
      StatefulShellBranch(
        navigatorKey: _hostInboxShellKey,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          GoRoute(
            path: Routes.hostInboxScreen.path,
            name: Routes.hostInboxScreen.name,
            builder: (context, state) => const ChatsListScreen(),
            routes: [
              GoRoute(
                path: ':matchId',
                name: Routes.hostChatScreen.name,
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
        navigatorKey: _hostSettingsShellKey,
        observers: [AnalyticsRouteObserver(analytics)],
        routes: [
          GoRoute(
            path: Routes.hostSettingsScreen.path,
            name: Routes.hostSettingsScreen.name,
            builder: (context, state) => const HostAccountScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                name: Routes.hostProfileScreen.name,
                builder: (context, state) => const HostProfileScreen(),
              ),
            ],
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
      return Routes.hostHomeScreen.path;
    }
    return defaultRouteName;
  }
  return AppConfig.appRole.isHost
      ? Routes.hostHomeScreen.path
      : Routes.startScreen.path;
}

/// Routes that unauthenticated users may access for read-only browsing.
bool _isPublicRoute(String matchedLocation) {
  if (AppConfig.enableEventPolicyLab &&
      matchedLocation == Routes.eventPolicyLabScreen.path) {
    return true;
  }
  if (AppConfig.enableEventSuccessPreview &&
      matchedLocation == Routes.eventSuccessLabScreen.path) {
    return true;
  }
  if (AppConfig.enableEventSuccessPreview &&
      matchedLocation == Routes.eventSuccessManualQaScreen.path) {
    return true;
  }
  if (matchedLocation == Routes.startScreen.path) return true;
  if (matchedLocation == Routes.authScreen.path) return true;
  if (matchedLocation == Routes.exploreScreen.path) return true;

  if (matchedLocation.startsWith('/clubs/')) {
    return true;
  }

  if (matchedLocation.startsWith('/events/') &&
      matchedLocation.endsWith('/location')) {
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
    if (!isHostApp && _isPublicRoute(matchedLocation)) return null;
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
      if (!_isPublicRoute(matchedLocation) ||
          _isTransientRoute(matchedLocation)) {
        return _locationWithFrom(
          Routes.authScreen.path,
          from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
        );
      }
    }
    if (_isPublicRoute(matchedLocation)) return null;
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
    return _profileCompletionLocation(
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
      ? Routes.hostHomeScreen.path
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

String _profileCompletionLocation({String? from}) {
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
