import 'dart:math' as math;

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_select_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_conversation_cue.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_runtime.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
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
    final shouldLoadAssignments =
        showTabs || initialTab == EventSuccessHostTab.live;
    final shouldLoadPreferences = shouldLoadAssignments;
    final shouldLoadWingmanRequests = shouldLoadAssignments;
    final AsyncValue<EventParticipationRoster> rosterAsync = shouldLoadRoster
        ? ref.watch(watchEventParticipationRosterProvider(event.id))
        : AsyncData(EventParticipationRoster.empty());
    final AsyncValue<List<EventSuccessFeedback>> feedbackAsync =
        shouldLoadFeedback
        ? ref.watch(watchEventSuccessFeedbackProvider(event.id))
        : const AsyncData(<EventSuccessFeedback>[]);
    final AsyncValue<List<EventSuccessAssignment>> assignmentsAsync =
        shouldLoadAssignments
        ? ref.watch(watchEventSuccessAssignmentsProvider(event.id))
        : const AsyncData(<EventSuccessAssignment>[]);
    final AsyncValue<List<EventSuccessAssignment>> rotationAssignmentsAsync =
        shouldLoadAssignments
        ? ref.watch(watchEventSuccessRotationAssignmentsProvider(event.id))
        : const AsyncData(<EventSuccessAssignment>[]);
    final rotationAssignmentsPreview =
        rotationAssignmentsAsync.asData?.value ??
        const <EventSuccessAssignment>[];
    final rotationParticipantUidsKey = eventSuccessPeerUidsKey(
      _rotationParticipantUids(rotationAssignmentsPreview),
    );
    final AsyncValue<List<PublicProfile>> rotationParticipantProfilesAsync =
        shouldLoadAssignments && rotationParticipantUidsKey.isNotEmpty
        ? ref.watch(
            eventSuccessAssignmentPeerProfilesProvider(
              rotationParticipantUidsKey,
            ),
          )
        : const AsyncData(<PublicProfile>[]);
    final AsyncValue<List<EventSuccessPreference>> preferencesAsync =
        shouldLoadPreferences
        ? ref.watch(watchEventSuccessPreferencesProvider(event.id))
        : const AsyncData(<EventSuccessPreference>[]);
    final AsyncValue<List<EventSuccessWingmanRequest>> wingmanRequestsAsync =
        shouldLoadWingmanRequests
        ? ref.watch(watchEventSuccessWingmanRequestsProvider(event.id))
        : const AsyncData(<EventSuccessWingmanRequest>[]);
    final wingmanProfilesKey = eventSuccessPeerUidsKey(
      _wingmanRequestProfileUids(
        wingmanRequestsAsync.asData?.value ??
            const <EventSuccessWingmanRequest>[],
      ),
    );
    final AsyncValue<List<PublicProfile>> wingmanProfilesAsync =
        shouldLoadWingmanRequests && wingmanProfilesKey.isNotEmpty
        ? ref.watch(
            eventSuccessAssignmentPeerProfilesProvider(wingmanProfilesKey),
          )
        : const AsyncData(<PublicProfile>[]);

    if (planAsync.isLoading ||
        rosterAsync.isLoading ||
        assignmentsAsync.isLoading ||
        rotationAssignmentsAsync.isLoading ||
        preferencesAsync.isLoading ||
        wingmanRequestsAsync.isLoading ||
        wingmanProfilesAsync.isLoading) {
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
    if (assignmentsAsync.hasError) {
      return CatchInlineErrorState.fromError(
        assignmentsAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessAssignmentsProvider(event.id)),
      );
    }
    if (rotationAssignmentsAsync.hasError) {
      return CatchInlineErrorState.fromError(
        rotationAssignmentsAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchEventSuccessRotationAssignmentsProvider(event.id),
        ),
      );
    }
    if (preferencesAsync.hasError) {
      return CatchInlineErrorState.fromError(
        preferencesAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessPreferencesProvider(event.id)),
      );
    }
    if (wingmanRequestsAsync.hasError) {
      return CatchInlineErrorState.fromError(
        wingmanRequestsAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessWingmanRequestsProvider(event.id)),
      );
    }
    if (wingmanProfilesAsync.hasError) {
      return CatchInlineErrorState.fromError(
        wingmanProfilesAsync.error!,
        context: AppErrorContext.profile,
        onRetry: () => ref.invalidate(
          eventSuccessAssignmentPeerProfilesProvider(wingmanProfilesKey),
        ),
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
    final assignments =
        assignmentsAsync.asData?.value ?? const <EventSuccessAssignment>[];
    final rotationAssignments =
        rotationAssignmentsAsync.asData?.value ??
        const <EventSuccessAssignment>[];
    final rotationParticipantProfiles =
        rotationParticipantProfilesAsync.asData?.value ??
        const <PublicProfile>[];
    final preferences =
        preferencesAsync.asData?.value ?? const <EventSuccessPreference>[];
    final wingmanRequests =
        wingmanRequestsAsync.asData?.value ??
        const <EventSuccessWingmanRequest>[];
    final wingmanProfiles =
        wingmanProfilesAsync.asData?.value ?? const <PublicProfile>[];

    return EventSuccessHostPanel(
      event: event,
      plan: plan,
      planIsPersisted: persistedPlan != null,
      roster: roster,
      feedback: feedback,
      assignments: assignments,
      rotationAssignments: rotationAssignments,
      rotationParticipantProfiles: rotationParticipantProfiles,
      preferences: preferences,
      wingmanRequests: wingmanRequests,
      wingmanProfiles: wingmanProfiles,
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
    this.assignments = const [],
    this.rotationAssignments = const [],
    this.rotationParticipantProfiles = const [],
    this.preferences = const [],
    this.wingmanRequests = const [],
    this.wingmanProfiles = const [],
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
    this.embedded = true,
    this.fixtureActions,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final List<EventSuccessFeedback> feedback;
  final List<EventSuccessAssignment> assignments;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<PublicProfile> rotationParticipantProfiles;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> wingmanProfiles;
  final EventSuccessHostTab initialTab;
  final bool showTabs;
  final bool embedded;
  final EventSuccessHostFixtureActions? fixtureActions;

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
        fixtureActions: widget.fixtureActions,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
      EventSuccessHostTab.live => _LiveTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        roster: widget.roster,
        assignments: widget.assignments,
        rotationAssignments: widget.rotationAssignments,
        rotationParticipantProfiles: widget.rotationParticipantProfiles,
        preferences: widget.preferences,
        wingmanRequests: widget.wingmanRequests,
        wingmanProfiles: widget.wingmanProfiles,
        fixtureActions: widget.fixtureActions,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
      EventSuccessHostTab.report => _ReportTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        feedback: widget.feedback,
        assignments: widget.assignments,
        rotationAssignments: widget.rotationAssignments,
        preferences: widget.preferences,
        wingmanRequests: widget.wingmanRequests,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
    };
  }
}

