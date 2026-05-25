import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/event_success/data/event_success_callable_dtos.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/events/data/event_callable_dtos.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_success_repository.g.dart';

class EventSuccessRepository {
  const EventSuccessRepository(this._db, {FirebaseFunctions? functions})
    : _functions = functions;

  static const _plansPath = 'eventSuccessPlans';
  static const _feedbackPath = 'eventSuccessFeedback';
  static const _assignmentsPath = 'eventSuccessAssignments';
  static const _preferencesPath = 'eventSuccessPreferences';
  static const _wingmanRequestsPath = 'eventSuccessWingmanRequests';
  static const _arrivalMissionsPath = 'eventSuccessArrivalMissions';
  static const _compatibilityResponsesPath =
      'eventSuccessCompatibilityResponses';
  static const _scorecardsPath = 'eventSuccessScorecards';

  final FirebaseFirestore _db;
  final FirebaseFunctions? _functions;

  CollectionReference<EventSuccessPlan> get _plansRef => _db
      .collection(_plansPath)
      .withDocumentIdConverter<EventSuccessPlan>(
        idField: 'id',
        fromJson: EventSuccessPlan.fromJson,
        toJson: (plan) => plan.toJson(),
      );

  CollectionReference<EventSuccessFeedback> get _feedbackRef => _db
      .collection(_feedbackPath)
      .withDocumentIdConverter<EventSuccessFeedback>(
        idField: 'id',
        fromJson: EventSuccessFeedback.fromJson,
        toJson: (feedback) => feedback.toJson(),
      );

  CollectionReference<EventSuccessAssignment> get _assignmentsRef => _db
      .collection(_assignmentsPath)
      .withDocumentIdConverter<EventSuccessAssignment>(
        idField: 'id',
        fromJson: EventSuccessAssignment.fromJson,
        toJson: (assignment) => assignment.toJson(),
      );

  CollectionReference<EventSuccessPreference> get _preferencesRef => _db
      .collection(_preferencesPath)
      .withDocumentIdConverter<EventSuccessPreference>(
        idField: 'id',
        fromJson: EventSuccessPreference.fromJson,
        toJson: (preference) => preference.toJson(),
      );

  CollectionReference<EventSuccessWingmanRequest> get _wingmanRequestsRef => _db
      .collection(_wingmanRequestsPath)
      .withDocumentIdConverter<EventSuccessWingmanRequest>(
        idField: 'id',
        fromJson: EventSuccessWingmanRequest.fromJson,
        toJson: (request) => request.toJson(),
      );

  CollectionReference<EventSuccessArrivalMission> get _arrivalMissionsRef => _db
      .collection(_arrivalMissionsPath)
      .withDocumentIdConverter<EventSuccessArrivalMission>(
        idField: 'id',
        fromJson: EventSuccessArrivalMission.fromJson,
        toJson: (mission) => mission.toJson(),
      );

  CollectionReference<EventSuccessCompatibilityResponse>
  get _compatibilityResponsesRef => _db
      .collection(_compatibilityResponsesPath)
      .withDocumentIdConverter<EventSuccessCompatibilityResponse>(
        idField: 'id',
        fromJson: EventSuccessCompatibilityResponse.fromJson,
        toJson: (response) => response.toJson(),
      );

  DocumentReference<EventSuccessPlan> _planRef(String eventId) =>
      _plansRef.doc(eventId);

  DocumentReference<EventSuccessFeedback> _feedbackDoc({
    required String eventId,
    required String uid,
  }) => _feedbackRef.doc(eventSuccessFeedbackId(eventId: eventId, uid: uid));

  DocumentReference<EventSuccessAssignment> _assignmentDoc({
    required String eventId,
    required String moduleId,
    required String uid,
  }) => _assignmentsRef.doc(
    eventSuccessAssignmentId(eventId: eventId, moduleId: moduleId, uid: uid),
  );

  DocumentReference<EventSuccessPreference> _preferenceDoc({
    required String eventId,
    required String uid,
  }) =>
      _preferencesRef.doc(eventSuccessPreferenceId(eventId: eventId, uid: uid));

  DocumentReference<EventSuccessWingmanRequest> _wingmanRequestDoc({
    required String eventId,
    required String uid,
  }) => _wingmanRequestsRef.doc(
    eventSuccessWingmanRequestId(eventId: eventId, uid: uid),
  );

