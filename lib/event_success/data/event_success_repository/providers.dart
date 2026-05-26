part of '../event_success_repository.dart';

@riverpod
EventSuccessRepository eventSuccessRepository(Ref ref) =>
    EventSuccessRepository(
      ref.watch(firebaseFirestoreProvider),
      functions: ref.watch(firebaseFunctionsProvider),
    );

@riverpod
Stream<EventSuccessPlan?> watchEventSuccessPlan(Ref ref, String eventId) =>
    ref.watch(eventSuccessRepositoryProvider).watchPlan(eventId);

@riverpod
Stream<List<EventSuccessFeedback>> watchEventSuccessFeedback(
  Ref ref,
  String eventId,
) => ref.watch(eventSuccessRepositoryProvider).watchFeedbackForEvent(eventId);

@riverpod
Stream<EventSuccessScorecard?> watchEventSuccessScorecard(
  Ref ref,
  String eventId,
) => ref.watch(eventSuccessRepositoryProvider).watchScorecardForEvent(eventId);

@riverpod
Stream<EventSuccessFeedback?> watchUserEventSuccessFeedback(
  Ref ref, {
  required String eventId,
  required String uid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchFeedbackForUser(eventId: eventId, uid: uid);

@riverpod
Stream<EventSuccessAssignment?> watchUserEventSuccessAssignment(
  Ref ref, {
  required String eventId,
  required String uid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchAssignmentForUser(eventId: eventId, uid: uid);

@riverpod
Stream<EventSuccessAssignment?> watchUserEventSuccessRotationAssignment(
  Ref ref, {
  required String eventId,
  required String uid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchRotationAssignmentForUser(eventId: eventId, uid: uid);

@riverpod
Stream<List<EventSuccessAssignment>> watchEventSuccessAssignments(
  Ref ref,
  String eventId,
) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchAssignmentsForEvent(eventId: eventId);

@riverpod
Stream<List<EventSuccessAssignment>> watchEventSuccessRotationAssignments(
  Ref ref,
  String eventId,
) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchRotationAssignmentsForEvent(eventId: eventId);

@riverpod
Stream<EventSuccessPreference?> watchUserEventSuccessPreference(
  Ref ref, {
  required String eventId,
  required String uid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchPreferenceForUser(eventId: eventId, uid: uid);

@riverpod
Stream<List<EventSuccessPreference>> watchEventSuccessPreferences(
  Ref ref,
  String eventId,
) =>
    ref.watch(eventSuccessRepositoryProvider).watchPreferencesForEvent(eventId);

@riverpod
Stream<EventSuccessWingmanRequest?> watchUserEventSuccessWingmanRequest(
  Ref ref, {
  required String eventId,
  required String uid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchWingmanRequestForUser(eventId: eventId, uid: uid);

@riverpod
Stream<EventSuccessArrivalMission?> watchUserEventSuccessArrivalMission(
  Ref ref, {
  required String eventId,
  required String uid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchArrivalMissionForUser(eventId: eventId, uid: uid);

@riverpod
Stream<List<EventSuccessWingmanRequest>> watchEventSuccessWingmanRequests(
  Ref ref,
  String eventId,
) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchWingmanRequestsForEvent(eventId);

@riverpod
Stream<EventSuccessCompatibilityResponse?>
watchUserEventSuccessCompatibilityResponse(
  Ref ref, {
  required String eventId,
  required String uid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchCompatibilityResponseForUser(eventId: eventId, uid: uid);

@riverpod
Future<List<PublicProfile>> wingmanRequestCandidates(
  Ref ref, {
  required String eventId,
  required UserProfile currentUser,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .fetchWingmanRequestCandidates(eventId: eventId, currentUser: currentUser);

@riverpod
Future<List<PublicProfile>> eventSuccessAssignmentPeerProfiles(
  Ref ref,
  String peerUidsKey,
) {
  final peerUids = _decodePeerUidsKey(peerUidsKey);
  if (peerUids.isEmpty) return Future.value(const <PublicProfile>[]);
  return ref
      .watch(publicProfileRepositoryProvider)
      .fetchPublicProfiles(peerUids);
}

String eventSuccessPeerUidsKey(List<String> uids) {
  if (uids.isEmpty) return '';
  final stableUids = uids.toSet().toList()..sort();
  return stableUids.join('|');
}

EventSuccessScorecard _eventSuccessScorecardFromJson(
  Map<String, dynamic> json,
) {
  return EventSuccessScorecard(
    bookedCount: _nonNegativeInt(json['bookedCount']),
    checkedInCount: _nonNegativeInt(json['checkedInCount']),
    attendeesWhoMetTwoPlusPeople: _nonNegativeInt(
      json['attendeesWhoMetTwoPlusPeople'],
    ),
    mutualMatchCount: _nonNegativeInt(json['mutualMatchCount']),
    chatStartedCount: _nonNegativeInt(json['chatStartedCount']),
    averageWelcomeRating: _rating(json['averageWelcomeRating']),
    averageStructureRating: _rating(json['averageStructureRating']),
    safetyIncidentCount: _nonNegativeInt(json['safetyIncidentCount']),
    feedbackResponseCount: _nonNegativeInt(json['feedbackCount']),
  );
}

int _nonNegativeInt(Object? value) {
  if (value is int) return value < 0 ? 0 : value;
  if (value is num) return value < 0 ? 0 : value.toInt();
  return 0;
}

double _rating(Object? value) {
  if (value is! num || !value.isFinite) return 0;
  return value.clamp(0, 5).toDouble();
}

String? _trimToNull(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

List<String> _decodePeerUidsKey(String value) {
  if (value.trim().isEmpty) return const [];
  return value
      .split('|')
      .map((uid) => uid.trim())
      .where((uid) => uid.isNotEmpty)
      .toList(growable: false);
}
