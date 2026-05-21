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
    if (eventAsync.isLoading && event == null) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (eventAsync.hasError) {
      return CatchErrorScaffold.fromError(
        eventAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventProvider(eventId)),
      );
    }
    if (event == null) {
      return const CatchErrorScaffold(
        title: 'Event not found',
        message: 'This event is no longer available.',
      );
    }
    if (uid == null) {
      return const CatchErrorScaffold(
        title: 'Sign in required',
        message: 'Sign in to open your event companion.',
      );
    }
    if (profileAsync.isLoading ||
        participationAsync.isLoading ||
        planAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (profileAsync.hasError) {
      return CatchErrorScaffold.fromError(
        profileAsync.error!,
        context: AppErrorContext.profile,
        onRetry: () => ref.invalidate(watchUserProfileProvider),
      );
    }
    if (participationAsync.hasError) {
      return CatchErrorScaffold.fromError(
        participationAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventParticipationProvider(eventId, uid)),
      );
    }
    if (planAsync.hasError) {
      return CatchErrorScaffold.fromError(
        planAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventSuccessPlanProvider(eventId)),
      );
    }

    final profile = profileAsync.asData?.value;
    final participation = participationAsync.asData?.value;
    if (profile == null || participation == null) {
      return const CatchErrorScaffold(
        title: 'No booking found',
        message: 'Book this event before opening the companion.',
      );
    }

    final plan = planAsync.asData?.value;
    if (plan == null) {
      return const CatchErrorScaffold(
        title: 'Companion not available',
        message:
            'The host has not enabled the live event guide for this event yet.',
      );
    }

    final referenceNow = DateTime.now();
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

    if (compatibilityAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (compatibilityAsync.hasError) {
      return CatchErrorScaffold.fromError(
        compatibilityAsync.error!,
        context: AppErrorContext.event,
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

    if (feedbackAsync.isLoading ||
        preferenceAsync.isLoading ||
        wingmanRequestAsync.isLoading ||
        assignmentAsync.isLoading ||
        rotationAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (feedbackAsync.hasError) {
      return CatchErrorScaffold.fromError(
        feedbackAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (assignmentAsync.hasError) {
      return CatchErrorScaffold.fromError(
        assignmentAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessAssignmentProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (rotationAsync.hasError) {
      return CatchErrorScaffold.fromError(
        rotationAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessRotationAssignmentProvider(
            eventId: eventId,
            uid: uid,
          ),
        ),
      );
    }
    if (preferenceAsync.hasError) {
      return CatchErrorScaffold.fromError(
        preferenceAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessPreferenceProvider(eventId: eventId, uid: uid),
        ),
      );
    }
    if (wingmanRequestAsync.hasError) {
      return CatchErrorScaffold.fromError(
        wingmanRequestAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessWingmanRequestProvider(
            eventId: eventId,
            uid: uid,
          ),
        ),
      );
    }
    if (candidatesAsync.hasError) {
      return CatchErrorScaffold.fromError(
        candidatesAsync.error!,
        context: AppErrorContext.event,
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
    final showPrompt = attendeeMoment.showPrompt;
    final showSelfCheckIn = attendeeMoment.showSelfCheckIn;
    final showPreCheckInPlanning = attendeeMoment.showPreCheckInPlanning;
    final showPodAssignment = attendeeMoment.showPodAssignment;
    final showRotationSchedule = attendeeMoment.showRotationSchedule;
    final showLiveReveal = attendeeMoment.showLiveReveal;
    final showCompatibilityQuestionnaire =
        attendeeMoment.showCompatibilityQuestionnaire;
    final showConversationCues = attendeeMoment.showConversationCues;
    final showPostEventOpeners = attendeeMoment.showPostEventOpeners;
    final showWingmanRequest = attendeeMoment.showWingmanRequest;
    final showFeedback = attendeeMoment.showFeedback;
    final wingmanCandidates = _wingmanCandidatesForViewer(
      viewer: widget.userProfile,
      candidates: widget.wingmanRequestCandidates,
    );
    final revealKind = _revealKindForAttendeeMoment(attendeeMoment);
    final hasVisibleModule = attendeeMoment.hasVisibleModule;

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: AppBar(
        title: const Text('Event companion'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        children: [
          _CompanionHero(
            event: event,
            plan: plan,
            attended: attended,
            showSelfCheckIn: showSelfCheckIn,
          ),
          gapH16,
          if (showSelfCheckIn) ...[_SelfCheckInCard(event: event), gapH16],
          if (showPreCheckInPlanning) ...[
            _PreCheckInPlanningCard(
              event: event,
              microPodsEnabled: runtime.microPodsEnabled,
              guidedRotationsEnabled: runtime.guidedRotationsEnabled,
              microPodsOptedOut: widget.microPodsOptedOut,
              guidedRotationsOptedOut: widget.guidedRotationsOptedOut,
            ),
            gapH16,
          ],
          if (showCompatibilityQuestionnaire)
            _CompatibilityQuestionnaireSection(
              event: event,
              plan: plan,
              response: widget.compatibilityResponse,
            ),
          if (showPrompt) ...[
            if (showCompatibilityQuestionnaire) gapH16,
            EventSuccessPromptCard(
              title: 'Social prompt',
              prompt: plan.attendeePromptFor(event),
            ),
          ],
          if (showConversationCues) ...[
            if (showPrompt || showCompatibilityQuestionnaire) gapH16,
            EventSuccessConversationCueCard(
              title: showPostEventOpeners
                  ? 'Post-match openers'
                  : 'Conversation cues',
              subtitle: showPostEventOpeners
                  ? 'Use one after a mutual match opens.'
                  : 'Pick one when the room needs an easy next line.',
              cues: showPostEventOpeners
                  ? EventSuccessConversationCueLibrary.postEventOpenersFor(
                      event,
                    )
                  : EventSuccessConversationCueLibrary.liveCuesFor(
                      event: event,
                      plan: plan,
                      activeStep: attendeeMoment.activeStep,
                    ),
            ),
          ],
          if (attendeeMoment.showLiveStepContext) ...[
            if (showPrompt ||
                showCompatibilityQuestionnaire ||
                showConversationCues)
              gapH16,
            _LiveStepContextCard(step: attendeeMoment.activeStep),
          ],
          if (showPodAssignment) ...[
            if (showPrompt ||
                showCompatibilityQuestionnaire ||
                showConversationCues ||
                attendeeMoment.showLiveStepContext)
              gapH16,
            if (showLiveReveal)
              EventSuccessLiveRevealAttendeeCard(
                event: event,
                plan: plan,
                kind: EventSuccessRevealAssignmentKind.microPods,
                assignment: widget.microPodsOptedOut ? null : widget.assignment,
                peerProfiles: widget.assignmentPeerProfiles,
                peersLoading: widget.assignmentPeersLoading,
                optedOut: widget.microPodsOptedOut,
                now: referenceNow,
              )
            else
              _MicroPodCard(
                event: event,
                assignment: widget.microPodsOptedOut ? null : widget.assignment,
                peerProfiles: widget.assignmentPeerProfiles,
                peersLoading: widget.assignmentPeersLoading,
                microPodsOptedOut: widget.microPodsOptedOut,
              ),
          ],
          if (showRotationSchedule) ...[
            if (showPrompt ||
                showCompatibilityQuestionnaire ||
                showConversationCues ||
                showPodAssignment ||
                attendeeMoment.showLiveStepContext)
              gapH16,
            if (showLiveReveal)
              EventSuccessLiveRevealAttendeeCard(
                event: event,
                plan: plan,
                kind: EventSuccessRevealAssignmentKind.rotations,
                assignment: widget.guidedRotationsOptedOut
                    ? null
                    : widget.rotationAssignment,
                peerProfiles: widget.rotationPeerProfiles,
                peersLoading: widget.rotationPeersLoading,
                optedOut: widget.guidedRotationsOptedOut,
                now: referenceNow,
              )
            else
              _RotationScheduleCard(
                event: event,
                assignment: widget.guidedRotationsOptedOut
                    ? null
                    : widget.rotationAssignment,
                peerProfiles: widget.rotationPeerProfiles,
                peersLoading: widget.rotationPeersLoading,
                guidedRotationsOptedOut: widget.guidedRotationsOptedOut,
              ),
          ],
          if (showLiveReveal && revealKind != null) ...[
            if (showPrompt ||
                showCompatibilityQuestionnaire ||
                showConversationCues ||
                attendeeMoment.showLiveStepContext)
              gapH16,
            EventSuccessLiveRevealAttendeeCard(
              event: event,
              plan: plan,
              kind: revealKind,
              assignment:
                  revealKind == EventSuccessRevealAssignmentKind.rotations
                  ? widget.guidedRotationsOptedOut
                        ? null
                        : widget.rotationAssignment
                  : widget.microPodsOptedOut
                  ? null
                  : widget.assignment,
              peerProfiles:
                  revealKind == EventSuccessRevealAssignmentKind.rotations
                  ? widget.rotationPeerProfiles
                  : widget.assignmentPeerProfiles,
              peersLoading:
                  revealKind == EventSuccessRevealAssignmentKind.rotations
                  ? widget.rotationPeersLoading
                  : widget.assignmentPeersLoading,
              optedOut: revealKind == EventSuccessRevealAssignmentKind.rotations
                  ? widget.guidedRotationsOptedOut
                  : widget.microPodsOptedOut,
              now: referenceNow,
            ),
          ],
          if (showWingmanRequest) ...[
            gapH16,
            _WingmanRequestSection(
              event: event,
              candidates: wingmanCandidates,
              existingRequest: widget.wingmanRequest,
            ),
          ],
          if (showFeedback) ...[
            gapH16,
            EventSuccessFeedbackForm(
              event: event,
              userProfile: widget.userProfile,
              existingFeedback: widget.existingFeedback,
            ),
          ],
          if (!hasVisibleModule) const _NoCompanionActionsCard(),
        ],
      ),
    );
  }
}
