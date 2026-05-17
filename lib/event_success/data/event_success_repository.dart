import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_success_repository.g.dart';

class EventSuccessRepository {
  const EventSuccessRepository(
    this._db,
    this._participationRepository,
    this._publicProfileRepository,
    this._swipeRepository,
  );

  static const _plansPath = 'eventSuccessPlans';
  static const _feedbackPath = 'eventSuccessFeedback';

  final FirebaseFirestore _db;
  final EventParticipationRepository _participationRepository;
  final PublicProfileRepository _publicProfileRepository;
  final SwipeRepository _swipeRepository;

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

  DocumentReference<EventSuccessPlan> _planRef(String eventId) =>
      _plansRef.doc(eventId);

  DocumentReference<EventSuccessFeedback> _feedbackDoc({
    required String eventId,
    required String uid,
  }) => _feedbackRef.doc(eventSuccessFeedbackId(eventId: eventId, uid: uid));

  Stream<EventSuccessPlan?> watchPlan(String eventId) => withBackendErrorStream(
    () => _planRef(
      eventId,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch event success plan',
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
          action: 'watch event success feedback',
          resource: _feedbackPath,
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
      action: 'watch user event success feedback',
      resource: _feedbackPath,
    ),
  );

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
          action: 'create event success plan',
          resource: _plansPath,
        ),
      );

  Future<void> savePlan(EventSuccessPlan plan) => withBackendErrorContext(
    () => _planRef(plan.eventId).set(plan.copyWith(updatedAt: DateTime.now())),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'save event success plan',
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
      action: 'update event success live step',
      resource: _plansPath,
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
          action: 'complete event success plan',
          resource: _plansPath,
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
          action: 'submit event success feedback',
          resource: _feedbackPath,
        ),
      );

  Future<List<PublicProfile>> fetchPrivateCrushCandidates({
    required String eventId,
    required String currentUid,
  }) => withBackendErrorContext(
    () async {
      final participations = await _participationRepository
          .fetchParticipationsForEvent(eventId: eventId);
      final candidateIds =
          participations
              .where(
                (participation) =>
                    participation.status == EventParticipationStatus.attended,
              )
              .map((participation) => participation.uid)
              .where((uid) => uid != currentUid)
              .toSet()
              .toList()
            ..sort();
      return _publicProfileRepository.fetchPublicProfiles(candidateIds);
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch private crush candidates',
      resource: _feedbackPath,
    ),
  );

  Future<void> markPrivateCrush({
    required String eventId,
    required String currentUid,
    required PublicProfile target,
  }) => withBackendErrorContext(
    () => _swipeRepository.recordSwipe(
      swipe: Swipe(
        swiperId: currentUid,
        targetId: target.uid,
        eventId: eventId,
        direction: SwipeDirection.like,
        reactionTargetType: SwipeReactionTargetType.compatibility,
        reactionTargetLabel: 'Private crush',
        reactionTargetPreview: 'Private post-event interest',
        createdAt: DateTime.now(),
      ),
    ),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'mark private crush',
      resource: 'profileDecisions',
    ),
  );
}

@riverpod
EventSuccessRepository eventSuccessRepository(Ref ref) =>
    EventSuccessRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(eventParticipationRepositoryProvider),
      ref.watch(publicProfileRepositoryProvider),
      ref.watch(swipeRepositoryProvider),
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
Stream<EventSuccessFeedback?> watchUserEventSuccessFeedback(
  Ref ref, {
  required String eventId,
  required String uid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .watchFeedbackForUser(eventId: eventId, uid: uid);

@riverpod
Future<List<PublicProfile>> privateCrushCandidates(
  Ref ref, {
  required String eventId,
  required String currentUid,
}) => ref
    .watch(eventSuccessRepositoryProvider)
    .fetchPrivateCrushCandidates(eventId: eventId, currentUid: currentUid);
