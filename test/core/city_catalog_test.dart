import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('city catalog', () {
    test('default city options have stable names, labels, and coordinates', () {
      expect(defaultCityOptions.map((city) => city.name), contains('mumbai'));
      expect(cityLabel('mumbai'), 'Mumbai');

      for (final city in defaultCityOptions) {
        expect(city.label, isNotEmpty);
        expect(city.latitude, inClosedOpenRange(-90, 90));
        expect(city.longitude, inClosedOpenRange(-180, 180));
      }
    });

    test('unknown city labels fall back to title case', () {
      expect(cityLabel('race-course-road'), 'Race Course Road');
      expect(cityOptionByName('unknown-city'), isNull);
    });
  });
}
