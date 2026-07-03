import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
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
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen_state.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_setup_body.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_check_in_qr_payload.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_booking_controller.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

export 'package:catch_dating_app/event_success/presentation/event_success_host_screen_state.dart';

part 'host_parts/event_success_host_live.dart';
part 'host_parts/event_success_host_overrides.dart';
part 'host_parts/event_success_host_report.dart';
part 'host_parts/event_success_host_setup.dart';
part 'host_parts/event_success_host_shared.dart';

const EdgeInsets _hostTabPickerPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.s4,
  CatchSpacing.s5,
  CatchSpacing.s2,
);
const EdgeInsets _hostLaunchIssueGap = EdgeInsets.only(bottom: CatchSpacing.s1);
const EdgeInsets _hostWingmanRequestGap = EdgeInsets.only(
  bottom: CatchSpacing.s2,
);
const EdgeInsets _hostWingmanRequestNotePadding = EdgeInsets.only(
  left: CatchSpacing.s5,
  right: CatchSpacing.s5,
  bottom: CatchSpacing.s2,
);

MutationState<void>? _firstHostRosterMutationError(
  MutationState<void> Function(Mutation<void> mutation) watchMutation, {
  required String eventId,
  required EventParticipationRoster? roster,
}) {
  if (roster == null) return null;
  final participantIds = <String>{...roster.bookedIds, ...roster.waitlistedIds};
  for (final uid in participantIds) {
    final mutations = <Mutation<void>>[
      HostEventBookingController.markAttendanceMutation(
        HostEventBookingController.markAttendanceMutationKey(
          eventId: eventId,
          userId: uid,
        ),
      ),
      HostEventBookingController.approveJoinRequestMutation(
        HostEventBookingController.approveJoinRequestMutationKey(
          eventId: eventId,
          userId: uid,
        ),
      ),
      HostEventBookingController.declineJoinRequestMutation(
        HostEventBookingController.declineJoinRequestMutationKey(
          eventId: eventId,
          userId: uid,
        ),
      ),
      HostEventBookingController.createWaitlistOfferMutation(
        HostEventBookingController.waitlistOfferMutationKey(
          eventId: eventId,
          userId: uid,
        ),
      ),
    ];
    for (final mutation in mutations) {
      final state = watchMutation(mutation);
      if (state.hasError) return state;
    }
  }
  final bulkOfferState = watchMutation(
    HostEventBookingController.createWaitlistOfferMutation(
      HostEventBookingController.bulkWaitlistOfferMutationKey(eventId: eventId),
    ),
  );
  return bulkOfferState.hasError ? bulkOfferState : null;
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}

Object? _nullableMutationError(MutationState<dynamic>? state) {
  return state == null ? null : _mutationError(state);
}

Object? _mutationError(MutationState<dynamic> state) {
  return state.hasError ? (state as MutationError).error : null;
}

class EventSuccessHostSection extends ConsumerStatefulWidget {
  const EventSuccessHostSection({
    super.key,
    required this.event,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
    this.liveRoster,
    this.compactLiveControls = false,
    this.fixtureActions,
  });

  final Event event;
  final EventSuccessHostTab initialTab;
  final bool showTabs;
  final Widget? liveRoster;
  final bool compactLiveControls;
  final EventSuccessHostFixtureActions? fixtureActions;

  @override
  ConsumerState<EventSuccessHostSection> createState() =>
      _EventSuccessHostSectionState();
}

