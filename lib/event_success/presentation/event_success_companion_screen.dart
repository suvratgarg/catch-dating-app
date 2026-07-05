import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_privacy_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_conversation_cue.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_runtime.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/event_success_companion_clock.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen_state.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/shared/event_check_in_qr_scanner.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'companion_parts/event_success_companion_afterglow.dart';
part 'companion_parts/event_success_companion_arrival_mission.dart';
part 'companion_parts/event_success_companion_feedback.dart';
part 'companion_parts/event_success_companion_live_cards.dart';
part 'companion_parts/event_success_companion_questionnaire.dart';
part 'companion_parts/event_success_companion_reveal_cinematic.dart';
part 'companion_parts/event_success_companion_shared.dart';
part 'companion_parts/event_success_companion_wingman.dart';
part 'event_success_companion_body_screen.dart';

PreferredSizeWidget _companionAppBar(BuildContext context) {
  final t = CatchTokens.of(context);
  final canPop = _companionCanPop(context);
  return CatchTopBar(
    title: 'Event companion',
    border: true,
    leading: CatchIconAction(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: CatchIcons.arrowBackIosNewRounded,
      foregroundColor: canPop ? t.ink : t.ink3,
      onPressed: canPop ? () => _popCompanion(context) : null,
    ),
  );
}

bool _companionCanPop(BuildContext context) =>
    Navigator.maybeOf(context)?.canPop() ?? false;

void _popCompanion(BuildContext context) {
  Navigator.maybeOf(context)?.maybePop();
}

class CompanionScaffold extends StatelessWidget {
  const CompanionScaffold({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: _companionAppBar(context),
      body: body,
    );
  }
}

class CompanionLoading extends StatelessWidget {
  const CompanionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompanionScaffold(body: EventSuccessCompanionLoadingBody());
  }
}

class EventSuccessCompanionLoadingBody extends StatelessWidget {
  const EventSuccessCompanionLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: CatchInsets.pageBodyRelaxed,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CompanionStageSkeleton(),
              gapH16,
              CompanionPrimaryActionSkeleton(),
              gapH16,
              CatchSkeletonRows(
                titleWidth: CatchLayout.skeletonTextSectionWideWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanionStageSkeleton extends StatelessWidget {
  const CompanionStageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.box(
            width: CatchLayout.skeletonTextPillWidth,
            height: CatchLayout.badgeActionHeight,
            radius: CatchRadius.pill,
          ),
          gapH16,
          CatchSkeleton.text(width: CatchLayout.skeletonTextFeatureWidth),
          gapH10,
          CatchSkeleton.textBlock(),
          gapH18,
          Row(
            children: [
              Expanded(
                child: CatchSkeleton.box(
                  height: CatchLayout.controlMdMinHeight,
                  radius: CatchRadius.sm,
                ),
              ),
              gapW10,
              CatchSkeleton.box(
                width: CatchLayout.controlMdMinHeight,
                height: CatchLayout.controlMdMinHeight,
                radius: CatchRadius.sm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CompanionPrimaryActionSkeleton extends StatelessWidget {
  const CompanionPrimaryActionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextActionLabelWidth),
          gapH12,
          CatchSkeleton.textBlock(lines: 2),
          gapH16,
          CatchSkeleton.box(
            height: CatchLayout.controlMdMinHeight,
            radius: CatchRadius.sm,
          ),
        ],
      ),
    );
  }
}

class CompanionError extends StatelessWidget {
  const CompanionError({
    super.key,
    required this.error,
    required this.errorContext,
    required this.onRetry,
  });

  final Object error;
  final AppErrorContext errorContext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CompanionScaffold(
      body: Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchInlineErrorState.fromError(
            error,
            context: errorContext,
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }
}

class CompanionMessage extends StatelessWidget {
  const CompanionMessage({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return CompanionScaffold(
      body: Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchInlineErrorState(title: title, message: message),
        ),
      ),
    );
  }
}

Future<void> _noopFuture() async {}
Future<void> _noopSaveCompatibilityAnswers(List<String> answerIds) async {}
void _noopIncludeChange(bool include) {}
Future<void> _noopSaveWingmanRequest(PublicProfile target, String note) async {}
Future<void> _noopSubmitFeedback(EventSuccessFeedback feedback) async {}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => CatchAsyncState<T>.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}

