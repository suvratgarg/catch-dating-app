import 'package:catch_dating_app/clubs/shared/club_action_keys.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/clubs/clubs_test_helpers.dart' as club_helpers;
import '../test/events/events_test_helpers.dart' as event_helpers;
import '../test/support/profile_readiness_fixtures.dart';
import '../test/test_pump_helpers.dart';
import 'support/app_shell_test_harness.dart';
import 'support/app_shell_workflow_steps.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'public Explore discovery opens club details through the real route',
    (tester) async {
      final club = club_helpers.buildClub();

      await pumpCatchAppShell(
        tester,
        initialRoute: Routes.exploreScreen.path,
        overrides: appShellTestOverrides(uid: null, user: null, clubs: [club]),
      );

      await openClubDetail(tester, club);
      await pumpFeatureUi(tester);

      expect(find.text('Stride Social'), findsWidgets);
      expect(
        find.text('Morning runners who like easy city loops.'),
        findsOneWidget,
      );
      expect(find.text('Sign in to join'), findsOneWidget);
    },
  );

  testWidgets('club detail joins through the membership action', (
    tester,
  ) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final clubsRepository = club_helpers.FakeClubsRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        clubsRepository: clubsRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await openClubDetail(tester, club);
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ClubActionKeys.joinButton));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(clubsRepository.joinedClubId, club.id);
  });

  testWidgets('club detail leaves through the membership action', (
    tester,
  ) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final clubsRepository = club_helpers.FakeClubsRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubsRepository: clubsRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await openClubDetail(tester, club);
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ClubActionKeys.leaveButton));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(clubsRepository.leftClubId, club.id);
  });

  testWidgets('clubs tab creates a new club', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final clubsRepository = club_helpers.FakeClubsRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        canCreateClub: true,
        clubsRepository: clubsRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await tapCreateClub(tester);

    await enterClubText('Club name', 'Sunset Striders', tester);
    await enterClubText('Area / neighbourhood', 'Bandra', tester);
    await selectClubCity(tester, 'Mumbai');
    await tapCatchButton(tester, 'Next');

    await enterClubText('Description', 'Easy social club', tester);
    await tapCatchButton(tester, 'Next');
    await tapCatchButton(tester, 'Next');
    await tapCatchButton(tester, 'Create club');
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(clubsRepository.lastCreateCall, isNotNull);
    expect(clubsRepository.lastCreateCall?.name, 'Sunset Striders');
    expect(clubsRepository.lastCreateCall?.location, 'mumbai');
    expect(clubsRepository.lastCreateCall?.area, 'Bandra');
    expect(clubsRepository.lastCreateCall?.description, 'Easy social club');
  });

  testWidgets('clubs tab uploads picked club photos while creating a club', (
    tester,
  ) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final clubsRepository = club_helpers.FakeClubsRepository();
    final pickedCover = await generatedPngXFile('club-cover.png');
    final imageUploadRepository = club_helpers.FakeImageUploadRepository(
      pickedImages: [pickedCover],
      uploadResult: 'https://example.com/uploaded-cover.jpg',
    );

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        canCreateClub: true,
        clubsRepository: clubsRepository,
        imageUploadRepository: imageUploadRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await tapCreateClub(tester);

    await tester.tap(find.text('Add club photos'));
    await pumpFeatureUi(tester);

    await enterClubText('Club name', 'Sunset Striders', tester);
    await enterClubText('Area / neighbourhood', 'Bandra', tester);
    await selectClubCity(tester, 'Mumbai');
    await tapCatchButton(tester, 'Next');

    await enterClubText('Description', 'Easy social club', tester);
    await tapCatchButton(tester, 'Next');
    await tapCatchButton(tester, 'Next');
    await tapCatchButton(tester, 'Create club');
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(imageUploadRepository.lastUploadClubId, isNotNull);
    expect(
      await imageUploadRepository.lastUploadedImage?.readAsBytes(),
      isNotEmpty,
    );
    expect(imageUploadRepository.uploadedClubPhotoPositions, [0]);
    expect(clubsRepository.lastUpdatedClubId, clubsRepository.generatedId);
    expect(
      clubsRepository.lastUpdatedFields?['imageUrl'],
      imageUploadRepository.uploadResult,
    );
    expect(clubsRepository.lastUpdatedFields?['clubPhotos'], isA<List>());
  });

  testWidgets('host edits a club from club detail', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub(
      hostUserId: user.uid,
      hostName: user.name,
    );
    final clubsRepository = club_helpers.FakeClubsRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubsRepository: clubsRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await openClubDetail(tester, club);
    await pumpFeatureUi(tester);
    await tester.scrollUntilVisible(find.byKey(ClubActionKeys.editButton), 240);
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ClubActionKeys.editButton));
    await pumpFeatureUi(tester);

    await tapCatchButton(tester, 'Next');
    await enterClubText('Description', 'Updated host-led city loops.', tester);
    await tapCatchButton(tester, 'Next');
    await tapCatchButton(tester, 'Next');
    await tapCatchButton(tester, 'Save changes');
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(clubsRepository.lastUpdatedClubId, club.id);
    expect(
      clubsRepository.lastUpdatedFields?['description'],
      'Updated host-led city loops.',
    );
  });

  testWidgets('club schedule opens an event detail route with booking CTA', (
    tester,
  ) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final run = event_helpers.buildEvent(
      id: 'run-1',
      clubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 2,
    );

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubEvents: {
          club.id: [run],
        },
      ),
    );

    await openAppTab(tester, 'Explore');
    await openClubDetail(tester, club);
    await pumpFeatureUi(tester);
    await openEventDetail(tester, club: club, event: run);

    expect(find.text('Carter Road Amphitheatre'), findsWidgets);
    expect(find.text('Join event — 18 spots left'), findsOneWidget);
  });

  testWidgets('host creates an event from club detail', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub(
      hostUserId: user.uid,
      hostName: user.name,
    );
    final eventRepository = event_helpers.FakeEventRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubsRepository: club_helpers.FakeClubsRepository(),
        eventRepository: eventRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await openClubDetail(tester, club);
    await pumpFeatureUi(tester);
    await tester.scrollUntilVisible(
      find.byKey(ClubActionKeys.addEventButton),
      240,
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ClubActionKeys.addEventButton));
    await pumpFeatureUi(tester);

    await submitValidEvent(tester);

    expect(eventRepository.createdEvent, isNotNull);
    expect(eventRepository.createdEvent?.clubId, club.id);
    expect(eventRepository.createdEvent?.meetingPoint, 'Bandra Fort');
    expect(eventRepository.createdEvent?.startingPointLat, 19.12345);
    expect(eventRepository.createdEvent?.startingPointLng, 72.98765);
    expect(eventRepository.createdEvent?.distanceKm, 7.5);
    expect(eventRepository.createdEvent?.capacityLimit, 18);
    expect(eventRepository.createdEvent?.priceInPaise, 24950);
    expect(find.text('EVENT CREATED'), findsOneWidget);
    expect(find.text('Your event is live.'), findsOneWidget);
  });
}
