import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('Add host sheet follows handoff copy and submits phone number', (
    tester,
  ) async {
    final repository = FakeClubsRepository();
    final club = buildClub(
      id: 'owned-club',
      ownerUserId: 'host-1',
      hostProfiles: const [
        ClubHostProfile(
          uid: 'host-1',
          displayName: 'Owner Host',
          role: ClubHostRole.owner,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => repository),
          uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: HostTeamManagementSection(club: club, currentUid: 'host-1'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Add host'));
    await pumpFeatureUi(tester);

    expect(find.byType(CatchBottomSheetScaffold), findsOneWidget);
    expect(find.text('Add host'), findsWidgets);
    expect(
      find.text('Enter the phone number on their Catch profile.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(CatchField, 'Phone number'), findsOneWidget);
    expect(find.widgetWithText(CatchButton, 'Add host'), findsOneWidget);

    final phoneField = find.descendant(
      of: find.widgetWithText(CatchField, 'Phone number'),
      matching: find.byType(TextField),
    );
    await tester.tap(find.widgetWithText(CatchField, 'Phone number'));
    await pumpFeatureUi(tester);
    await tester.enterText(phoneField, '98765 43210');
    await tester.tap(find.widgetWithText(CatchButton, 'Add host'));
    await pumpFeatureUi(tester);

    expect(repository.addedHostClubId, 'owned-club');
    expect(repository.addedHostPhoneNumber, '98765 43210');
    expect(find.text('Host added.'), findsOneWidget);
  });

  testWidgets('Remove host confirmation uses shared copy and mutation', (
    tester,
  ) async {
    final repository = FakeClubsRepository();
    final club = _hostTeamClub();

    await _pumpHostTeamSection(tester, repository: repository, club: club);

    await tester.tap(find.byKey(const ValueKey('host-team-actions-host-2')));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Remove host'));
    await pumpFeatureUi(tester);

    expect(find.text('Remove host?'), findsOneWidget);
    expect(
      find.text(
        'Rishi Mehta will stay a club member but will lose host tools.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(CatchButton, 'Remove'));
    await pumpFeatureUi(tester);

    expect(repository.removedHostClubId, 'owned-club');
    expect(repository.removedHostUid, 'host-2');
    expect(find.text('Rishi Mehta removed.'), findsOneWidget);
  });

  testWidgets('Transfer ownership confirmation uses shared copy and mutation', (
    tester,
  ) async {
    final repository = FakeClubsRepository();
    final club = _hostTeamClub();

    await _pumpHostTeamSection(tester, repository: repository, club: club);

    await tester.tap(find.byKey(const ValueKey('host-team-actions-host-2')));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Transfer ownership'));
    await pumpFeatureUi(tester);

    expect(find.text('Transfer ownership?'), findsOneWidget);
    expect(
      find.text(
        'Rishi Mehta will become the club owner. You will remain a host.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(CatchButton, 'Transfer'));
    await pumpFeatureUi(tester);

    expect(repository.transferredOwnershipClubId, 'owned-club');
    expect(repository.transferredOwnershipUid, 'host-2');
    expect(find.text('Ownership transferred to Rishi Mehta.'), findsOneWidget);
  });
}

Club _hostTeamClub() {
  return buildClub(
    id: 'owned-club',
    ownerUserId: 'host-1',
    hostProfiles: const [
      ClubHostProfile(
        uid: 'host-1',
        displayName: 'Owner Host',
        role: ClubHostRole.owner,
      ),
      ClubHostProfile(uid: 'host-2', displayName: 'Rishi Mehta'),
    ],
  );
}

Future<void> _pumpHostTeamSection(
  WidgetTester tester, {
  required FakeClubsRepository repository,
  required Club club,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clubsRepositoryProvider.overrideWith((ref) => repository),
        uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HostTeamManagementSection(club: club, currentUid: 'host-1'),
        ),
      ),
    ),
  );
  await tester.pump();
}
