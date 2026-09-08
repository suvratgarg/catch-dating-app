import 'dart:math' as math;

import 'package:flutter/material.dart';

class CatchTicketShapeClipper extends CustomClipper<Path> {
  const CatchTicketShapeClipper({
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
  bool shouldReclip(covariant CatchTicketShapeClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.notchDepth != notchDepth ||
        oldClipper.notchCenterY != notchCenterY;
  }
}
