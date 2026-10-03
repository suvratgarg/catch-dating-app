import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/data/program_lodging_repository.dart';
import 'package:catch_dating_app/programs/domain/program_lodging_board.dart';
import 'package:catch_dating_app/programs/domain/program_lodging_setup.dart';
import 'package:catch_dating_app/programs/presentation/program_lodging_board.dart';
import 'package:catch_dating_app/programs/presentation/program_lodging_controller.dart';
import 'package:catch_dating_app/programs/presentation/program_lodging_setup_editor.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The private coordinator route. Hotel desks retain their separate scoped
/// operational board; this route never fetches private collections directly.
class ProgramLodgingScreen extends ConsumerStatefulWidget {
  const ProgramLodgingScreen({super.key, required this.programId});
  final String programId;

  @override
  ConsumerState<ProgramLodgingScreen> createState() =>
      _ProgramLodgingScreenState();
}

class _ProgramLodgingScreenState extends ConsumerState<ProgramLodgingScreen> {
  ProgramLodgingDraft? _editing;
  ProgramLodgingSetup? _editingSetup;

  ProgramLodgingController get _controller =>
      ref.read(programLodgingControllerProvider(widget.programId).notifier);

  Future<List<ProgramLodgingDestination>> _destinations(
    String proposalId,
    String partyId,
  ) => _controller.destinations(proposalId, partyId);
  Future<void> _move(String proposalId, String partyId, String inventoryId) =>
      _controller.move(proposalId, partyId, inventoryId);

  void _action(Future<void> Function() action) {
    unawaited(() async {
      try {
        await action();
      } catch (_) {
        // The controller owns the visible mutation error and exact retry.
      }
    }());
  }

  Future<void> _openSetup() async {
    final setup = await _controller.loadSetup();
    if (!mounted) return;
    final catalog = setup.catalog;
    if (catalog == null) {
      throw const FormatException('Setup catalog is absent.');
    }
    setState(() {
      _editingSetup = setup;
      _editing = ProgramLodgingDraft(
        catalog: catalog,
        configuration: setup.configuration,
      );
    });
  }