class _EventSuccessHostSectionState
    extends ConsumerState<EventSuccessHostSection> {
  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final initialTab = widget.initialTab;
    final showTabs = widget.showTabs;
    final liveRoster = widget.liveRoster;
    final compactLiveControls = widget.compactLiveControls;
    final fixtureActions = widget.fixtureActions;
    final planAsync = ref.watch(watchEventSuccessPlanProvider(event.id));
    final ensureMutation = ref.watch(EventSuccessController.ensurePlanMutation);
    final saveSetupMutation = ref.watch(
      EventSuccessController.saveSetupMutation,
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
    final resetRevealMutation = ref.watch(
      EventSuccessController.resetRevealMutation,
    );
    final persistedPlan = planAsync.asData?.value;
    final hasSavedGuide = persistedPlan != null;
    final shouldLoadRoster =
        hasSavedGuide && (showTabs || initialTab == EventSuccessHostTab.live);
    final shouldLoadScorecard =
        hasSavedGuide && (showTabs || initialTab == EventSuccessHostTab.report);
    final shouldLoadAssignments =
        hasSavedGuide && (showTabs || initialTab == EventSuccessHostTab.live);
    final shouldLoadPreferences = shouldLoadAssignments;
    final shouldLoadWingmanRequests = shouldLoadAssignments;
    final AsyncValue<EventParticipationRoster> rosterAsync = shouldLoadRoster
        ? ref.watch(watchEventParticipationRosterProvider(event.id))
        : AsyncData(EventParticipationRoster.empty());
    final attendanceErrorMutation = liveRoster == null
        ? null
        : _firstHostRosterMutationError(
            (mutation) => ref.watch(mutation),
            eventId: event.id,
            roster: rosterAsync.asData?.value,
          );
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
      _rotationParticipantUids(assignmentsPreview),
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

    final state = EventSuccessHostSectionState.resolve(
      event: event,
      now: DateTime.now(),
      planState: _catchAsyncState(planAsync),
      rosterState: _catchAsyncState(rosterAsync),
      scorecardState: _catchAsyncState(scorecardAsync),
      assignmentsState: _catchAsyncState(assignmentsAsync),
      assignmentParticipantProfilesState: _catchAsyncState(
        assignmentParticipantProfilesAsync,
      ),
      rotationAssignmentsState: _catchAsyncState(rotationAssignmentsAsync),
      rotationParticipantProfilesState: _catchAsyncState(
        rotationParticipantProfilesAsync,
      ),
      preferencesState: _catchAsyncState(preferencesAsync),
      wingmanRequestsState: _catchAsyncState(wingmanRequestsAsync),
      wingmanProfilesState: _catchAsyncState(wingmanProfilesAsync),
    );

    switch (state.status) {
      case EventSuccessHostSectionStatus.loading:
        return EventSuccessHostSectionSkeleton(
          initialTab: initialTab,
          showTabs: showTabs,
        );
      case EventSuccessHostSectionStatus.error:
        final retryIntent = state.retryIntent!;
        return CatchInlineErrorState.fromError(
          state.error!,
          context: _eventSuccessHostRetryContext(retryIntent),
          onRetry: () => _retryEventSuccessHostSection(
            eventId: event.id,
            retryIntent: retryIntent,
            assignmentParticipantUidsKey: assignmentParticipantUidsKey,
            rotationParticipantUidsKey: rotationParticipantUidsKey,
            wingmanProfilesKey: wingmanProfilesKey,
          ),
        );
      case EventSuccessHostSectionStatus.ready:
        break;
    }

    return EventSuccessHostPanel(
      event: event,
      plan: state.plan,
      planIsPersisted: state.planIsPersisted,
      roster: state.roster,
      scorecard: state.scorecard,
      assignments: state.assignments,
      assignmentParticipantProfiles: state.assignmentParticipantProfiles,
      rotationAssignments: state.rotationAssignments,
      rotationParticipantProfiles: state.rotationParticipantProfiles,
      preferences: state.preferences,
      wingmanRequests: state.wingmanRequests,
      wingmanProfiles: state.wingmanProfiles,
      initialTab: initialTab,
      showTabs: showTabs,
      liveRoster: liveRoster,
      compactLiveControls: compactLiveControls,
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
        attendanceError: _nullableMutationError(attendanceErrorMutation),
      ),
      onSetLiveStep: (index) =>
          _setEventSuccessLiveStep(eventId: event.id, index: index),
      onCompleteLiveGuide: () =>
          _completeEventSuccessLiveGuide(eventId: event.id),
      microPodsGenerationState:
          EventSuccessAssignmentGenerationActionState.resolve(
            pending: generateMicroPodsMutation.isPending,
            error: generateMicroPodsError,
          ),
      rotationsGenerationState:
          EventSuccessAssignmentGenerationActionState.resolve(
            pending: generateGuidedRotationsMutation.isPending,
            error: generateGuidedRotationsError,
          ),
      onGenerateMicroPods: () =>
          _generateEventSuccessMicroPods(eventId: event.id),
      onGenerateGuidedRotations: () =>
          _generateEventSuccessGuidedRotations(eventId: event.id),
      onOverrideGroupAssignments: (rounds) =>
          _overrideEventSuccessGroupAssignments(
            eventId: event.id,
            rounds: rounds,
          ),
      onOverrideGuidedRotations: (rounds) =>
          _overrideEventSuccessGuidedRotations(
            eventId: event.id,
            rounds: rounds,
          ),
      revealActionState: EventSuccessRevealActionState.resolve(
        startPending: startRevealCountdownMutation.isPending,
        revealPending: revealRoundMutation.isPending,
        resetPending: resetRevealMutation.isPending,
        startError: startRevealCountdownMutation.hasError
            ? (startRevealCountdownMutation as MutationError).error
            : null,
        revealError: revealRoundMutation.hasError
            ? (revealRoundMutation as MutationError).error
            : null,
        resetError: resetRevealMutation.hasError
            ? (resetRevealMutation as MutationError).error
            : null,
      ),
      onStartRevealCountdown: (roundIndex, _) =>
          _startEventSuccessRevealCountdown(
            eventId: event.id,
            roundIndex: roundIndex,
          ),
      onRevealRound: (roundIndex) =>
          _revealEventSuccessRound(eventId: event.id, roundIndex: roundIndex),
      onResetReveal: () => _resetEventSuccessReveal(eventId: event.id),
      fixtureActions: fixtureActions,
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
            attendeePrompt: request.attendeePrompt,
          );
    });
  }

  Future<void> _generateEventSuccessMicroPods({required String eventId}) {
    return EventSuccessController.generateMicroPodsMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .generateMicroPods(eventId: eventId),
    );
  }

  Future<void> _generateEventSuccessGuidedRotations({required String eventId}) {
    return EventSuccessController.generateGuidedRotationsMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .generateGuidedRotations(eventId: eventId),
    );
  }

  Future<void> _startEventSuccessRevealCountdown({
    required String eventId,
    required int roundIndex,
  }) {
    return EventSuccessController.startRevealCountdownMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .startRevealCountdown(eventId: eventId, roundIndex: roundIndex),
    );
  }

  Future<void> _revealEventSuccessRound({
    required String eventId,
    required int roundIndex,
  }) {
    return EventSuccessController.revealRoundMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .revealRound(eventId: eventId, roundIndex: roundIndex),
    );
  }

  Future<void> _resetEventSuccessReveal({required String eventId}) {
    return EventSuccessController.resetRevealMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .resetReveal(eventId: eventId),
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
    required List<EventSuccessRotationOverrideRound> rounds,
  }) {
    return EventSuccessController.overrideGuidedRotationsMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .overrideGuidedRotations(eventId: eventId, rounds: rounds),
    );
  }

  Future<void> _setEventSuccessLiveStep({
    required String eventId,
    required int index,
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
          .updateActiveStep(eventId: eventId, activeStepIndex: index),
    );
  }

  Future<void> _completeEventSuccessLiveGuide({required String eventId}) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.guideComplete),
    );
    return EventSuccessController.completePlanMutation.run(
      ref,
      (tx) =>
          tx.get(eventSuccessControllerProvider.notifier).completePlan(eventId),
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
    }
  }
}

