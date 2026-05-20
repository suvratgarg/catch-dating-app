import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/create/create_club_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_screen.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/event_policies/presentation/event_policy_lab_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_event_preview_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_lab_screen.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/create_event_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/saved_events_screen.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/matches/presentation/matches_list_screen.dart'; // ChatsListScreen
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
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show AsyncValue, ConsumerWidget, WidgetRef;
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
  eventMapScreen('/map'),
  dashboardEventDetailScreen('/dashboard/clubs/:clubId/events/:eventId'),
  dashboardHostEventManageScreen(
    '/dashboard/clubs/:clubId/events/:eventId/manage',
  ),
  hostEventManageScreen('/clubs/:clubId/events/:eventId/manage'),
  editHostedEventScreen('/clubs/:clubId/events/:eventId/edit'),
  eventSuccessHostScreen('/dashboard/clubs/:clubId/events/:eventId/success'),
  eventLocationMapScreen('/events/:eventId/location'),
  // Home / Dashboard branch (index 0)
  dashboardScreen('/'),
  notificationsScreen('/notifications'),
  // Clubs branch (index 1)
  clubsListScreen('/clubs'),
  clubDetailScreen('/clubs/:clubId'),
  editClubScreen('/clubs/:clubId/edit'),
  eventDetailScreen('/clubs/:clubId/events/:eventId'),
  attendanceSheet('/clubs/:clubId/events/:eventId/attendance'),
  eventSuccessCompanionScreen('/clubs/:clubId/events/:eventId/companion'),
  createClubScreen('/clubs/create-club'),
  createEventScreen('/clubs/:clubId/create-event'),
  // Catches branch (index 2)
  swipeHubScreen('/catches'),
  swipeEventScreen('/catches/:eventId'),
  eventRecapScreen('/catches/:eventId/recap'),
  // Chats branch (index 3)
  matchesListScreen('/chats'),
  chatScreen('/chats/:matchId'),
  // Profile branch (index 4)
  profileScreen('/you'),
  reviewsHistoryScreen('/you/reviews'),
  publicProfileScreen('/profiles/:uid'),
  settingsScreen('/settings'),
  paymentHistoryScreen('/payment-history'),
  paymentConfirmationScreen('/payment-confirmation'),
  eventPolicyLabScreen('/dev/event-policy-lab'),
  eventSuccessLabScreen('/dev/event-success-lab'),
  eventSuccessPreviewScreen('/dev/event-success-preview/:clubId/:eventId');

  const Routes(this.path);
  final String path;
}

// Navigator keys are file-level so they are created once for the app lifetime.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardShellKey = GlobalKey<NavigatorState>();
final _clubsShellKey = GlobalKey<NavigatorState>();
final _catchesShellKey = GlobalKey<NavigatorState>();
final _chatsShellKey = GlobalKey<NavigatorState>();
final _profileShellKey = GlobalKey<NavigatorState>();

