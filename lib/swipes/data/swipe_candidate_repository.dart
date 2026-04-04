import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/publicProfile/data/public_profile_repository.dart';
import 'package:catch_dating_app/publicProfile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_candidate_repository.g.dart';

class SwipeCandidateRepository {
  SwipeCandidateRepository(
      this._db, this._swipeRepository, this._publicProfileRepository);

  final FirebaseFirestore _db;
  final SwipeRepository _swipeRepository;
  final PublicProfileRepository _publicProfileRepository;

  Future<List<PublicProfile>> fetchCandidates({
    required String runId,
    required AppUser currentUser,
  }) async {
    // 1. Get the run to find attendees.
    final runDoc = await _db.collection('runs').doc(runId).get();
    if (!runDoc.exists) return [];

    final attendedUserIds = List<String>.from(
      runDoc.data()!['attendedUserIds'] as List? ?? [],
    )..remove(currentUser.uid);

    if (attendedUserIds.isEmpty) return [];

    // 2. Exclude already-swiped users.
    final swipedIds = await _swipeRepository.fetchSwipedUserIds(
      uid: currentUser.uid,
    );
    final candidateIds =
        attendedUserIds.where((id) => !swipedIds.contains(id)).toList();

    if (candidateIds.isEmpty) return [];

    // 3. Batch-fetch public profiles (Firestore 'whereIn' limit is 30).
    final profiles =
        await _publicProfileRepository.fetchPublicProfiles(candidateIds);

    // 4. Filter by current user's age and gender preferences.
    return profiles.where((p) {
      final ageOk = p.age >= currentUser.minAgePreference &&
          p.age <= currentUser.maxAgePreference;
      final genderOk = currentUser.interestedInGenders.isEmpty ||
          currentUser.interestedInGenders.contains(p.gender);
      return ageOk && genderOk;
    }).toList();
  }
}

@riverpod
SwipeCandidateRepository swipeCandidateRepository(Ref ref) =>
    SwipeCandidateRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(swipeRepositoryProvider),
      ref.watch(publicProfileRepositoryProvider),
    );
