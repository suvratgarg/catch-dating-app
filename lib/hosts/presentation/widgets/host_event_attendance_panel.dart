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
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum HostEventParticipantsMode { setup, live, report }

class HostEventAttendancePanel extends StatelessWidget {
  const HostEventAttendancePanel({
    super.key,
    required this.eventId,
    this.scrollable = false,
    this.showSummaryHeader = true,
  });

  final String eventId;
  final bool scrollable;
  final bool showSummaryHeader;

  @override
  Widget build(BuildContext context) {
    return HostEventParticipantsPanel(
      eventId: eventId,
      mode: HostEventParticipantsMode.live,
      scrollable: scrollable,
      showSummaryHeader: showSummaryHeader,
    );
  }
}

class HostEventParticipantsPanel extends ConsumerWidget {
  const HostEventParticipantsPanel({
    super.key,
    required this.eventId,
    required this.mode,
    this.scrollable = false,
    this.showSummaryHeader = true,
  });

  final String eventId;
  final HostEventParticipantsMode mode;
  final bool scrollable;
  final bool showSummaryHeader;

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
        return _ParticipantsList(
          viewModel: viewModel,
          mode: mode,
          scrollable: scrollable,
          showSummaryHeader: showSummaryHeader,
        );
      },
    );
  }
}

class _ParticipantsList extends ConsumerWidget {
  const _ParticipantsList({
    required this.viewModel,
    required this.mode,
    required this.scrollable,
    required this.showSummaryHeader,
  });

  final AttendanceSheetViewModel viewModel;
  final HostEventParticipantsMode mode;
  final bool scrollable;
  final bool showSummaryHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendeeIds = viewModel.attendeeIds;
    final waitlistedIds = viewModel.waitlistedIds;
    final mutation = ref.watch(EventBookingController.markAttendanceMutation);
    final usesRequestApproval = viewModel
        .event
        .effectiveEventPolicy
        .admissionPolicy
        .manualApprovalRequired;

    if (viewModel.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s5),
        child: Center(
          child: CatchEmptyState(
            icon: Icons.group_outlined,
            title: mode.emptyTitle,
            message: mode.emptyMessage,
            surface: false,
            iconStyle: CatchEmptyStateIconStyle.plain,
          ),
        ),
      );
    }

    final profileIds = viewModel.profileIds;
    final profilesAsync = ref.watch(attendeeProfilesProvider(profileIds));
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
                  ref.invalidate(attendeeProfilesProvider(profileIds)),
            ),
          )
        : _ParticipantRows(
            attendeeIds: attendeeIds,
            waitlistedIds: waitlistedIds,
            profiles: profiles,
            attendedIds: viewModel.attendedIds,
            eventId: viewModel.event.id,
            mode: mode,
            scrollable: scrollable,
            usesRequestApproval: usesRequestApproval,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mutation.hasError)
          ErrorBanner(message: mutationErrorMessage(mutation)),
        if (showSummaryHeader)
          _ParticipantsSummaryHeader(
            mode: mode,
            checkedInCount: viewModel.checkedInCount,
            totalCount: viewModel.totalCount,
            waitlistCount: viewModel.waitlistCount,
            usesRequestApproval: usesRequestApproval,
          ),
        if (scrollable) Expanded(child: rows) else rows,
      ],
    );
  }
}

class _ParticipantsSummaryHeader extends StatelessWidget {
  const _ParticipantsSummaryHeader({
    required this.mode,
    required this.checkedInCount,
    required this.totalCount,
    required this.waitlistCount,
    required this.usesRequestApproval,
  });

