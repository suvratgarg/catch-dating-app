import 'dart:convert';
import 'dart:typed_data';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_tabbed_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_date_rail_card.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_club_edit_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_view_model.dart';
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
import 'package:image_picker/image_picker.dart';

import '../clubs/clubs_test_helpers.dart';
import '../test_pump_helpers.dart';

const _hostUid = 'host-1';
final _l10n = AppLocalizationsEn();

void main() {
  setUp(() {
    AppConfig.configureEntrypointRole(AppRole.host);
  });

  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  test(
    'HostTeamWorkspaceState uses club fallback while profile is loading',
    () {
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

      final state = buildHostTeamWorkspaceState(
        uid: _hostUid,
        profile: const AsyncLoading<HostProfile?>(),
        clubs: AsyncData<List<Club>>([ownedClub]),
      );

      final profileState = state.profile;
      expect(profileState, isA<HostTeamProfileContent>());
      final content = profileState as HostTeamProfileContent;
      expect(content.isFallback, isTrue);
      expect(content.profile.displayName, 'Suvrat');
      expect(content.profile.roleTitle, 'Owner');
      expect(state.clubs, isA<HostTeamHostedClubsContent>());
    },
  );

  test(
    'HostTeamWorkspaceActionState maps account and club navigation policy',
    () {
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

      final editState = buildHostTeamWorkspaceState(
        uid: _hostUid,
        profile: AsyncData<HostProfile?>(profile),
        clubs: AsyncData<List<Club>>([ownedClub, cohostClub]),
      );
      expect(editState.actions.canSignOut, isTrue);
      expect(editState.actions.canCreateProfile, isFalse);
      expect(editState.actions.canEditProfile, isTrue);
      expect(
        editState.actions.clubNavigationFor(ownedClub).destination,
        HostTeamClubDestination.edit,
      );
      expect(
        editState.actions.clubNavigationFor(cohostClub).destination,
        HostTeamClubDestination.preview,
      );
      expect(
        editState.actions.clubNavigationFor(cohostClub).roleLabel,
        'Host team',
      );

      final previewState = buildHostTeamWorkspaceState(
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
        HostTeamClubDestination.preview,
      );
    },
  );

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
    expect(clampedState.selectedTab, HostClubTab.edit);
  });

  test('HostClubInsightsState owns only club and narrative range', () {
    final state = HostClubInsightsState.initial(clubId: 'club-1');

    expect(state.rangePreset, HostClubInsightsRangePreset.thirtyDays);
    expect(state.query.clubId, 'club-1');

    final ranged = state.selectRange(HostClubInsightsRangePreset.twelveMonths);
    expect(ranged.rangePreset, HostClubInsightsRangePreset.twelveMonths);

    final switchedClub = ranged.selectClub('club-2');
    expect(switchedClub.query.clubId, 'club-2');
    expect(switchedClub.rangePreset, HostClubInsightsRangePreset.twelveMonths);
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

  testWidgets('Host team shows loading while uid resolves', (tester) async {
    await _pumpHostScreen(
      tester,
      const HostClubTeamScreen(clubId: 'owned-club'),
      overrides: [uidProvider.overrideWithValue(const AsyncLoading<String?>())],
      settle: false,
    );

    expect(find.byType(HostLoadingScreen), findsOneWidget);
    expect(find.text('Host team'), findsOneWidget);
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

  testWidgets('Host payout states each own one canonical field-row section', (
    tester,
  ) async {
    final club = buildClub(id: 'owned-club', ownerUserId: _hostUid);
    HostPaymentAccount account({
      required HostPaymentOnboardingStatus status,
      bool chargesEnabled = false,
      bool payoutsEnabled = false,
      String? disabledReason,
    }) => HostPaymentAccount(
      userId: _hostUid,
      country: 'IN',
      defaultCurrency: 'INR',
      stripeAccountId: 'acct_test',
      chargesEnabled: chargesEnabled,
      payoutsEnabled: payoutsEnabled,
      detailsSubmitted: status != HostPaymentOnboardingStatus.notStarted,
      onboardingStatus: status,
      disabledReason: disabledReason,
    );

    await _pumpHostScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              HostPaymentAccountCard(club: club, loading: true),
              HostPaymentAccountCard(
                club: club,
                error: StateError('payout query failed'),
              ),
              HostPaymentAccountCard(club: club),
              HostPaymentAccountCard(
                club: club,
                account: account(status: HostPaymentOnboardingStatus.pending),
              ),
              HostPaymentAccountCard(
                club: club,
                account: account(
                  status: HostPaymentOnboardingStatus.restricted,
                  disabledReason: 'Identity document required',
                ),
              ),
              HostPaymentAccountCard(
                club: club,
                account: account(
                  status: HostPaymentOnboardingStatus.complete,
                  chargesEnabled: true,
                  payoutsEnabled: true,
                ),
              ),
            ],
          ),
        ),
      ),
      settle: false,
    );
    await tester.pump();

    final sections = tester.widgetList<CatchSection>(find.byType(CatchSection));
    expect(sections, hasLength(6));
    expect(sections.every((section) => section.title == 'Payouts'), isTrue);
    expect(
      tester
          .widgetList<CatchDivider>(
            find.descendant(
              of: find.byType(CatchSection),
              matching: find.byType(CatchDivider),
            ),
          )
          .where((divider) => divider.role == CatchDividerRole.section),
      hasLength(6),
    );
    expect(find.byType(CatchSectionHeader), findsNothing);
    expect(find.byType(CatchField), findsWidgets);
    expect(find.text('Set up international payouts'), findsOneWidget);
    expect(find.text('Stripe onboarding is in progress'), findsOneWidget);
    expect(find.text('Stripe needs more information'), findsOneWidget);
    expect(find.text('International checkout is ready'), findsOneWidget);
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

  testWidgets('Host events centers its canonical empty-state primitive', (
    tester,
  ) async {
    final club = buildClub(id: 'empty-club', ownerUserId: _hostUid);

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
        ).overrideWithValue(const AsyncData<List<Event>>([])),
      ],
    );

    expect(find.text('No upcoming events'), findsOneWidget);
    final emptyState = find.byType(CatchEmptyState);
    final content = find.byType(CatchEmptyStateContent);
    expect(
      find.ancestor(of: emptyState, matching: find.byType(Center)),
      findsNothing,
    );
    final fill = tester.widget<SliverFillRemaining>(
      find.ancestor(of: emptyState, matching: find.byType(SliverFillRemaining)),
    );
    expect(fill.hasScrollBody, isTrue);
    expect(
      tester.getCenter(content).dx,
      closeTo(tester.getCenter(emptyState).dx, 0.5),
    );
    expect(
      tester.getCenter(content).dy,
      closeTo(tester.getCenter(emptyState).dy, 0.5),
    );
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
    final olderPast = buildEvent(
      id: 'older-past-event',
      clubId: club.id,
      startTime: DateTime(2026, 5, 27, 9),
      endTime: DateTime(2026, 5, 27, 10),
    );
    final oldestPast = buildEvent(
      id: 'oldest-past-event',
      clubId: club.id,
      startTime: DateTime(2026, 5, 18, 9),
      endTime: DateTime(2026, 5, 18, 10),
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
        watchEventsForClubProvider(club.id).overrideWithValue(
          AsyncData<List<Event>>([oldestPast, olderPast, past, live, upcoming]),
        ),
      ],
    );

    expect(
      find.byType(CatchOptionGroup<HostEventsLifecycleFilter>),
      findsOneWidget,
    );
    expect(find.text(upcoming.title), findsOneWidget);
    expect(find.text(live.title), findsNothing);
    expect(find.text(past.title), findsNothing);
    expect(find.text(olderPast.title), findsNothing);
    expect(find.text(oldestPast.title), findsNothing);
    expect(find.text('Repeat ‘Social run’'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await pumpFeatureUi(tester);
    expect(find.text(live.title), findsOneWidget);
    expect(find.text(upcoming.title), findsNothing);

    await tester.tap(find.text('Past'));
    await pumpFeatureUi(tester);
    expect(find.text(past.title), findsOneWidget);
    expect(find.text(olderPast.title), findsOneWidget);
    expect(find.text(oldestPast.title), findsOneWidget);
    expect(find.byType(HostEventLifecycleRow), findsNothing);

    final juneSection = find.byKey(
      const ValueKey<String>('host-events-month-2026-6'),
    );
    final maySection = find.byKey(
      const ValueKey<String>('host-events-month-2026-5'),
    );
    expect(juneSection, findsOneWidget);
    expect(maySection, findsOneWidget);
    expect(tester.widget<CatchSection>(juneSection).title, 'June');
    expect(tester.widget<CatchSection>(maySection).title, 'May');

    final juneFieldFinder = find.descendant(
      of: juneSection,
      matching: find.byType(CatchField),
    );
    final mayFieldFinder = find.descendant(
      of: maySection,
      matching: find.byType(CatchField),
    );
    expect(juneFieldFinder, findsOneWidget);
    expect(mayFieldFinder, findsNWidgets(2));
    final juneField = tester.widget<CatchField>(juneFieldFinder);
    expect(juneField.title, past.title);
    expect(juneField.body, contains('attended'));
    expect(juneField.leading, isA<HostEventLifecycleDateBlock>());
    expect(
      tester
          .widgetList<CatchField>(mayFieldFinder)
          .every((field) => !field.divider),
      isTrue,
    );
    final mayDividers = tester
        .widgetList<CatchDivider>(
          find.descendant(of: maySection, matching: find.byType(CatchDivider)),
        )
        .toList();
    expect(mayDividers.map((divider) => divider.role), [
      CatchDividerRole.section,
      CatchDividerRole.fieldRow,
    ]);
    final tokens = CatchTokens.of(tester.element(maySection));
    expect(
      CatchDivider.colorFor(tokens, mayDividers.last.role),
      tokens.line.withValues(
        alpha: tokens.line.a * CatchOpacity.fieldRowDivider,
      ),
    );

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
    expect(find.text('Quizzicals'), findsOneWidget);
    expect(find.text('Host team'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('host-today-club-option-cohost-club')),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Quizzicals'), findsOneWidget);
    expect(find.text(hostedEvent.title), findsOneWidget);
    expect(find.text(ownedEvent.title), findsNothing);
  });

  testWidgets('Host clubs defaults to the consolidated edit workspace', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      description: 'Dawn runs along the Bandra seafront, every Sunday.',
      location: 'in-dl-delhi-ncr',
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
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );
    expect(find.text('How guests see you'), findsNothing);
    expect(find.text('Public page'), findsNothing);
    expect(find.text('Preview'), findsWidgets);
    final editSections = tester
        .widgetList<CatchSection>(
          find.descendant(
            of: find.byType(HostClubEditTab),
            matching: find.byType(CatchSection),
          ),
        )
        .toList();
    expect(editSections, hasLength(4));
    expect(editSections.map((section) => section.title), [
      'Media',
      'Identity',
      'Contact',
      'Club settings',
    ]);
    for (final title in ['Media', 'Identity', 'Contact', 'Club settings']) {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is CatchSection && widget.title == title,
        ),
        findsOneWidget,
      );
    }
    expect(find.text('CLUB LOGO'), findsNothing);
    expect(find.text('PHOTOS'), findsNothing);
    expect(find.text('Event defaults'), findsOneWidget);
    expect(find.text('Live event guide'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Host team'), findsOneWidget);
    expect(find.byTooltip('Host team'), findsNothing);
    expect(find.text('Trends · last 12 weeks'), findsNothing);
    expect(find.text('See insights'), findsNothing);
    expect(find.byType(HostAnalyticsTrendPanel), findsNothing);
    expect(find.text('Manage'), findsNothing);
    expect(find.text('Team · 2'), findsNothing);
    expect(find.text('Connect payouts to get paid'), findsNothing);
    expect(find.textContaining('DELHI NCR'), findsNothing);
    expect(find.textContaining('IN-DL-DELHI-NCR'), findsNothing);
    expect(
      tester
          .widgetList<CatchBadge>(find.byType(CatchBadge))
          .where((badge) => badge.label.toLowerCase() == 'social run'),
      isEmpty,
    );

    final hostTeamRow = find.byKey(
      const ValueKey('host-club-settings-host-team'),
    );
    await tester.ensureVisible(hostTeamRow);
    await pumpFeatureUi(tester);
    await tester.tap(hostTeamRow);
    await pumpFeatureUi(tester);

    expect(find.byType(HostClubTeamScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('host-team-sign-out')), findsOneWidget);
  });

  testWidgets('Host club workspace keeps shared chrome across every tab', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Saket Run Club',
      description: 'Morning runs, plenty of sunshine and energy.',
      area: 'Saket',
      location: 'in-mp-indore',
      ownerUserId: _hostUid,
    );
    final secondClub = buildClub(
      id: 'second-club',
      name: 'Second Club',
      ownerUserId: _hostUid,
    );
    final previewEvent = buildEvent(
      clubId: ownedClub.id,
      startTime: DateTime(2030, 7, 20, 7),
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub, secondClub]),
        watchEventsForClubProvider(
          ownedClub.id,
        ).overrideWithValue(AsyncData<List<Event>>([previewEvent])),
        clubDetailViewModelProvider(ownedClub.id).overrideWithValue(
          AsyncData<ClubDetailViewModel?>(
            _previewViewModel(ownedClub, events: [previewEvent]),
          ),
        ),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
        hostAnalyticsRepositoryProvider.overrideWithValue(
          const _EmptyHostAnalyticsRepository(),
        ),
      ],
    );

    final tabRail = find.byKey(const ValueKey('host-club-tab-rail'));

    Finder tab(String label) =>
        find.descendant(of: tabRail, matching: find.text(label));

    void expectSharedChrome({bool switcherVisible = true}) {
      expect(find.byType(CatchTabbedScreenScaffold), findsOneWidget);
      expect(find.byType(NestedScrollView), findsOneWidget);
      expect(find.byType(SliverOverlapAbsorber), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
      expect(tabRail, findsOneWidget);
      expect(tab('Organizer'), findsNothing);
      expect(tab('Edit'), findsOneWidget);
      expect(tab('Insights'), findsOneWidget);
      expect(tab('Preview'), findsOneWidget);
      expect(
        find.byTooltip('Switch club'),
        switcherVisible ? findsOneWidget : findsNothing,
      );
      final workspaceSemantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Club workspace tabs',
        ),
      );
      expect(
        workspaceSemantics.properties.hint,
        'Drag left or right to switch between Edit, Insights, and Preview.',
      );
      final currentPage = tester.widget<CatchTabbedPageScrollView>(
        find.byType(CatchTabbedPageScrollView),
      );
      expect(currentPage.includeTerminalPadding, isTrue);
    }

    expectSharedChrome();
    final loadedHeader = tester.widget<CatchScreenHeaderTitle>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CatchScreenHeaderTitle &&
            widget.title == 'Saket Run Club',
      ),
    );
    expect(loadedHeader.eyebrow, isNull);
    expect(loadedHeader.subtitle, isNull);
    expect(loadedHeader.leading, isNull);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );

    final editWorkspaceScrollable = find
        .descendant(
          of: find.byKey(
            const PageStorageKey<String>('host-club-owned-club-edit-scroll'),
          ),
          matching: find.byType(Scrollable),
        )
        .first;
    await Scrollable.ensureVisible(
      tester.element(
        find.byKey(const ValueKey('host-club-settings-host-team')),
      ),
      alignment: 0.5,
    );
    await pumpFeatureUi(tester);

    expectSharedChrome(switcherVisible: false);
    expect(find.text('IDENTITY'), findsOneWidget);
    expect(find.text('SAKET · INDORE'), findsNothing);
    final editScroll = tester
        .state<ScrollableState>(editWorkspaceScrollable)
        .position;
    expect(editScroll.pixels, greaterThan(0));

    await tester.tap(tab('Insights'));
    await pumpFeatureUi(tester);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsOneWidget,
    );

    expectSharedChrome(switcherVisible: false);
    expect(find.byType(HostClubInsightsPane), findsOneWidget);
    expect(find.byType(HostAnalyticsTrendPanel), findsOneWidget);
    expect(find.text('SAKET · INDORE'), findsNothing);
    expect(find.byTooltip('Back to Organizer'), findsNothing);
    final rangeOptions = find.byType(
      CatchOptionGroup<HostClubInsightsRangePreset>,
    );
    expect(
      tester
          .widget<CatchOptionGroup<HostClubInsightsRangePreset>>(rangeOptions)
          .selected,
      HostClubInsightsRangePreset.thirtyDays,
    );
    await tester.tap(find.text('90 days'));
    await pumpFeatureUi(tester);
    expect(
      tester
          .widget<CatchOptionGroup<HostClubInsightsRangePreset>>(rangeOptions)
          .selected,
      HostClubInsightsRangePreset.ninetyDays,
    );

    await tester.tap(tab('Preview'));
    await pumpFeatureUi(tester);

    expectSharedChrome(switcherVisible: false);
    expect(
      find.byKey(const ValueKey('club-detail-hero-module')),
      findsOneWidget,
    );
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('Open public preview'), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.byTooltip('Share club'), findsNothing);
    expect(find.text('HOSTED'), findsNothing);
    expect(find.byType(SliverIgnorePointer), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('SCHEDULE'),
      320,
      scrollable: find
          .descendant(
            of: find.byKey(
              const PageStorageKey<String>(
                'host-club-owned-club-preview-scroll',
              ),
            ),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await pumpFeatureUi(tester);
    expect(find.text('SCHEDULE'), findsOneWidget);
    final eventCard = tester.widget<EventDateRailCard>(
      find.byType(EventDateRailCard),
    );
    expect(eventCard.statusLabel, isNull);
    expect(eventCard.onTap, isNull);

    await tester.tap(tab('Insights'));
    await pumpFeatureUi(tester);
    expect(
      tester
          .widget<CatchOptionGroup<HostClubInsightsRangePreset>>(rangeOptions)
          .selected,
      HostClubInsightsRangePreset.ninetyDays,
    );

    await tester.tap(tab('Edit'));
    await pumpFeatureUi(tester);

    expectSharedChrome(switcherVisible: false);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );
  });

  testWidgets('Host club workspace uses native horizontal tab paging', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ownedClub = buildClub(
      id: 'paged-club',
      name: 'Paged Club',
      ownerUserId: _hostUid,
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub]),
        watchEventsForClubProvider(
          ownedClub.id,
        ).overrideWithValue(const AsyncData<List<Event>>([])),
        clubDetailViewModelProvider(ownedClub.id).overrideWithValue(
          AsyncData<ClubDetailViewModel?>(_previewViewModel(ownedClub)),
        ),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
        hostAnalyticsRepositoryProvider.overrideWithValue(
          const _EmptyHostAnalyticsRepository(),
        ),
      ],
    );

    final pager = find.byType(TabBarView);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );
    expect(find.byType(HostClubEditTab), findsOneWidget);
    expect(find.byType(HostClubInsightsPane), findsNothing);

    await tester.drag(pager, const Offset(-320, 0));
    await pumpFeatureUi(tester);
    expect(find.byType(HostClubInsightsPane), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsOneWidget,
    );
    expect(find.byType(HostClubEditTab), findsNothing);

    await tester.drag(pager, const Offset(-320, 0));
    await pumpFeatureUi(tester);
    expect(
      find.byKey(const ValueKey('club-detail-hero-module')),
      findsOneWidget,
    );
    expect(find.text('Open public preview'), findsNothing);

    await tester.drag(pager, const Offset(320, 0));
    await pumpFeatureUi(tester);
    expect(find.byType(HostClubInsightsPane), findsOneWidget);

    await tester.drag(pager, const Offset(320, 0));
    await pumpFeatureUi(tester);
    expect(find.byType(HostClubEditTab), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );
  });

  testWidgets(
    'Host edit content is centered, capped, and reveals stable keys',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ownedClub = buildClub(
        id: 'wide-club',
        name: 'Wide Club',
        ownerUserId: _hostUid,
      );

      await _pumpHostScreen(
        tester,
        const HostClubsScreen(
          initialExpandedEditField: HostClubEditFieldKeys.description,
        ),
        overrides: [
          ..._hostClubOverrides(owned: [ownedClub]),
          watchHostPaymentAccountProvider(
            _hostUid,
          ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
        ],
      );

      final editTab = find.byType(HostClubEditTab);
      expect(editTab, findsOneWidget);
      expect(
        tester.getSize(editTab).width,
        closeTo(CatchLayout.maxContentWidth, 0.1),
      );
      expect(tester.getCenter(editTab).dx, closeTo(450, 0.1));
      expect(find.text('0 of 6 added'), findsOneWidget);

      final descriptionEditor = find.byKey(
        const ValueKey('catch-form-text-description'),
      );
      expect(descriptionEditor, findsOneWidget);
      final descriptionField = tester.widget<CatchField>(
        find.descendant(
          of: descriptionEditor,
          matching: find.byType(CatchField),
        ),
      );
      expect(descriptionField.open, isTrue);
    },
  );

  testWidgets('Host club photo picks commit immediately', (tester) async {
    final photoBytes = _testPngBytes();
    final actions = _RecordingHostClubEditActions(
      pickedPhotos: [
        HostPickedClubPhoto(
          image: XFile.fromData(photoBytes, name: 'picked.jpg'),
          bytes: photoBytes,
        ),
      ],
    );
    final club = buildClub(id: 'media-pick', ownerUserId: _hostUid);

    await _pumpHostClubEditTab(tester, club: club, actions: actions);
    final add = find.byKey(OrderedPhotoPickerKeys.addAction('Add photos'));
    await Scrollable.ensureVisible(tester.element(add));
    await tester.tap(add);
    await pumpFeatureUi(tester);

    expect(actions.mediaWrites, hasLength(1));
    expect(actions.mediaWrites.single, hasLength(1));
    expect(actions.mediaWrites.single.single, isA<HostNewClubPhotoInput>());
  });

  testWidgets('Club settings rows push every spoke with the selected club id', (
    tester,
  ) async {
    final club = buildClub(id: 'spoke-club', ownerUserId: _hostUid);
    final destinations = <(Routes, String)>[];
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: HostClubEditTab(
            club: club,
            currentUid: _hostUid,
            isOwner: true,
            onOpenSettingsRoute: (route, clubId) =>
                destinations.add((route, clubId)),
          ),
        ),
      ),
      overrides: _hostClubOverrides(owned: [club]),
    );

    for (final entry in {
      'host-club-settings-event-defaults': Routes.hostClubEventDefaultsScreen,
      'host-club-settings-live-guide': Routes.hostClubLiveGuideScreen,
      'host-club-settings-payments': Routes.hostClubPaymentsScreen,
      'host-club-settings-host-team': Routes.hostClubTeamScreen,
    }.entries) {
      final field = find.byKey(ValueKey(entry.key));
      await Scrollable.ensureVisible(tester.element(field));
      tester.widget<CatchField>(field).onTap!();
    }

    expect(destinations, [
      (Routes.hostClubEventDefaultsScreen, club.id),
      (Routes.hostClubLiveGuideScreen, club.id),
      (Routes.hostClubPaymentsScreen, club.id),
      (Routes.hostClubTeamScreen, club.id),
    ]);
  });

  testWidgets('Club settings spokes are read-only for co-hosts', (
    tester,
  ) async {
    final club = buildClub(
      id: 'cohost-spoke-club',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );
    final overrides = _hostClubOverrides(hosted: [club]);

    await _pumpHostScreen(
      tester,
      HostClubEventDefaultsScreen(clubId: club.id),
      overrides: overrides,
    );
    final topBar = tester.widget<CatchScreenTopBar>(
      find.byType(CatchScreenTopBar),
    );
    expect(topBar.title, 'Event defaults');
    expect(topBar.eyebrow, club.name);
    expect(topBar.leadingType, CatchTopBarLeading.back);
    expect(topBar.border, isTrue);
    expect(find.byType(CatchFieldToggle), findsNothing);
    expect(find.byType(CatchFieldActionBar), findsNothing);
    expect(find.text('Default activity'), findsOneWidget);

    await _pumpHostScreen(
      tester,
      HostClubLiveGuideScreen(clubId: club.id),
      overrides: overrides,
    );
    expect(find.byType(CatchFieldToggle), findsNothing);
    expect(find.byType(CatchFieldActionBar), findsNothing);

    await _pumpHostScreen(
      tester,
      HostClubTeamScreen(clubId: club.id),
      overrides: overrides,
    );
    expect(find.text('Add host'), findsNothing);

    await _pumpHostScreen(
      tester,
      HostClubPaymentsScreen(clubId: club.id),
      overrides: overrides,
    );
    expect(find.text('Owner'), findsOneWidget);
    expect(find.byType(HostPaymentAccountControllerCard), findsNothing);
  });

  testWidgets('Host club photo removal commits immediately', (tester) async {
    final actions = _RecordingHostClubEditActions();
    final club = buildClub(
      id: 'media-remove',
      ownerUserId: _hostUid,
      clubPhotos: [_uploadedClubPhoto('one', position: 0)],
    );

    await _pumpHostClubEditTab(tester, club: club, actions: actions);
    final remove = find.byKey(OrderedPhotoPickerKeys.removeAction(0));
    await Scrollable.ensureVisible(tester.element(remove));
    await tester.tap(remove);
    await pumpFeatureUi(tester);

    expect(actions.mediaWrites, hasLength(1));
    expect(actions.mediaWrites.single, isEmpty);
  });

  testWidgets('Host club photo reorder debounces one immediate commit', (
    tester,
  ) async {
    final actions = _RecordingHostClubEditActions();
    final club = buildClub(
      id: 'media-reorder',
      ownerUserId: _hostUid,
      clubPhotos: [
        _uploadedClubPhoto('one', position: 0),
        _uploadedClubPhoto('two', position: 1),
      ],
    );

    await _pumpHostClubEditTab(tester, club: club, actions: actions);
    tester
        .widget<CreateClubPhotosPicker>(find.byType(CreateClubPhotosPicker))
        .onReorderPhoto!(0, 1);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 399));
    expect(actions.mediaWrites, isEmpty);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1));
    await pumpFeatureUi(tester);

    expect(actions.mediaWrites, hasLength(1));
    final reordered = actions.mediaWrites.single
        .whereType<HostExistingClubPhotoInput>()
        .map((input) => input.photo.id)
        .toList();
    expect(reordered, ['two', 'one']);
  });

  testWidgets('Host club tabs preserve independent vertical scroll offsets', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ownedClub = buildClub(
      id: 'offset-club',
      name: 'Offset Club',
      ownerUserId: _hostUid,
      hostProfiles: const [
        ClubHostProfile(
          uid: _hostUid,
          displayName: 'Owner Host',
          role: ClubHostRole.owner,
        ),
        ClubHostProfile(uid: 'cohost-1', displayName: 'Co Host One'),
        ClubHostProfile(uid: 'cohost-2', displayName: 'Co Host Two'),
        ClubHostProfile(uid: 'cohost-3', displayName: 'Co Host Three'),
      ],
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub]),
        watchEventsForClubProvider(
          ownedClub.id,
        ).overrideWithValue(const AsyncData<List<Event>>([])),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
        hostAnalyticsRepositoryProvider.overrideWithValue(
          _EmptyHostAnalyticsRepository(
            topEvents: List.generate(
              12,
              (index) => _hostAnalyticsEventRow(eventId: 'offset-$index'),
            ),
          ),
        ),
      ],
    );

    final rail = find.byKey(const ValueKey('host-club-tab-rail'));
    final editKey = const PageStorageKey<String>(
      'host-club-offset-club-edit-scroll',
    );
    final insightsKey = const PageStorageKey<String>(
      'host-club-offset-club-insights-scroll',
    );

    ScrollPosition positionFor(PageStorageKey<String> key) => tester
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byKey(key),
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position;

    await tester.drag(find.byKey(editKey), const Offset(0, -1200));
    await pumpFeatureUi(tester);
    final editOffset = positionFor(editKey).pixels;
    expect(editOffset, greaterThan(0));

    await tester.tap(
      find.descendant(of: rail, matching: find.text('Insights')),
    );
    await pumpFeatureUi(tester);
    expect(positionFor(insightsKey).pixels, 0);
    expect(find.byType(HostClubInsightsPane), findsOneWidget);

    final insightsPosition = positionFor(insightsKey);
    expect(insightsPosition.maxScrollExtent, greaterThan(0));
    insightsPosition.jumpTo(insightsPosition.maxScrollExtent / 2);
    await pumpFeatureUi(tester);
    final insightsOffset = insightsPosition.pixels;
    expect(insightsOffset, greaterThan(0));

    await tester.tap(find.descendant(of: rail, matching: find.text('Edit')));
    await pumpFeatureUi(tester);
    expect(positionFor(editKey).pixels, closeTo(editOffset, 1));

    await tester.tap(
      find.descendant(of: rail, matching: find.text('Insights')),
    );
    await pumpFeatureUi(tester);
    expect(positionFor(insightsKey).pixels, closeTo(insightsOffset, 1));
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
        home: Scaffold(
          body: HostAnalyticsTrendPanel(
            points: points,
            granularity: HostAnalyticsGranularity.week,
          ),
        ),
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

  testWidgets('Host clubs owns profile management without event CTAs', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      description: 'Dawn runs along the Bandra seafront, every Sunday.',
      location: 'in-dl-delhi-ncr',
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
        clubDetailViewModelProvider(ownedClub.id).overrideWithValue(
          AsyncData<ClubDetailViewModel?>(_previewViewModel(ownedClub)),
        ),
        clubDetailViewModelProvider(cohostClub.id).overrideWithValue(
          AsyncData<ClubDetailViewModel?>(_previewViewModel(cohostClub)),
        ),
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
    expect(find.text('Delhi NCR'), findsOneWidget);
    expect(find.textContaining('IN-DL-DELHI-NCR'), findsNothing);
    expect(find.text('Area / neighbourhood'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('CONTACT'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('@sundayseafacecrew'), findsOneWidget);
    expect(find.text('CLUB SETTINGS'), findsOneWidget);
    expect(find.text('Event defaults'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Host team'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is CatchSection && widget.title == 'Media',
      ),
      findsOneWidget,
    );
    expect(find.text('Save media'), findsNothing);
    expect(find.byKey(const ValueKey('host-media-action-bar')), findsNothing);
    expect(find.text('Live event guide'), findsOneWidget);
    expect(find.text('Save defaults'), findsNothing);
    expect(
      find.byKey(const ValueKey('host-defaults-action-bar')),
      findsNothing,
    );
    expect(find.text('PUBLIC PROFILE'), findsNothing);
    expect(find.text('Preview club page'), findsNothing);
    expect(
      find.byKey(const ValueKey('host-club-settings-payments')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('host-club-settings-host-team')),
      findsOneWidget,
    );
    expect(find.text('Add host'), findsNothing);
    expect(find.text('Add event'), findsNothing);
    expect(find.text('View club'), findsNothing);
    expect(find.text('Owned club'), findsNothing);

    await tester.tap(find.byTooltip('Switch club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Co-hosted Club · Host team'));
    await pumpFeatureUi(tester);

    expect(find.text('Co-hosted Club'), findsWidgets);
    expect(find.text('CLUB SETTINGS'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is CatchSection && widget.title == 'Club settings',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('host-club-settings-payments')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('host-club-settings-host-team')),
      findsOneWidget,
    );
    expect(find.text('Add host'), findsNothing);
    expect(
      find.byKey(const ValueKey('host-team-actions-owner-2')),
      findsNothing,
    );
    expect(find.text('IDENTITY'), findsOneWidget);
    expect(find.text('Club name'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is CatchSection && widget.title == 'Media',
      ),
      findsOneWidget,
    );
    expect(find.text('Save media'), findsNothing);
    expect(find.text('Advanced event defaults'), findsNothing);
    expect(find.text('Save defaults'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('host-club-tab-rail')),
        matching: find.text('Preview'),
      ),
    );
    await pumpFeatureUi(tester);

    expect(
      find.byKey(const ValueKey('club-detail-hero-module')),
      findsOneWidget,
    );
    expect(find.text('Co-hosted Club'), findsWidgets);
    expect(find.text('Sunday sea-face crew'), findsNothing);
    expect(find.text('Open public preview'), findsNothing);
    expect(find.text('Club cohost-club'), findsNothing);
  });

  testWidgets('Default switches auto-save without a Done action', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      location: 'Mumbai',
      ownerUserId: _hostUid,
    );
    final repository = FakeClubsRepository();

    await _pumpHostScreen(
      tester,
      HostClubLiveGuideScreen(clubId: ownedClub.id),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub]),
        clubsRepositoryProvider.overrideWith((ref) => repository),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
      ],
    );

    final guideField = find.byWidgetPredicate(
      (widget) => widget is CatchField && widget.title == 'Live event guide',
    );
    expect(guideField, findsOneWidget);
    tester
        .widget<CatchFieldToggle>(
          find.descendant(
            of: guideField,
            matching: find.byType(CatchFieldToggle),
          ),
        )
        .onChanged!(true);
    await pumpFeatureUi(tester);

    expect(find.text('Done'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
    expect(repository.lastUpdatedClubId, ownedClub.id);
    final savedDefaults = repository.lastUpdatedFields?['hostDefaults'];
    expect(savedDefaults, isA<Map<String, dynamic>>());
    expect(
      ((savedDefaults as Map<String, dynamic>)['eventSuccess']
          as Map<String, dynamic>)['enabled'],
      isTrue,
    );
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

    await Scrollable.ensureVisible(
      tester.element(find.text('Description')),
      alignment: 0.5,
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Description'));
    await pumpFeatureUi(tester);

    expect(find.text('Edit owned-club'), findsNothing);

    final descriptionEditor = find.byKey(
      const ValueKey('catch-form-text-description'),
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
    expect(editorScrollView, findsWidgets);
    await tester.drag(editorScrollView.first, const Offset(0, -96));
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
    'Organizer Edit exposes demand-pricing defaults when configured',
    (tester) async {
      final ownedClub = buildClub(
        id: 'demand-pricing-club',
        ownerUserId: _hostUid,
        hostDefaults: const ClubHostDefaults(
          eventPolicy: EventPolicyDefaults(
            admissionPreset: EventAdmissionDefaultPreset.balancedSingles,
            dynamicPricingEnabled: true,
            dynamicPricingStepInPaise: 25000,
            dynamicPricingMaxInPaise: 150000,
          ),
        ),
      );

      await _pumpHostScreen(
        tester,
        HostClubEventDefaultsScreen(clubId: ownedClub.id),
        overrides: [
          ..._hostClubOverrides(owned: [ownedClub]),
          watchHostPaymentAccountProvider(
            _hostUid,
          ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
        ],
      );

      expect(find.text('Demand pricing'), findsOneWidget);
      expect(find.text('Step'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
    },
  );

  testWidgets('Host city editor displays labels and persists canonical ids', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'canonical-city-club',
      name: 'Saket Run Club',
      location: 'in-dl-delhi-ncr',
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

    expect(find.text('Delhi NCR'), findsOneWidget);
    expect(find.textContaining('IN-DL-DELHI-NCR'), findsNothing);

    await Scrollable.ensureVisible(
      tester.element(find.text('City')),
      alignment: 0.5,
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.text('City'));
    await pumpFeatureUi(tester);
    final citySheetScroll = findLastByType<Scrollable>();
    await tester.scrollUntilVisible(
      find.text('Mumbai'),
      180,
      scrollable: citySheetScroll,
    );
    await tester.tap(find.text('Mumbai'));
    await tester.scrollUntilVisible(
      find.text('Done'),
      -180,
      scrollable: citySheetScroll,
    );
    await tester.tap(find.text('Done'));
    await pumpFeatureUi(tester);

    expect(repository.lastUpdatedClubId, ownedClub.id);
    expect(
      repository.lastUpdatedFields,
      containsPair('location', 'in-mh-mumbai'),
    );
  });

  testWidgets(
    'Host team workspace edit loads from club snapshot while profile waits',
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
        const HostClubTeamScreen(clubId: 'owned-club'),
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
      expect(find.text('Suvrat'), findsWidgets);
      expect(find.text('Create host profile'), findsNothing);

      final displayNameField = find.widgetWithText(CatchField, 'Display name');
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

  testWidgets('Host team workspace creates a missing professional profile', (
    tester,
  ) async {
    final repository = _FakeHostProfileRepository();

    await _pumpHostScreen(
      tester,
      const HostClubTeamScreen(clubId: 'owned-club'),
      overrides: [
        ..._hostClubOverrides(owned: [_hostTeamClubWithoutProfile()]),
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

  testWidgets('Host team workspace no-profile row shows create pending state', (
    tester,
  ) async {
    final displayNameController = TextEditingController();
    final roleTitleController = TextEditingController();
    final bioController = TextEditingController();
    addTearDown(displayNameController.dispose);
    addTearDown(roleTitleController.dispose);
    addTearDown(bioController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: [
              HostTeamProfileSection(
                state: const HostTeamProfileMissing(),
                editMode: true,
                creatingProfile: true,
                onRetry: () {},
                onCreateProfile: () {},
                formKey: GlobalKey<FormState>(),
                displayNameController: displayNameController,
                roleTitleController: roleTitleController,
                bioController: bioController,
                savingProfile: false,
                onSaveProfile: null,
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

  testWidgets(
    'Host team workspace surfaces missing profile creation failures',
    (tester) async {
      final repository = _FakeHostProfileRepository(throwOnEnsure: true);

      await _pumpHostScreen(
        tester,
        const HostClubTeamScreen(clubId: 'owned-club'),
        overrides: [
          ..._hostClubOverrides(owned: [_hostTeamClubWithoutProfile()]),
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
    },
  );

  testWidgets('Host team workspace edits active professional profile inline', (
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
      const HostClubTeamScreen(clubId: 'owned-club'),
      overrides: [
        ..._hostClubOverrides(owned: [_hostTeamClub()]),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(AsyncData<HostProfile?>(profile)),
        hostProfileRepositoryProvider.overrideWith((ref) => repository),
      ],
    );

    expect(find.text('Active professional profile'), findsOneWidget);
    expect(find.byType(CatchBottomSheetScaffold), findsNothing);
    expect(find.text('BIO'), findsNothing);

    final displayNameField = find.widgetWithText(CatchField, 'Display name');
    await tester.enterText(
      find.descendant(of: displayNameField, matching: find.byType(TextField)),
      'Updated Host',
    );
    await tester.tap(find.text('Save profile'));
    await pumpFeatureUi(tester);

    expect(find.byType(CatchBottomSheetScaffold), findsNothing);
    expect(repository.savedDisplayName, 'Updated Host');
    expect(repository.savedRoleTitle, 'Founder');
    expect(repository.savedBio, 'Runs easy miles.');
    expect(find.text('Host profile saved.'), findsOneWidget);
  });

  testWidgets(
    'Host team workspace keeps inline profile fields after save failure',
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
      final repository = _FakeHostProfileRepository(
        profile: profile,
        throwOnSave: true,
      );

      await _pumpHostScreen(
        tester,
        const HostClubTeamScreen(clubId: 'owned-club'),
        overrides: [
          ..._hostClubOverrides(owned: [_hostTeamClub()]),
          watchHostProfileProvider(
            _hostUid,
          ).overrideWithValue(AsyncData<HostProfile?>(profile)),
          hostProfileRepositoryProvider.overrideWith((ref) => repository),
        ],
      );

      await tester.tap(find.text('Save profile'));
      await pumpFeatureUi(tester);

      expect(find.byType(CatchBottomSheetScaffold), findsNothing);
      expect(find.widgetWithText(CatchField, 'Display name'), findsOneWidget);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsWidgets,
      );
      expect(repository.savedUid, isNull);
    },
  );

  testWidgets(
    'Host team workspace exposes a back action with a safe root fallback',
    (tester) async {
      await _pumpHostScreen(
        tester,
        const HostClubTeamScreen(clubId: 'owned-club'),
        overrides: _hostClubOverrides(owned: [_hostTeamClub()]),
      );

      await tester.tap(find.byIcon(CatchIcons.arrowBackIosNewRounded));
      await pumpFeatureUi(tester);

      expect(find.text('Organizer route'), findsOneWidget);
    },
  );

  testWidgets('Host team workspace club rows use section-owned divider roles', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Owner Club',
      ownerUserId: _hostUid,
    );
    final hostedClub = buildClub(
      id: 'hosted-club',
      name: 'Hosted Club',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );

    await _pumpHostScreen(
      tester,
      const HostClubTeamScreen(clubId: 'owned-club'),
      overrides: _hostClubOverrides(owned: [ownedClub], hosted: [hostedClub]),
    );

    final clubsSection = find.ancestor(
      of: find.text('CLUBS YOU HOST'),
      matching: find.byType(CatchSection),
    );
    final clubFields = find.descendant(
      of: clubsSection,
      matching: find.byType(CatchField),
    );
    expect(
      tester
          .widgetList<CatchField>(clubFields)
          .every((field) => !field.divider),
      isTrue,
    );
    expect(
      tester
          .widgetList<CatchDivider>(
            find.descendant(
              of: clubsSection,
              matching: find.byType(CatchDivider),
            ),
          )
          .map((divider) => divider.role),
      contains(CatchDividerRole.fieldRow),
    );
  });

  testWidgets('Host team workspace surfaces sign out failures', (tester) async {
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
      const HostClubTeamScreen(clubId: 'owned-club'),
      overrides: [
        ..._hostClubOverrides(owned: [_hostTeamClub()]),
        watchHostProfileProvider(
          _hostUid,
        ).overrideWithValue(AsyncData<HostProfile?>(profile)),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );

    final signOutRow = find.byKey(const ValueKey('host-team-sign-out'));
    await tester.ensureVisible(signOutRow);
    await pumpFeatureUi(tester);
    await tester.tap(signOutRow);
    await pumpFeatureUi(tester);

    expect(authRepository.signOutCallCount, 1);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(HostClubTeamScreen), findsOneWidget);
  });

  testWidgets(
    'Host team workspace keeps management and sign out on Edit only',
    (tester) async {
      await _pumpHostScreen(
        tester,
        const HostClubTeamScreen(clubId: 'owned-club'),
        overrides: _hostClubOverrides(owned: [_hostTeamClub()]),
      );

      expect(find.text('Add host'), findsOneWidget);
      expect(find.byKey(const ValueKey('host-team-sign-out')), findsOneWidget);
      expect(find.text('CLUBS YOU HOST'), findsOneWidget);

      await tester.tap(find.text('Preview'));
      await pumpFeatureUi(tester);

      expect(find.text('Add host'), findsNothing);
      expect(find.byKey(const ValueKey('host-team-sign-out')), findsNothing);
      expect(find.text('CLUBS YOU HOST'), findsOneWidget);
      expect(find.text('Catch Host'), findsWidgets);
    },
  );

  testWidgets('Host team workspace validates required display name', (
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
      const HostClubTeamScreen(clubId: 'owned-club'),
      overrides: [
        ..._hostClubOverrides(owned: [_hostTeamClub()]),
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
}

Club _hostTeamClub() => buildClub(
  id: 'owned-club',
  name: 'Saket Run Club',
  ownerUserId: _hostUid,
  hostProfiles: const [
    ClubHostProfile(
      uid: _hostUid,
      displayName: 'Catch Host',
      role: ClubHostRole.owner,
    ),
  ],
);

Club _hostTeamClubWithoutProfile() => buildClub(
  id: 'owned-club',
  name: 'Saket Run Club',
  hostUserId: 'other-host',
  ownerUserId: 'other-host',
  hostProfiles: const [],
);

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

ClubDetailViewModel _previewViewModel(
  Club club, {
  List<Event> events = const [],
}) {
  return ClubDetailViewModel(
    club: club,
    isHost: true,
    isMember: true,
    upcomingEvents: events,
    reviews: const [],
    userProfile: buildUser(uid: _hostUid),
    uid: _hostUid,
    isAuthenticated: true,
  );
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
        path: Routes.hostClubTeamScreen.path,
        name: Routes.hostClubTeamScreen.name,
        builder: (_, state) => HostClubTeamScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
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
        path: Routes.hostClubEventDefaultsScreen.path,
        name: Routes.hostClubEventDefaultsScreen.name,
        builder: (_, state) => HostClubEventDefaultsScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostClubLiveGuideScreen.path,
        name: Routes.hostClubLiveGuideScreen.name,
        builder: (_, state) => HostClubLiveGuideScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostClubPaymentsScreen.path,
        name: Routes.hostClubPaymentsScreen.name,
        builder: (_, state) => HostClubPaymentsScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
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

Future<void> _pumpHostClubEditTab(
  WidgetTester tester, {
  required Club club,
  required HostClubEditActions actions,
}) {
  return _pumpHostScreen(
    tester,
    Scaffold(
      body: SingleChildScrollView(
        child: HostClubEditTab(club: club, currentUid: _hostUid, isOwner: true),
      ),
    ),
    overrides: [hostClubEditControllerProvider.overrideWithValue(actions)],
  );
}

UploadedPhoto _uploadedClubPhoto(String id, {required int position}) {
  final timestamp = DateTime(2026);
  return UploadedPhoto(
    id: id,
    url: 'https://example.test/$id.jpg',
    storagePath: 'clubs/test/$id.jpg',
    position: position,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

Uint8List _testPngBytes() => base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUl'
  'EQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
);

class _RecordingHostClubEditActions implements HostClubEditActions {
  _RecordingHostClubEditActions({this.pickedPhotos = const []});

  final List<HostPickedClubPhoto> pickedPhotos;
  final List<List<HostClubMediaInput>> mediaWrites = [];

  @override
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {}

  @override
  Future<List<HostPickedClubPhoto>> pickClubPhotos({
    required int limit,
  }) async => pickedPhotos.take(limit).toList(growable: false);

  @override
  Future<HostPickedClubLogo?> pickClubLogo() async => null;

  @override
  Future<void> updateClubMedia({
    required Club club,
    List<HostClubMediaInput>? photoInputs,
    HostPickedClubLogo? logo,
  }) async {
    if (photoInputs != null) {
      mediaWrites.add(List<HostClubMediaInput>.of(photoInputs));
    }
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
