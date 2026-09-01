part of 'host_operations_screen_test.dart';

void _registerHostOperationsCustomerReachTests() {
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