class EventSuccessHostFixtureActions {
  const EventSuccessHostFixtureActions({
    this.onSaveSetup,
    this.onPreviousStep,
    this.onNextStep,
    this.onCompletePlan,
    this.onGenerateMicroPods,
    this.onGenerateGuidedRotations,
    this.onOverrideGuidedRotations,
    this.onStartRevealCountdown,
    this.onRevealRound,
    this.onResetReveal,
  });

  final VoidCallback? onSaveSetup;
  final VoidCallback? onPreviousStep;
  final VoidCallback? onNextStep;
  final VoidCallback? onCompletePlan;
  final VoidCallback? onGenerateMicroPods;
  final VoidCallback? onGenerateGuidedRotations;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>?
  onOverrideGuidedRotations;
  final void Function(int roundIndex, int countdownSeconds)?
  onStartRevealCountdown;
  final ValueChanged<int>? onRevealRound;
  final VoidCallback? onResetReveal;
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
                    title: 'Recommended setup',
                    subtitle:
                        'Starts from the event activity, then lets the host override what this event actually needs.',
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
                  _SetupSectionTitle(
                    title: 'Event structure',
                    subtitle:
                        'Configure the unit size, number of units, rotation cadence, and reveal countdown for this format.',
                  ),
                  gapH8,
                  EventSuccessStructureConfigEditor(
                    value: _draft.structureConfig.normalizedForTarget(
                      _targetAttendeeCount,
                    ),
                    targetAttendeeCount: _targetAttendeeCount,
                    enabled: !setupFrozen,
                    onChanged: (value) => setState(
                      () => _draft = _draft.copyWith(structureConfig: value),
                    ),
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
                    title: 'Tools',
                    subtitle:
                        'Recommended tools are grouped by fit for this activity. Unsupported tools stay hidden.',
                  ),
                  gapH8,
                  for (final level in const [
                    EventSuccessRecommendationLevel.defaultOn,
                    EventSuccessRecommendationLevel.recommended,
                    EventSuccessRecommendationLevel.optional,
                    EventSuccessRecommendationLevel.discouraged,
                  ])
                    if (profile.recommendationsFor(level).isNotEmpty) ...[
                      _RecommendationLevelHeader(level: level),
                      gapH8,
                      for (final recommendation in profile.recommendationsFor(
                        level,
                      ))
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
                  _SetupSectionTitle(
                    title: 'Delivery moments',
                    subtitle:
                        'These toggles decide when the conversation and matching layers appear.',
                  ),
                  gapH8,
                  _FeatureSwitch(
                    title: 'Use questionnaire for pairing',
                    subtitle:
                        'Off keeps answers for reveal clues only. On lets the backend boost generated pairings after interest, safety, and opt-out checks.',
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

class _LiveTab extends ConsumerWidget {
  const _LiveTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.roster,
    required this.assignments,
    required this.rotationAssignments,
    required this.rotationParticipantProfiles,
    required this.preferences,
    required this.wingmanRequests,
    required this.wingmanProfiles,
    required this.fixtureActions,
    required this.shrinkWrap,
    required this.physics,
    required this.padding,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final List<EventSuccessAssignment> assignments;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<PublicProfile> rotationParticipantProfiles;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> wingmanProfiles;
  final EventSuccessHostFixtureActions? fixtureActions;
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

    final runtime = EventSuccessRuntime(
      plan: plan,
      event: event,
      now: DateTime.now(),
    );
    final livePlan = runtime.livePlan(
      bookedCount: roster.bookedCount == 0
          ? event.signedUpCount
          : roster.bookedCount,
      checkedInCount: roster.checkedInCount == 0
          ? event.attendedCount
          : roster.checkedInCount,
    );
    if (livePlan == null) {
      return ListView(
        shrinkWrap: shrinkWrap,
        primary: shrinkWrap ? false : null,
        physics: physics,
        padding: padding,
        children: const [
          _NoticeCard(
            icon: Icons.rule_folder_outlined,
            title: 'No live steps selected',
            body:
                'This saved setup does not currently include any selected tools with live run-of-show steps.',
          ),
        ],
      );
    }
    final previousIndex = (plan.activeStepIndex - 1).clamp(
      0,
      livePlan.steps.length - 1,
    );
    final nextIndex = (plan.activeStepIndex + 1).clamp(
      0,
      livePlan.steps.length - 1,
    );
    final activeModuleIds = livePlan.activeStep.moduleIds.toSet();
    bool activeStepHas(String moduleId) => activeModuleIds.contains(moduleId);
    final conversationCueActive =
        activeStepHas(EventSuccessModuleCatalog.socialMissions.id) ||
        activeStepHas(EventSuccessModuleCatalog.contextualOpeners.id);

    Widget attendanceCard() => _LiveAttendanceSummaryCard(
      bookedCount: livePlan.bookedCount,
      checkedInCount: livePlan.checkedInCount,
      waitlistCount: roster.waitlistedCount,
    );

    Widget wingmanCard() => _WingmanRequestsHostCard(
      requests: wingmanRequests,
      profiles: wingmanProfiles,
      rotationsEnabled: runtime.guidedRotationsEnabled,
    );

    Widget conversationCueCard() => EventSuccessConversationCueCard(
      title: 'Conversation cues',
      subtitle: runtime.socialMissionsEnabled
          ? 'Use one when the room needs a cleaner next interaction.'
          : 'Close with one suggested first message after mutual matches.',
      cues: runtime.socialMissionsEnabled
          ? EventSuccessConversationCueLibrary.liveCuesFor(
              event: event,
              plan: plan,
              activeStep: _activeRunOfShowStep(runtime),
            )
          : EventSuccessConversationCueLibrary.postEventOpenersFor(event),
    );

    Widget microPodsCard() => _MicroPodsHostCard(
      eventId: event.id,
      assignments: assignments,
      preferences: preferences,
      onGenerate: fixtureActions?.onGenerateMicroPods,
    );

    Widget rotationsCard() => _RotationsHostCard(
      event: event,
      rotationIntervalMinutes:
          plan.structureConfig.rotationIntervalMinutes ?? 15,
      assignments: rotationAssignments,
      participantProfiles: rotationParticipantProfiles,
      preferences: preferences,
      onGenerate: fixtureActions?.onGenerateGuidedRotations,
      onOverride: fixtureActions?.onOverrideGuidedRotations,
    );

    Widget liveRevealCard() => EventSuccessLiveRevealHostCard(
      event: event,
      plan: plan,
      podAssignments: assignments,
      rotationAssignments: rotationAssignments,
      preferences: preferences,
      onStartCountdown: fixtureActions?.onStartRevealCountdown,
      onRevealRound: fixtureActions?.onRevealRound,
      onResetReveal: fixtureActions?.onResetReveal,
    );

    final liveRevealAvailable =
        runtime.liveRevealEnabled &&
        (runtime.guidedRotationsEnabled || runtime.microPodsEnabled);
    final currentStepCards = <Widget>[
      if (runtime.checkInEnabled &&
          activeStepHas(EventSuccessModuleCatalog.checkIn.id))
        attendanceCard(),
      if (runtime.wingmanRequestsEnabled &&
          activeStepHas(EventSuccessModuleCatalog.wingmanRequests.id))
        wingmanCard(),
      if (runtime.conversationCuesEnabled && conversationCueActive)
        conversationCueCard(),
      if (runtime.microPodsEnabled &&
          activeStepHas(EventSuccessModuleCatalog.microPods.id))
        microPodsCard(),
      if (runtime.guidedRotationsEnabled &&
          activeStepHas(EventSuccessModuleCatalog.guidedRotations.id))
        rotationsCard(),
      if (liveRevealAvailable &&
          activeStepHas(EventSuccessModuleCatalog.liveReveal.id))
        liveRevealCard(),
    ];
    final supportingCards = <Widget>[
      if (runtime.checkInEnabled &&
          !activeStepHas(EventSuccessModuleCatalog.checkIn.id))
        attendanceCard(),
      if (runtime.compatibilityQuestionnaireEnabled)
        _CompatibilitySignalHostCard(plan: plan),
      if (runtime.wingmanRequestsEnabled &&
          !activeStepHas(EventSuccessModuleCatalog.wingmanRequests.id))
        wingmanCard(),
      if (runtime.conversationCuesEnabled && !conversationCueActive)
        conversationCueCard(),
      if (runtime.microPodsEnabled &&
          !activeStepHas(EventSuccessModuleCatalog.microPods.id))
        microPodsCard(),
      if (runtime.guidedRotationsEnabled &&
          !activeStepHas(EventSuccessModuleCatalog.guidedRotations.id))
        rotationsCard(),
      if (liveRevealAvailable &&
          !activeStepHas(EventSuccessModuleCatalog.liveReveal.id))
        liveRevealCard(),
    ];

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
        EventSuccessLiveHostMode(plan: livePlan, showStepList: false),
        gapH16,
        Row(
          children: [
            Expanded(
              child: CatchButton(
                label: 'Previous',
                variant: CatchButtonVariant.secondary,
                onPressed: mutation.isPending || plan.activeStepIndex == 0
                    ? null
                    : fixtureActions?.onPreviousStep ??
                          () => _setStep(ref, event.id, previousIndex),
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
                    : fixtureActions?.onNextStep ??
                          () => _setStep(ref, event.id, nextIndex),
              ),
            ),
          ],
        ),
        if (currentStepCards.isNotEmpty) ...[
          gapH20,
          const _LiveSectionHeader(
            title: 'Current step tools',
            subtitle:
                'The controls most relevant to the host step attendees are seeing now.',
          ),
          gapH10,
          ..._spacedCards(currentStepCards),
        ],
        if (supportingCards.isNotEmpty) ...[
          gapH20,
          const _LiveSectionHeader(
            title: 'Supporting controls',
            subtitle:
                'Operational panels that stay available without competing with the run-of-show.',
          ),
          gapH10,
          ..._spacedCards(supportingCards),
        ],
        gapH20,
        CatchButton(
          label: 'Mark event-success plan complete',
          variant: CatchButtonVariant.secondary,
          isLoading:
              fixtureActions?.onCompletePlan == null &&
              completeMutation.isPending,
          onPressed: completeMutation.isPending
              ? null
              : fixtureActions?.onCompletePlan ??
                    () => EventSuccessController.completePlanMutation.run(
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

class _LiveSectionHeader extends StatelessWidget {
  const _LiveSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CatchTextStyles.titleM(context)),
        gapH4,
        Text(subtitle, style: CatchTextStyles.bodyS(context, color: t.ink2)),
      ],
    );
  }
}

List<Widget> _spacedCards(List<Widget> cards) {
  final children = <Widget>[];
  for (var i = 0; i < cards.length; i += 1) {
    if (i > 0) children.add(gapH16);
    children.add(cards[i]);
  }
  return children;
}

class _ReportTab extends StatelessWidget {
  const _ReportTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.feedback,
    required this.assignments,
    required this.rotationAssignments,
    required this.preferences,
    required this.wingmanRequests,
    required this.shrinkWrap,
    required this.physics,
    required this.padding,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final List<EventSuccessFeedback> feedback;
  final List<EventSuccessAssignment> assignments;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
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

    final runtime = EventSuccessRuntime(
      plan: plan,
      event: event,
      now: DateTime.now(),
    );
    if (!runtime.hostReportEnabled) {
      return ListView(
        shrinkWrap: shrinkWrap,
        primary: shrinkWrap ? false : null,
        physics: physics,
        padding: padding,
        children: const [
          _NoticeCard(
            icon: Icons.insights_outlined,
            title: 'Host analytics disabled',
            body:
                'This event-success plan does not include the host analytics module.',
          ),
        ],
      );
    }

    final brief = plan.buildBrief(
      event: event,
      feedback: feedback,
      assignments: assignments,
      rotationAssignments: rotationAssignments,
      preferences: preferences,
      wingmanRequests: wingmanRequests,
    );

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
              'The report combines attendance, feedback, assignment coverage, and explicit wingman requests.',
        ),
        gapH16,
        _HostReportSignalGrid(brief: brief),
        gapH16,
        EventSuccessPostEventReport(brief: brief),
      ],
    );
  }
}

