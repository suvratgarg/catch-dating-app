import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

enum HostEventManageSection { setup, guests, live, report }

enum HostEventManageActionIntent { editEvent, cancelEvent, deleteEvent }

enum HostEventManageActionDestination {
  editEventRoute,
  cancelConfirmation,
  deleteConfirmation,
}

class HostEventManageActionEffect {
  const HostEventManageActionEffect({
    required this.destination,
    required this.event,
    this.pathParameters = const <String, String>{},
  });

  factory HostEventManageActionEffect.resolve({
    required HostEventManageActionIntent intent,
    required Event event,
  }) {
    return switch (intent) {
      HostEventManageActionIntent.editEvent => HostEventManageActionEffect(
        destination: HostEventManageActionDestination.editEventRoute,
        event: event,
        pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      ),
      HostEventManageActionIntent.cancelEvent => HostEventManageActionEffect(
        destination: HostEventManageActionDestination.cancelConfirmation,
        event: event,
      ),
      HostEventManageActionIntent.deleteEvent => HostEventManageActionEffect(
        destination: HostEventManageActionDestination.deleteConfirmation,
        event: event,
      ),
    };
  }

  final HostEventManageActionDestination destination;
  final Event event;
  final Map<String, String> pathParameters;
}

class HostEventManageScreenState {
  const HostEventManageScreenState({
    required this.selectedSection,
    required this.eventTitle,
    required this.collapseHeaderCopy,
    required this.collapsedTitleSemanticsLabel,
  });

  factory HostEventManageScreenState.resolve({
    required Club club,
    required Event event,
    required HostEventManageSection selectedSection,
    required double textScale,
  }) {
    final collapseHeaderCopy = textScale >= 1.4;
    final eventTitle = hostManageEventTitle(event);
    return HostEventManageScreenState(
      selectedSection: selectedSection,
      eventTitle: eventTitle,
      collapseHeaderCopy: collapseHeaderCopy,
      collapsedTitleSemanticsLabel: collapseHeaderCopy
          ? '${club.name}. $eventTitle'
          : null,
    );
  }

  final HostEventManageSection selectedSection;
  final String eventTitle;
  final bool collapseHeaderCopy;
  final String? collapsedTitleSemanticsLabel;

  HostEventManageScreenState selectSection(HostEventManageSection section) {
    return HostEventManageScreenState(
      selectedSection: section,
      eventTitle: eventTitle,
      collapseHeaderCopy: collapseHeaderCopy,
      collapsedTitleSemanticsLabel: collapsedTitleSemanticsLabel,
    );
  }
}

class HostEventActionDisplayState {
  const HostEventActionDisplayState({
    required this.hasKnownActivity,
    required this.cancelEventPending,
    required this.deleteEventPending,
    required this.isMutating,
    required this.showEditAction,
    required this.showCancelledState,
    required this.showCancelAction,
    required this.showDeleteAction,
    required this.cancelDetail,
    required this.deleteDetail,
  });

  factory HostEventActionDisplayState.resolve({
    required Event event,
    required EventParticipationRoster? roster,
    required bool cancelEventPending,
    required bool deleteEventPending,
  }) {
    final hasKnownActivity =
        hostManageBookedCount(event, roster) > 0 ||
        hostManageCheckedInCount(event, roster) > 0 ||
        hostManageWaitlistedCount(event, roster) > 0;
    final isMutating = cancelEventPending || deleteEventPending;
    final isCancelled = event.isCancelled;
    return HostEventActionDisplayState(
      hasKnownActivity: hasKnownActivity,
      cancelEventPending: cancelEventPending,
      deleteEventPending: deleteEventPending,
      isMutating: isMutating,
      showEditAction: !isCancelled,
      showCancelledState: isCancelled,
      showCancelAction: !isCancelled,
      showDeleteAction: !isCancelled && !hasKnownActivity,
      cancelDetail: cancelEventPending
          ? 'Cancelling...'
          : 'Keeps records · notifies guests',
      deleteDetail: deleteEventPending ? 'Deleting...' : 'Permanent removal',
    );
  }

  final bool hasKnownActivity;
  final bool cancelEventPending;
  final bool deleteEventPending;
  final bool isMutating;
  final bool showEditAction;
  final bool showCancelledState;
  final bool showCancelAction;
  final bool showDeleteAction;
  final String cancelDetail;
  final String deleteDetail;
}

class HostPrivateLinkActionState {
  const HostPrivateLinkActionState({
    required this.inviteCode,
    required this.inviteLink,
    required this.shareDetail,
    required this.canShare,
  });

  factory HostPrivateLinkActionState.resolve({
    required AppLocalizations l10n,
    required CatchAsyncState<EventPrivateAccess?>? accessState,
    required CatchAsyncState<List<EventInviteLink>>? inviteLinksState,
    required String? inviteLink,
    required bool sharePending,
  }) {
    final inviteCode = accessState?.value?.inviteCode.trim();
    return HostPrivateLinkActionState(
      inviteCode: inviteCode,
      inviteLink: inviteLink,
      shareDetail: hostPrivateShareDetail(
        l10n: l10n,
        accessState: accessState,
        inviteLinksState: inviteLinksState,
        sharePending: sharePending,
      ),
      canShare: inviteLink != null && !sharePending,
    );
  }

  final String? inviteCode;
  final String? inviteLink;
  final String shareDetail;
  final bool canShare;

  bool get hasInviteCode => inviteCode != null && inviteCode!.isNotEmpty;
}

class HostPrivateAccessDisplayState {
  const HostPrivateAccessDisplayState({
    required this.description,
    required this.linkAction,
  });

