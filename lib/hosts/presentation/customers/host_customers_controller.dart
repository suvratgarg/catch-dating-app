import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_customers_controller.g.dart';

@riverpod
class HostCustomersDirectoryController
    extends _$HostCustomersDirectoryController {
  @override
  Future<HostCustomersDirectoryState> build(
    HostCustomersDirectoryRequest request,
  ) async {
    final page = await ref
        .read(hostCrmRepositoryProvider)
        .listContacts(request.organizerId, query: _queryFor(request));
    return _directoryStateFromPage(page);
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.canLoadMore) return;
    state = AsyncData(
      current.copyWith(loadingMore: true, clearLoadMoreError: true),
    );
    try {
      final page = await ref
          .read(hostCrmRepositoryProvider)
          .listContacts(
            request.organizerId,
            query: _queryFor(request, cursor: current.nextCursor),
          );
      final byId = <String, HostCustomerDirectoryContact>{
        for (final contact in current.contacts) contact.contactId: contact,
        for (final contact in page.contacts)
          contact.contactId: _directoryContact(contact),
      };
      state = AsyncData(
        HostCustomersDirectoryState(
          contacts: List.unmodifiable(byId.values),
          nextCursor: page.nextCursor,
          matchCount:
              current.matchCountCoverage ==
                  HostCustomerMatchCountCoverage.atLeast
              ? byId.length > current.matchCount
                    ? byId.length
                    : current.matchCount
              : current.matchCount,
          matchCountCoverage: current.matchCountCoverage,
          sourceCoverage: _directoryCoverage(page.sourceCoverage),
          projectionVersion: page.projectionVersion,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(loadingMore: false, loadMoreError: error),
      );
    }
  }
}

@riverpod
Future<HostCustomerSegmentCount> hostCustomerSegmentCount(
  Ref ref,
  HostCustomerSegmentCountRequest request,
) async {
  final page = await ref
      .read(hostCrmRepositoryProvider)
      .listContacts(
        request.organizerId,
        query: HostAudienceQuery(
          search: request.search,
          segment: hostAudienceSegmentForCustomerFilter(request.filter),
        ),
        limit: 1,
      );
  return HostCustomerSegmentCount(
    count: page.matchCount,
    coverage: _matchCountCoverage(page.matchCountCoverage),
  );
}

HostAudienceQuery _queryFor(
  HostCustomersDirectoryRequest request, {
  String? cursor,
}) => HostAudienceQuery(
  search: request.search,
  segment: hostAudienceSegmentForCustomerFilter(request.filter),
  cursor: cursor,
);

HostAudienceSegment? hostAudienceSegmentForCustomerFilter(
  HostCustomerFilter filter,
) => switch (filter.tag) {
  null => null,
  HostCustomerTag.newToOrganizer => HostAudienceSegment.newToOrganizer,
  HostCustomerTag.firstTime => HostAudienceSegment.firstTimeAttendee,
  HostCustomerTag.repeat => HostAudienceSegment.repeatAttendee,
  HostCustomerTag.regular => HostAudienceSegment.regular,
  HostCustomerTag.atRisk => HostAudienceSegment.lapsedRegular,
  HostCustomerTag.reliable => HostAudienceSegment.reliableAttendee,
  HostCustomerTag.needsConfirmation => HostAudienceSegment.needsConfirmation,
  HostCustomerTag.advocate => HostAudienceSegment.advocate,
  HostCustomerTag.highImpactAdvocate => HostAudienceSegment.highImpactAdvocate,
  HostCustomerTag.whatsappReachable => HostAudienceSegment.whatsappReachable,
  HostCustomerTag.smsReachable => HostAudienceSegment.smsReachable,
};

HostCustomerFilter hostCustomerFilterForAudienceSegment(
  HostAudienceSegment segment,
) => switch (segment) {
  HostAudienceSegment.newToOrganizer => HostCustomerFilter.newToOrganizer,
  HostAudienceSegment.firstTimeAttendee => HostCustomerFilter.firstTime,
  HostAudienceSegment.repeatAttendee => HostCustomerFilter.repeat,
  HostAudienceSegment.regular => HostCustomerFilter.regular,
  HostAudienceSegment.lapsedRegular => HostCustomerFilter.atRisk,
  HostAudienceSegment.reliableAttendee => HostCustomerFilter.reliable,
  HostAudienceSegment.needsConfirmation => HostCustomerFilter.needsConfirmation,
  HostAudienceSegment.advocate => HostCustomerFilter.advocate,
  HostAudienceSegment.highImpactAdvocate =>
    HostCustomerFilter.highImpactAdvocate,
  HostAudienceSegment.whatsappReachable => HostCustomerFilter.whatsappReachable,
  HostAudienceSegment.smsReachable => HostCustomerFilter.smsReachable,
};

bool hostCrmSmsReachableAvailable(HostCrmChannelReadiness? readiness) =>
    readiness == HostCrmChannelReadiness.currentEventOnly;

List<HostCustomerFilter> hostCustomerFiltersForSmsReadiness(
  HostCrmChannelReadiness? smsReadiness,
) => [
  for (final filter in HostCustomerFilter.values)
    if (filter != HostCustomerFilter.smsReachable ||
        hostCrmSmsReachableAvailable(smsReadiness))
      filter,
];

