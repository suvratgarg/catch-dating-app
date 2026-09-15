import 'dart:async';

import 'package:catch_dating_app/core/app_error_context.dart' as app_ops;
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/clipboard.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/events/data/event_runtime_claim_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/events/domain/event_runtime_claim_request.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/data/crm/host_contacts_repository.dart';
import 'package:catch_dating_app/hosts/data/host_attendance_outbox.dart';
import 'package:catch_dating_app/hosts/data/host_provider_repository.dart';
import 'package:catch_dating_app/hosts/data/host_roster_file_parser.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_event_roster_insights.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/host_operational_roster_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_roster_insight_filter.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_booking_provider_section.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_luma_connection_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_roster_import_sheet.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'host_attendance_outbox_notice.dart';
part 'host_manual_attendee_sheet.dart';
part 'host_operational_roster_actions.dart';
part 'host_operational_roster_support.dart';
part 'host_roster_handoff_sheet.dart';

class HostGuestIntakeField extends StatelessWidget {
  const HostGuestIntakeField({
    super.key,
    required this.eventId,
    required this.organizerId,
    this.bookingProvider,
    this.suggestedRevenueAmountMinor,
    this.revenueCurrency = defaultCurrencyCode,
  });

  final String eventId;
  final String organizerId;
  final ExternalBookingProvider? bookingProvider;
  final int? suggestedRevenueAmountMinor;
  final String revenueCurrency;

  @override
  Widget build(BuildContext context) => HostOperationalRosterPanel._guestIntake(
    eventId: eventId,
    organizerId: organizerId,
    bookingProvider: bookingProvider,
    suggestedRevenueAmountMinor: suggestedRevenueAmountMinor,
    revenueCurrency: revenueCurrency,
  );
}

class HostGuestIntakeDisclosure extends StatelessWidget {
  const HostGuestIntakeDisclosure({
    super.key,
    required this.importing,
    required this.creatingHandoff,
    required this.providerMutationPending,
    required this.showsProviderSource,
    required this.providerSetup,
    required this.bookingProvider,
    required this.mutationError,
    required this.onOpenChanged,
    required this.onImport,
    required this.onAddGuest,
    required this.onForward,
    required this.onRetryProvider,
    required this.onConnect,
    required this.onSync,
    required this.onDisconnect,
  });

