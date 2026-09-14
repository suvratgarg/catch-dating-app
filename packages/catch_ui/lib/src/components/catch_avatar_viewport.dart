import 'dart:ui';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar_variant.dart';
import 'package:flutter/material.dart';

enum CatchAvatarViewportMode { clip, label, obscured }

/// Shared avatar clipping, obscuring and label allocation. Labels fit inside
/// the inscribed content square so larger text cannot wrap behind a circle.
class CatchAvatarViewport extends StatelessWidget {
  const CatchAvatarViewport({
    super.key,
    required this.size,
    required this.child,
    this.variant = CatchAvatarVariant.circle,
  }) : mode = CatchAvatarViewportMode.clip;

  const CatchAvatarViewport.label({
    super.key,
    required this.size,
    required this.child,
  }) : mode = CatchAvatarViewportMode.label,
       variant = CatchAvatarVariant.circle;

  /// Applies the avatar's blur and dark scrim inside its clipping boundary.
  const CatchAvatarViewport.obscured({
    super.key,
    required this.size,
    required this.child,
    this.variant = CatchAvatarVariant.circle,
  }) : mode = CatchAvatarViewportMode.obscured;

  final double size;
  final Widget child;
  final CatchAvatarVariant variant;
  final CatchAvatarViewportMode mode;

  @override
  Widget build(BuildContext context) {
    if (mode == CatchAvatarViewportMode.label) {
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
    final sized = SizedBox.square(
      dimension: size,
      child: mode == CatchAvatarViewportMode.obscured
          ? Stack(
              fit: StackFit.expand,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: CatchLayout.avatarObscuringBlurSigma,
                    sigmaY: CatchLayout.avatarObscuringBlurSigma,
                  ),
                  child: Transform.scale(
                    scale: CatchLayout.avatarObscuringScale,
                    child: child,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: CatchTokens.editorialBlack.withValues(
                      alpha: CatchOpacity.avatarPhotoScrim,
                    ),
                  ),
                ),
              ],
            )
          : child,
    );
    return switch (variant) {
      CatchAvatarVariant.circle => ClipOval(child: sized),
      CatchAvatarVariant.square => ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.md),
        child: sized,
      ),
    };
  }
}
