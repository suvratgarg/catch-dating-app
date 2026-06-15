import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommend_card.dart';
import 'package:flutter/material.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({super.key, required this.recommendations});

  final List<DashboardEventRecommendation> recommendations;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth * 0.78)
            .clamp(280.0, 340.0)
            .toDouble();
        return CatchHorizontalRail(
          title: 'Recommended for you',
          itemCount: recommendations.length,
          itemBuilder: (context, i) => RecommendCard.fromRecommendation(
            recommendation: recommendations[i],
            width: cardWidth,
          ),
          showDivider: false,
          height: null,
          spacing: CatchLayout.recommendationRailGap,
          headerPadding: EdgeInsets.zero,
          listPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
