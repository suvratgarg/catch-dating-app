import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:flutter/material.dart';

enum SwipeStampKind {
  like('LIKE', -0.3),
  nope('NOPE', 0.3);

  const SwipeStampKind(this.label, this.rotation);

  final String label;
  final double rotation;
}

class SwipeStamp extends StatelessWidget {
  const SwipeStamp({super.key, required this.kind, required this.color});

  final SwipeStampKind kind;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: kind.rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.p12,
          vertical: Sizes.p6,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(Sizes.p8),
        ),
        child: Text(
          kind.label,
          style: CatchTextStyles.displayL(
            context,
            color: color,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
    );
  }
}
