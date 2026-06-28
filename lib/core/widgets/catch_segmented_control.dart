import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Pill-style segmented control — used for Day/Agenda calendar switching and
/// Grid/List club view switching in the design.
///
/// The default filled style gives the active segment [CatchTokens.ink]
/// background with [CatchTokens.surface] text. The surface style raises the
/// active segment on a soft outer shell.
///
/// Inactive segments are transparent with [CatchTokens.ink2] text.
/// The outer container uses [CatchTokens.raised] with a [CatchTokens.line] border.
///
/// Usage:
/// ```dart
/// CatchSegmentedControl<String>(
///   segments: const [
///     CatchSegment(value: 'day',   label: 'Day'),
///     CatchSegment(value: 'week',  label: 'Week'),
///   ],
///   selected: _view,
///   onChanged: (v) => setState(() => _view = v),
/// )
///
/// // With icons
/// CatchSegmentedControl<String>(
///   segments: [
///     CatchSegment(value: 'grid', icon: CatchIcons.gridViewRounded),
///     CatchSegment(value: 'list', icon: CatchIcons.listRounded),
///   ],
///   selected: _layout,
///   onChanged: (v) => setState(() => _layout = v),
/// )
/// ```
enum CatchSegmentedControlStyle { filled, surface }

class CatchSegment<T> {
  const CatchSegment({required this.value, this.label, this.icon})
    : assert(
        label != null || icon != null,
        'Provide at least a label or an icon',
      );

  final T value;
  final String? label;
  final IconData? icon;
}

class CatchSegmentedControl<T> extends StatelessWidget {
  const CatchSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.expanded = false,
    this.style = CatchSegmentedControlStyle.filled,
  });

  final List<CatchSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool expanded;
  final CatchSegmentedControlStyle style;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      width: expanded ? double.infinity : null,
      padding: const EdgeInsets.all(CatchSpacing.s1),
      decoration: BoxDecoration(
        color: t.raised,
        borderRadius: BorderRadius.circular(CatchRadius.segmentedOuter),
        border: Border.all(color: t.line),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final segment in segments)
            _buildSegmentButton<T>(
              context,
              segment: segment,
              selected: segment.value == selected,
              expanded: expanded,
              style: style,
              onTap: () => onChanged(segment.value),
            ),
        ],
      ),
    );
  }
}

Widget _buildSegmentButton<T>(
  BuildContext context, {
  required CatchSegment<T> segment,
  required bool selected,
  required bool expanded,
  required CatchSegmentedControlStyle style,
  required VoidCallback onTap,
}) {
  final t = CatchTokens.of(context);
  final activeBackground = switch (style) {
    CatchSegmentedControlStyle.filled => t.ink,
    CatchSegmentedControlStyle.surface => t.surface,
  };
  final activeForeground = switch (style) {
    CatchSegmentedControlStyle.filled => t.surface,
    CatchSegmentedControlStyle.surface => t.ink,
  };
  final foreground = selected ? activeForeground : t.ink2;
  final labelStyle = CatchTextStyles.sectionTitle(
    context,
    color: foreground,
  ).copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w600);

  final content = Row(
    mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (segment.icon != null)
        Icon(segment.icon, size: CatchIcon.control, color: foreground),
      if (segment.icon != null && segment.label != null) gapW8,
      if (segment.label != null)
        if (expanded)
          Flexible(
            child: Text(
              segment.label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          )
        else
          Text(segment.label!, maxLines: 1, style: labelStyle),
    ],
  );

  final button = Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(CatchRadius.segmentedInner),
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: CatchMotion.micro,
          curve: CatchMotion.easeInOutCurve,
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? CatchSpacing.s3 : CatchSpacing.s2,
            vertical: CatchSpacing.s3,
          ),
          decoration: BoxDecoration(
            color: selected ? activeBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(CatchRadius.segmentedInner),
            boxShadow: selected && style == CatchSegmentedControlStyle.surface
                ? CatchElevation.segmentedSelected(t)
                : null,
          ),
          child: content,
        ),
      ),
    ),
  );

  return expanded ? Expanded(child: button) : button;
}
