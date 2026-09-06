import 'dart:async';

import 'package:catch_dating_app/clubs/data/club_posts_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/data/event_callable_responses.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_club_post_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_broadcast_composer_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_follower_update_composer.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_broadcast_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_manual_send_queue.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostSendsWorkspaceSliver extends ConsumerStatefulWidget {
  const HostSendsWorkspaceSliver({
    super.key,
    required this.club,
    required this.initialSavedAudienceId,
    required this.onBusyChanged,
    required this.onOpenInbox,
    this.preferredEventId,
    this.initialSegment = HostInboxAudienceSegment.booked,
    this.broadcastEnabled = true,
    this.now,
  });

  final Club club;
  final String? initialSavedAudienceId;
  final ValueChanged<bool> onBusyChanged;
  final VoidCallback onOpenInbox;
  final String? preferredEventId;
  final HostInboxAudienceSegment initialSegment;
  final bool broadcastEnabled;
  final DateTime? now;

  @override
  ConsumerState<HostSendsWorkspaceSliver> createState() =>
      _HostSendsWorkspaceSliverState();
}

class _HostSendsWorkspaceSliverState
    extends ConsumerState<HostSendsWorkspaceSliver> {
  late bool _composing;
  bool _choosingIntent = false;
  HostCampaign? _campaignReport;
  HostAnnouncementSendSummary? _announcementReport;
  HostFollowerUpdateSendSummary? _followerUpdateReport;
  String? _paginationBaseKey;
  List<HostSendSummary> _additionalSends = const [];
  String? _nextCursor;
  bool _loadingMore = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _composing = widget.initialSavedAudienceId != null;
  }

  @override
  void didUpdateWidget(covariant HostSendsWorkspaceSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _composing = false;
      _choosingIntent = false;
      _campaignReport = null;
      _announcementReport = null;
      _followerUpdateReport = null;
      _paginationBaseKey = null;
      _additionalSends = const [];
      _nextCursor = null;
      _loadingMore = false;
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _choosingIntent
        ? _HostSendsIntentPicker(
            club: widget.club,
            onBack: _showHistory,
            onOpenInbox: widget.onOpenInbox,
            onStartCampaign: () => setState(() {
              _choosingIntent = false;
              _composing = true;
            }),
            onStartEventAnnouncement: _composeEventAnnouncement,
            onStartFollowerUpdate: _composeFollowerUpdate,
            preferredEventId: widget.preferredEventId,
            initialSegment: widget.initialSegment,
            broadcastEnabled: widget.broadcastEnabled,
            now: widget.now ?? DateTime.now(),
          )
        : _composing
        ? _HostSendsComposer(
            club: widget.club,
            initialSavedAudienceId: widget.initialSavedAudienceId,
            onBusyChanged: _setBusy,
            onBack: _showHistory,
          )
        : _campaignReport != null
        ? _HostSendsCampaignReport(
            campaign: _campaignReport!,
            busy: _busy,
            onBack: _showHistory,
            onApprove: _campaignReport!.canApprove
                ? () => _runCampaignAction(
                    (controller) => controller.approveCampaign(
                      organizerId: widget.club.id,
                      campaign: _campaignReport!,
                    ),
                  )
                : null,
            onSend: _campaignReport!.canDispatch
                ? () => _runCampaignAction(
                    (controller) => controller.dispatchCampaign(
                      organizerId: widget.club.id,
                      campaign: _campaignReport!,
                    ),
                  )
                : null,
            onRefresh: () => _openCampaign(_campaignReport!.campaignId),
            onNew: () => setState(() {
              _campaignReport = null;
              _choosingIntent = true;
            }),
          )
        : _announcementReport != null
        ? _HostSendsAnnouncementReport(
            announcement: _announcementReport!,
            onBack: _showHistory,
          )
        : _followerUpdateReport != null
        ? _HostSendsFollowerUpdateReport(
            update: _followerUpdateReport!,
            onBack: _showHistory,
          )
        : _HostSendsHistory(
            organizerId: widget.club.id,
            busy: _busy,
            loadingMore: _loadingMore,
            paginationBaseKey: _paginationBaseKey,
            additionalSends: _additionalSends,
            nextCursor: _nextCursor,
            onNew: () => setState(() => _choosingIntent = true),
            onOpen: _open,
            onLoadMore: _loadMore,
          );
    return SliverPadding(
      padding: CatchInsets.pageBody.copyWith(top: CatchSpacing.s3),
      sliver: SliverList.list(children: [content]),
    );
  }

  void _showHistory() {
    if (_busy) return;
    setState(() {
      _composing = false;
      _choosingIntent = false;
      _campaignReport = null;
      _announcementReport = null;
      _followerUpdateReport = null;
      ref.invalidate(hostSendsProvider(widget.club.id));
    });
  }

  Future<void> _open(HostSendSummary send) async {
    switch (send) {
      case HostCampaignSendSummary():
        await _openCampaign(send.campaignId);
      case HostAnnouncementSendSummary():
        setState(() => _announcementReport = send);
      case HostFollowerUpdateSendSummary():
        setState(() => _followerUpdateReport = send);
    }
  }

  Future<void> _composeFollowerUpdate(int remainingQuota) async {
    if (_busy) return;
    final sent = await showHostFollowerUpdateComposer(
      context: context,
      club: widget.club,
      remainingQuota: remainingQuota,
      requestIdFactory: HostClubPostController.generateRequestId,
      onSubmitPost: ({required requestId, required text}) async {
        _setBusy(true);
        try {
          await ref
              .read(hostClubPostControllerProvider)
              .createPost(
                clubId: widget.club.id,
                requestId: requestId,
                text: text,
              );
        } finally {
          _setBusy(false);
        }
      },
    );
    if (!mounted || !sent) return;
    ref.invalidate(watchClubPostRemainingWeeklyQuotaProvider(widget.club.id));
    ref.invalidate(hostSendsProvider(widget.club.id));
    setState(() => _choosingIntent = false);
  }

  Future<void> _composeEventAnnouncement(
    _HostEventAnnouncementTarget target,
  ) async {
    if (_busy) return;
    HostInboxBroadcastController.reset(ref);
    final initialSegment =
        widget.initialSegment == HostInboxAudienceSegment.booked &&
            target.bookedCount == 0 &&
            target.prospectiveCount > 0
        ? HostInboxAudienceSegment.prospective
        : widget.initialSegment;
    final result =
        await showCatchBottomSheet<SendEventBroadcastCallableResponse>(
          context: context,
          builder: (_) => HostBroadcastComposerSheet(
            event: target.event,
            bookedCount: target.bookedCount,
            prospectiveCount: target.prospectiveCount,
            initialSegment: initialSegment,
            sendingEnabled: widget.broadcastEnabled,
          ),
        );
    if (!mounted || result == null) return;
    ref.invalidate(hostSendsProvider(widget.club.id));
    setState(() => _choosingIntent = false);
    final suffix = result.isPartial
        ? context.l10n.hostsHostInboxScreenVisiblecopySomePushAttemptsFailed
        : '';
    showCatchSnackBar(
      context,
      context.l10n.hostsHostInboxScreenVisiblecopyBroadcastSentToRecipientcount(
        recipientCount: result.recipientCount,
        suffix: suffix,
      ),
    );
  }

  Future<void> _openCampaign(String campaignId) async {
    if (_busy) return;
    _setBusy(true);
    try {
      final campaign = await ref
          .read(hostAudienceControllerProvider)
          .getCampaignReport(
            organizerId: widget.club.id,
            campaignId: campaignId,
          );
      if (mounted) setState(() => _campaignReport = campaign);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _loadMore(
    HostSendsPage firstPage,
    String baseKey,
    String cursor,
  ) async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final nextPage = await ref
          .read(hostAudienceControllerProvider)
          .listSends(organizerId: widget.club.id, cursor: cursor);
      if (!mounted) return;
      final existingKeys = <String>{
        for (final send in firstPage.sends) '${send.runtimeType}:${send.id}',
        if (_paginationBaseKey == baseKey)
          for (final send in _additionalSends) '${send.runtimeType}:${send.id}',
      };
      setState(() {
        if (_paginationBaseKey != baseKey) {
          _paginationBaseKey = baseKey;
          _additionalSends = const [];
        }
        _additionalSends = [
          ..._additionalSends,
          ...nextPage.sends.where(
            (send) => existingKeys.add('${send.runtimeType}:${send.id}'),
          ),
        ];
        _nextCursor = nextPage.nextCursor;
      });
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _runCampaignAction(
    Future<HostCampaign> Function(HostAudienceController) action,
  ) async {
    if (_busy) return;
    _setBusy(true);
    try {
      final campaign = await action(ref.read(hostAudienceControllerProvider));
      if (mounted) setState(() => _campaignReport = campaign);
      ref.invalidate(hostSendsProvider(widget.club.id));
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    if (!mounted || _busy == value) return;
    setState(() => _busy = value);
    widget.onBusyChanged(value);
  }
}

class _HostSendsHistory extends ConsumerWidget {
  const _HostSendsHistory({
    required this.organizerId,
    required this.busy,
    required this.loadingMore,
    required this.paginationBaseKey,
    required this.additionalSends,
    required this.nextCursor,
    required this.onNew,
    required this.onOpen,
    required this.onLoadMore,
  });

  final String organizerId;
  final bool busy;
  final bool loadingMore;
  final String? paginationBaseKey;
  final List<HostSendSummary> additionalSends;
  final String? nextCursor;
  final VoidCallback onNew;
  final ValueChanged<HostSendSummary> onOpen;
  final void Function(HostSendsPage, String, String) onLoadMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sends = ref.watch(hostSendsProvider(organizerId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton(
              key: const ValueKey('host-sends-new-message'),
              label: context.l10n.hostSendsChooseIntent,
              onPressed: busy ? null : onNew,
            ),
            CatchButton(
              label: context.l10n.hostSendsSettings,
              variant: CatchButtonVariant.secondary,
              onPressed: busy
                  ? null
                  : () => context.pushNamed(
                      Routes.hostOrganizerMessagingScreen.name,
                      pathParameters: {'clubId': organizerId},
                    ),
            ),
          ],
        ),
        gapH16,
        HostManualSendQueue(organizerId: organizerId),
        gapH16,
        sends.when(
          loading: () =>
              const CatchFieldLanes.single(child: LinearProgressIndicator()),
          error: (error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.club,
            mode: CatchErrorStateMode.compact,
            onRetry: () => ref.invalidate(hostSendsProvider(organizerId)),
          ),
          data: (page) => _HostSendsHistoryPage(
            page: page,
            busy: busy,
            loadingMore: loadingMore,
            paginationBaseKey: paginationBaseKey,
            additionalSends: additionalSends,
            paginationNextCursor: nextCursor,
            onOpen: onOpen,
            onLoadMore: onLoadMore,
          ),
        ),
      ],
    );
  }
}

