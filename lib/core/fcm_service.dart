import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fcm_service.g.dart';

// Must be top-level — called when app is terminated/backgrounded.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI available here. The OS shows the notification automatically.
  // Data-only processing (if needed) goes here.
}

class FcmService {
  FcmService(this._db);

  final FirebaseFirestore _db;

  /// Call once when the authenticated shell mounts.
  Future<void> initialize({
    required String uid,
    required GoRouter router,
  }) async {
    // Register the background handler before anything else.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission (no-op on Android < 13, required on iOS).
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Store the current token, then keep it up-to-date.
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _saveToken(uid, token);
    FirebaseMessaging.instance.onTokenRefresh
        .listen((t) => _saveToken(uid, t));

    // Foreground: the real-time Firestore stream updates the UI automatically.
    // We don't display an OS notification while the app is open, so no handler needed.

    // Background tap: app was open in background, user tapped notification.
    FirebaseMessaging.onMessageOpenedApp
        .listen((msg) => _handleTap(router, msg));

    // Terminated tap: app was closed, user tapped notification.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleTap(router, initial);
  }

  void _handleTap(GoRouter router, RemoteMessage message) {
    final matchId = message.data['matchId'] as String?;
    if (matchId != null) {
      router.go('/matches/$matchId');
    }
  }

  Future<void> _saveToken(String uid, String token) => _db
      .collection('users')
      .doc(uid)
      .update({'fcmToken': token});
}

@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) => FcmService(FirebaseFirestore.instance);
