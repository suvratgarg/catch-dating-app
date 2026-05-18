import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/host_tools/presentation/host_club_tools.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostEventManageRouteScreen extends ConsumerWidget {
  const HostEventManageRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
  });

  final String clubId;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final eventAsync = ref.watch(watchEventProvider(eventId));

    final loading =
        uidAsync.isLoading || clubAsync.isLoading || eventAsync.isLoading;
    if (loading) {
      return Scaffold(
        backgroundColor: CatchTokens.of(context).bg,
        body: const SafeArea(child: Center(child: CatchLoadingIndicator())),
      );
    }

    final error = uidAsync.error ?? clubAsync.error ?? eventAsync.error;
    if (error != null) {
      return CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.event,
        onRetry: () {
          ref.invalidate(fetchClubProvider(clubId));
          ref.invalidate(watchEventProvider(eventId));
        },
      );
    }

    final uid = uidAsync.asData?.value;
    final club = clubAsync.asData?.value;
    final event = eventAsync.asData?.value;
    if (club == null || event == null) {
      return const CatchErrorScaffold(
        title: 'Event not found',
        message: 'This hosted event is no longer available.',
      );
    }

    if (uid == null || club.hostUserId != uid) {
      return const CatchErrorScaffold(
        title: 'Action unavailable',
        message: 'You can manage only events that you host.',
        icon: Icons.block_rounded,
      );
    }

    return HostEventManageScreen(
      club: club,
      event: event,
      onBackToSuccess: () => Navigator.of(context).maybePop(),
    );
  }
}

class HostEventManageScreen extends ConsumerWidget {
  const HostEventManageScreen({
    super.key,
    required this.club,
    required this.event,
    required this.onBackToSuccess,
  });

  final Club club;
  final Event event;
  final VoidCallback onBackToSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(event.id),
    );
    final roster = rosterAsync.asData?.value;
    final bookedCount = math.max(roster?.bookedCount ?? 0, event.signedUpCount);
    final checkedInCount = math.max(
      roster?.checkedInCount ?? 0,
      event.attendedCount,
    );
    final waitlistCount = math.max(
      roster?.waitlistedCount ?? 0,
      event.waitlistCount,
    );
    final baseRevenueEstimateRupees = bookedCount * (event.priceInPaise ~/ 100);
    final usesDemandPricing = event.effectiveEventPolicy.usesDemandPricing;
    final hasKnownActivity =
        bookedCount > 0 || checkedInCount > 0 || waitlistCount > 0;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            12,
            CatchSpacing.s5,
            24,
          ),
          children: [
            Row(
              children: [
                IconBtn(
                  onTap: onBackToSuccess,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: t.ink,
                  ),
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOST MANAGE',
                        style: CatchTextStyles.labelM(context, color: t.ink3)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Text(event.title, style: CatchTextStyles.titleL(context)),
                    ],
                  ),
                ),
              ],
            ),
            gapH18,
            if (event.isFull) ...[
              CatchSurface(
                padding: const EdgeInsets.all(CatchSpacing.s4),
                backgroundColor: t.ink,
                borderWidth: 0,
                radius: CatchRadius.lg,
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, color: t.surface, size: 18),
                    gapW10,
                    Text(
                      'FULL',
                      style: CatchTextStyles.titleM(context, color: t.surface),
                    ),
                  ],
                ),
              ),
              gapH12,
            ],
            Row(
              children: [
                Expanded(
                  child: HostStatChip(
                    icon: Icons.check_circle_outline_rounded,
                    value: '$bookedCount/${event.capacityLimit}',
                    label: 'Booked',
                  ),
                ),
                gapW8,
                Expanded(
                  child: HostStatChip(
                    icon: Icons.access_time_rounded,
                    value: '$waitlistCount',
                    label: 'Waitlist',
                  ),
                ),
                gapW8,
                Expanded(
                  child: HostStatChip(
                    icon: Icons.currency_rupee_rounded,
                    value: baseRevenueEstimateRupees > 0
                        ? '₹$baseRevenueEstimateRupees'
                        : '-',
                    label: usesDemandPricing ? 'Base est.' : 'Revenue',
                  ),
                ),
              ],
            ),
            if (usesDemandPricing) ...[
              gapH8,
              Text(
                'Base estimate uses the starting price. Demand-priced bookings may settle higher.',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ],
            gapH20,
            _HostEventSummaryCard(club: club, event: event),
            if (event.effectiveEventPolicy.usesInviteOnly) ...[
              gapH20,
              _HostPrivateAccessCard(club: club, event: event),
            ],
            gapH20,
            _HostEventActionsCard(
              event: event,
              hasKnownActivity: hasKnownActivity,
              onDeleted: onBackToSuccess,
            ),
            gapH20,
            _HostEventSuccessCard(club: club, event: event),
            gapH20,
            _HostRosterHeader(
              icon: Icons.groups_2_outlined,
              title: 'Roster',
              count: bookedCount,
            ),
            gapH10,
            _HostEventRosterSection(
              rosterAsync: rosterAsync,
              eventId: event.id,
              selector: (roster) => roster.bookedIds,
              emptyText: 'No bookings yet.',
              loadingText: 'Loading bookings...',
              trailingLabel: event.isFree ? 'FREE' : 'PAID',
            ),
            gapH20,
            _HostRosterHeader(
              icon: Icons.pending_actions_outlined,
              title: 'Waitlist',
              count: waitlistCount,
            ),
            gapH10,
            _HostEventRosterSection(
              rosterAsync: rosterAsync,
              eventId: event.id,
              selector: (roster) => roster.waitlistedIds,
              emptyText: 'No one is waiting.',
              loadingText: 'Loading waitlist...',
              trailingLabel: 'WAITLIST',
            ),
          ],
        ),
      ),
    );
  }
}

