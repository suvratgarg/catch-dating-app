part of '../event_success_host_screen.dart';

enum EventSuccessControlRoomSyncState {
  synced,
  syncing,
  failed,
  offline,
  conflict,
}

class LiveTab extends StatelessWidget {
  const LiveTab({
    super.key,
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.spatialLayout,
    required this.spatialLayoutState,
    required this.showRoomWorkspace,
    required this.roster,
    required this.assignments,
    required this.assignmentParticipantProfiles,
    required this.rotationAssignments,
    required this.rotationDraftAssignments,
    required this.rotationParticipantProfiles,
    required this.preferences,
    this.standings,
    this.presenceSummary,
    this.presenceError,
    this.accountabilityAttendees = const [],
    this.accountabilityError,
    this.loadingAccountability = false,
    this.resolvingAccountability = false,
    this.resolvingLateArrival = false,
    this.lateArrivalError,
    required this.wingmanRequests,
    required this.wingmanProfiles,
    required this.resourceFailures,
    required this.onRetryResource,
    required this.compactLiveControls,
    required this.operationalRosterSummary,
    required this.onOpenGuests,
    required this.actionState,
    required this.onPreviousStep,
    required this.onNextStep,
    required this.onCompleteGuide,
    this.onResolveAccountability,
    required this.microPodsGenerationState,
    required this.rotationsGenerationState,
    required this.onGenerateMicroPods,
    required this.onGenerateGuidedRotations,
    this.onResolveLateArrival,
    required this.onPublishGuidedRotationRound,
    required this.onOverrideGroupAssignments,
    required this.onOverrideGuidedRotations,
    required this.onPreviewSpatial,
    required this.onReassignSpatial,
    required this.onConfirmSpatial,
    required this.onReleaseSpatial,
    required this.revealActionState,
    required this.onStartRevealCountdown,
    required this.onRevealRound,
    required this.onResetReveal,
    required this.outcomeActionState,
    required this.onRecordOutcomes,
    required this.fixtureActions,
    required this.exclusionAlertThreshold,
    this.exclusionReferenceNow,
    required this.embedded,
    this.referenceNow,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventSuccessLayout? spatialLayout;
  final EventSuccessSpatialLayoutState spatialLayoutState;
  final bool showRoomWorkspace;
  final EventParticipationRoster roster;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> assignmentParticipantProfiles;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<EventSuccessAssignment> rotationDraftAssignments;
  final List<PublicProfile> rotationParticipantProfiles;
  final List<EventSuccessPreference> preferences;
  final EventSuccessStandings? standings;
  final EventSuccessPresenceSummary? presenceSummary;
  final Object? presenceError;
  final List<EventAttendee> accountabilityAttendees;
  final Object? accountabilityError;
  final bool loadingAccountability;
  final bool resolvingAccountability;
  final bool resolvingLateArrival;
  final Object? lateArrivalError;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> wingmanProfiles;
  final List<EventSuccessHostResourceFailure> resourceFailures;
  final ValueChanged<EventSuccessHostRetryIntent>? onRetryResource;
  final bool compactLiveControls;
  final EventSuccessOperationalRosterSummary? operationalRosterSummary;
  final VoidCallback? onOpenGuests;
  final EventSuccessLiveActionState actionState;
  final Future<void> Function(int stepIndex)? onPreviousStep;
  final Future<void> Function(int stepIndex)? onNextStep;
  final Future<void> Function(bool accountabilityAcknowledged)? onCompleteGuide;
  final Future<void> Function(
    String attendeeId,
    EventSuccessAccountabilityResolution? resolution,
  )?
  onResolveAccountability;
  final EventSuccessAssignmentGenerationActionState microPodsGenerationState;
  final EventSuccessAssignmentGenerationActionState rotationsGenerationState;
  final Future<void> Function()? onGenerateMicroPods;
  final Future<void> Function()? onGenerateGuidedRotations;
  final Future<void> Function(String uid)? onResolveLateArrival;
  final Future<void> Function(int roundIndex)? onPublishGuidedRotationRound;
  final Future<void> Function(List<EventSuccessGroupOverrideRound> rounds)?
  onOverrideGroupAssignments;
  final Future<void> Function(List<EventSuccessRotationOverrideRound> rounds)?
  onOverrideGuidedRotations;
  final EventSuccessSpatialPreview? onPreviewSpatial;
  final EventSuccessSpatialReassign? onReassignSpatial;
  final Future<void> Function(EventSuccessAssignment assignment)?
  onConfirmSpatial;
  final Future<void> Function(EventSuccessAssignment assignment)?
  onReleaseSpatial;
  final EventSuccessRevealActionState revealActionState;
  final Future<void> Function(int roundIndex, int countdownSeconds)?
  onStartRevealCountdown;
  final Future<void> Function(int roundIndex)? onRevealRound;
  final Future<void> Function()? onResetReveal;
  final EventSuccessOutcomeActionState outcomeActionState;
  final Future<void> Function({
    required int expectedRevision,
    required int roundIndex,
    required List<EventSuccessUnitOutcomeEntryInput> entries,
  })?
  onRecordOutcomes;
  final EventSuccessHostFixtureActions? fixtureActions;
  final Duration exclusionAlertThreshold;
  final DateTime? exclusionReferenceNow;
  final bool embedded;
  final DateTime? referenceNow;

  @override
  Widget build(BuildContext context) {
    if (!planIsPersisted) {
      final isPreEvent = event.startTime.isAfter(
        referenceNow ?? DateTime.now(),
      );
      final body = EventSuccessHostTabBody(
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
      return compactLiveControls
          ? SingleChildScrollView(padding: CatchInsets.pageBody, child: body)
          : body;
    }

    final runtime = EventSuccessRuntime(
      plan: plan,
      event: event,
      now: referenceNow ?? DateTime.now(),
    );
    final eventSuccessProfile = EventSuccessActivityProfile.forFormat(
      event.eventFormat,
    );
    final accountability = eventSuccessProfile.accountability;
    final checkedInAccountabilityAttendees = accountabilityAttendees
        .where((attendee) => attendee.isCheckedIn)
        .toList(growable: false);
    final unresolvedAccountabilityAttendees = checkedInAccountabilityAttendees
        .where((attendee) => attendee.currentAccountabilityResolution == null)
        .toList(growable: false);
    final livePlan = runtime.livePlan(
      bookedCount: roster.bookedCount == 0
          ? event.signedUpCount
          : roster.bookedCount,
      checkedInCount: roster.checkedInCount == 0
          ? event.attendedCount
          : roster.checkedInCount,
    );
    if (livePlan == null) {
      final body = EventSuccessHostTabBody(
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
      return compactLiveControls
          ? SingleChildScrollView(padding: CatchInsets.pageBody, child: body)
          : body;
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
      assignments: rotationDraftAssignments.isNotEmpty
          ? rotationDraftAssignments
          : rotationAssignments,
      participantProfiles: rotationParticipantProfiles,
      preferences: preferences,
      actionState: rotationsGenerationState,
      onGenerate: onGenerateGuidedRotations,
      nextRoundIndex: plan.publishedRotationRoundIndex + 1,
      onPublish: onPublishGuidedRotationRound,
      onOverride: onOverrideGuidedRotations,
    );

    Widget? presenceCard() {
      final summary = presenceSummary;
      if (summary == null &&
          presenceError == null &&
          lateArrivalError == null) {
        return null;
      }
      if (summary != null &&
          summary.likelyDeparted.isEmpty &&
          summary.lateArrivals.isEmpty &&
          presenceError == null &&
          lateArrivalError == null) {
        return null;
      }
      return _EventSuccessPresenceCard(
        summary: summary,
        presenceError: presenceError,
        lateArrivalError: lateArrivalError,
        resolvingLateArrival: resolvingLateArrival,
        onRegenerate: onGenerateGuidedRotations,
        onResolveLateArrival: onResolveLateArrival,
      );
    }

    Widget? accountabilityCard() =>
        accountability != EventSuccessAccountability.sweep
        ? null
        : EventSuccessAccountabilityCard(
            attendees: checkedInAccountabilityAttendees,
            isLoading: loadingAccountability,
            isResolving: resolvingAccountability,
            error: accountabilityError,
            onResolve: onResolveAccountability,
          );

    Future<void> completeGuide() async {
      final complete = onCompleteGuide;
      if (complete == null) return;
      if (accountability != EventSuccessAccountability.sweep ||
          unresolvedAccountabilityAttendees.isEmpty) {
        await complete(false);
        return;
      }
      final finishAnyway = await showCatchAdaptiveDialog<bool>(
        context: context,
        title: context.l10n.eventSuccessAccountabilityWarningTitle,
        message: context.l10n.eventSuccessAccountabilityWarningMessage(
          count: unresolvedAccountabilityAttendees.length,
        ),
        actions: [
          CatchDialogAction(
            label: context.l10n.eventSuccessAccountabilityReviewAction,
            value: false,
          ),
          CatchDialogAction(
            label: context.l10n.eventSuccessAccountabilityFinishAnywayAction,
            value: true,
            isDefault: true,
          ),
        ],
      );
      if (finishAnyway == true) await complete(true);
    }

    Widget liveRevealCard() => EventSuccessLiveRevealHostCard(
      event: event,
      plan: plan,
      podAssignments: assignments,
      rotationAssignments: rotationAssignments,
      preferences: preferences,
      standings: standings,
      outcomeUnits: _eventSuccessOutcomeUnits(
        event: event,
        plan: plan,
        assignments: assignments,
        rotationAssignments: rotationAssignments,
        operationalAttendees: accountabilityAttendees,
        profiles: [
          ...rotationParticipantProfiles,
          ...assignmentParticipantProfiles,
        ],
      ),
      participantProfiles: [
        ...rotationParticipantProfiles,
        ...assignmentParticipantProfiles,
      ],
      actionState: revealActionState,
      onStartCountdown: onStartRevealCountdown,
      onRevealRound: onRevealRound,
      onResetReveal: onResetReveal,
      outcomeActionState: outcomeActionState,
      onRecordOutcomes: onRecordOutcomes,
    );

    final spatialAssignments =
        activeStepHas(EventSuccessModuleCatalog.guidedRotations.id) &&
            rotationAssignments.isNotEmpty
        ? rotationAssignments
        : assignments;
    final spatialProfiles = identical(spatialAssignments, rotationAssignments)
        ? rotationParticipantProfiles
        : assignmentParticipantProfiles;
    final exclusionSnapshot = buildEventSuccessExclusionLedger(
      attendeeUids: roster.checkedInIds,
      assignments: [...assignments, ...rotationAssignments],
      trackingStartedAt: event.startTime,
      trackingStartedAtByUid: roster.checkedInAtByUid,
      trackingEndedAt: event.endTime,
      now: exclusionReferenceNow ?? referenceNow ?? DateTime.now(),
      alertThreshold: exclusionAlertThreshold,
    );
    Widget? spatialMapCard() =>
        spatialLayout == null || spatialAssignments.isEmpty
        ? null
        : EventSuccessRoomMap(
            layout: spatialLayout!,
            assignments: spatialAssignments,
            profiles: spatialProfiles,
            exclusionAlertUids: exclusionSnapshot.alertEntries
                .map((entry) => entry.uid)
                .toSet(),
            onPreview: onPreviewSpatial,
            onReassign: onReassignSpatial,
            onConfirmPosition: onConfirmSpatial,
            onReleasePinned: onReleaseSpatial,
            initialSelectedUid: fixtureActions?.initialSpatialSelectionUid,
          );

    if (showRoomWorkspace) {
      final effectiveSpatialLayoutState =
          spatialLayoutState.status ==
                  EventSuccessSpatialLayoutStatus.notApplicable &&
              plan.structureConfig.unitKind != EventSuccessUnitKind.wholeGroup
          ? spatialLayout == null
                ? const EventSuccessSpatialLayoutState.unconfigured()
                : EventSuccessSpatialLayoutState.ready(spatialLayout!)
          : spatialLayoutState;
      final roomBody = switch (effectiveSpatialLayoutState.status) {
        EventSuccessSpatialLayoutStatus.notApplicable => CatchSurface.message(
          messageIcon: CatchIcons.gridViewRounded,
          title: context.l10n.eventSuccessRoomWorkspaceWholeGroupTitle,
          message: context.l10n.eventSuccessRoomWorkspaceWholeGroupBody,
        ),
        EventSuccessSpatialLayoutStatus.unconfigured => CatchSurface.message(
          messageIcon: CatchIcons.gridViewRounded,
          messageTone: CatchSurfaceMessageTone.warning,
          title: context.l10n.eventSuccessRoomWorkspaceUnconfiguredTitle,
          message: context.l10n.eventSuccessRoomWorkspaceUnconfiguredBody,
        ),
        EventSuccessSpatialLayoutStatus.loading => CatchSurface.message(
          messageIcon: CatchIcons.syncRounded,
          title: context.l10n.eventSuccessRoomWorkspaceLoadingTitle,
          message: context.l10n.eventSuccessRoomWorkspaceLoadingBody,
        ),
        EventSuccessSpatialLayoutStatus.error => EventSuccessHostResourceError(
          failure: EventSuccessHostResourceFailure(
            retryIntent: EventSuccessHostRetryIntent.spatialLayout,
            error: effectiveSpatialLayoutState.error!,
          ),
          onRetry: onRetryResource == null
              ? null
              : () =>
                    onRetryResource!(EventSuccessHostRetryIntent.spatialLayout),
        ),
        EventSuccessSpatialLayoutStatus.ready => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EventSuccessRoomWorkspaceSummary(
              layout: effectiveSpatialLayoutState.layout!,
              assignments: spatialAssignments,
              attentionCount: exclusionSnapshot.alertEntries.length,
            ),
            gapH16,
            EventSuccessRoomMap(
              layout: effectiveSpatialLayoutState.layout!,
              assignments: spatialAssignments,
              profiles: spatialProfiles,
              exclusionAlertUids: exclusionSnapshot.alertEntries
                  .map((entry) => entry.uid)
                  .toSet(),
              onPreview: onPreviewSpatial,
              onReassign: onReassignSpatial,
              onConfirmPosition: onConfirmSpatial,
              onReleasePinned: onReleaseSpatial,
              initialSelectedUid: fixtureActions?.initialSpatialSelectionUid,
              showHeader: false,
            ),
            if (spatialAssignments.isEmpty) ...[
              gapH16,
              CatchSurface.message(
                messageIcon: CatchIcons.groupsOutlined,
                title: context.l10n.eventSuccessRoomWorkspaceWaitingTitle,
                message: context.l10n.eventSuccessRoomWorkspaceWaitingBody,
              ),
            ],
          ],
        ),
      };
      return ColoredBox(
        color: CatchTokens.of(context).surface,
        child: SingleChildScrollView(
          padding: CatchInsets.pageBody,
          child: roomBody,
        ),
      );
    }

    final outcomeUsesStandings =
        eventSuccessProfile.unitOutcome == EventSuccessUnitOutcome.score ||
        (eventSuccessProfile.unitOutcome == EventSuccessUnitOutcome.rank &&
            eventSuccessProfile.assignmentResolution.supported);
    final liveRevealAvailable =
        runtime.liveRevealEnabled &&
        (outcomeUsesStandings ||
            runtime.guidedRotationsEnabled ||
            runtime.microPodsEnabled);
    final currentStepCards = compactLiveControls
        ? <Widget>[?accountabilityCard(), ?presenceCard(), ?spatialMapCard()]
        : <Widget>[
            ?accountabilityCard(),
            ?presenceCard(),
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
            ?spatialMapCard(),
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

    final actionFailed =
        actionState.stepError != null || actionState.completeError != null;
    final exclusionAlert = _EventSuccessExclusionAlertCard(
      attendeeUids: roster.checkedInIds,
      trackingStartedAtByUid: roster.checkedInAtByUid,
      assignments: [...assignments, ...rotationAssignments],
      trackingStartedAt: event.startTime,
      trackingEndedAt: event.endTime,
      alertThreshold: exclusionAlertThreshold,
      referenceNow: exclusionReferenceNow,
    );
    final console = LiveNowConsole(
      plan: livePlan,
      event: event,
      compactCopy: compactLiveControls,
      currentStepControls: currentStepCards,
      operationalRosterSummary: operationalRosterSummary,
      syncState: actionFailed
          ? EventSuccessControlRoomSyncState.failed
          : actionState.isChangingStep || actionState.isCompleting
          ? EventSuccessControlRoomSyncState.syncing
          : EventSuccessControlRoomSyncState.synced,
      isPrimaryLoading: actionState.isChangingStep || actionState.isCompleting,
      exclusionAlert: exclusionAlert,
      onOpenGuests: onOpenGuests,
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
      onComplete:
          compactLiveControls &&
              !actionState.isCompleting &&
              onCompleteGuide != null
          ? () => unawaited(completeGuide())
          : null,
    );
    final errorBanners = <Widget>[
      for (final failure in resourceFailures)
        if (failure.retryIntent != EventSuccessHostRetryIntent.scorecard)
          EventSuccessHostResourceError(
            failure: failure,
            onRetry: onRetryResource == null
                ? null
                : () => onRetryResource!(failure.retryIntent),
            compact: compactLiveControls,
          ),
      if (actionState.stepError != null)
        CatchErrorBanner.fromError(
          actionState.stepError!,
          context: AppErrorContext.event,
        ),
      if (actionState.completeError != null)
        CatchErrorBanner.fromError(
          actionState.completeError!,
          context: AppErrorContext.event,
        ),
    ];
    if (compactLiveControls) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (errorBanners.isNotEmpty)
            Padding(
              padding: CatchInsets.pageHorizontal.copyWith(
                top: CatchSpacing.s3,
                bottom: CatchSpacing.s2,
              ),
              child: CatchSectionList(
                emptyStateOmitted: true,
                gap: CatchSpacing.s2,
                children: errorBanners,
              ),
            ),
          Expanded(child: console),
        ],
      );
    }

    return EventSuccessHostTabBody(
      embedded: embedded,
      children: [
        ...errorBanners.expand((banner) => [banner, gapH16]),
        console,
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
                : () => unawaited(completeGuide()),
            fullWidth: true,
          ),
        ],
      ],
    );
  }
}

