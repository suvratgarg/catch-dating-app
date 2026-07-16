import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_journey_steps.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

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
              child: CatchSectionStack(
                padding: CatchInsets.pageBody.copyWith(
                  top: CatchSpacing.s5,
                  bottom: 0,
                ),
                children: [
                  CatchSection.divided(
                    title:
                        context.l10n.dashboardDashboardEmptyTitleHowCatchWorks,
                    first: true,
                    bodyGap: CatchSpacing.s4,
                    child: CatchJourneySteps(
                      steps: _howCatchWorksSteps(context.l10n),
                    ),
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

List<CatchJourneyStep> _howCatchWorksSteps(AppLocalizations l10n) => [
  CatchJourneyStep(
    title: l10n.dashboardDashboardEmptyTitleBookAGroupEvent,
    body: l10n.dashboardDashboardEmptyBodyPickAClubNear,
  ),
  CatchJourneyStep(
    title: l10n.dashboardDashboardEmptyTitleActuallyShowUp,
    body: l10n.dashboardDashboardEmptyBodyMeetTheClubAt,
  ),
  CatchJourneyStep(
    title: l10n.dashboardDashboardEmptyTitleCatchWithin24Hours,
    body: l10n.dashboardDashboardEmptyBodyYouGetTheRoster,
  ),
  CatchJourneyStep(
    title: l10n.dashboardDashboardEmptyTitleTheyCatchYouBack,
    body: l10n.dashboardDashboardEmptyBodyMatchMessagePlanThe,
  ),
];
