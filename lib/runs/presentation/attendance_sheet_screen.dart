import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
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
    final t = CatchTokens.of(context);
    final signedUpIds = run.signedUpUserIds;
    final attendedIds = run.attendedUserIds;
    final mutation = ref.watch(RunBookingController.markAttendanceMutation);

    if (signedUpIds.isEmpty) {
      return Center(
        child: Text(
          'No one has signed up for this run yet.',
          style: CatchTextStyles.bodyM(context, color: t.ink2),
        ),
      );
    }

    final profilesAsync = ref.watch(runnerProfilesProvider(signedUpIds));
    final profiles = profilesAsync.asData?.value ?? {};

    final attendedCount = signedUpIds.where((id) => attendedIds.contains(id)).length;

    return Column(
      children: [
        if (mutation.hasError)
          ErrorBanner(
            message: _attendanceErrorMessage(
              (mutation as MutationError).error,
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            Sizes.p12,
            CatchSpacing.s5,
            Sizes.p4,
          ),
          child: Row(
            children: [
              Text(
                '$attendedCount / ${signedUpIds.length} checked in',
                style: CatchTextStyles.titleM(context),
              ),
              const Spacer(),
              Text(
                'Tap to toggle',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ],
          ),
        ),
        Expanded(
          child: profilesAsync.isLoading
              ? const CatchLoadingIndicator()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s5,
                    0,
                    CatchSpacing.s5,
                    Sizes.p24,
                  ),
                  itemCount: signedUpIds.length,
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
                      runClubId: run.runClubId,
                    );
                  },
                ),
        ),
      ],
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
    required this.runClubId,
  });

  final String uid;
  final String name;
  final String? photoUrl;
  final bool isAttended;
  final String runId;
  final String runClubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final mutation =
        ref.watch(RunBookingController.markAttendanceMutation);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(CatchRadius.md),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.p14,
              vertical: Sizes.p12,
            ),
            child: Row(
              children: [
                PersonAvatar(
                  size: 40,
                  name: name,
                  imageUrl: photoUrl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: CatchTextStyles.bodyM(context),
                  ),
                ),
                Icon(
                  isAttended
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isAttended ? t.primary : t.ink3,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _attendanceErrorMessage(Object error) {
  if (error is AppException) return error.message;
  if (error is FirebaseFunctionsException) {
    final message = error.message;
    if (message != null && message.trim().isNotEmpty) return message.trim();
  }
  if (error is StateError && error.message.isNotEmpty) return error.message;
  return firestoreErrorMessage(error);
}
