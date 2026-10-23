// Riverpod reports the shared test-root ProviderScope overrides from the
// library entrypoint against this part file, so the adjacent entrypoint ignores
// cannot attach to the remapped diagnostics.
// ignore_for_file: riverpod_lint/scoped_providers_should_specify_dependencies

part of 'host_inbox_screen_test.dart';

void _registerHostInboxSendsTests(DateTime now) {
  testWidgets('moves roster-backed event announcements into Sends', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: const [],
        participations: [
          event_test.buildEventParticipation(event: event, uid: 'booked-1'),
          event_test.buildEventParticipation(event: event, uid: 'booked-2'),
        ],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Message 2 booked attendees'), findsNothing);
    expect(find.text('No booked attendees have written yet'), findsOneWidget);

    await tester.tap(find.text('Sends'));
    await pumpFeatureUi(tester);

    expect(find.text('Outbound delivery and history.'), findsOneWidget);
    expect(find.text('One-to-one conversations and replies.'), findsNothing);
    await tester.tap(find.text('Choose what to send'));
    await pumpFeatureUi(tester);

    expect(find.text('Send an event announcement'), findsOneWidget);
    expect(find.textContaining('2 booked people'), findsOneWidget);
    await tester.tap(find.text('Send an event announcement'));
    await pumpFeatureUi(tester);
    expect(find.text('New broadcast'), findsOneWidget);
  });

  testWidgets('wide Sends keeps history beside the selected operational pane', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _app(
        event: null,
        previews: const [],
        participations: const [],
        now: now,
        initialWorkspace: HostMessagingWorkspace.campaigns,
        routeWidth: 1200,
      ),
    );
    await pumpFeatureUi(tester);

    final viewport = tester.widget<CatchNavigationViewport>(
      find.byType(CatchNavigationViewport),
    );
    expect(viewport.panes, hasLength(2));
    expect(viewport.panes.first.id, 'index');
    expect(find.byType(HostMessagingWorkspaceTabBar), findsOneWidget);
    expect(find.text('Outbound delivery and history.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows Sends history before opening the campaign composer', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: const [],
        participations: const [],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Sends'));
    await pumpFeatureUi(tester);

    expect(find.text('Messaging'), findsOneWidget);
    expect(find.text('Choose what to send'), findsOneWidget);
    expect(find.text('WhatsApp Business settings'), findsOneWidget);
    expect(find.byType(HostCampaignEditor), findsNothing);

    await tester.tap(find.text('Choose what to send'));
    await pumpFeatureUi(tester);

    expect(find.text('WHAT DO YOU WANT TO DO?'), findsOneWidget);
    expect(find.text('Continue a conversation'), findsOneWidget);
    expect(find.text('Message a saved audience'), findsOneWidget);
    expect(find.text('Send an event announcement'), findsOneWidget);
    expect(find.text('Post a follower update'), findsOneWidget);
    expect(find.text('IN CATCH'), findsNothing);
    expect(find.text('WHATSAPP'), findsNothing);
    expect(find.textContaining('Meta'), findsNothing);
    expect(find.text('WhatsApp Business · Organizer number'), findsNothing);
    for (final intent in const [
      'conversation',
      'saved-audience',
      'event-announcement',
      'follower-update',
    ]) {
      expect(
        find.byKey(ValueKey('host-send-intent-$intent')),
        findsOneWidget,
        reason: '$intent must remain represented in the intent chooser',
      );
    }
    expect(find.byType(HostCampaignEditor), findsNothing);

    await tester.tap(find.text('Message a saved audience'));
    await pumpFeatureUi(tester);

    expect(find.byType(HostCampaignEditor), findsOneWidget);
    expect(find.text('MESSAGE PAST ATTENDEES'), findsOneWidget);
    expect(find.byType(HostInboxScopeMenu), findsNothing);
    expect(find.byType(HostInboxAudienceInput), findsNothing);
  });

  testWidgets('Sends omits WhatsApp setup where the provider is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        event: null,
        previews: const [],
        participations: const [],
        now: now,
        whatsappProviderConfigured: false,
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Sends'));
    await pumpFeatureUi(tester);

    expect(find.text('Choose what to send'), findsOneWidget);
    expect(find.text('WhatsApp Business settings'), findsNothing);

    await tester.tap(find.text('Choose what to send'));
    await pumpFeatureUi(tester);

    expect(find.text('Continue a conversation'), findsOneWidget);
    expect(find.text('Send an event announcement'), findsOneWidget);
    expect(find.text('Post a follower update'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-send-intent-saved-audience')),
      findsNothing,
    );
    expect(find.text('WhatsApp Business settings'), findsNothing);
  });

  testWidgets('Follower update intent opens its composer', (tester) async {
    await tester.pumpWidget(
      _app(
        event: null,
        previews: const [],
        participations: const [],
        now: now,
        remainingFollowerQuota: 2,
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Sends'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Choose what to send'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Post a follower update'));
    await pumpFeatureUi(tester);

    expect(find.text('Post to followers'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-follower-update-text')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Followers in Catch · Home and Activity'),
      findsWidgets,
    );
  });

  testWidgets('Sends history renders every server-managed send route', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );
    final sends = <HostSendSummary>[
      HostAnnouncementSendSummary(
        broadcastId: 'announcement-1',
        eventId: event.id,
        eventName: 'Doors open update',
        audience: 'booked',
        recipientCount: 18,
        sentAt: now,
        partialFailure: false,
        activityAt: now,
      ),
      HostCampaignSendSummary(
        campaignId: 'campaign-1',
        name: 'Bring regulars back',
        status: 'sent',
        segments: const {HostAudienceSegment.lapsedRegular},
        templateId: 'returning_guests',
        templateName: 'Returning guests',
        audienceCounts: const HostCampaignCounts({'eligible': 24}),
        deliveryCounts: const HostCampaignCounts({'sent': 24}),
        scheduledAt: null,
        dispatchedAt: now.subtract(const Duration(days: 1)),
        activityAt: now.subtract(const Duration(days: 1)),
      ),
      HostFollowerUpdateSendSummary(
        postId: 'post-1',
        eventId: null,
        audience: 'followers',
        status: 'active',
        deliveryStatus: 'completed',
        recipientCount: 20,
        excludedCount: 1,
        activityAvailableCount: 19,
        pushAttemptedCount: 15,
        pushAcceptedCount: 15,
        pushFailedCount: 0,
        pushUnknownCount: 0,
        createdAt: now.subtract(const Duration(hours: 12)),
        activityAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    await tester.pumpWidget(
      _app(
        event: event,
        previews: const [],
        participations: const [],
        sends: sends,
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Sends'));
    await pumpFeatureUi(tester);

    expect(find.text('Doors open update'), findsOneWidget);
    expect(find.text('Bring regulars back'), findsOneWidget);
    expect(find.text('Follower update · Organizer'), findsOneWidget);
    expect(find.text('Available in Catch'), findsOneWidget);
    expect(
      find.textContaining('Catch announcement · Organizer'),
      findsOneWidget,
    );
    expect(
      find.textContaining('WhatsApp Business · Organizer number'),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('Doors open update')).dy,
      lessThan(tester.getTopLeft(find.text('Bring regulars back')).dy),
    );
  });

  testWidgets('queued manual handoff cannot be marked sent before opening', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        event: null,
        previews: const [],
        participations: const [],
        manualSendTasks: [_manualSendTask(HostManualSendTaskStatus.queued)],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Sends'));
    await pumpFeatureUi(tester);

    expect(find.byType(HostManualSendList), findsOneWidget);
    expect(find.text('NEEDS YOUR SEND'), findsOneWidget);
    expect(find.text('Asha Manual'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);

    await tester.tap(find.text('Asha Manual'));
    await pumpFeatureUi(tester);

    final markSent = tester.widget<CatchButton>(
      find.byKey(const ValueKey('host-manual-send-mark-sent')),
    );
    expect(markSent.onPressed, isNull);
    expect(
      find.textContaining('cannot verify that the message was sent'),
      findsOneWidget,
    );
  });

  testWidgets('opened handoff remains unconfirmed but permits host assertion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        event: null,
        previews: const [],
        participations: const [],
        manualSendTasks: [
          _manualSendTask(HostManualSendTaskStatus.handoffOpened),
        ],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Sends'));
    await pumpFeatureUi(tester);

    expect(find.text('WhatsApp opened'), findsOneWidget);
    expect(
      find.text(
        'Not confirmed sent. Catch cannot observe the final action in WhatsApp.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Asha Manual'));
    await pumpFeatureUi(tester);

    final markSent = tester.widget<CatchButton>(
      find.byKey(const ValueKey('host-manual-send-mark-sent')),
    );
    expect(markSent.onPressed, isNotNull);
  });

  testWidgets('campaigns workspace restores the routed saved audience', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        event: null,
        previews: const [],
        participations: const [],
        now: now,
        initialWorkspace: HostMessagingWorkspace.campaigns,
        initialSavedAudienceId: 'audience-1',
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(HostMessagingWorkspaceTabBar), findsNothing);
    expect(find.byType(HostCampaignEditor), findsOneWidget);
    expect(find.text('Lapsed customers · 12 people at last preview'), findsOne);
    await tester.tap(find.byTooltip('Back'));
    await pumpFeatureUi(tester);
    expect(find.byType(HostMessagingWorkspaceTabBar), findsOneWidget);
  });
}