class _HostReportSignalGrid extends StatelessWidget {
  const _HostReportSignalGrid({required this.brief});

  final EventSuccessBrief brief;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final scorecard = brief.scorecard;
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.query_stats_rounded, color: t.primary),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Host signal quality',
                      style: CatchTextStyles.titleM(context),
                    ),
                    gapH4,
                    Text(
                      'Shows whether the report is based on enough live data to trust.',
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          gapH14,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              EventSuccessMetricPill(
                label: 'Feedback',
                value: scorecard.feedbackResponseRate,
              ),
              EventSuccessMetricPill(
                label: 'Assignment coverage',
                value: scorecard.assignmentCoverageRate,
              ),
              EventSuccessMetricPill(
                label: 'Assignment opt-out',
                value: scorecard.assignmentOptOutRate,
              ),
              EventSuccessMetricPill(
                label: 'Wingman help',
                value: scorecard.wingmanRequestRate,
              ),
            ],
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label:
                    '${scorecard.feedbackResponseCount}/${scorecard.checkedInCount} feedback',
                tone: CatchBadgeTone.neutral,
                icon: Icons.rate_review_outlined,
              ),
              CatchBadge(
                label: '${scorecard.assignmentParticipantCount} assigned',
                tone: CatchBadgeTone.neutral,
                icon: Icons.groups_2_outlined,
              ),
              CatchBadge(
                label: '${scorecard.assignmentOptOutCount} opted out',
                tone: CatchBadgeTone.neutral,
                icon: Icons.visibility_off_outlined,
              ),
              CatchBadge(
                label: '${scorecard.wingmanRequestCount} wingman requests',
                tone: CatchBadgeTone.neutral,
                icon: Icons.volunteer_activism_outlined,
              ),
            ],
          ),
        ],
      ),
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
          label: '${draft.selectedModules.length} tools',
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

