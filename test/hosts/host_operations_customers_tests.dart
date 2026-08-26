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

  testWidgets('customer directory clips pressed rows to its rounded frame', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomersDirectory(
          state: _customerDirectoryState(),
          hasActiveQuery: false,
          onCustomerSelected: (_) {},
          onLoadMore: null,
          onRefreshCoverage: () {},
        ),
      ),
    );

    final frame = find.byKey(const ValueKey('host-customers-directory-list'));
    final groupClip = tester.widget<ClipRRect>(
      find.descendant(
        of: frame,
        matching: find.byKey(CatchSectionFocusSurface.rowGroupClipKey),
      ),
    );
    expect(groupClip.clipBehavior, Clip.hardEdge);
    expect(groupClip.borderRadius, isNot(BorderRadius.zero));

    final row = find.byType(HostCustomerRow);
    final gesture = await tester.startGesture(tester.getCenter(row));
    await tester.pump();
    expect(
      tester
          .widget<ColoredBox>(find.byKey(CatchRowPressSurface.overlayKey))
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
        ),
      ),
    );

    expect(find.text('4+'), findsOneWidget);
    expect(find.text('3+'), findsOneWidget);
    expect(find.text('2+'), findsOneWidget);
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
    expect(search.mode, CatchSearchFieldMode.expanded);
    expect(search.placeholder, 'Search by name');
    expect(find.text('SMS reachable'), findsNothing);
    expect(requests.last.search, isNull);

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
    await tester.drag(scrollable, const Offset(0, -420));
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
      const Scaffold(body: HostAddCustomerSheet(organizerId: 'organizer-1')),
    );

    expect(
      tester
          .widget<CatchBottomSheetScaffold>(
            find.byType(CatchBottomSheetScaffold),
          )
          .keyboardSafe,
      isTrue,
    );
    expect(
      tester
          .widget<CatchField>(
            find.byKey(const ValueKey('host-add-customer-name')),
          )
          .title,
      'Customer name',
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

  testWidgets('customer controls separate sorting, commands, and status', (
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
    expect(find.text('Sort: Last seen'), findsOneWidget);
    expect(find.byTooltip('More customer actions'), findsOneWidget);
    expect(find.byTooltip('Export this audience'), findsNothing);

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
    expect(find.text('Review applications'), findsOneWidget);
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

    await tester.tap(find.text('Sort: Last seen'));
    await pumpFeatureUi(tester);
    expect(find.byType(CatchSelectionSheet<HostCustomerSort>), findsOneWidget);

    await tester.tap(find.text('Most attended'));
    await pumpFeatureUi(tester);
    expect(find.text('Sort: Most attended'), findsOneWidget);
    expect(requests.last.sort, HostCustomerSort.mostAttended);
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
      find.descendant(of: header, matching: find.byType(CatchIconAction)),
      findsOneWidget,
    );
    expect(find.byTooltip('Add customer'), findsOneWidget);
  });

  testWidgets('customer event history opens the host event detail route', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerAttendanceHistory(customer: _customerDetail()),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(HostCustomerAttendanceHistory),
        matching: find.byIcon(CatchIcons.chevronRightRounded),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Externally hosted'), findsOneWidget);
    expect(find.textContaining('Imported by your team'), findsOneWidget);

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
    expect(find.byType(HostCustomerConversationCard), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-customer-controls')),
      findsOneWidget,
    );
  });

  testWidgets('customer identity edits and saves in place', (tester) async {
    String? savedDisplayName;
    String? savedPhone;
    String? savedEmail;
    final customer = _customerDetail(
      contactDetailsEditable: true,
      linkedAccount: false,
      identityState: HostAudienceIdentityState.unlinked,
      identityConfidence: 'unverified',
    );
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerIdentityCard(
          customer: customer,
          onSave: ({required displayName, phoneE164, email}) async {
            savedDisplayName = displayName;
            savedPhone = phoneE164;
            savedEmail = email;
          },
        ),
      ),
    );

    expect(find.text('Add mobile number'), findsOneWidget);
    expect(find.text('Add email'), findsOneWidget);
    expect(find.text('Added by your team · not verified by Catch'), findsOne);
    expect(
      find.descendant(
        of: find.byType(HostCustomerIdentityCard),
        matching: find.byIcon(CatchIcons.chevronRightRounded),
      ),
      findsNothing,
    );

    for (final key in const [
      ValueKey('host-customer-name-field'),
      ValueKey('host-customer-phone-field'),
      ValueKey('host-customer-email-field'),
    ]) {
      expect(tester.widget<CatchField>(find.byKey(key)).onTap, isNull);
    }

    await tester.tap(find.byKey(const ValueKey('host-customer-edit-details')));
    await tester.pump();

    expect(find.byKey(const ValueKey('host-customer-edit-name')), findsOne);
    expect(find.byKey(const ValueKey('host-customer-edit-phone')), findsOne);
    expect(find.byKey(const ValueKey('host-customer-edit-email')), findsOne);
    expect(
      find.byKey(const ValueKey('host-customer-edit-details')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('catch-field-action-bar')), findsOne);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-customer-edit-name')),
        matching: find.byType(TextField),
      ),
      'Ananya Kapoor',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-customer-edit-phone')),
        matching: find.byType(TextField),
      ),
      '+919999999999',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-customer-edit-email')),
        matching: find.byType(TextField),
      ),
      'NEW@Example.COM',
    );
    await tester.tap(find.byKey(const ValueKey('catch-field-done')));
    await pumpFeatureUi(tester);

    expect(savedDisplayName, 'Ananya Kapoor');
    expect(savedPhone, '+919999999999');
    expect(savedEmail, 'new@example.com');
    expect(find.text('Ananya Kapoor'), findsOneWidget);
    expect(find.text('+919999999999'), findsOneWidget);
    expect(find.text('new@example.com'), findsOneWidget);
    expect(find.byKey(const ValueKey('catch-field-action-bar')), findsNothing);
  });

  testWidgets('cancel restores customer details without saving', (
    tester,
  ) async {
    var saves = 0;
    final customer = _customerDetail(
      contactDetailsEditable: true,
      linkedAccount: false,
      identityState: HostAudienceIdentityState.unlinked,
      identityConfidence: 'unverified',
    );
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerIdentityCard(
          customer: customer,
          onSave: ({required displayName, phoneE164, email}) async {
            saves += 1;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('host-customer-edit-details')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('catch-field-done')));
    await tester.pump();

    expect(saves, 0);
    expect(find.byKey(const ValueKey('host-customer-edit-name')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('host-customer-edit-details')));
    await tester.pump();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-customer-edit-name')),
        matching: find.byType(TextField),
      ),
      'Discarded name',
    );
    await tester.tap(find.byKey(const ValueKey('catch-field-cancel')));
    await tester.pump();

    expect(saves, 0);
    expect(find.text('Ananya Rao'), findsOneWidget);
    expect(find.text('Discarded name'), findsNothing);
    expect(find.byKey(const ValueKey('host-customer-edit-name')), findsNothing);
  });

  testWidgets('verified customer edits name while endpoints stay read-only', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerIdentityCard(
          customer: _customerDetail(),
          onSave: ({required displayName, phoneE164, email}) async {},
        ),
      ),
    );

    expect(find.text('Not saved'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('host-customer-edit-details')));
    await tester.pump();

    expect(find.byKey(const ValueKey('host-customer-edit-name')), findsOne);
    expect(
      find.byKey(const ValueKey('host-customer-edit-phone')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('host-customer-edit-email')),
      findsNothing,
    );
    expect(
      tester
          .widget<CatchField>(
            find.byKey(const ValueKey('host-customer-phone-field')),
          )
          .onTap,
      isNull,
    );
    expect(
      tester
          .widget<CatchField>(
            find.byKey(const ValueKey('host-customer-email-field')),
          )
          .onTap,
      isNull,
    );
    expect(
      find.text(
        'Linked Catch profiles stay private. Phone and email can’t be edited here.',
      ),
      findsOne,
    );
  });

  testWidgets('inline customer details keep invalid drafts open', (
    tester,
  ) async {
    var saves = 0;
    final customer = _customerDetail(
      contactDetailsEditable: true,
      linkedAccount: false,
      identityState: HostAudienceIdentityState.unlinked,
      identityConfidence: 'unverified',
    );
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerIdentityCard(
          customer: customer,
          onSave: ({required displayName, phoneE164, email}) async {
            saves += 1;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('host-customer-edit-details')));
    await tester.pump();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-customer-edit-name')),
        matching: find.byType(TextField),
      ),
      '   ',
    );
    await tester.tap(find.byKey(const ValueKey('catch-field-done')));
    await tester.pump();

    expect(saves, 0);
    expect(find.text('Enter the customer’s name.'), findsOneWidget);
    expect(find.byKey(const ValueKey('host-customer-edit-name')), findsOne);
  });

  testWidgets('organizer messaging control exposes the requested state', (
    tester,
  ) async {
    bool? requestedValue;
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: HostCustomerConversationCard(
          customer: _customerDetail(),
          loading: false,
          onOpen: () {},
          onMessagingEnabledChanged: (value) => requestedValue = value,
        ),
      ),
    );

    expect(find.text('Organizer messages'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('host-customer-organizer-messages')),
    );
    expect(requestedValue, isFalse);
  });

  testWidgets('customer activity shows campaign delivery history', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      Scaffold(body: HostCustomerSendHistory(customer: _customerDetail())),
    );

    expect(find.text('MESSAGES SENT'), findsOneWidget);
    expect(find.text('August invite'), findsOneWidget);
    expect(find.textContaining('Delivered'), findsOneWidget);
  });

  testWidgets('customer detail orders identity, memory, activity, controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final detail = _customerDetail();
    await _pumpHostScreen(
      tester,
      const HostCustomerDetailScreen(
        organizerId: 'organizer-1',
        contactId: 'contact-1',
      ),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        hostAudienceContactDetailProvider(
          'organizer-1',
          'contact-1',
        ).overrideWithValue(AsyncData(detail)),
      ],
    );

    final identityY = tester
        .getTopLeft(find.byType(HostCustomerIdentityCard))
        .dy;
    final memoryY = tester
        .getTopLeft(find.byType(HostCustomerMemorySection))
        .dy;
    final activityY = tester
        .getTopLeft(find.byKey(const ValueKey('host-customer-activity')))
        .dy;
    final controlsY = tester
        .getTopLeft(find.byKey(const ValueKey('host-customer-controls')))
        .dy;

    expect(identityY, lessThan(memoryY));
    expect(memoryY, lessThan(activityY));
    expect(activityY, lessThan(controlsY));
  });

  testWidgets('customer detail explains an unavailable WhatsApp handoff', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpHostScreen(
      tester,
      const HostCustomerDetailScreen(
        organizerId: 'organizer-1',
        contactId: 'contact-1',
      ),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        hostAudienceContactDetailProvider(
          'organizer-1',
          'contact-1',
        ).overrideWithValue(AsyncData(_customerDetail())),
      ],
    );

    expect(find.text('WhatsApp app · You'), findsOneWidget);
    expect(
      find.text('Add a valid phone number to use a personal WhatsApp handoff.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('host-customer-open-whatsapp')),
      findsNothing,
    );
  });

  testWidgets('customer WhatsApp handoff pre-fills copy and opens the app', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Uri? launchedUri;
    final detail = _customerDetail(phoneE164: '+91 98765 43210');

    await _pumpHostScreen(
      tester,
      const HostCustomerDetailScreen(
        organizerId: 'organizer-1',
        contactId: 'contact-1',
      ),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        hostAudienceContactDetailProvider(
          'organizer-1',
          'contact-1',
        ).overrideWithValue(AsyncData(detail)),
        externalUrlLauncherProvider.overrideWithValue((
          uri, {
          mode = LaunchMode.platformDefault,
        }) async {
          launchedUri = uri;
          return true;
        }),
      ],
    );

    await tester.tap(find.byKey(const ValueKey('host-customer-open-whatsapp')));
    await pumpFeatureUi(tester);

    expect(find.text('WhatsApp app'), findsOneWidget);
    expect(find.textContaining('You review it and press Send'), findsWidgets);
    final messageInput = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('host-customer-whatsapp-message')),
        matching: find.byType(TextField),
      ),
    );
    expect(messageInput.controller?.text, 'Hi Ananya Rao,');

    await tester.tap(
      find.byKey(const ValueKey('host-customer-confirm-whatsapp')),
    );
    await pumpFeatureUi(tester);

    expect(launchedUri?.scheme, 'whatsapp');
    expect(launchedUri?.host, 'send');
    expect(launchedUri?.queryParameters['phone'], '919876543210');
    expect(launchedUri?.queryParameters['text'], 'Hi Ananya Rao,');
  });
}

