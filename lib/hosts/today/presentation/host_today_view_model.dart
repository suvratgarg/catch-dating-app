import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/today/data/host_today_feed_controller.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

HostTodayRouteState buildHostTodayRouteState({
  required CatchAsyncState<String?> uid,
  CatchAsyncState<List<Club>>? organizers,
}) {
  if (uid.hasError) {
    return HostTodayRouteState(
      status: HostTodayRouteStatus.error,
      error: uid.error,
      stackTrace: uid.stackTrace,
      errorContext: AppErrorContext.auth,
    );
  }

  final currentUid = uid.value;
  if (currentUid == null) {
    return uid.isLoading
        ? const HostTodayRouteState(status: HostTodayRouteStatus.loading)
        : const HostTodayRouteState(status: HostTodayRouteStatus.authRequired);
  }

  final organizerValue = organizers;
  if (organizerValue == null || organizerValue.isLoading) {
    return HostTodayRouteState(
      status: HostTodayRouteStatus.loading,
      uid: currentUid,
    );
  }
  if (organizerValue.hasError) {
    return HostTodayRouteState(
      status: HostTodayRouteStatus.error,
      uid: currentUid,
      error: organizerValue.error,
      stackTrace: organizerValue.stackTrace,
    );
  }

  final resolved = List<Club>.unmodifiable(
    organizerValue.value ?? const <Club>[],
  );
  return HostTodayRouteState(
    status: resolved.isEmpty
        ? HostTodayRouteStatus.empty
        : HostTodayRouteStatus.loaded,
    uid: currentUid,
    organizers: resolved,
  );
}

HostTodayState buildHostTodayState(
  CatchAsyncState<HostTodayFeedData> feed, {
  required DateTime now,
  required AppLocalizations l10n,
}) {
  if (feed.hasError) {
    return HostTodayState(
      status: HostTodayStatus.error,
      error: feed.error,
      stackTrace: feed.stackTrace,
    );
  }
  if (feed.isLoading) {
    return const HostTodayState(status: HostTodayStatus.loading);
  }

  final data = feed.value;
  final activeEvents =
      (data?.activeEvents ?? const <Event>[])
          .where((event) => !event.isCancelled && event.endTime.isAfter(now))
          .toList()
        ..sort((a, b) {
          final aIsLive = !a.startTime.isAfter(now) && a.endTime.isAfter(now);
          final bIsLive = !b.startTime.isAfter(now) && b.endTime.isAfter(now);
          if (aIsLive != bIsLive) return aIsLive ? -1 : 1;
          return a.startTime.compareTo(b.startTime);
        });
  final featuredEvent = activeEvents.firstOrNull;
  if (featuredEvent == null) {
    return HostTodayState(
      status: HostTodayStatus.empty,
      hasPastEvents: data?.hasPastEvents ?? false,
    );
  }

  final attentionItems = HostAttentionPolicy.forEvents(activeEvents, now: now)
      .map((item) => HostTodayAttentionData.fromItem(item, l10n))
      .toList(growable: false);
  final laterEvents = activeEvents
      .skip(1)
      .take(2)
      .map((event) => HostTodayEventRowData.fromEvent(event: event, now: now))
      .toList(growable: false);

  return HostTodayState(
    status: HostTodayStatus.content,
    featuredEvent: featuredEvent,
    attentionItems: List<HostTodayAttentionData>.unmodifiable(attentionItems),
    laterEvents: List<HostTodayEventRowData>.unmodifiable(laterEvents),
    hasPastEvents: data?.hasPastEvents ?? false,
  );
}
