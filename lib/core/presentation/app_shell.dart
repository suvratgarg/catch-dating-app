import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/presentation/app_shell_keys.dart';
import 'package:catch_dating_app/core/presentation/catch_adaptive_tab_scaffold.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_bar.dart';
import 'package:catch_dating_app/event_success/event_success_companion_launcher.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Tab indices — kept in sync with branch order in go_router.dart
//   0  Home      (DashboardScreen)
//   1  Explore   (ExploreScreen)
//   2  Chats     (MatchesListScreen)
//   3  Profile   (ProfileScreen)

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
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value ?? '';
    final isAuthenticated = uid.isNotEmpty;
    final showGuestAuthCta =
        !isAuthenticated && !uidAsync.isLoading && !uidAsync.hasError;
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

    final authenticatedNavigationBar = isAuthenticated
        ? appShellNavigationBar(
            navigationShell: navigationShell,
            unreadCount: unreadCount,
          )
        : null;
    return CatchAdaptiveTabScaffold(
      activeIndex: navigationShell.currentIndex,
      navigationBar: authenticatedNavigationBar,
      anchoredFallback: showGuestAuthCta ? const GuestAuthCtaBar() : null,
      body: CatchNoticeHost(
        persistentNotices: [
          if (isOffline) CatchNoticeData.offline(context.l10n),
        ],
        child: navigationShell,
      ),
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

class GuestAuthCtaBar extends StatelessWidget {
  const GuestAuthCtaBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchBottomDock(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.micro10,
        CatchSpacing.s4,
        CatchSpacing.s3,
      ),
      child: CatchButton(
        label: context.l10n.consumerAuthContinueWithPhone,
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
        'from': from.isEmpty ? Routes.exploreScreen.path : from,
      },
    ).toString();
  }
}

Widget appShellNavigationBar({
  required StatefulNavigationShell navigationShell,
  required int unreadCount,
}) {
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

class AppShellNavigationBar extends StatelessWidget {
  const AppShellNavigationBar({
    super.key,
    required this.currentIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
    this.items,
  });

  final int currentIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;
  final List<AppShellNavigationItem>? items;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = currentIndex;
    final destinations = items ?? _consumerNavigationItems();
    final l10n = context.l10n;

    return CatchTabBar<int>(
      key: AppShellKeys.navigationBar,
      active: selectedIndex,
      onChanged: onDestinationSelected,
      items: [
        for (final (fallbackIndex, item) in destinations.indexed)
          CatchTabBarItem(
            id: item.branchIndex ?? fallbackIndex,
            icon: prefersCupertinoControls()
                ? item.cupertinoIcon
                : item.materialIcon,
            activeIcon: prefersCupertinoControls()
                ? item.cupertinoSelectedIcon
                : item.materialSelectedIcon,
            label: item.destination.localizedLabel(l10n),
            badgeCount: item.showsUnreadBadge ? unreadCount : 0,
          ),
      ],
    );
  }
}

class AppShellNavigationItem {
  const AppShellNavigationItem({
    required this.destination,
    required this.materialIcon,
    required this.materialSelectedIcon,
    required this.cupertinoIcon,
    required this.cupertinoSelectedIcon,
    this.branchIndex,
    this.showsUnreadBadge = false,
  });

  final AppShellNavigationDestination destination;
  final int? branchIndex;
  final IconData materialIcon;
  final IconData materialSelectedIcon;
  final IconData cupertinoIcon;
  final IconData cupertinoSelectedIcon;
  final bool showsUnreadBadge;
}

enum AppShellNavigationDestination {
  consumerHome,
  consumerExplore,
  consumerChats,
  consumerProfile,
  hostToday,
  hostEvents,
  hostInbox,
  hostOrganizer;

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    AppShellNavigationDestination.consumerHome => l10n.consumerNavigationHome,
    AppShellNavigationDestination.consumerExplore =>
      l10n.consumerNavigationExplore,
    AppShellNavigationDestination.consumerChats => l10n.consumerNavigationChats,
    AppShellNavigationDestination.consumerProfile =>
      l10n.consumerNavigationProfile,
    AppShellNavigationDestination.hostToday => l10n.hostNavigationToday,
    AppShellNavigationDestination.hostEvents => l10n.hostNavigationEvents,
    AppShellNavigationDestination.hostInbox => l10n.hostNavigationInbox,
    AppShellNavigationDestination.hostOrganizer => l10n.hostNavigationOrganizer,
  };
}

List<AppShellNavigationItem> _consumerNavigationItems() => [
  AppShellNavigationItem(
    destination: AppShellNavigationDestination.consumerHome,
    branchIndex: appShellHomeTabIndex,
    materialIcon: CatchIcons.tabHome,
    materialSelectedIcon: CatchIcons.tabHomeFilled,
    cupertinoIcon: CupertinoIcons.house,
    cupertinoSelectedIcon: CupertinoIcons.house_fill,
  ),
  AppShellNavigationItem(
    destination: AppShellNavigationDestination.consumerExplore,
    branchIndex: appShellClubsTabIndex,
    materialIcon: CatchIcons.tabExplore,
    materialSelectedIcon: CatchIcons.tabExploreFilled,
    cupertinoIcon: CupertinoIcons.person_2,
    cupertinoSelectedIcon: CupertinoIcons.person_2_fill,
  ),
  AppShellNavigationItem(
    destination: AppShellNavigationDestination.consumerChats,
    branchIndex: appShellChatsTabIndex,
    materialIcon: CatchIcons.tabChats,
    materialSelectedIcon: CatchIcons.tabChatsFilled,
    cupertinoIcon: CupertinoIcons.chat_bubble_2,
    cupertinoSelectedIcon: CupertinoIcons.chat_bubble_2_fill,
    showsUnreadBadge: true,
  ),
  AppShellNavigationItem(
    destination: AppShellNavigationDestination.consumerProfile,
    branchIndex: appShellProfileTabIndex,
    materialIcon: CatchIcons.tabYou,
    materialSelectedIcon: CatchIcons.tabYouFilled,
    cupertinoIcon: CupertinoIcons.person,
    cupertinoSelectedIcon: CupertinoIcons.person_fill,
  ),
];
