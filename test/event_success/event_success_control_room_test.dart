import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart' show buildEvent;

void main() {
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
                onOpenGuests: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('LIVE NOW'), findsOneWidget);
      expect(find.textContaining('SYNCED'), findsOneWidget);
      expect(find.textContaining('Step 2 of 4'), findsOneWidget);
      expect(find.text('18 checked in · 24 expected'), findsOneWidget);
      expect(find.text('Guests'), findsOneWidget);
      expect(find.text('Help & fallback'), findsOneWidget);
      expect(find.byType(CatchBottomAction), findsOneWidget);
      expect(
        tester.getBottomRight(find.byType(CatchBottomAction)).dy,
        lessThanOrEqualTo(812),
      );
    },
  );
}
