import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyHeroCard extends StatelessWidget {
  const EmptyHeroCard({super.key, this.fullBleed = false, this.onFindEvent});

  final bool fullBleed;
  final VoidCallback? onFindEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final content = EmptyHeroContent(
      onFindEvent: onFindEvent ?? () => context.go(Routes.exploreScreen.path),
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
              padding: CatchInsets.pageBody.copyWith(
                top: CatchSpacing.s12,
                bottom: CatchSpacing.s5,
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

class EmptyHeroContent extends StatelessWidget {
  const EmptyHeroContent({
    super.key,
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
            context.l10n.dashboardEmptyHeroCardTextWelcomeToCatch,
            style: CatchTextStyles.kicker(
              context,
              color: CatchTokens.editorialWhite,
            ),
          ),
          gapH28,
        ],
        Text(
          context.l10n.dashboardEmptyHeroCardTextNoEventsBooked,
          style: CatchTextStyles.kicker(
            context,
            color: CatchTokens.editorialWhite,
          ),
        ),
        gapH10,
        Text(
          context.l10n.dashboardEmptyHeroCardTextYourCatchesUnlockAfter,
          style: CatchTextStyles.headline(
            context,
            color: CatchTokens.editorialWhite,
          ),
        ),
        gapH8,
        Text(
          context.l10n.dashboardEmptyHeroCardTextTheDatingAppWhere,
          style: CatchTextStyles.supporting(
            context,
            color: CatchTokens.editorialWhite,
          ),
        ),
        gapH16,
        Semantics(
          hint:
              context.l10n.dashboardEmptyHeroCardVisiblecopyOpensTheExplorePage,
          child: CatchButton(
            label: context.l10n.dashboardEmptyHeroCardLabelFindAnEventNear,
            onPressed: onFindEvent,
            variant: CatchButtonVariant.light,
            size: CatchButtonSize.lg,
            fullWidth: true,
          ),
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
      ..color = CatchTokens.editorialWhite.withValues(alpha: 0.08)
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
