import 'dart:async';

import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/presentation/app_shell_keys.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/event_success_companion_launcher.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Tab indices — kept in sync with branch order in go_router.dart
//   0  Home      (DashboardScreen)
//   1  Explore   (ClubsListScreen)
//   2  Catches   (SwipeHubScreen)
//   3  Chats     (MatchesListScreen)
//   4  Profile   (ProfileScreen)

part 'app_shell.g.dart';

@riverpod
Future<void> appShellFcmInitialization(Ref ref, String uid) async {
  final fcmService = ref.watch(fcmServiceProvider);
  if (!fcmService.isSupportedPlatform) return;

  await fcmService.initialize(uid: uid, router: ref.read(goRouterProvider));
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).value ?? '';
    final isAuthenticated = uid.isNotEmpty;
    final unreadCount = isAuthenticated
        ? ref.watch(totalUnreadCountProvider(uid))
        : 0;
    final connectivityResults = ref
        .watch(appConnectivityProvider)
        .asData
        ?.value;
    final isOffline =
        connectivityResults != null &&
        connectivityResultsAreOffline(connectivityResults);
    final errorLogger = ref.read(errorLoggerProvider);
    final analytics = ref.read(appAnalyticsProvider);

    if (isAuthenticated) {
      ref.watch(appShellFcmInitializationProvider(uid));
      ref.listen(appShellFcmInitializationProvider(uid), (previous, next) {
        if (!next.hasError) return;
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: next.error!,
            stack: next.stackTrace,
            library: 'catch_fcm',
            context: ErrorDescription('while initializing Firebase Messaging'),
          ),
        );
      });
      ref.listen(watchEventParticipationsForUserProvider(uid), (_, next) {
        final participations = next.asData?.value;
        if (participations == null) return;
        final registry = ref.read(eventSuccessCompanionLaunchRegistryProvider);
        final transitions = registry.attendedTransitionsForUser(
          uid: uid,
          participations: participations,
        );
        for (final participation in transitions) {
          unawaited(
            launchEventSuccessCompanionForParticipation(
              context: context,
              ref: ref,
              uid: uid,
              participation: participation,
            ),
          );
        }
      });
    }

    // Keep observability user IDs in sync with auth state. Also invalidate the
    // user profile stream on sign-out so the next user starts fresh.
    _syncObservabilityUserId(
      uid.isEmpty ? null : uid,
      errorLogger: errorLogger,
      analytics: analytics,
    );
    ref.listen(uidProvider, (prev, next) {
      final uid = next.asData?.value;
      _syncObservabilityUserId(
        uid,
        errorLogger: errorLogger,
        analytics: analytics,
      );
      if (uid != prev?.asData?.value) {
        ref.read(eventSuccessCompanionLaunchRegistryProvider).reset();
      }
      if (uid == null && prev?.asData?.value != null) {
        unawaited(ref.read(fcmServiceProvider).reset());
        ref.invalidate(watchUserProfileProvider);
      }
    });

    return Scaffold(
      body: CatchNoticeHost(
        persistentNotices: [if (isOffline) const AppNotice.offline()],
        child: AppShellActiveTab(
          index: navigationShell.currentIndex,
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: isAuthenticated
          ? _AppShellNavigationBar(
              navigationShell: navigationShell,
              unreadCount: unreadCount,
            )
          : const _GuestAuthCtaBar(),
    );
  }
}

void _syncObservabilityUserId(
  String? uid, {
  required ErrorLogger errorLogger,
  required AppAnalytics analytics,
}) {
  final normalizedUid = uid == null || uid.isEmpty ? null : uid;
  errorLogger.setUserId(normalizedUid);
  analytics.setUserId(normalizedUid);
}

class _GuestAuthCtaBar extends StatelessWidget {
  const _GuestAuthCtaBar();

  @override
  Widget build(BuildContext context) {
    return CatchBottomDock(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: CatchButton(
        label: 'Continue with phone',
        onPressed: () => context.go(_authLocation(context)),
        fullWidth: true,
        size: CatchButtonSize.lg,
      ),
    );
  }

