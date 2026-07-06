import 'dart:async';

import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_analytics.g.dart';

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

final class NoOpAnalyticsReporter implements AnalyticsReporter {
  const NoOpAnalyticsReporter();

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}

// keepalive: analytics facade keeps user/session attribution stable across
// navigation and background event emission.
@Riverpod(keepAlive: true)
AppAnalytics appAnalytics(Ref ref) => AppAnalytics();

/// Vendor-neutral analytics facade for product and navigation events.
class AppAnalytics {
  AppAnalytics({AnalyticsReporter? reporter, bool? shouldCollect})
    : _shouldCollect = shouldCollect ?? _defaultShouldCollect,
      _reporter =
          reporter ?? _defaultReporter(shouldCollect ?? _defaultShouldCollect);

  final AnalyticsReporter _reporter;
  final bool _shouldCollect;
  Map<String, Object> _baseParameters = const {};

  static bool get _defaultShouldCollect {
    return AppConfig.shouldCollectObservability;
  }

  static AnalyticsReporter _defaultReporter(bool shouldCollect) {
    if (!shouldCollect) return const NoOpAnalyticsReporter();
    return FirebaseAnalyticsReporter(FirebaseAnalytics.instance);
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

  /// Logs a normalized backend failure with non-PII operation context.
  void logBackendOperationFailed({
    required BackendErrorContext context,
    required String errorCode,
    required bool retryable,
    required AppErrorSeverity severity,
  }) {
    logEvent(
      AnalyticsEvents.backendOperationFailed,
      parameters: {
        AnalyticsParameters.backendService: context.service.label,
        AnalyticsParameters.backendAction: context.action,
        AnalyticsParameters.backendResource: context.resource,
        AnalyticsParameters.backendErrorCode: errorCode,
        AnalyticsParameters.backendRetryable: retryable,
        AnalyticsParameters.backendSeverity: severity.name,
        ...context.metadata,
      },
    );
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
  static const welcomeSplashShown = 'welcome_splash_shown';
  static const welcomeSplashSkipped = 'welcome_splash_skipped';
  static const welcomeCtaTapped = 'welcome_cta_tapped';
  static const clubViewed = 'club_viewed';
  static const clubJoined = 'club_joined';
  static const exploreEventOpened = 'explore_event_opened';
  static const exploreMapEventSelected = 'explore_map_event_selected';
  static const homeOpened = 'home_opened';
  static const homeModuleImpression = 'home_module_impression';
  static const homeActionTap = 'home_action_tap';
  static const catchWindowImpression = 'catch_window_impression';
  static const catchWindowOpen = 'catch_window_open';
  static const clubPostCreated = 'club_post_created';
  static const clubPostImpression = 'club_post_impression';
  static const clubPostOpen = 'club_post_open';
  static const eventViewed = 'event_viewed';
  static const eventBookingStarted = 'event_booking_started';
  static const eventBooked = 'event_booked';
  static const eventBookingFailed = 'event_booking_failed';
  static const eventAttended = 'event_attended';
  static const phoneVerified = 'phone_verified';
  static const profileCompleted = 'profile_completed';
  static const postEventReactionSent = 'post_event_reaction_sent';
  static const matchCreated = 'match_created';
  static const hostClubCreated = 'host_club_created';
  static const hostEventCreated = 'host_event_created';
  static const swipeSent = 'swipe_sent';
  static const matchViewed = 'match_viewed';
  static const chatMessageSent = 'chat_message_sent';
  static const profileEdited = 'profile_edited';
  static const backendOperationFailed = 'backend_operation_failed';
  static const observabilitySmoke = 'observability_smoke';
}

abstract final class AnalyticsParameters {
  static const environment = 'environment';
  static const platform = 'platform';
  static const appVersion = 'app_version';
  static const buildNumber = 'build_number';
  static const authMethod = 'auth_method';
  static const onboardingStep = 'onboarding_step';
  static const splashMotion = 'splash_motion';
  static const cta = 'cta';
  static const clubId = 'club_id';
  static const eventId = 'event_id';
  static const activityKind = 'activity_kind';
  static const availabilityStatus = 'availability_status';
  static const exploreSource = 'explore_source';
  static const distanceKm = 'distance_km';
  static const homeState = 'state';
  static const homeModule = 'module';
  static const homeAction = 'action';
  static const surface = 'surface';
  static const matchId = 'match_id';

  // Backend error context. Values must be non-PII.
  static const backendService = 'backend_service';
  static const backendAction = 'backend_action';
  static const backendResource = 'backend_resource';
  static const backendErrorCode = 'backend_error_code';
  static const backendRetryable = 'backend_retryable';
  static const backendSeverity = 'backend_severity';
}
