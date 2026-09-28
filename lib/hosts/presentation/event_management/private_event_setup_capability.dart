import 'dart:async';

import 'package:catch_dating_app/core/app_error_context.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'private_event_setup_capability.g.dart';

const hostPrivateEventSetupFlagKey = 'host_private_event_setup_enabled';
const hostProgressiveEventDefaultsFlagKey =
    'host_progressive_event_defaults_enabled';

/// Bundled fallback until both the backend and the Remote Config rollout are
/// ready. Auth, privacy, and payment checks remain server owned.
const hostReleaseConfigDefaults = <String, dynamic>{
  hostPrivateEventSetupFlagKey: false,
  hostProgressiveEventDefaultsFlagKey: false,
};

/// Read-only release capability seam; overrides belong to local fixtures.
// keepalive: The flag is shared across routes and refreshed on app resume.
@Riverpod(keepAlive: true, name: 'privateEventSetupAvailableProvider')
bool privateEventSetupCapability(Ref ref) =>
    _hostReleaseFlag(ref, hostPrivateEventSetupFlagKey);

// keepalive: The same remote rollout is shared by every organizer defaults view.
@Riverpod(keepAlive: true, name: 'progressiveEventDefaultsAvailableProvider')
bool progressiveEventDefaultsCapability(Ref ref) =>
    _hostReleaseFlag(ref, hostProgressiveEventDefaultsFlagKey);

bool _hostReleaseFlag(Ref ref, String key) {
  // A fixture may render a Host route without Firebase. Avoid mounting the
  // Firebase provider in error/retry state; app bootstrap initializes it first.
  if (Firebase.apps.isEmpty) return false;
  final remoteConfig = ref.watch(firebaseRemoteConfigProvider);
  final logError = ref.read(errorLoggerProvider);
  var active = true;
  void report(Object error, StackTrace stackTrace) => logAppError(
    error,
    stackTrace: stackTrace,
    context: const AppErrorContext(
      operation: AppOperation.runtime,
      action: 'activate host release config',
      resource: 'remote_config',
    ),
    logError: logError,
  );
  final subscription = remoteConfig.onConfigUpdated.listen((update) {
    unawaited(() async {
      try {
        await activateHostReleaseUpdate(
          updatedKeys: update.updatedKeys,
          key: key,
          activate: remoteConfig.activate,
          onActivated: () {
            if (active) ref.invalidateSelf();
          },
        );
      } catch (error, stackTrace) {
        report(error, stackTrace);
      }
    }());
  }, onError: report);
  ref.onDispose(() {
    active = false;
    unawaited(subscription.cancel());
  });
  return hostReleaseFlagValue(remoteConfig, key);
}

bool hostReleaseFlagValue(FirebaseRemoteConfig remoteConfig, String key) =>
    remoteConfig.getBool(key);

/// Apply only an update for this capability, then read the newly activated
/// value through the provider. An activation failure keeps its cached value.
Future<void> activateHostReleaseUpdate({
  required Set<String> updatedKeys,
  required String key,
  required Future<bool> Function() activate,
  required void Function() onActivated,
}) async {
  if (!updatedKeys.contains(key)) return;
  await activate();
  onActivated();
}
