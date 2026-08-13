import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
  });

  test('parses contact detail without exposing private runtime answers', () {
    final detail = HostAudienceContactDetail.fromCallableData({
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
          {'currency': 'INR', 'amountMinor': 450000, 'paidOrderCount': 3},
        ],
      },
      'events': [
        {
          'eventId': 'event-1',
          'displayName': 'Asha Rao',
          'source': 'hostImport',
          'status': 'checkedIn',
          'checkedIn': true,
          'eventStartAtMillis': 1700000000000,
        },
      ],
      'eventsTruncated': false,
      'revision': 7,
    });

    expect(detail.displayName, 'Asha');
    expect(detail.whatsappAdminSuppressed, isTrue);
    expect(detail.traits.attendanceRate, 0.75);
    expect(detail.revenue.amounts.single.amountMinor, 450000);
    expect(detail.events.single.checkedIn, isTrue);
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
}
