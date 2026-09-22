import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/data/program_operations_outbox.dart';
import 'package:catch_dating_app/programs/data/program_snapshot_reader.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The greeter's live arrivals roster for one pickup station.
///
/// Rows are sorted by curb estimate — the moment a guest actually reaches
/// the exit, not when the wheels touch — and claims are exclusive so two
/// greeters never greet the same party. Mutations go through the offline
/// outbox: a claim taken in a dead zone is replayed with the same
/// `clientOperationId` so the server cannot double-apply it.
class ProgramArrivalsScreen extends ConsumerStatefulWidget {
  const ProgramArrivalsScreen({
    super.key,
    required this.programId,
    required this.pickupPointId,
    required this.stationLabel,
  });

  final String programId;
  final String? pickupPointId;
  final String stationLabel;

  @override
  ConsumerState<ProgramArrivalsScreen> createState() =>
      _ProgramArrivalsScreenState();
}

class _ProgramArrivalsScreenState extends ConsumerState<ProgramArrivalsScreen> {
  ProgramOperationOutboxSummary _outbox = const ProgramOperationOutboxSummary(
    [],
  );
  Object? _mutationError;
  bool _outboxBusy = false;

  @override
  void initState() {
    super.initState();
    _reloadOutbox();
  }

  Future<void> _reloadOutbox() async {
    final accountId = programWorkAccountId(
      ref,
      action: 'load pending program operations',
    );
    final summary = await ref
        .read(programOperationsOutboxProvider)
        .loadForProgram(accountId: accountId, programId: widget.programId);
    if (mounted) setState(() => _outbox = summary);
  }

  Future<void> _enqueueObservation(
    ArrivalsRosterRow row,
    String action, {
    String? manualCurbNote,
  }) async {
    final accountId = programWorkAccountId(
      ref,
      action: 'record an arrival observation',
    );
    final operationId =
        'arrival_${action}_${row.legId.hashCode.abs().toRadixString(36)}_'
        '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
    try {
      final summary = await ref
          .read(programOperationsOutboxProvider)
          .enqueueAndAttempt(
            accountId: accountId,
            offline: ref.read(isObviouslyOfflineProvider),
            entry: ProgramOperationOutboxEntry.legObservation(
              programId: widget.programId,
              legId: row.legId,
              action: action,
              clientOperationId: operationId,
              createdAt: DateTime.now(),
              expectedRevision: row.revision,
              manualCurbAtMillis:
                  action == 'markReady' || action == 'markDisrupted'
                  ? DateTime.now().millisecondsSinceEpoch
                  : null,
              manualCurbNote: manualCurbNote,
            ),
          );
      if (mounted) {
        setState(() {
          _outbox = summary;
          _mutationError = null;
        });
      }
      ref.invalidate(
        programArrivalsRosterProvider(widget.programId, widget.pickupPointId),
      );
    } on Object catch (error) {
      if (mounted) setState(() => _mutationError = error);
    }
  }

  Future<void> _clearOutboxReview() async {
    final accountId = programWorkAccountId(
      ref,
      action: 'clear stale program operations',
    );
    final summary = await ref
        .read(programOperationsOutboxProvider)
        .clearNeedsReview(accountId: accountId, programId: widget.programId);
    if (mounted) setState(() => _outbox = summary);
  }

