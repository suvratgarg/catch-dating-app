import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_empty_state.dart';
import 'package:catch_ui/src/components/catch_empty_state_types.dart';
import 'package:catch_ui/src/patterns/catch_sliver_state_viewport.dart';
import 'package:catch_ui/src/primitives/catch_icon_tile.dart';
import 'package:flutter/material.dart';

/// Canonical sliver placement for a full-region empty success state.
class CatchSliverEmptyState extends StatelessWidget {
  const CatchSliverEmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.action,
    this.iconVariant = CatchIconTileVariant.plain,
    this.layout = CatchEmptyStateLayout.stacked,
    this.iconSize,
    this.iconContainerSize,
    this.padding = const EdgeInsets.symmetric(horizontal: CatchSpacing.s6),
    this.titleStyle,
    this.messageStyle,
    this.accountForBottomOverlay = true,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final Widget? action;
  final CatchIconTileVariant iconVariant;
  final CatchEmptyStateLayout layout;
  final double? iconSize;
  final double? iconContainerSize;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final bool accountForBottomOverlay;

  @override
  Widget build(BuildContext context) {
    return CatchSliverStateViewport(
      accountForBottomOverlay: accountForBottomOverlay,
      child: CatchEmptyState(
        icon: icon,
        title: title,
        message: message,
        action: action,
        iconVariant: iconVariant,
        layout: layout,
        iconSize: iconSize,
        iconContainerSize: iconContainerSize,
        padding: padding,
        titleStyle: titleStyle,
        messageStyle: messageStyle,
      ),
    );
  }
}
