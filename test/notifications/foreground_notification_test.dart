import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/notifications/domain/foreground_notification.dart';
import 'package:catch_dating_app/notifications/presentation/foreground_notification_controller.dart';
import 'package:catch_dating_app/notifications/presentation/foreground_notification_listener.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_pump_helpers.dart';

void main() {
  ForegroundNotification? parse(
    Map<String, Object?> data, {
    AppRole role = AppRole.consumer,
  }) => ForegroundNotification.parse(
    data: data,
    uid: 'me',
    role: role,
    deliveryId: 'delivery',
  );

  test('only match/message events with valid targets are accepted', () {
    for (final data in [
      <String, Object?>{},
      {'type': 'eventReminder', 'matchId': 'abc'},
      {'type': 'message', 'matchId': '../other'},
      {'type': 'message', 'matchId': 'abc', 'recipientUid': 'other'},
      {'type': 'message', 'matchId': 'abc', 'appRole': 'host'},
    ]) {
      expect(parse(data), isNull);
    }
    expect(
      parse({'type': 'match', 'matchId': 'abc'}, role: AppRole.host),
      isNull,
    );
    expect(parse({'type': 'message', 'matchId': 'abc'})!.route, '/chats/abc');
    expect(
      parse({'type': 'message', 'matchId': 'abc'}, role: AppRole.host)!.route,
      '/host/inbox/abc',
    );
  });

  test('network URLs cannot supply navigation and avatar must be HTTPS', () {
    final event = parse({
      'type': 'message',
      'matchId': 'abc',
      'route': 'https://evil.example',
      'actorName': 'Ananya',
      'actorAvatarUrl': 'javascript:bad',
    })!;
    expect(event.route, '/chats/abc');
    expect(event.actorAvatarUrl, isNull);
    expect(event.actorName, 'Ananya');
  });

  test(
    'session gate dedupes events and clears queue on account/lifecycle changes',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(
        foregroundNotificationControllerProvider.notifier,
      );
      controller.receive('me', _message());
      expect(container.read(foregroundNotificationControllerProvider), isNull);
      controller.startSession('me');
      controller.receive('me', _message());
      final event = container.read(foregroundNotificationControllerProvider)!;
      controller.receive('me', _message());
      expect(
        container.read(foregroundNotificationControllerProvider),
        same(event),
      );
      container
          .read(catchNoticeControllerProvider.notifier)
          .show(
            CatchNoticeData.arrival(
              id: event.id,
              title: 'Pending',
              onOpen: () {},
            ),
          );
      controller.startSession('someone-else');
      expect(container.read(catchNoticeControllerProvider).notices, isEmpty);
      expect(controller.canOpen(event), isFalse);
      controller.receive('me', _message('late'));
      expect(container.read(foregroundNotificationControllerProvider), isNull);
      controller.startSession('me');
      controller.setForeground(false);
      controller.receive('me', _message('background'));
      expect(container.read(foregroundNotificationControllerProvider), isNull);
      controller.setForeground(true);
      controller.receive('me', _message('resumed'));
      expect(
        container.read(foregroundNotificationControllerProvider),
        isNotNull,
      );
    },
  );

  testWidgets(
    'foreground receipt renders globally, taps route, and active chat suppresses another card',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final chatPath = AppConfig.appRole.isHost
          ? '/host/inbox/abc'
          : '/chats/abc';
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('Home route')),
          ),
          GoRoute(
            path: '/pushed',
            builder: (_, _) => const Scaffold(body: Text('Pushed route')),
          ),
          GoRoute(
            path: chatPath,
            builder: (_, _) =>
                const Scaffold(body: Text('Opened conversation')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (_, child) => CatchNoticeHost(
              child: ForegroundNotificationListener(
                router: router,
                child: child!,
              ),
            ),
          ),
        ),
      );
      router.go('/pushed');
      await pumpFeatureUi(tester);
      final controller = container.read(
        foregroundNotificationControllerProvider.notifier,
      );
      controller.startSession('me');
      controller.receive('me', _message());
      await pumpFeatureUi(tester);
      expect(find.byType(CatchNotice), findsOneWidget);
      expect(find.text('Pushed route'), findsOneWidget);
      expect(find.text('Ananya'), findsOneWidget);
      await tester.tap(find.byType(CatchNotice));
      await pumpFeatureUi(tester);
      expect(find.text('Opened conversation'), findsOneWidget);
      expect(find.byType(CatchNotice), findsNothing);
      controller.receive('me', _message('next'));
      await tester.pump();
      expect(find.byType(CatchNotice), findsNothing);
      router.go('/pushed');
      await pumpFeatureUi(tester);
      controller.receive('me', _message('older-queued'));
      controller.receive(
        'me',
        RemoteMessage(
          messageId: 'newer-other-chat',
          notification: const RemoteNotification(title: 'Other chat'),
          data: {..._message().data, 'matchId': 'other'},
        ),
      );
      await pumpFeatureUi(tester);
      expect(
        container.read(catchNoticeControllerProvider).notices,
        hasLength(2),
      );
      router.go(chatPath);
      await pumpFeatureUi(tester);
      final queued = container.read(catchNoticeControllerProvider).notices;
      expect(queued, hasLength(1));
      expect(queued.single.title, 'Other chat');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(container.read(catchNoticeControllerProvider).notices, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.byType(CatchNotice), findsNothing);
    },
  );
}

RemoteMessage _message([String id = 'one']) => RemoteMessage(
  messageId: id,
  notification: const RemoteNotification(title: 'Ananya', body: 'Hello there'),
  data: const {
    'type': 'message',
    'matchId': 'abc',
    'recipientUid': 'me',
    'actorName': 'Ananya',
  },
);
