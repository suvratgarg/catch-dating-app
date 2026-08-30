part of 'host_operations_screen_test.dart';

void _registerHostOperationsCustomersTests() {
  testWidgets('customer rows preserve hierarchy, tag, and disclosure', (
    tester,
  ) async {
    var tapped = false;
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerRow(
          contact: _customerDirectoryContact(),
          divider: true,
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
      find.descendant(of: row, matching: find.text('8 events attended')),
      findsOne,
    );
    expect(find.descendant(of: row, matching: find.text('Regulars')), findsOne);
    expect(
      find.descendant(of: row, matching: find.byType(CatchField)),
      findsNothing,
    );
    expect(
      find.descendant(
        of: row,
        matching: find.byIcon(CatchIcons.chevronRightRounded),
      ),
      findsOne,
    );

    final name = tester.widget<Text>(find.text('Ananya Rao'));
    final metadata = tester.widget<Text>(find.text('8 events attended'));
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
      CatchTabbedScreenScaffold(
        title: 'Customers',
        tabRail: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(height: 1),
        ),
        body: HostSavedAudiencesWorkspace(
          organizerId: organizerId,
          query: null,
          onCreate: () {},
          onOpen: (_) {},
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
      CatchTabbedScreenScaffold(
        title: 'Customers',
        tabRail: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(height: 1),
        ),
        body: HostSavedAudiencesWorkspace(
          organizerId: organizerId,
          query: null,
          onCreate: () {},
          onOpen: (_) {},
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
      CatchTabbedScreenScaffold(
        title: 'Customers',
        tabRail: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(height: 1),
        ),
        body: HostSavedAudiencesWorkspace(
          organizerId: organizerId,
          query: null,
          onCreate: () {},
          onOpen: (_) {},
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
          divider: false,
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

  testWidgets('customer directory uses flat divided rows', (tester) async {
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomersDirectory(
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
    );

    final frame = find.byKey(const ValueKey('host-customers-directory-list'));
    expect(
      find.descendant(
        of: frame,
        matching: find.byKey(CatchSectionFocusSurface.rowGroupClipKey),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: frame, matching: find.byType(CatchDivider)),
      findsOneWidget,
    );

    final row = find.byType(HostCustomerRow).first;
    final gesture = await tester.startGesture(tester.getCenter(row));
    await tester.pump();
    expect(
      tester
          .widget<ColoredBox>(
            find.descendant(
              of: row,
              matching: find.byKey(CatchRowPressSurface.overlayKey),
            ),
          )
          .color,
      isNot(Colors.transparent),
    );
    await gesture.up();
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

  testWidgets('incomplete CRM totals render as lower bounds', (tester) async {
    HostCustomerFilter? selectedFilter;
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomersSummary(
          summary: const AsyncData(
            HostCrmSummary(
              organizerId: 'organizer-1',
              contactCount: 4,
              pastAttendeeCount: 3,
              repeatAttendeeCount: 2,
              linkedAccountCount: 1,
              importedContactCount: 0,
              whatsappOptInCount: 0,
              smsOptInCount: 0,
              truncated: true,
              inAppReadiness: HostCrmChannelReadiness.currentEventOnly,
              whatsappReadiness: HostCrmChannelReadiness.providerSetupRequired,
              smsReadiness: HostCrmChannelReadiness.providerAndDltSetupRequired,
            ),
          ),
          onRetry: () {},
          selectedFilter: HostCustomerFilter.all,
          onFilterSelected: (filter) => selectedFilter = filter,
        ),
      ),
    );

    expect(find.text('4+'), findsOneWidget);
    expect(find.text('3+'), findsOneWidget);
    expect(find.text('2+'), findsOneWidget);

    final summary = find.byType(HostCustomersSummary);
    final statColumns = tester
        .widgetList<CatchStatColumn>(
          find.descendant(of: summary, matching: find.byType(CatchStatColumn)),
        )
        .toList();
    expect(statColumns, hasLength(3));
    expect(statColumns.every((column) => !column.surface), isTrue);
    expect(statColumns.every((column) => !column.center), isTrue);

    final statSurfaces = find.descendant(
      of: summary,
      matching: find.byType(CatchSurface),
    );
    expect(statSurfaces, findsNWidgets(3));
    final surfaces = tester.widgetList<CatchSurface>(statSurfaces).toList();
    expect(
      surfaces.every((surface) => surface.tone == CatchSurfaceTone.transparent),
      isTrue,
    );
    expect(
      surfaces.every((surface) => surface.radius == CatchRadius.md),
      isTrue,
    );
    expect(surfaces.every((surface) => surface.borderSpec != null), isTrue);
    expect(surfaces.every((surface) => surface.onTap != null), isTrue);

    final contactsTile = find.byKey(
      const ValueKey('host-customers-summary-all'),
    );
    final contactsSemantics = tester.getSemantics(contactsTile);
    expect(contactsSemantics.label, 'Contacts, 4+');
    expect(contactsSemantics.flagsCollection.isButton, isTrue);
    expect(contactsSemantics.flagsCollection.isSelected, ui.Tristate.isTrue);
    expect(
      contactsSemantics.getSemanticsData().hasAction(ui.SemanticsAction.tap),
      isTrue,
    );
    await tester.tap(
      find.byKey(const ValueKey('host-customers-summary-attended')),
    );
    expect(selectedFilter, HostCustomerFilter.attended);

    final surfaceRects = <Rect>[
      for (var index = 0; index < 3; index++)
        tester.getRect(statSurfaces.at(index)),
    ];
    expect(surfaceRects[0].width, closeTo(surfaceRects[1].width, 0.01));
    expect(surfaceRects[1].width, closeTo(surfaceRects[2].width, 0.01));
    expect(surfaceRects[1].left - surfaceRects[0].right, CatchSpacing.s2);
    expect(surfaceRects[2].left - surfaceRects[1].right, CatchSpacing.s2);
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
      const HostCustomersScreen(initialView: HostCustomersView.audiences),
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
      CatchTabbedScreenScaffold(
        title: 'Customers',
        tabRail: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(height: 1),
        ),
        body: HostSavedAudiencesWorkspace(
          organizerId: organizerId,
          query: null,
          onCreate: () {},
          onOpen: (_) {},
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

  testWidgets('customer detail failure names the customer, not organizer', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: HostCustomerDetailScreen(
          organizerId: 'organizer-1',
          contactId: 'contact-1',
          initialDisplayName: 'Ananya Rao',
        ),
      ),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        hostAudienceContactDetailProvider(
          'organizer-1',
          'contact-1',
        ).overrideWithValue(
          AsyncError<HostAudienceContactDetail>(
            StateError('detail failed'),
            StackTrace.current,
          ),
        ),
      ],
    );

    expect(find.text('Customer details unavailable'), findsOneWidget);
    expect(find.text('Reload customer'), findsOneWidget);
    expect(find.text('Organizer unavailable'), findsNothing);
    expect(
      tester.widget<CatchScreenTopBar>(find.byType(CatchScreenTopBar)).title,
      'Ananya Rao',
    );
    expect(find.byType(CatchScreenHeaderTitle), findsOneWidget);
  });

  testWidgets('customer overview groups status and directory controls', (
    tester,
  ) async {
    final club = buildClub(id: 'header-club', ownerUserId: _hostUid);
    final requests = <HostCustomersDirectoryRequest>[];
    await _pumpHostScreen(
      tester,
      const HostCustomersScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            requests,
            _emptyCustomerDirectoryState(),
          ),
        ),
      ],
    );

    final summary = find.byType(HostCustomersSummary);
    expect(
      find.descendant(of: summary, matching: find.byType(CatchStatColumn)),
      findsNWidgets(3),
    );
    expect(
      find.text(
        'Everyone who has attended, registered, been imported, or been added by your team.',
      ),
      findsOneWidget,
    );
    expect(find.text('0 WhatsApp-ready contacts'), findsOneWidget);
    expect(
      find.text('0 imported or added by your team · 0 linked Catch accounts'),
      findsOneWidget,
    );
    final activeView = find.byType(HostCustomerFilterSummary);
    expect(find.ancestor(of: activeView, matching: summary), findsOneWidget);
    expect(find.text('All · 0 people'), findsOneWidget);
    expect(find.text('Message these 0'), findsNothing);
    expect(
      find.byKey(const ValueKey('host-customers-messaging-action')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('host-customers-sender-setup-action')),
      findsNothing,
    );

    final controls = find.byType(HostCustomerDirectoryControls);
    expect(
      find.descendant(of: controls, matching: find.text('Filters')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: controls, matching: find.text('Sort: Last seen')),
      findsOneWidget,
    );
    expect(find.byTooltip('More customer actions'), findsOneWidget);
    expect(find.byTooltip('Export this audience'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('host-customers-summary-attended')),
    );
    await pumpFeatureUi(tester);
    expect(requests.last.filter, HostCustomerFilter.attended);
    expect(find.text('Attended · 0 people'), findsOneWidget);
    final attendedSemantics = tester.getSemantics(
      find.byKey(const ValueKey('host-customers-summary-attended')),
    );
    expect(attendedSemantics.label, 'Attended, 0');
    expect(attendedSemantics.flagsCollection.isButton, isTrue);
    expect(attendedSemantics.flagsCollection.isSelected, ui.Tristate.isTrue);
    expect(
      attendedSemantics.getSemanticsData().hasAction(ui.SemanticsAction.tap),
      isTrue,
    );

    await tester.tap(
      find.byKey(const ValueKey('host-customers-summary-attended')),
    );
    await pumpFeatureUi(tester);
    expect(requests.last.filter, HostCustomerFilter.all);
    expect(find.text('All · 0 people'), findsOneWidget);

    await tester.tap(find.text('Filters'));
    await pumpFeatureUi(tester);
    expect(find.byType(HostCustomerFilterSheet), findsOneWidget);
    Navigator.of(tester.element(find.byType(HostCustomerFilterSheet))).pop();
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Sort: Last seen'));
    await pumpFeatureUi(tester);
    final sortMenu = find.byType(CatchMenu<HostCustomerSort>);
    expect(sortMenu, findsOneWidget);
    await tester.tap(
      find.descendant(of: sortMenu, matching: find.text('Name')),
    );
    await pumpFeatureUi(tester);
    expect(find.text('Sort: Name'), findsOneWidget);
    expect(requests.last.sort, HostCustomerSort.name);

    await tester.tap(find.byTooltip('More customer actions'));
    await pumpFeatureUi(tester);
    expect(find.text('Export this audience'), findsOneWidget);
    expect(find.text('Review applications'), findsNothing);
    expect(find.text('Review possible duplicates'), findsOneWidget);
    expect(find.text('Last seen'), findsNothing);
    expect(find.text('Most attended'), findsNothing);
    expect(find.text('WhatsApp ready'), findsNothing);
  });

  testWidgets('customer sort opens a bottom sheet on phones', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final club = buildClub(id: 'phone-sort-club', ownerUserId: _hostUid);
    final requests = <HostCustomersDirectoryRequest>[];
    await _pumpHostScreen(
      tester,
      const HostCustomersScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            requests,
            _emptyCustomerDirectoryState(),
          ),
        ),
      ],
    );

    final filtersRect = tester.getRect(
      find.byKey(const ValueKey('host-customers-filters')),
    );
    final sortRect = tester.getRect(
      find.byKey(const ValueKey('host-customers-sort')),
    );
    expect(
      filtersRect.center.dy,
      closeTo(sortRect.center.dy, 0.5),
      reason: 'Filters $filtersRect and Sort $sortRect must share one row.',
    );

    expect(find.text('Last seen'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('host-customers-sort')));
    await pumpFeatureUi(tester);
    expect(find.byType(CatchSelectionSheet<HostCustomerSort>), findsOneWidget);

    await tester.tap(find.text('Most attended'));
    await pumpFeatureUi(tester);
    expect(find.text('Most attended'), findsOneWidget);
    expect(requests.last.sort, HostCustomerSort.mostAttended);
  });

  testWidgets('sender recovery opens dedicated WhatsApp Business setup', (
    tester,
  ) async {
    final club = buildClub(id: 'messaging-club', ownerUserId: _hostUid);
    await _pumpHostScreen(
      tester,
      const HostCustomersScreen(),
      overrides: [
        ..._hostClubOverrides(
          owned: [club],
          messagingSetupByOrganizer: {
            club.id: _hostMessagingSetup(
              organizerId: club.id,
              connectionStatus: 'pending',
            ),
          },
        ),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            [],
            _customerDirectoryState(),
          ),
        ),
      ],
    );

    expect(find.text('All · 1 person'), findsOneWidget);
    expect(find.text('Open messaging'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('host-customers-filters')));
    await pumpFeatureUi(tester);
    final atRiskFilter = find.byKey(
      const ValueKey('host-customer-filter-atRisk'),
    );
    await tester.ensureVisible(atRiskFilter);
    await pumpFeatureUi(tester);
    await tester.tap(atRiskFilter);
    await pumpFeatureUi(tester);

    expect(find.text('Sender verification is incomplete'), findsOneWidget);
    expect(find.text('Set up WhatsApp Business'), findsOneWidget);
    await tester.tap(find.text('Set up WhatsApp Business'));
    await pumpFeatureUi(tester);

    expect(find.text('Messaging setup messaging-club'), findsOneWidget);
  });

  testWidgets('customer search shows clear only while input is non-empty', (
    tester,
  ) async {
    final club = buildClub(id: 'search-club', ownerUserId: _hostUid);
    await _pumpHostScreen(
      tester,
      const HostCustomersScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            [],
            _emptyCustomerDirectoryState(),
          ),
        ),
      ],
    );

    final search = find.byKey(const ValueKey('host-customers-search'));
    Finder trailingIcon(IconData icon) =>
        find.descendant(of: search, matching: find.byIcon(icon));

    expect(trailingIcon(CatchIcons.close), findsNothing);
    expect(trailingIcon(CatchIcons.clearCircle), findsNothing);

    await tester.tap(search);
    await pumpFeatureUi(tester);
    await tester.enterText(
      find.descendant(of: search, matching: find.byType(TextField)),
      'Ananya',
    );
    await tester.pump();

    expect(trailingIcon(CatchIcons.clearCircle), findsOneWidget);
    await tester.tap(trailingIcon(CatchIcons.clearCircle));
    await tester.pump();

    expect(trailingIcon(CatchIcons.clearCircle), findsNothing);
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: search, matching: find.byType(TextField)),
          )
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('compact customer header preserves its title at large text', (
    tester,
  ) async {
    final club = buildClub(id: 'compact-header-club', ownerUserId: _hostUid);
    await _pumpHostScreen(
      tester,
      const MediaQuery(
        data: MediaQueryData(
          size: Size(393, 852),
          textScaler: TextScaler.linear(1.6),
        ),
        child: HostCustomersScreen(),
      ),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            [],
            _emptyCustomerDirectoryState(),
          ),
        ),
      ],
    );

    final header = find.byType(CatchScreenHeaderTitle);
    final titleFinder = find.descendant(
      of: header,
      matching: find.text('Customers'),
    );
    final title = tester.widget<Text>(titleFinder);
    final intrinsicTitle = TextPainter(
      text: TextSpan(text: title.data, style: title.style),
      textDirection: TextDirection.ltr,
      textScaler: const TextScaler.linear(1.6),
    )..layout();

    expect(
      tester.getSize(titleFinder).width,
      greaterThanOrEqualTo(intrinsicTitle.width - 0.5),
    );
    expect(
      find.descendant(
        of: find.byType(CatchTopBar),
        matching: find.byType(CatchIconAction),
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Add customer'), findsOneWidget);
  });

  testWidgets('customer timeline opens the host event detail route', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => HostCustomerTimelineSection(
            customer: _customerDetail(),
            onOpenFormResponse: (_) {},
            onOpenEvent: (eventId) => context.pushNamed(
              Routes.hostAppEventDetailScreen.name,
              pathParameters: {'clubId': 'organizer-1', 'eventId': eventId},
            ),
            onOpenCatchThread: (_) {},
            onOpenWhatsappThread: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(HostCustomerTimelineSection),
        matching: find.byIcon(CatchIcons.chevronRightRounded),
      ),
      findsNWidgets(3),
    );

    await tester.tap(find.text('Sunday Run Club'));
    await pumpFeatureUi(tester);
    expect(find.text('Event organizer-1 event-1'), findsOneWidget);
  });

  testWidgets('customer memory keeps manual tags separate and notes editable', (
    tester,
  ) async {
    var tagEdits = 0;
    var noteAdds = 0;
    HostCustomerNote? editedNote;
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: HostCustomerMemorySection(
            customer: _customerDetail(),
            currentUid: _hostUid,
            onEditTags: () => tagEdits += 1,
            onAddNote: () => noteAdds += 1,
            onEditNote: (note) => editedNote = note,
          ),
        ),
      ),
    );

    expect(find.text('MEMORY'), findsOneWidget);
    expect(find.text('Brings friends'), findsOneWidget);
    final manualTagsField = tester.widget<CatchField>(
      find.byKey(const ValueKey('host-customer-edit-tags')),
    );
    expect(manualTagsField.body, 'Brings friends');
    expect(manualTagsField.onTap, isNotNull);
    expect(find.text('Introduced three friends.'), findsOneWidget);
    expect(find.textContaining('You ·'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('host-customer-edit-tags')));
    await tester.tap(find.byKey(const ValueKey('host-customer-add-note')));
    await tester.tap(find.byTooltip('Edit note'));
    expect(tagEdits, 1);
    expect(noteAdds, 1);
    expect(editedNote?.noteId, 'note-1');
  });

  testWidgets('customer detail skeleton reuses the loaded composition', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: HostCustomerDetailScreen(
          organizerId: 'organizer-1',
          contactId: 'contact-1',
          initialDisplayName: 'Ananya Rao',
        ),
      ),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        hostAudienceContactDetailProvider(
          'organizer-1',
          'contact-1',
        ).overrideWithValue(const AsyncLoading()),
      ],
    );

    expect(find.byType(CatchSkeletonized), findsOneWidget);
    expect(find.byType(CatchSkeletonRows), findsNothing);
    expect(find.byType(HostCustomerIdentityCard), findsOneWidget);
    expect(find.byType(HostCustomerMemorySection), findsOneWidget);
    expect(find.byType(HostCustomerAttendanceCard), findsOneWidget);
    expect(find.byType(HostCustomerReachSection), findsOneWidget);
    expect(find.byType(HostCustomerTimelineSection), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-customer-controls')),
      findsOneWidget,
    );
  });

  testWidgets('organizer messaging control exposes the requested state', (
    tester,
  ) async {
    bool? requestedValue;
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerReachSection(
          customer: _customerDetail(),
          communicationPlan: _individualCommunicationPlan(),
          communicationPlanLoading: false,
          communicationPlanFailed: false,
          messageLoading: false,
          onMessage: () {},
          onRetryCommunicationPlan: () {},
          onMessagingEnabledChanged: (value) => requestedValue = value,
        ),
      ),
    );

    expect(find.text('Pause personal WhatsApp handoffs'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('host-customer-organizer-messages')),
    );
    expect(requestedValue, isFalse);
  });
}