class _EventSuccessRoomWorkspaceSummary extends StatelessWidget {
  const _EventSuccessRoomWorkspaceSummary({
    required this.layout,
    required this.assignments,
    required this.attentionCount,
  });

  final EventSuccessLayout layout;
  final List<EventSuccessAssignment> assignments;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    final placedCount = assignments
        .where((assignment) => assignment.layoutUnitId != null)
        .length;
    final confirmedCount = assignments
        .where((assignment) => assignment.confirmedLayoutUnitId != null)
        .length;
    final unconfirmedCount = math.max(0, placedCount - confirmedCount);
    final seatCount = layout.units.fold<int>(
      0,
      (total, unit) => total + unit.capacity,
    );
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.eventSuccessRoomWorkspaceCapacitySummary(
              units: _eventSuccessRoomUnitCountLabel(context, layout),
              seats: seatCount,
            ),
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CatchStatColumn(
                  value: '$placedCount',
                  label: context.l10n.eventSuccessRoomWorkspacePlaced,
                  center: true,
                ),
              ),
              VerticalDivider(color: t.line, width: CatchSpacing.s3),
              Expanded(
                child: CatchStatColumn(
                  value: '$unconfirmedCount',
                  label: context.l10n.eventSuccessRoomWorkspaceUnconfirmed,
                  center: true,
                  highlight: unconfirmedCount > 0,
                ),
              ),
              VerticalDivider(color: t.line, width: CatchSpacing.s3),
              Expanded(
                child: CatchStatColumn(
                  value: '$attentionCount',
                  label: context.l10n.eventSuccessRoomWorkspaceNeedsAttention,
                  center: true,
                  highlight: attentionCount > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _eventSuccessRoomUnitCountLabel(
  BuildContext context,
  EventSuccessLayout layout,
) {
  final count = layout.units.length;
  final shapes = layout.units.map((unit) => unit.shape).toSet();
  if (shapes.every(
    (shape) =>
        shape == EventSuccessLayoutShape.round ||
        shape == EventSuccessLayoutShape.rect,
  )) {
    return context.l10n.eventSuccessRoomWorkspaceTableCount(count: count);
  }
  if (shapes.length == 1) {
    return switch (shapes.single) {
      EventSuccessLayoutShape.row =>
        context.l10n.eventSuccessRoomWorkspaceRowCount(count: count),
      EventSuccessLayoutShape.court =>
        context.l10n.eventSuccessRoomWorkspaceCourtCount(count: count),
      EventSuccessLayoutShape.zone =>
        context.l10n.eventSuccessRoomWorkspaceZoneCount(count: count),
      EventSuccessLayoutShape.round || EventSuccessLayoutShape.rect =>
        context.l10n.eventSuccessRoomWorkspaceTableCount(count: count),
    };
  }
  return context.l10n.eventSuccessRoomWorkspaceAreaCount(count: count);
}

enum _EventSuccessAccountabilitySelection { unresolved, returned, departed }

class EventSuccessAccountabilityCard extends StatelessWidget {
  const EventSuccessAccountabilityCard({
    super.key,
    required this.attendees,
    required this.isLoading,
    required this.isResolving,
    required this.error,
    required this.onResolve,
  });

  final List<EventAttendee> attendees;
  final bool isLoading;
  final bool isResolving;
  final Object? error;
  final Future<void> Function(
    String attendeeId,
    EventSuccessAccountabilityResolution? resolution,
  )?
  onResolve;

  @override
  Widget build(BuildContext context) {
    final resolvedCount = attendees
        .where((attendee) => attendee.currentAccountabilityResolution != null)
        .length;
    return CatchSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSectionHeader(
            padding: EdgeInsets.zero,
            title: context.l10n.eventSuccessAccountabilityTitle,
            subtitle: context.l10n.eventSuccessAccountabilitySubtitle,
          ),
          gapH8,
          Text(
            context.l10n.eventSuccessAccountabilityProgress(
              resolved: resolvedCount,
              total: attendees.length,
            ),
            style: CatchTextStyles.supporting(context),
          ),
          if (error != null) ...[
            gapH10,
            CatchErrorBanner.fromError(error!, context: AppErrorContext.event),
          ],
          if (isLoading && attendees.isEmpty) ...[
            gapH12,
            CatchSkeleton.text(width: CatchLayout.skeletonTextSectionWideWidth),
          ] else if (attendees.isEmpty) ...[
            gapH12,
            Text(
              context.l10n.eventSuccessAccountabilityEmpty,
              style: CatchTextStyles.supporting(context),
            ),
          ] else ...[
            gapH8,
            CatchSection.fieldRows(
              first: true,
              children: [
                for (final indexed in attendees.indexed)
                  CatchField.choices<_EventSuccessAccountabilitySelection>(
                    key: ValueKey(
                      'event_success.accountability.${indexed.$2.id}',
                    ),
                    title: indexed.$2.displayName,
                    body: _accountabilitySelectionLabel(
                      context,
                      _accountabilitySelection(indexed.$2),
                    ),
                    contract: CatchContractConstraints
                        .setEventSuccessAccountabilityResolutionCallablePayloadResolution,
                    contractValue: (value) => value.name,
                    values: _EventSuccessAccountabilitySelection.values,
                    itemLabel: (value) =>
                        _accountabilitySelectionLabel(context, value),
                    selected: {_accountabilitySelection(indexed.$2)},
                    onSelectionChanged: isResolving || onResolve == null
                        ? null
                        : (selection) {
                            final value = selection.firstOrNull;
                            if (value == null) return;
                            unawaited(
                              onResolve!(
                                indexed.$2.id,
                                _accountabilityResolution(value),
                              ),
                            );
                          },
                    isLoading: isResolving,
                    divider: indexed.$1 > 0,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

_EventSuccessAccountabilitySelection _accountabilitySelection(
  EventAttendee attendee,
) => switch (attendee.currentAccountabilityResolution) {
  EventSuccessAccountabilityResolution.returned =>
    _EventSuccessAccountabilitySelection.returned,
  EventSuccessAccountabilityResolution.departed =>
    _EventSuccessAccountabilitySelection.departed,
  null => _EventSuccessAccountabilitySelection.unresolved,
};

EventSuccessAccountabilityResolution? _accountabilityResolution(
  _EventSuccessAccountabilitySelection selection,
) => switch (selection) {
  _EventSuccessAccountabilitySelection.returned =>
    EventSuccessAccountabilityResolution.returned,
  _EventSuccessAccountabilitySelection.departed =>
    EventSuccessAccountabilityResolution.departed,
  _EventSuccessAccountabilitySelection.unresolved => null,
};

String _accountabilitySelectionLabel(
  BuildContext context,
  _EventSuccessAccountabilitySelection selection,
) => switch (selection) {
  _EventSuccessAccountabilitySelection.unresolved =>
    context.l10n.eventSuccessAccountabilityUnresolved,
  _EventSuccessAccountabilitySelection.returned =>
    context.l10n.eventSuccessAccountabilityReturned,
  _EventSuccessAccountabilitySelection.departed =>
    context.l10n.eventSuccessAccountabilityDeparted,
};

class _EventSuccessPresenceCard extends StatelessWidget {
  const _EventSuccessPresenceCard({
    required this.summary,
    required this.presenceError,
    required this.lateArrivalError,
    required this.resolvingLateArrival,
    required this.onRegenerate,
    required this.onResolveLateArrival,
  });

  final EventSuccessPresenceSummary? summary;
  final Object? presenceError;
  final Object? lateArrivalError;
  final bool resolvingLateArrival;
  final Future<void> Function()? onRegenerate;
  final Future<void> Function(String uid)? onResolveLateArrival;

  @override
  Widget build(BuildContext context) {
    final likelyDeparted = summary?.likelyDeparted ?? const [];
    final lateArrivals = summary?.lateArrivals ?? const [];
    return CatchSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSectionHeader(
            padding: EdgeInsets.zero,
            title:
                context.l10n.eventSuccessEventSuccessHostLiveTitleGuestPresence,
            subtitle: context
                .l10n
                .eventSuccessEventSuccessHostLiveSubtitlePresenceNeverChangesPublished,
          ),
          if (presenceError != null) ...[
            gapH10,
            CatchErrorBanner.fromError(
              presenceError!,
              context: AppErrorContext.event,
            ),
          ],
          if (likelyDeparted.isNotEmpty) ...[
            gapH12,
            Text(
              context.l10n
                  .eventSuccessEventSuccessHostLiveTextGuestsMayHaveLeft(
                    count: likelyDeparted.length,
                  ),
              style: CatchTextStyles.sectionTitle(context),
            ),
            gapH4,
            Text(
              likelyDeparted.map((entry) => entry.displayName).join(', '),
              style: CatchTextStyles.supporting(context),
            ),
            gapH10,
            CatchButton(
              label: context
                  .l10n
                  .eventSuccessEventSuccessHostLiveLabelRegenerateNextRound,
              onPressed: onRegenerate == null
                  ? null
                  : () => unawaited(onRegenerate!()),
              variant: CatchButtonVariant.secondary,
              size: CatchButtonSize.sm,
            ),
          ],
          if (lateArrivals.isNotEmpty) ...[
            gapH16,
            Text(
              context.l10n.eventSuccessEventSuccessHostLiveTitleLateArrivals,
              style: CatchTextStyles.sectionTitle(context),
            ),
            gapH4,
            ...lateArrivals.map(
              (candidate) => Padding(
                padding: CatchInsets.controlVerticalTight,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        candidate.displayName,
                        style: CatchTextStyles.name(context),
                      ),
                    ),
                    gapW8,
                    CatchButton(
                      label: context
                          .l10n
                          .eventSuccessEventSuccessHostLiveLabelPlaceNextRound,
                      size: CatchButtonSize.sm,
                      isLoading: resolvingLateArrival,
                      onPressed:
                          resolvingLateArrival || onResolveLateArrival == null
                          ? null
                          : () =>
                                unawaited(onResolveLateArrival!(candidate.uid)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (lateArrivalError != null) ...[
            gapH10,
            CatchErrorBanner.fromError(
              lateArrivalError!,
              context: AppErrorContext.event,
            ),
          ],
        ],
      ),
    );
  }
}

List<EventSuccessOutcomeUnit> _eventSuccessOutcomeUnits({
  required Event event,
  required EventSuccessPlan plan,
  required List<EventSuccessAssignment> assignments,
  required List<EventSuccessAssignment> rotationAssignments,
  required List<EventAttendee> operationalAttendees,
  required List<PublicProfile> profiles,
}) {
  final outcome = EventSuccessActivityProfile.forFormat(
    event.eventFormat,
  ).unitOutcome;
  if (outcome == EventSuccessUnitOutcome.score) {
    final units = <String, EventSuccessOutcomeUnit>{};
    final unitLabels = <String>{};
    for (final assignment in assignments) {
      final unitKey = assignment.unitIndex?.toString() ?? assignment.label;
      final label = _boundedOutcomeLabel(
        assignment.unitLabel ?? assignment.label,
      );
      units.putIfAbsent(
        unitKey,
        () => EventSuccessOutcomeUnit(
          id: _safeOutcomeUnitId('${assignment.moduleId}_unit_$unitKey'),
          label: label,
        ),
      );
      unitLabels.add(_normalizedOutcomeLabelKey(label));
    }
    for (final attendee in operationalAttendees) {
      if (!attendee.isCheckedIn) continue;
      final arrivalGroup = attendee.arrivalGroup;
      if (arrivalGroup == null) continue;
      final label = _boundedOutcomeLabel(arrivalGroup);
      final labelKey = _normalizedOutcomeLabelKey(label);
      if (labelKey.isEmpty || !unitLabels.add(labelKey)) continue;
      units['arrival_group_$labelKey'] = EventSuccessOutcomeUnit(
        id: _safeOutcomeUnitId('arrival_group_$labelKey'),
        label: label,
      );
    }
    final result = units.values.toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    return result;
  }
  if (outcome == EventSuccessUnitOutcome.rank) {
    final targetRound = plan.publishedRotationRoundIndex < 0
        ? 0
        : plan.publishedRotationRoundIndex;
    final profilesByUid = {
      for (final profile in profiles) profile.uid: profile,
    };
    final units = <String, EventSuccessOutcomeUnit>{};
    for (final assignment in rotationAssignments) {
      for (final slot in assignment.rotationSlots) {
        if (slot.roundIndex != targetRound) continue;
        final uids = [assignment.uid, slot.peerUid]..sort();
        final pairKey = slot.slotId ?? uids.join('_');
        units.putIfAbsent(
          pairKey,
          () => EventSuccessOutcomeUnit(
            id: _safeOutcomeUnitId('round_${targetRound}_$pairKey'),
            label: _boundedOutcomeLabel(
              '${profilesByUid[uids[0]]?.name ?? 'Guest'} + '
              '${profilesByUid[uids[1]]?.name ?? 'Guest'}',
            ),
          ),
        );
      }
    }
    final result = units.values.toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    return result;
  }
  return const [];
}

String _safeOutcomeUnitId(String value) {
  final normalized = value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  final safe = normalized.isEmpty ? 'unit' : normalized;
  return safe.length <= 120 ? safe : safe.substring(0, 120);
}

String _boundedOutcomeLabel(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  final trimmed = normalized.isEmpty ? 'Unit' : normalized;
  return trimmed.length <= 80 ? trimmed : trimmed.substring(0, 80);
}

String _normalizedOutcomeLabelKey(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

class LiveNowConsole extends StatelessWidget {
  const LiveNowConsole({
    super.key,
    required this.plan,
    required this.event,
    required this.compactCopy,
    required this.currentStepControls,
    required this.onPrevious,
    required this.onNext,
    this.onComplete,
    this.onOpenGuests,
    this.operationalRosterSummary,
    this.syncState = EventSuccessControlRoomSyncState.synced,
    this.isPrimaryLoading = false,
    this.exclusionAlert,
  });

  final EventSuccessLivePlan plan;
  final Event event;
  final bool compactCopy;
  final List<Widget> currentStepControls;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onComplete;
  final VoidCallback? onOpenGuests;
  final EventSuccessOperationalRosterSummary? operationalRosterSummary;
  final EventSuccessControlRoomSyncState syncState;
  final bool isPrimaryLoading;
  final Widget? exclusionAlert;

  @override
  Widget build(BuildContext context) {
    final total = plan.steps.length;
    final t = CatchTokens.of(context);
    final accent = ActivityPalette.resolve(context, event.activityKind).accent;
    final isFinalStep = plan.activeStepIndex >= total - 1;
    final nextStepTitle = isFinalStep
        ? context.l10n.eventSuccessEventSuccessHostLiveVisiblecopyFinalStep
        : _runOfShowStepLabel(context, plan, plan.activeStepIndex + 1);
    final primaryLabel = isFinalStep
        ? context
              .l10n
              .eventSuccessEventSuccessHostLiveLabelMarkLiveGuideComplete
        : context.l10n.eventSuccessControlRoomContinueTo(title: nextStepTitle);
    final primaryAction = isFinalStep ? onComplete : onNext;
    final checkedInCount =
        operationalRosterSummary?.checkedInCount ?? plan.checkedInCount;
    final expectedCount = operationalRosterSummary == null
        ? plan.bookedCount
        : operationalRosterSummary!.expectedCount;
    final attendeeExperience = context.l10n
        .eventSuccessEventSuccessHostLiveVisiblecopyAttendeesAtLocationnameSee(
          locationName: event.locationName,
          attendeeExperience: plan.activeStep.attendeeExperience,
        );

    final guestSummary = expectedCount == null
        ? context.l10n.eventSuccessControlRoomGuestsCheckedInOnly(
            checkedIn: checkedInCount,
          )
        : context.l10n.eventSuccessControlRoomGuestsSummary(
            checkedIn: checkedInCount,
            expected: expectedCount,
          );
    Widget controlRoomBody({required bool showVenue}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ControlRoomStage(
          event: event,
          plan: plan,
          syncState: syncState,
          nextStepTitle: nextStepTitle,
          attendeeExperience: compactCopy ? null : attendeeExperience,
          showVenue: showVenue,
        ),
        ?exclusionAlert,
        DecoratedBox(
          decoration: BoxDecoration(color: t.surface),
          child: CatchSection.fieldRows(
            children: [
              CatchField.nav(
                icon: CatchIcons.groupsOutlined,
                title: context.l10n.eventSuccessControlRoomGuests,
                body: guestSummary,
                onTap: onOpenGuests,
              ),
              CatchField.nav(
                icon: CatchIcons.helpOutlineRounded,
                title: context.l10n.eventSuccessControlRoomHelpFallback,
                body: context.l10n.eventSuccessControlRoomHelpFallbackSubtitle,
                onTap: () => unawaited(_showControlRoomFallback(context)),
              ),
            ],
          ),
        ),
        if (compactCopy && currentStepControls.isNotEmpty)
          Padding(
            padding: CatchInsets.pageBody,
            child: CatchSectionList(
              emptyStateOmitted: true,
              gap: CatchSpacing.s4,
              children: currentStepControls,
            ),
          ),
      ],
    );

    final previousAction = CatchIconButton.icon(
      key: ValueKey(
        context
            .l10n
            .eventSuccessEventSuccessHostLiveCatchbuttonEventsuccesspreviousstepbutton,
      ),
      icon: CatchIcons.arrowBackRounded,
      onTap: onPrevious,
      tooltip: context.l10n.eventSuccessEventSuccessHostLiveLabelPrevious,
    );

    if (compactCopy) {
      return ColoredBox(
        color: t.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: controlRoomBody(showVenue: true),
              ),
            ),
            CatchBottomAction(
              label: primaryLabel,
              onPressed: primaryAction,
              isLoading: isPrimaryLoading,
              buttonAccentColor: accent,
              buttonKey: ValueKey(
                context
                    .l10n
                    .eventSuccessEventSuccessHostLiveCatchbuttonEventsuccessnextstepbutton,
              ),
              leadingContent: previousAction,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        controlRoomBody(showVenue: true),
        LiveStepNavigation(
          plan: plan,
          onPrevious: onPrevious,
          onNext: primaryAction,
          primaryLabel: primaryLabel,
          accentColor: accent,
          isLoading: isPrimaryLoading,
        ),
        if (currentStepControls.isNotEmpty) ...[
          gapH14,
          Padding(
            padding: CatchInsets.pageHorizontal,
            child: CatchSectionHeader(
              padding: EdgeInsets.zero,
              title: context
                  .l10n
                  .eventSuccessEventSuccessHostLiveTitleControlsForThisStep,
              subtitle: context
                  .l10n
                  .eventSuccessEventSuccessHostLiveSubtitleHandleTheseBeforeMoving,
            ),
          ),
          gapH10,
          Padding(
            padding: CatchInsets.pageHorizontal,
            child: CatchSectionList(
              emptyStateOmitted: true,
              gap: CatchSpacing.s4,
              children: currentStepControls,
            ),
          ),
        ],
      ],
    );
  }
}

class _EventSuccessExclusionAlertCard extends StatefulWidget {
  const _EventSuccessExclusionAlertCard({
    required this.attendeeUids,
    required this.trackingStartedAtByUid,
    required this.assignments,
    required this.trackingStartedAt,
    required this.trackingEndedAt,
    required this.alertThreshold,
    required this.referenceNow,
  });

  final List<String> attendeeUids;
  final Map<String, DateTime> trackingStartedAtByUid;
  final List<EventSuccessAssignment> assignments;
  final DateTime trackingStartedAt;
  final DateTime trackingEndedAt;
  final Duration alertThreshold;
  final DateTime? referenceNow;

  @override
  State<_EventSuccessExclusionAlertCard> createState() =>
      _EventSuccessExclusionAlertCardState();
}

class _EventSuccessExclusionAlertCardState
    extends State<_EventSuccessExclusionAlertCard> {
  Timer? _thresholdTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleThreshold());
  }

  @override
  void didUpdateWidget(covariant _EventSuccessExclusionAlertCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleThreshold();
  }

  @override
  void dispose() {
    _thresholdTimer?.cancel();
    super.dispose();
  }

  DateTime get _now => widget.referenceNow ?? DateTime.now();

  EventSuccessExclusionLedgerSnapshot _snapshot() =>
      buildEventSuccessExclusionLedger(
        attendeeUids: widget.attendeeUids,
        assignments: widget.assignments,
        trackingStartedAt: widget.trackingStartedAt,
        trackingStartedAtByUid: widget.trackingStartedAtByUid,
        trackingEndedAt: widget.trackingEndedAt,
        now: _now,
        alertThreshold: widget.alertThreshold,
      );

  void _scheduleThreshold() {
    _thresholdTimer?.cancel();
    if (!mounted || widget.referenceNow != null) return;
    final delay = _snapshot().nextAlertDelay;
    if (delay == null) return;
    _thresholdTimer = Timer(delay + CatchMotion.eventSuccessThresholdTick, () {
      if (!mounted) return;
      setState(() {});
      _scheduleThreshold();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertCount = _snapshot().alertEntries.length;
    if (alertCount == 0) return const SizedBox.shrink();
    final thresholdMinutes = widget.alertThreshold.inMinutes;
    return Semantics(
      liveRegion: true,
      child: ColoredBox(
        color: CatchTokens.of(context).surface,
        child: Padding(
          padding: CatchInsets.pageHorizontal.copyWith(
            top: CatchSpacing.s3,
            bottom: CatchSpacing.s2,
          ),
          child: CatchSurface.message(
            key: const ValueKey('event_success.exclusion_alert'),
            messageIcon: CatchIcons.personSearchOutlined,
            messageTone: CatchSurfaceMessageTone.warning,
            title: context.l10n.eventSuccessControlRoomExclusionAlertTitle,
            message: context.l10n.eventSuccessControlRoomExclusionAlertBody(
              count: alertCount,
              minutes: thresholdMinutes,
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlRoomStage extends StatelessWidget {
  const _ControlRoomStage({
    required this.event,
    required this.plan,
    required this.syncState,
    required this.nextStepTitle,
    required this.attendeeExperience,
    required this.showVenue,
  });

  final Event event;
  final EventSuccessLivePlan plan;
  final EventSuccessControlRoomSyncState syncState;
  final String nextStepTitle;
  final String? attendeeExperience;
  final bool showVenue;

  @override
  Widget build(BuildContext context) {
    final dark = CatchTokens.editorialDark;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final eventIdentity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.consoleTitle(context, color: dark.ink),
        ),
        if (showVenue) ...[
          gapH4,
          Text(
            event.locationName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.monoLabel(context, color: dark.ink2),
          ),
        ],
      ],
    );
    final syncPill = _ControlRoomSyncPill(state: syncState);
    return ColoredBox(
      color: CatchTokens.editorialBlack,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: CatchInsets.eventSuccessControlRoomStage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              eventIdentity,
              gapH12,
              Align(alignment: Alignment.centerLeft, child: syncPill),
              gapH24,
              Text(
                context.l10n.eventSuccessControlRoomStepProgress(
                  current: plan.activeStepIndex + 1,
                  total: plan.steps.length,
                  stage:
                      '${_runOfShowBeatLabel(context, plan.durationShape, plan.activeStepIndex)} · ${plan.activeStep.stage.label}',
                ),
                style: CatchTextStyles.monoLabel(context, color: dark.ink2),
              ),
              gapH12,
              Text(
                plan.activeStep.title,
                maxLines: textScale >= 1.4 ? null : 2,
                overflow: textScale >= 1.4 ? null : TextOverflow.ellipsis,
                style: textScale >= 1.4
                    ? CatchTextStyles.headlineS(context, color: dark.ink)
                    : CatchTextStyles.display(context, color: dark.ink),
              ),
              gapH14,
              Text(
                plan.activeStep.hostInstruction,
                style: CatchTextStyles.bodyL(context, color: dark.ink2),
              ),
              if (attendeeExperience case final copy?) ...[
                gapH12,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CatchIcons.phoneIphoneRounded,
                      size: CatchIcon.md,
                      color: dark.ink2,
                    ),
                    gapW8,
                    Expanded(
                      child: Text(
                        copy,
                        style: CatchTextStyles.supporting(
                          context,
                          color: dark.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              gapH24,
              Text(
                context.l10n.eventSuccessControlRoomUpNext,
                style: CatchTextStyles.monoLabel(context, color: dark.ink2),
              ),
              gapH6,
              Text(
                nextStepTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.fieldRowTitle(context, color: dark.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlRoomSyncPill extends StatelessWidget {
  const _ControlRoomSyncPill({required this.state});

  final EventSuccessControlRoomSyncState state;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (state) {
      EventSuccessControlRoomSyncState.synced => (
        CatchIcons.checkCircleOutlineRounded,
        context.l10n.eventSuccessControlRoomSynced,
      ),
      EventSuccessControlRoomSyncState.syncing => (
        CatchIcons.syncRounded,
        context.l10n.eventSuccessControlRoomSyncing,
      ),
      EventSuccessControlRoomSyncState.failed => (
        CatchIcons.errorOutlineRounded,
        context.l10n.eventSuccessControlRoomSaveFailed,
      ),
      EventSuccessControlRoomSyncState.offline => (
        CatchIcons.wifiOffRounded,
        context.l10n.eventSuccessControlRoomOffline,
      ),
      EventSuccessControlRoomSyncState.conflict => (
        CatchIcons.errorOutlineRounded,
        context.l10n.eventSuccessControlRoomNeedsReview,
      ),
    };
    return Semantics(
      liveRegion: true,
      label: label,
      child: CatchBadge.onDarkStatus(
        label: context.l10n.eventSuccessControlRoomLiveSyncStatus(
          syncStatus: label,
        ),
        icon: icon,
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
    this.primaryLabel,
    this.accentColor,
    this.isLoading = false,
  });

  final EventSuccessLivePlan plan;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String? primaryLabel;
  final Color? accentColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final nextLabel =
        primaryLabel ??
        (plan.activeStepIndex >= plan.steps.length - 1
            ? context.l10n.eventSuccessEventSuccessHostLiveVisiblecopyFinalStep
            : context.l10n.eventSuccessEventSuccessHostLiveVisiblecopyNextTitle(
                title: _runOfShowStepLabel(
                  context,
                  plan,
                  plan.activeStepIndex + 1,
                ),
              ));
    return CatchBottomActionContent(
      label: nextLabel,
      onPressed: onNext,
      isLoading: isLoading,
      buttonAccentColor: accentColor,
      buttonKey: ValueKey(
        context
            .l10n
            .eventSuccessEventSuccessHostLiveCatchbuttonEventsuccessnextstepbutton,
      ),
      leadingContent: CatchIconButton.icon(
        key: ValueKey(
          context
              .l10n
              .eventSuccessEventSuccessHostLiveCatchbuttonEventsuccesspreviousstepbutton,
        ),
        icon: CatchIcons.arrowBackRounded,
        onTap: onPrevious,
        tooltip: context.l10n.eventSuccessEventSuccessHostLiveLabelPrevious,
      ),
    );
  }
}

String _runOfShowStepLabel(
  BuildContext context,
  EventSuccessLivePlan plan,
  int index,
) =>
    '${_runOfShowBeatLabel(context, plan.durationShape, index)} · ${plan.steps[index].title}';

String _runOfShowBeatLabel(
  BuildContext context,
  EventSuccessDurationShape shape,
  int index,
) {
  final number = index + 1;
  return switch (shape) {
    EventSuccessDurationShape.continuous =>
      context.l10n.eventSuccessEventSuccessHostLiveLabelBeatNumber(
        number: number,
      ),
    EventSuccessDurationShape.rounds =>
      context.l10n.eventSuccessEventSuccessHostLiveLabelRoundNumber(
        number: number,
      ),
    EventSuccessDurationShape.courses => switch (number) {
      1 => context.l10n.eventSuccessEventSuccessHostLiveLabelFirstCourse,
      2 => context.l10n.eventSuccessEventSuccessHostLiveLabelSecondCourse,
      3 => context.l10n.eventSuccessEventSuccessHostLiveLabelThirdCourse,
      4 => context.l10n.eventSuccessEventSuccessHostLiveLabelFourthCourse,
      _ => context.l10n.eventSuccessEventSuccessHostLiveLabelCourseNumber(
        number: number,
      ),
    },
    EventSuccessDurationShape.segments =>
      context.l10n.eventSuccessEventSuccessHostLiveLabelLegNumber(
        number: number,
      ),
  };
}

Future<void> _showControlRoomFallback(BuildContext context) {
  return showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => CatchBottomSheetScaffold(
      title: context.l10n.eventSuccessControlRoomFallbackTitle,
      subtitle: context.l10n.eventSuccessControlRoomFallbackSubtitle,
      glyph: CatchIcons.helpOutlineRounded,
      action: CatchButton(
        label: context.l10n.eventSuccessControlRoomFallbackDone,
        onPressed: () => Navigator.of(sheetContext).pop(),
        fullWidth: true,
      ),
      child: CatchSection.fieldRows(
        children: [
          CatchField.content(
            title: context.l10n.eventSuccessControlRoomFallbackStayTitle,
            body: context.l10n.eventSuccessControlRoomFallbackStayBody,
            icon: CatchIcons.checklistRounded,
          ),
          CatchField.content(
            title: context.l10n.eventSuccessControlRoomFallbackGuestsTitle,
            body: context.l10n.eventSuccessControlRoomFallbackGuestsBody,
            icon: CatchIcons.groupsOutlined,
          ),
          CatchField.content(
            title: context.l10n.eventSuccessControlRoomFallbackContinueTitle,
            body: context.l10n.eventSuccessControlRoomFallbackContinueBody,
            icon: CatchIcons.arrowForwardRounded,
          ),
        ],
      ),
    ),
  );
}
