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
    'HostTeamWorkspaceActionState maps profile and club navigation policy',
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
      );
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

    final ownerState = state.selectClubIndex(0);
    expect(ownerState.selectedClub, ownedClub);
    expect(ownerState.selectedClubIsOwner, isTrue);

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
}
