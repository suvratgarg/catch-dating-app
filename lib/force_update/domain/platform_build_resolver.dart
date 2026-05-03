import 'package:catch_dating_app/force_update/domain/app_version_config.dart';
import 'package:flutter/foundation.dart';

/// Returns the minimum build number that applies to the current platform.
///
/// Platform parameters are exposed so tests can override them without changing
/// [defaultTargetPlatform] or [kIsWeb].
int minimumBuildForCurrentPlatform(
  AppVersionConfig config, {
  TargetPlatform? platform,
  bool? isWeb,
}) {
  if (isWeb ?? kIsWeb) return config.minBuildWeb;

  return switch (platform ?? defaultTargetPlatform) {
    TargetPlatform.android => config.minBuildAndroid,
    TargetPlatform.iOS => config.minBuildIos,
    TargetPlatform.macOS => config.minBuildMacos,
    _ => 0,
  };
}
