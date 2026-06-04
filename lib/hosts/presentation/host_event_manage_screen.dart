import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_invite_share_copy.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_attendance_panel.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum HostEventManageSection { setup, live, report }

class HostEventManageRouteScreen extends ConsumerWidget {
  const HostEventManageRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
    this.initialSection = HostEventManageSection.setup,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;
  final HostEventManageSection initialSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final event = eventAsync.asData?.value ?? initialEvent;

    final loading =
        uidAsync.isLoading ||
        clubAsync.isLoading ||
        (eventAsync.isLoading && event == null);
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
    if (club == null || event == null) {
      return const CatchErrorScaffold(
        title: 'Event not found',
        message: 'This hosted event is no longer available.',
      );
    }

    if (uid == null || !club.isHostedBy(uid)) {
      return CatchErrorScaffold(
        title: 'Action unavailable',
        message: 'You can manage only events that you host.',
        icon: CatchIcons.blockRounded,
      );
    }

    return HostEventManageScreen(
      club: club,
      event: event,
      onBackToSuccess: () => Navigator.of(context).maybePop(),
      initialSection: initialSection,
    );
  }
}

class HostEventManageScreen extends ConsumerStatefulWidget {
  const HostEventManageScreen({
    super.key,
    required this.club,
    required this.event,
    required this.onBackToSuccess,
    this.initialSection = HostEventManageSection.setup,
    this.onSectionChanged,
    this.eventSuccessFixtureActions,
  });

  final Club club;
  final Event event;
  final VoidCallback onBackToSuccess;
  final HostEventManageSection initialSection;
  final ValueChanged<HostEventManageSection>? onSectionChanged;
  final EventSuccessHostFixtureActions? eventSuccessFixtureActions;

  @override
  ConsumerState<HostEventManageScreen> createState() =>
      _HostEventManageScreenState();
}

class _HostEventManageScreenState extends ConsumerState<HostEventManageScreen> {
  late HostEventManageSection _selectedSection = widget.initialSection;

  @override
  void didUpdateWidget(covariant HostEventManageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      _selectedSection = widget.initialSection;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final club = widget.club;
    final event = widget.event;
    final onBackToSuccess = widget.onBackToSuccess;
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(event.id),
    );
    final roster = rosterAsync.asData?.value;
    final hasKnownActivity =
        (roster?.bookedCount ?? event.signedUpCount) > 0 ||
        (roster?.checkedInCount ?? event.attendedCount) > 0 ||
        (roster?.waitlistedCount ?? event.waitlistCount) > 0;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          key: const Key('host_event_manage_scroll_view'),
          padding: CatchInsets.pageBodyTight,
          children: [
            Row(
              children: [
                IconBtn(
                  onTap: onBackToSuccess,
                  child: Icon(
                    CatchIcons.arrowBackIosNewRounded,
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
                        style: CatchTextStyles.kicker(context, color: t.ink3),
                      ),
                      Text(event.title, style: CatchTextStyles.titleL(context)),
                    ],
                  ),
                ),
              ],
            ),
            gapH18,
            _HostManageSectionPicker(
              selectedSection: _selectedSection,
              onChanged: (section) {
                setState(() => _selectedSection = section);
                widget.onSectionChanged?.call(section);
              },
            ),
            gapH20,
            if (event.isFull) ...[
              CatchSurface(
                padding: CatchInsets.content,
                backgroundColor: t.ink,
                borderWidth: 0,
                child: Row(
                  children: [
                    Icon(
                      CatchIcons.lockRounded,
                      color: t.surface,
                      size: CatchIcon.md,
                    ),
                    gapW10,
                    Text(
                      'FULL',
                      style: CatchTextStyles.sectionTitle(
                        context,
                        color: t.surface,
                      ),
                    ),
                  ],
                ),
              ),
              gapH12,
            ],
            ..._selectedSectionChildren(
              club: club,
              event: event,
              hasKnownActivity: hasKnownActivity,
              onDeleted: onBackToSuccess,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _selectedSectionChildren({
    required Club club,
    required Event event,
    required bool hasKnownActivity,
    required VoidCallback onDeleted,
  }) {
    return switch (_selectedSection) {
      HostEventManageSection.setup => [
        HostEventParticipantsPanel(
          eventId: event.id,
          mode: HostEventParticipantsMode.setup,
        ),
        gapH20,
        _HostEventSummaryCard(club: club, event: event),
        if (event.effectiveEventPolicy.usesInviteOnly) ...[
          gapH20,
          _HostPrivateAccessCard(club: club, event: event),
        ],
        gapH20,
        EventSuccessHostSection(
          event: event,
          showTabs: false,
          fixtureActions: widget.eventSuccessFixtureActions,
        ),
        gapH20,
        _HostEventActionsCard(
          event: event,
          hasKnownActivity: hasKnownActivity,
          onDeleted: onDeleted,
        ),
      ],
      HostEventManageSection.live => [
        EventSuccessHostSection(
          event: event,
          initialTab: EventSuccessHostTab.live,
          showTabs: false,
          fixtureActions: widget.eventSuccessFixtureActions,
          liveRoster: HostEventParticipantsPanel(
            eventId: event.id,
            mode: HostEventParticipantsMode.live,
            showSummaryHeader: false,
          ),
        ),
      ],
      HostEventManageSection.report => [
        HostEventParticipantsPanel(
          eventId: event.id,
          mode: HostEventParticipantsMode.report,
        ),
        gapH20,
        EventSuccessHostSection(
          event: event,
          initialTab: EventSuccessHostTab.report,
          showTabs: false,
          fixtureActions: widget.eventSuccessFixtureActions,
        ),
      ],
    };
  }
}

