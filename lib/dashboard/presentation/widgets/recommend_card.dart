import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tiles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({super.key, required this.data, this.width});

  factory RecommendCard.fromRecommendation({
    Key? key,
    required DashboardRunRecommendation recommendation,
    double? width,
  }) {
    return RecommendCard(
      key: key,
      data: RunTileData.fromRun(
        run: recommendation.run,
        status: RunTileStatus.recommended,
        clubName: recommendation.clubName,
        reasonLabel: recommendation.reasonLabel,
      ),
      width: width,
    );
  }

  factory RecommendCard.fromRun({Key? key, required Run run, double? width}) {
    return RecommendCard(
      key: key,
      data: RunTileData.fromRun(
        run: run,
        status: RunTileStatus.recommended,
        clubName: 'Your run club',
        reasonLabel: 'From your clubs',
      ),
      width: width,
    );
  }

  final RunTileData data;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return RunRailTile(
      data: data,
      width: width,
      onTap: () => context.pushNamed(
        Routes.dashboardRunDetailScreen.name,
        pathParameters: {'runClubId': data.runClubId, 'runId': data.runId},
      ),
    );
  }
}
