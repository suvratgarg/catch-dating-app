import 'dart:async';

import 'package:catch_dating_app/core/app_error_context.dart' as app_ops;
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/clipboard.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/events/data/event_runtime_claim_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/events/domain/event_runtime_claim_request.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/data/host_attendance_outbox.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/data/host_provider_repository.dart';
import 'package:catch_dating_app/hosts/data/host_roster_file_parser.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/host_operational_roster_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_roster_insight_filter.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostOperationalRosterPanel extends ConsumerStatefulWidget {
  const HostOperationalRosterPanel({
    super.key,
    required this.eventId,
    required this.organizerId,
    this.allowRosterIntake = true,
    this.allowAttendanceChanges = true,
    this.allowRuntimeClaimReview = true,
    this.showProviderControls = true,
    this.showAudienceInsights = true,
    this.bookingProvider,
  });

  final String eventId;
  final String organizerId;
  final bool allowRosterIntake;
  final bool allowAttendanceChanges;
  final bool allowRuntimeClaimReview;
  final bool showProviderControls;
  final bool showAudienceInsights;
  final ExternalBookingProvider? bookingProvider;

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
    unawaited(_loadAttendanceOutbox());
    ref.listenManual(appConnectivityProvider, (previous, next) {
      final results = next.asData?.value;
      if (results != null && !connectivityResultsAreOffline(results)) {
        unawaited(_flushAttendanceOutbox());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendeesAsync = ref.watch(
      watchEventAttendeesProvider(widget.eventId),
    );
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
          if (widget.allowRosterIntake) ...[
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchButton(
                  label: context.l10n.hostsOperationalRosterImport,
                  onPressed: _importing ? null : () => unawaited(_pickRoster()),
                  isLoading: _importing,
                  variant: CatchButtonVariant.secondary,
                  icon: Icon(CatchIcons.cloudUploadOutlined),
                ),
                CatchButton(
                  label: context.l10n.hostsOperationalRosterAddGuest,
                  onPressed: _importing
                      ? null
                      : () => unawaited(_showManualGuest()),
                  variant: CatchButtonVariant.ghost,
                  icon: Icon(CatchIcons.personAddAlt1Outlined),
                ),
                CatchButton(
                  label: context.l10n.hostsOperationalRosterForwardCsv,
                  onPressed: _importing || _creatingHandoff
                      ? null
                      : () => unawaited(_showRosterHandoff()),
                  isLoading: _creatingHandoff,
                  variant: CatchButtonVariant.ghost,
                  icon: Icon(CatchIcons.alternateEmailOutlined),
                ),
              ],
            ),
            gapH12,
          ],
          if (_mutationError case final error?) ...[
            CatchErrorBanner.fromError(error, context: AppErrorContext.event),
            gapH12,
          ],
          if (_attendanceOutbox case final outbox?
              when outbox.entries.isNotEmpty) ...[
            _HostAttendanceOutboxNotice(
              summary: outbox,
              onRetry: () => unawaited(_flushAttendanceOutbox()),
              onDiscardConflicts: () => unawaited(_clearAttendanceConflicts()),
            ),
            gapH12,
          ],
          CatchAsyncValueView<List<EventRuntimeClaimRequest>>(
            value: claimsAsync,
            onRetry: () => ref.invalidate(
              watchPendingEventRuntimeClaimsProvider(widget.eventId),
            ),
            loadingBuilder: (_) => const SizedBox.shrink(),
            errorBuilder: (_, error, _) => CatchErrorBanner.fromError(
              error,
              context: AppErrorContext.event,
              onRetry: () => ref.invalidate(
                watchPendingEventRuntimeClaimsProvider(widget.eventId),
              ),
            ),
            builder: (context, claims) {
              if (claims.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: CatchInsets.sectionItemBottomGap,
                child: _HostRuntimeClaimQueue(
                  claims: claims,
                  attendees: attendeesAsync.asData?.value ?? const [],
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
          CatchAsyncValueView<List<EventAttendee>>(
            value: attendeesAsync,
            errorContext: AppErrorContext.event,
            onRetry: () =>
                ref.invalidate(watchEventAttendeesProvider(widget.eventId)),
            builder: (context, attendees) {
              if (attendees.isEmpty) {
                return CatchEmptyState(
                  layout: CatchEmptyStateLayout.inline,
                  icon: CatchIcons.groupsOutlined,
                  title: context.l10n.hostsOperationalRosterEmptyTitle,
                  message: context.l10n.hostsOperationalRosterEmptyMessage,
                );
              }
              final insights = insightsAsync?.asData?.value;
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
                      layout: CatchEmptyStateLayout.inline,
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
    if (!_showsProviderSource) return rosterSection;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSection.fieldRows(
          first: true,
          children: [
            CatchField.control(
              title: context.l10n.hostsOperationalRosterProviderTitle,
              contractExemption:
                  'Disclosure and action surface for a server-owned '
                  'booking-provider connection; the field itself does not '
                  'persist an editable scalar value.',
              body: context.l10n.hostsOperationalRosterProviderBody(
                provider: _providerDisplayName(
                  context,
                  widget.bookingProvider!,
                ),
              ),
              icon: CatchIcons.syncRounded,
              control: _HostProviderControl(
                value: _providerSetup,
                provider: widget.bookingProvider!,
                mutationPending: _providerMutationPending,
                allowChanges: widget.allowRosterIntake,
                onRetry: () => unawaited(_loadProviderSetup(force: true)),
                onConnect: () => unawaited(_connectLuma()),
                onSync: () => unawaited(_syncProvider()),
                onDisconnect: () => unawaited(_disconnectProvider()),
                onImport: () => unawaited(_pickRoster()),
              ),
              onOpenChanged: (open) {
                if (open) unawaited(_loadProviderSetup());
              },
            ),
          ],
        ),
        gapH20,
        rosterSection,
      ],
    );
  }

  bool get _showsProviderSource {
    final provider = widget.bookingProvider;
    return widget.showProviderControls &&
        provider != null &&
        provider != ExternalBookingProvider.catchPlatform;
  }

  Future<void> _loadProviderSetup({bool force = false}) async {
    if (!force && _providerSetup != null) return;
    setState(() => _providerSetup = const AsyncLoading());
    try {
      final setup = await ref
          .read(hostOperationalRosterControllerProvider)
          .getProviderSetup(
            organizerId: widget.organizerId,
            eventId: widget.eventId,
          );
      if (mounted) setState(() => _providerSetup = AsyncData(setup));
    } catch (error, stackTrace) {
      app_ops.logAppError(
        error,
        stackTrace: stackTrace,
        context: const app_ops.AppErrorContext(
          operation: app_ops.AppOperation.ui,
          action: 'load organizer booking provider setup',
          resource: 'host_provider_setup',
        ),
        logError: ref.read(errorLoggerProvider),
      );
      if (mounted) {
        setState(() => _providerSetup = AsyncError(error, stackTrace));
      }
    }
  }

  Future<void> _connectLuma() async {
    final input = await showCatchBottomSheet<_LumaConnectionInput>(
      context: context,
      builder: (context) => _HostLumaConnectionSheet(
        organizerId: widget.organizerId,
        eventId: widget.eventId,
        controller: ref.read(hostOperationalRosterControllerProvider),
      ),
    );
    if (input == null || !mounted) return;
    setState(() {
      _providerMutationPending = true;
      _mutationError = null;
    });
    try {
      final setup = await ref
          .read(hostOperationalRosterControllerProvider)
          .connectLuma(
            organizerId: widget.organizerId,
            eventId: widget.eventId,
            externalEventId: input.externalEventId,
            apiKey: input.apiKey,
          );
      if (!mounted) return;
      setState(() => _providerSetup = AsyncData(setup));
      showCatchSnackBar(
        context,
        context.l10n.hostsOperationalRosterProviderConnected,
      );
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _providerMutationPending = false);
    }
  }

  Future<void> _syncProvider() async {
    if (_providerMutationPending) return;
    final operationId = _providerSyncOperationId ??=
        _newProviderSyncOperationId();
    setState(() {
      _providerMutationPending = true;
      _mutationError = null;
    });
    try {
      final result = await ref
          .read(hostOperationalRosterControllerProvider)
          .syncProvider(
            organizerId: widget.organizerId,
            eventId: widget.eventId,
            clientOperationId: operationId,
          );
      _providerSyncOperationId = null;
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
      await _loadProviderSetup(force: true);
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsOperationalRosterProviderSyncSuccess(
          created: result.createdCount,
          updated: result.updatedCount,
          skipped: result.skippedCount,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _providerMutationPending = false);
    }
  }

  Future<void> _disconnectProvider() async {
    final connection = _providerSetup?.asData?.value.mappedConnection;
    if (connection == null || _providerMutationPending) return;
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostsOperationalRosterProviderDisconnectTitle,
      message: context.l10n.hostsOperationalRosterProviderDisconnectBody,
      confirmLabel: context.l10n.hostsOperationalRosterProviderDisconnect,
      danger: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _providerMutationPending = true;
      _mutationError = null;
    });
    try {
      final next = await ref
          .read(hostOperationalRosterControllerProvider)
          .disconnectProvider(
            organizerId: widget.organizerId,
            eventId: widget.eventId,
            connectionId: connection.connectionId,
          );
      if (mounted) setState(() => _providerSetup = AsyncData(next));
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _providerMutationPending = false);
    }
  }

  Future<void> _pickRoster() async {
    setState(() {
      _importing = true;
      _mutationError = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'xlsx'],
        withData: true,
      );
      if (result == null || !mounted) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        throw const HostRosterImportException(
          HostRosterImportIssue.unreadableXlsx,
        );
      }
      final table = parseHostRosterFile(
        fileName: file.name,
        bytes: bytes,
        providerHint: widget.bookingProvider,
      );
      final selection = await _showRosterMapping(context, table);
      if (selection == null || !mounted) return;
      await _importRows(
        fileName: table.fileName,
        format: table.format,
        rows: selection.rows,
      );
    } on HostRosterImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(context, _importIssueCopy(context, error.issue));
      }
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _showManualGuest() async {
    final row = await showCatchBottomSheet<EventAttendeeImportRow>(
      context: context,
      builder: (context) => const _HostManualAttendeeSheet(),
    );
    if (row == null || !mounted) return;
    setState(() {
      _importing = true;
      _mutationError = null;
    });
    try {
      await _importRows(
        fileName: 'manual-entry',
        format: EventAttendeeImportFormat.manual,
        rows: [row],
      );
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _showRosterHandoff() async {
    setState(() {
      _creatingHandoff = true;
      _mutationError = null;
    });
    try {
      final instructions = await ref
          .read(hostOperationalRosterControllerProvider)
          .createRosterHandoff(eventId: widget.eventId);
      if (!mounted) return;
      await showCatchBottomSheet<void>(
        context: context,
        builder: (context) => _HostRosterHandoffSheet(
          instructions: instructions,
          onCopy: (value) =>
              ref.read(clipboardControllerProvider).copyText(value),
        ),
      );
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _creatingHandoff = false);
    }
  }

  Future<void> _reviewClaim(
    EventRuntimeClaimRequest claim,
    EventRuntimeClaimDecision decision, {
    String? attendeeId,
  }) async {
    if (_pendingClaimUid != null) return;
    setState(() {
      _pendingClaimUid = claim.uid;
      _mutationError = null;
    });
    try {
      await ref
          .read(hostOperationalRosterControllerProvider)
          .reviewRuntimeClaim(
            eventId: widget.eventId,
            uid: claim.uid,
            decision: decision,
            attendeeId: attendeeId,
          );
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
      if (!mounted) return;
      showCatchSnackBar(
        context,
        decision == EventRuntimeClaimDecision.approve
            ? context.l10n.hostsOperationalRosterClaimApproved
            : context.l10n.hostsOperationalRosterClaimRejected,
      );
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _pendingClaimUid = null);
    }
  }

  Future<void> _importRows({
    required String fileName,
    required EventAttendeeImportFormat format,
    required List<EventAttendeeImportRow> rows,
  }) async {
    final importKey = format == EventAttendeeImportFormat.manual
        ? _newImportKey()
        : hostRosterImportKey(fileName: fileName, format: format, rows: rows);
    try {
      final result = await ref
          .read(hostOperationalRosterControllerProvider)
          .importAttendees(
            eventId: widget.eventId,
            importKey: importKey,
            fileName: fileName,
            format: format,
            rows: rows,
          );
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsOperationalRosterImportSuccess(
          created: result.createdCount,
          updated: result.updatedCount,
          skipped: result.skippedCount,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
      rethrow;
    }
  }

  Future<void> _toggleAttendance(EventAttendee attendee) async {
    if (_pendingAttendanceId != null) return;
    setState(() {
      _pendingAttendanceId = attendee.id;
      _mutationError = null;
    });
    try {
      final outbox = await ref
          .read(hostOperationalRosterControllerProvider)
          .setAttendance(
            eventId: widget.eventId,
            attendee: attendee,
            clientOperationId: _newAttendanceOperationId(attendee.id),
          );
      if (mounted) setState(() => _attendanceOutbox = outbox);
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _pendingAttendanceId = null);
    }
  }

  Future<void> _loadAttendanceOutbox() async {
    try {
      final outbox = await ref
          .read(hostOperationalRosterControllerProvider)
          .loadAttendanceOutbox(widget.eventId);
      if (mounted) setState(() => _attendanceOutbox = outbox);
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    }
  }

  Future<void> _flushAttendanceOutbox() async {
    try {
      final outbox = await ref
          .read(hostOperationalRosterControllerProvider)
          .flushAttendanceOutbox(widget.eventId);
      if (!mounted) return;
      setState(() => _attendanceOutbox = outbox);
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      ref.invalidate(hostEventRosterInsightsProvider(widget.eventId));
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    }
  }

  Future<void> _clearAttendanceConflicts() async {
    try {
      final outbox = await ref
          .read(hostOperationalRosterControllerProvider)
          .clearAttendanceConflicts(widget.eventId);
      if (mounted) setState(() => _attendanceOutbox = outbox);
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    }
  }
}

