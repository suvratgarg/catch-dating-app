import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_trip_actions_controller.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The trip ledger: every dispatch as a reconciliation record — plate,
/// vendor, class, manifest and outcome. Voided trips keep their row so the
/// vendor invoice can be checked line by line.
class ProgramTripsScreen extends ConsumerWidget {
  const ProgramTripsScreen({super.key, required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(programTripListProvider(programId));
    return CatchAsyncBoundary<ProgramTripList>(
      retainDataOn: const {},
      value: tripsAsync,
      onRetry: () => ref.invalidate(programTripListProvider(programId)),
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsTripsTitle,
          subtitle: context.l10n.programsTripsSubtitle,
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
          title: context.l10n.programsTripsTitle,
          subtitle: context.l10n.programsTripsSubtitle,
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
      builder: (context, list) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsTripsTitle,
          subtitle: context.l10n.programsTripsSubtitle,
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
        ),
        body: CatchRouteBody.standardSections(
          sections: [
            CatchSectionListItem(
              child: CatchSection.contained(
                title: context.l10n.programsTripsLedgerTitle,
                subtitle: context.l10n.programsTripsLedgerSubtitle,
                child: list.trips.isEmpty
                    ? CatchEmptyState(
                        icon: CatchIcons.receiptLongOutlined,
                        message: context.l10n.programsTripsEmpty,
                        variant: CatchEmptyStateVariant.inline,
                      )
                    : Column(
                        children: [
                          for (final trip in list.trips) ...[
                            ProgramTripLedgerRow(
                              trip: trip,
                              programId: programId,
                            ),
                            gapH8,
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgramTripLedgerRow extends ConsumerStatefulWidget {
  const ProgramTripLedgerRow({
    super.key,
    required this.trip,
    required this.programId,
  });

  final ProgramTripSummary trip;
  final String programId;

  @override
  ConsumerState<ProgramTripLedgerRow> createState() =>
      _ProgramTripLedgerRowState();
}

class _ProgramTripLedgerRowState extends ConsumerState<ProgramTripLedgerRow> {
  bool _busy = false;
  Object? _error;

  Future<void> _voidTrip() async {
    final reason = await showCatchBottomSheet<String>(
      context: context,
      builder: (context) => const ProgramTripVoidSheet(),
    );
    if (reason == null || reason.isEmpty || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(programTripActionsProvider.notifier)
          .voidTrip(
            programId: widget.programId,
            tripId: widget.trip.tripId,
            expectedRevision: widget.trip.revision,
            reason: reason,
            clientOperationId:
                'void_${widget.trip.tripId.hashCode.abs().toRadixString(36)}_'
                '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
          );
      if (!mounted) return;
      ref.invalidate(programTripListProvider(widget.programId));
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return CatchSurface.card(
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.plateDisplay,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              CatchBadge.functional(
                label: _statusLabel(context, trip.status),
                tone: _statusTone(trip.status),
              ),
            ],
          ),
          gapH8,
          CatchMetaRow(icon: CatchIcons.hotel, label: trip.destinationLabel),
          CatchMetaRow(
            icon: CatchIcons.group,
            label: context.l10n.programsTripsRowMeta(
              passengers: trip.passengerCount,
              names: trip.guestNames.join(', '),
            ),
          ),
          CatchMetaRow(
            icon: CatchIcons.clock,
            label: trip.arrivedAt != null
                ? context.l10n.programsTripsRowTimingArrived(
                    departed: AppTimeFormatters.time(trip.departedAt),
                    arrived: AppTimeFormatters.time(trip.arrivedAt!),
                  )
                : context.l10n.programsTripsRowTimingDeparted(
                    departed: AppTimeFormatters.time(trip.departedAt),
                  ),
          ),
          if (trip.vendorName != null)
            CatchMetaRow(
              icon: CatchIcons.businessOutlined,
              label: trip.vendorName!,
            ),
          if (trip.voidReason != null)
            CatchMetaRow(
              icon: CatchIcons.warningAmberRounded,
              label: trip.voidReason!,
            ),
          if (_error != null) ...[
            gapH8,
            CatchBanner.error(
              message: appErrorMessage(_error!, l10n: context.l10n),
            ),
          ],
          if (trip.status == TransportTripStatus.enRoute) ...[
            gapH12,
            CatchButton.command(
              label: context.l10n.programsTripsVoidAction,
              leading: Icon(CatchIcons.blockOutlined),
              onPressed: _busy ? null : _voidTrip,
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, TransportTripStatus status) {
    return switch (status) {
      TransportTripStatus.enRoute => context.l10n.programsTripsStatusEnRoute,
      TransportTripStatus.arrived => context.l10n.programsTripsStatusArrived,
      TransportTripStatus.cancelled =>
        context.l10n.programsTripsStatusCancelled,
      TransportTripStatus.voided => context.l10n.programsTripsStatusVoided,
    };
  }

  CatchBadgeTone _statusTone(TransportTripStatus status) {
    return switch (status) {
      TransportTripStatus.enRoute => CatchBadgeTone.brand,
      TransportTripStatus.arrived => CatchBadgeTone.success,
      TransportTripStatus.cancelled => CatchBadgeTone.warning,
      TransportTripStatus.voided => CatchBadgeTone.danger,
    };
  }
}

class ProgramTripVoidSheet extends StatefulWidget {
  const ProgramTripVoidSheet({super.key});

  @override
  State<ProgramTripVoidSheet> createState() => _ProgramTripVoidSheetState();
}

class _ProgramTripVoidSheetState extends State<ProgramTripVoidSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchSheet(
      title: context.l10n.programsTripsVoidSheetTitle,
      subtitle: context.l10n.programsTripsVoidSheetSubtitle,
      glyph: CatchIcons.warningAmberRounded,
      keyboardSafe: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchTextInput(
            controller: _controller,
            decoration: InputDecoration(
              hintText: context.l10n.programsTripsVoidReasonHint,
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
          ),
          gapH20,
          CatchButton(
            label: context.l10n.programsTripsVoidConfirm,
            fullWidth: true,
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(_controller.text.trim()),
          ),
        ],
      ),
    );
  }
}
