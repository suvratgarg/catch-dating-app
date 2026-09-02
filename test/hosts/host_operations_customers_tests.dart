part of 'host_operations_screen_test.dart';

void _registerHostOperationsCustomersTests() {
  testWidgets('Host Customers keeps Audience composition across route states', (
    tester,
  ) async {
    for (final view in [HostAudienceView.people, HostAudienceView.audiences]) {
      final screen = HostCustomersScreen(initialView: view);

      await _pumpHostScreen(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncLoading<String?>()),
          hostOperableClubsProvider(
            _hostUid,
          ).overrideWithValue(const AsyncLoading<List<Club>>()),
        ],
        settle: false,
        resetProviderScope: true,
      );
      _expectAudienceStateOwner(tester, selected: view);
      expect(find.byType(HostRouteLoadingBody), findsOneWidget);
      expect(find.byType(CatchSliverStateViewport), findsOneWidget);

      await _pumpHostScreen(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(
            AsyncError<String?>(StateError('uid failed'), StackTrace.current),
          ),
          hostOperableClubsProvider(
            _hostUid,
          ).overrideWithValue(const AsyncLoading<List<Club>>()),
        ],
        settle: false,
        resetProviderScope: true,
      );
      _expectAudienceStateOwner(tester, selected: view);
      expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);

      await _pumpHostScreen(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>(null)),
          hostOperableClubsProvider(
            _hostUid,
          ).overrideWithValue(const AsyncLoading<List<Club>>()),
        ],
        settle: false,
        resetProviderScope: true,
      );
      _expectAudienceStateOwner(tester, selected: view);
      expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);
      expect(find.text('Sign in required'), findsOneWidget);

      await _pumpHostScreen(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>(_hostUid)),
          hostOperableClubsProvider(
            _hostUid,
          ).overrideWithValue(const AsyncLoading<List<Club>>()),
        ],
        settle: false,
        resetProviderScope: true,
      );
      _expectAudienceStateOwner(tester, selected: view);
      expect(find.byType(HostRouteLoadingBody), findsOneWidget);
      expect(find.byType(CatchSliverStateViewport), findsOneWidget);

      await _pumpHostScreen(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>(_hostUid)),
          hostOperableClubsProvider(_hostUid).overrideWithValue(
            AsyncError<List<Club>>(
              StateError('clubs failed'),
              StackTrace.current,
            ),
          ),
        ],
        settle: false,
        resetProviderScope: true,
      );
      _expectAudienceStateOwner(tester, selected: view);
      expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);

      await _pumpHostScreen(
        tester,
        screen,
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>(_hostUid)),
          hostOperableClubsProvider(
            _hostUid,
          ).overrideWithValue(const AsyncData<List<Club>>([])),
        ],
        settle: false,
        resetProviderScope: true,
      );
      _expectAudienceStateOwner(tester, selected: view);
      expect(find.byType(HostCustomersNoOrganizer), findsOneWidget);
      expect(find.byType(CatchSliverEmptyState), findsOneWidget);
    }
  });

  testWidgets('customer rows preserve hierarchy, tag, and disclosure', (
    tester,
  ) async {
    var tapped = false;
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerRow(
          contact: _customerDirectoryContact(),
          onTap: () => tapped = true,
        ),
      ),
    );

    final row = find.byType(HostCustomerRow);
    expect(
      find.descendant(of: row, matching: find.text('Ananya Rao')),
      findsOne,
    );
    expect(
      find.descendant(
        of: row,
        matching: find.textContaining('8 events attended'),
      ),
      findsOne,
    );
    expect(
      find.descendant(of: row, matching: find.textContaining('Regulars')),
      findsOne,
    );
    expect(
      find.descendant(of: row, matching: find.byType(CatchField)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: row,
        matching: find.byIcon(CatchIcons.chevronRightRounded),
      ),
      findsOne,
    );

    final name = tester.widget<Text>(find.text('Ananya Rao'));
    final metadata = tester.widget<Text>(
      find.textContaining('8 events attended'),
    );
    final avatar = tester.widget<CatchPersonAvatar>(
      find.descendant(of: row, matching: find.byType(CatchPersonAvatar)),
    );
    expect(avatar.size, CatchSpacing.s10);
    expect(tester.getSize(row).height, greaterThanOrEqualTo(72));
    expect(
      name.style!.fontWeight!.value,
      greaterThan(metadata.style!.fontWeight!.value),
    );

    await tester.tap(row);
    expect(tapped, isTrue);
  });

  testWidgets('saved audiences render populated, empty, and error states', (
    tester,
  ) async {
    const organizerId = 'organizer-1';
    final audience = HostSavedAudience(
      organizerId: organizerId,
      audienceId: 'repeat-runners',
      name: 'Repeat runners',
      status: 'active',
      definition: const HostSavedAudienceDefinition(
        join: HostSavedAudienceJoin.all,
        predicates: [
          HostSavedAudienceComputedSegment(HostAudienceSegment.repeatAttendee),
        ],
      ),
      definitionHash: 'repeat-runners-hash',
      definitionVersion: 1,
      revision: 2,
      lastPreviewMatchCount: 24,
      lastPreviewReachSummary: const HostAudienceReachSummary(
        inCatch: 14,
        automatic: 0,
        byHand: 8,
        unavailable: 2,
      ),
      lastPreviewAt: DateTime(2026, 8, 29),
      createdAt: DateTime(2026, 8, 28),
      updatedAt: DateTime(2026, 8, 29),
    );

    await _pumpHostScreen(
      tester,
      CatchRootScreenScaffold.withPrimaryRail(
        header: const CatchRootScreenHeader.title(title: 'Customers'),
        primaryRail: const _CustomersTestPrimaryRail(),
        body: CatchRootScreenBody.single(
          page: CatchRootScreenPageSpec.scroll(
            page: HostSavedAudiencesWorkspace(
              organizerId: organizerId,
              query: null,
              onCreate: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
      overrides: [
        hostAllSavedAudiencesProvider(organizerId).overrideWithValue(
          AsyncData(
            HostSavedAudiencePage(audiences: [audience], nextCursor: null),
          ),
        ),
      ],
    );
    expect(find.text('Repeat runners'), findsOneWidget);
    expect(
      find.text('24 people\n14 IN CATCH · 8 BY HAND · 2 NO REACH'),
      findsOneWidget,
    );
    expect(find.text('New audience'), findsOneWidget);
    expect(find.text('Archive'), findsNothing);

    await _pumpHostScreen(
      tester,
      CatchRootScreenScaffold.withPrimaryRail(
        header: const CatchRootScreenHeader.title(title: 'Customers'),
        primaryRail: const _CustomersTestPrimaryRail(),
        body: CatchRootScreenBody.single(
          page: CatchRootScreenPageSpec.scroll(
            page: HostSavedAudiencesWorkspace(
              organizerId: organizerId,
              query: null,
              onCreate: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
      overrides: [
        hostAllSavedAudiencesProvider(organizerId).overrideWithValue(
          const AsyncData(
            HostSavedAudiencePage(audiences: [], nextCursor: null),
          ),
        ),
      ],
    );
    expect(find.text('No saved audiences yet'), findsOneWidget);

    await _pumpHostScreen(
      tester,
      CatchRootScreenScaffold.withPrimaryRail(
        header: const CatchRootScreenHeader.title(title: 'Customers'),
        primaryRail: const _CustomersTestPrimaryRail(),
        body: CatchRootScreenBody.single(
          page: CatchRootScreenPageSpec.scroll(
            page: HostSavedAudiencesWorkspace(
              organizerId: organizerId,
              query: null,
              onCreate: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
      overrides: [
        hostAllSavedAudiencesProvider(organizerId).overrideWithValue(
          AsyncError(StateError('unavailable'), StackTrace.empty),
        ),
      ],
    );
    expect(find.text('Customers unavailable'), findsOneWidget);
  });

  testWidgets('ambiguous customer keeps warning and disclosure affordances', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerRow(
          contact: _customerDirectoryContact(hasAmbiguousIdentity: true),
          onTap: () {},
        ),
      ),
    );

    final row = find.byType(HostCustomerRow);
    final warning = tester.widget<CatchBadge>(
      find.descendant(of: row, matching: find.byType(CatchBadge)),
    );
    expect(warning.label, 'Needs review');
    expect(warning.tone, CatchBadgeTone.warning);
    expect(
      find.descendant(
        of: row,
        matching: find.byIcon(CatchIcons.chevronRightRounded),
      ),
      findsOne,
    );
  });

  testWidgets('customer directory uses canonical field-row feedback', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: CatchPageBody(
          child: HostCustomersDirectory(
            state: HostCustomersDirectoryState(
              contacts: [
                _customerDirectoryContact(),
                _customerDirectoryContact(),
              ],
              nextCursor: null,
              matchCount: 2,
              matchCountCoverage: HostCustomerMatchCountCoverage.exact,
              sourceCoverage: HostCustomerDirectoryCoverage.exact,
              projectionVersion: 1,
            ),
            hasActiveQuery: false,
            onCustomerSelected: (_) {},
            onLoadMore: null,
            onRefreshCoverage: () {},
          ),
        ),
      ),
    );

    final frame = find.byKey(const ValueKey('host-customers-directory-list'));
    expect(
      find.descendant(of: frame, matching: find.byType(CatchRowPressSurface)),
      findsNothing,
    );
    expect(
      find.descendant(
        of: frame,
        matching: find.byKey(CatchSectionFocusSurface.rowGroupClipKey),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: frame, matching: find.byType(CatchDivider)),
      findsNWidgets(2),
    );

    final row = find.byType(HostCustomerRow).first;
    final pressOverlayFinder = find.descendant(
      of: row,
      matching: find.byKey(CatchField.pressOverlayKey),
    );
    final activeOverlayFinder = find.descendant(
      of: row,
      matching: find.byKey(const ValueKey('catch-field-active-overlay')),
    );
    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(row));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(row));
    await tester.pump();
    final hoveredPressDecoration =
        tester.widget<AnimatedContainer>(pressOverlayFinder).decoration!
            as BoxDecoration;
    final hoveredActiveDecoration =
        tester.widget<AnimatedContainer>(activeOverlayFinder).decoration!
            as BoxDecoration;
    expect(hoveredPressDecoration.color, Colors.transparent);
    expect(hoveredActiveDecoration.color, Colors.transparent);
    expect(hoveredActiveDecoration.boxShadow, CatchElevation.none);

    final gesture = await tester.startGesture(tester.getCenter(row));
    await tester.pump();
    final overlay = tester.widget<AnimatedContainer>(pressOverlayFinder);
    final decoration = overlay.decoration! as BoxDecoration;
    expect(decoration.color, isNot(Colors.transparent));
    expect(decoration.borderRadius, BorderRadius.zero);
    expect(decoration.border, isNull);
    expect(decoration.boxShadow, isNull);
    final pageWidth = tester.getSize(find.byType(Scaffold).first).width;
    final overlayRect = tester.getRect(pressOverlayFinder);
    expect(overlayRect.left, closeTo(0, 0.001));
    expect(overlayRect.right, closeTo(pageWidth, 0.001));
    await gesture.up();
    await tester.pump();
    await tester.pump(CatchFieldTokens.pressOut);
    final releasedDecoration =
        tester.widget<AnimatedContainer>(pressOverlayFinder).decoration!
            as BoxDecoration;
    expect(releasedDecoration.color, Colors.transparent);
  });

  testWidgets('incomplete customer history is honest and can be rechecked', (
    tester,
  ) async {
    var refreshes = 0;
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomersDirectory(
          state: HostCustomersDirectoryState(
            contacts: [_customerDirectoryContact()],
            nextCursor: null,
            matchCount: 1,
            matchCountCoverage: HostCustomerMatchCountCoverage.atLeast,
            sourceCoverage: HostCustomerDirectoryCoverage.partial,
            projectionVersion: 1,
          ),
          hasActiveQuery: false,
          onCustomerSelected: (_) {},
          onLoadMore: null,
          onRefreshCoverage: () => refreshes += 1,
        ),
      ),
    );

    expect(find.text('Some customer history is unavailable'), findsOneWidget);
    expect(find.textContaining('still syncing'), findsNothing);
    expect(find.textContaining('Counts marked + are minimums'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('host-customers-refresh-coverage')),
    );
    expect(refreshes, 1);
  });

  testWidgets('customer search debounces and unavailable SMS stays hidden', (
    tester,
  ) async {
    final club = buildClub(id: 'customers-club', ownerUserId: _hostUid);
    final requests = <HostCustomersDirectoryRequest>[];
    await _pumpHostScreen(
      tester,
      const HostCustomersScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            requests,
            _customerDirectoryState(),
          ),
        ),
      ],
    );

    final searchFinder = find.byKey(const ValueKey('host-customers-search'));
    final search = tester.widget<CatchSearchField>(searchFinder);
    expect(search.mode, CatchSearchFieldMode.expanding);
    expect(search.placeholder, 'Search by name');
    expect(find.text('SMS reachable'), findsNothing);
    expect(requests.last.search, isNull);
    final body = tester.widget<CatchSliverScreenBody>(
      find.ancestor(
        of: find.byType(HostCustomersDirectory),
        matching: find.byType(CatchSliverScreenBody),
      ),
    );
    expect(body.layout, CatchScreenBodyLayout.standard);

    await tester.tap(searchFinder);
    await pumpFeatureUi(tester);
    await tester.enterText(
      find.descendant(of: searchFinder, matching: find.byType(TextField)),
      '  ananya  ',
    );
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 299));
    expect(requests.last.search, isNull);

    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1));
    await pumpFeatureUi(tester);
    expect(requests.last.search, 'ananya');
  });

  testWidgets('Audiences has one local create action and skips People loads', (
    tester,
  ) async {
    final club = buildClub(id: 'customers-club', ownerUserId: _hostUid);
    final requests = <HostCustomersDirectoryRequest>[];
    final audience = HostSavedAudience(
      organizerId: club.id,
      audienceId: 'audience-1',
      name: 'Repeat runners',
      status: 'active',
      definition: const HostSavedAudienceDefinition(
        join: HostSavedAudienceJoin.all,
        predicates: [
          HostSavedAudienceComputedSegment(HostAudienceSegment.repeatAttendee),
        ],
      ),
      definitionHash:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      definitionVersion: 1,
      revision: 1,
      lastPreviewMatchCount: 9,
      lastPreviewAt: DateTime(2026, 8, 30),
      createdAt: DateTime(2026, 8, 29),
      updatedAt: DateTime(2026, 8, 30),
    );

    await _pumpHostScreen(
      tester,
      const HostCustomersScreen(initialView: HostAudienceView.audiences),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            requests,
            _customerDirectoryState(),
          ),
        ),
        hostAllSavedAudiencesProvider(club.id).overrideWithValue(
          AsyncData(
            HostSavedAudiencePage(audiences: [audience], nextCursor: null),
          ),
        ),
      ],
    );

    expect(find.text('People'), findsOneWidget);
    expect(find.text('Audiences'), findsOneWidget);
    expect(find.text('New audience'), findsOneWidget);
    expect(find.text('Repeat runners'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-customers-add-customer')),
      findsNothing,
    );
    expect(requests, isEmpty);
  });

  testWidgets(
    'expanded customer workspace keeps directory and detail together',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final club = buildClub(id: 'organizer-1', ownerUserId: _hostUid);

      await _pumpHostScreen(
        tester,
        const HostCustomersScreen(
          initialOrganizerId: 'organizer-1',
          initialContactId: 'contact-1',
          initialContactDisplayName: 'Ananya Rao',
        ),
        overrides: [
          ..._hostClubOverrides(owned: [club]),
          hostCustomersDirectoryControllerProvider.overrideWith2(
            (_) => _FixedHostCustomersDirectoryController(
              [],
              _customerDirectoryState(),
            ),
          ),
          hostAudienceContactDetailProvider(
            'organizer-1',
            'contact-1',
          ).overrideWithValue(AsyncData(_customerDetail())),
          hostCommunicationPlanProvider(
            'organizer-1',
            'contact-1',
          ).overrideWithValue(AsyncData(_individualCommunicationPlan())),
        ],
      );

      expect(
        find.byKey(const ValueKey('catch-master-detail-divider')),
        findsOneWidget,
      );
      expect(find.byType(HostCustomersDirectory), findsOneWidget);
      final detail = tester.widget<HostCustomerDetailScreen>(
        find.byType(HostCustomerDetailScreen),
      );
      expect(detail.embedded, isTrue);
      final detailTopBar = tester.widget<CatchScreenTopBar>(
        find.descendant(
          of: find.byType(HostCustomerDetailScreen),
          matching: find.byType(CatchScreenTopBar),
        ),
      );
      expect(detailTopBar.leadingType, CatchTopBarLeading.none);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('customer filter sheet scrolls without loading every count', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpHostScreen(
      tester,
      const Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: HostCustomerFilterSheet(
            selectedFilter: HostCustomerFilter.newToOrganizer,
            selectedManualTag: null,
            manualTagVocabulary: [],
            selectedCount: HostCustomerSegmentCount(
              count: 12,
              coverage: HostCustomerMatchCountCoverage.exact,
            ),
            smsReadiness: HostCrmChannelReadiness.currentEventOnly,
          ),
        ),
      ),
    );

    expect(find.text('New to your audience · 12 people'), findsOneWidget);
    expect(find.textContaining('Loading count'), findsNothing);
    expect(find.text('ADVOCACY').hitTestable(), findsNothing);

    final scrollable = find.descendant(
      of: find.byKey(const ValueKey('host-customer-filter-scroll')),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable).position;
    expect(position.maxScrollExtent, greaterThan(0));
    await tester.scrollUntilVisible(
      find.text('ADVOCACY'),
      200,
      scrollable: scrollable,
    );
    await pumpFeatureUi(tester);

    expect(position.pixels, greaterThan(0));
    expect(find.text('ADVOCACY').hitTestable(), findsOneWidget);
    expect(find.text('Advocates'), findsOneWidget);
    expect(find.text('REACHABLE'), findsOneWidget);
  });

  testWidgets('manual customer form captures useful identity and memory', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      const HostAddCustomerScreen(organizerId: 'organizer-1'),
    );

    expect(find.byType(CatchRouteScaffold), findsOneWidget);
    expect(find.byType(CatchBottomSheetScaffold), findsNothing);
    expect(
      find.byKey(const ValueKey('host-add-customer-details')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('host-add-customer-memory')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<CatchField>(
            find.byKey(const ValueKey('host-add-customer-name')),
          )
          .title,
      'Name shown to your team',
    );
    expect(
      tester
          .widget<CatchField>(
            find.byKey(const ValueKey('host-add-customer-phone')),
          )
          .title,
      'Mobile number',
    );
    expect(
      tester
          .widget<CatchField>(
            find.byKey(const ValueKey('host-add-customer-email')),
          )
          .title,
      'Email',
    );
    expect(
      tester
          .widget<CatchField>(
            find.byKey(const ValueKey('host-add-customer-note')),
          )
          .title,
      'Private note',
    );
    expect(
      find.textContaining('never grant messaging permission'),
      findsOneWidget,
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-add-customer-name')),
        matching: find.byType(TextField),
      ),
      'Name only',
    );
    await tester.tap(find.byKey(const ValueKey('host-add-customer-submit')));
    await pumpFeatureUi(tester);

    expect(
      find.text('Add or keep at least one mobile number or email address.'),
      findsOneWidget,
    );
  });

  testWidgets('saved audience directory exposes one create action', (
    tester,
  ) async {
    const organizerId = 'organizer-1';
    final audience = HostSavedAudience(
      organizerId: organizerId,
      audienceId: 'audience-1',
      name: 'Regular customers',
      status: 'active',
      definition: const HostSavedAudienceDefinition(
        join: HostSavedAudienceJoin.all,
        predicates: [
          HostSavedAudienceComputedSegment(HostAudienceSegment.regular),
        ],
      ),
      definitionHash:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      definitionVersion: 1,
      revision: 3,
      lastPreviewMatchCount: 9,
      lastPreviewAt: DateTime(2026, 8, 30),
      createdAt: DateTime(2026, 8, 29),
      updatedAt: DateTime(2026, 8, 30),
    );

    await _pumpHostScreen(
      tester,
      CatchRootScreenScaffold.withPrimaryRail(
        header: const CatchRootScreenHeader.title(title: 'Customers'),
        primaryRail: const _CustomersTestPrimaryRail(),
        body: CatchRootScreenBody.single(
          page: CatchRootScreenPageSpec.scroll(
            page: HostSavedAudiencesWorkspace(
              organizerId: organizerId,
              query: null,
              onCreate: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
      overrides: [
        hostAllSavedAudiencesProvider(organizerId).overrideWithValue(
          AsyncData(
            HostSavedAudiencePage(audiences: [audience], nextCursor: null),
          ),
        ),
      ],
    );

    expect(find.text('New audience'), findsOneWidget);
    expect(find.text('Regular customers'), findsOneWidget);
    expect(find.text('9 people'), findsOneWidget);
    expect(find.text('Archive'), findsNothing);
    expect(find.text('Refresh exact preview'), findsNothing);
  });

  testWidgets('saved audience create and edit use full-page routes', (
    tester,
  ) async {
    const organizerId = 'organizer-1';
    final audience = HostSavedAudience(
      organizerId: organizerId,
      audienceId: 'audience-1',
      name: 'Repeat runners',
      status: 'active',
      definition: const HostSavedAudienceDefinition(
        join: HostSavedAudienceJoin.all,
        predicates: [
          HostSavedAudienceComputedSegment(HostAudienceSegment.repeatAttendee),
        ],
      ),
      definitionHash:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      definitionVersion: 1,
      revision: 3,
      lastPreviewMatchCount: 9,
      lastPreviewReachSummary: const HostAudienceReachSummary(
        inCatch: 5,
        automatic: 0,
        byHand: 3,
        unavailable: 1,
      ),
      lastPreviewAt: DateTime(2026, 8, 30),
      createdAt: DateTime(2026, 8, 29),
      updatedAt: DateTime(2026, 8, 30),
    );

    await _pumpHostScreen(
      tester,
      const HostSavedAudienceEditorScreen(organizerId: organizerId),
      overrides: [
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            [],
            _customerDirectoryState(),
          ),
        ),
      ],
    );

    expect(find.text('New audience'), findsOneWidget);
    expect(find.text('AUDIENCE DETAILS'), findsOneWidget);
    expect(find.text('CONDITION 1'), findsOneWidget);
    expect(find.text('Create audience'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-saved-audience-create')),
      findsNothing,
    );

    await _pumpHostScreen(
      tester,
      HostSavedAudienceEditorScreen(
        organizerId: organizerId,
        initialAudience: audience,
      ),
      overrides: [
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            [],
            _customerDirectoryState(),
          ),
        ),
      ],
    );

    expect(find.text('Repeat runners'), findsWidgets);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('CURRENT PREVIEW'), findsOneWidget);
    expect(find.text('Refresh exact preview'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
  });
}

class _CustomersTestPrimaryRail extends StatelessWidget
    implements CatchPrimaryRail {
  const _CustomersTestPrimaryRail();

  @override
  Size get preferredSize => const Size.fromHeight(CatchLayout.tabRailHeight);

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: CatchLayout.tabRailHeight);
}
