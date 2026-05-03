import 'dart:async';

import 'package:catch_dating_app/core/app_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract interface class AnalyticsReporter {
  Future<void> setCollectionEnabled(bool enabled);

  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  Future<void> logScreenView({required String screenName, String? screenClass});

  Future<void> setUserId(String? userId);
}

final class FirebaseAnalyticsReporter implements AnalyticsReporter {
  FirebaseAnalyticsReporter(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  @override
  Future<void> setUserId(String? userId) {
    return _analytics.setUserId(id: userId);
  }
}

final appAnalyticsProvider = Provider<AppAnalytics>((ref) {
  return AppAnalytics();
});

/// Vendor-neutral analytics facade for product and navigation events.
class AppAnalytics {
  AppAnalytics({AnalyticsReporter? reporter, bool? shouldCollect})
    : _reporter =
          reporter ?? FirebaseAnalyticsReporter(FirebaseAnalytics.instance),
      _shouldCollect = shouldCollect ?? _defaultShouldCollect;

  final AnalyticsReporter _reporter;
  final bool _shouldCollect;
  Map<String, Object> _baseParameters = const {};

  static bool get _defaultShouldCollect {
    return kReleaseMode &&
        AppConfig.environment.isProduction &&
        !AppConfig.useFirebaseEmulators;
  }

  Future<void> initialize() async {
    await _reporter.setCollectionEnabled(_shouldCollect);
    if (!_shouldCollect) return;

    final packageInfo = await PackageInfo.fromPlatform();
    _baseParameters = {
      AnalyticsParameters.environment: AppConfig.environmentName,
      AnalyticsParameters.platform: defaultTargetPlatform.name,
      AnalyticsParameters.appVersion: packageInfo.version,
      AnalyticsParameters.buildNumber: packageInfo.buildNumber,
    };
  }

  void logScreenView(String screenName) {
    if (!_shouldCollect) return;
    unawaited(
      _reporter.logScreenView(screenName: screenName, screenClass: 'GoRouter'),
    );
  }

  void logEvent(String name, {Map<String, Object?> parameters = const {}}) {
    if (!_shouldCollect) return;
    final sanitizedParameters = _sanitizeParameters(parameters);

    unawaited(
      _reporter.logEvent(
        _validateEventName(name),
        parameters: {..._baseParameters, ...sanitizedParameters},
      ),
    );
  }

  void setUserId(String? userId) {
    if (!_shouldCollect) return;
    unawaited(_reporter.setUserId(userId));
  }

  /// Logs a Firestore write failure so we can track permission-denied,
  /// network, and quota errors in dashboards alongside Crashlytics.
  void logFirestoreWriteFailed({
    required String collection,
    required String action,
    required String errorCode,
  }) {
    logEvent(AnalyticsEvents.firestoreWriteFailed, parameters: {
      AnalyticsParameters.firestoreCollection: collection,
      AnalyticsParameters.firestoreAction: action,
      AnalyticsParameters.firestoreErrorCode: errorCode,
    });
  }

  static String _validateEventName(String name) {
    final isValid = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{0,39}$').hasMatch(name);
    if (!isValid) {
      throw ArgumentError.value(
        name,
        'name',
        'Analytics event names must start with a letter and contain only letters, numbers, or underscores.',
      );
    }
    return name;
  }

  static Map<String, Object> _sanitizeParameters(
    Map<String, Object?> parameters,
  ) {
    return {
      for (final entry in parameters.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
  }
}

class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AppAnalytics _analytics;
  String? _lastScreenName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _logRoute(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _logRoute(previousRoute);
    }
  }

  void _logRoute(Route<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName == null || screenName.isEmpty) return;
    if (screenName == _lastScreenName) return;

    _lastScreenName = screenName;
    _analytics.logScreenView(screenName);
  }
}

abstract final class AnalyticsEvents {
  static const authStarted = 'auth_started';
  static const authCompleted = 'auth_completed';
  static const onboardingStarted = 'onboarding_started';
  static const onboardingCompleted = 'onboarding_completed';
  static const runClubViewed = 'run_club_viewed';
  static const runClubJoined = 'run_club_joined';
  static const runViewed = 'run_viewed';
  static const runBookingStarted = 'run_booking_started';
  static const runBookingCompleted = 'run_booking_completed';
  static const runBookingFailed = 'run_booking_failed';
  static const swipeSent = 'swipe_sent';
  static const matchViewed = 'match_viewed';
  static const chatMessageSent = 'chat_message_sent';
  static const profileEdited = 'profile_edited';
  static const firestoreWriteFailed = 'firestore_write_failed';
}

abstract final class AnalyticsParameters {
  static const environment = 'environment';
  static const platform = 'platform';
  static const appVersion = 'app_version';
  static const buildNumber = 'build_number';
  static const authMethod = 'auth_method';
  static const onboardingStep = 'onboarding_step';
  static const runClubId = 'run_club_id';
  static const runId = 'run_id';
  static const matchId = 'match_id';

  // Firestore error context
  static const firestoreCollection = 'firestore_collection';
  static const firestoreAction = 'firestore_action';
  static const firestoreErrorCode = 'firestore_error_code';
}
