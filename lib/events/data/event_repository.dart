import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/events/data/event_callable_adapters.dart';
import 'package:catch_dating_app/events/data/event_callable_dtos.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_repository.g.dart';

class EventRepository {
  const EventRepository(this._db, this._functions);

  static const _collectionPath = 'events';

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Event> get _eventsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<Event>(
        idField: 'id',
        fromJson: Event.fromJson,
        toJson: (event) => event.toJson(),
      );

  CollectionReference<EventParticipation> get _participationsRef => _db
      .collection('eventParticipations')
      .withDocumentIdConverter<EventParticipation>(
        idField: 'id',
        fromJson: EventParticipation.fromJson,
        toJson: (participation) => participation.toJson(),
      );

  CollectionReference<EventPrivateAccess> get _privateAccessRef => _db
      .collection('eventPrivateAccess')
      .withDocumentIdConverter<EventPrivateAccess>(
        idField: 'id',
        fromJson: EventPrivateAccess.fromJson,
        toJson: (access) => access.toJson(),
      );

  DocumentReference<Event> _eventRef(String id) => _eventsRef.doc(id);

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<Event?> fetchEvent(String id) => withBackendErrorContext(
    () async {
      final doc = await _eventRef(id).get();
      return doc.exists ? doc.data() : null;
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch event',
      resource: _collectionPath,
    ),
  );