  factory HostPrivateAccessDisplayState.resolve({
    required AppLocalizations l10n,
    required EventPrivateAccess? access,
    required CatchAsyncState<List<EventInviteLink>>? inviteLinksState,
    required String? inviteLink,
    required bool sharePending,
  }) {
    final linkAction = HostPrivateLinkActionState.resolve(
      l10n: l10n,
      accessState: CatchAsyncState<EventPrivateAccess?>.data(access),
      inviteLinksState: inviteLinksState,
      inviteLink: inviteLink,
      sharePending: sharePending,
    );
    return HostPrivateAccessDisplayState(
      description: linkAction.hasInviteCode
          ? l10n.hostsHostEventManageScreenStateDescriptionThisEventCanStay
          : l10n.hostsHostEventManageScreenStateDescriptionThisEventRequiresAn,
      linkAction: linkAction,
    );
  }

  final String description;
  final HostPrivateLinkActionState linkAction;

  bool get hasInviteCode => linkAction.hasInviteCode;
}

enum HostInviteLinksMutationMode { idle, creating, copying, disabling }

class HostParticipantsMutationDisplayState {
  const HostParticipantsMutationDisplayState({
    required this.requestActionPendingIds,
    required this.waitlistOfferPendingIds,
    required this.bulkWaitlistOfferPending,
    required this.attendanceActionPendingIds,
    required this.opsReportExportPending,
    required this.revenueReportExportPending,
    this.participantActionError,
    this.reportExportError,
  });

  factory HostParticipantsMutationDisplayState.resolve({
    required Set<String> markAttendancePendingIds,
    required Set<String> approveJoinRequestPendingIds,
    required Set<String> declineJoinRequestPendingIds,
    required Set<String> createWaitlistOfferPendingIds,
    required bool bulkWaitlistOfferPending,
    required bool opsReportPending,
    required bool revenueReportPending,
    Object? markAttendanceError,
    Object? approveJoinRequestError,
    Object? declineJoinRequestError,
    Object? createWaitlistOfferError,
    Object? opsReportError,
    Object? revenueReportError,
  }) {
    return HostParticipantsMutationDisplayState(
      requestActionPendingIds: Set.unmodifiable({
        ...approveJoinRequestPendingIds,
        ...declineJoinRequestPendingIds,
      }),
      waitlistOfferPendingIds: Set.unmodifiable(createWaitlistOfferPendingIds),
      bulkWaitlistOfferPending: bulkWaitlistOfferPending,
      attendanceActionPendingIds: Set.unmodifiable(markAttendancePendingIds),
      opsReportExportPending: opsReportPending,
      revenueReportExportPending: revenueReportPending,
      participantActionError:
          markAttendanceError ??
          approveJoinRequestError ??
          declineJoinRequestError ??
          createWaitlistOfferError,
      reportExportError: opsReportError ?? revenueReportError,
    );
  }

  final Set<String> requestActionPendingIds;
  final Set<String> waitlistOfferPendingIds;
  final bool bulkWaitlistOfferPending;
  final Set<String> attendanceActionPendingIds;
  final bool opsReportExportPending;
  final bool revenueReportExportPending;
  final Object? participantActionError;
  final Object? reportExportError;

  bool get requestActionPending => requestActionPendingIds.isNotEmpty;
  bool get waitlistOfferPending =>
      bulkWaitlistOfferPending || waitlistOfferPendingIds.isNotEmpty;
  bool get attendanceActionPending => attendanceActionPendingIds.isNotEmpty;

  bool isRequestActionPending(String uid) =>
      requestActionPendingIds.contains(uid);

  bool isWaitlistOfferPending(String uid) =>
      bulkWaitlistOfferPending || waitlistOfferPendingIds.contains(uid);

  bool isAttendanceActionPending(String uid) =>
      attendanceActionPendingIds.contains(uid);
}

class HostParticipantLifecycleActions {
  const HostParticipantLifecycleActions({
    required this.openProfile,
    required this.approveJoinRequest,
    required this.declineJoinRequest,
    required this.toggleAttendance,
    required this.createWaitlistOffers,
    required this.shareOpsReport,
    required this.shareRevenueReport,
  });

  final void Function(String uid) openProfile;
  final void Function(String uid) approveJoinRequest;
  final void Function(String uid) declineJoinRequest;
  final void Function(String uid) toggleAttendance;
  final void Function(List<String> userIds) createWaitlistOffers;
  final Future<void> Function() shareOpsReport;
  final Future<void> Function() shareRevenueReport;

  void createWaitlistOffer(String uid) => createWaitlistOffers([uid]);
}

class HostReportSummaryDisplayState {
  const HostReportSummaryDisplayState({
    required this.grossEstimateInPaise,
    required this.checkedInCount,
    required this.noShowCount,
    required this.waitlistCount,
    required this.currencyCode,
  });

  factory HostReportSummaryDisplayState.resolve({
    required int totalCount,
    required int checkedInCount,
    required int waitlistCount,
    required int priceInPaise,
    required String currencyCode,
  }) {
    final noShowCount = totalCount - checkedInCount;
    final grossEstimateInPaise = totalCount * priceInPaise;
    return HostReportSummaryDisplayState(
      grossEstimateInPaise: grossEstimateInPaise,
      checkedInCount: checkedInCount,
      noShowCount: noShowCount,
      waitlistCount: waitlistCount,
      currencyCode: currencyCode,
    );
  }

  final int grossEstimateInPaise;
  final int checkedInCount;
  final int noShowCount;
  final int waitlistCount;
  final String currencyCode;

