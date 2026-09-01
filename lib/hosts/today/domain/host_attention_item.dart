import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/foundation.dart';

enum HostAttentionKind { reviewWaitlist }

enum HostAttentionDestination { guests, setup }

enum HostAttentionUrgency { immediate, soon, upcoming }

const hostTodayAttentionHorizon = Duration(days: 7);
const hostTodayImmediateAttentionLeadTime = Duration(hours: 24);
const hostTodaySoonAttentionLeadTime = Duration(hours: 72);

@immutable
class HostAttentionItem {
  const HostAttentionItem({
    required this.id,
    required this.event,
    required this.kind,
    required this.destination,
    required this.urgency,
  });

  final String id;
  final Event event;
  final HostAttentionKind kind;
  final HostAttentionDestination destination;
  final HostAttentionUrgency urgency;
}

abstract final class HostAttentionPolicy {
  static List<HostAttentionItem> forEvents(
    Iterable<Event> events, {
    required DateTime now,
  }) {
    final horizon = now.add(hostTodayAttentionHorizon);
    final items =
        events
            .where(
              (event) =>
                  event.endTime.isAfter(now) &&
                  !event.startTime.isAfter(horizon),
            )
            .expand((event) => _forEvent(event, now))
            .toList()
          ..sort((a, b) {
            final urgency = a.urgency.index.compareTo(b.urgency.index);
            if (urgency != 0) return urgency;
            return a.event.startTime.compareTo(b.event.startTime);
          });
    return List<HostAttentionItem>.unmodifiable(items);
  }

  static Iterable<HostAttentionItem> _forEvent(
    Event event,
    DateTime now,
  ) sync* {
    if (event.waitlistCount <= 0 ||
        event.effectiveEventPolicy.admissionPolicy.manualApprovalRequired) {
      return;
    }
    yield HostAttentionItem(
      id: 'waitlist:${event.id}',
      event: event,
      kind: HostAttentionKind.reviewWaitlist,
      destination: HostAttentionDestination.guests,
      urgency: _urgencyFor(event, now),
    );
  }

  static HostAttentionUrgency _urgencyFor(Event event, DateTime now) {
    if (!event.startTime.isAfter(now) ||
        !event.startTime.isAfter(
          now.add(hostTodayImmediateAttentionLeadTime),
        )) {
      return HostAttentionUrgency.immediate;
    }
    if (!event.startTime.isAfter(now.add(hostTodaySoonAttentionLeadTime))) {
      return HostAttentionUrgency.soon;
    }
    return HostAttentionUrgency.upcoming;
  }
}
