import 'dart:async';

import 'package:catch_dating_app/core/app_error_context.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_release_config.g.dart';

const hostPrivateEventSetupFlagKey = 'host_private_event_setup_enabled';
const hostProgressiveEventDefaultsFlagKey =
    'host_progressive_event_defaults_enabled';

/// Bundled fallback until both the backend and the Remote Config rollout are
/// ready. Auth, privacy, and payment checks remain server owned.
const hostReleaseConfigDefaults = <String, dynamic>{
  hostPrivateEventSetupFlagKey: false,
  hostProgressiveEventDefaultsFlagKey: false,
};

/// Re-read both cached values after an explicit fetch, including when the
/// realtime stream missed an update while the app was backgrounded.
void invalidateHostReleaseFlags(
  void Function(HostReleaseFlagProvider provider) invalidate,
) {
  invalidate(hostReleaseFlagProvider(hostPrivateEventSetupFlagKey));
  invalidate(hostReleaseFlagProvider(hostProgressiveEventDefaultsFlagKey));
}

// keepalive: Release values are shared across Host routes and updated in real
// time, independent of the regular Remote Config fetch interval.
@Riverpod(keepAlive: true)
bool hostReleaseFlag(Ref ref, String key) {
  // A fixture may render a Host route without Firebase. App bootstrap
  // initializes Firebase before production routes read this provider.
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
        logAppError(
          error,
          stackTrace: stackTrace,
          context: const AppErrorContext(
            operation: AppOperation.runtime,
            action: 'activate host release config',
            resource: 'remote_config',
          ),
          logError: logError,
        );
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
