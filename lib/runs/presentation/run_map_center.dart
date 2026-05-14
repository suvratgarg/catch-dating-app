import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';

LocationCoordinate resolveRunMapInitialCenter({
  LocationCoordinate? deviceLocation,
  required CityData selectedCity,
  required bool selectedCityWasUserSelected,
}) {
  if (!selectedCityWasUserSelected && deviceLocation != null) {
    return deviceLocation;
  }

  return LocationCoordinate(selectedCity.latitude, selectedCity.longitude);
}
