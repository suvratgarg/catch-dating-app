part of '../event_success_host_screen.dart';

class _LiveTab extends ConsumerWidget {
  const _LiveTab({
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
  final List<PublicProfile> assignmentParticipantProfiles;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<PublicProfile> rotationParticipantProfiles;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> wingmanProfiles;
  final Widget? liveRoster;
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
            const _LiveSectionHeader(
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
      return ListView(
        shrinkWrap: shrinkWrap,
        primary: shrinkWrap ? false : null,
        physics: physics,
        padding: padding,
        children: [
          _NoticeCard(
            icon: CatchIcons.ruleFolderOutlined,
            title: 'No live steps selected',
            body:
                'This saved setup does not include any tools the host can use during the event.',
          ),
          if (liveRoster != null) ...[
            gapH16,
            const _LiveSectionHeader(
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

    Widget attendanceCard() => _LiveAttendanceSummaryCard(
      event: event,
      bookedCount: livePlan.bookedCount,
      checkedInCount: livePlan.checkedInCount,
      waitlistCount: roster.waitlistedCount,
    );

    Widget attendanceQrCard() => _LiveCheckInQrCard(event: event);

    final hasEmbeddedRoster = liveRoster != null;

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
      event: event,
      eventId: event.id,
      assignments: assignments,
      participantProfiles: assignmentParticipantProfiles,
      preferences: preferences,
      onGenerate: fixtureActions?.onGenerateMicroPods,
      onOverride: fixtureActions?.onOverrideGroupAssignments,
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
      participantProfiles: [
        ...rotationParticipantProfiles,
        ...assignmentParticipantProfiles,
      ],
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
    final supportingCards = <Widget>[
      if (runtime.checkInEnabled &&
          !activeStepHas(EventSuccessModuleCatalog.checkIn.id))
        hasEmbeddedRoster ? attendanceQrCard() : attendanceCard(),
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
          CatchErrorBanner.fromError(
            (mutation as MutationError).error,
            context: AppErrorContext.event,
          ),
          gapH16,
        ],
        if (completeMutation.hasError) ...[
          CatchErrorBanner.fromError(
            (completeMutation as MutationError).error,
            context: AppErrorContext.event,
          ),
          gapH16,
        ],
        _LiveNowConsole(
          plan: livePlan,
          event: event,
          liveRoster: liveRoster,
          currentStepControls: currentStepCards,
          onPrevious: mutation.isPending || activeStepIndex == 0
              ? null
              : () => _advanceStep(
                  ref,
                  event.id,
                  previousIndex,
                  fixtureActions?.onPreviousStep,
                ),
          onNext:
              mutation.isPending || activeStepIndex >= livePlan.steps.length - 1
              ? null
              : () => _advanceStep(
                  ref,
                  event.id,
                  nextIndex,
                  fixtureActions?.onNextStep,
                ),
        ),
        if (supportingCards.isNotEmpty) ...[
          gapH20,
          const _LiveSectionHeader(
            title: 'Supporting controls',
            subtitle:
                'Controls that stay available without competing with the current live step.',
          ),
          gapH10,
          CatchSectionList(gap: CatchSpacing.s4, children: supportingCards),
        ],
        gapH20,
        CatchButton(
          label: 'Mark live guide complete',
          variant: CatchButtonVariant.secondary,
          isLoading:
              fixtureActions?.onCompletePlan == null &&
              completeMutation.isPending,
          onPressed: completeMutation.isPending
              ? null
              : () => _completeGuide(
                  ref,
                  event.id,
                  fixtureActions?.onCompletePlan,
                ),
          fullWidth: true,
        ),
      ],
    );
  }

  void _advanceStep(
    WidgetRef ref,
    String eventId,
    int index,
    VoidCallback? fixtureAction,
  ) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.stepChange),
    );
    if (fixtureAction != null) {
      fixtureAction();
      return;
    }
    _setStep(ref, eventId, index);
  }

  void _setStep(WidgetRef ref, String eventId, int index) {
    EventSuccessController.updateStepMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .updateActiveStep(eventId: eventId, activeStepIndex: index),
    );
  }

