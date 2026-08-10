import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

const double eventTicketDividerHeight = CatchLayout.eventTicketDividerHeight;
const double eventTicketNotchRadius = CatchLayout.eventTicketNotchRadius;
const double eventTicketNotchDepth = CatchLayout.eventTicketNotchDepth;

typedef EventTicketHeroSectionBuilder =
    Widget Function(BuildContext context, bool compact);

/// Canonical adaptive flight for the large ticket used in an event hero.
///
/// It owns the visual/body split and fitted body width so event features only
/// provide semantic sections rather than measuring the collapsing hero box.
class EventTicketHeroLayout extends StatelessWidget {
  const EventTicketHeroLayout({
    super.key,
    required this.visualBuilder,
    required this.divider,
    required this.bodyBuilder,
  });

  final EventTicketHeroSectionBuilder visualBuilder;
  final Widget divider;
  final EventTicketHeroSectionBuilder bodyBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight <
            CatchLayout.eventDetailTicketCompactHeightThreshold;
        final visualHeight =
            (constraints.maxHeight *
                    (compact
                        ? CatchLayout.eventDetailTicketVisualCompactRatio
                        : CatchLayout.eventDetailTicketVisualExpandedRatio))
                .clamp(
                  CatchLayout.eventDetailTicketVisualMinHeight,
                  CatchLayout.eventDetailTicketVisualMaxHeight,
                )
                .toDouble();
        final bodyPadding = compact
            ? const EdgeInsets.fromLTRB(
                CatchSpacing.s4,
                CatchSpacing.s2,
                CatchSpacing.s4,
                CatchSpacing.s3,
              )
            : CatchInsets.pageBody.copyWith(
                top: CatchSpacing.s4,
                bottom: CatchSpacing.s5,
              );
        final bodyWidth = constraints.maxWidth > bodyPadding.horizontal
            ? constraints.maxWidth - bodyPadding.horizontal
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: visualHeight,
              child: visualBuilder(context, compact),
            ),
            divider,
            Expanded(
              child: Padding(
                padding: bodyPadding,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: bodyWidth,
                    child: bodyBuilder(context, compact),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EventTicketPerforatedDivider extends StatelessWidget {
  const EventTicketPerforatedDivider({
    super.key,
    this.height = eventTicketDividerHeight,
    this.lineColor,
    this.notchRadius = eventTicketNotchRadius,
  });

  final double height;
  final Color? lineColor;
  final double notchRadius;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: EventTicketPerforationPainter(
          lineColor: lineColor ?? t.line2,
          notchRadius: notchRadius,
        ),
      ),
    );
  }
}

class EventTicketShapeClipper extends CustomClipper<Path> {
  const EventTicketShapeClipper({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchDepth,
    required this.notchCenterY,
  }) : assert(notchDepth <= notchRadius);

  final double cornerRadius;
  final double notchRadius;
  final double notchDepth;
  final double notchCenterY;

  @override
  Path getClip(Size size) {
    final radius = math.min(cornerRadius, size.shortestSide / 2);
    final top = notchCenterY - notchRadius;
    final bottom = notchCenterY + notchRadius;
    const circleKappa = 0.5522847498;

    return Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, top)
      ..cubicTo(
        size.width - circleKappa * notchDepth,
        top,
        size.width - notchDepth,
        notchCenterY - circleKappa * notchRadius,
        size.width - notchDepth,
        notchCenterY,
      )
      ..cubicTo(
        size.width - notchDepth,
        notchCenterY + circleKappa * notchRadius,
        size.width - circleKappa * notchDepth,
        bottom,
        size.width,
        bottom,
      )
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, bottom)
      ..cubicTo(
        circleKappa * notchDepth,
        bottom,
        notchDepth,
        notchCenterY + circleKappa * notchRadius,
        notchDepth,
        notchCenterY,
      )
      ..cubicTo(
        notchDepth,
        notchCenterY - circleKappa * notchRadius,
        circleKappa * notchDepth,
        top,
        0,
        top,
      )
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant EventTicketShapeClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.notchDepth != notchDepth ||
        oldClipper.notchCenterY != notchCenterY;
  }
}

class EventTicketPerforationPainter extends CustomPainter {
  const EventTicketPerforationPainter({
    required this.lineColor,
    this.notchRadius = eventTicketNotchRadius,
  });

  final Color lineColor;
  final double notchRadius;

  static const _dashWidth = 5.0;
  static const _dashGap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    var x = notchRadius + CatchSpacing.s2;
    final lineEnd = size.width - notchRadius - CatchSpacing.s2;
    while (x < lineEnd) {
      canvas.drawLine(Offset(x, y), Offset(x + _dashWidth, y), linePaint);
      x += _dashWidth + _dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant EventTicketPerforationPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.notchRadius != notchRadius;
  }
}
