import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/force_update/domain/app_version_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version_config_provider.g.dart';

/// Reads the force-update config from the already-initialized Remote Config
/// singleton so the paired-down Firebase initialization sequence in [main]
/// is complete.
///
/// Reads are synchronous — all Remote Config values were fetched and activated
/// at startup, falling back to [kAppVersionConfigDefaults] when the fetch
/// failed.
@Riverpod(keepAlive: true)
AppVersionConfig appVersionConfig(Ref ref) {
  final remoteConfig = ref.watch(firebaseRemoteConfigProvider);
  return AppVersionConfig(
    minVersion: remoteConfig.getString('min_version'),
    minBuildAndroid: remoteConfig.getInt('min_build_android'),
    minBuildIos: remoteConfig.getInt('min_build_ios'),
    minBuildWeb: remoteConfig.getInt('min_build_web'),
    minBuildMacos: remoteConfig.getInt('min_build_macos'),
    storeUrlAndroid: remoteConfig.getString('store_url_android'),
    storeUrlIos: remoteConfig.getString('store_url_ios'),
  );
}