class _HostSendsIntentPicker extends ConsumerWidget {
  const _HostSendsIntentPicker({
    required this.club,
    required this.onBack,
    required this.onOpenInbox,
    required this.onStartCampaign,
    required this.onStartEventAnnouncement,
    required this.onStartFollowerUpdate,
    required this.preferredEventId,
    required this.initialSegment,
    required this.broadcastEnabled,
    required this.now,
  });

  final Club club;
  final VoidCallback onBack;
  final VoidCallback onOpenInbox;
  final VoidCallback onStartCampaign;
  final Future<void> Function(_HostEventAnnouncementTarget target)
  onStartEventAnnouncement;
  final Future<void> Function(int remainingQuota) onStartFollowerUpdate;
  final String? preferredEventId;
  final HostInboxAudienceSegment initialSegment;
  final bool broadcastEnabled;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(hostMessagingSetupProvider(club.id));
    final followerQuota = ref.watch(
      watchClubPostRemainingWeeklyQuotaProvider(club.id),
    );
    final campaignField = setup.when<Widget>(
      loading: () => CatchFieldLanes.single(
        child: CatchField.read(
          key: const ValueKey('host-send-intent-saved-audience'),
          title: context.l10n.hostSendsSavedAudienceIntent,
          body: context.l10n.hostSendsChannelChecking,
        ),
      ),
      error: (_, _) => CatchFieldLanes.single(
        child: CatchField.read(
          key: const ValueKey('host-send-intent-saved-audience'),
          title: context.l10n.hostSendsSavedAudienceIntent,
          body: context.l10n.hostSendsChannelUnavailable,
          valueText: context.l10n.hostSendsSetupRequired,
        ),
      ),
      data: (value) => CatchFieldLanes.single(
        child: value.canComposeCampaign
            ? CatchField.nav(
                key: const ValueKey('host-send-intent-saved-audience'),
                title: context.l10n.hostSendsSavedAudienceIntent,
                body: context.l10n.hostSendsSavedAudienceIntentBody,
                onTap: onStartCampaign,
              )
            : CatchField.read(
                key: const ValueKey('host-send-intent-saved-audience'),
                title: context.l10n.hostSendsSavedAudienceIntent,
                body: context.l10n.hostSendsSavedAudienceSetupBody,
                valueText: context.l10n.hostSendsSetupRequired,
              ),
      ),
    );
    final followerUpdateField = followerQuota.when<Widget>(
      loading: () => CatchFieldLanes.single(
        child: CatchField.read(
          key: const ValueKey('host-send-intent-follower-update'),
          title: context.l10n.hostSendsFollowerUpdateIntent,
          body: context.l10n.hostSendsChannelChecking,
        ),
      ),
      error: (_, _) => CatchFieldLanes.single(
        child: CatchField.read(
          key: const ValueKey('host-send-intent-follower-update'),
          title: context.l10n.hostSendsFollowerUpdateIntent,
          body: context.l10n.hostSendsChannelUnavailable,
        ),
      ),
      data: (remainingQuota) => CatchFieldLanes.single(
        child: remainingQuota > 0
            ? CatchField.nav(
                key: const ValueKey('host-send-intent-follower-update'),
                title: context.l10n.hostSendsFollowerUpdateIntent,
                body: context.l10n.hostSendsFollowerUpdateDescription,
                onTap: () => unawaited(onStartFollowerUpdate(remainingQuota)),
              )
            : CatchField.read(
                key: const ValueKey('host-send-intent-follower-update'),
                title: context.l10n.hostSendsFollowerUpdateIntent,
                body: context.l10n.hostSendsFollowerUpdateQuotaUsed,
                valueText: context.l10n.hostSendsWeeklyLimit,
              ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HostSendsBackButton(onPressed: onBack),
        gapH12,
        CatchSection.divided(
          title: context.l10n.hostSendsIntentTitle,
          children: [
            CatchFieldLanes.single(
              child: CatchField.nav(
                key: const ValueKey('host-send-intent-conversation'),
                title: context.l10n.hostSendsConversationIntent,
                body: context.l10n.hostSendsConversationIntentBody,
                onTap: onOpenInbox,
              ),
            ),
            campaignField,
            _HostEventAnnouncementIntent(
              organizerId: club.id,
              preferredEventId: preferredEventId,
              initialSegment: initialSegment,
              sendingEnabled: broadcastEnabled,
              now: now,
              onStart: onStartEventAnnouncement,
            ),
            followerUpdateField,
          ],
        ),
        gapH12,
        CatchButton(
          label: context.l10n.hostSendsSettings,
          variant: CatchButtonVariant.secondary,
          onPressed: () => context.pushNamed(
            Routes.hostOrganizerMessagingScreen.name,
            pathParameters: {'clubId': club.id},
          ),
        ),
      ],
    );
  }
}

