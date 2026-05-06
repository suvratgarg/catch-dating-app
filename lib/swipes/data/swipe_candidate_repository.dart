import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_candidate_repository.g.dart';

class SwipeCandidateRepository {
  const SwipeCandidateRepository(
    this._runRepository,
    this._runParticipationRepository,
    this._swipeRepository,
    this._publicProfileRepository, [
    this._safetyRepository,
  ]);

  final RunRepository _runRepository;
  final RunParticipationRepository _runParticipationRepository;
  final SwipeRepository _swipeRepository;
  final PublicProfileRepository _publicProfileRepository;
  final SafetyRepository? _safetyRepository;

  Future<List<PublicProfile>> fetchCandidates({
    required String runId,
    required UserProfile currentUser,
  }) async {
    // 1. Get the run to find attendees.
    final run = await _runRepository.fetchRun(runId);
    if (run == null) return [];
    if (!hasOpenSwipeWindow(run)) return [];

    final attendedParticipantIds = await _fetchAttendedParticipantIds(
      runId: run.id,
    );
    if (!attendedParticipantIds.contains(currentUser.uid)) return [];
    attendedParticipantIds.remove(currentUser.uid);

    if (attendedParticipantIds.isEmpty) return [];

    // 2. Exclude already-swiped users.
    final swipedIds = await _swipeRepository.fetchSwipedUserIds(
      uid: currentUser.uid,
    );
    final blockedIds =
        await _safetyRepository?.fetchBlockedUserIds(uid: currentUser.uid) ??
        const <String>{};
    final candidateIds = attendedParticipantIds
        .where((id) => !swipedIds.contains(id))
        .where((id) => !blockedIds.contains(id))
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

  Future<List<String>> _fetchAttendedParticipantIds({
    required String runId,
  }) async {
    final participations = await _runParticipationRepository
        .fetchParticipationsForRun(runId: runId);
    final attendedParticipations =
        participations
            .where(
              (participation) =>
                  participation.status == RunParticipationStatus.attended,
            )
            .toList()
          ..sort(_compareParticipationTimes);

    final userIds = <String>[];
    final seen = <String>{};
    for (final participation in attendedParticipations) {
      if (seen.add(participation.uid)) {
        userIds.add(participation.uid);
      }
    }
    return userIds;
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

int _compareParticipationTimes(RunParticipation a, RunParticipation b) {
  final aTime = a.attendedAt ?? a.signedUpAt ?? a.createdAt;
  final bTime = b.attendedAt ?? b.signedUpAt ?? b.createdAt;
  final byTime = aTime.compareTo(bTime);
  if (byTime != 0) return byTime;
  return a.uid.compareTo(b.uid);
}

@riverpod
SwipeCandidateRepository swipeCandidateRepository(Ref ref) =>
    SwipeCandidateRepository(
      ref.watch(runRepositoryProvider),
      ref.watch(runParticipationRepositoryProvider),
      ref.watch(swipeRepositoryProvider),
      ref.watch(publicProfileRepositoryProvider),
      ref.watch(safetyRepositoryProvider),
    );