  Future<void> _flushOutbox() async {
    if (_outboxBusy) return;
    setState(() => _outboxBusy = true);
    try {
      final accountId = programWorkAccountId(
        ref,
        action: 'sync pending program operations',
      );
      final summary = await ref
          .read(programOperationsOutboxProvider)
          .flushProgram(accountId: accountId, programId: widget.programId);
      if (mounted) setState(() => _outbox = summary);
      ref.invalidate(
        programArrivalsRosterProvider(widget.programId, widget.pickupPointId),
      );
    } on Object catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _outboxBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rosterAsync = ref.watch(
      programArrivalsRosterViewProvider(widget.programId, widget.pickupPointId),
    );
    return CatchAsyncBoundary<ProgramReadView<ProgramArrivalsRoster>>(
      value: rosterAsync,
      onRetry: () => ref.invalidate(
        programArrivalsRosterProvider(widget.programId, widget.pickupPointId),
      ),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: widget.stationLabel,
          subtitle: context.l10n.programsArrivalsTitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: const CatchRouteBody.standardViewport(
          child: CatchStateViewport.loading(accountForBottomOverlay: false),
        ),
      ),
      errorBuilder: (_, error, _, onBoundaryRetry) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: widget.stationLabel,
          subtitle: context.l10n.programsArrivalsTitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: CatchRouteBody.standardViewport(
          child: CatchLocalizedErrorState(
            error,
            context: AppErrorContext.event,
            onRetry: onBoundaryRetry,
          ),
        ),
      ),
      builder: (context, result) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: widget.stationLabel,
          subtitle: context.l10n.programsArrivalsTitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: CatchRouteBody.standardSections(
          sections: [
            if (result.snapshotAt != null)
              CatchSectionListItem(
                child: CatchBanner(
                  title: context.l10n.programsSnapshotTitle,
                  message: context.l10n.programsSnapshotBanner(
                    time: AppTimeFormatters.time(result.snapshotAt!),
                  ),
                  icon: CatchIcons.wifiOffRounded,
                  tone: CatchBannerTone.warning,
                ),
              ),
            ..._rosterSections(
              context,
              roster: result.value,
              outbox: _outbox,
              mutationError: _mutationError,
              outboxBusy: _outboxBusy,
              onFlushOutbox: _flushOutbox,
              onClearReview: _clearOutboxReview,
              onAction: _enqueueObservation,
            ),
          ],
        ),
      ),
    );
  }
}

