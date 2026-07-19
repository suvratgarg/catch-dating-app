part of '../event_success_host_screen.dart';

class LiveTab extends StatelessWidget {
  const LiveTab({
    super.key,
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.roster,
    required this.assignments,
    required this.assignmentParticipantProfiles,
    required this.rotationAssignments,
    required this.rotationParticipantProfiles,
    required this.preferences,
    required this.wingmanRequests,
    required this.wingmanProfiles,
    required this.compactLiveControls,
    required this.actionState,
    required this.onPreviousStep,
    required this.onNextStep,
    required this.onCompleteGuide,
    required this.microPodsGenerationState,
    required this.rotationsGenerationState,
    required this.onGenerateMicroPods,
    required this.onGenerateGuidedRotations,
    required this.onOverrideGroupAssignments,
    required this.onOverrideGuidedRotations,
    required this.revealActionState,
    required this.onStartRevealCountdown,
    required this.onRevealRound,
    required this.onResetReveal,
    required this.fixtureActions,
    required this.embedded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> assignmentParticipantProfiles;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<PublicProfile> rotationParticipantProfiles;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> wingmanProfiles;
  final bool compactLiveControls;
  final EventSuccessLiveActionState actionState;
  final Future<void> Function(int stepIndex)? onPreviousStep;
  final Future<void> Function(int stepIndex)? onNextStep;
  final Future<void> Function()? onCompleteGuide;
  final EventSuccessAssignmentGenerationActionState microPodsGenerationState;
  final EventSuccessAssignmentGenerationActionState rotationsGenerationState;
  final Future<void> Function()? onGenerateMicroPods;
  final Future<void> Function()? onGenerateGuidedRotations;
  final Future<void> Function(List<EventSuccessGroupOverrideRound> rounds)?
  onOverrideGroupAssignments;
  final Future<void> Function(List<EventSuccessRotationOverrideRound> rounds)?
  onOverrideGuidedRotations;
  final EventSuccessRevealActionState revealActionState;
  final Future<void> Function(int roundIndex, int countdownSeconds)?
  onStartRevealCountdown;
  final Future<void> Function(int roundIndex)? onRevealRound;
  final Future<void> Function()? onResetReveal;
  final EventSuccessHostFixtureActions? fixtureActions;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (!planIsPersisted) {
      final isPreEvent = event.startTime.isAfter(DateTime.now());
      return EventSuccessHostTabBody(
        embedded: embedded,
        children: [
          CatchSurface.message(
            messageIcon: isPreEvent
                ? CatchIcons.cloudUploadOutlined
                : CatchIcons.lockClockRounded,
            title: isPreEvent
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostLiveTitleLiveModeNeedsSaved
                : context
                      .l10n
                      .eventSuccessEventSuccessHostLiveTitleLiveModeWasNot,
            message: isPreEvent
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostLiveBodySaveTheLiveGuide
                : context
                      .l10n
                      .eventSuccessEventSuccessHostLiveBodyThisEventDidNot,
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
      return EventSuccessHostTabBody(
        embedded: embedded,
        children: [
          CatchSurface.message(
            messageIcon: CatchIcons.ruleFolderOutlined,
            title: context
                .l10n
                .eventSuccessEventSuccessHostLiveTitleNoLiveStepsSelected,
            message: context
                .l10n
                .eventSuccessEventSuccessHostLiveBodyThisSavedSetupDoes,
          ),
        ],
      );
    }
    final activeStepIndex = livePlan.activeStepIndex;
    final previousIndex = (activeStepIndex - 1)
        .clamp(0, livePlan.steps.length - 1)
        .toInt();
    final nextIndex = (activeStepIndex + 1)
        .clamp(0, livePlan.steps.length - 1)
        .toInt();
    final activeModuleIds = livePlan.activeStep.moduleIds.toSet();
    bool activeStepHas(String moduleId) => activeModuleIds.contains(moduleId);
    final conversationCueActive =
        activeStepHas(EventSuccessModuleCatalog.socialMissions.id) ||
        activeStepHas(EventSuccessModuleCatalog.contextualOpeners.id);

    Widget wingmanCard() => WingmanRequestsHostCard(
      requests: wingmanRequests,
      profiles: wingmanProfiles,
      rotationsEnabled: runtime.guidedRotationsEnabled,
    );

    Widget conversationCueCard() => EventSuccessConversationCueCard(
      title: context.l10n.eventSuccessEventSuccessHostLiveTitleConversationCues,
      subtitle: runtime.socialMissionsEnabled
          ? context.l10n.eventSuccessEventSuccessHostLiveSubtitleUseOneWhenThe
          : context
                .l10n
                .eventSuccessEventSuccessHostLiveSubtitleCloseWithOneSuggested,
      cues: runtime.socialMissionsEnabled
          ? EventSuccessConversationCueLibrary.liveCuesFor(
              event: event,
              plan: plan,
              l10n: context.l10n,
              activeStep: _activeRunOfShowStep(runtime),
            )
          : EventSuccessConversationCueLibrary.postEventOpenersFor(
              event,
              l10n: context.l10n,
            ),
    );

    Widget microPodsCard() => MicroPodsHostCard(
      event: event,
      assignments: assignments,
      participantProfiles: assignmentParticipantProfiles,
      preferences: preferences,
      actionState: microPodsGenerationState,
      onGenerate: onGenerateMicroPods,
      onOverride: onOverrideGroupAssignments,
    );

    Widget rotationsCard() => RotationsHostCard(
      event: event,
      rotationIntervalMinutes:
          plan.structureConfig.rotationIntervalMinutes ?? 15,
      assignments: rotationAssignments,
      participantProfiles: rotationParticipantProfiles,
      preferences: preferences,
      actionState: rotationsGenerationState,
      onGenerate: onGenerateGuidedRotations,
      onOverride: onOverrideGuidedRotations,
    );

    Widget liveRevealCard() => EventSuccessLiveRevealHostCard(
      event: event,
      plan: plan,
      podAssignments: assignments,
      rotationAssignments: rotationAssignments,
      preferences: preferences,
      participantProfiles: [
        ...rotationParticipantProfiles,
        ...assignmentParticipantProfiles,
      ],
      actionState: revealActionState,
      onStartCountdown: onStartRevealCountdown,
      onRevealRound: onRevealRound,
      onResetReveal: onResetReveal,
    );

    final liveRevealAvailable =
        runtime.liveRevealEnabled &&
        (runtime.guidedRotationsEnabled || runtime.microPodsEnabled);
    final currentStepCards = compactLiveControls
        ? <Widget>[]
        : <Widget>[
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
    final supportingCards = compactLiveControls
        ? <Widget>[]
        : <Widget>[
            if (runtime.compatibilityQuestionnaireEnabled)
              CompatibilitySignalHostCard(plan: plan),
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

    return EventSuccessHostTabBody(
      embedded: embedded,
      children: [
        if (actionState.stepError != null) ...[
          CatchErrorBanner.fromError(
            actionState.stepError!,
            context: AppErrorContext.event,
          ),
          gapH16,
        ],
        if (actionState.completeError != null) ...[
          CatchErrorBanner.fromError(
            actionState.completeError!,
            context: AppErrorContext.event,
          ),
          gapH16,
        ],
        LiveNowConsole(
          plan: livePlan,
          event: event,
          compactCopy: compactLiveControls,
          currentStepControls: currentStepCards,
          onPrevious:
              actionState.isChangingStep ||
                  activeStepIndex == 0 ||
                  onPreviousStep == null
              ? null
              : () => unawaited(onPreviousStep!(previousIndex)),
          onNext:
              actionState.isChangingStep ||
                  activeStepIndex >= livePlan.steps.length - 1 ||
                  onNextStep == null
              ? null
              : () => unawaited(onNextStep!(nextIndex)),
        ),
        if (supportingCards.isNotEmpty) ...[
          gapH20,
          CatchSectionHeader(
            padding: EdgeInsets.zero,
            title: context
                .l10n
                .eventSuccessEventSuccessHostLiveTitleSupportingControls,
            subtitle: context
                .l10n
                .eventSuccessEventSuccessHostLiveSubtitleControlsThatStayAvailable,
          ),
          gapH10,
          CatchSectionList(
            emptyStateOmitted: true,
            gap: CatchSpacing.s4,
            children: supportingCards,
          ),
        ],
        if (!compactLiveControls) ...[
          gapH20,
          CatchButton(
            label: context
                .l10n
                .eventSuccessEventSuccessHostLiveLabelMarkLiveGuideComplete,
            variant: CatchButtonVariant.secondary,
            isLoading: actionState.isCompleting,
            onPressed: actionState.isCompleting || onCompleteGuide == null
                ? null
                : () => unawaited(onCompleteGuide!()),
            fullWidth: true,
          ),
        ],
      ],
    );
  }
}

class LiveNowConsole extends StatelessWidget {
  const LiveNowConsole({
    super.key,
    required this.plan,
    required this.event,
    required this.compactCopy,
    required this.currentStepControls,
    required this.onPrevious,
    required this.onNext,
  });

  final EventSuccessLivePlan plan;
  final Event event;
  final bool compactCopy;
  final List<Widget> currentStepControls;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final total = plan.steps.length;
    final compactPresenter = compactCopy
        ? _CompactLiveConsolePresenter.forEvent(event, plan, context.l10n)
        : null;
    final activeStepTitle = compactPresenter?.title ?? plan.activeStep.title;
    final activeStepInstruction =
        compactPresenter?.instruction ?? plan.activeStep.hostInstruction;
    final attendeeExperience =
        compactPresenter?.attendeeExperience ??
        context.l10n
            .eventSuccessEventSuccessHostLiveVisiblecopyAttendeesAtLocationnameSee(
              locationName: event.locationName,
              attendeeExperience: plan.activeStep.attendeeExperience,
            );
    final stepLine =
        compactPresenter?.stepLine ??
        (total > 0
            ? context.l10n
                  .eventSuccessEventSuccessHostLiveVisiblecopyStepValue1TotalLabel(
                    value1: plan.activeStepIndex + 1,
                    total: total,
                    label: plan.activeStep.stage.label,
                  )
            : plan.activeStep.stage.label);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSection.contained(
          title: activeStepTitle,
          subtitle: activeStepInstruction,
          trailing: CatchBadge.live(
            label: context.l10n.eventSuccessEventSuccessHostLiveTextLiveNow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchStepProgress(
                currentStep: plan.activeStepIndex,
                totalSteps: total,
                label: stepLine,
                showCounter: false,
              ),
              gapH16,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CatchIcons.phoneIphoneRounded,
                    size: CatchIcon.md,
                    color: CatchTokens.of(context).ink2,
                  ),
                  gapW8,
                  Expanded(
                    child: Text(
                      attendeeExperience,
                      style: CatchTextStyles.supporting(
                        context,
                        color: CatchTokens.of(context).ink2,
                      ),
                    ),
                  ),
                ],
              ),
              gapH16,
              LiveStepNavigation(
                plan: plan,
                onPrevious: onPrevious,
                onNext: onNext,
              ),
            ],
          ),
        ),
        if (currentStepControls.isNotEmpty) ...[
          gapH14,
          CatchSectionHeader(
            padding: EdgeInsets.zero,
            title: context
                .l10n
                .eventSuccessEventSuccessHostLiveTitleControlsForThisStep,
            subtitle: context
                .l10n
                .eventSuccessEventSuccessHostLiveSubtitleHandleTheseBeforeMoving,
          ),
          gapH10,
          CatchSectionList(
            emptyStateOmitted: true,
            gap: CatchSpacing.s4,
            children: currentStepControls,
          ),
        ],
      ],
    );
  }
}

