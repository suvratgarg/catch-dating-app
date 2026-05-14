import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_map_view_model.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tiles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RunMapSheet extends StatelessWidget {
  const RunMapSheet({
    super.key,
    required this.items,
    required this.selectedRun,
    required this.onRunSelected,
  });

  final List<RunMapItem> items;
  final Run? selectedRun;
  final ValueChanged<Run> onRunSelected;

  @override
  Widget build(BuildContext context) {
    final highlightedItem =
        _selectedItem(items, selectedRun?.id) ?? items.first;
    final highlightedRun = highlightedItem.run;

    return CatchSurface(
      padding: const EdgeInsets.all(Sizes.p14),
      elevation: CatchSurfaceElevation.overlay,
      borderColor: CatchTokens.of(context).line,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nearby runs',
                  style: CatchTextStyles.labelM(context),
                ),
              ),
              Text(
                '${items.length}',
                style: CatchTextStyles.labelM(
                  context,
                  color: CatchTokens.of(context).primary,
                ),
              ),
            ],
          ),
          gapH10,
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth * 0.58)
                  .clamp(190.0, 260.0)
                  .toDouble();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < items.length; index += 1) ...[
                      if (index > 0) gapW10,
                      RunMapTile(
                        data: items[index].tileData,
                        selected: items[index].run.id == highlightedRun.id,
                        width: cardWidth,
                        onTap: () => onRunSelected(items[index].run),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          gapH12,
          CatchButton(
            label: 'View run',
            onPressed: () => context.pushNamed(
              Routes.dashboardRunDetailScreen.name,
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

RunMapItem? _selectedItem(List<RunMapItem> items, String? selectedRunId) {
  if (selectedRunId == null) return null;
  for (final item in items) {
    if (item.run.id == selectedRunId) return item;
  }
  return null;
}
