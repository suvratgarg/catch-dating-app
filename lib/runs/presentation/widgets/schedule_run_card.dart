import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/runs/domain/pace_level_theme.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';

class ScheduleRunCard extends StatelessWidget {
  const ScheduleRunCard({
    super.key,
    required this.run,
    required this.isSelected,
    this.onTap,
  });

  final Run run;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pace = run.pace.colors;

    return CatchSurface(
      onTap: onTap,
      radius: CatchRadius.sm,
      backgroundColor: pace.bg,
      borderColor: isSelected ? pace.fg : pace.fg.withAlpha(80),
      borderWidth: isSelected ? 2 : 1,
      boxShadow: isSelected
          ? [BoxShadow(color: pace.fg.withAlpha(60), blurRadius: 6)]
          : CatchElevation.none,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      duration: const Duration(milliseconds: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${run.distanceLabel} · ${run.pace.label}',
            style: CatchTextStyles.labelM(context, color: pace.fg),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            run.compactTimeRangeLabel,
            style: CatchTextStyles.labelS(context, color: pace.fg),
            maxLines: 1,
          ),
          if (run.signedUpCount > 0)
            Text(
              run.spotsLabel,
              style: CatchTextStyles.labelS(context, color: pace.fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
