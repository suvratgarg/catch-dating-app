import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart';
import '../test_pump_helpers.dart';

const _hostUid = 'host-1';
const _switcherKey = ValueKey('host-today-club-switcher');
const _identityArtKey = ValueKey('host-today-club-identity-art');

void main() {
  testWidgets('single-club identity is explicitly passive', (tester) async {
    final club = buildClub(name: 'Sea Face Social', ownerUserId: _hostUid);

    await _pumpSwitcher(
      tester,
      club: club,
      clubs: [club],
      showClubPicker: true,
    );

    final surface = tester.widget<CatchSurface>(find.byKey(_switcherKey));
    expect(surface.onTap, isNull);
    expect(find.byType(MenuAnchor), findsNothing);
    expect(find.byIcon(CatchIcons.expandMoreRounded), findsNothing);
  });

  testWidgets('multi-club identity opens from the whole bounded surface', (
    tester,
  ) async {
    final ownerClub = buildClub(
      id: 'owner-club',
      name: 'Sea Face Social',
      ownerUserId: _hostUid,
    );
    final teamClub = buildClub(
      id: 'team-club',
      name: 'Long Table Club',
      ownerUserId: 'another-owner',
      hostUserIds: const [_hostUid],
    );
    var selectedIndex = -1;

    await _pumpSwitcher(
      tester,
      club: ownerClub,
      clubs: [ownerClub, teamClub],
      showClubPicker: true,
      onSwitchClubIndex: (index) => selectedIndex = index,
    );

    final surface = tester.widget<CatchSurface>(find.byKey(_switcherKey));
    expect(surface.onTap, isNotNull);
    expect(find.byIcon(CatchIcons.expandMoreRounded), findsOneWidget);

    await tester.tap(find.byKey(_identityArtKey));
    await pumpFeatureUi(tester);

    final ownerOption = find.byKey(
      const ValueKey('host-today-club-option-owner-club'),
    );
    final teamOption = find.byKey(
      const ValueKey('host-today-club-option-team-club'),
    );
    expect(ownerOption, findsOneWidget);
    expect(teamOption, findsOneWidget);
    expect(
      find.descendant(of: ownerOption, matching: find.text('Owner')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: teamOption, matching: find.text('Host team')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: ownerOption, matching: find.byIcon(CatchIcons.check)),
      findsOneWidget,
    );
    expect(tester.widget<Semantics>(ownerOption).properties.selected, isTrue);
    expect(tester.widget<Semantics>(teamOption).properties.selected, isFalse);

    await tester.tap(
      find.descendant(of: teamOption, matching: find.text('Long Table Club')),
    );
    await pumpFeatureUi(tester);

    expect(selectedIndex, 1);
  });

  testWidgets('identity art prefers the real logo with activity fallback', (
    tester,
  ) async {
    const logoPath = 'assets/fixtures/club_hero_portrait.jpg';
    final clubWithLogo = buildClub(
      name: 'Sea Face Social',
      profileImageUrl: logoPath,
    );

    await _pumpSwitcher(tester, club: clubWithLogo, clubs: [clubWithLogo]);

    var art = tester.widget<CatchPersonAvatar>(find.byKey(_identityArtKey));
    expect(art.imageUrl, logoPath);
    expect(art.initials, 'SF');
    expect(art.activityKind, ActivityKind.socialRun);

    final clubWithoutLogo = buildClub(name: 'Long Table Club');
    await _pumpSwitcher(
      tester,
      club: clubWithoutLogo,
      clubs: [clubWithoutLogo],
    );

    art = tester.widget<CatchPersonAvatar>(find.byKey(_identityArtKey));
    expect(art.imageUrl, isNull);
    expect(art.initials, 'LT');
    expect(art.activityKind, ActivityKind.socialRun);
  });

  testWidgets('identity surface and menu remain stable at 2x text', (
    tester,
  ) async {
    final ownerClub = buildClub(
      id: 'owner-club',
      name: 'Sea Face Social With An Intentionally Long Name',
      ownerUserId: _hostUid,
    );
    final teamClub = buildClub(
      id: 'team-club',
      name: 'Long Table Club With An Intentionally Long Name',
      ownerUserId: 'another-owner',
      hostUserIds: const [_hostUid],
    );

    await _pumpSwitcher(
      tester,
      club: ownerClub,
      clubs: [ownerClub, teamClub],
      showClubPicker: true,
      textScale: 2,
    );
    await tester.tap(find.byKey(_switcherKey));
    await pumpFeatureUi(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('host-today-club-option-owner-club')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('host-today-club-option-team-club')),
      findsOneWidget,
    );
  });
}

Future<void> _pumpSwitcher(
  WidgetTester tester, {
  required Club club,
  required List<Club> clubs,
  bool showClubPicker = false,
  ValueChanged<int>? onSwitchClubIndex,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: HostTodayClubPill(
              club: club,
              currentUid: _hostUid,
              clubs: clubs,
              showClubPicker: showClubPicker,
              onSwitchClubIndex: onSwitchClubIndex ?? (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await pumpFeatureUi(tester);
}
