import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/presentation/run_arrival_action.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_error_message.dart';
import 'package:catch_dating_app/runs/presentation/run_check_in_celebration_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RunArrivalActionCard extends ConsumerWidget {
  const RunArrivalActionCard({super.key, required this.action});

  final RunArrivalAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final checkInMutation = ref.watch(RunBookingController.selfCheckInMutation);
    final hasCheckInError =
        action.kind == RunArrivalActionKind.selfCheckIn &&
        checkInMutation.hasError;

    return Column(
      children: [
        if (hasCheckInError)
          ErrorBanner(
            message: runBookingErrorMessage(
              (checkInMutation as MutationError).error,
            ),
          ),
        CatchSurface(
          padding: const EdgeInsets.all(CatchSpacing.s4),
          backgroundColor: t.primarySoft,
          borderColor: t.primary.withValues(alpha: 0.24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                switch (action.kind) {
                  RunArrivalActionKind.selfCheckIn => 'CHECK-IN OPEN',
                  RunArrivalActionKind.takeAttendance => 'HOST TOOLS',
                },
                style: CatchTextStyles.labelM(
                  context,
                  color: t.primary,
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1),
              ),
              gapH6,
              Text(switch (action.kind) {
                RunArrivalActionKind.selfCheckIn => 'Check in for your run',
                RunArrivalActionKind.takeAttendance => 'Take attendance',
              }, style: CatchTextStyles.titleL(context, color: t.ink)),
              gapH4,
              Text(
                '${RunFormatters.time(action.run.startTime)} · ${action.run.meetingPoint}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
              gapH14,
              CatchButton(
                label: switch (action.kind) {
                  RunArrivalActionKind.selfCheckIn => 'Check in',
                  RunArrivalActionKind.takeAttendance => 'Take Attendance',
                },
                icon: Icon(switch (action.kind) {
                  RunArrivalActionKind.selfCheckIn => Icons.location_on_rounded,
                  RunArrivalActionKind.takeAttendance =>
                    Icons.checklist_rounded,
                }, size: 18),
                fullWidth: true,
                isLoading:
                    action.kind == RunArrivalActionKind.selfCheckIn &&
                    checkInMutation.isPending,
                onPressed:
                    action.kind == RunArrivalActionKind.selfCheckIn &&
                        checkInMutation.isPending
                    ? null
                    : () => _handleTap(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    switch (action.kind) {
      case RunArrivalActionKind.selfCheckIn:
        RunBookingController.selfCheckInMutation.run(ref, (tx) async {
          await tx
              .get(runBookingControllerProvider.notifier)
              .selfCheckIn(runId: action.run.id);
          if (!context.mounted) return;
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute<void>(
              fullscreenDialog: true,
              builder: (routeContext) => RunCheckInCelebrationScreen(
                run: action.run,
                onViewRun: () {
                  Navigator.of(routeContext).pop();
                  GoRouter.of(context).goNamed(
                    Routes.runDetailScreen.name,
                    pathParameters: {
                      'runClubId': action.run.runClubId,
                      'runId': action.run.id,
                    },
                  );
                },
                onBackHome: () {
                  Navigator.of(routeContext).pop();
                  GoRouter.of(context).goNamed(Routes.dashboardScreen.name);
                },
              ),
            ),
          );
        });
      case RunArrivalActionKind.takeAttendance:
        GoRouter.of(context).pushNamed(
          Routes.attendanceSheet.name,
          pathParameters: {
            'runClubId': action.run.runClubId,
            'runId': action.run.id,
          },
        );
    }
  }
}
