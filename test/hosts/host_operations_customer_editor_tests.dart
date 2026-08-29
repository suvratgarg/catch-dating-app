part of 'host_operations_screen_test.dart';

void _registerHostOperationsCustomerEditorTests() {
  testWidgets('customer identity edits and saves in place', (tester) async {
    String? savedDisplayName;
    String? savedPhone;
    String? savedEmail;
    final customer = _customerDetail(
      contactDetailsEditable: true,
      linkedAccount: false,
      identityState: HostAudienceIdentityState.unlinked,
      identityConfidence: 'unverified',
      phoneE164: '+919876543210',
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

    expect(find.text('+919876543210'), findsOneWidget);
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
        of: find.byKey(const ValueKey('host-customer-edit-phone')),
        matching: find.byType(TextField),
      ),
      '',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-customer-edit-email')),
        matching: find.byType(TextField),
      ),
      '',
    );
    await tester.tap(find.byKey(const ValueKey('catch-field-done')));
    await pumpFeatureUi(tester);

    expect(
      find.text('Add or keep at least one mobile number or email address.'),
      findsOneWidget,
    );
    expect(savedDisplayName, isNull);

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
