import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('city catalog', () {
    test('default city options have stable names, labels, and coordinates', () {
      expect(defaultCityOptions.map((city) => city.name), contains('mumbai'));
      expect(
        defaultCityOptions.map((city) => city.name),
        contains('kathmandu'),
      );
      expect(defaultCityOptions.map((city) => city.name), contains('sydney'));
      expect(defaultCityOptions.map((city) => city.name), contains('new-york'));
      expect(cityLabel('mumbai'), 'Mumbai');

      for (final city in defaultCityOptions) {
        expect(city.label, isNotEmpty);
        expect(city.latitude, inClosedOpenRange(-90, 90));
        expect(city.longitude, inClosedOpenRange(-180, 180));
        expect(city.countryIsoCode, hasLength(2));
        expect(city.currencyCode, hasLength(3));
        expect(city.dialCode, startsWith('+'));
        expect(city.timeZone, contains('/'));
      }
    });

    test('derives market metadata from city names', () {
      expect(currencyCodeForCityName('sydney'), 'AUD');
      expect(dialCodeForCityName('kathmandu'), '+977');
      expect(marketForCityName('new-york').isoCode, 'US');
      expect(defaultCityDataForMarket().name, 'mumbai');
    });

    test('unknown city labels fall back to title case', () {
      expect(cityLabel('race-course-road'), 'Race Course Road');
      expect(cityOptionByName('unknown-city'), isNull);
    });
  });
}