AppErrorContext _eventSuccessHostRetryContext(
  EventSuccessHostRetryIntent intent,
) {
  return switch (intent) {
    EventSuccessHostRetryIntent.assignmentParticipantProfiles ||
    EventSuccessHostRetryIntent.rotationParticipantProfiles ||
    EventSuccessHostRetryIntent.wingmanProfiles => AppErrorContext.profile,
    EventSuccessHostRetryIntent.plan ||
    EventSuccessHostRetryIntent.roster ||
    EventSuccessHostRetryIntent.assignments ||
    EventSuccessHostRetryIntent.rotationAssignments ||
    EventSuccessHostRetryIntent.preferences ||
    EventSuccessHostRetryIntent.wingmanRequests ||
    EventSuccessHostRetryIntent.scorecard => AppErrorContext.event,
  };
}

class EventSuccessHostSectionSkeleton extends StatelessWidget {
  const EventSuccessHostSectionSkeleton({
    super.key,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
  });

  final EventSuccessHostTab initialTab;
  final bool showTabs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTabs) ...[const EventSuccessTabPickerSkeleton(), gapH16],
        switch (initialTab) {
          EventSuccessHostTab.setup => const EventSuccessSetupTabSkeleton(),
          EventSuccessHostTab.live => const EventSuccessLiveTabSkeleton(),
          EventSuccessHostTab.report => const EventSuccessReportTabSkeleton(),
        },
      ],
    );
  }
}