  Widget _scaffold(BuildContext context, Widget body) => CatchRouteScaffold(
    topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
      title: context.l10n.programsLodgingTitle,
      subtitle: context.l10n.programsLodgingSubtitle,
      emphasis: scrolledUnder
          ? CatchTopBarEmphasis.divided
          : CatchTopBarEmphasis.plain,
      navigation: const CatchTopBarNavigation(
        mode: CatchTopBarNavigationMode.back,
      ),
    ),
    body: CatchRouteBody.standardViewport(child: body),
  );

  @override
  Widget build(BuildContext context) => CatchAsyncBoundary<ProgramLodgingView>(
    retainDataOn: const {},
    value: ref.watch(programLodgingControllerProvider(widget.programId)),
    onRetry: () =>
        ref.invalidate(programLodgingControllerProvider(widget.programId)),
    loadingBuilder: (_) => _scaffold(
      context,
      const CatchStateViewport.loading(accountForBottomOverlay: false),
    ),
    errorBuilder: (_, error, _, retry) => _scaffold(
      context,
      CatchLocalizedErrorState(
        error,
        context: AppErrorContext.event,
        onRetry: retry,
      ),
    ),
    builder: (context, view) {
      if (_editing != null && !identical(view.setup, _editingSetup)) {
        // Account/authority rebuild or a new source read cannot retain a
        // private draft from the previous projection lifetime.
        _editing = null;
        _editingSetup = null;
      }
      final editing = _editing;
      if (editing != null) {
        return CatchRouteScaffold(
          topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
            title: context.l10n.programsLodgingSetup,
            subtitle: editing.catalog.timezone,
            navigation: const CatchTopBarNavigation(
              mode: CatchTopBarNavigationMode.back,
            ),
          ),
          body: CatchRouteBody.standardSections(
            sections: [
              CatchSectionListItem(
                child: ProgramLodgingSetupEditor(
                  key: ObjectKey(editing),
                  initial: editing,
                  busy: view.busy,
                  error: view.error,
                  resolveDates: (arrival, departure) =>
                      _controller.resolveDates(
                        editing.catalog.timezone,
                        arrival,
                        departure,
                      ),
                  onSave: (draft, adoptions) async {
                    await _controller.saveDraft(draft, adoptions: adoptions);
                    if (mounted) setState(() => _editing = null);
                  },
                  onCancel: () {
                    setState(() => _editing = null);
                    _controller.refresh();
                  },
                ),
              ),
            ],
          ),
        );
      }
      final review = view.review;
      if (review == null) {
        return _scaffold(
          context,
          Column(
            children: [
              CatchEmptyState(
                icon: CatchIcons.hotel,
                message: context.l10n.programsLodgingSetupMissing,
              ),
              if (view.error != null)
                CatchLocalizedErrorBanner(
                  view.error!,
                  context: AppErrorContext.event,
                ),
              CatchButton(
                label: context.l10n.programsLodgingSetup,
                onPressed: view.busy ? null : () => _action(_openSetup),
              ),
            ],
          ),
        );
      }
      final proposal = review.proposal;
      final approved = review.workflow['approvedProposalId'] == proposal.id;
      final published =
          review.workflow['guestPublishedProposalId'] == proposal.id;
      final retry = view.retryAction;
      return CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: context.l10n.programsLodgingTitle,
          subtitle: context.l10n.programsLodgingSubtitle,
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
                title: context.l10n.programsLodgingReview,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (view.error != null)
                      CatchLocalizedErrorBanner(
                        view.error!,
                        context: AppErrorContext.event,
                      ),
                    if (proposal.unplacedPartyIds.isNotEmpty)
                      Text(
                        context.l10n.programsLodgingUnplaced(
                          count: proposal.unplacedPartyIds.length,
                        ),
                      ),
                    if (!proposal.searchComplete)
                      Text(context.l10n.programsLodgingBoundedSearch),
                    for (final explanation in proposal.explanations)
                      Text(explanation),
                    CatchButton(
                      label: context.l10n.programsLodgingEditSetup,
                      variant: CatchButtonVariant.secondary,
                      onPressed: view.busy || retry != null
                          ? null
                          : () => _action(_openSetup),
                    ),
                    CatchButton(
                      label: context.l10n.programsLodgingRegenerate,
                      variant: CatchButtonVariant.secondary,
                      onPressed: view.busy || retry != null
                          ? null
                          : () => _action(_controller.regenerate),
                    ),
                    CatchButton(
                      label: context.l10n.programsLodgingApprove,
                      onPressed:
                          view.busy ||
                              proposal.unplacedPartyIds.isNotEmpty ||
                              (retry != null &&
                                  retry != ProgramLodgingAction.approve) ||
                              (retry == null && approved)
                          ? null
                          : () => _action(
                              () => _controller.decide(
                                ProgramLodgingAction.approve,
                              ),
                            ),
                    ),
                    CatchButton(
                      label: context.l10n.programsLodgingPublish,
                      onPressed:
                          view.busy ||
                              (retry != null &&
                                  retry !=
                                      ProgramLodgingAction.publishGuests) ||
                              (retry == null && (!approved || published))
                          ? null
                          : () => _action(
                              () => _controller.decide(
                                ProgramLodgingAction.publishGuests,
                              ),
                            ),
                    ),
                    CatchButton(
                      label: context.l10n.programsRoomsRefresh,
                      variant: CatchButtonVariant.ghost,
                      onPressed: view.busy || retry != null
                          ? null
                          : _controller.refresh,
                    ),
                  ],
                ),
              ),
            ),
            CatchSectionListItem(
              child: AbsorbPointer(
                absorbing: view.busy || retry != null,
                child: ProgramLodgingBoard(
                  proposalId: proposal.id,
                  units: review.units,
                  parties: review.parties,
                  // Bound method tear-offs stay equal across busy-state rebuilds,
                  // preserving the board's own pending-operation fence.
                  onPreview: _destinations,
                  onMove: _move,
                  copy: ProgramLodgingBoardCopy(
                    parties: context.l10n.programsLodgingParties,
                    rooms: context.l10n.programsRoomsTitle,
                    list: context.l10n.programsLodgingList,
                    map: context.l10n.programsLodgingMap,
                    move: context.l10n.programsLodgingMove,
                    locked: context.l10n.programsLodgingLocked,
                    provisional: context.l10n.programsLodgingProvisional,
                    empty: context.l10n.programsLodgingEmpty,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
