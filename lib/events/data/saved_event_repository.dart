import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_chunks.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/saved_event.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_event_repository.g.dart';

class SavedEventRepository {
  const SavedEventRepository(this._db);

  static const _collectionPath = 'savedEvents';

  final FirebaseFirestore _db;

  CollectionReference<SavedEvent> get _savedEventsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<SavedEvent>(
        idField: 'id',
        fromJson: SavedEvent.fromJson,
        toJson: (savedEvent) => savedEvent.toJson(),
      );

  CollectionReference<Event> get _eventsRef => _db
      .collection('events')
      .withDocumentIdConverter<Event>(
        idField: 'id',
        fromJson: Event.fromJson,
        toJson: (event) => event.toJson(),
      );

  DocumentReference<Map<String, dynamic>> _rawSavedEventRef({
    required String uid,
    required String eventId,
  }) => _db
      .collection(_collectionPath)
      .doc(savedEventId(uid: uid, eventId: eventId));

  Stream<List<SavedEvent>> watchSavedEventsForUser({required String uid}) =>
      withBackendErrorStream(
        () => _savedEventsRef
            .where('uid', isEqualTo: uid)
            .snapshots()
            .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch saved events',
          resource: _collectionPath,
        ),
      );

  Stream<List<Event>> watchSavedEventDetailsForUser({required String uid}) {
    StreamSubscription<QuerySnapshot<SavedEvent>>? savedEventSub;
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

      final events = [
        for (final id in eventIds)
          if (byId[id] != null) byId[id]!,
      ]..sort((a, b) => a.startTime.compareTo(b.startTime));
      controller.add(events);
    }

    controller = StreamController<List<Event>>(
      onListen: () {
        savedEventSub = _savedEventsRef
            .where('uid', isEqualTo: uid)
            .snapshots()
            .listen((snap) {
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

              final chunks = chunkedForWhereIn(eventIds).toList(growable: false);
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
        await savedEventSub?.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );

    return withBackendErrorStream(
      () => controller.stream,
      context: const BackendErrorContext(
        service: BackendService.firestore,
        action: 'watch saved event details',
        resource: 'events',
      ),
    );
  }

  Stream<SavedEvent?> watchSavedEvent({
    required String uid,
    required String eventId,
  }) => withBackendErrorStream(
    () => _savedEventsRef
        .where('uid', isEqualTo: uid)
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch saved event',
      resource: _collectionPath,
    ),
  );

  Future<void> saveEvent({required String uid, required String eventId}) =>
      withBackendErrorContext(
        () => _rawSavedEventRef(uid: uid, eventId: eventId).set({
          'uid': uid,
          'eventId': eventId,
          'savedAt': FieldValue.serverTimestamp(),
        }),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'save event',
          resource: _collectionPath,
        ),
      );

  Future<void> unsaveEvent({required String uid, required String eventId}) =>
      withBackendErrorContext(
        () => _rawSavedEventRef(uid: uid, eventId: eventId).delete(),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'unsave event',
          resource: _collectionPath,
        ),
      );
}

@Riverpod(keepAlive: true)
SavedEventRepository savedEventRepository(Ref ref) =>
    SavedEventRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<SavedEvent>> watchSavedEventsForUser(Ref ref, String uid) =>
    ref.watch(savedEventRepositoryProvider).watchSavedEventsForUser(uid: uid);

@riverpod
Stream<SavedEvent?> watchSavedEvent(Ref ref, String uid, String eventId) => ref
    .watch(savedEventRepositoryProvider)
    .watchSavedEvent(uid: uid, eventId: eventId);

@riverpod
Stream<List<Event>> watchSavedEventDetailsForUser(Ref ref, String uid) => ref
    .watch(savedEventRepositoryProvider)
    .watchSavedEventDetailsForUser(uid: uid);
