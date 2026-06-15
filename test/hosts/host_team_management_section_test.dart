import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
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
    expect(find.widgetWithText(CatchTextField, 'Phone number'), findsOneWidget);
    expect(find.widgetWithText(CatchButton, 'Add host'), findsOneWidget);

    final phoneField = find.descendant(
      of: find.widgetWithText(CatchTextField, 'Phone number'),
      matching: find.byType(TextField),
    );
    await tester.enterText(phoneField, '98765 43210');
    await tester.tap(find.widgetWithText(CatchButton, 'Add host'));
    await pumpFeatureUi(tester);

    expect(repository.addedHostClubId, 'owned-club');
    expect(repository.addedHostPhoneNumber, '98765 43210');
  });
}
