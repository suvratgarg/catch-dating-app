import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
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
      EventDateMarkerLayout.weekStrip => _weekMarker(
        context,
        date: date,
        active: active,
        hasEvent: hasEvent,
        onTap: onTap,
        label: label,
      ),
      EventDateMarkerLayout.monthGrid => _monthMarker(
        context,
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

Widget _weekMarker(
  BuildContext context, {
  required DateTime date,
  required bool active,
  required bool hasEvent,
  required VoidCallback onTap,
  String? label,
}) {
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

Widget _monthMarker(
  BuildContext context, {
  required DateTime date,
  required bool active,
  required bool today,
  required bool hasEvent,
  required bool enabled,
  required VoidCallback onTap,
}) {
  final t = CatchTokens.of(context);
  final textColor = active
      ? t.surface
      : enabled
      ? t.ink
      : t.ink3.withValues(alpha: CatchOpacity.mutedContent);
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
