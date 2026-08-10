import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:flutter/material.dart';

/// Lays out a chat timestamp on the final message line when it fits, otherwise
/// directly below it.
class CatchTimestampedMessageText extends StatelessWidget {
  const CatchTimestampedMessageText({
    super.key,
    required this.text,
    required this.timestamp,
    required this.textStyle,
    required this.timestampStyle,
  });

  final String text;
  final String timestamp;
  final TextStyle textStyle;
  final TextStyle timestampStyle;

  @override
  Widget build(BuildContext context) {
    const inlineGap = CatchSpacing.s2;
    const stackedGap = CatchSpacing.micro3;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width * 0.72;
        final direction = Directionality.of(context);
        final textScaler = MediaQuery.textScalerOf(context);
        final messagePainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          textDirection: direction,
          textScaler: textScaler,
        )..layout(maxWidth: maxWidth);
        final timestampPainter = TextPainter(
          text: TextSpan(text: timestamp, style: timestampStyle),
          textDirection: direction,
          textScaler: textScaler,
        )..layout(maxWidth: maxWidth);
        final messageLines = messagePainter.computeLineMetrics();
        final timestampLines = timestampPainter.computeLineMetrics();

        if (messageLines.isEmpty) {
          return Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(timestamp, style: timestampStyle),
          );
        }

        final longestLineWidth = messageLines.fold<double>(
          0,
          (width, line) => math.max(width, line.width),
        );
        final lastLine = messageLines.last;
        final timestampWidth = timestampPainter.width;
        final timestampHeight = timestampPainter.height;
        final fitsInline =
            lastLine.width + inlineGap + timestampWidth <= maxWidth;
        final desiredWidth = fitsInline
            ? math.max(
                longestLineWidth,
                lastLine.width + inlineGap + timestampWidth,
              )
            : math.max(longestLineWidth, timestampWidth);
        final width = math.min(maxWidth, desiredWidth);
        final timestampBaseline = timestampLines.isEmpty
            ? timestampHeight
            : timestampLines.first.baseline;
        final inlineTop = (lastLine.baseline - timestampBaseline)
            .clamp(0.0, math.max(0.0, messagePainter.height - timestampHeight))
            .toDouble();
        final timestampTop = fitsInline
            ? inlineTop
            : messagePainter.height + stackedGap;
        final height = fitsInline
            ? math.max(messagePainter.height, timestampTop + timestampHeight)
            : messagePainter.height + stackedGap + timestampHeight;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PositionedDirectional(
                start: 0,
                top: 0,
                width: width,
                child: Text(text, style: textStyle),
              ),
              PositionedDirectional(
                end: 0,
                top: timestampTop,
                child: Text(timestamp, style: timestampStyle),
              ),
            ],
          ),
        );
      },
    );
  }
}
