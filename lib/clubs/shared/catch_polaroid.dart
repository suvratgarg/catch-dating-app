import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchPolaroid extends StatelessWidget {
  const CatchPolaroid({
    super.key,
    required this.media,
    required this.caption,
    required this.title,
    this.subtitle,
    this.footer,
    this.mediaOverlay,
    this.onTap,
    this.padding = CatchInsets.contentDense,
    this.paddingKey,
    this.radius = CatchLayout.clubPolaroidRadius,
    this.mediaRadius = CatchLayout.clubPolaroidMediaRadius,
    this.titleMaxLines = 1,
    this.titleStyle,
    this.captionColor,
    this.subtitleStyle,
    this.showArrow = true,
  });

  final Widget media;
  final String caption;
  final String title;
  final String? subtitle;
  final Widget? footer;
  final Widget? mediaOverlay;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Key? paddingKey;
  final double radius;
  final double mediaRadius;
  final int titleMaxLines;
  final TextStyle? titleStyle;
  final Color? captionColor;
  final TextStyle? subtitleStyle;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      onTap: onTap,
      borderColor: t.line,
      radius: radius,
      elevation: CatchSurfaceElevation.card,
      backgroundColor: t.surface,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        key: paddingKey,
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mediaFrame = ClipRRect(
              borderRadius: BorderRadius.circular(mediaRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [media, ?mediaOverlay],
              ),
            );
            final mediaChild =
                constraints.hasBoundedHeight && constraints.maxHeight.isFinite
                ? SizedBox(
                    height: math.max(
                      0,
                      constraints.maxHeight -
                          (footer == null
                              ? CatchLayout.polaroidBodyReserve
                              : CatchLayout.polaroidBodyReserveWithFooter),
                    ),
                    child: mediaFrame,
                  )
                : AspectRatio(
                    aspectRatio: CatchAspectRatio.standardPhoto,
                    child: mediaFrame,
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                mediaChild,
                gapH10,
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.monoLabel(
                    context,
                    color: captionColor ?? t.ink3,
                  ),
                ),
                gapH4,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style:
                            titleStyle ??
                            CatchTextStyles.clubDisplay(
                              context,
                              size: CatchLayout.clubPolaroidTitleSize,
                            ),
                      ),
                    ),
                    if (showArrow) ...[
                      gapW10,
                      Icon(
                        CatchIcons.forwardArrow,
                        size: CatchIcon.sm,
                        color: t.ink2,
                      ),
                    ],
                  ],
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  gapH4,
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        subtitleStyle ??
                        CatchTextStyles.proseM(context, color: t.ink2),
                  ),
                ],
                if (footer != null) ...[gapH10, footer!],
              ],
            );
          },
        ),
      ),
    );
  }
}

class ClubPolaroidArtwork extends StatelessWidget {
  const ClubPolaroidArtwork({
    super.key,
    required this.club,
    this.compact = false,
  });

  final Club club;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = ClubCoverVisualPalette.forClub(context, club);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.start, palette.end],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _ClubCoverPatternPainter(palette)),
          Align(
            child: CatchIconTile(
              icon: CatchIcons.locationOnRounded,
              iconColor: palette.icon,
              backgroundColor: palette.iconFill,
              borderColor: palette.iconBorder,
              size: compact ? 42 : 62,
              iconSize: compact ? 23 : 32,
              radius: compact ? 16 : 22,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CatchTokens.editorialWhite.withValues(
                    alpha: CatchOpacity.clubCoverHighlightOverlay,
                  ),
                  CatchTokens.editorialBlack.withValues(
                    alpha: CatchOpacity.clubCoverLowScrim,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClubCoverVisualPalette {
  const ClubCoverVisualPalette({
    required this.start,
    required this.end,
    required this.line,
    required this.block,
    required this.accent,
    required this.iconFill,
    required this.iconBorder,
    required this.icon,
    required this.text,
  });

  final Color start;
  final Color end;
  final Color line;
  final Color block;
  final Color accent;
  final Color iconFill;
  final Color iconBorder;
  final Color icon;
  final Color text;

  static ClubCoverVisualPalette forClub(BuildContext context, Club club) =>
      forSeed('${club.id}:${club.name}', context: context);

  static ClubCoverVisualPalette forSeed(String seed, {BuildContext? context}) {
    final t = context != null
        ? CatchTokens.of(context)
        : CatchTokens.editorialLight;
    final palette = context != null
        ? ActivityPalette.of(context)
        : ActivityPalette.light;

    final kinds = ActivityKind.values;
    final i1 = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    final i2 = (i1 * 7) % kinds.length;
    final swatch = palette.forKind(kinds[i1 % kinds.length]);
    final mixer = palette.forKind(kinds[i2]);

    final accent = Color.alphaBlend(
      mixer.accent.withValues(alpha: CatchOpacity.clubCoverAccentBlend),
      swatch.accent,
    );
    final deep = Color.alphaBlend(
      mixer.deep.withValues(alpha: CatchOpacity.clubCoverDeepBlend),
      swatch.deep,
    );

    return ClubCoverVisualPalette(
      start: Color.alphaBlend(
        accent.withValues(alpha: CatchOpacity.clubCoverHighlightOverlay),
        t.surface,
      ),
      end: Color.alphaBlend(
        deep.withValues(alpha: CatchOpacity.controlOverlayPressed),
        t.surface,
      ),
      line: accent.withValues(alpha: CatchOpacity.clubCoverPaletteLine),
      block: accent.withValues(alpha: CatchOpacity.clubCoverPaletteBlock),
      accent: accent,
      iconFill: t.surface.withValues(alpha: CatchOpacity.clubCoverChipFill),
      iconBorder: accent.withValues(alpha: CatchOpacity.clubCoverPatternLine),
      icon: accent,
      text: t.ink2,
    );
  }
}

class _ClubCoverPatternPainter extends CustomPainter {
  const _ClubCoverPatternPainter(this.palette);

  final ClubCoverVisualPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final blockPaint = Paint()
      ..color = palette.block
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * -0.08,
          size.height * 0.52,
          size.width * 0.72,
          size.height * 0.56,
        ),
        Radius.circular(size.shortestSide * 0.18),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.50,
          size.height * -0.12,
          size.width * 0.62,
          size.height * 0.42,
        ),
        Radius.circular(size.shortestSide * 0.16),
      ),
      blockPaint
        ..color = palette.block.withValues(
          alpha: CatchOpacity.clubCoverPatternBlock,
        ),
    );

    final gridPaint = Paint()
      ..color = palette.line.withValues(
        alpha: CatchOpacity.clubCoverPatternLine,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final gap = size.shortestSide * 0.18;
    for (var x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        gridPaint,
      );
    }

    final routePaint = Paint()
      ..color = palette.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.026
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * -0.06, size.height * 0.70)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.58,
        size.width * 0.34,
        size.height * 0.84,
        size.width * 0.58,
        size.height * 0.62,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.46,
        size.width * 0.90,
        size.height * 0.58,
        size.width * 1.08,
        size.height * 0.42,
      );

    canvas.drawPath(path, routePaint);

    final dotPaint = Paint()
      ..color = palette.accent.withValues(
        alpha: CatchOpacity.clubCoverPatternDot,
      );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.60),
      size.shortestSide * 0.025,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.54),
      size.shortestSide * 0.022,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ClubCoverPatternPainter oldDelegate) =>
      oldDelegate.palette != palette;
}
