import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_empty_state.dart';
import 'package:catch_ui/src/components/catch_empty_state_variant.dart';
import 'package:catch_ui/src/patterns/catch_state_viewport.dart';
import 'package:catch_ui/src/primitives/catch_icon_tile.dart';
import 'package:flutter/material.dart';

/// Canonical sliver placement for a full-region empty success state.
class CatchSliverEmptyState extends StatelessWidget {
  const CatchSliverEmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.actions = const [],
    this.iconVariant = CatchIconTileVariant.plain,
    this.variant = CatchEmptyStateVariant.stacked,
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
  final List<Widget> actions;
  final CatchIconTileVariant iconVariant;
  final CatchEmptyStateVariant variant;
  final double? iconSize;
  final double? iconContainerSize;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final bool accountForBottomOverlay;

  @override
  Widget build(BuildContext context) {
    return CatchStateViewport.sliver(
      accountForBottomOverlay: accountForBottomOverlay,
      child: CatchEmptyState(
        icon: icon,
        title: title,
        message: message,
        actions: actions,
        iconVariant: iconVariant,
        variant: variant,
        iconSize: iconSize,
        iconContainerSize: iconContainerSize,
        padding: padding,
        titleStyle: titleStyle,
        messageStyle: messageStyle,
      ),
    );
  }
}
