import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

typedef HostHomeCreateEventCallback = void Function(Club club);
typedef HostHomeRepeatEventCallback = void Function(Club club, Event event);
typedef HostHomeManageEventCallback = void Function(Club club, Event event);

enum HostHomeRouteStatus { authRequired, loading, error, empty, loaded }

@immutable
class HostHomeRouteState {
  const HostHomeRouteState({
    required this.status,
    this.uid,
    this.clubs = const [],
    this.error,
    this.stackTrace,
    this.errorContext = AppErrorContext.club,
  });

  final HostHomeRouteStatus status;
  final String? uid;
  final List<Club> clubs;
  final Object? error;
  final StackTrace? stackTrace;
  final AppErrorContext errorContext;
}

@immutable
class HostHomeScreenState {
  const HostHomeScreenState._({
    required this.clubs,
    required this.currentUid,
    required this.selectedClubIndex,
  });

  factory HostHomeScreenState.resolve({
    required List<Club> clubs,
    required String currentUid,
    int selectedClubIndex = 0,
    String? selectedClubId,
  }) {
    return HostHomeScreenState._(
      clubs: List<Club>.unmodifiable(clubs),
      currentUid: currentUid,
      selectedClubIndex: _resolveSelectedClubIndex(
        clubs: clubs,
        selectedClubIndex: selectedClubIndex,
        selectedClubId: selectedClubId,
      ),
    );
  }

  final List<Club> clubs;
  final String currentUid;
  final int selectedClubIndex;

  bool get hasClubs => clubs.isNotEmpty;
  bool get showClubPicker => clubs.length > 1;
  Club? get selectedClub => hasClubs ? clubs[selectedClubIndex] : null;
  bool get selectedClubIsOwner => selectedClub?.isOwnedBy(currentUid) ?? false;

  HostHomeScreenState selectClubIndex(int index) {
    return HostHomeScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: index,
    );
  }
}

enum HostEventsWorkspaceStatus { loading, error, empty, populated }

@immutable
class HostEventsWorkspaceState {
  const HostEventsWorkspaceState({
    required this.status,
    this.activeSections = const <HostEventsMonthSection>[],
    this.pastSections = const <HostEventsMonthSection>[],
    this.repeatSource,
    this.hasMoreActive = false,
    this.hasMorePast = false,
    this.loadingMoreActive = false,
    this.loadingMorePast = false,
    this.activeLoadMoreError,
    this.pastError,
    this.pastStackTrace,
    this.error,
    this.stackTrace,
  });

  factory HostEventsWorkspaceState.fromEvents({
    required Iterable<Event> events,
    required DateTime now,
    String? featuredEventId,
    bool hasMoreActive = false,
    bool hasMorePast = false,
    bool loadingMoreActive = false,
    bool loadingMorePast = false,
    Object? activeLoadMoreError,
    Object? pastError,
    StackTrace? pastStackTrace,
  }) {
    final active = events.where((event) => !event.isCancelled).toList();
    final past = active.where((event) => !event.endTime.isAfter(now)).toList()
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
    final repeatSource = past.where(_canRepeatEvent).firstOrNull;
    final currentAndUpcoming =
        active.where((event) => event.endTime.isAfter(now)).toList()
          ..sort((a, b) {
            final aLive = !a.startTime.isAfter(now);
            final bLive = !b.startTime.isAfter(now);
            if (aLive != bLive) return aLive ? -1 : 1;
            return a.startTime.compareTo(b.startTime);
          });
    final visibleActive = featuredEventId == null
        ? currentAndUpcoming
        : currentAndUpcoming.where((event) => event.id != featuredEventId);

    final activeSections = _eventMonthSections(visibleActive, now);
    final pastSections = _eventMonthSections(past, now);

    return HostEventsWorkspaceState(
      // The operational spotlight is the richer representation of the
      // featured event, so the timeline remains populated when it has no
      // additional condensed rows.
      status:
          currentAndUpcoming.isEmpty &&
              past.isEmpty &&
              !hasMoreActive &&
              !hasMorePast &&
              activeLoadMoreError == null &&
              pastError == null
          ? HostEventsWorkspaceStatus.empty
          : HostEventsWorkspaceStatus.populated,
      activeSections: activeSections,
      pastSections: pastSections,
      repeatSource: repeatSource,
      hasMoreActive: hasMoreActive,
      hasMorePast: hasMorePast,
      loadingMoreActive: loadingMoreActive,
      loadingMorePast: loadingMorePast,
      activeLoadMoreError: activeLoadMoreError,
      pastError: pastError,
      pastStackTrace: pastStackTrace,
    );
  }