class _HostEventAnnouncementTarget {
  const _HostEventAnnouncementTarget({
    required this.event,
    required this.bookedCount,
    required this.prospectiveCount,
  });

  final Event event;
  final int bookedCount;
  final int prospectiveCount;
}

class _HostEventAnnouncementIntent extends ConsumerWidget {
  const _HostEventAnnouncementIntent({
    required this.organizerId,
    required this.preferredEventId,
    required this.initialSegment,
    required this.sendingEnabled,
    required this.now,
    required this.onStart,
  });

  final String organizerId;
  final String? preferredEventId;
  final HostInboxAudienceSegment initialSegment;
  final bool sendingEnabled;
  final DateTime now;
  final Future<void> Function(_HostEventAnnouncementTarget target) onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(watchEventsForClubProvider(organizerId));
    return events.when(
      loading: () => CatchFieldLanes.single(
        child: CatchField.read(
          key: const ValueKey('host-send-intent-event-announcement'),
          title: context.l10n.hostSendsEventAnnouncementIntent,
          body: context.l10n.hostSendsEventAnnouncementChecking,
        ),
      ),
      error: (_, _) => CatchFieldLanes.single(
        child: CatchField.read(
          key: const ValueKey('host-send-intent-event-announcement'),
          title: context.l10n.hostSendsEventAnnouncementIntent,
          body: context.l10n.hostSendsEventAnnouncementUnavailable,
        ),
      ),
      data: (events) {
        final event = _eventForAnnouncement(
          events,
          preferredEventId: preferredEventId,
          now: now,
        );
        if (event == null) {
          return CatchFieldLanes.single(
            child: CatchField.read(
              key: const ValueKey('host-send-intent-event-announcement'),
              title: context.l10n.hostSendsEventAnnouncementIntent,
              body: context.l10n.hostSendsEventAnnouncementEmpty,
            ),
          );
        }
        final participations = ref.watch(
          watchEventParticipationsForEventProvider(event.id),
        );
        return participations.when(
          loading: () => CatchFieldLanes.single(
            child: CatchField.read(
              key: const ValueKey('host-send-intent-event-announcement'),
              title: context.l10n.hostSendsEventAnnouncementIntent,
              body: context.l10n.hostSendsEventAnnouncementCheckingAudience,
            ),
          ),
          error: (_, _) => CatchFieldLanes.single(
            child: CatchField.read(
              key: const ValueKey('host-send-intent-event-announcement'),
              title: context.l10n.hostSendsEventAnnouncementIntent,
              body: context.l10n.hostSendsEventAnnouncementUnavailable,
            ),
          ),
          data: (participations) {
            final roster = EventParticipationRoster.fromParticipations(
              participations
                  .where((participation) => participation.eventId == event.id)
                  .toList(growable: false),
            );
            final target = _HostEventAnnouncementTarget(
              event: event,
              bookedCount: roster.bookedCount,
              prospectiveCount: roster.waitlistedCount,
            );
            final selectedCount =
                initialSegment == HostInboxAudienceSegment.booked
                ? target.bookedCount
                : target.prospectiveCount;
            final hasAudience =
                target.bookedCount + target.prospectiveCount > 0;
            final canStart =
                sendingEnabled &&
                !event.isCancelled &&
                event.endTime.isAfter(now) &&
                hasAudience;
            final body = context.l10n.hostSendsEventAnnouncementIntentBody(
              eventTitle: event.title,
              bookedCount: target.bookedCount,
              prospectiveCount: target.prospectiveCount,
            );
            return CatchFieldLanes.single(
              child: canStart
                  ? CatchField.nav(
                      key: const ValueKey(
                        'host-send-intent-event-announcement',
                      ),
                      title: context.l10n.hostSendsEventAnnouncementIntent,
                      body: body,
                      valueText: context.l10n.hostSendsEventAudienceSelected(
                        count: selectedCount,
                      ),
                      onTap: () => unawaited(onStart(target)),
                    )
                  : CatchField.read(
                      key: const ValueKey(
                        'host-send-intent-event-announcement',
                      ),
                      title: context.l10n.hostSendsEventAnnouncementIntent,
                      body: body,
                      valueText: hasAudience
                          ? context
                                .l10n
                                .hostSendsEventAnnouncementUnavailableShort
                          : context.l10n.hostSendsEventAnnouncementNoAudience,
                    ),
            );
          },
        );
      },
    );
  }
}

