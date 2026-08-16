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
    expect(find.descendant(of: row, matching: find.text('REGULARS')), findsOne);
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

    final search = tester.widget<CatchField>(find.byType(CatchField).first);
    expect(search.showLabel, isFalse);
    expect(search.inputHint, 'Search by name');
    expect(find.text('SMS reachable'), findsNothing);
    expect(requests.last.search, isNull);

    await tester.enterText(find.byType(TextField), '  ananya  ');
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 299));
    expect(requests.last.search, isNull);

    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1));
    await pumpFeatureUi(tester);
    expect(requests.last.search, 'ananya');
  });

  testWidgets('customer header compresses stats and export into overflow', (
    tester,
  ) async {
    final club = buildClub(id: 'header-club', ownerUserId: _hostUid);
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
    expect(find.byTooltip('Export this audience'), findsOneWidget);

    await tester.tap(find.byTooltip('Export this audience'));
    await pumpFeatureUi(tester);
    expect(find.text('Export this audience'), findsOneWidget);
    expect(find.text('WhatsApp ready'), findsOneWidget);
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

    await tester.tap(find.text('Sunday Run Club'));
    await pumpFeatureUi(tester);
    expect(find.text('Event organizer-1 event-1'), findsOneWidget);
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
      sourceCoverage: HostCustomerDirectoryCoverage.exact,
      projectionVersion: 1,
    );

HostCustomersDirectoryState _emptyCustomerDirectoryState() =>
    const HostCustomersDirectoryState(
      contacts: [],
      nextCursor: null,
      sourceCoverage: HostCustomerDirectoryCoverage.exact,
      projectionVersion: 1,
    );

HostAudienceContactDetail _customerDetail() => HostAudienceContactDetail(
  organizerId: 'organizer-1',
  contactId: 'contact-1',
  displayName: 'Ananya Rao',
  sourceDisplayName: 'Ananya Rao',
  displayNameOverride: null,
  phoneE164: null,
  email: null,
  linkedAccount: true,
  identityState: HostAudienceIdentityState.verified,
  identityConfidence: 'verified_account',
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
      source: 'attendance',
      status: 'attended',
      checkedIn: true,
      eventStartAt: DateTime(2026, 8),
    ),
  ],
  eventsTruncated: false,
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
