import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:flutter/material.dart';

enum EventDateMarkerLayout { weekStrip, monthGrid }

class EventDateMarker extends StatelessWidget {
  const EventDateMarker({
    super.key,
    required this.date,
    required this.active,
    required this.hasEvent,
    required this.onTap,
    this.layout = EventDateMarkerLayout.weekStrip,
    this.today = false,
    this.enabled = true,
    this.label,
  });

  final DateTime date;
  final bool active;
  final bool hasEvent;
  final VoidCallback onTap;
  final EventDateMarkerLayout layout;
  final bool today;
  final bool enabled;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      EventDateMarkerLayout.weekStrip => _WeekMarker(
        date: date,
        active: active,
        hasEvent: hasEvent,
        onTap: onTap,
        label: label,
      ),
      EventDateMarkerLayout.monthGrid => _MonthMarker(
        date: date,
        active: active,
        today: today,
        hasEvent: hasEvent,
        enabled: enabled,
        onTap: onTap,
      ),
    };
  }
}

class _WeekMarker extends StatelessWidget {
  const _WeekMarker({
    required this.date,
    required this.active,
    required this.hasEvent,
    required this.onTap,
    this.label,
  });

  final DateTime date;
  final bool active;
  final bool hasEvent;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final day =
        label ?? const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];

    return Semantics(
      button: true,
      selected: active,
      label: '$day ${date.day}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? t.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: CatchTextStyles.statusLabel(
                    context,
                    color: active ? t.surface.withValues(alpha: 0.72) : t.ink3,
                  ),
                ),
                gapH2,
                Text(
                  '${date.day}',
                  style: CatchTextStyles.statCompact(
                    context,
                    color: active ? t.surface : t.ink,
                  ),
                ),
                gapH4,
                CatchStatusDot(
                  color: hasEvent ? t.primary : Colors.transparent,
                  size: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthMarker extends StatelessWidget {
  const _MonthMarker({
    required this.date,
    required this.active,
    required this.today,
    required this.hasEvent,
    required this.enabled,
    required this.onTap,
  });

  final DateTime date;
  final bool active;
  final bool today;
  final bool hasEvent;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final textColor = active
        ? t.surface
        : enabled
        ? t.ink
        : t.ink3.withValues(alpha: 0.36);
    final dayText = Text(
      '${date.day}',
      style: CatchTextStyles.labelL(context, color: textColor),
    );

    return Semantics(
      button: enabled,
      selected: active,
      label: '${date.day}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            height: 40,
            decoration: BoxDecoration(
              color: active ? t.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: today && !active ? Border.all(color: t.line2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                enabled ? dayText : Opacity(opacity: 0, child: dayText),
                gapH4,
                CatchStatusDot(
                  color: hasEvent && enabled ? t.primary : Colors.transparent,
                  size: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