class _HostPrivateAccessCard extends ConsumerWidget {
  const _HostPrivateAccessCard({required this.club, required this.event});

  final Club club;
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessAsync = ref.watch(watchEventPrivateAccessProvider(event.id));
    return accessAsync.when(
      loading: () => const _PrivateAccessShell(
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            gapW12,
            Text('Loading invite access...'),
          ],
        ),
      ),
      error: (error, _) => CatchInlineErrorState.fromError(
        error,
        context: AppErrorContext.event,
        compact: true,
        onRetry: () =>
            ref.invalidate(watchEventPrivateAccessProvider(event.id)),
      ),
      data: (access) =>
          _PrivateAccessBody(club: club, event: event, access: access),
    );
  }
}

class _PrivateAccessShell extends StatelessWidget {
  const _PrivateAccessShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: child,
    );
  }
}

class _PrivateAccessBody extends ConsumerWidget {
  const _PrivateAccessBody({
    required this.club,
    required this.event,
    required this.access,
  });

  final Club club;
  final Event event;
  final EventPrivateAccess? access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final inviteCode = access?.inviteCode.trim();
    final inviteLink = inviteCode == null || inviteCode.isEmpty
        ? null
        : AppDeepLinks.event(
            clubId: club.id,
            eventId: event.id,
            inviteCode: inviteCode,
          ).toString();

    return _PrivateAccessShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.key_outlined, color: t.primary),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Private access',
                      style: CatchTextStyles.titleM(context),
                    ),
                    gapH4,
                    Text(
                      inviteCode == null || inviteCode.isEmpty
                          ? 'This event requires an invite, but no host-readable access code was found.'
                          : 'This event can stay listed; only people with this code or private link can book.',
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              const CatchBadge(label: 'Invite', tone: CatchBadgeTone.brand),
            ],
          ),
          if (inviteCode != null && inviteCode.isNotEmpty) ...[
            gapH14,
            _HostEventSummaryRow(
              icon: Icons.password_rounded,
              label: 'Code',
              value: inviteCode,
            ),
            if (inviteLink != null)
              _HostEventSummaryRow(
                icon: Icons.link_rounded,
                label: 'Link',
                value: inviteLink,
                showDivider: false,
              ),
            gapH14,
            CatchButton(
              label: 'Share private link',
              onPressed: inviteLink == null
                  ? null
                  : () =>
                        unawaited(_sharePrivateLink(context, ref, inviteLink)),
              variant: CatchButtonVariant.secondary,
              icon: const Icon(Icons.ios_share_rounded),
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _sharePrivateLink(
    BuildContext context,
    WidgetRef ref,
    String inviteLink,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      await ref
          .read(externalShareControllerProvider)
          .shareText(
            text: 'Join ${event.title} from ${club.name}: $inviteLink',
            subject: event.title,
            origin: origin,
          );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open share sheet.')),
      );
    }
  }
}

class _HostEventSuccessCard extends StatelessWidget {
  const _HostEventSuccessCard({required this.club, required this.event});

