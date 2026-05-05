import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_stats_grid.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_where_card.dart';
import 'package:flutter/material.dart';

class RunDetailOverviewSection extends StatelessWidget {
  const RunDetailOverviewSection({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(run.title, style: CatchTextStyles.displayL(context)),
        const SizedBox(height: 6),
        Row(
          children: [
            VibeTag(label: run.pace.label, active: true),
            const SizedBox(width: 6),
            Text(
              run.shortDateLabel,
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ],
        ),
        const SizedBox(height: 20),
        RunStatsGrid(run: run),
        const SizedBox(height: 20),
        WhenWhereCard(run: run),
        if (run.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            run.description,
            style: CatchTextStyles.bodyM(context, color: t.ink2),
          ),
        ],
        if (run.hasRequirements) ...[
          const SizedBox(height: 20),
          RequirementsRow(run: run),
        ],
      ],
    );
  }
}
