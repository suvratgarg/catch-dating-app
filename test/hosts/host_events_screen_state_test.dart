import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_view_model.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart' show buildEvent;

final _l10n = AppLocalizationsEn();

void main() {
  test('Host Events groups upcoming rows and derives truthful metadata', () {
    final now = DateTime(2026, 6, 15, 12);
    final today = buildEvent(
      id: 'today',
      startTime: DateTime(2026, 6, 15, 18),
      bookedCount: 24,
    ).copyWith(capacityLimit: 30);
    final july = buildEvent(
      id: 'july',
      startTime: DateTime(2026, 7, 2, 9),
      bookedCount: 40,
    );
    final nextYear = buildEvent(
      id: 'next-year',
      startTime: DateTime(2027, 6, 1, 9),
    );
    final past = buildEvent(
      id: 'past',
      startTime: DateTime(2026, 6, 14, 9),
      endTime: DateTime(2026, 6, 14, 10),
    );
    final cancelled = buildEvent(
      id: 'cancelled',
      startTime: DateTime(2026, 6, 15, 17),
    ).copyWith(status: EventLifecycleStatus.cancelled);

    final state = HostEventsWorkspaceState.fromEvents(
      events: [nextYear, july, cancelled, past, today],
      now: now,
      selectedFilter: HostEventsLifecycleFilter.upcoming,
    );

    expect(state.status, HostEventsWorkspaceStatus.populated);
    expect(state.sections.map((section) => section.label), [
      'June',
      'July',
      'June 2027',
    ]);
    expect(
      state.sections
          .expand((section) => section.rows)
          .map((row) => row.event.id),
      ['today', 'july', 'next-year'],
    );
    final todayRow = state.sections.first.rows.single;
    expect(todayRow.isToday, isTrue);
    expect(todayRow.metaLabel, 'Today · 24 going');
    expect(todayRow.fillPercent, 80);
    expect(state.sections[1].rows.single.fillRatio, 1);
    expect(state.repeatSource, past);
  });

  test('Host Events classifies exact lifecycle boundaries', () {
    final now = DateTime(2026, 6, 15, 12);
    final startsNow = buildEvent(
      id: 'starts-now',
      startTime: now,
      endTime: now.add(const Duration(hours: 1)),
    );
    final endsNow = buildEvent(
      id: 'ends-now',
      startTime: now.subtract(const Duration(hours: 1)),
      endTime: now,
      checkedInCount: 12,
      bookedCount: 15,
    );

    final live = HostEventsWorkspaceState.fromEvents(
      events: [endsNow, startsNow],
      now: now,
      selectedFilter: HostEventsLifecycleFilter.live,
    );
    expect(live.sections.single.rows.single.event, startsNow);
    expect(live.sections.single.rows.single.isLive, isTrue);

    final past = HostEventsWorkspaceState.fromEvents(
      events: [endsNow, startsNow],
      now: now,
      selectedFilter: HostEventsLifecycleFilter.past,
    );
    expect(past.sections.single.rows.single.event, endsNow);
    expect(past.sections.single.rows.single.metaLabel, contains('12 attended'));
    expect(past.sections.single.rows.single.metaLabel, contains('free'));
  });

  test(
    'Host Events async state maps loading, error, and filter empty copy',
    () {
      final now = DateTime(2026, 6, 15, 12);
      final cancelled = buildEvent(
        id: 'cancelled',
        startTime: DateTime(2026, 6, 14),
      ).copyWith(status: EventLifecycleStatus.cancelled);
      final stackTrace = StackTrace.current;
      final error = StateError('events failed');

      expect(
        buildHostEventsWorkspaceState(
          const AsyncLoading<List<Event>>(),
          now: now,
          selectedFilter: HostEventsLifecycleFilter.upcoming,
        ).status,
        HostEventsWorkspaceStatus.loading,
      );

      final errorState = buildHostEventsWorkspaceState(
        AsyncError<List<Event>>(error, stackTrace),
        now: now,
        selectedFilter: HostEventsLifecycleFilter.live,
      );
      expect(errorState.status, HostEventsWorkspaceStatus.error);
      expect(errorState.error, error);

      final emptyState = buildHostEventsWorkspaceState(
        AsyncData<List<Event>>([cancelled]),
        now: now,
        selectedFilter: HostEventsLifecycleFilter.live,
      );
      expect(emptyState.status, HostEventsWorkspaceStatus.empty);
      expect(emptyState.emptyTitle(_l10n), 'Nothing live right now');
      expect(emptyState.emptyBody(_l10n), contains('when it starts'));
    },
  );

  test('HostEventsOverviewState maps next event and tasks', () {
    final now = DateTime(2026, 6, 15, 12);
    final early = buildEvent(
      id: 'early',
      startTime: DateTime(2026, 6, 15, 17),
      bookedCount: 24,
      waitlistedCount: 6,
    ).copyWith(capacityLimit: 30);
    final late = buildEvent(id: 'late', startTime: DateTime(2026, 6, 16, 20));
    final cancelled = buildEvent(
      id: 'cancelled',
      startTime: DateTime(2026, 6, 14),
    ).copyWith(status: EventLifecycleStatus.cancelled);

    expect(
      buildHostEventsOverviewState(
        const AsyncLoading<List<Event>>(),
        now: now,
        l10n: _l10n,
      ).status,
      HostEventsOverviewStatus.loading,
    );

    final emptyState = buildHostEventsOverviewState(
      AsyncData<List<Event>>([cancelled]),
      now: now,
      l10n: _l10n,
    );
    expect(emptyState.status, HostEventsOverviewStatus.empty);

    final contentState = buildHostEventsOverviewState(
      AsyncData<List<Event>>([late, early, cancelled]),
      now: now,
      l10n: _l10n,
    );
    expect(contentState.status, HostEventsOverviewStatus.content);
    expect(contentState.event, early);
    expect(contentState.tasks, hasLength(1));
    expect(contentState.tasks.first.id, 'waitlist:early');
    expect(contentState.tasks.first.event, early);
    expect(contentState.tasks.first.title, 'Review waitlist');
    expect(
      contentState.tasks.first.destination,
      HostEventAttentionDestination.guests,
    );
    final upcomingState = HostEventsWorkspaceState.fromEvents(
      events: [late, early],
      now: now,
      selectedFilter: HostEventsLifecycleFilter.upcoming,
      featuredEventId: early.id,
    );
    expect(upcomingState.status, HostEventsWorkspaceStatus.populated);
    expect(
      upcomingState.sections.expand((section) => section.rows).single.event,
      late,
    );
  });

  test(
    'Host Events overview prioritizes live work and unsupported approvals',
    () {
      final now = DateTime(2026, 6, 15, 12);
      final hero = buildEvent(
        id: 'hero-live',
        startTime: DateTime(2026, 6, 15, 10),
        endTime: DateTime(2026, 6, 15, 14),
      );
      final overlapping = buildEvent(
        id: 'overlapping-live',
        startTime: DateTime(2026, 6, 15, 11),
        endTime: DateTime(2026, 6, 15, 13),
      );
      final approval =
          buildEvent(
            id: 'approval-event',
            startTime: DateTime(2026, 6, 16, 18),
            waitlistedCount: 3,
          ).copyWith(
            eventPolicy: EventPolicyBundle.requestToJoinEvent(
              capacityLimit: 20,
              basePriceInPaise: 0,
            ),
          );

      final state = buildHostEventsOverviewState(
        AsyncData<List<Event>>([approval, overlapping, hero]),
        now: now,
        l10n: _l10n,
      );

      expect(state.event, hero);
      expect(state.tasks, isEmpty);
    },
  );

  test(
    'Host Events overview keeps every real task instead of truncating work',
    () {
      final now = DateTime(2026, 6, 15, 12);
      final events = List.generate(
        5,
        (index) => buildEvent(
          id: 'task-$index',
          startTime: now.add(Duration(hours: index + 1)),
          waitlistedCount: index + 1,
        ),
      );

      final state = buildHostEventsOverviewState(
        AsyncData<List<Event>>(events),
        now: now,
        l10n: _l10n,
      );

      expect(state.tasks, hasLength(5));
      expect(state.tasks.map((task) => task.event.id), [
        'task-0',
        'task-1',
        'task-2',
        'task-3',
        'task-4',
      ]);
    },
  );
}