  DocumentReference<EventSuccessArrivalMission> _arrivalMissionDoc({
    required String eventId,
    required String uid,
  }) => _arrivalMissionsRef.doc(
    eventSuccessArrivalMissionId(eventId: eventId, uid: uid),
  );

  DocumentReference<EventSuccessCompatibilityResponse>
  _compatibilityResponseDoc({required String eventId, required String uid}) =>
      _compatibilityResponsesRef.doc(
        eventSuccessCompatibilityResponseId(eventId: eventId, uid: uid),
      );

  Stream<EventSuccessPlan?> watchPlan(String eventId) => withBackendErrorStream(
    () => _planRef(
      eventId,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'open live event guide',
      resource: _plansPath,
    ),
  );

  Future<EventSuccessPlan?> fetchPlan(String eventId) =>
      withBackendErrorContext(
        () async {
          final doc = await _planRef(eventId).get();
          return doc.exists ? doc.data() : null;
        },
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'open live event guide',
          resource: _plansPath,
        ),
      );

  Stream<List<EventSuccessFeedback>> watchFeedbackForEvent(String eventId) =>
      withBackendErrorStream(
        () => _feedbackRef
            .where('eventId', isEqualTo: eventId)
            .snapshots()
            .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'load event feedback',
          resource: _feedbackPath,
        ),
      );

  Stream<EventSuccessScorecard?> watchScorecardForEvent(String eventId) =>
      withBackendErrorStream(
        () => _db
            .collection(_scorecardsPath)
            .doc(eventId)
            .snapshots()
            .map(
              (doc) => doc.exists
                  ? _eventSuccessScorecardFromJson(doc.data() ?? const {})
                  : null,
            ),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'load event report',
          resource: _scorecardsPath,
        ),
      );

  Stream<EventSuccessFeedback?> watchFeedbackForUser({
    required String eventId,
    required String uid,
  }) => withBackendErrorStream(
    () => _feedbackDoc(
      eventId: eventId,
      uid: uid,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'load your event feedback',
      resource: _feedbackPath,
    ),
  );

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

  Future<EventSuccessPlan> ensurePlanForEvent(Event event) =>
      withBackendErrorContext(
        () async {
          final ref = _planRef(event.id);
          final now = DateTime.now();
          return _db.runTransaction((tx) async {
            final snapshot = await tx.get(ref);
            final existing = snapshot.data();
            if (snapshot.exists && existing != null) return existing;
            final plan = EventSuccessPlan.defaultForEvent(event, now: now);
            tx.set(ref, plan);
            return plan;
          });
        },
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'create live event guide',
          resource: _plansPath,
        ),
      );

  Stream<EventSuccessPreference?> watchPreferenceForUser({
    required String eventId,
    required String uid,
  }) => withBackendErrorStream(
    () => _preferenceDoc(
      eventId: eventId,
      uid: uid,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'load your event preference',
      resource: _preferencesPath,
    ),
  );

  Stream<List<EventSuccessPreference>> watchPreferencesForEvent(
    String eventId,
  ) => withBackendErrorStream(
    () => _preferencesRef
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'load event preferences',
      resource: _preferencesPath,
    ),
  );

  Future<void> savePlan(EventSuccessPlan plan) => withBackendErrorContext(
    () => _planRef(plan.eventId).set(plan.copyWith(updatedAt: DateTime.now())),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'save live event guide',
      resource: _plansPath,
    ),
  );

  Future<void> updateActiveStep({
    required String eventId,
    required int activeStepIndex,
  }) => withBackendErrorContext(
    () => _planRef(eventId).update({
      'activeStepIndex': activeStepIndex,
      'status': EventSuccessPlanStatus.live.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'frozenAt': FieldValue.serverTimestamp(),
    }),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'update live event step',
      resource: _plansPath,
    ),
  );

  Future<void> startLiveRevealCountdown({
    required String eventId,
    required int roundIndex,
  }) => withBackendErrorContext(
    () {
      final safeRoundIndex = roundIndex.clamp(0, 100).toInt();
      return _planRef(eventId).update({
        'status': EventSuccessPlanStatus.live.name,
        'revealStatus': EventSuccessRevealStatus.countingDown.name,
        'activeRevealRoundIndex': safeRoundIndex,
        'revealStartedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'frozenAt': FieldValue.serverTimestamp(),
      });
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'start reveal countdown',
      resource: _plansPath,
    ),
  );

  Future<void> revealLiveRound({
    required String eventId,
    required int roundIndex,
  }) => withBackendErrorContext(
    () => _planRef(eventId).update({
      'status': EventSuccessPlanStatus.live.name,
      'revealStatus': EventSuccessRevealStatus.revealed.name,
      'activeRevealRoundIndex': roundIndex.clamp(0, 100).toInt(),
      'revealStartedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'frozenAt': FieldValue.serverTimestamp(),
    }),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'reveal event round',
      resource: _plansPath,
    ),
  );

  Future<void> resetLiveReveal({required String eventId}) =>
      withBackendErrorContext(
        () => _planRef(eventId).update({
          'revealStatus': EventSuccessRevealStatus.idle.name,
          'activeRevealRoundIndex': 0,
          'revealStartedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'reset event reveal',
          resource: _plansPath,
        ),
      );

  Stream<EventSuccessWingmanRequest?> watchWingmanRequestForUser({
    required String eventId,
    required String uid,
  }) => withBackendErrorStream(
    () => _wingmanRequestDoc(
      eventId: eventId,
      uid: uid,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch user wingman request',
      resource: _wingmanRequestsPath,
    ),
  );

  Stream<EventSuccessArrivalMission?> watchArrivalMissionForUser({
    required String eventId,
    required String uid,
  }) => withBackendErrorStream(
    () => _arrivalMissionDoc(
      eventId: eventId,
      uid: uid,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'load your First Hello mission',
      resource: _arrivalMissionsPath,
    ),
  );

  Stream<List<EventSuccessWingmanRequest>> watchWingmanRequestsForEvent(
    String eventId,
  ) => withBackendErrorStream(
    () => _wingmanRequestsRef
        .where('eventId', isEqualTo: eventId)
        .where(
          'status',
          isEqualTo: EventSuccessWingmanRequestStatus.active.name,
        )
        .where('hostVisibleConsent', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch event wingman requests',
      resource: _wingmanRequestsPath,
    ),
  );

  Future<void> completePlan({required String eventId}) =>
      withBackendErrorContext(
        () => _planRef(eventId).update({
          'status': EventSuccessPlanStatus.complete.name,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
          'completedAt': FieldValue.serverTimestamp(),
        }),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'complete live event guide',
          resource: _plansPath,
        ),
      );

  Stream<EventSuccessCompatibilityResponse?> watchCompatibilityResponseForUser({
    required String eventId,
    required String uid,
  }) => withBackendErrorStream(
    () => _compatibilityResponseDoc(
      eventId: eventId,
      uid: uid,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'load your match clue answers',
      resource: _compatibilityResponsesPath,
    ),
  );

  Future<void> submitFeedback(EventSuccessFeedback feedback) =>
      withBackendErrorContext(
        () => _feedbackDoc(eventId: feedback.eventId, uid: feedback.uid).set(
          feedback.copyWith(updatedAt: DateTime.now()),
          SetOptions(merge: true),
        ),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'submit event feedback',
          resource: _feedbackPath,
        ),
      );

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
      return functions.httpsCallable('overrideEventSuccessRotations').call(
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

  Future<void> setMicroPodsOptOut({
    required Event event,
    required String uid,
    required bool optedOut,
  }) => withBackendErrorContext(
    () => _setPreference(event: event, uid: uid, microPodsOptedOut: optedOut),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'save event preference',
      resource: _preferencesPath,
    ),
  );

  Future<void> setGuidedRotationsOptOut({
    required Event event,
    required String uid,
    required bool optedOut,
  }) => withBackendErrorContext(
    () => _setPreference(
      event: event,
      uid: uid,
      guidedRotationsOptedOut: optedOut,
    ),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'save event preference',
      resource: _preferencesPath,
    ),
  );

  Future<void> saveCompatibilityResponse({
    required Event event,
    required String uid,
    required List<String> answerIds,
    EventSuccessQuestionnaireConfig questionnaireConfig =
        const EventSuccessQuestionnaireConfig.defaultTemplate(),
  }) => withBackendErrorContext(
    () async {
      final ref = _compatibilityResponseDoc(eventId: event.id, uid: uid);
      final existing = (await ref.get()).data();
      final now = DateTime.now();
      final response = EventSuccessCompatibilityResponse(
        id: eventSuccessCompatibilityResponseId(eventId: event.id, uid: uid),
        eventId: event.id,
        clubId: event.clubId,
        uid: uid,
        answerIds: EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(
          answerIds,
          config: questionnaireConfig,
        ),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      await ref.set(response);
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'save match clue answers',
      resource: _compatibilityResponsesPath,
    ),
  );

  Future<void> saveWingmanRequest({
    required Event event,
    required PublicProfile target,
    String? note,
  }) => withBackendErrorContext(
    () {
      final functions = _functions;
      if (functions == null) {
        throw StateError('FirebaseFunctions is not configured.');
      }
      return functions.httpsCallable('submitEventSuccessWingmanRequest').call(
        SubmitEventSuccessWingmanRequestCallableRequest(
          eventId: event.id,
          targetUid: target.uid,
          note: _trimToNull(note),
        ).toJson(),
      );
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'save event wingman request',
      resource: _wingmanRequestsPath,
    ),
  );

  Future<void> withdrawWingmanRequest({required Event event}) =>
      withBackendErrorContext(
        () {
          final functions = _functions;
          if (functions == null) {
            throw StateError('FirebaseFunctions is not configured.');
          }
          return functions
              .httpsCallable('withdrawEventSuccessWingmanRequest')
              .call(EventIdCallableRequest(eventId: event.id).toJson());
        },
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'withdraw event wingman request',
          resource: _wingmanRequestsPath,
        ),
      );

  Future<void> startFirstHelloMission({
    required Event event,
    required double? latitude,
    required double? longitude,
  }) => withBackendErrorContext(
    () {
      final functions = _functions;
      if (functions == null) {
        throw StateError('FirebaseFunctions is not configured.');
      }
      return functions.httpsCallable('startEventSuccessFirstHelloMission').call(
        StartEventSuccessFirstHelloMissionCallableRequest(
          eventId: event.id,
          latitude: latitude,
          longitude: longitude,
        ).toJson(),
      );
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'start First Hello mission',
      resource: _arrivalMissionsPath,
    ),
  );

  Future<void> completeFirstHelloMission({
    required Event event,
    required String answerId,
    required double? latitude,
    required double? longitude,
  }) => withBackendErrorContext(
    () {
      final functions = _functions;
      if (functions == null) {
        throw StateError('FirebaseFunctions is not configured.');
      }
      return functions
          .httpsCallable('completeEventSuccessFirstHelloMission')
          .call(
            CompleteEventSuccessFirstHelloMissionCallableRequest(
              eventId: event.id,
              answerId: answerId,
              latitude: latitude,
              longitude: longitude,
            ).toJson(),
          );
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'complete First Hello mission',
      resource: _arrivalMissionsPath,
    ),
  );

  Future<void> _setPreference({
    required Event event,
    required String uid,
    bool? microPodsOptedOut,
    bool? guidedRotationsOptedOut,
  }) async {
    final ref = _preferenceDoc(eventId: event.id, uid: uid);
    final now = DateTime.now();
    final snapshot = await ref.get();
    final existing = snapshot.data();
    final preference = EventSuccessPreference(
      id: eventSuccessPreferenceId(eventId: event.id, uid: uid),
      eventId: event.id,
      clubId: event.clubId,
      uid: uid,
      microPodsOptedOut:
          microPodsOptedOut ?? existing?.microPodsOptedOut ?? false,
      guidedRotationsOptedOut:
          guidedRotationsOptedOut ?? existing?.guidedRotationsOptedOut ?? false,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await ref.set(preference);
  }

  Future<List<PublicProfile>> fetchWingmanRequestCandidates({
    required String eventId,
    required UserProfile currentUser,
  }) => withBackendErrorContext(
    () async {
      if (currentUser.uid.trim().isEmpty) return const <PublicProfile>[];
      final functions = _functions;
      if (functions == null) {
        throw StateError('FirebaseFunctions is not configured.');
      }
      final result = await functions
          .httpsCallable('fetchEventSuccessWingmanCandidates')
          .call<Object?>(EventIdCallableRequest(eventId: eventId).toJson());
      return FetchEventSuccessWingmanCandidatesCallableResponse.fromCallableData(
        result.data,
      ).profiles;
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'fetch wingman request candidates',
      resource: _wingmanRequestsPath,
    ),
  );
}

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
