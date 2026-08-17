import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_view_model.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart' show buildEvent;

final _l10n = AppLocalizationsEn();

void main() {
  test('Host event entry resolves organizer capabilities once', () {
    final draft = EventDraft(
      id: 'draft-1',
      clubId: 'club-1',
      savedAt: DateTime(2026, 6, 15, 10),
      customActivityLabel: 'Quiz night',
    );
    final past = buildEvent(
      id: 'past',
      startTime: DateTime(2026, 6, 14, 9),
      endTime: DateTime(2026, 6, 14, 10),
    );

    final firstEvent = HostEventEntryState.resolve(organizerId: 'club-1');
    expect(firstEvent.continueIntents, isEmpty);
    expect(firstEvent.startIntents, [
      HostEventEntryIntent.createWithCatchBookings,
      HostEventEntryIntent.createFromGuestList,
    ]);

    final returning = HostEventEntryState.resolve(
      organizerId: 'club-1',
      drafts: [draft],
      repeatSource: past,
    );
    expect(returning.continueIntents, [
      HostEventEntryIntent.resumeDraft,
      HostEventEntryIntent.repeatLastEvent,
    ]);
    expect(returning.mostRecentDraft, draft);
    expect(returning.repeatSource, past);

    final noOrganizer = HostEventEntryState.resolve(
      organizerId: null,
      drafts: [draft],
      repeatSource: past,
    );
    expect(noOrganizer.hasOrganizer, isFalse);
    expect(noOrganizer.intents, isEmpty);
  });

  test(
    'Host event entry ignores drafts and repeats from another organizer',
    () {
      final state = HostEventEntryState.resolve(
        organizerId: 'club-1',
        drafts: [
          EventDraft(
            id: 'other-draft',
            clubId: 'club-2',
            savedAt: DateTime(2026, 6, 15),
          ),
        ],
        repeatSource: buildEvent(id: 'other-event', clubId: 'club-2'),
      );

      expect(state.continueIntents, isEmpty);
      expect(state.drafts, isEmpty);
      expect(state.repeatSource, isNull);
    },
  );

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
    );

    expect(state.status, HostEventsWorkspaceStatus.populated);
    expect(state.activeSections.map((section) => section.label), [
      'June',
      'July',
      'June 2027',
    ]);
    expect(
      state.activeSections
          .expand((section) => section.rows)
          .map((row) => row.event.id),
      ['today', 'july', 'next-year'],
    );
    final todayRow = state.activeSections.first.rows.single;
    expect(todayRow.isToday, isTrue);
    expect(todayRow.metaLabel, 'Today · 24 going');
    expect(todayRow.fillPercent, 80);
    expect(state.activeSections[1].rows.single.fillRatio, 1);
    expect(state.pastSections.single.rows.single.event, past);
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

    final state = HostEventsWorkspaceState.fromEvents(
      events: [endsNow, startsNow],
      now: now,
    );
    expect(state.activeSections.single.rows.single.event, startsNow);
    expect(state.activeSections.single.rows.single.isLive, isTrue);
    expect(state.pastSections.single.rows.single.event, endsNow);
    expect(
      state.pastSections.single.rows.single.metaLabel,
      contains('12 attended'),
    );
    expect(state.pastSections.single.rows.single.metaLabel, contains('free'));
  });

  test(
    'Host Events async state maps loading, error, and timeline empty copy',
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
        ).status,
        HostEventsWorkspaceStatus.loading,
      );

      final errorState = buildHostEventsWorkspaceState(
        AsyncError<List<Event>>(error, stackTrace),
        now: now,
      );
      expect(errorState.status, HostEventsWorkspaceStatus.error);
      expect(errorState.error, error);

      final emptyState = buildHostEventsWorkspaceState(
        AsyncData<List<Event>>([cancelled]),
        now: now,
      );
      expect(emptyState.status, HostEventsWorkspaceStatus.empty);
      expect(emptyState.emptyTitle(_l10n), 'No upcoming events');
      expect(emptyState.emptyBody(_l10n), contains('Create your next event'));
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
      featuredEventId: early.id,
    );
    expect(upcomingState.status, HostEventsWorkspaceStatus.populated);
    expect(
      upcomingState.activeSections
          .expand((section) => section.rows)
          .single
          .event,
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
