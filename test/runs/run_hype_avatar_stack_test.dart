import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_hype_avatar_stack.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

void main() {
  test(
    'runHypeAvatars uses recent matching-gender profile thumbnails',
    () async {
      final firestore = FakeFirebaseFirestore();
      final run = buildRun(id: 'run-1');
      final now = DateTime(2026, 5, 8, 8);

      await firestore
          .collection('runParticipations')
          .doc('run-1_runner-old')
          .set(
            _participationJson(
              runId: run.id,
              uid: 'runner-old',
              gender: Gender.woman,
              signedUpAt: now.subtract(const Duration(hours: 2)),
            ),
          );
      await firestore
          .collection('runParticipations')
          .doc('run-1_runner-new')
          .set(
            _participationJson(
              runId: run.id,
              uid: 'runner-new',
              gender: Gender.woman,
              signedUpAt: now,
            ),
          );
      await firestore
          .collection('runParticipations')
          .doc('run-1_runner-filtered')
          .set(
            _participationJson(
              runId: run.id,
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
        runHypeAvatarsProvider(
          const RunHypeAvatarQuery(
            runId: 'run-1',
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
    'runHypeAvatars falls back to full photo while thumbnails backfill',
    () async {
      final firestore = FakeFirebaseFirestore();
      final run = buildRun(id: 'run-1');
      final now = DateTime(2026, 5, 8, 8);

      await firestore
          .collection('runParticipations')
          .doc('run-1_runner-1')
          .set(
            _participationJson(
              runId: run.id,
              uid: 'runner-1',
              gender: Gender.woman,
              signedUpAt: now,
            ),
          );

      await firestore.collection('publicProfiles').doc('runner-1').set({
        'name': 'Runner One',
        'age': 28,
        'bio': 'Here to run.',
        'gender': Gender.woman.name,
        'photoUrls': ['https://full.test/runner-1.jpg'],
        'photoThumbnailUrls': <String>[],
        'paceMinSecsPerKm': 300,
        'paceMaxSecsPerKm': 420,
      });

      final container = ProviderContainer(
        overrides: [firebaseFirestoreProvider.overrideWithValue(firestore)],
      );
      addTearDown(container.dispose);

      final avatars = await container.read(
        runHypeAvatarsProvider(
          const RunHypeAvatarQuery(
            runId: 'run-1',
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
  required String runId,
  required String uid,
  required Gender gender,
  required DateTime signedUpAt,
}) {
  return RunParticipation(
    id: runParticipationId(runId: runId, uid: uid),
    runId: runId,
    runClubId: 'club-1',
    uid: uid,
    status: RunParticipationStatus.signedUp,
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
    'bio': 'Here to run.',
    'gender': gender.name,
    'photoUrls': [fullUrl],
    'photoThumbnailUrls': [thumbnailUrl],
    'paceMinSecsPerKm': 300,
    'paceMaxSecsPerKm': 420,
  });
}
