import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/saved_event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_controller.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'events_test_helpers.dart';

void main() {
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  group('buildEventDetailViewModel', () {
    test('returns loading while any dependency is still loading', () {
      final result = buildEventDetailViewModel(
        eventAsync: const AsyncLoading(),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.isLoading, isTrue);
    });

    test('consumer role treats owned events as consumer event detail', () {
      final event = buildEvent();
      final user = buildUser();
      final review = buildReview(reviewerUserId: 'runner-2');

      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(event),
        userProfileAsync: AsyncData(user),
        reviewsAsync: AsyncData([review]),
        clubAsync: AsyncData(buildClub(hostUserId: 'runner-1')),
        savedEventAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      final value = result.requireValue;
      expect(value, isNotNull);
      expect(value!.event, event);
      expect(value.userProfile, user);
      expect(value.reviews, [review]);
      expect(value.isHost, isFalse);
      expect(value.isSaved, isFalse);
      expect(value.participation, isNull);
    });

    test('host role derives host event detail state', () {
      AppConfig.configureEntrypointRole(AppRole.host);

      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(buildEvent()),
        userProfileAsync: AsyncData(buildUser(uid: 'host-1')),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'host-1',
        isAuthenticated: true,
      );

      expect(result.requireValue!.isHost, isTrue);
    });

    test('returns saved state from the saved event relationship doc', () {
      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(buildEvent()),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: AsyncData(
          SavedEvent(
            id: savedEventId(uid: 'runner-1', eventId: 'event-1'),
            uid: 'runner-1',
            eventId: 'event-1',
            savedAt: DateTime(2026),
          ),
        ),
        currentUid: 'runner-1',
        isAuthenticated: true,
        participationAsync: const AsyncData(null),
      );

      expect(result.requireValue!.isSaved, isTrue);
    });

    test('returns participation state from the event participation edge', () {
      final participation = _participation(
        eventId: 'event-1',
        uid: 'runner-1',
        status: EventParticipationStatus.signedUp,
      );

      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(buildEvent()),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: AsyncData(participation),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.requireValue!.participation, participation);
    });

    test('returns null data when the event does not exist', () {
      final result = buildEventDetailViewModel(
        eventAsync: const AsyncData(null),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.value, isNull);
    });

    test('returns data with null userProfile when user is authenticated and '
        'the app user stream yields null', () {
      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(buildEvent()),
        userProfileAsync: const AsyncData(null),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.requireValue, isNotNull);
      expect(result.requireValue!.userProfile, isNull);
    });

    test('surfaces event stream errors', () {
      final result = buildEventDetailViewModel(
        eventAsync: AsyncError(StateError('event failed'), StackTrace.empty),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces app user stream errors', () {
      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(buildEvent()),
        userProfileAsync: AsyncError(
          StateError('user failed'),
          StackTrace.empty,
        ),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces review stream errors instead of swallowing them', () {
      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(buildEvent()),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: AsyncError(
          StateError('reviews failed'),
          StackTrace.empty,
        ),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('keeps the detail page available when saved state fails', () {
      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(buildEvent()),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: AsyncError(
          StateError('saved event failed'),
          StackTrace.empty,
        ),
        participationAsync: const AsyncData(null),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.hasError, isFalse);
      expect(result.requireValue, isNotNull);
      expect(result.requireValue!.isSaved, isFalse);
    });

    test('keeps the detail page available when participation state fails', () {
      final result = buildEventDetailViewModel(
        eventAsync: AsyncData(buildEvent()),
        userProfileAsync: AsyncData(buildUser()),
        reviewsAsync: const AsyncData(<Review>[]),
        clubAsync: AsyncData(buildClub()),
        savedEventAsync: const AsyncData(null),
        participationAsync: AsyncError(
          StateError('participation failed'),
          StackTrace.empty,
        ),
        currentUid: 'runner-1',
        isAuthenticated: true,
      );

      expect(result.hasError, isFalse);
      expect(result.requireValue, isNotNull);
      expect(result.requireValue!.participation, isNull);
    });

    test(
      'provider wires together the event, user, and reviews streams',
      () async {
        final event = buildEvent(id: 'event-77');
        final user = buildUser(uid: 'runner-77');
        final review = buildReview(eventId: 'event-77');
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-77')),
            watchEventProvider(
              event.id,
            ).overrideWith((ref) => Stream.value(event)),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            fetchClubProvider(
              event.clubId,
            ).overrideWith((ref) async => buildClub(hostUserId: 'runner-77')),
            watchReviewsForEventProvider(
              event.id,
            ).overrideWith((ref) => Stream.value([review])),
            watchSavedEventProvider(
              user.uid,
              event.id,
            ).overrideWith((ref) => Stream.value(null)),
            watchEventParticipationProvider(
              event.id,
              user.uid,
            ).overrideWith((ref) => Stream.value(null)),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          eventDetailViewModelProvider(event.id),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        await container.read(watchEventProvider(event.id).future);
        await container.read(watchUserProfileProvider.future);
        await container.read(watchReviewsForEventProvider(event.id).future);
        await container.read(
          watchSavedEventProvider(user.uid, event.id).future,
        );
        await container.read(
          watchEventParticipationProvider(event.id, user.uid).future,
        );
        await container.pump();
        await container.pump();

        final value = subscription.read().requireValue;
        expect(value, isNotNull);
        expect(value!.event, event);
        expect(value.userProfile, user);
        expect(value.reviews, [review]);
        expect(value.isHost, isFalse);
        expect(value.isSaved, isFalse);
        expect(value.participation, isNull);
      },
    );
  });

  group('EventDetailController', () {
    test('saves an unsaved event and returns the new saved state', () async {
      final repository = FakeSavedEventRepository();
      final container = ProviderContainer(
        overrides: [savedEventRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final nowSaved = await container
          .read(eventDetailControllerProvider.notifier)
          .toggleSavedEvent(
            event: buildEvent(id: 'event-9'),
            userProfile: buildUser(uid: 'runner-9'),
            isSaved: false,
          );

      expect(nowSaved, isTrue);
      expect(repository.savedUid, 'runner-9');
      expect(repository.savedEventId, 'event-9');
      expect(repository.unsavedEventId, isNull);
    });

    test('unsaves a saved event and returns the new saved state', () async {
      final repository = FakeSavedEventRepository();
      final container = ProviderContainer(
        overrides: [savedEventRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final nowSaved = await container
          .read(eventDetailControllerProvider.notifier)
          .toggleSavedEvent(
            event: buildEvent(id: 'event-10'),
            userProfile: buildUser(uid: 'runner-10'),
            isSaved: true,
          );

      expect(nowSaved, isFalse);
      expect(repository.unsavedUid, 'runner-10');
      expect(repository.unsavedEventId, 'event-10');
      expect(repository.savedEventId, isNull);
    });
  });
}

EventParticipation _participation({
  required String eventId,
  required String uid,
  required EventParticipationStatus status,
}) {
  final now = DateTime(2026);
  return EventParticipation(
    id: eventParticipationId(eventId: eventId, uid: uid),
    eventId: eventId,
    clubId: 'club-1',
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}
