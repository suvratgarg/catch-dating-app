import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_rehearsal/data/event_rehearsal_repository.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_controller.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_runtime_adapter.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_link_and_run.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_setup_section.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_simulator.dart';
import 'package:catch_dating_app/event_success/event_success.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HostEventRehearsalScreen extends ConsumerStatefulWidget {
  const HostEventRehearsalScreen({
    super.key,
    required this.clubId,
    required this.sessionId,
  });

  final String clubId;
  final String sessionId;

  @override
  ConsumerState<HostEventRehearsalScreen> createState() =>
      _HostEventRehearsalScreenState();
}

class _HostEventRehearsalScreenState
    extends ConsumerState<HostEventRehearsalScreen> {
  var _coachCollapsed = false;
  var _coachTextScaleInitialized = false;
  String? _lastCoachTaskKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_coachTextScaleInitialized) return;
    _coachTextScaleInitialized = true;
    if (MediaQuery.textScalerOf(context).scale(1) >= 1.4) {
      _coachCollapsed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rehearsalAsync = ref.watch(eventRehearsalProvider(widget.sessionId));
    final setupMutation = ref.watch(EventRehearsalController.setupMutation);
    final controlMutation = ref.watch(EventRehearsalController.controlMutation);
    final behaviorMutation = ref.watch(
      EventRehearsalController.behaviorMutation,
    );
    final spatialMutation = ref.watch(EventRehearsalController.spatialMutation);
    final resetMutation = ref.watch(EventRehearsalController.resetMutation);
    final forkMutation = ref.watch(EventRehearsalController.forkMutation);
    final guestLinkMutation = ref.watch(
      EventRehearsalController.guestLinkMutation,
    );
    final exportMutation = ref.watch(EventRehearsalController.exportMutation);
    final shareMutation = ref.watch(EventRehearsalController.shareMutation);
    final busy =
        setupMutation.isPending ||
        controlMutation.isPending ||
        behaviorMutation.isPending ||
        spatialMutation.isPending ||
        resetMutation.isPending ||
        forkMutation.isPending ||
        guestLinkMutation.isPending ||
        exportMutation.isPending ||
        shareMutation.isPending;
    final topBarTitleMaxLines = MediaQuery.textScalerOf(context).scale(1) >= 1.4
        ? 3
        : 1;
    return CatchMutationErrorListeners(
      mutations: [
        EventRehearsalController.setupMutation,
        EventRehearsalController.controlMutation,
        EventRehearsalController.behaviorMutation,
        EventRehearsalController.spatialMutation,
        EventRehearsalController.resetMutation,
        EventRehearsalController.forkMutation,
        EventRehearsalController.guestLinkMutation,
        EventRehearsalController.exportMutation,
        EventRehearsalController.shareMutation,
      ],
      errorContext: AppErrorContext.event,
      child: CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          large: false,
          height: CatchTopBar.workspaceHeightFor(
            context: context,
            hasEyebrow: true,
            titleMaxLines: topBarTitleMaxLines,
          ),
          allowContentHeightExpansion: true,
          contentCrossAxisAlignment: CrossAxisAlignment.start,
          eyebrow: context.l10n.hostEventRehearsalManageSubtitle,
          title:
              rehearsalAsync.asData?.value.session.setup.title ??
              context.l10n.hostEventRehearsalTitle,
          titleMaxLines: topBarTitleMaxLines,
          leadingType: CatchTopBarLeading.back,
          leading: CatchIconAction(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: CatchIcons.arrowBackIosNewRounded,
            onPressed: () =>
                _leaveRehearsal(rehearsalAsync.asData?.value.session),
          ),
          divider: scrolledUnder,
        ),
        body: CatchRouteBody.fullBleed(
          child: SafeArea(
            top: false,
            bottom: false,
            child: CatchAsyncValueView<EventRehearsalBootstrap>(
              value: rehearsalAsync,
              onRetry: () =>
                  ref.invalidate(eventRehearsalProvider(widget.sessionId)),
              initialLoadTimeout: null,
              loadingBuilder: (_) =>
                  const CatchPageBody(child: CatchSkeletonRows(count: 9)),
              errorBuilder: (_, error, _) => CatchPageBody(
                child: CatchErrorState.fromError(
                  error,
                  context: AppErrorContext.event,
                  onRetry: () =>
                      ref.invalidate(eventRehearsalProvider(widget.sessionId)),
                ),
              ),
              builder: (context, rehearsal) {
                final runtime = buildEventRehearsalRuntimeProjection(
                  rehearsal,
                  practiceGuestLabel:
                      context.l10n.hostEventRehearsalPracticeGuest,
                  latePracticeGuestLabel:
                      context.l10n.hostEventRehearsalLatePracticeGuest,
                );
                final coachTask = _buildCoachTask(context, rehearsal);
                _syncCoachTask(coachTask);
                return Column(
                  children: [
                    _RehearsalBand(
                      session: rehearsal.session,
                      onOpenClock: () => _showRunControls(rehearsal, busy),
                      onOpenTools: () => _showPracticeTools(rehearsal, busy),
                    ),
                    Expanded(
                      child: EventSuccessHostPanel(
                        key: ValueKey(
                          'rehearsal-runtime-${rehearsal.session.id}',
                        ),
                        event: runtime.event,
                        plan: runtime.plan,
                        planIsPersisted: true,
                        spatialLayout: runtime.layout,
                        spatialLayoutState:
                            EventSuccessSpatialLayoutState.ready(
                              runtime.layout,
                            ),
                        roster: runtime.roster,
                        assignments: runtime.assignments,
                        assignmentParticipantProfiles: runtime.profiles,
                        presenceSummary: runtime.presence,
                        initialTab: switch (rehearsal.session.status) {
                          EventRehearsalStatus.draft ||
                          EventRehearsalStatus.ready =>
                            EventSuccessHostTab.setup,
                          EventRehearsalStatus.running ||
                          EventRehearsalStatus.paused =>
                            EventSuccessHostTab.live,
                          EventRehearsalStatus.complete ||
                          EventRehearsalStatus.expired =>
                            EventSuccessHostTab.report,
                        },
                        showTabs: false,
                        compactLiveControls: true,
                        initialLiveWorkspace: coachTask.workspace,
                        initialSpatialSelectionUid: coachTask.actorId,
                        referenceNow: rehearsal.session.virtualNow,
                        exclusionReferenceNow: rehearsal.session.virtualNow,
                        liveActionState: EventSuccessLiveActionState(
                          isChangingStep: controlMutation.isPending,
                          isCompleting: controlMutation.isPending,
                        ),
                        onOpenGuests: () => _showPracticeTools(rehearsal, busy),
                        onSetLiveStep: (stepIndex) =>
                            _setCanonicalLiveStep(rehearsal.session, stepIndex),
                        onCompleteLiveGuide: (_) => _control(
                          rehearsal.session,
                          EventRehearsalControlAction.complete,
                          null,
                        ),
                        onResolveLateArrival: (actorId) => _injectBehavior(
                          rehearsal.session,
                          actorId,
                          EventRehearsalBehavior.arrive,
                        ),
                        onPreviewSpatial: (assignment) =>
                            _previewSpatial(runtime, rehearsal, assignment),
                        onReassignSpatial: (assignment, unitId, scope) =>
                            _controlSpatial(
                              rehearsal.session,
                              assignment.uid,
                              EventRehearsalSpatialAction.reassign,
                              destinationUnitId: unitId,
                              scope: _rehearsalSpatialScope(scope),
                            ),
                        onConfirmSpatial: (assignment) => _controlSpatial(
                          rehearsal.session,
                          assignment.uid,
                          EventRehearsalSpatialAction.confirmPosition,
                        ),
                        onReleaseSpatial: (assignment) => _controlSpatial(
                          rehearsal.session,
                          assignment.uid,
                          EventRehearsalSpatialAction.releasePinned,
                        ),
                      ),
                    ),
                    _RehearsalCoachDock(
                      task: coachTask,
                      collapsed: _coachCollapsed,
                      onWhy: () => _showCoachWhy(rehearsal),
                      onToggle: () =>
                          setState(() => _coachCollapsed = !_coachCollapsed),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _syncCoachTask(_RehearsalCoachTask task) {
    if (_lastCoachTaskKey == task.key) return;
    final previousTaskKey = _lastCoachTaskKey;
    _lastCoachTaskKey = task.key;
    if (previousTaskKey == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_coachCollapsed) {
        setState(() => _coachCollapsed = true);
      }
    });
  }

  Future<void> _setCanonicalLiveStep(
    EventRehearsalSession session,
    int stepIndex,
  ) async {
    if (stepIndex == session.activeStepIndex) return;
    await _control(
      session,
      stepIndex > session.activeStepIndex
          ? EventRehearsalControlAction.advance
          : EventRehearsalControlAction.previous,
      null,
    );
  }

  Future<void> _showRunControls(EventRehearsalBootstrap rehearsal, bool busy) =>
      showCatchBottomSheet<void>(
        context: context,
        builder: (sheetContext) => CatchBottomSheetScaffold(
          title: context.l10n.hostEventRehearsalRunTitle,
          subtitle: context.l10n.hostEventRehearsalRunSheetBody,
          badge: context.l10n.hostEventRehearsalBadge,
          badgeTone: CatchBadgeTone.danger,
          child: EventRehearsalRunSection(
            session: rehearsal.session,
            isLoading: busy,
            onControl: (action, minutes) =>
                _control(rehearsal.session, action, minutes),
          ),
        ),
      );

  Future<void> _showPracticeTools(
    EventRehearsalBootstrap rehearsal,
    bool busy,
  ) => showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => CatchBottomSheetScaffold(
      title: context.l10n.hostEventRehearsalPracticeTools,
      subtitle: context.l10n.hostEventRehearsalPracticeToolsBody,
      glyph: CatchIcons.scienceOutlined,
      child: SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.72,
        child: ListView(
          children: [
            EventRehearsalSetupSection(
              session: rehearsal.session,
              isLoading: busy,
              onSave: (setup, scenario, actorCount) =>
                  _saveSetup(rehearsal.session, setup, scenario, actorCount),
            ),
            gapH20,
            EventRehearsalGuestLinkSection(
              guestUrl: rehearsal.guestUrl,
              isLoading: busy,
              onCopy: () => _copyGuestLink(rehearsal.guestUrl),
              onShare: () => _shareGuestLink(rehearsal.guestUrl),
              onRotate: _rotateGuestLink,
            ),
            gapH20,
            EventRehearsalRunSection(
              session: rehearsal.session,
              isLoading: busy,
              onControl: (action, minutes) =>
                  _control(rehearsal.session, action, minutes),
            ),
            gapH20,
            EventRehearsalSimulator(
              rehearsal: rehearsal,
              isLoading: busy,
              onBehavior: (actorId, behavior) =>
                  _injectBehavior(rehearsal.session, actorId, behavior),
              onFault: (fault) => _injectFault(rehearsal.session, fault),
            ),
            gapH20,
            EventRehearsalRosterSection(rehearsal: rehearsal),
            gapH20,
            EventRehearsalRecapSection(
              rehearsal: rehearsal,
              isLoading: busy,
              onReset: _reset,
              onFork: _fork,
              onExport: _export,
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _showCoachWhy(EventRehearsalBootstrap rehearsal) async {
    await showCatchAdaptiveDialog<void>(
      context: context,
      title: context.l10n.hostEventRehearsalCoachWhyTitle,
      message: context.l10n.hostEventRehearsalCoachWhyBody,
      actions: [
        CatchDialogAction(
          label: context.l10n.hostEventRehearsalCoachGotIt,
          value: null,
          isDefault: true,
        ),
      ],
    );
  }

  Future<void> _leaveRehearsal(EventRehearsalSession? session) async {
    if (session?.hasStarted == true) {
      final confirmed = await showCatchConfirmDialog(
        context: context,
        title: context.l10n.hostEventRehearsalLeaveTitle,
        message: context.l10n.hostEventRehearsalLeaveBody,
        confirmLabel: context.l10n.hostEventRehearsalLeaveAction,
      );
      if (confirmed != true || !mounted) return;
    }
    if (mounted) await Navigator.of(context).maybePop();
  }

  Future<void> _saveSetup(
    EventRehearsalSession session,
    EventRehearsalSetup setup,
    EventRehearsalScenario scenario,
    int actorCount,
  ) async {
    try {
      await EventRehearsalController.setupMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .updateSetup(
              session: session,
              setup: setup,
              scenario: scenario,
              actorCount: actorCount,
            ),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _control(
    EventRehearsalSession session,
    EventRehearsalControlAction action,
    int? minutes,
  ) async {
    try {
      await EventRehearsalController.controlMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .control(session: session, action: action, minutes: minutes),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _injectBehavior(
    EventRehearsalSession session,
    String actorId,
    EventRehearsalBehavior behavior,
  ) async {
    try {
      await EventRehearsalController.behaviorMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .inject(
              session: session,
              actorId: actorId,
              behavior: behavior,
              fault: session.fault,
            ),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _injectFault(
    EventRehearsalSession session,
    EventRehearsalFault fault,
  ) async {
    try {
      await EventRehearsalController.behaviorMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .inject(session: session, fault: fault),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<List<EventSuccessSpatialDestination>> _previewSpatial(
    EventRehearsalRuntimeProjection runtime,
    EventRehearsalBootstrap rehearsal,
    EventSuccessAssignment assignment,
  ) async {
    final actor = rehearsal.actors
        .where((candidate) => candidate.actorId == assignment.uid)
        .firstOrNull;
    final assignmentsByUnit = <String, List<EventSuccessAssignment>>{};
    for (final candidate in runtime.assignments) {
      final unitId = candidate.layoutUnitId;
      if (unitId == null || candidate.uid == assignment.uid) continue;
      assignmentsByUnit.putIfAbsent(unitId, () => []).add(candidate);
    }
    return [
      for (final unit in runtime.layout.units)
        if (unit.id != assignment.layoutUnitId)
          () {
            final occupants = assignmentsByUnit[unit.id] ?? const [];
            final full = occupants.length >= unit.capacity;
            final conflicts =
                actor != null &&
                occupants.any(
                  (occupant) => actor.keepApartActorIds.contains(occupant.uid),
                );
            return EventSuccessSpatialDestination(
              unitId: unit.id,
              valid: !full && !conflicts,
              reason: full
                  ? EventSuccessSpatialDestinationReason.capacity
                  : conflicts
                  ? EventSuccessSpatialDestinationReason.safetyKeepApart
                  : null,
              recommendedScope: actor?.status == EventRehearsalActorStatus.late
                  ? EventSuccessSpatialScope.thisRound
                  : EventSuccessSpatialScope.pinned,
            );
          }(),
    ];
  }

  Future<void> _controlSpatial(
    EventRehearsalSession session,
    String actorId,
    EventRehearsalSpatialAction action, {
    String? destinationUnitId,
    EventRehearsalSpatialScope? scope,
  }) async {
    try {
      await EventRehearsalController.spatialMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .controlSpatial(
              session: session,
              actorId: actorId,
              action: action,
              destinationUnitId: destinationUnitId,
              scope: scope,
            ),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _copyGuestLink(String guestUrl) async {
    try {
      await EventRehearsalController.shareMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .copyGuestLink(guestUrl),
      );
      if (mounted) {
        showCatchSnackBar(context, context.l10n.hostEventRehearsalLinkCopied);
      }
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _shareGuestLink(String guestUrl) async {
    try {
      await EventRehearsalController.shareMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .shareGuestLink(guestUrl),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _rotateGuestLink() async {
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostEventRehearsalRotateLink,
      message: context.l10n.hostEventRehearsalRotateLinkBody,
      confirmLabel: context.l10n.hostEventRehearsalRotateLink,
    );
    if (confirmed != true || !mounted) return;
    try {
      await EventRehearsalController.guestLinkMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .rotateGuestLink(widget.sessionId),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _reset() async {
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostEventRehearsalReset,
      message: context.l10n.hostEventRehearsalResetBody,
      confirmLabel: context.l10n.hostEventRehearsalReset,
    );
    if (confirmed != true || !mounted) return;
    try {
      await EventRehearsalController.resetMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .reset(widget.sessionId),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _fork() async {
    try {
      final created = await EventRehearsalController.forkMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .fork(widget.sessionId),
      );
      if (!mounted) return;
      context.goNamed(
        Routes.hostEventRehearsalScreen.name,
        pathParameters: {
          'clubId': widget.clubId,
          'sessionId': created.sessionId,
        },
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _export() async {
    try {
      await EventRehearsalController.exportMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .exportReproduction(widget.sessionId),
      );
      if (mounted) {
        showCatchSnackBar(
          context,
          context.l10n.hostEventRehearsalReproductionCopied,
        );
      }
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }
}

class _RehearsalBand extends StatelessWidget {
  const _RehearsalBand({
    required this.session,
    required this.onOpenClock,
    required this.onOpenTools,
  });

  final EventRehearsalSession session;
  final VoidCallback onOpenClock;
  final VoidCallback onOpenTools;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final formatter = DateFormat.jm(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final clock = CatchButton(
      label: context.l10n.hostEventRehearsalClockPill(
        time: formatter.format(session.virtualNow),
      ),
      size: CatchButtonSize.sm,
      accentColor: t.danger,
      fullWidth: largeText,
      onPressed: onOpenClock,
    );
    final tools = CatchIconButton.icon(
      icon: CatchIcons.more,
      variant: CatchIconButtonVariant.plain,
      size: CatchIconButton.navSize,
      tooltip: context.l10n.hostEventRehearsalPracticeTools,
      onTap: onOpenTools,
    );
    final identity = Row(
      children: [
        Icon(CatchIcons.groupsOutlined, size: CatchIcon.md, color: t.danger),
        gapW8,
        Expanded(
          child: Text(
            context.l10n.hostEventRehearsalBadge.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.kicker(context, color: t.danger),
          ),
        ),
      ],
    );
    final descriptor = Text(
      context.l10n.hostEventRehearsalSyntheticGuests,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.labelS(context, color: t.ink2),
    );
    final bandContent = largeText
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: identity),
                  tools,
                ],
              ),
              gapH4,
              descriptor,
              gapH8,
              clock,
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [identity, gapH2, descriptor],
                ),
              ),
              gapW8,
              clock,
              gapW4,
              tools,
            ],
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.danger.withValues(alpha: CatchOpacity.tabBarPillFill),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: t.danger.withValues(alpha: CatchOpacity.lightOverlayBorder),
          ),
        ),
      ),
      child: Padding(padding: CatchInsets.controlContent, child: bandContent),
    );
  }
}

class _RehearsalCoachDock extends StatelessWidget {
  const _RehearsalCoachDock({
    required this.task,
    required this.collapsed,
    required this.onWhy,
    required this.onToggle,
  });

  final _RehearsalCoachTask task;
  final bool collapsed;
  final VoidCallback onWhy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    if (collapsed) {
      final coachIdentity = Row(
        children: [
          Icon(CatchIcons.scienceOutlined, color: t.danger),
          gapW8,
          Expanded(
            child: Text(
              context.l10n.hostEventRehearsalCoachCollapsed,
              style: CatchTextStyles.labelM(context),
            ),
          ),
        ],
      );
      final showCoach = CatchButton(
        label: context.l10n.hostEventRehearsalCoachShow,
        size: CatchButtonSize.sm,
        variant: CatchButtonVariant.secondary,
        fullWidth: largeText,
        onPressed: onToggle,
      );
      return CatchBottomDock(
        padding: CatchInsets.rosterRowContent,
        child: largeText
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [coachIdentity, gapH8, showCoach],
              )
            : Row(
                children: [
                  Expanded(child: coachIdentity),
                  showCoach,
                ],
              ),
      );
    }

    final taskCopy = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSurface(
          width: CatchIconButton.navSize,
          height: CatchIconButton.navSize,
          radius: CatchRadius.sm,
          backgroundColor: t.danger,
          child: Icon(CatchIcons.scienceOutlined, color: t.primaryInk),
        ),
        gapW12,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.hostEventRehearsalCoachProgress(
                  current: task.number,
                  total: 8,
                ),
                style: CatchTextStyles.kicker(context, color: t.danger),
              ),
              gapH4,
              Text(
                task.title,
                maxLines: largeText ? null : 2,
                overflow: largeText ? null : TextOverflow.ellipsis,
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH2,
              Text(
                task.body,
                maxLines: largeText ? null : 1,
                overflow: largeText ? null : TextOverflow.ellipsis,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
    final actions = Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      alignment: WrapAlignment.end,
      children: [
        CatchButton(
          label: context.l10n.hostEventRehearsalCoachWhy,
          size: CatchButtonSize.sm,
          variant: CatchButtonVariant.secondary,
          onPressed: onWhy,
        ),
        CatchButton(
          label: context.l10n.hostEventRehearsalCoachGotIt,
          size: CatchButtonSize.sm,
          onPressed: onToggle,
        ),
      ],
    );
    return CatchBottomDock(
      padding: largeText ? CatchInsets.content : CatchInsets.rosterRowContent,
      child: largeText
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [taskCopy, gapH10, actions],
            )
          : Row(
              children: [
                Expanded(child: taskCopy),
                gapW8,
                actions,
              ],
            ),
    );
  }
}

class _RehearsalCoachTask {
  const _RehearsalCoachTask({
    required this.key,
    required this.number,
    required this.title,
    required this.body,
    required this.workspace,
    this.actorId,
  });

  final String key;
  final int number;
  final String title;
  final String body;
  final EventSuccessLiveWorkspace workspace;
  final String? actorId;
}

_RehearsalCoachTask _buildCoachTask(
  BuildContext context,
  EventRehearsalBootstrap rehearsal,
) {
  final late = rehearsal.actors
      .where((actor) => actor.status == EventRehearsalActorStatus.late)
      .firstOrNull;
  if (late != null) {
    return _RehearsalCoachTask(
      key: 'late:${late.actorId}',
      number: 3,
      title: context.l10n.hostEventRehearsalCoachResolveLate(
        name: _coachFirstName(late.displayName),
      ),
      body: context.l10n.hostEventRehearsalCoachSameControl,
      workspace: EventSuccessLiveWorkspace.now,
      actorId: late.actorId,
    );
  }
  final help = rehearsal.actors
      .where((actor) => actor.helpRequested)
      .firstOrNull;
  if (help != null) {
    return _RehearsalCoachTask(
      key: 'help:${help.actorId}',
      number: 5,
      title: context.l10n.hostEventRehearsalCoachResolveHelp(
        name: _coachFirstName(help.displayName),
      ),
      body: context.l10n.hostEventRehearsalCoachSameControl,
      workspace: EventSuccessLiveWorkspace.now,
      actorId: help.actorId,
    );
  }
  final placement = rehearsal.actors
      .where(
        (actor) =>
            (actor.status == EventRehearsalActorStatus.present ||
                actor.status == EventRehearsalActorStatus.returned) &&
            actor.layoutUnitId != null &&
            actor.confirmedLayoutUnitId != actor.layoutUnitId,
      )
      .firstOrNull;
  if (placement != null) {
    return _RehearsalCoachTask(
      key: 'place:${placement.actorId}:${placement.layoutUnitId}',
      number: 4,
      title: context.l10n.hostEventRehearsalCoachPlaceGuest(
        name: _coachFirstName(placement.displayName),
      ),
      body: context.l10n.hostEventRehearsalCoachPlaceGuestBody,
      workspace: EventSuccessLiveWorkspace.room,
      actorId: placement.actorId,
    );
  }
  return switch (rehearsal.session.status) {
    EventRehearsalStatus.draft ||
    EventRehearsalStatus.ready => _RehearsalCoachTask(
      key: 'start',
      number: 1,
      title: context.l10n.hostEventRehearsalCoachStart,
      body: context.l10n.hostEventRehearsalCoachStartBody,
      workspace: EventSuccessLiveWorkspace.now,
    ),
    EventRehearsalStatus.paused => _RehearsalCoachTask(
      key: 'resume:${rehearsal.session.activeStepIndex}',
      number: (rehearsal.session.activeStepIndex + 2).clamp(1, 8),
      title: context.l10n.hostEventRehearsalCoachResume,
      body: context.l10n.hostEventRehearsalCoachSameControl,
      workspace: EventSuccessLiveWorkspace.now,
    ),
    EventRehearsalStatus.complete ||
    EventRehearsalStatus.expired => _RehearsalCoachTask(
      key: 'complete',
      number: 8,
      title: context.l10n.hostEventRehearsalCoachComplete,
      body: context.l10n.hostEventRehearsalCoachCompleteBody,
      workspace: EventSuccessLiveWorkspace.now,
    ),
    EventRehearsalStatus.running => _RehearsalCoachTask(
      key: 'advance:${rehearsal.session.activeStepIndex}',
      number: (rehearsal.session.activeStepIndex + 2).clamp(1, 8),
      title: context.l10n.hostEventRehearsalCoachAdvance,
      body: context.l10n.hostEventRehearsalCoachSameControl,
      workspace: EventSuccessLiveWorkspace.now,
    ),
  };
}

String _coachFirstName(String displayName) {
  final trimmed = displayName.trim();
  if (trimmed.isEmpty) return displayName;
  return trimmed.split(RegExp(r'\s+')).first;
}

EventRehearsalSpatialScope _rehearsalSpatialScope(
  EventSuccessSpatialScope scope,
) => switch (scope) {
  EventSuccessSpatialScope.thisRound => EventRehearsalSpatialScope.thisRound,
  EventSuccessSpatialScope.pinned => EventRehearsalSpatialScope.pinned,
};
