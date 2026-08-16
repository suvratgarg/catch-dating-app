import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
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
}
