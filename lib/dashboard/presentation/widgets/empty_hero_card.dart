import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyHeroCard extends StatelessWidget {
  const EmptyHeroCard({super.key, required this.tokens});

  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
      padding: const EdgeInsets.all(Sizes.p20),
      decoration: BoxDecoration(
        gradient: t.heroGrad as LinearGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _ConcentricCirclesPainter(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '● NO RUNS BOOKED',
                style: CatchTextStyles.labelSm(
                  context,
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.4),
              ),
              gapH10,
              Text(
                'Your catches unlock\nafter your first run.',
                style: CatchTextStyles.displayLg(
                  context,
                  color: Colors.white,
                ).copyWith(letterSpacing: -0.52, height: 1.1),
              ),
              gapH8,
              Text(
                "Book a group run. Show up. Meet people.\nThen we'll hand you the roster.",
                style: CatchTextStyles.bodySm(
                  context,
                  color: Colors.white,
                ).copyWith(height: 1.5),
              ),
              gapH16,
              FilledButton(
                onPressed: () => context.go(Routes.runClubsListScreen.path),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: t.ink,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(CatchRadius.button),
                  ),
                ),
                child: Text(
                  'Find a run near me',
                  style: CatchTextStyles.labelLg(context, color: t.ink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (final r in [40.0, 60.0, 80.0]) {
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
