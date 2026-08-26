part of 'host_operations_screen_test.dart';

void _registerHostOperationsCustomerDetailLoadingTests() {
  testWidgets('customer history stays deferred until requested', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var historyLoads = 0;
    final detail = _customerDetail();
    await _pumpHostScreen(
      tester,
      const HostCustomerDetailScreen(
        organizerId: 'organizer-1',
        contactId: 'contact-1',
      ),
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
        hostAudienceContactOverviewProvider(
          'organizer-1',
          'contact-1',
        ).overrideWithValue(AsyncData(detail)),
        hostAudienceContactHistoryProvider(
          'organizer-1',
          'contact-1',
        ).overrideWith((ref) async {
          historyLoads += 1;
          return _customerHistory(detail);
        }),
      ],
    );

    expect(historyLoads, 0);
    expect(
      find.byKey(const ValueKey('host-customer-load-history')),
      findsOneWidget,
    );

    await tester.tap(find.text('Load more'));
    await pumpFeatureUi(tester);

    expect(historyLoads, 1);
    expect(find.byType(HostCustomerRevenueCard), findsOneWidget);
  });
}

HostAudienceContactHistory _customerHistory(HostAudienceContactDetail detail) =>
    HostAudienceContactHistory(
      organizerId: detail.organizerId,
      contactId: detail.contactId,
      revenue: detail.revenue,
      events: detail.events,
      eventsTruncated: detail.eventsTruncated,
      sends: detail.sends,
      sendsTruncated: detail.sendsTruncated,
      sendsCoverage: detail.sendsCoverage,
      activeMerges: detail.activeMerges,
      revision: detail.revision,
    );
