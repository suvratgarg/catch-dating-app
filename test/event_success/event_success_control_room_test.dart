import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart' show buildEvent;

void main() {
  testWidgets('report empty state inherits the contained report module', (
    tester,
  ) async {
    final event = buildEvent(id: 'waiting-report');
    final plan = EventSuccessPlan.defaultForEvent(event, now: event.startTime);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EventSuccessHostPanel(
              event: event,
              plan: plan,
              planIsPersisted: true,
              roster: EventParticipationRoster.empty(),
              initialTab: EventSuccessHostTab.report,
              showTabs: false,
              embedded: true,
            ),
          ),
        ),
      ),
    );

    final waiting = find.text('Waiting for attendee feedback');
    expect(waiting, findsOneWidget);
    expect(
      find.ancestor(
        of: waiting,
        matching: find.byType(CatchSectionFocusSurface),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<CatchEmptyState>(find.byType(CatchEmptyState)).surface,
      isFalse,
    );
  });

  testWidgets('restart mid-round resumes the correct persisted beat', (
    tester,
  ) async {
    final event = buildEvent(
      id: 'restart-control-room',
      eventFormat: const EventFormatSnapshot(
        activityKind: ActivityKind.pubQuiz,
        interactionModel: EventInteractionModel.hostLedProgram,
        customActivityLabel: 'host-led social',
        defaultPlaybookId: 'host_led_social',
      ),
    );
    final persisted =
        EventSuccessPlan.defaultForEvent(event, now: event.startTime).copyWith(
          status: EventSuccessPlanStatus.live,
          activeStepIndex: 2,
          liveControlRevision: 9,
          assignmentDraftRevision: 3,
          publishedRotationRoundIndex: 1,
          publishedRevealRoundIndex: 1,
        );

    Future<void> pumpControlRoom(EventSuccessPlan plan) => tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EventSuccessHostPanel(
              event: event,
              plan: plan,
              planIsPersisted: true,
              roster: EventParticipationRoster.empty(),
              initialTab: EventSuccessHostTab.live,
              showTabs: false,
              compactLiveControls: true,
              fixtureActions: EventSuccessHostFixtureActions(
                onPreviousStep: () {},
                onNextStep: () {},
                onCompletePlan: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await pumpControlRoom(persisted);
    expect(find.textContaining('Step 3 of 4'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    final restarted = EventSuccessPlan.fromJson({
      ...persisted.toJson(),
      'id': persisted.id,
    });
    await pumpControlRoom(restarted);

    expect(restarted.liveControlRevision, 9);
    expect(restarted.publishedRotationRoundIndex, 1);
    expect(find.textContaining('Step 3 of 4'), findsOneWidget);
    expect(find.textContaining('Step 1 of 4'), findsNothing);
  });

  testWidgets(
    'compact Control Room fits the first viewport with an external-only roster',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final event = buildEvent(
        id: 'external-only-control-room',
        eventFormat: const EventFormatSnapshot(
          activityKind: ActivityKind.pubQuiz,
          interactionModel: EventInteractionModel.hostLedProgram,
          customActivityLabel: 'host-led social',
          defaultPlaybookId: 'host_led_social',
        ),
      );
      final plan = EventSuccessPlan.defaultForEvent(
        event,
        now: event.startTime,
      ).copyWith(status: EventSuccessPlanStatus.live, activeStepIndex: 1);
      var guestDrawerOpenCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: EventSuccessHostPanel(
                event: event,
                plan: plan,
                planIsPersisted: true,
                roster: EventParticipationRoster.empty(),
                operationalRosterSummary:
                    const EventSuccessOperationalRosterSummary(
                      checkedInCount: 18,
                      expectedCount: 24,
                    ),
                initialTab: EventSuccessHostTab.live,
                showTabs: false,
                compactLiveControls: true,
                fixtureActions: EventSuccessHostFixtureActions(
                  onPreviousStep: () {},
                  onNextStep: () {},
                  onCompletePlan: () {},
                ),
                onOpenGuests: () => guestDrawerOpenCount += 1,
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('LIVE NOW'), findsOneWidget);
      expect(find.textContaining('SYNCED'), findsOneWidget);
      expect(find.textContaining('Step 2 of 4'), findsOneWidget);
      expect(find.text('18 checked in · 24 expected'), findsOneWidget);
      expect(find.text('Guests'), findsNWidgets(2));
      expect(find.text('Help & fallback'), findsOneWidget);
      expect(find.byType(CatchBottomAction), findsOneWidget);
      expect(
        tester.getBottomRight(find.byType(CatchBottomAction)).dy,
        lessThanOrEqualTo(812),
      );

      await tester.tap(
        find.descendant(
          of: find.byType(EventSuccessLiveWorkspacePicker),
          matching: find.text('Guests'),
        ),
      );
      await tester.pump();
      expect(guestDrawerOpenCount, 1);

      await tester.tap(find.text('Room'));
      await tester.pump();
      expect(find.text('One shared room'), findsOneWidget);
      expect(find.byType(CatchBottomAction), findsNothing);
    },
  );

  testWidgets('Room workspace renders the saved map before placements exist', (
    tester,
  ) async {
    final event = buildEvent(
      id: 'saved-room-control-room',
      eventFormat: EventFormatSnapshot.custom(
        label: 'Table mixer',
        interactionModel: EventInteractionModel.pairedRotations,
      ),
    );
    final layout = EventSuccessLayout.parametric(
      layoutId: 'room-a',
      label: 'Room A',
      shape: EventSuccessLayoutShape.round,
      unitCount: 6,
      unitCapacity: 4,
      columnCount: 2,
    );
    final plan = EventSuccessPlan.defaultForEvent(
      event,
      now: event.startTime,
    ).copyWith(status: EventSuccessPlanStatus.live, layoutId: layout.layoutId);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EventSuccessHostPanel(
              event: event,
              plan: plan,
              planIsPersisted: true,
              roster: EventParticipationRoster.empty(),
              initialTab: EventSuccessHostTab.live,
              showTabs: false,
              compactLiveControls: true,
              spatialLayout: layout,
              spatialLayoutState: EventSuccessSpatialLayoutState.ready(layout),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Room'));
    await tester.pump();

    expect(find.text('6 tables · 24 seats'), findsOneWidget);
    expect(find.text('Waiting for placements'), findsOneWidget);
  });
}
