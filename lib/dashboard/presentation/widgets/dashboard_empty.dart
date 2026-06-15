import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:flutter/material.dart';

class DashboardEmpty extends StatelessWidget {
  const DashboardEmpty({super.key});

  static const _steps = [
    (
      '01',
      'Book a group event',
      "Pick a club near you. Pay the fee — or don't; some are free.",
    ),
    (
      '02',
      'Actually show up',
      'Meet the club at the event. No cold matching happens here.',
    ),
    (
      '03',
      'Catch within 24 hours',
      'You get the roster of who came. Catch anyone who caught your eye.',
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
  const DashboardEmptySliverBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: const CatchSectionStack(
            padding: CatchInsets.pageBodyUnderHeader,
            children: [
              EmptyHeroCard(),
              CatchDesignSection(
                kicker: 'How Catch works',
                first: true,
                bodyGap: CatchSpacing.s4,
                child: _DashboardJourneySteps(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardJourneySteps extends StatelessWidget {
  const _DashboardJourneySteps();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      children: List.generate(DashboardEmpty._steps.length, (i) {
        final step = DashboardEmpty._steps[i];
        return Column(
          children: [
            Padding(
              padding: CatchInsets.contentVerticalMedium,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.$1,
                    style: CatchTextStyles.mono(context, color: t.primary),
                  ),
                  gapW14,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.$2,
                          style: CatchTextStyles.sectionTitle(context),
                        ),
                        gapH3,
                        Text(
                          step.$3,
                          style: CatchTextStyles.proseM(context, color: t.ink2),
                        ),
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
    );
  }
}
