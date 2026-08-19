import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('campaign segments stay inside the sender-backed segment set', () {
    expect(
      hostCampaignEligibleSegmentsForSmsReadiness(null),
      isNot(contains(HostAudienceSegment.smsReachable)),
    );
    final unavailable = hostCampaignEligibleSegmentsForSmsReadiness(
      HostCrmChannelReadiness.providerAndDltSetupRequired,
    );

    expect(unavailable, contains(HostAudienceSegment.whatsappReachable));
    expect(unavailable, isNot(contains(HostAudienceSegment.newToOrganizer)));
    expect(unavailable, isNot(contains(HostAudienceSegment.needsConfirmation)));
    expect(unavailable, isNot(contains(HostAudienceSegment.smsReachable)));
    expect(
      hostCampaignEligibleSegmentsForSmsReadiness(
        HostCrmChannelReadiness.currentEventOnly,
      ),
      contains(HostAudienceSegment.smsReachable),
    );
  });

  test('campaign bridge requires an eligible segment and active sender', () {
    expect(
      hostCampaignBridgeBlocker(
        segment: HostAudienceSegment.lapsedRegular,
        smsReadiness: HostCrmChannelReadiness.providerAndDltSetupRequired,
        messagingSetup: _messagingSetup(),
        audienceCoverageComplete: true,
      ),
      isNull,
    );
    expect(
      hostCampaignBridgeBlocker(
        segment: HostAudienceSegment.newToOrganizer,
        smsReadiness: HostCrmChannelReadiness.currentEventOnly,
        messagingSetup: _messagingSetup(),
        audienceCoverageComplete: true,
      ),
      HostCampaignBlockers.noReachableRecipients,
    );
    expect(
      hostCampaignBridgeBlocker(
        segment: HostAudienceSegment.lapsedRegular,
        smsReadiness: HostCrmChannelReadiness.currentEventOnly,
        messagingSetup: _messagingSetup(providerConfigured: false),
        audienceCoverageComplete: true,
      ),
      HostCampaignBlockers.providerSetupRequired,
    );
    expect(
      hostCampaignBridgeBlocker(
        segment: HostAudienceSegment.lapsedRegular,
        smsReadiness: HostCrmChannelReadiness.currentEventOnly,
        messagingSetup: _messagingSetup(connectionStatus: 'pending'),
        audienceCoverageComplete: true,
      ),
      HostCampaignBlockers.senderInactive,
    );
  });
}

HostMessagingSetup _messagingSetup({
  bool providerConfigured = true,
  String connectionStatus = 'active',
}) => HostMessagingSetup(
  organizerId: 'organizer-1',
  providerConfigured: providerConfigured,
  embeddedSignup: const HostWhatsappEmbeddedSignupConfig(
    appId: 'app-id',
    configId: 'config-id',
    graphVersion: 'v24.0',
  ),
  connection: HostWhatsappConnection(
    connectionId: 'connection-1',
    status: connectionStatus,
    displayPhoneNumber: '+91 98765 43210',
    verifiedName: 'Catch Social',
    qualityRating: 'GREEN',
    messagingLimitTier: 'TIER_1K',
    templateSyncStatus: 'ready',
    webhookStatus: 'healthy',
    testStatus: 'verified',
    revision: 1,
  ),
  templates: const [],
);
