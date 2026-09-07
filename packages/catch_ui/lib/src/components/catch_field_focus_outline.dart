import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchFieldFocusOutline extends StatelessWidget {
  const CatchFieldFocusOutline({
    super.key,
    required this.debugKey,
    required this.show,
    required this.borderRadius,
    required this.child,
  });

  final Key debugKey;
  final bool show;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final focusBorder = CatchBorder.resolve(t, CatchBorderRole.focus);
    return Stack(
      key: debugKey,
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CatchFieldFocusOutlinePainter(
                  color: focusBorder.color,
                  width: focusBorder.width,
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CatchFieldFocusOutlinePainter extends CustomPainter {
  const _CatchFieldFocusOutlinePainter({
    required this.color,
    required this.width,
    required this.borderRadius,
  });

  final Color color;
  final double width;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final reach =
        CatchFieldTokens.focusRingOffset + CatchFieldTokens.focusRingWidth / 2;
    final outline = borderRadius.toRRect(Offset.zero & size).inflate(reach);
    canvas.drawRRect(
      outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_CatchFieldFocusOutlinePainter oldDelegate) =>
      color != oldDelegate.color ||
      width != oldDelegate.width ||
      borderRadius != oldDelegate.borderRadius;
}
