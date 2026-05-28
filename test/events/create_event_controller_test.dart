import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
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
  String? uploadedUid;
  String? uploadedClubId;
  String? uploadedEventId;
  XFile? uploadedImage;

  @override
  Future<String> uploadEventPhoto({
    required String uid,
    required String clubId,
    required String eventId,
    required XFile image,
  }) async {
    uploadedUid = uid;
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
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
          ],
        );
        addTearDown(container.dispose);
        final uidSubscription = container.listen(
          uidProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(uidSubscription.close);
        await container.pump();

        await container
            .read(createEventControllerProvider.notifier)
            .submit(
              clubId: '  club-7  ',
              startTime: DateTime(2025, 3, 1, 6),
              endTime: DateTime(2025, 3, 1, 7, 15),
              meetingLocation: _meetingLocation(name: '  Marine Drive  '),
              eventFormat: const EventFormatSnapshot.socialRun(),
              distanceKm: 7.5,
              pace: PaceLevel.moderate,
              description: '  Steady social event  ',
              currency: defaultCurrencyCode,
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
        expect(fakeImageUploadRepository.uploadedUid, 'host-1');
        expect(fakeImageUploadRepository.uploadedClubId, 'club-7');
        expect(fakeImageUploadRepository.uploadedEventId, 'generated-7');
        expect(fakeImageUploadRepository.uploadedImage, photo);
        expect(createdEvent.clubId, 'club-7');
        expect(createdEvent.startTime, DateTime(2025, 3, 1, 6));
        expect(createdEvent.endTime, DateTime(2025, 3, 1, 7, 15));
        expect(createdEvent.meetingPoint, 'Marine Drive');
        expect(createdEvent.meetingLocation?.name, 'Marine Drive');
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
        expect(createdEvent.eventFormat, const EventFormatSnapshot.socialRun());
      },
    );

    test('sends enabled event-success defaults through createEvent', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(createEventControllerProvider.notifier)
          .submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 18),
            endTime: DateTime(2025, 3, 1, 20),
            meetingLocation: _meetingLocation(name: 'Dinner table'),
            eventFormat: EventFormatSnapshot.fromActivityKind(
              ActivityKind.dinner,
            ),
            distanceKm: 0,
            pace: PaceLevel.easy,
            description: 'Dinner',
            currency: defaultCurrencyCode,
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(),
            eventSuccessDefaults: EventSuccessDefaults.recommendedForActivity(
              ActivityKind.dinner,
              enabled: true,
              targetAttendeeCount: 12,
            ),
          );

      final defaults = fakeEventRepository.createdEventSuccessDefaults
          ?.toJson();
      expect(defaults, isNotNull);
      expect(defaults!['enabled'], true);
      expect(defaults['playbookId'], 'dinner_table_mixer');
      expect(defaults['selectedModuleIds'], contains('qr_check_in'));
    });

    test(
      'uses event capacity when normalizing pub quiz team defaults',
      () async {
        final fakeEventRepository = FakeEventRepository();
        final container = ProviderContainer(
          overrides: [
            eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(createEventControllerProvider.notifier)
            .submit(
              clubId: 'club-1',
              startTime: DateTime(2025, 3, 1, 18),
              endTime: DateTime(2025, 3, 1, 20),
              meetingLocation: _meetingLocation(name: 'Quiz venue'),
              eventFormat: EventFormatSnapshot.fromActivityKind(
                ActivityKind.pubQuiz,
              ),
              distanceKm: 0,
              pace: PaceLevel.easy,
              description: 'Trivia night',
              currency: defaultCurrencyCode,
              constraints: const EventConstraints(),
              eventPolicy: _eventPolicy(capacityLimit: 50),
              eventSuccessDefaults: EventSuccessDefaults.recommendedForActivity(
                ActivityKind.pubQuiz,
                enabled: true,
                targetAttendeeCount: 50,
              ),
            );

        final defaults = fakeEventRepository.createdEventSuccessDefaults
            ?.toJson();
        final structure = defaults?['structureConfig'] as Map<String, Object?>?;
        expect(defaults, isNotNull);
        expect(defaults!['playbookId'], 'pub_quiz_team_mixer');
        expect(structure?['unitKind'], 'teams');
        expect(structure?['unitSize'], 5);
        expect(structure?['unitCount'], isNull);
      },
    );

    test('allows zero distance for non-distance event formats', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(createEventControllerProvider.notifier)
          .submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 18),
            endTime: DateTime(2025, 3, 1, 20),
            meetingLocation: _meetingLocation(name: 'Dinner table'),
            eventFormat: EventFormatSnapshot.fromActivityKind(
              ActivityKind.dinner,
            ),
            distanceKm: 0,
            pace: PaceLevel.easy,
            description: 'Dinner',
            currency: defaultCurrencyCode,
            constraints: const EventConstraints(),
            eventPolicy: _eventPolicy(),
          );

      expect(fakeEventRepository.createdEvent!.distanceKm, 0);
      expect(
        fakeEventRepository.createdEvent!.eventFormat.activityKind,
        ActivityKind.dinner,
      );
    });

    test('passes invite codes for invite-only events', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(createEventControllerProvider.notifier)
          .submit(
            clubId: 'club-1',
            startTime: DateTime(2025, 3, 1, 18),
            endTime: DateTime(2025, 3, 1, 20),
            meetingLocation: _meetingLocation(name: 'Private route'),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Invite-only evening event',
            currency: defaultCurrencyCode,
            constraints: const EventConstraints(),
            eventPolicy: EventPolicyBundle.inviteOnlyEvent(
              capacityLimit: 12,
              basePriceInPaise: 0,
              inviteCodeHint: 'CA...HI',
            ),
            inviteCode: ' CATCH-DELHI ',
          );

      expect(fakeEventRepository.createdEvent, isNotNull);
      expect(
        fakeEventRepository.createdEvent!.eventPolicy!.usesInviteOnly,
        isTrue,
      );
      expect(fakeEventRepository.createdEventInviteCode, 'CATCH-DELHI');
    });

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
            meetingLocation: _meetingLocation(),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
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
            meetingLocation: _meetingLocation(latitude: 91),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
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
            meetingLocation: _meetingLocation(),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
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
            meetingLocation: _meetingLocation(name: '   '),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
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
            meetingLocation: _meetingLocation(),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 0,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
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
            meetingLocation: _meetingLocation(),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
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
            meetingLocation: _meetingLocation(),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
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
            meetingLocation: _meetingLocation(longitude: 181),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
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
            meetingLocation: _meetingLocation(),
            eventFormat: const EventFormatSnapshot.socialRun(),
            distanceKm: 5,
            pace: PaceLevel.easy,
            description: 'Event',
            currency: defaultCurrencyCode,
            constraints: const EventConstraints(),
            eventPolicy: EventPolicyBundle.inviteOnlyEvent(
              capacityLimit: 10,
              basePriceInPaise: 0,
            ),
            inviteCode: 'abc',
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

EventMeetingLocation _meetingLocation({
  String name = 'Marine Drive',
  double latitude = 19.076,
  double longitude = 72.8777,
  String? notes,
}) {
  return EventMeetingLocation(
    name: name,
    latitude: latitude,
    longitude: longitude,
    notes: notes,
  );
}