class _HostActivitySummary extends StatelessWidget {
  const _HostActivitySummary({required this.profile, required this.draft});

  final EventSuccessActivityProfile profile;
  final EventSuccessHostDraft draft;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchBadge(
                label: profile.activityKind.label,
                tone: CatchBadgeTone.brand,
                icon: Icons.auto_awesome_outlined,
              ),
              CatchBadge(
                label: profile.activityKind.defaultInteractionModel.label,
                tone: CatchBadgeTone.neutral,
              ),
              CatchBadge(
                label: '${draft.selectedModules.length} selected',
                tone: CatchBadgeTone.neutral,
              ),
            ],
          ),
          gapH8,
          Text(
            profile.summary,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _CompatibilitySignalHostCard extends StatelessWidget {
  const _CompatibilitySignalHostCard({required this.plan});

  final EventSuccessPlan plan;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final rankingOn = plan.compatibilityAffectsRanking;
    final pack = plan.questionnaireConfig.pack;
    return CatchSurface(
      borderColor: rankingOn ? Colors.transparent : t.line,
      tone: rankingOn ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_alt_outlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Compatibility questionnaire',
                      style: CatchTextStyles.titleM(context),
                    ),
                    CatchBadge(
                      label: rankingOn ? 'Ranking on' : 'Clues only',
                      tone: rankingOn
                          ? CatchBadgeTone.success
                          : CatchBadgeTone.neutral,
                    ),
                    CatchBadge(
                      label: pack.title,
                      tone: CatchBadgeTone.neutral,
                      icon: pack.custom
                          ? Icons.edit_note_rounded
                          : Icons.style_outlined,
                    ),
                  ],
                ),
                gapH6,
                Text(
                  rankingOn
                      ? 'Generated pairings can use shared answers as a ranking boost after interested-in, safety, and attendee opt-out checks.'
                      : 'Answers can still inform reveal language, but generated pairings will not use them for ranking.',
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

class _LiveAttendanceSummaryCard extends StatelessWidget {
  const _LiveAttendanceSummaryCard({
    required this.bookedCount,
    required this.checkedInCount,
    required this.waitlistCount,
  });

  final int bookedCount;
  final int checkedInCount;
  final int waitlistCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_2_rounded, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  'Arrival check-in',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              Text(
                '$checkedInCount / $bookedCount',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ],
          ),
          gapH8,
          Text(
            'Attendance decides who can use assignments, wingman requests, and post-event feedback.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: '$bookedCount booked',
                tone: bookedCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.brand,
                icon: Icons.confirmation_number_outlined,
              ),
              CatchBadge(
                label: '$checkedInCount checked in',
                tone: checkedInCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.success,
                icon: Icons.check_circle_outline_rounded,
              ),
              CatchBadge(
                label: '$waitlistCount waitlist',
                tone: waitlistCount == 0
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.warning,
                icon: Icons.hourglass_empty_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WingmanRequestsHostCard extends StatelessWidget {
  const _WingmanRequestsHostCard({
    required this.requests,
    required this.profiles,
    required this.rotationsEnabled,
  });

  final List<EventSuccessWingmanRequest> requests;
  final List<PublicProfile> profiles;
  final bool rotationsEnabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activeRequests =
        requests.where((request) => request.isActive).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final profileByUid = {for (final profile in profiles) profile.uid: profile};
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism_outlined, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  'Wingman requests',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              CatchBadge(
                label: '${activeRequests.length} active',
                tone: activeRequests.isEmpty
                    ? CatchBadgeTone.neutral
                    : CatchBadgeTone.live,
                icon: Icons.visibility_outlined,
              ),
            ],
          ),
          gapH8,
          Text(
            rotationsEnabled
                ? 'Attendees explicitly asked the host for help. Use rotation edits or live facilitation to pair them safely.'
                : 'Attendees explicitly asked the host for help. Use this as live facilitation context.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH12,
          if (activeRequests.isEmpty)
            Text(
              'No host-help requests yet.',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            )
          else
            for (final request in activeRequests)
              Padding(
                padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
                child: _WingmanRequestHostRow(
                  request: request,
                  requester: profileByUid[request.requesterUid],
                  target: profileByUid[request.targetUid],
                ),
              ),
        ],
      ),
    );
  }
}

