import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_feed_controller.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_view_model.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../clubs/clubs_test_helpers.dart' show buildClub, buildEvent;

final _l10n = AppLocalizationsEn();

void main() {
  test('Today route state exhaustively maps auth and organizer branches', () {
    final authError = StateError('auth failed');
    final organizerError = StateError('organizers failed');

    expect(
      buildHostTodayRouteState(
        uid: const CatchAsyncState<String?>.loading(),
      ).status,
      HostTodayRouteStatus.loading,
    );
    expect(
      buildHostTodayRouteState(
        uid: const CatchAsyncState<String?>.data(null),
      ).status,
      HostTodayRouteStatus.authRequired,
    );
    final failedAuth = buildHostTodayRouteState(
      uid: CatchAsyncState<String?>.error(authError, StackTrace.current),
    );
    expect(failedAuth.status, HostTodayRouteStatus.error);
    expect(failedAuth.errorContext, AppErrorContext.auth);

    expect(
      buildHostTodayRouteState(
        uid: const CatchAsyncState<String?>.data('host-1'),
        organizers: const CatchAsyncState.loading(),
      ).status,
      HostTodayRouteStatus.loading,
    );
    final failedOrganizers = buildHostTodayRouteState(
      uid: const CatchAsyncState<String?>.data('host-1'),
      organizers: CatchAsyncState.error(organizerError, StackTrace.current),
    );
    expect(failedOrganizers.status, HostTodayRouteStatus.error);
    expect(failedOrganizers.errorContext, AppErrorContext.club);
    expect(
      buildHostTodayRouteState(
        uid: const CatchAsyncState<String?>.data('host-1'),
        organizers: const CatchAsyncState.data([]),
      ).status,
      HostTodayRouteStatus.empty,
    );
    final loaded = buildHostTodayRouteState(
      uid: const CatchAsyncState<String?>.data('host-1'),
      organizers: CatchAsyncState.data([buildClub()]),
    );
    expect(loaded.status, HostTodayRouteStatus.loaded);
    expect(loaded.organizers.single.id, 'club-1');
  });

  test('Today prioritizes live work and derives every supported task', () {
    final now = DateTime(2026, 6, 15, 12);
    final live = buildEvent(
      id: 'live',
      startTime: DateTime(2026, 6, 15, 10),
      endTime: DateTime(2026, 6, 15, 14),
    );
    final next = buildEvent(
      id: 'next',
      startTime: DateTime(2026, 6, 15, 17),
      waitlistedCount: 6,
    );
    final later = buildEvent(
      id: 'later',
      startTime: DateTime(2026, 6, 16, 20),
      waitlistedCount: 2,
    );

    final state = buildHostTodayState(
      CatchAsyncState<HostTodayFeedData>.data(
        HostTodayFeedData(
          activeEvents: [later, next, live],
          pastEvents: const [],
        ),
      ),
      now: now,
      l10n: _l10n,
    );

    expect(state.status, HostTodayStatus.content);
    expect(state.featuredEvent, live);
    expect(state.laterEvents.map((row) => row.event.id), ['next', 'later']);
    expect(state.attentionItems.map((data) => data.item.event.id), [
      'next',
      'later',
    ]);
    expect(state.attentionItems.first.title, 'Review waitlist');
    expect(
      state.attentionItems.first.item.destination,
      HostAttentionDestination.guests,
    );
    expect(state.attentionItems.map((data) => data.item.urgency), [
      HostAttentionUrgency.immediate,
      HostAttentionUrgency.soon,
    ]);
  });

  test('Today attention is exhaustive only inside the seven-day horizon', () {
    final now = DateTime(2026, 6, 15, 12);
    final today = buildEvent(
      id: 'today',
      startTime: now.add(const Duration(hours: 4)),
      waitlistedCount: 1,
    );
    final soon = buildEvent(
      id: 'soon',
      startTime: now.add(const Duration(hours: 48)),
      waitlistedCount: 2,
    );
    final upcoming = buildEvent(
      id: 'upcoming',
      startTime: now.add(const Duration(days: 6)),
      waitlistedCount: 3,
    );
    final later = buildEvent(
      id: 'later',
      startTime: now.add(const Duration(days: 8)),
      waitlistedCount: 4,
    );

    final items = HostAttentionPolicy.forEvents([
      later,
      upcoming,
      soon,
      today,
    ], now: now);

    expect(items.map((item) => item.event.id), ['today', 'soon', 'upcoming']);
    expect(items.map((item) => item.urgency), [
      HostAttentionUrgency.immediate,
      HostAttentionUrgency.soon,
      HostAttentionUrgency.upcoming,
    ]);
  });

  test('Today suppresses unsupported manual-approval waitlist work', () {
    final now = DateTime(2026, 6, 15, 12);
    final approval =
        buildEvent(
          id: 'approval',
          startTime: DateTime(2026, 6, 16, 18),
          waitlistedCount: 3,
        ).copyWith(
          eventPolicy: EventPolicyBundle.requestToJoinEvent(
            capacityLimit: 20,
            basePriceInPaise: 0,
          ),
        );

    final state = buildHostTodayState(
      CatchAsyncState<HostTodayFeedData>.data(
        HostTodayFeedData(activeEvents: [approval], pastEvents: const []),
      ),
      now: now,
      l10n: _l10n,
    );

    expect(state.featuredEvent, approval);
    expect(state.attentionItems, isEmpty);
  });

  test('Today maps loading, error, and empty history context', () {
    final now = DateTime(2026, 6, 15, 12);
    final error = StateError('today failed');
    final stackTrace = StackTrace.current;

    expect(
      buildHostTodayState(
        const CatchAsyncState<HostTodayFeedData>.loading(),
        now: now,
        l10n: _l10n,
      ).status,
      HostTodayStatus.loading,
    );
    final errorState = buildHostTodayState(
      CatchAsyncState<HostTodayFeedData>.error(error, stackTrace),
      now: now,
      l10n: _l10n,
    );
    expect(errorState.status, HostTodayStatus.error);
    expect(errorState.error, error);

    final emptyState = buildHostTodayState(
      CatchAsyncState<HostTodayFeedData>.data(
        HostTodayFeedData(
          activeEvents: const [],
          pastEvents: [
            buildEvent(
              id: 'past',
              startTime: DateTime(2026, 6, 14, 9),
              endTime: DateTime(2026, 6, 14, 10),
            ),
          ],
        ),
      ),
      now: now,
      l10n: _l10n,
    );
    expect(emptyState.status, HostTodayStatus.empty);
    expect(emptyState.hasPastEvents, isTrue);
  });
}
