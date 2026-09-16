import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
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
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'host_event_rehearsal_coach_task.dart';

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
    final rehearsalState = catchAsyncStateFromAsyncValue(rehearsalAsync);
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
    listenToCatchMutationErrors(
      context,
      ref,
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
    );
    return CatchRouteScaffold(
      statuses: [
        if (rehearsalState.value case final rehearsal?)
          CatchBannerStatus(
            id: 'rehearsal.${rehearsal.session.id}',
            label: context.l10n.hostEventRehearsalBadge,
            message: context.l10n.hostEventRehearsalSyntheticGuests,
            icon: CatchIcons.groupsOutlined,
            color: CatchTokens.of(context).danger,
            actions: [
              CatchBannerAction(
                label: context.l10n.hostEventRehearsalClockPill(
                  time: DateFormat.jm(
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(rehearsal.session.virtualNow),
                ),
                onPressed: () => _showRunControls(rehearsal, busy),
              ),
              CatchBannerAction(
                label: context.l10n.hostEventRehearsalPracticeTools,
                icon: CatchIcons.more,
                onPressed: () => _showPracticeTools(rehearsal, busy),
              ),
            ],
          ),
      ],
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        size: CatchTopBarSize.compact,
        height: CatchTopBar.workspaceHeightFor(
          context: context,
          hasEyebrow: true,
          titleMaxLines: topBarTitleMaxLines,
        ),
        mode: CatchTopBarMode.content,
        contentCrossAxisAlignment: CrossAxisAlignment.start,
        eyebrow: context.l10n.hostEventRehearsalManageSubtitle,
        title:
            rehearsalState.value?.session.setup.title ??
            context.l10n.hostEventRehearsalTitle,
        titleMaxLines: topBarTitleMaxLines,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
        leading: CatchIconAction.toolbar(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: CatchIcons.arrowBackIosNewRounded,
          onPressed: () => _leaveRehearsal(rehearsalState.value?.session),
        ),
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
      ),
      body: CatchRouteBody.fullBleed(
        child: SafeArea(
          top: false,
          bottom: false,
          child: CatchAsyncBoundary<EventRehearsalBootstrap>(
            value: rehearsalAsync,
            onRetry: () =>
                ref.invalidate(eventRehearsalProvider(widget.sessionId)),
            initialLoadTimeout: null,
            loadingBuilder: (_) => const CatchStateViewport.loading(
              accountForBottomOverlay: false,
            ),
            errorBuilder: (_, error, _, onBoundaryRetry) => CatchPageBody(
              child: CatchLocalizedErrorState(
                error,
                context: AppErrorContext.event,
                onRetry: onBoundaryRetry,
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
                  Expanded(
                    child: EventSuccessHostWorkspacePageBody(
                      key: ValueKey(
                        'rehearsal-runtime-${rehearsal.session.id}',
                      ),
                      event: runtime.event,
                      plan: runtime.plan,
                      planIsPersisted: true,
                      spatialLayout: runtime.layout,
                      spatialLayoutState: EventSuccessSpatialLayoutState.ready(
                        runtime.layout,
                      ),
                      roster: runtime.roster,
                      assignments: runtime.assignments,
                      assignmentParticipantProfiles: runtime.profiles,
                      presenceSummary: runtime.presence,
                      initialTab: switch (rehearsal.session.status) {
                        EventRehearsalStatus.draft ||
                        EventRehearsalStatus.ready => EventSuccessHostTab.setup,
                        EventRehearsalStatus.running ||
                        EventRehearsalStatus.paused => EventSuccessHostTab.live,
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
        builder: (sheetContext) => CatchSheet(
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
    builder: (sheetContext) => CatchSheet(
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
        copy: catchDialogCopy(context.l10n),
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
      copy: catchDialogCopy(context.l10n),
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
      copy: catchDialogCopy(context.l10n),
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
      return CatchDockSurface(
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
          width: CatchIconAction.navSize,
          height: CatchIconAction.navSize,
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
    return CatchDockSurface(
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
