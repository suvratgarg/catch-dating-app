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

/// Vertical density for the segmented-control contract.
///
/// [compact] is the design handoff's dense `SegPill` treatment. It keeps the
/// same selection, border, and elevation semantics while reducing the
/// control's vertical footprint for operational surfaces.
enum CatchSegmentedControlSize { compact, regular }

/// Typography treatment for segmented-control labels.
enum CatchSegmentedControlLabelStyle { standard, mono }

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
    this.size = CatchSegmentedControlSize.regular,
    this.labelStyle = CatchSegmentedControlLabelStyle.standard,
  });

  final List<CatchSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool expanded;
  final CatchSegmentedControlStyle style;
  final CatchSegmentedControlSize size;
  final CatchSegmentedControlLabelStyle labelStyle;

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
            CatchSegmentButton<T>(
              segment: segment,
              selected: segment.value == selected,
              expanded: expanded,
              style: style,
              size: size,
              labelStyle: labelStyle,
              onTap: () => onChanged(segment.value),
            ),
        ],
      ),
    );
  }
}

class CatchSegmentButton<T> extends StatelessWidget {
  const CatchSegmentButton({
    super.key,
    required this.segment,
    required this.selected,
    required this.expanded,
    required this.style,
    this.size = CatchSegmentedControlSize.regular,
    this.labelStyle = CatchSegmentedControlLabelStyle.standard,
    required this.onTap,
  });

  final CatchSegment<T> segment;
  final bool selected;
  final bool expanded;
  final CatchSegmentedControlStyle style;
  final CatchSegmentedControlSize size;
  final CatchSegmentedControlLabelStyle labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
    final resolvedLabelStyle = switch (labelStyle) {
      CatchSegmentedControlLabelStyle.standard => CatchTextStyles.sectionTitle(
        context,
        color: foreground,
      ),
      CatchSegmentedControlLabelStyle.mono => CatchTextStyles.monoLabel(
        context,
        color: foreground,
      ),
    }.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w600);
    final verticalPadding = switch (size) {
      CatchSegmentedControlSize.compact => CatchSpacing.micro6,
      CatchSegmentedControlSize.regular => CatchSpacing.s3,
    };

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
                style: resolvedLabelStyle,
              ),
            )
          else
            Text(segment.label!, maxLines: 1, style: resolvedLabelStyle),
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
              vertical: verticalPadding,
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
}