class _HostRosterInsightsBar extends StatelessWidget {
  const _HostRosterInsightsBar({
    required this.insightsAsync,
    required this.selected,
    required this.onSelected,
    required this.onRetry,
  });

  final AsyncValue<HostEventRosterInsights> insightsAsync;
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
                        ? insights.rows.length
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

List<HostRosterInsightSignal> _displayInsightSignals(
  HostEventRosterInsight? insight,
) {
  if (insight?.availability != HostRosterInsightAvailability.ready) {
    return const [];
  }
  const priority = [
    HostRosterInsightSignal.highImpactAdvocate,
    HostRosterInsightSignal.topCatchSpender,
    HostRosterInsightSignal.firstTime,
    HostRosterInsightSignal.reEngaging,
    HostRosterInsightSignal.needsConfirmation,
    HostRosterInsightSignal.regular,
    HostRosterInsightSignal.reliable,
    HostRosterInsightSignal.advocate,
    HostRosterInsightSignal.returning,
    HostRosterInsightSignal.knownCatchSpender,
  ];
  return priority
      .where(insight!.signals.contains)
      .take(3)
      .toList(growable: false);
}

String _insightFilterLabel(
  BuildContext context,
  HostRosterInsightFilter filter,
  int count,
) => context.l10n.hostsOperationalRosterInsightsFilterCount(
  label: switch (filter) {
    HostRosterInsightFilter.all =>
      context.l10n.hostsOperationalRosterInsightsFilterAll,
    HostRosterInsightFilter.firstTime =>
      context.l10n.hostsOperationalRosterInsightFirstTime,
    HostRosterInsightFilter.returning =>
      context.l10n.hostsOperationalRosterInsightReturning,
    HostRosterInsightFilter.regular =>
      context.l10n.hostsOperationalRosterInsightRegular,
    HostRosterInsightFilter.reEngaging =>
      context.l10n.hostsOperationalRosterInsightReEngaging,
    HostRosterInsightFilter.reliable =>
      context.l10n.hostsOperationalRosterInsightReliable,
    HostRosterInsightFilter.needsConfirmation =>
      context.l10n.hostsOperationalRosterInsightNeedsConfirmation,
    HostRosterInsightFilter.advocate =>
      context.l10n.hostsOperationalRosterInsightAdvocate,
    HostRosterInsightFilter.topCatchSpender =>
      context.l10n.hostsOperationalRosterInsightTopCatchSpender,
  },
  count: count,
);

String _insightSignalLabel(
  BuildContext context,
  HostRosterInsightSignal signal,
) => switch (signal) {
  HostRosterInsightSignal.firstTime =>
    context.l10n.hostsOperationalRosterInsightFirstTime,
  HostRosterInsightSignal.returning =>
    context.l10n.hostsOperationalRosterInsightReturning,
  HostRosterInsightSignal.regular =>
    context.l10n.hostsOperationalRosterInsightRegular,
  HostRosterInsightSignal.reEngaging =>
    context.l10n.hostsOperationalRosterInsightReEngaging,
  HostRosterInsightSignal.reliable =>
    context.l10n.hostsOperationalRosterInsightReliable,
  HostRosterInsightSignal.needsConfirmation =>
    context.l10n.hostsOperationalRosterInsightNeedsConfirmation,
  HostRosterInsightSignal.advocate =>
    context.l10n.hostsOperationalRosterInsightAdvocate,
  HostRosterInsightSignal.highImpactAdvocate =>
    context.l10n.hostsOperationalRosterInsightHighImpactAdvocate,
  HostRosterInsightSignal.knownCatchSpender =>
    context.l10n.hostsOperationalRosterInsightCatchSpender,
  HostRosterInsightSignal.topCatchSpender =>
    context.l10n.hostsOperationalRosterInsightTopCatchSpender,
};

CatchBadgeTone _insightSignalTone(HostRosterInsightSignal signal) =>
    switch (signal) {
      HostRosterInsightSignal.firstTime => CatchBadgeTone.brand,
      HostRosterInsightSignal.returning => CatchBadgeTone.neutral,
      HostRosterInsightSignal.regular ||
      HostRosterInsightSignal.reliable => CatchBadgeTone.success,
      HostRosterInsightSignal.reEngaging ||
      HostRosterInsightSignal.needsConfirmation => CatchBadgeTone.warning,
      HostRosterInsightSignal.advocate ||
      HostRosterInsightSignal.highImpactAdvocate ||
      HostRosterInsightSignal.topCatchSpender => CatchBadgeTone.gold,
      HostRosterInsightSignal.knownCatchSpender => CatchBadgeTone.neutral,
    };

class _HostAttendanceOutboxNotice extends StatelessWidget {
  const _HostAttendanceOutboxNotice({
    required this.summary,
    required this.onRetry,
    required this.onDiscardConflicts,
  });

