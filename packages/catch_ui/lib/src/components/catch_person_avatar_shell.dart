import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_person_avatar_shape.dart';
import 'package:flutter/material.dart';

class CatchPersonAvatarShell extends StatelessWidget {
  const CatchPersonAvatarShell({
    super.key,
    required this.size,
    required this.child,
    this.shape = CatchPersonAvatarShape.circle,
  });

  final double size;
  final Widget child;
  final CatchPersonAvatarShape shape;

  @override
  Widget build(BuildContext context) {
    final sized = SizedBox.square(dimension: size, child: child);
    return switch (shape) {
      CatchPersonAvatarShape.circle => ClipOval(child: sized),
      CatchPersonAvatarShape.square => ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.md),
        child: sized,
      ),
    };
  }
}
