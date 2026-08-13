import 'package:flutter/foundation.dart';

enum HostCustomerTag {
  firstTime,
  repeat,
  regular,
  atRisk,
  needsConfirmation,
  advocate,
}

enum HostCustomerFilter {
  all,
  attended,
  repeat,
  regular,
  atRisk,
  needsConfirmation,
  advocate;

  HostCustomerTag? get tag => switch (this) {
    HostCustomerFilter.all || HostCustomerFilter.attended => null,
    HostCustomerFilter.repeat => HostCustomerTag.repeat,
    HostCustomerFilter.regular => HostCustomerTag.regular,
    HostCustomerFilter.atRisk => HostCustomerTag.atRisk,
    HostCustomerFilter.needsConfirmation => HostCustomerTag.needsConfirmation,
    HostCustomerFilter.advocate => HostCustomerTag.advocate,
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

  factory HostCustomersDirectoryState.fromPageData({
    required Iterable<HostCustomerDirectoryContact> contacts,
    required String? nextCursor,
    required HostCustomerDirectoryCoverage sourceCoverage,
    required int projectionVersion,
  }) => HostCustomersDirectoryState(
    contacts: List.unmodifiable(contacts),
    nextCursor: nextCursor,
    sourceCoverage: sourceCoverage,
    projectionVersion: projectionVersion,
  );

  final List<HostCustomerDirectoryContact> contacts;
  final String? nextCursor;
  final HostCustomerDirectoryCoverage sourceCoverage;
  final int projectionVersion;
  final bool loadingMore;
  final Object? loadMoreError;

  bool get canLoadMore => nextCursor != null && !loadingMore;

  HostCustomersDirectoryState copyWith({
    List<HostCustomerDirectoryContact>? contacts,
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

enum HostCustomerDirectoryCoverage { exact, partial, insufficientData }

@immutable
class HostCustomerDirectoryContact {
  const HostCustomerDirectoryContact({
    required this.contactId,
    required this.displayName,
    required this.attendedEventCount,
    required this.lastAttendedAt,
    required this.tags,
    required this.hasAmbiguousIdentity,
  });

  final String contactId;
  final String displayName;
  final int attendedEventCount;
  final DateTime? lastAttendedAt;
  final Set<HostCustomerTag> tags;
  final bool hasAmbiguousIdentity;
}

enum HostCustomerConversationAvailability { ready, unlinked, ambiguous }

HostCustomerConversationAvailability customerConversationAvailability({
  required bool linkedAccount,
  required bool identityVerified,
  required int ambiguousCandidateCount,
}) {
  if (ambiguousCandidateCount > 0) {
    return HostCustomerConversationAvailability.ambiguous;
  }
  if (!linkedAccount || !identityVerified) {
    return HostCustomerConversationAvailability.unlinked;
  }
  return HostCustomerConversationAvailability.ready;
}
