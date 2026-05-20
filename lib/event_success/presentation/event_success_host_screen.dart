import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EventSuccessHostTab { setup, live, report }

class EventSuccessHostSection extends ConsumerWidget {
  const EventSuccessHostSection({
    super.key,
    required this.event,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
  });

  final Event event;
  final EventSuccessHostTab initialTab;
  final bool showTabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(watchEventSuccessPlanProvider(event.id));
    final shouldLoadRoster = showTabs || initialTab == EventSuccessHostTab.live;
    final shouldLoadFeedback =
        showTabs || initialTab == EventSuccessHostTab.report;
    final AsyncValue<EventParticipationRoster> rosterAsync = shouldLoadRoster
        ? ref.watch(watchEventParticipationRosterProvider(event.id))
        : AsyncData(EventParticipationRoster.empty());
    final AsyncValue<List<EventSuccessFeedback>> feedbackAsync =
        shouldLoadFeedback
        ? ref.watch(watchEventSuccessFeedbackProvider(event.id))
        : const AsyncData(<EventSuccessFeedback>[]);

    if (planAsync.isLoading || rosterAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: CatchSpacing.s6),
        child: Center(child: CatchLoadingIndicator()),
      );
    }
    if (planAsync.hasError) {
      return CatchInlineErrorState.fromError(
        planAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventSuccessPlanProvider(event.id)),
      );
    }
    if (rosterAsync.hasError) {
      return CatchInlineErrorState.fromError(
        rosterAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventParticipationRosterProvider(event.id)),
      );
    }
    if (feedbackAsync.hasError) {
      return CatchInlineErrorState.fromError(
        feedbackAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessFeedbackProvider(event.id)),
      );
    }

    final persistedPlan = planAsync.asData?.value;
    final plan = persistedPlan ?? EventSuccessPlan.defaultForEvent(event);
    final roster =
        rosterAsync.asData?.value ?? EventParticipationRoster.empty();
    final feedback =
        feedbackAsync.asData?.value ?? const <EventSuccessFeedback>[];

    return EventSuccessHostPanel(
      event: event,
      plan: plan,
      planIsPersisted: persistedPlan != null,
      roster: roster,
      feedback: feedback,
      initialTab: initialTab,
      showTabs: showTabs,
      embedded: true,
    );
  }
}

class EventSuccessHostPanel extends StatefulWidget {
  const EventSuccessHostPanel({
    super.key,
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.roster,
    required this.feedback,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
    this.embedded = true,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final List<EventSuccessFeedback> feedback;
  final EventSuccessHostTab initialTab;
  final bool showTabs;
  final bool embedded;

  @override
  State<EventSuccessHostPanel> createState() => _EventSuccessHostPanelState();
}

class _EventSuccessHostPanelState extends State<EventSuccessHostPanel> {
  late EventSuccessHostTab _selectedTab = widget.initialTab;

  @override
  void didUpdateWidget(covariant EventSuccessHostPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedTab = widget.initialTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _selectedBody();
    if (!widget.showTabs) return body;

    final tabs = _EventSuccessTabPicker(
      selectedTab: _selectedTab,
      onChanged: (tab) => setState(() => _selectedTab = tab),
    );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [tabs, gapH16, body],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s2,
          ),
          child: tabs,
        ),
        Expanded(child: body),
      ],
    );
  }

  Widget _selectedBody() {
    final shrinkWrap = widget.embedded;
    final physics = widget.embedded
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics();
    final padding = widget.embedded
        ? EdgeInsets.zero
        : const EdgeInsets.all(CatchSpacing.s5);

    return switch (_selectedTab) {
      EventSuccessHostTab.setup => _SetupTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
      EventSuccessHostTab.live => _LiveTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        roster: widget.roster,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
      EventSuccessHostTab.report => _ReportTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        feedback: widget.feedback,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
    };
  }
}

class _EventSuccessTabPicker extends StatelessWidget {
  const _EventSuccessTabPicker({
    required this.selectedTab,
    required this.onChanged,
  });

  final EventSuccessHostTab selectedTab;
  final ValueChanged<EventSuccessHostTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final tab in EventSuccessHostTab.values)
          CatchChip(
            label: tab.label,
            active: selectedTab == tab,
            icon: Icon(tab.icon),
            onTap: () => onChanged(tab),
          ),
      ],
    );
  }
}

extension on EventSuccessHostTab {
  String get label {
    return switch (this) {
      EventSuccessHostTab.setup => 'Setup',
      EventSuccessHostTab.live => 'Live',
      EventSuccessHostTab.report => 'Report',
    };
  }

  IconData get icon {
    return switch (this) {
      EventSuccessHostTab.setup => Icons.tune_rounded,
      EventSuccessHostTab.live => Icons.play_circle_outline_rounded,
      EventSuccessHostTab.report => Icons.insights_outlined,
    };
  }
}

class _SetupTab extends StatefulWidget {
  const _SetupTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.shrinkWrap,
    required this.physics,
    required this.padding,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry padding;

