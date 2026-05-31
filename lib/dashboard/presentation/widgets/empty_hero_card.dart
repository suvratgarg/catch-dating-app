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
      radius: CatchRadius.heroCard,
      gradient: t.heroGrad,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: CatchLayout.emptyHeroArtOffset,
            top: CatchLayout.emptyHeroArtOffset,
            child: CustomPaint(
              size: const Size.square(CatchLayout.emptyHeroArtSize),
              painter: _ConcentricCirclesPainter(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '● NO EVENTS BOOKED',
                style: CatchTextStyles.kicker(
                  context,
                  color: CatchTokens.editorialLight,
                ),
              ),
              gapH10,
              Text(
                'Your catches unlock\nafter your first event.',
                style: CatchTextStyles.headline(
                  context,
                  color: CatchTokens.editorialLight,
                ),
              ),
              gapH8,
              Text(
                "Book a group event. Show up. Meet people.\nThen we'll hand you the roster.",
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.editorialLight,
                ),
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
      ..color = CatchTokens.editorialLight.withValues(
        alpha: CatchOpacity.emptyHeroArtStroke,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = CatchStroke.hairline;
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (final r in CatchLayout.emptyHeroCircleRadii) {
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
