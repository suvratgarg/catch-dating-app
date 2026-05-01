import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommend_card.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({super.key, required this.tokens, required this.runs});

  final CatchTokens tokens;
  final List<Run> runs;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recommended runs',
                style: CatchTextStyles.titleL(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: runs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) =>
                RecommendCard.fromRun(run: runs[i], tokens: t),
          ),
        ),
      ],
    );
  }
}
