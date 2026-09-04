part of 'host_operations_screen_test.dart';

void _registerHostOperationsCustomerReachTests() {
  testWidgets(
    'customer reach separates recorded permission from missing evidence',
    (tester) async {
      for (final evidence in [
        HostCustomerPermissionEvidenceStatus.incomplete,
        HostCustomerPermissionEvidenceStatus.unavailable,
      ]) {
        await _pumpHostScreen(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: HostCustomerReachSection(
                customer: _customerDetail(
                  whatsappPermission: HostCustomerWhatsappPermission(
                    status: HostAudiencePermissionStatus.optedIn,
                    evidenceStatus: evidence,
                    receiptId: null,
                    source: null,
                    sourceFormId: null,
                    sourceFormTitle: null,
                    decisionAt: null,
                    identityStrength: null,
                  ),
                ),
                communicationPlan: _individualCommunicationPlan(),
                communicationPlanLoading: false,
                communicationPlanFailed: false,
                messageLoading: false,
                onMessage: () {},
                onRetryCommunicationPlan: () {},
                onMessagingEnabledChanged: null,
              ),
            ),
          ),
        );
        if (evidence == HostCustomerPermissionEvidenceStatus.incomplete) {
          expect(
            find.textContaining('Participant granted permission.'),
            findsOneWidget,
          );
          expect(
            find.textContaining('legacy evidence is incomplete'),
            findsOneWidget,
          );
        } else {
          expect(
            find.text('Permission evidence is unavailable right now.'),
            findsOneWidget,
          );
          expect(
            find.textContaining('Participant granted permission.'),
            findsNothing,
          );
        }
      }
    },
  );

  testWidgets('customer reach retains retry and every loaded source', (
    tester,
  ) async {
    var retried = 0;
    final origins = [
      for (var i = 0; i < 4; i++)
        HostCustomerOrigin(
          originId: 'receipt-$i',
          sourceKind: HostCustomerOriginSourceKind.hostForm,
          sourceEntityKind: 'hostFormResponse',
          formId: 'form-$i',
          formTitle: 'Application $i',
          eventId: null,
          eventTitle: null,
          observedAt: DateTime(2026, 7, i + 1),
        ),
    ];
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: HostCustomerReachSection(
            customer: _customerDetail(origins: origins, originsTruncated: true),
            communicationPlan: null,
            communicationPlanLoading: false,
            communicationPlanFailed: true,
            messageLoading: false,
            messageActionInHeader: true,
            onMessage: () {},
            onRetryCommunicationPlan: () => retried++,
            onMessagingEnabledChanged: null,
          ),
        ),
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('host-customer-message-plan-retry')),
    );
    expect(retried, 1);
    for (var i = 0; i < 4; i++) {
      expect(find.text('Application $i'), findsOneWidget);
    }
    expect(
      find.text(
        'More source records exist. Only the loaded records are shown.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'customer reach loading and blockers never offer an unavailable route',
    (tester) async {
      for (final loading in [true, false]) {
        await _pumpHostScreen(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: HostCustomerReachSection(
                customer: _customerDetail(),
                communicationPlan: _individualCommunicationPlan(
                  catchChatAvailable: false,
                  whatsappHandoffAvailable: false,
                  whatsappHandoffBlocker:
                      HostCommunicationRouteBlocker.contactOptedOut,
                ),
                communicationPlanLoading: loading,
                communicationPlanFailed: false,
                messageLoading: false,
                onMessage: () => fail('Unavailable route opened'),
                onRetryCommunicationPlan: () {},
                onMessagingEnabledChanged: null,
              ),
            ),
          ),
        );
        expect(
          find.byKey(const ValueKey('host-customer-message-plan-loading')),
          loading ? findsOneWidget : findsNothing,
        );
        if (!loading) {
          expect(
            find.text(
              AppLocalizationsEn().hostCustomersWhatsappContactOptedOut,
            ),
            findsOneWidget,
          );
          await tester.tap(find.byKey(const ValueKey('host-customer-message')));
        }
      }
    },
  );

  testWidgets('customer reach resumes only team suppression', (tester) async {
    bool? enabled;
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: HostCustomerReachSection(
            customer: _customerDetail(whatsappAdminSuppressed: true),
            communicationPlan: _individualCommunicationPlan(),
            communicationPlanLoading: false,
            communicationPlanFailed: false,
            messageLoading: false,
            onMessage: () {},
            onRetryCommunicationPlan: () {},
            onMessagingEnabledChanged: (value) => enabled = value,
          ),
        ),
      ),
    );
    final toggle = find.byKey(
      const ValueKey('host-customer-organizer-messages'),
    );
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    expect(enabled, isTrue);
    expect(
      find.textContaining('Granted on Sunday Run sign-up'),
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
