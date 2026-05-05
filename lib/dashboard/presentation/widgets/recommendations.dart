import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommend_card.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({super.key, required this.runs});

  final List<Run> runs;

  @override
  Widget build(BuildContext context) {
    return CatchHorizontalRail(
      title: 'Recommended runs',
      itemCount: runs.length,
      itemBuilder: (context, i) => RecommendCard.fromRun(run: runs[i]),
      showDivider: false,
      height: 146,
      spacing: 10,
      headerPadding: EdgeInsets.zero,
      listPadding: EdgeInsets.zero,
    );
  }
}
