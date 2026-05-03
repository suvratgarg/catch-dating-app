import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_version_config.freezed.dart';

/// Remote Config parameter defaults used by [setDefaults] at startup.
///
/// When no remote values exist (or the fetch fails), these defaults keep all
/// force-update gates disabled so users are never blocked accidentally.
const kAppVersionConfigDefaults = <String, dynamic>{
  'min_version': '0.0.0',
  'min_build_android': 0,
  'min_build_ios': 0,
  'min_build_web': 0,
  'min_build_macos': 0,
  'store_url_android': '',
  'store_url_ios': '',
};

/// Remote configuration served by Firebase Remote Config.
///
/// Fields:
/// - [minVersion]       — oldest semver allowed to run (e.g. "1.2.0").
///                        Users on an older version see the update screen.
/// - [minBuildAndroid]  — oldest Android build number allowed to run.
/// - [minBuildIos]      — oldest iOS build number allowed to run.
/// - [minBuildWeb]      — oldest web build number allowed to run.
/// - [minBuildMacos]    — oldest macOS build number allowed to run.
/// - [storeUrlAndroid]  — Play Store URL for the app.
/// - [storeUrlIos]      — App Store URL for the app.
@freezed
abstract class AppVersionConfig with _$AppVersionConfig {
  const factory AppVersionConfig({
    @Default('0.0.0') String minVersion,
    @Default(0) int minBuildAndroid,
    @Default(0) int minBuildIos,
    @Default(0) int minBuildWeb,
    @Default(0) int minBuildMacos,
    @Default('') String storeUrlAndroid,
    @Default('') String storeUrlIos,
  }) = _AppVersionConfig;
}
