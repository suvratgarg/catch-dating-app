import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RunMapSheet extends StatelessWidget {
  const RunMapSheet({
    super.key,
    required this.runs,
    required this.selectedRun,
    required this.onRunSelected,
  });

  final List<Run> runs;
  final Run? selectedRun;
  final ValueChanged<Run> onRunSelected;

  @override
  Widget build(BuildContext context) {
    final highlightedRun = selectedRun ?? runs.first;

    return CatchSurface(
      padding: const EdgeInsets.all(Sizes.p14),
      elevation: CatchSurfaceElevation.overlay,
      borderColor: CatchTokens.of(context).line,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nearby runs', style: CatchTextStyles.labelM(context)),
          gapH10,
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: runs.length,
              separatorBuilder: (_, _) => gapW10,
              itemBuilder: (context, index) {
                final run = runs[index];
                final selected = run.id == highlightedRun.id;
                return _RunMapChip(
                  run: run,
                  selected: selected,
                  onTap: () => onRunSelected(run),
                );
              },
            ),
          ),
          gapH12,
          CatchButton(
            label: 'View run',
            onPressed: () => context.pushNamed(
              Routes.runDetailScreen.name,
              pathParameters: {
                'runClubId': highlightedRun.runClubId,
                'runId': highlightedRun.id,
              },
            ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _RunMapChip extends StatelessWidget {
  const _RunMapChip({
    required this.run,
    required this.selected,
    required this.onTap,
  });

  final Run run;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: '${run.meetingPoint} run',
      child: CatchSurface(
        width: 180,
        padding: const EdgeInsets.all(Sizes.p12),
        tone: selected ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
        radius: CatchRadius.md,
        borderColor: selected ? t.primary : t.line,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              run.meetingPoint,
              style: CatchTextStyles.labelL(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            gapH6,
            Text(
              '${run.shortDateLabel} · ${run.compactTimeRangeLabel}',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
            gapH4,
            Text(
              '${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label}',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
            if (run.startingPointLat == null || run.startingPointLng == null)
              Text(
                'No exact pin',
                style: CatchTextStyles.bodyS(context, color: t.primary),
              ),
          ],
        ),
      ),
    );
  }
}