  final HostEventParticipantsMode mode;
  final int checkedInCount;
  final int totalCount;
  final int waitlistCount;
  final bool usesRequestApproval;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = mode == HostEventParticipantsMode.live
        ? HostToolPalette.forAttendanceState(
            context,
            HostEventAttendanceState.open,
          )
        : HostToolPalette.defaultPanel(context);

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
              ],
            ),
            gapH6,
            CatchBadge(
              label: mode.badgeLabel,
              tone: mode.badgeTone,
              uppercase: true,
              icon: mode.icon,
            ),
            gapH10,
            Row(
              children: [
                Expanded(
                  child: Text(
                    mode.title,
                    style: CatchTextStyles.titleM(context),
                  ),
                ),
                gapW12,
                Text(
                  '$checkedInCount / $totalCount checked in',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
            gapH8,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s1,
              children: [
                CatchBadge(
                  label: '$totalCount booked',
                  tone: totalCount == 0
                      ? CatchBadgeTone.neutral
                      : CatchBadgeTone.brand,
                ),
                CatchBadge(
                  label: '$checkedInCount checked in',
                  tone: checkedInCount == 0
                      ? CatchBadgeTone.neutral
                      : CatchBadgeTone.success,
                ),
                CatchBadge(
                  label: usesRequestApproval
                      ? '$waitlistCount requests'
                      : '$waitlistCount waitlist',
                  tone: waitlistCount == 0
                      ? CatchBadgeTone.neutral
                      : CatchBadgeTone.warning,
                ),
              ],
            ),
            if (mode == HostEventParticipantsMode.live) ...[
              gapH8,
              Text(
                usesRequestApproval
                    ? 'Tap a booked participant to toggle check-in. Requests are shown for host review context.'
                    : 'Tap a booked participant to toggle check-in. Waitlisted people are shown for context only.',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ParticipantRows extends StatelessWidget {
  const _ParticipantRows({
    required this.attendeeIds,
    required this.waitlistedIds,
    required this.profiles,
    required this.attendedIds,
    required this.eventId,
    required this.mode,
    required this.scrollable,
    required this.usesRequestApproval,
  });

  final List<String> attendeeIds;
  final List<String> waitlistedIds;
  final Map<String, (String, String?)> profiles;
  final Set<String> attendedIds;
  final String eventId;
  final HostEventParticipantsMode mode;
  final bool scrollable;
  final bool usesRequestApproval;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: !scrollable,
      primary: scrollable ? null : false,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: scrollable ? CatchSpacing.s6 : 0),
      children: [
        if (attendeeIds.isNotEmpty)
          _ParticipantSection(
            title: mode == HostEventParticipantsMode.report
                ? 'Attendance'
                : 'Booked',
            count: attendeeIds.length,
            children: [
              for (var i = 0; i < attendeeIds.length; i++) ...[
                _AttendeeRow(
                  uid: attendeeIds[i],
                  name: profiles[attendeeIds[i]]?.$1 ?? 'Runner',
                  photoUrl: profiles[attendeeIds[i]]?.$2,
                  isAttended: attendedIds.contains(attendeeIds[i]),
                  eventId: eventId,
                  mode: mode,
                ),
                if (i < attendeeIds.length - 1) gapH8,
              ],
            ],
          ),
        if (attendeeIds.isNotEmpty && waitlistedIds.isNotEmpty) gapH16,
        if (waitlistedIds.isNotEmpty)
          _ParticipantSection(
            title: usesRequestApproval ? 'Requests' : 'Waitlist',
            count: waitlistedIds.length,
            children: [
              for (var i = 0; i < waitlistedIds.length; i++) ...[
                _WaitlistedRow(
                  uid: waitlistedIds[i],
                  name: profiles[waitlistedIds[i]]?.$1 ?? 'Runner',
                  photoUrl: profiles[waitlistedIds[i]]?.$2,
                  usesRequestApproval: usesRequestApproval,
                ),
                if (i < waitlistedIds.length - 1) gapH8,
              ],
            ],
          ),
      ],
    );
  }
}

class _ParticipantSection extends StatelessWidget {
  const _ParticipantSection({
    required this.title,
    required this.count,
    required this.children,
  });

  final String title;
  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: CatchTextStyles.titleM(context)),
            const Spacer(),
            CatchBadge(
              label: '$count',
              tone: count == 0 ? CatchBadgeTone.neutral : CatchBadgeTone.brand,
            ),
          ],
        ),
        gapH10,
        Column(children: children),
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
    required this.eventId,
    required this.mode,
  });

  final String uid;
  final String name;
  final String? photoUrl;
  final bool isAttended;
  final String eventId;
  final HostEventParticipantsMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final mutation = ref.watch(EventBookingController.markAttendanceMutation);
    final label = _participantStatusLabel(mode: mode, isAttended: isAttended);
    final canToggle = mode == HostEventParticipantsMode.live;

    return CatchSurface(
      borderColor: t.line,
      radius: CatchRadius.md,
      clipBehavior: Clip.antiAlias,
      child: PersonRow(
        data: PersonRowData(
          name: name,
          imageUrl: photoUrl,
          seed: uid,
          metaLine: label.metaLine,
        ),
        trailing: _ParticipantTrailing(
          status: CatchBadge(
            label: label.badge,
            tone: label.tone,
            icon: label.icon,
            uppercase: true,
          ),
          uid: uid,
        ),
        onTap: canToggle
            ? mutation.isPending
                  ? null
                  : () {
                      EventBookingController.markAttendanceMutation.run(
                        ref,
                        (tx) async => tx
                            .get(eventBookingControllerProvider.notifier)
                            .markAttendance(eventId: eventId, userId: uid),
                      );
                    }
            : () => _openPublicProfile(context, uid),
      ),
    );
  }
}