class _HostManageSectionPicker extends StatelessWidget {
  const _HostManageSectionPicker({
    required this.selectedSection,
    required this.onChanged,
  });

  final HostEventManageSection selectedSection;
  final ValueChanged<HostEventManageSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return CatchSegmentedControl<HostEventManageSection>(
      selected: selectedSection,
      onChanged: onChanged,
      expanded: true,
      style: CatchSegmentedControlStyle.surface,
      segments: [
        for (final section in HostEventManageSection.values)
          CatchSegment(
            value: section,
            label: section.label,
            icon: section.icon,
          ),
      ],
    );
  }
}

extension on HostEventManageSection {
  String get label {
    return switch (this) {
      HostEventManageSection.setup => 'Setup',
      HostEventManageSection.live => 'Live',
      HostEventManageSection.report => 'Report',
    };
  }

  IconData get icon {
    return switch (this) {
      HostEventManageSection.setup => CatchIcons.tuneRounded,
      HostEventManageSection.live => CatchIcons.playCircleOutlineRounded,
      HostEventManageSection.report => CatchIcons.insightsOutlined,
    };
  }
}

class _HostPrivateAccessCard extends ConsumerWidget {
  const _HostPrivateAccessCard({required this.club, required this.event});

  final Club club;
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final accessAsync = ref.watch(watchEventPrivateAccessProvider(event.id));
    return accessAsync.when(
      loading: () => _PrivateAccessShell(
        child: Row(
          children: [
            const SizedBox.square(
              dimension: CatchIcon.md,
              child: CatchLoadingIndicator(strokeWidth: 2),
            ),
            gapW12,
            Text(
              'Loading invite access...',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
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
      padding: CatchInsets.content,
      borderColor: t.line,
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
    final inviteLinksAsync = ref.watch(watchEventInviteLinksProvider(event.id));
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
              Icon(CatchIcons.keyOutlined, color: t.primary),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Private access',
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH4,
                    Text(
                      inviteCode == null || inviteCode.isEmpty
                          ? 'This event requires an invite, but no host-readable access code was found.'
                          : 'This event can stay listed; only people with this code or private link can book.',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
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
              icon: CatchIcons.passwordRounded,
              label: 'Code',
              value: inviteCode,
            ),
            if (inviteLink != null)
              _HostEventSummaryRow(
                icon: CatchIcons.linkRounded,
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
              icon: Icon(
                CatchIcons.platformShare(platform: Theme.of(context).platform),
              ),
              fullWidth: true,
            ),
            gapH18,
            _HostInviteLinksList(
              event: event,
              inviteCode: inviteCode,
              linksAsync: inviteLinksAsync,
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
            text: EventInviteShareCopy.hostPrivateInviteText(
              event: event,
              clubName: club.name,
              inviteLink: inviteLink,
            ),
            subject: EventInviteShareCopy.subject(event),
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

class _HostInviteLinksList extends ConsumerWidget {
  const _HostInviteLinksList({
    required this.event,
    required this.inviteCode,
    required this.linksAsync,
  });

  final Event event;
  final String inviteCode;
  final AsyncValue<List<EventInviteLink>> linksAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Named invite links',
                style: CatchTextStyles.labelL(context),
              ),
            ),
            CatchButton(
              label: 'New link',
              onPressed: () => unawaited(_createNamedLink(context, ref)),
              variant: CatchButtonVariant.secondary,
              icon: Icon(CatchIcons.addRounded),
            ),
          ],
        ),
        gapH6,
        Text(
          'Track which channels create demand, bookings, arrivals, catches, and chats.',
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        gapH12,
        linksAsync.when(
          loading: () => Text(
            'Loading invite links...',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          error: (error, _) => CatchInlineErrorState.fromError(
            error,
            context: AppErrorContext.event,
            compact: true,
            onRetry: () =>
                ref.invalidate(watchEventInviteLinksProvider(event.id)),
          ),
          data: (links) => links.isEmpty
              ? Text(
                  'Create links for Instagram bio, WhatsApp alumni, venue partners, or any channel you want to compare.',
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                )
              : Column(
                  children: [
                    for (final link in links)
                      _HostInviteLinkRow(
                        event: event,
                        inviteCode: inviteCode,
                        link: link,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _createNamedLink(BuildContext context, WidgetRef ref) async {
    final draft = await _showInviteLinkDialog(context);
    if (draft == null) return;
    try {
      final response = await ref
          .read(eventRepositoryProvider)
          .createInviteLink(
            eventId: event.id,
            label: draft.label,
            source: draft.source,
          );
      final url = _inviteLinkUrl(
        event: event,
        inviteCode: inviteCode,
        inviteLinkId: response.inviteLinkId,
      );
      await Clipboard.setData(ClipboardData(text: url));
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${response.label} copied.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create invite link.')),
      );
    }
  }
}

class _HostInviteLinkRow extends ConsumerWidget {
  const _HostInviteLinkRow({
    required this.event,
    required this.inviteCode,
    required this.link,
  });

  final Event event;
  final String inviteCode;
  final EventInviteLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final url = _inviteLinkUrl(
      event: event,
      inviteCode: inviteCode,
      inviteLinkId: link.id,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
      child: CatchSurface(
        padding: CatchInsets.contentDense,
        borderColor: t.line,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          link.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.labelL(context),
                        ),
                      ),
                      if (link.isDisabled) ...[
                        gapW8,
                        const CatchBadge(
                          label: 'Disabled',
                          tone: CatchBadgeTone.neutral,
                        ),
                      ],
                    ],
                  ),
                  if (link.source != null) ...[
                    gapH2,
                    Text(
                      link.source!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                  gapH8,
                  Text(
                    _inviteLinkStats(link),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
              ),
            ),
            gapW8,
            Tooltip(
              message: 'Copy link',
              child: IconBtn(
                onTap: () => unawaited(_copyInviteLink(context, url)),
                child: Icon(CatchIcons.contentCopyRounded, size: CatchIcon.sm),
              ),
            ),
            if (!link.isDisabled) ...[
              gapW8,
              Tooltip(
                message: 'Disable link',
                child: IconBtn(
                  onTap: () => unawaited(_disableInviteLink(context, ref)),
                  child: Icon(
                    CatchIcons.hourglassDisabledRounded,
                    size: CatchIcon.sm,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _copyInviteLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${link.label} copied.')));
  }

  Future<void> _disableInviteLink(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Disable invite link?',
      message:
          'This stops new attribution for ${link.label}, but keeps its history in reporting.',
      actions: const [
        CatchDialogAction(label: 'Keep active', value: false),
        CatchDialogAction(label: 'Disable', value: true, isDestructive: true),
      ],
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(eventRepositoryProvider)
          .disableInviteLink(eventId: event.id, inviteLinkId: link.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${link.label} disabled.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not disable invite link.')),
      );
    }
  }
}

class _InviteLinkDraft {
  const _InviteLinkDraft({required this.label, this.source});

  final String label;
  final String? source;
}

Future<_InviteLinkDraft?> _showInviteLinkDialog(BuildContext context) async {
  final labelController = TextEditingController();
  final sourceController = TextEditingController();
  try {
    return showDialog<_InviteLinkDraft>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final label = labelController.text.trim();
          final source = sourceController.text.trim();
          return AlertDialog(
            title: const Text('New invite link'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchTextField(
                  label: 'Label',
                  controller: labelController,
                  hintText: 'Instagram bio',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
                gapH12,
                CatchTextField(
                  label: 'Source',
                  isOptional: true,
                  controller: sourceController,
                  hintText: 'instagram',
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            actions: [
              CatchTextButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              CatchTextButton(
                label: 'Create',
                onPressed: label.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(
                        _InviteLinkDraft(
                          label: label,
                          source: source.isEmpty ? null : source,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  } finally {
    labelController.dispose();
    sourceController.dispose();
  }
}

String _inviteLinkUrl({
  required Event event,
  required String inviteCode,
  required String inviteLinkId,
}) {
  return AppDeepLinks.event(
    clubId: event.clubId,
    eventId: event.id,
    inviteCode: inviteCode,
    inviteLinkId: inviteLinkId,
  ).toString();
}

String _inviteLinkStats(EventInviteLink link) {
  return [
    '${link.openCount} opens',
    '${link.requestCount} requests',
    '${link.confirmedCount} confirmed',
    '${link.checkedInCount} checked in',
    '${link.catcherCount} caught',
    '${link.chatStartedCount} chats',
  ].join(' | ');
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
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CatchIcons.adminPanelSettingsOutlined, color: t.ink2),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Host actions',
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH4,
                    Text(
                      event.isCancelled
                          ? 'This event has already been cancelled.'
                          : 'Use cancel for published events that should leave schedules but keep attendee, payment, and history records. Delete is only for unused events created by mistake.',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
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
              label: 'Edit event details',
              onPressed: isMutating
                  ? null
                  : () => context.pushNamed(
                      Routes.editHostedEventScreen.name,
                      pathParameters: {
                        'clubId': event.clubId,
                        'eventId': event.id,
                      },
                      extra: event,
                    ),
              variant: CatchButtonVariant.secondary,
              icon: Icon(CatchIcons.editOutlined),
              fullWidth: true,
            ),
          if (!event.isCancelled) gapH10,
          if (!event.isCancelled)
            CatchButton(
              label: 'Cancel published event',
              onPressed: isMutating
                  ? null
                  : () => _confirmCancelEvent(context, ref),
              variant: CatchButtonVariant.danger,
              icon: Icon(CatchIcons.cancelOutlined),
              isLoading: cancelMutation.isPending,
              fullWidth: true,
            ),
          if (!event.isCancelled) gapH10,
          if (hasKnownActivity)
            Text(
              'Delete unused event is unavailable once an event has bookings, waitlist, attendance, payments, or reviews. Cancel the published event instead.',
              style: CatchTextStyles.supporting(context, color: t.ink3),
            )
          else
            CatchButton(
              label: 'Delete unused event',
              onPressed: isMutating
                  ? null
                  : () => _confirmDeleteEvent(context, ref),
              variant: CatchButtonVariant.secondary,
              icon: Icon(CatchIcons.deleteOutlineRounded),
              isLoading: deleteMutation.isPending,
              fullWidth: true,
              foregroundColor: t.danger,
              borderColor: t.danger.withValues(
                alpha: CatchOpacity.hostDangerBorder,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelEvent(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Cancel published event?',
      message: hasKnownActivity
          ? 'Booked and waitlisted attendees will be notified. Attendance, payment, and review history will stay attached to this event.'
          : 'This removes the event from upcoming schedules while keeping a history record. If it was created by mistake and has no activity, you can delete it instead.',
      actions: const [
        CatchDialogAction(label: 'Keep event', value: false, isDefault: true),
        CatchDialogAction(
          label: 'Cancel published event',
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
      title: 'Delete unused event?',
      message:
          'Only events with no bookings, waitlist, attendance, payments, or reviews can be deleted. This permanently removes the event.',
      actions: const [
        CatchDialogAction(label: 'Keep event', value: false, isDefault: true),
        CatchDialogAction(
          label: 'Delete unused event',
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
    final price = event.isFree
        ? 'Free'
        : EventFormatters.priceInPaise(
            event.priceInPaise,
            currencyCode: event.currency,
          );

    return CatchSurface(
      padding: CatchInsets.listBody,
      borderColor: t.line,
      child: Column(
        children: [
          _HostEventSummaryRow(
            icon: CatchIcons.groupsRounded,
            label: 'Club',
            value: club.name,
          ),
          _HostEventSummaryRow(
            icon: CatchIcons.locationOnOutlined,
            label: 'Meet',
            value: event.locationName,
          ),
          _HostEventSummaryRow(
            icon: CatchIcons.routeRounded,
            label: 'Event',
            value: event.activitySummaryLabel,
          ),
          _HostEventSummaryRow(
            icon: CatchIcons.paymentsOutlined,
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
            Icon(icon, color: t.ink2, size: CatchIcon.md),
            gapW10,
            Text(
              label,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
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
