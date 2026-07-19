part of '../event_success_repository.dart';

mixin _EventSuccessAssignmentRepository on _EventSuccessRepositoryCore {
  Stream<EventSuccessAssignment?> watchAssignmentForUser({
    required String eventId,
    required String uid,
    String moduleId = 'micro_pods',
  }) => withBackendErrorStream(
    () => _assignmentDoc(
      eventId: eventId,
      moduleId: moduleId,
      uid: uid,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'load your event assignment',
      resource: _assignmentsPath,
    ),
  );

  Stream<EventSuccessAssignment?> watchRotationAssignmentForUser({
    required String eventId,
    required String uid,
  }) => watchAssignmentForUser(
    eventId: eventId,
    uid: uid,
    moduleId: 'guided_rotations',
  );

  Stream<List<EventSuccessAssignment>> watchAssignmentsForEvent({
    required String eventId,
    String moduleId = 'micro_pods',
  }) => withBackendErrorStream(
    () => _assignmentsRef
        .where('eventId', isEqualTo: eventId)
        .where('moduleId', isEqualTo: moduleId)
        .limit(ReadLimitPolicy.boundedWorkingSet)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'load event assignments',
      resource: _assignmentsPath,
    ),
  );

  Stream<List<EventSuccessAssignment>> watchRotationAssignmentsForEvent({
    required String eventId,
  }) =>
      watchAssignmentsForEvent(eventId: eventId, moduleId: 'guided_rotations');

  Future<void> generateMicroPodAssignments({required String eventId}) =>
      withBackendErrorContext(
        () {
          final functions = _functions;
          if (functions == null) {
            throw StateError('FirebaseFunctions is not configured.');
          }
          return functions
              .httpsCallable('generateEventSuccessPods')
              .call(EventIdCallableRequest(eventId: eventId).toJson());
        },
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'generate event pods',
          resource: _assignmentsPath,
        ),
      );

  Future<void> generateGuidedRotations({required String eventId}) =>
      withBackendErrorContext(
        () {
          final functions = _functions;
          if (functions == null) {
            throw StateError('FirebaseFunctions is not configured.');
          }
          return functions
              .httpsCallable('generateEventSuccessRotations')
              .call(EventIdCallableRequest(eventId: eventId).toJson());
        },
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'generate event rotations',
          resource: _assignmentsPath,
        ),
      );

  Future<void> overrideGuidedRotations({
    required String eventId,
    required List<EventSuccessRotationOverrideRound> rounds,
  }) => withBackendErrorContext(
    () {
      final functions = _functions;
      if (functions == null) {
        throw StateError('FirebaseFunctions is not configured.');
      }
      return functions
          .httpsCallable('overrideEventSuccessRotations')
          .call(
            OverrideEventSuccessRotationsCallableRequest(
              eventId: eventId,
              rounds: rounds.map((round) => round.toJson()).toList(),
            ).toJson(),
          );
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'adjust event rotations',
      resource: _assignmentsPath,
    ),
  );

  Future<void> overrideGroupAssignments({
    required String eventId,
    required List<EventSuccessGroupOverrideRound> rounds,
  }) => withBackendErrorContext(
    () {
      final functions = _functions;
      if (functions == null) {
        throw StateError('FirebaseFunctions is not configured.');
      }
      return functions
          .httpsCallable('overrideEventSuccessGroups')
          .call(
            OverrideEventSuccessGroupsCallableRequest(
              eventId: eventId,
              rounds: rounds.map((round) => round.toJson()).toList(),
            ).toJson(),
          );
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'adjust event groups',
      resource: _assignmentsPath,
    ),
  );
}
