import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/matches_list_screen.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/profile/presentation/edit_profile_screen.dart';
import 'package:catch_dating_app/profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/create_run_club_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_detail_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_list_screen.dart';
import 'package:catch_dating_app/runs/presentation/create_run_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_router.g.dart';

enum Routes {
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

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier();

  ref.listen(uidProvider, (_, _) => notifier.notify());
  ref.listen(appUserStreamProvider, (_, _) => notifier.notify());

  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.dashboardScreen.path,
    refreshListenable: notifier,
    redirect: (context, state) {
      final uidAsync = ref.read(uidProvider);
      final appUserAsync = ref.read(appUserStreamProvider);

      if (uidAsync.isLoading || appUserAsync.isLoading) return null;

      final uid = uidAsync.value;
      final appUser = appUserAsync.value;
      final loc = state.matchedLocation;

      final onOnboarding = loc == Routes.onboardingScreen.path;
      final onAuth = loc == Routes.authScreen.path;

      if (uid == null) {
        // Not authenticated — only allow auth and onboarding routes
        if (onAuth || onOnboarding) return null;
        return Routes.authScreen.path;
      }

      if (appUser == null) {
        // Authenticated but no profile doc yet
        if (onOnboarding) return null;
        return Routes.onboardingScreen.path;
      }

      if (!appUser.profileComplete) {
        // Profile started but not finished
        if (onOnboarding) return null;
        return Routes.onboardingScreen.path;
      }

      // Fully set up — redirect away from auth / onboarding flows
      if (onAuth || onOnboarding) return Routes.dashboardScreen.path;

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.authScreen.path,
        name: Routes.authScreen.name,
        builder: (context, state) => const AuthScreen(authState: AuthState.signIn),
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
                        builder: (context, state) =>
                            CreateRunScreen(runClub: state.extra! as RunClub),
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
                    builder: (context, state) => SwipeScreen(
                      runId: state.pathParameters['runId']!,
                    ),
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
                      otherProfile: state.extra as PublicProfile?,
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

// Minimal ChangeNotifier used as GoRouter's refreshListenable.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
