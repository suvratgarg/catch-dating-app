// ignore_for_file: riverpod_lint/scoped_providers_should_specify_dependencies

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/clubs/data/club_posts_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_screen.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_manual_send_queue.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart' as club_test;
import '../events/events_test_helpers.dart' as event_test;
import '../test_pump_helpers.dart';

void main() {
  final now = DateTime(2026, 7, 10, 18);

  setUp(() => AppConfig.configureEntrypointRole(AppRole.host));
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  testWidgets('resolved signed-out state is not shown as loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream<String?>.value(null)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: HostInboxScreen(now: now, syncSelectionToRoute: false),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Sign in required'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create your first organizer'), findsNothing);
  });

  testWidgets('renders selected-event segments without an outbound card', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );
    final booked = _preview(
      uid: 'booked-1',
      name: 'Asha Guest',
      eventIds: [event.id],
    );
    final prospective = _preview(
      uid: 'waitlist-1',
      name: 'Mira Guest',
      eventIds: [event.id],
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: [booked, prospective],
        participations: [
          event_test.buildEventParticipation(event: event, uid: 'booked-1'),
          event_test.buildEventParticipation(
            event: event,
            uid: 'waitlist-1',
            status: EventParticipationStatus.waitlisted,
            hostApprovalStatus: EventJoinRequestStatus.pending,
          ),
        ],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Messaging'), findsOneWidget);
    expect(find.text('One-to-one conversations and replies.'), findsNothing);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Sends'), findsOneWidget);
    expect(find.byType(HostInboxScopeSelector), findsOneWidget);
    expect(find.text('BOOKED · 1'), findsOneWidget);
    expect(find.text('PROSPECTIVE · 1'), findsOneWidget);
    expect(
      find.byType(CatchOptionGroup<HostInboxAudienceSegment>),
      findsOneWidget,
    );
    expect(find.text('Message 1 booked attendee'), findsNothing);
    expect(find.text('Asha Guest'), findsOneWidget);
    expect(
      find.text('Catch chat · Organizer · Booked · Can you help?'),
      findsOneWidget,
    );
    expect(find.text('Mira Guest'), findsNothing);

    await tester.tap(find.text('PROSPECTIVE · 1'));
    await pumpFeatureUi(tester);

    expect(find.text('Message 1 prospective attendee'), findsNothing);
    expect(find.text('Mira Guest'), findsOneWidget);
    expect(
      find.text('Catch chat · Organizer · Requested · Can you help?'),
      findsOneWidget,
    );
    expect(find.text('Asha Guest'), findsNothing);
  });

  testWidgets(
    'Messaging title collapses while the workspace rail stays pinned',
    (tester) async {
      final previews = List<ChatThreadPreview>.generate(
        24,
        (index) => _preview(
          uid: 'general-$index',
          name: 'General Guest $index',
          eventIds: const [],
        ),
      );
      await tester.pumpWidget(
        _app(
          event: null,
          previews: previews,
          participations: const [],
          now: now,
        ),
      );
      await pumpFeatureUi(tester);

      expect(find.byType(NestedScrollView), findsOneWidget);
      final topBar = tester.widget<CatchScreenTopBar>(
        find.byType(CatchScreenTopBar),
      );
      expect(topBar.contentPadding, CatchInsets.primaryRailTitleBlock);
      final rail = find.byType(HostMessagingWorkspaceRail);
      final railBefore = tester.getRect(rail);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await pumpFeatureUi(tester);
      final railAfterCollapse = tester.getRect(rail);
      expect(railAfterCollapse.top, lessThan(railBefore.top));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -240));
      await pumpFeatureUi(tester);
      expect(tester.getRect(rail).top, closeTo(railAfterCollapse.top, 0.001));
    },
  );

  testWidgets('expanded inbox reserves a stable conversation detail pane', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final preview = _preview(
      uid: 'expanded-guest',
      name: 'Expanded Guest',
      eventIds: const [],
    );

    await tester.pumpWidget(
      _app(
        event: null,
        previews: [preview],
        participations: const [],
        now: now,
        routeWidth: 1200,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(CatchScreenScaffold), findsOneWidget);
    expect(
      find.byKey(const ValueKey('catch-master-detail-divider')),
      findsOneWidget,
    );
    expect(find.text('Select a conversation'), findsOneWidget);
    expect(find.text('Expanded Guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('split view uses route-body width after shell chrome', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final preview = _preview(
      uid: 'constrained-guest',
      name: 'Constrained Guest',
      eventIds: const [],
    );

    await tester.pumpWidget(
      _app(
        event: null,
        previews: [preview],
        participations: const [],
        now: now,
        routeWidth: 700,
      ),
    );
    await pumpFeatureUi(tester);

    expect(
      find.byKey(const ValueKey('catch-master-detail-divider')),
      findsNothing,
    );
    expect(find.text('Select a conversation'), findsNothing);
    expect(find.text('Constrained Guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('wide Sends keeps its operational content in a bounded lane', (
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

    final lane = tester.widget<CatchSliverContentWidth>(
      find.byType(CatchSliverContentWidth),
    );
    expect(lane.maxExtent, CatchLayout.hostMessagingSendsPageMaxExtent);
    expect(find.text('Outbound delivery and history.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps WhatsApp threads inside the existing Inbox scopes', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );
    final eventThread = _whatsappThread(
      threadId: 'event-thread',
      displayName: 'Event Guest',
      eventIds: [event.id],
      body: 'Where is the entrance?',
      now: now,
    );
    final generalThread = _whatsappThread(
      threadId: 'general-thread',
      displayName: 'General Guest',
      eventIds: const [],
      body: 'When is your next event?',
      now: now,
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: const [],
        participations: const [],
        whatsappThreads: [eventThread, generalThread],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Event Guest'), findsOneWidget);
    expect(find.text('Where is the entrance?'), findsOneWidget);
    expect(find.text('WhatsApp Business · Organizer number'), findsOneWidget);
    expect(find.text('General Guest'), findsNothing);

    await tester.tap(find.bySemanticsLabel(RegExp('Inbox scope')));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('General inquiries'));
    await pumpFeatureUi(tester);

    expect(find.text('General Guest'), findsOneWidget);
    expect(find.text('When is your next event?'), findsOneWidget);
    expect(find.text('Event Guest'), findsNothing);
  });

  testWidgets('keeps Catch Inbox usable when WhatsApp enrichment fails', (
    tester,
  ) async {
    final preview = _preview(
      uid: 'general-1',
      name: 'Asha Guest',
      eventIds: const [],
    );

    await tester.pumpWidget(
      _app(
        event: null,
        previews: [preview],
        participations: const [],
        whatsappThreadsValue: AsyncError(
          StateError('listOrganizerWhatsappThreads is not deployed'),
          StackTrace.empty,
        ),
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Asha Guest'), findsOneWidget);
    expect(
      find.text('Catch chat · Organizer · General inquiry · Can you help?'),
      findsOneWidget,
    );
    expect(find.text('Chat not found'), findsNothing);
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
    expect(find.byType(HostCampaignComposer), findsNothing);

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
    expect(find.byType(HostCampaignComposer), findsNothing);

    await tester.tap(find.text('Message a saved audience'));
    await pumpFeatureUi(tester);

    expect(find.byType(HostCampaignComposer), findsOneWidget);
    expect(find.text('MESSAGE PAST ATTENDEES'), findsOneWidget);
    expect(find.byType(HostInboxScopeSelector), findsNothing);
    expect(find.byType(HostInboxAudienceRail), findsNothing);
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

    expect(find.byType(HostManualSendQueue), findsOneWidget);
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

  testWidgets('compact scope label opens the shared event menu', (
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

    await tester.tap(find.bySemanticsLabel(RegExp('Inbox scope')));
    await pumpFeatureUi(tester);

    expect(find.byType(CatchMenu<HostInboxScope>), findsOneWidget);
    expect(find.text('General inquiries'), findsOneWidget);

    await tester.tap(find.text('General inquiries'));
    await pumpFeatureUi(tester);

    expect(find.text('GENERAL INQUIRIES'), findsOneWidget);
    expect(find.byType(HostInboxAudienceRail), findsNothing);
  });

  testWidgets(
    'scope menu stays above floating shell navigation and scrolls internally',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      const bottomOverlayInset = 100.0;
      final events = [
        for (var index = 0; index < 20; index++)
          event_test.buildEvent(
            id: 'event-$index',
            name: 'Scope event $index',
            startTime: now.add(Duration(days: index + 1)),
            endTime: now.add(Duration(days: index + 1, hours: 1)),
          ),
      ];

      await tester.pumpWidget(
        _app(
          event: events.first,
          events: events,
          previews: const [],
          participations: const [],
          now: now,
          routeWidth: 400,
          floatingBottomOverlayInset: bottomOverlayInset,
        ),
      );
      await pumpFeatureUi(tester);

      await tester.tap(find.bySemanticsLabel(RegExp('Inbox scope')));
      await pumpFeatureUi(tester);

      final menu = find.byType(CatchMenu<HostInboxScope>);
      expect(menu, findsOneWidget);
      final usableBottom =
          tester.view.physicalSize.height / tester.view.devicePixelRatio -
          bottomOverlayInset;
      expect(tester.getRect(menu).bottom, lessThanOrEqualTo(usableBottom));
      final scrollable = find.descendant(
        of: menu,
        matching: find.byType(Scrollable),
      );
      expect(scrollable, findsOneWidget);
      expect(
        tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
        greaterThan(0),
      );
    },
  );

  testWidgets('General scope excludes event-specific inquiries', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );
    final general = _preview(
      uid: 'general-1',
      name: 'General Guest',
      eventIds: const [],
    );
    final scoped = _preview(
      uid: 'event-1',
      name: 'Event Guest',
      eventIds: [event.id],
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: [general, scoped],
        participations: const [],
        initialScope: const HostInboxScope.general(),
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('GENERAL INQUIRIES'), findsOneWidget);
    expect(find.text('General Guest'), findsOneWidget);
    expect(
      find.text('Catch chat · Organizer · General inquiry · Can you help?'),
      findsOneWidget,
    );
    expect(find.text('Event Guest'), findsNothing);
    expect(find.textContaining('Message '), findsNothing);
    expect(find.textContaining('Booked ·'), findsNothing);
  });

  testWidgets(
    'singleton general scope centers the canonical empty state without a header',
    (tester) async {
      await tester.pumpWidget(
        _app(
          event: null,
          previews: const [],
          participations: const [],
          now: now,
        ),
      );
      await pumpFeatureUi(tester);

      expect(find.byType(HostInboxScopeSelector), findsNothing);
      expect(find.text('GENERAL INQUIRIES'), findsNothing);
      expect(find.text('No general inquiries'), findsOneWidget);

      final emptyState = find.byType(CatchEmptyState);
      final content = find.byType(CatchEmptyStateContent);
      expect(find.byType(CatchSliverStateViewport), findsOneWidget);
      expect(
        find.ancestor(of: emptyState, matching: find.byType(Center)),
        findsNothing,
      );
      final fills = tester.widgetList<SliverFillRemaining>(
        find.ancestor(
          of: emptyState,
          matching: find.byType(SliverFillRemaining),
        ),
      );
      expect(fills.any((fill) => fill.hasScrollBody), isTrue);
      expect(
        tester.getCenter(content).dx,
        closeTo(tester.getCenter(emptyState).dx, 0.5),
      );
      expect(
        tester.getCenter(content).dy,
        closeTo(tester.getCenter(emptyState).dy, 0.5),
      );
    },
  );

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

    expect(find.byType(HostMessagingWorkspaceRail), findsOneWidget);
    expect(find.byType(HostCampaignComposer), findsOneWidget);
    expect(find.text('Lapsed customers · 12 people at last preview'), findsOne);
  });
}

Widget _app({
  required Event? event,
  List<Event>? events,
  required List<ChatThreadPreview> previews,
  required List<EventParticipation> participations,
  required DateTime now,
  HostInboxScope? initialScope,
  HostMessagingWorkspace initialWorkspace = HostMessagingWorkspace.inbox,
  String? initialSavedAudienceId,
  List<HostSendSummary> sends = const [],
  List<HostWhatsappThreadSummary> whatsappThreads = const [],
  List<HostManualSendTask> manualSendTasks = const [],
  AsyncValue<HostWhatsappThreadPage>? whatsappThreadsValue,
  int remainingFollowerQuota = 3,
  double routeWidth = 390,
  double floatingBottomOverlayInset = 0,
}) {
  final club = club_test.buildClub(id: event?.clubId ?? 'club-1');
  final inbox = ChatsListViewModel(
    newMatches: const [],
    conversations: previews,
    totalThreadCount: previews.length,
  );
  final screen = HostInboxScreen(
    initialScope: initialScope,
    initialWorkspace: initialWorkspace,
    initialSavedAudienceId: initialSavedAudienceId,
    syncSelectionToRoute: false,
    now: now,
  );
  final route = Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: routeWidth, height: 900, child: screen),
  );
  return ProviderScope(
    overrides: [
      uidProvider.overrideWith((ref) => Stream.value('host-1')),
      eventRepositoryProvider.overrideWithValue(
        event_test.FakeEventRepository(),
      ),
      hostOperableClubsProvider('host-1').overrideWithValue(AsyncData([club])),
      watchEventsForClubProvider(
        club.id,
      ).overrideWith((ref) => Stream.value(events ?? [?event])),
      chatsListViewModelProvider.overrideWithValue(AsyncData(inbox)),
      hostMessagingSetupProvider(
        club.id,
      ).overrideWithValue(AsyncData(_messagingSetup(club.id))),
      hostCrmSummaryProvider(
        club.id,
      ).overrideWithValue(AsyncData(_crmSummary(club.id))),
      hostSendsProvider(club.id).overrideWithValue(
        AsyncData(
          HostSendsPage(organizerId: club.id, sends: sends, nextCursor: null),
        ),
      ),
      hostManualSendTasksProvider(club.id).overrideWithValue(
        AsyncData(
          HostManualSendTaskPage(
            organizerId: club.id,
            tasks: manualSendTasks,
            nextCursor: null,
          ),
        ),
      ),
      watchClubPostRemainingWeeklyQuotaProvider(
        club.id,
      ).overrideWith((ref) => Stream.value(remainingFollowerQuota)),
      hostWhatsappThreadsProvider(club.id).overrideWithValue(
        whatsappThreadsValue ??
            AsyncData(
              HostWhatsappThreadPage(
                organizerId: club.id,
                threads: whatsappThreads,
                nextCursor: null,
              ),
            ),
      ),
      hostCustomerSegmentCountProvider.overrideWith(
        (ref, request) async => const HostCustomerSegmentCount(
          count: 12,
          coverage: HostCustomerMatchCountCoverage.exact,
        ),
      ),
      hostSavedAudiencesProvider(club.id).overrideWithValue(
        AsyncData(
          HostSavedAudiencePage(
            audiences: [_savedAudience(club.id)],
            nextCursor: null,
          ),
        ),
      ),
      if (event != null)
        watchEventParticipationsForEventProvider(
          event.id,
        ).overrideWith((ref) => Stream.value(participations)),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: floatingBottomOverlayInset > 0
          ? AppShellActiveTab(
              index: appShellChatsTabIndex,
              bottomBarPlacement: AppShellBottomBarPlacement.floating,
              bottomOverlayInset: floatingBottomOverlayInset,
              child: route,
            )
          : route,
    ),
  );
}

