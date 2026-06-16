import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:flutter/material.dart';

class CatchActionMenuItem<T> {
  const CatchActionMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.sublabel,
    this.selected = false,
    this.enabled = true,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? sublabel;
  final bool selected;
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
    // Keep the public parameter name as `icon` while storing the optional
    // override privately.
    // ignore: prefer_initializing_formals
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
      style: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        elevation: WidgetStatePropertyAll(0),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      menuChildren: [
        CatchMenu<T>(
          width: CatchLayout.actionMenuWidth,
          items: [
            for (final item in widget.items)
              CatchMenuItem<T>(
                value: item.value,
                label: item.label,
                sublabel: item.sublabel,
                icon: item.icon,
                selected: item.selected,
                danger: item.isDestructive,
                enabled: item.enabled,
              ),
          ],
          onSelected: (value, _) {
            widget.onSelected?.call(value);
            _controller.close();
          },
        ),
      ],
      builder: (context, controller, child) {
        return Tooltip(
          message: widget.tooltip,
          child: CatchIconButton(
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
}
