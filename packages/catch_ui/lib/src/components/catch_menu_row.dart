import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_menu_item.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

class CatchMenuRow<T> extends StatelessWidget {
  const CatchMenuRow({super.key, required this.item, required this.onSelected});

  final CatchMenuItem<T> item;
  final void Function(T value, CatchMenuItem<T> item)? onSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = _menuItemColor(t, item);
    final onTap = item.enabled
        ? () {
            item.onSelected?.call(item.value);
            onSelected?.call(item.value, item);
          }
        : null;

    return Semantics(
      button: item.role == CatchMenuItemRole.action,
      enabled: item.enabled,
      selected: item.selected,
      inMutuallyExclusiveGroup: item.role == CatchMenuItemRole.choice,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CatchLayout.menuRowMinHeight,
            ),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.labelL(context, color: color),
                        ),
                        if (item.sublabel != null &&
                            item.sublabel!.trim().isNotEmpty) ...[
                          const SizedBox(height: CatchSpacing.micro2),
                          Text(
                            item.sublabel!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.menuSupporting(
                              context,
                              color: t.ink3,
                            ),
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
      ),
    );
  }
}

Color _menuItemColor<T>(CatchTokens t, CatchMenuItem<T> item) {
  if (!item.enabled) return t.ink3;
  if (item.danger) return t.danger;
  return t.ink;
}
