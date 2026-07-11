import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:flutter/material.dart';

enum HostHomeTab { today, events }

typedef HostHomeCreateEventCallback = void Function(Club club);
typedef HostHomeRepeatEventCallback = void Function(Club club, Event event);
typedef HostHomeManageEventCallback = void Function(Club club, Event event);
typedef HostHomeOpenTaskCallback =
    void Function(Club club, Event event, HostHomeTodayTaskData task);

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
    required this.selectedTab,
  });

  factory HostHomeScreenState.resolve({
    required List<Club> clubs,
    required String currentUid,
    int selectedClubIndex = 0,
    String? selectedClubId,
    HostHomeTab selectedTab = HostHomeTab.today,
  }) {
    return HostHomeScreenState._(
      clubs: List<Club>.unmodifiable(clubs),
      currentUid: currentUid,
      selectedClubIndex: _resolveSelectedClubIndex(
        clubs: clubs,
        selectedClubIndex: selectedClubIndex,
        selectedClubId: selectedClubId,
      ),
      selectedTab: selectedTab,
    );
  }

  final List<Club> clubs;
  final String currentUid;
  final int selectedClubIndex;
  final HostHomeTab selectedTab;

  bool get hasClubs => clubs.isNotEmpty;
  bool get showClubPicker => clubs.length > 1;
  Club? get selectedClub => hasClubs ? clubs[selectedClubIndex] : null;
  String get title => selectedClub?.name ?? 'Host events';
  bool get selectedClubIsOwner => selectedClub?.isOwnedBy(currentUid) ?? false;
  String get selectedClubRoleLabel =>
      selectedClubIsOwner ? 'Owner' : 'Host team';

  HostHomeScreenState selectClubIndex(int index) {
    return HostHomeScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: index,
      selectedTab: selectedTab,
    );
  }

  HostHomeScreenState selectTab(HostHomeTab tab) {
    return HostHomeScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: selectedClubIndex,
      selectedTab: tab,
    );
  }
}

enum HostEventsLifecycleFilter {
  upcoming('Upcoming'),
  live('Live'),
  past('Past');

  const HostEventsLifecycleFilter(this.label);

  final String label;
}

enum HostEventsWorkspaceStatus { loading, error, empty, populated }

@immutable
class HostEventsWorkspaceState {
  const HostEventsWorkspaceState({
    required this.status,
    required this.selectedFilter,
    this.sections = const <HostEventsMonthSection>[],
    this.repeatSource,
    this.error,
    this.stackTrace,
  });