class _CompactLiveConsolePresenter {
  const _CompactLiveConsolePresenter({
    required this.stepLine,
    required this.title,
    required this.instruction,
    required this.attendeeExperience,
  });

  final String stepLine;
  final String title;
  final String instruction;
  final String attendeeExperience;

  static _CompactLiveConsolePresenter? forEvent(
    Event event,
    EventSuccessLivePlan plan,
    AppLocalizations l10n,
  ) {
    final stage = plan.activeStep.stage;
    final isRoundLike =
        event.eventFormat.interactionModel ==
            EventInteractionModel.teamRotations &&
        (stage == EventSuccessStage.activity ||
            stage == EventSuccessStage.mixing);
    if (!isRoundLike) return null;
    final total = plan.steps.length;
    final stepLine = total > 0
        ? l10n.eventSuccessEventSuccessHostLiveVisiblecopyStepValue1TotalRound(
            value1: plan.activeStepIndex + 1,
            total: total,
          )
        : l10n.eventSuccessEventSuccessHostLiveVisiblecopyRound;
    return _CompactLiveConsolePresenter(
      stepLine: stepLine,
      title: l10n.eventSuccessEventSuccessHostLiveTitleRoundInPlay,
      instruction:
          l10n.eventSuccessEventSuccessHostLiveVisiblecopyKeepRoundsTightReveal,
      attendeeExperience:
          l10n.eventSuccessEventSuccessHostLiveVisiblecopyAttendeesSeeGuestsSee,
    );
  }
}