  final HostAttendanceOutboxSummary summary;
  final VoidCallback onRetry;
  final VoidCallback onDiscardConflicts;

  @override
  Widget build(BuildContext context) {
    final needsReview = summary.needsReviewCount > 0;
    return CatchSection.contained(
      title: needsReview
          ? context.l10n.hostsOperationalRosterOutboxReviewTitle
          : context.l10n.hostsOperationalRosterOutboxPendingTitle,
      subtitle: needsReview
          ? context.l10n.hostsOperationalRosterOutboxReviewBody(
              count: summary.needsReviewCount,
            )
          : context.l10n.hostsOperationalRosterOutboxPendingBody(
              count: summary.pendingCount,
            ),
      child: Wrap(
        spacing: CatchSpacing.s2,
        runSpacing: CatchSpacing.s2,
        children: [
          if (summary.pendingCount > 0)
            CatchButton(
              label: context.l10n.hostsOperationalRosterOutboxRetry,
              variant: CatchButtonVariant.secondary,
              onPressed: onRetry,
            ),
          if (needsReview)
            CatchButton(
              label: context.l10n.hostsOperationalRosterOutboxDiscard,
              variant: CatchButtonVariant.ghost,
              onPressed: onDiscardConflicts,
            ),
        ],
      ),
    );
  }
}

class _HostProviderControl extends StatelessWidget {
  const _HostProviderControl({
    required this.value,
    required this.provider,
    required this.mutationPending,
    required this.allowChanges,
    required this.onRetry,
    required this.onConnect,
    required this.onSync,
    required this.onDisconnect,
    required this.onImport,
  });

