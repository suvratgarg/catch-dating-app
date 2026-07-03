import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_settings_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_settings_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller_card.dart';
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

  test('HostSettingsState uses club fallback while profile is loading', () {
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

    final state = buildHostSettingsState(
      uid: _hostUid,
      profile: const AsyncLoading<HostProfile?>(),
      clubs: AsyncData<List<Club>>([ownedClub]),
    );

    final profileState = state.profile;
    expect(profileState, isA<HostSettingsProfileContent>());
    final content = profileState as HostSettingsProfileContent;
    expect(content.isFallback, isTrue);
    expect(content.profile.displayName, 'Suvrat');
    expect(content.profile.roleTitle, 'Owner');
    expect(state.clubs, isA<HostSettingsClubsContent>());
  });

  test('HostSettingsActionState maps account and club navigation policy', () {
    final profile = HostProfile(
      uid: _hostUid,
      displayName: 'Asha Host',
      status: HostProfileStatus.active,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Owner Club',
      ownerUserId: _hostUid,
    );
    final cohostClub = buildClub(
      id: 'cohost-club',
      name: 'Co-host Club',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );

    final editState = buildHostSettingsState(
      uid: _hostUid,
      profile: AsyncData<HostProfile?>(profile),
      clubs: AsyncData<List<Club>>([ownedClub, cohostClub]),
    );
    expect(editState.actions.canSignOut, isTrue);
    expect(editState.actions.canCreateProfile, isFalse);
    expect(editState.actions.canEditProfile, isTrue);
    expect(
      editState.actions.clubNavigationFor(ownedClub).destination,
      HostSettingsClubDestination.edit,
    );
    expect(
      editState.actions.clubNavigationFor(cohostClub).destination,
      HostSettingsClubDestination.preview,
    );
    expect(
      editState.actions.clubNavigationFor(cohostClub).roleLabel,
      'Host team',
    );

    final previewState = buildHostSettingsState(
      uid: _hostUid,
      profile: const AsyncData<HostProfile?>(null),
      clubs: const AsyncData<List<Club>>([]),
      editMode: false,
      signOutPending: true,
    );
    expect(previewState.actions.canSignOut, isFalse);
    expect(previewState.actions.canCreateProfile, isTrue);
    expect(previewState.actions.canEditProfile, isFalse);
    expect(
      previewState.actions.clubNavigationFor(ownedClub).destination,
      HostSettingsClubDestination.preview,
    );
  });

  test('HostProfileEditState maps profile async branches', () {
    final profile = HostProfile(
      uid: _hostUid,
      displayName: 'Asha Host',
      status: HostProfileStatus.active,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    expect(
      buildHostProfileEditState(
        uid: null,
        profile: const AsyncData<HostProfile?>(null),
      ),
      isA<HostProfileEditAuthRequired>(),
    );
    expect(
      buildHostProfileEditState(
        uid: _hostUid,
        profile: const AsyncLoading<HostProfile?>(),
      ),
      isA<HostProfileEditLoading>(),
    );
    expect(
      buildHostProfileEditState(
        uid: _hostUid,
        profile: const AsyncData<HostProfile?>(null),
      ),
      isA<HostProfileEditMissing>(),
    );
    expect(
      buildHostProfileEditState(
        uid: _hostUid,
        profile: AsyncData<HostProfile?>(profile),
      ),
      isA<HostProfileEditContent>(),
    );
  });

  test('HostClubsScreenState resolves selected club, tab, and owner role', () {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Owner Club',
      ownerUserId: _hostUid,
    );
    final cohostClub = buildClub(
      id: 'cohost-club',
      name: 'Co-host Club',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );

    final state = HostClubsScreenState.resolve(
      clubs: [ownedClub, cohostClub],
      currentUid: _hostUid,
      selectedClubId: cohostClub.id,
      selectedTab: HostClubTab.insights,
    );

    expect(state.selectedClub, cohostClub);
    expect(state.title, 'Co-host Club');
    expect(state.selectedClubIsOwner, isFalse);
    expect(state.showClubPicker, isTrue);
    expect(state.selectedTab, HostClubTab.insights);

    final ownerState = state.selectClubIndex(0).selectTab(HostClubTab.preview);
    expect(ownerState.selectedClub, ownedClub);
    expect(ownerState.selectedClubIsOwner, isTrue);
    expect(ownerState.selectedTab, HostClubTab.preview);

    final clampedState = HostClubsScreenState.resolve(
      clubs: [ownedClub],
      currentUid: _hostUid,
      selectedClubIndex: 99,
    );
    expect(clampedState.selectedClub, ownedClub);
    expect(clampedState.selectedTab, HostClubTab.organizer);
  });

  test('HostClubInsightsState owns analytics query and event scope', () {
    final state = HostClubInsightsState.initial(
      clubId: 'club-1',
      now: DateTime(2026, 6, 25, 12),
    );

    expect(state.rangePreset, HostClubInsightsRangePreset.thirtyDays);
    expect(state.granularity, HostClubInsightsGranularity.day);
    expect(state.customStartDate, DateTime(2026, 5, 27));
    expect(state.customEndDate, DateTime(2026, 6, 25));
    expect(state.query.clubId, 'club-1');
    expect(state.query.eventId, isNull);

    final scoped = state
        .selectGranularity(HostClubInsightsGranularity.week)
        .selectEvent('event-1')
        .selectCustomStartDate(DateTime(2026, 6, 1, 18))
        .selectCustomEndDate(DateTime(2026, 6, 20, 9));

    expect(scoped.rangePreset, HostClubInsightsRangePreset.custom);
    expect(scoped.query.clubId, 'club-1');
    expect(scoped.query.eventId, 'event-1');
    expect(scoped.query.granularity, HostClubInsightsGranularity.week);
    expect(scoped.query.startDate, DateTime(2026, 6));
    expect(scoped.query.endDate, DateTime(2026, 6, 20));

    final switchedClub = scoped.selectClub('club-2');
    expect(switchedClub.query.clubId, 'club-2');
    expect(switchedClub.selectedEventId, isNull);
    expect(switchedClub.rangePreset, HostClubInsightsRangePreset.custom);
  });

  test('HostHomeScreenState resolves selected club and host role', () {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Owner Club',
      ownerUserId: _hostUid,
    );
    final cohostClub = buildClub(
      id: 'cohost-club',
      name: 'Co-host Club',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );

    final state = HostHomeScreenState.resolve(
      clubs: [ownedClub, cohostClub],
      currentUid: _hostUid,
      selectedClubId: cohostClub.id,
    );

    expect(state.selectedClub, cohostClub);
    expect(state.title, 'Co-host Club');
    expect(state.selectedClubIsOwner, isFalse);
    expect(state.selectedClubRoleLabel, 'Host team');
    expect(state.showClubPicker, isTrue);
    expect(state.selectedTab, HostHomeTab.today);

    final ownerState = state.selectClubIndex(0);
    expect(ownerState.selectedClub, ownedClub);
    expect(ownerState.selectedClubIsOwner, isTrue);
    expect(ownerState.selectedClubRoleLabel, 'Owner');
    expect(ownerState.selectedTab, HostHomeTab.today);

    final eventsState = ownerState.selectTab(HostHomeTab.events);
    expect(eventsState.selectedTab, HostHomeTab.events);
    expect(eventsState.selectedClub, ownedClub);

    final clampedState = HostHomeScreenState.resolve(
      clubs: [ownedClub],
      currentUid: _hostUid,
      selectedClubIndex: 99,
    );
    expect(clampedState.selectedClub, ownedClub);
  });

  test('HostHomeRouteState maps auth and club async branches', () {
    final club = buildClub(id: 'owned-club', ownerUserId: _hostUid);
    final stackTrace = StackTrace.current;
    final authError = StateError('auth failed');
    final clubsError = StateError('clubs failed');

    expect(
      buildHostHomeRouteState(uid: const AsyncData<String?>(null)).status,
      HostHomeRouteStatus.authRequired,
    );
    expect(
      buildHostHomeRouteState(uid: const AsyncLoading<String?>()).status,
      HostHomeRouteStatus.loading,
    );

    final authErrorState = buildHostHomeRouteState(
      uid: AsyncError<String?>(authError, stackTrace),
    );
    expect(authErrorState.status, HostHomeRouteStatus.error);
    expect(authErrorState.error, authError);
    expect(authErrorState.errorContext, AppErrorContext.auth);

    expect(
      buildHostHomeRouteState(
        uid: const AsyncData<String?>(_hostUid),
        clubs: const AsyncLoading<List<Club>>(),
      ).status,
      HostHomeRouteStatus.loading,
    );

    final clubsErrorState = buildHostHomeRouteState(
      uid: const AsyncData<String?>(_hostUid),
      clubs: AsyncError<List<Club>>(clubsError, stackTrace),
    );
    expect(clubsErrorState.status, HostHomeRouteStatus.error);
    expect(clubsErrorState.uid, _hostUid);
    expect(clubsErrorState.error, clubsError);
    expect(clubsErrorState.errorContext, AppErrorContext.club);

    final emptyState = buildHostHomeRouteState(
      uid: const AsyncData<String?>(_hostUid),
      clubs: const AsyncData<List<Club>>([]),
    );
    expect(emptyState.status, HostHomeRouteStatus.empty);
    expect(emptyState.uid, _hostUid);

    final loadedState = buildHostHomeRouteState(
      uid: const AsyncData<String?>(_hostUid),
      clubs: AsyncData<List<Club>>([club]),
    );
    expect(loadedState.status, HostHomeRouteStatus.loaded);
    expect(loadedState.clubs, [club]);
  });

  testWidgets('Host clubs shows loading while uid resolves', (tester) async {
    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [uidProvider.overrideWithValue(const AsyncLoading<String?>())],
      settle: false,
    );

    expect(find.byType(HostLoadingScreen), findsOneWidget);
    expect(find.text('Clubs'), findsOneWidget);
    expect(find.text('Sign in required'), findsNothing);
  });

  testWidgets('Host account shows loading while uid resolves', (tester) async {
    await _pumpHostScreen(
      tester,
      const HostAccountScreen(),
      overrides: [uidProvider.overrideWithValue(const AsyncLoading<String?>())],
      settle: false,
    );

    expect(find.byType(HostLoadingScreen), findsOneWidget);
    expect(find.text('Host profile'), findsOneWidget);
    expect(find.text('Sign in required'), findsNothing);
  });

  testWidgets('Host profile route shows loading while uid resolves', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      const HostProfileScreen(),
      overrides: [uidProvider.overrideWithValue(const AsyncLoading<String?>())],
      settle: false,
    );

    expect(find.byType(HostLoadingScreen), findsOneWidget);
    expect(find.text('Professional profile'), findsOneWidget);
    expect(find.text('Sign in required'), findsNothing);
  });

  testWidgets('Host payment card shows loading while uid resolves', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      HostPaymentAccountControllerCard(
        club: buildClub(id: 'owned-club', ownerUserId: _hostUid),
      ),
      overrides: [uidProvider.overrideWithValue(const AsyncLoading<String?>())],
      settle: false,
    );

    expect(find.byType(HostPaymentAccountLoadingCard), findsOneWidget);
    expect(find.text('Connect payouts to get paid'), findsNothing);
  });

  test(
    'HostHomeEventRowsState sorts, limits, and filters cancelled events',
    () {
      final early = buildEvent(
        id: 'early',
        startTime: DateTime(2026, 6, 15, 8),
      );
      final middle = buildEvent(
        id: 'middle',
        startTime: DateTime(2026, 6, 15, 12),
      );
      final late = buildEvent(id: 'late', startTime: DateTime(2026, 6, 15, 18));
      final latest = buildEvent(
        id: 'latest',
        startTime: DateTime(2026, 6, 15, 22),
      );
      final cancelled = buildEvent(
        id: 'cancelled',
        startTime: DateTime(2026, 6, 15, 6),
      ).copyWith(status: EventLifecycleStatus.cancelled);

      final state = HostHomeEventRowsState.fromEvents([
        late,
        cancelled,
        middle,
        latest,
        early,
      ]);

      expect(state.isEmpty, isFalse);
      expect(state.rows.map((row) => row.event.id), [
        'early',
        'middle',
        'late',
      ]);
      expect(state.rows.map((row) => row.divider), [false, true, true]);
    },
  );

  test('HostHomeEventsSectionState maps event async branches', () {
    final event = buildEvent();
    final cancelled = buildEvent(
      id: 'cancelled',
      startTime: DateTime(2026, 6, 14),
    ).copyWith(status: EventLifecycleStatus.cancelled);
    final stackTrace = StackTrace.current;
    final error = StateError('events failed');

    expect(
      buildHostHomeEventsSectionState(const AsyncLoading<List<Event>>()).status,
      HostHomeEventsStatus.loading,
    );

    final errorState = buildHostHomeEventsSectionState(
      AsyncError<List<Event>>(error, stackTrace),
    );
    expect(errorState.status, HostHomeEventsStatus.error);
    expect(errorState.error, error);

    final emptyState = buildHostHomeEventsSectionState(
      AsyncData<List<Event>>([cancelled]),
    );
    expect(emptyState.status, HostHomeEventsStatus.empty);
    expect(emptyState.rows.isEmpty, isTrue);

    final populatedState = buildHostHomeEventsSectionState(
      AsyncData<List<Event>>([event, cancelled]),
    );
    expect(populatedState.status, HostHomeEventsStatus.populated);
    expect(populatedState.rows.rows.single.event, event);
  });

  test('HostHomeTodayDashboardState maps next event and tasks', () {
    final early = buildEvent(
      id: 'early',
      startTime: DateTime(2026, 6, 15, 17),
      bookedCount: 24,
      waitlistedCount: 6,
    ).copyWith(capacityLimit: 30);
    final late = buildEvent(id: 'late', startTime: DateTime(2026, 6, 16, 20));
    final cancelled = buildEvent(
      id: 'cancelled',
      startTime: DateTime(2026, 6, 14),
    ).copyWith(status: EventLifecycleStatus.cancelled);

    expect(
      buildHostHomeTodayDashboardState(
        const AsyncLoading<List<Event>>(),
      ).status,
      HostHomeTodayStatus.loading,
    );

    final emptyState = buildHostHomeTodayDashboardState(
      AsyncData<List<Event>>([cancelled]),
    );
    expect(emptyState.status, HostHomeTodayStatus.empty);

    final contentState = buildHostHomeTodayDashboardState(
      AsyncData<List<Event>>([late, early, cancelled]),
    );
    expect(contentState.status, HostHomeTodayStatus.content);
    expect(contentState.event, early);
    expect(contentState.tasks, hasLength(4));
    expect(contentState.tasks.first.title, 'Approve requests');
    expect(contentState.tasks[1].primaryActionLabel, 'Offer 6');
  });

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
      const HostOperationsHomeScreen(initialTab: HostHomeTab.events),
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
      const HostOperationsHomeScreen(initialTab: HostHomeTab.events),
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

  testWidgets('Host clubs defaults to organizer overview', (tester) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      description: 'Dawn runs along the Bandra seafront, every Sunday.',
      location: 'Mumbai',
      ownerUserId: _hostUid,
      tags: const ['social run', 'coffee', 'beginner'],
      memberCount: 128,
      rating: 4.8,
      reviewCount: 42,
      hostProfiles: const [
        ClubHostProfile(
          uid: _hostUid,
          displayName: 'Owner Host',
          role: ClubHostRole.owner,
        ),
        ClubHostProfile(uid: 'co-host', displayName: 'Co Host'),
      ],
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub]),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
      ],
    );

    expect(
      find.byKey(const ValueKey('host-club-organizer-overview')),
      findsOneWidget,
    );
    expect(find.text('How guests see you'), findsOneWidget);
    expect(find.text('Team · 2'), findsOneWidget);
    expect(find.text('Trends · last 12 weeks'), findsOneWidget);
    expect(find.text('Manage'), findsWidgets);
    expect(find.text('Connect payouts to get paid'), findsOneWidget);

    await tester.tap(find.text('Set up payouts'));
    await pumpFeatureUi(tester);

    expect(find.text('Identity'), findsOneWidget);
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
      const HostClubsScreen(initialTab: HostClubTab.edit),
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

    await tester.tap(find.text('Open public preview'));
    await pumpFeatureUi(tester);

    expect(find.text('Club cohost-club'), findsOneWidget);
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
      const HostClubsScreen(initialTab: HostClubTab.edit),
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
    final doneButton = find.text('Done');
    final editorScrollView = find.ancestor(
      of: descriptionEditor,
      matching: find.byType(Scrollable),
    );
    expect(editorScrollView, findsOneWidget);
    await tester.drag(editorScrollView, const Offset(0, -96));
    await pumpFeatureUi(tester);
    await tester.tap(doneButton);
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
        matching: find.byType(CatchField),
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

  testWidgets('Host account creates a missing professional profile', (
    tester,
  ) async {
    final repository = _FakeHostProfileRepository();

    await _pumpHostScreen(
      tester,
      const HostAccountScreen(),
      overrides: [
        ..._hostClubOverrides(),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostProfile?>(null)),
        hostProfileRepositoryProvider.overrideWith((ref) => repository),
      ],
    );

    await tester.tap(find.text('Create host profile'));
    await pumpFeatureUi(tester);

    expect(repository.ensuredUid, _hostUid);
  });

  testWidgets('Host account no-profile row shows create pending state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: [
              HostSettingsProfileSection(
                state: const HostSettingsProfileMissing(),
                editMode: true,
                creatingProfile: true,
                onRetry: () {},
                onCreateProfile: () {},
                onEditProfile: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 50));

    expect(find.text('Creating profile...'), findsOneWidget);
    expect(find.byType(CatchLoadingIndicator), findsOneWidget);
    expect(find.text('Create host profile'), findsNothing);
  });

  testWidgets('Host account surfaces missing profile creation failures', (
    tester,
  ) async {
    final repository = _FakeHostProfileRepository(throwOnEnsure: true);

    await _pumpHostScreen(
      tester,
      const HostAccountScreen(),
      overrides: [
        ..._hostClubOverrides(),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostProfile?>(null)),
        hostProfileRepositoryProvider.overrideWith((ref) => repository),
      ],
    );

    await tester.tap(find.text('Create host profile'));
    await pumpFeatureUi(tester);

    expect(find.text('Create host profile'), findsOneWidget);
    expect(find.text('create failed'), findsOneWidget);
  });

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
        matching: find.byType(CatchField),
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

  testWidgets('Host account keeps profile editor open after save failure', (
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
    final repository = _FakeHostProfileRepository(
      profile: profile,
      throwOnSave: true,
    );

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

    await tester.tap(find.text('Display name'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Save profile'));
    await pumpFeatureUi(tester);

    expect(find.byType(CatchBottomSheetScaffold), findsOneWidget);
    expect(find.text('save failed'), findsOneWidget);
    expect(repository.savedUid, isNull);
  });

  testWidgets('Host account surfaces sign out failures', (tester) async {
    final profile = HostProfile(
      uid: _hostUid,
      displayName: 'Asha Host',
      status: HostProfileStatus.active,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final authRepository = _FakeHostAuthRepository(throwOnSignOut: true);

    await _pumpHostScreen(
      tester,
      const HostAccountScreen(),
      overrides: [
        ..._hostClubOverrides(),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(AsyncData<HostProfile?>(profile)),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );

    await tester.tap(find.byTooltip('Sign out'));
    await pumpFeatureUi(tester);

    expect(authRepository.signOutCallCount, 1);
    expect(find.text('sign out failed'), findsOneWidget);
    expect(find.byType(HostAccountScreen), findsOneWidget);
  });

  testWidgets('Host profile route creates a missing professional profile', (
    tester,
  ) async {
    final repository = _FakeHostProfileRepository();

    await _pumpHostScreen(
      tester,
      const HostProfileScreen(),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostProfile?>(null)),
        hostProfileRepositoryProvider.overrideWith((ref) => repository),
      ],
    );

    await tester.tap(find.text('Create host profile'));
    await pumpFeatureUi(tester);

    expect(repository.ensuredUid, _hostUid);
  });

  testWidgets('Host profile route surfaces missing profile creation failures', (
    tester,
  ) async {
    final repository = _FakeHostProfileRepository(throwOnEnsure: true);

    await _pumpHostScreen(
      tester,
      const HostProfileScreen(),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostProfile?>(null)),
        hostProfileRepositoryProvider.overrideWith((ref) => repository),
      ],
    );

    await tester.tap(find.text('Create host profile'));
    await pumpFeatureUi(tester);

    expect(find.text('No host profile yet'), findsOneWidget);
    expect(find.text('create failed'), findsOneWidget);
  });

  testWidgets('Host profile route validates required display name', (
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
      const HostProfileScreen(),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(AsyncData<HostProfile?>(profile)),
        hostProfileRepositoryProvider.overrideWith((ref) => repository),
      ],
    );

    final displayNameField = find.descendant(
      of: find.widgetWithText(CatchField, 'Display name'),
      matching: find.byType(TextField),
    );
    await tester.enterText(displayNameField, '');
    await tester.tap(find.text('Save profile'));
    await pumpFeatureUi(tester);

    expect(find.text('Enter a display name.'), findsOneWidget);
    expect(repository.savedUid, isNull);
  });

  testWidgets('Host profile route surfaces save failures', (tester) async {
    final profile = HostProfile(
      uid: _hostUid,
      displayName: 'Asha Host',
      roleTitle: 'Founder',
      bio: 'Runs easy miles.',
      status: HostProfileStatus.active,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final repository = _FakeHostProfileRepository(
      profile: profile,
      throwOnSave: true,
    );

    await _pumpHostScreen(
      tester,
      const HostProfileScreen(),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(AsyncData<HostProfile?>(profile)),
        hostProfileRepositoryProvider.overrideWith((ref) => repository),
      ],
    );

    await tester.tap(find.text('Save profile'));
    await pumpFeatureUi(tester);

    expect(find.text('Professional profile'), findsOneWidget);
    expect(find.text('save failed'), findsOneWidget);
    expect(repository.savedUid, isNull);
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
  bool settle = true,
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
  if (settle) {
    await pumpFeatureUi(tester);
  } else {
    await tester.pump();
    await tester.pump();
  }
}

class _FakeHostProfileRepository implements HostProfileRepository {
  _FakeHostProfileRepository({
    this.profile,
    this.throwOnEnsure = false,
    this.throwOnSave = false,
  });

  HostProfile? profile;
  final bool throwOnEnsure;
  final bool throwOnSave;
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
    if (throwOnEnsure) throw StateError('create failed');
    ensuredUid = uid;
  }

  @override
  Future<void> saveHostProfile({
    required String uid,
    required String displayName,
    String? roleTitle,
    String? bio,
  }) async {
    if (throwOnSave) throw StateError('save failed');
    savedUid = uid;
    savedDisplayName = displayName;
    savedRoleTitle = roleTitle;
    savedBio = bio;
  }
}

class _FakeHostAuthRepository extends Fake implements AuthRepository {
  _FakeHostAuthRepository({this.throwOnSignOut = false});

  final bool throwOnSignOut;
  int signOutCallCount = 0;

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
    if (throwOnSignOut) throw StateError('sign out failed');
  }
}
