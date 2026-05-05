import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_agenda_list.dart';
import 'package:flutter/material.dart';

class ClubScheduleSection extends StatelessWidget {
  const ClubScheduleSection({
    super.key,
    required this.runs,
    this.onRunSelected,
  });

  final List<Run> runs;
  final ValueChanged<Run>? onRunSelected;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            0,
            CatchSpacing.s5,
            12,
          ),
          sliver: SliverToBoxAdapter(
            child: Text('Schedule', style: CatchTextStyles.titleL(context)),
          ),
        ),
        if (runs.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              0,
              CatchSpacing.s5,
              24,
            ),
            sliver: SliverToBoxAdapter(
              child: CatchEmptyState(
                icon: Icons.calendar_month_outlined,
                title: 'No upcoming runs',
                message: 'New runs from this club will appear here.',
              ),
            ),
          )
        else
          RunAgendaSliverList(
            runs: runs,
            badgeLabel: 'VIEW',
            onRunSelected: onRunSelected,
          ),
      ],
    );
  }
}
