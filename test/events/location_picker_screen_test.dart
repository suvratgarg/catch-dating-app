import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/presentation/location_picker_screen.dart';
import 'package:catch_dating_app/locations/data/places_repository.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../test_pump_helpers.dart';
import 'events_test_helpers.dart';

void main() {
  group('LocationPickerScreen', () {
    test('stores the initial location argument', () {
      const initialLocation = LocationCoordinate(19.076, 72.8777);
      const screen = LocationPickerScreen(initialLocation: initialLocation);

      expect(screen.initialLocation, initialLocation);
    });

    testWidgets('starts without a selection', (tester) async {
      await pumpEventsTestApp(
        tester,
        const LocationPickerScreen(loadMapTiles: false),
      );

      expect(find.text('Pick starting point'), findsNothing);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(
        find.text('Tap on the map to set the starting point.'),
        findsOneWidget,
      );
      expect(find.byType(CatchTextField), findsOneWidget);
      expect(
        tester
            .widget<CatchTopBarTextAction>(
              find.widgetWithText(CatchTopBarTextAction, 'Confirm'),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('updates the selected point when the map callback fires', (
      tester,
    ) async {
      await pumpEventsTestApp(
        tester,
        const LocationPickerScreen(loadMapTiles: false),
      );

      final googleMap = tester.widget<gmaps.GoogleMap>(
        find.byType(gmaps.GoogleMap),
      );
      expect(googleMap.mapType, gmaps.MapType.none);
      const selectedPoint = LocationCoordinate(19.11, 72.91);
      googleMap.onTap?.call(
        gmaps.LatLng(selectedPoint.latitude, selectedPoint.longitude),
      );
      await tester.pump();

      expect(
        find.text('Starting point selected. Tap elsewhere to adjust.'),
        findsOneWidget,
      );
      expect(find.text('19.110000, 72.910000'), findsNothing);
      expect(
        tester
            .widget<CatchTopBarTextAction>(
              find.widgetWithText(CatchTopBarTextAction, 'Confirm'),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets(
      'uses the initial location and confirms it through navigation',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<LocationCoordinate?>(
                          builder: (_) => const LocationPickerScreen(
                            initialLocation: LocationCoordinate(
                              19.076,
                              72.8777,
                            ),
                            loadMapTiles: false,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await pumpFeatureUi(tester);

        await tester.tap(find.text('Open'));
        await pumpFeatureUi(tester);

        expect(
          find.text('Starting point selected. Tap elsewhere to adjust.'),
          findsOneWidget,
        );
        expect(find.text('19.076000, 72.877700'), findsNothing);
        expect(
          tester
              .widget<CatchTopBarTextAction>(
                find.widgetWithText(CatchTopBarTextAction, 'Confirm'),
              )
              .onPressed,
          isNotNull,
        );

        await tester.tap(find.widgetWithText(CatchTopBarTextAction, 'Confirm'));
        await pumpFeatureUi(tester);

        expect(find.text('Open'), findsOneWidget);
      },
    );

    testWidgets('searches places and uses the selected place coordinates', (
      tester,
    ) async {
      await pumpEventsTestApp(
        tester,
        const LocationPickerScreen(loadMapTiles: false),
        overrides: [
          placesRepositoryProvider.overrideWithValue(
            _FakePlacesRepository(
              suggestions: const [
                PlaceAutocompleteSuggestion(
                  placeId: 'cubbon-park',
                  description: 'Cubbon Park, Bengaluru, Karnataka',
                  mainText: 'Cubbon Park',
                  secondaryText: 'Bengaluru, Karnataka',
                ),
              ],
              placeDetails: const PlaceDetails(
                placeId: 'cubbon-park',
                displayName: 'Cubbon Park',
                formattedAddress: 'Cubbon Park, Bengaluru, Karnataka',
                location: LocationCoordinate(12.9763, 77.5929),
              ),
            ),
          ),
        ],
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Search for a meeting point'),
        'Cubbon',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(find.text('Cubbon Park'), findsOneWidget);
      expect(find.text('Bengaluru, Karnataka'), findsOneWidget);

      await tester.tap(find.text('Cubbon Park'));
      await tester.pump();

      expect(
        find.text('Starting point selected. Tap elsewhere to adjust.'),
        findsOneWidget,
      );
      expect(find.text('12.976300, 77.592900'), findsNothing);
      expect(
        tester
            .widget<CatchTopBarTextAction>(
              find.widgetWithText(CatchTopBarTextAction, 'Confirm'),
            )
            .onPressed,
        isNotNull,
      );
    });
  });
}

class _FakePlacesRepository implements PlacesRepository {
  const _FakePlacesRepository({
    required this.suggestions,
    required this.placeDetails,
  });

  final List<PlaceAutocompleteSuggestion> suggestions;
  final PlaceDetails placeDetails;

  @override
  Future<List<PlaceAutocompleteSuggestion>> autocomplete({
    required String input,
    required String sessionToken,
    LocationCoordinate? bias,
    String? countryIsoCode,
  }) async {
    return suggestions;
  }

  @override
  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  }) async {
    return placeDetails;
  }
}
