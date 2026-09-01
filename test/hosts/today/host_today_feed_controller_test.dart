import 'package:catch_dating_app/core/data/cursor_page.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_feed_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../events/events_test_helpers.dart';

typedef _EventPage = CursorPage<Event, DocumentSnapshot<Event>>;

void main() {
  test(
    'Today fetches its bounded feed without the Events controller',
    () async {
      final boundary = DateTime(2026, 9, 1, 12);
      final active = buildEvent(
        id: 'active',
        startTime: boundary.add(const Duration(hours: 2)),
        endTime: boundary.add(const Duration(hours: 4)),
      );
      final past = buildEvent(
        id: 'past',
        startTime: boundary.subtract(const Duration(hours: 2)),
        endTime: boundary.subtract(const Duration(hours: 1)),
      );
      final repository = _TodayEventRepository(
        activePage: _EventPage(items: [active], hasMore: false),
        pastPage: _EventPage(items: [past], hasMore: false),
      );
      final container = ProviderContainer(
        overrides: [eventRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final request = HostTodayFeedRequest(
        organizerId: 'organizer-1',
        sessionBoundary: boundary,
      );

      final result = await container.read(
        hostTodayFeedControllerProvider(request).future,
      );

      expect(result.activeEvents, [active]);
      expect(result.pastEvents, [past]);
      expect(repository.activeRequests, 1);
      expect(repository.pastRequests, 1);
    },
  );

  test('Today remains available when optional history fails', () async {
    final boundary = DateTime(2026, 9, 1, 12);
    final active = buildEvent(
      id: 'active',
      startTime: boundary.add(const Duration(hours: 2)),
      endTime: boundary.add(const Duration(hours: 4)),
    );
    final repository = _TodayEventRepository(
      activePage: _EventPage(items: [active], hasMore: false),
      pastError: StateError('history unavailable'),
    );
    final container = ProviderContainer(
      overrides: [eventRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      hostTodayFeedControllerProvider(
        HostTodayFeedRequest(
          organizerId: 'organizer-1',
          sessionBoundary: boundary,
        ),
      ).future,
    );

    expect(result.activeEvents, [active]);
    expect(result.pastEvents, isEmpty);
  });
}

class _TodayEventRepository extends Fake implements EventRepository {
  _TodayEventRepository({
    required this.activePage,
    this.pastPage = const _EventPage(items: [], hasMore: false),
    this.pastError,
  });

  final _EventPage activePage;
  final _EventPage pastPage;
  final Object? pastError;
  int activeRequests = 0;
  int pastRequests = 0;

  @override
  Future<_EventPage> fetchActiveEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) async {
    activeRequests += 1;
    return activePage;
  }

  @override
  Future<_EventPage> fetchPastEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) async {
    pastRequests += 1;
    final error = pastError;
    if (error != null) throw error;
    return pastPage;
  }
}
