part of 'host_operations_screen_test.dart';

void _registerHostOperationsStateEventsTests() {
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
    expect(find.text('Organizers'), findsOneWidget);
    expect(find.text('Sign in required'), findsNothing);
    expect(
      tester.widget<CatchSectionStack>(find.byType(CatchSectionStack)).padding,
      CatchInsets.pageBody,
    );
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
}
