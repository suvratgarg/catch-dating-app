import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class BottomSheetGrabber extends StatelessWidget {
  const BottomSheetGrabber({super.key, this.width = 40, this.height = 4});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: t.line2,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
        ),
      ),
    );
  }
}
