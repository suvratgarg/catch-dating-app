import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndianCity', () {
    test('every city has valid coordinates', () {
      for (final city in IndianCity.values) {
        expect(city.latitude, inClosedOpenRange(-90, 90));
        expect(city.longitude, inClosedOpenRange(-180, 180));
      }
    });

    test('coordinates getter returns LocationCoordinate', () {
      expect(
        IndianCity.mumbai.coordinates,
        const LocationCoordinate(19.0760, 72.8777),
      );
    });

    group('nearestCity', () {
      test('returns Mumbai for a position in Mumbai', () {
        // Right at Mumbai city center
        final result = IndianCity.nearestCity(
          const LocationCoordinate(19.0760, 72.8777),
        );
        expect(result, IndianCity.mumbai);
      });

      test('returns Delhi for a position in Delhi', () {
        // Near Delhi center
        final result = IndianCity.nearestCity(
          const LocationCoordinate(28.7041, 77.1025),
        );
        expect(result, IndianCity.delhi);
      });

      test('returns the closest city for a position between two cities', () {
        // South of Pune, clearly closer to Pune than Mumbai.
        final result = IndianCity.nearestCity(
          const LocationCoordinate(18.0, 74.0),
        );
        expect(result, IndianCity.pune);
      });

      test('returns Bangalore for a position in southern India', () {
        final result = IndianCity.nearestCity(
          const LocationCoordinate(12.0, 77.0),
        );
        expect(result, IndianCity.bangalore);
      });

      test('returns non-null for any valid position', () {
        final result = IndianCity.nearestCity(const LocationCoordinate(0, 0));
        expect(result, isNotNull);
        // (0,0) is in the Atlantic — closest to Mumbai
      });
    });
  });
}
