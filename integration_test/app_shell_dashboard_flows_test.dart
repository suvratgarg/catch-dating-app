import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/clubs/clubs_test_helpers.dart' as club_helpers;
import '../test/events/events_test_helpers.dart' as event_helpers;
import '../test/support/profile_readiness_fixtures.dart';
import 'support/app_shell_test_binding.dart';
import 'support/app_shell_test_harness.dart';

void main() {
  ensureAppShellTestBinding();

  testWidgets('dashboard next-event card opens event detail', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final run = event_helpers.buildEvent(
      id: 'run-1',
      clubId: club.id,
      startTime: DateTime.now().add(const Duration(hours: 3)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpEvents: [run],
      ),
    );

    await tester.tap(find.byKey(EventFocusRail.actionKey('viewEvent')));
    await pumpAppShellFrames(tester);

    expect(find.text('Carter Road Amphitheatre'), findsWidgets);
    expect(find.text('Cancel booking'), findsOneWidget);
  });

  testWidgets('dashboard self check-in records attendance', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final run = event_helpers.buildEvent(
      id: 'check-in-run-1',
      clubId: club.id,
      startTime: DateTime.now().add(const Duration(minutes: 5)),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final eventRepository = event_helpers.FakeEventRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpEvents: [run],
        eventRepository: eventRepository,
      ),
    );

    expect(find.text('Check-in open'), findsOneWidget);
    await tester.tap(find.byKey(EventFocusRail.actionKey('checkIn')));
    await flushAppShellCallbacks(tester);
    await pumpAppShellFrames(tester);

    expect(eventRepository.selfCheckedInEventId, run.id);
    expect(find.text('CHECKED IN'), findsOneWidget);
    expect(find.text('Checked in.'), findsOneWidget);
  });
}
