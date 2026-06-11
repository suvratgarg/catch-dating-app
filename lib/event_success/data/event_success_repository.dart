import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        CompleteEventSuccessFirstHelloMissionCallableRequest,
        EventIdCallableRequest,
        OverrideEventSuccessGroupsCallableRequest,
        OverrideEventSuccessRotationsCallableRequest,
        StartEventSuccessFirstHelloMissionCallableRequest,
        SubmitEventSuccessWingmanRequestCallableRequest;
import 'package:catch_dating_app/event_success/data/event_success_callable_responses.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_success_repository.g.dart';
part 'event_success_repository/plan.dart';
part 'event_success_repository/feedback.dart';
part 'event_success_repository/assignment.dart';
part 'event_success_repository/preference.dart';
part 'event_success_repository/compatibility.dart';
part 'event_success_repository/wingman.dart';
part 'event_success_repository/arrival.dart';
part 'event_success_repository/providers.dart';

const _plansPath = 'eventSuccessPlans';
const _feedbackPath = 'eventSuccessFeedback';
const _assignmentsPath = 'eventSuccessAssignments';
const _preferencesPath = 'eventSuccessPreferences';
const _wingmanRequestsPath = 'eventSuccessWingmanRequests';
const _arrivalMissionsPath = 'eventSuccessArrivalMissions';
const _compatibilityResponsesPath = 'eventSuccessCompatibilityResponses';
const _scorecardsPath = 'eventSuccessScorecards';

abstract class _EventSuccessRepositoryCore {
  const _EventSuccessRepositoryCore();

  FirebaseFirestore get _db;
  FirebaseFunctions? get _functions;

  CollectionReference<EventSuccessFeedback> get _feedbackRef;
  CollectionReference<EventSuccessAssignment> get _assignmentsRef;
  CollectionReference<EventSuccessPreference> get _preferencesRef;
  CollectionReference<EventSuccessWingmanRequest> get _wingmanRequestsRef;

  DocumentReference<EventSuccessPlan> _planRef(String eventId);

  DocumentReference<EventSuccessFeedback> _feedbackDoc({
    required String eventId,
    required String uid,
  });

  DocumentReference<EventSuccessAssignment> _assignmentDoc({
    required String eventId,
    required String moduleId,
    required String uid,
  });

  DocumentReference<EventSuccessPreference> _preferenceDoc({
    required String eventId,
    required String uid,
  });

  DocumentReference<EventSuccessWingmanRequest> _wingmanRequestDoc({
    required String eventId,
    required String uid,
  });

  DocumentReference<EventSuccessArrivalMission> _arrivalMissionDoc({
    required String eventId,
    required String uid,
  });

  DocumentReference<EventSuccessCompatibilityResponse>
  _compatibilityResponseDoc({required String eventId, required String uid});
}

class EventSuccessRepository extends _EventSuccessRepositoryCore
    with
        _EventSuccessPlanRepository,
        _EventSuccessFeedbackRepository,
        _EventSuccessAssignmentRepository,
        _EventSuccessPreferenceRepository,
        _EventSuccessCompatibilityRepository,
        _EventSuccessWingmanRepository,
        _EventSuccessArrivalRepository {
  const EventSuccessRepository(this._db, {FirebaseFunctions? functions})
    // Keep the public named parameter as `functions:` for tests and callers.
    // ignore: prefer_initializing_formals
    : _functions = functions;

  @override
  final FirebaseFirestore _db;

  @override
  final FirebaseFunctions? _functions;

  CollectionReference<EventSuccessPlan> get _plansRef => _db
      .collection(_plansPath)
      .withDocumentIdConverter<EventSuccessPlan>(
        idField: 'id',
        fromJson: EventSuccessPlan.fromJson,
        toJson: (plan) => plan.toJson(),
      );

  @override
  CollectionReference<EventSuccessFeedback> get _feedbackRef => _db
      .collection(_feedbackPath)
      .withDocumentIdConverter<EventSuccessFeedback>(
        idField: 'id',
        fromJson: EventSuccessFeedback.fromJson,
        toJson: (feedback) => feedback.toJson(),
      );

  @override
  CollectionReference<EventSuccessAssignment> get _assignmentsRef => _db
      .collection(_assignmentsPath)
      .withDocumentIdConverter<EventSuccessAssignment>(
        idField: 'id',
        fromJson: EventSuccessAssignment.fromJson,
        toJson: (assignment) => assignment.toJson(),
      );

  @override
  CollectionReference<EventSuccessPreference> get _preferencesRef => _db
      .collection(_preferencesPath)
      .withDocumentIdConverter<EventSuccessPreference>(
        idField: 'id',
        fromJson: EventSuccessPreference.fromJson,
        toJson: (preference) => preference.toJson(),
      );

  @override
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

  @override
  DocumentReference<EventSuccessPlan> _planRef(String eventId) =>
      _plansRef.doc(eventId);

  @override
  DocumentReference<EventSuccessFeedback> _feedbackDoc({
    required String eventId,
    required String uid,
  }) => _feedbackRef.doc(eventSuccessFeedbackId(eventId: eventId, uid: uid));

  @override
  DocumentReference<EventSuccessAssignment> _assignmentDoc({
    required String eventId,
    required String moduleId,
    required String uid,
  }) => _assignmentsRef.doc(
    eventSuccessAssignmentId(eventId: eventId, moduleId: moduleId, uid: uid),
  );

  @override
  DocumentReference<EventSuccessPreference> _preferenceDoc({
    required String eventId,
    required String uid,
  }) =>
      _preferencesRef.doc(eventSuccessPreferenceId(eventId: eventId, uid: uid));

  @override
  DocumentReference<EventSuccessWingmanRequest> _wingmanRequestDoc({
    required String eventId,
    required String uid,
  }) => _wingmanRequestsRef.doc(
    eventSuccessWingmanRequestId(eventId: eventId, uid: uid),
  );

  @override
  DocumentReference<EventSuccessArrivalMission> _arrivalMissionDoc({
    required String eventId,
    required String uid,
  }) => _arrivalMissionsRef.doc(
    eventSuccessArrivalMissionId(eventId: eventId, uid: uid),
  );

  @override
  DocumentReference<EventSuccessCompatibilityResponse>
  _compatibilityResponseDoc({required String eventId, required String uid}) =>
      _compatibilityResponsesRef.doc(
        eventSuccessCompatibilityResponseId(eventId: eventId, uid: uid),
      );
}