  final bool importing;
  final bool creatingHandoff;
  final bool providerMutationPending;
  final bool showsProviderSource;
  final AsyncValue<HostProviderSetup>? providerSetup;
  final ExternalBookingProvider? bookingProvider;
  final Object? mutationError;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback onImport;
  final VoidCallback onAddGuest;
  final VoidCallback onForward;
  final VoidCallback onRetryProvider;
  final VoidCallback onConnect;
  final VoidCallback onSync;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return CatchFieldLanes.single(
      child: CatchField.control(
        copy: catchFieldCopy(context.l10n),
        key: const ValueKey<String>('host_event_guest_intake_field'),
        title: context.l10n.hostsOperationalRosterGuestIntakeTitle,
        body: context.l10n.hostsOperationalRosterGuestIntakeBody,
        contractExemption:
            'Disclosure and action surface for importing a server-owned event '
            'guest list; the field itself does not persist a scalar value.',
        icon: CatchIcons.groupsOutlined,
        onOpenChanged: onOpenChanged,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchButton(
                  label: context.l10n.hostsOperationalRosterImport,
                  onPressed: importing ? null : onImport,
                  status: (importing)
                      ? CatchButtonStatus.loading
                      : CatchButtonStatus.idle,
                  variant: CatchButtonVariant.secondary,
                  leading: Icon(CatchIcons.cloudUploadOutlined),
                ),
                CatchButton(
                  label: context.l10n.hostsOperationalRosterAddGuest,
                  onPressed: importing ? null : onAddGuest,
                  variant: CatchButtonVariant.ghost,
                  leading: Icon(CatchIcons.personAddAlt1Outlined),
                ),
                CatchButton(
                  label: context.l10n.hostsOperationalRosterForwardCsv,
                  onPressed: importing || creatingHandoff ? null : onForward,
                  status: (creatingHandoff)
                      ? CatchButtonStatus.loading
                      : CatchButtonStatus.idle,
                  variant: CatchButtonVariant.ghost,
                  leading: Icon(CatchIcons.alternateEmailOutlined),
                ),
              ],
            ),
            if (mutationError case final error?) ...[
              gapH12,
              CatchLocalizedErrorBanner(error, context: AppErrorContext.event),
            ],
            if (showsProviderSource) ...[
              gapH20,
              Text(
                context.l10n.hostsOperationalRosterProviderTitle,
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH4,
              Text(
                context.l10n.hostsOperationalRosterProviderBody(
                  provider: _providerDisplayName(context, bookingProvider!),
                ),
                style: CatchTextStyles.supporting(context),
              ),
              gapH12,
              HostBookingProviderSection(
                value: providerSetup,
                provider: bookingProvider!,
                mutationPending: providerMutationPending,
                allowChanges: true,
                onRetry: onRetryProvider,
                onConnect: onConnect,
                onSync: onSync,
                onDisconnect: onDisconnect,
                onImport: onImport,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _HostOperationalRosterView { guestIntake, roster }

class HostOperationalRosterPanel extends ConsumerStatefulWidget {
  const HostOperationalRosterPanel({
    super.key,
    required this.eventId,
    required this.organizerId,
    this.allowAttendanceChanges = true,
    this.allowRuntimeClaimReview = true,
    this.showAudienceInsights = true,
    this.allowManualGuest = false,
    this.suggestedRevenueAmountMinor,
    this.revenueCurrency = defaultCurrencyCode,
  }) : _view = _HostOperationalRosterView.roster,
       bookingProvider = null;

  const HostOperationalRosterPanel._guestIntake({
    required this.eventId,
    required this.organizerId,
    required this.bookingProvider,
    required this.suggestedRevenueAmountMinor,
    required this.revenueCurrency,
  }) : _view = _HostOperationalRosterView.guestIntake,
       allowAttendanceChanges = false,
       allowRuntimeClaimReview = false,
       showAudienceInsights = false,
       allowManualGuest = false;

  final String eventId;
  final String organizerId;
  final bool allowAttendanceChanges;
  final bool allowRuntimeClaimReview;
  final bool showAudienceInsights;
  final bool allowManualGuest;
  final ExternalBookingProvider? bookingProvider;
  final int? suggestedRevenueAmountMinor;
  final String revenueCurrency;
  final _HostOperationalRosterView _view;

  @override
  ConsumerState<HostOperationalRosterPanel> createState() =>
      _HostOperationalRosterPanelState();
}

class _HostOperationalRosterPanelState
    extends ConsumerState<HostOperationalRosterPanel> {
  var _importing = false;
  var _creatingHandoff = false;
  String? _pendingAttendanceId;
  String? _pendingClaimUid;
  AsyncValue<HostProviderSetup>? _providerSetup;
  var _providerMutationPending = false;
  String? _providerSyncOperationId;
  Object? _mutationError;
  HostAttendanceOutboxSummary? _attendanceOutbox;
  HostRosterInsightFilter _insightFilter = HostRosterInsightFilter.all;

  @override
  void initState() {
    super.initState();
    if (widget._view == _HostOperationalRosterView.roster) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadAttendanceOutbox());
      });
      ref.listenManual(appConnectivityProvider, (previous, next) {
        final results = next.asData?.value;
        if (results != null && !connectivityResultsAreOffline(results)) {
          unawaited(_flushAttendanceOutbox());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget._view == _HostOperationalRosterView.guestIntake) {
      return HostGuestIntakeDisclosure(
        importing: _importing,
        creatingHandoff: _creatingHandoff,
        providerMutationPending: _providerMutationPending,
        showsProviderSource: _showsProviderSource,
        providerSetup: _providerSetup,
        bookingProvider: widget.bookingProvider,
        mutationError: _mutationError,
        onOpenChanged: (open) {
          if (open && _showsProviderSource) {
            unawaited(_loadProviderSetup());
          }
        },
        onImport: () => unawaited(_pickRoster()),
        onAddGuest: () => unawaited(_showManualGuest()),
        onForward: () => unawaited(_showRosterHandoff()),
        onRetryProvider: () => unawaited(_loadProviderSetup(force: true)),
        onConnect: () => unawaited(_connectLuma()),
        onSync: () => unawaited(_syncProvider()),
        onDisconnect: () => unawaited(_disconnectProvider()),
      );
    }
    final attendeesAsync = ref.watch(
      watchEventAttendeesProvider(widget.eventId),
    );
    final attendeesState = catchAsyncStateFromAsyncValue(attendeesAsync);
    final insightsAsync = widget.showAudienceInsights
        ? ref.watch(hostEventRosterInsightsProvider(widget.eventId))
        : null;
    final claimsAsync = widget.allowRuntimeClaimReview
        ? ref.watch(watchPendingEventRuntimeClaimsProvider(widget.eventId))
        : const AsyncData<List<EventRuntimeClaimRequest>>([]);
    final rosterSection = CatchSection.contained(
      title: context.l10n.hostsOperationalRosterTitle,
      subtitle: context.l10n.hostsOperationalRosterSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.allowManualGuest) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: CatchButton(
                label: context.l10n.hostsOperationalRosterAddWalkIn,
                onPressed: _importing
                    ? null
                    : () => unawaited(_showManualGuest()),
                status: (_importing)
                    ? CatchButtonStatus.loading
                    : CatchButtonStatus.idle,
                variant: CatchButtonVariant.secondary,
                leading: Icon(CatchIcons.personAddAlt1Outlined),
              ),
            ),
            gapH12,
          ],
          if (_mutationError case final error?) ...[
            CatchLocalizedErrorBanner(error, context: AppErrorContext.event),
            gapH12,
          ],
          if (_attendanceOutbox case final outbox?
              when outbox.entries.isNotEmpty) ...[
            HostAttendanceOutboxNotice(
              summary: outbox,
              onRetry: () => unawaited(_flushAttendanceOutbox()),
              onDiscardConflicts: () => unawaited(_clearAttendanceConflicts()),
            ),
            gapH12,
          ],
          CatchAsyncBoundary<List<EventRuntimeClaimRequest>>(
            value: claimsAsync,
            onRetry: () => ref.invalidate(
              watchPendingEventRuntimeClaimsProvider(widget.eventId),
            ),
            loadingBuilder: (_) => const SizedBox.shrink(),
            errorBuilder: (_, error, _, onBoundaryRetry) =>
                CatchLocalizedErrorBanner(
                  error,
                  context: AppErrorContext.event,
                  onRetry: onBoundaryRetry,
                ),
            builder: (context, claims) {
              if (claims.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: CatchInsets.sectionItemBottomGap,
                child: _HostRuntimeClaimQueue(
                  claims: claims,
                  attendees: attendeesState.value ?? const [],
                  pendingUid: _pendingClaimUid,
                  onApprove: (claim, attendeeId) => unawaited(
                    _reviewClaim(
                      claim,
                      EventRuntimeClaimDecision.approve,
                      attendeeId: attendeeId,
                    ),
                  ),
                  onReject: (claim) => unawaited(
                    _reviewClaim(claim, EventRuntimeClaimDecision.reject),
                  ),
                ),
              );
            },
          ),
          CatchAsyncBoundary<List<EventAttendee>>(
            value: attendeesAsync,
            errorContext: AppErrorContext.event,
            onRetry: () =>
                ref.invalidate(watchEventAttendeesProvider(widget.eventId)),
            builder: (context, attendees) {
              if (attendees.isEmpty) {
                return CatchEmptyState(
                  variant: CatchEmptyStateVariant.inline,
                  icon: CatchIcons.groupsOutlined,
                  title: context.l10n.hostsOperationalRosterEmptyTitle,
                  message: context.l10n.hostsOperationalRosterEmptyMessage,
                );
              }
              final insights = insightsAsync == null
                  ? null
                  : catchAsyncStateFromAsyncValue(insightsAsync).value;
              final insightByAttendeeId = insights?.byAttendeeId ?? const {};
              final effectiveFilter = insights == null
                  ? HostRosterInsightFilter.all
                  : _insightFilter;
              final filteredAttendees = attendees
                  .where(
                    (attendee) => hostRosterInsightMatches(
                      effectiveFilter,
                      insightByAttendeeId[attendee.id],
                    ),
                  )
                  .toList(growable: false);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showAudienceInsights) ...[
                    _HostRosterInsightsBar(
                      insightsAsync: insightsAsync!,
                      attendeeCount: attendees.length,
                      selected: _insightFilter,
                      onSelected: (filter) =>
                          setState(() => _insightFilter = filter),
                      onRetry: () => ref.invalidate(
                        hostEventRosterInsightsProvider(widget.eventId),
                      ),
                    ),
                    gapH12,
                  ],
                  if (filteredAttendees.isEmpty)
                    CatchEmptyState(
                      variant: CatchEmptyStateVariant.inline,
                      icon: CatchIcons.searchOffRounded,
                      title: context
                          .l10n
                          .hostsOperationalRosterInsightsFilterEmptyTitle,
                      message: context
                          .l10n
                          .hostsOperationalRosterInsightsFilterEmptyMessage,
                    )
                  else
                    for (final indexed in filteredAttendees.indexed)
                      _HostOperationalAttendeeRow(
                        key: ValueKey(indexed.$2.id),
                        attendee: indexed.$2,
                        insight: insightByAttendeeId[indexed.$2.id],
                        divider: indexed.$1 > 0,
                        pending:
                            _pendingAttendanceId == indexed.$2.id ||
                            _attendanceOutbox?.forAttendee(indexed.$2.id) !=
                                null,
                        enabled: widget.allowAttendanceChanges,
                        onPressed: () =>
                            unawaited(_toggleAttendance(indexed.$2)),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
    return rosterSection;
  }
}

class _HostRosterInsightsBar extends StatelessWidget {
  const _HostRosterInsightsBar({
    required this.insightsAsync,
    required this.attendeeCount,
    required this.selected,
    required this.onSelected,
    required this.onRetry,
  });

  final AsyncValue<HostEventRosterInsights> insightsAsync;
  final int attendeeCount;
  final HostRosterInsightFilter selected;
  final ValueChanged<HostRosterInsightFilter> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => insightsAsync.when(
    loading: () => Text(
      context.l10n.hostsOperationalRosterInsightsLoading,
      style: CatchTextStyles.supporting(context),
    ),
    error: (_, _) => Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        Text(
          context.l10n.hostsOperationalRosterInsightsUnavailable,
          style: CatchTextStyles.supporting(context),
        ),
        CatchButton(
          label: context.l10n.hostsOperationalRosterInsightsRetry,
          onPressed: onRetry,
          size: CatchButtonSize.sm,
          variant: CatchButtonVariant.ghost,
        ),
      ],
    ),
    data: (insights) {
      final filters = <HostRosterInsightFilter>[
        HostRosterInsightFilter.all,
        for (final filter in HostRosterInsightFilter.values.skip(1))
          if (hostRosterInsightFilterCount(filter, insights.rows) > 0 ||
              filter == selected)
            filter,
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.hostsOperationalRosterInsightsCaption,
            style: CatchTextStyles.supporting(context),
          ),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final filter in filters)
                CatchChip.selectable(
                  label: _insightFilterLabel(
                    context,
                    filter,
                    filter == HostRosterInsightFilter.all
                        ? attendeeCount
                        : hostRosterInsightFilterCount(filter, insights.rows),
                  ),
                  selected: selected == filter,
                  onChanged: (_) => onSelected(filter),
                  contractExemption:
                      'Manager-only, callable-owned roster insight filter; '
                      'selection is ephemeral and is never persisted.',
                ),
            ],
          ),
          if (insights.spendCoverage ==
              HostRosterSpendCoverage.catchPaymentsOnly) ...[
            gapH8,
            Text(
              context.l10n.hostsOperationalRosterInsightsSpendFootnote,
              style: CatchTextStyles.meta(context),
            ),
          ],
          if (insights.sourceCoverage == HostRosterInsightCoverage.partial) ...[
            gapH8,
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                Text(
                  context.l10n.hostsOperationalRosterInsightsPreparing,
                  style: CatchTextStyles.meta(context),
                ),
                CatchButton(
                  label: context.l10n.hostsOperationalRosterInsightsRetry,
                  onPressed: onRetry,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.ghost,
                ),
              ],
            ),
          ],
        ],
      );
    },
  );
}

