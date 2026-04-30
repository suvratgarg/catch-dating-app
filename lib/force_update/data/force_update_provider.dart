import 'package:catch_dating_app/force_update/data/app_version_repository.dart';
import 'package:catch_dating_app/force_update/domain/app_version_config.dart';
import 'package:catch_dating_app/force_update/domain/version.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'force_update_provider.g.dart';

/// The current app version string (e.g. "1.2.3") from the platform.
@Riverpod(keepAlive: true)
Future<String> currentAppVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}

/// The current platform build number from pubspec/native metadata.
@Riverpod(keepAlive: true)
Future<String> currentAppBuildNumber(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.buildNumber;
}

/// True when the running version is below the remote [minVersion].
///
/// Loading and error states are surfaced to the app shell so the app does not
/// silently continue when the compatibility check cannot complete.
@Riverpod(keepAlive: true)
AsyncValue<bool> forceUpdateRequired(Ref ref) {
  final configAsync = ref.watch(watchAppVersionConfigProvider);
  final versionAsync = ref.watch(currentAppVersionProvider);
  final buildNumberAsync = ref.watch(currentAppBuildNumberProvider);

  final error = _firstError(configAsync, versionAsync, buildNumberAsync);
  if (error != null) {
    return AsyncValue.error(error.error, error.stackTrace);
  }

  if (configAsync.isLoading ||
      versionAsync.isLoading ||
      buildNumberAsync.isLoading ||
      !configAsync.hasValue ||
      !versionAsync.hasValue ||
      !buildNumberAsync.hasValue) {
    return const AsyncValue.loading();
  }

  final config = configAsync.requireValue;
  final current = versionAsync.requireValue;
  final currentBuild = buildNumberAsync.requireValue;

  final minimumBuild = minimumBuildForCurrentPlatform(config);
  if (minimumBuild > 0) {
    return AsyncValue.data(
      isBuildUpdateRequired(
        currentBuild: currentBuild,
        minimumBuild: minimumBuild,
      ),
    );
  }

  return AsyncValue.data(
    isUpdateRequired(current: current, minimum: config.minVersion),
  );
}

({Object error, StackTrace stackTrace})? _firstError(
  AsyncValue<Object?> config,
  AsyncValue<Object?> version,
  AsyncValue<Object?> buildNumber,
) {
  for (final value in [config, version, buildNumber]) {
    if (value.hasError) {
      return (
        error: value.error!,
        stackTrace: value.stackTrace ?? StackTrace.current,
      );
    }
  }
  return null;
}

@visibleForTesting
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
