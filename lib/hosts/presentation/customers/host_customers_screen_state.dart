import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:flutter/foundation.dart';

enum HostCustomerFilter {
  all,
  attended,
  repeat,
  regular,
  atRisk,
  needsConfirmation,
  advocate;

  HostAudienceSegment? get segment => switch (this) {
    HostCustomerFilter.all || HostCustomerFilter.attended => null,
    HostCustomerFilter.repeat => HostAudienceSegment.repeatAttendee,
    HostCustomerFilter.regular => HostAudienceSegment.regular,
    HostCustomerFilter.atRisk => HostAudienceSegment.lapsedRegular,
    HostCustomerFilter.needsConfirmation =>
      HostAudienceSegment.needsConfirmation,
    HostCustomerFilter.advocate => HostAudienceSegment.advocate,
  };
}

@immutable
class HostCustomersDirectoryRequest {
  const HostCustomersDirectoryRequest({
    required this.organizerId,
    this.search,
    this.filter = HostCustomerFilter.all,
  });

  final String organizerId;
  final String? search;
  final HostCustomerFilter filter;

  HostAudienceQuery get query =>
      HostAudienceQuery(search: search, segment: filter.segment);

  @override
  bool operator ==(Object other) =>
      other is HostCustomersDirectoryRequest &&
      other.organizerId == organizerId &&
      other.search == search &&
      other.filter == filter;

  @override
  int get hashCode => Object.hash(organizerId, search, filter);
}

@immutable
class HostCustomersDirectoryState {
  const HostCustomersDirectoryState({
    required this.contacts,
    required this.nextCursor,
    required this.sourceCoverage,
    required this.projectionVersion,
    this.loadingMore = false,
    this.loadMoreError,
  });

  factory HostCustomersDirectoryState.fromPage(HostAudiencePage page) =>
      HostCustomersDirectoryState(
        contacts: List.unmodifiable(page.contacts),
        nextCursor: page.nextCursor,
        sourceCoverage: page.sourceCoverage,
        projectionVersion: page.projectionVersion,
      );

  final List<HostAudienceContact> contacts;
  final String? nextCursor;
  final HostAudienceSourceCoverage sourceCoverage;
  final int projectionVersion;
  final bool loadingMore;
  final Object? loadMoreError;

  bool get canLoadMore => nextCursor != null && !loadingMore;

  HostCustomersDirectoryState copyWith({
    List<HostAudienceContact>? contacts,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? loadingMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) => HostCustomersDirectoryState(
    contacts: contacts ?? this.contacts,
    nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
    sourceCoverage: sourceCoverage,
    projectionVersion: projectionVersion,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreError: clearLoadMoreError
        ? null
        : loadMoreError ?? this.loadMoreError,
  );
}

enum HostCustomerConversationAvailability { ready, unlinked, ambiguous }

HostCustomerConversationAvailability customerConversationAvailability(
  HostAudienceContactDetail detail,
) {
  if (detail.identityState == HostAudienceIdentityState.ambiguous ||
      detail.ambiguousCandidateCount > 0) {
    return HostCustomerConversationAvailability.ambiguous;
  }
  if (!detail.linkedAccount ||
      detail.identityState != HostAudienceIdentityState.verified) {
    return HostCustomerConversationAvailability.unlinked;
  }
  return HostCustomerConversationAvailability.ready;
}
