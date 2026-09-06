import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/explore/domain/explore_event_recommendation.dart';
import 'package:catch_dating_app/explore/presentation/widgets/recommend_card.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({super.key, required this.recommendations, this.title});

  final List<ExploreEventRecommendation> recommendations;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return CatchHorizontalRail(
      title: title ?? context.l10n.exploreRecommendationsTitleForYou,
      itemCount: recommendations.length,
      itemBuilder: (context, i) =>
          RecommendCard.fromRecommendation(recommendation: recommendations[i]),
      height: null,
      spacing: CatchLayout.recommendationRailGap,
      itemWidth: const CatchRailItemWidth.fractional(
        fraction: CatchLayout.recommendationRailItemWidthFraction,
        min: CatchLayout.recommendationRailItemMinWidth,
        max: CatchLayout.recommendationRailItemMaxWidth,
      ),
    );
  }
}