class EventSuccessTabPickerSkeleton extends StatelessWidget {
  const EventSuccessTabPickerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: CatchSkeleton.box(
              height: CatchLayout.controlCompactMinHeight,
              radius: CatchRadius.sm,
            ),
          ),
          if (i < 2) gapW8,
        ],
      ],
    );
  }
}

class EventSuccessSetupTabSkeleton extends StatelessWidget {
  const EventSuccessSetupTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchSectionStack(
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessSkeletonSurface(
          titleWidth: 170,
          textLines: 3,
          trailingChips: 3,
        ),
        EventSuccessSetupControlsSkeleton(),
        EventSuccessSkeletonSurface(
          titleWidth: 150,
          textLines: 2,
          trailingChips: 2,
        ),
      ],
    );
  }
}

class EventSuccessLiveTabSkeleton extends StatelessWidget {
  const EventSuccessLiveTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchSectionStack(
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessSkeletonSurface(
          titleWidth: 148,
          textLines: 2,
          trailingChips: 2,
        ),
        EventSuccessLiveRosterSkeleton(),
        EventSuccessSkeletonSurface(
          titleWidth: 190,
          textLines: 3,
          trailingChips: 0,
        ),
      ],
    );
  }
}

class EventSuccessReportTabSkeleton extends StatelessWidget {
  const EventSuccessReportTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchSectionStack(
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessReportMetricsSkeleton(),
        EventSuccessSkeletonSurface(
          titleWidth: 180,
          textLines: 3,
          trailingChips: 2,
        ),
        EventSuccessSkeletonSurface(
          titleWidth: 140,
          textLines: 2,
          trailingChips: 0,
        ),
      ],
    );
  }
}

class EventSuccessSkeletonSurface extends StatelessWidget {
  const EventSuccessSkeletonSurface({
    super.key,
    required this.titleWidth,
    required this.textLines,
    required this.trailingChips,
  });

  final double titleWidth;
  final int textLines;
  final int trailingChips;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: titleWidth),
          gapH12,
          CatchSkeleton.textBlock(lines: textLines),
          if (trailingChips > 0) ...[
            gapH16,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (var i = 0; i < trailingChips; i++)
                  CatchSkeleton.box(
                    width: i == 0 ? 104 : 86,
                    height: CatchLayout.badgeActionHeight,
                    radius: CatchRadius.pill,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class EventSuccessSetupControlsSkeleton extends StatelessWidget {
  const EventSuccessSetupControlsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Row(
              children: [
                CatchSkeleton.box(
                  width: CatchLayout.toggleTrackWidth,
                  height: CatchLayout.toggleTrackHeight,
                  radius: CatchRadius.pill,
                ),
                gapW12,
                Expanded(child: CatchSkeleton.text()),
              ],
            ),
            if (i < 3) gapH14,
          ],
        ],
      ),
    );
  }
}

class EventSuccessLiveRosterSkeleton extends StatelessWidget {
  const EventSuccessLiveRosterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
          gapH14,
          for (var i = 0; i < 3; i++) ...[
            Row(
              children: [
                CatchSkeleton.circle(
                  size: CatchLayout.skeletonAvatarCompactExtent,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(
                        width: i == 0
                            ? CatchLayout.skeletonTextTertiaryWidth
                            : CatchLayout.skeletonTextCompactWidth,
                      ),
                      gapH6,
                      CatchSkeleton.text(
                        width: i == 2
                            ? CatchLayout.skeletonTextDetailWideWidth
                            : CatchLayout.skeletonTextBodyLongWidth,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < 2) gapH16,
          ],
        ],
      ),
    );
  }
}

