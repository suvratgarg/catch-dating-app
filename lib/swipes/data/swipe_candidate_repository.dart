import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_candidate_repository.g.dart';

class SwipeCandidateRepository {
  const SwipeCandidateRepository(
    this._runRepository,
    this._swipeRepository,
    this._publicProfileRepository,
  );

  final RunRepository _runRepository;
  final SwipeRepository _swipeRepository;
  final PublicProfileRepository _publicProfileRepository;

  Future<List<PublicProfile>> fetchCandidates({
    required String runId,
    required UserProfile currentUser,
  }) async {
    // 1. Get the run to find attendees.
    final run = await _runRepository.fetchRun(runId);
    if (run == null) return [];
    if (!hasOpenSwipeWindow(run)) return [];
    if (!run.hasAttended(currentUser.uid)) return [];

    final attendedUserIds = [...run.attendedUserIds]..remove(currentUser.uid);

    if (attendedUserIds.isEmpty) return [];

    // 2. Exclude already-swiped users.
    final swipedIds = await _swipeRepository.fetchSwipedUserIds(
      uid: currentUser.uid,
    );
    final candidateIds = attendedUserIds
        .where((id) => !swipedIds.contains(id))
        .toList();

    if (candidateIds.isEmpty) return [];

    // 3. Batch-fetch public profiles (Firestore 'whereIn' limit is 30).
    final profiles = await _publicProfileRepository.fetchPublicProfiles(
      candidateIds,
    );
    final orderedProfiles = _orderProfilesByCandidateIds(
      profiles: profiles,
      candidateIds: candidateIds,
    );

    // 4. Filter by current user's age and gender preferences.
    final ageRange = normalizeAgePreferenceRange(
      minAgePreference: currentUser.minAgePreference,
      maxAgePreference: currentUser.maxAgePreference,
    );
    return orderedProfiles.where((p) {
      final ageOk = p.age >= ageRange.minAge && p.age <= ageRange.maxAge;
      final genderOk =
          currentUser.interestedInGenders.isEmpty ||
          currentUser.interestedInGenders.contains(p.gender);
      return ageOk && genderOk;
    }).toList();
  }

  List<PublicProfile> _orderProfilesByCandidateIds({
    required List<PublicProfile> profiles,
    required List<String> candidateIds,
  }) {
    final profilesById = {for (final profile in profiles) profile.uid: profile};
    final orderedProfiles = <PublicProfile>[];
    for (final candidateId in candidateIds) {
      final profile = profilesById[candidateId];
      if (profile != null) {
        orderedProfiles.add(profile);
      }
    }
    return orderedProfiles;
  }
}

@Riverpod(keepAlive: true)
SwipeCandidateRepository swipeCandidateRepository(Ref ref) =>
    SwipeCandidateRepository(
      ref.watch(runRepositoryProvider),
      ref.watch(swipeRepositoryProvider),
      ref.watch(publicProfileRepositoryProvider),
    );
