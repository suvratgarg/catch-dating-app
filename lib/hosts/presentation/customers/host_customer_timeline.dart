import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class HostCustomerReachSection extends StatelessWidget {
  const HostCustomerReachSection({
    super.key,
    required this.customer,
    required this.communicationPlan,
    required this.communicationPlanLoading,
    required this.communicationPlanFailed,
    required this.messageLoading,
    required this.onMessage,
    required this.onRetryCommunicationPlan,
    required this.onMessagingEnabledChanged,
    this.messageActionInHeader = false,
    this.onReviewDuplicates,
  });

  final HostAudienceContactDetail customer;
  final HostCommunicationPlan? communicationPlan;
  final bool communicationPlanLoading;
  final bool communicationPlanFailed;
  final bool messageLoading;
  final VoidCallback onMessage;
  final VoidCallback onRetryCommunicationPlan;
  final ValueChanged<bool>? onMessagingEnabledChanged;
  final bool messageActionInHeader;
  final VoidCallback? onReviewDuplicates;

  @override
  Widget build(BuildContext context) {
    final recipient = communicationPlan?.singleRecipient;
    final recommendedRoute = recipient?.recommendedRouteId;
    final l10n = context.l10n;
    final t = CatchTokens.of(context);
    return Column(
      key: const ValueKey('host-customer-reach-and-provenance'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSection.plain(
          title: l10n.hostCustomersMessaging,
          showInternalDividers: false,
          children: [
            if (communicationPlanLoading)
              CatchRecordRow(
                key: const ValueKey('host-customer-message-plan-loading'),
                title: l10n.hostCustomersMessageOptionsLoading,
                icon: CatchIcons.tabChats,
              )
            else if (communicationPlanFailed || recipient == null) ...[
              CatchRecordRow(
                key: const ValueKey('host-customer-message-plan-error'),
                title: l10n.hostCustomersMessageOptionsUnavailable,
                description: l10n.hostCustomersMessageOptionsRetry,
                icon: CatchIcons.tabChats,
                color: t.warning,
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CatchButton(
                  key: const ValueKey('host-customer-message-plan-retry'),
                  label: l10n.hostCustomersCheckMessaging,
                  onPressed: onRetryCommunicationPlan,
                  variant: CatchButtonVariant.ghost,
                ),
              ),
            ] else if (recommendedRoute != null) ...[
              CatchRecordRow(
                key: const ValueKey('host-customer-message-availability'),
                title: _recommendedMessageBody(context, recommendedRoute),
                icon: CatchIcons.tabChats,
              ),
              if (!messageActionInHeader)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CatchButton(
                    key: const ValueKey('host-customer-message'),
                    label: l10n.hostCustomersMessagePerson(
                      name: customer.displayName,
                    ),
                    onPressed: messageLoading ? null : onMessage,
                    variant: CatchButtonVariant.ghost,
                  ),
                ),
            ] else
              CatchRecordRow(
                key: const ValueKey('host-customer-message'),
                title: l10n.hostCustomersMessageOptionsUnavailable,
                description: _unavailableMessageBody(context, recipient),
                icon: CatchIcons.tabChats,
              ),
            CatchRecordRow(
              key: const ValueKey('host-customer-whatsapp-permission'),
              title: l10n.hostCustomersWhatsappPermission,
              description: _permissionSummary(
                context,
                customer.whatsappPermission,
              ),
              icon: CatchIcons.verifiedUserOutlined,
              color: switch (customer.whatsappPermission.evidenceStatus) {
                HostCustomerPermissionEvidenceStatus.unavailable => t.ink2,
                HostCustomerPermissionEvidenceStatus.incomplete => t.warning,
                _ => switch (customer.whatsappPermission.status) {
                  HostAudiencePermissionStatus.optedIn => t.success,
                  HostAudiencePermissionStatus.optedOut => t.danger,
                  HostAudiencePermissionStatus.unknown => t.ink2,
                },
              },
            ),
          ],
        ),
        gapH16,
        CatchSection.containedFieldRows(
          children: [
            CatchField.toggle(
              key: const ValueKey('host-customer-organizer-messages'),
              title: l10n.hostCustomersPauseWhatsappHandoffs,
              titleMaxLines: 5,
              contract: CatchContractConstraints
                  .mutateOrganizerContactCallablePayloadWhatsappAdminSuppressed,
              helperText: l10n.hostCustomersPauseWhatsappHandoffsBody,
              value: customer.whatsappAdminSuppressed,
              onChanged: onMessagingEnabledChanged == null
                  ? null
                  : (paused) => onMessagingEnabledChanged!(!paused),
            ),
          ],
        ),
        gapH24,
        CatchSection.plain(
          key: const ValueKey('host-customer-provenance'),
          title: l10n.hostCustomersCustomerProvenance,
          showInternalDividers: false,
          children: [
            if (customer.origins.isEmpty)
              CatchRecordRow(
                title: l10n.hostCustomersSourceUnavailable,
                description: l10n.hostCustomersCustomerProvenanceUnavailable,
                icon: CatchIcons.accountTreeOutlined,
              )
            else
              for (final origin in customer.origins)
                CatchRecordRow(
                  key: ValueKey('host-customer-origin-${origin.originId}'),
                  title: _originLabel(context, origin),
                  metadata: l10n.hostCustomersCustomerProvenanceItem(
                    source: _originKindLabel(context, origin.sourceKind),
                    date: AppTimeFormatters.shortDate(origin.observedAt),
                  ),
                  icon:
                      origin.sourceKind == HostCustomerOriginSourceKind.hostForm
                      ? CatchIcons.descriptionOutlined
                      : CatchIcons.accountTreeOutlined,
                ),
            if (customer.originsTruncated)
              Text(
                l10n.hostCustomersSourcesTruncated,
                style: CatchTextStyles.recordContext(context),
              ),
            if (onReviewDuplicates != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CatchButton(
                  key: const ValueKey('host-customer-review-duplicates'),
                  label: l10n.hostCustomersReviewDuplicates,
                  onPressed: onReviewDuplicates,
                  variant: CatchButtonVariant.ghost,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String _recommendedMessageBody(
  BuildContext context,
  HostCommunicationRouteId route,
) => switch (route) {
  HostCommunicationRouteId.catchChat =>
    context.l10n.hostCustomersMessagePersonCatch,
  HostCommunicationRouteId.personalWhatsappHandoff =>
    context.l10n.hostCustomersMessagePersonHandoff,
  _ => context.l10n.hostCustomersMessageOptionsUnavailable,
};

String _unavailableMessageBody(
  BuildContext context,
  HostCommunicationRecipientPlan recipient,
) {
  final blockers = recipient.routes
      .map((route) => route.blocker)
      .whereType<HostCommunicationRouteBlocker>()
      .toList(growable: false);
  final blocker =
      blockers.contains(HostCommunicationRouteBlocker.contactOptedOut)
      ? HostCommunicationRouteBlocker.contactOptedOut
      : blockers.contains(HostCommunicationRouteBlocker.organizerSuppressed)
      ? HostCommunicationRouteBlocker.organizerSuppressed
      : blockers.firstOrNull;
  return _communicationRouteBlockerLabel(context, blocker);
}

String _communicationRouteBlockerLabel(
  BuildContext context,
  HostCommunicationRouteBlocker? blocker,
) => switch (blocker) {
  HostCommunicationRouteBlocker.catchAccountRequired =>
    context.l10n.hostCustomersConversationUnlinked,
  HostCommunicationRouteBlocker.identityAmbiguous =>
    context.l10n.hostCustomersConversationAmbiguous,
  HostCommunicationRouteBlocker.missingPhone =>
    context.l10n.hostCustomersWhatsappMissingPhone,
  HostCommunicationRouteBlocker.organizerSuppressed =>
    context.l10n.hostCustomersWhatsappOrganizerSuppressed,
  HostCommunicationRouteBlocker.contactOptedOut =>
    context.l10n.hostCustomersWhatsappContactOptedOut,
  HostCommunicationRouteBlocker.permissionRequired =>
    context.l10n.hostCustomersMessagePermissionRequired,
  HostCommunicationRouteBlocker.senderUnavailable =>
    context.l10n.hostCustomersMessageSenderUnavailable,
  HostCommunicationRouteBlocker.contactUnavailable ||
  HostCommunicationRouteBlocker.endpointChanged ||
  HostCommunicationRouteBlocker.intentUnsupported ||
  null => context.l10n.hostCustomersMessageOptionsUnavailable,
};

String _permissionSummary(
  BuildContext context,
  HostCustomerWhatsappPermission permission,
) {
  if (permission.evidenceStatus ==
      HostCustomerPermissionEvidenceStatus.unavailable) {
    return context.l10n.hostCustomersWhatsappPermissionUnavailable;
  }
  if (permission.evidenceStatus ==
      HostCustomerPermissionEvidenceStatus.incomplete) {
    return '${_permissionStatusLabel(context, permission.status)}\n${context.l10n.hostCustomersWhatsappPermissionIncomplete}';
  }
  final date = permission.decisionAt == null
      ? null
      : AppTimeFormatters.shortDate(permission.decisionAt!);
  return switch (permission.status) {
    HostAudiencePermissionStatus.unknown =>
      context.l10n.hostCustomersWhatsappPermissionUnknown,
    HostAudiencePermissionStatus.optedIn
        when permission.sourceFormTitle != null && date != null =>
      context.l10n.hostCustomersWhatsappPermissionGrantedByForm(
        formTitle: permission.sourceFormTitle!,
        date: date,
      ),
    HostAudiencePermissionStatus.optedIn when date != null =>
      context.l10n.hostCustomersWhatsappPermissionGranted(date: date),
    HostAudiencePermissionStatus.optedOut when date != null =>
      context.l10n.hostCustomersWhatsappPermissionRevoked(date: date),
    HostAudiencePermissionStatus.optedIn =>
      context.l10n.hostCustomersWhatsappPermissionGrantedUndated,
    HostAudiencePermissionStatus.optedOut =>
      context.l10n.hostCustomersWhatsappPermissionRevokedUndated,
  };
}

String _permissionStatusLabel(
  BuildContext context,
  HostAudiencePermissionStatus status,
) => switch (status) {
  HostAudiencePermissionStatus.optedIn =>
    context.l10n.hostCustomersWhatsappPermissionGrantedUndated,
  HostAudiencePermissionStatus.optedOut =>
    context.l10n.hostCustomersWhatsappPermissionRevokedUndated,
  HostAudiencePermissionStatus.unknown =>
    context.l10n.hostCustomersWhatsappPermissionUnknown,
};

String _originKindLabel(
  BuildContext context,
  HostCustomerOriginSourceKind kind,
) => switch (kind) {
  HostCustomerOriginSourceKind.catchBooking =>
    context.l10n.hostCustomersOriginCatchBooking,
  HostCustomerOriginSourceKind.hostImport =>
    context.l10n.hostCustomersOriginHostImport,
  HostCustomerOriginSourceKind.hostManual =>
    context.l10n.hostCustomersOriginHostManual,
  HostCustomerOriginSourceKind.webOtp => context.l10n.hostCustomersOriginWebOtp,
  HostCustomerOriginSourceKind.providerSync =>
    context.l10n.hostCustomersOriginProviderSync,
  HostCustomerOriginSourceKind.hostForm =>
    context.l10n.hostCustomersTimelineFormFallback,
};

String _originLabel(BuildContext context, HostCustomerOrigin origin) =>
    switch (origin.sourceKind) {
      HostCustomerOriginSourceKind.catchBooking =>
        origin.eventTitle ?? context.l10n.hostCustomersOriginCatchBooking,
      HostCustomerOriginSourceKind.hostImport =>
        context.l10n.hostCustomersOriginHostImport,
      HostCustomerOriginSourceKind.hostManual =>
        context.l10n.hostCustomersOriginHostManual,
      HostCustomerOriginSourceKind.webOtp =>
        origin.eventTitle ?? context.l10n.hostCustomersOriginWebOtp,
      HostCustomerOriginSourceKind.providerSync =>
        origin.eventTitle ?? context.l10n.hostCustomersOriginProviderSync,
      HostCustomerOriginSourceKind.hostForm =>
        context.l10n.hostCustomersOriginHostForm(
          formTitle:
              origin.formTitle ??
              context.l10n.hostCustomersTimelineFormFallback,
        ),
    };

enum HostCustomerHistoryKind { all, forms, events, messages }

class HostCustomerHistoryFilters extends StatefulWidget {
  const HostCustomerHistoryFilters({super.key, required this.builder});

  final Widget Function(HostCustomerHistoryKind filter) builder;

  @override
  State<HostCustomerHistoryFilters> createState() =>
      _HostCustomerHistoryFiltersState();
}

class _HostCustomerHistoryFiltersState
    extends State<HostCustomerHistoryFilters> {
  HostCustomerHistoryKind selected = HostCustomerHistoryKind.all;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: CatchAdaptiveSelectionControl<HostCustomerHistoryKind>(
          title: context.l10n.hostCustomersTimeline,
          tooltip: context.l10n.hostCustomersTimeline,
          buttonKey: const ValueKey('host-customer-history-filter'),
          value: selected,
          triggerLabel: (item) => item.label,
          onSelected: (value) => setState(() => selected = value),
          items: [
            CatchSelectionMenuItem(
              value: HostCustomerHistoryKind.all,
              label: context.l10n.hostCustomersAllActivity,
            ),
            CatchSelectionMenuItem(
              value: HostCustomerHistoryKind.forms,
              label: context.l10n.hostFormsViewForms,
            ),
            CatchSelectionMenuItem(
              value: HostCustomerHistoryKind.events,
              label: context.l10n.hostNavigationEvents,
            ),
            CatchSelectionMenuItem(
              value: HostCustomerHistoryKind.messages,
              label: context.l10n.hostCustomersMessageHistory,
            ),
          ],
        ),
      ),
      gapH16,
      widget.builder(selected),
    ],
  );
}

class HostCustomerTimelineSection extends StatelessWidget {
  const HostCustomerTimelineSection({
    super.key,
    required this.customer,
    required this.onOpenFormResponse,
    required this.onOpenEvent,
    required this.onOpenCatchThread,
    required this.onOpenWhatsappThread,
    this.filter = HostCustomerHistoryKind.all,
  });

  final HostAudienceContactDetail customer;
  final ValueChanged<String> onOpenFormResponse;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenCatchThread;
  final ValueChanged<String> onOpenWhatsappThread;
  final HostCustomerHistoryKind filter;

  @override
  Widget build(BuildContext context) {
    final entries = customer.timeline
        .where(
          (entry) => switch (filter) {
            HostCustomerHistoryKind.all => true,
            HostCustomerHistoryKind.forms =>
              entry is HostCustomerFormTimelineEntry,
            HostCustomerHistoryKind.events =>
              entry is HostCustomerEventTimelineEntry,
            HostCustomerHistoryKind.messages =>
              entry is HostCustomerSendTimelineEntry ||
                  entry is HostCustomerReplyTimelineEntry,
          },
        )
        .toList(growable: false);
    final hasGap =
        customer.timelineTruncated ||
        customer.timelineCoverage.forms !=
            HostCustomerTimelineCoverageValue.exact ||
        customer.timelineCoverage.events !=
            HostCustomerTimelineCoverageValue.exact ||
        customer.timelineCoverage.sends !=
            HostCustomerTimelineCoverageValue.exact ||
        customer.timelineCoverage.replies ==
            HostCustomerTimelineCoverageValue.unavailable;
    return CatchSection.plain(
      key: const ValueKey('host-customer-timeline'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (entries.isEmpty)
            Text(
              context.l10n.hostCustomersTimelineEmpty,
              style: CatchTextStyles.supporting(context),
            )
          else
            _HostCustomerTimelineRows(
              entries: entries,
              onOpenFormResponse: onOpenFormResponse,
              onOpenEvent: onOpenEvent,
              onOpenCatchThread: onOpenCatchThread,
              onOpenWhatsappThread: onOpenWhatsappThread,
            ),
          if (hasGap) ...[
            gapH12,
            CatchNotice(
              notice: CatchNoticeData(
                id: 'host.customer.timeline.partial',
                title: context.l10n.hostCustomersTimelinePartialTitle,
                message: context.l10n.hostCustomersTimelinePartialBody,
                tone: CatchNoticeTone.warning,
              ),
            ),
          ],
          gapH12,
          Text(
            context.l10n.hostCustomersTimelineReplyBoundary,
            style: CatchTextStyles.recordContext(context),
          ),
        ],
      ),
    );
  }
}

class _HostCustomerTimelineRows extends StatelessWidget {
  const _HostCustomerTimelineRows({
    required this.entries,
    required this.onOpenFormResponse,
    required this.onOpenEvent,
    required this.onOpenCatchThread,
    required this.onOpenWhatsappThread,
  });

  final List<HostCustomerTimelineEntry> entries;
  final ValueChanged<String> onOpenFormResponse;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenCatchThread;
  final ValueChanged<String> onOpenWhatsappThread;

  @override
  Widget build(BuildContext context) {
    final ordered = [...entries]
      ..sort((a, b) {
        final time = b.occurredAt.compareTo(a.occurredAt);
        return time != 0 ? time : a.timelineId.compareTo(b.timelineId);
      });
    final days = <DateTime, List<HostCustomerTimelineEntry>>{};
    for (final entry in ordered) {
      final local = entry.occurredAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      days.putIfAbsent(day, () => []).add(entry);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final day in days.entries) ...[
          if (day.key != days.keys.first) gapH24,
          Semantics(
            header: true,
            child: Text(
              MaterialLocalizations.of(context).formatFullDate(day.key),
              style: CatchTextStyles.supportingStrong(context),
            ),
          ),
          gapH8,
          for (final entry in day.value)
            HostCustomerTimelineRecord(
              entry: entry,
              onOpenFormResponse: onOpenFormResponse,
              onOpenEvent: onOpenEvent,
              onOpenCatchThread: onOpenCatchThread,
              onOpenWhatsappThread: onOpenWhatsappThread,
            ),
        ],
      ],
    );
  }
}

class HostCustomerTimelineRecord extends StatelessWidget {
  const HostCustomerTimelineRecord({
    super.key,
    required this.entry,
    required this.onOpenFormResponse,
    required this.onOpenEvent,
    required this.onOpenCatchThread,
    required this.onOpenWhatsappThread,
  });
  final HostCustomerTimelineEntry entry;
  final ValueChanged<String> onOpenFormResponse;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenCatchThread;
  final ValueChanged<String> onOpenWhatsappThread;
  @override
  Widget build(BuildContext context) {
    final entry = this.entry;
    final t = CatchTokens.of(context);
    final key = ValueKey('host-customer-timeline-${entry.timelineId}');
    return switch (entry) {
      HostCustomerFormTimelineEntry() => CatchRecordRow(
        key: key,
        title:
            entry.formTitle ?? context.l10n.hostCustomersTimelineFormFallback,
        metadata: entry.action == HostCustomerFormTimelineAction.submitted
            ? context.l10n.hostCustomersTimelineFormSubmitted(
                answerCount: entry.answeredQuestionCount,
              )
            : context.l10n.hostFormResponsesWithdrawn,
        icon: CatchIcons.tabForms,
        color: t.primary,
        onTap: () => onOpenFormResponse(entry.responseId),
      ),
      HostCustomerEventTimelineEntry() => CatchRecordRow(
        key: key,
        title: entry.eventName,
        metadata: context.l10n.hostCustomersTimelineEventStatus(
          status: entry.checkedIn ? 'checkedIn' : entry.status,
        ),
        icon: CatchIcons.eventAvailable,
        color: entry.checkedIn ? t.success : t.ink2,
        onTap: () => onOpenEvent(entry.eventId),
      ),
      HostCustomerSendTimelineEntry() => CatchRecordRow(
        key: key,
        title: entry.sendKind == HostCustomerTimelineSendKind.manualHandoff
            ? context.l10n.hostCustomersTimelineManualHandoff
            : entry.name,
        metadata: context.l10n.hostCustomersTimelineSendStatus(
          status: entry.status,
        ),
        icon: CatchIcons.sendRounded,
        color: entry.status == 'failed' ? t.danger : t.ink2,
      ),
      HostCustomerReplyTimelineEntry() => CatchRecordRow(
        key: key,
        title: context.l10n.hostCustomersTimelineDirection(
          direction: entry.direction.name,
        ),
        metadata: entry.transport == HostCustomerReplyTransport.catchChat
            ? context.l10n.hostCustomersTimelineCatchMessage
            : context.l10n.hostCustomersTimelineManagedWhatsapp,
        description: entry.bodyPreview,
        icon: CatchIcons.tabChats,
        color: t.primary,
        onTap: () => entry.transport == HostCustomerReplyTransport.catchChat
            ? onOpenCatchThread(entry.threadId)
            : onOpenWhatsappThread(entry.threadId),
      ),
    };
  }
}
