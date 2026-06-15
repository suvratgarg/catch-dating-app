import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final hostAppShellFcmInitializationProvider = FutureProvider.family
    .autoDispose<void, String>((ref, uid) async {
      final fcmService = ref.watch(fcmServiceProvider);
      if (!fcmService.isSupportedPlatform) return;

      await fcmService.initialize(uid: uid, router: ref.read(goRouterProvider));
    });

class HostAppShell extends ConsumerWidget {
  const HostAppShell({super.key, required this.navigationShell});

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

    if (isAuthenticated) {
      ref.watch(hostAppShellFcmInitializationProvider(uid));
      ref.listen(hostAppShellFcmInitializationProvider(uid), (previous, next) {
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
    ref.listen(uidProvider, (previous, next) {
      final nextUid = next.asData?.value;
      errorLogger.setUserId(
        nextUid == null || nextUid.isEmpty ? null : nextUid,
      );
      if (nextUid == null && previous?.asData?.value != null) {
        unawaited(ref.read(fcmServiceProvider).reset());
      }
    });

    return Scaffold(
      body: CatchNoticeHost(
        persistentNotices: [if (isOffline) const CatchNoticeData.offline()],
        child: navigationShell,
      ),
      bottomNavigationBar: isAuthenticated
          ? AppShellNavigationBar(
              currentIndex: navigationShell.currentIndex,
              unreadCount: unreadCount,
              items: _hostNavigationItems,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            )
          : null,
    );
  }
}

final _hostNavigationItems = [
  AppShellNavigationItem(
    label: 'Events',
    materialIcon: CatchIcons.calendarMonthOutlined,
    materialSelectedIcon: CatchIcons.calendarMonthOutlined,
    cupertinoIcon: CupertinoIcons.calendar,
    cupertinoSelectedIcon: CupertinoIcons.calendar,
  ),
  AppShellNavigationItem(
    label: 'Clubs',
    materialIcon: CatchIcons.groupsOutlined,
    materialSelectedIcon: CatchIcons.groupsRounded,
    cupertinoIcon: CupertinoIcons.person_2,
    cupertinoSelectedIcon: CupertinoIcons.person_2_fill,
  ),
  AppShellNavigationItem(
    label: 'Inbox',
    materialIcon: CatchIcons.chatBubbleOutlineRounded,
    materialSelectedIcon: CatchIcons.chatBubbleRounded,
    cupertinoIcon: CupertinoIcons.chat_bubble_2,
    cupertinoSelectedIcon: CupertinoIcons.chat_bubble_2_fill,
    showsUnreadBadge: true,
  ),
  AppShellNavigationItem(
    label: 'Account',
    materialIcon: CatchIcons.settingsOutlined,
    materialSelectedIcon: CatchIcons.settingsOutlined,
    cupertinoIcon: CupertinoIcons.gear,
    cupertinoSelectedIcon: CupertinoIcons.gear,
  ),
];
