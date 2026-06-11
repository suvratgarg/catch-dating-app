import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../clubs/clubs_test_helpers.dart';
import '../test_pump_helpers.dart';

const _hostUid = 'host-1';

void main() {
  setUp(() {
    AppConfig.configureEntrypointRole(AppRole.host);
  });

  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  testWidgets('Host events has no create-club header and opens event manage', (
    tester,
  ) async {
    final club = buildClub(id: 'club-host', ownerUserId: _hostUid);
    final event = buildEvent(
      id: 'event-host',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 17),
    );

    await _pumpHostScreen(
      tester,
      const HostOperationsHomeScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([event])),
      ],
    );

    expect(find.text('Host events'), findsOneWidget);
    expect(find.byTooltip('Create club'), findsNothing);
    expect(find.text('Add event'), findsOneWidget);
    expect(find.text('View club'), findsNothing);
    expect(find.text('View public profile'), findsNothing);

    await tester.tap(find.text(event.title));
    await pumpFeatureUi(tester);

    expect(find.text('Manage ${event.id}'), findsOneWidget);
  });

  testWidgets('Host clubs owns profile management without event CTAs', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      ownerUserId: _hostUid,
      hostProfiles: const [
        ClubHostProfile(
          uid: _hostUid,
          displayName: 'Owner Host',
          role: ClubHostRole.owner,
        ),
        ClubHostProfile(uid: 'co-host', displayName: 'Co Host'),
      ],
    );
    final cohostClub = buildClub(
      id: 'cohost-club',
      name: 'Co-hosted Club',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub], hosted: [cohostClub]),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
      ],
    );

    expect(find.text('Clubs'), findsOneWidget);
    expect(find.byTooltip('Create club'), findsNothing);
    expect(find.text('Owned club'), findsOneWidget);
    expect(find.text('Edit club profile'), findsOneWidget);
    expect(find.text('View public profile'), findsWidgets);
    expect(find.text('Payouts'), findsOneWidget);
    expect(find.text('Host team'), findsWidgets);
    expect(find.byTooltip('Add host'), findsOneWidget);
    expect(find.text('Add event'), findsNothing);
    expect(find.text('View club'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await pumpFeatureUi(tester);
    expect(find.text('Host teams'), findsOneWidget);
    expect(find.text('Co-hosted Club'), findsOneWidget);
  });

  testWidgets('Host account opens and saves active professional profile', (
    tester,
  ) async {
    final profile = HostProfile(
      uid: _hostUid,
      displayName: 'Asha Host',
      roleTitle: 'Founder',
      bio: 'Runs easy miles.',
      status: HostProfileStatus.active,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final repository = _FakeHostProfileRepository(profile: profile);

    await _pumpHostScreen(
      tester,
      const HostAccountScreen(),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(AsyncData<HostProfile?>(profile)),
        hostProfileRepositoryProvider.overrideWith((ref) => repository),
      ],
    );

    expect(find.text('Active professional profile'), findsOneWidget);
    await tester.tap(find.text('View / edit profile'));
    await pumpFeatureUi(tester);

    expect(find.text('Professional profile'), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);

    final displayNameField = find.ancestor(
      of: find.text('Display name'),
      matching: find.byType(CatchTextField),
    );
    await tester.enterText(
      find.descendant(of: displayNameField, matching: find.byType(TextField)),
      'Updated Host',
    );
    await tester.tap(find.text('Save profile'));
    await pumpFeatureUi(tester);

    expect(repository.savedDisplayName, 'Updated Host');
    expect(repository.savedRoleTitle, 'Founder');
    expect(repository.savedBio, 'Runs easy miles.');
  });
}

List _hostClubOverrides({
  List<Club> owned = const [],
  List<Club> hosted = const [],
}) {
  return [
    uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
    watchClubsOwnedByProvider(
      _hostUid,
    ).overrideWithValue(AsyncData<List<Club>>(owned)),
    watchClubsHostedByProvider(
      _hostUid,
    ).overrideWithValue(AsyncData<List<Club>>(hosted)),
  ];
}

Future<void> _pumpHostScreen(
  WidgetTester tester,
  Widget child, {
  List overrides = const [],
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => child),
      GoRoute(
        path: Routes.hostCreateClubScreen.path,
        name: Routes.hostCreateClubScreen.name,
        builder: (_, _) => const Text('Create club route'),
      ),
      GoRoute(
        path: Routes.hostCreateEventScreen.path,
        name: Routes.hostCreateEventScreen.name,
        builder: (_, state) => Text('Create ${state.pathParameters['clubId']}'),
      ),
      GoRoute(
        path: Routes.hostClubDetailScreen.path,
        name: Routes.hostClubDetailScreen.name,
        builder: (_, state) => Text('Club ${state.pathParameters['clubId']}'),
      ),
      GoRoute(
        path: Routes.hostEditClubScreen.path,
        name: Routes.hostEditClubScreen.name,
        builder: (_, state) => Text('Edit ${state.pathParameters['clubId']}'),
      ),
      GoRoute(
        path: Routes.hostAppEventManageScreen.path,
        name: Routes.hostAppEventManageScreen.name,
        builder: (_, state) =>
            Text('Manage ${state.pathParameters['eventId']}'),
      ),
      GoRoute(
        path: Routes.hostProfileScreen.path,
        name: Routes.hostProfileScreen.name,
        builder: (_, _) => const HostProfileScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await pumpFeatureUi(tester);
}

class _FakeHostProfileRepository implements HostProfileRepository {
  _FakeHostProfileRepository({this.profile});

  HostProfile? profile;
  String? ensuredUid;
  String? savedUid;
  String? savedDisplayName;
  String? savedRoleTitle;
  String? savedBio;

  @override
  Stream<HostProfile?> watchHostProfile(String uid) => Stream.value(profile);

  @override
  Future<void> ensureHostProfile({
    required String uid,
    required String displayName,
  }) async {
    ensuredUid = uid;
  }

  @override
  Future<void> saveHostProfile({
    required String uid,
    required String displayName,
    String? roleTitle,
    String? bio,
  }) async {
    savedUid = uid;
    savedDisplayName = displayName;
    savedRoleTitle = roleTitle;
    savedBio = bio;
  }
}