  final AsyncValue<HostProviderSetup>? value;
  final ExternalBookingProvider provider;
  final bool mutationPending;
  final bool allowChanges;
  final VoidCallback onRetry;
  final VoidCallback onConnect;
  final VoidCallback onSync;
  final VoidCallback onDisconnect;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final setupValue = value;
    if (setupValue == null) {
      return Text(
        context.l10n.hostsOperationalRosterProviderOpenToLoad,
        style: CatchTextStyles.supporting(context),
      );
    }
    return CatchAsyncValueView<HostProviderSetup>(
      value: setupValue,
      errorContext: AppErrorContext.event,
      onRetry: onRetry,
      builder: (context, setup) => _HostProviderSetupView(
        setup: setup,
        provider: provider,
        mutationPending: mutationPending,
        allowChanges: allowChanges,
        onConnect: onConnect,
        onSync: onSync,
        onDisconnect: onDisconnect,
        onImport: onImport,
      ),
    );
  }
}

class _HostProviderSetupView extends StatelessWidget {
  const _HostProviderSetupView({
    required this.setup,
    required this.provider,
    required this.mutationPending,
    required this.allowChanges,
    required this.onConnect,
    required this.onSync,
    required this.onDisconnect,
    required this.onImport,
  });

  final HostProviderSetup setup;
  final ExternalBookingProvider provider;
  final bool mutationPending;
  final bool allowChanges;
  final VoidCallback onConnect;
  final VoidCallback onSync;
  final VoidCallback onDisconnect;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final entry = setup.catalogFor(provider);
    if (entry == null) {
      return CatchErrorBanner(
        message: context.l10n.hostsOperationalRosterProviderUnavailable,
      );
    }
    final mapping = setup.mapping;
    final connection = setup.mappedConnection;
    if (provider == ExternalBookingProvider.luma &&
        mapping != null &&
        connection != null &&
        mapping.status == 'active') {
      final reconnectRequired =
          connection.status == 'credentialRevoked' ||
          connection.status == 'disconnected';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CatchBadge.functional(
              label: _providerConnectionStatus(context, connection.status),
              tone: connection.status == 'active'
                  ? CatchBadgeTone.success
                  : CatchBadgeTone.warning,
            ),
          ),
          gapH8,
          CatchFieldLanes.divided(
            children: [
              CatchField.read(
                title: context.l10n.hostsOperationalRosterProviderAccount,
                body: connection.externalAccountName,
                icon: CatchIcons.linkOutlined,
              ),
              CatchField.read(
                title: context.l10n.hostsOperationalRosterProviderCoverage,
                body: _providerCoverage(context, connection.capabilities),
                icon: CatchIcons.groupsOutlined,
              ),
              CatchField.read(
                title: context.l10n.hostsOperationalRosterProviderLastSync,
                body: mapping.lastSuccessfulSyncAt == null
                    ? context.l10n.hostsOperationalRosterProviderNeverSynced
                    : AppTimeFormatters.dateTime(
                        mapping.lastSuccessfulSyncAt!.toLocal(),
                      ),
                icon: CatchIcons.refresh,
              ),
              CatchField.read(
                title: context.l10n.hostsOperationalRosterProviderLimits,
                body: context.l10n.hostsOperationalRosterProviderLumaLimits,
                icon: CatchIcons.infoOutline,
              ),
            ],
          ),
          if (allowChanges) ...[
            gapH12,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                if (reconnectRequired)
                  CatchButton(
                    label: context.l10n.hostsOperationalRosterProviderReconnect,
                    onPressed: mutationPending ? null : onConnect,
                    isLoading: mutationPending,
                    size: CatchButtonSize.sm,
                    icon: Icon(CatchIcons.keyOutlined),
                  )
                else
                  CatchButton(
                    label: context.l10n.hostsOperationalRosterProviderSyncNow,
                    onPressed: mutationPending ? null : onSync,
                    isLoading: mutationPending,
                    size: CatchButtonSize.sm,
                    icon: Icon(CatchIcons.syncRounded),
                  ),
                CatchButton(
                  label: context.l10n.hostsOperationalRosterProviderDisconnect,
                  onPressed: mutationPending ? null : onDisconnect,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.ghost,
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CatchBadge.functional(
            label: _providerAvailability(context, entry.availability),
            tone: entry.availability == HostProviderAvailability.available
                ? CatchBadgeTone.brand
                : CatchBadgeTone.neutral,
          ),
        ),
        gapH8,
        Text(entry.requirement, style: CatchTextStyles.supporting(context)),
        if (entry.importSupport ==
            HostProviderImportSupport.sampleRequired) ...[
          gapH8,
          CatchErrorBanner(
            message: context.l10n.hostsOperationalRosterAdapterSampleRequired,
          ),
        ],
        if (allowChanges) ...[
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              if (provider == ExternalBookingProvider.luma &&
                  entry.availability == HostProviderAvailability.available)
                CatchButton(
                  label: context.l10n.hostsOperationalRosterProviderConnect,
                  onPressed: mutationPending ? null : onConnect,
                  isLoading: mutationPending,
                  size: CatchButtonSize.sm,
                  icon: Icon(CatchIcons.keyOutlined),
                ),
              if (entry.capabilities.fileImport)
                CatchButton(
                  label: context.l10n.hostsOperationalRosterProviderImport,
                  onPressed: mutationPending ? null : onImport,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.secondary,
                  icon: Icon(CatchIcons.cloudUploadOutlined),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LumaConnectionInput {
  const _LumaConnectionInput({
    required this.externalEventId,
    required this.apiKey,
  });

  final String externalEventId;
  final String apiKey;
}

class _HostLumaConnectionSheet extends StatefulWidget {
  const _HostLumaConnectionSheet({
    required this.organizerId,
    required this.eventId,
    required this.controller,
  });

  final String organizerId;
  final String eventId;
  final HostOperationalRosterController controller;

  @override
  State<_HostLumaConnectionSheet> createState() =>
      _HostLumaConnectionSheetState();
}

class _HostLumaConnectionSheetState extends State<_HostLumaConnectionSheet> {
  final _apiKeyController = TextEditingController();
  var _showErrors = false;
  var _loading = false;
  Object? _error;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = _apiKeyController.text.trim();
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsOperationalRosterProviderConnectTitle,
      subtitle: context.l10n.hostsOperationalRosterProviderConnectBody,
      keyboardSafe: true,
      action: CatchButton(
        label: context.l10n.hostsOperationalRosterProviderChooseEvent,
        onPressed: _loading ? null : _verifyAndChoose,
        isLoading: _loading,
        fullWidth: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchFieldLanes.single(
            child: CatchField.input(
              title: context.l10n.hostsOperationalRosterProviderApiKey,
              contract: CatchContractConstraints
                  .listOrganizerLumaEventsCallablePayloadApiKey,
              controller: _apiKeyController,
              obscureText: true,
              helperText: context.l10n.hostsOperationalRosterProviderApiKeyHelp,
              errorText: _showErrors && apiKey.length < 16
                  ? context.l10n.hostsOperationalRosterProviderFieldRequired
                  : null,
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_error case final error?) ...[
            gapH12,
            CatchErrorBanner.fromError(error, context: AppErrorContext.event),
          ],
        ],
      ),
    );
  }

  Future<void> _verifyAndChoose() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.length < 16) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final choices = await widget.controller.listLumaEvents(
        organizerId: widget.organizerId,
        eventId: widget.eventId,
        apiKey: apiKey,
      );
      if (!mounted) return;
      final choice = await showCatchBottomSheet<HostProviderEventChoice>(
        context: context,
        builder: (context) => _HostLumaEventChoiceSheet(choices: choices),
      );
      if (choice != null && mounted) {
        Navigator.of(context).pop(
          _LumaConnectionInput(
            externalEventId: choice.externalEventId,
            apiKey: apiKey,
          ),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _HostLumaEventChoiceSheet extends StatelessWidget {
  const _HostLumaEventChoiceSheet({required this.choices});

  final HostProviderEventChoices choices;

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsOperationalRosterProviderChooseEventTitle,
      subtitle: context.l10n.hostsOperationalRosterProviderChooseEventBody(
        calendar: choices.calendarName,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.58,
        ),
        child: choices.events.isEmpty
            ? CatchEmptyState(
                layout: CatchEmptyStateLayout.inline,
                icon: CatchIcons.calendarMonthOutlined,
                title: context.l10n.hostsOperationalRosterProviderNoEventsTitle,
                message:
                    context.l10n.hostsOperationalRosterProviderNoEventsBody,
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (choices.truncated) ...[
                      CatchErrorBanner(
                        message: context
                            .l10n
                            .hostsOperationalRosterProviderEventsTruncated,
                      ),
                      gapH12,
                    ],
                    CatchFieldLanes.single(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final indexed in choices.events.indexed) ...[
                            if (indexed.$1 > 0) const CatchDivider.fieldRow(),
                            CatchField.nav(
                              title: indexed.$2.name,
                              body: AppTimeFormatters.dateTime(
                                indexed.$2.startAt.toLocal(),
                              ),
                              onTap: () =>
                                  Navigator.of(context).pop(indexed.$2),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HostRosterHandoffSheet extends StatelessWidget {
  const _HostRosterHandoffSheet({
    required this.instructions,
    required this.onCopy,
  });

  final EventRosterHandoffInstructions instructions;
  final Future<void> Function(String value) onCopy;

  @override
  Widget build(BuildContext context) {
    final emailAlias = instructions.emailAlias;
    final whatsappNumber = instructions.whatsappNumber;
    final whatsappMessage = instructions.whatsappMessage;
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsOperationalRosterForwardTitle,
      subtitle: context.l10n.hostsOperationalRosterForwardSubtitle,
      glyph: CatchIcons.alternateEmailOutlined,
      action: CatchButton(
        label: context.l10n.hostsOperationalRosterForwardDone,
        onPressed: () => Navigator.of(context).pop(),
        fullWidth: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!instructions.hasAvailableChannel) ...[
            CatchErrorBanner(
              message: context.l10n.hostsOperationalRosterForwardProviderSetup,
            ),
            gapH12,
          ],
          CatchSection.fieldRows(
            children: [
              CatchField.read(
                title: context.l10n.hostsOperationalRosterForwardEmail,
                body:
                    emailAlias ??
                    context.l10n.hostsOperationalRosterForwardNotAvailable,
                icon: CatchIcons.emailOutlined,
                action: emailAlias == null
                    ? null
                    : CatchButton(
                        label: context.l10n.hostsOperationalRosterForwardCopy,
                        onPressed: () => unawaited(onCopy(emailAlias)),
                        size: CatchButtonSize.sm,
                        variant: CatchButtonVariant.ghost,
                      ),
              ),
              CatchField.read(
                title: context.l10n.hostsOperationalRosterForwardWhatsapp,
                body: whatsappNumber == null || whatsappMessage == null
                    ? context.l10n.hostsOperationalRosterForwardNotAvailable
                    : context.l10n.hostsOperationalRosterForwardWhatsappBody(
                        whatsappNumber: whatsappNumber,
                        whatsappMessage: whatsappMessage,
                      ),
                icon: CatchIcons.sendRounded,
                action: whatsappNumber == null || whatsappMessage == null
                    ? null
                    : CatchButton(
                        label: context.l10n.hostsOperationalRosterForwardCopy,
                        onPressed: () => unawaited(
                          onCopy('$whatsappNumber\n$whatsappMessage'),
                        ),
                        size: CatchButtonSize.sm,
                        variant: CatchButtonVariant.ghost,
                      ),
              ),
            ],
          ),
        ],
      ),
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
            isLoading: pending,
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
          )
        : CatchMenuAnchor<String>(
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
              isLoading: pending,
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
            isLoading: pending,
            variant: CatchButtonVariant.ghost,
            size: CatchButtonSize.sm,
          ),
        ],
      ],
    );
  }
}

class _HostRosterImportSelection {
  const _HostRosterImportSelection(this.rows);

  final List<EventAttendeeImportRow> rows;
}

Future<_HostRosterImportSelection?> _showRosterMapping(
  BuildContext context,
  HostRosterTable table,
) => showCatchBottomSheet<_HostRosterImportSelection>(
  context: context,
  builder: (context) => _HostRosterImportSheet(table: table),
);

class _HostRosterImportSheet extends StatefulWidget {
  const _HostRosterImportSheet({required this.table});

  final HostRosterTable table;

  @override
  State<_HostRosterImportSheet> createState() => _HostRosterImportSheetState();
}

class _HostRosterImportSheetState extends State<_HostRosterImportSheet> {
  late final Map<HostRosterField, int?> _mapping = {
    ...widget.table.suggestedMapping,
  };

  @override
  Widget build(BuildContext context) {
    final mapped = widget.table.mapRows(_mapping);
    final canImport =
        mapped.rows.isNotEmpty &&
        !mapped.issues.any(
          (issue) => issue.type == HostRosterRowIssueType.missingNameColumn,
        );
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsOperationalRosterImportTitle,
      subtitle: context.l10n.hostsOperationalRosterImportSubtitle,
      action: CatchButton(
        label: context.l10n.hostsOperationalRosterImportAction(
          count: mapped.rows.length,
        ),
        onPressed: canImport
            ? () => Navigator.of(
                context,
              ).pop(_HostRosterImportSelection(mapped.rows))
            : null,
        fullWidth: true,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.58,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchBadge.functional(
                label: widget.table.adapter.adapterId.label,
                tone:
                    widget.table.adapter.support ==
                        HostRosterAdapterSupport.sampleRequired
                    ? CatchBadgeTone.warning
                    : CatchBadgeTone.brand,
              ),
              if (widget.table.adapter.support ==
                  HostRosterAdapterSupport.sampleRequired) ...[
                gapH8,
                CatchErrorBanner(
                  message:
                      context.l10n.hostsOperationalRosterAdapterSampleRequired,
                ),
              ],
              gapH12,
              CatchFieldLanes.divided(
                children: [
                  for (final field in HostRosterField.values)
                    _RosterMappingField(
                      field: field,
                      headers: widget.table.headers,
                      value: _mapping[field],
                      onChanged: (value) => setState(() {
                        _mapping[field] = value;
                      }),
                    ),
                ],
              ),
              gapH12,
              CatchBadge(
                label: context.l10n.hostsOperationalRosterPreviewCount(
                  count: mapped.rows.length,
                ),
                tone: CatchBadgeTone.brand,
              ),
              if (mapped.truncatedCount > 0) ...[
                gapH8,
                CatchErrorBanner(
                  message: context.l10n.hostsOperationalRosterLimit(
                    count: mapped.truncatedCount,
                  ),
                ),
              ],
              for (final issue in mapped.issues.take(5)) ...[
                gapH8,
                CatchErrorBanner(message: _rowIssueCopy(context, issue)),
              ],
              if (mapped.rows.isNotEmpty) ...[
                gapH12,
                for (final row in mapped.rows.take(3).indexed)
                  CatchPersonRow(
                    data: CatchPersonRowData(
                      name: row.$2.displayName,
                      metaLine: [
                        row.$2.phone,
                        row.$2.email,
                      ].whereType<String>().join(' · '),
                    ),
                    divider: row.$1 > 0,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RosterMappingField extends StatelessWidget {
  const _RosterMappingField({
    required this.field,
    required this.headers,
    required this.value,
    required this.onChanged,
  });

  final HostRosterField field;
  final List<String> headers;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = value ?? -1;
    final options = [-1, ...List.generate(headers.length, (index) => index)];
    return CatchMenuAnchor<int>(
      items: [
        for (final option in options)
          CatchMenuItem<int>(
            value: option,
            label: option == -1
                ? context.l10n.hostsOperationalRosterDoNotImport
                : headers[option],
            selected: option == selectedValue,
          ),
      ],
      onSelected: (option, _) => onChanged(option == -1 ? null : option),
      builder: (context, controller, _) => CatchFieldLanes.single(
        child: CatchField.nav(
          title: _fieldCopy(context, field),
          valueText: selectedValue == -1
              ? context.l10n.hostsOperationalRosterDoNotImport
              : headers[selectedValue],
          onTap: controller.isOpen ? controller.close : controller.open,
        ),
      ),
    );
  }
}

class _HostManualAttendeeSheet extends StatefulWidget {
  const _HostManualAttendeeSheet();

  @override
  State<_HostManualAttendeeSheet> createState() =>
      _HostManualAttendeeSheetState();
}

class _HostManualAttendeeSheetState extends State<_HostManualAttendeeSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  var _showNameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsOperationalRosterManualTitle,
      subtitle: context.l10n.hostsOperationalRosterManualSubtitle,
      keyboardSafe: true,
      action: CatchButton(
        label: context.l10n.hostsOperationalRosterManualSave,
        onPressed: _submit,
        fullWidth: true,
      ),
      child: CatchFieldLanes.divided(
        children: [
          CatchField.input(
            title: context.l10n.hostsOperationalRosterFieldName,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsDisplayName,
            controller: _nameController,
            errorText: _showNameError
                ? context.l10n.hostsOperationalRosterManualNameRequired
                : null,
          ),
          CatchField.input(
            title: context.l10n.hostsOperationalRosterFieldPhone,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsPhone,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          CatchField.input(
            title: context.l10n.hostsOperationalRosterFieldEmail,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsEmail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }
    Navigator.of(context).pop(
      EventAttendeeImportRow(
        rowId: 'manual',
        displayName: name,
        phone: _nullableText(_phoneController.text),
        email: _nullableText(_emailController.text),
        status: EventAttendeeStatus.registered,
      ),
    );
  }
}

String? _nullableText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String _newImportKey() =>
    'host-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

String _newAttendanceOperationId(String attendeeId) =>
    'attendance_${attendeeId.hashCode.abs().toRadixString(36)}_'
    '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

String _newProviderSyncOperationId() =>
    'provider_sync_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

String _attendeeMeta(BuildContext context, EventAttendee attendee) => [
  _sourceCopy(context, attendee.source),
  attendee.phoneE164,
  attendee.email,
].whereType<String>().join(' · ');

String _sourceCopy(BuildContext context, EventAttendeeSource source) =>
    switch (source) {
      EventAttendeeSource.catchBooking =>
        context.l10n.hostsOperationalRosterSourceCatchBooking,
      EventAttendeeSource.hostImport =>
        context.l10n.hostsOperationalRosterSourceHostImport,
      EventAttendeeSource.hostManual =>
        context.l10n.hostsOperationalRosterSourceHostManual,
      EventAttendeeSource.webOtp =>
        context.l10n.hostsOperationalRosterSourceWebOtp,
      EventAttendeeSource.providerSync =>
        context.l10n.hostsOperationalRosterSourceProviderSync,
    };

String _providerDisplayName(
  BuildContext context,
  ExternalBookingProvider provider,
) => switch (provider) {
  ExternalBookingProvider.catchPlatform =>
    context.l10n.hostsEventDetailsStepExternalProviderCatch,
  ExternalBookingProvider.generic =>
    context.l10n.hostsEventDetailsStepExternalProviderOther,
  ExternalBookingProvider.luma =>
    context.l10n.hostsEventDetailsStepExternalProviderLuma,
  ExternalBookingProvider.eventbrite =>
    context.l10n.hostsEventDetailsStepExternalProviderEventbrite,
  ExternalBookingProvider.partiful =>
    context.l10n.hostsEventDetailsStepExternalProviderPartiful,
  ExternalBookingProvider.posh =>
    context.l10n.hostsEventDetailsStepExternalProviderPosh,
  ExternalBookingProvider.bookmyshow =>
    context.l10n.hostsEventDetailsStepExternalProviderBookMyShow,
  ExternalBookingProvider.district =>
    context.l10n.hostsEventDetailsStepExternalProviderDistrict,
  ExternalBookingProvider.sortmyscene =>
    context.l10n.hostsEventDetailsStepExternalProviderSortMyScene,
  ExternalBookingProvider.airbnb =>
    context.l10n.hostsEventDetailsStepExternalProviderAirbnbExperiences,
};

String _providerCoverage(
  BuildContext context,
  HostProviderCapabilities capabilities,
) {
  final values = <String>[
    if (capabilities.rosterIdentity)
      context.l10n.hostsOperationalRosterProviderCapabilityGuests,
    if (capabilities.registrationStatus)
      context.l10n.hostsOperationalRosterProviderCapabilityStatus,
    if (capabilities.providerCheckIn)
      context.l10n.hostsOperationalRosterProviderCapabilityCheckIn,
  ];
  return values.join(' · ');
}

String _providerAvailability(
  BuildContext context,
  HostProviderAvailability value,
) => switch (value) {
  HostProviderAvailability.available =>
    context.l10n.hostsOperationalRosterProviderAvailable,
  HostProviderAvailability.exportOnly =>
    context.l10n.hostsOperationalRosterProviderExportOnly,
  HostProviderAvailability.configurationRequired =>
    context.l10n.hostsOperationalRosterProviderConfigurationRequired,
  HostProviderAvailability.partnerAccessRequired =>
    context.l10n.hostsOperationalRosterProviderPartnerRequired,
  HostProviderAvailability.sampleRequired =>
    context.l10n.hostsOperationalRosterProviderSampleRequired,
  HostProviderAvailability.manualOnly =>
    context.l10n.hostsOperationalRosterProviderManualOnly,
};

String _providerConnectionStatus(BuildContext context, String value) =>
    switch (value) {
      'active' => context.l10n.hostsOperationalRosterProviderStatusActive,
      'degraded' => context.l10n.hostsOperationalRosterProviderStatusDegraded,
      'credentialRevoked' =>
        context.l10n.hostsOperationalRosterProviderStatusReconnect,
      _ => context.l10n.hostsOperationalRosterProviderStatusDisconnected,
    };

String _statusCopy(BuildContext context, EventAttendeeStatus status) =>
    switch (status) {
      EventAttendeeStatus.invited =>
        context.l10n.hostsOperationalRosterStatusInvited,
      EventAttendeeStatus.registered =>
        context.l10n.hostsOperationalRosterStatusRegistered,
      EventAttendeeStatus.waitlisted =>
        context.l10n.hostsOperationalRosterStatusWaitlisted,
      EventAttendeeStatus.checkedIn =>
        context.l10n.hostsOperationalRosterStatusCheckedIn,
      EventAttendeeStatus.cancelled =>
        context.l10n.hostsOperationalRosterStatusRegistered,
    };

String _fieldCopy(
  BuildContext context,
  HostRosterField field,
) => switch (field) {
  HostRosterField.displayName => context.l10n.hostsOperationalRosterFieldName,
  HostRosterField.phone => context.l10n.hostsOperationalRosterFieldPhone,
  HostRosterField.email => context.l10n.hostsOperationalRosterFieldEmail,
  HostRosterField.externalReference =>
    context.l10n.hostsOperationalRosterFieldReference,
  HostRosterField.arrivalGroup =>
    context.l10n.hostsOperationalRosterFieldArrivalGroup,
  HostRosterField.ticketType => context.l10n.hostsOperationalRosterFieldTicket,
  HostRosterField.status => context.l10n.hostsOperationalRosterFieldStatus,
};

String _importIssueCopy(BuildContext context, HostRosterImportIssue issue) =>
    switch (issue) {
      HostRosterImportIssue.unsupportedFile =>
        context.l10n.hostsOperationalRosterIssueUnsupported,
      HostRosterImportIssue.missingRows =>
        context.l10n.hostsOperationalRosterIssueMissingRows,
      HostRosterImportIssue.tooManyColumns =>
        context.l10n.hostsOperationalRosterIssueTooManyColumns,
      HostRosterImportIssue.malformedCsv =>
        context.l10n.hostsOperationalRosterIssueMalformedCsv,
      HostRosterImportIssue.unreadableXlsx ||
      HostRosterImportIssue.missingWorksheet =>
        context.l10n.hostsOperationalRosterIssueUnreadableXlsx,
    };

String _rowIssueCopy(BuildContext context, HostRosterRowIssue issue) =>
    switch (issue.type) {
      HostRosterRowIssueType.missingNameColumn =>
        context.l10n.hostsOperationalRosterIssueMissingNameColumn,
      HostRosterRowIssueType.missingName =>
        context.l10n.hostsOperationalRosterIssueMissingName(
          row: issue.rowNumber ?? 0,
        ),
    };
