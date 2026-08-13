import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('customer filters map to explainable organizer segments', () {
    expect(HostCustomerFilter.atRisk.tag, HostCustomerTag.atRisk);
    expect(
      HostCustomerFilter.needsConfirmation.tag,
      HostCustomerTag.needsConfirmation,
    );
    expect(HostCustomerFilter.attended.tag, isNull);
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
