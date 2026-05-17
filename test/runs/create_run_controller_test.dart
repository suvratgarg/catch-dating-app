import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/create_run_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'runs_test_helpers.dart';

class FakeRunImageUploadRepository extends Fake
    implements ImageUploadRepository {
  String uploadResult = 'https://img.example/runs/generated-7.jpg';
  String? uploadedRunClubId;
  String? uploadedRunId;
  XFile? uploadedImage;

  @override
  Future<String> uploadRunPhoto({
    required String runClubId,
    required String runId,
    required XFile image,
  }) async {
    uploadedRunClubId = runClubId;
    uploadedRunId = runId;
    uploadedImage = image;
    return uploadResult;
  }
}

void main() {
  group('CreateRunController.submit', () {
    test('creates a run with a generated id and normalized fields', () async {
      final fakeRunRepository = FakeRunRepository()
        ..generatedId = 'generated-7';
      final fakeImageUploadRepository = FakeRunImageUploadRepository();
      final photo = XFile('selected-run-photo.jpg');
      final container = ProviderContainer(
        overrides: [
          runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(createRunControllerProvider.notifier)
          .submit(
            runClubId: '  club-7  ',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7, 15),
            meetingPoint: '  Marine Drive  ',
            startingPointLat: 19.076,
            startingPointLng: 72.8777,
            locationDetails: '   ',
            distanceKm: 7.5,
            pace: PaceLevel.moderate,
            description: '  Steady social run  ',
            constraints: const RunConstraints(
              minAge: 21,
              maxAge: 35,
              maxMen: 9,
              maxWomen: 9,
            ),
            eventPolicy: EventPolicyBundle.fixedCohortCapsRun(
              capacityLimit: 18,
              basePriceInPaise: 25000,
              maxMenInterestedInWomen: 9,
              maxWomenInterestedInMen: 9,
            ),
            photoImage: photo,
          );

      final createdRun = fakeRunRepository.createdRun;
      expect(createdRun, isNotNull);
      expect(createdRun!.id, 'generated-7');
      expect(fakeImageUploadRepository.uploadedRunClubId, 'club-7');
      expect(fakeImageUploadRepository.uploadedRunId, 'generated-7');
      expect(fakeImageUploadRepository.uploadedImage, photo);
      expect(createdRun.runClubId, 'club-7');
      expect(createdRun.startTime, DateTime(2025, 3, 1, 6));
      expect(createdRun.endTime, DateTime(2025, 3, 1, 7, 15));
      expect(createdRun.meetingPoint, 'Marine Drive');
      expect(createdRun.startingPointLat, 19.076);
      expect(createdRun.startingPointLng, 72.8777);
      expect(createdRun.locationDetails, isNull);
      expect(createdRun.photoUrl, 'https://img.example/runs/generated-7.jpg');
      expect(createdRun.distanceKm, 7.5);
      expect(createdRun.pace, PaceLevel.moderate);
      expect(createdRun.capacityLimit, 18);
      expect(createdRun.description, 'Steady social run');
      expect(createdRun.priceInPaise, 25000);
      expect(createdRun.eventPolicy, isNotNull);
      expect(
        createdRun.constraints,
        const RunConstraints(minAge: 21, maxAge: 35, maxMen: 9, maxWomen: 9),
      );
    });

    test(
      'rejects invalid create-run inputs before touching the repository',
      () async {
        final fakeRunRepository = FakeRunRepository();
        final container = ProviderContainer(
          overrides: [
            runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(createRunControllerProvider.notifier);

        await expectLater(
          () => controller.submit(
            runClubId: '',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Run',
            constraints: const RunConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            runClubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Run',
            constraints: const RunConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            runClubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 6),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Run',
            constraints: const RunConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            runClubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: '   ',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Run',
            constraints: const RunConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            runClubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 0,
            pace: PaceLevel.easy,
            description: 'Run',
            constraints: const RunConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            runClubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Run',
            constraints: const RunConstraints(),
            eventPolicy: _eventPolicy(capacityLimit: 0),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            runClubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Run',
            constraints: const RunConstraints(),
            eventPolicy: _eventPolicy(basePriceInPaise: -1),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            runClubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            startingPointLat: 19.076,
            startingPointLng: 181,
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Run',
            constraints: const RunConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        expect(fakeRunRepository.createdRun, isNull);
      },
    );
  });
}

EventPolicyBundle _eventPolicy({
  int capacityLimit = 10,
  int basePriceInPaise = 0,
}) {
  return EventPolicyBundle.openRun(
    capacityLimit: capacityLimit,
    basePriceInPaise: basePriceInPaise,
  );
}
