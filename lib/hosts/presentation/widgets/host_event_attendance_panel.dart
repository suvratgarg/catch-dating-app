import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/hosts/domain/host_attendance_window.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostEventAttendancePanel extends ConsumerWidget {
  const HostEventAttendancePanel({
    super.key,
    required this.eventId,
    this.scrollable = false,
  });

  final String eventId;
  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(
      attendanceSheetViewModelProvider(eventId),
    );

    return attendanceAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: CatchSpacing.s6),
        child: Center(child: CatchLoadingIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        child: CatchInlineErrorState.fromError(
          e,
          context: AppErrorContext.event,
          onRetry: () {
            ref.invalidate(watchEventProvider(eventId));
            ref.invalidate(watchEventParticipationsForEventProvider(eventId));
            ref.invalidate(attendanceSheetViewModelProvider(eventId));
          },
        ),
      ),
      data: (viewModel) {
        if (viewModel == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: CatchSpacing.s5),
            child: CatchEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Event not found',
              message: 'This event is no longer available.',
              surface: false,
              iconStyle: CatchEmptyStateIconStyle.plain,
            ),
          );
        }
        return _AttendanceList(viewModel: viewModel, scrollable: scrollable);
      },
    );
  }
}

class _AttendanceList extends ConsumerWidget {
  const _AttendanceList({required this.viewModel, required this.scrollable});

  final AttendanceSheetViewModel viewModel;
  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendeeIds = viewModel.attendeeIds;
    final mutation = ref.watch(EventBookingController.markAttendanceMutation);

    if (viewModel.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: CatchSpacing.s5),
        child: Center(
          child: CatchEmptyState(
            icon: Icons.group_outlined,
            title: 'No attendees yet',
            message: 'No one has signed up for this event yet.',
            surface: false,
            iconStyle: CatchEmptyStateIconStyle.plain,
          ),
        ),
      );
    }

    final profilesAsync = ref.watch(attendeeProfilesProvider(attendeeIds));
    final profiles = profilesAsync.asData?.value ?? {};
    final Widget rows = profilesAsync.isLoading
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: CatchSpacing.s6),
            child: Center(child: CatchLoadingIndicator()),
          )
        : profilesAsync.hasError
        ? Padding(
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: CatchInlineErrorState.fromError(
              profilesAsync.error!,
              context: AppErrorContext.event,
              onRetry: () =>
                  ref.invalidate(attendeeProfilesProvider(attendeeIds)),
            ),
          )
        : _AttendeeRows(
            attendeeIds: attendeeIds,
            profiles: profiles,
            attendedIds: viewModel.attendedIds,
            eventId: viewModel.event.id,
            scrollable: scrollable,
          );

    return Column(
      children: [
        if (mutation.hasError)
          ErrorBanner(message: mutationErrorMessage(mutation)),
        _AttendanceSummaryHeader(
          checkedInCount: viewModel.checkedInCount,
          totalCount: viewModel.totalCount,
        ),
        if (scrollable) Expanded(child: rows) else rows,
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
      HostEventAttendanceState.open,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
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
                Expanded(
                  child: Text(
                    '$checkedInCount / $totalCount checked in',
                    style: CatchTextStyles.titleM(context),
                  ),
                ),
                gapW12,
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

class _AttendeeRows extends StatelessWidget {
  const _AttendeeRows({
    required this.attendeeIds,
    required this.profiles,
    required this.attendedIds,
    required this.eventId,
    required this.scrollable,
  });

  final List<String> attendeeIds;
  final Map<String, (String, String?)> profiles;
  final Set<String> attendedIds;
  final String eventId;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: !scrollable,
      primary: scrollable ? null : false,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: scrollable ? CatchSpacing.s6 : 0),
      itemCount: attendeeIds.length,
      separatorBuilder: (_, _) => const SizedBox(height: CatchSpacing.s2),
      itemBuilder: (context, index) {
        final uid = attendeeIds[index];
        final profile = profiles[uid];
        final isAttended = attendedIds.contains(uid);

        return _AttendeeRow(
          uid: uid,
          name: profile?.$1 ?? 'Runner',
          photoUrl: profile?.$2,
          isAttended: isAttended,
          eventId: eventId,
        );
      },
    );
  }
}

class _AttendeeRow extends ConsumerWidget {
  const _AttendeeRow({
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.isAttended,
    required this.eventId,
  });

  final String uid;
  final String name;
  final String? photoUrl;
  final bool isAttended;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final mutation = ref.watch(EventBookingController.markAttendanceMutation);

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
                EventBookingController.markAttendanceMutation.run(
                  ref,
                  (tx) async => tx
                      .get(eventBookingControllerProvider.notifier)
                      .markAttendance(eventId: eventId, userId: uid),
                );
              },
      ),
    );
  }
}