  String summary(AppLocalizations l10n) => l10n
      .hostsHostEventManageScreenStateVisiblecopyPriceinpaiseGrossEstimateCheckedincount(
        priceInPaise: EventFormatters.priceInPaise(
          grossEstimateInPaise,
          currencyCode: currencyCode,
        ),
        checkedInCount: checkedInCount,
        noShowCount: noShowCount,
        waitlistCount: waitlistCount,
      );
}

enum HostParticipantProfilesLookupStatus { ready, loading, error }

class HostParticipantProfilesLookupState {
  const HostParticipantProfilesLookupState({
    required this.status,
    required this.profileIds,
    required this.profiles,
    this.error,
  });

  factory HostParticipantProfilesLookupState.resolve({
    required List<String> profileIds,
    required CatchAsyncState<Map<String, (String, String?)>>? profilesState,
  }) {
    if (profileIds.isEmpty) {
      return const HostParticipantProfilesLookupState(
        status: HostParticipantProfilesLookupStatus.ready,
        profileIds: <String>[],
        profiles: <String, (String, String?)>{},
      );
    }
    final profiles = profilesState?.value;
    if (profiles != null) {
      return HostParticipantProfilesLookupState(
        status: HostParticipantProfilesLookupStatus.ready,
        profileIds: profileIds,
        profiles: profiles,
      );
    }
    if (profilesState?.status == CatchAsyncStatus.error) {
      return HostParticipantProfilesLookupState(
        status: HostParticipantProfilesLookupStatus.error,
        profileIds: profileIds,
        profiles: const <String, (String, String?)>{},
        error: profilesState!.error,
      );
    }
    return HostParticipantProfilesLookupState(
      status: HostParticipantProfilesLookupStatus.loading,
      profileIds: profileIds,
      profiles: const <String, (String, String?)>{},
    );
  }

  final HostParticipantProfilesLookupStatus status;
  final List<String> profileIds;
  final Map<String, (String, String?)> profiles;
  final Object? error;

  bool get shouldWatchProfiles => profileIds.isNotEmpty;
}

class HostInviteLinksListDisplayState {
  const HostInviteLinksListDisplayState({
    required this.mutationMode,
    required this.emptyCopy,
  });

  factory HostInviteLinksListDisplayState.resolve({
    required bool createPending,
    required bool copyPending,
    required bool disablePending,
  }) {
    final mutationMode = createPending
        ? HostInviteLinksMutationMode.creating
        : copyPending
        ? HostInviteLinksMutationMode.copying
        : disablePending
        ? HostInviteLinksMutationMode.disabling
        : HostInviteLinksMutationMode.idle;
    return HostInviteLinksListDisplayState(
      mutationMode: mutationMode,
      emptyCopy:
          'Create links for Instagram bio, WhatsApp alumni, venue partners, or any channel you want to compare.',
    );
  }

  final HostInviteLinksMutationMode mutationMode;
  final String emptyCopy;

  bool get isMutating => mutationMode != HostInviteLinksMutationMode.idle;

  bool get createPending =>
      mutationMode == HostInviteLinksMutationMode.creating;
}

class HostInviteLinkRowDisplayState {
  const HostInviteLinkRowDisplayState({
    required this.label,
    required this.source,
    required this.url,
    required this.stats,
    required this.actionsDisabled,
    required this.showDisabledBadge,
    required this.showDisableAction,
  });

  factory HostInviteLinkRowDisplayState.resolve({
    required EventInviteLink link,
    required String url,
    required bool actionsDisabled,
  }) {
    return HostInviteLinkRowDisplayState(
      label: link.label,
      source: link.source,
      url: url,
      stats: hostInviteLinkStats(link),
      actionsDisabled: actionsDisabled,
      showDisabledBadge: link.isDisabled,
      showDisableAction: !link.isDisabled,
    );
  }

  final String label;
  final String? source;
  final String url;
  final String stats;
  final bool actionsDisabled;
  final bool showDisabledBadge;
  final bool showDisableAction;
}

enum HostRosterFilter {
  all,
  booked,
  waitlist,
  slots,
  requests,
  due,
  checkedIn,
  attended,
  noShow,
}

class HostRosterFilterSpec {
  const HostRosterFilterSpec({
    required this.filter,
    required this.label,
    required this.value,
    required this.tone,
  });

  final HostRosterFilter filter;
  final String label;
  final int value;
  final CatchBadgeTone tone;
}

class HostRosterDisplayState {
  HostRosterDisplayState._({
    required List<HostRosterFilterSpec> filters,
    required this.activeFilter,
    required List<String> rowIds,
    required List<String> offerableWaitlistIds,
    required this.bulkOfferCount,
    required this.emptyTitle,
    required this.emptyMessage,
  }) : filters = List.unmodifiable(filters),
       rowIds = List.unmodifiable(rowIds),
       offerableWaitlistIds = List.unmodifiable(offerableWaitlistIds);

