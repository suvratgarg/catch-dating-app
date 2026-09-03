import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_events_state.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_events_view_model.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
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
          const CatchAsyncState<List<Event>>.loading(),
          now: now,
        ).status,
        HostEventsWorkspaceStatus.loading,
      );

      final errorState = buildHostEventsWorkspaceState(
        CatchAsyncState<List<Event>>.error(error, stackTrace),
        now: now,
      );
      expect(errorState.status, HostEventsWorkspaceStatus.error);
      expect(errorState.error, error);

      final emptyState = buildHostEventsWorkspaceState(
        CatchAsyncState<List<Event>>.data([cancelled]),
        now: now,
      );
      expect(emptyState.status, HostEventsWorkspaceStatus.empty);
      expect(emptyState.emptyTitle(_l10n), 'No upcoming events');
      expect(emptyState.emptyBody(_l10n), contains('Create your next event'));

      final continuationState = HostEventsWorkspaceState.fromEvents(
        events: [cancelled],
        now: now,
        hasMoreActive: true,
      );
      expect(continuationState.status, HostEventsWorkspaceStatus.populated);
      expect(continuationState.canLoadMoreActive, isTrue);
    },
  );
}