class EventSuccessCompanionRouteScreen extends ConsumerWidget {
  const EventSuccessCompanionRouteScreen({
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
    final uidAsync = ref.watch(uidProvider);
    final watchedUid = uidAsync.asData?.value;
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final planAsync = ref.watch(watchEventSuccessPlanProvider(eventId));
    final referenceNow =
        ref.watch(eventSuccessCompanionClockProvider).asData?.value ??
        DateTime.now();

    final profileAsync = watchedUid == null
        ? null
        : ref.watch(watchUserProfileProvider);
    final participationAsync = watchedUid == null
        ? null
        : ref.watch(watchEventParticipationProvider(eventId, watchedUid));
    var routeState = EventSuccessCompanionRouteState.resolveCore(
      eventState: _catchAsyncState(eventAsync),
      initialEvent: initialEvent,
      uidState: _catchAsyncState(uidAsync),
      profileState: profileAsync == null
          ? null
          : _catchAsyncState(profileAsync),
      participationState: participationAsync == null
          ? null
          : _catchAsyncState(participationAsync),
      planState: _catchAsyncState(planAsync),
      referenceNow: referenceNow,
    );
    final coreGate = _buildCompanionRouteGate(
      routeState,
      ref,
      eventId: eventId,
    );
    if (coreGate != null) return coreGate;

    final event = routeState.event!;
    final uid = routeState.uid!;
    final profile = routeState.profile!;
    final participation = routeState.participation!;
    final plan = routeState.plan!;
    final AsyncValue<EventSuccessArrivalMission?> arrivalMissionAsync =
        routeState.firstHelloAvailable
        ? ref.watch(
            watchUserEventSuccessArrivalMissionProvider(
              eventId: eventId,
              uid: uid,
            ),
          )
        : const AsyncData<EventSuccessArrivalMission?>(null);

    // Wave 2: arrival mission resolves before the attendee moment so First
    // Hello can preempt questionnaire/check-in when the module is enabled.
    routeState = routeState.withArrivalMission(
      _catchAsyncState(arrivalMissionAsync),
    );
    final arrivalGate = _buildCompanionRouteGate(
      routeState,
      ref,
      eventId: eventId,
    );
    if (arrivalGate != null) return arrivalGate;

    final AsyncValue<EventSuccessCompatibilityResponse?> compatibilityAsync =
        !routeState.firstHelloAvailable &&
            routeState.runtime!.canUseCompatibilityQuestionnaire(
              participationStatus: participation.status,
              eventEnded: routeState.eventEnded,
            )
        ? ref.watch(
            watchUserEventSuccessCompatibilityResponseProvider(
              eventId: eventId,
              uid: uid,
            ),
          )
        : const AsyncData<EventSuccessCompatibilityResponse?>(null);

    // Wave 2: compatibility response, resolved before the attendee moment.
    routeState = routeState.withCompatibilityResponse(
      _catchAsyncState(compatibilityAsync),
    );
    final compatibilityGate = _buildCompanionRouteGate(
      routeState,
      ref,
      eventId: eventId,
    );
    if (compatibilityGate != null) return compatibilityGate;

    final attendeeMoment = routeState.attendeeMoment!;
    final AsyncValue<EventSuccessPreference?> preferenceAsync =
        attendeeMoment.showPreCheckInPlanning ||
            routeState.shouldLoadAssignment ||
            routeState.shouldLoadRotations
        ? ref.watch(
            watchUserEventSuccessPreferenceProvider(eventId: eventId, uid: uid),
          )
        : const AsyncData<EventSuccessPreference?>(null);
    final microPodsOptedOut =
        preferenceAsync.asData?.value?.microPodsOptedOut ?? false;
    final guidedRotationsOptedOut =
        preferenceAsync.asData?.value?.guidedRotationsOptedOut ?? false;
    final AsyncValue<EventSuccessFeedback?> feedbackAsync =
        routeState.shouldLoadFeedback
        ? ref.watch(
            watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
          )
        : const AsyncData<EventSuccessFeedback?>(null);
    final AsyncValue<List<PublicProfile>> candidatesAsync =
        routeState.shouldLoadWingmanRequest
        ? ref.watch(
            wingmanRequestCandidatesProvider(
              eventId: eventId,
              currentUser: profile,
            ),
          )
        : const AsyncData(<PublicProfile>[]);
    final AsyncValue<EventSuccessWingmanRequest?> wingmanRequestAsync =
        routeState.shouldLoadWingmanRequest
        ? ref.watch(
            watchUserEventSuccessWingmanRequestProvider(
              eventId: eventId,
              uid: uid,
            ),
          )
        : const AsyncData<EventSuccessWingmanRequest?>(null);
    final AsyncValue<EventSuccessAssignment?> assignmentAsync =
        routeState.shouldLoadAssignment &&
            !preferenceAsync.isLoading &&
            !microPodsOptedOut
        ? ref.watch(
            watchUserEventSuccessAssignmentProvider(eventId: eventId, uid: uid),
          )
        : const AsyncData<EventSuccessAssignment?>(null);
    final AsyncValue<EventSuccessAssignment?> rotationAsync =
        routeState.shouldLoadRotations &&
            !preferenceAsync.isLoading &&
            !guidedRotationsOptedOut
        ? ref.watch(
            watchUserEventSuccessRotationAssignmentProvider(
              eventId: eventId,
              uid: uid,
            ),
          )
        : const AsyncData<EventSuccessAssignment?>(null);

    // Wave 3: moment-specific feedback, preference, wingman, and assignments.
    routeState = routeState.withMomentData(
      feedbackState: _catchAsyncState(feedbackAsync),
      preferenceState: _catchAsyncState(preferenceAsync),
      wingmanCandidatesState: _catchAsyncState(candidatesAsync),
      wingmanRequestState: _catchAsyncState(wingmanRequestAsync),
      assignmentState: _catchAsyncState(assignmentAsync),
      rotationState: _catchAsyncState(rotationAsync),
    );
    final momentGate = _buildCompanionRouteGate(
      routeState,
      ref,
      eventId: eventId,
    );
    if (momentGate != null) return momentGate;

    final assignment = routeState.assignment;
    final rotationAssignment = routeState.rotationAssignment;
    final peerUidsKey = assignment == null
        ? ''
        : eventSuccessPeerUidsKey(assignment.allPeerUids);
    final peersAsync = peerUidsKey.isEmpty
        ? const AsyncData(<PublicProfile>[])
        : ref.watch(eventSuccessAssignmentPeerProfilesProvider(peerUidsKey));
    final rotationPeerUidsKey = rotationAssignment == null
        ? ''
        : eventSuccessPeerUidsKey(rotationAssignment.allPeerUids);
    final rotationPeersAsync = rotationPeerUidsKey.isEmpty
        ? const AsyncData(<PublicProfile>[])
        : ref.watch(
            eventSuccessAssignmentPeerProfilesProvider(rotationPeerUidsKey),
          );
    final compatibilityMutation = ref.watch(
      EventSuccessController.compatibilityResponseMutation,
    );
    final feedbackMutation = ref.watch(EventSuccessController.feedbackMutation);
    final wingmanRequestMutation = ref.watch(
      EventSuccessController.wingmanRequestMutation,
    );
    final firstHelloStartMutation = ref.watch(
      EventSuccessController.firstHelloStartMutation,
    );
    final firstHelloCompleteMutation = ref.watch(
      EventSuccessController.firstHelloCompleteMutation,
    );
    final selfCheckInMutation = ref.watch(
      EventBookingController.selfCheckInMutation,
    );
    final microPodsOptOutMutation = ref.watch(
      EventSuccessController.microPodsOptOutMutation,
    );
    final guidedRotationsOptOutMutation = ref.watch(
      EventSuccessController.guidedRotationsOptOutMutation,
    );

    // Surface companion action failures (feedback, wingman, opt-outs, first
    // hello, match clues). These run as fire-and-forget mutations from the
    // cards, so without these listeners a failed write would be silent.
    return CatchMutationErrorListeners(
      mutations: [
        EventSuccessController.feedbackMutation,
        EventSuccessController.compatibilityResponseMutation,
        EventSuccessController.wingmanRequestMutation,
        EventSuccessController.firstHelloStartMutation,
        EventSuccessController.firstHelloCompleteMutation,
        EventBookingController.selfCheckInMutation,
        EventSuccessController.microPodsOptOutMutation,
        EventSuccessController.guidedRotationsOptOutMutation,
      ],
      child: EventSuccessCompanionScreen(
        event: event,
        plan: plan,
        userProfile: profile,
        participation: participation,
        wingmanRequestCandidates: routeState.wingmanRequestCandidates,
        wingmanRequest: routeState.wingmanRequest,
        compatibilityResponse: routeState.compatibilityResponse,
        existingFeedback: routeState.feedback,
        assignment: assignment,
        assignmentPeerProfiles:
            peersAsync.asData?.value ?? const <PublicProfile>[],
        assignmentPeersLoading: peersAsync.isLoading,
        microPodsOptedOut: routeState.microPodsOptedOut,
        rotationAssignment: rotationAssignment,
        rotationPeerProfiles:
            rotationPeersAsync.asData?.value ?? const <PublicProfile>[],
        rotationPeersLoading: rotationPeersAsync.isLoading,
        guidedRotationsOptedOut: routeState.guidedRotationsOptedOut,
        arrivalMission: routeState.activeArrivalMission,
        now: routeState.referenceNow!,
        compatibilityActionState: CompatibilityQuestionnaireActionState(
          isSaving: compatibilityMutation.isPending,
          error: compatibilityMutation.hasError
              ? (compatibilityMutation as MutationError).error
              : null,
        ),
        firstHelloActionState: FirstHelloActionState(
          startPending: firstHelloStartMutation.isPending,
          completePending: firstHelloCompleteMutation.isPending,
          skipPending: selfCheckInMutation.isPending,
        ),
        selfCheckInActionState: SelfCheckInActionState(
          isCheckingIn: selfCheckInMutation.isPending,
        ),
        isSavingMicroPodsOptOut: microPodsOptOutMutation.isPending,
        isSavingGuidedRotationsOptOut: guidedRotationsOptOutMutation.isPending,
        wingmanActionState: WingmanRequestActionState(
          isSaving: wingmanRequestMutation.isPending,
        ),
        feedbackActionState: EventSuccessFeedbackActionState(
          isSaving: feedbackMutation.isPending,
        ),
        onStartArrivalMission: () async {
          await EventSuccessController.firstHelloStartMutation.run(
            ref,
            (tx) => tx
                .get(eventSuccessControllerProvider.notifier)
                .startFirstHelloMission(event: event),
          );
        },
        onCompleteArrivalMission: (mission, answerId) async {
          await EventSuccessController.firstHelloCompleteMutation.run(
            ref,
            (tx) => tx
                .get(eventSuccessControllerProvider.notifier)
                .completeFirstHelloMission(
                  event: event,
                  mission: mission,
                  answerId: answerId,
                ),
          );
        },
        onSkipArrivalMission: () {
          EventBookingController.selfCheckInMutation.run(
            ref,
            (tx) => tx
                .get(eventBookingControllerProvider.notifier)
                .selfCheckIn(eventId: event.id),
          );
        },
        onSetMicroPodsIncluded: (include) {
          EventSuccessController.microPodsOptOutMutation.run(
            ref,
            (tx) => tx
                .get(eventSuccessControllerProvider.notifier)
                .setMicroPodsOptOut(event: event, optedOut: !include),
          );
        },
        onSetGuidedRotationsIncluded: (include) {
          EventSuccessController.guidedRotationsOptOutMutation.run(
            ref,
            (tx) => tx
                .get(eventSuccessControllerProvider.notifier)
                .setGuidedRotationsOptOut(event: event, optedOut: !include),
          );
        },
        onSaveWingmanRequest: (target, note) async {
          await EventSuccessController.wingmanRequestMutation.run(
            ref,
            (tx) => tx
                .get(eventSuccessControllerProvider.notifier)
                .saveWingmanRequest(event: event, target: target, note: note),
          );
        },
        onWithdrawWingmanRequest: () async {
          await EventSuccessController.wingmanRequestMutation.run(
            ref,
            (tx) => tx
                .get(eventSuccessControllerProvider.notifier)
                .withdrawWingmanRequest(event: event),
          );
        },
        onSubmitFeedback: (feedback) async {
          await EventSuccessController.feedbackMutation.run(
            ref,
            (tx) => tx
                .get(eventSuccessControllerProvider.notifier)
                .submitFeedback(feedback),
          );
        },
        onSelfCheckIn: () async {
          unawaited(
            ref
                .read(eventSuccessLiveEffectsControllerProvider)
                .play(EventSuccessLiveEffectKind.liveEntry),
          );
          await EventBookingController.selfCheckInMutation.run(
            ref,
            (tx) => tx
                .get(eventBookingControllerProvider.notifier)
                .selfCheckIn(eventId: event.id),
          );
        },
        onPlayLiveEffect: (kind) =>
            ref.read(eventSuccessLiveEffectsControllerProvider).play(kind),
        onPlayAmbientBed: (bed) => ref
            .read(eventSuccessLiveEffectsControllerProvider)
            .playAmbientBed(bed),
      ),
    );
  }
}

Widget? _buildCompanionRouteGate(
  EventSuccessCompanionRouteState state,
  WidgetRef ref, {
  required String eventId,
}) {
  return switch (state.status) {
    EventSuccessCompanionRouteStatus.loading => const CompanionLoading(),
    EventSuccessCompanionRouteStatus.message => CompanionMessage(
      title: state.message!.title,
      message: state.message!.message,
    ),
    EventSuccessCompanionRouteStatus.error => CompanionError(
      error: state.error!,
      errorContext: state.errorContext!,
      onRetry: _companionRouteRetryCallback(ref, state, eventId: eventId),
    ),
    EventSuccessCompanionRouteStatus.ready => null,
  };
}

VoidCallback _companionRouteRetryCallback(
  WidgetRef ref,
  EventSuccessCompanionRouteState state, {
  required String eventId,
}) {
  return () {
    switch (state.retryIntent) {
      case EventSuccessCompanionRetryIntent.event:
        ref.invalidate(watchEventProvider(eventId));
      case EventSuccessCompanionRetryIntent.uid:
        ref.invalidate(uidProvider);
      case EventSuccessCompanionRetryIntent.profile:
        ref.invalidate(watchUserProfileProvider);
      case EventSuccessCompanionRetryIntent.participation:
        final uid = state.uid;
        if (uid != null) {
          ref.invalidate(watchEventParticipationProvider(eventId, uid));
        }
      case EventSuccessCompanionRetryIntent.plan:
        ref.invalidate(watchEventSuccessPlanProvider(eventId));
      case EventSuccessCompanionRetryIntent.arrivalMission:
        final uid = state.uid;
        if (uid != null) {
          ref.invalidate(
            watchUserEventSuccessArrivalMissionProvider(
              eventId: eventId,
              uid: uid,
            ),
          );
        }
      case EventSuccessCompanionRetryIntent.compatibility:
        final uid = state.uid;
        if (uid != null) {
          ref.invalidate(
            watchUserEventSuccessCompatibilityResponseProvider(
              eventId: eventId,
              uid: uid,
            ),
          );
        }
      case EventSuccessCompanionRetryIntent.feedback:
        final uid = state.uid;
        if (uid != null) {
          ref.invalidate(
            watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
          );
        }
      case EventSuccessCompanionRetryIntent.assignment:
        final uid = state.uid;
        if (uid != null) {
          ref.invalidate(
            watchUserEventSuccessAssignmentProvider(eventId: eventId, uid: uid),
          );
        }
      case EventSuccessCompanionRetryIntent.rotationAssignment:
        final uid = state.uid;
        if (uid != null) {
          ref.invalidate(
            watchUserEventSuccessRotationAssignmentProvider(
              eventId: eventId,
              uid: uid,
            ),
          );
        }
      case EventSuccessCompanionRetryIntent.preference:
        final uid = state.uid;
        if (uid != null) {
          ref.invalidate(
            watchUserEventSuccessPreferenceProvider(eventId: eventId, uid: uid),
          );
        }
      case EventSuccessCompanionRetryIntent.wingmanRequest:
        final uid = state.uid;
        if (uid != null) {
          ref.invalidate(
            watchUserEventSuccessWingmanRequestProvider(
              eventId: eventId,
              uid: uid,
            ),
          );
        }
      case EventSuccessCompanionRetryIntent.wingmanCandidates:
        final profile = state.profile;
        if (profile != null) {
          ref.invalidate(
            wingmanRequestCandidatesProvider(
              eventId: eventId,
              currentUser: profile,
            ),
          );
        }
      case null:
        break;
    }
  };
}
