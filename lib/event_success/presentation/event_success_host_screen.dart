import 'dart:async';

import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_exclusion_ledger.dart';
import 'package:catch_dating_app/event_success/domain/event_success_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_presence.dart';
import 'package:catch_dating_app/event_success/domain/event_success_standings.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/presentation/assignments/event_success_assignment_profiles.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_fixture_actions.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen_state.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_state_adapter.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_workspace_page_body.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card_state.dart';
import 'package:catch_dating_app/event_success/presentation/host_components/event_success_host_resource_error_state.dart';
import 'package:catch_dating_app/event_success/presentation/host_components/event_success_host_section_skeleton.dart';
import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:catch_dating_app/event_success/presentation/event_success_host_screen_state.dart';
export 'package:catch_dating_app/event_success/presentation/event_success_host_fixture_actions.dart';

Object? _mutationError(MutationState<dynamic> state) {
  return state.hasError ? (state as MutationError).error : null;
}

class EventSuccessHostSection extends ConsumerStatefulWidget {
  const EventSuccessHostSection({
    super.key,
    required this.event,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
    this.compactLiveControls = false,
    this.initialLiveWorkspace = EventSuccessLiveWorkspace.now,
    this.initialSpatialSelectionUid,
    this.operationalRosterSummary,
    this.onOpenGuests,
    this.guestsWorkspaceSemanticLabel,
    this.fixtureActions,
    this.referenceNow,
    this.exclusionAlertThreshold = defaultEventSuccessExclusionAlertThreshold,
  }) : assert(exclusionAlertThreshold > Duration.zero);

  final Event event;
  final EventSuccessHostTab initialTab;
  final bool showTabs;
  final bool compactLiveControls;
  final EventSuccessLiveWorkspace initialLiveWorkspace;
  final String? initialSpatialSelectionUid;
  final EventSuccessOperationalRosterSummary? operationalRosterSummary;
  final VoidCallback? onOpenGuests;
  final String? guestsWorkspaceSemanticLabel;
  final EventSuccessHostFixtureActions? fixtureActions;
  final DateTime? referenceNow;
  final Duration exclusionAlertThreshold;

  @override
  ConsumerState<EventSuccessHostSection> createState() =>
      _EventSuccessHostSectionState();
}

