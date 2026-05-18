import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
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
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventSuccessHostRouteScreen extends ConsumerWidget {
  const EventSuccessHostRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final event = eventAsync.asData?.value ?? initialEvent;
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final planAsync = ref.watch(watchEventSuccessPlanProvider(eventId));
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(eventId),
    );
    final feedbackAsync = ref.watch(watchEventSuccessFeedbackProvider(eventId));

    if (eventAsync.isLoading && event == null) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (eventAsync.hasError) {
      return CatchErrorScaffold.fromError(
        eventAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventProvider(eventId)),
      );
    }
    if (event == null) {
      return const CatchErrorScaffold(
        title: 'Event not found',
        message: 'This event is no longer available.',
      );
    }
    if (clubAsync.isLoading || planAsync.isLoading || rosterAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (clubAsync.hasError) {
      return CatchErrorScaffold.fromError(
        clubAsync.error!,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(fetchClubProvider(clubId)),
      );
    }
    if (planAsync.hasError) {
      return CatchErrorScaffold.fromError(
        planAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventSuccessPlanProvider(eventId)),
      );
    }
    if (rosterAsync.hasError) {
      return CatchErrorScaffold.fromError(
        rosterAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventParticipationRosterProvider(eventId)),
      );
    }
    if (feedbackAsync.hasError) {
      return CatchErrorScaffold.fromError(
        feedbackAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessFeedbackProvider(eventId)),
      );
    }

    final club = clubAsync.asData?.value;
    if (club == null) {
      return const CatchErrorScaffold(
        title: 'Club not found',
        message: 'This club is no longer available.',
      );
    }
    if (uid == null || club.hostUserId != uid) {
      return const CatchErrorScaffold(
        title: 'Host access only',
        message: 'Only the club host can manage event success tools.',
      );
    }

    final plan =
        planAsync.asData?.value ?? EventSuccessPlan.defaultForEvent(event);
    final roster =
        rosterAsync.asData?.value ?? EventParticipationRoster.empty();
    final feedback =
        feedbackAsync.asData?.value ?? const <EventSuccessFeedback>[];

    return EventSuccessHostScreen(
      club: club,
      event: event,
      plan: plan,
      planIsPersisted: planAsync.asData?.value != null,
      roster: roster,
      feedback: feedback,
    );
  }
}

class EventSuccessHostScreen extends StatelessWidget {
  const EventSuccessHostScreen({
    super.key,
    required this.club,
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.roster,
    required this.feedback,
  });

  final Club club;
  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final List<EventSuccessFeedback> feedback;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          title: const Text('Event success'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Setup'),
              Tab(text: 'Live'),
              Tab(text: 'Report'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SetupTab(
              event: event,
              plan: plan,
              planIsPersisted: planIsPersisted,
            ),
            _LiveTab(event: event, plan: plan, roster: roster),
            _ReportTab(event: event, plan: plan, feedback: feedback),
          ],
        ),
      ),
    );
  }
}

class _SetupTab extends StatefulWidget {
  const _SetupTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;

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
    final setupFrozen = !widget.event.startTime.isAfter(DateTime.now());

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
          padding: const EdgeInsets.all(CatchSpacing.s5),
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
                body:
                    'Event-success setup can be changed before the event starts. Live step controls and the report remain available.',
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
                  _SectionTitle(
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
                  _SectionTitle(
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
    required this.roster,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventParticipationRoster roster;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(EventSuccessController.updateStepMutation);
    final completeMutation = ref.watch(
      EventSuccessController.completePlanMutation,
    );
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
      padding: const EdgeInsets.all(CatchSpacing.s5),
      children: [
        if (mutation.hasError) ...[
          _ErrorText(error: (mutation as MutationError).error),
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
    required this.feedback,
  });

  final Event event;
  final EventSuccessPlan plan;
  final List<EventSuccessFeedback> feedback;

  @override
  Widget build(BuildContext context) {
    final brief = plan.buildBrief(event: event, feedback: feedback);

    return ListView(
      padding: const EdgeInsets.all(CatchSpacing.s5),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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
