import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/runs/presentation/run_map_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_map_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(find.text('No exact pin'), findsOneWidget);
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