Event? _eventForAnnouncement(
  List<Event> events, {
  required String? preferredEventId,
  required DateTime now,
}) {
  final eligible = orderHostInboxEvents(
    events,
    now: now,
  ).where((event) => !event.isCancelled && event.endTime.isAfter(now)).toList();
  if (preferredEventId != null) {
    for (final event in eligible) {
      if (event.id == preferredEventId) return event;
    }
  }
  return eligible.firstOrNull;
}

class _HostSendsHistoryPage extends StatelessWidget {
  const _HostSendsHistoryPage({
    required this.page,
    required this.busy,
    required this.loadingMore,
    required this.paginationBaseKey,
    required this.additionalSends,
    required this.paginationNextCursor,
    required this.onOpen,
    required this.onLoadMore,
  });

  final HostSendsPage page;
  final bool busy;
  final bool loadingMore;
  final String? paginationBaseKey;
  final List<HostSendSummary> additionalSends;
  final String? paginationNextCursor;
  final ValueChanged<HostSendSummary> onOpen;
  final void Function(HostSendsPage, String, String) onLoadMore;

  @override
  Widget build(BuildContext context) {
    final baseKey = _hostSendsBaseKey(page);
    final hasCurrentPagination = paginationBaseKey == baseKey;
    final sends = [...page.sends, if (hasCurrentPagination) ...additionalSends];
    final nextCursor = hasCurrentPagination
        ? paginationNextCursor
        : page.nextCursor;
    if (sends.isEmpty) {
      return CatchEmptyState(
        title: context.l10n.hostSendsEmpty,
        message: context.l10n.hostSendsEmptyHelp,
      );
    }
    return CatchSection.divided(
      title: context.l10n.hostMessagingWorkspaceSends,
      child: Column(
        children: [
          CatchFieldLanes.divided(
            children: [
              for (final send in sends)
                CatchRowPressSurface(
                  onTap: busy ? null : () => onOpen(send),
                  child: _HostSendRow(send: send),
                ),
            ],
          ),
          if (nextCursor != null)
            Padding(
              padding: CatchInsets.fieldSectionChildTop,
              child: CatchButton(
                label: context.l10n.hostSendsLoadMore,
                variant: CatchButtonVariant.secondary,
                isLoading: loadingMore,
                onPressed: loadingMore
                    ? null
                    : () => onLoadMore(page, baseKey, nextCursor),
              ),
            ),
        ],
      ),
    );
  }
}