HostCustomerDirectoryContact _customerDirectoryContact({
  bool hasAmbiguousIdentity = false,
}) => HostCustomerDirectoryContact(
  contactId: 'contact-1',
  displayName: 'Ananya Rao',
  attendedEventCount: 8,
  lastAttendedAt: null,
  tags: const {HostCustomerTag.regular},
  hasAmbiguousIdentity: hasAmbiguousIdentity,
  whatsappOptedIn: false,
  whatsappAdminSuppressed: false,
);

HostCustomersDirectoryState _customerDirectoryState() =>
    HostCustomersDirectoryState(
      contacts: [_customerDirectoryContact()],
      nextCursor: null,
      matchCount: 1,
      matchCountCoverage: HostCustomerMatchCountCoverage.exact,
      sourceCoverage: HostCustomerDirectoryCoverage.exact,
      projectionVersion: 1,
    );

HostCustomersDirectoryState _emptyCustomerDirectoryState() =>
    const HostCustomersDirectoryState(
      contacts: [],
      nextCursor: null,
      matchCount: 0,
      matchCountCoverage: HostCustomerMatchCountCoverage.exact,
      sourceCoverage: HostCustomerDirectoryCoverage.exact,
      projectionVersion: 1,
    );

HostAudienceContactDetail _customerDetail({
  bool contactDetailsEditable = false,
  bool linkedAccount = true,
  HostAudienceIdentityState identityState = HostAudienceIdentityState.verified,
  String identityConfidence = 'verified_account',
  String? phoneE164,
}) => HostAudienceContactDetail(
  organizerId: 'organizer-1',
  contactId: 'contact-1',
  displayName: 'Ananya Rao',
  sourceDisplayName: 'Ananya Rao',
  displayNameOverride: null,
  phoneE164: phoneE164,
  email: null,
  linkedAccount: linkedAccount,
  identityState: identityState,
  identityConfidence: identityConfidence,
  contactDetailsEditable: contactDetailsEditable,
  ambiguousCandidateCount: 0,
  whatsappAdminSuppressed: false,
  traits: const HostCustomerTraits(
    expectedEventCount: 1,
    attendedEventCount: 1,
    cancelledEventCount: 0,
    noShowCount: 0,
    importedEventCount: 0,
    attendanceRate: 1,
    segments: {HostAudienceSegment.regular},
    whatsappStatus: HostAudiencePermissionStatus.optedIn,
    sourceCoverage: HostAudienceSourceCoverage.exact,
  ),
  revenue: const HostCustomerRevenue(
    coverage: HostCustomerRevenueCoverage.exact,
    amounts: [],
  ),
  events: [
    HostAudienceEventFact(
      eventId: 'event-1',
      displayName: 'Sunday Run Club',
      eventOrigin: HostCustomerEventOrigin.externalCompanion,
      eventProvider: 'eventbrite',
      source: 'attendance',
      status: 'attended',
      checkedIn: true,
      eventStartAt: DateTime(2026, 8),
      revenues: const [
        HostCustomerEventRevenue(
          currency: 'INR',
          amountMinor: 125000,
          source: HostCustomerRevenueSource.hostImport,
          factCount: 1,
          allocation: HostCustomerRevenueAllocation.perAttendee,
        ),
      ],
    ),
  ],
  eventsTruncated: false,
  manualTags: const [
    HostManualTag(
      tagId: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      label: 'Brings friends',
    ),
  ],
  manualTagVocabulary: const [
    HostManualTag(
      tagId: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      label: 'Brings friends',
    ),
    HostManualTag(
      tagId: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      label: 'Prefers weekends',
    ),
  ],
  notes: [
    HostCustomerNote(
      noteId: 'note-1',
      body: 'Introduced three friends.',
      authorUid: _hostUid,
      createdAt: DateTime(2026, 8, 15),
      updatedAt: DateTime(2026, 8, 15),
      revision: 1,
    ),
  ],
  sends: [
    HostCustomerSend(
      campaignId: 'campaign-1',
      name: 'August invite',
      messageClass: 'organizerPromotion',
      deliveryStatus: HostCustomerSendDeliveryStatus.delivered,
      createdAt: DateTime(2026, 8, 14),
      sentAt: DateTime(2026, 8, 14),
      updatedAt: DateTime(2026, 8, 14),
    ),
  ],
  revision: 1,
);

class _FixedHostCustomersDirectoryController
    extends HostCustomersDirectoryController {
  _FixedHostCustomersDirectoryController(this.requests, this.value);

  final List<HostCustomersDirectoryRequest> requests;
  final HostCustomersDirectoryState value;

  @override
  Future<HostCustomersDirectoryState> build(
    HostCustomersDirectoryRequest request,
  ) async {
    requests.add(request);
    return value;
  }
}
