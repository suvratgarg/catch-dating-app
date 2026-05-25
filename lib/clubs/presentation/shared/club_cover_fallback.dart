import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class ClubCoverFallback extends StatelessWidget {
  const ClubCoverFallback({
    super.key,
    required this.club,
    this.compact = false,
    bool? showLocationChip,
    bool? showFooterLabel,
  }) : showLocationChip = showLocationChip ?? !compact,
       showFooterLabel = showFooterLabel ?? true;

  final Club club;
  final bool compact;
  final bool showLocationChip;
  final bool showFooterLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = _ClubCoverPalette.forSeed('${club.id}:${club.name}');

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
            alignment: Alignment.center,
            child: CatchIconTile(
              icon: Icons.location_on_rounded,
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
                  Colors.white.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.04),
                ],
              ),
            ),
          ),
          if (showLocationChip)
            Positioned(
              left: CatchSpacing.s4,
              top: CatchSpacing.s4,
              child: _CoverChip(
                icon: Icons.location_on_outlined,
                label: cityLabel(club.location),
              ),
            ),
          if (showFooterLabel)
            Positioned(
              left: compact ? 8 : CatchSpacing.s4,
              bottom: compact ? 8 : CatchSpacing.s4,
              child: Text(
                compact ? club.area : 'Club',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? CatchTextStyles.labelS(
                        context,
                        color: palette.text.withValues(alpha: 0.76),
                      )
                    : CatchTextStyles.labelL(context, color: t.ink2),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverChip extends StatelessWidget {
  const _CoverChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: Colors.white.withValues(alpha: 0.72),
      borderColor: Colors.white.withValues(alpha: 0.62),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: t.primary),
          gapW4,
          Text(label, style: CatchTextStyles.labelS(context, color: t.ink2)),
        ],
      ),
    );
  }
}

class _ClubCoverPatternPainter extends CustomPainter {
  const _ClubCoverPatternPainter(this.palette);

  final _ClubCoverPalette palette;

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
      blockPaint..color = palette.block.withValues(alpha: 0.44),
    );

    final gridPaint = Paint()
      ..color = palette.line.withValues(alpha: 0.28)
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

    final dotPaint = Paint()..color = palette.accent.withValues(alpha: 0.50);
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

class _ClubCoverPalette {
  const _ClubCoverPalette({
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

  static _ClubCoverPalette forSeed(String seed) {
    final palettes = [
      _ClubCoverPalette(
        start: const Color(0xFFFFF6EF),
        end: const Color(0xFFEAF4EF),
        line: const Color(0xFF7C978B).withValues(alpha: 0.24),
        block: const Color(0xFFFFD9C9).withValues(alpha: 0.56),
        accent: const Color(0xFFFF5A36),
        iconFill: Colors.white.withValues(alpha: 0.72),
        iconBorder: const Color(0xFFFFD4C5),
        icon: const Color(0xFFFF5A36),
        text: const Color(0xFF5A4A40),
      ),
      _ClubCoverPalette(
        start: const Color(0xFFF4F0FF),
        end: const Color(0xFFEAF4FA),
        line: const Color(0xFF7E8FA7).withValues(alpha: 0.25),
        block: const Color(0xFFE4D7FF).withValues(alpha: 0.52),
        accent: const Color(0xFF4A7BC5),
        iconFill: Colors.white.withValues(alpha: 0.72),
        iconBorder: const Color(0xFFD9E0F5),
        icon: const Color(0xFF4A7BC5),
        text: const Color(0xFF464A5B),
      ),
      _ClubCoverPalette(
        start: const Color(0xFFFFF7DE),
        end: const Color(0xFFEFF6E8),
        line: const Color(0xFF969C74).withValues(alpha: 0.25),
        block: const Color(0xFFFFE1A6).withValues(alpha: 0.50),
        accent: const Color(0xFFD28A23),
        iconFill: Colors.white.withValues(alpha: 0.72),
        iconBorder: const Color(0xFFF1DBA8),
        icon: const Color(0xFFD28A23),
        text: const Color(0xFF554D35),
      ),
      _ClubCoverPalette(
        start: const Color(0xFFEFF8F6),
        end: const Color(0xFFFFF0EA),
        line: const Color(0xFF769D97).withValues(alpha: 0.25),
        block: const Color(0xFFCDEBE5).withValues(alpha: 0.56),
        accent: const Color(0xFF218A77),
        iconFill: Colors.white.withValues(alpha: 0.72),
        iconBorder: const Color(0xFFCBE7E2),
        icon: const Color(0xFF218A77),
        text: const Color(0xFF38544F),
      ),
    ];
    final index = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return palettes[index % palettes.length];
  }
}