  factory HostRosterDisplayState.setup({
    required AppLocalizations l10n,
    required bool usesRequestApproval,
    required List<String> attendeeIds,
    required List<String> waitlistedIds,
    required int totalCount,
    required int capacityLimit,
    required int waitlistCount,
    required Map<String, EventParticipation> participationsByUid,
    required Map<String, (String, String?)> profiles,
    required String searchQuery,
    required HostRosterFilter selectedFilter,
  }) {
    final requestIds = usesRequestApproval ? waitlistedIds : const <String>[];
    final bookedIds = attendeeIds;
    final displayWaitlistedIds = usesRequestApproval
        ? const <String>[]
        : waitlistedIds;
    final allIds = [...requestIds, ...bookedIds, ...displayWaitlistedIds];
    final remainingSlots = (capacityLimit - totalCount)
        .clamp(0, capacityLimit)
        .toInt();
    final offerableWaitlistIds = _offerableWaitlistIds(
      displayWaitlistedIds,
      participationsByUid,
    );
    final bulkOfferCount = _bulkOfferCount(
      offerableWaitlistIds,
      remainingSlots,
    );
    final filters = [
      HostRosterFilterSpec(
        filter: HostRosterFilter.all,
        label: l10n.hostsHostEventManageScreenStateLabelAll,
        value: allIds.length,
        tone: CatchBadgeTone.neutral,
      ),
      HostRosterFilterSpec(
        filter: HostRosterFilter.booked,
        label: l10n.hostsHostEventManageScreenStateLabelBooked,
        value: bookedIds.length,
        tone: CatchBadgeTone.success,
      ),
      HostRosterFilterSpec(
        filter: usesRequestApproval
            ? HostRosterFilter.requests
            : HostRosterFilter.waitlist,
        label: usesRequestApproval
            ? l10n.hostsHostEventManageScreenStateLabelRequests
            : l10n.hostsHostEventManageScreenStateLabelWaitlist,
        value: waitlistCount,
        tone: usesRequestApproval
            ? CatchBadgeTone.brand
            : CatchBadgeTone.warning,
      ),
      HostRosterFilterSpec(
        filter: HostRosterFilter.slots,
        label: l10n.hostsHostEventManageScreenStateLabelSlots,
        value: remainingSlots,
        tone: CatchBadgeTone.neutral,
      ),
    ];
    final activeFilter = _effectiveFilter(selectedFilter, filters);
    final visibleIds = switch (activeFilter) {
      HostRosterFilter.booked => bookedIds,
      HostRosterFilter.waitlist => displayWaitlistedIds,
      HostRosterFilter.requests => requestIds,
      HostRosterFilter.slots => const <String>[],
      _ => allIds,
    };
    final rowIds = _matchingIds(
      visibleIds,
      profiles: profiles,
      searchQuery: searchQuery,
    );
    final hasSearch = searchQuery.trim().isNotEmpty;
    return HostRosterDisplayState._(
      filters: filters,
      activeFilter: activeFilter,
      rowIds: rowIds,
      offerableWaitlistIds: offerableWaitlistIds,
      bulkOfferCount: bulkOfferCount,
      emptyTitle: hasSearch
          ? l10n.hostsHostEventManageScreenStateEmptytitleNoMatches
          : activeFilter == HostRosterFilter.slots
          ? l10n.hostsHostEventManageScreenStateEmptytitleOpenSlotsAreNot
          : l10n.hostsHostEventManageScreenStateEmptytitleNoParticipantsYet,
      emptyMessage: hasSearch
          ? l10n.hostsHostEventManageScreenStateVisiblecopyNoPeopleMatchThis
          : activeFilter == HostRosterFilter.slots
          ? l10n.hostsHostEventManageScreenStateVisiblecopySlotsShowCapacityLeft
          : l10n.hostsHostEventManageScreenStateVisiblecopyBookedAndWaitlistedPeople,
    );
  }

  factory HostRosterDisplayState.live({
    required AppLocalizations l10n,
    required bool usesRequestApproval,
    required List<String> attendeeIds,
    required Set<String> attendedIds,
    required List<String> waitlistedIds,
    required int totalCount,
    required int capacityLimit,
    required Map<String, EventParticipation> participationsByUid,
    required Map<String, (String, String?)> profiles,
    required String searchQuery,
    required HostRosterFilter selectedFilter,
  }) {
    final checkedInBaseIds = attendeeIds
        .where(attendedIds.contains)
        .toList(growable: false);
    final needsCheckInBaseIds = attendeeIds
        .where((uid) => !attendedIds.contains(uid))
        .toList(growable: false);
    final remainingSlots = (capacityLimit - totalCount)
        .clamp(0, capacityLimit)
        .toInt();
    final offerableWaitlistIds = _offerableWaitlistIds(
      waitlistedIds,
      participationsByUid,
    );
    final bulkOfferCount = _bulkOfferCount(
      offerableWaitlistIds,
      remainingSlots,
    );
    final allBaseIds = [
      ...needsCheckInBaseIds,
      ...checkedInBaseIds,
      ...waitlistedIds,
    ];
    final filters = [
      HostRosterFilterSpec(
        filter: HostRosterFilter.all,
        label: l10n.hostsHostEventManageScreenStateLabelAll,
        value: allBaseIds.length,
        tone: CatchBadgeTone.neutral,
      ),
      HostRosterFilterSpec(
        filter: HostRosterFilter.due,
        label: l10n.hostsHostEventManageScreenStateLabelDue,
        value: needsCheckInBaseIds.length,
        tone: CatchBadgeTone.brand,
      ),
      HostRosterFilterSpec(
        filter: HostRosterFilter.checkedIn,
        label: l10n.hostsHostEventManageScreenStateLabelIn,
        value: checkedInBaseIds.length,
        tone: CatchBadgeTone.success,
      ),
      HostRosterFilterSpec(
        filter: usesRequestApproval
            ? HostRosterFilter.requests
            : HostRosterFilter.waitlist,
        label: usesRequestApproval
            ? l10n.hostsHostEventManageScreenStateLabelRequests
            : l10n.hostsHostEventManageScreenStateLabelWaitlist,
        value: waitlistedIds.length,
        tone: CatchBadgeTone.warning,
      ),
    ];
    final activeFilter = _effectiveFilter(selectedFilter, filters);
    final visibleIds = switch (activeFilter) {
      HostRosterFilter.due => needsCheckInBaseIds,
      HostRosterFilter.checkedIn => checkedInBaseIds,
      HostRosterFilter.waitlist || HostRosterFilter.requests => waitlistedIds,
      _ => allBaseIds,
    };
    final rowIds = _matchingIds(
      visibleIds,
      profiles: profiles,
      searchQuery: searchQuery,
    );
    final hasRoster = totalCount > 0;
    final hasSearch = searchQuery.trim().isNotEmpty;
    return HostRosterDisplayState._(
      filters: filters,
      activeFilter: activeFilter,
      rowIds: rowIds,
      offerableWaitlistIds: offerableWaitlistIds,
      bulkOfferCount: bulkOfferCount,
      emptyTitle: hasSearch
          ? l10n.hostsHostEventManageScreenStateEmptytitleNoMatches
          : _liveEmptyTitle(activeFilter, hasRoster, l10n),
      emptyMessage: hasSearch
          ? l10n.hostsHostEventManageScreenStateVisiblecopyNoLiveRosterRows
          : _liveEmptyMessage(activeFilter, hasRoster, l10n),
    );
  }