class _HostSendRow extends StatelessWidget {
  const _HostSendRow({required this.send});

  final HostSendSummary send;

  @override
  Widget build(BuildContext context) => CatchFieldLanes.single(
    child: switch (send) {
      HostCampaignSendSummary campaign => CatchField.read(
        key: ValueKey('host-send-campaign-${campaign.campaignId}'),
        title: campaign.name,
        body: [
          context.l10n.hostSendsWhatsappBusinessChannel,
          campaign.templateName ?? campaign.templateId,
          AppTimeFormatters.shortDate(campaign.activityAt),
        ].join(' · '),
        valueText: campaign.status,
      ),
      HostAnnouncementSendSummary announcement => CatchField.read(
        key: ValueKey('host-send-announcement-${announcement.broadcastId}'),
        title: announcement.eventName,
        body: [
          context.l10n.hostSendsCatchAnnouncementChannel,
          context.l10n.hostSendsRecipients(count: announcement.recipientCount),
          AppTimeFormatters.shortDate(announcement.sentAt),
        ].join(' · '),
        valueText: announcement.partialFailure
            ? context.l10n.hostSendsPartial
            : announcement.audience,
      ),
      HostFollowerUpdateSendSummary update => CatchField.read(
        key: ValueKey('host-send-follower-update-${update.postId}'),
        title: context.l10n.hostSendsFollowerUpdateChannel,
        body: [
          context.l10n.hostSendsFollowersAudience,
          if (update.hasTrackedDelivery)
            context.l10n.hostSendsRecipients(
              count: update.activityAvailableCount,
            ),
          AppTimeFormatters.shortDate(update.createdAt),
        ].join(' · '),
        valueText: context.l10n.hostSendsFollowerDeliveryStatus(
          status: update.deliveryStatus,
        ),
      ),
    },
  );
}

