import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('customer filters map to explainable organizer segments', () {
    expect(
      HostCustomerFilter.atRisk.segment,
      HostAudienceSegment.lapsedRegular,
    );
    expect(
      HostCustomerFilter.needsConfirmation.segment,
      HostAudienceSegment.needsConfirmation,
    );
    expect(HostCustomerFilter.attended.segment, isNull);
  });

  test('conversation requires an unambiguous linked customer identity', () {
    expect(
      customerConversationAvailability(_detail()),
      HostCustomerConversationAvailability.ready,
    );
    expect(
      customerConversationAvailability(_detail(linked: false)),
      HostCustomerConversationAvailability.unlinked,
    );
    expect(
      customerConversationAvailability(
        _detail(identityState: HostAudienceIdentityState.ambiguous),
      ),
      HostCustomerConversationAvailability.ambiguous,
    );
  });
}

HostAudienceContactDetail _detail({
  bool linked = true,
  HostAudienceIdentityState identityState = HostAudienceIdentityState.verified,
}) => HostAudienceContactDetail(
  organizerId: 'organizer-1',
  contactId: 'contact-1',
  displayName: 'Asha',
  sourceDisplayName: 'Asha',
  displayNameOverride: null,
  phoneE164: null,
  email: null,
  linkedAccount: linked,
  identityState: identityState,
  identityConfidence: 'verified',
  ambiguousCandidateCount: identityState == HostAudienceIdentityState.ambiguous
      ? 2
      : 0,
  whatsappAdminSuppressed: false,
  traits: const HostCustomerTraits(
    expectedEventCount: 0,
    attendedEventCount: 0,
    cancelledEventCount: 0,
    noShowCount: 0,
    importedEventCount: 0,
    attendanceRate: null,
    segments: {},
    sourceCoverage: HostAudienceSourceCoverage.exact,
  ),
  revenue: const HostCustomerRevenue(
    coverage: HostCustomerRevenueCoverage.exact,
    amounts: [],
  ),
  events: const [],
  eventsTruncated: false,
  revision: 1,
);
