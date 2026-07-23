part of '../event_success_host_screen.dart';

class SetupTab extends StatefulWidget {
  const SetupTab({
    super.key,
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.actionState,
    required this.onSaveSetup,
    required this.embedded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventSuccessSetupActionState actionState;
  final Future<void> Function(EventSuccessSetupSaveRequest request)?
  onSaveSetup;
  final bool embedded;

  @override
  State<SetupTab> createState() => _SetupTabState();
}

class _SetupTabState extends State<SetupTab> {
  late EventSuccessHostDraft _draft = widget.plan.hostDraft.normalizeForFormat(
    widget.event.eventFormat,
  );
  late int _targetAttendeeCount = widget.plan.targetAttendeeCount;
  late String _attendeePromptText = widget.plan.attendeePrompt ?? '';
  bool _remotePlanChanged = false;

  @override
  void didUpdateWidget(covariant SetupTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) {
      if (_hasLocalChangesAgainst(oldWidget.plan)) {
        _remotePlanChanged = true;
      } else {
        _syncFromPlan(widget.plan);
      }
    }
  }

  void _syncFromPlan(EventSuccessPlan plan) {
    _draft = plan.hostDraft.normalizeForFormat(widget.event.eventFormat);
    _targetAttendeeCount = plan.targetAttendeeCount;
    _attendeePromptText = plan.attendeePrompt ?? '';
    _remotePlanChanged = false;
  }

  /// Draft as actually presented to the body and used on save: target-attendee
  /// override applied and structure normalized for that target.
  EventSuccessHostDraft get _resolvedDraft => _draft.copyWith(
    targetAttendeeCount: _targetAttendeeCount,
    structureConfig: _draft.structureConfig.normalizedForTarget(
      _targetAttendeeCount,
    ),
  );

  /// True when the in-memory draft differs from the saved plan. Only meaningful
  /// once the plan has been persisted — pre-persistence, the save button
  /// itself already communicates "you haven't saved yet."
  bool get _isDirty {
    if (!widget.planIsPersisted) return false;
    return _hasLocalChangesAgainst(widget.plan);
  }

  bool _hasLocalChangesAgainst(EventSuccessPlan plan) {
    final saved = plan.hostDraft.normalizeForFormat(widget.event.eventFormat);
    final resolved = _resolvedDraft;
    if (_targetAttendeeCount != plan.targetAttendeeCount) return true;
    if (_attendeePromptText.trim() != (plan.attendeePrompt ?? '').trim()) {
      return true;
    }
    if (resolved.playbook.id != saved.playbook.id) return true;
    if (resolved.hostGoal != saved.hostGoal) return true;
    if (resolved.compatibilityAffectsRanking !=
        saved.compatibilityAffectsRanking) {
      return true;
    }
    if (resolved.questionnaireConfig != saved.questionnaireConfig) return true;
    if (resolved.structureConfig != saved.structureConfig) return true;
    if (resolved.selectedModuleIds.length != saved.selectedModuleIds.length ||
        !resolved.selectedModuleIds.containsAll(saved.selectedModuleIds)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hasParticipantActivity =
        widget.event.signedUpCount > 0 ||
        widget.event.waitlistCount > 0 ||
        widget.event.attendedCount > 0;
    final eventHasStarted = !widget.event.startTime.isAfter(DateTime.now());
    final planFrozen =
        widget.plan.status != EventSuccessPlanStatus.setup ||
        widget.plan.frozenAt != null;
    final setupFrozen = hasParticipantActivity || eventHasStarted || planFrozen;
    final unsavedFrozen = !widget.planIsPersisted && setupFrozen;
    final profile = EventSuccessActivityProfile.forFormat(
      widget.event.eventFormat,
      targetAttendeeCount: _targetAttendeeCount,
    );
    final presentedDraft = _resolvedDraft;

    return EventSuccessHostTabBody(
      embedded: widget.embedded,
      children: [
        if (unsavedFrozen) ...[
          CatchSurface.message(
            messageIcon: CatchIcons.lockClockRounded,
            title: eventHasStarted
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostSetupTitleEventStartedWithoutA
                : context
                      .l10n
                      .eventSuccessEventSuccessHostSetupTitleLiveGuideCanNo,
            message: eventHasStarted
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostSetupBodyThisEventBeganBefore
                : context
                      .l10n
                      .eventSuccessEventSuccessHostSetupBodyBookingsHaveAlreadyStarted,
          ),
          gapH16,
        ] else if (!widget.planIsPersisted) ...[
          CatchSurface.message(
            messageIcon: CatchIcons.cloudUploadOutlined,
            title: context
                .l10n
                .eventSuccessEventSuccessHostSetupTitleSetupNotSavedYet,
            message: context
                .l10n
                .eventSuccessEventSuccessHostSetupBodyThisDefaultPlanIs,
          ),
          gapH16,
        ],
        if (setupFrozen && widget.planIsPersisted) ...[
          CatchSurface.message(
            messageIcon: CatchIcons.lockClockRounded,
            messageTone: CatchSurfaceMessageTone.warning,
            title: context
                .l10n
                .eventSuccessEventSuccessHostSetupTitleSettingsAreLocked,
            message: hasParticipantActivity
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostSetupBodyBookingsHaveStartedSo
                : context
                      .l10n
                      .eventSuccessEventSuccessHostSetupBodyTheEventHasStarted,
          ),
          gapH16,
        ],
        if (widget.actionState.hasError) ...[
          CatchErrorBanner.fromError(
            widget.actionState.error!,
            context: AppErrorContext.event,
          ),
          gapH16,
        ],
        if (_remotePlanChanged) ...[
          CatchSurface.message(
            title: context
                .l10n
                .eventSuccessEventSuccessHostSetupTitleSettingsAreLocked,
            message: context
                .l10n
                .eventSuccessEventSuccessHostSetupBodyThisDefaultPlanIs,
            messageIcon: CatchIcons.errorOutlineRounded,
            messageTone: CatchSurfaceMessageTone.warning,
          ),
          gapH16,
        ],
        if (setupFrozen)
          CatchSection.fieldRows(
            first: true,
            title: context.l10n.eventSuccessEventSuccessHostSetupTitleYourPlan,
            children: [
              HostActivitySummary(profile: profile, draft: presentedDraft),
              PlanSummary(
                plan: widget.plan,
                draft: presentedDraft,
                planIsPersisted: widget.planIsPersisted,
              ),
              if (presentedDraft.readinessIssues.isNotEmpty)
                ReadinessIssues(issues: presentedDraft.readinessIssues),
            ],
          )
        else
          EventSuccessSetupBody(
            draft: presentedDraft,
            eventFormat: widget.event.eventFormat,
            targetAttendeeCount: _targetAttendeeCount,
            attendeePrompt: _attendeePromptText,
            planLeadingRows: [
              PlanSummary(
                plan: widget.plan,
                draft: presentedDraft,
                planIsPersisted: widget.planIsPersisted,
              ),
              if (presentedDraft.readinessIssues.isNotEmpty)
                ReadinessIssues(issues: presentedDraft.readinessIssues),
              TargetAttendeeControl(
                value: _targetAttendeeCount,
                recommendedMin: _draft.playbook.capacity.min,
                recommendedMax: _draft.playbook.capacity.max,
                enabled: true,
                onChanged: (value) =>
                    setState(() => _targetAttendeeCount = value),
              ),
            ],
            onChanged: (update) {
              setState(() => _draft = update(_draft));
            },
            onAttendeePromptChanged: (value) {
              setState(() => _attendeePromptText = value);
            },
          ),
        if (_isDirty && !setupFrozen) ...[
          gapH16,
          CatchInlineStatus(
            label: context
                .l10n
                .eventSuccessEventSuccessHostSetupTextUnsavedChanges,
            tone: CatchInlineStatusTone.warning,
          ),
          gapH8,
        ],
        if (!setupFrozen) ...[
          gapH16,
          CatchButton(
            label: widget.planIsPersisted
                ? (_isDirty
                      ? context
                            .l10n
                            .eventSuccessEventSuccessHostSetupLabelSaveChanges
                      : context
                            .l10n
                            .eventSuccessEventSuccessHostSetupLabelSaveSetup)
                : context
                      .l10n
                      .eventSuccessEventSuccessHostSetupLabelSaveLiveGuide,
            isLoading: widget.actionState.isSaving,
            onPressed:
                widget.actionState.isSaving ||
                    _remotePlanChanged ||
                    widget.onSaveSetup == null
                ? null
                : () => unawaited(
                    widget.onSaveSetup!(
                      EventSuccessSetupSaveRequest(
                        event: widget.event,
                        plan: widget.plan,
                        planIsPersisted: widget.planIsPersisted,
                        draft: _resolvedDraft,
                        attendeePrompt: _attendeePromptText,
                      ),
                    ),
                  ),
            fullWidth: true,
          ),
        ],
      ],
    );
  }
}

class TargetAttendeeControl extends StatelessWidget {
  const TargetAttendeeControl({
    super.key,
    required this.value,
    required this.recommendedMin,
    required this.recommendedMax,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final int recommendedMin;
  final int recommendedMax;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return CatchField.stepper(
      title: context.l10n.eventSuccessEventSuccessHostSetupTextTargetAttendees,
      contract:
          CatchContractConstraints.eventSuccessPlanDocumentTargetAttendeeCount,
      body: context.l10n
          .eventSuccessEventSuccessHostSetupTextRecommendedRangeRecommendedminRecommendedmax(
            recommendedMin: recommendedMin,
            recommendedMax: recommendedMax,
          ),
      value: value,
      min: 1,
      max: 1000,
      formatter: (number) =>
          context.l10n.eventSuccessEventSuccessHostSetupVisiblecopyToint(
            toInt: number.toInt(),
          ),
      enabled: enabled,
      decreaseSemanticLabel: context
          .l10n
          .eventSuccessEventSuccessHostSetupVisiblecopyDecreaseTargetAttendees,
      increaseSemanticLabel: context
          .l10n
          .eventSuccessEventSuccessHostSetupVisiblecopyIncreaseTargetAttendees,
      onChanged: enabled ? (number) => onChanged(number.toInt()) : null,
    );
  }
}

class ReadinessIssues extends StatelessWidget {
  const ReadinessIssues({super.key, required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchField.content(
      title: context.l10n.eventSuccessEventSuccessHostSetupTitleBeforeLaunch,
      body: issues.join('\n'),
      bodyMaxLines: math.max(3, issues.length * 2),
      icon: CatchIcons.errorOutlineRounded,
      iconColor: t.warning,
    );
  }
}

EventRunOfShowStep? _activeRunOfShowStep(EventSuccessRuntime runtime) {
  final steps = runtime.runOfShowSteps;
  if (steps.isEmpty) return null;
  final index = runtime.plan.activeStepIndex;
  if (index <= 0) return steps.first;
  if (index >= steps.length) return steps.last;
  return steps[index];
}

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return CatchSurface.message(title: title, message: body, messageIcon: icon);
  }
}