  final Club club;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_graph_rounded, color: t.primary),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event success',
                      style: CatchTextStyles.titleM(context),
                    ),
                    gapH4,
                    Text(
                      'Set up the live host flow, attendee companion, private follow-up, and post-event report.',
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              const CatchBadge(label: 'Live', tone: CatchBadgeTone.success),
            ],
          ),
          gapH14,
          CatchButton(
            label: 'Open event success',
            onPressed: () => context.pushNamed(
              Routes.eventSuccessHostScreen.name,
              pathParameters: {'clubId': club.id, 'eventId': event.id},
              extra: event,
            ),
            variant: CatchButtonVariant.secondary,
            icon: const Icon(Icons.visibility_outlined),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _HostEventActionsCard extends ConsumerWidget {
  const _HostEventActionsCard({
    required this.event,
    required this.hasKnownActivity,
    required this.onDeleted,
  });

  final Event event;
  final bool hasKnownActivity;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final cancelMutation = ref.watch(
      EventBookingController.hostCancelEventMutation,
    );
    final deleteMutation = ref.watch(
      EventBookingController.deleteEventMutation,
    );
    final errorMutation = [
      cancelMutation,
      deleteMutation,
    ].firstWhere((mutation) => mutation.hasError, orElse: () => cancelMutation);
    final isMutating = cancelMutation.isPending || deleteMutation.isPending;

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.admin_panel_settings_outlined, color: t.ink2),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Host actions',
                      style: CatchTextStyles.titleM(context),
                    ),
                    gapH4,
                    Text(
                      event.isCancelled
                          ? 'This event has already been cancelled.'
                          : 'Cancel events that have activity. Delete only unused drafts or accidental events.',
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              if (event.isCancelled)
                const CatchBadge(
                  label: 'Cancelled',
                  tone: CatchBadgeTone.danger,
                ),
            ],
          ),
          if (errorMutation.hasError) ...[
            gapH12,
            ErrorBanner.fromError(
              (errorMutation as MutationError).error,
              context: AppErrorContext.event,
            ),
          ],
          gapH14,
          if (!event.isCancelled)
            CatchButton(
              label: 'Cancel event',
              onPressed: isMutating
                  ? null
                  : () => _confirmCancelEvent(context, ref),
              variant: CatchButtonVariant.danger,
              icon: const Icon(Icons.cancel_outlined),
              isLoading: cancelMutation.isPending,
              fullWidth: true,
            ),
          if (!event.isCancelled) gapH10,
          if (hasKnownActivity)
            Text(
              'Delete is unavailable once an event has bookings, waitlist, attendance, payments, or reviews. Cancel it instead.',
              style: CatchTextStyles.bodyS(context, color: t.ink3),
            )
          else
            CatchButton(
              label: 'Delete event',
              onPressed: isMutating
                  ? null
                  : () => _confirmDeleteEvent(context, ref),
              variant: CatchButtonVariant.secondary,
              icon: const Icon(Icons.delete_outline_rounded),
              isLoading: deleteMutation.isPending,
              fullWidth: true,
              foregroundColor: t.danger,
              borderColor: t.danger.withValues(alpha: 0.45),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelEvent(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Cancel this event?',
      message: hasKnownActivity
          ? 'Booked and waitlisted attendees will be notified. Attendance, payment, and review history will stay attached to this event.'
          : 'This removes the event from upcoming schedules while keeping a history record. If it was created by mistake and has no activity, you can delete it instead.',
      actions: const [
        CatchDialogAction(label: 'Keep event', value: false, isDefault: true),
        CatchDialogAction(
          label: 'Cancel event',
          value: true,
          isDestructive: true,
        ),
      ],
    );
    if (confirmed != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    unawaited(
      EventBookingController.hostCancelEventMutation.run(ref, (tx) async {
        await tx
            .get(eventBookingControllerProvider.notifier)
            .cancelHostedEvent(event: event);
        ref.invalidate(watchEventProvider(event.id));
        ref.invalidate(watchEventParticipationRosterProvider(event.id));
        messenger.showSnackBar(
          const SnackBar(content: Text('Event cancelled.')),
        );
      }),
    );
  }

  Future<void> _confirmDeleteEvent(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Delete this event?',
      message:
          'Only events with no bookings, waitlist, attendance, payments, or reviews can be deleted. This permanently removes the event.',
      actions: const [
        CatchDialogAction(label: 'Keep event', value: false, isDefault: true),
        CatchDialogAction(
          label: 'Delete event',
          value: true,
          isDestructive: true,
        ),
      ],
    );
    if (confirmed != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    unawaited(
      EventBookingController.deleteEventMutation.run(ref, (tx) async {
        await tx
            .get(eventBookingControllerProvider.notifier)
            .deleteHostedEvent(event: event);
        ref.invalidate(watchEventProvider(event.id));
        ref.invalidate(watchEventParticipationRosterProvider(event.id));
        messenger.showSnackBar(const SnackBar(content: Text('Event deleted.')));
        onDeleted();
      }),
    );
  }
}

class _HostEventSummaryCard extends StatelessWidget {
  const _HostEventSummaryCard({required this.club, required this.event});