({String badge, String metaLine, CatchBadgeTone tone, IconData icon})
_participantStatusLabel({
  required HostEventParticipantsMode mode,
  required bool isAttended,
}) {
  if (isAttended) {
    return (
      badge: 'checked in',
      metaLine: 'Checked in',
      tone: CatchBadgeTone.success,
      icon: Icons.check_circle_rounded,
    );
  }

  return switch (mode) {
    HostEventParticipantsMode.setup => (
      badge: 'booked',
      metaLine: 'Booked',
      tone: CatchBadgeTone.brand,
      icon: Icons.confirmation_number_outlined,
    ),
    HostEventParticipantsMode.live => (
      badge: 'not checked in',
      metaLine: 'Not checked in',
      tone: CatchBadgeTone.neutral,
      icon: Icons.radio_button_unchecked,
    ),
    HostEventParticipantsMode.report => (
      badge: 'absent',
      metaLine: 'Absent',
      tone: CatchBadgeTone.neutral,
      icon: Icons.radio_button_unchecked,
    ),
  };
}

class _WaitlistedRow extends StatelessWidget {
  const _WaitlistedRow({
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.usesRequestApproval,
  });

  final String uid;
  final String name;
  final String? photoUrl;
  final bool usesRequestApproval;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      radius: CatchRadius.md,
      clipBehavior: Clip.antiAlias,
      child: PersonRow(
        data: PersonRowData(
          name: name,
          imageUrl: photoUrl,
          seed: uid,
          metaLine: usesRequestApproval ? 'Requested' : 'Waitlisted',
        ),
        trailing: _ParticipantTrailing(
          status: CatchBadge(
            label: usesRequestApproval ? 'request' : 'waitlist',
            tone: usesRequestApproval
                ? CatchBadgeTone.warning
                : CatchBadgeTone.neutral,
            icon: usesRequestApproval
                ? Icons.pending_actions_rounded
                : Icons.hourglass_empty_rounded,
            uppercase: true,
          ),
          uid: uid,
        ),
        onTap: () => _openPublicProfile(context, uid),
      ),
    );
  }
}

class _ParticipantTrailing extends StatelessWidget {
  const _ParticipantTrailing({required this.status, required this.uid});

  final Widget status;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        status,
        gapW6,
        Tooltip(
          message: 'View profile',
          child: IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            color: t.ink2,
            onPressed: () => _openPublicProfile(context, uid),
            icon: const Icon(Icons.person_search_outlined),
          ),
        ),
      ],
    );
  }
}

void _openPublicProfile(BuildContext context, String uid) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;
  router.pushNamed(
    Routes.publicProfileScreen.name,
    pathParameters: {'uid': uid},
  );
}

extension on HostEventParticipantsMode {
  IconData get icon {
    return switch (this) {
      HostEventParticipantsMode.setup => Icons.groups_2_outlined,
      HostEventParticipantsMode.live => Icons.checklist_rounded,
      HostEventParticipantsMode.report => Icons.assignment_turned_in_outlined,
    };
  }

  String get title {
    return switch (this) {
      HostEventParticipantsMode.setup => 'Participants',
      HostEventParticipantsMode.live => 'Check-in',
      HostEventParticipantsMode.report => 'Attendance summary',
    };
  }

  String get badgeLabel {
    return switch (this) {
      HostEventParticipantsMode.setup => 'Participants',
      HostEventParticipantsMode.live => 'Live attendance',
      HostEventParticipantsMode.report => 'Report',
    };
  }

  CatchBadgeTone get badgeTone {
    return switch (this) {
      HostEventParticipantsMode.setup => CatchBadgeTone.brand,
      HostEventParticipantsMode.live => CatchBadgeTone.live,
      HostEventParticipantsMode.report => CatchBadgeTone.neutral,
    };
  }

  String get emptyTitle {
    return switch (this) {
      HostEventParticipantsMode.live => 'No attendees yet',
      HostEventParticipantsMode.setup ||
      HostEventParticipantsMode.report => 'No participants yet',
    };
  }

  String get emptyMessage {
    return switch (this) {
      HostEventParticipantsMode.live =>
        'No one has signed up for this event yet.',
      HostEventParticipantsMode.setup =>
        'Booked and waitlisted people will appear here.',
      HostEventParticipantsMode.report =>
        'Attendance and waitlist history will appear here once people sign up.',
    };
  }
}
