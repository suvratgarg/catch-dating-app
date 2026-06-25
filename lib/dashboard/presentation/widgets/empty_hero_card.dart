import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyHeroCard extends StatelessWidget {
  const EmptyHeroCard({super.key, this.fullBleed = false});

  final bool fullBleed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final content = _EmptyHeroContent(
      onFindEvent: () => context.go(Routes.exploreScreen.path),
      showWelcomeEyebrow: fullBleed,
    );

    if (fullBleed) {
      return CatchSurface(
        width: double.infinity,
        height: CatchLayout.dashboardEmptyHeroHeight,
        radius: 0,
        gradient: t.heroGrad,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _HeroLineWash())),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                CatchSpacing.s12,
                CatchSpacing.s5,
                CatchSpacing.s5,
              ),
              child: content,
            ),
          ],
        ),
      );
    }

    return CatchSurface(
      padding: CatchInsets.contentRelaxed,
      radius: CatchRadius.heroCard,
      gradient: t.heroGrad,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

class _EmptyHeroContent extends StatelessWidget {
  const _EmptyHeroContent({
    required this.onFindEvent,
    this.showWelcomeEyebrow = false,
  });

  final VoidCallback onFindEvent;
  final bool showWelcomeEyebrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showWelcomeEyebrow) ...[
          Text(
            'WELCOME TO CATCH',
            style: CatchTextStyles.kicker(
              context,
              color: CatchTokens.editorialLight,
            ),
          ),
          gapH28,
        ],
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
          "The dating app where you've already met. No cold swiping — just people you actually crossed paths with.",
          style: CatchTextStyles.supporting(
            context,
            color: CatchTokens.editorialLight,
          ),
        ),
        gapH16,
        CatchButton(
          label: 'Find an event near me',
          onPressed: onFindEvent,
          variant: CatchButtonVariant.light,
          size: CatchButtonSize.lg,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _HeroLineWash extends CustomPainter {
  const _HeroLineWash();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = CatchTokens.editorialLight.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width + size.height; x += 22) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroLineWash oldDelegate) => false;
}
