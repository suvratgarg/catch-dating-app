import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.sentAt,
    this.imageUrl,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  final String text;
  final bool isMe;
  final DateTime? sentAt;
  final String? imageUrl;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final sentAt = this.sentAt;
    final timeStr = sentAt == null
        ? 'Sending...'
        : AppTimeFormatters.time(sentAt);
    final messageStyle = CatchTextStyles.chatMessage(
      context,
      color: isMe ? t.primaryInk : t.ink,
    );
    final timestampStyle = CatchTextStyles.meta(
      context,
      color: isMe
          ? t.primaryInk.withValues(alpha: CatchOpacity.onDarkMuted)
          : t.ink3,
    );

    return Padding(
      padding: isLastInGroup
          ? CatchInsets.chatBubbleGroupEnd
          : CatchInsets.chatBubbleGroupContinue,
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) gapW4,
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    (MediaQuery.of(context).size.width *
                            CatchLayout.chatBubbleMaxWidthFraction)
                        .clamp(0, CatchLayout.chatBubbleMaxWidth)
                        .toDouble(),
              ),
              child: CatchSurface(
                padding: CatchInsets.chatBubbleContent,
                backgroundColor: isMe ? t.primary : t.surface,
                borderColor: isMe ? null : t.line,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    isMe || isFirstInGroup ? CatchRadius.lg : CatchRadius.sm,
                  ),
                  topRight: Radius.circular(
                    !isMe || isFirstInGroup ? CatchRadius.lg : CatchRadius.sm,
                  ),
                  bottomLeft: Radius.circular(
                    isMe || !isLastInGroup ? CatchRadius.lg : CatchRadius.sm,
                  ),
                  bottomRight: Radius.circular(
                    isMe && isLastInGroup ? CatchRadius.sm : CatchRadius.lg,
                  ),
                ),
                child: imageUrl == null && text.isNotEmpty
                    ? _TimestampedMessageText(
                        text: text,
                        timestamp: timeStr,
                        textStyle: messageStyle,
                        timestampStyle: timestampStyle,
                      )
                    : _MediaMessageBody(
                        text: text,
                        timestamp: timeStr,
                        imageUrl: imageUrl,
                        textStyle: messageStyle,
                        timestampStyle: timestampStyle,
                      ),
              ),
            ),
          ),
          if (isMe) gapW4,
        ],
      ),
    );
  }
}

class _TimestampedMessageText extends StatelessWidget {
  const _TimestampedMessageText({
    required this.text,
    required this.timestamp,
    required this.textStyle,
    required this.timestampStyle,
  });

  static const double _inlineGap = CatchSpacing.s2;
  static const double _stackedGap = CatchSpacing.micro3;

  final String text;
  final String timestamp;
  final TextStyle textStyle;
  final TextStyle timestampStyle;

  @override
  Widget build(BuildContext context) {
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
            lastLine.width + _inlineGap + timestampWidth <= maxWidth;
        final desiredWidth = fitsInline
            ? math.max(
                longestLineWidth,
                lastLine.width + _inlineGap + timestampWidth,
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
            : messagePainter.height + _stackedGap;
        final height = fitsInline
            ? math.max(messagePainter.height, timestampTop + timestampHeight)
            : messagePainter.height + _stackedGap + timestampHeight;

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

class _MediaMessageBody extends StatelessWidget {
  const _MediaMessageBody({
    required this.text,
    required this.timestamp,
    required this.imageUrl,
    required this.textStyle,
    required this.timestampStyle,
  });

  final String text;
  final String timestamp;
  final String? imageUrl;
  final TextStyle textStyle;
  final TextStyle timestampStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (imageUrl != null)
          Padding(
            padding: CatchInsets.chatMediaAttachmentBottom,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.md),
              child: AspectRatio(
                aspectRatio: CatchAspectRatio.standardPhoto,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        if (text.isNotEmpty) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(text, style: textStyle),
          ),
          gapH2,
        ],
        Text(timestamp, style: timestampStyle),
      ],
    );
  }
}
