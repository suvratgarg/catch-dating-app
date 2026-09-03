import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/presentation/app_shell_keys.dart';
import 'package:catch_dating_app/core/presentation/catch_adaptive_tab_scaffold.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
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
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
Future<void> appShellFcmInitialization(
  Ref ref,
  String uid,
  GoRouter router,
) async {
  final fcmService = ref.watch(fcmServiceProvider);
  if (!fcmService.isSupportedPlatform) return;

  await fcmService.initialize(uid: uid, router: router);
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
      final router = GoRouter.of(context);
      final fcmInitialization = appShellFcmInitializationProvider(uid, router);
      // FCM initialization is a background side effect; its value is not part
      // of the shell UI. Listening starts the provider and reports failures
      // without rebuilding the keyed StatefulNavigationShell when the future
      // completes.
      ref.listen(fcmInitialization, (previous, next) {
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
    this.layout = AppShellNavigationLayout.bottom,
  });

  final int currentIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;
  final List<AppShellNavigationItem>? items;
  final AppShellNavigationLayout layout;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = currentIndex;
    final destinations = items ?? _consumerNavigationItems();
    final l10n = context.l10n;
    final navigationItems = [
      for (final (fallbackIndex, item) in destinations.indexed)
        CatchTabBarItem(
          id: item.branchIndex ?? fallbackIndex,
          icon: prefersCupertinoControls()
              ? item.cupertinoIcon
              : item.materialIcon,
          activeIcon: prefersCupertinoControls()
              ? item.cupertinoSelectedIcon
              : item.materialSelectedIcon,
          iconWidget: item.iconBuilder?.call(context),
          activeIconWidget:
              item.selectedIconBuilder?.call(context) ??
              item.iconBuilder?.call(context),
          label: item.destination.localizedLabel(l10n),
          badgeCount: item.showsUnreadBadge ? unreadCount : 0,
          onLongPress: item.onLongPress,
          semanticValue: item.semanticValue,
          semanticHint: item.semanticHint,
        ),
    ];

    return switch (layout) {
      AppShellNavigationLayout.bottom => CatchTabBar<int>(
        key: AppShellKeys.navigationBar,
        active: selectedIndex,
        onChanged: onDestinationSelected,
        items: navigationItems,
      ),
      AppShellNavigationLayout.rail => AppShellSideNavigation(
        key: AppShellKeys.navigationBar,
        active: selectedIndex,
        items: navigationItems,
        onChanged: onDestinationSelected,
      ),
      AppShellNavigationLayout.sidebar => AppShellSideNavigation(
        key: AppShellKeys.navigationBar,
        active: selectedIndex,
        items: navigationItems,
        onChanged: onDestinationSelected,
        expanded: true,
        title: l10n.appTitleHost,
      ),
    };
  }
}

/// Placement variants supported by the shared shell destination adapter.
enum AppShellNavigationLayout { bottom, rail, sidebar }

/// Labelled vertical destination plane for medium and expanded app shells.
class AppShellSideNavigation extends StatelessWidget {
  const AppShellSideNavigation({
    super.key,
    required this.active,
    required this.items,
    required this.onChanged,
    this.expanded = false,
    this.title,
  });

  final int active;
  final List<CatchTabBarItem<int>> items;
  final ValueChanged<int> onChanged;
  final bool expanded;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
    final horizontalDestinations = expanded || largeText;
    return DecoratedBox(
      key: ValueKey(
        expanded ? 'app_shell.navigation.sidebar' : 'app_shell.navigation.rail',
      ),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(right: BorderSide(color: t.line)),
      ),
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: expanded
              ? CatchLayout.appShellSidebarWidth
              : largeText
              ? CatchLayout.appShellLargeTextRailWidth
              : CatchLayout.appShellRailWidth,
          child: Material(
            color: Colors.transparent,
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.s3,
                  vertical: CatchSpacing.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title case final title?) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          CatchSpacing.s2,
                          CatchSpacing.s2,
                          CatchSpacing.s2,
                          CatchSpacing.s6,
                        ),
                        child: Text(
                          title,
                          maxLines: largeText ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.headlineS(
                            context,
                            color: t.ink,
                          ),
                        ),
                      ),
                    ],
                    for (final item in items) ...[
                      AppShellSideNavigationButton(
                        item: item,
                        selected: item.id == active,
                        expanded: horizontalDestinations,
                        onTap: () => onChanged(item.id),
                      ),
                      if (item != items.last)
                        const SizedBox(height: CatchSpacing.s2),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One selected, focusable, and badge-aware side-navigation destination.
class AppShellSideNavigationButton extends StatelessWidget {
  const AppShellSideNavigationButton({
    super.key,
    required this.item,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final CatchTabBarItem<int> item;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = selected ? t.ink : t.ink3;
    final icon = CatchTabBarIcon(
      icon: selected ? item.activeIcon ?? item.icon : item.icon,
      color: color,
      badgeCount: item.badgeCount,
      child: selected
          ? item.activeIconWidget ?? item.iconWidget
          : item.iconWidget,
    );
    final label = Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: expanded ? TextAlign.start : TextAlign.center,
      style: CatchTextStyles.buttonSm(context, color: color),
    );
    final content = expanded
        ? Row(
            children: [
              icon,
              const SizedBox(width: CatchSpacing.s3),
              Expanded(child: label),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: CatchSpacing.s1),
              label,
            ],
          );
    final button = Semantics(
      key: ValueKey('app_shell.navigation.destination.${item.id}'),
      container: true,
      button: true,
      selected: selected,
      label: item.label,
      value: item.semanticValue,
      hint: item.semanticHint,
      onLongPress: item.onLongPress,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: expanded
                ? CatchLayout.appShellSidebarItemMinHeight
                : CatchLayout.appShellRailItemMinHeight,
          ),
          child: Material(
            color: selected
                ? t.ink.withValues(alpha: CatchOpacity.tabBarPillFill)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(CatchRadius.md),
            child: InkWell(
              onTap: () {
                catchSelectionHaptic();
                onTap();
              },
              onLongPress: item.onLongPress,
              borderRadius: BorderRadius.circular(CatchRadius.md),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: expanded ? CatchSpacing.s3 : CatchSpacing.s1,
                  vertical: CatchSpacing.s2,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );

    return expanded
        ? button
        : Tooltip(
            message: item.label,
            excludeFromSemantics: true,
            child: button,
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
    this.iconBuilder,
    this.selectedIconBuilder,
    this.onLongPress,
    this.semanticValue,
    this.semanticHint,
  });

  final AppShellNavigationDestination destination;
  final int? branchIndex;
  final IconData materialIcon;
  final IconData materialSelectedIcon;
  final IconData cupertinoIcon;
  final IconData cupertinoSelectedIcon;
  final bool showsUnreadBadge;
  final WidgetBuilder? iconBuilder;
  final WidgetBuilder? selectedIconBuilder;
  final VoidCallback? onLongPress;
  final String? semanticValue;
  final String? semanticHint;
}

enum AppShellNavigationDestination {
  consumerHome,
  consumerExplore,
  consumerChats,
  consumerProfile,
  hostToday,
  hostEvents,
  hostAudience,
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
    AppShellNavigationDestination.hostAudience => l10n.hostNavigationAudience,
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
