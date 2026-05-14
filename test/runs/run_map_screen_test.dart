import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/runs/presentation/run_map_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_map_view_model.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_pins_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'runs_test_helpers.dart';

void main() {
  testWidgets('shows an empty state when no map runs are available', (
    tester,
  ) async {
    await pumpRunsTestApp(
      tester,
      const RunMapScreen(enableNetworkTiles: false),
      overrides: [
        runMapViewModelProvider.overrideWith(
          (ref) => const AsyncData(RunMapViewModel(runs: [], pinnedRuns: [])),
        ),
        deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
        selectedRunClubCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(find.text('No mapped runs yet'), findsOneWidget);
    expect(find.text('Nearby runs'), findsNothing);
  });

  testWidgets('keeps run sheet visible when upcoming runs have no exact pins', (
    tester,
  ) async {
    final unpinned = buildRun(
      id: 'unpinned',
      meetingPoint: 'Race Course Road main gate',
      startTime: DateTime.now().add(const Duration(days: 1)),
    );

    await pumpRunsTestApp(
      tester,
      const RunMapScreen(enableNetworkTiles: false),
      overrides: [
        runMapViewModelProvider.overrideWith(
          (ref) => AsyncData(
            RunMapViewModel(runs: [unpinned], pinnedRuns: const []),
          ),
        ),
        deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
        selectedRunClubCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(find.text('No exact pins yet'), findsOneWidget);
    expect(find.text('Nearby runs'), findsOneWidget);
    expect(find.text('Race Course Road main gate'), findsOneWidget);
    expect(find.text('No pin'), findsOneWidget);
  });

  testWidgets('view run opens the dashboard run detail route', (tester) async {
    final run = buildRun(
      id: 'run-map-1',
      runClubId: 'club-map-1',
      meetingPoint: 'Race Course Road main gate',
      startTime: DateTime.now().add(const Duration(days: 1)),
      startingPointLat: 22.72,
      startingPointLng: 75.86,
    );
    final router = GoRouter(
      initialLocation: Routes.runMapScreen.path,
      routes: [
        GoRoute(
          path: Routes.runMapScreen.path,
          name: Routes.runMapScreen.name,
          builder: (_, _) => const RunMapScreen(enableNetworkTiles: false),
        ),
        GoRoute(
          path: Routes.dashboardRunDetailScreen.path,
          name: Routes.dashboardRunDetailScreen.name,
          builder: (_, state) => Scaffold(
            body: Text(
              'Run detail ${state.pathParameters['runClubId']}/'
              '${state.pathParameters['runId']}',
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          runMapViewModelProvider.overrideWith(
            (ref) => AsyncData(RunMapViewModel(runs: [run], pinnedRuns: [run])),
          ),
          deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
          selectedRunClubCityProvider.overrideWithValue(_mumbai),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('View run'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pump();

    expect(find.text('Run detail club-map-1/run-map-1'), findsOneWidget);
  });

  testWidgets('selecting a nearby run makes its pin the camera target', (
    tester,
  ) async {
    final firstRun = buildRun(
      id: 'first-run',
      meetingPoint: 'Race Course Road main gate',
      startingPointLat: 22.72,
      startingPointLng: 75.86,
    );
    final secondRun = buildRun(
      id: 'second-run',
      meetingPoint: 'Vijay Nagar main gate',
      startingPointLat: 22.75,
      startingPointLng: 75.9,
    );

    await pumpRunsTestApp(
      tester,
      const RunMapScreen(enableNetworkTiles: false),
      overrides: [
        runMapViewModelProvider.overrideWith(
          (ref) => AsyncData(
            RunMapViewModel(
              runs: [firstRun, secondRun],
              pinnedRuns: [firstRun, secondRun],
            ),
          ),
        ),
        deviceLocationProvider.overrideWith(() => _FakeDeviceLocation(null)),
        selectedRunClubCityProvider.overrideWithValue(_mumbai),
      ],
    );

    expect(
      tester.widget<RunPinsMap>(find.byType(RunPinsMap)).selectedRunCenter,
      isNull,
    );

    await tester.tap(find.text('Vijay Nagar main gate'));
    await tester.pump();

    final map = tester.widget<RunPinsMap>(find.byType(RunPinsMap));
    expect(map.selectedRunId, 'second-run');
    expect(map.selectedRunCenter, const LocationCoordinate(22.75, 75.9));
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