class _HostSendsComposer extends StatelessWidget {
  const _HostSendsComposer({
    required this.club,
    required this.initialSavedAudienceId,
    required this.onBusyChanged,
    required this.onBack,
  });

  final Club club;
  final String? initialSavedAudienceId;
  final ValueChanged<bool> onBusyChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _HostSendsBackButton(onPressed: onBack),
      gapH12,
      HostCampaignComposer(
        club: club,
        initialSavedAudienceId: initialSavedAudienceId,
        onBusyChanged: onBusyChanged,
      ),
    ],
  );
}

class _HostSendsCampaignReport extends StatelessWidget {
  const _HostSendsCampaignReport({
    required this.campaign,
    required this.busy,
    required this.onBack,
    required this.onApprove,
    required this.onSend,
    required this.onRefresh,
    required this.onNew,
  });

  final HostCampaign campaign;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback? onApprove;
  final VoidCallback? onSend;
  final VoidCallback onRefresh;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _HostSendsBackButton(onPressed: busy ? null : onBack),
      gapH12,
      CatchSection.divided(
        title: context.l10n.hostSendsCampaignType,
        child: HostCampaignReport(
          campaign: campaign,
          busy: busy,
          onApprove: onApprove,
          onSend: onSend,
          onCancel: null,
          onRefresh: onRefresh,
          onNew: onNew,
        ),
      ),
    ],
  );
}

