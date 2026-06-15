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
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
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
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_check_in_qr_payload.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

part 'companion_parts/event_success_companion_shared.dart';
part 'companion_parts/event_success_companion_reveal_cinematic.dart';
part 'companion_parts/event_success_companion_questionnaire.dart';
part 'companion_parts/event_success_companion_arrival_mission.dart';
part 'companion_parts/event_success_companion_live_cards.dart';
part 'companion_parts/event_success_companion_wingman.dart';
part 'companion_parts/event_success_companion_feedback.dart';
part 'companion_parts/event_success_companion_afterglow.dart';

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

/// Renders [body] inside the stable companion chrome. Loading, error, and
/// content states all share this scaffold so the app bar never pops in as the
/// route's data-dependent provider waves resolve.
class _CompanionScaffold extends StatelessWidget {
  const _CompanionScaffold({required this.body});

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

class _CompanionLoading extends StatelessWidget {
  const _CompanionLoading();

  @override
  Widget build(BuildContext context) {
    return const _CompanionScaffold(
      body: Center(child: CatchLoadingIndicator()),
    );
  }
}

class _CompanionError extends StatelessWidget {
  const _CompanionError({
    required this.error,
    required this.errorContext,
    required this.onRetry,
  });

  final Object error;
  final AppErrorContext errorContext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CompanionScaffold(
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

class _CompanionMessage extends StatelessWidget {
  const _CompanionMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _CompanionScaffold(
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
      return const _CompanionLoading();
    }
    if (eventAsync.hasError) {
      return _CompanionError(
        error: eventAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventProvider(eventId)),
      );
    }
    if (event == null) {
      return const _CompanionMessage(
        title: 'Event not found',
        message: 'This event is no longer available.',
      );
    }
    if (uid == null) {
      return const _CompanionMessage(
        title: 'Sign in required',
        message: 'Sign in to open your event companion.',
      );
    }
    if (profileAsync.isLoading ||
        participationAsync.isLoading ||
        planAsync.isLoading) {
      return const _CompanionLoading();
    }
    if (profileAsync.hasError) {
      return _CompanionError(
        error: profileAsync.error!,
        errorContext: AppErrorContext.profile,
        onRetry: () => ref.invalidate(watchUserProfileProvider),
      );
    }
    if (participationAsync.hasError) {
      return _CompanionError(
        error: participationAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventParticipationProvider(eventId, uid)),
      );
    }
    if (planAsync.hasError) {
      return _CompanionError(
        error: planAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventSuccessPlanProvider(eventId)),
      );
    }

    final profile = profileAsync.asData?.value;
    final participation = participationAsync.asData?.value;
    if (profile == null || participation == null) {
      return const _CompanionMessage(
        title: 'No booking found',
        message: 'Book this event before opening the companion.',
      );
    }

