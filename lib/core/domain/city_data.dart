import 'package:catch_dating_app/core/country_markets.dart';
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
    /// newer city regions. City names must stay globally unique.
    required String name,

    /// Human-readable label (e.g. `'Mumbai'`, `'New Delhi'`).
    required String label,

    /// Latitude for GPS-based nearest-city detection.
    required double latitude,

    /// Longitude for GPS-based nearest-city detection.
    required double longitude,

    /// ISO 3166-1 alpha-2 country code for market-specific behavior.
    @Default(defaultCountryIsoCode) String countryIsoCode,

    /// Currency used for event price display and future provider routing.
    @Default(defaultCurrencyCode) String currencyCode,

    /// Local phone dial code used for contact/auth defaults in this market.
    @Default(defaultCountryDialCode) String dialCode,

    /// IANA timezone for event scheduling and future localized display.
    @Default(defaultTimeZone) String timeZone,
  }) = _CityData;

  factory CityData.fromJson(Map<String, dynamic> json) =>
      _$CityDataFromJson(json);
}
