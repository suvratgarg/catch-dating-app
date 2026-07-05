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
    this.liveRoster,
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
  final Widget? liveRoster;
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
          NoticeCard(
            icon: isPreEvent
                ? CatchIcons.cloudUploadOutlined
                : CatchIcons.lockClockRounded,
            title: isPreEvent
                ? 'Live mode needs saved setup'
                : 'Live mode was not configured',
            body: isPreEvent
                ? 'Save the live guide before the event to enable guided controls. Attendance and check-in stay available from this Live tab.'
                : 'This event did not have a live guide saved before it started. Attendance and check-in remain available; guided live controls stay unavailable for this event.',
          ),
          if (liveRoster != null) ...[
            gapH16,
            const CatchSectionHeader(
              padding: EdgeInsets.zero,
              title: 'Editable roster',
              subtitle:
                  'Tap a booked attendee if their check-in state is wrong.',
            ),
            gapH10,
            liveRoster!,
          ],
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
          NoticeCard(
            icon: CatchIcons.ruleFolderOutlined,
            title: 'No live steps selected',
            body:
                'This saved setup does not include any tools the host can use during the event.',
          ),
          if (liveRoster != null) ...[
            gapH16,
            const CatchSectionHeader(
              padding: EdgeInsets.zero,
              title: 'Editable roster',
              subtitle:
                  'Tap a booked attendee if their check-in state is wrong.',
            ),
            gapH10,
            liveRoster!,
          ],
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

    Widget attendanceCard() => LiveAttendanceSummaryCard(
      event: event,
      bookedCount: livePlan.bookedCount,
      checkedInCount: livePlan.checkedInCount,
      waitlistCount: roster.waitlistedCount,
    );

    Widget attendanceQrCard() => LiveCheckInQrCard(event: event);

    final hasEmbeddedRoster = liveRoster != null;

    Widget wingmanCard() => WingmanRequestsHostCard(
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
            if (runtime.checkInEnabled &&
                activeStepHas(EventSuccessModuleCatalog.checkIn.id))
              hasEmbeddedRoster ? attendanceQrCard() : attendanceCard(),
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
            if (runtime.checkInEnabled &&
                !activeStepHas(EventSuccessModuleCatalog.checkIn.id))
              hasEmbeddedRoster ? attendanceQrCard() : attendanceCard(),
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
        if (actionState.attendanceError != null) ...[
          CatchErrorBanner.fromError(
            actionState.attendanceError!,
            context: AppErrorContext.event,
          ),
          gapH16,
        ],
        LiveNowConsole(
          plan: livePlan,
          event: event,
          liveRoster: liveRoster,
          compactCopy: compactLiveControls,
          bookedCount: livePlan.bookedCount,
          checkedInCount: livePlan.checkedInCount,
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
          const CatchSectionHeader(
            padding: EdgeInsets.zero,
            title: 'Supporting controls',
            subtitle:
                'Controls that stay available without competing with the current live step.',
          ),
          gapH10,
          CatchSectionList(gap: CatchSpacing.s4, children: supportingCards),
        ],
        if (!compactLiveControls) ...[
          gapH20,
          CatchButton(
            label: 'Mark live guide complete',
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
    required this.liveRoster,
    required this.compactCopy,
    required this.bookedCount,
    required this.checkedInCount,
    required this.currentStepControls,
    required this.onPrevious,
    required this.onNext,
  });

  final EventSuccessLivePlan plan;
  final Event event;
  final Widget? liveRoster;
  final bool compactCopy;
  final int bookedCount;
  final int checkedInCount;
  final List<Widget> currentStepControls;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final fg = t.primaryInk;
    final total = plan.steps.length;
    final compactPresenter = compactCopy
        ? _CompactLiveConsolePresenter.forEvent(event, plan)
        : null;
    final activeStepTitle = compactPresenter?.title ?? plan.activeStep.title;
    final activeStepInstruction =
        compactPresenter?.instruction ?? plan.activeStep.hostInstruction;
    final attendeeExperience =
        compactPresenter?.attendeeExperience ??
        'Attendees at ${event.locationName} see: ${plan.activeStep.attendeeExperience}';
    final stepLine =
        compactPresenter?.stepLine ??
        (total > 0
            ? 'Step ${plan.activeStepIndex + 1}/$total · ${plan.activeStep.stage.label}'
            : plan.activeStep.stage.label);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSurface(
          clipBehavior: Clip.antiAlias,
          borderWidth: 0,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [t.ink, Color.lerp(t.ink, t.gold, 0.2)!],
          ),
          padding: CatchInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  LiveNowPill(foreground: fg, accent: t.gold),
                  gapW8,
                  Expanded(
                    child: Text(
                      stepLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.monoLabel(
                        context,
                        color: fg.withValues(alpha: CatchOpacity.onFillMuted),
                      ),
                    ),
                  ),
                ],
              ),
              gapH14,
              ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.pill),
                child: LinearProgressIndicator(
                  value: plan.runOfShowProgress.clamp(0, 1).toDouble(),
                  minHeight: 5,
                  backgroundColor: fg.withValues(
                    alpha: CatchOpacity.subtleBorder,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              ),
              gapH16,
              Text(
                activeStepTitle,
                style: CatchTextStyles.consoleTitle(context, color: fg),
              ),
              gapH6,
              Text(
                activeStepInstruction,
                style: CatchTextStyles.supporting(
                  context,
                  color: fg.withValues(
                    alpha: CatchOpacity.eventSuccessProminent,
                  ),
                ),
              ),
              gapH12,
              ColoredBox(
                color: fg.withValues(alpha: CatchOpacity.photoScrimLight),
                child: Padding(
                  padding: CatchInsets.contentDense,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CatchIcons.phoneIphoneRounded,
                        size: CatchIcon.md,
                        color: fg.withValues(
                          alpha: CatchOpacity.eventSuccessProminent,
                        ),
                      ),
                      gapW8,
                      Expanded(
                        child: Text(
                          attendeeExperience,
                          style: CatchTextStyles.supporting(
                            context,
                            color: fg.withValues(
                              alpha: CatchOpacity.eventSuccessProminent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        gapH14,
        LiveStepNavigation(plan: plan, onPrevious: onPrevious, onNext: onNext),
        gapH12,
        LiveCheckInSummaryStrip(
          bookedCount: bookedCount,
          checkedInCount: checkedInCount,
        ),
        if (liveRoster != null) ...[
          gapH14,
          const CatchSectionHeader(
            padding: EdgeInsets.zero,
            title: 'Editable roster',
            subtitle: 'Tap a booked attendee if their check-in state is wrong.',
          ),
          gapH10,
          liveRoster!,
        ],
        if (currentStepControls.isNotEmpty) ...[
          gapH14,
          const CatchSectionHeader(
            padding: EdgeInsets.zero,
            title: 'Controls for this step',
            subtitle: 'Handle these before moving the room forward.',
          ),
          gapH10,
          CatchSectionList(gap: CatchSpacing.s4, children: currentStepControls),
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
        ? 'Step ${plan.activeStepIndex + 1}/$total · Round'
        : 'Round';
    return _CompactLiveConsolePresenter(
      stepLine: stepLine,
      title: 'Round in play',
      instruction:
          'Keep rounds tight; reveal scores between each. Swap anyone sitting out into a team.',
      attendeeExperience:
          'Attendees see: Guests see the current round and the live scoreboard.',
    );
  }
}

class LiveCheckInSummaryStrip extends StatelessWidget {
  const LiveCheckInSummaryStrip({
    super.key,
    required this.bookedCount,
    required this.checkedInCount,
  });

  final int bookedCount;
  final int checkedInCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final arrivedLabel = bookedCount <= 0
        ? '$checkedInCount arrived'
        : '$checkedInCount of $bookedCount arrived';
    return CatchSurface(
      backgroundColor: t.ink,
      borderWidth: 0,
      radius: CatchRadius.md,
      padding: CatchInsets.eventSuccessLiveSummaryContent,
      child: Row(
        children: [
          Icon(CatchIcons.gridViewRounded, color: t.bg, size: CatchIcon.row),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check guests in',
                  style: CatchTextStyles.sectionTitle(context, color: t.bg),
                ),
                gapH2,
                Text(
                  arrivedLabel,
                  style: CatchTextStyles.supporting(
                    context,
                    color: t.bg.withValues(
                      alpha: CatchOpacity.eventSuccessProminent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          gapW12,
          Text(
            '$checkedInCount',
            style: CatchTextStyles.display(context, color: t.bg),
          ),
        ],
      ),
    );
  }
}

class LiveCheckInQrCard extends StatelessWidget {
  const LiveCheckInQrCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CatchIcons.qrCode2Rounded, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  'Host check-in QR',
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
            ],
          ),
          gapH8,
          Text(
            'Use this for new arrivals; use the editable roster above for manual fixes.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
          HostCheckInQrPanel(event: event),
        ],
      ),
    );
  }
}

/// The "LIVE NOW" status pill of the live console — a gold dot on a dim-fill
/// pill, per the design-system `LiveConsole` header.
class LiveNowPill extends StatelessWidget {
  const LiveNowPill({
    super.key,
    required this.foreground,
    required this.accent,
  });

  final Color foreground;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      radius: CatchRadius.pill,
      padding: CatchInsets.compactLabelContent,
      backgroundColor: foreground.withValues(
        alpha: CatchOpacity.photoScrimMedium,
      ),
      borderColor: foreground.withValues(alpha: CatchOpacity.subtleBorder),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchStatusDot(color: accent, size: CatchSpacing.micro6),
          gapW6,
          Text(
            'Live now'.toUpperCase(),
            style: CatchTextStyles.badge(context, color: foreground),
          ),
        ],
      ),
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
        ? 'Final step'
        : 'Next: ${plan.steps[plan.activeStepIndex + 1].title}';
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CatchButton(
            key: const ValueKey('eventSuccessPreviousStepButton'),
            label: 'Previous',
            icon: Icon(CatchIcons.arrowBackRounded),
            variant: CatchButtonVariant.secondary,
            onPressed: onPrevious,
            fullWidth: true,
          ),
        ),
        gapW10,
        Expanded(
          flex: 3,
          child: CatchButton(
            key: const ValueKey('eventSuccessNextStepButton'),
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
