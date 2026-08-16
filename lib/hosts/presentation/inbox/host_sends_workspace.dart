import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostSendsWorkspaceSliver extends ConsumerStatefulWidget {
  const HostSendsWorkspaceSliver({
    super.key,
    required this.club,
    required this.initialSegments,
    required this.initialSearch,
    required this.onBusyChanged,
  });

  final Club club;
  final Set<HostAudienceSegment> initialSegments;
  final String? initialSearch;
  final ValueChanged<bool> onBusyChanged;

  @override
  ConsumerState<HostSendsWorkspaceSliver> createState() =>
      _HostSendsWorkspaceSliverState();
}

class _HostSendsWorkspaceSliverState
    extends ConsumerState<HostSendsWorkspaceSliver> {
  late bool _composing;
  HostCampaign? _campaignReport;
  HostAnnouncementSendSummary? _announcementReport;
  String? _paginationBaseKey;
  List<HostSendSummary> _additionalSends = const [];
  String? _nextCursor;
  bool _loadingMore = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _composing =
        widget.initialSegments.isNotEmpty ||
        (widget.initialSearch?.isNotEmpty ?? false);
  }

  @override
  void didUpdateWidget(covariant HostSendsWorkspaceSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _composing = false;
      _campaignReport = null;
      _announcementReport = null;
      _paginationBaseKey = null;
      _additionalSends = const [];
      _nextCursor = null;
      _loadingMore = false;
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _composing
        ? _composer(context)
        : _campaignReport != null
        ? _campaignReportView(context, _campaignReport!)
        : _announcementReport != null
        ? _announcementReportView(context, _announcementReport!)
        : _history(context);
    return SliverPadding(
      padding: CatchInsets.pageBody.copyWith(top: CatchSpacing.s3),
      sliver: SliverList.list(children: [content]),
    );
  }

  Widget _history(BuildContext context) {
    final sends = ref.watch(hostSendsProvider(widget.club.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton(
              key: const ValueKey('host-sends-new-message'),
              label: context.l10n.hostSendsNewMessage,
              onPressed: _busy ? null : () => setState(() => _composing = true),
            ),
            CatchButton(
              label: context.l10n.hostSendsSettings,
              variant: CatchButtonVariant.secondary,
              onPressed: _busy
                  ? null
                  : () => context.pushNamed(
                      Routes.hostOrganizerMessagingScreen.name,
                      pathParameters: {'clubId': widget.club.id},
                    ),
            ),
          ],
        ),
        gapH16,
        sends.when(
          loading: () =>
              const CatchFieldLanes.single(child: LinearProgressIndicator()),
          error: (error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.club,
            mode: CatchErrorStateMode.compact,
            onRetry: () => ref.invalidate(hostSendsProvider(widget.club.id)),
          ),
          data: (page) => _historyPage(context, page),
        ),
      ],
    );
  }

  Widget _historyPage(BuildContext context, HostSendsPage page) {
    final baseKey = _baseKey(page);
    final hasCurrentPagination = _paginationBaseKey == baseKey;
    final sends = [
      ...page.sends,
      if (hasCurrentPagination) ..._additionalSends,
    ];
    final nextCursor = hasCurrentPagination ? _nextCursor : page.nextCursor;
    if (sends.isEmpty) {
      return CatchEmptyState(
        title: context.l10n.hostSendsEmpty,
        message: context.l10n.hostSendsEmptyHelp,
      );
    }
    return CatchSection.divided(
      title: context.l10n.hostMessagingWorkspaceSends,
      child: CatchFieldLanes.single(
        child: Column(
          children: [
            for (final (index, send) in sends.indexed)
              CatchRowPressSurface(
                onTap: _busy ? null : () => _open(send),
                child: _sendRow(
                  context,
                  send,
                  divider: index < sends.length - 1 || nextCursor != null,
                ),
              ),
            if (nextCursor != null)
              Padding(
                padding: const EdgeInsets.only(top: CatchSpacing.s3),
                child: CatchButton(
                  label: context.l10n.hostSendsLoadMore,
                  variant: CatchButtonVariant.secondary,
                  isLoading: _loadingMore,
                  onPressed: _loadingMore
                      ? null
                      : () => _loadMore(page, baseKey, nextCursor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sendRow(
    BuildContext context,
    HostSendSummary send, {
    required bool divider,
  }) => switch (send) {
    HostCampaignSendSummary campaign => CatchField.read(
      key: ValueKey('host-send-campaign-${campaign.campaignId}'),
      title: campaign.name,
      body: [
        context.l10n.hostSendsCampaignType,
        campaign.templateName ?? campaign.templateId,
        AppTimeFormatters.shortDate(campaign.activityAt),
      ].join(' · '),
      valueText: campaign.status,
      divider: divider,
    ),
    HostAnnouncementSendSummary announcement => CatchField.read(
      key: ValueKey('host-send-announcement-${announcement.broadcastId}'),
      title: announcement.eventName,
      body: [
        context.l10n.hostSendsAnnouncementType,
        context.l10n.hostSendsRecipients(count: announcement.recipientCount),
        AppTimeFormatters.shortDate(announcement.sentAt),
      ].join(' · '),
      valueText: announcement.partialFailure
          ? context.l10n.hostSendsPartial
          : announcement.audience,
      divider: divider,
    ),
  };

  Widget _composer(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _backButton(context),
      gapH12,
      HostCampaignComposer(
        club: widget.club,
        initialSegments: widget.initialSegments,
        initialSearch: widget.initialSearch,
        onBusyChanged: _setBusy,
      ),
    ],
  );

  Widget _campaignReportView(BuildContext context, HostCampaign campaign) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _backButton(context),
          gapH12,
          CatchSection.divided(
            title: context.l10n.hostSendsCampaignType,
            child: HostCampaignReport(
              campaign: campaign,
              busy: _busy,
              onApprove: campaign.canApprove
                  ? () => _runCampaignAction(
                      (controller) => controller.approveCampaign(
                        organizerId: widget.club.id,
                        campaign: campaign,
                      ),
                    )
                  : null,
              onSend: campaign.canDispatch
                  ? () => _runCampaignAction(
                      (controller) => controller.dispatchCampaign(
                        organizerId: widget.club.id,
                        campaign: campaign,
                      ),
                    )
                  : null,
              onCancel: null,
              onRefresh: () => _openCampaign(campaign.campaignId),
              onNew: () => setState(() {
                _campaignReport = null;
                _composing = true;
              }),
            ),
          ),
        ],
      );

  Widget _announcementReportView(
    BuildContext context,
    HostAnnouncementSendSummary announcement,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _backButton(context),
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

  Widget _backButton(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: CatchButton(
      label: context.l10n.hostMessagingWorkspaceSends,
      variant: CatchButtonVariant.ghost,
      onPressed: _busy
          ? null
          : () => setState(() {
              _composing = false;
              _campaignReport = null;
              _announcementReport = null;
              ref.invalidate(hostSendsProvider(widget.club.id));
            }),
    ),
  );

  Future<void> _open(HostSendSummary send) async {
    switch (send) {
      case HostCampaignSendSummary():
        await _openCampaign(send.campaignId);
      case HostAnnouncementSendSummary():
        setState(() => _announcementReport = send);
    }
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
          .read(hostCrmRepositoryProvider)
          .listCampaigns(widget.club.id, cursor: cursor);
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

  String _baseKey(HostSendsPage page) => [
    page.nextCursor ?? '',
    for (final send in page.sends) '${send.runtimeType}:${send.id}',
  ].join('|');
}
