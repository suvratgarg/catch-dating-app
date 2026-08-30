part of 'host_operations_screen_test.dart';

void _registerHostOperationsCustomerSummaryFiltersTests() {
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
}
