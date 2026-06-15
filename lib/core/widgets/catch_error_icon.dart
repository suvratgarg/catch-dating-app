import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Shared icon medallion for branded error surfaces.
class CatchErrorIcon extends StatelessWidget {
  const CatchErrorIcon({
    super.key,
    this.icon,
    this.extent = CatchLayout.errorIconExtent,
    this.iconSize = CatchLayout.errorIconSize,
  });

  final IconData? icon;
  final double extent;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);

    return Align(
      child: Container(
        width: extent,
        height: extent,
        decoration: BoxDecoration(
          color: tokens.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon ?? CatchIcons.errorOutlineRounded,
          color: tokens.danger,
          size: iconSize,
        ),
      ),
    );
  }
}
