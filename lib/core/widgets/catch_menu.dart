import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchMenuItem<T> {
  const CatchMenuItem({
    required this.value,
    required this.label,
    this.sublabel,
    this.icon,
    this.selected = false,
    this.danger = false,
    this.enabled = true,
    this.onSelected,
  });

  final T value;
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool selected;
  final bool danger;
  final bool enabled;
  final ValueChanged<T>? onSelected;
}

/// Handoff `Menu`: anchored surface panel of selectable rows.
class CatchMenu<T> extends StatelessWidget {
  const CatchMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.width,
  });

  final List<CatchMenuItem<T>> items;
  final void Function(T value, CatchMenuItem<T> item)? onSelected;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      elevation: CatchSurfaceElevation.overlay,
      radius: CatchRadius.md,
      borderColor: t.line2,
      padding: EdgeInsets.zero,
      width: width,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final indexed in items.indexed) ...[
            if (indexed.$1 > 0)
              Divider(
                height: CatchStroke.hairline,
                thickness: CatchStroke.hairline,
                color: t.line,
              ),
            _CatchMenuRow<T>(item: indexed.$2, onSelected: onSelected),
          ],
        ],
      ),
    );
  }
}

class _CatchMenuRow<T> extends StatelessWidget {
  const _CatchMenuRow({required this.item, required this.onSelected});

  final CatchMenuItem<T> item;
  final void Function(T value, CatchMenuItem<T> item)? onSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = _itemColor(t);
    final onTap = item.enabled
        ? () {
            item.onSelected?.call(item.value);
            onSelected?.call(item.value, item);
          }
        : null;

    return Semantics(
      button: true,
      enabled: item.enabled,
      selected: item.selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CatchSpacing.micro14,
              vertical: CatchLayout.menuRowVerticalPadding,
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: CatchLayout.menuRowIconSize,
                    color: item.danger ? t.danger : t.ink2,
                  ),
                  const SizedBox(width: CatchLayout.menuRowGap),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.labelL(context, color: color),
                      ),
                      if (item.sublabel != null &&
                          item.sublabel!.trim().isNotEmpty) ...[
                        const SizedBox(height: CatchSpacing.micro2),
                        Text(
                          item.sublabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.monoLabel(
                            context,
                            color: t.ink3,
                          ).copyWith(fontSize: CatchLayout.menuRowSublabelSize),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.selected) ...[
                  const SizedBox(width: CatchLayout.menuRowGap),
                  Icon(
                    CatchIcons.check,
                    size: CatchLayout.menuRowCheckSize,
                    color: t.ink,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _itemColor(CatchTokens t) {
    if (!item.enabled) return t.ink3;
    if (item.danger) return t.danger;
    return t.ink;
  }
}
