import 'dart:ui';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchObscuredAvatarContent extends StatelessWidget {
  const CatchObscuredAvatarContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: Transform.scale(scale: 1.16, child: child),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: CatchTokens.editorialBlack.withValues(
              alpha: CatchOpacity.avatarPhotoScrim,
            ),
          ),
        ),
      ],
    );
  }
}