  final HostEventsWorkspaceStatus status;
  final List<HostEventsMonthSection> activeSections;
  final List<HostEventsMonthSection> pastSections;
  final Event? repeatSource;
  final bool hasMoreActive;
  final bool hasMorePast;
  final bool loadingMoreActive;
  final bool loadingMorePast;
  final Object? activeLoadMoreError;
  final Object? pastError;
  final StackTrace? pastStackTrace;
  final Object? error;
  final StackTrace? stackTrace;

  bool get canRepeat => repeatSource != null;
  bool get canLoadMoreActive => hasMoreActive && !loadingMoreActive;
  bool get canLoadMorePast => hasMorePast && !loadingMorePast;

  String repeatLabel(AppLocalizations l10n) {
    final event = repeatSource;
    if (event == null) {
      return l10n.hostsHostHomeScreenStateVisiblecopyRepeatLast;
    }
    final label = event.eventFormat.label.trim();
    return label.isEmpty
        ? l10n.hostsHostHomeScreenStateVisiblecopyRepeatLast
        : l10n.hostsHostHomeScreenStateVisiblecopyRepeatLabel(label: label);
  }

  String emptyTitle(AppLocalizations l10n) =>
      l10n.hostsHostHomeScreenStateEmptytitleNoUpcomingEvents;

  String emptyBody(AppLocalizations l10n) =>
      l10n.hostsHostHomeScreenStateEmptybodyCreateYourNextEvent;
}

List<HostEventsMonthSection> _eventMonthSections(
  Iterable<Event> events,
  DateTime now,
) {
  final sectionsByMonth = <String, List<HostEventLifecycleRowData>>{};
  for (final event in events) {
    final key = '${event.startTime.year}-${event.startTime.month}';
    sectionsByMonth
        .putIfAbsent(key, () => <HostEventLifecycleRowData>[])
        .add(HostEventLifecycleRowData.fromEvent(event: event, now: now));
  }
  return List<HostEventsMonthSection>.unmodifiable([
    for (final entry in sectionsByMonth.entries)
      HostEventsMonthSection(
        key: entry.key,
        label: _monthSectionLabel(entry.value.first.event.startTime, now),
        rows: List<HostEventLifecycleRowData>.unmodifiable(entry.value),
      ),
  ]);
}

@immutable
class HostEventsMonthSection {
  const HostEventsMonthSection({
    required this.key,
    required this.label,
    required this.rows,
  });

  final String key;
  final String label;
  final List<HostEventLifecycleRowData> rows;
}

@immutable
class HostEventLifecycleRowData {
  const HostEventLifecycleRowData({
    required this.event,
    required this.isToday,
    required this.isLive,
    required this.isPast,
    required this.fillRatio,
  });

  factory HostEventLifecycleRowData.fromEvent({
    required Event event,
    required DateTime now,
  }) {
    final capacity = event.capacityLimit;
    final fillRatio = capacity <= 0
        ? 0.0
        : (event.signedUpCount / capacity).clamp(0.0, 1.0);
    return HostEventLifecycleRowData(
      event: event,
      isToday: DateUtils.isSameDay(event.startTime, now),
      isLive: !event.startTime.isAfter(now) && event.endTime.isAfter(now),
      isPast: !event.endTime.isAfter(now),
      fillRatio: fillRatio,
    );
  }

  final Event event;
  final bool isToday;
  final bool isLive;
  final bool isPast;
  final double fillRatio;

  String get dateLabel => '${event.startTime.day}'.padLeft(2, '0');
  String get monthLabel =>
      EventFormatters.shortMonth(event.startTime).toUpperCase();
  int get fillPercent => (fillRatio * 100).round();

  String get metaLabel {
    if (isLive) return 'Live · ${event.signedUpCount} going';
    if (isPast) {
      final price = event.isFree
          ? 'free'
          : EventFormatters.priceInPaise(
              event.priceInPaise,
              currencyCode: event.currency,
            );
      return '${event.attendedCount} attended · $fillPercent% full · $price';
    }
    if (isToday) return 'Today · ${event.signedUpCount} going';
    return '${EventFormatters.shortWeekday(event.startTime)} · '
        '${EventFormatters.time(event.startTime)} · $fillPercent% full';
  }
}

bool _canRepeatEvent(Event event) => CreateEventPrefill.canRepeat(event);

String _monthSectionLabel(DateTime date, DateTime now) {
  final month = EventFormatters.longMonth(date);
  return date.year == now.year ? month : '$month ${date.year}';
}

int _resolveSelectedClubIndex({
  required List<Club> clubs,
  required int selectedClubIndex,
  String? selectedClubId,
}) {
  if (clubs.isEmpty) return 0;
  final selectedId = selectedClubId;
  if (selectedId != null) {
    final index = clubs.indexWhere((club) => club.id == selectedId);
    if (index != -1) return index;
  }
  if (selectedClubIndex < 0) return 0;
  if (selectedClubIndex >= clubs.length) return clubs.length - 1;
  return selectedClubIndex;
}