Map<HostCustomerFilterGroup, List<HostCustomerFilter>>
hostCustomerFilterGroupsForSmsReadiness(HostCrmChannelReadiness? smsReadiness) {
  final filters = hostCustomerFiltersForSmsReadiness(smsReadiness).toSet();
  return {
    HostCustomerFilterGroup.attendance: [
      HostCustomerFilter.newToOrganizer,
      HostCustomerFilter.firstTime,
      HostCustomerFilter.repeat,
      HostCustomerFilter.regular,
      HostCustomerFilter.atRisk,
    ].where(filters.contains).toList(growable: false),
    HostCustomerFilterGroup.reliability: [
      HostCustomerFilter.reliable,
      HostCustomerFilter.needsConfirmation,
    ].where(filters.contains).toList(growable: false),
    HostCustomerFilterGroup.advocacy: [
      HostCustomerFilter.advocate,
      HostCustomerFilter.highImpactAdvocate,
    ].where(filters.contains).toList(growable: false),
    HostCustomerFilterGroup.reachable: [
      HostCustomerFilter.whatsappReachable,
      HostCustomerFilter.smsReachable,
    ].where(filters.contains).toList(growable: false),
  };
}

HostCustomersDirectoryState _directoryStateFromPage(HostAudiencePage page) =>
    HostCustomersDirectoryState.fromPageData(
      contacts: page.contacts.map(_directoryContact),
      nextCursor: page.nextCursor,
      matchCount: page.matchCount,
      matchCountCoverage: _matchCountCoverage(page.matchCountCoverage),
      sourceCoverage: _directoryCoverage(page.sourceCoverage),
      projectionVersion: page.projectionVersion,
    );

HostCustomerMatchCountCoverage _matchCountCoverage(
  HostAudienceMatchCountCoverage coverage,
) => switch (coverage) {
  HostAudienceMatchCountCoverage.exact => HostCustomerMatchCountCoverage.exact,
  HostAudienceMatchCountCoverage.atLeast =>
    HostCustomerMatchCountCoverage.atLeast,
};

HostCustomerDirectoryContact _directoryContact(HostAudienceContact contact) =>
    HostCustomerDirectoryContact(
      contactId: contact.contactId,
      displayName: contact.displayName,
      attendedEventCount: contact.attendedEventCount,
      lastAttendedAt: contact.lastAttendedAt,
      tags: {for (final segment in contact.segments) ?_customerTag(segment)},
      hasAmbiguousIdentity:
          contact.identityState == HostAudienceIdentityState.ambiguous ||
          contact.ambiguousCandidateCount > 0,
      whatsappOptedIn:
          contact.whatsappStatus == HostAudiencePermissionStatus.optedIn,
      whatsappAdminSuppressed: contact.whatsappAdminSuppressed,
    );

HostCustomerTag? _customerTag(HostAudienceSegment segment) => switch (segment) {
  HostAudienceSegment.newToOrganizer => HostCustomerTag.newToOrganizer,
  HostAudienceSegment.firstTimeAttendee => HostCustomerTag.firstTime,
  HostAudienceSegment.repeatAttendee => HostCustomerTag.repeat,
  HostAudienceSegment.regular => HostCustomerTag.regular,
  HostAudienceSegment.lapsedRegular => HostCustomerTag.atRisk,
  HostAudienceSegment.reliableAttendee => HostCustomerTag.reliable,
  HostAudienceSegment.needsConfirmation => HostCustomerTag.needsConfirmation,
  HostAudienceSegment.advocate => HostCustomerTag.advocate,
  HostAudienceSegment.highImpactAdvocate => HostCustomerTag.highImpactAdvocate,
  HostAudienceSegment.whatsappReachable => HostCustomerTag.whatsappReachable,
  HostAudienceSegment.smsReachable => HostCustomerTag.smsReachable,
};

HostCustomerDirectoryCoverage _directoryCoverage(
  HostAudienceSourceCoverage coverage,
) => switch (coverage) {
  HostAudienceSourceCoverage.exact => HostCustomerDirectoryCoverage.exact,
  HostAudienceSourceCoverage.partial => HostCustomerDirectoryCoverage.partial,
  HostAudienceSourceCoverage.insufficientData =>
    HostCustomerDirectoryCoverage.insufficientData,
};

@riverpod
HostCustomersController hostCustomersController(Ref ref) =>
    HostCustomersController(ref.watch(hostCrmRepositoryProvider));

class HostCustomersController {
  const HostCustomersController(this._repository);

  final HostCrmRepository _repository;

  Future<HostCreatedCustomer> createCustomer({
    required String organizerId,
    required String displayName,
  }) => _repository.createContact(
    organizerId: organizerId,
    displayName: displayName,
  );

  Future<String> startConversation({
    required String organizerId,
    required String contactId,
  }) => _repository.startContactConversation(
    organizerId: organizerId,
    contactId: contactId,
  );

  Future<HostAudienceExport> exportCustomers({
    required String organizerId,
    HostAudienceSegment? segment,
  }) => _repository.exportContacts(organizerId, segment: segment);

  Future<void> mutateCustomer({
    required String organizerId,
    required String contactId,
    required int expectedRevision,
    String? displayNameOverride,
    bool clearDisplayNameOverride = false,
    bool? whatsappAdminSuppressed,
    bool? hidden,
  }) => _repository.mutateContact(
    organizerId: organizerId,
    contactId: contactId,
    expectedRevision: expectedRevision,
    displayNameOverride: displayNameOverride,
    clearDisplayNameOverride: clearDisplayNameOverride,
    whatsappAdminSuppressed: whatsappAdminSuppressed,
    hidden: hidden,
  );
}
