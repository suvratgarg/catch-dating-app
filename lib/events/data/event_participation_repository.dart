import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_participation_repository.g.dart';

class EventParticipationRepository {
  const EventParticipationRepository(this._db);

  static const _collectionPath = 'eventParticipations';
  static const _rosterVisibleStatuses = ['signedUp', 'waitlisted', 'attended'];
  static const _hostReportStatuses = [
    'signedUp',
    'waitlisted',
    'attended',
    'cancelled',
  ];

  final FirebaseFirestore _db;

  CollectionReference<EventParticipation> get _participationsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<EventParticipation>(
        idField: 'id',
        fromJson: EventParticipation.fromJson,
        toJson: (participation) => participation.toJson(),
      );

  Stream<List<EventParticipation>> watchParticipationsForUser({
    required String uid,
  }) => withBackendErrorStream(
    () => _participationsRef
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch user participations',
      resource: _collectionPath,
    ),
  );

  Stream<List<EventParticipation>> watchParticipationsForEvent({
    required String eventId,
  }) => withBackendErrorStream(
    () => _participationsRef
        .where('eventId', isEqualTo: eventId)
        .where('status', whereIn: _rosterVisibleStatuses)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch event participations',
      resource: _collectionPath,
    ),
  );

  Future<List<EventParticipation>> fetchParticipationsForEvent({
    required String eventId,
  }) => withBackendErrorContext(
    () async {
      final snap = await _participationsRef
          .where('eventId', isEqualTo: eventId)
          .where('status', whereIn: _rosterVisibleStatuses)
          .get();
      return snap.docs.map((doc) => doc.data()).toList();
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch event participations',
      resource: _collectionPath,
    ),
  );

  Future<List<EventParticipation>> fetchHostReportParticipationsForEvent({
    required String eventId,
  }) => withBackendErrorContext(
    () async {
      final snap = await _participationsRef
          .where('eventId', isEqualTo: eventId)
          .where('status', whereIn: _hostReportStatuses)
          .get();
      return snap.docs.map((doc) => doc.data()).toList();
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch host event report participations',
      resource: _collectionPath,
    ),
  );

  Stream<EventParticipation?> watchParticipation({
    required String eventId,
    required String uid,
  }) => withBackendErrorStream(
    () => _participationsRef
        .where('eventId', isEqualTo: eventId)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch event participation',
      resource: _collectionPath,
    ),
  );
}

// keepalive: participation repository is shared by event detail, rosters, and
// host operations.
@Riverpod(keepAlive: true)
EventParticipationRepository eventParticipationRepository(Ref ref) =>
    EventParticipationRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<EventParticipation>> watchEventParticipationsForUser(
  Ref ref,
  String uid,
) => ref
    .watch(eventParticipationRepositoryProvider)
    .watchParticipationsForUser(uid: uid);

@riverpod
Stream<List<EventParticipation>> watchEventParticipationsForEvent(
  Ref ref,
  String eventId,
) => ref
    .watch(eventParticipationRepositoryProvider)
    .watchParticipationsForEvent(eventId: eventId);

@riverpod
Stream<EventParticipationRoster> watchEventParticipationRoster(
  Ref ref,
  String eventId,
) => ref
    .watch(eventParticipationRepositoryProvider)
    .watchParticipationsForEvent(eventId: eventId)
    .map(EventParticipationRoster.fromParticipations);

@riverpod
Stream<EventParticipation?> watchEventParticipation(
  Ref ref,
  String eventId,
  String uid,
) => ref
    .watch(eventParticipationRepositoryProvider)
    .watchParticipation(eventId: eventId, uid: uid);
