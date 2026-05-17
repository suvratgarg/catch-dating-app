import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:flutter/material.dart';

/// Event / roster status badge.
///
/// Usage:
/// ```dart
/// StatusChip(status: EventStatus.joined)
/// StatusChip(status: EventStatus.waitlist, waitlistPosition: 3)
/// StatusChip(status: EventStatus.full)
/// ```
enum EventStatus { open, joined, waitlist, pending, paid, full, interested }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.waitlistPosition});

  final EventStatus status;

  /// Only relevant when [status] is [EventStatus.waitlist].
  final int? waitlistPosition;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = _resolve(status, waitlistPosition);

    return CatchBadge(label: label, tone: tone, uppercase: true);
  }

  static (String, CatchBadgeTone) _resolve(EventStatus s, int? pos) {
    return switch (s) {
      EventStatus.joined => ('joined', CatchBadgeTone.brand),
      EventStatus.paid => ('paid', CatchBadgeTone.success),
      EventStatus.waitlist => ('waitlist #${pos ?? '?'}', CatchBadgeTone.solid),
      EventStatus.pending => ('pending', CatchBadgeTone.neutral),
      EventStatus.full => ('full', CatchBadgeTone.solid),
      EventStatus.interested => ('interested', CatchBadgeTone.brand),
      EventStatus.open => ('open', CatchBadgeTone.brand),
    };
  }
}