  String _authLocation(BuildContext context) {
    final from = GoRouterState.of(context).uri.toString();
    return Uri(
      path: Routes.authScreen.path,
      queryParameters: {
        'from': from.isEmpty ? Routes.clubsListScreen.path : from,
      },
    ).toString();
  }
}

class _AppShellNavigationBar extends StatelessWidget {
  const _AppShellNavigationBar({
    required this.navigationShell,
    required this.unreadCount,
  });

  final StatefulNavigationShell navigationShell;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navigationShell.currentIndex;

    return AppShellNavigationBar(
      currentIndex: selectedIndex,
      unreadCount: unreadCount,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == selectedIndex,
      ),
    );
  }
}

@visibleForTesting
class AppShellNavigationBar extends StatelessWidget {
  const AppShellNavigationBar({
    super.key,
    required this.currentIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = currentIndex;

    if (prefersCupertinoControls()) {
      final t = CatchTokens.of(context);
      return MediaQuery.withNoTextScaling(
        child: CupertinoTabBar(
          key: AppShellKeys.navigationBar,
          currentIndex: selectedIndex,
          onTap: onDestinationSelected,
          activeColor: t.primary,
          inactiveColor: t.ink3,
          backgroundColor: t.surface.withValues(alpha: 0.96),
          border: Border(top: BorderSide(color: t.line)),
          height: 50,
          iconSize: 30,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_2),
              activeIcon: Icon(CupertinoIcons.person_2_fill),
              label: 'Explore',
            ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.heart),
              activeIcon: Icon(CupertinoIcons.heart_fill),
              label: 'Catches',
            ),
            BottomNavigationBarItem(
              icon: AppShellNavigationBadge(
                count: unreadCount,
                child: const Icon(CupertinoIcons.chat_bubble_2),
              ),
              activeIcon: AppShellNavigationBadge(
                count: unreadCount,
                child: const Icon(CupertinoIcons.chat_bubble_2_fill),
              ),
              label: 'Chats',
            ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    return NavigationBar(
      key: AppShellKeys.navigationBar,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        // 0 — Home
        NavigationDestination(
          icon: Icon(CatchIcons.homeOutlined),
          selectedIcon: Icon(CatchIcons.homeRounded),
          label: 'Home',
        ),
        // 1 — Explore
        NavigationDestination(
          icon: Icon(CatchIcons.groupsOutlined),
          selectedIcon: Icon(CatchIcons.groupsRounded),
          label: 'Explore',
        ),
        // 2 — Catches
        NavigationDestination(
          icon: Icon(CatchIcons.favoriteOutlineRounded),
          selectedIcon: Icon(CatchIcons.favoriteRounded),
          label: 'Catches',
        ),
        // 3 — Chats
        NavigationDestination(
          icon: unreadCount > 0
              ? AppShellNavigationBadge(
                  count: unreadCount,
                  child: Icon(CatchIcons.chatBubbleOutlineRounded),
                )
              : Icon(CatchIcons.chatBubbleOutlineRounded),
          selectedIcon: unreadCount > 0
              ? AppShellNavigationBadge(
                  count: unreadCount,
                  child: Icon(CatchIcons.chatBubbleRounded),
                )
              : Icon(CatchIcons.chatBubbleRounded),
          label: 'Chats',
        ),
        // 4 — Profile
        NavigationDestination(
          icon: Icon(CatchIcons.personOutlineRounded),
          selectedIcon: Icon(CatchIcons.personRounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

@visibleForTesting
class AppShellNavigationBadge extends StatelessWidget {
  const AppShellNavigationBadge({
    super.key,
    required this.count,
    required this.child,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final t = CatchTokens.of(context);
    final label = count > 99 ? '99+' : '$count';

    return SizedBox(
      width: 38,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(alignment: Alignment.bottomCenter, child: child),
          Positioned(
            top: 0,
            right: 1,
            child: CatchSurface(
              radius: CatchRadius.pill,
              backgroundColor: t.primary,
              borderColor: t.surface,
              borderWidth: 1.5,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: CatchTextStyles.statusLabel(
                        context,
                        color: t.primaryInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
