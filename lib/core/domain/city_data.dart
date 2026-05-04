import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_data.freezed.dart';
part 'city_data.g.dart';

/// A supported city sourced from the `config/cities` Firestore document.
///
/// This replaces the hardcoded [IndianCity] enum for UI selection and
/// server-side validation. The enum is kept for backward compatibility
/// with existing Firestore documents that store city as an enum string.
@freezed
abstract class CityData with _$CityData {
  const factory CityData({
    /// Machine name — matches the [IndianCity] enum value for existing
    /// cities (e.g. `'mumbai'`, `'delhi'`). New cities use lowercase
    /// kebab-case (e.g. `'jaipur'`, `'noida'`).
    required String name,

    /// Human-readable label (e.g. `'Mumbai'`, `'New Delhi'`).
    required String label,

    /// Latitude for GPS-based nearest-city detection.
    required double latitude,

    /// Longitude for GPS-based nearest-city detection.
    required double longitude,
  }) = _CityData;

  factory CityData.fromJson(Map<String, dynamic> json) =>
      _$CityDataFromJson(json);
}