  final Club club;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final price = event.isFree ? 'Free' : '₹${event.priceInPaise ~/ 100}';

    return CatchSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.s3,
      ),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: Column(
        children: [
          _HostEventSummaryRow(
            icon: Icons.groups_rounded,
            label: 'Club',
            value: club.name,
          ),
          _HostEventSummaryRow(
            icon: Icons.location_on_outlined,
            label: 'Meet',
            value: event.meetingPoint,
          ),
          _HostEventSummaryRow(
            icon: Icons.route_rounded,
            label: 'Event',
            value: event.activitySummaryLabel,
          ),
          _HostEventSummaryRow(
            icon: Icons.payments_outlined,
            label: 'Price',
            value: price,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _HostEventSummaryRow extends StatelessWidget {
  const _HostEventSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: t.ink2, size: 18),
            gapW10,
            Text(label, style: CatchTextStyles.bodyS(context, color: t.ink2)),
            gapW16,
            Expanded(
              child: Text(
                value,
                style: CatchTextStyles.labelL(context),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (showDivider) ...[gapH12, Divider(color: t.line, height: 1), gapH12],
      ],
    );
  }
}

class _HostRosterHeader extends StatelessWidget {
  const _HostRosterHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: t.ink2),
        gapW8,
        Text(title, style: CatchTextStyles.titleM(context)),
        const Spacer(),
        CatchBadge(
          label: '$count',
          tone: count == 0 ? CatchBadgeTone.neutral : CatchBadgeTone.brand,
        ),
      ],
    );
  }
}

class _HostEventRosterSection extends ConsumerWidget {
  const _HostEventRosterSection({
    required this.rosterAsync,
    required this.eventId,
    required this.selector,
    required this.emptyText,
    required this.loadingText,
    required this.trailingLabel,
  });

  final AsyncValue<EventParticipationRoster> rosterAsync;
  final String eventId;
  final List<String> Function(EventParticipationRoster roster) selector;
  final String emptyText;
  final String loadingText;
  final String trailingLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return rosterAsync.when(
      loading: () => _HostEventRosterLoading(text: loadingText),
      error: (e, _) => CatchInlineErrorState.fromError(
        e,
        context: AppErrorContext.event,
        compact: true,
        onRetry: () =>
            ref.invalidate(watchEventParticipationRosterProvider(eventId)),
      ),
      data: (roster) => _HostEventUserList(
        userIds: selector(roster),
        emptyText: emptyText,
        trailingLabel: trailingLabel,
      ),
    );
  }
}

class _HostEventRosterLoading extends StatelessWidget {
  const _HostEventRosterLoading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: t.primary),
          ),
          gapW12,
          Text(text, style: CatchTextStyles.bodyS(context, color: t.ink2)),
        ],
      ),
    );
  }
}

class _HostEventUserList extends ConsumerWidget {
  const _HostEventUserList({
    required this.userIds,
    required this.emptyText,
    required this.trailingLabel,
  });

  final List<String> userIds;
  final String emptyText;
  final String trailingLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final profilesAsync = ref.watch(attendeeProfilesProvider(userIds));
    final profiles = profilesAsync.asData?.value ?? {};

    return CatchSurface(
      borderColor: t.line,
      radius: CatchRadius.lg,
      clipBehavior: Clip.antiAlias,
      child: userIds.isEmpty
          ? CatchEmptyState(
              icon: Icons.group_outlined,
              title: emptyText,
              message: 'New sign-ups will appear here.',
              surface: false,
              iconStyle: CatchEmptyStateIconStyle.plain,
              iconSize: 36,
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s4,
                vertical: CatchSpacing.s6,
              ),
              titleStyle: CatchTextStyles.titleM(context),
              messageStyle: CatchTextStyles.bodyS(context, color: t.ink2),
            )
          : Column(
              children: [
                for (var i = 0; i < userIds.length; i++) ...[
                  PersonRow(
                    data: PersonRowData(
                      name: profiles[userIds[i]]?.$1 ?? 'Runner',
                      imageUrl: profiles[userIds[i]]?.$2,
                      seed: userIds[i],
                      metaLine: profilesAsync.isLoading
                          ? 'Loading profile...'
                          : profiles[userIds[i]] == null
                          ? 'Profile unavailable'
                          : null,
                    ),
                    trailing: CatchBadge(
                      label: trailingLabel,
                      tone: trailingLabel == 'WAITLIST'
                          ? CatchBadgeTone.neutral
                          : CatchBadgeTone.brand,
                      uppercase: true,
                    ),
                  ),
                  if (i < userIds.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 72),
                      child: Divider(color: t.line, height: 1),
                    ),
                ],
              ],
            ),
    );
  }
}
