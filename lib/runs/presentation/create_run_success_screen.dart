import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';

class CreateRunSuccessScreen extends StatelessWidget {
  const CreateRunSuccessScreen({
    super.key,
    required this.runClub,
    required this.run,
    required this.onManageRun,
    required this.onDone,
  });

  final RunClub runClub;
  final Run run;
  final VoidCallback onManageRun;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.runCreated,
      eyebrow: 'Run created',
      title: 'Your run is live.',
      message:
          '${run.title} is now listed on ${runClub.name}. Followers can discover it from their home feed.',
      details: [
        CelebrationDetail(
          icon: Icons.calendar_month_outlined,
          label: 'When',
          value: '${run.longDateLabel} · ${run.timeRangeLabel}',
        ),
        CelebrationDetail(
          icon: Icons.location_on_outlined,
          label: 'Where',
          value: run.meetingPoint,
        ),
        CelebrationDetail(
          icon: Icons.directions_run_rounded,
          label: 'Run',
          value:
              '${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label}',
        ),
        CelebrationDetail(
          icon: Icons.group_outlined,
          label: 'Capacity',
          value: '${run.capacityLimit} runners',
        ),
      ],
      note: 'Bookings, waitlist, and attendance are tracked from Manage run.',
      primaryAction: CelebrationAction(
        label: 'Manage run',
        onPressed: onManageRun,
        icon: const Icon(Icons.tune_rounded),
      ),
      secondaryAction: CelebrationAction(
        label: 'Back to club',
        onPressed: onDone,
      ),
      onClose: onDone,
    );
  }
}
