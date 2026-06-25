import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import 'events_test_helpers.dart';

void main() {
  testWidgets('shows a map-shaped skeleton while map events load', (
    tester,
  ) async {
    await pumpEventsTestApp(
      tester,
      const EventMapView(
        enableNetworkTiles: false,
        viewModel: AsyncLoading<EventMapViewModel>(),
      ),
      overrides: [
        deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
        selectedExploreCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(find.byType(EventMapLoadingBody), findsOneWidget);
    expect(find.byType(CatchSkeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No mapped events yet'), findsNothing);
  });

  testWidgets('shows an empty state when no map events are available', (
    tester,
  ) async {
    await pumpEventsTestApp(
      tester,
      const EventMapView(enableNetworkTiles: false),
      overrides: [
        eventMapViewModelProvider.overrideWith(
          (ref) =>
              const AsyncData(EventMapViewModel(events: [], pinnedEvents: [])),
        ),
        deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
        selectedExploreCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(find.text('No mapped events yet'), findsOneWidget);
    expect(find.text('Nearby events'), findsNothing);
  });

  testWidgets('shows no-pinned state without a nearby-events sheet', (
    tester,
  ) async {
    final unpinned = buildEvent(
      id: 'unpinned',
      meetingPoint: 'Race Course Road main gate',
      startTime: DateTime.now().add(const Duration(days: 1)),
    );

    await pumpEventsTestApp(
      tester,
      const EventMapView(enableNetworkTiles: false),
      overrides: [
        eventMapViewModelProvider.overrideWith(
          (ref) => AsyncData(
            EventMapViewModel(events: [unpinned], pinnedEvents: const []),
          ),
        ),
        deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
        selectedExploreCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(find.text('No exact pins yet'), findsOneWidget);
    expect(find.text('Nearby events'), findsNothing);
    expect(find.text('Race Course Road main gate'), findsNothing);
    expect(find.text('No pin'), findsNothing);
  });

  testWidgets('selecting a map marker makes its pin the camera target', (
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
      const EventMapView(enableNetworkTiles: false),
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
        selectedExploreCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(
      tester
          .widget<EventPinsMap>(find.byType(EventPinsMap))
          .selectedEventCenter,
      isNull,
    );

    await tester.tap(find.bySemanticsLabel('Select Vijay Nagar main gate'));
    await tester.pump();

    final map = tester.widget<EventPinsMap>(find.byType(EventPinsMap));
    expect(map.selectedEventId, 'second-event');
    expect(map.selectedEventCenter, const LocationCoordinate(22.75, 75.9));
  });

  testWidgets('event pin maps use Google default map styling', (tester) async {
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
          items: [EventMapItem(event: event, status: EventTileStatus.open)],
          initialCenter: const LocationCoordinate(22.72, 75.86),
        ),
      ),
    );
    await tester.pump();

    final googleMap = tester.widget<gmaps.GoogleMap>(
      find.byType(gmaps.GoogleMap),
    );

    expect(googleMap.style, isNull);
  });

  testWidgets('event pin maps expose native marker info windows', (
    tester,
  ) async {
    final event = buildEvent(
      id: 'info-event',
      meetingPoint: 'Race Course Road main gate',
      startTime: DateTime(2026, 5, 27, 17, 42),
      startingPointLat: 22.72,
      startingPointLng: 75.86,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EventPinsMap(
          items: [EventMapItem(event: event, status: EventTileStatus.full)],
          initialCenter: const LocationCoordinate(22.72, 75.86),
        ),
      ),
    );
    await tester.pump();

    final googleMap = tester.widget<gmaps.GoogleMap>(
      find.byType(gmaps.GoogleMap),
    );
    final marker = googleMap.markers.single;

    expect(marker.infoWindow.title, '5:42 PM · Wednesday Evening Run');
    expect(marker.infoWindow.snippet, 'Race Course Road main gate');
  });

  testWidgets('event pin maps expose user dot and distance ring circles', (
    tester,
  ) async {
    var ringTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EventPinsMap(
          items: const <EventMapItem>[],
          initialCenter: const LocationCoordinate(22.72, 75.86),
          userLocation: const LocationCoordinate(22.72, 75.86),
          distanceRingRadiusKm: 3,
          onDistanceRingTapped: () => ringTaps += 1,
        ),
      ),
    );
    await tester.pump();

    final googleMap = tester.widget<gmaps.GoogleMap>(
      find.byType(gmaps.GoogleMap),
    );
    final circleIds = googleMap.circles.map((circle) => circle.circleId.value);

    expect(circleIds, contains('event-map-user-location'));
    expect(circleIds, contains('event-map-distance-ring'));

    googleMap.circles
        .singleWhere(
          (circle) => circle.circleId.value == 'event-map-distance-ring',
        )
        .onTap!();
    expect(ringTaps, 1);
  });

  testWidgets('event pin maps report initial and moved camera centers', (
    tester,
  ) async {
    final centers = <LocationCoordinate>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EventPinsMap(
          items: const <EventMapItem>[],
          initialCenter: const LocationCoordinate(22.72, 75.86),
          onCameraCenterChanged: centers.add,
        ),
      ),
    );
    await tester.pump();

    expect(centers, [const LocationCoordinate(22.72, 75.86)]);

    final googleMap = tester.widget<gmaps.GoogleMap>(
      find.byType(gmaps.GoogleMap),
    );
    googleMap.onCameraMove!(
      const gmaps.CameraPosition(target: gmaps.LatLng(22.75, 75.9), zoom: 13),
    );
    googleMap.onCameraIdle!();

    expect(centers.last, const LocationCoordinate(22.75, 75.9));
  });

  testWidgets('event pin maps cluster dense pins at low zoom', (tester) async {
    final events = [
      for (var i = 0; i < 8; i += 1)
        buildEvent(
          id: 'dense-$i',
          meetingPoint: 'Dense marker $i',
          startingPointLat: 22.72 + i * 0.0001,
          startingPointLng: 75.86 + i * 0.0001,
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EventPinsMap(
          items: [
            for (final event in events)
              EventMapItem(event: event, status: EventTileStatus.open),
          ],
          initialCenter: const LocationCoordinate(22.72, 75.86),
          initialZoom: 12,
        ),
      ),
    );
    await tester.pump();

    final googleMap = tester.widget<gmaps.GoogleMap>(
      find.byType(gmaps.GoogleMap),
    );

    expect(googleMap.markers, hasLength(1));
    expect(googleMap.markers.single.markerId.value, startsWith('cluster-'));
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