    final plan = planAsync.asData?.value;
    if (plan == null) {
      return const _CompanionMessage(
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
      return const _CompanionLoading();
    }
    if (arrivalMissionAsync.hasError) {
      return _CompanionError(
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
      return const _CompanionLoading();
    }
    if (compatibilityAsync.hasError) {
      return _CompanionError(
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
      return const _CompanionLoading();
    }
    if (feedbackAsync.hasError) {
      return _CompanionError(
        error: feedbackAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (assignmentAsync.hasError) {
      return _CompanionError(
        error: assignmentAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessAssignmentProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (rotationAsync.hasError) {
      return _CompanionError(
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
      return _CompanionError(
        error: preferenceAsync.error!,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessPreferenceProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (wingmanRequestAsync.hasError) {
      return _CompanionError(
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
      return _CompanionError(
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

    return EventSuccessCompanionScreen(
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
    );
  }
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
    final runtime = EventSuccessRuntime(
      plan: plan,
      event: event,
      now: referenceNow,
    );
    final attended =
        widget.participation.status == EventParticipationStatus.attended;
    final eventEnded = !widget.event.endTime.isAfter(referenceNow);
    final checkInOpen = isSelfCheckInOpenForParticipationStatus(
      event: widget.event,
      status: widget.participation.status,
      now: referenceNow,
    );
    final attendeeMoment = runtime.attendeeMoment(
      participationStatus: widget.participation.status,
      checkInOpen: checkInOpen,
      eventEnded: eventEnded,
      compatibilityResponseSaved: widget.compatibilityResponse != null,
      arrivalMissionAssigned: widget.arrivalMission != null,
      arrivalMissionStartAvailable: widget.onStartArrivalMission != null,
    );
    final momentPresentation = EventSuccessMomentPresentation.forMoment(
      event: event,
      plan: plan,
      moment: attendeeMoment,
      attended: attended,
      showSelfCheckIn: attendeeMoment.showSelfCheckIn,
      eventEnded: eventEnded,
    );
    _playMomentEffectOnce(attendeeMoment, momentPresentation);
    final wingmanCandidates = _wingmanCandidatesForViewer(
      viewer: widget.userProfile,
      candidates: widget.wingmanRequestCandidates,
    );
    final revealKind = _revealKindForAttendeeMoment(attendeeMoment);

    final stageTheme = _CompanionStageTheme.forMoment(
      context,
      moment: attendeeMoment,
      plan: plan,
    );
    final momentContents = <Widget>[];
    String transitionKey(String suffix) =>
        '${attendeeMoment.kind.name}:$suffix:${plan.activeStepIndex}:'
        '${plan.revealStatus.name}:${plan.activeRevealRoundIndex}';

    void addMomentContent(Widget content, {String? momentKey}) {
      momentContents.add(
        momentKey == null
            ? content
            : _CompanionStageContentTransition(
                momentKey: momentKey,
                child: content,
              ),
      );
    }

    if (attendeeMoment.showSelfCheckIn) {
      addMomentContent(
        _SelfCheckInCard(event: event),
        momentKey: transitionKey('self-check-in'),
      );
    }
    if (attendeeMoment.showFirstHelloCheckIn) {
      addMomentContent(
        _FirstHelloCheckInCard(
          mission: widget.arrivalMission,
          onStart: widget.onStartArrivalMission,
          onComplete: widget.onCompleteArrivalMission,
          onSkip: widget.onSkipArrivalMission,
        ),
        momentKey: transitionKey('first-hello'),
      );
    }
    if (attendeeMoment.showPreCheckInPlanning) {
      addMomentContent(
        _PreCheckInPlanningCard(
          microPodsEnabled: runtime.microPodsEnabled,
          guidedRotationsEnabled: runtime.guidedRotationsEnabled,
          liveRevealEnabled: runtime.liveRevealEnabled,
          socialMissionsEnabled: runtime.socialMissionsEnabled,
          wingmanRequestsEnabled: runtime.wingmanRequestsEnabled,
        ),
        momentKey: transitionKey('pre-arrival'),
      );
    }
    if (attendeeMoment.showCompatibilityQuestionnaire) {
      addMomentContent(
        _CompatibilityQuestionnaireSection(
          event: event,
          plan: plan,
          response: widget.compatibilityResponse,
          onSaveAnswers: widget.onSaveCompatibilityAnswers,
        ),
        momentKey: transitionKey('questionnaire'),
      );
    }
    if (attendeeMoment.showPrompt) {
      addMomentContent(
        _StagePromptCard(
          title: 'Social prompt',
          prompt: plan.attendeePromptFor(event),
        ),
        momentKey: transitionKey('prompt'),
      );
    }
    if (attendeeMoment.kind == EventSuccessAttendeeMomentKind.postEvent) {
      addMomentContent(
        _PrivateAfterglowRecapCard(
          event: event,
          openersEnabled: attendeeMoment.showPostEventOpeners,
          feedbackEnabled: attendeeMoment.showFeedback,
          feedback: widget.existingFeedback,
        ),
        momentKey: transitionKey('afterglow-recap'),
      );
    }
    if (attendeeMoment.showConversationCues) {
      final isPostEvent = attendeeMoment.showPostEventOpeners;
      addMomentContent(
        _StageConversationCueCard(
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
        momentKey: transitionKey(isPostEvent ? 'post-openers' : 'live-cues'),
      );
    }
    if (attendeeMoment.showLiveStepContext) {
      addMomentContent(
        _LiveStepContextCard(step: attendeeMoment.activeStep),
        momentKey: transitionKey('live-step'),
      );
    }
    // `showPodAssignment` and `showRotationSchedule` are mutually exclusive
    // with `showLiveReveal` at runtime (different `EventSuccessAttendeeMoment`
    // kinds), so we render the non-reveal cards here directly and let the
    // dedicated reveal branch below handle the reveal case.
    if (attendeeMoment.showPodAssignment) {
      addMomentContent(
        _MicroPodCard(
          event: event,
          assignment: widget.microPodsOptedOut ? null : widget.assignment,
          peerProfiles: widget.assignmentPeerProfiles,
          peersLoading: widget.assignmentPeersLoading,
          microPodsOptedOut: widget.microPodsOptedOut,
        ),
        momentKey: transitionKey('micro-pod'),
      );
    }
    if (attendeeMoment.showRotationSchedule) {
      addMomentContent(
        _RotationScheduleCard(
          event: event,
          assignment: widget.guidedRotationsOptedOut
              ? null
              : widget.rotationAssignment,
          peerProfiles: widget.rotationPeerProfiles,
          peersLoading: widget.rotationPeersLoading,
          guidedRotationsOptedOut: widget.guidedRotationsOptedOut,
        ),
        momentKey: transitionKey('rotation-schedule'),
      );
    }
    if (attendeeMoment.showLiveReveal && revealKind != null) {
      final isRotations =
          revealKind == EventSuccessRevealAssignmentKind.rotations;
      addMomentContent(
        EventSuccessLiveRevealAttendeeCard(
          event: event,
          plan: plan,
          kind: revealKind,
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
        momentKey: transitionKey('live-reveal'),
      );
    }
    if (attendeeMoment.showWingmanRequest) {
      addMomentContent(
        _WingmanRequestSection(
          event: event,
          candidates: wingmanCandidates,
          existingRequest: widget.wingmanRequest,
        ),
        momentKey: transitionKey('wingman'),
      );
    }
    if (attendeeMoment.showFeedback) {
      addMomentContent(
        EventSuccessFeedbackForm(
          event: event,
          userProfile: widget.userProfile,
          existingFeedback: widget.existingFeedback,
        ),
        momentKey: transitionKey('feedback'),
      );
    }
    if (!attendeeMoment.hasVisibleModule) {
      addMomentContent(
        const _NoCompanionActionsCard(),
        momentKey: transitionKey('empty'),
      );
    }

    return _CompanionStageScaffold(
      event: event,
      plan: plan,
      presentation: momentPresentation,
      stageTheme: stageTheme,
      attended: attended,
      showSelfCheckIn: attendeeMoment.showSelfCheckIn,
      eventEnded: eventEnded,
      momentKey: transitionKey('stage'),
      momentKind: attendeeMoment.kind,
      referenceNow: referenceNow,
      content: _CompanionMomentStageContent(children: momentContents),
    );
  }

  void _playMomentEffectOnce(
    EventSuccessAttendeeMoment moment,
    EventSuccessMomentPresentation presentation,
  ) {
    final key =
        '${widget.event.id}:${moment.kind.name}:${widget.plan.activeStepIndex}:'
        '${widget.plan.revealStatus.name}:${widget.plan.activeRevealRoundIndex}:'
        '${moment.activeStep?.stage.name ?? 'no-stage'}:'
        '${moment.activeStep?.title ?? 'no-step'}';
    if (_lastEffectKey == key) return;
    _lastEffectKey = key;
    final effect = presentation.effectKind;
    final bed = presentation.ambientBed;
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
