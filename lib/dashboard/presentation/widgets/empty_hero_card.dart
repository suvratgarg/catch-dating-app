import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyHeroCard extends StatelessWidget {
  const EmptyHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s5),
      radius: 22,
      gradient: t.heroGrad,
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
                '● NO EVENTS BOOKED',
                style: CatchTextStyles.kicker(context, color: Colors.white),
              ),
              gapH10,
              Text(
                'Your catches unlock\nafter your first event.',
                style: CatchTextStyles.heroHeadline(
                  context,
                  color: Colors.white,
                ),
              ),
              gapH8,
              Text(
                "Book a group event. Show up. Meet people.\nThen we'll hand you the roster.",
                style: CatchTextStyles.supporting(context, color: Colors.white),
              ),
              gapH16,
              CatchButton(
                label: 'Find an event near me',
                onPressed: () => context.go(Routes.clubsListScreen.path),
                variant: CatchButtonVariant.light,
                size: CatchButtonSize.lg,
                fullWidth: true,
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