  factory HostEventsWorkspaceState.fromEvents({
    required Iterable<Event> events,
    required DateTime now,
    required HostEventsLifecycleFilter selectedFilter,
  }) {
    final active = events.where((event) => !event.isCancelled).toList();
    final past = active.where((event) => !event.endTime.isAfter(now)).toList()
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
    final repeatSource = past.where(_canRepeatEvent).firstOrNull;
    final filtered = switch (selectedFilter) {
      HostEventsLifecycleFilter.upcoming =>
        active.where((event) => event.startTime.isAfter(now)).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime)),
      HostEventsLifecycleFilter.live =>
        active
            .where(
              (event) =>
                  !event.startTime.isAfter(now) && event.endTime.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime)),
      HostEventsLifecycleFilter.past => past,
    };
    final sectionsByMonth = <String, List<HostEventLifecycleRowData>>{};
    for (final event in filtered) {
      final key = '${event.startTime.year}-${event.startTime.month}';
      sectionsByMonth
          .putIfAbsent(key, () => <HostEventLifecycleRowData>[])
          .add(HostEventLifecycleRowData.fromEvent(event: event, now: now));
    }
    final sections = <HostEventsMonthSection>[
      for (final entry in sectionsByMonth.entries)
        HostEventsMonthSection(
          key: entry.key,
          label: _monthSectionLabel(entry.value.first.event.startTime, now),
          rows: List<HostEventLifecycleRowData>.unmodifiable(entry.value),
        ),
    ];

    return HostEventsWorkspaceState(
      status: sections.isEmpty
          ? HostEventsWorkspaceStatus.empty
          : HostEventsWorkspaceStatus.populated,
      selectedFilter: selectedFilter,
      sections: List<HostEventsMonthSection>.unmodifiable(sections),
      repeatSource: repeatSource,
    );
  }

  final HostEventsWorkspaceStatus status;
  final HostEventsLifecycleFilter selectedFilter;
  final List<HostEventsMonthSection> sections;
  final Event? repeatSource;
  final Object? error;
  final StackTrace? stackTrace;

  bool get canRepeat => repeatSource != null;

  String get repeatLabel {
    final event = repeatSource;
    if (event == null) return 'Repeat last';
    final label = event.eventFormat.label.trim();
    return label.isEmpty ? 'Repeat last' : 'Repeat ‘$label’';
  }

  String get emptyTitle => switch (selectedFilter) {
    HostEventsLifecycleFilter.upcoming => 'No upcoming events',
    HostEventsLifecycleFilter.live => 'Nothing live right now',
    HostEventsLifecycleFilter.past => 'No past events yet',
  };

  String get emptyBody => switch (selectedFilter) {
    HostEventsLifecycleFilter.upcoming =>
      'Create your next event to start filling this list.',
    HostEventsLifecycleFilter.live =>
      'Your next event appears here when it starts.',
    HostEventsLifecycleFilter.past =>
      'Completed events and their attendance will appear here.',
  };
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

enum HostHomeTodayStatus { loading, error, empty, content }

@immutable
class HostHomeTodayDashboardState {
  const HostHomeTodayDashboardState({
    required this.status,
    this.event,
    this.laterEvents = const <HostEventLifecycleRowData>[],
    this.tasks = const <HostHomeTodayTaskData>[],
    this.error,
    this.stackTrace,
  });

  final HostHomeTodayStatus status;
  final Event? event;
  final List<HostEventLifecycleRowData> laterEvents;
  final List<HostHomeTodayTaskData> tasks;
  final Object? error;
  final StackTrace? stackTrace;
}

@immutable
class HostHomeTodayTaskData {
  const HostHomeTodayTaskData({
    required this.id,
    required this.event,
    required this.title,
    required this.body,
    required this.primaryActionLabel,
    required this.icon,
    required this.destination,
  });

  factory HostHomeTodayTaskData.reviewWaitlist(Event event) {
    final waitlistCount = event.waitlistCount;
    final availability = event.spotsRemaining > 0
        ? '${event.spotsRemaining} spots open'
        : 'event full';
    return HostHomeTodayTaskData(
      id: 'waitlist:${event.id}',
      event: event,
      title: 'Review waitlist',
      body: '${event.title}\n$waitlistCount waiting · $availability',
      primaryActionLabel: 'Review',
      icon: CatchIcons.personSearchOutlined,
      destination: HostHomeTodayTaskDestination.guests,
    );
  }

  static List<HostHomeTodayTaskData> forEvent(Event event) {
    return event.waitlistCount > 0 &&
            !event.effectiveEventPolicy.admissionPolicy.manualApprovalRequired
        ? <HostHomeTodayTaskData>[HostHomeTodayTaskData.reviewWaitlist(event)]
        : const <HostHomeTodayTaskData>[];
  }

  static List<HostHomeTodayTaskData> forEvents(Iterable<Event> events) =>
      List<HostHomeTodayTaskData>.unmodifiable(
        events.expand(HostHomeTodayTaskData.forEvent),
      );

  final String id;
  final Event event;
  final String title;
  final String body;
  final String primaryActionLabel;
  final IconData icon;
  final HostHomeTodayTaskDestination destination;
}

enum HostHomeTodayTaskDestination { guests, setup }

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
