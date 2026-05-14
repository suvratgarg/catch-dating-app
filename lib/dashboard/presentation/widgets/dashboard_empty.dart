import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashed_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

class DashboardEmpty extends StatelessWidget {
  const DashboardEmpty({super.key, required this.user});

  final UserProfile? user;

  static const _steps = [
    (
      '01',
      'Book a group run',
      "Pick a club near you. Pay the fee (or don't — some are free).",
    ),
    (
      '02',
      'Actually show up',
      'Run with the club. No swiping happens here. Just run.',
    ),
    (
      '03',
      'Swipe within 24 hours',
      'You get the roster of who ran. Catch anyone who caught your eye.',
    ),
    (
      '04',
      'They catch you back?',
      'Match. Message. Plan the next run together.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final firstName = user?.greetingDisplayName ?? '';
    final photoUrl = user?.photoUrls.firstOrNull;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...DashboardSliverHeader(
              eyebrow: 'WELCOME TO CATCH',
              title: "Let's find your first run",
              avatar: DashedAvatar(
                size: 42,
                imageUrl: photoUrl,
                name: firstName,
              ),
            ).buildSlivers(context),
            const DashboardEmptySliverBody(),
          ],
        ),
      ),
    );
  }
}

class DashboardEmptySliverBody extends StatelessWidget {
  const DashboardEmptySliverBody({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s1,
        CatchSpacing.s5,
        CatchSpacing.s6,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const EmptyHeroCard(),
          gapH20,
          const QuickActions(),
          gapH20,
          Text('How Catch works', style: CatchTextStyles.titleL(context)),
          gapH10,
          ...List.generate(DashboardEmpty._steps.length, (i) {
            final s = DashboardEmpty._steps[i];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Sizes.p14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.$1,
                        style: CatchTextStyles.mono(context, color: t.primary),
                      ),
                      gapW14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.$2, style: CatchTextStyles.titleM(context)),
                            gapH3,
                            Text(s.$3, style: CatchTextStyles.bodyS(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < DashboardEmpty._steps.length - 1)
                  Divider(color: t.line, height: 1),
              ],
            );
          }),
        ]),
      ),
    );
  }
}
