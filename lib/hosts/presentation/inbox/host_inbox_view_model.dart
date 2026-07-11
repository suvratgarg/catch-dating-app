import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:flutter/foundation.dart';

enum HostInboxAudienceSegment { booked, prospective }

enum HostInboxScopeKind { event, general }

@immutable
class HostInboxScope {
  const HostInboxScope.general()
    : kind = HostInboxScopeKind.general,
      eventId = null;

  const HostInboxScope.event(String this.eventId)
    : kind = HostInboxScopeKind.event;

  final HostInboxScopeKind kind;
  final String? eventId;

  bool get isGeneral => kind == HostInboxScopeKind.general;

  @override
  bool operator ==(Object other) =>
      other is HostInboxScope && other.kind == kind && other.eventId == eventId;

  @override
  int get hashCode => Object.hash(kind, eventId);
}

@immutable
class HostInboxThreadRowData {
  const HostInboxThreadRowData({
    required this.preview,
    required this.statusLabel,
  });

  final ChatThreadPreview preview;
  final String statusLabel;

  String get supportingText => '$statusLabel · ${preview.previewText}';
}

@immutable
class HostInboxViewModel {
  const HostInboxViewModel({
    required this.events,
    required this.scopeOptions,
    required this.selectedScope,
    required this.selectedEvent,
    required this.selectedSegment,
    required this.threads,
    required this.bookedThreadCount,
    required this.prospectiveThreadCount,
    required this.bookedAudienceCount,
    required this.prospectiveAudienceCount,
    required this.unfilteredSelectedThreadCount,
    required this.query,
    required this.broadcastLifecycleAvailable,
  });

  factory HostInboxViewModel.compose({
    required List<Event> events,
    required ChatsListViewModel inbox,
    required List<EventParticipation> participations,
    required HostInboxScope selectedScope,
    required HostInboxAudienceSegment selectedSegment,
    required String query,
    required DateTime now,
  }) {
    final orderedEvents = orderHostInboxEvents(events, now: now);
    final eventsById = {for (final event in orderedEvents) event.id: event};
    final selectedEvent = selectedScope.eventId == null
        ? null
        : eventsById[selectedScope.eventId];
    final effectiveScope = selectedEvent == null
        ? const HostInboxScope.general()
        : selectedScope;
    final scopeOptions = <HostInboxScope>[
      for (final event in orderedEvents) HostInboxScope.event(event.id),
      const HostInboxScope.general(),
    ];
    final allThreads = [...inbox.newMatches, ...inbox.conversations];

    if (selectedEvent == null) {
      final generalThreads = allThreads
          .where((preview) => preview.eventIds.isEmpty)
          .map(
            (preview) => HostInboxThreadRowData(
              preview: preview,
              statusLabel: 'General inquiry',
            ),
          )
          .toList(growable: false);
      final filtered = _filterRows(generalThreads, query);
      return HostInboxViewModel(
        events: orderedEvents,
        scopeOptions: List.unmodifiable(scopeOptions),
        selectedScope: effectiveScope,
        selectedEvent: null,
        selectedSegment: selectedSegment,
        threads: List.unmodifiable(filtered),
        bookedThreadCount: 0,
        prospectiveThreadCount: 0,
        bookedAudienceCount: 0,
        prospectiveAudienceCount: 0,
        unfilteredSelectedThreadCount: generalThreads.length,
        query: query.trim(),
        broadcastLifecycleAvailable: false,
      );
    }

    final eventParticipations = participations
        .where((participation) => participation.eventId == selectedEvent.id)
        .toList(growable: false);
    final participationByUid = <String, EventParticipation>{
      for (final participation in eventParticipations)
        participation.uid: participation,
    };
    final roster = EventParticipationRoster.fromParticipations(
      eventParticipations,
    );
    final bookedIds = roster.bookedIds.toSet();
    final eventThreads = allThreads
        .where((preview) => preview.eventIds.contains(selectedEvent.id))
        .toList(growable: false);
    final bookedThreads = eventThreads
        .where((preview) => bookedIds.contains(preview.otherUid))
        .toList(growable: false);
    final prospectiveThreads = eventThreads
        .where((preview) => !bookedIds.contains(preview.otherUid))
        .toList(growable: false);
    final selectedThreads = selectedSegment == HostInboxAudienceSegment.booked
        ? bookedThreads
        : prospectiveThreads;
    final rows = selectedThreads
        .map(
          (preview) => HostInboxThreadRowData(
            preview: preview,
            statusLabel: _statusLabelFor(
              participationByUid[preview.otherUid],
              selectedSegment,
            ),
          ),
        )
        .toList(growable: false);

    return HostInboxViewModel(
      events: orderedEvents,
      scopeOptions: List.unmodifiable(scopeOptions),
      selectedScope: effectiveScope,
      selectedEvent: selectedEvent,
      selectedSegment: selectedSegment,
      threads: List.unmodifiable(_filterRows(rows, query)),
      bookedThreadCount: bookedThreads.length,
      prospectiveThreadCount: prospectiveThreads.length,
      bookedAudienceCount: roster.bookedCount,
      prospectiveAudienceCount: roster.waitlistedCount,
      unfilteredSelectedThreadCount: rows.length,
      query: query.trim(),
      broadcastLifecycleAvailable:
          !selectedEvent.isCancelled && selectedEvent.endTime.isAfter(now),
    );
  }