  factory HostRosterDisplayState.report({
    required AppLocalizations l10n,
    required List<String> attendeeIds,
    required Set<String> attendedIds,
    required List<String> waitlistedIds,
    required int totalCount,
    required int waitlistCount,
    required Map<String, (String, String?)> profiles,
    required String searchQuery,
    required HostRosterFilter selectedFilter,
  }) {
    final attendedBaseIds = attendeeIds
        .where(attendedIds.contains)
        .toList(growable: false);
    final noShowBaseIds = attendeeIds
        .where((uid) => !attendedIds.contains(uid))
        .toList(growable: false);
    final noShowCount = totalCount - attendedBaseIds.length;
    final allBaseIds = [...attendedBaseIds, ...noShowBaseIds, ...waitlistedIds];
    final filters = [
      HostRosterFilterSpec(
        filter: HostRosterFilter.all,
        label: l10n.hostsHostEventManageScreenStateLabelAll,
        value: allBaseIds.length,
        tone: CatchBadgeTone.neutral,
      ),
      HostRosterFilterSpec(
        filter: HostRosterFilter.attended,
        label: l10n.hostsHostEventManageScreenStateLabelAttended,
        value: attendedBaseIds.length,
        tone: CatchBadgeTone.success,
      ),
      HostRosterFilterSpec(
        filter: HostRosterFilter.noShow,
        label: l10n.hostsHostEventManageScreenStateLabelNoShow,
        value: noShowCount,
        tone: CatchBadgeTone.neutral,
      ),
      HostRosterFilterSpec(
        filter: HostRosterFilter.waitlist,
        label: l10n.hostsHostEventManageScreenStateLabelWaitlist,
        value: waitlistCount,
        tone: CatchBadgeTone.warning,
      ),
    ];
    final activeFilter = _effectiveFilter(selectedFilter, filters);
    final visibleIds = switch (activeFilter) {
      HostRosterFilter.attended => attendedBaseIds,
      HostRosterFilter.noShow => noShowBaseIds,
      HostRosterFilter.waitlist => waitlistedIds,
      _ => allBaseIds,
    };
    final rowIds = _matchingIds(
      visibleIds,
      profiles: profiles,
      searchQuery: searchQuery,
    );
    final hasSearch = searchQuery.trim().isNotEmpty;
    return HostRosterDisplayState._(
      filters: filters,
      activeFilter: activeFilter,
      rowIds: rowIds,
      offerableWaitlistIds: const [],
      bulkOfferCount: 0,
      emptyTitle: hasSearch
          ? l10n.hostsHostEventManageScreenStateEmptytitleNoMatches
          : _reportEmptyTitle(activeFilter, l10n),
      emptyMessage: hasSearch
          ? l10n.hostsHostEventManageScreenStateVisiblecopyNoReportRowsMatch
          : _reportEmptyMessage(activeFilter, l10n),
    );
  }

  final List<HostRosterFilterSpec> filters;
  final HostRosterFilter activeFilter;
  final List<String> rowIds;
  final List<String> offerableWaitlistIds;
  final int bulkOfferCount;
  final String emptyTitle;
  final String emptyMessage;

  List<String> get bulkOfferIds =>
      offerableWaitlistIds.take(bulkOfferCount).toList(growable: false);

  bool get showBulkOfferAction => bulkOfferCount > 0;
}

class HostSetupRosterRowDisplayState {
  const HostSetupRosterRowDisplayState({
    required this.meta,
    required this.signal,
    required this.tone,
    required this.showRequestActions,
    required this.showWaitlistOfferAction,
  });

  factory HostSetupRosterRowDisplayState.resolve({
    required AppLocalizations l10n,
    required EventParticipation? participation,
    required bool usesRequestApproval,
  }) {
    final status = participation?.status;
    return HostSetupRosterRowDisplayState(
      meta: _setupMeta(participation, usesRequestApproval, l10n),
      signal: _setupSignal(participation, usesRequestApproval, l10n).label,
      tone: _setupSignal(participation, usesRequestApproval, l10n).tone,
      showRequestActions:
          usesRequestApproval && status == EventParticipationStatus.waitlisted,
      showWaitlistOfferAction:
          !usesRequestApproval && status == EventParticipationStatus.waitlisted,
    );
  }

  final String meta;
  final String signal;
  final CatchBadgeTone tone;
  final bool showRequestActions;
  final bool showWaitlistOfferAction;
}

class HostLiveRosterRowDisplayState {
  const HostLiveRosterRowDisplayState({
    required this.meta,
    required this.signal,
    required this.tone,
    required this.showAttendanceToggle,
    required this.attendanceButtonLabel,
    required this.attendanceButtonPrimary,
    required this.showWaitlistOfferAction,
  });

