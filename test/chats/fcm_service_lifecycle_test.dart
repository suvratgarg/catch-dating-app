import 'dart:async';

import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/notifications/presentation/foreground_notification_controller.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_pump_helpers.dart';

class _Settings extends Fake implements NotificationSettings {}

class _Messaging extends Fake implements FirebaseMessaging {
  final refresh = StreamController<String>.broadcast();
  final permissionStarted = Completer<void>();
  final initialStarted = Completer<void>();
  Completer<RemoteMessage?>? initialGate;
  Completer<void>? permissionGate;
  String? token;
  bool failDelete = false;
  int permissions = 0;
  int deletes = 0;
  int presentations = 0;

  Future<void> dispose() => refresh.close();

  @override
  Stream<String> get onTokenRefresh => refresh.stream;

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async {
    permissions++;
    if (!permissionStarted.isCompleted) permissionStarted.complete();
    await permissionGate?.future;
    return _Settings();
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    expect([alert, badge, sound], [false, false, false]);
    presentations++;
  }

  @override
  Future<String?> getToken({
    String? vapidKey,
    String? serviceWorkerScriptPath,
  }) async => token;
  @override
  Future<RemoteMessage?> getInitialMessage() async {
    if (!initialStarted.isCompleted) initialStarted.complete();
    return initialGate?.future;
  }

  @override
  Future<void> deleteToken() async {
    deletes++;
    if (failDelete) throw StateError('network unavailable');
  }
}

class _SupportedFcm extends FcmService {
  _SupportedFcm(
    FakeFirebaseFirestore db,
    _Messaging sdk,
    Stream<RemoteMessage> foreground,
    Stream<RemoteMessage> opened,
  ) : super(
        db,
        ErrorLogger.silent(),
        messaging: sdk,
        foregroundMessages: foreground,
        openedMessages: opened,
      );
  @override
  bool get isSupportedPlatform => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Messaging sdk;
  late FakeFirebaseFirestore db;
  late StreamController<RemoteMessage> foreground;
  late StreamController<RemoteMessage> opened;
  late FcmService service;
  late GoRouter router;
  final delivered = <String>[];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Catch',
      packageName: 'catch.test',
      version: '1',
      buildNumber: '1',
      buildSignature: '',
    );
    db = FakeFirebaseFirestore();
    sdk = _Messaging();
    foreground = StreamController<RemoteMessage>.broadcast();
    opened = StreamController<RemoteMessage>.broadcast();
    service = _SupportedFcm(db, sdk, foreground.stream, opened.stream);
    router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
    );
    delivered.clear();
  });
  tearDown(() async {
    await service.reset();
    await foreground.close();
    await opened.close();
    await sdk.dispose();
    router.dispose();
  });

  Future<void> initialize(String uid) => service.initialize(
    uid: uid,
    router: router,
    onForegroundMessage: (message) => delivered.add(message.messageId!),
  );

  RemoteMessage message(String id, {String uid = 'one', String? role}) =>
      RemoteMessage(
        messageId: id,
        data: {
          'type': 'message',
          'matchId': 'chat',
          'recipientUid': uid,
          'appRole': role ?? AppConfig.appRoleName,
        },
      );

  test(
    'shared shell initialization connects actual SDK stream to arrivals',
    () async {
      final container = ProviderContainer(
        overrides: [fcmServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      await container.read(
        appShellFcmInitializationProvider('one', router).future,
      );
      foreground.add(message('through-shared-shell'));
      await flushTestEventQueue();
      final event = container.read(foregroundNotificationControllerProvider)!;
      expect(event.uid, 'one');
      expect(event.role, AppConfig.appRole);
      expect(event.matchId, 'chat');
    },
  );

  test(
    'one subscription per session, explicit app/recipient validation, reset',
    () async {
      await Future.wait([initialize('one'), initialize('one')]);
      expect(sdk.permissions, 1);
      expect(sdk.presentations, 1);
      foreground.add(message('valid'));
      foreground.add(message('wrong-user', uid: 'two'));
      foreground.add(
        message(
          'wrong-app',
          role: AppConfig.appRole.isHost ? 'consumer' : 'host',
        ),
      );
      await flushTestEventQueue();
      expect(delivered, ['valid']);
      await service.reset();
      expect(foreground.hasListener, false);
      expect(opened.hasListener, false);
      expect(sdk.refresh.hasListener, false);
      foreground.add(message('after-logout'));
      await flushTestEventQueue();
      expect(delivered, ['valid']);
    },
  );

  test(
    'logout during initial-message lookup cannot navigate afterwards',
    () async {
      sdk.initialGate = Completer<RemoteMessage?>();
      final initialization = initialize('one');
      await sdk.initialStarted.future;
      await service.reset();
      sdk.initialGate!.complete(message('initial'));
      await initialization;
      expect(router.routeInformationProvider.value.uri.path, '/');
    },
  );

  test(
    'an upgraded installation rotates its previously unscoped address',
    () async {
      SharedPreferences.setMockInitialValues({
        'catch.pushInstallationId': 'legacy',
      });
      await initialize('one');
      expect(sdk.deletes, 1);
    },
  );

  test(
    'logout during permission prompt cannot reattach token/tap listeners',
    () async {
      sdk.permissionGate = Completer<void>();
      final initialization = initialize('one');
      await sdk.permissionStarted.future;
      await service.reset();
      sdk.permissionGate!.complete();
      await initialization;
      expect(sdk.presentations, 0);
      expect(sdk.refresh.hasListener, false);
      expect(foreground.hasListener, false);
      expect(opened.hasListener, false);
    },
  );

  test(
    'account replacement rotates address and rejects previous recipient',
    () async {
      await initialize('one');
      await initialize('two');
      expect(sdk.deletes, 1);
      foreground.add(message('old'));
      foreground.add(message('new', uid: 'two'));
      await flushTestEventQueue();
      expect(delivered, ['new']);
    },
  );

  test(
    'unregister removes only this installation and matching legacy token',
    () async {
      sdk.token = 'this-device';
      await db.collection('users').doc('one').set({});
      await initialize('one');
      final user = db.collection('users').doc('one');
      final devices = await user.collection('pushInstallations').get();
      expect(devices.docs.single.data()['appRole'], AppConfig.appRoleName);
      await user.collection('pushInstallations').doc('other').set({
        'token': 'other-device',
      });
      await service.unregisterCurrentInstallation();
      expect(
        (await user.collection('pushInstallations').get()).docs.map(
          (d) => d.id,
        ),
        ['other'],
      );
      expect((await user.get()).data()!.containsKey('fcmToken'), false);
      expect(sdk.deletes, 1);
      expect(foreground.hasListener, false);
    },
  );

  test(
    'failed offline revocation blocks token reuse until rotation succeeds',
    () async {
      await initialize('one');
      sdk.failDelete = true;
      await service.unregisterCurrentInstallation();
      await expectLater(initialize('two'), throwsA(anything));
      expect(foreground.hasListener, false);
      sdk.failDelete = false;
      await initialize('two');
      expect(foreground.hasListener, true);
      expect(
        (await SharedPreferences.getInstance()).getBool(
          'catch.pushTokenNeedsRevocation',
        ),
        isNull,
      );
    },
  );
}
