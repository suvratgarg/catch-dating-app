import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HostHomeTab { today, events }

typedef HostHomeCreateEventCallback = void Function(Club club);
typedef HostHomeManageEventCallback = void Function(Club club, Event event);

enum HostHomeRouteStatus { authRequired, loading, error, empty, loaded }

@immutable
class HostHomeRouteState {
  const HostHomeRouteState._({
    required this.status,
    this.uid,
    this.clubs = const [],
    this.error,
    this.stackTrace,
    this.errorContext = AppErrorContext.club,
  });

  factory HostHomeRouteState.fromAsync({
    required AsyncValue<String?> uid,
    AsyncValue<List<Club>>? clubs,
  }) {
    if (uid.hasError) {
      return HostHomeRouteState._(
        status: HostHomeRouteStatus.error,
        error: uid.error,
        stackTrace: uid.stackTrace,
        errorContext: AppErrorContext.auth,
      );
    }

    final currentUid = uid.asData?.value;
    if (currentUid == null) {
      return uid.isLoading
          ? const HostHomeRouteState._(status: HostHomeRouteStatus.loading)
          : const HostHomeRouteState._(
              status: HostHomeRouteStatus.authRequired,
            );
    }

    final clubValue = clubs;
    if (clubValue == null || clubValue.isLoading) {
      return HostHomeRouteState._(
        status: HostHomeRouteStatus.loading,
        uid: currentUid,
      );
    }
    if (clubValue.hasError) {
      return HostHomeRouteState._(
        status: HostHomeRouteStatus.error,
        uid: currentUid,
        error: clubValue.error,
        stackTrace: clubValue.stackTrace,
      );
    }

    final resolvedClubs = List<Club>.unmodifiable(
      clubValue.asData?.value ?? const <Club>[],
    );
    return HostHomeRouteState._(
      status: resolvedClubs.isEmpty
          ? HostHomeRouteStatus.empty
          : HostHomeRouteStatus.loaded,
      uid: currentUid,
      clubs: resolvedClubs,
    );
  }

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

@immutable
class HostHomeEventRowsState {
  const HostHomeEventRowsState._({required this.rows});

  factory HostHomeEventRowsState.fromEvents(
    Iterable<Event> events, {
    int limit = 3,
  }) {
    final activeEvents = events.where((event) => !event.isCancelled).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final visibleEvents = activeEvents.take(limit).toList(growable: false);
    return HostHomeEventRowsState._(
      rows: [
        for (var index = 0; index < visibleEvents.length; index++)
          HostHomeEventRowData(event: visibleEvents[index], divider: index > 0),
      ],
    );
  }

  final List<HostHomeEventRowData> rows;

  bool get isEmpty => rows.isEmpty;
}

@immutable
class HostHomeEventRowData {
  const HostHomeEventRowData({required this.event, required this.divider});

  final Event event;
  final bool divider;

  String get title => event.title;
  String get timeRangeLabel => event.timeRangeLabel;
}

enum HostHomeEventsStatus { loading, error, empty, populated }

@immutable
class HostHomeEventsSectionState {
  const HostHomeEventsSectionState._({
    required this.status,
    this.rows = const HostHomeEventRowsState._(rows: []),
    this.error,
    this.stackTrace,
  });

  factory HostHomeEventsSectionState.fromAsync(AsyncValue<List<Event>> events) {
    if (events.isLoading) {
      return const HostHomeEventsSectionState._(
        status: HostHomeEventsStatus.loading,
      );
    }
    if (events.hasError) {
      return HostHomeEventsSectionState._(
        status: HostHomeEventsStatus.error,
        error: events.error,
        stackTrace: events.stackTrace,
      );
    }

    final rows = HostHomeEventRowsState.fromEvents(
      events.asData?.value ?? const <Event>[],
    );
    return HostHomeEventsSectionState._(
      status: rows.isEmpty
          ? HostHomeEventsStatus.empty
          : HostHomeEventsStatus.populated,
      rows: rows,
    );
  }

