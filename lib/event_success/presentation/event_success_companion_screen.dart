import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/person_row.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
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
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'companion_parts/event_success_companion_shared.dart';
part 'companion_parts/event_success_companion_questionnaire.dart';
part 'companion_parts/event_success_companion_live_cards.dart';
part 'companion_parts/event_success_companion_wingman.dart';
part 'companion_parts/event_success_companion_feedback.dart';

AppBar _companionAppBar(BuildContext context) => AppBar(
  title: const Text('Event companion'),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_rounded),
    tooltip: 'Back',
    onPressed: () => context.pop(),
  ),
);

/// Renders [body] inside the stable companion chrome. Loading, error, and
/// content states all share this scaffold so the app bar never pops in as the
/// route's data-dependent provider waves resolve.
Widget _companionScaffold(BuildContext context, Widget body) => Scaffold(
  backgroundColor: CatchTokens.of(context).bg,
  appBar: _companionAppBar(context),
  body: body,
);

Widget _companionLoading(BuildContext context) =>
    _companionScaffold(context, const Center(child: CatchLoadingIndicator()));

Widget _companionError(
  BuildContext context,
  Object error,
  AppErrorContext errorContext,
  VoidCallback onRetry,
) => _companionScaffold(
  context,
  Center(
    child: Padding(
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: CatchInlineErrorState.fromError(
        error,
        context: errorContext,
        onRetry: onRetry,
      ),
    ),
  ),
);

