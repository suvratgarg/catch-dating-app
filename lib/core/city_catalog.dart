import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/labelled.dart';

class CityOption implements Labelled {
  const CityOption({
    required this.name,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.countryIsoCode,
    required this.currencyCode,
    required this.dialCode,
    required this.timeZone,
  });

  final String name;
  @override
  final String label;
  final double latitude;
  final double longitude;
  final String countryIsoCode;
  final String currencyCode;
  final String dialCode;
  final String timeZone;

  CityData toCityData() => CityData(
    name: name,
    label: label,
    latitude: latitude,
    longitude: longitude,
    countryIsoCode: countryIsoCode,
    currencyCode: currencyCode,
    dialCode: dialCode,
    timeZone: timeZone,
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
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'delhi',
    label: 'Delhi',
    latitude: 28.7041,
    longitude: 77.1025,
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'bangalore',
    label: 'Bangalore',
    latitude: 12.9716,
    longitude: 77.5946,
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'hyderabad',
    label: 'Hyderabad',
    latitude: 17.3850,
    longitude: 78.4867,
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'chennai',
    label: 'Chennai',
    latitude: 13.0827,
    longitude: 80.2707,
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'kolkata',
    label: 'Kolkata',
    latitude: 22.5726,
    longitude: 88.3639,
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'pune',
    label: 'Pune',
    latitude: 18.5204,
    longitude: 73.8567,
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'ahmedabad',
    label: 'Ahmedabad',
    latitude: 23.0225,
    longitude: 72.5714,
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'indore',
    label: 'Indore',
    latitude: 22.7196,
    longitude: 75.8577,
    countryIsoCode: 'IN',
    currencyCode: 'INR',
    dialCode: '+91',
    timeZone: 'Asia/Kolkata',
  ),
  CityOption(
    name: 'kathmandu',
    label: 'Kathmandu',
    latitude: 27.7172,
    longitude: 85.3240,
    countryIsoCode: 'NP',
    currencyCode: 'NPR',
    dialCode: '+977',
    timeZone: 'Asia/Kathmandu',
  ),
  CityOption(
    name: 'pokhara',
    label: 'Pokhara',
    latitude: 28.2096,
    longitude: 83.9856,
    countryIsoCode: 'NP',
    currencyCode: 'NPR',
    dialCode: '+977',
    timeZone: 'Asia/Kathmandu',
  ),
  CityOption(
    name: 'sydney',
    label: 'Sydney',
    latitude: -33.8688,
    longitude: 151.2093,
    countryIsoCode: 'AU',
    currencyCode: 'AUD',
    dialCode: '+61',
    timeZone: 'Australia/Sydney',
  ),
  CityOption(
    name: 'melbourne',
    label: 'Melbourne',
    latitude: -37.8136,
    longitude: 144.9631,
    countryIsoCode: 'AU',
    currencyCode: 'AUD',
    dialCode: '+61',
    timeZone: 'Australia/Melbourne',
  ),
  CityOption(
    name: 'brisbane',
    label: 'Brisbane',
    latitude: -27.4698,
    longitude: 153.0251,
    countryIsoCode: 'AU',
    currencyCode: 'AUD',
    dialCode: '+61',
    timeZone: 'Australia/Brisbane',
  ),
  CityOption(
    name: 'new-york',
    label: 'New York',
    latitude: 40.7128,
    longitude: -74.0060,
    countryIsoCode: 'US',
    currencyCode: 'USD',
    dialCode: '+1',
    timeZone: 'America/New_York',
  ),
  CityOption(
    name: 'san-francisco',
    label: 'San Francisco',
    latitude: 37.7749,
    longitude: -122.4194,
    countryIsoCode: 'US',
    currencyCode: 'USD',
    dialCode: '+1',
    timeZone: 'America/Los_Angeles',
  ),
  CityOption(
    name: 'los-angeles',
    label: 'Los Angeles',
    latitude: 34.0522,
    longitude: -118.2437,
    countryIsoCode: 'US',
    currencyCode: 'USD',
    dialCode: '+1',
    timeZone: 'America/Los_Angeles',
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

CityData defaultCityDataForMarket([
  CountryMarket market = defaultCountryMarket,
]) {
  final configured = cityOptionByName(market.defaultCityName);
  return configured?.toCityData() ?? defaultCityData.first;
}

CountryMarket marketForCityName(String? cityName) {
  final city = cityOptionByName(cityName);
  return marketForIsoCode(city?.countryIsoCode);
}

String countryIsoCodeForCityName(String? cityName) =>
    marketForCityName(cityName).isoCode;

String currencyCodeForCityName(String? cityName) =>
    marketForCityName(cityName).currencyCode;

String dialCodeForCityName(String? cityName) =>
    marketForCityName(cityName).dialCode;
