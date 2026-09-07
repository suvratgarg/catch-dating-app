import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

enum OrganizerPosterLayout { editorial, photo, split, minimal }

enum OrganizerPosterTreatment { paper, ink, signal }

/// Canonical organizer material.
///
/// The component owns the poster canvas and its four approved layouts. Host
/// tools can later persist a small recipe that selects these variants without
/// letting arbitrary typography or positioning leak into consumer surfaces.
class CatchOrganizerPoster extends StatelessWidget {
  const CatchOrganizerPoster({
    super.key,
    required this.media,
    required this.kicker,
    required this.title,
    this.tagline,
    this.meta,
    this.footer,
    this.mediaOverlay,
    this.onTap,
    this.layout = OrganizerPosterLayout.editorial,
    this.treatment = OrganizerPosterTreatment.paper,
    this.radius = CatchLayout.organizerPosterRadius,
    this.titleMaxLines = 1,
    this.showArrow = true,
  });

  final Widget media;
  final String kicker;
  final String title;
  final String? tagline;
  final String? meta;
  final Widget? footer;
  final Widget? mediaOverlay;
  final VoidCallback? onTap;
  final OrganizerPosterLayout layout;
  final OrganizerPosterTreatment treatment;
  final double radius;
  final int titleMaxLines;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final colors = _OrganizerPosterColors.resolve(t, treatment);

    return LayoutBuilder(
      builder: (context, constraints) {
        final poster = CatchSurface(
          key: const ValueKey('organizer-poster-canvas'),
          onTap: onTap,
          borderColor: colors.border,
          radius: radius,
          elevation: CatchSurfaceElevation.card,
          backgroundColor: colors.paper,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: switch (layout) {
            OrganizerPosterLayout.editorial => _buildEditorial(context, colors),
            OrganizerPosterLayout.photo => _buildPhoto(context, colors),
            OrganizerPosterLayout.split => _buildSplit(context, colors),
            OrganizerPosterLayout.minimal => _buildMinimal(context, colors),
          },
        );

        if (constraints.hasBoundedHeight && constraints.maxHeight.isFinite) {
          return SizedBox(height: constraints.maxHeight, child: poster);
        }
        return AspectRatio(
          aspectRatio: CatchAspectRatio.organizerPoster,
          child: poster,
        );
      },
    );
  }

  Widget _buildEditorial(BuildContext context, _OrganizerPosterColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 58, child: _mediaFrame()),
        Expanded(
          flex: 42,
          child: ColoredBox(
            color: colors.copyPlane,
            child: _copyBlock(context, colors),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(BuildContext context, _OrganizerPosterColors colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _mediaFrame(radius: 0),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, colors.photoScrim],
              stops: const [0.38, 1],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _copyBlock(
            context,
            colors.copyWith(
              ink: CatchTokens.editorialWhite,
              ink2: CatchTokens.editorialWhite.withValues(alpha: 0.86),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplit(BuildContext context, _OrganizerPosterColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _mediaFrame(radius: 0)),
        Expanded(
          child: ColoredBox(
            color: colors.copyPlane,
            child: _copyBlock(context, colors, compact: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimal(BuildContext context, _OrganizerPosterColors colors) {
    return Padding(
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _copyBlock(context, colors, roomy: true)),
          SizedBox(
            height: CatchLayout.organizerPosterMinimalMediaHeight,
            child: _mediaFrame(),
          ),
        ],
      ),
    );
  }

  Widget _mediaFrame({double? radius}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        radius ?? CatchLayout.organizerPosterMediaRadius,
      ),
      child: Stack(fit: StackFit.expand, children: [media, ?mediaOverlay]),
    );
  }

  Widget _copyBlock(
    BuildContext context,
    _OrganizerPosterColors colors, {
    bool compact = false,
    bool roomy = false,
  }) {
    final taglineText = tagline?.trim();
    final metaText = meta?.trim();
    return Padding(
      key: const ValueKey('organizer-poster-copy'),
      padding: compact ? CatchInsets.contentDense : CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: roomy
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Text(
            kicker.toUpperCase(),
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.kicker(context, color: colors.accent),
          ),
          gapH6,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.clubDisplay(
                    context,
                    step: compact ? CatchDisplayStep.s : CatchDisplayStep.m,
                    height: 0.94,
                    color: colors.ink,
                  ),
                ),
              ),
              if (showArrow) ...[
                gapW8,
                Icon(
                  CatchIcons.forwardArrow,
                  size: CatchIcon.sm,
                  color: colors.ink2,
                ),
              ],
            ],
          ),
          if (taglineText != null && taglineText.isNotEmpty) ...[
            gapH6,
            Text(
              taglineText,
              maxLines: compact ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.proseM(context, color: colors.ink2),
            ),
          ],
          if (metaText != null && metaText.isNotEmpty) ...[
            gapH8,
            Text(
              metaText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.numericMeta(context, color: colors.ink2),
            ),
          ],
          if (footer != null) ...[gapH10, footer!],
        ],
      ),
    );
  }
}

class OrganizerPosterArtwork extends StatelessWidget {
  const OrganizerPosterArtwork({
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

class _OrganizerPosterColors {
  const _OrganizerPosterColors({
    required this.paper,
    required this.copyPlane,
    required this.ink,
    required this.ink2,
    required this.accent,
    required this.border,
    required this.photoScrim,
  });

  final Color paper;
  final Color copyPlane;
  final Color ink;
  final Color ink2;
  final Color accent;
  final Color border;
  final Color photoScrim;

  _OrganizerPosterColors copyWith({Color? ink, Color? ink2}) {
    return _OrganizerPosterColors(
      paper: paper,
      copyPlane: copyPlane,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      accent: accent,
      border: border,
      photoScrim: photoScrim,
    );
  }

  static _OrganizerPosterColors resolve(
    CatchTokens t,
    OrganizerPosterTreatment treatment,
  ) {
    return switch (treatment) {
      OrganizerPosterTreatment.paper => _OrganizerPosterColors(
        paper: t.surface,
        copyPlane: t.raised,
        ink: t.ink,
        ink2: t.ink2,
        accent: t.primary,
        border: t.line,
        photoScrim: CatchTokens.editorialBlack.withValues(alpha: 0.82),
      ),
      OrganizerPosterTreatment.ink => _OrganizerPosterColors(
        paper: t.ink,
        copyPlane: t.ink,
        ink: t.surface,
        ink2: t.surface.withValues(alpha: 0.78),
        accent: t.primary,
        border: t.ink,
        photoScrim: CatchTokens.editorialBlack.withValues(alpha: 0.88),
      ),
      OrganizerPosterTreatment.signal => _OrganizerPosterColors(
        paper: t.primary,
        copyPlane: t.primary,
        ink: t.primaryInk,
        ink2: t.primaryInk.withValues(alpha: 0.78),
        accent: t.primaryInk,
        border: t.primary,
        photoScrim: CatchTokens.editorialBlack.withValues(alpha: 0.82),
      ),
    };
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
      ..strokeWidth = CatchStroke.hairline;
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
