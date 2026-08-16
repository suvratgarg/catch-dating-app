import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('customer filters map to explainable organizer segments', () {
    expect(HostCustomerFilter.atRisk.tag, HostCustomerTag.atRisk);
    expect(
      HostCustomerFilter.needsConfirmation.tag,
      HostCustomerTag.needsConfirmation,
    );
    expect(
      hostAudienceSegmentForCustomerFilter(HostCustomerFilter.reliable),
      HostAudienceSegment.reliableAttendee,
    );
    expect(
      hostAudienceSegmentForCustomerFilter(
        HostCustomerFilter.highImpactAdvocate,
      ),
      HostAudienceSegment.highImpactAdvocate,
    );
    expect(
      hostAudienceSegmentForCustomerFilter(
        HostCustomerFilter.whatsappReachable,
      ),
      HostAudienceSegment.whatsappReachable,
    );
    expect(
      HostCustomerFilter.values
          .where((filter) => filter != HostCustomerFilter.all)
          .every(
            (filter) => hostAudienceSegmentForCustomerFilter(filter) != null,
          ),
      isTrue,
    );
  });

  test('customer SMS filters render only when SMS is available', () {
    expect(
      hostCustomerFiltersForSmsReadiness(null),
      isNot(contains(HostCustomerFilter.smsReachable)),
    );
    expect(
      hostCustomerFiltersForSmsReadiness(
        HostCrmChannelReadiness.providerAndDltSetupRequired,
      ),
      isNot(contains(HostCustomerFilter.smsReachable)),
    );
    expect(
      hostCustomerFiltersForSmsReadiness(
        HostCrmChannelReadiness.currentEventOnly,
      ),
      contains(HostCustomerFilter.smsReachable),
    );
  });

  test('conversation requires an unambiguous linked customer identity', () {
    expect(
      customerConversationAvailability(
        linkedAccount: true,
        identityVerified: true,
        ambiguousCandidateCount: 0,
      ),
      HostCustomerConversationAvailability.ready,
    );
    expect(
      customerConversationAvailability(
        linkedAccount: false,
        identityVerified: true,
        ambiguousCandidateCount: 0,
      ),
      HostCustomerConversationAvailability.unlinked,
    );
    expect(
      customerConversationAvailability(
        linkedAccount: true,
        identityVerified: false,
        ambiguousCandidateCount: 2,
      ),
      HostCustomerConversationAvailability.ambiguous,
    );
  });
}
