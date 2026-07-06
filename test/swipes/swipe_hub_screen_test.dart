import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_view_model.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:flutter/material.dart';
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

  testWidgets('Catches intro CTA uses the light button variant in dark mode', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 22, 12);
    final activeRun = buildEvent(
      startTime: now.subtract(const Duration(hours: 11)),
      endTime: now.subtract(const Duration(hours: 10)),
      checkedInCount: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchAttendedEventsProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value([activeRun])),
        ],
        child: AppShellActiveTab(
          index: appShellCatchesTabIndex,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: SwipeHubScreen(now: now),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final button = tester.widget<CatchButton>(
      find.widgetWithText(CatchButton, 'Start catching'),
    );
    final label = tester.widget<Text>(find.text('Start catching'));

    expect(button.variant, CatchButtonVariant.light);
    expect(button.isInteractive, isFalse);
    expect(label.style?.color, CatchTokens.editorialLight.ink);
  });

  testWidgets('Catches hub active window list uses section primitives', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 22, 12);
    final rows = catchesHubRowsFromEvents([
      buildEvent(
        id: 'morning',
        startTime: now.subtract(const Duration(hours: 5)),
        endTime: now.subtract(const Duration(hours: 4)),
        checkedInCount: 4,
      ),
      buildEvent(
        id: 'evening',
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 7)),
        checkedInCount: 7,
      ),
    ], now: now);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchesHubContent(
            state: CatchesHubReady(uid: 'runner-1', rows: rows),
            onOpenCatch: (_) {},
            onOpenRecap: (_) {},
          ),
        ),
      ),
    );

    final headerFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CatchSectionHeader && widget.title == 'Open catch windows',
    );
    expect(headerFinder, findsOneWidget);

    final header = tester.widget<CatchSectionHeader>(headerFinder);
    final trailing = header.trailing as Text;

    expect(trailing.data, '${rows.length}');
    expect(find.byType(CatchSectionList), findsOneWidget);
  });

  testWidgets('Catches empty body centers below the header', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: CatchesHubEmptyState(onFindEvent: () {})),
      ),
    );
    await tester.pump();

    final headerRect = tester.getRect(find.byType(CatchesHubHeader));
    final emptyRect = tester.getRect(find.byType(CatchEmptyState));
    final noteRect = tester.getRect(find.byType(CatchSurface));
    final emptyBodyRect = emptyRect.expandToInclude(noteRect);
    final availableBodyCenterY = (headerRect.bottom + 844) / 2;

    expect(emptyBodyRect.top - headerRect.bottom, greaterThan(100));
    expect(
      (emptyBodyRect.center.dy - availableBodyCenterY).abs(),
      lessThan(36),
    );
  });
}