  Stream<Event?> watchEvent(String id) => withBackendErrorStream(
    () =>
        _eventRef(id).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch event',
      resource: _collectionPath,
    ),
  );

  Stream<EventPrivateAccess?> watchPrivateAccess(String eventId) =>
      withBackendErrorStream(
        () => _privateAccessRef
            .doc(eventId)
            .snapshots()
            .map((doc) => doc.exists ? doc.data() : null),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch event private access',
          resource: 'eventPrivateAccess',
        ),
      );

  Stream<List<Event>> watchEventsForClub({required String clubId}) =>
      withBackendErrorStream(
        () => _eventsRef
            .where('clubId', isEqualTo: clubId)
            .orderBy('startTime')
            .snapshots()
            .map((snap) => snap.docs.map((d) => d.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch club events',
          resource: _collectionPath,
        ),
      );

  Stream<List<Event>> watchAttendedEvents({required String uid}) =>
      _watchEventsForParticipationStatuses(
        uid: uid,
        statuses: const {EventParticipationStatus.attended},
        descending: true,
      );

  /// Streams upcoming events the user has signed up for (paid / reserved a spot).
  Stream<List<Event>> watchSignedUpEvents({required String uid}) =>
      _watchEventsForParticipationStatuses(
        uid: uid,
        statuses: const {EventParticipationStatus.signedUp},
      );

  Stream<List<Event>> _watchEventsForParticipationStatuses({
    required String uid,
    required Set<EventParticipationStatus> statuses,
    bool descending = false,
  }) {
    if (statuses.isEmpty) return Stream.value(const []);

    StreamSubscription<QuerySnapshot<EventParticipation>>? participationSub;
    var eventSubs = <StreamSubscription<QuerySnapshot<Event>>>[];
    var generation = 0;
    var closed = false;

    late final StreamController<List<Event>> controller;

    void cancelEventSubscriptions() {
      for (final sub in eventSubs) {
        unawaited(sub.cancel());
      }
      eventSubs = [];
    }

    void emitSortedEvents({
      required List<String> eventIds,
      required Map<int, List<Event>> eventsByChunk,
      required int chunkCount,
    }) {
      if (eventsByChunk.length < chunkCount || controller.isClosed) return;
      final byId = <String, Event>{};
      for (final events in eventsByChunk.values) {
        for (final event in events) {
          byId[event.id] = event;
        }
      }
      final events =
          [
            for (final id in eventIds)
              if (byId[id] != null) byId[id]!,
          ]..sort(
            (a, b) => descending
                ? b.startTime.compareTo(a.startTime)
                : a.startTime.compareTo(b.startTime),
          );
      controller.add(events);
    }

    controller = StreamController<List<Event>>(
      onListen: () {
        Query<EventParticipation> query = _participationsRef.where(
          'uid',
          isEqualTo: uid,
        );
        final statusNames = statuses.map((status) => status.name).toList();
        query = statusNames.length == 1
            ? query.where('status', isEqualTo: statusNames.single)
            : query.where('status', whereIn: statusNames);

        participationSub = query.snapshots().listen((snap) {
          generation += 1;
          final localGeneration = generation;
          cancelEventSubscriptions();

          final eventIds = snap.docs
              .map((doc) => doc.data().eventId)
              .toSet()
              .toList();
          if (eventIds.isEmpty) {
            if (!controller.isClosed) controller.add(const []);
            return;
          }

          final chunks = _chunks(eventIds, 10).toList(growable: false);
          final eventsByChunk = <int, List<Event>>{};

          for (var i = 0; i < chunks.length; i += 1) {
            final chunk = chunks[i];
            final sub = _eventsRef
                .where(FieldPath.documentId, whereIn: chunk)
                .snapshots()
                .listen((eventSnap) {
                  if (closed || localGeneration != generation) return;
                  eventsByChunk[i] = eventSnap.docs
                      .map((doc) => doc.data())
                      .toList();
                  emitSortedEvents(
                    eventIds: eventIds,
                    eventsByChunk: eventsByChunk,
                    chunkCount: chunks.length,
                  );
                }, onError: controller.addError);
            eventSubs.add(sub);
          }
        }, onError: controller.addError);
      },
      onCancel: () async {
        closed = true;
        cancelEventSubscriptions();
        await participationSub?.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );

    return withBackendErrorStream(
      () => controller.stream,
      context: const BackendErrorContext(
        service: BackendService.firestore,
        action: 'watch events by participation',
        resource: _collectionPath,
      ),
    );
  }

  /// Generates a new unique Firestore document ID for an event without writing it.
  String generateId() => _eventsRef.doc().id;

  /// Fetches upcoming events from the given club IDs.
  Future<List<Event>> fetchUpcomingEventsForClubs(List<String> clubIds) =>
      withBackendErrorContext(
        () async {
          final uniqueClubIds = clubIds.toSet().toList()..sort();
          if (uniqueClubIds.isEmpty) return [];
          final nowDateTime = DateTime.now();
          final now = Timestamp.fromDate(nowDateTime);
          final events = <Event>[];
          for (final chunk in _chunks(uniqueClubIds, 10)) {
            final snap = await _eventsRef
                .where('clubId', whereIn: chunk)
                .where('startTime', isGreaterThan: now)
                .orderBy('startTime')
                .limit(10)
                .get();
            events.addAll(
              snap.docs
                  .map((doc) => doc.data())
                  .where(
                    (event) =>
                        !event.isCancelled &&
                        event.startTime.isAfter(nowDateTime),
                  ),
            );
          }
          events.sort((a, b) => a.startTime.compareTo(b.startTime));
          return events.take(30).toList(growable: false);
        },
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'fetch recommended events',
          resource: _collectionPath,
        ),
      );

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> createEvent({
    required Event event,
    String? inviteCode,
    EventSuccessDefaults? eventSuccessDefaults,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('createEvent')
        .call(
          createEventCallableRequestFromEvent(
            event,
            inviteCode: inviteCode,
            eventSuccessDefaults: eventSuccessDefaults,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'create event',
      resource: _collectionPath,
    ),
  );

  Future<void> updateEventDetails({
    required Event event,
    bool includePolicy = false,
    String? inviteCode,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('updateEvent')
        .call(
          updateEventCallableRequestFromEvent(
            event,
            includePolicy: includePolicy,
            inviteCode: inviteCode,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'update event',
      resource: _collectionPath,
    ),
  );

  /// Cancels a hosted event via the [cancelEvent] Cloud Function.
  ///
  /// The backend verifies the signed-in user hosts the club, marks the event
  /// cancelled, releases schedule projections, and notifies participants.
  Future<void> cancelEvent({required String eventId, String? reason}) =>
      withBackendErrorContext(
        () => _functions
            .httpsCallable('cancelEvent')
            .call(
              CancelEventCallableRequest(
                eventId: eventId,
                reason: reason,
              ).toJson(),
            ),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'cancel event',
          resource: _collectionPath,
        ),
      );

  /// Deletes an unused hosted event via the [deleteEvent] Cloud Function.
  ///
  /// Events with bookings, payments, reviews, or other activity must be
  /// cancelled instead so history remains auditable.
  Future<void> deleteEvent({required String eventId}) =>
      withBackendErrorContext(
        () => _functions
            .httpsCallable('deleteEvent')
            .call(EventIdCallableRequest(eventId: eventId).toJson()),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'delete event',
          resource: _collectionPath,
        ),
      );

  /// Cancels the current user's sign-up via the [cancelEventSignUp] Cloud
  /// Function, which atomically updates their participation edge and aggregate
  /// booking projections.
  Future<void> cancelSignUpViaFunction({required String eventId}) =>
      withBackendErrorContext(
        () => _functions
            .httpsCallable('cancelEventSignUp')
            .call(EventIdCallableRequest(eventId: eventId).toJson()),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'cancel sign-up',
          resource: _collectionPath,
        ),
      );

  Future<void> joinWaitlistViaFunction({
    required String eventId,
    String? inviteCode,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('joinEventWaitlist')
        .call(
          EventIdCallableRequest(
            eventId: eventId,
            inviteCode: inviteCode,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'join waitlist',
      resource: _collectionPath,
    ),
  );

  Future<void> leaveWaitlist({required String eventId}) =>
      withBackendErrorContext(
        () => _functions
            .httpsCallable('leaveEventWaitlist')
            .call(EventIdCallableRequest(eventId: eventId).toJson()),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'leave waitlist',
          resource: _collectionPath,
        ),
      );

  /// Approves or declines a request-to-join participation via the
  /// [decideEventJoinRequest] Cloud Function.
  ///
  /// The backend verifies host ownership and applies the final policy checks.
  Future<void> decideJoinRequest({
    required String eventId,
    required String userId,
    required String decision,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('decideEventJoinRequest')
        .call(
          EventJoinRequestDecisionCallableRequest(
            eventId: eventId,
            userId: userId,
            decision: decision,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'review join request',
      resource: _collectionPath,
    ),
  );

  /// Toggles attendance for a single user via the [markEventAttendance] Cloud
  /// Function. Only callable by the club's host.
  /// Returns `true` if the user is now marked attended, `false` if removed.
  Future<bool> markAttendance({
    required String eventId,
    required String userId,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable('markEventAttendance')
          .call(
            MarkEventAttendanceCallableRequest(
              eventId: eventId,
              userId: userId,
            ).toJson(),
          );
      return MarkEventAttendanceCallableResponse.fromCallableData(
        result.data,
      ).attended;
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'mark attendance',
      resource: _collectionPath,
    ),
  );

  /// Self-check-in for a signed-up participant via the
  /// [selfCheckInAttendance] Cloud Function.
  ///
  /// Requires GPS coordinates so the server can verify the user is within
  /// 200 m of the event's meeting point. Pass `null` for events without
  /// coordinates (the server skips the proximity check).
  Future<void> selfCheckInAttendance({
    required String eventId,
    required double? latitude,
    required double? longitude,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('selfCheckInAttendance')
        .call(
          SelfCheckInAttendanceCallableRequest(
            eventId: eventId,
            latitude: latitude,
            longitude: longitude,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'self check-in',
      resource: _collectionPath,
    ),
  );
}

Iterable<List<T>> _chunks<T>(List<T> values, int size) sync* {
  for (var start = 0; start < values.length; start += size) {
    final end = start + size > values.length ? values.length : start + size;
    yield values.sublist(start, end);
  }
}

@riverpod
EventRepository eventRepository(Ref ref) => EventRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
);

@riverpod
Stream<Event?> watchEvent(Ref ref, String eventId) =>
    ref.watch(eventRepositoryProvider).watchEvent(eventId);

@riverpod
Stream<EventPrivateAccess?> watchEventPrivateAccess(Ref ref, String eventId) =>
    ref.watch(eventRepositoryProvider).watchPrivateAccess(eventId);

@riverpod
Stream<List<Event>> watchEventsForClub(Ref ref, String clubId) =>
    ref.watch(eventRepositoryProvider).watchEventsForClub(clubId: clubId);

@riverpod
Stream<List<Event>> watchAttendedEvents(Ref ref, String uid) =>
    ref.watch(eventRepositoryProvider).watchAttendedEvents(uid: uid);

@riverpod
Stream<List<Event>> watchSignedUpEvents(Ref ref, String uid) =>
    ref.watch(eventRepositoryProvider).watchSignedUpEvents(uid: uid);

class RecommendedEventsQuery {
  RecommendedEventsQuery._(Iterable<String> followedClubIds)
    : followedClubIds = List.unmodifiable(
        (followedClubIds.toSet().toList()..sort()),
      );

  factory RecommendedEventsQuery.fromClubIds(
    Iterable<String> followedClubIds,
  ) => RecommendedEventsQuery._(followedClubIds);

  static const _equality = ListEquality<String>();

  final List<String> followedClubIds;

  @override
  bool operator ==(Object other) {
    return other is RecommendedEventsQuery &&
        _equality.equals(other.followedClubIds, followedClubIds);
  }

  @override
  int get hashCode => _equality.hash(followedClubIds);
}

/// Returns upcoming events from clubs the user follows.
@riverpod
Future<List<Event>> recommendedEvents(Ref ref, RecommendedEventsQuery query) =>
    ref
        .watch(eventRepositoryProvider)
        .fetchUpcomingEventsForClubs(query.followedClubIds);