HostSavedAudience _savedAudience(String organizerId) => HostSavedAudience(
  organizerId: organizerId,
  audienceId: 'audience-1',
  name: 'Lapsed customers',
  status: 'active',
  definition: const HostSavedAudienceDefinition(
    join: HostSavedAudienceJoin.all,
    predicates: [
      HostSavedAudienceComputedSegment(HostAudienceSegment.lapsedRegular),
    ],
  ),
  definitionHash:
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  definitionVersion: 1,
  revision: 1,
  lastPreviewMatchCount: 12,
  lastPreviewAt: DateTime(2026, 8, 30),
  createdAt: DateTime(2026, 8, 30),
  updatedAt: DateTime(2026, 8, 30),
);

HostManualSendTask _manualSendTask(HostManualSendTaskStatus status) =>
    HostManualSendTask(
      organizerId: 'club-1',
      taskId: 'task-1',
      contactId: 'contact-1',
      displayName: 'Asha Manual',
      status: status,
      active: true,
      revision: status == HostManualSendTaskStatus.handoffOpened ? 2 : 1,
      phoneE164: '+919876543210',
      prefillText: 'Would you like to join us?',
      openCount: status == HostManualSendTaskStatus.handoffOpened ? 1 : 0,
      createdAt: DateTime(2026, 8, 30),
      updatedAt: DateTime(2026, 8, 30),
      openedAt: status == HostManualSendTaskStatus.handoffOpened
          ? DateTime(2026, 8, 30)
          : null,
      expiresAt: DateTime(2026, 9, 29),
    );

