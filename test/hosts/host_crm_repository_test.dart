import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestFirebaseFunctions extends Fake implements FirebaseFunctions {
  final callables = <String, _TestHttpsCallable>{};

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) =>
      callables.putIfAbsent(name, _TestHttpsCallable.new);
}

class _TestHttpsCallable extends Fake implements HttpsCallable {
  final calls = <Object?>[];
  Object? resultData;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    calls.add(parameters);
    return _TestHttpsCallableResult<T>(resultData as T);
  }
}

class _TestHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  _TestHttpsCallableResult(this.dataValue);

  final T dataValue;

  @override
  T get data => dataValue;
}

void main() {
  test('audience query identity and copies retain the server sort order', () {
    const query = HostAudienceQuery(
      search: 'asha',
      sort: HostAudienceSort.mostAttended,
      cursor: 'page-2',
    );

    expect(
      query,
      const HostAudienceQuery(
        search: 'asha',
        sort: HostAudienceSort.mostAttended,
        cursor: 'page-2',
      ),
    );
    expect(
      query.copyWith(clearCursor: true),
      const HostAudienceQuery(
        search: 'asha',
        sort: HostAudienceSort.mostAttended,
      ),
    );
    expect(
      query.copyWith(sort: HostAudienceSort.name, clearCursor: true),
      const HostAudienceQuery(search: 'asha', sort: HostAudienceSort.name),
    );
  });

  test(
    'default contact ordering omits sort for rolling deploy compatibility',
    () async {
      final functions = _TestFirebaseFunctions();
      final callable =
          functions.httpsCallable('listOrganizerContacts')
              as _TestHttpsCallable;
      callable.resultData = _emptyAudiencePageData();
      final repository = HostCrmRepository(functions);

      await repository.listContacts('organizer-1');

      final payload = callable.calls.single as Map<Object?, Object?>;
      expect(payload['organizerId'], 'organizer-1');
      expect(payload['limit'], 30);
      expect(payload, isNot(contains('sort')));
    },
  );

  test(
    'communication plan is parsed from the server without local inference',
    () async {
      final functions = _TestFirebaseFunctions();
      final callable =
          functions.httpsCallable('resolveOrganizerCommunicationPlan')
              as _TestHttpsCallable;
      callable.resultData = {
        'organizerId': 'organizer-1',
        'intent': 'individualConversation',
        'capabilityVersion': 1,
        'resolvedAtMillis': 1700000000000,
        'recipients': [
          {
            'contactId': 'contact-1',
            'displayName': 'Asha',
            'outcome': 'byHand',
            'recommendedRouteId': 'personalWhatsappHandoff',
            'routes': [
              {
                'routeId': 'catchChat',
                'executionMode': 'managedDelivery',
                'availability': 'unavailable',
                'blocker': 'catchAccountRequired',
              },
              {
                'routeId': 'personalWhatsappHandoff',
                'executionMode': 'externalHandoff',
                'availability': 'available',
                'blocker': null,
              },
            ],
          },
        ],
      };
      final repository = HostCrmRepository(functions);

      final plan = await repository.resolveIndividualCommunicationPlan(
        organizerId: 'organizer-1',
        contactId: 'contact-1',
      );

      expect(callable.calls.single, {
        'organizerId': 'organizer-1',
        'intent': 'individualConversation',
        'target': {'kind': 'contact', 'contactId': 'contact-1'},
      });
      expect(plan.singleRecipient.outcome, HostCommunicationOutcome.byHand);
      expect(
        plan.singleRecipient.route(HostCommunicationRouteId.catchChat).blocker,
        HostCommunicationRouteBlocker.catchAccountRequired,
      );
    },
  );

  test('communication plan parser rejects contradictory route state', () {
    expect(
      () => HostCommunicationPlan.fromCallableData({
        'organizerId': 'organizer-1',
        'intent': 'individualConversation',
        'capabilityVersion': 1,
        'resolvedAtMillis': 1700000000000,
        'recipients': [
          {
            'contactId': 'contact-1',
            'displayName': 'Asha',
            'outcome': 'inCatch',
            'recommendedRouteId': 'catchChat',
            'routes': [
              {
                'routeId': 'catchChat',
                'executionMode': 'managedDelivery',
                'availability': 'available',
                'blocker': 'identityAmbiguous',
              },
              {
                'routeId': 'personalWhatsappHandoff',
                'executionMode': 'externalHandoff',
                'availability': 'available',
                'blocker': null,
              },
            ],
          },
        ],
      }),
      throwsFormatException,
    );
  });

  test('non-default contact ordering remains explicit', () async {
    final functions = _TestFirebaseFunctions();
    final callable =
        functions.httpsCallable('listOrganizerContacts') as _TestHttpsCallable;
    callable.resultData = _emptyAudiencePageData();
    final repository = HostCrmRepository(functions);

    await repository.listContacts(
      'organizer-1',
      query: const HostAudienceQuery(sort: HostAudienceSort.mostAttended),
    );

    final payload = callable.calls.single as Map<Object?, Object?>;
    expect(payload['sort'], 'mostAttended');
  });

  test(
    'manual contact creation sends identity details and initial note',
    () async {
      final functions = _TestFirebaseFunctions();
      final callable =
          functions.httpsCallable('createOrganizerContact')
              as _TestHttpsCallable;
      callable.resultData = {
        'organizerId': 'organizer-1',
        'contactId': 'contact-1',
        'displayName': 'Asha Rao',
        'revision': 1,
      };
      final repository = HostCrmRepository(functions);

      await repository.createContact(
        organizerId: 'organizer-1',
        displayName: 'Asha Rao',
        phoneE164: '+919876543210',
        email: 'asha@example.com',
        initialNote: 'Prefers the Friday event.',
      );

      expect(callable.calls.single, {
        'organizerId': 'organizer-1',
        'displayName': 'Asha Rao',
        'phoneE164': '+919876543210',
        'email': 'asha@example.com',
        'initialNote': 'Prefers the Friday event.',
      });
    },
  );

  test(
    'manual contact mutation explicitly serializes endpoint clears',
    () async {
      final functions = _TestFirebaseFunctions();
      final callable =
          functions.httpsCallable('mutateOrganizerContact')
              as _TestHttpsCallable;
      callable.resultData = null;
      final repository = HostCrmRepository(functions);

      await repository.mutateContact(
        organizerId: 'organizer-1',
        contactId: 'contact-1',
        expectedRevision: 3,
        updatePhoneE164: true,
        updateEmail: true,
      );

      expect(callable.calls.single, {
        'organizerId': 'organizer-1',
        'contactId': 'contact-1',
        'expectedRevision': 3,
        'phoneE164': null,
        'email': null,
      });
    },
  );

  test('parses privacy-bounded CRM counts and delivery readiness', () {
    final summary = HostCrmSummary.fromCallableData({
      'organizerId': 'organizer-1',
      'contactCount': 20,
      'pastAttendeeCount': 12,
      'repeatAttendeeCount': 3,
      'linkedAccountCount': 8,
      'importedContactCount': 5,
      'whatsappOptInCount': 6,
      'smsOptInCount': 4,
      'truncated': false,
      'readiness': {
        'inApp': 'currentEventOnly',
        'whatsapp': 'providerSetupRequired',
        'sms': 'providerAndDltSetupRequired',
      },
    });

    expect(summary.pastAttendeeCount, 12);
    expect(summary.repeatAttendeeCount, 3);
    expect(summary.whatsappOptInCount, 6);
    expect(
      summary.smsReadiness,
      HostCrmChannelReadiness.providerAndDltSetupRequired,
    );
  });

  test('rejects a summary that omits a required readiness field', () {
    expect(
      () => HostCrmSummary.fromCallableData({
        'organizerId': 'organizer-1',
        'contactCount': 0,
        'pastAttendeeCount': 0,
        'repeatAttendeeCount': 0,
        'linkedAccountCount': 0,
        'importedContactCount': 0,
        'whatsappOptInCount': 0,
        'smsOptInCount': 0,
        'truncated': false,
        'readiness': const <String, Object?>{},
      }),
      throwsFormatException,
    );
  });

  test('parses event-relative roster labels without private profile data', () {
    final insights = HostEventRosterInsights.fromCallableData({
      'eventId': 'event-1',
      'organizerId': 'organizer-1',
      'cutoffAtMillis': 1786500000000,
      'sourceCoverage': 'exact',
      'spendCoverage': 'catchPaymentsOnly',
      'rows': [
        {
          'attendeeId': 'attendee-1',
          'contactId': 'contact-1',
          'availability': 'ready',
          'signals': ['returning', 'top_catch_spender'],
          'priorAttendedEventCount': 3,
          'priorExpectedEventCount': 4,
          'priorNoShowCount': 1,
          'lastAttendedAtMillis': 1780000000000,
          'attendanceRate': 0.75,
          'catchSpend': [
            {'currency': 'INR', 'amountMinor': 600000, 'paidOrderCount': 3},
          ],
        },
      ],
      'computedAtMillis': 1786500001000,
    });

    final row = insights.rows.single;
    expect(row.signals, contains(HostRosterInsightSignal.returning));
    expect(row.signals, contains(HostRosterInsightSignal.topCatchSpender));
    expect(row.catchSpend.single.currency, 'INR');
    expect(row.catchSpend.single.amountMinor, 600000);
    expect(insights.byAttendeeId['attendee-1'], same(row));
  });

  test(
    'parses audience contacts with explainable segments and permissions',
    () {
      final page = HostAudiencePage.fromCallableData({
        'organizerId': 'organizer-1',
        'contacts': [
          {
            'contactId': 'contact-1',
            'displayName': 'Asha Shah',
            'phoneE164': '+919876543210',
            'email': null,
            'identityState': 'verified',
            'identityConfidence': 'verifiedPhone',
            'ambiguousCandidateCount': 0,
            'attendedEventCount': 4,
            'expectedEventCount': 5,
            'lastAttendedAtMillis': 1786460400000,
            'segmentIds': [
              'repeat_attendee',
              'reliable_attendee',
              'needs_confirmation',
              'whatsapp_reachable',
              'sms_reachable',
            ],
            'whatsappStatus': 'optedIn',
            'whatsappAdminSuppressed': false,
            'smsStatus': 'unknown',
            'sourceCoverage': 'exact',
            'revision': 3,
          },
        ],
        'nextCursor': 'contact-1',
        'matchCount': 37,
        'matchCountCoverage': 'atLeast',
        'sourceCoverage': 'exact',
        'projectionVersion': 1,
      });

      final contact = page.contacts.single;
      expect(contact.displayName, 'Asha Shah');
      expect(contact.identityState, HostAudienceIdentityState.verified);
      expect(contact.whatsappStatus, HostAudiencePermissionStatus.optedIn);
      expect(contact.whatsappAdminSuppressed, isFalse);
      expect(contact.segments, contains(HostAudienceSegment.repeatAttendee));
      expect(contact.segments, contains(HostAudienceSegment.whatsappReachable));
      expect(contact.segments, contains(HostAudienceSegment.needsConfirmation));
      expect(contact.segments, contains(HostAudienceSegment.smsReachable));
      expect(page.nextCursor, 'contact-1');
      expect(page.matchCount, 37);
      expect(page.matchCountCoverage, HostAudienceMatchCountCoverage.atLeast);
    },
  );

  test('parses WhatsApp setup without exposing provider credentials', () {
    final setup = HostMessagingSetup.fromCallableData({
      'organizerId': 'organizer-1',
      'providerConfigured': true,
      'embeddedSignup': {
        'appId': 'app-1',
        'configId': 'config-1',
        'graphVersion': 'v24.0',
      },
      'connection': {
        'connectionId': 'connection-1',
        'status': 'active',
        'displayPhoneNumber': '+91 98765 43210',
        'verifiedName': 'Courtyard Socials',
        'qualityRating': 'GREEN',
        'messagingLimitTier': 'TIER_1K',
        'templateSyncStatus': 'ready',
        'webhookStatus': 'healthy',
        'testStatus': 'verified',
        'revision': 5,
      },
      'templates': [
        {
          'templateId': 'template-1',
          'name': 'event_invitation',
          'language': 'en_US',
          'category': 'MARKETING',
          'status': 'APPROVED',
          'variableNames': ['first_name', 'invite_url'],
          'hasMediaHeader': true,
          'buttonKinds': ['URL'],
        },
      ],
    });

    expect(setup.embeddedSignup.isConfigured, isTrue);
    expect(setup.connection?.isActive, isTrue);
    expect(setup.approvedTemplates.single.variableNames, [
      'first_name',
      'invite_url',
    ]);
    expect(setup.campaignReadiness, HostWhatsappCampaignReadiness.ready);
    expect(setup.canComposeCampaign, isTrue);
  });

  test('WhatsApp campaign readiness fails closed at each setup gate', () {
    const signup = HostWhatsappEmbeddedSignupConfig(
      appId: 'app-1',
      configId: 'config-1',
      graphVersion: 'v24.0',
    );
    const activeConnection = HostWhatsappConnection(
      connectionId: 'connection-1',
      status: 'active',
      displayPhoneNumber: '+91 98765 43210',
      verifiedName: 'Courtyard Socials',
      qualityRating: 'GREEN',
      messagingLimitTier: 'TIER_1K',
      templateSyncStatus: 'ready',
      webhookStatus: 'healthy',
      testStatus: 'verified',
      revision: 1,
    );

    HostMessagingSetup setup({
      bool configured = true,
      HostWhatsappConnection? connection = activeConnection,
      List<HostWhatsappTemplate> templates = const [
        HostWhatsappTemplate(
          templateId: 'template-1',
          name: 'event_invitation',
          language: 'en_US',
          category: 'MARKETING',
          status: 'APPROVED',
          variableNames: [],
          hasMediaHeader: false,
          buttonKinds: [],
        ),
      ],
    }) => HostMessagingSetup(
      organizerId: 'organizer-1',
      providerConfigured: configured,
      embeddedSignup: signup,
      connection: connection,
      templates: templates,
    );

    expect(
      setup(configured: false).campaignReadiness,
      HostWhatsappCampaignReadiness.providerUnavailable,
    );
    expect(
      setup(connection: null).campaignReadiness,
      HostWhatsappCampaignReadiness.senderNotConnected,
    );
    expect(
      setup(
        connection: const HostWhatsappConnection(
          connectionId: 'connection-1',
          status: 'testing',
          displayPhoneNumber: '+91 98765 43210',
          verifiedName: 'Courtyard Socials',
          qualityRating: 'GREEN',
          messagingLimitTier: 'TIER_1K',
          templateSyncStatus: 'ready',
          webhookStatus: 'healthy',
          testStatus: 'pending',
          revision: 1,
        ),
      ).campaignReadiness,
      HostWhatsappCampaignReadiness.senderNeedsAttention,
    );
    expect(
      setup(templates: const []).campaignReadiness,
      HostWhatsappCampaignReadiness.approvedTemplateRequired,
    );
  });

  test('parses contact detail without exposing private runtime answers', () {
    final data = <String, Object?>{
      'organizerId': 'organizer-1',
      'contactId': 'contact-1',
      'displayName': 'Asha',
      'sourceDisplayName': 'Asha Rao',
      'displayNameOverride': 'Asha',
      'phoneE164': '+919876543210',
      'email': null,
      'linkedAccount': true,
      'identityState': 'verified',
      'identityConfidence': 'verified',
      'contactDetailsEditable': false,
      'ambiguousCandidateContactIds': <String>[],
      'whatsappAdminSuppressed': true,
      'traits': {
        'expectedEventCount': 4,
        'attendedEventCount': 3,
        'cancelledEventCount': 0,
        'noShowCount': 1,
        'importedEventCount': 1,
        'attendanceRate': 0.75,
        'segmentIds': ['repeat_attendee'],
        'whatsappStatus': 'optedIn',
        'smsStatus': 'unknown',
        'sourceCoverage': 'exact',
      },
      'revenue': {
        'coverage': 'exact',
        'amounts': [
          {
            'currency': 'INR',
            'amountMinor': 450000,
            'factCount': 3,
            'sources': [
              {'source': 'catchPayment', 'amountMinor': 450000, 'factCount': 3},
            ],
          },
        ],
      },
      'events': [
        {
          'eventId': 'event-1',
          'displayName': 'Social run',
          'eventOriginMode': 'externalCompanion',
          'eventProvider': 'eventbrite',
          'source': 'hostImport',
          'status': 'checkedIn',
          'checkedIn': true,
          'eventStartAtMillis': 1700000000000,
          'revenues': [
            {
              'currency': 'INR',
              'amountMinor': 150000,
              'source': 'hostImport',
              'factCount': 1,
              'allocation': 'perAttendee',
            },
          ],
        },
      ],
      'eventsTruncated': false,
      'activeMerges': [
        {
          'mergeReceiptId': 'receipt-1',
          'sourceContactId': 'contact-2',
          'sourceDisplayName': 'Asha R.',
          'evidence': ['sameVerifiedPhone', 'managerConfirmed'],
          'conflicts': <String>[],
          'movedFactCount': 4,
          'mergedAtMillis': 1700000001000,
        },
      ],
      'revision': 7,
    };
    final detail = HostAudienceContactDetail.fromCallableData(data);

    expect(detail.displayName, 'Asha');
    expect(detail.contactDetailsEditable, isFalse);
    expect(detail.whatsappAdminSuppressed, isTrue);
    expect(detail.traits.whatsappStatus, HostAudiencePermissionStatus.optedIn);
    expect(detail.traits.attendanceRate, 0.75);
    expect(detail.revenue.amounts.single.amountMinor, 450000);
    expect(detail.events.single.checkedIn, isTrue);
    expect(detail.activeMerges.single.sourceContactId, 'contact-2');
    expect(detail.activeMerges.single.movedFactCount, 4);
  });

  test('parses evidence-bearing and dismissed merge candidates', () {
    Map<String, Object?> candidate({required bool dismissed}) => {
      'candidateId': 'ocmc_${List.filled(48, 'a').join()}',
      'contacts': [
        {
          'contactId': 'contact-1',
          'displayName': 'Asha Rao',
          'phoneE164': '+919876543210',
          'email': null,
          'linkedAccount': true,
          'primarySource': 'catchBooking',
          'revision': 2,
        },
        {
          'contactId': 'contact-2',
          'displayName': 'Asha R.',
          'phoneE164': '+919876543210',
          'email': null,
          'linkedAccount': false,
          'primarySource': 'hostImport',
          'revision': 3,
        },
      ],
      'matchKinds': ['sameVerifiedPhone'],
      'confidence': 'verified',
      'sourceKinds': ['catchBooking', 'hostImport'],
      'sharedEventIds': ['event-1'],
      'sharedEventCount': 1,
      'updatedAtMillis': 1700000000000,
      'decisionState': dismissed ? 'differentPeople' : 'none',
      'decisionRevision': dismissed ? 4 : null,
      'canReopen': dismissed,
    };
    final page = HostContactMergeCandidatePage.fromCallableData({
      'organizerId': 'organizer-1',
      'candidates': [candidate(dismissed: false)],
      'dismissedCandidates': [candidate(dismissed: true)],
      'nextCursor': null,
      'truncated': false,
    });

    expect(page.candidates.single.matchKinds, {
      HostContactMergeMatchKind.sameVerifiedPhone,
    });
    expect(page.candidates.single.sharedEventCount, 1);
    expect(page.dismissedCandidates.single.canReopen, isTrue);
  });

  test('parses campaign blockers and aggregate delivery counts', () {
    final campaign = HostCampaign.fromCallableData({
      'organizerId': 'organizer-1',
      'campaignId': 'campaign-1',
      'status': 'previewed',
      'revision': 2,
      'audienceCounts': {'selected': 20, 'eligible': 14, 'suppressed': 6},
      'deliveryCounts': {'accepted': 10, 'delivered': 8, 'failed': 2},
      'senderStatus': 'active',
      'templateStatus': 'APPROVED',
      'canApprove': false,
      'canDispatch': false,
      'blockers': ['audience_changed'],
    });

    expect(campaign.audienceCounts['eligible'], 14);
    expect(campaign.deliveryCounts['delivered'], 8);
    expect(campaign.blockers, {'audience_changed'});
  });

  test('parses mixed reverse-chronological Sends rows', () {
    final page = HostSendsPage.fromCallableData({
      'organizerId': 'organizer-1',
      'sends': <Object?>[
        {
          'kind': 'announcement',
          'broadcastId': 'broadcast-1',
          'eventId': 'event-1',
          'eventName': 'Friday run',
          'audience': 'booked',
          'recipientCount': 18,
          'sentAtMillis': 3000,
          'partialFailure': true,
          'activityAtMillis': 3000,
        },
        {
          'kind': 'campaign',
          'campaignId': 'campaign-1',
          'name': 'Regulars invite',
          'status': 'scheduled',
          'segmentIds': <Object?>['regular'],
          'templateId': 'template-1',
          'templateName': 'Event invite',
          'audienceCounts': {'total': 12, 'reachable': 10},
          'deliveryCounts': {'pending': 10},
          'scheduledAtMillis': 5000,
          'dispatchedAtMillis': null,
          'activityAtMillis': 2000,
        },
        {
          'kind': 'followerUpdate',
          'postId': 'post-1',
          'eventId': null,
          'audience': 'followers',
          'status': 'active',
          'deliveryStatus': 'completed',
          'recipientCount': 10,
          'excludedCount': 1,
          'activityAvailableCount': 9,
          'pushAttemptedCount': 8,
          'pushAcceptedCount': 8,
          'pushFailedCount': 0,
          'pushUnknownCount': 0,
          'createdAtMillis': 1000,
          'activityAtMillis': 1000,
        },
      ],
      'nextCursor': 'next-page',
    });

    expect(page.sends.first, isA<HostAnnouncementSendSummary>());
    expect(
      (page.sends.first as HostAnnouncementSendSummary).partialFailure,
      isTrue,
    );
    expect(page.sends[1], isA<HostCampaignSendSummary>());
    expect((page.sends[1] as HostCampaignSendSummary).scheduledAt, isNotNull);
    expect(page.sends.last, isA<HostFollowerUpdateSendSummary>());
    final followerUpdate = page.sends.last as HostFollowerUpdateSendSummary;
    expect(followerUpdate.postId, 'post-1');
    expect(followerUpdate.audience, 'followers');
    expect(followerUpdate.eventId, isNull);
    expect(page.nextCursor, 'next-page');
  });

  test('parses WhatsApp channel facets and service-window state', () {
    final page = HostWhatsappThreadPage.fromCallableData({
      'organizerId': 'organizer-1',
      'threads': [
        {
          'threadId': 'owt_${List.filled(48, 'a').join()}',
          'contactId': 'contact-1',
          'displayName': 'Asha Rao',
          'eventIds': ['event-1'],
          'lastMessageBody': 'Where is the entrance?',
          'lastMessageDirection': 'inbound',
          'lastMessageAtMillis': 1700000000000,
          'lastInboundAtMillis': 1700000000000,
          'serviceWindowExpiresAtMillis': 1700086400000,
          'serviceWindowOpen': true,
        },
      ],
      'nextCursor': null,
    });
    final thread = page.threads.single;
    expect(thread.eventIds, ['event-1']);
    expect(thread.lastMessageDirection, HostWhatsappMessageDirection.inbound);
    expect(thread.serviceWindowOpen, isTrue);

    final detail = HostWhatsappThreadDetail.fromCallableData({
      'organizerId': 'organizer-1',
      'threadId': thread.threadId,
      'contactId': thread.contactId,
      'displayName': thread.displayName,
      'lastInboundAtMillis': 1700000000000,
      'serviceWindowExpiresAtMillis': 1700086400000,
      'serviceWindowOpen': false,
      'messages': [
        {
          'messageId': 'owm_${List.filled(48, 'b').join()}',
          'direction': 'inbound',
          'body': 'Where is the entrance?',
          'occurredAtMillis': 1700000000000,
        },
      ],
      'messagesTruncated': false,
    });
    expect(detail.messages.single.body, 'Where is the entrance?');
    expect(detail.serviceWindowOpen, isFalse);
  });
}

Map<String, Object?> _emptyAudiencePageData() => {
  'organizerId': 'organizer-1',
  'contacts': const <Object?>[],
  'nextCursor': null,
  'matchCount': 0,
  'matchCountCoverage': 'exact',
  'sourceCoverage': 'exact',
  'projectionVersion': 1,
};