class _WingmanRequestHostRow extends StatelessWidget {
  const _WingmanRequestHostRow({
    required this.request,
    required this.requester,
    required this.target,
  });

  final EventSuccessWingmanRequest request;
  final PublicProfile? requester;
  final PublicProfile? target;

  @override
  Widget build(BuildContext context) {
    final targetName = target?.name ?? 'this attendee';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonRow(
          data: PersonRowData(
            name: requester?.name ?? 'Attendee',
            imageUrl: requester?.primaryPhotoThumbnailUrl,
            seed: request.requesterUid,
            metaLine: 'Asked for help meeting $targetName',
          ),
          avatarSize: 40,
          trailing: CatchBadge(
            label: 'Host visible',
            tone: CatchBadgeTone.live,
            icon: Icons.visibility_outlined,
          ),
        ),
        if (request.note != null && request.note!.trim().isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s2,
            ),
            child: Text(
              request.note!,
              style: CatchTextStyles.bodyS(
                context,
                color: CatchTokens.of(context).ink2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MicroPodsHostCard extends ConsumerWidget {
  const _MicroPodsHostCard({
    required this.eventId,
    required this.assignments,
    required this.preferences,
    this.onGenerate,
  });

  final String eventId;
  final List<EventSuccessAssignment> assignments;
  final List<EventSuccessPreference> preferences;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(
      EventSuccessController.generateMicroPodsMutation,
    );
    final optedOutUids = preferences
        .where((preference) => preference.microPodsOptedOut)
        .map((preference) => preference.uid)
        .toSet();
    final optedOutCount = optedOutUids.length;
    final activeAssignments = assignments
        .where((assignment) => !optedOutUids.contains(assignment.uid))
        .toList(growable: false);
    final staleAssignmentCount = assignments.length - activeAssignments.length;
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_2_outlined,
                color: CatchTokens.of(context).primary,
              ),
              gapW10,
              Expanded(
                child: Text(
                  'Micro-pods',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              CatchBadge(
                label: '${activeAssignments.length} assigned',
                tone: activeAssignments.isEmpty
                    ? CatchBadgeTone.warning
                    : CatchBadgeTone.success,
              ),
              if (optedOutCount > 0) ...[
                gapW8,
                CatchBadge(
                  label: '$optedOutCount opted out',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.visibility_off_outlined,
                ),
              ],
            ],
          ),
          gapH8,
          Text(
            staleAssignmentCount > 0
                ? 'Regenerate to remove opted-out attendee cards from the current pod set.'
                : optedOutCount > 0
                ? 'Generate attendee pod cards from the roster, excluding opted-out attendees.'
                : 'Generate attendee pod cards from the current booked and checked-in roster.',
            style: CatchTextStyles.bodyS(context),
          ),
          if (activeAssignments.isNotEmpty) ...[
            gapH12,
            _PodGroupSummary(assignments: activeAssignments),
          ],
          if (mutation.hasError) ...[
            gapH8,
            _ErrorText(error: (mutation as MutationError).error),
          ],
          gapH12,
          CatchButton(
            key: const ValueKey('eventSuccessGenerateMicroPodsButton'),
            label: assignments.isEmpty ? 'Generate micro-pods' : 'Regenerate',
            icon: const Icon(Icons.auto_awesome_outlined),
            isLoading: onGenerate == null && mutation.isPending,
            onPressed: mutation.isPending
                ? null
                : onGenerate ??
                      () =>
                          EventSuccessController.generateMicroPodsMutation.run(
                            ref,
                            (tx) => tx
                                .get(eventSuccessControllerProvider.notifier)
                                .generateMicroPods(eventId: eventId),
                          ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _RotationsHostCard extends ConsumerWidget {
  const _RotationsHostCard({
    required this.event,
    required this.rotationIntervalMinutes,
    required this.assignments,
    required this.participantProfiles,
    required this.preferences,
    this.onGenerate,
    this.onOverride,
  });

  final Event event;
  final int rotationIntervalMinutes;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> participantProfiles;
  final List<EventSuccessPreference> preferences;
  final VoidCallback? onGenerate;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>? onOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(
      EventSuccessController.generateGuidedRotationsMutation,
    );
    final optedOutUids = preferences
        .where((preference) => preference.guidedRotationsOptedOut)
        .map((preference) => preference.uid)
        .toSet();
    final activeAssignments = assignments
        .where((assignment) => !optedOutUids.contains(assignment.uid))
        .toList(growable: false);
    final roundCount = _maxRotationRoundCount(activeAssignments);
    final optedOutCount = optedOutUids.length;
    final staleAssignmentCount = assignments.length - activeAssignments.length;
    final hostEdited = activeAssignments.any(
      (assignment) => assignment.source == 'host_override_v1',
    );
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sync_alt_rounded,
                color: CatchTokens.of(context).primary,
              ),
              gapW10,
              Expanded(
                child: Text(
                  'Guided rotations',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              CatchBadge(
                label: '$roundCount rounds',
                tone: roundCount == 0
                    ? CatchBadgeTone.warning
                    : CatchBadgeTone.success,
              ),
              if (optedOutCount > 0) ...[
                gapW8,
                CatchBadge(
                  label: '$optedOutCount opted out',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.visibility_off_outlined,
                ),
              ],
              if (hostEdited) ...[
                gapW8,
                const CatchBadge(
                  label: 'Host edited',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.edit_outlined,
                ),
              ],
            ],
          ),
          gapH8,
          Text(
            staleAssignmentCount > 0
                ? 'Regenerate to remove opted-out attendees from timed rotations.'
                : 'Generate pairings from event duration, saved cadence, checked-in participants, and mutual gender interest.',
            style: CatchTextStyles.bodyS(context),
          ),
          if (activeAssignments.isNotEmpty) ...[
            gapH12,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchBadge(
                  label: '${activeAssignments.length} assigned',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.people_outline_rounded,
                ),
                CatchBadge(
                  label:
                      '${_eventRotationCapacity(event, rotationIntervalMinutes)} possible',
                  tone: CatchBadgeTone.neutral,
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ],
          if (mutation.hasError) ...[
            gapH8,
            _ErrorText(error: (mutation as MutationError).error),
          ],
          gapH12,
          if (activeAssignments.isEmpty)
            CatchButton(
              key: const ValueKey('eventSuccessGenerateRotationsButton'),
              label: 'Generate rotations',
              icon: const Icon(Icons.auto_awesome_outlined),
              isLoading: onGenerate == null && mutation.isPending,
              onPressed: mutation.isPending
                  ? null
                  : onGenerate ??
                        () => EventSuccessController
                            .generateGuidedRotationsMutation
                            .run(
                              ref,
                              (tx) => tx
                                  .get(eventSuccessControllerProvider.notifier)
                                  .generateGuidedRotations(eventId: event.id),
                            ),
              fullWidth: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: CatchButton(
                    key: const ValueKey('eventSuccessGenerateRotationsButton'),
                    label: 'Regenerate',
                    icon: const Icon(Icons.auto_awesome_outlined),
                    variant: CatchButtonVariant.secondary,
                    isLoading: onGenerate == null && mutation.isPending,
                    onPressed: mutation.isPending
                        ? null
                        : onGenerate ??
                              () => EventSuccessController
                                  .generateGuidedRotationsMutation
                                  .run(
                                    ref,
                                    (tx) => tx
                                        .get(
                                          eventSuccessControllerProvider
                                              .notifier,
                                        )
                                        .generateGuidedRotations(
                                          eventId: event.id,
                                        ),
                                  ),
                    fullWidth: true,
                  ),
                ),
                gapW10,
                Expanded(
                  child: CatchButton(
                    label: 'Edit rotations',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showRotationOverrideSheet(
                      context: context,
                      event: event,
                      assignments: activeAssignments,
                      participantProfiles: participantProfiles,
                      onOverride: onOverride,
                    ),
                    fullWidth: true,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

Future<void> _showRotationOverrideSheet({
  required BuildContext context,
  required Event event,
  required List<EventSuccessAssignment> assignments,
  required List<PublicProfile> participantProfiles,
  ValueChanged<List<EventSuccessRotationOverrideRound>>? onOverride,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _RotationOverrideSheet(
      event: event,
      assignments: assignments,
      participantProfiles: participantProfiles,
      onOverride: onOverride,
    ),
  );
}

class _RotationOverrideSheet extends ConsumerStatefulWidget {
  const _RotationOverrideSheet({
    required this.event,
    required this.assignments,
    required this.participantProfiles,
    this.onOverride,
  });

  final Event event;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> participantProfiles;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>? onOverride;

  @override
  ConsumerState<_RotationOverrideSheet> createState() =>
      _RotationOverrideSheetState();
}

class _RotationOverrideSheetState
    extends ConsumerState<_RotationOverrideSheet> {
  late final List<String> _participantUids = _rotationParticipantUids(
    widget.assignments,
  );
  late final Map<String, String> _participantLabels = {
    for (final profile in widget.participantProfiles) profile.uid: profile.name,
  };
  late final List<_RotationOverrideRoundDraft> _rounds =
      _rotationRoundDraftsFromAssignments(widget.assignments);

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(
      EventSuccessController.overrideGuidedRotationsMutation,
    );
    final validationError = _validationError;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.68;
    return CatchBottomSheetScaffold(
      title: 'Edit rotations',
      subtitle: 'Host override',
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mutation.hasError) ...[
            _ErrorText(error: (mutation as MutationError).error),
            gapH8,
          ],
          if (validationError != null) ...[
            Text(
              validationError,
              style: CatchTextStyles.bodyS(
                context,
                color: CatchTokens.of(context).danger,
              ),
            ),
            gapH8,
          ],
          CatchButton(
            label: 'Save overrides',
            icon: const Icon(Icons.check_rounded),
            isLoading: widget.onOverride == null && mutation.isPending,
            onPressed: mutation.isPending || validationError != null
                ? null
                : () => _saveOverrides(context),
            fullWidth: true,
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _rounds.length,
          separatorBuilder: (_, _) => gapH12,
          itemBuilder: (context, index) {
            final round = _rounds[index];
            return _RotationOverrideRoundEditor(
              round: round,
              participantUids: _participantUids,
              participantLabel: _participantLabel,
              onChanged: () => setState(() {}),
              onAddPair: () => setState(() => _addPair(round)),
              onRemovePair: (pair) =>
                  setState(() => round.pairings.remove(pair)),
            );
          },
        ),
      ),
    );
  }

  String _participantLabel(String uid) => _participantLabels[uid] ?? uid;

  String? get _validationError {
    if (_rounds.every((round) => round.pairings.isEmpty)) {
      return 'Add at least one pair.';
    }
    for (final round in _rounds) {
      final usedInRound = <String>{};
      for (final pair in round.pairings) {
        final uidA = pair.uidA;
        final uidB = pair.uidB;
        if (uidA == null || uidB == null) {
          return 'Choose both attendees for every pair.';
        }
        if (uidA == uidB) {
          return 'Choose two different attendees.';
        }
        if (!usedInRound.add(uidA) || !usedInRound.add(uidB)) {
          return 'Each attendee can appear once per round.';
        }
      }
    }
    return null;
  }

  void _addPair(_RotationOverrideRoundDraft round) {
    final used = round.pairings
        .expand((pair) => [pair.uidA, pair.uidB])
        .whereType<String>()
        .toSet();
    final available = _participantUids
        .where((uid) => !used.contains(uid))
        .toList(growable: false);
    round.pairings.add(
      _RotationOverridePairDraft(
        uidA: available.isEmpty ? null : available.first,
        uidB: available.length < 2 ? null : available[1],
      ),
    );
  }

  void _saveOverrides(BuildContext context) {
    final overrideRounds = [
      for (final round in _rounds)
        EventSuccessRotationOverrideRound(
          roundIndex: round.roundIndex,
          pairings: [
            for (final pair in round.pairings)
              EventSuccessRotationOverridePair(
                uidA: pair.uidA!,
                uidB: pair.uidB!,
              ),
          ],
        ),
    ];
    final fixtureOverride = widget.onOverride;
    if (fixtureOverride != null) {
      fixtureOverride(overrideRounds);
      Navigator.of(context).pop();
      return;
    }
    EventSuccessController.overrideGuidedRotationsMutation.run(ref, (tx) async {
      await tx
          .get(eventSuccessControllerProvider.notifier)
          .overrideGuidedRotations(
            eventId: widget.event.id,
            rounds: overrideRounds,
          );
      if (context.mounted) Navigator.of(context).pop();
    });
  }
}

class _RotationOverrideRoundEditor extends StatelessWidget {
  const _RotationOverrideRoundEditor({
    required this.round,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onAddPair,
    required this.onRemovePair,
  });

  final _RotationOverrideRoundDraft round;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final VoidCallback onChanged;
  final VoidCallback onAddPair;
  final ValueChanged<_RotationOverridePairDraft> onRemovePair;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Round ${round.roundIndex + 1}',
                  style: CatchTextStyles.titleS(context),
                ),
              ),
              CatchButton(
                label: 'Add pair',
                icon: const Icon(Icons.add_rounded),
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
                onPressed: onAddPair,
              ),
            ],
          ),
          gapH10,
          if (round.pairings.isEmpty)
            Text(
              'No pairs in this round.',
              style: CatchTextStyles.bodyS(context, color: t.ink3),
            )
          else
            for (final pair in round.pairings) ...[
              _RotationOverridePairEditor(
                pair: pair,
                participantUids: participantUids,
                participantLabel: participantLabel,
                onChanged: onChanged,
                onRemove: () => onRemovePair(pair),
              ),
              if (pair != round.pairings.last) gapH8,
            ],
        ],
      ),
    );
  }
}

