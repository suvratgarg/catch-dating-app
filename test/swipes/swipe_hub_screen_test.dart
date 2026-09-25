import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

void main() {
  test('CatchesHubScreenState maps provider waves into route states', () {
    final now = DateTime(2026, 6, 22, 12);
    final user = const AsyncData<String?>('runner-1');

    expect(
      buildCatchesHubScreenState(
        uid: const AsyncLoading(),
        attendedEvents: null,
        now: now,
      ),
      isA<CatchesHubAccessLoading>(),
    );
    expect(
      buildCatchesHubScreenState(
        uid: AsyncError<String?>(StateError('auth'), StackTrace.empty),
        attendedEvents: null,
        now: now,
      ),
      isA<CatchesHubAccessError>(),
    );
    expect(
      buildCatchesHubScreenState(
        uid: const AsyncData(null),
        attendedEvents: null,
        now: now,
      ),
      isA<CatchesHubSignedOut>(),
    );
    expect(
      buildCatchesHubScreenState(uid: user, attendedEvents: null, now: now),
      isA<CatchesHubEventsLoading>(),
    );
    expect(
      buildCatchesHubScreenState(
        uid: user,
        attendedEvents: AsyncError<List<Event>>(
          StateError('offline'),
          StackTrace.empty,
        ),
        now: now,
      ),
      isA<CatchesHubEventsError>(),
    );
    expect(
      buildCatchesHubScreenState(
        uid: user,
        attendedEvents: AsyncData([
          buildEvent(
            id: 'future',
            startTime: now.add(const Duration(hours: 1)),
            endTime: now.add(const Duration(hours: 2)),
          ),
        ]),
        now: now,
      ),
      isA<CatchesHubEmpty>(),
    );
  });

  test('CatchesHubScreenState owns active-window rows and route intents', () {
    final now = DateTime(2026, 6, 22, 12);
    final state = buildCatchesHubScreenState(
      uid: const AsyncData('runner-1'),
      attendedEvents: AsyncData([
        buildEvent(
          id: 'future',
          startTime: now.add(const Duration(hours: 1)),
          endTime: now.add(const Duration(hours: 2)),
          checkedInCount: 4,
        ),
        buildEvent(
          id: 'recent',
          startTime: now.subtract(const Duration(hours: 3, minutes: 5)),
          endTime: now.subtract(const Duration(hours: 2, minutes: 5)),
          checkedInCount: 8,
        ),
        buildEvent(
          id: 'closed',
          startTime: now.subtract(const Duration(hours: 27)),
          endTime: now.subtract(const Duration(hours: 26)),
          checkedInCount: 5,
        ),
        buildEvent(
          id: 'nearly-closed',
          startTime: now.subtract(const Duration(hours: 24, minutes: 45)),
          endTime: now.subtract(const Duration(hours: 23, minutes: 45)),
          checkedInCount: 12,
        ),
      ]),
      now: now,
    );

    expect(state, isA<CatchesHubReady>());
    final ready = state as CatchesHubReady;

    expect(ready.rows.map((row) => row.eventId), ['recent', 'nearly-closed']);
    expect(ready.featuredRow.eventId, 'recent');
    expect(ready.featuredRow.openCatchRoute, '/catches/recent');
    expect(ready.featuredRow.recapRoute, '/catches/recent/recap');
    expect(ready.featuredRow.introCountdownLabel, '21h 55m');
    expect(ready.featuredRow.tileCountdownLabel, '21H 55M');
    expect(ready.featuredRow.attendedCountLabel, '8');
    expect(ready.featuredRow.dateAttendeeLabel, contains('8 attendees'));
    expect(ready.rows.last.tileCountdownLabel, '15M');
  });
}
