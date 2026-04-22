import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: pace.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? pace.fg : pace.fg.withAlpha(80),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: pace.fg.withAlpha(60), blurRadius: 6)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${run.distanceLabel} · ${run.pace.label}',
              style: CatchTextStyles.labelSm(context, color: pace.fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              run.compactTimeRangeLabel,
              style: CatchTextStyles.caption(context, color: pace.fg),
              maxLines: 1,
            ),
            if (run.signedUpCount > 0)
              Text(
                run.spotsLabel,
                style: CatchTextStyles.caption(context, color: pace.fg),
              ),
          ],
        ),
      ),
    );
  }
}
