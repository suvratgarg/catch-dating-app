import 'package:catch_dating_app/core/labelled.dart';
import 'package:latlong2/latlong.dart';

enum IndianCity implements Labelled {
  mumbai('Mumbai', 19.0760, 72.8777),
  delhi('Delhi', 28.7041, 77.1025),
  bangalore('Bangalore', 12.9716, 77.5946),
  hyderabad('Hyderabad', 17.3850, 78.4867),
  chennai('Chennai', 13.0827, 80.2707),
  kolkata('Kolkata', 22.5726, 88.3639),
  pune('Pune', 18.5204, 73.8567),
  ahmedabad('Ahmedabad', 23.0225, 72.5714),
  indore('Indore', 22.7196, 75.8577);

  const IndianCity(this.label, this.latitude, this.longitude);
  @override
  final String label;
  final double latitude;
  final double longitude;

  LatLng get coordinates => LatLng(latitude, longitude);

  /// Returns the city closest to [position], or null if no cities are defined.
  @Deprecated('Use CityRepository.nearestCity() via cityListProvider instead.')
  static IndianCity? nearestCity(LatLng position) {
    IndianCity? closest;
    double minDistance = double.infinity;
    const distanceCalc = Distance();
    for (final city in values) {
      final d = distanceCalc(city.coordinates, position);
      if (d < minDistance) {
        minDistance = d;
        closest = city;
      }
    }
    return closest;
  }

  /// Looks up an [IndianCity] by its enum value name (e.g. `'mumbai'`).
  ///
  /// Returns `null` when [name] doesn't match any known city — callers
  /// should fall back to [CityData]-based lookup via [cityListProvider].
  static IndianCity? fromName(String name) {
    for (final city in values) {
      if (city.name == name) return city;
    }
    return null;
  }

  /// The 9 hardcoded city defaults used as a fallback when the Firestore
  /// `config/cities` document is unavailable.
  static List<IndianCity> get defaults => values;
}
