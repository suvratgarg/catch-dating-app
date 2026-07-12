import 'dart:async';
import 'dart:math';
import 'dart:ui' show PlatformDispatcher;

import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'fcm_service.g.dart';

// Must be top-level — called when app is terminated/backgrounded.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI available here. The OS shows the notification automatically.
  // Data-only processing (if needed) goes here.
}

void registerFirebaseMessagingBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

String? chatRouteFromMessageData(Map<String, Object?> data) {
  final matchId = data['matchId'];
  if (matchId is! String || matchId.isEmpty) return null;
  if (AppConfig.appRole.isHost) return '/host/inbox/$matchId';
  return '/chats/$matchId';
}

String? hostEventManageRouteFromMessageData(Map<String, Object?> data) {
  if (!AppConfig.appRole.isHost) return null;
  final type = data['type'];
  if (type != 'hostEventManage' &&
      type != 'hostEventReady' &&
      type != 'eventHostManage') {
    return null;
  }
  final clubId = data['clubId'];
  final eventId = data['eventId'];
  if (clubId is! String || clubId.isEmpty) return null;
  if (eventId is! String || eventId.isEmpty) return null;
  return '/host/clubs/$clubId/events/$eventId/manage';
}

String? eventCompanionRouteFromMessageData(Map<String, Object?> data) {
  if (AppConfig.appRole.isHost) return null;
  if (data['type'] != 'eventCompanionReady') return null;
  final clubId = data['clubId'];
  final eventId = data['eventId'];
  if (clubId is! String || clubId.isEmpty) return null;
  if (eventId is! String || eventId.isEmpty) return null;
  return '/clubs/$clubId/events/$eventId/companion';
}

String? eventDetailRouteFromMessageData(Map<String, Object?> data) {
  if (AppConfig.appRole.isHost) return null;
  const eventActivityTypes = {
    'eventReminder',
    'eventSignup',
    'waitlistPromotion',
    'waitlistOffer',
    'waitlistOfferExpiring',
    'waitlistOfferExpired',
    'eventCancelled',
    'eventUpdated',
  };
  if (!eventActivityTypes.contains(data['type'])) return null;
  final clubId = data['clubId'];
  final eventId = data['eventId'];
  if (clubId is! String || clubId.isEmpty) return null;
  if (eventId is! String || eventId.isEmpty) return null;
  return '/clubs/$clubId/events/$eventId';
}

String? routeFromMessageData(Map<String, Object?> data) =>
    hostEventManageRouteFromMessageData(data) ??
    chatRouteFromMessageData(data) ??
    eventCompanionRouteFromMessageData(data) ??
    eventDetailRouteFromMessageData(data);

void navigateToMessageRoute(GoRouter router, Map<String, Object?> data) {
  final route = routeFromMessageData(data);
  if (route != null) router.go(route);
}

class FcmService {
  FcmService(this._db, this._errorLogger);

  static const _installationIdPreferenceKey = 'catch.pushInstallationId';

  final FirebaseFirestore _db;
  final ErrorLogger _errorLogger;
  Future<void>? _initialization;
  Future<String>? _installationId;
  String? _initializedUid;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  bool get isSupportedPlatform =>
      AppConfig.supportsPushMessagingOnCurrentPlatform;

  /// Call once when the authenticated shell mounts.
  Future<void> initialize({
    required String uid,
    required GoRouter router,
  }) async {
    if (!isSupportedPlatform) return;
    final currentInitialization = _initialization;
    if (_initializedUid == uid && currentInitialization != null) {
      return currentInitialization;
    }

    _initializedUid = uid;
    final initialization = withBackendErrorContext(
      () => _initialize(uid: uid, router: router),
      context: const BackendErrorContext(
        service: BackendService.messaging,
        action: 'initialize push notifications',
        resource: 'push_notifications',
      ),
    );
    _initialization = initialization;

    try {
      await initialization;
    } catch (_) {
      if (identical(_initialization, initialization)) {
        _initialization = null;
        _initializedUid = null;
      }
      rethrow;
    }
  }

  Future<void> reset() async {
    _initialization = null;
    _initializedUid = null;
    await _tokenRefreshSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _messageOpenedSubscription = null;
  }

  Future<void> _initialize({
    required String uid,
    required GoRouter router,
  }) async {
    await reset();
    _initializedUid = uid;

    // Request permission (no-op on Android < 13, required on iOS).
    await FirebaseMessaging.instance.requestPermission();

    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => unawaited(_saveToken(uid, token)));
    final token = await _currentToken();
    if (token != null) await _saveToken(uid, token);

    // Foreground: the real-time Firestore stream updates the UI automatically.
    // We don't display an OS notification while the app is open, so no handler needed.

    // Background tap: app was open in background, user tapped notification.
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (msg) => _handleTap(router, msg),
    );

    // Terminated tap: app was closed, user tapped notification.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleTap(router, initial);
  }

  void _handleTap(GoRouter router, RemoteMessage message) {
    navigateToMessageRoute(router, message.data);
  }

  Future<String?> _currentToken() async {
    if (kIsWeb) {
      return FirebaseMessaging.instance.getToken(
        vapidKey: AppConfig.firebaseWebVapidKey,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _waitForApnsToken();
      if (apnsToken == null) return null;
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }

    return FirebaseMessaging.instance.getToken();
  }

  Future<String?> _waitForApnsToken({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final token = await FirebaseMessaging.instance.getAPNSToken();
      if (token != null) return token;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return FirebaseMessaging.instance.getAPNSToken();
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      final installationId = await _pushInstallationId();
      final packageInfo = await PackageInfo.fromPlatform();
      final userRef = _db.collection('users').doc(uid);
      await userRef.collection('pushInstallations').doc(installationId).set({
        'token': token,
        'appRole': AppConfig.appRoleName,
        'environment': AppConfig.environmentName,
        'platform': _platformName,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
        'timeZone': DateTime.now().timeZoneName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Legacy compatibility for existing consumer notification senders.
      if (!AppConfig.appRole.isHost) {
        await userRef.update({'fcmToken': token});
      }
    } catch (e, st) {
      _errorLogger.logAppException(
        normalizeBackendError(
          e,
          stackTrace: st,
          context: const BackendErrorContext(
            service: BackendService.firestore,
            action: 'save push token',
            resource: 'users',
          ),
        ),
      );
    }
  }

  Future<String> _pushInstallationId() {
    return _installationId ??= _loadOrCreatePushInstallationId();
  }

  Future<String> _loadOrCreatePushInstallationId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_installationIdPreferenceKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated =
        '${AppConfig.appRoleName}_${_platformName}_'
        '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}_'
        '${Random.secure().nextInt(1 << 31).toRadixString(36)}';
    await prefs.setString(_installationIdPreferenceKey, generated);
    return generated;
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}

// keepalive: FCM service owns app-wide token/message registration lifecycle.
@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) {
  final service = FcmService(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(errorLoggerProvider),
  );
  ref.onDispose(() => unawaited(service.reset()));
  return service;
}