  factory HostLiveRosterRowDisplayState.resolve({
    required AppLocalizations l10n,
    required EventParticipation? participation,
    required bool attended,
    required bool usesRequestApproval,
  }) {
    final status = participation?.status;
    final signal = _liveSignal(
      participation,
      attended,
      usesRequestApproval,
      l10n,
    );
    final showAttendanceToggle =
        status == EventParticipationStatus.signedUp ||
        status == EventParticipationStatus.attended;
    return HostLiveRosterRowDisplayState(
      meta: attended
          ? participation?.attendedAt == null
                ? l10n.hostsHostEventManageScreenStateVisiblecopyCheckedIn
                : EventFormatters.time(participation!.attendedAt!)
          : _reportMeta(participation, l10n),
      signal: signal.label,
      tone: signal.tone,
      showAttendanceToggle: showAttendanceToggle,
      attendanceButtonLabel: attended
          ? l10n.hostsHostEventManageScreenStateVisiblecopyUndo
          : l10n.hostsHostEventManageScreenStateVisiblecopyCheckIn,
      attendanceButtonPrimary: !attended,
      showWaitlistOfferAction:
          status == EventParticipationStatus.waitlisted && !usesRequestApproval,
    );
  }

  final String meta;
  final String signal;
  final CatchBadgeTone tone;
  final bool showAttendanceToggle;
  final String attendanceButtonLabel;
  final bool attendanceButtonPrimary;
  final bool showWaitlistOfferAction;
}

class HostReportRosterRowDisplayState {
  const HostReportRosterRowDisplayState({
    required this.meta,
    required this.signal,
    required this.tone,
    required this.payment,
  });

  factory HostReportRosterRowDisplayState.resolve({
    required AppLocalizations l10n,
    required EventParticipation? participation,
    required bool attended,
    required int priceInPaise,
    required String currencyCode,
  }) {
    final attendance = _reportAttendance(participation, attended, l10n);
    final status = participation?.status;
    return HostReportRosterRowDisplayState(
      meta: _reportMeta(participation, l10n),
      signal: attendance.label,
      tone: attendance.tone,
      payment: status == EventParticipationStatus.waitlisted
          ? '-'
          : priceInPaise == 0
          ? l10n.hostsHostEventManageScreenStateVisiblecopyFree
          : EventFormatters.priceInPaise(
              priceInPaise,
              currencyCode: currencyCode,
            ),
    );
  }

  final String meta;
  final String signal;
  final CatchBadgeTone tone;
  final String payment;
}

extension HostEventManageSectionLabel on HostEventManageSection {
  String label(AppLocalizations l10n) {
    return switch (this) {
      HostEventManageSection.setup =>
        l10n.hostsHostEventManageScreenStateLabelSetup,
      HostEventManageSection.guests =>
        l10n.hostsHostEventManageScreenStateLabelGuests,
      HostEventManageSection.live =>
        l10n.hostsHostEventManageScreenStateLabelLive,
      HostEventManageSection.report =>
        l10n.hostsHostEventManageScreenStateLabelReport,
    };
  }
}

String hostManageEventTitle(Event event) {
  if (event.eventFormat.isDistanceBased) return event.title;
  final weekday = EventFormatters.longWeekday(event.startTime);
  return '$weekday ${event.eventFormat.eventTitleLabel}';
}

int hostManageBookedCount(Event event, EventParticipationRoster? roster) {
  final rosterCount = roster?.bookedCount;
  if (rosterCount == null) return event.signedUpCount;
  return rosterCount > event.signedUpCount ? rosterCount : event.signedUpCount;
}

int hostManageCheckedInCount(Event event, EventParticipationRoster? roster) {
  final rosterCount = roster?.checkedInCount;
  if (rosterCount == null) return event.attendedCount;
  return rosterCount > event.attendedCount ? rosterCount : event.attendedCount;
}

int hostManageWaitlistedCount(Event event, EventParticipationRoster? roster) {
  final rosterCount = roster?.waitlistedCount;
  if (rosterCount == null) return event.waitlistCount;
  return rosterCount > event.waitlistCount ? rosterCount : event.waitlistCount;
}

String hostPrivateShareDetail({
  required AppLocalizations l10n,
  required CatchAsyncState<EventPrivateAccess?>? accessState,
  required CatchAsyncState<List<EventInviteLink>>? inviteLinksState,
  required bool sharePending,
}) {
  if (sharePending)
    return l10n.hostsHostEventManageScreenStateVisiblecopySharing;
  if (accessState == null)
    return l10n.hostsHostEventManageScreenStateVisiblecopyPublicEventLink;
  if (accessState.status == CatchAsyncStatus.loading)
    return l10n.hostsHostEventManageScreenStateVisiblecopyLoadingLink;
  if (accessState.status == CatchAsyncStatus.error ||
      accessState.value == null) {
    return l10n
        .hostsHostEventManageScreenStateVisiblecopyInviteSetupUnavailable;
  }

  if (inviteLinksState == null ||
      inviteLinksState.status == CatchAsyncStatus.loading) {
    return l10n.hostsHostEventManageScreenStateVisiblecopyPrivateInviteLink;
  }
  if (inviteLinksState.status == CatchAsyncStatus.error) {
    return l10n
        .hostsHostEventManageScreenStateVisiblecopyInviteLinksUnavailable;
  }
  final count = inviteLinksState.value?.length ?? 0;
  if (count == 1)
    return l10n.hostsHostEventManageScreenStateVisiblecopy1InviteLink;
  return l10n.hostsHostEventManageScreenStateVisiblecopyCountInviteLinks(
    count: count,
  );
}

