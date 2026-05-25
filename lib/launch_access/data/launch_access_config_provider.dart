import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/launch_access/domain/launch_access_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_access_config_provider.g.dart';

/// Reads launch-access rollout controls from the already initialized Remote
/// Config singleton.
///
/// This provider is intentionally not wired into routing yet. When the router
/// starts using it, the bundled default keeps the gate off unless Remote Config
/// explicitly enables it.
@Riverpod(keepAlive: true)
LaunchAccessConfig launchAccessConfig(Ref ref) {
  final remoteConfig = ref.watch(firebaseRemoteConfigProvider);
  return LaunchAccessConfig(
    gateEnabled: remoteConfig.getBool(LaunchAccessConfig.enableGateKey),
  );
}
