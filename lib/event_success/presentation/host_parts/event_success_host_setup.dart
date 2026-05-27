part of '../event_success_host_screen.dart';

class _SetupTab extends StatefulWidget {
  const _SetupTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.fixtureActions,
    required this.shrinkWrap,
    required this.physics,
    required this.padding,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventSuccessHostFixtureActions? fixtureActions;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry padding;

  @override
  State<_SetupTab> createState() => _SetupTabState();
}

class _SetupTabState extends State<_SetupTab> {
  late EventSuccessHostDraft _draft = widget.plan.hostDraft.normalizeForFormat(
    widget.event.eventFormat,
  );
  late int _targetAttendeeCount = widget.plan.targetAttendeeCount;
  late String _attendeePromptText = widget.plan.attendeePrompt ?? '';

  @override
  void didUpdateWidget(covariant _SetupTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) {
      _draft = widget.plan.hostDraft.normalizeForFormat(
        widget.event.eventFormat,
      );
      _targetAttendeeCount = widget.plan.targetAttendeeCount;
      _attendeePromptText = widget.plan.attendeePrompt ?? '';
    }
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
    final saved = widget.plan.hostDraft.normalizeForFormat(
      widget.event.eventFormat,
    );
    final resolved = _resolvedDraft;
    if (_targetAttendeeCount != widget.plan.targetAttendeeCount) return true;
    if (_attendeePromptText.trim() !=
        (widget.plan.attendeePrompt ?? '').trim()) {
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
    final t = CatchTokens.of(context);
    final hasParticipantActivity =
        widget.event.signedUpCount > 0 ||
        widget.event.waitlistCount > 0 ||
        widget.event.attendedCount > 0;
    final eventHasStarted = !widget.event.startTime.isAfter(DateTime.now());
    final setupFrozen = hasParticipantActivity || eventHasStarted;
    final unsavedFrozen = !widget.planIsPersisted && setupFrozen;

    return Consumer(
      builder: (context, ref, _) {
        final ensureMutation = ref.watch(
          EventSuccessController.ensurePlanMutation,
        );
        final saveMutation = ref.watch(
          EventSuccessController.saveSetupMutation,
        );
        final errorMutation = saveMutation.hasError
            ? saveMutation
            : ensureMutation;
        final profile = EventSuccessActivityProfile.forFormat(
          widget.event.eventFormat,
          targetAttendeeCount: _targetAttendeeCount,
        );
        final presentedDraft = _resolvedDraft;

        return ListView(
          shrinkWrap: widget.shrinkWrap,
          primary: widget.shrinkWrap ? false : null,
          physics: widget.physics,
          padding: widget.padding,
          children: [
            if (unsavedFrozen) ...[
              _NoticeCard(
                icon: CatchIcons.lockClockRounded,
                title: eventHasStarted
                    ? 'Event started without a saved guide'
                    : 'Live guide can no longer be saved',
                body: eventHasStarted
                    ? 'This event began before a live guide was saved. Attendance and check-in still work, but the Live tab won\'t have any guided controls for this event.'
                    : 'Bookings have already started. Attendance and check-in still work, but the Live tab won\'t have guided controls unless a guide was saved first.',
              ),
              gapH16,
            ] else if (!widget.planIsPersisted) ...[
              _NoticeCard(
                icon: CatchIcons.cloudUploadOutlined,
                title: 'Setup not saved yet',
                body:
                    'This default plan is visible here only. Save it so the Live tab is ready when the event starts.',
              ),
              gapH16,
            ],
            if (setupFrozen && widget.planIsPersisted) ...[
              _NoticeCard(
                icon: CatchIcons.lockClockRounded,
                title: 'Settings are locked',
                body: hasParticipantActivity
                    ? 'Bookings have started, so the saved guide is locked in. Switch to the Live tab to drive the event in real time once it starts.'
                    : 'The event has started — setup is locked. Use the Live tab to control the event right now, and the Report tab afterward.',
              ),
              gapH16,
            ],
            if (errorMutation.hasError) ...[
              _ErrorText(error: (errorMutation as MutationError).error),
              gapH16,
            ],
            CatchSurface(
              borderColor: t.line,
              padding: const EdgeInsets.all(CatchSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SetupSectionTitle(
                    title: 'Recommended setup',
                    subtitle:
                        'Review the essentials first. Format controls and advanced timing stay available below.',
                  ),
                  gapH12,
                  _HostActivitySummary(profile: profile, draft: presentedDraft),
                  gapH16,
                  _PlanSummary(
                    plan: widget.plan,
                    draft: presentedDraft,
                    planIsPersisted: widget.planIsPersisted,
                  ),
                  if (presentedDraft.readinessIssues.isNotEmpty) ...[
                    gapH12,
                    _ReadinessIssues(issues: presentedDraft.readinessIssues),
                  ],
                  gapH16,
                  _TargetAttendeeControl(
                    value: _targetAttendeeCount,
                    recommendedMin: _draft.playbook.capacity.min,
                    recommendedMax: _draft.playbook.capacity.max,
                    enabled: !setupFrozen,
                    onChanged: (value) =>
                        setState(() => _targetAttendeeCount = value),
                  ),
                  gapH16,
                  EventSuccessSetupBody(
                    draft: presentedDraft,
                    eventFormat: widget.event.eventFormat,
                    targetAttendeeCount: _targetAttendeeCount,
                    attendeePrompt: _attendeePromptText,
                    editable: !setupFrozen,
                    onDraftChanged: (nextDraft) {
                      setState(() => _draft = nextDraft);
                    },
                    onAttendeePromptChanged: (value) {
                      setState(() => _attendeePromptText = value);
                    },
                  ),
                ],
              ),
            ),
            gapH16,
            if (_isDirty && !setupFrozen) ...[_UnsavedChangesPill(), gapH8],
            CatchButton(
              label: !widget.planIsPersisted && setupFrozen
                  ? 'Save unavailable'
                  : widget.planIsPersisted
                  ? (_isDirty ? 'Save changes' : 'Save setup')
                  : 'Save live guide',
              isLoading:
                  widget.fixtureActions?.onSaveSetup == null &&
                  (saveMutation.isPending || ensureMutation.isPending),
              onPressed:
                  widget.fixtureActions?.onSaveSetup ??
                  (saveMutation.isPending ||
                          ensureMutation.isPending ||
                          setupFrozen
                      ? null
                      : () => EventSuccessController.saveSetupMutation.run(
                          ref,
                          (tx) async {
                            final basePlan = widget.planIsPersisted
                                ? widget.plan
                                : await tx
                                      .get(
                                        eventSuccessControllerProvider.notifier,
                                      )
                                      .ensurePlan(widget.event);
                            await tx
                                .get(eventSuccessControllerProvider.notifier)
                                .saveSetup(
                                  plan: basePlan,
                                  draft: _resolvedDraft,
                                  attendeePrompt: _attendeePromptText,
                                );
                          },
                        )),
              fullWidth: true,
            ),
          ],
        );
      },
    );
  }
}

