import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar_variant.dart';
import 'package:flutter/material.dart';

/// Shared avatar clipping and label allocation. Labels fit inside the inscribed
/// content square so larger text cannot wrap behind a circular clip.
class CatchAvatarViewport extends StatelessWidget {
  const CatchAvatarViewport({
    super.key,
    required this.size,
    required this.child,
    this.variant = CatchAvatarVariant.circle,
  }) : _label = false;

  const CatchAvatarViewport.label({
    super.key,
    required this.size,
    required this.child,
  }) : _label = true,
       variant = CatchAvatarVariant.circle;

  final double size;
  final Widget child;
  final CatchAvatarVariant variant;
  final bool _label;

  @override
  Widget build(BuildContext context) {
    if (_label) {
      final extent = size * CatchLayout.avatarLabelContentScale;
      return SizedBox.square(
        dimension: size,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: extent, maxHeight: extent),
            child: DefaultTextHeightBehavior(
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              child: FittedBox(fit: BoxFit.scaleDown, child: child),
            ),
          ),
        ),
      );
    }
    final sized = SizedBox.square(dimension: size, child: child);
    return switch (variant) {
      CatchAvatarVariant.circle => ClipOval(child: sized),
      CatchAvatarVariant.square => ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.md),
        child: sized,
      ),
    };
  }
}
