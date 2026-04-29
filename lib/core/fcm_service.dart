import 'package:catch_dating_app/core/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fcm_service.g.dart';

// Must be top-level — called when app is terminated/backgrounded.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI available here. The OS shows the notification automatically.
  // Data-only processing (if needed) goes here.
}

String? chatRouteFromMessageData(Map<String, Object?> data) {
  final matchId = data['matchId'];
  if (matchId is! String || matchId.isEmpty) return null;
  return '/chats/$matchId';
}

void navigateToMessageRoute(GoRouter router, Map<String, Object?> data) {
  final route = chatRouteFromMessageData(data);
  if (route != null) router.go(route);
}

class FcmService {
  FcmService(this._db);

  final FirebaseFirestore _db;

  bool get isSupportedPlatform =>
      AppConfig.supportsPushMessagingOnCurrentPlatform;

  /// Call once when the authenticated shell mounts.
  Future<void> initialize({
    required String uid,
    required GoRouter router,
  }) async {
    if (!isSupportedPlatform) return;

    // Request permission (no-op on Android < 13, required on iOS).
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((t) => _saveToken(uid, t));
    final token = await _currentToken();
    if (token != null) await _saveToken(uid, token);

    // Foreground: the real-time Firestore stream updates the UI automatically.
    // We don't display an OS notification while the app is open, so no handler needed.

    // Background tap: app was open in background, user tapped notification.
    FirebaseMessaging.onMessageOpenedApp.listen(
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

  Future<void> _saveToken(String uid, String token) =>
      _db.collection('users').doc(uid).update({'fcmToken': token});
}

@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) => FcmService(FirebaseFirestore.instance);