class LiveStepNavigation extends StatelessWidget {
  const LiveStepNavigation({
    super.key,
    required this.plan,
    required this.onPrevious,
    required this.onNext,
  });

  final EventSuccessLivePlan plan;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final nextLabel = plan.activeStepIndex >= plan.steps.length - 1
        ? context.l10n.eventSuccessEventSuccessHostLiveVisiblecopyFinalStep
        : context.l10n.eventSuccessEventSuccessHostLiveVisiblecopyNextTitle(
            title: plan.steps[plan.activeStepIndex + 1].title,
          );
    return Row(
      children: [
        CatchButton(
          key: ValueKey(
            context
                .l10n
                .eventSuccessEventSuccessHostLiveCatchbuttonEventsuccesspreviousstepbutton,
          ),
          label: context.l10n.eventSuccessEventSuccessHostLiveLabelPrevious,
          icon: Icon(CatchIcons.arrowBackRounded),
          variant: CatchButtonVariant.ghost,
          onPressed: onPrevious,
        ),
        gapW10,
        Expanded(
          child: CatchButton(
            key: ValueKey(
              context
                  .l10n
                  .eventSuccessEventSuccessHostLiveCatchbuttonEventsuccessnextstepbutton,
            ),
            label: nextLabel,
            icon: Icon(CatchIcons.arrowForwardRounded),
            onPressed: onNext,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}
