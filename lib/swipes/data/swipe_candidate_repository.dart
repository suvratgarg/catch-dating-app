import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_candidate_repository.g.dart';

class SwipeCandidateRepository {
  const SwipeCandidateRepository(
    this._eventRepository,
    this._eventParticipationRepository,
    this._swipeRepository,
    this._publicProfileRepository, [
    this._safetyRepository,
  ]);

  final EventRepository _eventRepository;
  final EventParticipationRepository _eventParticipationRepository;
  final SwipeRepository _swipeRepository;
  final PublicProfileRepository _publicProfileRepository;
  final SafetyRepository? _safetyRepository;

  Future<List<PublicProfile>> fetchCandidates({
    required String eventId,
    required UserProfile currentUser,
  }) async {
    return withBackendErrorContext(
      () async {
        // 1. Get the event to find attendees.
        final event = await _eventRepository.fetchEvent(eventId);
        if (event == null) return [];
        if (!hasOpenSwipeWindow(event, now: DateTime.now())) return [];

        final attendedParticipantIds = await _fetchAttendedParticipantIds(
          eventId: event.id,
        );
        if (!attendedParticipantIds.contains(currentUser.uid)) return [];
        attendedParticipantIds.remove(currentUser.uid);

        if (attendedParticipantIds.isEmpty) return [];

        // 2. Exclude already-swiped users.
        final swipedIds = await _swipeRepository.fetchSwipedUserIds(
          uid: currentUser.uid,
        );
        final blockedIds =
            await _safetyRepository?.fetchBlockedUserIds(
              uid: currentUser.uid,
            ) ??
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
      },
      context: const BackendErrorContext(
        service: BackendService.firestore,
        action: 'fetch swipe candidates',
        resource: 'swipe_candidates',
      ),
    );
  }

  Future<List<String>> _fetchAttendedParticipantIds({
    required String eventId,
  }) async {
    final participations = await _eventParticipationRepository
        .fetchParticipationsForEvent(eventId: eventId);
    final attendedParticipations =
        participations
            .where(
              (participation) =>
                  participation.status == EventParticipationStatus.attended,
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

int _compareParticipationTimes(EventParticipation a, EventParticipation b) {
  final aTime = a.attendedAt ?? a.signedUpAt ?? a.createdAt;
  final bTime = b.attendedAt ?? b.signedUpAt ?? b.createdAt;
  final byTime = aTime.compareTo(bTime);
  if (byTime != 0) return byTime;
  return a.uid.compareTo(b.uid);
}

@riverpod
SwipeCandidateRepository swipeCandidateRepository(Ref ref) =>
    SwipeCandidateRepository(
      ref.watch(eventRepositoryProvider),
      ref.watch(eventParticipationRepositoryProvider),
      ref.watch(swipeRepositoryProvider),
      ref.watch(publicProfileRepositoryProvider),
      ref.watch(safetyRepositoryProvider),
    );
