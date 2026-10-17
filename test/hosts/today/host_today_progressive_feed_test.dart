import 'dart:async';

import 'package:catch_dating_app/core/data/cursor_page.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_sliver_error_state.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_attendance_outbox.dart';
import 'package:catch_dating_app/hosts/today/data/host_attention_repository.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/personalization/domain/host_today_preference.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_feed_controller.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_view_model.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_body.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../clubs/clubs_test_helpers.dart' show buildClub;
import '../../events/events_test_helpers.dart' show buildEvent;
import '../../test_pump_helpers.dart';

typedef _EventPage = CursorPage<Event, DocumentSnapshot<Event>>;

enum _OptionalSource { attention, attendance, history }

// Actual generated controller, async adapter, view model and production body.
// Only repository I/O is held; this does not replace the feed or assert latency.
void main() {
  for (final held in _OptionalSource.values) {
    testWidgets('available event renders while ${held.name} remains pending', (
      tester,
    ) async {
      final rig = _Rig();
      rig.completeActive();
      rig.completeOptionalExcept(held);
      await rig.mount(tester);
      try {
        await pumpUntilFound(tester, find.text(rig.event.title));
        expect(rig.isCompleted(held), isFalse);
        expect(rig.state(tester).featuredEvent?.id, rig.event.id);
        expect(isHostTodayQuiet(rig.state(tester)), isFalse);
        expect(
          rig.state(tester).attentionCountIsComplete,
          held == _OptionalSource.history,
        );
        expect(rig.container.read(rig.provider).value?.activeEvents, [
          rig.event,
        ]);
        rig.expectOneBoundedReadPerSource();
        rig.completeOptional(held);
        await pumpFeatureUi(tester);
        expect(find.text(rig.event.title), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        await rig.close(tester);
      }
    });

    if (held != _OptionalSource.history) {
      testWidgets(
        'empty active feed is not quiet while ${held.name} is pending',
        (tester) async {
          final rig = _Rig(emptyActive: true);
          rig.completeActive();
          rig.completeOptionalExcept(held);
          await rig.mount(tester);
          try {
            final state = rig.state(tester);
            expect(rig.isCompleted(held), isFalse);
            expect(state.status, isNot(HostTodayStatus.empty));
            expect(isHostTodayQuiet(state), isFalse);
            expect(
              buildHostTodayPersonalizationState(
                today: state,
                preference: const HostTodayPreference.unanswered(),
                evidence: const HostTodayRoadmapEvidence(),
              ).showOrientation,
              isFalse,
            );
            expect(find.byType(HostTodayQuietState), findsNothing);
            rig.completeOptional(held);
            await pumpUntilFound(tester, find.byType(HostTodayQuietState));
            expect(isHostTodayQuiet(rig.state(tester)), isTrue);
            rig.expectOneBoundedReadPerSource();
            expect(tester.takeException(), isNull);
          } finally {
            await rig.close(tester);
          }
        },
      );
    }

    testWidgets('${held.name} failure keeps the event and exposes an error', (
      tester,
    ) async {
      final rig = _Rig();
      rig.completeActive();
      rig.completeOptionalExcept(held);
      await rig.mount(tester);
      try {
        rig.failOptional(held, StateError('${held.name} unavailable'));
        await pumpUntilFound(tester, find.text(rig.event.title));
        expect(rig.state(tester).featuredEvent?.id, rig.event.id);
        expect(isHostTodayQuiet(rig.state(tester)), isFalse);
        expect(find.byType(CatchLocalizedErrorState), findsWidgets);
        rig.expectOneBoundedReadPerSource();
        expect(tester.takeException(), isNull);
      } finally {
        await rig.close(tester);
      }
    });
  }

  testWidgets('independent sources start before active events settle', (
    tester,
  ) async {
    final rig = _Rig();
    await rig.mount(tester);
    try {
      expect(rig.active.isCompleted, isFalse);
      expect(rig.attention.isCompleted, isFalse);
      expect(rig.attendance.isCompleted, isFalse);
      expect(rig.history.isCompleted, isFalse);
      rig.expectOneBoundedReadPerSource();
      expect(rig.state(tester).status, HostTodayStatus.loading);
    } finally {
      await rig.close(tester);
    }
  });

  testWidgets('settled sources render real events and exact task coverage', (
    tester,
  ) async {
    final rig = _Rig();
    rig.completeAll();
    await rig.mount(tester);
    try {
      await pumpUntilFound(tester, find.text(rig.event.title));
      final state = rig.state(tester);
      expect(state.status, HostTodayStatus.content);
      expect(state.featuredEvent?.id, rig.event.id);
      expect(state.hasPastEvents, isTrue);
      expect(state.attentionCountIsComplete, isTrue);
      expect(state.attentionIssues, isEmpty);
      expect(find.byType(HostTodayQuietState), findsNothing);
      rig.expectOneBoundedReadPerSource();
      expect(tester.takeException(), isNull);
    } finally {
      await rig.close(tester);
    }
  });

  testWidgets('active source failure never becomes a quiet empty feed', (
    tester,
  ) async {
    final rig = _Rig();
    rig.completeOptionalExcept(null);
    await rig.mount(tester);
    try {
      final failure = StateError('active events unavailable');
      rig.active.completeError(failure);
      await pumpUntilFound(tester, find.byType(CatchLocalizedSliverErrorState));
      expect(rig.state(tester).status, HostTodayStatus.error);
      expect(rig.state(tester).error, same(failure));
      expect(isHostTodayQuiet(rig.state(tester)), isFalse);
      expect(find.byType(HostTodayQuietState), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      await rig.close(tester);
    }
  });
}

class _Rig {
  _Rig({this.emptyActive = false});

  final bool emptyActive;
  final boundary = DateTime(2026, 10, 17, 12);
  late final event = buildEvent(
    id: 'available-event',
    name: 'Available event before optional sources',
    clubId: 'organizer-105',
    startTime: boundary.add(const Duration(hours: 2)),
    endTime: boundary.add(const Duration(hours: 4)),
  );
  late final pastEvent = buildEvent(
    id: 'past-event',
    clubId: 'organizer-105',
    startTime: boundary.subtract(const Duration(hours: 2)),
    endTime: boundary.subtract(const Duration(hours: 1)),
  );
  late final request = HostTodayFeedRequest(
    organizerId: 'organizer-105',
    accountId: 'host-105',
    sessionBoundary: boundary,
  );
  final active = Completer<_EventPage>();
  final history = Completer<_EventPage>();
  final attention = Completer<HostAttentionProjection>();
  final attendance = Completer<HostAttendanceOutboxSummary>();
  final calls = <String>[];
  late final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      eventRepositoryProvider.overrideWithValue(_HeldEvents(this)),
      hostAttentionRepositoryProvider.overrideWithValue(_HeldAttention(this)),
      hostAttendanceOutboxProvider.overrideWithValue(_HeldAttendance(this)),
    ],
  );
  HostTodayFeedControllerProvider get provider =>
      hostTodayFeedControllerProvider(request);

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) {
              final state = buildHostTodayState(
                catchAsyncStateFromAsyncValue(ref.watch(provider)),
                now: boundary,
                l10n: context.l10n,
              );
              return Scaffold(
                body: CustomScrollView(
                  slivers: [
                    HostTodayBody(
                      organizer: buildClub(id: request.organizerId),
                      state: state,
                      now: boundary,
                      onRetry: () => ref.read(provider.notifier).retry(),
                      onOpenEvent: (_) {},
                      onOpenAttention: (_) {},
                      onCreateEvent: () {},
                      onViewEvents: () {},
                      onStartRehearsal: () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    // Drain delivered futures and rebuild once without waiting on held I/O or
    // attempting to settle the intentional loading animation.
    await tester.pump();
    await tester.pump();
  }

  HostTodayState state(WidgetTester tester) =>
      tester.widget<HostTodayBody>(find.byType(HostTodayBody)).state;

  void expectOneBoundedReadPerSource() {
    expect(
      calls,
      unorderedEquals(['active', 'history', 'attention', 'attendance']),
    );
  }

  void completeActive() {
    if (!active.isCompleted) {
      active.complete(
        _EventPage(items: emptyActive ? [] : [event], hasMore: false),
      );
    }
  }

  void completeOptionalExcept(_OptionalSource? held) {
    for (final source in _OptionalSource.values) {
      if (source != held) completeOptional(source);
    }
  }

  bool isCompleted(_OptionalSource source) => switch (source) {
    _OptionalSource.attention => attention.isCompleted,
    _OptionalSource.attendance => attendance.isCompleted,
    _OptionalSource.history => history.isCompleted,
  };

  void completeOptional(_OptionalSource source) {
    if (isCompleted(source)) return;
    switch (source) {
      case _OptionalSource.attention:
        attention.complete(
          HostAttentionProjection(
            organizerId: request.organizerId,
            policyVersion: 1,
            generatedAt: boundary,
            horizonEndsAt: boundary.add(const Duration(days: 7)),
            items: const [],
            coverage: [
              for (final kind in HostAttentionKind.values)
                HostAttentionCoverage(
                  kind: kind,
                  state: kind == HostAttentionKind.attendanceSync
                      ? HostAttentionCoverageState.clientMergeRequired
                      : HostAttentionCoverageState.complete,
                  reason: 'Authoritative synthetic source settled.',
                ),
            ],
          ),
        );
      case _OptionalSource.attendance:
        attendance.complete(const HostAttendanceOutboxSummary([]));
      case _OptionalSource.history:
        history.complete(_EventPage(items: [pastEvent], hasMore: false));
    }
  }

  void failOptional(_OptionalSource source, Object error) {
    switch (source) {
      case _OptionalSource.attention:
        attention.completeError(error);
      case _OptionalSource.attendance:
        attendance.completeError(error);
      case _OptionalSource.history:
        history.completeError(error);
    }
  }

  void completeAll() {
    completeActive();
    completeOptionalExcept(null);
  }

  Future<void> close(WidgetTester tester) async {
    completeAll();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump();
  }
}

class _HeldEvents extends Fake implements EventRepository {
  _HeldEvents(this.rig);
  final _Rig rig;

  @override
  Future<_EventPage> fetchActiveEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) {
    expect(organizerId, rig.request.organizerId);
    expect(sessionBoundary, rig.boundary);
    expect(startAfter, isNull);
    expect(limit, ReadLimitPolicy.directoryPage);
    rig.calls.add('active');
    return rig.active.future;
  }

  @override
  Future<_EventPage> fetchPastEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) {
    expect(organizerId, rig.request.organizerId);
    expect(sessionBoundary, rig.boundary);
    expect(startAfter, isNull);
    expect(limit, ReadLimitPolicy.directoryPage);
    rig.calls.add('history');
    return rig.history.future;
  }
}

class _HeldAttention implements HostAttentionRepository {
  _HeldAttention(this.rig);
  final _Rig rig;

  @override
  Future<HostAttentionProjection> fetch(String organizerId) {
    expect(organizerId, rig.request.organizerId);
    rig.calls.add('attention');
    return rig.attention.future;
  }
}

class _HeldAttendance extends Fake implements HostAttendanceOutbox {
  _HeldAttendance(this.rig);
  final _Rig rig;

  @override
  Future<HostAttendanceOutboxSummary> loadAll({
    required String accountId,
    DateTime? now,
  }) {
    expect(accountId, rig.request.accountId);
    expect(now, rig.boundary);
    rig.calls.add('attendance');
    return rig.attendance.future;
  }
}