  @override
  State<_SetupTab> createState() => _SetupTabState();
}

class _SetupTabState extends State<_SetupTab> {
  late EventSuccessHostDraft _draft = widget.plan.hostDraft;
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
      _draft = widget.plan.hostDraft;
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
                    'This default plan is visible here only. Save it to make event-success tools live for this event.',
              ),
              gapH16,
            ],
            if (setupFrozen) ...[
              _NoticeCard(
                icon: Icons.lock_clock_rounded,
                title: 'Setup is frozen',
                body: hasParticipantActivity
                    ? 'Event-success setup can be changed until someone books or joins the waitlist. Live step controls and the report remain available.'
                    : 'Event-success setup can be changed before the event starts. Live step controls and the report remain available.',
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
                    title: 'Format',
                    subtitle:
                        'Pick the live structure the host will use before, during, and after this event.',
                  ),
                  gapH12,
                  Wrap(
                    spacing: CatchSpacing.s2,
                    runSpacing: CatchSpacing.s2,
                    children: [
                      for (final playbook in EventSuccessPlaybookLibrary.all)
                        CatchChip(
                          label: playbook.activityType.label,
                          active: _draft.playbook.id == playbook.id,
                          enabled: !setupFrozen,
                          onTap: () => setState(() {
                            _draft =
                                EventSuccessHostDraft.fromPlaybook(
                                  playbook,
                                  targetAttendeeCount: _targetAttendeeCount,
                                ).copyWith(
                                  hostGoal: _normalizedRequired(
                                    _hostGoalController.text,
                                    fallback: _draft.hostGoal,
                                  ),
                                  privateCrushEnabled:
                                      _draft.privateCrushEnabled,
                                  contextualOpenersEnabled:
                                      _draft.contextualOpenersEnabled,
                                );
                          }),
                        ),
                    ],
                  ),
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
                  _SetupSectionTitle(
                    title: 'Modules',
                    subtitle:
                        'These controls decide which success tools appear for the host and attendees.',
                  ),
                  gapH8,
                  for (final module in _draft.playbook.modules)
                    _ModuleToggle(
                      title: module.title,
                      subtitle: module.hostPromise,
                      active: _draft.isModuleSelected(module.id),
                      onChanged: setupFrozen
                          ? null
                          : (_) => setState(
                              () => _draft = _draft.toggleModule(module.id),
                            ),
                    ),
                  gapH8,
                  _FeatureSwitch(
                    title: 'Private follow-up',
                    subtitle:
                        'Attendees can mark private interest after attendance is confirmed.',
                    value: _draft.privateCrushEnabled,
                    enabled: !setupFrozen,
                    onChanged: (value) => setState(
                      () =>
                          _draft = _draft.copyWith(privateCrushEnabled: value),
                    ),
                  ),
                  gapH8,
                  _FeatureSwitch(
                    title: 'Contextual openers',
                    subtitle:
                        'Matches can get lightweight opener context from this event.',
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
            ),
            gapH16,
            CatchButton(
              label: widget.planIsPersisted ? 'Save setup' : 'Save and go live',
              isLoading: saveMutation.isPending || ensureMutation.isPending,
              onPressed:
                  saveMutation.isPending ||
                      ensureMutation.isPending ||
                      setupFrozen
                  ? null
                  : () => EventSuccessController.saveSetupMutation.run(ref, (
                      tx,
                    ) async {
                      final basePlan = widget.planIsPersisted
                          ? widget.plan
                          : await tx
                                .get(eventSuccessControllerProvider.notifier)
                                .ensurePlan(widget.event);
                      await tx
                          .get(eventSuccessControllerProvider.notifier)
                          .saveSetup(
                            plan: basePlan,
                            draft: _resolvedDraft,
                            attendeePrompt: _attendeePromptController.text,
                          );
                    }),
              fullWidth: true,
            ),
          ],
        );
      },
    );
  }

  EventSuccessHostDraft get _resolvedDraft => _draft.copyWith(
    targetAttendeeCount: _targetAttendeeCount,
    hostGoal: _normalizedRequired(
      _hostGoalController.text,
      fallback: _draft.hostGoal,
    ),
  );
}

class _LiveTab extends ConsumerWidget {
  const _LiveTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.roster,
    required this.shrinkWrap,
    required this.physics,
    required this.padding,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(EventSuccessController.updateStepMutation);
    final completeMutation = ref.watch(
      EventSuccessController.completePlanMutation,
    );
    if (!planIsPersisted) {
      final isPreEvent = event.startTime.isAfter(DateTime.now());
      return ListView(
        shrinkWrap: shrinkWrap,
        primary: shrinkWrap ? false : null,
        physics: physics,
        padding: padding,
        children: [
          _NoticeCard(
            icon: isPreEvent
                ? Icons.cloud_upload_outlined
                : Icons.lock_clock_rounded,
            title: isPreEvent
                ? 'Live mode needs saved setup'
                : 'Live mode was not configured',
            body: isPreEvent
                ? 'Save event-success setup before the event to enable run-of-show controls. Attendance and check-in stay available from this Live tab.'
                : 'This event did not have event-success setup saved before it went live. Attendance and check-in remain available; event-success live controls stay unavailable for this event.',
          ),
        ],
      );
    }