class _TargetAttendeeControl extends StatelessWidget {
  const _TargetAttendeeControl({
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
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target attendees',
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH2,
                Text(
                  'Recommended range: $recommendedMin-$recommendedMax',
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: CatchNumberStepper(
              value: value,
              min: 1,
              max: 1000,
              formatValue: (number) => '${number.toInt()}',
              enabled: enabled,
              decreaseTooltip: 'Decrease target attendees',
              increaseTooltip: 'Increase target attendees',
              onChanged: (number) => onChanged(number.toInt()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessIssues extends StatelessWidget {
  const _ReadinessIssues({required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.warning.withValues(alpha: 0.32),
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Before launch', style: CatchTextStyles.sectionTitle(context)),
          gapH6,
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.only(bottom: CatchSpacing.s1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CatchIcons.errorOutlineRounded,
                    color: t.warning,
                    size: 16,
                  ),
                  gapW6,
                  Expanded(
                    child: Text(
                      issue,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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

class _SetupSectionTitle extends StatelessWidget {
  const _SetupSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CatchTextStyles.titleL(context)),
        gapH4,
        Text(
          subtitle,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ],
    );
  }
}

class _UnsavedChangesPill extends StatelessWidget {
  const _UnsavedChangesPill();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CatchIcons.fiberManualRecord, size: 8, color: t.warning),
        gapW6,
        Text(
          'Unsaved changes',
          style: CatchTextStyles.supporting(context, color: t.warning),
        ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.sectionTitle(context)),
                gapH4,
                Text(
                  body,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Text(
      appErrorMessage(error, context: AppErrorContext.event),
      style: CatchTextStyles.supporting(
        context,
        color: CatchTokens.of(context).danger,
      ),
    );
  }
}
