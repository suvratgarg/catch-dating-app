import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';

HostHomeRouteState buildHostHomeRouteState({
  required CatchAsyncState<String?> uid,
  CatchAsyncState<List<Club>>? clubs,
}) {
  if (uid.hasError) {
    return HostHomeRouteState(
      status: HostHomeRouteStatus.error,
      error: uid.error,
      stackTrace: uid.stackTrace,
      errorContext: AppErrorContext.auth,
    );
  }

  final currentUid = uid.value;
  if (currentUid == null) {
    return uid.isLoading
        ? const HostHomeRouteState(status: HostHomeRouteStatus.loading)
        : const HostHomeRouteState(status: HostHomeRouteStatus.authRequired);
  }

  final clubValue = clubs;
  if (clubValue == null) {
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
  if (clubValue.isLoading) {
    return HostHomeRouteState(
      status: HostHomeRouteStatus.loading,
      uid: currentUid,
    );
  }

  final resolvedClubs = List<Club>.unmodifiable(
    clubValue.value ?? const <Club>[],
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
  CatchAsyncState<List<Event>> events, {
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
  if (events.hasError) {
    return HostEventsWorkspaceState(
      status: HostEventsWorkspaceStatus.error,
      error: events.error,
      stackTrace: events.stackTrace,
    );
  }
  if (events.isLoading) {
    return const HostEventsWorkspaceState(
      status: HostEventsWorkspaceStatus.loading,
    );
  }

  return HostEventsWorkspaceState.fromEvents(
    events: events.value ?? const <Event>[],
    now: now,
    featuredEventId: featuredEventId,
    hasMoreActive: hasMoreActive,
    hasMorePast: hasMorePast,
    loadingMoreActive: loadingMoreActive,
    loadingMorePast: loadingMorePast,
    activeLoadMoreError: activeLoadMoreError,
    pastError: pastError,
    pastStackTrace: pastStackTrace,
  );
}