    final livePlan = plan.livePlan(
      bookedCount: roster.bookedCount == 0
          ? event.signedUpCount
          : roster.bookedCount,
      checkedInCount: roster.checkedInCount == 0
          ? event.attendedCount
          : roster.checkedInCount,
    );
    final previousIndex = (plan.activeStepIndex - 1).clamp(
      0,
      livePlan.steps.length - 1,
    );
    final nextIndex = (plan.activeStepIndex + 1).clamp(
      0,
      livePlan.steps.length - 1,
    );

    return ListView(
      shrinkWrap: shrinkWrap,
      primary: shrinkWrap ? false : null,
      physics: physics,
      padding: padding,
      children: [
        if (mutation.hasError) ...[
          _ErrorText(error: (mutation as MutationError).error),
          gapH16,
        ],
        if (completeMutation.hasError) ...[
          _ErrorText(error: (completeMutation as MutationError).error),
          gapH16,
        ],
        EventSuccessLiveHostMode(plan: livePlan),
        gapH16,
        Row(
          children: [
            Expanded(
              child: CatchButton(
                label: 'Previous',
                variant: CatchButtonVariant.secondary,
                onPressed: mutation.isPending || plan.activeStepIndex == 0
                    ? null
                    : () => _setStep(ref, event.id, previousIndex),
              ),
            ),
            gapW10,
            Expanded(
              child: CatchButton(
                label: 'Next',
                onPressed:
                    mutation.isPending ||
                        plan.activeStepIndex >= livePlan.steps.length - 1
                    ? null
                    : () => _setStep(ref, event.id, nextIndex),
              ),
            ),
          ],
        ),
        gapH10,
        CatchButton(
          label: 'Mark event-success plan complete',
          variant: CatchButtonVariant.secondary,
          isLoading: completeMutation.isPending,
          onPressed: completeMutation.isPending
              ? null
              : () => EventSuccessController.completePlanMutation.run(
                  ref,
                  (tx) => tx
                      .get(eventSuccessControllerProvider.notifier)
                      .completePlan(event.id),
                ),
          fullWidth: true,
        ),
      ],
    );
  }

  void _setStep(WidgetRef ref, String eventId, int index) {
    EventSuccessController.updateStepMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .updateActiveStep(eventId: eventId, activeStepIndex: index),
    );
  }
}

class _ReportTab extends StatelessWidget {
  const _ReportTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.feedback,
    required this.shrinkWrap,
    required this.physics,
    required this.padding,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final List<EventSuccessFeedback> feedback;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (!planIsPersisted) {
      return ListView(
        shrinkWrap: shrinkWrap,
        primary: shrinkWrap ? false : null,
        physics: physics,
        padding: padding,
        children: const [
          _NoticeCard(
            icon: Icons.insights_outlined,
            title: 'No event-success report',
            body:
                'Event-success setup was not saved for this event, so there is no run-of-show report to review. Attendance reporting remains available on this screen.',
          ),
        ],
      );
    }

    final brief = plan.buildBrief(event: event, feedback: feedback);

    return ListView(
      shrinkWrap: shrinkWrap,
      primary: shrinkWrap ? false : null,
      physics: physics,
      padding: padding,
      children: [
        _NoticeCard(
          icon: Icons.assignment_turned_in_outlined,
          title:
              '${feedback.length} attendee feedback response${feedback.length == 1 ? '' : 's'}',
          body:
              'The report combines attendance and decomposed feedback. Private crush targets are never exposed to hosts.',
        ),
        gapH16,
        EventSuccessPostEventReport(brief: brief),
      ],
    );
  }
}

class _PlanSummary extends StatelessWidget {
  const _PlanSummary({required this.plan, required this.draft});

  final EventSuccessPlan plan;
  final EventSuccessHostDraft draft;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        CatchBadge(label: draft.playbook.title, tone: CatchBadgeTone.brand),
        CatchBadge(
          label: '${draft.selectedModules.length} modules',
          tone: CatchBadgeTone.neutral,
        ),
        CatchBadge(
          label: draft.status.label,
          tone: draft.status == EventSuccessSetupStatus.readyForPilot
              ? CatchBadgeTone.success
              : CatchBadgeTone.warning,
        ),
        CatchBadge(label: plan.status.name, tone: CatchBadgeTone.live),
      ],
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
          IconButton(
            tooltip: 'Decrease target attendees',
            icon: const Icon(Icons.remove_circle_outline_rounded),
            onPressed: !enabled || value <= 1
                ? null
                : () => onChanged(value - 1),
          ),
          Text('$value', style: CatchTextStyles.titleM(context)),
          IconButton(
            tooltip: 'Increase target attendees',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: !enabled ? null : () => onChanged(value + 1),
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
          Text('Before pilot', style: CatchTextStyles.titleS(context)),
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
