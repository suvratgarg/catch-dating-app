import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:flutter/material.dart';

/// Run / roster status badge.
///
/// Usage:
/// ```dart
/// StatusChip(status: RunStatus.joined)
/// StatusChip(status: RunStatus.waitlist, waitlistPosition: 3)
/// StatusChip(status: RunStatus.full)
/// ```
enum RunStatus { open, joined, waitlist, pending, paid, full, interested }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.waitlistPosition});

  final RunStatus status;

  /// Only relevant when [status] is [RunStatus.waitlist].
  final int? waitlistPosition;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = _resolve(status, waitlistPosition);

    return CatchBadge(label: label, tone: tone, uppercase: true);
  }

  static (String, CatchBadgeTone) _resolve(RunStatus s, int? pos) {
    return switch (s) {
      RunStatus.joined => ('joined', CatchBadgeTone.brand),
      RunStatus.paid => ('paid', CatchBadgeTone.success),
      RunStatus.waitlist => ('waitlist #${pos ?? '?'}', CatchBadgeTone.solid),
      RunStatus.pending => ('pending', CatchBadgeTone.neutral),
      RunStatus.full => ('full', CatchBadgeTone.solid),
      RunStatus.interested => ('interested', CatchBadgeTone.brand),
      RunStatus.open => ('open', CatchBadgeTone.brand),
    };
  }
}
