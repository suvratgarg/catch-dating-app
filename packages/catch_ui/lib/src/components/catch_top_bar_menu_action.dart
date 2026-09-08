import 'package:catch_ui/src/components/catch_action_menu.dart';
import 'package:catch_ui/src/components/catch_action_menu_item.dart';
import 'package:catch_ui/src/components/catch_icon_button.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:flutter/material.dart';

class CatchTopBarMenuAction<T> extends StatelessWidget {
  const CatchTopBarMenuAction({
    super.key,
    required this.items,
    required this.tooltip,
    this.onSelected,
    this.enabled = true,
    this.variant = CatchIconButtonVariant.bordered,
    IconData? icon,
    // Keep the public parameter name as `icon` while storing the optional
    // override privately.
    // ignore: prefer_initializing_formals
  }) : _icon = icon;

  final List<CatchActionMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final String tooltip;
  final bool enabled;
  final CatchIconButtonVariant variant;
  final IconData? _icon;

  IconData get icon => _icon ?? CatchIcons.moreHorizRounded;

  @override
  Widget build(BuildContext context) {
    return CatchActionMenu<T>(
      items: items,
      tooltip: tooltip,
      onSelected: onSelected,
      enabled: enabled,
      icon: icon,
      variant: variant,
    );
  }
}
