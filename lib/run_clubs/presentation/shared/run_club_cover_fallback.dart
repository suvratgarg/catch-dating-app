import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:flutter/material.dart';

class RunClubCoverFallback extends StatelessWidget {
  const RunClubCoverFallback({
    super.key,
    required this.club,
    this.compact = false,
  });

  final RunClub club;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = _RunClubCoverPalette.forSeed('${club.id}:${club.name}');

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
          CustomPaint(painter: _RunClubRoutePainter(palette.line)),
          Positioned(
            right: compact ? -12 : -20,
            bottom: compact ? -18 : -28,
            child: Icon(
              Icons.directions_run_rounded,
              size: compact ? 72 : 128,
              color: Colors.white.withValues(alpha: compact ? 0.08 : 0.10),
            ),
          ),
          Center(
            child: Container(
              width: compact ? 56 : 96,
              height: compact ? 56 : 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.30),
                  width: 1.5,
                ),
              ),
              child: Text(
                _initials(club.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 18 : 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          if (!compact)
            Positioned(
              left: CatchSpacing.s4,
              top: CatchSpacing.s4,
              child: _CoverChip(
                icon: Icons.location_on_outlined,
                label: club.location.label,
              ),
            ),
          Positioned(
            left: compact ? 8 : CatchSpacing.s4,
            bottom: compact ? 8 : CatchSpacing.s4,
            child: Text(
              compact ? club.area : 'Run club',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: compact
                  ? CatchTextStyles.labelS(
                      context,
                      color: Colors.white.withValues(alpha: 0.78),
                    )
                  : CatchTextStyles.labelL(context, color: t.primaryInk),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.86)),
          const SizedBox(width: 4),
          Text(
            label,
            style: CatchTextStyles.labelS(
              context,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunClubRoutePainter extends CustomPainter {
  const _RunClubRoutePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.035
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * -0.08, size.height * 0.70)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.42,
        size.width * 0.34,
        size.height * 0.96,
        size.width * 0.58,
        size.height * 0.66,
      )
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.44,
        size.width * 0.86,
        size.height * 0.58,
        size.width * 1.10,
        size.height * 0.30,
      );

    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = color.withValues(alpha: 0.62);
    canvas.drawCircle(
      Offset(size.width * 0.20, size.height * 0.54),
      size.shortestSide * 0.025,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.52),
      size.shortestSide * 0.022,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RunClubRoutePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _RunClubCoverPalette {
  const _RunClubCoverPalette({
    required this.start,
    required this.end,
    required this.line,
  });

  final Color start;
  final Color end;
  final Color line;

  static _RunClubCoverPalette forSeed(String seed) {
    final palettes = [
      _RunClubCoverPalette(
        start: const Color(0xFF21433D),
        end: const Color(0xFF6A3D2A),
        line: const Color(0xFFE6D8B8).withValues(alpha: 0.20),
      ),
      _RunClubCoverPalette(
        start: const Color(0xFF243D5A),
        end: const Color(0xFF5B2F4B),
        line: const Color(0xFFD9E7F2).withValues(alpha: 0.20),
      ),
      _RunClubCoverPalette(
        start: const Color(0xFF39452D),
        end: const Color(0xFF7A4C32),
        line: const Color(0xFFF1E3C6).withValues(alpha: 0.20),
      ),
      _RunClubCoverPalette(
        start: const Color(0xFF2E385A),
        end: const Color(0xFF365947),
        line: const Color(0xFFE2F0DD).withValues(alpha: 0.20),
      ),
    ];
    final index = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return palettes[index % palettes.length];
  }
}

String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) {
    return 'RC';
  }
  return words
      .take(2)
      .map((word) => word.characters.first)
      .join()
      .toUpperCase();
}
