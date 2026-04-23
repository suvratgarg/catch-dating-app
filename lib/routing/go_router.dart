import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/matches/presentation/matches_list_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/profile/presentation/edit_profile_screen.dart';
import 'package:catch_dating_app/profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/create/create_run_club_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_detail_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_screen.dart';
import 'package:catch_dating_app/runs/presentation/create_run_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
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
  editProfileScreen('/edit-profile'),
  // Home / Dashboard branch (index 0)
  dashboardScreen('/'),
  // Clubs branch (index 1)
  runClubsListScreen('/clubs'),
  runClubDetailScreen('/clubs/run-clubs/:runClubId'),
  runDetailScreen('/clubs/run-clubs/:runClubId/runs/:runId'),
  createRunClubScreen('/clubs/create-run-club'),
  createRunScreen('/clubs/run-clubs/:runClubId/create-run'),
  // Catches branch (index 2)
  swipeHubScreen('/catches'),
  swipeRunScreen('/catches/:runId'),
  // Chats branch (index 3)
  matchesListScreen('/chats'),
  chatScreen('/chats/:matchId'),
  // You / Profile branch (index 4)
  profileScreen('/you'),
  paymentHistoryScreen('/payment-history');

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

  ref.listen(uidProvider, (_, _) => notifier.notify());
  ref.listen(userProfileStreamProvider, (_, _) => notifier.notify());

  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.dashboardScreen.path,
    refreshListenable: notifier,
    redirect: (context, state) {
      return appRedirect(
        uidAsync: ref.read(uidProvider),
        userProfileAsync: ref.read(userProfileStreamProvider),
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
        builder: (context, state) =>
            const AuthScreen(authState: AuthState.signIn),
      ),
      GoRoute(
        path: Routes.onboardingScreen.path,
        name: Routes.onboardingScreen.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.editProfileScreen.path,
        name: Routes.editProfileScreen.name,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: Routes.paymentHistoryScreen.path,
        name: Routes.paymentHistoryScreen.name,
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // ── Branch 0: Home / Dashboard ───────────────────────────────
          StatefulShellBranch(
            navigatorKey: _dashboardShellKey,
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
                      initialRunClub: state.extra is RunClub
                          ? state.extra! as RunClub
                          : null,
                    ),
                    routes: [
                      GoRoute(
                        path: 'runs/:runId',
                        name: Routes.runDetailScreen.name,
                        builder: (context, state) => RunDetailScreen(
                          runClubId: state.pathParameters['runClubId']!,
                          runId: state.pathParameters['runId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'create-run',
                        name: Routes.createRunScreen.name,
                        builder: (context, state) => CreateRunRouteScreen(
                          runClubId: state.pathParameters['runClubId']!,
                          initialRunClub: state.extra is RunClub
                              ? state.extra! as RunClub
                              : null,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'create-run-club',
                    name: Routes.createRunClubScreen.name,
                    builder: (context, state) => const CreateRunClubScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 2: Catches (swipe) ────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _catchesShellKey,
            routes: [
              GoRoute(
                path: Routes.swipeHubScreen.path,
                name: Routes.swipeHubScreen.name,
                builder: (context, state) => const SwipeHubScreen(),
                routes: [
                  GoRoute(
                    path: ':runId',
                    name: Routes.swipeRunScreen.name,
                    builder: (context, state) =>
                        SwipeScreen(runId: state.pathParameters['runId']!),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 3: Chats ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _chatsShellKey,
            routes: [
              GoRoute(
                path: Routes.matchesListScreen.path,
                name: Routes.matchesListScreen.name,
                builder: (context, state) => const MatchesListScreen(),
                routes: [
                  GoRoute(
                    path: ':matchId',
                    name: Routes.chatScreen.name,
                    builder: (context, state) => ChatScreen(
                      matchId: state.pathParameters['matchId']!,
                      otherProfile: state.extra is PublicProfile
                          ? state.extra! as PublicProfile
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 4: You / Profile ──────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _profileShellKey,
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
    if (onLoading) return null;
    return _locationWithFrom(
      Routes.loadingScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
  }

  final uid = uidAsync.value;
  final userProfile = userProfileAsync.value;

  if (uid == null) {
    if (onAuth || onOnboarding) return null;
    return _locationWithFrom(
      Routes.authScreen.path,
      from: _pendingDestination(uri: uri, matchedLocation: matchedLocation),
    );
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
      error: (error, _) =>
          Scaffold(body: Center(child: Text(error.toString()))),
      data: (runClub) => runClub == null
          ? const Scaffold(body: Center(child: Text('Run club not found.')))
          : CreateRunScreen(runClub: runClub),
    );
  }
}

// Minimal ChangeNotifier used as GoRouter's refreshListenable.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
