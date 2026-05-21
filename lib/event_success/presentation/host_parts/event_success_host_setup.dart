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
  late EventSuccessHostDraft _draft = widget.plan.hostDraft
      .normalizeForActivity(widget.event.activityKind);
  late int _targetAttendeeCount = widget.plan.targetAttendeeCount;
  late final TextEditingController _hostGoalController = TextEditingController(
    text: widget.plan.hostGoal,
  );
  late final TextEditingController _attendeePromptController =
      TextEditingController(text: widget.plan.attendeePrompt ?? '');

  @override
  void didUpdateWidget(covariant _SetupTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) {
      _draft = widget.plan.hostDraft.normalizeForActivity(
        widget.event.activityKind,
      );
      _targetAttendeeCount = widget.plan.targetAttendeeCount;
      _hostGoalController.text = widget.plan.hostGoal;
      _attendeePromptController.text = widget.plan.attendeePrompt ?? '';
    }
  }

  @override
  void dispose() {
    _hostGoalController.dispose();
    _attendeePromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasParticipantActivity =
        widget.event.signedUpCount > 0 ||
        widget.event.waitlistCount > 0 ||
        widget.event.attendedCount > 0;
    final setupFrozen =
        hasParticipantActivity ||
        !widget.event.startTime.isAfter(DateTime.now());

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
        final profile = EventSuccessActivityProfile.forActivity(
          widget.event.activityKind,
          targetAttendeeCount: _targetAttendeeCount,
        );

        return ListView(
          shrinkWrap: widget.shrinkWrap,
          primary: widget.shrinkWrap ? false : null,
          physics: widget.physics,
          padding: widget.padding,
          children: [
            if (!widget.planIsPersisted) ...[
              _NoticeCard(
                icon: Icons.cloud_upload_outlined,
                title: 'Setup is not saved yet',
                body:
                    'This default plan is visible here only. Save it to make the live guide available for this event.',
              ),
              gapH16,
            ],
            if (setupFrozen) ...[
              _NoticeCard(
                icon: Icons.lock_clock_rounded,
                title: 'Setup is frozen',
                body: hasParticipantActivity
                    ? 'Live guide setup is locked once someone books or joins the waitlist. Live controls and the report remain available.'
                    : 'Live guide setup is locked once the event starts. Live controls and the report remain available.',
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
                  _HostActivitySummary(profile: profile, draft: _resolvedDraft),
                  gapH16,
                  _PlanSummary(plan: widget.plan, draft: _resolvedDraft),
                  if (_resolvedDraft.readinessIssues.isNotEmpty) ...[
                    gapH12,
                    _ReadinessIssues(issues: _resolvedDraft.readinessIssues),
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
                  CatchTextField(
                    label: 'Host goal',
                    controller: _hostGoalController,
                    enabled: !setupFrozen,
                    hintText: 'Help attendees meet at least two new people.',
                    inputFormatters: [LengthLimitingTextInputFormatter(300)],
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                  ),
                  gapH12,
                  CatchTextField(
                    label: 'Attendee prompt',
                    controller: _attendeePromptController,
                    enabled: !setupFrozen,
                    hintText: widget.plan.attendeePromptFor(widget.event),
                    inputFormatters: [LengthLimitingTextInputFormatter(300)],
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                  ),
                  gapH16,
                  _SetupDisclosureSection(
                    title: 'Event structure',
                    subtitle:
                        'Unit sizes, rotation cadence, and reveal countdown.',
                    children: [
                      EventSuccessStructureConfigEditor(
                        value: _draft.structureConfig.normalizedForTarget(
                          _targetAttendeeCount,
                        ),
                        targetAttendeeCount: _targetAttendeeCount,
                        enabled: !setupFrozen,
                        onChanged: (value) => setState(
                          () =>
                              _draft = _draft.copyWith(structureConfig: value),
                        ),
                      ),
                    ],
                  ),
                  gapH8,
                  _SetupDisclosureSection(
                    title: 'Tools',
                    subtitle:
                        'Default and recommended tools are already selected.',
                    children: [
                      for (final level in const [
                        EventSuccessRecommendationLevel.defaultOn,
                        EventSuccessRecommendationLevel.recommended,
                        EventSuccessRecommendationLevel.optional,
                        EventSuccessRecommendationLevel.discouraged,
                      ])
                        if (profile.recommendationsFor(level).isNotEmpty) ...[
                          _RecommendationLevelHeader(level: level),
                          gapH8,
                          for (final recommendation
                              in profile.recommendationsFor(level))
                            _ModuleToggle(
                              title: recommendation.module.title,
                              subtitle: recommendation.reason,
                              active: _draft.isModuleSelected(
                                recommendation.module.id,
                              ),
                              onChanged: setupFrozen
                                  ? null
                                  : (_) => setState(
                                      () => _draft = _draft.toggleModule(
                                        recommendation.module.id,
                                      ),
                                    ),
                            ),
                          gapH8,
                        ],
                    ],
                  ),
                  gapH8,
                  _SetupDisclosureSection(
                    title: 'Delivery moments',
                    subtitle:
                        'Reveal clues, host-help requests, and match openers.',
                    children: [
                      _FeatureSwitch(
                        title: 'Let answers guide pairings',
                        subtitle:
                            'Off keeps answers for reveal clues only. On lets suggested pairings use them as one light input after interest, safety, and opt-out checks.',
                        value:
                            _draft.isModuleSelected(
                              EventSuccessModuleCatalog
                                  .compatibilityQuestionnaire
                                  .id,
                            ) &&
                            _draft.compatibilityAffectsRanking,
                        enabled:
                            !setupFrozen &&
                            _draft.isModuleSelected(
                              EventSuccessModuleCatalog
                                  .compatibilityQuestionnaire
                                  .id,
                            ),
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(
                            compatibilityAffectsRanking: value,
                          ),
                        ),
                      ),
                      if (_draft.isModuleSelected(
                        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
                      )) ...[
                        gapH12,
                        EventSuccessQuestionnaireConfigEditor(
                          value: _draft.questionnaireConfig,
                          enabled: !setupFrozen,
                          onChanged: (value) => setState(
                            () => _draft = _draft.copyWith(
                              questionnaireConfig: value,
                            ),
                          ),
                        ),
                      ],
                      gapH8,
                      _FeatureSwitch(
                        title: 'Wingman requests',
                        subtitle:
                            'Attendees can explicitly ask the host for help with one natural introduction during the event.',
                        value: _draft.wingmanRequestsEnabled,
                        enabled: !setupFrozen,
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(
                            wingmanRequestsEnabled: value,
                          ),
                        ),
                      ),
                      gapH8,
                      _FeatureSwitch(
                        title: 'Post-match openers',
                        subtitle:
                            'Matches can get a lightweight opener from shared event context.',
                        value: _draft.contextualOpenersEnabled,
                        enabled: !setupFrozen,
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(
                            contextualOpenersEnabled: value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            gapH16,
            CatchButton(
              label: widget.planIsPersisted ? 'Save setup' : 'Save and go live',
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
                                  attendeePrompt:
                                      _attendeePromptController.text,
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

  EventSuccessHostDraft get _resolvedDraft => _draft.copyWith(
    targetAttendeeCount: _targetAttendeeCount,
    structureConfig: _draft.structureConfig.normalizedForTarget(
      _targetAttendeeCount,
    ),
    hostGoal: _normalizedRequired(
      _hostGoalController.text,
      fallback: _draft.hostGoal,
    ),
  );
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
                  style: CatchTextStyles.titleS(context),
                ),
                gapH2,
                Text(
                  'Recommended range: $recommendedMin-$recommendedMax',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
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

class _FeatureSwitch extends StatelessWidget {
  const _FeatureSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: value ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
      borderColor: value ? Colors.transparent : t.line,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.titleS(context)),
                gapH3,
                Text(subtitle, style: CatchTextStyles.bodyS(context)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: enabled ? onChanged : null),
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
          Text('Before launch', style: CatchTextStyles.titleS(context)),
          gapH6,
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.only(bottom: CatchSpacing.s1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline_rounded, color: t.warning, size: 16),
                  gapW6,
                  Expanded(
                    child: Text(
                      issue,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
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

class _SetupDisclosureSection extends StatelessWidget {
  const _SetupDisclosureSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: CatchSpacing.s2),
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: t.primary,
        collapsedIconColor: t.ink2,
        title: Text(title, style: CatchTextStyles.titleM(context)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.s1),
          child: Text(
            subtitle,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ],
      ),
    );
  }
}

class _RecommendationLevelHeader extends StatelessWidget {
  const _RecommendationLevelHeader({required this.level});

  final EventSuccessRecommendationLevel level;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: CatchSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.label, style: CatchTextStyles.titleS(context)),
                gapH3,
                Text(
                  level.description,
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW8,
          CatchBadge(label: level.badgeLabel, tone: level.badgeTone),
        ],
      ),
    );
  }
}

extension on EventSuccessRecommendationLevel {
  String get description => switch (this) {
    EventSuccessRecommendationLevel.defaultOn =>
      'Selected for this activity by default.',
    EventSuccessRecommendationLevel.recommended =>
      'Useful for this activity, but the host should opt in intentionally.',
    EventSuccessRecommendationLevel.optional =>
      'Available when the host wants a more structured version of the event.',
    EventSuccessRecommendationLevel.discouraged =>
      'Advanced for this activity; use only when the host has a clear reason.',
    EventSuccessRecommendationLevel.unsupported =>
      'Hidden because it does not fit this activity structure.',
  };

  String get badgeLabel => switch (this) {
    EventSuccessRecommendationLevel.defaultOn => 'Default',
    EventSuccessRecommendationLevel.recommended => 'Recommended',
    EventSuccessRecommendationLevel.optional => 'Optional',
    EventSuccessRecommendationLevel.discouraged => 'Advanced',
    EventSuccessRecommendationLevel.unsupported => 'Hidden',
  };

  CatchBadgeTone get badgeTone => switch (this) {
    EventSuccessRecommendationLevel.defaultOn => CatchBadgeTone.success,
    EventSuccessRecommendationLevel.recommended => CatchBadgeTone.brand,
    EventSuccessRecommendationLevel.optional => CatchBadgeTone.neutral,
    EventSuccessRecommendationLevel.discouraged => CatchBadgeTone.warning,
    EventSuccessRecommendationLevel.unsupported => CatchBadgeTone.neutral,
  };
}

class _ModuleToggle extends StatelessWidget {
  const _ModuleToggle({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool active;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: CatchSurface(
        tone: active ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
        borderColor: active ? Colors.transparent : t.line,
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CatchTextStyles.titleS(context)),
                  gapH3,
                  Text(subtitle, style: CatchTextStyles.bodyS(context)),
                ],
              ),
            ),
            Switch.adaptive(value: active, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

String _normalizedRequired(String value, {required String fallback}) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
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
        Text(subtitle, style: CatchTextStyles.bodyS(context, color: t.ink2)),
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
                Text(title, style: CatchTextStyles.titleS(context)),
                gapH4,
                Text(
                  body,
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
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
      style: CatchTextStyles.bodyS(
        context,
        color: CatchTokens.of(context).danger,
      ),
    );
  }
}
