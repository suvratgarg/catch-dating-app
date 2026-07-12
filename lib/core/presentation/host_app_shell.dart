import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/presentation/app_shell_keys.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_bar.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostAppShell extends ConsumerWidget {
  const HostAppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value ?? '';
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
      // Reuse the shared FCM-init provider so host and consumer shells cannot
      // drift apart.
      ref.watch(appShellFcmInitializationProvider(uid));
      ref.listen(appShellFcmInitializationProvider(uid), (previous, next) {
        if (!next.hasError) return;
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: next.error!,
            stack: next.stackTrace,
            library: 'catch_fcm',
            context: ErrorDescription(
              'while initializing host Firebase Messaging',
            ),
          ),
        );
      });
    }

    errorLogger.setUserId(uid.isEmpty ? null : uid);
    analytics.setUserId(uid.isEmpty ? null : uid);
    ref.listen(uidProvider, (previous, next) {
      final nextUid = next.asData?.value;
      final normalized = nextUid == null || nextUid.isEmpty ? null : nextUid;
      errorLogger.setUserId(normalized);
      analytics.setUserId(normalized);
      if (nextUid == null && previous?.asData?.value != null) {
        unawaited(ref.read(fcmServiceProvider).reset());
      }
    });

    final authenticatedTabBarFloats =
        isAuthenticated && CatchTabBar.floatsFor(context);
    final authenticatedBottomOverlayInset = authenticatedTabBarFloats
        ? CatchTabBar.reservedBottomInset(context)
        : 0.0;
    final authenticatedNavigationBar = isAuthenticated
        ? AppShellNavigationBar(
            currentIndex: navigationShell.currentIndex,
            unreadCount: unreadCount,
            items: _hostNavigationItems,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          )
        : null;
    final body = CatchNoticeHost(
      persistentNotices: [if (isOffline) CatchNoticeData.offline(context.l10n)],
      child: AppShellActiveTab(
        index: navigationShell.currentIndex,
        bottomOverlayInset: authenticatedBottomOverlayInset,
        child: navigationShell,
      ),
    );

    return Scaffold(
      key: AppShellKeys.scaffold,
      extendBody: authenticatedTabBarFloats,
      body: authenticatedTabBarFloats
          ? Stack(
              children: [
                Positioned.fill(child: body),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: authenticatedNavigationBar!,
                ),
              ],
            )
          : body,
      bottomNavigationBar: authenticatedTabBarFloats
          ? null
          : isAuthenticated
          ? authenticatedNavigationBar
          : null,
    );
  }
}

final _hostNavigationItems = [
  AppShellNavigationItem(
    destination: AppShellNavigationDestination.hostToday,
    materialIcon: CatchIcons.tabHome,
    materialSelectedIcon: CatchIcons.tabHomeFilled,
    cupertinoIcon: CatchIcons.tabHome,
    cupertinoSelectedIcon: CatchIcons.tabHomeFilled,
  ),
  AppShellNavigationItem(
    destination: AppShellNavigationDestination.hostEvents,
    materialIcon: CatchIcons.tabEvents,
    materialSelectedIcon: CatchIcons.tabEventsFilled,
    cupertinoIcon: CatchIcons.tabEvents,
    cupertinoSelectedIcon: CatchIcons.tabEventsFilled,
  ),
  AppShellNavigationItem(
    destination: AppShellNavigationDestination.hostInbox,
    materialIcon: CatchIcons.tabChats,
    materialSelectedIcon: CatchIcons.tabChatsFilled,
    cupertinoIcon: CatchIcons.tabChats,
    cupertinoSelectedIcon: CatchIcons.tabChatsFilled,
    showsUnreadBadge: true,
  ),
  AppShellNavigationItem(
    destination: AppShellNavigationDestination.hostOrganizer,
    materialIcon: CatchIcons.tabOrganizer,
    materialSelectedIcon: CatchIcons.tabOrganizerFilled,
    cupertinoIcon: CatchIcons.tabOrganizer,
    cupertinoSelectedIcon: CatchIcons.tabOrganizerFilled,
  ),
];