class _RotationOverridePairEditor extends StatelessWidget {
  const _RotationOverridePairEditor({
    required this.pair,
    required this.participantUids,
    required this.participantLabel,
    required this.onChanged,
    required this.onRemove,
  });

  final _RotationOverridePairDraft pair;
  final List<String> participantUids;
  final String Function(String uid) participantLabel;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CatchSelectMenu<String>(
            values: participantUids,
            value: pair.uidA,
            itemLabel: participantLabel,
            hintText: 'Attendee',
            semanticLabel: 'First rotation attendee',
            onChanged: (value) {
              pair.uidA = value;
              onChanged();
            },
          ),
        ),
        gapW8,
        Expanded(
          child: CatchSelectMenu<String>(
            values: participantUids,
            value: pair.uidB,
            itemLabel: participantLabel,
            hintText: 'Partner',
            semanticLabel: 'Second rotation attendee',
            onChanged: (value) {
              pair.uidB = value;
              onChanged();
            },
          ),
        ),
        IconButton(
          tooltip: 'Remove pair',
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class _PodGroupSummary extends StatelessWidget {
  const _PodGroupSummary({required this.assignments});

  final List<EventSuccessAssignment> assignments;

  @override
  Widget build(BuildContext context) {
    final groups = _assignmentCountsByLabel(assignments);
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final entry in groups.entries)
          CatchBadge(
            label: '${entry.key} · ${entry.value} assigned',
            tone: CatchBadgeTone.neutral,
            icon: Icons.group_outlined,
          ),
      ],
    );
  }
}

