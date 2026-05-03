import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class BottomSheetGrabber extends StatelessWidget {
  const BottomSheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: t.line2,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
        ),
      ),
    );
  }
}
