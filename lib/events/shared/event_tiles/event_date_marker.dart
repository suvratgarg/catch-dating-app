import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

const double _dateMarkerRadius = CatchSpacing.s3;
const double _monthMarkerHeight = CatchSpacing.s10;

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
      EventDateMarkerLayout.weekStrip => WeekMarker(
        date: date,
        active: active,
        hasEvent: hasEvent,
        onTap: onTap,
        label: label,
      ),
      EventDateMarkerLayout.monthGrid => MonthMarker(
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

class WeekMarker extends StatelessWidget {
  const WeekMarker({
    super.key,
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
      label: context.l10n.eventsEventDateMarkerLabelDayDay2(
        day: day,
        day2: date.day,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_dateMarkerRadius),
          child: Ink(
            padding: CatchInsets.contentVerticalCompact,
            decoration: BoxDecoration(
              color: active ? t.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(_dateMarkerRadius),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: CatchTextStyles.statusLabel(
                    context,
                    color: active
                        ? t.surface.withValues(alpha: CatchOpacity.scrimFill)
                        : t.ink3,
                  ),
                ),
                gapH2,
                Text(
                  context.l10n.eventsEventDateMarkerTextDay(day: date.day),
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

class MonthMarker extends StatelessWidget {
  const MonthMarker({
    super.key,
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
        : t.ink3.withValues(alpha: CatchOpacity.mutedContent);
    final dayText = Text(
      context.l10n.eventsEventDateMarkerTextDay(day: date.day),
      style: CatchTextStyles.labelL(context, color: textColor),
    );

    return Semantics(
      button: enabled,
      selected: active,
      label: context.l10n.eventsEventDateMarkerLabelDay(day: date.day),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(_dateMarkerRadius),
          child: Ink(
            height: _monthMarkerHeight,
            decoration: BoxDecoration(
              color: active ? t.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(_dateMarkerRadius),
              border: today && !active ? Border.all(color: t.line2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                enabled
                    ? dayText
                    : Visibility(
                        visible: false,
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true,
                        child: dayText,
                      ),
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