class _EventSuccessHostSectionState
    extends ConsumerState<EventSuccessHostSection> {
  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final requestedInitialTab = widget.initialTab;
    final compactLiveControls = widget.compactLiveControls;
    final operationalRosterSummary = widget.operationalRosterSummary;
    final onOpenGuests = widget.onOpenGuests;
    final fixtureActions = widget.fixtureActions;
    final referenceNow = widget.referenceNow ?? DateTime.now();
    final planAsync = ref.watch(watchEventSuccessPlanProvider(event.id));
    final ensureMutation = ref.watch(EventSuccessController.ensurePlanMutation);
    final saveSetupMutation = ref.watch(
      EventSuccessController.saveSetupMutation,
    );
    final upsertLayoutMutation = ref.watch(
      EventSuccessController.upsertLayoutMutation,
    );
    final updateStepMutation = ref.watch(
      EventSuccessController.updateStepMutation,
    );
    final completePlanMutation = ref.watch(
      EventSuccessController.completePlanMutation,
    );
    final generateMicroPodsMutation = ref.watch(
      EventSuccessController.generateMicroPodsMutation,
    );
    final generateGuidedRotationsMutation = ref.watch(
      EventSuccessController.generateGuidedRotationsMutation,
    );
    final startRevealCountdownMutation = ref.watch(
      EventSuccessController.startRevealCountdownMutation,
    );
    final revealRoundMutation = ref.watch(
      EventSuccessController.revealRoundMutation,
    );
    final cancelRevealCountdownMutation = ref.watch(
      EventSuccessController.cancelRevealCountdownMutation,
    );
    final recordUnitOutcomesMutation = ref.watch(
      EventSuccessController.recordUnitOutcomesMutation,
    );
    final publishRotationRoundMutation = ref.watch(
      EventSuccessController.publishRotationRoundMutation,
    );
    final resolveLateArrivalMutation = ref.watch(
      EventSuccessController.resolveLateArrivalMutation,
    );
    final accountabilityResolutionMutation = ref.watch(
      EventSuccessController.accountabilityResolutionMutation,
    );
    final persistedPlan = planAsync.asData?.value;
    final eventIsInProgress =
        !event.startTime.isAfter(referenceNow) &&
        event.endTime.isAfter(referenceNow);
    final phaseLocksLive =
        eventIsInProgress ||
        persistedPlan?.status == EventSuccessPlanStatus.live;
    final initialTab = phaseLocksLive
        ? EventSuccessHostTab.live
        : requestedInitialTab;
    final showTabs = widget.showTabs && !phaseLocksLive;
    final hasSavedGuide = persistedPlan != null;
    final shouldLoadSetupResources =
        showTabs || initialTab == EventSuccessHostTab.setup;
    final AsyncValue<List<EventSuccessLayout>> organizerLayoutsAsync =
        shouldLoadSetupResources
        ? ref.watch(watchOrganizerEventSuccessLayoutsProvider(event.clubId))
        : const AsyncData(<EventSuccessLayout>[]);
    final eventEnded = !event.endTime.isAfter(referenceNow);
    final shouldLoadLiveResources =
        hasSavedGuide &&
        !eventEnded &&
        (showTabs || initialTab == EventSuccessHostTab.live);
    final shouldLoadRoster = shouldLoadLiveResources;
    final shouldLoadScorecard =
        hasSavedGuide && (showTabs || initialTab == EventSuccessHostTab.report);
    final shouldLoadAssignments = shouldLoadLiveResources;
    final shouldLoadPreferences = shouldLoadAssignments;
    final shouldLoadWingmanRequests = shouldLoadAssignments;
    final eventSuccessProfile = EventSuccessActivityProfile.forFormat(
      event.eventFormat,
    );
    final unitOutcome = eventSuccessProfile.unitOutcome;
    final shouldLoadStandings =
        shouldLoadAssignments &&
        (unitOutcome == EventSuccessUnitOutcome.score ||
            unitOutcome == EventSuccessUnitOutcome.rank);
    final AsyncValue<EventSuccessStandings?> standingsAsync =
        shouldLoadStandings
        ? ref.watch(watchEventSuccessStandingsProvider(event.id))
        : const AsyncData<EventSuccessStandings?>(null);
    final AsyncValue<EventSuccessPresenceSummary?> presenceSummaryAsync =
        shouldLoadAssignments
        ? ref
              .watch(watchEventSuccessPresenceSummaryProvider(event.id))
              .whenData((summary) => summary)
        : const AsyncData<EventSuccessPresenceSummary?>(null);
    final shouldLoadOperationalAttendees =
        shouldLoadAssignments &&
        (eventSuccessProfile.accountability ==
                EventSuccessAccountability.sweep ||
            unitOutcome == EventSuccessUnitOutcome.score);
    final AsyncValue<List<EventAttendee>> accountabilityAttendeesAsync =
        shouldLoadOperationalAttendees
        ? ref.watch(watchEventAttendeesProvider(event.id))
        : const AsyncData(<EventAttendee>[]);
    final AsyncValue<EventSuccessLayout?> spatialLayoutAsync =
        shouldLoadAssignments &&
            persistedPlan.layoutId != null &&
            persistedPlan.structureConfig.unitKind !=
                EventSuccessUnitKind.wholeGroup
        ? ref.watch(eventSuccessSpatialLayoutProvider(event.id))
        : const AsyncData<EventSuccessLayout?>(null);
    final spatialLayoutState = eventSuccessHostSpatialLayoutState(
      plan: persistedPlan,
      value: spatialLayoutAsync,
    );
    final AsyncValue<EventParticipationRoster> rosterAsync = shouldLoadRoster
        ? ref.watch(watchEventParticipationRosterProvider(event.id))
        : AsyncData(EventParticipationRoster.empty());
    final ensureError = ensureMutation.hasError
        ? _mutationError(ensureMutation)
        : null;
    final saveSetupError = saveSetupMutation.hasError
        ? _mutationError(saveSetupMutation)
        : null;
    final updateStepError = updateStepMutation.hasError
        ? _mutationError(updateStepMutation)
        : null;
    final completePlanError = completePlanMutation.hasError
        ? _mutationError(completePlanMutation)
        : null;
    final generateMicroPodsError = generateMicroPodsMutation.hasError
        ? _mutationError(generateMicroPodsMutation)
        : null;
    final generateGuidedRotationsError =
        generateGuidedRotationsMutation.hasError
        ? _mutationError(generateGuidedRotationsMutation)
        : null;
    final recordUnitOutcomesError = recordUnitOutcomesMutation.hasError
        ? _mutationError(recordUnitOutcomesMutation)
        : null;
    final AsyncValue<EventSuccessScorecard?> scorecardAsync =
        shouldLoadScorecard
        ? ref.watch(watchEventSuccessScorecardProvider(event.id))
        : const AsyncData<EventSuccessScorecard?>(null);
    final AsyncValue<List<EventSuccessAssignment>> assignmentsAsync =
        shouldLoadAssignments
        ? ref.watch(watchEventSuccessAssignmentsProvider(event.id))
        : const AsyncData(<EventSuccessAssignment>[]);
    final assignmentsPreview =
        assignmentsAsync.asData?.value ?? const <EventSuccessAssignment>[];
    final assignmentParticipantUidsKey = eventSuccessPeerUidsKey(
      eventSuccessAssignmentParticipantUids(assignmentsPreview),
    );
    final AsyncValue<List<PublicProfile>> assignmentParticipantProfilesAsync =
        shouldLoadAssignments && assignmentParticipantUidsKey.isNotEmpty
        ? ref.watch(
            eventSuccessAssignmentPeerProfilesProvider(
              assignmentParticipantUidsKey,
            ),
          )
        : const AsyncData(<PublicProfile>[]);
    final AsyncValue<List<EventSuccessAssignment>> rotationAssignmentsAsync =
        shouldLoadAssignments
        ? ref.watch(watchEventSuccessRotationAssignmentsProvider(event.id))
        : const AsyncData(<EventSuccessAssignment>[]);
    final shouldLoadRotationDrafts =
        shouldLoadAssignments &&
        persistedPlan.hasModule(EventSuccessModuleCatalog.guidedRotations.id) &&
        persistedPlan.structureConfig.rotates;
    final AsyncValue<List<EventSuccessAssignmentDraft>> rotationDraftsAsync =
        shouldLoadRotationDrafts
        ? ref.watch(watchEventSuccessRotationDraftsProvider(event.id))
        : const AsyncData(<EventSuccessAssignmentDraft>[]);
    final rotationAssignmentsPreview =
        rotationDraftsAsync.asData?.value
            .map((draft) => draft.assignment)
            .toList(growable: false) ??
        rotationAssignmentsAsync.asData?.value ??
        const <EventSuccessAssignment>[];
    final rotationParticipantUidsKey = eventSuccessPeerUidsKey(
      eventSuccessAssignmentParticipantUids(rotationAssignmentsPreview),
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
      eventSuccessWingmanProfileUids(
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

    final state = EventSuccessHostSectionState.resolve(
      event: event,
      now: referenceNow,
      planState: catchAsyncStateFromAsyncValue(planAsync),
      rosterState: catchAsyncStateFromAsyncValue(rosterAsync),
      scorecardState: catchAsyncStateFromAsyncValue(scorecardAsync),
      assignmentsState: catchAsyncStateFromAsyncValue(assignmentsAsync),
      assignmentParticipantProfilesState: catchAsyncStateFromAsyncValue(
        assignmentParticipantProfilesAsync,
      ),
      rotationAssignmentsState: catchAsyncStateFromAsyncValue(
        rotationAssignmentsAsync,
      ),
      rotationDraftsState: catchAsyncStateFromAsyncValue(rotationDraftsAsync),
      rotationParticipantProfilesState: catchAsyncStateFromAsyncValue(
        rotationParticipantProfilesAsync,
      ),
      preferencesState: catchAsyncStateFromAsyncValue(preferencesAsync),
      wingmanRequestsState: catchAsyncStateFromAsyncValue(wingmanRequestsAsync),
      wingmanProfilesState: catchAsyncStateFromAsyncValue(wingmanProfilesAsync),
    );

    Widget frameCompactLiveState(Widget child) => compactLiveControls
        ? SingleChildScrollView(padding: CatchInsets.pageBody, child: child)
        : child;

    switch (state.status) {
      case EventSuccessHostSectionStatus.loading:
        return frameCompactLiveState(
          EventSuccessHostSectionSkeleton(
            initialTab: initialTab,
            showTabs: showTabs,
          ),
        );
      case EventSuccessHostSectionStatus.error:
        final retryIntent = state.retryIntent!;
        return frameCompactLiveState(
          EventSuccessHostResourceErrorState(
            failure: EventSuccessHostResourceFailure(
              retryIntent: retryIntent,
              error: state.error!,
            ),
            onRetry: () => _retryEventSuccessHostSection(
              eventId: event.id,
              retryIntent: retryIntent,
              assignmentParticipantUidsKey: assignmentParticipantUidsKey,
              rotationParticipantUidsKey: rotationParticipantUidsKey,
              wingmanProfilesKey: wingmanProfilesKey,
            ),
          ),
        );
      case EventSuccessHostSectionStatus.ready:
        break;
    }

    return EventSuccessHostWorkspacePageBody(
      event: event,
      plan: state.plan,
      planIsPersisted: state.planIsPersisted,
      spatialLayout: spatialLayoutAsync.asData?.value,
      spatialLayoutState: spatialLayoutState,
      organizerLayoutsState: catchAsyncStateFromAsyncValue(
        organizerLayoutsAsync,
      ),
      layoutSavePending: upsertLayoutMutation.isPending,
      layoutSaveError: upsertLayoutMutation.hasError
          ? _mutationError(upsertLayoutMutation)
          : null,
      onSaveLayout: (layout) => EventSuccessController.upsertLayoutMutation.run(
        ref,
        (tx) => tx
            .get(eventSuccessControllerProvider.notifier)
            .upsertLayout(organizerId: event.clubId, layout: layout),
      ),
      roster: state.roster,
      scorecard: state.scorecard,
      assignments: state.assignments,
      assignmentParticipantProfiles: state.assignmentParticipantProfiles,
      rotationAssignments: state.rotationAssignments,
      rotationDraftAssignments: state.rotationDraftAssignments,
      rotationParticipantProfiles: state.rotationParticipantProfiles,
      preferences: state.preferences,
      standings: standingsAsync.asData?.value,
      presenceSummary: presenceSummaryAsync.asData?.value,
      presenceError: presenceSummaryAsync.hasError
          ? presenceSummaryAsync.error
          : null,
      accountabilityAttendees:
          accountabilityAttendeesAsync.asData?.value ?? const [],
      accountabilityError: accountabilityAttendeesAsync.hasError
          ? accountabilityAttendeesAsync.error
          : accountabilityResolutionMutation.hasError
          ? _mutationError(accountabilityResolutionMutation)
          : null,
      loadingAccountability: accountabilityAttendeesAsync.isLoading,
      resolvingAccountability: accountabilityResolutionMutation.isPending,
      resolvingLateArrival: resolveLateArrivalMutation.isPending,
      lateArrivalError: resolveLateArrivalMutation.hasError
          ? _mutationError(resolveLateArrivalMutation)
          : null,
      wingmanRequests: state.wingmanRequests,
      wingmanProfiles: state.wingmanProfiles,
      liveResourcesLoaded: shouldLoadLiveResources,
      resourceFailures: state.resourceFailures,
      onRetryResource: (retryIntent) => _retryEventSuccessHostSection(
        eventId: event.id,
        retryIntent: retryIntent,
        assignmentParticipantUidsKey: assignmentParticipantUidsKey,
        rotationParticipantUidsKey: rotationParticipantUidsKey,
        wingmanProfilesKey: wingmanProfilesKey,
      ),
      initialTab: initialTab,
      showTabs: showTabs,
      embedded: true,
      compactLiveControls: compactLiveControls,
      initialLiveWorkspace: widget.initialLiveWorkspace,
      initialSpatialSelectionUid: widget.initialSpatialSelectionUid,
      operationalRosterSummary: operationalRosterSummary,
      onOpenGuests: onOpenGuests,
      guestsWorkspaceSemanticLabel: widget.guestsWorkspaceSemanticLabel,
      setupActionState: EventSuccessSetupActionState.resolve(
        ensurePending: ensureMutation.isPending,
        savePending: saveSetupMutation.isPending,
        ensureError: ensureError,
        saveError: saveSetupError,
      ),
      onSaveSetup: _saveEventSuccessSetup,
      liveActionState: EventSuccessLiveActionState.resolve(
        stepPending: updateStepMutation.isPending,
        completePending: completePlanMutation.isPending,
        stepError: updateStepError,
        completeError: completePlanError,
      ),
      onSetLiveStep: (index) => _setEventSuccessLiveStep(
        eventId: event.id,
        index: index,
        expectedRevision: state.plan.liveControlRevision,
      ),
      onCompleteLiveGuide: (accountabilityAcknowledged) =>
          _completeEventSuccessLiveGuide(
            eventId: event.id,
            expectedRevision: state.plan.liveControlRevision,
            accountabilityAcknowledged: accountabilityAcknowledged,
          ),
      onResolveAccountability: (attendeeId, resolution) async {
        await EventSuccessController.accountabilityResolutionMutation.run(
          ref,
          (tx) => tx
              .get(eventSuccessControllerProvider.notifier)
              .setAccountabilityResolution(
                eventId: event.id,
                attendeeId: attendeeId,
                resolution: resolution,
              ),
        );
        ref.invalidate(watchEventAttendeesProvider(event.id));
      },
      microPodsGenerationState:
          EventSuccessAssignmentGenerationActionState.resolve(
            pending: generateMicroPodsMutation.isPending,
            error: generateMicroPodsError,
          ),
      rotationsGenerationState:
          EventSuccessAssignmentGenerationActionState.resolve(
            pending:
                generateGuidedRotationsMutation.isPending ||
                publishRotationRoundMutation.isPending,
            error: publishRotationRoundMutation.hasError
                ? _mutationError(publishRotationRoundMutation)
                : generateGuidedRotationsError,
          ),
      onGenerateMicroPods: () =>
          _generateEventSuccessMicroPods(eventId: event.id),
      onGenerateGuidedRotations: () => _generateEventSuccessGuidedRotations(
        eventId: event.id,
        expectedRevision: state.plan.liveControlRevision,
      ),
      onResolveLateArrival: (uid) async {
        await EventSuccessController.resolveLateArrivalMutation.run(
          ref,
          (tx) => tx
              .get(eventSuccessControllerProvider.notifier)
              .resolveLateArrival(
                eventId: event.id,
                uid: uid,
                expectedRevision:
                    presenceSummaryAsync.asData?.value?.liveControlRevision ??
                    state.plan.liveControlRevision,
              ),
        );
        ref.invalidate(watchEventSuccessPresenceSummaryProvider(event.id));
      },
      onPublishGuidedRotationRound: (roundIndex) =>
          _publishEventSuccessGuidedRotationRound(
            eventId: event.id,
            roundIndex: roundIndex,
            expectedRevision: state.plan.liveControlRevision,
          ),
      onOverrideGroupAssignments: (rounds) =>
          _overrideEventSuccessGroupAssignments(
            eventId: event.id,
            rounds: rounds,
          ),
      onOverrideGuidedRotations: (rounds) =>
          _overrideEventSuccessGuidedRotations(
            eventId: event.id,
            expectedRevision: state.plan.liveControlRevision,
            rounds: rounds,
          ),
      onPreviewSpatial: (assignment) => _controlEventSuccessSpatial(
        eventId: event.id,
        expectedRevision: state.plan.liveControlRevision,
        action: EventSuccessSpatialAction.previewReassignment,
        assignment: assignment,
      ).then((result) => result.destinations),
      onReassignSpatial: (assignment, destinationUnitId, scope) =>
          _controlEventSuccessSpatial(
            eventId: event.id,
            expectedRevision: state.plan.liveControlRevision,
            action: EventSuccessSpatialAction.reassign,
            assignment: assignment,
            destinationUnitId: destinationUnitId,
            scope: scope,
          ),
      onConfirmSpatial: (assignment) => _controlEventSuccessSpatial(
        eventId: event.id,
        expectedRevision: state.plan.liveControlRevision,
        action: EventSuccessSpatialAction.confirmPosition,
        assignment: assignment,
      ),
      onReleaseSpatial: (assignment) => _controlEventSuccessSpatial(
        eventId: event.id,
        expectedRevision: state.plan.liveControlRevision,
        action: EventSuccessSpatialAction.releasePinned,
        assignment: assignment,
      ),
      revealActionState: EventSuccessRevealActionState.resolve(
        startPending: startRevealCountdownMutation.isPending,
        revealPending: revealRoundMutation.isPending,
        resetPending: cancelRevealCountdownMutation.isPending,
        startError: startRevealCountdownMutation.hasError
            ? (startRevealCountdownMutation as MutationError).error
            : null,
        revealError: revealRoundMutation.hasError
            ? (revealRoundMutation as MutationError).error
            : null,
        resetError: cancelRevealCountdownMutation.hasError
            ? (cancelRevealCountdownMutation as MutationError).error
            : null,
      ),
      onStartRevealCountdown: (roundIndex, _) =>
          _startEventSuccessRevealCountdown(
            eventId: event.id,
            roundIndex: roundIndex,
            expectedRevision: state.plan.liveControlRevision,
          ),
      onRevealRound: (roundIndex) => _revealEventSuccessRound(
        eventId: event.id,
        roundIndex: roundIndex,
        expectedRevision: state.plan.liveControlRevision,
      ),
      onResetReveal: () => _cancelEventSuccessRevealCountdown(
        eventId: event.id,
        expectedRevision: state.plan.liveControlRevision,
      ),
      outcomeActionState: EventSuccessOutcomeActionState(
        isLoading:
            standingsAsync.isLoading || recordUnitOutcomesMutation.isPending,
        error: standingsAsync.hasError
            ? standingsAsync.error
            : recordUnitOutcomesError,
      ),
      onRecordOutcomes:
          ({
            required expectedRevision,
            required roundIndex,
            required entries,
          }) => _recordEventSuccessUnitOutcomes(
            eventId: event.id,
            expectedRevision: expectedRevision,
            roundIndex: roundIndex,
            entries: entries,
          ),
      fixtureActions: fixtureActions,
      exclusionAlertThreshold: widget.exclusionAlertThreshold,
      referenceNow: referenceNow,
    );
  }

  Future<void> _saveEventSuccessSetup(EventSuccessSetupSaveRequest request) {
    return EventSuccessController.saveSetupMutation.run(ref, (tx) async {
      final basePlan = request.planIsPersisted
          ? request.plan
          : await tx
                .get(eventSuccessControllerProvider.notifier)
                .ensurePlan(request.event);
      await tx
          .get(eventSuccessControllerProvider.notifier)
          .saveSetup(
            plan: basePlan,
            draft: request.draft,
            layoutId: request.layoutId,
            attendeePrompt: request.attendeePrompt,
          );
    });
  }

  Future<EventSuccessSpatialActionResult> _controlEventSuccessSpatial({
    required String eventId,
    required int expectedRevision,
    required EventSuccessSpatialAction action,
    required EventSuccessAssignment assignment,
    String? destinationUnitId,
    EventSuccessSpatialScope? scope,
  }) => EventSuccessController.spatialControlMutation.run(
    ref,
    (tx) => tx
        .get(eventSuccessControllerProvider.notifier)
        .controlSpatialPlacement(
          eventId: eventId,
          expectedRevision: expectedRevision,
          action: action,
          moduleId: assignment.moduleId,
          uid: assignment.uid,
          destinationUnitId: destinationUnitId,
          scope: scope,
        ),
  );

  Future<void> _generateEventSuccessMicroPods({required String eventId}) {
    return EventSuccessController.generateMicroPodsMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .generateMicroPods(eventId: eventId),
    );
  }

  Future<void> _generateEventSuccessGuidedRotations({
    required String eventId,
    required int expectedRevision,
  }) {
    return EventSuccessController.generateGuidedRotationsMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .generateGuidedRotations(
            eventId: eventId,
            expectedRevision: expectedRevision,
          ),
    );
  }

  Future<void> _startEventSuccessRevealCountdown({
    required String eventId,
    required int roundIndex,
    required int expectedRevision,
  }) {
    return EventSuccessController.startRevealCountdownMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .startRevealCountdown(
            eventId: eventId,
            roundIndex: roundIndex,
            expectedRevision: expectedRevision,
            confirmed: true,
          ),
    );
  }

  Future<void> _revealEventSuccessRound({
    required String eventId,
    required int roundIndex,
    required int expectedRevision,
  }) {
    return EventSuccessController.revealRoundMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .revealRound(
            eventId: eventId,
            roundIndex: roundIndex,
            expectedRevision: expectedRevision,
            confirmed: true,
          ),
    );
  }

  Future<void> _cancelEventSuccessRevealCountdown({
    required String eventId,
    required int expectedRevision,
  }) {
    return EventSuccessController.cancelRevealCountdownMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .cancelRevealCountdown(
            eventId: eventId,
            expectedRevision: expectedRevision,
          ),
    );
  }

  Future<void> _recordEventSuccessUnitOutcomes({
    required String eventId,
    required int expectedRevision,
    required int roundIndex,
    required List<EventSuccessUnitOutcomeEntryInput> entries,
  }) {
    return EventSuccessController.recordUnitOutcomesMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .recordUnitOutcomes(
            eventId: eventId,
            expectedRevision: expectedRevision,
            roundIndex: roundIndex,
            entries: entries,
          ),
    );
  }

  Future<void> _publishEventSuccessGuidedRotationRound({
    required String eventId,
    required int roundIndex,
    required int expectedRevision,
  }) {
    return EventSuccessController.publishRotationRoundMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .publishGuidedRotationRound(
            eventId: eventId,
            roundIndex: roundIndex,
            expectedRevision: expectedRevision,
            confirmed: true,
          ),
    );
  }

  Future<void> _overrideEventSuccessGroupAssignments({
    required String eventId,
    required List<EventSuccessGroupOverrideRound> rounds,
  }) {
    return EventSuccessController.overrideGroupAssignmentsMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .overrideGroupAssignments(eventId: eventId, rounds: rounds),
    );
  }

  Future<void> _overrideEventSuccessGuidedRotations({
    required String eventId,
    required int expectedRevision,
    required List<EventSuccessRotationOverrideRound> rounds,
  }) {
    return EventSuccessController.overrideGuidedRotationsMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .overrideGuidedRotations(
            eventId: eventId,
            expectedRevision: expectedRevision,
            rounds: rounds,
          ),
    );
  }

  Future<void> _setEventSuccessLiveStep({
    required String eventId,
    required int index,
    required int expectedRevision,
  }) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.stepChange),
    );
    return EventSuccessController.updateStepMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .updateActiveStep(
            eventId: eventId,
            activeStepIndex: index,
            expectedRevision: expectedRevision,
          ),
    );
  }

  Future<void> _completeEventSuccessLiveGuide({
    required String eventId,
    required int expectedRevision,
    required bool accountabilityAcknowledged,
  }) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.guideComplete),
    );
    return EventSuccessController.completePlanMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .completePlan(
            eventId: eventId,
            expectedRevision: expectedRevision,
            accountabilityAcknowledged: accountabilityAcknowledged,
          ),
    );
  }

  void _retryEventSuccessHostSection({
    required String eventId,
    required EventSuccessHostRetryIntent retryIntent,
    required String assignmentParticipantUidsKey,
    required String rotationParticipantUidsKey,
    required String wingmanProfilesKey,
  }) {
    switch (retryIntent) {
      case EventSuccessHostRetryIntent.plan:
        ref.invalidate(watchEventSuccessPlanProvider(eventId));
      case EventSuccessHostRetryIntent.roster:
        ref.invalidate(watchEventParticipationRosterProvider(eventId));
      case EventSuccessHostRetryIntent.assignments:
        ref.invalidate(watchEventSuccessAssignmentsProvider(eventId));
      case EventSuccessHostRetryIntent.rotationAssignments:
        ref.invalidate(watchEventSuccessRotationAssignmentsProvider(eventId));
      case EventSuccessHostRetryIntent.rotationDrafts:
        ref.invalidate(watchEventSuccessRotationDraftsProvider(eventId));
      case EventSuccessHostRetryIntent.assignmentParticipantProfiles:
        ref.invalidate(
          eventSuccessAssignmentPeerProfilesProvider(
            assignmentParticipantUidsKey,
          ),
        );
      case EventSuccessHostRetryIntent.rotationParticipantProfiles:
        ref.invalidate(
          eventSuccessAssignmentPeerProfilesProvider(
            rotationParticipantUidsKey,
          ),
        );
      case EventSuccessHostRetryIntent.preferences:
        ref.invalidate(watchEventSuccessPreferencesProvider(eventId));
      case EventSuccessHostRetryIntent.wingmanRequests:
        ref.invalidate(watchEventSuccessWingmanRequestsProvider(eventId));
      case EventSuccessHostRetryIntent.wingmanProfiles:
        ref.invalidate(
          eventSuccessAssignmentPeerProfilesProvider(wingmanProfilesKey),
        );
      case EventSuccessHostRetryIntent.scorecard:
        ref.invalidate(watchEventSuccessScorecardProvider(eventId));
      case EventSuccessHostRetryIntent.spatialLayout:
        ref.invalidate(eventSuccessSpatialLayoutProvider(eventId));
    }
  }
}
