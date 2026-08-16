// ignore_for_file: riverpod_lint/scoped_providers_should_specify_dependencies

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
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
import 'package:catch_dating_app/matches/domain/match.dart';
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

  testWidgets('renders selected-event segments and roster-backed broadcast', (
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
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Sends'), findsOneWidget);
    expect(find.byType(HostInboxScopeSelector), findsOneWidget);
    expect(find.text('BOOKED · 1'), findsOneWidget);
    expect(find.text('PROSPECTIVE · 1'), findsOneWidget);
    expect(
      find.byType(CatchOptionGroup<HostInboxAudienceSegment>),
      findsOneWidget,
    );
    expect(find.text('Message 1 booked attendee'), findsOneWidget);
    expect(find.text('Asha Guest'), findsOneWidget);
    expect(find.text('Booked · Can you help?'), findsOneWidget);
    expect(find.text('Mira Guest'), findsNothing);

    await tester.tap(find.text('PROSPECTIVE · 1'));
    await pumpFeatureUi(tester);

    expect(find.text('Message 1 prospective attendee'), findsOneWidget);
    expect(find.text('Mira Guest'), findsOneWidget);
    expect(find.text('Requested · Can you help?'), findsOneWidget);
    expect(find.text('Asha Guest'), findsNothing);
  });

  testWidgets('keeps broadcast card when roster exists without threads', (
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

    expect(find.text('Message 2 booked attendees'), findsOneWidget);
    expect(find.text('No booked attendees have written yet'), findsOneWidget);
    expect(
      find.textContaining(
        'Broadcast audience size is based on the event roster',
      ),
      findsOneWidget,
    );
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
    expect(find.text('New message'), findsOneWidget);
    expect(find.text('WhatsApp settings'), findsOneWidget);
    expect(find.byType(HostCampaignComposer), findsNothing);

    await tester.tap(find.text('New message'));
    await pumpFeatureUi(tester);

    expect(find.byType(HostCampaignComposer), findsOneWidget);
    expect(find.text('MESSAGE PAST ATTENDEES'), findsOneWidget);
    expect(find.byType(HostInboxScopeSelector), findsNothing);
    expect(find.byType(HostInboxAudienceRail), findsNothing);
  });

  testWidgets('Sends history renders Campaign and Announcement rows', (
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
    expect(find.textContaining('Announcement'), findsOneWidget);
    expect(find.textContaining('Campaign'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Doors open update')).dy,
      lessThan(tester.getTopLeft(find.text('Bring regulars back')).dy),
    );
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
    expect(find.text('General inquiry · Can you help?'), findsOneWidget);
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
      final fill = tester.widget<SliverFillRemaining>(
        find.ancestor(
          of: emptyState,
          matching: find.byType(SliverFillRemaining),
        ),
      );
      expect(fill.hasScrollBody, isTrue);
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

  testWidgets('campaigns workspace restores the routed campaign segment', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        event: null,
        previews: const [],
        participations: const [],
        now: now,
        initialWorkspace: HostMessagingWorkspace.campaigns,
        initialCampaignSegments: const {HostAudienceSegment.lapsedRegular},
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(HostMessagingWorkspaceRail), findsOneWidget);
    expect(find.byType(HostCampaignComposer), findsOneWidget);
    final selected = tester.widget<CatchChip>(
      find.byKey(const ValueKey('host-campaign-segment-lapsed_regular')),
    );
    expect(selected.selected, isTrue);
  });
}

Widget _app({
  required Event? event,
  required List<ChatThreadPreview> previews,
  required List<EventParticipation> participations,
  required DateTime now,
  HostInboxScope? initialScope,
  HostMessagingWorkspace initialWorkspace = HostMessagingWorkspace.inbox,
  Set<HostAudienceSegment> initialCampaignSegments = const {},
  List<HostSendSummary> sends = const [],
}) {
  final club = club_test.buildClub(id: event?.clubId ?? 'club-1');
  final inbox = ChatsListViewModel(
    newMatches: const [],
    conversations: previews,
    totalThreadCount: previews.length,
  );
  return ProviderScope(
    overrides: [
      uidProvider.overrideWith((ref) => Stream.value('host-1')),
      hostOperableClubsProvider('host-1').overrideWithValue(AsyncData([club])),
      watchEventsForClubProvider(
        club.id,
      ).overrideWith((ref) => Stream.value([?event])),
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
      hostCustomerSegmentCountProvider.overrideWith(
        (ref, request) async => const HostCustomerSegmentCount(
          count: 12,
          coverage: HostCustomerMatchCountCoverage.exact,
        ),
      ),
      if (event != null)
        watchEventParticipationsForEventProvider(
          event.id,
        ).overrideWith((ref) => Stream.value(participations)),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: HostInboxScreen(
        initialScope: initialScope,
        initialWorkspace: initialWorkspace,
        initialCampaignSegments: initialCampaignSegments,
        syncSelectionToRoute: false,
        now: now,
      ),
    ),
  );
}

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
