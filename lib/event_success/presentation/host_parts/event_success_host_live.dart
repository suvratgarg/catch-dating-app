part of '../event_success_host_screen.dart';

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
                ? 'Save the live guide before the event to enable guided controls. Attendance and check-in stay available from this Live tab.'
                : 'This event did not have a live guide saved before it started. Attendance and check-in remain available; guided live controls stay unavailable for this event.',
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
                'This saved setup does not include any tools the host can use during the event.',
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
      event: event,
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
        _LiveShowtimeConsole(plan: livePlan, event: event),
        gapH16,
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
                    : () => _advanceStep(
                        ref,
                        event.id,
                        previousIndex,
                        fixtureActions?.onPreviousStep,
                      ),
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
                    : () => _advanceStep(
                        ref,
                        event.id,
                        nextIndex,
                        fixtureActions?.onNextStep,
                      ),
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
                'Controls that stay available without competing with the current live step.',
          ),
          gapH10,
          ..._spacedCards(supportingCards),
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

class _LiveShowtimeConsole extends StatelessWidget {
  const _LiveShowtimeConsole({required this.plan, required this.event});

  final EventSuccessLivePlan plan;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      clipBehavior: Clip.antiAlias,
      borderWidth: 0,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          t.ink,
          Color.lerp(t.ink, t.primary, 0.52)!,
          Color.lerp(t.accent, t.gold, 0.18)!,
        ],
      ),
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: 'Showtime console',
                tone: CatchBadgeTone.live,
                icon: Icons.auto_awesome_rounded,
                backgroundColor: t.surface.withValues(alpha: 0.14),
                foregroundColor: t.surface,
                borderColor: t.surface.withValues(alpha: 0.18),
              ),
              CatchBadge(
                label: 'Step ${plan.activeStepIndex + 1}/${plan.steps.length}',
                tone: CatchBadgeTone.neutral,
                backgroundColor: t.surface.withValues(alpha: 0.12),
                foregroundColor: t.surface.withValues(alpha: 0.90),
                borderColor: t.surface.withValues(alpha: 0.16),
              ),
            ],
          ),
          gapH14,
          Text(
            plan.activeStep.title,
            style: CatchTextStyles.titleL(context, color: t.surface),
          ),
          gapH6,
          Text(
            plan.activeStep.hostInstruction,
            style: CatchTextStyles.bodyS(
              context,
              color: t.surface.withValues(alpha: 0.80),
            ),
          ),
          gapH12,
          Container(
            padding: const EdgeInsets.all(CatchSpacing.s3),
            decoration: BoxDecoration(
              color: t.surface.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(CatchRadius.sm),
              border: Border.all(color: t.surface.withValues(alpha: 0.14)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.phone_iphone_rounded,
                  size: 18,
                  color: t.surface.withValues(alpha: 0.82),
                ),
                gapW8,
                Expanded(
                  child: Text(
                    'Attendees at ${event.locationName} see: ${plan.activeStep.attendeeExperience}',
                    style: CatchTextStyles.bodyS(
                      context,
                      color: t.surface.withValues(alpha: 0.82),
                    ),
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
