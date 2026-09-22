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

/// The dispatcher's desk for one pickup station: the deterministic batch
/// suggestions plus the dispatch sheet that captures plate, vendor and class
/// at the moment the vehicle departs — the act that generates the
/// reconciliation record.
class ProgramDispatchScreen extends ConsumerStatefulWidget {
  const ProgramDispatchScreen({
    super.key,
    required this.programId,
    required this.pickupPointId,
    required this.stationLabel,
  });

  final String programId;
  final String pickupPointId;
  final String stationLabel;

  @override
  ConsumerState<ProgramDispatchScreen> createState() =>
      _ProgramDispatchScreenState();
}

class _ProgramDispatchScreenState extends ConsumerState<ProgramDispatchScreen> {
  ProgramOperationOutboxSummary _outbox = const ProgramOperationOutboxSummary(
    [],
  );
  Object? _mutationError;

  @override
  void initState() {
    super.initState();
    _reloadOutbox();
  }

  Future<void> _reloadOutbox() async {
    final accountId = programWorkAccountId(
      ref,
      action: 'load pending dispatches',
    );
    final summary = await ref
        .read(programOperationsOutboxProvider)
        .loadForProgram(accountId: accountId, programId: widget.programId);
    if (mounted) setState(() => _outbox = summary);
  }

  Future<void> _openDispatchSheet(
    TransportGroupSuggestion group,
    ProgramTransportPlan plan,
  ) async {
    final access = await ref.read(
      programWorkAccessProvider(widget.programId).future,
    );
    if (!mounted) return;
    // Ready groups may hold for expected parties bound for the same
    // destination; the dispatcher, not the suggestion engine, makes that call.
    final holdCandidates = group.readiness == TransportGroupReadiness.ready
        ? plan.groups
              .where(
                (candidate) =>
                    candidate.readiness == TransportGroupReadiness.expected &&
                    _sameDestination(group, candidate),
              )
              .toList(growable: false)
        : const <TransportGroupSuggestion>[];
    await showCatchBottomSheet<void>(
      context: context,
      builder: (sheetContext) => ProgramDispatchSheet(
        programId: widget.programId,
        pickupPointId: widget.pickupPointId,
        organizerId: access.organizerId,
        group: group,
        holdCandidates: holdCandidates,
        vehicleClasses: access.vehicleClasses,
        onDispatched: (summary, error) {
          if (!mounted) return;
          setState(() {
            if (summary != null) _outbox = summary;
            _mutationError = error;
          });
          ref.invalidate(
            programTransportPlanProvider(
              widget.programId,
              widget.pickupPointId,
            ),
          );
          ref.invalidate(programTripListProvider(widget.programId));
        },
      ),
    );
    await _reloadOutbox();
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(
      programTransportPlanViewProvider(widget.programId, widget.pickupPointId),
    );
    return CatchAsyncBoundary<ProgramReadView<ProgramTransportPlan>>(
      value: planAsync,
      onRetry: () => ref.invalidate(
        programTransportPlanProvider(widget.programId, widget.pickupPointId),
      ),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: widget.stationLabel,
          subtitle: context.l10n.programsDispatchTitle,
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
          subtitle: context.l10n.programsDispatchTitle,
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
          subtitle: context.l10n.programsDispatchTitle,
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
            ..._planSections(
              context,
              plan: result.value,
              outbox: _outbox,
              mutationError: _mutationError,
              onDispatch: (group) => _openDispatchSheet(group, result.value),
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDestination(
    TransportGroupSuggestion a,
    TransportGroupSuggestion b,
  ) {
    if (a.destinationHotelId != null || b.destinationHotelId != null) {
      return a.destinationHotelId != null &&
          a.destinationHotelId == b.destinationHotelId;
    }
    return a.destinationLabel == b.destinationLabel;
  }
}

class ProgramDispatchGroupTile extends StatelessWidget {
  const ProgramDispatchGroupTile({
    super.key,
    required this.group,
    required this.onDispatch,
  });

  final TransportGroupSuggestion group;
  final VoidCallback onDispatch;

  @override
  Widget build(BuildContext context) {
    return CatchSurface.card(
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${AppTimeFormatters.time(group.earliestCurbAt)}'
                  ' – ${AppTimeFormatters.time(group.latestCurbAt)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              CatchBadge.functional(
                label: group.vehicleClassLabel,
                tone: CatchBadgeTone.brand,
              ),
            ],
          ),
          gapH8,
          CatchMetaRow(icon: CatchIcons.hotel, label: group.destinationLabel),
          CatchMetaRow(
            icon: CatchIcons.group,
            label: context.l10n.programsDispatchGroupMeta(
              passengers: group.passengers,
              luggage: group.luggageUnits,
              legs: group.legIds.length,
            ),
          ),
          if (group.dispatchBy != null)
            CatchMetaRow(
              icon: CatchIcons.clock,
              label: group.waitOverdue
                  ? context.l10n.programsDispatchWaitOverdue(
                      time: AppTimeFormatters.time(group.dispatchBy!),
                    )
                  : context.l10n.programsDispatchDispatchBy(
                      time: AppTimeFormatters.time(group.dispatchBy!),
                    ),
              color: group.waitOverdue
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          gapH12,
          CatchButton(
            label: context.l10n.programsDispatchAction,
            leading: Icon(CatchIcons.taxi),
            fullWidth: true,
            onPressed: onDispatch,
          ),
        ],
      ),
    );
  }
}