  void _completeGuide(
    WidgetRef ref,
    String eventId,
    VoidCallback? fixtureAction,
  ) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.guideComplete),
    );
    if (fixtureAction != null) {
      fixtureAction();
      return;
    }
    EventSuccessController.completePlanMutation.run(
      ref,
      (tx) =>
          tx.get(eventSuccessControllerProvider.notifier).completePlan(eventId),
    );
  }
}

class _LiveNowConsole extends StatelessWidget {
  const _LiveNowConsole({
    required this.plan,
    required this.event,
    required this.liveRoster,
    required this.currentStepControls,
    required this.onPrevious,
    required this.onNext,
  });

  final EventSuccessLivePlan plan;
  final Event event;
  final Widget? liveRoster;
  final List<Widget> currentStepControls;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final fg = t.primaryInk;
    final total = plan.steps.length;
    final stepLine = total > 0
        ? 'Step ${plan.activeStepIndex + 1}/$total · ${plan.activeStep.stage.label}'
        : plan.activeStep.stage.label;
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
                  _LiveNowPill(foreground: fg, accent: t.gold),
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
                plan.activeStep.title,
                style: CatchTextStyles.consoleTitle(context, color: fg),
              ),
              gapH6,
              Text(
                plan.activeStep.hostInstruction,
                style: CatchTextStyles.bodyS(
                  context,
                  color: fg.withValues(
                    alpha: CatchOpacity.eventSuccessProminent,
                  ),
                ),
              ),
              gapH12,
              CatchSurface(
                padding: CatchInsets.contentDense,
                backgroundColor: fg.withValues(
                  alpha: CatchOpacity.photoScrimLight,
                ),
                borderColor: fg.withValues(alpha: CatchOpacity.subtleBorder),
                radius: CatchRadius.sm,
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
                        'Attendees at ${event.locationName} see: ${plan.activeStep.attendeeExperience}',
                        style: CatchTextStyles.bodyS(
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
            ],
          ),
        ),
        if (liveRoster != null) ...[
          gapH14,
          const _LiveSectionHeader(
            title: 'Editable roster',
            subtitle: 'Tap a booked attendee if their check-in state is wrong.',
          ),
          gapH10,
          liveRoster!,
        ],
        if (currentStepControls.isNotEmpty) ...[
          gapH14,
          const _LiveSectionHeader(
            title: 'Controls for this step',
            subtitle: 'Handle these before moving the room forward.',
          ),
          gapH10,
          CatchSectionList(gap: CatchSpacing.s4, children: currentStepControls),
        ],
        gapH14,
        _LiveStepNavigation(plan: plan, onPrevious: onPrevious, onNext: onNext),
      ],
    );
  }
}

class _LiveCheckInQrCard extends StatelessWidget {
  const _LiveCheckInQrCard({required this.event});

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
          _HostCheckInQrPanel(event: event),
        ],
      ),
    );
  }
}

/// The "LIVE NOW" status pill of the live console — a gold dot on a dim-fill
/// pill, per the design-system `LiveConsole` header.
class _LiveNowPill extends StatelessWidget {
  const _LiveNowPill({required this.foreground, required this.accent});

  final Color foreground;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: CatchOpacity.photoScrimMedium),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        border: Border.all(
          color: foreground.withValues(alpha: CatchOpacity.subtleBorder),
        ),
      ),
      child: Padding(
        padding: CatchInsets.compactLabelContent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
              child: const SizedBox.square(dimension: CatchSpacing.micro6),
            ),
            gapW6,
            Text(
              'Live now'.toUpperCase(),
              style: CatchTextStyles.badge(context, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveStepNavigation extends StatelessWidget {
  const _LiveStepNavigation({
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
        Text(title, style: CatchTextStyles.sectionTitle(context)),
        gapH4,
        Text(
          subtitle,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ],
    );
  }
}
