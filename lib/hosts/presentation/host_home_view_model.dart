import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
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

HostHomeEventsSectionState buildHostHomeEventsSectionState(
  AsyncValue<List<Event>> events,
) {
  if (events.isLoading) {
    return const HostHomeEventsSectionState(
      status: HostHomeEventsStatus.loading,
    );
  }
  if (events.hasError) {
    return HostHomeEventsSectionState(
      status: HostHomeEventsStatus.error,
      error: events.error,
      stackTrace: events.stackTrace,
    );
  }

  final rows = HostHomeEventRowsState.fromEvents(
    events.asData?.value ?? const <Event>[],
  );
  return HostHomeEventsSectionState(
    status: rows.isEmpty
        ? HostHomeEventsStatus.empty
        : HostHomeEventsStatus.populated,
    rows: rows,
  );
}

HostHomeTodayDashboardState buildHostHomeTodayDashboardState(
  AsyncValue<List<Event>> events,
) {
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
      .where((event) => !event.isCancelled)
      .toList();
  activeEvents?.sort((a, b) => a.startTime.compareTo(b.startTime));
  final event = activeEvents?.firstOrNull;
  if (event == null) {
    return const HostHomeTodayDashboardState(status: HostHomeTodayStatus.empty);
  }

  return HostHomeTodayDashboardState(
    status: HostHomeTodayStatus.content,
    event: event,
    tasks: HostHomeTodayTaskData.forEvent(event),
  );
}