/// Plate capture + vendor + class override. The dispatch write is queued
/// through the operations outbox so a dead zone cannot lose a departure.
class ProgramDispatchSheet extends ConsumerStatefulWidget {
  const ProgramDispatchSheet({
    super.key,
    required this.programId,
    required this.pickupPointId,
    required this.organizerId,
    required this.group,
    required this.holdCandidates,
    required this.vehicleClasses,
    required this.onDispatched,
  });

  final String programId;
  final String pickupPointId;
  final String organizerId;
  final TransportGroupSuggestion group;

  /// Expected-readiness suggestions bound for the same destination; toggling
  /// one pins its legs into this dispatch so the vehicle waits for them.
  final List<TransportGroupSuggestion> holdCandidates;
  final List<ProgramVehicleClass> vehicleClasses;
  final void Function(ProgramOperationOutboxSummary? summary, Object? error)
  onDispatched;

  @override
  ConsumerState<ProgramDispatchSheet> createState() =>
      _ProgramDispatchSheetState();
}

class _ProgramDispatchSheetState extends ConsumerState<ProgramDispatchSheet> {
  final _plateController = TextEditingController();
  late String _vehicleClassId = widget.group.vehicleClassId;
  final Set<int> _heldCandidates = {};
  String? _vendorId;
  bool _busy = false;

  List<String> get _dispatchLegIds => [
    ...widget.group.legIds,
    for (final index in _heldCandidates) ...widget.holdCandidates[index].legIds,
  ];

  int get _passengers =>
      widget.group.passengers +
      _heldCandidates.fold(
        0,
        (sum, index) => sum + widget.holdCandidates[index].passengers,
      );

  int get _luggageUnits =>
      widget.group.luggageUnits +
      _heldCandidates.fold(
        0,
        (sum, index) => sum + widget.holdCandidates[index].luggageUnits,
      );

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<List<({String legId, int revision})>?> _legRevisionFences() async {
    try {
      final roster = await ref.read(
        programArrivalsRosterProvider(
          widget.programId,
          widget.pickupPointId,
        ).future,
      );
      final revisions = {
        for (final row in roster.rows) row.legId: row.revision,
      };
      return [
        for (final legId in _dispatchLegIds)
          if (revisions[legId] case final revision?)
            (legId: legId, revision: revision),
      ];
    } on Object {
      return null;
    }
  }

