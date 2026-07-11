import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firestore_chunks.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Listens to [idStream] — a stream of event-ID lists — and reconciles them
/// against the real-time document state from [eventsRef].
///
/// On each emission from [idStream]:
///  1. Cancels previous real-time subscriptions (generation-gated to avoid
///     stale emissions from a previous set).
///  2. Chunks IDs respecting Firestore's `whereIn` limit.
///  3. Subscribes to a snapshot per chunk.
///  4. Once all chunks arrive, emits a sorted (by [Event.startTime]) list.
///
/// The returned stream is single-subscription by design.
///
/// This extracted common code was previously duplicated in
/// [EventRepository._watchEventsForParticipationStatuses] and
/// [SavedEventRepository.watchSavedEventDetailsForUser].
Stream<List<Event>> watchEventsByIdStream({
  required Stream<List<String>> idStream,
  required CollectionReference<Event> eventsRef,
  required BackendErrorContext context,
  bool descending = false,
}) {
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
      StreamSubscription<List<String>>? idSub;
      idSub = idStream.listen((eventIds) {
        generation += 1;
        final localGeneration = generation;
        cancelEventSubscriptions();

        if (eventIds.isEmpty) {
          if (!controller.isClosed) controller.add(const []);
          return;
        }

        final chunks = chunkedForWhereIn(eventIds).toList(growable: false);
        final eventsByChunk = <int, List<Event>>{};

        for (var i = 0; i < chunks.length; i += 1) {
          final chunk = chunks[i];
          final sub = eventsRef
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

      controller.onCancel = () async {
        closed = true;
        cancelEventSubscriptions();
        await idSub?.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      };
    },
  );

  return withBackendErrorStream(() => controller.stream, context: context);
}

/// Watches events for one or more clubs without requiring one subscription per
/// club. Firestore `whereIn` limits are handled by the shared chunk helper and
/// every emission is de-duplicated and ordered by start time.
Stream<List<Event>> watchEventsForClubIdsStream({
  required List<String> clubIds,
  required CollectionReference<Event> eventsRef,
  required BackendErrorContext context,
}) {
  final uniqueClubIds = clubIds.toSet().toList()..sort();
  if (uniqueClubIds.isEmpty) return Stream.value(const []);

  var eventSubs = <StreamSubscription<QuerySnapshot<Event>>>[];
  var closed = false;
  late final StreamController<List<Event>> controller;

  void emitEvents({
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
    final events = byId.values.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    controller.add(List.unmodifiable(events));
  }

  controller = StreamController<List<Event>>(
    onListen: () {
      final chunks = chunkedForWhereIn(uniqueClubIds).toList(growable: false);
      final eventsByChunk = <int, List<Event>>{};
      for (var index = 0; index < chunks.length; index += 1) {
        final chunk = chunks[index];
        final sub = eventsRef
            .where('clubId', whereIn: chunk)
            .snapshots()
            .listen((snapshot) {
              if (closed) return;
              eventsByChunk[index] = snapshot.docs
                  .map((doc) => doc.data())
                  .toList(growable: false);
              emitEvents(
                eventsByChunk: eventsByChunk,
                chunkCount: chunks.length,
              );
            }, onError: controller.addError);
        eventSubs.add(sub);
      }
    },
    onCancel: () async {
      closed = true;
      for (final sub in eventSubs) {
        await sub.cancel();
      }
      eventSubs = [];
      if (!controller.isClosed) await controller.close();
    },
  );

  return withBackendErrorStream(() => controller.stream, context: context);
}
