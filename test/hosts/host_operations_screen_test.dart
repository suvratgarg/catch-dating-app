import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
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

    expect(find.text(club.name), findsOneWidget);
    expect(find.byTooltip('Create club'), findsNothing);
    expect(find.byTooltip('Switch club'), findsNothing);
    expect(find.text('Add event'), findsOneWidget);
    expect(find.text('View club'), findsNothing);
    expect(find.text('View public profile'), findsNothing);

    await tester.tap(find.text(event.title));
    await pumpFeatureUi(tester);

    expect(find.text('Manage ${event.id}'), findsOneWidget);
  });

  testWidgets('Host events switches between hosted clubs from the app bar', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      ownerUserId: _hostUid,
    );
    final cohostClub = buildClub(
      id: 'cohost-club',
      name: 'Quizzicals',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );
    final ownedEvent = buildEvent(
      id: 'owned-event',
      clubId: ownedClub.id,
      startTime: DateTime(2026, 6, 15, 17),
    );
    final hostedEvent = buildEvent(
      id: 'hosted-event',
      clubId: cohostClub.id,
      startTime: DateTime(2026, 6, 16, 20),
    );

    await _pumpHostScreen(
      tester,
      const HostOperationsHomeScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub], hosted: [cohostClub]),
        watchEventsForClubProvider(
          ownedClub.id,
        ).overrideWithValue(AsyncData<List<Event>>([ownedEvent])),
        watchEventsForClubProvider(
          cohostClub.id,
        ).overrideWithValue(AsyncData<List<Event>>([hostedEvent])),
      ],
    );

    expect(find.text('Sunday sea-face crew'), findsWidgets);
    expect(find.text(ownedEvent.title), findsOneWidget);
    expect(find.text(hostedEvent.title), findsNothing);

    await tester.tap(find.byTooltip('Switch club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Quizzicals · Host team'));
    await pumpFeatureUi(tester);

    expect(find.text('Quizzicals'), findsOneWidget);
    expect(find.text(hostedEvent.title), findsOneWidget);
    expect(find.text(ownedEvent.title), findsNothing);
    expect(find.text('HOST TEAM'), findsOneWidget);
  });

  testWidgets('Host clubs owns profile management without event CTAs', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      description: 'Dawn runs along the Bandra seafront, every Sunday.',
      location: 'Mumbai',
      ownerUserId: _hostUid,
      instagramHandle: '@sundayseafacecrew',
      phoneNumber: '98765 43210',
      email: 'hello@seafacecrew.com',
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

    expect(find.text('Sunday sea-face crew'), findsWidgets);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Preview'), findsWidgets);
    expect(find.byTooltip('Switch club'), findsOneWidget);
    expect(find.byTooltip('Create club'), findsNothing);
    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Club name'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('Area / neighbourhood'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('@sundayseafacecrew'), findsOneWidget);
    expect(find.text('Event defaults'), findsOneWidget);
    expect(find.text('Default activity'), findsOneWidget);
    expect(find.text('Admission'), findsOneWidget);
    expect(find.text('Age range'), findsOneWidget);
    expect(find.text('Cancellation policy'), findsOneWidget);
    expect(find.text('Public profile'), findsOneWidget);
    expect(find.text('Preview club page'), findsOneWidget);
    expect(find.text('Payouts'), findsWidgets);
    expect(find.text('Host team'), findsWidgets);
    expect(find.byTooltip('Add host'), findsOneWidget);
    expect(find.text('Add event'), findsNothing);
    expect(find.text('View club'), findsNothing);
    expect(find.text('Owned club'), findsNothing);

    await tester.tap(find.byTooltip('Switch club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Co-hosted Club · Host team'));
    await pumpFeatureUi(tester);

    expect(find.text('Co-hosted Club'), findsWidgets);
    expect(find.text('HOST TEAM'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('host-club-tab-rail')),
        matching: find.text('Preview'),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Open public preview'), findsOneWidget);
  });

  testWidgets('Host club fields edit inline without opening edit wizard', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      description: 'Dawn runs along the Bandra seafront, every Sunday.',
      location: 'Mumbai',
      ownerUserId: _hostUid,
    );
    final repository = FakeClubsRepository();

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub]),
        clubsRepositoryProvider.overrideWith((ref) => repository),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
      ],
    );

    await tester.tap(find.text('Description'));
    await pumpFeatureUi(tester);

    expect(find.text('Edit owned-club'), findsNothing);

    final descriptionEditor = find.byKey(
      const ValueKey('host-inline-description'),
    );
    expect(descriptionEditor, findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: descriptionEditor,
        matching: find.byType(EditableText),
      ),
      'Updated dawn loops.',
    );
    await tester.tap(find.text('Done'));
    await pumpFeatureUi(tester);

    expect(find.text('Edit owned-club'), findsNothing);
    expect(repository.lastUpdatedClubId, ownedClub.id);
    expect(
      repository.lastUpdatedFields,
      containsPair('description', 'Updated dawn loops.'),
    );
  });

  testWidgets(
    'Host account edit loads from club snapshot while profile waits',
    (tester) async {
      final ownedClub = buildClub(
        id: 'owned-club',
        name: 'Saket Run Club',
        ownerUserId: _hostUid,
        hostProfiles: const [
          ClubHostProfile(
            uid: _hostUid,
            displayName: 'Suvrat',
            role: ClubHostRole.owner,
          ),
        ],
      );
      final repository = _FakeHostProfileRepository();

      await _pumpHostScreen(
        tester,
        const HostAccountScreen(),
        overrides: [
          ..._hostClubOverrides(owned: [ownedClub]),
          watchHostProfileProvider(
            _hostUid,
          ).overrideWithValue(const AsyncLoading<HostProfile?>()),
          hostProfileRepositoryProvider.overrideWith((ref) => repository),
        ],
      );

      expect(find.byType(CatchLoadingIndicator), findsNothing);
      expect(find.text('Display name'), findsOneWidget);
      expect(find.text('Suvrat'), findsOneWidget);
      expect(find.text('Create host profile'), findsNothing);

      await tester.tap(find.text('Display name'));
      await pumpFeatureUi(tester);
      final displayNameField = find.ancestor(
        of: find.descendant(
          of: find.byType(CatchBottomSheetScaffold),
          matching: find.text('Display name'),
        ),
        matching: find.byType(CatchTextField),
      );
      await tester.enterText(
        find.descendant(of: displayNameField, matching: find.byType(TextField)),
        'Updated Host',
      );
      await tester.tap(find.text('Save profile'));
      await pumpFeatureUi(tester);

      expect(repository.savedUid, _hostUid);
      expect(repository.savedDisplayName, 'Updated Host');
    },
  );

  testWidgets(
    'Host account edits active professional profile in account sheet',
    (tester) async {
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
      await tester.tap(find.text('Display name'));
      await pumpFeatureUi(tester);

      final editorSheet = find.byType(CatchBottomSheetScaffold);
      expect(editorSheet, findsOneWidget);
      expect(find.byType(HostProfileScreen), findsNothing);
      expect(
        find.descendant(
          of: editorSheet,
          matching: find.text('Professional profile'),
        ),
        findsOneWidget,
      );

      final displayNameField = find.ancestor(
        of: find.descendant(
          of: editorSheet,
          matching: find.text('Display name'),
        ),
        matching: find.byType(CatchTextField),
      );
      await tester.enterText(
        find.descendant(of: displayNameField, matching: find.byType(TextField)),
        'Updated Host',
      );
      await tester.tap(find.text('Save profile'));
      await pumpFeatureUi(tester);

      expect(editorSheet, findsNothing);
      expect(repository.savedDisplayName, 'Updated Host');
      expect(repository.savedRoleTitle, 'Founder');
      expect(repository.savedBio, 'Runs easy miles.');
    },
  );
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