HostWhatsappThreadSummary _whatsappThread({
  required String threadId,
  required String displayName,
  required List<String> eventIds,
  required String body,
  required DateTime now,
}) => HostWhatsappThreadSummary(
  threadId: threadId,
  contactId: 'contact-$threadId',
  displayName: displayName,
  eventIds: eventIds,
  lastMessageBody: body,
  lastMessageDirection: HostWhatsappMessageDirection.inbound,
  lastMessageAt: now,
  lastInboundAt: now,
  serviceWindowExpiresAt: now.add(const Duration(hours: 24)),
  serviceWindowOpen: true,
);

HostMessagingSetup _messagingSetup(String organizerId) => HostMessagingSetup(
  organizerId: organizerId,
  providerConfigured: true,
  embeddedSignup: const HostWhatsappEmbeddedSignupConfig(
    appId: 'test-app',
    configId: 'test-config',
    graphVersion: 'v24.0',
  ),
  connection: const HostWhatsappConnection(
    connectionId: 'test-whatsapp',
    status: 'active',
    displayPhoneNumber: '+91 98765 43210',
    verifiedName: 'Test organizer',
    qualityRating: 'GREEN',
    messagingLimitTier: 'TIER_1K',
    templateSyncStatus: 'ready',
    webhookStatus: 'healthy',
    testStatus: 'verified',
    revision: 1,
  ),
  templates: const [
    HostWhatsappTemplate(
      templateId: 'test-invitation',
      name: 'event_invitation',
      language: 'en_US',
      category: 'MARKETING',
      status: 'APPROVED',
      variableNames: ['first_name', 'invite_url'],
      hasMediaHeader: false,
      buttonKinds: ['URL'],
    ),
  ],
);

