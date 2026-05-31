import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_sheet_grabber.dart';
import 'package:flutter/material.dart';

class CatchDraggableSheetShell extends StatelessWidget {
  const CatchDraggableSheetShell({
    super.key,
    required this.child,
    this.showShadow = true,
    this.showHandle = true,
    this.handleOpacity = 1,
    this.topRadius = CatchRadius.lg,
  });

  final Widget child;
  final bool showShadow;
  final bool showHandle;
  final double handleOpacity;
  final double topRadius;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return AnimatedContainer(
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
        border: Border.all(color: t.line),
        boxShadow: showShadow ? CatchElevation.raised : CatchElevation.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (showHandle)
            Opacity(
              opacity: handleOpacity.clamp(0.0, 1.0),
              child: const Padding(
                padding: EdgeInsets.only(
                  top: CatchSpacing.s2,
                  bottom: CatchSpacing.s1,
                ),
                child: BottomSheetGrabber(
                  width: CatchLayout.sheetGrabberWideWidth,
                  height: CatchLayout.sheetGrabberTallHeight,
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
