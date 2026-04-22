import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
  const StatusChip({
    super.key,
    required this.status,
    this.waitlistPosition,
  });

  final RunStatus status;

  /// Only relevant when [status] is [RunStatus.waitlist].
  final int? waitlistPosition;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final (label, bg, fg) = _resolve(status, t, waitlistPosition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(CatchRadius.button),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }

  static (String, Color, Color) _resolve(
    RunStatus s,
    CatchTokens t,
    int? pos,
  ) {
    return switch (s) {
      RunStatus.joined     => ('JOINED',               t.accent,      t.accentInk),
      RunStatus.paid       => ('PAID',                 t.accent,      t.accentInk),
      RunStatus.waitlist   => ('WAITLIST #${pos ?? '?'}', t.gold,    t.surface),
      RunStatus.pending    => ('PENDING',              t.raised,      t.ink2),
      RunStatus.full       => ('FULL',                 t.ink,         t.surface),
      RunStatus.interested => ('INTERESTED',           t.primarySoft, t.primary),
      RunStatus.open       => ('OPEN',                 t.primarySoft, t.primary),
    };
  }
}
