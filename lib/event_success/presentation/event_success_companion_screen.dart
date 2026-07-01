import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
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
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
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
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/domain/event_check_in_qr_payload.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

part 'companion_parts/event_success_companion_afterglow.dart';
part 'companion_parts/event_success_companion_arrival_mission.dart';
part 'companion_parts/event_success_companion_feedback.dart';
part 'companion_parts/event_success_companion_live_cards.dart';
part 'companion_parts/event_success_companion_questionnaire.dart';
part 'companion_parts/event_success_companion_reveal_cinematic.dart';
part 'companion_parts/event_success_companion_shared.dart';
part 'companion_parts/event_success_companion_wingman.dart';

PreferredSizeWidget _companionAppBar(BuildContext context) {
  final t = CatchTokens.of(context);
  final canPop = _companionCanPop(context);
  return CatchTopBar(
    title: 'Event companion',
    border: true,
    leading: CatchTopBarIconAction(
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
    return CompanionScaffold(body: const EventSuccessCompanionLoadingBody());
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CompanionStageSkeleton(),
              gapH16,
              const CompanionPrimaryActionSkeleton(),
              gapH16,
              const CompanionPeerListSkeleton(),
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

class CompanionPeerListSkeleton extends StatelessWidget {
  const CompanionPeerListSkeleton({super.key});

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
                        width: i == 1
                            ? CatchLayout.skeletonTextBodyWidth
                            : CatchLayout.skeletonTextBodyWideWidth,
                      ),
                      gapH6,
                      CatchSkeleton.text(
                        width: i == 2
                            ? CatchLayout.skeletonTextCardTitleWidth
                            : CatchLayout.skeletonTextDetailWidth,
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
    final uid = ref.watch(uidProvider).asData?.value;
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final event = eventAsync.asData?.value ?? initialEvent;
    final profileAsync = ref.watch(watchUserProfileProvider);
    final participationAsync = uid == null
        ? const AsyncData<EventParticipation?>(null)
        : ref.watch(watchEventParticipationProvider(eventId, uid));
    final planAsync = ref.watch(watchEventSuccessPlanProvider(eventId));
    // Wave 1: core event, profile, participation, and plan load together.
    if (eventAsync.isLoading && event == null) {
      return const CompanionLoading();
    }
    if (eventAsync.hasError) {
      return CompanionError(
        error: eventAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventProvider(eventId)),
      );
    }
    if (event == null) {
      return CompanionMessage(
        title: 'Event not found',
        message: 'This event is no longer available.',
      );
    }
    if (uid == null) {
      return CompanionMessage(
        title: 'Sign in required',
        message: 'Sign in to open your event companion.',
      );
    }
    if (profileAsync.isLoading ||
        participationAsync.isLoading ||
        planAsync.isLoading) {
      return const CompanionLoading();
    }
    if (profileAsync.hasError) {
      return CompanionError(
        error: profileAsync.error!,
        errorContext: AppErrorContext.profile,
        onRetry: () => ref.invalidate(watchUserProfileProvider),
      );
    }
    if (participationAsync.hasError) {
      return CompanionError(
        error: participationAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventParticipationProvider(eventId, uid)),
      );
    }
    if (planAsync.hasError) {
      return CompanionError(
        error: planAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventSuccessPlanProvider(eventId)),
      );
    }

    final profile = profileAsync.asData?.value;
    final participation = participationAsync.asData?.value;
    if (profile == null || participation == null) {
      return CompanionMessage(
        title: 'No booking found',
        message: 'Book this event before opening the companion.',
      );
    }

    final plan = planAsync.asData?.value;
    if (plan == null) {
      return CompanionMessage(
        title: 'Companion not available',
        message:
            'The host has not enabled the live event guide for this event yet.',
      );
    }

    final referenceNow =
        ref.watch(eventSuccessCompanionClockProvider).asData?.value ??
        DateTime.now();
    final runtime = EventSuccessRuntime(
      plan: plan,
      event: event,
      now: referenceNow,
    );
    final eventEnded = !event.endTime.isAfter(referenceNow);
    final checkInOpen = isSelfCheckInOpenForParticipationStatus(
      event: event,
      status: participation.status,
      now: referenceNow,
    );
    final firstHelloAvailable = runtime.canShowFirstHelloCheckIn(
      participationStatus: participation.status,
      checkInOpen: checkInOpen,
      eventEnded: eventEnded,
      arrivalMissionAssigned: false,
      arrivalMissionStartAvailable: true,
    );
    final AsyncValue<EventSuccessArrivalMission?> arrivalMissionAsync =
        firstHelloAvailable
        ? ref.watch(
            watchUserEventSuccessArrivalMissionProvider(
              eventId: eventId,
              uid: uid,
            ),
          )
        : const AsyncData<EventSuccessArrivalMission?>(null);

    // Wave 2: arrival mission resolves before the attendee moment so First
    // Hello can preempt questionnaire/check-in when the module is enabled.
    if (arrivalMissionAsync.isLoading) {
      return const CompanionLoading();
    }
    if (arrivalMissionAsync.hasError) {
      return CompanionError(
        error: arrivalMissionAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessArrivalMissionProvider(
            eventId: eventId,
            uid: uid,
          ),
        ),
      );
    }
    final arrivalMission = arrivalMissionAsync.asData?.value;
    final activeArrivalMission = arrivalMission?.isActive == true
        ? arrivalMission
        : null;
    final AsyncValue<EventSuccessCompatibilityResponse?> compatibilityAsync =
        !firstHelloAvailable &&
            runtime.canUseCompatibilityQuestionnaire(
              participationStatus: participation.status,
              eventEnded: eventEnded,
            )
        ? ref.watch(
            watchUserEventSuccessCompatibilityResponseProvider(
              eventId: eventId,
              uid: uid,
            ),
          )
        : const AsyncData<EventSuccessCompatibilityResponse?>(null);

    // Wave 2: compatibility response, resolved before the attendee moment.
    if (compatibilityAsync.isLoading) {
      return const CompanionLoading();
    }
    if (compatibilityAsync.hasError) {
      return CompanionError(
        error: compatibilityAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessCompatibilityResponseProvider(
            eventId: eventId,
            uid: uid,
          ),
        ),
      );
    }

    final attendeeMoment = runtime.attendeeMoment(
      participationStatus: participation.status,
      checkInOpen: checkInOpen,
      eventEnded: eventEnded,
      compatibilityResponseSaved: compatibilityAsync.asData?.value != null,
      arrivalMissionAssigned: activeArrivalMission != null,
      arrivalMissionStartAvailable: firstHelloAvailable,
    );
    final shouldLoadFeedback = attendeeMoment.showFeedback;
    final shouldLoadWingmanRequest = attendeeMoment.showWingmanRequest;
    final shouldLoadAssignment =
        attendeeMoment.showPodAssignment ||
        (attendeeMoment.showLiveReveal &&
            attendeeMoment.assignmentModuleId ==
                EventSuccessModuleCatalog.microPods.id);
    final shouldLoadRotations =
        attendeeMoment.showRotationSchedule ||
        (attendeeMoment.showLiveReveal &&
            attendeeMoment.assignmentModuleId ==
                EventSuccessModuleCatalog.guidedRotations.id);
    final AsyncValue<EventSuccessPreference?> preferenceAsync =
        attendeeMoment.showPreCheckInPlanning ||
            shouldLoadAssignment ||
            shouldLoadRotations
        ? ref.watch(
            watchUserEventSuccessPreferenceProvider(eventId: eventId, uid: uid),
          )
        : const AsyncData<EventSuccessPreference?>(null);
    final microPodsOptedOut =
        preferenceAsync.asData?.value?.microPodsOptedOut ?? false;
    final guidedRotationsOptedOut =
        preferenceAsync.asData?.value?.guidedRotationsOptedOut ?? false;
    final AsyncValue<EventSuccessFeedback?> feedbackAsync = shouldLoadFeedback
        ? ref.watch(
            watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
          )
        : const AsyncData<EventSuccessFeedback?>(null);
    final AsyncValue<List<PublicProfile>> candidatesAsync =
        shouldLoadWingmanRequest
        ? ref.watch(
            wingmanRequestCandidatesProvider(
              eventId: eventId,
              currentUser: profile,
            ),
          )
        : const AsyncData(<PublicProfile>[]);
    final AsyncValue<EventSuccessWingmanRequest?> wingmanRequestAsync =
        shouldLoadWingmanRequest
        ? ref.watch(
            watchUserEventSuccessWingmanRequestProvider(
              eventId: eventId,
              uid: uid,
            ),
          )
        : const AsyncData<EventSuccessWingmanRequest?>(null);
    final AsyncValue<EventSuccessAssignment?> assignmentAsync =
        shouldLoadAssignment && !preferenceAsync.isLoading && !microPodsOptedOut
        ? ref.watch(
            watchUserEventSuccessAssignmentProvider(eventId: eventId, uid: uid),
          )
        : const AsyncData<EventSuccessAssignment?>(null);
    final AsyncValue<EventSuccessAssignment?> rotationAsync =
        shouldLoadRotations &&
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
    if (feedbackAsync.isLoading ||
        preferenceAsync.isLoading ||
        wingmanRequestAsync.isLoading ||
        assignmentAsync.isLoading ||
        rotationAsync.isLoading) {
      return const CompanionLoading();
    }
    if (feedbackAsync.hasError) {
      return CompanionError(
        error: feedbackAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (assignmentAsync.hasError) {
      return CompanionError(
        error: assignmentAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessAssignmentProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (rotationAsync.hasError) {
      return CompanionError(
        error: rotationAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessRotationAssignmentProvider(
            eventId: eventId,
            uid: uid,
          ),
        ),
      );
    }
    if (preferenceAsync.hasError) {
      return CompanionError(
        error: preferenceAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessPreferenceProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (wingmanRequestAsync.hasError) {
      return CompanionError(
        error: wingmanRequestAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessWingmanRequestProvider(
            eventId: eventId,
            uid: uid,
          ),
        ),
      );
    }
    if (candidatesAsync.hasError) {
      return CompanionError(
        error: candidatesAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          wingmanRequestCandidatesProvider(
            eventId: eventId,
            currentUser: profile,
          ),
        ),
      );
    }

    final candidates = candidatesAsync.asData?.value ?? const <PublicProfile>[];
    final feedback = feedbackAsync.asData?.value;
    final assignment = assignmentAsync.asData?.value;
    final rotationAssignment = rotationAsync.asData?.value;
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

    // Surface companion action failures (feedback, wingman, opt-outs, first
    // hello, match clues). These run as fire-and-forget mutations from the
    // cards, so without these listeners a failed write would be silent.
    return _wrapCompanionMutationListeners(
      EventSuccessCompanionScreen(
        event: event,
        plan: plan,
        userProfile: profile,
        participation: participation,
        wingmanRequestCandidates: candidates,
        wingmanRequest: wingmanRequestAsync.asData?.value,
        compatibilityResponse: compatibilityAsync.asData?.value,
        existingFeedback: feedback,
        assignment: assignment,
        assignmentPeerProfiles:
            peersAsync.asData?.value ?? const <PublicProfile>[],
        assignmentPeersLoading: peersAsync.isLoading,
        microPodsOptedOut: microPodsOptedOut,
        rotationAssignment: rotationAssignment,
        rotationPeerProfiles:
            rotationPeersAsync.asData?.value ?? const <PublicProfile>[],
        rotationPeersLoading: rotationPeersAsync.isLoading,
        guidedRotationsOptedOut: guidedRotationsOptedOut,
        arrivalMission: activeArrivalMission,
        now: referenceNow,
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
      ),
    );
  }

  Widget _wrapCompanionMutationListeners(Widget child) =>
      CatchMutationErrorListener(
        mutation: EventSuccessController.feedbackMutation,
        child: CatchMutationErrorListener(
          mutation: EventSuccessController.compatibilityResponseMutation,
          child: CatchMutationErrorListener(
            mutation: EventSuccessController.wingmanRequestMutation,
            child: CatchMutationErrorListener(
              mutation: EventSuccessController.firstHelloStartMutation,
              child: CatchMutationErrorListener(
                mutation: EventSuccessController.firstHelloCompleteMutation,
                child: CatchMutationErrorListener(
                  mutation: EventSuccessController.microPodsOptOutMutation,
                  child: CatchMutationErrorListener(
                    mutation:
                        EventSuccessController.guidedRotationsOptOutMutation,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

@immutable
class EventSuccessCompanionScreenState {
  const EventSuccessCompanionScreenState({
    required this.runtime,
    required this.attendeeMoment,
    required this.presentation,
    required this.attended,
    required this.eventEnded,
    required this.checkInOpen,
    required this.wingmanCandidates,
    required this.revealKind,
    required this.effectKey,
    required this.usePaperShell,
  });

  factory EventSuccessCompanionScreenState.from({
    required Event event,
    required EventSuccessPlan plan,
    required UserProfile userProfile,
    required EventParticipation participation,
    required List<PublicProfile> wingmanRequestCandidates,
    required EventSuccessCompatibilityResponse? compatibilityResponse,
    required EventSuccessArrivalMission? arrivalMission,
    required bool arrivalMissionStartAvailable,
    required DateTime now,
  }) {
    final runtime = EventSuccessRuntime(plan: plan, event: event, now: now);
    final attended = participation.status == EventParticipationStatus.attended;
    final eventEnded = !event.endTime.isAfter(now);
    final checkInOpen = isSelfCheckInOpenForParticipationStatus(
      event: event,
      status: participation.status,
      now: now,
    );
    final attendeeMoment = runtime.attendeeMoment(
      participationStatus: participation.status,
      checkInOpen: checkInOpen,
      eventEnded: eventEnded,
      compatibilityResponseSaved: compatibilityResponse != null,
      arrivalMissionAssigned: arrivalMission != null,
      arrivalMissionStartAvailable: arrivalMissionStartAvailable,
    );
    final presentation = EventSuccessMomentPresentation.forMoment(
      event: event,
      plan: plan,
      moment: attendeeMoment,
      attended: attended,
      showSelfCheckIn: attendeeMoment.showSelfCheckIn,
      eventEnded: eventEnded,
    );
    final effectKey = [
      event.id,
      attendeeMoment.kind.name,
      plan.activeStepIndex,
      plan.revealStatus.name,
      plan.activeRevealRoundIndex,
      attendeeMoment.activeStep?.stage.name ?? 'no-stage',
      attendeeMoment.activeStep?.title ?? 'no-step',
    ].join(':');

    return EventSuccessCompanionScreenState(
      runtime: runtime,
      attendeeMoment: attendeeMoment,
      presentation: presentation,
      attended: attended,
      eventEnded: eventEnded,
      checkInOpen: checkInOpen,
      wingmanCandidates: _wingmanCandidatesForViewer(
        viewer: userProfile,
        candidates: wingmanRequestCandidates,
      ),
      revealKind: _revealKindForAttendeeMoment(attendeeMoment),
      effectKey: effectKey,
      usePaperShell: _shouldUsePaperCompanionShell(attendeeMoment.kind),
    );
  }

  final EventSuccessRuntime runtime;
  final EventSuccessAttendeeMoment attendeeMoment;
  final EventSuccessMomentPresentation presentation;
  final bool attended;
  final bool eventEnded;
  final bool checkInOpen;
  final List<PublicProfile> wingmanCandidates;
  final EventSuccessRevealAssignmentKind? revealKind;
  final String effectKey;
  final bool usePaperShell;

  String transitionKey(String suffix) =>
      '${attendeeMoment.kind.name}:$suffix:${runtime.plan.activeStepIndex}:'
      '${runtime.plan.revealStatus.name}:'
      '${runtime.plan.activeRevealRoundIndex}';
}

class EventSuccessCompanionScreen extends ConsumerStatefulWidget {
  const EventSuccessCompanionScreen({
    super.key,
    required this.event,
    required this.plan,
    required this.userProfile,
    required this.participation,
    required this.wingmanRequestCandidates,
    this.wingmanRequest,
    this.compatibilityResponse,
    this.existingFeedback,
    this.assignment,
    this.assignmentPeerProfiles = const [],
    this.assignmentPeersLoading = false,
    this.microPodsOptedOut = false,
    this.rotationAssignment,
    this.rotationPeerProfiles = const [],
    this.rotationPeersLoading = false,
    this.guidedRotationsOptedOut = false,
    this.arrivalMission,
    this.now,
    this.onSaveCompatibilityAnswers,
    this.onStartArrivalMission,
    this.onCompleteArrivalMission,
    this.onSkipArrivalMission,
    this.onSetMicroPodsIncluded,
    this.onSetGuidedRotationsIncluded,
    this.onSaveWingmanRequest,
    this.onWithdrawWingmanRequest,
    this.onSubmitFeedback,
    this.onSelfCheckIn,
  });

  final Event event;
  final EventSuccessPlan plan;
  final UserProfile userProfile;
  final EventParticipation participation;
  final List<PublicProfile> wingmanRequestCandidates;
  final EventSuccessWingmanRequest? wingmanRequest;
  final EventSuccessCompatibilityResponse? compatibilityResponse;
  final EventSuccessFeedback? existingFeedback;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> assignmentPeerProfiles;
  final bool assignmentPeersLoading;
  final bool microPodsOptedOut;
  final EventSuccessAssignment? rotationAssignment;
  final List<PublicProfile> rotationPeerProfiles;
  final bool rotationPeersLoading;
  final bool guidedRotationsOptedOut;
  final EventSuccessArrivalMission? arrivalMission;
  final DateTime? now;
  final Future<void> Function(List<String> answerIds)?
  onSaveCompatibilityAnswers;
  final Future<void> Function()? onStartArrivalMission;
  final Future<void> Function(
    EventSuccessArrivalMission mission,
    String answerId,
  )?
  onCompleteArrivalMission;
  final VoidCallback? onSkipArrivalMission;
  final ValueChanged<bool>? onSetMicroPodsIncluded;
  final ValueChanged<bool>? onSetGuidedRotationsIncluded;
  final Future<void> Function(PublicProfile target, String note)?
  onSaveWingmanRequest;
  final Future<void> Function()? onWithdrawWingmanRequest;
  final Future<void> Function(EventSuccessFeedback feedback)? onSubmitFeedback;
  final Future<void> Function()? onSelfCheckIn;

  @override
  ConsumerState<EventSuccessCompanionScreen> createState() =>
      _EventSuccessCompanionScreenState();
}

class _EventSuccessCompanionScreenState
    extends ConsumerState<EventSuccessCompanionScreen> {
  String? _lastEffectKey;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final plan = widget.plan;
    final referenceNow = widget.now ?? DateTime.now();
    final screenState = EventSuccessCompanionScreenState.from(
      event: event,
      plan: plan,
      userProfile: widget.userProfile,
      participation: widget.participation,
      wingmanRequestCandidates: widget.wingmanRequestCandidates,
      compatibilityResponse: widget.compatibilityResponse,
      arrivalMission: widget.arrivalMission,
      arrivalMissionStartAvailable: widget.onStartArrivalMission != null,
      now: referenceNow,
    );
    final runtime = screenState.runtime;
    final attendeeMoment = screenState.attendeeMoment;
    final momentPresentation = screenState.presentation;
    final compatibilityMutation = ref.watch(
      EventSuccessController.compatibilityResponseMutation,
    );
    final feedbackMutation = ref.watch(EventSuccessController.feedbackMutation);
    final wingmanRequestMutation = ref.watch(
      EventSuccessController.wingmanRequestMutation,
    );
    final compatibilityActionState = CompatibilityQuestionnaireActionState(
      isSaving: compatibilityMutation.isPending,
      error: compatibilityMutation.hasError
          ? (compatibilityMutation as MutationError).error
          : null,
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
    final firstHelloActionState = FirstHelloActionState(
      startPending: firstHelloStartMutation.isPending,
      completePending: firstHelloCompleteMutation.isPending,
      skipPending: selfCheckInMutation.isPending,
    );
    final selfCheckInActionState = SelfCheckInActionState(
      isCheckingIn: selfCheckInMutation.isPending,
    );
    final microPodsOptOutMutation = ref.watch(
      EventSuccessController.microPodsOptOutMutation,
    );
    final guidedRotationsOptOutMutation = ref.watch(
      EventSuccessController.guidedRotationsOptOutMutation,
    );
    final microPodsActionState = AssignmentOptOutActionState(
      optedOut: widget.microPodsOptedOut,
      isSaving: microPodsOptOutMutation.isPending,
    );
    final guidedRotationsActionState = AssignmentOptOutActionState(
      optedOut: widget.guidedRotationsOptedOut,
      isSaving: guidedRotationsOptOutMutation.isPending,
    );
    final wingmanActionState = WingmanRequestActionState(
      isSaving: wingmanRequestMutation.isPending,
    );
    final feedbackActionState = EventSuccessFeedbackActionState(
      isSaving: feedbackMutation.isPending,
    );
    _playMomentEffectOnce(screenState);

    final stageTheme = _CompanionStageTheme.forMoment(
      context,
      moment: attendeeMoment,
      plan: plan,
    );
    final momentContents = <Widget>[];

    void addMomentContent(Widget content, {String? momentKey}) {
      momentContents.add(
        momentKey == null
            ? content
            : CompanionStageContentTransition(
                momentKey: momentKey,
                child: content,
              ),
      );
    }

    if (attendeeMoment.showSelfCheckIn) {
      addMomentContent(
        SelfCheckInCard(
          event: event,
          actionState: selfCheckInActionState,
          onSelfCheckIn:
              widget.onSelfCheckIn ?? () => _defaultSelfCheckIn(event),
        ),
        momentKey: screenState.transitionKey('self-check-in'),
      );
    }
    if (attendeeMoment.showFirstHelloCheckIn) {
      addMomentContent(
        FirstHelloCheckInCard(
          mission: widget.arrivalMission,
          actionState: firstHelloActionState,
          onStart: widget.onStartArrivalMission,
          onComplete: widget.onCompleteArrivalMission,
          onSkip: widget.onSkipArrivalMission,
          onPlayCompleteEffect: () => ref
              .read(eventSuccessLiveEffectsControllerProvider)
              .play(EventSuccessLiveEffectKind.guideComplete),
        ),
        momentKey: screenState.transitionKey('first-hello'),
      );
    }
    if (attendeeMoment.showPreCheckInPlanning) {
      addMomentContent(
        PreCheckInPlanningCard(
          microPodsEnabled: runtime.microPodsEnabled,
          guidedRotationsEnabled: runtime.guidedRotationsEnabled,
          liveRevealEnabled: runtime.liveRevealEnabled,
          socialMissionsEnabled: runtime.socialMissionsEnabled,
          wingmanRequestsEnabled: runtime.wingmanRequestsEnabled,
        ),
        momentKey: screenState.transitionKey('pre-arrival'),
      );
    }
    if (attendeeMoment.showCompatibilityQuestionnaire) {
      addMomentContent(
        CompatibilityQuestionnaireSection(
          event: event,
          plan: plan,
          response: widget.compatibilityResponse,
          actionState: compatibilityActionState,
          onSaveAnswers:
              widget.onSaveCompatibilityAnswers ??
              (answerIds) async {
                await EventSuccessController.compatibilityResponseMutation.run(
                  ref,
                  (tx) => tx
                      .get(eventSuccessControllerProvider.notifier)
                      .saveCompatibilityResponse(
                        event: event,
                        answerIds: answerIds,
                        questionnaireConfig: plan.questionnaireConfig,
                      ),
                );
              },
        ),
        momentKey: screenState.transitionKey('questionnaire'),
      );
    }
    if (attendeeMoment.showPrompt) {
      addMomentContent(
        StagePromptCard(
          title: 'Social prompt',
          prompt: plan.attendeePromptFor(event),
        ),
        momentKey: screenState.transitionKey('prompt'),
      );
    }
    if (attendeeMoment.kind == EventSuccessAttendeeMomentKind.postEvent) {
      addMomentContent(
        PrivateAfterglowRecapCard(
          event: event,
          openersEnabled: attendeeMoment.showPostEventOpeners,
          feedbackEnabled: attendeeMoment.showFeedback,
          feedback: widget.existingFeedback,
        ),
        momentKey: screenState.transitionKey('afterglow-recap'),
      );
    }
    if (attendeeMoment.showConversationCues) {
      final isPostEvent = attendeeMoment.showPostEventOpeners;
      addMomentContent(
        StageConversationCueCard(
          title: isPostEvent
              ? 'Suggested first-message openers'
              : 'Conversation cues',
          subtitle: isPostEvent
              ? 'Use one after a mutual match opens.'
              : 'Pick one when the room needs an easy next line.',
          cues: isPostEvent
              ? EventSuccessConversationCueLibrary.postEventOpenersFor(event)
              : EventSuccessConversationCueLibrary.liveCuesFor(
                  event: event,
                  plan: plan,
                  activeStep: attendeeMoment.activeStep,
                ),
        ),
        momentKey: screenState.transitionKey(
          isPostEvent ? 'post-openers' : 'live-cues',
        ),
      );
    }
    if (attendeeMoment.showLiveStepContext) {
      addMomentContent(
        LiveStepContextCard(step: attendeeMoment.activeStep),
        momentKey: screenState.transitionKey('live-step'),
      );
    }
    // `showPodAssignment` and `showRotationSchedule` are mutually exclusive
    // with `showLiveReveal` at runtime (different `EventSuccessAttendeeMoment`
    // kinds), so we render the non-reveal cards here directly and let the
    // dedicated reveal branch below handle the reveal case.
    if (attendeeMoment.showPodAssignment) {
      addMomentContent(
        MicroPodCard(
          event: event,
          assignment: widget.microPodsOptedOut ? null : widget.assignment,
          peerProfiles: widget.assignmentPeerProfiles,
          peersLoading: widget.assignmentPeersLoading,
          actionState: microPodsActionState,
          onIncludeChanged:
              widget.onSetMicroPodsIncluded ??
              (include) {
                EventSuccessController.microPodsOptOutMutation.run(
                  ref,
                  (tx) => tx
                      .get(eventSuccessControllerProvider.notifier)
                      .setMicroPodsOptOut(event: event, optedOut: !include),
                );
              },
        ),
        momentKey: screenState.transitionKey('micro-pod'),
      );
    }
    if (attendeeMoment.showRotationSchedule) {
      addMomentContent(
        RotationScheduleCard(
          event: event,
          assignment: widget.guidedRotationsOptedOut
              ? null
              : widget.rotationAssignment,
          peerProfiles: widget.rotationPeerProfiles,
          peersLoading: widget.rotationPeersLoading,
          actionState: guidedRotationsActionState,
          onIncludeChanged:
              widget.onSetGuidedRotationsIncluded ??
              (include) {
                EventSuccessController.guidedRotationsOptOutMutation.run(
                  ref,
                  (tx) => tx
                      .get(eventSuccessControllerProvider.notifier)
                      .setGuidedRotationsOptOut(
                        event: event,
                        optedOut: !include,
                      ),
                );
              },
        ),
        momentKey: screenState.transitionKey('rotation-schedule'),
      );
    }
    if (attendeeMoment.showLiveReveal && screenState.revealKind != null) {
      final isRotations =
          screenState.revealKind == EventSuccessRevealAssignmentKind.rotations;
      addMomentContent(
        EventSuccessLiveRevealAttendeeCard(
          event: event,
          plan: plan,
          kind: screenState.revealKind!,
          assignment: isRotations
              ? (widget.guidedRotationsOptedOut
                    ? null
                    : widget.rotationAssignment)
              : (widget.microPodsOptedOut ? null : widget.assignment),
          peerProfiles: isRotations
              ? widget.rotationPeerProfiles
              : widget.assignmentPeerProfiles,
          peersLoading: isRotations
              ? widget.rotationPeersLoading
              : widget.assignmentPeersLoading,
          optedOut: isRotations
              ? widget.guidedRotationsOptedOut
              : widget.microPodsOptedOut,
          now: widget.now,
        ),
        momentKey: screenState.transitionKey('live-reveal'),
      );
    }
    if (attendeeMoment.showWingmanRequest) {
      addMomentContent(
        WingmanRequestSection(
          event: event,
          candidates: screenState.wingmanCandidates,
          existingRequest: widget.wingmanRequest,
          actionState: wingmanActionState,
          onSaveRequest:
              widget.onSaveWingmanRequest ??
              (target, note) async {
                await EventSuccessController.wingmanRequestMutation.run(
                  ref,
                  (tx) => tx
                      .get(eventSuccessControllerProvider.notifier)
                      .saveWingmanRequest(
                        event: event,
                        target: target,
                        note: note,
                      ),
                );
              },
          onWithdrawRequest:
              widget.onWithdrawWingmanRequest ??
              () async {
                await EventSuccessController.wingmanRequestMutation.run(
                  ref,
                  (tx) => tx
                      .get(eventSuccessControllerProvider.notifier)
                      .withdrawWingmanRequest(event: event),
                );
              },
        ),
        momentKey: screenState.transitionKey('wingman'),
      );
    }
    if (attendeeMoment.showFeedback) {
      addMomentContent(
        EventSuccessFeedbackForm(
          event: event,
          userProfile: widget.userProfile,
          existingFeedback: widget.existingFeedback,
          actionState: feedbackActionState,
          onSubmitFeedback:
              widget.onSubmitFeedback ??
              (feedback) async {
                await EventSuccessController.feedbackMutation.run(
                  ref,
                  (tx) => tx
                      .get(eventSuccessControllerProvider.notifier)
                      .submitFeedback(feedback),
                );
              },
        ),
        momentKey: screenState.transitionKey('feedback'),
      );
    }
    if (!attendeeMoment.hasVisibleModule) {
      addMomentContent(
        const NoCompanionActionsCard(),
        momentKey: screenState.transitionKey('empty'),
      );
    }

    if (screenState.usePaperShell) {
      return CompanionPaperScaffold(
        event: event,
        plan: plan,
        presentation: momentPresentation,
        showSelfCheckIn: attendeeMoment.showSelfCheckIn,
        eventEnded: screenState.eventEnded,
        selfCheckInActionState: selfCheckInActionState,
        onSelfCheckIn: widget.onSelfCheckIn ?? () => _defaultSelfCheckIn(event),
      );
    }

    return CompanionStageScaffold(
      event: event,
      plan: plan,
      presentation: momentPresentation,
      stageTheme: stageTheme,
      attended: screenState.attended,
      showSelfCheckIn: attendeeMoment.showSelfCheckIn,
      eventEnded: screenState.eventEnded,
      momentKey: screenState.transitionKey('stage'),
      momentKind: attendeeMoment.kind,
      referenceNow: referenceNow,
      content: CompanionMomentStageContent(children: momentContents),
    );
  }

  Future<void> _defaultSelfCheckIn(Event event) async {
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
  }

  void _playMomentEffectOnce(EventSuccessCompanionScreenState screenState) {
    if (_lastEffectKey == screenState.effectKey) return;
    _lastEffectKey = screenState.effectKey;
    final effect = screenState.presentation.effectKind;
    final bed = screenState.presentation.ambientBed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(eventSuccessLiveEffectsControllerProvider);
      // Switch the ambient bed first so the one-shot lands over the new
      // soundscape, not the previous moment's bed.
      unawaited(controller.playAmbientBed(bed));
      if (effect != null) {
        unawaited(controller.play(effect));
      }
    });
  }
}

bool _shouldUsePaperCompanionShell(EventSuccessAttendeeMomentKind kind) {
  return switch (kind) {
    EventSuccessAttendeeMomentKind.preArrival ||
    EventSuccessAttendeeMomentKind.selfCheckIn => true,
    _ => false,
  };
}
