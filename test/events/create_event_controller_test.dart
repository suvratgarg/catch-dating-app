import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/presentation/create_event_controller.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'events_test_helpers.dart';

class FakeRunImageUploadRepository extends Fake
    implements ImageUploadRepository {
  String uploadResult = 'https://img.example/events/generated-7.jpg';
  String? uploadedClubId;
  String? uploadedEventId;
  XFile? uploadedImage;

  @override
  Future<String> uploadEventPhoto({
    required String clubId,
    required String eventId,
    required XFile image,
  }) async {
    uploadedClubId = clubId;
    uploadedEventId = eventId;
    uploadedImage = image;
    return uploadResult;
  }
}

void main() {
  group('CreateEventController.submit', () {
    test(
      'creates an event with a generated id and normalized fields',
      () async {
        final fakeEventRepository = FakeEventRepository()
          ..generatedId = 'generated-7';
        final fakeImageUploadRepository = FakeRunImageUploadRepository();
        final photo = XFile('selected-event-photo.jpg');
        final container = ProviderContainer(
          overrides: [
            eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
            imageUploadRepositoryProvider.overrideWith(
              (ref) => fakeImageUploadRepository,
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(createEventControllerProvider.notifier)
            .submit(
              clubId: '  club-7  ',
              startTime: DateTime(2025, 3, 1, 6),
              endTime: DateTime(2025, 3, 1, 7, 15),
              meetingPoint: '  Marine Drive  ',
              startingPointLat: 19.076,
              startingPointLng: 72.8777,
              locationDetails: '   ',
              distanceKm: 7.5,
              pace: PaceLevel.moderate,
              description: '  Steady social event  ',
              constraints: const EventConstraints(
                minAge: 21,
                maxAge: 35,
                maxMen: 9,
                maxWomen: 9,
              ),
              eventPolicy: EventPolicyBundle.fixedCohortCapsEvent(
                capacityLimit: 18,
                basePriceInPaise: 25000,
                maxMenInterestedInWomen: 9,
                maxWomenInterestedInMen: 9,
              ),
              photoImage: photo,
            );

        final createdEvent = fakeEventRepository.createdEvent;
        expect(createdEvent, isNotNull);
        expect(createdEvent!.id, 'generated-7');
        expect(fakeImageUploadRepository.uploadedClubId, 'club-7');
        expect(fakeImageUploadRepository.uploadedEventId, 'generated-7');
        expect(fakeImageUploadRepository.uploadedImage, photo);
        expect(createdEvent.clubId, 'club-7');
        expect(createdEvent.startTime, DateTime(2025, 3, 1, 6));
        expect(createdEvent.endTime, DateTime(2025, 3, 1, 7, 15));
        expect(createdEvent.meetingPoint, 'Marine Drive');
        expect(createdEvent.startingPointLat, 19.076);
        expect(createdEvent.startingPointLng, 72.8777);
        expect(createdEvent.locationDetails, isNull);
        expect(
          createdEvent.photoUrl,
          'https://img.example/events/generated-7.jpg',
        );
        expect(createdEvent.distanceKm, 7.5);
        expect(createdEvent.pace, PaceLevel.moderate);
        expect(createdEvent.capacityLimit, 18);
        expect(createdEvent.description, 'Steady social event');
        expect(createdEvent.priceInPaise, 25000);
        expect(createdEvent.eventPolicy, isNotNull);
        expect(
          createdEvent.constraints,
          const EventConstraints(
            minAge: 21,
            maxAge: 35,
            maxMen: 9,
            maxWomen: 9,
          ),
        );
      },
    );

    test(
      'rejects invalid create-event inputs before touching the repository',
      () async {
        final fakeEventRepository = FakeEventRepository();
        final container = ProviderContainer(
          overrides: [
            eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          createEventControllerProvider.notifier,
        );

        await expectLater(
          () => controller.submit(
            clubId: '',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 6),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: '   ',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 0,
            pace: PaceLevel.easy,
            description: 'Event',
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(capacityLimit: 0),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(basePriceInPaise: -1),
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => controller.submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 6),
            endTime: DateTime(2025, 3, 1, 7),
            meetingPoint: 'Marine Drive',
            startingPointLat: 19.076,
            startingPointLng: 181,
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(),
          ),
          throwsArgumentError,
        );

        expect(fakeEventRepository.createdEvent, isNull);
      },
    );
  });
}

EventPolicyBundle _eventPolicy({
  int capacityLimit = 10,
  int basePriceInPaise = 0,
}) {
  return EventPolicyBundle.openEvent(
    capacityLimit: capacityLimit,
    basePriceInPaise: basePriceInPaise,
  );
}
