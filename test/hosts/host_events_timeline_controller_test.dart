import 'dart:async';

import 'package:catch_dating_app/core/data/cursor_page.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/events/data/host_events_timeline_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

typedef _Page = CursorPage<Event, DocumentSnapshot<Event>>;
typedef _PageStep = Future<_Page> Function();

void main() {
  test('appends and de-duplicates schedule and history pages', () async {
    final boundary = DateTime(2026, 8, 18, 12);
    final activeCursor = await _eventCursor('active-cursor');
    final pastCursor = await _eventCursor('past-cursor');
    final scheduleOne = buildEvent(
      id: 'schedule-1',
      startTime: boundary.add(const Duration(hours: 1)),
      endTime: boundary.add(const Duration(hours: 2)),
    );
    final scheduleTwo = buildEvent(
      id: 'schedule-2',
      startTime: boundary.add(const Duration(days: 1)),
      endTime: boundary.add(const Duration(days: 1, hours: 1)),
    );
    final historyOne = buildEvent(
      id: 'history-1',
      startTime: boundary.subtract(const Duration(hours: 2)),
      endTime: boundary.subtract(const Duration(hours: 1)),
    );
    final historyTwo = buildEvent(
      id: 'history-2',
      startTime: boundary.subtract(const Duration(days: 1, hours: 1)),
      endTime: boundary.subtract(const Duration(days: 1)),
    );
    final repository = _PagedEventRepository(
      activeSteps: [
        () async => _Page(
          items: [scheduleOne],
          nextCursor: activeCursor,
          hasMore: true,
        ),
        () async => _Page(items: [scheduleOne, scheduleTwo], hasMore: false),
      ],
      pastSteps: [
        () async =>
            _Page(items: [historyOne], nextCursor: pastCursor, hasMore: true),
        () async => _Page(items: [historyOne, historyTwo], hasMore: false),
      ],
    );
    final request = HostEventsTimelineRequest(
      organizerId: 'club-1',
      sessionBoundary: boundary,
    );
    final container = _container(repository);
    final provider = hostEventsTimelineControllerProvider(request);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    final initial = await container.read(provider.future);
    expect(initial.activeEvents.map((event) => event.id), ['schedule-1']);
    expect(initial.pastEvents.map((event) => event.id), ['history-1']);

    await container.read(provider.notifier).loadMoreActive();
    await container.read(provider.notifier).loadMorePast();

    final accumulated = container.read(provider).requireValue;
    expect(accumulated.activeEvents.map((event) => event.id), [
      'schedule-1',
      'schedule-2',
    ]);
    expect(accumulated.pastEvents.map((event) => event.id), [
      'history-1',
      'history-2',
    ]);
    expect(accumulated.hasMoreActive, isFalse);
    expect(accumulated.hasMorePast, isFalse);
    expect(repository.activeStartAfterCalls, [null, activeCursor]);
    expect(repository.pastStartAfterCalls, [null, pastCursor]);
  });

  test(
    'preserves the schedule when history fails and retry recovers',
    () async {
      final boundary = DateTime(2026, 8, 18, 12);
      final schedule = buildEvent(
        id: 'schedule-1',
        startTime: boundary.add(const Duration(hours: 1)),
        endTime: boundary.add(const Duration(hours: 2)),
      );
      final history = buildEvent(
        id: 'history-1',
        startTime: boundary.subtract(const Duration(hours: 2)),
        endTime: boundary.subtract(const Duration(hours: 1)),
      );
      final repository = _PagedEventRepository(
        activeSteps: [
          () async => _Page(items: [schedule], hasMore: false),
        ],
        pastSteps: [
          () async => throw StateError('history unavailable'),
          () async => _Page(items: [history], hasMore: false),
        ],
      );
      final request = HostEventsTimelineRequest(
        organizerId: 'club-1',
        sessionBoundary: boundary,
      );
      final container = _container(repository);
      final provider = hostEventsTimelineControllerProvider(request);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final partial = await container.read(provider.future);
      expect(partial.activeEvents.map((event) => event.id), ['schedule-1']);
      expect(partial.pastEvents, isEmpty);
      expect(partial.pastError, isA<StateError>());

      await container.read(provider.notifier).retryPast();

      final recovered = container.read(provider).requireValue;
      expect(recovered.activeEvents.map((event) => event.id), ['schedule-1']);
      expect(recovered.pastEvents.map((event) => event.id), ['history-1']);
      expect(recovered.pastError, isNull);
      expect(repository.pastStartAfterCalls, [null, null]);
    },
  );

  test(
    'suppresses a duplicate load-more request while one is active',
    () async {
      final boundary = DateTime(2026, 8, 18, 12);
      final activeCursor = await _eventCursor('active-cursor');
      final nextPage = Completer<_Page>();
      final repository = _PagedEventRepository(
        activeSteps: [
          () async => _Page(
            items: [buildEvent(id: 'schedule-1')],
            nextCursor: activeCursor,
            hasMore: true,
          ),
          () => nextPage.future,
        ],
        pastSteps: [() async => const _Page(items: [], hasMore: false)],
      );
      final request = HostEventsTimelineRequest(
        organizerId: 'club-1',
        sessionBoundary: boundary,
      );
      final container = _container(repository);
      final provider = hostEventsTimelineControllerProvider(request);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await container.read(provider.future);

      final notifier = container.read(provider.notifier);
      final first = notifier.loadMoreActive();
      final duplicate = notifier.loadMoreActive();

      expect(repository.activeStartAfterCalls, [null, activeCursor]);
      expect(container.read(provider).requireValue.loadingMoreActive, isTrue);
      nextPage.complete(const _Page(items: [], hasMore: false));
      await Future.wait([first, duplicate]);
      expect(container.read(provider).requireValue.loadingMoreActive, isFalse);
    },
  );
}

ProviderContainer _container(EventRepository repository) {
  final container = ProviderContainer(
    overrides: [eventRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

Future<DocumentSnapshot<Event>> _eventCursor(String id) async {
  final firestore = FakeFirebaseFirestore();
  final reference = firestore
      .collection('events')
      .withDocumentIdConverter<Event>(
        idField: 'id',
        fromJson: Event.fromJson,
        toJson: (event) => event.toJson(),
      )
      .doc(id);
  await reference.set(buildEvent(id: id));
  return reference.get();
}

class _PagedEventRepository extends Fake implements EventRepository {
  _PagedEventRepository({required this.activeSteps, required this.pastSteps});

  final List<_PageStep> activeSteps;
  final List<_PageStep> pastSteps;
  final List<DocumentSnapshot<Event>?> activeStartAfterCalls = [];
  final List<DocumentSnapshot<Event>?> pastStartAfterCalls = [];

  @override
  Future<_Page> fetchActiveEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) {
    activeStartAfterCalls.add(startAfter);
    return activeSteps.removeAt(0)();
  }

  @override
  Future<_Page> fetchPastEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) {
    pastStartAfterCalls.add(startAfter);
    return pastSteps.removeAt(0)();
  }
}