String hostInviteLinkStats(EventInviteLink link) {
  return [
    '${link.openCount} opens',
    '${link.requestCount} requests',
    '${link.confirmedCount} confirmed',
    '${link.checkedInCount} checked in',
    '${link.catcherCount} caught',
    '${link.chatStartedCount} chats',
  ].join(' | ');
}

HostRosterFilter _effectiveFilter(
  HostRosterFilter selected,
  List<HostRosterFilterSpec> filters,
) {
  for (final filter in filters) {
    if (filter.filter == selected) return selected;
  }
  return HostRosterFilter.all;
}

List<String> _offerableWaitlistIds(
  List<String> ids,
  Map<String, EventParticipation> participationsByUid,
) {
  return [
    for (final uid in ids)
      if (_canCreateWaitlistOffer(participationsByUid[uid])) uid,
  ];
}

int _bulkOfferCount(List<String> offerableIds, int remainingSlots) {
  if (offerableIds.isEmpty || remainingSlots <= 0) return 0;
  return offerableIds.length < remainingSlots
      ? offerableIds.length
      : remainingSlots;
}

bool _canCreateWaitlistOffer(EventParticipation? participation) {
  if (participation?.status != EventParticipationStatus.waitlisted) {
    return false;
  }
  final offerStatus = participation?.waitlistOfferStatus;
  return offerStatus != EventWaitlistOfferStatus.active &&
      offerStatus != EventWaitlistOfferStatus.accepted;
}

List<String> _matchingIds(
  List<String> ids, {
  required Map<String, (String, String?)> profiles,
  required String searchQuery,
}) {
  final query = searchQuery.trim().toLowerCase();
  if (query.isEmpty) return ids;
  return [
    for (final uid in ids)
      if (_profileName(profiles, uid).toLowerCase().contains(query) ||
          uid.toLowerCase().contains(query))
        uid,
  ];
}

String _profileName(Map<String, (String, String?)> profiles, String uid) =>
    profiles[uid]?.$1 ?? 'Runner';

String _liveEmptyTitle(
  HostRosterFilter filter,
  bool hasRoster,
  AppLocalizations l10n,
) {
  return switch (filter) {
    HostRosterFilter.due when hasRoster =>
      l10n.hostsHostEventManageScreenStateVisiblecopyEveryoneVisibleIsChecked,
    HostRosterFilter.checkedIn =>
      l10n.hostsHostEventManageScreenStateVisiblecopyNoCheckedInPeople,
    HostRosterFilter.waitlist || HostRosterFilter.requests =>
      l10n.hostsHostEventManageScreenStateVisiblecopyNoWaitlistedPeople,
    _ => l10n.hostsHostEventManageScreenStateVisiblecopyRosterIsEmpty,
  };
}

String _liveEmptyMessage(
  HostRosterFilter filter,
  bool hasRoster,
  AppLocalizations l10n,
) {
  return switch (filter) {
    HostRosterFilter.due when hasRoster =>
      l10n.hostsHostEventManageScreenStateVisiblecopySwitchToInTo,
    HostRosterFilter.checkedIn =>
      l10n.hostsHostEventManageScreenStateVisiblecopyCheckedInPeopleWill,
    HostRosterFilter.waitlist || HostRosterFilter.requests =>
      l10n.hostsHostEventManageScreenStateVisiblecopyWaitlistedPeopleWillAppear,
    _ =>
      l10n.hostsHostEventManageScreenStateVisiblecopySignedUpParticipantsWill,
  };
}

String _reportEmptyTitle(HostRosterFilter filter, AppLocalizations l10n) {
  return switch (filter) {
    HostRosterFilter.attended =>
      l10n.hostsHostEventManageScreenStateVisiblecopyNoAttendedPeopleYet,
    HostRosterFilter.noShow =>
      l10n.hostsHostEventManageScreenStateVisiblecopyNoNoShowsYet,
    HostRosterFilter.waitlist =>
      l10n.hostsHostEventManageScreenStateVisiblecopyNoWaitlistedPeople,
    _ => l10n.hostsHostEventManageScreenStateVisiblecopyNoParticipantsYet,
  };
}

String _reportEmptyMessage(HostRosterFilter filter, AppLocalizations l10n) {
  return switch (filter) {
    HostRosterFilter.attended =>
      l10n.hostsHostEventManageScreenStateVisiblecopyCheckedInPeopleWill186cb6,
    HostRosterFilter.noShow =>
      l10n.hostsHostEventManageScreenStateVisiblecopyBookedPeopleWhoDid,
    HostRosterFilter.waitlist =>
      l10n.hostsHostEventManageScreenStateVisiblecopyWaitlistHistoryWillAppear,
    _ =>
      l10n.hostsHostEventManageScreenStateVisiblecopyAttendanceAndWaitlistHistory,
  };
}

({String label, CatchBadgeTone tone}) _liveSignal(
  EventParticipation? participation,
  bool attended,
  bool usesRequestApproval,
  AppLocalizations l10n,
) {
  final status = participation?.status;
  return switch (status) {
    EventParticipationStatus.waitlisted
        when participation?.waitlistOfferStatus ==
            EventWaitlistOfferStatus.active =>
      (
        label: l10n.hostsHostEventManageScreenStateLabelOffered,
        tone: CatchBadgeTone.brand,
      ),
    EventParticipationStatus.waitlisted
        when participation?.waitlistOfferStatus ==
            EventWaitlistOfferStatus.accepted =>
      (
        label: l10n.hostsHostEventManageScreenStateLabelAccepted,
        tone: CatchBadgeTone.success,
      ),
    EventParticipationStatus.waitlisted when usesRequestApproval => (
      label: l10n.hostsHostEventManageScreenStateLabelRequest,
      tone: CatchBadgeTone.brand,
    ),
    EventParticipationStatus.waitlisted => (
      label: l10n.hostsHostEventManageScreenStateLabelWait,
      tone: CatchBadgeTone.warning,
    ),
    _ when attended => (
      label: l10n.hostsHostEventManageScreenStateLabelIn,
      tone: CatchBadgeTone.success,
    ),
    _ => (
      label: l10n.hostsHostEventManageScreenStateLabelDue,
      tone: CatchBadgeTone.neutral,
    ),
  };
}