const _fromQueryParam = 'from';
const _onboardingIntentQueryParam = 'intent';
const _completeProfileIntent = 'complete-profile';
const _completeRunPreferencesIntent = 'complete-run-preferences';

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier();
  final analytics = ref.read(appAnalyticsProvider);

  ref.listen(uidProvider, (_, _) => notifier.notify());
  ref.listen(watchUserProfileProvider, (_, _) => notifier.notify());

  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.startScreen.path,
    refreshListenable: notifier,
    observers: [AnalyticsRouteObserver(analytics)],
    redirect: (context, state) {
      return appRedirect(
        uidAsync: ref.read(uidProvider),
        userProfileAsync: ref.read(watchUserProfileProvider),
        matchedLocation: state.matchedLocation,
        uri: state.uri,
      );
    },
    routes: [
      GoRoute(
        path: Routes.loadingScreen.path,
        name: Routes.loadingScreen.name,
        builder: (context, state) => const _RouterLoadingScreen(),
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
        builder: (context, state) => EventDetailScreen(
          clubId: state.pathParameters['clubId']!,
          eventId: state.pathParameters['eventId']!,
          inviteCode: state.uri.queryParameters['invite'],
          initialEvent: switch (state.extra) {
            final Event event => event,
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: Routes.savedEventsScreen.path,
        name: Routes.savedEventsScreen.name,
        builder: (context, state) => const SavedEventsScreen(),
      ),
      GoRoute(
        path: Routes.savedEventDetailScreen.path,
        name: Routes.savedEventDetailScreen.name,
        builder: (context, state) => EventDetailScreen(
          clubId: state.pathParameters['clubId']!,
          eventId: state.pathParameters['eventId']!,
          inviteCode: state.uri.queryParameters['invite'],
          initialEvent: switch (state.extra) {
            final Event event => event,
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: Routes.filtersScreen.path,
        name: Routes.filtersScreen.name,
        builder: (context, state) => const FiltersScreen(),
      ),
      GoRoute(
        path: Routes.eventMapScreen.path,
        name: Routes.eventMapScreen.name,
        builder: (context, state) => const EventMapScreen(),
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
        builder: (context, state) => EventDetailScreen(
          clubId: state.pathParameters['clubId']!,
          eventId: state.pathParameters['eventId']!,
          inviteCode: state.uri.queryParameters['invite'],
          initialEvent: switch (state.extra) {
            final Event event => event,
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: Routes.dashboardHostEventManageScreen.path,
        builder: (context, state) => HostEventManageRouteScreen(
          clubId: state.pathParameters['clubId']!,
          eventId: state.pathParameters['eventId']!,
          initialEvent: switch (state.extra) {
            final Event event => event,
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: Routes.hostEventManageScreen.path,
        name: Routes.hostEventManageScreen.name,
        builder: (context, state) => HostEventManageRouteScreen(
          clubId: state.pathParameters['clubId']!,
          eventId: state.pathParameters['eventId']!,
          initialEvent: switch (state.extra) {
            final Event event => event,
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: Routes.editHostedEventScreen.path,
        name: Routes.editHostedEventScreen.name,
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
        path: Routes.eventSuccessHostScreen.path,
        name: Routes.eventSuccessHostScreen.name,
        builder: (context, state) => HostEventManageRouteScreen(
          clubId: state.pathParameters['clubId']!,
          eventId: state.pathParameters['eventId']!,
          initialEvent: switch (state.extra) {
            final Event event => event,
            _ => null,
          },
          initialSection: HostEventManageSection.setup,
        ),
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
                ],
              ),
            ],
          ),

          // ── Branch 1: Clubs ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _clubsShellKey,
            observers: [AnalyticsRouteObserver(analytics)],
            routes: [
              GoRoute(
                path: Routes.clubsListScreen.path,
                name: Routes.clubsListScreen.name,
                builder: (context, state) => const ClubsListScreen(),
                routes: [
                  GoRoute(
                    path: 'create-club',
                    name: Routes.createClubScreen.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const CreateClubScreen(),
                  ),
                  GoRoute(
                    path: ':clubId',
                    name: Routes.clubDetailScreen.name,
                    builder: (context, state) => ClubDetailScreen(
                      clubId: state.pathParameters['clubId']!,
                      initialClub: switch (state.extra) {
                        final Club rc => rc,
                        _ => null,
                      },
                    ),
                    routes: [
                      GoRoute(
                        path: 'events/:eventId',
                        name: Routes.eventDetailScreen.name,
                        builder: (context, state) => EventDetailScreen(
                          clubId: state.pathParameters['clubId']!,
                          eventId: state.pathParameters['eventId']!,
                          inviteCode: state.uri.queryParameters['invite'],
                          initialEvent: switch (state.extra) {
                            final Event event => event,
                            _ => null,
                          },
                        ),
                        routes: [
                          GoRoute(
                            path: 'attendance',
                            name: Routes.attendanceSheet.name,
                            parentNavigatorKey: _rootNavigatorKey,
                            builder: (context, state) =>
                                HostEventManageRouteScreen(
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
                      GoRoute(
                        path: 'edit',
                        name: Routes.editClubScreen.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => EditClubRouteScreen(
                          clubId: state.pathParameters['clubId']!,
                          initialClub: switch (state.extra) {
                            final Club rc => rc,
                            _ => null,
                          },
                        ),
                      ),
                      GoRoute(
                        path: 'create-event',
                        name: Routes.createEventScreen.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => CreateEventRouteScreen(
                          clubId: state.pathParameters['clubId']!,
                          initialClub: switch (state.extra) {
                            final Club rc => rc,
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

          // ── Branch 2: Catches (swipe) ────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _catchesShellKey,
            observers: [AnalyticsRouteObserver(analytics)],
            routes: [
              GoRoute(
                path: Routes.swipeHubScreen.path,
                name: Routes.swipeHubScreen.name,
                builder: (context, state) => const SwipeHubScreen(),
                routes: [
                  GoRoute(
                    path: ':eventId/recap',
                    name: Routes.eventRecapScreen.name,
                    builder: (context, state) => EventRecapScreen(
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':eventId',
                    name: Routes.swipeEventScreen.name,
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

          // ── Branch 3: Chats ──────────────────────────────────────────
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

          // ── Branch 4: Profile ────────────────────────────────────────
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
  if (matchedLocation == Routes.startScreen.path) return true;
  if (matchedLocation == Routes.authScreen.path) return true;
  if (matchedLocation == Routes.clubsListScreen.path) return true;

  if (matchedLocation.startsWith('/clubs/') &&
      matchedLocation != Routes.createClubScreen.path) {
    // Write-oriented sub-routes still require auth.
    if (matchedLocation.endsWith('/edit')) return false;
    if (matchedLocation.endsWith('/create-event')) return false;
    if (matchedLocation.endsWith('/manage')) return false;
    if (matchedLocation.endsWith('/attendance')) return false;
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
  required String matchedLocation,
  required Uri uri,
}) {
  final onLoading = matchedLocation == Routes.loadingScreen.path;
  final onStart = matchedLocation == Routes.startScreen.path;
  final onOnboarding = matchedLocation == Routes.onboardingScreen.path;
  final onAuth = matchedLocation == Routes.authScreen.path;

  final isWaitingOnAuth = uidAsync.isLoading;
  final isWaitingOnProfile =
      uidAsync.hasValue && uidAsync.value != null && userProfileAsync.isLoading;

  if (isWaitingOnAuth || isWaitingOnProfile) {
    if (_isPublicRoute(matchedLocation)) return null;
    if (onLoading) return null;
    return _locationWithFrom(
      Routes.loadingScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  final uid = uidAsync.value;
  final userProfile = userProfileAsync.value;

  if (uid == null) {
    if (_isPublicRoute(matchedLocation)) return null;
    return _locationWithFrom(
      Routes.startScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  final onProfileCompletionOnboarding =
      onOnboarding &&
      uri.queryParameters[_onboardingIntentQueryParam] ==
          _completeProfileIntent;
  final onRunPreferencesOnboarding =
      onOnboarding &&
      uri.queryParameters[_onboardingIntentQueryParam] ==
          _completeRunPreferencesIntent;

  if (userProfile == null || !userProfile.hasBookingReadyIdentity) {
    if (onOnboarding) return null;
    return _locationWithFrom(
      Routes.onboardingScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  if (onProfileCompletionOnboarding) {
    if (!userProfile.hasSocialReadyProfile) return null;
    return _resumeDestination(uri);
  }

  if (onRunPreferencesOnboarding) {
    if (!userProfile.hasCurrentRunPreferences) return null;
    return _resumeDestination(uri);
  }

  if (_requiresSocialProfile(matchedLocation) &&
      !userProfile.hasSocialReadyProfile) {
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
      matchedLocation == Routes.swipeHubScreen.path ||
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
  if (from == null) return Routes.dashboardScreen.path;

  final targetPath = Uri.parse(from).path;
  if (_isTransientRoute(targetPath)) {
    return Routes.dashboardScreen.path;
  }
  return from;
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

class _RouterLoadingScreen extends StatelessWidget {
  const _RouterLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const CatchStartupLoadingScreen();
  }
}

class CreateEventRouteScreen extends ConsumerWidget {
  const CreateEventRouteScreen({
    super.key,
    required this.clubId,
    this.initialClub,
  });

  final String clubId;
  final Club? initialClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialClub != null) {
      return CreateEventScreen(club: initialClub!);
    }

    final clubAsync = ref.watch(fetchClubProvider(clubId));
    return clubAsync.when(
      loading: () => const _RouterLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(fetchClubProvider(clubId)),
      ),
      data: (club) => club == null
          ? const CatchErrorScaffold(
              title: 'Club not found',
              message: 'This club is no longer available.',
            )
          : CreateEventScreen(club: club),
    );
  }
}

class EditClubRouteScreen extends ConsumerWidget {
  const EditClubRouteScreen({
    super.key,
    required this.clubId,
    this.initialClub,
  });

  final String clubId;
  final Club? initialClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialClub != null) {
      return CreateClubScreen(initialClub: initialClub!);
    }

    final clubAsync = ref.watch(fetchClubProvider(clubId));
    return clubAsync.when(
      loading: () => const _RouterLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(fetchClubProvider(clubId)),
      ),
      data: (club) => club == null
          ? const CatchErrorScaffold(
              title: 'Club not found',
              message: 'This club is no longer available.',
            )
          : CreateClubScreen(initialClub: club),
    );
  }
}

// Minimal ChangeNotifier used as GoRouter's refreshListenable.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
