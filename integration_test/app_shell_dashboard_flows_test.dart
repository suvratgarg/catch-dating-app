import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_action_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/clubs/clubs_test_helpers.dart' as club_helpers;
import '../test/events/events_test_helpers.dart' as event_helpers;
import '../test/support/profile_readiness_fixtures.dart';
import '../test/test_pump_helpers.dart';
import 'support/app_shell_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    await pumpFeatureUi(tester);

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
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(eventRepository.selfCheckedInEventId, run.id);
    expect(find.text('CHECKED IN'), findsOneWidget);
    expect(find.text('Checked in.'), findsOneWidget);
  });

  testWidgets('dashboard host attendance toggles an attendee', (tester) async {
    final host = buildSocialReadyUser(uid: 'host-1', name: 'Suvrat Garg');
    final club = club_helpers.buildClub(
      hostUserId: host.uid,
      hostName: host.name,
    );
    final run = event_helpers.buildEvent(
      id: 'attendance-run-1',
      clubId: club.id,
      startTime: DateTime.now().subtract(const Duration(minutes: 5)),
      endTime: DateTime.now().add(const Duration(minutes: 55)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final attendeeProfile = event_helpers.buildPublicProfile(
      uid: 'runner-2',
      name: 'Taylor',
    );
    final eventRepository = event_helpers.FakeEventRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: host.uid,
        user: host,
        clubs: [club],
        joinedClubIds: {club.id},
        clubEvents: {
          club.id: [run],
        },
        eventParticipations: {
          run.id: [
            event_helpers.buildEventParticipation(event: run, uid: 'runner-2'),
          ],
        },
        publicProfiles: [attendeeProfile],
        eventRepository: eventRepository,
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(HostEventActionKeys.takeAttendanceButton),
      240,
      scrollable: findPrimaryScrollable(),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Host event'), findsOneWidget);
    expect(find.text('Attendance open'), findsOneWidget);
    await tester.tap(find.byKey(HostEventActionKeys.takeAttendanceButton));
    await pumpFeatureUi(tester);

    expect(find.text('Editable roster'), findsOneWidget);
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('Booked'), findsOneWidget);
    expect(find.text('Check in'), findsOneWidget);

    await tester.tap(
      find.byKey(HostEventActionKeys.attendeeCheckInButton('runner-2')),
    );
    await flushTestEventQueue();
    await pumpMutationUi(tester);

    expect(eventRepository.markedAttendanceEventId, run.id);
    expect(eventRepository.markedAttendanceUserId, 'runner-2');
  });

  testWidgets('dashboard recommended event opens event detail', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final nextRun = event_helpers.buildEvent(
      id: 'run-1',
      clubId: club.id,
      startTime: DateTime.now().add(const Duration(hours: 3)),
      bookedCount: 1,
    );
    final recommendedRun = event_helpers.buildEvent(
      id: 'recommended-run-1',
      clubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
      meetingPoint: 'Joggers Park Gate',
      bookedCount: 3,
    );

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpEvents: [nextRun],
        recommendedEvents: [recommendedRun],
      ),
    );

    final recommendedTitle = find.text(recommendedRun.title);
    for (var i = 0; i < 5; i += 1) {
      if (recommendedTitle.hitTestable().evaluate().isNotEmpty) break;
      await tester.dragFrom(const Offset(200, 700), const Offset(0, -240));
      await pumpFeatureUi(tester);
    }
    await tester.tap(recommendedTitle.hitTestable());
    await pumpFeatureUi(tester);

    expect(find.text('Joggers Park Gate'), findsWidgets);
    expect(find.text('Join event — 17 spots left'), findsOneWidget);
  });
}
