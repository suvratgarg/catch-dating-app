import 'package:catch_dating_app/appUser/data/app_user_repository.dart';
import 'package:catch_dating_app/appUser/presentation/create_profile_screen.dart';
import 'package:catch_dating_app/imageUploads/presentation/upload_photos_screen.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/profile/presentation/edit_profile_screen.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/matches_list_screen.dart';
import 'package:catch_dating_app/publicProfile/domain/public_profile.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/runClubs/domain/run_club.dart';
import 'package:catch_dating_app/runClubs/presentation/create_run_club_screen.dart';
import 'package:catch_dating_app/runClubs/presentation/run_club_detail_screen.dart';
import 'package:catch_dating_app/runClubs/presentation/run_clubs_list_screen.dart';
import 'package:catch_dating_app/runs/presentation/create_run_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_router.g.dart';

enum Routes {
  authScreen('/auth'),
  createProfileScreen('/create-profile'),
  uploadPhotosScreen('/upload-photos'),
  editProfileScreen('/edit-profile'),
  // Clubs branch
  runClubsListScreen('/'),
  runClubDetailScreen('/run-clubs/:runClubId'),
  createRunClubScreen('/create-run-club'),
  createRunScreen('/run-clubs/:runClubId/create-run'),
  // Swipe branch
  swipeHubScreen('/swipe'),
  swipeRunScreen('/swipe/:runId'),
  // Chats branch
  matchesListScreen('/matches'),
  chatScreen('/matches/:matchId'),
  // Profile branch
  profileScreen('/profile');

  const Routes(this.path);
  final String path;
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final uidAsync = ref.watch(uidProvider);
  final appUserAsync = ref.watch(appUserStreamProvider);

  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final clubsShellKey = GlobalKey<NavigatorState>();
  final swipeShellKey = GlobalKey<NavigatorState>();
  final chatsShellKey = GlobalKey<NavigatorState>();
  final profileShellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.runClubsListScreen.path,
    redirect: (context, state) {
      if (uidAsync.isLoading || appUserAsync.isLoading) return null;

      final uid = uidAsync.value;
      final appUser = appUserAsync.value;
      final loc = state.matchedLocation;

      if (uid == null) {
        return loc == Routes.authScreen.path ? null : Routes.authScreen.path;
      }

      if (appUser == null) {
        return loc == Routes.createProfileScreen.path
            ? null
            : Routes.createProfileScreen.path;
      }

      if (!appUser.profileComplete) {
        return loc == Routes.uploadPhotosScreen.path
            ? null
            : Routes.uploadPhotosScreen.path;
      }

      if (loc == Routes.authScreen.path ||
          loc == Routes.createProfileScreen.path ||
          loc == Routes.uploadPhotosScreen.path) {
        return Routes.runClubsListScreen.path;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.authScreen.path,
        name: Routes.authScreen.name,
        builder: (context, state) => AuthScreen(authState: AuthState.signIn),
      ),
      GoRoute(
        path: Routes.createProfileScreen.path,
        name: Routes.createProfileScreen.name,
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: Routes.uploadPhotosScreen.path,
        name: Routes.uploadPhotosScreen.name,
        builder: (context, state) => const UploadPhotosScreen(),
      ),
      GoRoute(
        path: Routes.editProfileScreen.path,
        name: Routes.editProfileScreen.name,
        builder: (context, state) => const EditProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // ── Branch 0: Clubs ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: clubsShellKey,
            routes: [
              GoRoute(
                path: Routes.runClubsListScreen.path,
                name: Routes.runClubsListScreen.name,
                builder: (context, state) => RunClubsListScreen(),
                routes: [
                  GoRoute(
                    path: 'run-clubs/:runClubId',
                    name: Routes.runClubDetailScreen.name,
                    builder: (context, state) =>
                        RunClubDetailScreen(runClub: state.extra! as RunClub),
                    routes: [
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

          // ── Branch 1: Swipe ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: swipeShellKey,
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

          // ── Branch 2: Chats ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: chatsShellKey,
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

          // ── Branch 3: Profile ─────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: profileShellKey,
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
