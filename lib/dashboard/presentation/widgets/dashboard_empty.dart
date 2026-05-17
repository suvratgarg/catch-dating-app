import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:flutter/material.dart';

class DashboardEmpty extends StatelessWidget {
  const DashboardEmpty({super.key});

  static const _steps = [
    (
      '01',
      'Book a group event',
      "Pick a club near you. Pay the fee (or don't — some are free).",
    ),
    (
      '02',
      'Actually show up',
      'Event with the club. No swiping happens here. Just event.',
    ),
    (
      '03',
      'Swipe within 24 hours',
      'You get the roster of who ran. Catch anyone who caught your eye.',
    ),
    (
      '04',
      'They catch you back?',
      'Match. Message. Plan the next event together.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...DashboardSliverHeader(
              eyebrow: 'WELCOME TO CATCH',
              title: "Let's find your first event",
            ).buildSlivers(context),
            const DashboardEmptySliverBody(),
          ],
        ),
      ),
    );
  }
}

class DashboardEmptySliverBody extends StatelessWidget {
  const DashboardEmptySliverBody({super.key, this.weeklyActivitySection});

  final DashboardSectionModel<WeeklyRunningActivitySnapshot>?
  weeklyActivitySection;

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
          if (weeklyActivitySection != null) ...[
            DashboardStrideSection(section: weeklyActivitySection!),
            gapH20,
          ],
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
