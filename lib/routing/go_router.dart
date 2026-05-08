import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/matches/presentation/matches_list_screen.dart'; // ChatsListScreen
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_screen.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/create/create_run_club_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_detail_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_screen.dart';
import 'package:catch_dating_app/runs/presentation/attendance_sheet_screen.dart';
import 'package:catch_dating_app/runs/presentation/create_run_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_location_map_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_map_screen.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/run_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
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
  authScreen('/auth'),
  onboardingScreen('/onboarding'),
  calendarScreen('/calendar'),
  calendarRunDetailScreen('/calendar/run-clubs/:runClubId/runs/:runId'),
  filtersScreen('/filters'),
  runMapScreen('/map'),
  dashboardRunDetailScreen('/dashboard/run-clubs/:runClubId/runs/:runId'),
  runLocationMapScreen('/runs/:runId/location'),
  // Home / Dashboard branch (index 0)
  dashboardScreen('/'),
  // Clubs branch (index 1)
  runClubsListScreen('/clubs'),
  runClubDetailScreen('/clubs/run-clubs/:runClubId'),
  editRunClubScreen('/clubs/run-clubs/:runClubId/edit'),
  runDetailScreen('/clubs/run-clubs/:runClubId/runs/:runId'),
  attendanceSheet('/clubs/run-clubs/:runClubId/runs/:runId/attendance'),
  createRunClubScreen('/clubs/create-run-club'),
  createRunScreen('/clubs/run-clubs/:runClubId/create-run'),
  // Catches branch (index 2)
  swipeHubScreen('/catches'),
  swipeRunScreen('/catches/:runId'),
  runRecapScreen('/catches/:runId/recap'),
  // Chats branch (index 3)
  matchesListScreen('/chats'),
  chatScreen('/chats/:matchId'),
  // Profile branch (index 4)
  profileScreen('/you'),
  reviewsHistoryScreen('/you/reviews'),
  publicProfileScreen('/profiles/:uid'),
  settingsScreen('/settings'),
  paymentHistoryScreen('/payment-history'),
  paymentConfirmationScreen('/payment-confirmation');

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

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier();
  final analytics = ref.read(appAnalyticsProvider);

  ref.listen(uidProvider, (_, _) => notifier.notify());
  ref.listen(watchUserProfileProvider, (_, _) => notifier.notify());

  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.dashboardScreen.path,
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
        path: Routes.authScreen.path,
        name: Routes.authScreen.name,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: Routes.onboardingScreen.path,
        name: Routes.onboardingScreen.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.calendarScreen.path,
        name: Routes.calendarScreen.name,
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: Routes.calendarRunDetailScreen.path,
        name: Routes.calendarRunDetailScreen.name,
        builder: (context, state) => RunDetailScreen(
          runClubId: state.pathParameters['runClubId']!,
          runId: state.pathParameters['runId']!,
        ),
      ),
      GoRoute(
        path: Routes.filtersScreen.path,
        name: Routes.filtersScreen.name,
        builder: (context, state) => const FiltersScreen(),
      ),
      GoRoute(
        path: Routes.runMapScreen.path,
        name: Routes.runMapScreen.name,
        builder: (context, state) => const RunMapScreen(),
      ),
      GoRoute(
        path: Routes.runLocationMapScreen.path,
        name: Routes.runLocationMapScreen.name,
        builder: (context, state) =>
            RunLocationMapRouteScreen(runId: state.pathParameters['runId']!),
      ),
      GoRoute(
        path: Routes.dashboardRunDetailScreen.path,
        name: Routes.dashboardRunDetailScreen.name,
        builder: (context, state) => RunDetailScreen(
          runClubId: state.pathParameters['runClubId']!,
          runId: state.pathParameters['runId']!,
        ),
      ),
      GoRoute(
        path: Routes.paymentHistoryScreen.path,
        name: Routes.paymentHistoryScreen.name,
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: Routes.paymentConfirmationScreen.path,
        name: Routes.paymentConfirmationScreen.name,
        builder: (context, state) {
          final data = state.extra! as PaymentConfirmationData;
          return PaymentConfirmationScreen(data: data);
        },
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
              ),
            ],
          ),

          // ── Branch 1: Clubs ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _clubsShellKey,
            observers: [AnalyticsRouteObserver(analytics)],
            routes: [
              GoRoute(
                path: Routes.runClubsListScreen.path,
                name: Routes.runClubsListScreen.name,
                builder: (context, state) => const RunClubsListScreen(),
                routes: [
                  GoRoute(
                    path: 'run-clubs/:runClubId',
                    name: Routes.runClubDetailScreen.name,
                    builder: (context, state) => RunClubDetailScreen(
                      runClubId: state.pathParameters['runClubId']!,
                      initialRunClub: switch (state.extra) {
                        final RunClub rc => rc,
                        _ => null,
                      },
                    ),
                    routes: [
                      GoRoute(
                        path: 'runs/:runId',
                        name: Routes.runDetailScreen.name,
                        builder: (context, state) => RunDetailScreen(
                          runClubId: state.pathParameters['runClubId']!,
                          runId: state.pathParameters['runId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'attendance',
                            name: Routes.attendanceSheet.name,
                            parentNavigatorKey: _rootNavigatorKey,
                            builder: (context, state) => AttendanceSheetScreen(
                              runClubId: state.pathParameters['runClubId']!,
                              runId: state.pathParameters['runId']!,
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'edit',
                        name: Routes.editRunClubScreen.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => EditRunClubRouteScreen(
                          runClubId: state.pathParameters['runClubId']!,
                          initialRunClub: switch (state.extra) {
                            final RunClub rc => rc,
                            _ => null,
                          },
                        ),
                      ),
                      GoRoute(
                        path: 'create-run',
                        name: Routes.createRunScreen.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => CreateRunRouteScreen(
                          runClubId: state.pathParameters['runClubId']!,
                          initialRunClub: switch (state.extra) {
                            final RunClub rc => rc,
                            _ => null,
                          },
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'create-run-club',
                    name: Routes.createRunClubScreen.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const CreateRunClubScreen(),
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
                    path: ':runId/recap',
                    name: Routes.runRecapScreen.name,
                    builder: (context, state) =>
                        RunRecapScreen(runId: state.pathParameters['runId']!),
                  ),
                  GoRoute(
                    path: ':runId',
                    name: Routes.swipeRunScreen.name,
                    builder: (context, state) => SwipeScreen(
                      runId: state.pathParameters['runId']!,
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
                routes: [
                  GoRoute(
                    path: 'reviews',
                    name: Routes.reviewsHistoryScreen.name,
                    builder: (context, state) => const ReviewsHistoryScreen(),
                  ),
                ],
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
  if (matchedLocation == Routes.runClubsListScreen.path) return true;

  if (matchedLocation.startsWith('/clubs/run-clubs/')) {
    // Write-oriented sub-routes still require auth.
    if (matchedLocation.endsWith('/edit')) return false;
    if (matchedLocation.endsWith('/create-run')) return false;
    if (matchedLocation.endsWith('/attendance')) return false;
    return true;
  }

  if (matchedLocation.startsWith('/runs/') &&
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
    if (onOnboarding) return null;
    if (onAuth) return null;
    return Routes.runClubsListScreen.path;
  }

  if (userProfile == null || !userProfile.profileComplete) {
    if (onOnboarding) return null;
    return _locationWithFrom(
      Routes.onboardingScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  if (onLoading || onAuth || onOnboarding) {
    return _resumeDestination(uri);
  }

  return null;
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

String? _sanitizeFrom(String? from) {
  if (from == null || from.isEmpty || !from.startsWith('/')) return null;
  final uri = Uri.tryParse(from);
  return uri?.toString();
}

bool _isTransientRoute(String path) =>
    path == Routes.loadingScreen.path ||
    path == Routes.authScreen.path ||
    path == Routes.onboardingScreen.path;

class _RouterLoadingScreen extends StatelessWidget {
  const _RouterLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CatchLoadingIndicator());
  }
}

class CreateRunRouteScreen extends ConsumerWidget {
  const CreateRunRouteScreen({
    super.key,
    required this.runClubId,
    this.initialRunClub,
  });

  final String runClubId;
  final RunClub? initialRunClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialRunClub != null) {
      return CreateRunScreen(runClub: initialRunClub!);
    }

    final runClubAsync = ref.watch(fetchRunClubProvider(runClubId));
    return runClubAsync.when(
      loading: () => const _RouterLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(fetchRunClubProvider(runClubId)),
      ),
      data: (runClub) => runClub == null
          ? const CatchErrorScaffold(
              title: 'Club not found',
              message: 'This run club is no longer available.',
            )
          : CreateRunScreen(runClub: runClub),
    );
  }
}

class EditRunClubRouteScreen extends ConsumerWidget {
  const EditRunClubRouteScreen({
    super.key,
    required this.runClubId,
    this.initialRunClub,
  });

  final String runClubId;
  final RunClub? initialRunClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialRunClub != null) {
      return CreateRunClubScreen(initialRunClub: initialRunClub!);
    }

    final runClubAsync = ref.watch(fetchRunClubProvider(runClubId));
    return runClubAsync.when(
      loading: () => const _RouterLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(fetchRunClubProvider(runClubId)),
      ),
      data: (runClub) => runClub == null
          ? const CatchErrorScaffold(
              title: 'Club not found',
              message: 'This run club is no longer available.',
            )
          : CreateRunClubScreen(initialRunClub: runClub),
    );
  }
}

// Minimal ChangeNotifier used as GoRouter's refreshListenable.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
