import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_journey_steps.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:flutter/material.dart';

class DashboardEmptySliverBody extends StatelessWidget {
  const DashboardEmptySliverBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(child: EmptyHeroCard(fullBleed: true)),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: const CatchSectionStack(
                padding: EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  CatchSpacing.s5,
                  CatchSpacing.s5,
                  CatchSpacing.screenPb,
                ),
                children: [
                  CatchDesignSection(
                    kicker: 'How Catch works',
                    first: true,
                    bodyGap: CatchSpacing.s4,
                    child: CatchJourneySteps(steps: _howCatchWorksSteps),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const List<CatchJourneyStep> _howCatchWorksSteps = [
  CatchJourneyStep(
    title: 'Book a group event',
    body: "Pick a club near you. Pay the fee — or don't; some are free.",
  ),
  CatchJourneyStep(
    title: 'Actually show up',
    body: 'Meet the club at the event. No cold matching happens here.',
  ),
  CatchJourneyStep(
    title: 'Catch within 24 hours',
    body: 'You get the roster of who came. Catch anyone who caught your eye.',
  ),
  CatchJourneyStep(
    title: 'They catch you back?',
    body: 'Match. Message. Plan the next event together.',
  ),
];
