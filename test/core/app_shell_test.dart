import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/app_shell_keys.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('connectivityResultsAreOffline', () {
    test('treats empty and none-only results as offline', () {
      expect(connectivityResultsAreOffline(const []), isTrue);
      expect(
        connectivityResultsAreOffline(const [ConnectivityResult.none]),
        isTrue,
      );
    });

    test('treats any real transport as online', () {
      expect(
        connectivityResultsAreOffline(const [
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ]),
        isFalse,
      );
    });
  });

  testWidgets('chat navigation badge stays inside its icon box', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Center(
          child: AppShellNavigationBadge(
            count: 3,
            child: Icon(CatchIcons.chatBubbleOutlineRounded),
          ),
        ),
      ),
    );

    final badgeBox = find.byWidgetPredicate(
      (widget) =>
          widget is SizedBox && widget.width == 38 && widget.height == 30,
    );
    final boxRect = tester.getRect(badgeBox);
    final labelRect = tester.getRect(find.text('3'));

    expect(labelRect.top, greaterThanOrEqualTo(boxRect.top));
    expect(labelRect.right, lessThanOrEqualTo(boxRect.right));
  });

  testWidgets('iOS navigation bar keeps native tab metrics with large text', (
    tester,
  ) async {
    final previousPlatformOverride = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    try {
      int? tappedIndex;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(393, 852),
              padding: EdgeInsets.only(bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
              textScaler: TextScaler.linear(1.6),
            ),
            child: Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: AppShellNavigationBar(
                currentIndex: 0,
                unreadCount: 3,
                onDestinationSelected: (index) => tappedIndex = index,
              ),
            ),
          ),
        ),
      );

      final tabBar = tester.widget<CupertinoTabBar>(
        find.byKey(AppShellKeys.navigationBar),
      );
      expect(tabBar.height, 50);
      expect(tabBar.iconSize, 30);

      final labelContext = tester.element(find.text('Home'));
      expect(MediaQuery.textScalerOf(labelContext).scale(10), 10);
      expect(tester.getSize(find.text('Home')).height, lessThan(14));

      await tester.tap(find.text('Explore'));
      expect(tappedIndex, 1);
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatformOverride;
    }
  });

  test('app notice controller dedupes notices by key', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(appNoticeControllerProvider.notifier);
    controller.show(
      const AppNotice(
        id: 'match.first',
        title: 'First match',
        dedupeKey: 'match',
      ),
    );
    controller.show(
      const AppNotice(
        id: 'match.second',
        title: 'Second match',
        dedupeKey: 'match',
      ),
    );

    final notices = container.read(appNoticeControllerProvider).notices;
    expect(notices, hasLength(1));
    expect(notices.single.title, 'Second match');
  });

  testWidgets('persistent app notices render below the safe area', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(393, 852),
              padding: EdgeInsets.only(top: 59),
            ),
            child: Scaffold(
              body: CatchNoticeHost(
                persistentNotices: [AppNotice.offline()],
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );

    final notice = find.byKey(
      const ValueKey('app_notice.connectivity.offline'),
    );
    expect(notice, findsOneWidget);
    expect(find.byType(MaterialBanner), findsNothing);
    expect(tester.getTopLeft(notice).dy, greaterThanOrEqualTo(59 + 12));
  });

  testWidgets('ephemeral app notices dismiss after their duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: CatchNoticeHost(child: SizedBox.expand())),
        ),
      ),
    );

    final context = tester.element(find.byType(CatchNoticeHost));
    ProviderScope.containerOf(context)
        .read(appNoticeControllerProvider.notifier)
        .show(
          const AppNotice(
            id: 'match.created',
            title: 'New match',
            message: 'You matched with Ananya.',
            tone: CatchNoticeTone.event,
            duration: Duration(milliseconds: 20),
          ),
        );

    await tester.pump();
    expect(find.text('New match'), findsOneWidget);

    final autoDismissDelay = const Duration(milliseconds: 25);
    await tester.pump(autoDismissDelay);
    await tester.pump();
    expect(find.text('New match'), findsNothing);
  });
}