  final List<Event> events;
  final List<HostInboxScope> scopeOptions;
  final HostInboxScope selectedScope;
  final Event? selectedEvent;
  final HostInboxAudienceSegment selectedSegment;
  final List<HostInboxThreadRowData> threads;
  final int bookedThreadCount;
  final int prospectiveThreadCount;
  final int bookedAudienceCount;
  final int prospectiveAudienceCount;
  final int unfilteredSelectedThreadCount;
  final String query;
  final bool broadcastLifecycleAvailable;

  bool get isGeneral => selectedEvent == null;
  bool get hasSearchResults => threads.isNotEmpty;
  bool get hasUnfilteredThreads => unfilteredSelectedThreadCount > 0;
  int get selectedAudienceCount =>
      selectedSegment == HostInboxAudienceSegment.booked
      ? bookedAudienceCount
      : prospectiveAudienceCount;
  int get everyoneAudienceCount =>
      bookedAudienceCount + prospectiveAudienceCount;
}

HostInboxScope resolveHostInboxScope({
  required List<Event> events,
  required DateTime now,
  HostInboxScope? requestedScope,
  String? initialEventId,
  bool preferGeneral = false,
}) {
  final byId = {for (final event in events) event.id: event};
  final requestedEventId = requestedScope?.eventId ?? initialEventId;
  if (requestedEventId != null && byId.containsKey(requestedEventId)) {
    return HostInboxScope.event(requestedEventId);
  }
  if (requestedScope?.isGeneral == true || preferGeneral) {
    return const HostInboxScope.general();
  }
  final defaultEvent = orderHostInboxEvents(events, now: now)
      .where((event) => !event.isCancelled && event.endTime.isAfter(now))
      .firstOrNull;
  return defaultEvent == null
      ? const HostInboxScope.general()
      : HostInboxScope.event(defaultEvent.id);
}

List<Event> orderHostInboxEvents(List<Event> events, {required DateTime now}) {
  final ordered = events.where((event) => !event.isCancelled).toList();
  ordered.sort((a, b) {
    final aRank = _eventRank(a, now);
    final bRank = _eventRank(b, now);
    if (aRank != bRank) return aRank.compareTo(bRank);
    if (aRank == 2) return b.startTime.compareTo(a.startTime);
    return a.startTime.compareTo(b.startTime);
  });
  return List.unmodifiable(ordered);
}

int _eventRank(Event event, DateTime now) {
  if (!event.startTime.isAfter(now) && event.endTime.isAfter(now)) return 0;
  if (event.startTime.isAfter(now)) return 1;
  return 2;
}

List<HostInboxThreadRowData> _filterRows(
  List<HostInboxThreadRowData> rows,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return rows;
  return rows
      .where(
        (row) => row.preview.displayName.toLowerCase().contains(normalized),
      )
      .toList(growable: false);
}

String _statusLabelFor(
  EventParticipation? participation,
  HostInboxAudienceSegment segment,
) {
  if (participation == null) return 'Inquiry';
  if (segment == HostInboxAudienceSegment.booked) {
    return participation.status == EventParticipationStatus.attended
        ? 'Checked in'
        : 'Booked';
  }
  if (participation.hostApprovalStatus == EventJoinRequestStatus.pending) {
    return 'Requested';
  }
  return switch (participation.waitlistOfferStatus) {
    EventWaitlistOfferStatus.active => 'Offered',
    EventWaitlistOfferStatus.accepted => 'Accepted',
    _ => 'Waitlist',
  };
}