HostCrmSummary _crmSummary(String organizerId) => HostCrmSummary(
  organizerId: organizerId,
  contactCount: 12,
  pastAttendeeCount: 10,
  repeatAttendeeCount: 5,
  linkedAccountCount: 8,
  importedContactCount: 4,
  whatsappOptInCount: 7,
  smsOptInCount: 0,
  truncated: false,
  inAppReadiness: HostCrmChannelReadiness.currentEventOnly,
  whatsappReadiness: HostCrmChannelReadiness.currentEventOnly,
  smsReadiness: HostCrmChannelReadiness.providerAndDltSetupRequired,
);

ChatThreadPreview _preview({
  required String uid,
  required String name,
  required List<String> eventIds,
}) {
  final match = Match(
    id: 'match-$uid',
    user1Id: uid,
    user2Id: 'host-1',
    eventIds: eventIds,
    createdAt: DateTime(2026, 7, 10),
    lastMessageAt: DateTime(2026, 7, 10, 17),
    lastMessagePreview: 'Can you help?',
    lastMessageSenderId: uid,
    conversationType: MatchConversationType.clubHostInquiry,
    clubId: 'club-1',
  );
  return ChatThreadPreview(
    match: match,
    matchId: match.id,
    otherUid: uid,
    displayName: name,
    photoUrl: null,
    previewText: match.lastMessagePreview!,
    timestamp: match.lastMessageAt!,
    unreadCount: 0,
    hasConversation: true,
    eventIds: eventIds,
  );
}
