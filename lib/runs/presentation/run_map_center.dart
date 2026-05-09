import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/runs/domain/run.dart';

const fallbackRunMapCenter = LocationCoordinate(19.0760, 72.8777);

LocationCoordinate resolveRunMapInitialCenter({
  LocationCoordinate? deviceLocation,
  CityData? selectedCity,
  Iterable<Run> pinnedRuns = const <Run>[],
}) {
  final device = deviceLocation;
  if (device != null) return device;

  final city = selectedCity;
  if (city != null) return LocationCoordinate(city.latitude, city.longitude);

  for (final run in pinnedRuns) {
    final lat = run.startingPointLat;
    final lng = run.startingPointLng;
    if (lat != null && lng != null) return LocationCoordinate(lat, lng);
  }

  return fallbackRunMapCenter;
}
