import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';

class RunCheckInCelebrationScreen extends StatelessWidget {
  const RunCheckInCelebrationScreen({
    super.key,
    required this.run,
    required this.onViewRun,
    required this.onBackHome,
  });

  final Run run;
  final VoidCallback onViewRun;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.runCheckedIn,
      eyebrow: 'Checked in',
      title: 'Checked in.',
      message: "You're on the roster. Have a great run.",
      icon: Icons.location_on_rounded,
      details: [
        CelebrationDetail(
          icon: Icons.directions_run_rounded,
          label: 'Run',
          value: run.title,
        ),
        CelebrationDetail(
          icon: Icons.schedule_rounded,
          label: 'Starts',
          value: run.timeRangeLabel,
        ),
        CelebrationDetail(
          icon: Icons.location_on_outlined,
          label: 'Meet point',
          value: run.meetingPoint,
        ),
      ],
      primaryAction: CelebrationAction(
        label: 'View run',
        onPressed: onViewRun,
        icon: const Icon(Icons.directions_run_rounded),
      ),
      secondaryAction: CelebrationAction(
        label: 'Back to home',
        onPressed: onBackHome,
      ),
      onClose: onBackHome,
    );
  }
}
