import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_version_config.freezed.dart';
part 'app_version_config.g.dart';

/// Remote configuration document stored at Firestore path `config/app_config`.
///
/// Fields:
/// - [minVersion]       — oldest version allowed to run (e.g. "1.2.0").
///                        Users on an older version see the update screen.
/// - [storeUrlAndroid]  — Play Store URL for the app.
/// - [storeUrlIos]      — App Store URL for the app.
@freezed
abstract class AppVersionConfig with _$AppVersionConfig {
  const factory AppVersionConfig({
    @Default('0.0.0') String minVersion,
    @Default('') String storeUrlAndroid,
    @Default('') String storeUrlIos,
  }) = _AppVersionConfig;

  factory AppVersionConfig.fromJson(Map<String, dynamic> json) =>
      _$AppVersionConfigFromJson(json);
}
