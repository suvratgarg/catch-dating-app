import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
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
    final runAsync = ref.watch(watchRunProvider(runId));

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
      body: runAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (e, _) => CatchErrorText(e),
        data: (run) {
          if (run == null) {
            return const Center(child: Text('Run not found.'));
          }
          return _AttendanceList(run: run);
        },
      ),
    );
  }
}

class _AttendanceList extends ConsumerWidget {
  const _AttendanceList({required this.run});

  final Run run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedUpIds = run.signedUpUserIds;
    final attendedIds = run.attendedUserIds;
    final mutation = ref.watch(RunBookingController.markAttendanceMutation);

    if (signedUpIds.isEmpty) {
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

    final profilesAsync = ref.watch(runnerProfilesProvider(signedUpIds));
    final profiles = profilesAsync.asData?.value ?? {};

    final attendedCount = signedUpIds
        .where((id) => attendedIds.contains(id))
        .length;

    return Column(
      children: [
        if (mutation.hasError)
          ErrorBanner(message: mutationErrorMessage(mutation)),
        _AttendanceSummaryHeader(
          checkedInCount: attendedCount,
          totalCount: signedUpIds.length,
        ),
        Expanded(
          child: profilesAsync.isLoading
              ? const CatchLoadingIndicator()
              : profilesAsync.hasError
              ? CatchErrorText(profilesAsync.error!)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s5,
                    Sizes.p8,
                    CatchSpacing.s5,
                    Sizes.p24,
                  ),
                  itemCount: signedUpIds.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final uid = signedUpIds[index];
                    final profile = profiles[uid];
                    final isAttended = attendedIds.contains(uid);

                    return _AttendeeRow(
                      uid: uid,
                      name: profile?.$1 ?? 'Runner',
                      photoUrl: profile?.$2,
                      isAttended: isAttended,
                      runId: run.id,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        Sizes.p12,
        CatchSpacing.s5,
        Sizes.p4,
      ),
      child: Row(
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
