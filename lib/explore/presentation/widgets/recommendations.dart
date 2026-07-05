import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/explore/data/explore_recommendations_repository.dart';
import 'package:catch_dating_app/explore/presentation/widgets/recommend_card.dart';
import 'package:flutter/material.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({
    super.key,
    required this.recommendations,
    this.title = 'For you',
  });

  final List<ExploreEventRecommendation> recommendations;
  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth * 0.78)
            .clamp(280.0, 340.0)
            .toDouble();
        return CatchHorizontalRail(
          title: title,
          itemCount: recommendations.length,
          itemBuilder: (context, i) => RecommendCard.fromRecommendation(
            recommendation: recommendations[i],
            width: cardWidth,
          ),
          height: null,
          spacing: CatchLayout.recommendationRailGap,
        );
      },
    );
  }
}
