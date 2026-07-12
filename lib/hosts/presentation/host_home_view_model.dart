import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

HostHomeRouteState buildHostHomeRouteState({
  required AsyncValue<String?> uid,
  AsyncValue<List<Club>>? clubs,
}) {
  if (uid.hasError) {
    return HostHomeRouteState(
      status: HostHomeRouteStatus.error,
      error: uid.error,
      stackTrace: uid.stackTrace,
      errorContext: AppErrorContext.auth,
    );
  }

  final currentUid = uid.asData?.value;
  if (currentUid == null) {
    return uid.isLoading
        ? const HostHomeRouteState(status: HostHomeRouteStatus.loading)
        : const HostHomeRouteState(status: HostHomeRouteStatus.authRequired);
  }

  final clubValue = clubs;
  if (clubValue == null || clubValue.isLoading) {
    return HostHomeRouteState(
      status: HostHomeRouteStatus.loading,
      uid: currentUid,
    );
  }
  if (clubValue.hasError) {
    return HostHomeRouteState(
      status: HostHomeRouteStatus.error,
      uid: currentUid,
      error: clubValue.error,
      stackTrace: clubValue.stackTrace,
    );
  }

  final resolvedClubs = List<Club>.unmodifiable(
    clubValue.asData?.value ?? const <Club>[],
  );
  return HostHomeRouteState(
    status: resolvedClubs.isEmpty
        ? HostHomeRouteStatus.empty
        : HostHomeRouteStatus.loaded,
    uid: currentUid,
    clubs: resolvedClubs,
  );
}

HostEventsWorkspaceState buildHostEventsWorkspaceState(
  AsyncValue<List<Event>> events, {
  required DateTime now,
  required HostEventsLifecycleFilter selectedFilter,
}) {
  if (events.isLoading) {
    return HostEventsWorkspaceState(
      status: HostEventsWorkspaceStatus.loading,
      selectedFilter: selectedFilter,
    );
  }
  if (events.hasError) {
    return HostEventsWorkspaceState(
      status: HostEventsWorkspaceStatus.error,
      selectedFilter: selectedFilter,
      error: events.error,
      stackTrace: events.stackTrace,
    );
  }

  return HostEventsWorkspaceState.fromEvents(
    events: events.asData?.value ?? const <Event>[],
    now: now,
    selectedFilter: selectedFilter,
  );
}

HostHomeTodayDashboardState buildHostHomeTodayDashboardState(
  AsyncValue<List<Event>> events, {
  required DateTime now,
  required AppLocalizations l10n,
}) {
  if (events.isLoading) {
    return const HostHomeTodayDashboardState(
      status: HostHomeTodayStatus.loading,
    );
  }
  if (events.hasError) {
    return HostHomeTodayDashboardState(
      status: HostHomeTodayStatus.error,
      error: events.error,
      stackTrace: events.stackTrace,
    );
  }

  final activeEvents = events.asData?.value
      .where((event) => !event.isCancelled && event.endTime.isAfter(now))
      .toList();
  activeEvents?.sort((a, b) {
    final aIsLive = !a.startTime.isAfter(now) && a.endTime.isAfter(now);
    final bIsLive = !b.startTime.isAfter(now) && b.endTime.isAfter(now);
    if (aIsLive != bIsLive) return aIsLive ? -1 : 1;
    return a.startTime.compareTo(b.startTime);
  });
  final event = activeEvents?.firstOrNull;
  if (event == null) {
    return const HostHomeTodayDashboardState(status: HostHomeTodayStatus.empty);
  }

  final laterHorizon = DateTime(
    now.year,
    now.month,
    now.day,
  ).add(const Duration(days: 7));
  final laterEvents = activeEvents!
      .skip(1)
      .where(
        (candidate) =>
            candidate.startTime.isAfter(now) &&
            candidate.startTime.isBefore(laterHorizon),
      )
      .take(3)
      .map(
        (candidate) =>
            HostEventLifecycleRowData.fromEvent(event: candidate, now: now),
      )
      .toList(growable: false);
  final tasks = HostHomeTodayTaskData.forEvents(
    activeEvents,
    l10n,
  ).toList(growable: false);

  return HostHomeTodayDashboardState(
    status: HostHomeTodayStatus.content,
    event: event,
    laterEvents: List<HostEventLifecycleRowData>.unmodifiable(laterEvents),
    tasks: List<HostHomeTodayTaskData>.unmodifiable(tasks),
  );
}