List<CatchSectionListItem> _rosterSections(
  BuildContext context, {
  required ProgramArrivalsRoster roster,
  required ProgramOperationOutboxSummary outbox,
  required Object? mutationError,
  required bool outboxBusy,
  required VoidCallback onFlushOutbox,
  required VoidCallback onClearReview,
  required Future<void> Function(
    ArrivalsRosterRow row,
    String action, {
    String? manualCurbNote,
  })
  onAction,
}) {
  final attention = roster.rows
      .where((row) => row.needsAttention)
      .toList(growable: false);
  final ready =
      roster.rows
          .where(
            (row) =>
                !row.needsAttention &&
                row.readiness == TravelLegReadiness.ready,
          )
          .toList(growable: false)
        ..sort(
          (a, b) => (a.curbAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(b.curbAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
  final expected =
      roster.rows
          .where(
            (row) =>
                !row.needsAttention &&
                row.readiness == TravelLegReadiness.expected,
          )
          .toList(growable: false)
        ..sort(
          (a, b) => (a.curbAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(b.curbAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );

  return <CatchSectionListItem>[
    if (outbox.pendingCount + outbox.needsReviewCount > 0)
      CatchSectionListItem(
        child: ProgramArrivalsOutboxBanner(
          outbox: outbox,
          busy: outboxBusy,
          onFlush: onFlushOutbox,
          onClearReview: onClearReview,
        ),
      ),
    if (mutationError != null)
      CatchSectionListItem(
        child: CatchBanner.error(
          message: appErrorMessage(mutationError, l10n: context.l10n),
        ),
      ),
    if (attention.isNotEmpty)
      CatchSectionListItem(
        child: CatchSection.contained(
          title: context.l10n.programsArrivalsAttentionTitle,
          subtitle: context.l10n.programsArrivalsAttentionSubtitle,
          child: Column(
            children: [
              for (final row in attention)
                ProgramArrivalRow(
                  row: row,
                  queuedAction:
                      outbox.forLeg(row.legId)?.payload['action'] as String?,
                  onAction: onAction,
                ),
            ],
          ),
        ),
      ),
    CatchSectionListItem(
      child: CatchSection.contained(
        title: context.l10n.programsArrivalsReadyTitle,
        subtitle: context.l10n.programsArrivalsReadySubtitle,
        child: ready.isEmpty
            ? CatchEmptyState(
                icon: CatchIcons.flagBanner,
                message: context.l10n.programsArrivalsReadyEmpty,
                variant: CatchEmptyStateVariant.inline,
              )
            : Column(
                children: [
                  for (final row in ready)
                    ProgramArrivalRow(
                      row: row,
                      queuedAction:
                          outbox.forLeg(row.legId)?.payload['action']
                              as String?,
                      onAction: onAction,
                    ),
                ],
              ),
      ),
    ),
    CatchSectionListItem(
      child: CatchSection.contained(
        title: context.l10n.programsArrivalsExpectedTitle,
        subtitle: context.l10n.programsArrivalsExpectedSubtitle,
        child: expected.isEmpty
            ? CatchEmptyState(
                icon: CatchIcons.flightLanding,
                message: context.l10n.programsArrivalsExpectedEmpty,
                variant: CatchEmptyStateVariant.inline,
              )
            : Column(
                children: [
                  for (final row in expected)
                    ProgramArrivalRow(
                      row: row,
                      queuedAction:
                          outbox.forLeg(row.legId)?.payload['action']
                              as String?,
                      onAction: onAction,
                    ),
                ],
              ),
      ),
    ),
  ];
}

class ProgramArrivalsOutboxBanner extends StatelessWidget {
  const ProgramArrivalsOutboxBanner({
    super.key,
    required this.outbox,
    required this.busy,
    required this.onFlush,
    required this.onClearReview,
  });

  final ProgramOperationOutboxSummary outbox;
  final bool busy;
  final VoidCallback onFlush;
  final VoidCallback onClearReview;

  @override
  Widget build(BuildContext context) {
    final pending = outbox.pendingCount;
    final review = outbox.needsReviewCount;
    final message = review > 0
        ? context.l10n.programsArrivalsOutboxReview(
            pending: pending,
            review: review,
          )
        : context.l10n.programsArrivalsOutboxPending(count: pending);
    return CatchBanner(
      title: context.l10n.programsArrivalsOutboxTitle,
      message: message,
      icon: CatchIcons.wifiOffRounded,
      tone: review > 0 ? CatchBannerTone.danger : CatchBannerTone.warning,
      actions: [
        CatchButton(
          label: context.l10n.programsArrivalsOutboxSync,
          size: CatchButtonSize.sm,
          status: busy ? CatchButtonStatus.loading : CatchButtonStatus.idle,
          onPressed: onFlush,
        ),
        if (review > 0)
          CatchButton(
            label: context.l10n.programsArrivalsOutboxClear,
            size: CatchButtonSize.sm,
            variant: CatchButtonVariant.secondary,
            onPressed: onClearReview,
          ),
      ],
    );
  }
}

class ProgramArrivalRow extends StatelessWidget {
  const ProgramArrivalRow({
    super.key,
    required this.row,
    required this.queuedAction,
    required this.onAction,
  });

  final ArrivalsRosterRow row;
  final String? queuedAction;
  final Future<void> Function(
    ArrivalsRosterRow row,
    String action, {
    String? manualCurbNote,
  })
  onAction;

  @override
  Widget build(BuildContext context) {
    final claimed = row.claimedByDisplay != null;
    return CatchFieldRow.standard(
      leading: Icon(
        row.needsAttention
            ? CatchIcons.warningAmberRounded
            : row.readiness == TravelLegReadiness.ready
            ? CatchIcons.flagBanner
            : CatchIcons.flightLanding,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.partyTitle, style: Theme.of(context).textTheme.titleMedium),
          CatchMetaRow(icon: CatchIcons.group, label: _meta(context)),
          gapH4,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s1,
            children: [
              ProgramArrivalReadinessBadge(row: row),
              if (claimed)
                CatchBadge.functional(
                  label: row.claimedByMe
                      ? context.l10n.programsArrivalsClaimedByMe
                      : context.l10n.programsArrivalsClaimedBy(
                          name: row.claimedByDisplay!,
                        ),
                  tone: CatchBadgeTone.brand,
                ),
              if (queuedAction != null)
                CatchBadge(
                  label: context.l10n.programsArrivalsQueued,
                  tone: CatchBadgeTone.warning,
                  icon: CatchIcons.wifiOffRounded,
                ),
            ],
          ),
        ],
      ),
      trailing: ProgramArrivalActionMenu(
        row: row,
        queued: queuedAction != null,
        onAction: onAction,
      ),
    );
  }

  String _meta(BuildContext context) {
    final parts = <String>[
      '${row.passengers} pax',
      if (row.luggageUnits > 0) '${row.luggageUnits} bags',
      if (row.flightNumber != null) row.flightNumber!,
      if (row.originIata != null) 'from ${row.originIata}',
      if (row.arrivalTerminal != null) 'T${row.arrivalTerminal}',
      row.curbLabel(context),
      row.destinationLabel,
    ];
    return parts.join(' · ');
  }
}

extension on ArrivalsRosterRow {
  String curbLabel(BuildContext context) {
    if (curbAt != null) {
      final source = switch (curbSource) {
        CurbSource.ready => context.l10n.programsArrivalsCurbSourceReady,
        CurbSource.manual => context.l10n.programsArrivalsCurbSourceManual,
        CurbSource.actualLanding =>
          context.l10n.programsArrivalsCurbSourceLanded,
        CurbSource.estimatedLanding =>
          context.l10n.programsArrivalsCurbSourceEstimated,
        CurbSource.scheduledLanding =>
          context.l10n.programsArrivalsCurbSourceScheduled,
        null => '',
      };
      return '${AppTimeFormatters.time(curbAt!)} $source'.trim();
    }
    return switch (unavailableReason) {
      TimingUnavailableReason.cancelled =>
        context.l10n.programsArrivalsCancelled,
      TimingUnavailableReason.diverted => context.l10n.programsArrivalsDiverted,
      _ => context.l10n.programsArrivalsNoEstimate,
    };
  }
}

class ProgramArrivalReadinessBadge extends StatelessWidget {
  const ProgramArrivalReadinessBadge({super.key, required this.row});

  final ArrivalsRosterRow row;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (row.readiness) {
      TravelLegReadiness.ready => (
        context.l10n.programsArrivalsReadyBadge,
        CatchBadgeTone.success,
      ),
      TravelLegReadiness.expected => (
        context.l10n.programsArrivalsExpectedBadge,
        CatchBadgeTone.brand,
      ),
      TravelLegReadiness.disrupted => (
        context.l10n.programsArrivalsDisruptedBadge,
        CatchBadgeTone.danger,
      ),
      TravelLegReadiness.dispatched => (
        context.l10n.programsArrivalsDispatchedBadge,
        CatchBadgeTone.success,
      ),
      TravelLegReadiness.arrived => (
        context.l10n.programsArrivalsArrivedBadge,
        CatchBadgeTone.success,
      ),
    };
    return CatchBadge.functional(label: label, tone: tone);
  }
}

enum ProgramArrivalActionKind { claim, unclaim, ready, disrupted }

class ProgramArrivalActionMenu extends StatelessWidget {
  const ProgramArrivalActionMenu({
    super.key,
    required this.row,
    required this.queued,
    required this.onAction,
  });

  final ArrivalsRosterRow row;
  final bool queued;
  final Future<void> Function(
    ArrivalsRosterRow row,
    String action, {
    String? manualCurbNote,
  })
  onAction;

  @override
  Widget build(BuildContext context) {
    return CatchActionMenu<ProgramArrivalActionKind>(
      tooltip: context.l10n.programsArrivalsRowActions,
      enabled: !queued,
      items: [
        if (row.claimedByDisplay == null)
          CatchActionMenuItem(
            value: ProgramArrivalActionKind.claim,
            label: context.l10n.programsArrivalsClaimAction,
          ),
        if (row.claimedByMe)
          CatchActionMenuItem(
            value: ProgramArrivalActionKind.unclaim,
            label: context.l10n.programsArrivalsUnclaimAction,
          ),
        if (row.readiness == TravelLegReadiness.expected)
          CatchActionMenuItem(
            value: ProgramArrivalActionKind.ready,
            label: context.l10n.programsArrivalsReadyAction,
          ),
        if (row.readiness != TravelLegReadiness.disrupted &&
            row.readiness != TravelLegReadiness.arrived)
          CatchActionMenuItem(
            value: ProgramArrivalActionKind.disrupted,
            label: context.l10n.programsArrivalsDisruptedAction,
          ),
      ],
      onSelected: (action) {
        final name = switch (action) {
          ProgramArrivalActionKind.claim => 'claim',
          ProgramArrivalActionKind.unclaim => 'unclaim',
          ProgramArrivalActionKind.ready => 'markReady',
          ProgramArrivalActionKind.disrupted => 'markDisrupted',
        };
        onAction(row, name);
      },
    );
  }
}
