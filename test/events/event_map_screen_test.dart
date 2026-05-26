import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/presentation/catch_google_map_style.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import 'events_test_helpers.dart';

void main() {
  testWidgets('shows an empty state when no map events are available', (
    tester,
  ) async {
    await pumpEventsTestApp(
      tester,
      const EventMapScreen(enableNetworkTiles: false),
      overrides: [
        eventMapViewModelProvider.overrideWith(
          (ref) =>
              const AsyncData(EventMapViewModel(events: [], pinnedEvents: [])),
        ),
        deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
        selectedClubCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(find.text('No mapped events yet'), findsOneWidget);
    expect(find.text('Nearby events'), findsNothing);
  });

  testWidgets(
    'keeps event sheet visible when upcoming events have no exact pins',
    (tester) async {
      final unpinned = buildEvent(
        id: 'unpinned',
        meetingPoint: 'Race Course Road main gate',
        startTime: DateTime.now().add(const Duration(days: 1)),
      );

      await pumpEventsTestApp(
        tester,
        const EventMapScreen(enableNetworkTiles: false),
        overrides: [
          eventMapViewModelProvider.overrideWith(
            (ref) => AsyncData(
              EventMapViewModel(events: [unpinned], pinnedEvents: const []),
            ),
          ),
          deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
          selectedClubCityProvider.overrideWithValue(_mumbai),
        ],
      );

      expect(find.text('No exact pins yet'), findsOneWidget);
      expect(find.text('Nearby events'), findsOneWidget);
      expect(find.text('Race Course Road main gate'), findsOneWidget);
      expect(find.text('No pin'), findsOneWidget);
    },
  );

  testWidgets('view event opens the club event detail route', (tester) async {
    final event = buildEvent(
      id: 'event-map-1',
      clubId: 'club-map-1',
      meetingPoint: 'Race Course Road main gate',
      startTime: DateTime.now().add(const Duration(days: 1)),
      startingPointLat: 22.72,
      startingPointLng: 75.86,
    );
    final router = GoRouter(
      initialLocation: Routes.eventMapScreen.path,
      routes: [
        GoRoute(
          path: Routes.eventMapScreen.path,
          name: Routes.eventMapScreen.name,
          builder: (_, _) => const EventMapScreen(enableNetworkTiles: false),
        ),
        GoRoute(
          path: Routes.eventDetailScreen.path,
          name: Routes.eventDetailScreen.name,
          builder: (_, state) => Scaffold(
            body: Text(
              'Event detail ${state.pathParameters['clubId']}/'
              '${state.pathParameters['eventId']}',
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventMapViewModelProvider.overrideWith(
            (ref) => AsyncData(
              EventMapViewModel(events: [event], pinnedEvents: [event]),
            ),
          ),
          deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
          selectedClubCityProvider.overrideWithValue(_mumbai),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('View event'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pump();

    expect(find.text('Event detail club-map-1/event-map-1'), findsOneWidget);
  });

  testWidgets('selecting a nearby event makes its pin the camera target', (
    tester,
  ) async {
    final firstRun = buildEvent(
      id: 'first-event',
      meetingPoint: 'Race Course Road main gate',
      startingPointLat: 22.72,
      startingPointLng: 75.86,
    );
    final secondRun = buildEvent(
      id: 'second-event',
      meetingPoint: 'Vijay Nagar main gate',
      startingPointLat: 22.75,
      startingPointLng: 75.9,
    );

    await pumpEventsTestApp(
      tester,
      const EventMapScreen(enableNetworkTiles: false),
      overrides: [
        eventMapViewModelProvider.overrideWith(
          (ref) => AsyncData(
            EventMapViewModel(
              events: [firstRun, secondRun],
              pinnedEvents: [firstRun, secondRun],
            ),
          ),
        ),
        deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
        selectedClubCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(
      tester
          .widget<EventPinsMap>(find.byType(EventPinsMap))
          .selectedEventCenter,
      isNull,
    );

    await tester.tap(find.text('Vijay Nagar main gate'));
    await tester.pump();

    final map = tester.widget<EventPinsMap>(find.byType(EventPinsMap));
    expect(map.selectedEventId, 'second-event');
    expect(map.selectedEventCenter, const LocationCoordinate(22.75, 75.9));
  });

  testWidgets('event pin maps use the active app brightness style', (
    tester,
  ) async {
    final event = buildEvent(
      id: 'styled-event',
      meetingPoint: 'Race Course Road main gate',
      startingPointLat: 22.72,
      startingPointLng: 75.86,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: EventPinsMap(
          items: [
            EventMapItem(event: event, status: EventTileStatus.open),
          ],
          initialCenter: const LocationCoordinate(22.72, 75.86),
        ),
      ),
    );
    await tester.pump();

    final googleMap = tester.widget<gmaps.GoogleMap>(
      find.byType(gmaps.GoogleMap),
    );

    expect(googleMap.style, catchGoogleMapStyleFor(Brightness.dark));
  });
}

const _mumbai = CityData(
  name: 'mumbai',
  label: 'Mumbai',
  latitude: 19.076,
  longitude: 72.8777,
);

class _FakeDeviceLocation extends DeviceLocation {
  _FakeDeviceLocation(this.location);

  final LocationCoordinate? location;

  @override
  Future<LocationCoordinate?> build() async => location;
}
