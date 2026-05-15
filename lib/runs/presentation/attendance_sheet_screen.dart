import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/host_tools/presentation/host_run_tools.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceSheetScreen extends ConsumerWidget {
  const AttendanceSheetScreen({
    super.key,
    required this.runClubId,
    required this.runId,
  });

  final String runClubId;
  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final attendanceAsync = ref.watch(attendanceSheetViewModelProvider(runId));

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        title: 'Take Attendance',
        leading: CatchTopBarIconAction(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: attendanceAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (e, _) => CatchErrorState.fromError(
          e,
          context: AppErrorContext.run,
          onRetry: () {
            ref.invalidate(watchRunProvider(runId));
            ref.invalidate(watchRunParticipationsForRunProvider(runId));
            ref.invalidate(attendanceSheetViewModelProvider(runId));
          },
        ),
        data: (viewModel) {
          if (viewModel == null) {
            return const CatchErrorState(
              title: 'Run not found',
              message: 'This run is no longer available.',
            );
          }
          return _AttendanceList(viewModel: viewModel);
        },
      ),
    );
  }
}

class _AttendanceList extends ConsumerWidget {
  const _AttendanceList({required this.viewModel});

  final AttendanceSheetViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendeeIds = viewModel.attendeeIds;
    final mutation = ref.watch(RunBookingController.markAttendanceMutation);

    if (viewModel.isEmpty) {
      return const Center(
        child: CatchEmptyState(
          icon: Icons.group_outlined,
          title: 'No runners yet',
          message: 'No one has signed up for this run yet.',
          surface: false,
          iconStyle: CatchEmptyStateIconStyle.plain,
        ),
      );
    }

    final profilesAsync = ref.watch(runnerProfilesProvider(attendeeIds));
    final profiles = profilesAsync.asData?.value ?? {};

    return Column(
      children: [
        if (mutation.hasError)
          ErrorBanner(message: mutationErrorMessage(mutation)),
        _AttendanceSummaryHeader(
          checkedInCount: viewModel.checkedInCount,
          totalCount: viewModel.totalCount,
        ),
        Expanded(
          child: profilesAsync.isLoading
              ? const CatchLoadingIndicator()
              : profilesAsync.hasError
              ? Padding(
                  padding: const EdgeInsets.all(CatchSpacing.s5),
                  child: CatchInlineErrorState.fromError(
                    profilesAsync.error!,
                    context: AppErrorContext.run,
                    onRetry: () =>
                        ref.invalidate(runnerProfilesProvider(attendeeIds)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s5,
                    CatchSpacing.s2,
                    CatchSpacing.s5,
                    CatchSpacing.s6,
                  ),
                  itemCount: attendeeIds.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final uid = attendeeIds[index];
                    final profile = profiles[uid];
                    final isAttended = viewModel.isAttended(uid);

                    return _AttendeeRow(
                      uid: uid,
                      name: profile?.$1 ?? 'Runner',
                      photoUrl: profile?.$2,
                      isAttended: isAttended,
                      runId: viewModel.run.id,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AttendanceSummaryHeader extends StatelessWidget {
  const _AttendanceSummaryHeader({
    required this.checkedInCount,
    required this.totalCount,
  });

  final int checkedInCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = HostToolPalette.forAttendanceState(
      context,
      HostRunAttendanceState.open,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s3,
        CatchSpacing.s5,
        CatchSpacing.s3,
      ),
      child: CatchSurface(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        backgroundColor: palette.background,
        borderColor: palette.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s1,
              children: [
                CatchBadge(
                  label: 'Host tools',
                  tone: CatchBadgeTone.brand,
                  uppercase: true,
                ),
                CatchBadge(
                  label: 'Attendance',
                  tone: CatchBadgeTone.live,
                  uppercase: true,
                  icon: Icons.checklist_rounded,
                ),
              ],
            ),
            gapH10,
            Row(
              children: [
                Text(
                  '$checkedInCount / $totalCount checked in',
                  style: CatchTextStyles.titleM(context),
                ),
                const Spacer(),
                Text(
                  'Tap to toggle',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendeeRow extends ConsumerWidget {
  const _AttendeeRow({
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.isAttended,
    required this.runId,
  });

  final String uid;
  final String name;
  final String? photoUrl;
  final bool isAttended;
  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final mutation = ref.watch(RunBookingController.markAttendanceMutation);

    return CatchSurface(
      borderColor: t.line,
      radius: CatchRadius.md,
      clipBehavior: Clip.antiAlias,
      child: PersonRow(
        data: PersonRowData(
          name: name,
          imageUrl: photoUrl,
          seed: uid,
          metaLine: isAttended ? 'Checked in' : 'Not checked in',
        ),
        trailing: CatchBadge(
          label: isAttended ? 'checked in' : 'absent',
          tone: isAttended ? CatchBadgeTone.success : CatchBadgeTone.neutral,
          icon: isAttended
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked,
          uppercase: true,
        ),
        onTap: mutation.isPending
            ? null
            : () {
                RunBookingController.markAttendanceMutation.run(
                  ref,
                  (tx) async => tx
                      .get(runBookingControllerProvider.notifier)
                      .markAttendance(runId: runId, userId: uid),
                );
              },
      ),
    );
  }
}
