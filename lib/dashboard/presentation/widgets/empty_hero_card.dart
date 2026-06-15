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
      padding: CatchInsets.contentRelaxed,
      radius: CatchRadius.heroCard,
      gradient: t.heroGrad,
      clipBehavior: Clip.antiAlias,
      child: Column(
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
            "The dating app where you've already met. No cold swiping — just people you actually crossed paths with.",
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
    );
  }
}