  Future<void> _dispatch() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final accountId = programWorkAccountId(
        ref,
        action: 'dispatch a program vehicle',
      );
      final operationId =
          'dispatch_${widget.pickupPointId.hashCode.abs().toRadixString(36)}_'
          '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
      final fences = await _legRevisionFences();
      final summary = await ref
          .read(programOperationsOutboxProvider)
          .enqueueAndAttempt(
            accountId: accountId,
            offline: ref.read(isObviouslyOfflineProvider),
            entry: ProgramOperationOutboxEntry.dispatch(
              programId: widget.programId,
              pickupPointId: widget.pickupPointId,
              vehicleClassId: _vehicleClassId,
              plateDisplay: _plateController.text.trim(),
              legIds: _dispatchLegIds,
              destinationHotelId: widget.group.destinationHotelId,
              destinationLabel: widget.group.destinationLabel,
              vendorId: _vendorId,
              expectedLegRevisions: fences,
              clientOperationId: operationId,
              createdAt: DateTime.now(),
            ),
          );
      widget.onDispatched(summary, null);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      widget.onDispatched(null, error);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(
      programTransportVendorsProvider(widget.organizerId, widget.programId),
    );
    final classes = [...widget.vehicleClasses]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final canDispatch = _plateController.text.trim().isNotEmpty && !_busy;
    return CatchSheet(
      title: context.l10n.programsDispatchSheetTitle,
      subtitle: context.l10n.programsDispatchSheetSubtitle(
        destination: widget.group.destinationLabel,
      ),
      glyph: CatchIcons.taxi,
      keyboardSafe: true,
      mode: CatchSheetMode.scrollable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchMetaRow(
            icon: CatchIcons.group,
            label: context.l10n.programsDispatchGroupMeta(
              passengers: _passengers,
              luggage: _luggageUnits,
              legs: _dispatchLegIds.length,
            ),
          ),
          if (widget.holdCandidates.isNotEmpty) ...[
            gapH16,
            Text(
              context.l10n.programsDispatchHoldTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            gapH4,
            Text(
              context.l10n.programsDispatchHoldSubtitle(
                destination: widget.group.destinationLabel,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            gapH8,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (
                  var index = 0;
                  index < widget.holdCandidates.length;
                  index += 1
                )
                  CatchChoiceButton<int>(
                    option: CatchOption(
                      value: index,
                      label: context.l10n.programsDispatchHoldOption(
                        time: AppTimeFormatters.time(
                          widget.holdCandidates[index].earliestCurbAt,
                        ),
                        passengers: widget.holdCandidates[index].passengers,
                      ),
                    ),
                    selected: _heldCandidates.contains(index),
                    onTap: () => setState(() {
                      if (!_heldCandidates.remove(index)) {
                        _heldCandidates.add(index);
                      }
                    }),
                  ),
              ],
            ),
          ],
          gapH16,
          CatchTextInput(
            controller: _plateController,
            decoration: InputDecoration(
              hintText: context.l10n.programsDispatchPlateHint,
            ),
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
          ),
          gapH16,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final entry in classes)
                CatchChoiceButton<ProgramVehicleClass>(
                  option: CatchOption(value: entry, label: entry.label),
                  selected: _vehicleClassId == entry.id,
                  onTap: () => setState(() => _vehicleClassId = entry.id),
                ),
            ],
          ),

          gapH16,
          vendorsAsync.when(
            data: (vendors) {
              final active = vendors
                  .where((vendor) => vendor.active && vendor.boundToProgram)
                  .toList(growable: false);
              if (active.isEmpty) {
                return CatchMetaRow(
                  icon: CatchIcons.businessOutlined,
                  label: context.l10n.programsDispatchNoVendors,
                );
              }
              return Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  for (final vendor in active)
                    CatchChoiceButton<ProgramVendorOption>(
                      option: CatchOption(value: vendor, label: vendor.name),
                      selected: _vendorId == vendor.vendorId,
                      onTap: () => setState(
                        () => _vendorId = _vendorId == vendor.vendorId
                            ? null
                            : vendor.vendorId,
                      ),
                    ),
                ],
              );
            },
            loading: CatchLoadingIndicator.new,
            error: (_, _) => CatchMetaRow(
              icon: CatchIcons.warningAmberRounded,
              label: context.l10n.programsDispatchVendorsUnavailable,
            ),
          ),
          gapH20,
          CatchButton(
            label: context.l10n.programsDispatchConfirm,
            leading: Icon(CatchIcons.taxi),
            fullWidth: true,
            status: _busy ? CatchButtonStatus.loading : CatchButtonStatus.idle,
            onPressed: canDispatch ? _dispatch : null,
          ),
        ],
      ),
    );
  }
}

List<CatchSectionListItem> _planSections(
  BuildContext context, {
  required ProgramTransportPlan plan,
  required ProgramOperationOutboxSummary outbox,
  required Object? mutationError,
  required void Function(TransportGroupSuggestion group) onDispatch,
}) {
  return [
    if (outbox.pendingCount > 0)
      CatchSectionListItem(
        child: CatchBanner(
          title: context.l10n.programsDispatchOutboxTitle,
          message: context.l10n.programsDispatchOutboxPending(
            count: outbox.pendingCount,
          ),
          icon: CatchIcons.wifiOffRounded,
          tone: CatchBannerTone.warning,
        ),
      ),
    if (mutationError != null)
      CatchSectionListItem(
        child: CatchBanner.error(
          message: appErrorMessage(mutationError, l10n: context.l10n),
        ),
      ),
    CatchSectionListItem(
      child: CatchSection.contained(
        title: context.l10n.programsDispatchGroupsTitle,
        subtitle: context.l10n.programsDispatchGroupsSubtitle,
        child: plan.groups.isEmpty
            ? CatchEmptyState(
                icon: CatchIcons.taxi,
                message: context.l10n.programsDispatchGroupsEmpty,
                variant: CatchEmptyStateVariant.inline,
              )
            : Column(
                children: [
                  for (final group in plan.groups) ...[
                    ProgramDispatchGroupTile(
                      group: group,
                      onDispatch: () => onDispatch(group),
                    ),
                    gapH8,
                  ],
                ],
              ),
      ),
    ),
    if (plan.unassigned.isNotEmpty)
      CatchSectionListItem(
        child: CatchSection.contained(
          title: context.l10n.programsDispatchUnassignedTitle,
          subtitle: context.l10n.programsDispatchUnassignedSubtitle,
          child: Column(
            children: [
              for (final item in plan.unassigned)
                CatchFieldRow.standard(
                  leading: Icon(CatchIcons.warningAmberRounded),
                  body: Text(
                    _unassignedReasonText(context, item.reason),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
  ];
}

String _unassignedReasonText(
  BuildContext context,
  TransportUnassignedReason reason,
) {
  return switch (reason) {
    TransportUnassignedReason.missingTime =>
      context.l10n.programsDispatchReasonMissingTime,
    TransportUnassignedReason.noSuitableVehicle =>
      context.l10n.programsDispatchReasonNoVehicle,
    TransportUnassignedReason.missingScope =>
      context.l10n.programsDispatchReasonMissingScope,
  };
}