Map<String, int> _assignmentCountsByLabel(
  List<EventSuccessAssignment> assignments,
) {
  final counts = <String, int>{};
  for (final assignment in assignments) {
    counts.update(assignment.label, (value) => value + 1, ifAbsent: () => 1);
  }
  return Map.fromEntries(
    counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

List<String> _rotationParticipantUids(
  List<EventSuccessAssignment> assignments,
) {
  final uids = <String>{};
  for (final assignment in assignments) {
    uids.add(assignment.uid);
    uids.addAll(assignment.peerUids);
    for (final slot in assignment.rotationSlots) {
      uids.add(slot.peerUid);
    }
  }
  return uids.toList()..sort();
}

List<String> _wingmanRequestProfileUids(
  List<EventSuccessWingmanRequest> requests,
) {
  final uids = <String>{};
  for (final request in requests) {
    if (!request.isActive) continue;
    uids
      ..add(request.requesterUid)
      ..add(request.targetUid);
  }
  return uids.toList()..sort();
}

List<_RotationOverrideRoundDraft> _rotationRoundDraftsFromAssignments(
  List<EventSuccessAssignment> assignments,
) {
  final pairsByRound = <int, Map<String, _RotationOverridePairDraft>>{};
  for (final assignment in assignments) {
    for (final slot in assignment.rotationSlots) {
      final pairUids = [assignment.uid, slot.peerUid]..sort();
      final key = pairUids.join('__');
      pairsByRound
          .putIfAbsent(slot.roundIndex, () => {})
          .putIfAbsent(
            key,
            () => _RotationOverridePairDraft(
              uidA: pairUids.first,
              uidB: pairUids.last,
            ),
          );
    }
  }
  final entries = pairsByRound.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final entry in entries)
      _RotationOverrideRoundDraft(
        roundIndex: entry.key,
        pairings: entry.value.values.toList(),
      ),
  ];
}

final class _RotationOverrideRoundDraft {
  _RotationOverrideRoundDraft({
    required this.roundIndex,
    required this.pairings,
  });

  final int roundIndex;
  final List<_RotationOverridePairDraft> pairings;
}

final class _RotationOverridePairDraft {
  _RotationOverridePairDraft({required this.uidA, required this.uidB});

  String? uidA;
  String? uidB;
}

int _maxRotationRoundCount(List<EventSuccessAssignment> assignments) {
  var maxRounds = 0;
  for (final assignment in assignments) {
    maxRounds = math.max(maxRounds, assignment.rotationSlots.length);
  }
  return maxRounds;
}

int _eventRotationCapacity(Event event, int rotationIntervalMinutes) {
  final durationMinutes = event.endTime.difference(event.startTime).inMinutes;
  return math.max(0, durationMinutes ~/ rotationIntervalMinutes);
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
