import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/create_run_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

void main() {
  group('CreateRunController.submit', () {
    test(
      'creates a run with a generated id and normalized optional fields',
      () async {
        final fakeRunRepository = FakeRunRepository()
          ..generatedId = 'generated-7';
        final container = ProviderContainer(
          overrides: [
            runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(createRunControllerProvider.notifier)
            .submit(
              runClubId: 'club-7',
              startTime: DateTime(2025, 3, 1, 6),
              endTime: DateTime(2025, 3, 1, 7, 15),
              meetingPoint: 'Marine Drive',
              startingPointLat: 19.076,
              startingPointLng: 72.8777,
              locationDetails: null,
              distanceKm: 7.5,
              pace: PaceLevel.moderate,
              capacityLimit: 18,
              description: 'Steady social run',
              priceInPaise: 25000,
              constraints: const RunConstraints(
                minAge: 21,
                maxAge: 35,
                maxMen: 9,
                maxWomen: 9,
              ),
            );

        final createdRun = fakeRunRepository.createdRun;
        expect(createdRun, isNotNull);
        expect(createdRun!.id, 'generated-7');
        expect(createdRun.runClubId, 'club-7');
        expect(createdRun.startTime, DateTime(2025, 3, 1, 6));
        expect(createdRun.endTime, DateTime(2025, 3, 1, 7, 15));
        expect(createdRun.meetingPoint, 'Marine Drive');
        expect(createdRun.startingPointLat, 19.076);
        expect(createdRun.startingPointLng, 72.8777);
        expect(createdRun.locationDetails, isNull);
        expect(createdRun.distanceKm, 7.5);
        expect(createdRun.pace, PaceLevel.moderate);
        expect(createdRun.capacityLimit, 18);
        expect(createdRun.description, 'Steady social run');
        expect(createdRun.priceInPaise, 25000);
        expect(
          createdRun.constraints,
          const RunConstraints(minAge: 21, maxAge: 35, maxMen: 9, maxWomen: 9),
        );
      },
    );
  });
}