class _HostSendsAnnouncementReport extends StatelessWidget {
  const _HostSendsAnnouncementReport({
    required this.announcement,
    required this.onBack,
  });

  final HostAnnouncementSendSummary announcement;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _HostSendsBackButton(onPressed: onBack),
      gapH12,
      CatchSection.divided(
        title: context.l10n.hostSendsAnnouncementType,
        child: CatchNotice(
          notice: CatchNoticeData(
            id: 'host.sends.announcement.${announcement.broadcastId}',
            title: announcement.eventName,
            message: [
              context.l10n.hostSendsRecipients(
                count: announcement.recipientCount,
              ),
              AppTimeFormatters.dateTime(announcement.sentAt),
              if (announcement.partialFailure) context.l10n.hostSendsPartial,
            ].join(' · '),
            tone: announcement.partialFailure
                ? CatchNoticeTone.warning
                : CatchNoticeTone.status,
          ),
        ),
      ),
    ],
  );
}

class _HostSendsFollowerUpdateReport extends StatelessWidget {
  const _HostSendsFollowerUpdateReport({
    required this.update,
    required this.onBack,
  });

  final HostFollowerUpdateSendSummary update;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _HostSendsBackButton(onPressed: onBack),
      gapH12,
      CatchSection.divided(
        title: context.l10n.hostSendsFollowerUpdateChannel,
        child: CatchNotice(
          notice: CatchNoticeData(
            id: 'host.sends.follower-update.${update.postId}',
            title: context.l10n.hostSendsFollowersAudience,
            message: [
              AppTimeFormatters.dateTime(update.createdAt),
              if (update.eventId != null)
                context.l10n.hostSendsLinkedEventUpdate,
              context.l10n.hostSendsFollowerDeliveryStatus(
                status: update.deliveryStatus,
              ),
              if (update.hasTrackedDelivery)
                context.l10n.hostSendsRecipients(
                  count: update.activityAvailableCount,
                ),
            ].join(' · '),
            tone: update.deliveryCompleted
                ? CatchNoticeTone.status
                : CatchNoticeTone.warning,
          ),
        ),
      ),
    ],
  );
}

class _HostSendsBackButton extends StatelessWidget {
  const _HostSendsBackButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: CatchButton(
      label: context.l10n.hostMessagingWorkspaceSends,
      variant: CatchButtonVariant.ghost,
      onPressed: onPressed,
    ),
  );
}

String _hostSendsBaseKey(HostSendsPage page) => [
  page.nextCursor ?? '',
  for (final send in page.sends) '${send.runtimeType}:${send.id}',
].join('|');