class _HostOperationalAttendeeRow extends StatelessWidget {
  const _HostOperationalAttendeeRow({
    super.key,
    required this.attendee,
    required this.insight,
    required this.divider,
    required this.pending,
    required this.enabled,
    required this.onPressed,
  });

  final EventAttendee attendee;
  final HostEventRosterInsight? insight;
  final bool divider;
  final bool pending;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final signals = _displayInsightSignals(insight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchPersonRow(
          copy: catchPersonRowCopy(context.l10n),
          data: CatchPersonRowData(
            name: attendee.displayName,
            seed: attendee.id,
            metaLine: _attendeeMeta(context, attendee),
            contextLine: attendee.hasEventIdentity
                ? context.l10n.hostsOperationalRosterIdentityLinked
                : null,
          ),
          divider: divider,
          trailing: _RosterAttendanceAction(
            attendee: attendee,
            pending: pending,
            enabled: enabled,
            onPressed: onPressed,
          ),
        ),
        if (signals.isNotEmpty)
          Padding(
            padding: CatchInsets.operationalRosterInsightLane,
            child: Wrap(
              spacing: CatchSpacing.s1,
              runSpacing: CatchSpacing.s1,
              children: [
                for (final signal in signals)
                  CatchBadge(
                    label: _insightSignalLabel(context, signal),
                    tone: _insightSignalTone(signal),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HostRuntimeClaimQueue extends StatelessWidget {
  const _HostRuntimeClaimQueue({
    required this.claims,
    required this.attendees,
    required this.pendingUid,
    required this.onApprove,
    required this.onReject,
  });

  final List<EventRuntimeClaimRequest> claims;
  final List<EventAttendee> attendees;
  final String? pendingUid;
  final void Function(EventRuntimeClaimRequest claim, String attendeeId)
  onApprove;
  final ValueChanged<EventRuntimeClaimRequest> onReject;

  @override
  Widget build(BuildContext context) {
    final attendeesById = <String, EventAttendee>{
      for (final attendee in attendees) attendee.id: attendee,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchBadge.functional(
          label: context.l10n.hostsOperationalRosterClaimsPending(
            count: claims.length,
          ),
          tone: CatchBadgeTone.warning,
        ),
        gapH8,
        for (final indexed in claims.indexed)
          CatchPersonRow(
            copy: catchPersonRowCopy(context.l10n),
            key: ValueKey('runtime-claim-${indexed.$2.uid}'),
            data: CatchPersonRowData(
              name: indexed.$2.displayName,
              seed: indexed.$2.uid,
              metaLine: context.l10n.hostsOperationalRosterClaimPhone(
                phoneLastFour: indexed.$2.phoneLastFour,
              ),
              contextLine: context.l10n.hostsOperationalRosterClaimContext,
            ),
            divider: indexed.$1 > 0,
            trailing: _HostRuntimeClaimActions(
              claim: indexed.$2,
              attendeesById: attendeesById,
              pending: pendingUid == indexed.$2.uid,
              enabled: pendingUid == null,
              onApprove: (attendeeId) => onApprove(indexed.$2, attendeeId),
              onReject: () => onReject(indexed.$2),
            ),
          ),
      ],
    );
  }
}

class _HostRuntimeClaimActions extends StatelessWidget {
  const _HostRuntimeClaimActions({
    required this.claim,
    required this.attendeesById,
    required this.pending,
    required this.enabled,
    required this.onApprove,
    required this.onReject,
  });

  final EventRuntimeClaimRequest claim;
  final Map<String, EventAttendee> attendeesById;
  final bool pending;
  final bool enabled;
  final ValueChanged<String> onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final candidateIds = claim.candidateAttendeeIds;
    final approve = candidateIds.length == 1
        ? CatchButton(
            label: context.l10n.hostsOperationalRosterClaimApprove,
            onPressed: enabled ? () => onApprove(candidateIds.single) : null,
            status: (pending)
                ? CatchButtonStatus.loading
                : CatchButtonStatus.idle,
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
          )
        : CatchMenu<String>.anchored(
            items: [
              for (final attendeeId in candidateIds)
                CatchMenuItem<String>(
                  value: attendeeId,
                  label: attendeesById[attendeeId]?.displayName ?? attendeeId,
                  sublabel: attendeesById[attendeeId]?.phoneE164,
                ),
            ],
            onSelected: (attendeeId, _) => onApprove(attendeeId),
            builder: (context, controller, child) => CatchButton(
              label: context.l10n.hostsOperationalRosterClaimChooseGuest,
              onPressed: enabled && candidateIds.isNotEmpty
                  ? controller.open
                  : null,
              status: (pending)
                  ? CatchButtonStatus.loading
                  : CatchButtonStatus.idle,
              variant: CatchButtonVariant.secondary,
              size: CatchButtonSize.sm,
            ),
          );
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: CatchSpacing.s1,
      runSpacing: CatchSpacing.s1,
      children: [
        approve,
        CatchButton(
          label: context.l10n.hostsOperationalRosterClaimReject,
          onPressed: enabled ? onReject : null,
          variant: CatchButtonVariant.ghost,
          size: CatchButtonSize.sm,
        ),
      ],
    );
  }
}

class _RosterAttendanceAction extends StatelessWidget {
  const _RosterAttendanceAction({
    required this.attendee,
    required this.pending,
    required this.enabled,
    required this.onPressed,
  });

  final EventAttendee attendee;
  final bool pending;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final checkedIn = attendee.isCheckedIn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CatchBadge.functional(
          label: _statusCopy(context, attendee.status),
          tone: checkedIn ? CatchBadgeTone.success : CatchBadgeTone.neutral,
        ),
        if (enabled) ...[
          gapH4,
          CatchButton(
            label: checkedIn
                ? context.l10n.hostsOperationalRosterUndoCheckIn
                : context.l10n.hostsOperationalRosterCheckIn,
            onPressed: pending ? null : onPressed,
            status: (pending)
                ? CatchButtonStatus.loading
                : CatchButtonStatus.idle,
            variant: CatchButtonVariant.ghost,
            size: CatchButtonSize.sm,
          ),
        ],
      ],
    );
  }
}
