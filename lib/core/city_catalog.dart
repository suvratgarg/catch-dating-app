import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/labelled.dart';

class CityOption implements Labelled {
  const CityOption({
    required this.name,
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  @override
  final String label;
  final double latitude;
  final double longitude;

  CityData toCityData() => CityData(
    name: name,
    label: label,
    latitude: latitude,
    longitude: longitude,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityOption &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

const defaultCityOptions = [
  CityOption(
    name: 'mumbai',
    label: 'Mumbai',
    latitude: 19.0760,
    longitude: 72.8777,
  ),
  CityOption(
    name: 'delhi',
    label: 'Delhi',
    latitude: 28.7041,
    longitude: 77.1025,
  ),
  CityOption(
    name: 'bangalore',
    label: 'Bangalore',
    latitude: 12.9716,
    longitude: 77.5946,
  ),
  CityOption(
    name: 'hyderabad',
    label: 'Hyderabad',
    latitude: 17.3850,
    longitude: 78.4867,
  ),
  CityOption(
    name: 'chennai',
    label: 'Chennai',
    latitude: 13.0827,
    longitude: 80.2707,
  ),
  CityOption(
    name: 'kolkata',
    label: 'Kolkata',
    latitude: 22.5726,
    longitude: 88.3639,
  ),
  CityOption(
    name: 'pune',
    label: 'Pune',
    latitude: 18.5204,
    longitude: 73.8567,
  ),
  CityOption(
    name: 'ahmedabad',
    label: 'Ahmedabad',
    latitude: 23.0225,
    longitude: 72.5714,
  ),
  CityOption(
    name: 'indore',
    label: 'Indore',
    latitude: 22.7196,
    longitude: 75.8577,
  ),
];

final defaultCityData = defaultCityOptions
    .map((city) => city.toCityData())
    .toList(growable: false);

CityOption? cityOptionByName(String? name) {
  if (name == null) return null;
  for (final city in defaultCityOptions) {
    if (city.name == name) return city;
  }
  return null;
}

String cityLabel(String? name) {
  final configured = cityOptionByName(name);
  if (configured != null) return configured.label;
  if (name == null || name.isEmpty) return '';
  return name
      .split(RegExp(r'[-_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