  final HostHomeEventsStatus status;
  final HostHomeEventRowsState rows;
  final Object? error;
  final StackTrace? stackTrace;
}

enum HostHomeTodayStatus { loading, error, empty, content }

@immutable
class HostHomeTodayDashboardState {
  const HostHomeTodayDashboardState._({
    required this.status,
    this.event,
    this.tasks = const <HostHomeTodayTaskData>[],
    this.error,
    this.stackTrace,
  });

  factory HostHomeTodayDashboardState.fromAsync(
    AsyncValue<List<Event>> events,
  ) {
    if (events.isLoading) {
      return const HostHomeTodayDashboardState._(
        status: HostHomeTodayStatus.loading,
      );
    }
    if (events.hasError) {
      return HostHomeTodayDashboardState._(
        status: HostHomeTodayStatus.error,
        error: events.error,
        stackTrace: events.stackTrace,
      );
    }

    final activeEvents = events.asData?.value
        .where((event) => !event.isCancelled)
        .toList();
    activeEvents?.sort((a, b) => a.startTime.compareTo(b.startTime));
    final event = activeEvents?.firstOrNull;
    if (event == null) {
      return const HostHomeTodayDashboardState._(
        status: HostHomeTodayStatus.empty,
      );
    }

    return HostHomeTodayDashboardState._(
      status: HostHomeTodayStatus.content,
      event: event,
      tasks: HostHomeTodayTaskData.forEvent(event),
    );
  }

  final HostHomeTodayStatus status;
  final Event? event;
  final List<HostHomeTodayTaskData> tasks;
  final Object? error;
  final StackTrace? stackTrace;
}

@immutable
class HostHomeTodayTaskData {
  const HostHomeTodayTaskData({
    required this.title,
    required this.body,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.icon,
  });

  factory HostHomeTodayTaskData.approveRequests(Event event) {
    final waitlistCount = event.waitlistCount;
    return HostHomeTodayTaskData(
      title: 'Approve requests',
      body: waitlistCount > 0
          ? '$waitlistCount people want into ${event.title}'
          : 'Review pending guest requests before the event opens.',
      primaryActionLabel: 'Approve',
      secondaryActionLabel: 'Later',
      icon: CatchIcons.personSearchOutlined,
    );
  }

  factory HostHomeTodayTaskData.offerWaitlist(Event event) {
    final waitlistCount = event.waitlistCount;
    final openCount = event.spotsRemaining;
    return HostHomeTodayTaskData(
      title: 'Offer waitlist spots',
      body: waitlistCount > 0
          ? '$waitlistCount waiting · $openCount spots open'
          : 'No waitlist pressure right now.',
      primaryActionLabel: waitlistCount > 0 ? 'Offer $waitlistCount' : 'Review',
      secondaryActionLabel: 'Later',
      icon: CatchIcons.groupAddOutlined,
    );
  }

  factory HostHomeTodayTaskData.guestWaiting(Event event) {
    return HostHomeTodayTaskData(
      title: 'A guest is waiting on you',
      body: 'Reply before ${EventFormatters.time(event.startTime)}.',
      primaryActionLabel: 'Reply',
      secondaryActionLabel: 'Later',
      icon: CatchIcons.chatBubbleOutlineRounded,
    );
  }

  factory HostHomeTodayTaskData.hostSetup(Event event) {
    return HostHomeTodayTaskData(
      title: 'Check host setup',
      body: 'Confirm entry flow, venue notes, and host cues.',
      primaryActionLabel: 'Check',
      secondaryActionLabel: 'Later',
      icon: CatchIcons.factCheckOutlined,
    );
  }

  static List<HostHomeTodayTaskData> forEvent(Event event) {
    final tasks = <HostHomeTodayTaskData>[];
    if (event.waitlistCount > 0) {
      tasks.add(HostHomeTodayTaskData.approveRequests(event));
      tasks.add(HostHomeTodayTaskData.offerWaitlist(event));
    }
    tasks.add(HostHomeTodayTaskData.guestWaiting(event));
    tasks.add(HostHomeTodayTaskData.hostSetup(event));
    return tasks;
  }

  final String title;
  final String body;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final IconData icon;
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
