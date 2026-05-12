import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_data.freezed.dart';
part 'city_data.g.dart';

/// A supported city sourced from the `config/cities` Firestore document.
///
/// This is the app-facing city representation for UI selection, nearest-city
/// detection, and server-side validation.
@freezed
abstract class CityData with _$CityData {
  const factory CityData({
    /// Machine name, e.g. `'mumbai'`, `'delhi'`, or lowercase kebab-case for
    /// newer city regions.
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