Widget _companionMessage(BuildContext context, String title, String message) =>
    _companionScaffold(
      context,
      Center(
        child: Padding(
          padding: const EdgeInsets.all(CatchSpacing.s5),
          child: CatchInlineErrorState(title: title, message: message),
        ),
      ),
    );

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
      return _companionLoading(context);
    }
    if (eventAsync.hasError) {
      return _companionError(
        context,
        eventAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(watchEventProvider(eventId)),
      );
    }
    if (event == null) {
      return _companionMessage(
        context,
        'Event not found',
        'This event is no longer available.',
      );
    }
    if (uid == null) {
      return _companionMessage(
        context,
        'Sign in required',
        'Sign in to open your event companion.',
      );
    }
    if (profileAsync.isLoading ||
        participationAsync.isLoading ||
        planAsync.isLoading) {
      return _companionLoading(context);
    }
    if (profileAsync.hasError) {
      return _companionError(
        context,
        profileAsync.error!,
        AppErrorContext.profile,
        () => ref.invalidate(watchUserProfileProvider),
      );
    }
    if (participationAsync.hasError) {
      return _companionError(
        context,
        participationAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(watchEventParticipationProvider(eventId, uid)),
      );
    }
    if (planAsync.hasError) {
      return _companionError(
        context,
        planAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(watchEventSuccessPlanProvider(eventId)),
      );
    }

    final profile = profileAsync.asData?.value;
    final participation = participationAsync.asData?.value;
    if (profile == null || participation == null) {
      return _companionMessage(
        context,
        'No booking found',
        'Book this event before opening the companion.',
      );
    }

    final plan = planAsync.asData?.value;
    if (plan == null) {
      return _companionMessage(
        context,
        'Companion not available',
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
    final AsyncValue<EventSuccessCompatibilityResponse?> compatibilityAsync =
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
      return _companionLoading(context);
    }
    if (compatibilityAsync.hasError) {
      return _companionError(
        context,
        compatibilityAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(
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
      return _companionLoading(context);
    }
    if (feedbackAsync.hasError) {
      return _companionError(
        context,
        feedbackAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(
          watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (assignmentAsync.hasError) {
      return _companionError(
        context,
        assignmentAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(
          watchUserEventSuccessAssignmentProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (rotationAsync.hasError) {
      return _companionError(
        context,
        rotationAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(
          watchUserEventSuccessRotationAssignmentProvider(
            eventId: eventId,
            uid: uid,
          ),
        ),
      );
    }
    if (preferenceAsync.hasError) {
      return _companionError(
        context,
        preferenceAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(
          watchUserEventSuccessPreferenceProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (wingmanRequestAsync.hasError) {
      return _companionError(
        context,
        wingmanRequestAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(
          watchUserEventSuccessWingmanRequestProvider(
            eventId: eventId,
            uid: uid,
          ),
        ),
      );
    }
    if (candidatesAsync.hasError) {
      return _companionError(
        context,
        candidatesAsync.error!,
        AppErrorContext.event,
        () => ref.invalidate(
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
        : eventSuccessPeerUidsKey(assignment.peerUids);
    final peersAsync = peerUidsKey.isEmpty
        ? const AsyncData(<PublicProfile>[])
        : ref.watch(eventSuccessAssignmentPeerProfilesProvider(peerUidsKey));
    final rotationPeerUidsKey = rotationAssignment == null
        ? ''
        : eventSuccessPeerUidsKey(rotationAssignment.peerUids);
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
      now: referenceNow,
    );
  }
}

class EventSuccessCompanionScreen extends StatefulWidget {
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
    this.now,
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
  final DateTime? now;

  @override
  State<EventSuccessCompanionScreen> createState() =>
      _EventSuccessCompanionScreenState();
}

class _EventSuccessCompanionScreenState
    extends State<EventSuccessCompanionScreen> {
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
    );
    final wingmanCandidates = _wingmanCandidatesForViewer(
      viewer: widget.userProfile,
      candidates: widget.wingmanRequestCandidates,
    );
    final revealKind = _revealKindForAttendeeMoment(attendeeMoment);

    // Build the card stack as a flat list — each `addCard` prepends a gap so
    // spacing stays correct without cumulative-`gapH16` conditional chains.
    final children = <Widget>[
      _CompanionHero(
        event: event,
        plan: plan,
        attended: attended,
        showSelfCheckIn: attendeeMoment.showSelfCheckIn,
        eventEnded: eventEnded,
      ),
    ];
    void addCard(Widget card) {
      children.add(gapH16);
      children.add(card);
    }

    if (attendeeMoment.showSelfCheckIn) {
      addCard(_SelfCheckInCard(event: event));
    }
    if (attendeeMoment.showPreCheckInPlanning) {
      addCard(
        _PreCheckInPlanningCard(
          microPodsEnabled: runtime.microPodsEnabled,
          guidedRotationsEnabled: runtime.guidedRotationsEnabled,
          liveRevealEnabled: runtime.liveRevealEnabled,
          socialMissionsEnabled: runtime.socialMissionsEnabled,
          wingmanRequestsEnabled: runtime.wingmanRequestsEnabled,
        ),
      );
    }
    if (attendeeMoment.showCompatibilityQuestionnaire) {
      addCard(
        _CompatibilityQuestionnaireSection(
          event: event,
          plan: plan,
          response: widget.compatibilityResponse,
        ),
      );
    }
    if (attendeeMoment.showPrompt) {
      addCard(
        EventSuccessPromptCard(
          title: 'Social prompt',
          prompt: plan.attendeePromptFor(event),
        ),
      );
    }
    if (attendeeMoment.showConversationCues) {
      final isPostEvent = attendeeMoment.showPostEventOpeners;
      addCard(
        EventSuccessConversationCueCard(
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
      );
    }
    if (attendeeMoment.showLiveStepContext) {
      addCard(_LiveStepContextCard(step: attendeeMoment.activeStep));
    }
    // `showPodAssignment` and `showRotationSchedule` are mutually exclusive
    // with `showLiveReveal` at runtime (different `EventSuccessAttendeeMoment`
    // kinds), so we render the non-reveal cards here directly and let the
    // dedicated reveal branch below handle the reveal case.
    if (attendeeMoment.showPodAssignment) {
      addCard(
        _MicroPodCard(
          event: event,
          assignment: widget.microPodsOptedOut ? null : widget.assignment,
          peerProfiles: widget.assignmentPeerProfiles,
          peersLoading: widget.assignmentPeersLoading,
          microPodsOptedOut: widget.microPodsOptedOut,
        ),
      );
    }
    if (attendeeMoment.showRotationSchedule) {
      addCard(
        _RotationScheduleCard(
          event: event,
          assignment: widget.guidedRotationsOptedOut
              ? null
              : widget.rotationAssignment,
          peerProfiles: widget.rotationPeerProfiles,
          peersLoading: widget.rotationPeersLoading,
          guidedRotationsOptedOut: widget.guidedRotationsOptedOut,
        ),
      );
    }
    if (attendeeMoment.showLiveReveal && revealKind != null) {
      final isRotations =
          revealKind == EventSuccessRevealAssignmentKind.rotations;
      addCard(
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
          now: referenceNow,
        ),
      );
    }
    if (attendeeMoment.showWingmanRequest) {
      addCard(
        _WingmanRequestSection(
          event: event,
          candidates: wingmanCandidates,
          existingRequest: widget.wingmanRequest,
        ),
      );
    }
    if (attendeeMoment.showFeedback) {
      addCard(
        EventSuccessFeedbackForm(
          event: event,
          userProfile: widget.userProfile,
          existingFeedback: widget.existingFeedback,
        ),
      );
    }
    if (!attendeeMoment.hasVisibleModule) {
      addCard(const _NoCompanionActionsCard());
    }

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: _companionAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        children: children,
      ),
    );
  }
}