class EventSuccessReportMetricsSkeleton extends StatelessWidget {
  const EventSuccessReportMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextSectionWideWidth),
          gapH14,
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextValueWidth,
                      ),
                      gapH8,
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextStatusWidth,
                      ),
                    ],
                  ),
                ),
                if (i < 2) gapW12,
              ],
            ],
          ),
        ],
      ),
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
    this.scorecard,
    this.assignments = const [],
    this.assignmentParticipantProfiles = const [],
    this.rotationAssignments = const [],
    this.rotationParticipantProfiles = const [],
    this.preferences = const [],
    this.wingmanRequests = const [],
    this.wingmanProfiles = const [],
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
    this.embedded = true,
    this.liveRoster,
    this.compactLiveControls = false,
    this.setupActionState = const EventSuccessSetupActionState(),
    this.onSaveSetup,
    this.liveActionState = const EventSuccessLiveActionState(),
    this.onSetLiveStep,
    this.onCompleteLiveGuide,
    this.onPlayLiveEffect,
    this.microPodsGenerationState =
        const EventSuccessAssignmentGenerationActionState(),
    this.rotationsGenerationState =
        const EventSuccessAssignmentGenerationActionState(),
    this.onGenerateMicroPods,
    this.onGenerateGuidedRotations,
    this.onOverrideGroupAssignments,
    this.onOverrideGuidedRotations,
    this.revealActionState = const EventSuccessRevealActionState(),
    this.onStartRevealCountdown,
    this.onRevealRound,
    this.onResetReveal,
    this.fixtureActions,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final EventSuccessScorecard? scorecard;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> assignmentParticipantProfiles;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<PublicProfile> rotationParticipantProfiles;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> wingmanProfiles;
  final EventSuccessHostTab initialTab;
  final bool showTabs;
  final bool embedded;
  final Widget? liveRoster;
  final bool compactLiveControls;
  final EventSuccessSetupActionState setupActionState;
  final Future<void> Function(EventSuccessSetupSaveRequest request)?
  onSaveSetup;
  final EventSuccessLiveActionState liveActionState;
  final Future<void> Function(int stepIndex)? onSetLiveStep;
  final Future<void> Function()? onCompleteLiveGuide;
  final Future<void> Function(EventSuccessLiveEffectKind kind)?
  onPlayLiveEffect;
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
    final shrinkWrap = widget.embedded;
    final physics = widget.embedded
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics();
    final padding = widget.embedded
        ? EdgeInsets.zero
        : CatchInsets.contentRelaxed;

    final body = switch (_selectedTab) {
      EventSuccessHostTab.setup => SetupTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        actionState: widget.setupActionState,
        onSaveSetup: _setupSaveCallback(),
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
      EventSuccessHostTab.live => LiveTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        roster: widget.roster,
        assignments: widget.assignments,
        assignmentParticipantProfiles: widget.assignmentParticipantProfiles,
        rotationAssignments: widget.rotationAssignments,
        rotationParticipantProfiles: widget.rotationParticipantProfiles,
        preferences: widget.preferences,
        wingmanRequests: widget.wingmanRequests,
        wingmanProfiles: widget.wingmanProfiles,
        liveRoster: widget.liveRoster,
        compactLiveControls: widget.compactLiveControls,
        actionState: widget.liveActionState,
        onPreviousStep: _liveStepCallback(
          widget.fixtureActions?.onPreviousStep,
        ),
        onNextStep: _liveStepCallback(widget.fixtureActions?.onNextStep),
        onCompleteGuide: _liveCompleteCallback(),
        microPodsGenerationState: widget.microPodsGenerationState,
        rotationsGenerationState: widget.rotationsGenerationState,
        onGenerateMicroPods: _voidFixtureCallback(
          widget.fixtureActions?.onGenerateMicroPods,
          widget.onGenerateMicroPods,
        ),
        onGenerateGuidedRotations: _voidFixtureCallback(
          widget.fixtureActions?.onGenerateGuidedRotations,
          widget.onGenerateGuidedRotations,
        ),
        onOverrideGroupAssignments: _groupOverrideCallback(),
        onOverrideGuidedRotations: _rotationOverrideCallback(),
        revealActionState: widget.revealActionState,
        onStartRevealCountdown: _startRevealCountdownCallback(),
        onRevealRound: _revealRoundCallback(),
        onResetReveal: _resetRevealCallback(),
        fixtureActions: widget.fixtureActions,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
      EventSuccessHostTab.report => ReportTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        scorecard: widget.scorecard,
        assignments: widget.assignments,
        rotationAssignments: widget.rotationAssignments,
        preferences: widget.preferences,
        wingmanRequests: widget.wingmanRequests,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
    };
    if (!widget.showTabs) return body;

    final tabs = EventSuccessTabPicker(
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
        Padding(padding: _hostTabPickerPadding, child: tabs),
        Expanded(child: body),
      ],
    );
  }

  Future<void> Function(EventSuccessSetupSaveRequest request)?
  _setupSaveCallback() {
    final fixtureAction = widget.fixtureActions?.onSaveSetup;
    if (fixtureAction != null) {
      return (_) async => fixtureAction();
    }
    return widget.onSaveSetup;
  }

  Future<void> Function(int stepIndex)? _liveStepCallback(
    VoidCallback? fixtureAction,
  ) {
    if (fixtureAction != null) {
      return (_) async {
        await widget.onPlayLiveEffect?.call(
          EventSuccessLiveEffectKind.stepChange,
        );
        fixtureAction();
      };
    }
    return widget.onSetLiveStep;
  }

  Future<void> Function()? _liveCompleteCallback() {
    final fixtureAction = widget.fixtureActions?.onCompletePlan;
    if (fixtureAction != null) {
      return () async {
        await widget.onPlayLiveEffect?.call(
          EventSuccessLiveEffectKind.guideComplete,
        );
        fixtureAction();
      };
    }
    return widget.onCompleteLiveGuide;
  }

  Future<void> Function()? _voidFixtureCallback(
    VoidCallback? fixtureAction,
    Future<void> Function()? productionAction,
  ) {
    if (fixtureAction != null) {
      return () async => fixtureAction();
    }
    return productionAction;
  }

  Future<void> Function(List<EventSuccessGroupOverrideRound> rounds)?
  _groupOverrideCallback() {
    final fixtureAction = widget.fixtureActions?.onOverrideGroupAssignments;
    final productionAction = widget.onOverrideGroupAssignments;
    if (fixtureAction == null && productionAction == null) return null;
    return (rounds) async {
      if (fixtureAction != null) {
        fixtureAction(rounds);
        return;
      }
      await productionAction?.call(rounds);
    };
  }

  Future<void> Function(List<EventSuccessRotationOverrideRound> rounds)?
  _rotationOverrideCallback() {
    final fixtureAction = widget.fixtureActions?.onOverrideGuidedRotations;
    final productionAction = widget.onOverrideGuidedRotations;
    if (fixtureAction == null && productionAction == null) return null;
    return (rounds) async {
      if (fixtureAction != null) {
        fixtureAction(rounds);
        return;
      }
      await productionAction?.call(rounds);
    };
  }

  Future<void> Function(int roundIndex, int countdownSeconds)?
  _startRevealCountdownCallback() {
    final fixtureAction = widget.fixtureActions?.onStartRevealCountdown;
    final productionAction = widget.onStartRevealCountdown;
    if (fixtureAction == null && productionAction == null) return null;
    return (roundIndex, countdownSeconds) async {
      await widget.onPlayLiveEffect?.call(
        EventSuccessLiveEffectKind.countdownStart,
      );
      if (fixtureAction != null) {
        fixtureAction(roundIndex, countdownSeconds);
        return;
      }
      await productionAction?.call(roundIndex, countdownSeconds);
    };
  }

  Future<void> Function(int roundIndex)? _revealRoundCallback() {
    final fixtureAction = widget.fixtureActions?.onRevealRound;
    final productionAction = widget.onRevealRound;
    if (fixtureAction == null && productionAction == null) return null;
    return (roundIndex) async {
      await widget.onPlayLiveEffect?.call(
        EventSuccessLiveEffectKind.assignmentRevealed,
      );
      if (fixtureAction != null) {
        fixtureAction(roundIndex);
        return;
      }
      await productionAction?.call(roundIndex);
    };
  }

  Future<void> Function()? _resetRevealCallback() {
    final fixtureAction = widget.fixtureActions?.onResetReveal;
    final productionAction = widget.onResetReveal;
    if (fixtureAction == null && productionAction == null) return null;
    return () async {
      await widget.onPlayLiveEffect?.call(
        EventSuccessLiveEffectKind.revealReset,
      );
      if (fixtureAction != null) {
        fixtureAction();
        return;
      }
      await productionAction?.call();
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
    this.onOverrideGroupAssignments,
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
  final ValueChanged<List<EventSuccessGroupOverrideRound>>?
  onOverrideGroupAssignments;
  final VoidCallback? onGenerateGuidedRotations;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>?
  onOverrideGuidedRotations;
  final void Function(int roundIndex, int countdownSeconds)?
  onStartRevealCountdown;
  final ValueChanged<int>? onRevealRound;
  final VoidCallback? onResetReveal;
}
