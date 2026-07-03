import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_hype_avatar_stack.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'events_test_helpers.dart';

void main() {
  testWidgets(
    'EventHypeAvatarStack renders veiled activity placeholders when obscured',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: EventHypeAvatarStack(
                eventId: 'event-1',
                totalCount: 4,
                viewerInterestedInGenders: [],
                size: 42,
                limit: 3,
                activityKind: ActivityKind.yoga,
                showOverflowCount: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(CatchIcons.personOutlined), findsNWidgets(3));
      expect(find.text('+1'), findsOneWidget);
    },
  );

  test(
    'eventHypeAvatars uses recent matching-gender profile thumbnails',
    () async {
      final firestore = FakeFirebaseFirestore();
      final event = buildEvent();
      final now = DateTime(2026, 5, 8, 8);

      await firestore
          .collection('eventParticipations')
          .doc('event-1_runner-old')
          .set(
            _participationJson(
              eventId: event.id,
              uid: 'runner-old',
              gender: Gender.woman,
              signedUpAt: now.subtract(const Duration(hours: 2)),
            ),
          );
      await firestore
          .collection('eventParticipations')
          .doc('event-1_runner-new')
          .set(
            _participationJson(
              eventId: event.id,
              uid: 'runner-new',
              gender: Gender.woman,
              signedUpAt: now,
            ),
          );
      await firestore
          .collection('eventParticipations')
          .doc('event-1_runner-filtered')
          .set(
            _participationJson(
              eventId: event.id,
              uid: 'runner-filtered',
              gender: Gender.man,
              signedUpAt: now.add(const Duration(hours: 1)),
            ),
          );

      await _seedPublicProfile(
        firestore,
        uid: 'runner-old',
        name: 'Old Runner',
        gender: Gender.woman,
        thumbnailUrl: 'https://thumb.test/old.jpg',
        fullUrl: 'https://full.test/old.jpg',
      );
      await _seedPublicProfile(
        firestore,
        uid: 'runner-new',
        name: 'New Runner',
        gender: Gender.woman,
        thumbnailUrl: 'https://thumb.test/new.jpg',
        fullUrl: 'https://full.test/new.jpg',
      );
      await _seedPublicProfile(
        firestore,
        uid: 'runner-filtered',
        name: 'Filtered Runner',
        gender: Gender.man,
        thumbnailUrl: 'https://thumb.test/filtered.jpg',
        fullUrl: 'https://full.test/filtered.jpg',
      );

      final container = ProviderContainer(
        overrides: [firebaseFirestoreProvider.overrideWithValue(firestore)],
      );
      addTearDown(container.dispose);

      final avatars = await container.read(
        eventHypeAvatarsProvider(
          const EventHypeAvatarQuery(
            eventId: 'event-1',
            viewerInterestedInGenders: [Gender.woman],
          ),
        ).future,
      );

      expect(avatars.map((avatar) => avatar.name), [
        'New Runner',
        'Old Runner',
      ]);
      expect(avatars.map((avatar) => avatar.imageUrl), [
        'https://thumb.test/new.jpg',
        'https://thumb.test/old.jpg',
      ]);
    },
  );

  test(
    'eventHypeAvatars falls back to full photo while thumbnails backfill',
    () async {
      final firestore = FakeFirebaseFirestore();
      final event = buildEvent();
      final now = DateTime(2026, 5, 8, 8);

      await firestore
          .collection('eventParticipations')
          .doc('event-1_runner-1')
          .set(
            _participationJson(
              eventId: event.id,
              uid: 'runner-1',
              gender: Gender.woman,
              signedUpAt: now,
            ),
          );

      await firestore.collection('publicProfiles').doc('runner-1').set({
        'name': 'Runner One',
        'age': 28,
        'bio': 'Here to event.',
        'gender': Gender.woman.name,
        'profilePhotos': [
          ProfilePhoto.uploaded(
            position: 0,
            url: 'https://full.test/runner-1.jpg',
            storagePath: 'publicProfiles/runner-1/photos/photo-0.jpg',
            now: now,
          ).copyWith(thumbnailUrl: '').toJson(),
        ],
        'paceMinSecsPerKm': 300,
        'paceMaxSecsPerKm': 420,
      });

      final container = ProviderContainer(
        overrides: [firebaseFirestoreProvider.overrideWithValue(firestore)],
      );
      addTearDown(container.dispose);

      final avatars = await container.read(
        eventHypeAvatarsProvider(
          const EventHypeAvatarQuery(
            eventId: 'event-1',
            viewerInterestedInGenders: [Gender.woman],
          ),
        ).future,
      );

      expect(avatars.single.name, 'Runner One');
      expect(avatars.single.imageUrl, 'https://full.test/runner-1.jpg');
    },
  );
}

Map<String, Object?> _participationJson({
  required String eventId,
  required String uid,
  required Gender gender,
  required DateTime signedUpAt,
}) {
  return EventParticipation(
    id: eventParticipationId(eventId: eventId, uid: uid),
    eventId: eventId,
    clubId: 'club-1',
    uid: uid,
    status: EventParticipationStatus.signedUp,
    createdAt: signedUpAt,
    updatedAt: signedUpAt,
    signedUpAt: signedUpAt,
    genderAtSignup: gender,
  ).toJson();
}

Future<void> _seedPublicProfile(
  FakeFirebaseFirestore firestore, {
  required String uid,
  required String name,
  required Gender gender,
  required String thumbnailUrl,
  required String fullUrl,
}) {
  return firestore.collection('publicProfiles').doc(uid).set({
    'name': name,
    'age': 28,
    'bio': 'Here to event.',
    'gender': gender.name,
    'profilePhotos': [
      ProfilePhoto.uploaded(
        position: 0,
        url: fullUrl,
        storagePath: 'publicProfiles/$uid/photos/photo-0.jpg',
        now: DateTime(2026),
      ).copyWith(thumbnailUrl: thumbnailUrl).toJson(),
    ],
    'paceMinSecsPerKm': 300,
    'paceMaxSecsPerKm': 420,
  });
}