({String label, CatchBadgeTone tone}) _reportAttendance(
  EventParticipation? participation,
  bool attended,
  AppLocalizations l10n,
) {
  final status = participation?.status;
  final offerStatus = participation?.waitlistOfferStatus;
  return switch (status) {
    EventParticipationStatus.waitlisted
        when offerStatus == EventWaitlistOfferStatus.active =>
      (
        label: l10n.hostsHostEventManageScreenStateLabelOffered,
        tone: CatchBadgeTone.brand,
      ),
    EventParticipationStatus.waitlisted
        when offerStatus == EventWaitlistOfferStatus.accepted =>
      (
        label: l10n.hostsHostEventManageScreenStateLabelAccepted,
        tone: CatchBadgeTone.success,
      ),
    EventParticipationStatus.waitlisted
        when offerStatus == EventWaitlistOfferStatus.expired =>
      (
        label: l10n.hostsHostEventManageScreenStateLabelExpired,
        tone: CatchBadgeTone.neutral,
      ),
    EventParticipationStatus.waitlisted => (
      label: l10n.hostsHostEventManageScreenStateLabelWait,
      tone: CatchBadgeTone.warning,
    ),
    _ when attended => (
      label: l10n.hostsHostEventManageScreenStateLabelAttended,
      tone: CatchBadgeTone.success,
    ),
    _ => (
      label: l10n.hostsHostEventManageScreenStateLabelNoShow,
      tone: CatchBadgeTone.neutral,
    ),
  };
}

({String label, CatchBadgeTone tone}) _setupSignal(
  EventParticipation? participation,
  bool usesRequestApproval,
  AppLocalizations l10n,
) {
  final offerStatus = participation?.waitlistOfferStatus;
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.active) {
    return (
      label: l10n.hostsHostEventManageScreenStateLabelOffered,
      tone: CatchBadgeTone.brand,
    );
  }
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.accepted) {
    return (
      label: l10n.hostsHostEventManageScreenStateLabelAccepted,
      tone: CatchBadgeTone.success,
    );
  }
  return switch (participation?.status) {
    EventParticipationStatus.attended || EventParticipationStatus.signedUp => (
      label: l10n.hostsHostEventManageScreenStateLabelBooked,
      tone: CatchBadgeTone.success,
    ),
    EventParticipationStatus.waitlisted when usesRequestApproval => (
      label: l10n.hostsHostEventManageScreenStateLabelRequest,
      tone: CatchBadgeTone.brand,
    ),
    EventParticipationStatus.waitlisted => (
      label: l10n.hostsHostEventManageScreenStateLabelWait,
      tone: CatchBadgeTone.warning,
    ),
    _ => (
      label: l10n.hostsHostEventManageScreenStateLabelNew,
      tone: CatchBadgeTone.neutral,
    ),
  };
}

String _setupMeta(
  EventParticipation? participation,
  bool usesRequestApproval,
  AppLocalizations l10n,
) {
  final offerStatus = participation?.waitlistOfferStatus;
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.active) {
    return l10n.hostsHostEventManageScreenStateVisiblecopyOfferSent;
  }
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.accepted) {
    return l10n.hostsHostEventManageScreenStateVisiblecopyAcceptedOffer;
  }
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.expired) {
    return l10n.hostsHostEventManageScreenStateVisiblecopyOfferExpired;
  }
  return switch (participation?.status) {
    EventParticipationStatus.attended || EventParticipationStatus.signedUp =>
      l10n.hostsHostEventManageScreenStateVisiblecopyApproved,
    EventParticipationStatus.waitlisted when usesRequestApproval =>
      l10n.hostsHostEventManageScreenStateVisiblecopyViewProfile,
    EventParticipationStatus.waitlisted =>
      l10n.hostsHostEventManageScreenStateVisiblecopyWaitlisted,
    _ => l10n.hostsHostEventManageScreenStateVisiblecopyProfileReady,
  };
}

String _reportMeta(EventParticipation? participation, AppLocalizations l10n) {
  final status = participation?.status;
  final offerStatus = participation?.waitlistOfferStatus;
  if (status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.active) {
    return l10n.hostsHostEventManageScreenStateVisiblecopyOfferSent;
  }
  if (status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.accepted) {
    return l10n.hostsHostEventManageScreenStateVisiblecopyAcceptedOffer;
  }
  if (status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.expired) {
    return l10n.hostsHostEventManageScreenStateVisiblecopyOfferExpired;
  }
  return switch (status) {
    EventParticipationStatus.waitlisted =>
      l10n.hostsHostEventManageScreenStateVisiblecopyWaitlisted,
    EventParticipationStatus.attended || EventParticipationStatus.signedUp =>
      l10n.hostsHostEventManageScreenStateVisiblecopyBooked,
    EventParticipationStatus.cancelled =>
      l10n.hostsHostEventManageScreenStateVisiblecopyCancelled,
    EventParticipationStatus.deleted =>
      l10n.hostsHostEventManageScreenStateVisiblecopyDeleted,
    null => l10n.hostsHostEventManageScreenStateVisiblecopyParticipant,
  };
}
