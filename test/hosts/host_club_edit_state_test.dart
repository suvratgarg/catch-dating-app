import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_create_club_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final club = Club(
    id: 'club-1',
    name: 'Sea Face Social',
    description: 'Hosted social formats.',
    location: 'Mumbai',
    area: 'Bandra',
    hostUserId: 'owner-1',
    hostName: 'Mira',
    ownerUserId: 'owner-1',
    hostUserIds: const ['owner-1', 'cohost-1'],
    createdAt: DateTime(2026),
  );

  test('HostClubEditState maps owner and co-host edit modes', () {
    final ownerState = HostClubEditState.resolve(
      club: club,
      uid: const AsyncData<String?>('owner-1'),
    );
    expect(ownerState.mode, HostClubEditMode.ownerFull);
    expect(ownerState.canEdit, isTrue);
    expect(ownerState.mediaOnly, isFalse);

    final cohostState = HostClubEditState.resolve(
      club: club,
      uid: const AsyncData<String?>('cohost-1'),
    );
    expect(cohostState.mode, HostClubEditMode.cohostMediaOnly);
    expect(cohostState.canEdit, isTrue);
    expect(cohostState.mediaOnly, isTrue);
  });

  test('HostClubEditState blocks missing and non-host identity', () {
    expect(
      HostClubEditState.resolve(
        club: club,
        uid: const AsyncLoading<String?>(),
      ).mode,
      HostClubEditMode.loadingIdentity,
    );

    expect(
      HostClubEditState.resolve(
        club: club,
        uid: const AsyncData<String?>(null),
      ).mode,
      HostClubEditMode.forbidden,
    );

    expect(
      HostClubEditState.resolve(
        club: club,
        uid: const AsyncData<String?>('guest-1'),
      ).mode,
      HostClubEditMode.forbidden,
    );
  });

  testWidgets('HostEditClubRouteScreen blocks non-host edit route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('guest-1')),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: HostEditClubRouteScreen(clubId: club.id, initialClub: club),
        ),
      ),
    );

    expect(find.text('Host access required'), findsOneWidget);
    expect(find.text('Edit club'), findsNothing);
  });
}
