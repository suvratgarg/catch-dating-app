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
    expect(
      HostAudienceSegment.values.every(
        (segment) =>
            hostAudienceSegmentForCustomerFilter(
              hostCustomerFilterForAudienceSegment(segment),
            ) ==
            segment,
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

  test('customer filters are grouped without losing SMS readiness', () {
    final unavailable = hostCustomerFilterGroupsForSmsReadiness(
      HostCrmChannelReadiness.providerAndDltSetupRequired,
    );

    expect(unavailable.keys, HostCustomerFilterGroup.values);
    expect(unavailable[HostCustomerFilterGroup.attendance], [
      HostCustomerFilter.newToOrganizer,
      HostCustomerFilter.firstTime,
      HostCustomerFilter.repeat,
      HostCustomerFilter.regular,
      HostCustomerFilter.atRisk,
    ]);
    expect(unavailable[HostCustomerFilterGroup.reliability], [
      HostCustomerFilter.reliable,
      HostCustomerFilter.needsConfirmation,
    ]);
    expect(unavailable[HostCustomerFilterGroup.advocacy], [
      HostCustomerFilter.advocate,
      HostCustomerFilter.highImpactAdvocate,
    ]);
    expect(unavailable[HostCustomerFilterGroup.reachable], [
      HostCustomerFilter.whatsappReachable,
    ]);
    expect(
      hostCustomerFilterGroupsForSmsReadiness(
        HostCrmChannelReadiness.currentEventOnly,
      )[HostCustomerFilterGroup.reachable],
      [HostCustomerFilter.whatsappReachable, HostCustomerFilter.smsReachable],
    );
  });

  test(
    'segment count requests retain organizer, search and filter identity',
    () {
      const first = HostCustomerSegmentCountRequest(
        organizerId: 'organizer-1',
        search: 'asha',
        filter: HostCustomerFilter.atRisk,
      );
      const same = HostCustomerSegmentCountRequest(
        organizerId: 'organizer-1',
        search: 'asha',
        filter: HostCustomerFilter.atRisk,
      );
      const different = HostCustomerSegmentCountRequest(
        organizerId: 'organizer-1',
        search: 'asha',
        filter: HostCustomerFilter.reliable,
      );

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first, isNot(different));
    },
  );

  test('directory request identity includes the server sort order', () {
    const lastSeen = HostCustomersDirectoryRequest(organizerId: 'organizer-1');
    const mostAttended = HostCustomersDirectoryRequest(
      organizerId: 'organizer-1',
      sort: HostCustomerSort.mostAttended,
    );
    const sameMostAttended = HostCustomersDirectoryRequest(
      organizerId: 'organizer-1',
      sort: HostCustomerSort.mostAttended,
    );

    expect(lastSeen, isNot(mostAttended));
    expect(mostAttended, sameMostAttended);
    expect(mostAttended.hashCode, sameMostAttended.hashCode);
  });
}
