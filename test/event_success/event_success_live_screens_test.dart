import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart'
    show
        buildClub,
        buildEvent,
        buildEventParticipation,
        buildPublicProfile,
        buildUser;

void main() {
  testWidgets('host screen exposes setup live mode and report tabs', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 3000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final event = buildEvent(bookedCount: 10, checkedInCount: 6);
    final plan = EventSuccessPlan.defaultForEvent(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessHostScreen(
            club: buildClub(),
            event: event,
            plan: plan,
            planIsPersisted: true,
            roster: const EventParticipationRoster(
              bookedIds: ['a', 'b', 'c'],
              checkedInIds: ['a', 'b'],
              waitlistedIds: [],
            ),
            feedback: const [],
          ),
        ),
      ),
    );

    expect(find.text('Event success'), findsOneWidget);
    expect(find.text('Setup'), findsWidgets);
    expect(find.text('Save setup'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();
    expect(find.text('Live host mode'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(find.text('Post-event host report'), findsOneWidget);
  });

  testWidgets(
    'companion screen shows private follow-up and feedback after attendance',
    (tester) async {
      final start = DateTime(2026, 5, 18, 7);
      final event = buildEvent(
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
      );
      final plan = EventSuccessPlan.defaultForEvent(event);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: EventSuccessCompanionScreen(
              event: event,
              plan: plan,
              userProfile: buildUser(uid: 'runner-1'),
              participation: buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
              privateCrushCandidates: [
                buildPublicProfile(uid: 'runner-2', name: 'Rhea'),
              ],
              now: start.add(const Duration(hours: 2)),
            ),
          ),
        ),
      );

      expect(find.text('Event companion'), findsOneWidget);
      expect(find.text('Social prompt'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Private follow-up'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Rhea'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Event feedback'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Submit feedback'), findsOneWidget);
    },
  );
}
