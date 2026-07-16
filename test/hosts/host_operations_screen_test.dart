import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_settings_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_settings_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
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
final _l10n = AppLocalizationsEn();

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
    expect(state.title(AppLocalizationsEn()), 'Co-host Club');
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
    expect(state.selectedClubIsOwner, isFalse);
    expect(state.showClubPicker, isTrue);
    expect(state.selectedTab, HostHomeTab.today);

    final ownerState = state.selectClubIndex(0);
    expect(ownerState.selectedClub, ownedClub);
    expect(ownerState.selectedClubIsOwner, isTrue);
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

  testWidgets('CatchSection.fieldRows rows align to the section text lane', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CatchSection.fieldRows(
            title: 'Profile',
            first: true,
            children: [
              CatchField.nav(
                title: 'Display name',
                valueText: 'Suvrat',
                icon: Icons.person_outline,
              ),
            ],
          ),
        ),
      ),
    );

    final sectionLeft = tester.getTopLeft(find.text('PROFILE')).dx;
    final rowTextLeft = tester.getTopLeft(find.text('Display name')).dx;

    expect(
      rowTextLeft - sectionLeft,
      moreOrLessEquals(CatchFieldRow.textLaneInset, epsilon: 0.5),
    );
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

  test('Host Events groups upcoming rows and derives truthful metadata', () {
    final now = DateTime(2026, 6, 15, 12);
    final today = buildEvent(
      id: 'today',
      startTime: DateTime(2026, 6, 15, 18),
      bookedCount: 24,
    ).copyWith(capacityLimit: 30);
    final july = buildEvent(
      id: 'july',
      startTime: DateTime(2026, 7, 2, 9),
      bookedCount: 40,
    );
    final nextYear = buildEvent(
      id: 'next-year',
      startTime: DateTime(2027, 6, 1, 9),
    );
    final past = buildEvent(
      id: 'past',
      startTime: DateTime(2026, 6, 14, 9),
      endTime: DateTime(2026, 6, 14, 10),
    );
    final cancelled = buildEvent(
      id: 'cancelled',
      startTime: DateTime(2026, 6, 15, 17),
    ).copyWith(status: EventLifecycleStatus.cancelled);

    final state = HostEventsWorkspaceState.fromEvents(
      events: [nextYear, july, cancelled, past, today],
      now: now,
      selectedFilter: HostEventsLifecycleFilter.upcoming,
    );

    expect(state.status, HostEventsWorkspaceStatus.populated);
    expect(state.sections.map((section) => section.label), [
      'June',
      'July',
      'June 2027',
    ]);
    expect(
      state.sections
          .expand((section) => section.rows)
          .map((row) => row.event.id),
      ['today', 'july', 'next-year'],
    );
    final todayRow = state.sections.first.rows.single;
    expect(todayRow.isToday, isTrue);
    expect(todayRow.metaLabel, 'Today · 24 going');
    expect(todayRow.fillPercent, 80);
    expect(state.sections[1].rows.single.fillRatio, 1);
    expect(state.repeatSource, past);
  });

  test('Host Events classifies exact lifecycle boundaries', () {
    final now = DateTime(2026, 6, 15, 12);
    final startsNow = buildEvent(
      id: 'starts-now',
      startTime: now,
      endTime: now.add(const Duration(hours: 1)),
    );
    final endsNow = buildEvent(
      id: 'ends-now',
      startTime: now.subtract(const Duration(hours: 1)),
      endTime: now,
      checkedInCount: 12,
      bookedCount: 15,
    );

    final live = HostEventsWorkspaceState.fromEvents(
      events: [endsNow, startsNow],
      now: now,
      selectedFilter: HostEventsLifecycleFilter.live,
    );
    expect(live.sections.single.rows.single.event, startsNow);
    expect(live.sections.single.rows.single.isLive, isTrue);

    final past = HostEventsWorkspaceState.fromEvents(
      events: [endsNow, startsNow],
      now: now,
      selectedFilter: HostEventsLifecycleFilter.past,
    );
    expect(past.sections.single.rows.single.event, endsNow);
    expect(past.sections.single.rows.single.metaLabel, contains('12 attended'));
    expect(past.sections.single.rows.single.metaLabel, contains('free'));
  });

  test(
    'Host Events async state maps loading, error, and filter empty copy',
    () {
      final now = DateTime(2026, 6, 15, 12);
      final cancelled = buildEvent(
        id: 'cancelled',
        startTime: DateTime(2026, 6, 14),
      ).copyWith(status: EventLifecycleStatus.cancelled);
      final stackTrace = StackTrace.current;
      final error = StateError('events failed');

      expect(
        buildHostEventsWorkspaceState(
          const AsyncLoading<List<Event>>(),
          now: now,
          selectedFilter: HostEventsLifecycleFilter.upcoming,
        ).status,
        HostEventsWorkspaceStatus.loading,
      );

      final errorState = buildHostEventsWorkspaceState(
        AsyncError<List<Event>>(error, stackTrace),
        now: now,
        selectedFilter: HostEventsLifecycleFilter.live,
      );
      expect(errorState.status, HostEventsWorkspaceStatus.error);
      expect(errorState.error, error);

      final emptyState = buildHostEventsWorkspaceState(
        AsyncData<List<Event>>([cancelled]),
        now: now,
        selectedFilter: HostEventsLifecycleFilter.live,
      );
      expect(emptyState.status, HostEventsWorkspaceStatus.empty);
      expect(emptyState.emptyTitle(_l10n), 'Nothing live right now');
      expect(emptyState.emptyBody(_l10n), contains('when it starts'));
    },
  );

  test('HostHomeTodayDashboardState maps next event and tasks', () {
    final now = DateTime(2026, 6, 15, 12);
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
        now: now,
        l10n: _l10n,
      ).status,
      HostHomeTodayStatus.loading,
    );

    final emptyState = buildHostHomeTodayDashboardState(
      AsyncData<List<Event>>([cancelled]),
      now: now,
      l10n: _l10n,
    );
    expect(emptyState.status, HostHomeTodayStatus.empty);

    final contentState = buildHostHomeTodayDashboardState(
      AsyncData<List<Event>>([late, early, cancelled]),
      now: now,
      l10n: _l10n,
    );
    expect(contentState.status, HostHomeTodayStatus.content);
    expect(contentState.event, early);
    expect(contentState.tasks, hasLength(1));
    expect(contentState.tasks.first.id, 'waitlist:early');
    expect(contentState.tasks.first.event, early);
    expect(contentState.tasks.first.title, 'Review waitlist');
    expect(
      contentState.tasks.first.destination,
      HostHomeTodayTaskDestination.guests,
    );
    expect(contentState.laterEvents, hasLength(1));
    expect(contentState.laterEvents.single.event, late);
  });

  test(
    'Host Today excludes concurrent live rows and unsupported approvals',
    () {
      final now = DateTime(2026, 6, 15, 12);
      final hero = buildEvent(
        id: 'hero-live',
        startTime: DateTime(2026, 6, 15, 10),
        endTime: DateTime(2026, 6, 15, 14),
      );
      final overlapping = buildEvent(
        id: 'overlapping-live',
        startTime: DateTime(2026, 6, 15, 11),
        endTime: DateTime(2026, 6, 15, 13),
      );
      final approval =
          buildEvent(
            id: 'approval-event',
            startTime: DateTime(2026, 6, 16, 18),
            waitlistedCount: 3,
          ).copyWith(
            eventPolicy: EventPolicyBundle.requestToJoinEvent(
              capacityLimit: 20,
              basePriceInPaise: 0,
            ),
          );

      final state = buildHostHomeTodayDashboardState(
        AsyncData<List<Event>>([approval, overlapping, hero]),
        now: now,
        l10n: _l10n,
      );

      expect(state.event, hero);
      expect(state.laterEvents.map((row) => row.event.id), ['approval-event']);
      expect(state.tasks, isEmpty);
    },
  );

  test('Host Today keeps every real task instead of truncating work', () {
    final now = DateTime(2026, 6, 15, 12);
    final events = List.generate(
      5,
      (index) => buildEvent(
        id: 'task-$index',
        startTime: now.add(Duration(hours: index + 1)),
        waitlistedCount: index + 1,
      ),
    );

    final state = buildHostHomeTodayDashboardState(
      AsyncData<List<Event>>(events),
      now: now,
      l10n: _l10n,
    );

    expect(state.tasks, hasLength(5));
    expect(state.tasks.map((task) => task.event.id), [
      'task-0',
      'task-1',
      'task-2',
      'task-3',
      'task-4',
    ]);
  });

  testWidgets('Host Today uses real countdown and routes cross-event tasks', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15, 12);
    final club = buildClub(id: 'today-club', ownerUserId: _hostUid);
    final hero = buildEvent(
      id: 'hero-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 17),
    );
    final later = buildEvent(
      id: 'later-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 16, 20),
      waitlistedCount: 3,
    );

    await _pumpHostScreen(
      tester,
      HostOperationsHomeScreen(now: now),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([hero, later])),
      ],
    );

    expect(find.text('STARTS IN 5H'), findsOneWidget);
    expect(find.text('Review waitlist'), findsOneWidget);
    expect(find.textContaining('3 waiting · 20 spots open'), findsOneWidget);
    expect(find.text('Check host setup'), findsNothing);
    expect(find.byType(HostEventLifecycleRow), findsOneWidget);
    expect(find.text(later.title), findsOneWidget);

    await tester.tap(find.text('REVIEW'));
    await pumpFeatureUi(tester);
    expect(find.text('Manage ${later.id}'), findsOneWidget);
    expect(find.text('Section guests'), findsOneWidget);
  });

  testWidgets('Host Today opens a live hero in the run-of-show', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15, 12);
    final club = buildClub(id: 'live-club', ownerUserId: _hostUid);
    final live = buildEvent(
      id: 'live-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 11),
      endTime: DateTime(2026, 6, 15, 13),
    );

    await _pumpHostScreen(
      tester,
      HostOperationsHomeScreen(now: now),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([live])),
      ],
    );

    expect(find.text('LIVE NOW'), findsOneWidget);
    expect(find.text('Open run-of-show'), findsOneWidget);
    await tester.tap(find.text('Open run-of-show'));
    await pumpFeatureUi(tester);
    expect(find.text('Manage live-event'), findsOneWidget);
    expect(find.text('Section live'), findsOneWidget);
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
      HostOperationsHomeScreen(
        initialTab: HostHomeTab.events,
        now: DateTime(2026, 6, 15, 12),
      ),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([event])),
      ],
    );

    expect(find.text('Events'), findsWidgets);
    expect(find.byTooltip('Create club'), findsNothing);
    expect(find.byTooltip('Switch club'), findsNothing);
    expect(find.text('New event'), findsOneWidget);
    expect(find.text('Repeat last'), findsOneWidget);
    expect(find.text('View club'), findsNothing);
    expect(find.text('View public profile'), findsNothing);

    await tester.tap(find.text(event.title));
    await pumpFeatureUi(tester);

    expect(find.text('Manage ${event.id}'), findsOneWidget);
  });

  testWidgets('Host events filters lifecycle rows and repeats a past event', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15, 12);
    final club = buildClub(id: 'club-host', ownerUserId: _hostUid);
    final past = buildEvent(
      id: 'past-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 14, 9),
      endTime: DateTime(2026, 6, 14, 10),
    );
    final live = buildEvent(
      id: 'live-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 11),
      endTime: DateTime(2026, 6, 15, 13),
    );
    final upcoming = buildEvent(
      id: 'upcoming-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 16, 18),
    );

    await _pumpHostScreen(
      tester,
      HostOperationsHomeScreen(initialTab: HostHomeTab.events, now: now),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([past, live, upcoming])),
      ],
    );

    expect(find.text(upcoming.title), findsOneWidget);
    expect(find.text(live.title), findsNothing);
    expect(find.text(past.title), findsNothing);
    expect(find.text('Repeat ‘Social run’'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await pumpFeatureUi(tester);
    expect(find.text(live.title), findsOneWidget);
    expect(find.text(upcoming.title), findsNothing);

    await tester.tap(find.text('Past'));
    await pumpFeatureUi(tester);
    expect(find.text(past.title), findsOneWidget);

    await tester.tap(find.text('Repeat ‘Social run’'));
    await pumpFeatureUi(tester);
    expect(find.text('Repeat ${past.id}'), findsOneWidget);
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
      HostOperationsHomeScreen(
        initialTab: HostHomeTab.events,
        now: DateTime(2026, 6, 15, 12),
      ),
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
      findsWidgets,
    );
    expect(find.text('How guests see you'), findsOneWidget);
    expect(find.text('Team · 2'), findsOneWidget);
    expect(find.text('Trends · last 12 weeks'), findsOneWidget);
    expect(find.text('Manage'), findsWidgets);
    expect(find.text('Connect payouts to get paid'), findsOneWidget);

    await tester.tap(find.text('Set up payouts'));
    await pumpFeatureUi(tester);

    expect(find.text('IDENTITY'), findsOneWidget);
  });

  testWidgets('Host Insights resolves the exact club and owns range chrome', (
    tester,
  ) async {
    final firstClub = buildClub(
      id: 'first-club',
      name: 'First Club',
      ownerUserId: _hostUid,
    );
    final exactClub = buildClub(
      id: 'exact-club',
      name: 'Bandra Social',
      ownerUserId: _hostUid,
    );

    await _pumpHostScreen(
      tester,
      const HostInsightsScreen(clubId: 'exact-club'),
      overrides: [
        ..._hostClubOverrides(owned: [firstClub, exactClub]),
        hostAnalyticsRepositoryProvider.overrideWithValue(
          _EmptyHostAnalyticsRepository(
            topEvents: [_hostAnalyticsEventRow(eventId: 'top-event')],
          ),
        ),
      ],
    );

    expect(find.text('Bandra Social · all events'), findsOneWidget);
    expect(find.text('First Club · all events'), findsNothing);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.byTooltip('Back to Organizer'), findsOneWidget);
    expect(find.text('30 days'), findsOneWidget);
    expect(find.text('Organizer'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Preview'), findsNothing);

    await tester.tap(find.text('30 days'));
    await pumpFeatureUi(tester);
    expect(find.text('Date range'), findsOneWidget);
    await tester.tap(find.text('7 DAYS'));
    await tester.tap(find.text('Apply range'));
    await pumpFeatureUi(tester);
    expect(find.text('7 days'), findsOneWidget);

    await tester.ensureVisible(find.text('Top event'));
    await tester.tap(find.text('Top event'));
    await pumpFeatureUi(tester);
    expect(find.text('Manage top-event'), findsOneWidget);
    expect(find.text('Section report'), findsOneWidget);
  });

  testWidgets('Host analytics trend renders every backend bucket', (
    tester,
  ) async {
    final points = List.generate(
      30,
      (index) => HostAnalyticsTrendPoint(
        periodStart: DateTime(2026, 6, index + 1),
        periodEnd: DateTime(2026, 6, index + 2),
        metrics: {'demand': index + 2, 'bookings': index + 1},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: HostAnalyticsTrendPanel(points: points)),
      ),
    );

    expect(find.byType(HostAnalyticsDualBar), findsNWidgets(30));
    expect(find.byType(CatchSection), findsOneWidget);
  });

  testWidgets('Host analytics loading uses canonical section rhythm', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: HostAnalyticsReportSkeleton()),
        ),
      ),
    );

    final stack = tester.widget<CatchSectionStack>(
      find.byType(CatchSectionStack),
    );
    expect(stack.gap, 0);
    expect(find.byType(CatchSection), findsNWidgets(4));
  });

  testWidgets('Host Insights never falls back when the route club is unknown', (
    tester,
  ) async {
    final availableClub = buildClub(
      id: 'available-club',
      name: 'Available Club',
      ownerUserId: _hostUid,
    );

    await _pumpHostScreen(
      tester,
      const HostInsightsScreen(clubId: 'missing-club'),
      overrides: _hostClubOverrides(owned: [availableClub]),
    );

    expect(find.text('Insights unavailable'), findsOneWidget);
    expect(find.text('Available Club · all events'), findsNothing);

    await tester.tap(find.text('Back to Organizer'));
    await pumpFeatureUi(tester);
    expect(find.text('Organizer route'), findsOneWidget);
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
    expect(find.text('IDENTITY'), findsOneWidget);
    expect(find.text('Club name'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('Area / neighbourhood'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('CONTACT'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('@sundayseafacecrew'), findsOneWidget);
    expect(find.text('EVENT DEFAULTS'), findsOneWidget);
    expect(find.text('Default activity'), findsOneWidget);
    expect(find.text('Admission'), findsOneWidget);
    expect(find.text('Age range'), findsOneWidget);
    expect(find.text('Cancellation policy'), findsOneWidget);
    expect(find.text('PUBLIC PROFILE'), findsOneWidget);
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
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
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
    expect(find.text('Something went wrong. Please try again.'), findsWidgets);
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
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
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
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
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
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(repository.savedUid, isNull);
  });

  testWidgets('Host profile route saves and keeps the editor open', (
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

    await tester.enterText(
      find.descendant(
        of: find.widgetWithText(CatchField, 'Display name'),
        matching: find.byType(TextField),
      ),
      'Updated Host',
    );
    await tester.enterText(
      find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is CatchField && widget.title == 'Role title',
        ),
        matching: find.byType(TextField),
      ),
      'Lead organizer',
    );
    await tester.enterText(
      find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is CatchField && widget.title == 'Bio',
        ),
        matching: find.byType(TextField),
      ),
      'Curates social runs.',
    );
    await tester.tap(find.text('Save profile'));
    await pumpFeatureUi(tester);

    expect(repository.savedUid, _hostUid);
    expect(repository.savedDisplayName, 'Updated Host');
    expect(repository.savedRoleTitle, 'Lead organizer');
    expect(repository.savedBio, 'Curates social runs.');
    expect(find.byType(HostProfileScreen), findsOneWidget);
    expect(find.text('Host profile saved.'), findsOneWidget);
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
        path: Routes.hostOrganizerScreen.path,
        name: Routes.hostOrganizerScreen.name,
        builder: (_, _) => const Text('Organizer route'),
      ),
      GoRoute(
        path: Routes.hostCreateClubScreen.path,
        name: Routes.hostCreateClubScreen.name,
        builder: (_, _) => const Text('Create club route'),
      ),
      GoRoute(
        path: Routes.hostCreateEventScreen.path,
        name: Routes.hostCreateEventScreen.name,
        builder: (_, state) => switch (state.extra) {
          final HostCreateEventRouteArguments arguments
              when arguments.initialPrefill != null =>
            Text('Repeat ${arguments.initialPrefill!.sourceEventId}'),
          _ => Text('Create ${state.pathParameters['clubId']}'),
        },
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
        builder: (_, state) => Column(
          children: [
            Text('Manage ${state.pathParameters['eventId']}'),
            Text('Section ${state.uri.queryParameters['section'] ?? 'setup'}'),
          ],
        ),
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

final class _EmptyHostAnalyticsRepository implements HostAnalyticsRepository {
  const _EmptyHostAnalyticsRepository({this.topEvents = const []});

  final List<HostAnalyticsEventRow> topEvents;

  @override
  Future<HostAnalyticsReport> getHostAnalytics(HostAnalyticsQuery query) async {
    return HostAnalyticsReport(
      generatedAt: DateTime(2026, 7, 10),
      summaryCards: const [],
      trend: const [],
      topEvents: topEvents,
      reviewSummary: const HostAnalyticsReviewSummary(
        newReviews: 0,
        publishedReviews: 0,
        verifiedReviews: 0,
        publicReviews: 0,
        ownerResponseCount: 0,
        averageRating: 0,
      ),
      discoverySummary: const HostAnalyticsDiscoverySummary(
        listingViews: 0,
        searchAppearances: 0,
        eventViews: 0,
        organizerSaves: 0,
        eventSaves: 0,
        contactClicks: 0,
        claimClicks: 0,
        outboundClicks: 0,
      ),
      dataQuality: const [],
    );
  }
}

HostAnalyticsEventRow _hostAnalyticsEventRow({required String eventId}) =>
    HostAnalyticsEventRow(
      eventId: eventId,
      clubId: 'exact-club',
      title: 'Top event',
      startTime: DateTime(2026, 7, 8, 19),
      status: 'completed',
      bookedCount: 20,
      checkedInCount: 18,
      waitlistedCount: 2,
      fillRate: 1,
      checkInRate: 0.9,
      grossRevenueMinor: 0,
      currency: 'INR',
      checkoutStartedCount: 0,
      checkoutDropoffCount: 0,
      paymentCompletedCount: 0,
      paymentFailedCount: 0,
      paymentRefundedCount: 0,
      reviewCount: 2,
      averageRating: 4.5,
      demandCount: 24,
      inviteOpenCount: 3,
      mutualMatchCount: 4,
      chatStartedCount: 2,
      repeatAttendeeCount: 5,
    );
