import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class CatchActionMenuItem<T> {
  const CatchActionMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.sublabel,
    this.enabled = true,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? sublabel;
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
    this.icon,
    this.variant = CatchIconButtonVariant.bordered,
  }) : assert(tooltip != '', 'CatchActionMenu requires an accessible tooltip.');

  final List<CatchActionMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final String tooltip;
  final bool enabled;
  final IconData? icon;
  final CatchIconButtonVariant variant;

  @override
  State<CatchActionMenu<T>> createState() => _CatchActionMenuState<T>();
}

class _CatchActionMenuState<T> extends State<CatchActionMenu<T>> {
  final _controller = MenuController();

  bool get _canOpen => widget.enabled && widget.items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    assert(
      widget.items.length <= CatchLayout.actionMenuMaxItems,
      'CatchActionMenu is for at most five commands. Use a dedicated '
      'selection control or sheet for larger collections.',
    );
    assert(
      widget.items.every(
        (item) => item.enabled || (item.sublabel?.trim().isNotEmpty ?? false),
      ),
      'Disabled action-menu rows need a reason. Informational status does not '
      'belong in an action menu.',
    );
    final menuWidth = CatchLayout.menuWidthFor(
      preferredWidth: CatchLayout.actionMenuWidth,
      viewportWidth: MediaQuery.sizeOf(context).width,
    );

    return CatchMenuAnchor<T>(
      controller: _controller,
      width: menuWidth,
      alignmentOffset: Offset(
        CatchLayout.actionMenuAlignmentXFor(menuWidth),
        CatchSpacing.s1,
      ),
      items: [
        for (final item in widget.items)
          CatchMenuItem<T>(
            value: item.value,
            label: item.label,
            sublabel: item.sublabel,
            icon: item.icon,
            danger: item.isDestructive,
            enabled: item.enabled,
          ),
      ],
      onSelected: (value, _) {
        widget.onSelected?.call(value);
        _controller.close();
      },
      builder: (context, controller, child) {
        return CatchIconButton(
          tooltip: widget.tooltip,
          variant: widget.variant,
          onTap: _canOpen
              ? () => controller.isOpen ? controller.close() : controller.open()
              : null,
          child: Icon(
            widget.icon ?? CatchIcons.moreHorizRounded,
            size: CatchIcon.md,
            color: widget.enabled ? t.ink : t.ink3,
          ),
        );
      },
    );
  }
}
