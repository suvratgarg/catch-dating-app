import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';

class CatchActionMenuItem<T> {
  const CatchActionMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
  final bool isDestructive;
}

class CatchActionMenu<T> extends StatefulWidget {
  const CatchActionMenu({
    super.key,
    required this.items,
    required this.tooltip,
    this.onSelected,
    this.enabled = true,
    IconData? icon,
  }) : _icon = icon;

  final List<CatchActionMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final String tooltip;
  final bool enabled;
  final IconData? _icon;

  IconData get icon => _icon ?? CatchIcons.moreHorizRounded;

  @override
  State<CatchActionMenu<T>> createState() => _CatchActionMenuState<T>();
}

class _CatchActionMenuState<T> extends State<CatchActionMenu<T>> {
  final _controller = MenuController();

  bool get _canOpen => widget.enabled && widget.items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return MenuAnchor(
      controller: _controller,
      alignmentOffset: const Offset(
        CatchLayout.actionMenuAlignmentX,
        CatchSpacing.s1,
      ),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(t.surface),
        elevation: const WidgetStatePropertyAll(CatchElevation.menu),
        shadowColor: WidgetStatePropertyAll(t.overlay),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CatchRadius.sm),
            side: BorderSide(color: t.line),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: CatchSpacing.s1),
        ),
      ),
      menuChildren: [
        for (final item in widget.items)
          SizedBox(
            width: CatchLayout.actionMenuWidth,
            child: MenuItemButton(
              onPressed: item.enabled
                  ? () {
                      widget.onSelected?.call(item.value);
                      _controller.close();
                    }
                  : null,
              leadingIcon: item.icon == null
                  ? null
                  : Icon(
                      item.icon,
                      size: CatchIcon.sm,
                      color: _itemColor(t, item),
                    ),
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(
                  Size(CatchSpacing.s0, CatchLayout.menuItemHeightCompact),
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
                ),
                foregroundColor: WidgetStatePropertyAll(_itemColor(t, item)),
                overlayColor: WidgetStatePropertyAll(t.primarySoft),
                textStyle: WidgetStatePropertyAll(
                  CatchTextStyles.bodyLead(context, color: _itemColor(t, item)),
                ),
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.labelL(
                  context,
                  color: _itemColor(t, item),
                ),
              ),
            ),
          ),
      ],
      builder: (context, controller, child) {
        return Tooltip(
          message: widget.tooltip,
          child: IconBtn(
            onTap: _canOpen
                ? () =>
                      controller.isOpen ? controller.close() : controller.open()
                : null,
            child: Icon(
              widget.icon,
              size: CatchIcon.md,
              color: widget.enabled ? t.ink : t.ink3,
            ),
          ),
        );
      },
    );
  }

  Color _itemColor(CatchTokens t, CatchActionMenuItem<T> item) {
    if (!item.enabled) return t.ink3;
    if (item.isDestructive) return t.danger;
    return t.ink;
  }
}
