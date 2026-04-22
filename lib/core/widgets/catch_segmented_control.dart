import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Pill-style segmented control — used for Day/Agenda calendar switching and
/// Grid/List club view switching in the design.
///
/// The active segment gets [CatchTokens.ink] background with [CatchTokens.surface]
/// text; inactive segments are transparent with [CatchTokens.ink2] text.
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
///     CatchSegment(value: 'grid', icon: Icons.grid_view_rounded),
///     CatchSegment(value: 'list', icon: Icons.list_rounded),
///   ],
///   selected: _layout,
///   onChanged: (v) => setState(() => _layout = v),
/// )
/// ```
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
  });

  final List<CatchSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.raised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments.map((seg) {
          final isActive = seg.value == selected;
          return GestureDetector(
            onTap: () => onChanged(seg.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? t.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: seg.icon != null
                  ? Icon(
                      seg.icon,
                      size: 14,
                      color: isActive ? t.surface : t.ink2,
                    )
                  : Text(
                      seg.label!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isActive ? t.surface : t.ink2,
                      ),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
