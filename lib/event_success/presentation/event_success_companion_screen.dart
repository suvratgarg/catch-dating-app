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
            'The host has not enabled event companion tools for this event yet.',
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

class _CompanionHero extends StatelessWidget {
  const _CompanionHero({
    required this.event,
    required this.plan,
    required this.attended,
    required this.showSelfCheckIn,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool attended;
  final bool showSelfCheckIn;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      backgroundColor: t.ink,
      borderWidth: 0,
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge(
            label: attended
                ? 'Checked in'
                : showSelfCheckIn
                ? 'Check in open'
                : 'Booked',
            tone: attended ? CatchBadgeTone.success : CatchBadgeTone.live,
            icon: attended ? Icons.check_rounded : Icons.qr_code_2_rounded,
          ),
          gapH12,
          Text(
            event.title,
            style: CatchTextStyles.displayM(context, color: t.surface),
          ),
          gapH6,
          Text(
            '${plan.playbook.title} · ${event.meetingPoint}',
            style: CatchTextStyles.bodyS(
              context,
              color: t.surface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityQuestionnaireSection extends ConsumerStatefulWidget {
  const _CompatibilityQuestionnaireSection({
    required this.event,
    required this.plan,
    required this.response,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessCompatibilityResponse? response;

  @override
  ConsumerState<_CompatibilityQuestionnaireSection> createState() =>
      _CompatibilityQuestionnaireSectionState();
}

class _CompatibilityQuestionnaireSectionState
    extends ConsumerState<_CompatibilityQuestionnaireSection> {
  late List<String> _answerIds = _initialAnswerIds;

  @override
  void didUpdateWidget(covariant _CompatibilityQuestionnaireSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response?.id != widget.response?.id ||
        oldWidget.plan.questionnaireConfig != widget.plan.questionnaireConfig ||
        !_sameAnswers(
          oldWidget.response?.answerIds,
          widget.response?.answerIds,
        )) {
      _answerIds = _initialAnswerIds;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final mutation = ref.watch(
      EventSuccessController.compatibilityResponseMutation,
    );
    final rankingOn = widget.plan.compatibilityAffectsRanking;
    final hasAnswers = _answerIds.isNotEmpty;
    final dirty = !_sameAnswers(_answerIds, widget.response?.answerIds);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Compatibility questionnaire',
                style: CatchTextStyles.titleM(context),
              ),
              CatchBadge(
                label: rankingOn ? 'Can affect rotations' : 'Clues only',
                tone: rankingOn
                    ? CatchBadgeTone.success
                    : CatchBadgeTone.neutral,
                icon: rankingOn
                    ? Icons.auto_awesome_rounded
                    : Icons.lightbulb_outline_rounded,
              ),
              if (widget.response != null)
                const CatchBadge(
                  label: 'Saved',
                  tone: CatchBadgeTone.success,
                  icon: Icons.check_rounded,
                ),
            ],
          ),
          gapH6,
          Text(
            rankingOn
                ? 'Your answers can shape reveal clues and boost generated pairings. Hosts never see individual answers.'
                : 'Your answers can shape reveal clues. Hosts never see individual answers, and pair rankings ignore them for this event.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH16,
          for (final question
              in EventSuccessCompatibilityQuestionnaire.questionsFor(
                widget.plan.questionnaireConfig,
              )) ...[
            Text(question.prompt, style: CatchTextStyles.titleS(context)),
            gapH8,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (final option in question.options)
                  CatchChip(
                    label: option.label,
                    active: _answerIds.contains(option.id),
                    onTap: () => setState(() {
                      _answerIds = _answersReplacingQuestion(
                        question: question,
                        answerId: option.id,
                      );
                    }),
                  ),
              ],
            ),
            gapH14,
          ],
          if (mutation.hasError) ...[
            Text(
              appErrorMessage(
                (mutation as MutationError).error,
                context: AppErrorContext.event,
              ),
              style: CatchTextStyles.bodyS(context, color: t.danger),
            ),
            gapH10,
          ],
          CatchButton(
            label: widget.response == null ? 'Save answers' : 'Update answers',
            isLoading: mutation.isPending,
            onPressed: !hasAnswers || !dirty || mutation.isPending
                ? null
                : () =>
                      EventSuccessController.compatibilityResponseMutation.run(
                        ref,
                        (tx) => tx
                            .get(eventSuccessControllerProvider.notifier)
                            .saveCompatibilityResponse(
                              event: widget.event,
                              answerIds: _answerIds,
                              questionnaireConfig:
                                  widget.plan.questionnaireConfig,
                            ),
                      ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  List<String> get _initialAnswerIds =>
      EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(
        widget.response?.answerIds ?? const [],
        config: widget.plan.questionnaireConfig,
      );

  List<String> _answersReplacingQuestion({
    required EventSuccessCompatibilityQuestion question,
    required String answerId,
  }) {
    final optionIds = question.options.map((option) => option.id).toSet();
    final next = _answerIds
        .where((existing) => !optionIds.contains(existing))
        .toList();
    next.add(answerId);
    return EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(
      next,
      config: widget.plan.questionnaireConfig,
    );
  }
}

class _MicroPodCard extends ConsumerWidget {
  const _MicroPodCard({
    required this.event,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.microPodsOptedOut,
  });

  final Event event;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final bool microPodsOptedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final mutation = ref.watch(EventSuccessController.microPodsOptOutMutation);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.groups_2_outlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  microPodsOptedOut
                      ? 'Micro-pods paused for you'
                      : assigned?.displayTitle ?? 'Pod assignment pending',
                  style: CatchTextStyles.titleM(context),
                ),
                gapH4,
                Text(
                  microPodsOptedOut
                      ? 'You will not be included when the host generates pods.'
                      : assigned?.displaySubtitle ??
                            'The host will publish pods once the roster is ready.',
                  style: CatchTextStyles.bodyS(context),
                ),
                if (assigned != null) ...[
                  gapH10,
                  Wrap(
                    spacing: CatchSpacing.s2,
                    runSpacing: CatchSpacing.s2,
                    children: [
                      CatchBadge(
                        label: '${assigned.peerUids.length + 1} people',
                        tone: CatchBadgeTone.neutral,
                        icon: Icons.group_outlined,
                      ),
                      if (peersLoading)
                        const CatchBadge(
                          label: 'Loading podmates',
                          tone: CatchBadgeTone.neutral,
                          icon: Icons.hourglass_empty_rounded,
                        )
                      else
                        for (final profile in peerProfiles)
                          CatchBadge(
                            label: profile.name,
                            tone: CatchBadgeTone.neutral,
                            icon: Icons.person_outline_rounded,
                          ),
                    ],
                  ),
                ],
                gapH12,
                CatchButton(
                  label: microPodsOptedOut
                      ? 'Join micro-pods'
                      : 'Skip micro-pods',
                  variant: microPodsOptedOut
                      ? CatchButtonVariant.primary
                      : CatchButtonVariant.secondary,
                  isLoading: mutation.isPending,
                  onPressed: mutation.isPending
                      ? null
                      : () =>
                            EventSuccessController.microPodsOptOutMutation.run(
                              ref,
                              (tx) => tx
                                  .get(eventSuccessControllerProvider.notifier)
                                  .setMicroPodsOptOut(
                                    event: event,
                                    optedOut: !microPodsOptedOut,
                                  ),
                            ),
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationScheduleCard extends ConsumerWidget {
  const _RotationScheduleCard({
    required this.event,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.guidedRotationsOptedOut,
  });

  final Event event;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final bool guidedRotationsOptedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final mutation = ref.watch(
      EventSuccessController.guidedRotationsOptOutMutation,
    );
    final profilesByUid = {
      for (final profile in peerProfiles) profile.uid: profile,
    };
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sync_alt_rounded, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guidedRotationsOptedOut
                      ? 'Rotations paused for you'
                      : assigned?.displayTitle ?? 'Rotation schedule pending',
                  style: CatchTextStyles.titleM(context),
                ),
                gapH4,
                Text(
                  guidedRotationsOptedOut
                      ? 'You will not be included when the host generates timed rotations.'
                      : assigned?.displaySubtitle ??
                            'The host will publish timed pairings once the roster is ready.',
                  style: CatchTextStyles.bodyS(context),
                ),
                if (assigned != null) ...[
                  gapH10,
                  if (peersLoading)
                    const CatchBadge(
                      label: 'Loading partners',
                      tone: CatchBadgeTone.neutral,
                      icon: Icons.hourglass_empty_rounded,
                    )
                  else
                    Column(
                      children: [
                        for (final slot in assigned.rotationSlots)
                          _RotationSlotRow(
                            slot: slot,
                            peerName:
                                profilesByUid[slot.peerUid]?.name ?? 'Partner',
                          ),
                      ],
                    ),
                ],
                gapH12,
                CatchButton(
                  label: guidedRotationsOptedOut
                      ? 'Join rotations'
                      : 'Skip rotations',
                  variant: guidedRotationsOptedOut
                      ? CatchButtonVariant.primary
                      : CatchButtonVariant.secondary,
                  isLoading: mutation.isPending,
                  onPressed: mutation.isPending
                      ? null
                      : () => EventSuccessController
                            .guidedRotationsOptOutMutation
                            .run(
                              ref,
                              (tx) => tx
                                  .get(eventSuccessControllerProvider.notifier)
                                  .setGuidedRotationsOptOut(
                                    event: event,
                                    optedOut: !guidedRotationsOptedOut,
                                  ),
                            ),
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationSlotRow extends StatelessWidget {
  const _RotationSlotRow({required this.slot, required this.peerName});

  final EventSuccessRotationSlot slot;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final timeRange =
        '${TimeOfDay.fromDateTime(slot.startsAt).format(context)}-'
        '${TimeOfDay.fromDateTime(slot.endsAt).format(context)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: Row(
        children: [
          CatchBadge(
            label: slot.label,
            tone: _isStrongRotationSignal(slot.compatibility)
                ? CatchBadgeTone.success
                : CatchBadgeTone.neutral,
          ),
          gapW8,
          Expanded(
            child: Text(
              '$timeRange · $peerName',
              style: CatchTextStyles.bodyS(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStepContextCard extends StatelessWidget {
  const _LiveStepContextCard({required this.step});

  final EventRunOfShowStep? step;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activeStep = step;
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      activeStep == null ? 'Event is live' : activeStep.title,
                      style: CatchTextStyles.titleM(context),
                    ),
                    if (activeStep != null)
                      CatchBadge(
                        label: activeStep.stage.label,
                        tone: CatchBadgeTone.neutral,
                      ),
                  ],
                ),
                gapH4,
                Text(
                  activeStep?.attendeeExperience ??
                      'Follow the host for the next event moment.',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreCheckInPlanningCard extends ConsumerWidget {
  const _PreCheckInPlanningCard({
    required this.event,
    required this.microPodsEnabled,
    required this.guidedRotationsEnabled,
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
  });

  final Event event;
  final bool microPodsEnabled;
  final bool guidedRotationsEnabled;
  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final microPodsMutation = ref.watch(
      EventSuccessController.microPodsOptOutMutation,
    );
    final rotationsMutation = ref.watch(
      EventSuccessController.guidedRotationsOptOutMutation,
    );

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_available_outlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Before you arrive',
                      style: CatchTextStyles.titleM(context),
                    ),
                    const CatchBadge(
                      label: 'Pre-arrival',
                      tone: CatchBadgeTone.neutral,
                      icon: Icons.schedule_rounded,
                    ),
                  ],
                ),
                gapH4,
                Text(
                  'Live partner and pod details unlock after check-in. Set planning preferences now so the host can prepare clean assignments.',
                  style: CatchTextStyles.bodyS(context),
                ),
                gapH12,
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    if (microPodsEnabled)
                      CatchButton(
                        label: microPodsOptedOut
                            ? 'Join micro-pods'
                            : 'Skip micro-pods',
                        size: CatchButtonSize.sm,
                        variant: microPodsOptedOut
                            ? CatchButtonVariant.primary
                            : CatchButtonVariant.secondary,
                        icon: Icon(
                          microPodsOptedOut
                              ? Icons.groups_2_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        isLoading: microPodsMutation.isPending,
                        onPressed: microPodsMutation.isPending
                            ? null
                            : () => EventSuccessController
                                  .microPodsOptOutMutation
                                  .run(
                                    ref,
                                    (tx) => tx
                                        .get(
                                          eventSuccessControllerProvider
                                              .notifier,
                                        )
                                        .setMicroPodsOptOut(
                                          event: event,
                                          optedOut: !microPodsOptedOut,
                                        ),
                                  ),
                      ),
                    if (guidedRotationsEnabled)
                      CatchButton(
                        label: guidedRotationsOptedOut
                            ? 'Join rotations'
                            : 'Skip rotations',
                        size: CatchButtonSize.sm,
                        variant: guidedRotationsOptedOut
                            ? CatchButtonVariant.primary
                            : CatchButtonVariant.secondary,
                        icon: Icon(
                          guidedRotationsOptedOut
                              ? Icons.sync_alt_rounded
                              : Icons.block_outlined,
                        ),
                        isLoading: rotationsMutation.isPending,
                        onPressed: rotationsMutation.isPending
                            ? null
                            : () => EventSuccessController
                                  .guidedRotationsOptOutMutation
                                  .run(
                                    ref,
                                    (tx) => tx
                                        .get(
                                          eventSuccessControllerProvider
                                              .notifier,
                                        )
                                        .setGuidedRotationsOptOut(
                                          event: event,
                                          optedOut: !guidedRotationsOptedOut,
                                        ),
                                  ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoCompanionActionsCard extends StatelessWidget {
  const _NoCompanionActionsCard();

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Text(
        'No companion actions are active for this event.',
        style: CatchTextStyles.bodyS(context),
      ),
    );
  }
}

class _SelfCheckInCard extends ConsumerWidget {
  const _SelfCheckInCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(EventBookingController.selfCheckInMutation);
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arrival check-in', style: CatchTextStyles.titleM(context)),
          gapH6,
          Text(
            'Confirm you are at the event so post-event follow-up only includes actual attendees.',
            style: CatchTextStyles.bodyS(context),
          ),
          gapH12,
          CatchButton(
            label: 'Check in',
            isLoading: mutation.isPending,
            onPressed: mutation.isPending
                ? null
                : () => EventBookingController.selfCheckInMutation.run(
                    ref,
                    (tx) => tx
                        .get(eventBookingControllerProvider.notifier)
                        .selfCheckIn(eventId: event.id),
                  ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _WingmanRequestSection extends ConsumerStatefulWidget {
  const _WingmanRequestSection({
    required this.event,
    required this.candidates,
    this.existingRequest,
  });

  final Event event;
  final List<PublicProfile> candidates;
  final EventSuccessWingmanRequest? existingRequest;

  @override
  ConsumerState<_WingmanRequestSection> createState() =>
      _WingmanRequestSectionState();
}

class _WingmanRequestSectionState
    extends ConsumerState<_WingmanRequestSection> {
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existingRequest?.isActive == true
        ? widget.existingRequest?.note ?? ''
        : '',
  );
  String? _optimisticTargetUid;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(EventSuccessController.wingmanRequestMutation);
    final activeRequest = widget.existingRequest?.isActive == true
        ? widget.existingRequest
        : null;
    final requestedTargetUid = _optimisticTargetUid ?? activeRequest?.targetUid;
    final requestedTargetName = requestedTargetUid == null
        ? null
        : _profileNameForUid(widget.candidates, requestedTargetUid);

    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ask the host to help',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              CatchBadge(
                label: 'Host visible',
                tone: CatchBadgeTone.live,
                icon: Icons.visibility_outlined,
              ),
            ],
          ),
          gapH4,
          Text(
            'Pick someone you would like help getting paired with. The host can see this request; the other person is not notified.',
            style: CatchTextStyles.bodyS(context),
          ),
          if (requestedTargetUid != null) ...[
            gapH12,
            CatchSurface(
              backgroundColor: CatchTokens.of(context).primarySoft,
              borderWidth: 0,
              padding: const EdgeInsets.all(CatchSpacing.s3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Request sent for ${requestedTargetName ?? 'this attendee'}.',
                      style: CatchTextStyles.bodyS(context),
                    ),
                  ),
                  gapW8,
                  CatchButton(
                    label: 'Withdraw',
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.secondary,
                    isLoading: mutation.isPending,
                    onPressed: mutation.isPending
                        ? null
                        : () => EventSuccessController.wingmanRequestMutation
                              .run(ref, (tx) async {
                                await tx
                                    .get(
                                      eventSuccessControllerProvider.notifier,
                                    )
                                    .withdrawWingmanRequest(
                                      event: widget.event,
                                    );
                                if (!mounted) return;
                                setState(() => _optimisticTargetUid = null);
                              }),
                  ),
                ],
              ),
            ),
          ],
          gapH12,
          CatchTextField(
            label: 'Private note to host',
            controller: _noteController,
            maxLines: 2,
            inputFormatters: [LengthLimitingTextInputFormatter(240)],
          ),
          gapH12,
          if (widget.candidates.isEmpty)
            Text(
              'No checked-in attendees available yet.',
              style: CatchTextStyles.bodyS(context),
            )
          else
            for (final candidate in widget.candidates)
              Padding(
                padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
                child: PersonRow(
                  data: PersonRowData(
                    name: candidate.name,
                    imageUrl: candidate.primaryPhotoThumbnailUrl,
                    seed: candidate.uid,
                    metaLine: candidate.uid == requestedTargetUid
                        ? 'Host-help request active'
                        : 'Checked in to this event',
                  ),
                  avatarSize: 40,
                  trailing: CatchButton(
                    label: candidate.uid == requestedTargetUid
                        ? 'Requested'
                        : requestedTargetUid == null
                        ? 'Ask host'
                        : 'Switch',
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.secondary,
                    isLoading:
                        mutation.isPending &&
                        candidate.uid != requestedTargetUid,
                    onPressed:
                        mutation.isPending ||
                            candidate.uid == requestedTargetUid
                        ? null
                        : () => _saveRequest(candidate),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _saveRequest(PublicProfile candidate) {
    EventSuccessController.wingmanRequestMutation.run(ref, (tx) async {
      await tx
          .get(eventSuccessControllerProvider.notifier)
          .saveWingmanRequest(
            event: widget.event,
            target: candidate,
            note: _noteController.text,
          );
      if (!mounted) return;
      setState(() => _optimisticTargetUid = candidate.uid);
    });
  }
}

String? _profileNameForUid(List<PublicProfile> profiles, String uid) {
  for (final profile in profiles) {
    if (profile.uid == uid) return profile.name;
  }
  return null;
}

List<PublicProfile> _wingmanCandidatesForViewer({
  required UserProfile viewer,
  required List<PublicProfile> candidates,
}) {
  final interestedIn = viewer.interestedInGenders.toSet();
  if (interestedIn.isEmpty) return const [];
  return [
    for (final candidate in candidates)
      if (candidate.uid != viewer.uid &&
          interestedIn.contains(candidate.gender))
        candidate,
  ];
}

class EventSuccessFeedbackForm extends StatefulWidget {
  const EventSuccessFeedbackForm({
    super.key,
    required this.event,
    required this.userProfile,
    this.existingFeedback,
  });

  final Event event;
  final UserProfile userProfile;
  final EventSuccessFeedback? existingFeedback;

  @override
  State<EventSuccessFeedbackForm> createState() =>
      _EventSuccessFeedbackFormState();
}

class _EventSuccessFeedbackFormState extends State<EventSuccessFeedbackForm> {
  late int _welcome = widget.existingFeedback?.welcomeRating ?? 4;
  late int _structure = widget.existingFeedback?.structureRating ?? 4;
  late int _metPeople = widget.existingFeedback?.metNewPeopleCount ?? 2;
  late bool _safetyConcern = widget.existingFeedback?.safetyConcern ?? false;
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existingFeedback?.privateNote ?? '',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final mutation = ref.watch(EventSuccessController.feedbackMutation);
        return CatchSurface(
          borderColor: CatchTokens.of(context).line,
          padding: const EdgeInsets.all(CatchSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event feedback', style: CatchTextStyles.titleM(context)),
              gapH4,
              Text(
                'This helps the host improve the next event.',
                style: CatchTextStyles.bodyS(context),
              ),
              gapH12,
              _RatingRow(
                label: 'Welcome',
                value: _welcome,
                onChanged: (value) => setState(() => _welcome = value),
              ),
              gapH8,
              _RatingRow(
                label: 'Structure',
                value: _structure,
                onChanged: (value) => setState(() => _structure = value),
              ),
              gapH8,
              _CounterRow(
                value: _metPeople,
                onChanged: (value) => setState(() => _metPeople = value),
              ),
              gapH8,
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _safetyConcern,
                onChanged: (value) =>
                    setState(() => _safetyConcern = value ?? false),
                title: const Text('I had a safety or comfort concern'),
              ),
              CatchTextField(
                label: 'Private note to host',
                controller: _noteController,
                maxLines: 3,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
              ),
              gapH12,
              CatchButton(
                label: widget.existingFeedback == null
                    ? 'Submit feedback'
                    : 'Update feedback',
                isLoading: mutation.isPending,
                onPressed: mutation.isPending ? null : () => _submit(ref),
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(WidgetRef ref) {
    final now = DateTime.now();
    final existing = widget.existingFeedback;
    final feedback = EventSuccessFeedback(
      id:
          existing?.id ??
          eventSuccessFeedbackId(
            eventId: widget.event.id,
            uid: widget.userProfile.uid,
          ),
      eventId: widget.event.id,
      clubId: widget.event.clubId,
      uid: widget.userProfile.uid,
      welcomeRating: _welcome,
      structureRating: _structure,
      metNewPeopleCount: _metPeople,
      safetyConcern: _safetyConcern,
      privateNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    EventSuccessController.feedbackMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .submitFeedback(feedback),
    );
  }
}

EventSuccessRevealAssignmentKind? _revealKindForAttendeeMoment(
  EventSuccessAttendeeMoment moment,
) {
  if (moment.assignmentModuleId ==
      EventSuccessModuleCatalog.guidedRotations.id) {
    return EventSuccessRevealAssignmentKind.rotations;
  }
  if (moment.assignmentModuleId == EventSuccessModuleCatalog.microPods.id) {
    return EventSuccessRevealAssignmentKind.microPods;
  }
  return null;
}

bool _sameAnswers(List<String>? a, List<String>? b) {
  final normalizedA =
      EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(a ?? const []);
  final normalizedB =
      EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(b ?? const []);
  if (normalizedA.length != normalizedB.length) return false;
  for (var i = 0; i < normalizedA.length; i++) {
    if (normalizedA[i] != normalizedB[i]) return false;
  }
  return true;
}

bool _isStrongRotationSignal(String compatibility) =>
    compatibility == 'mutual_interest' ||
    compatibility == 'questionnaire_match';

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: CatchTextStyles.titleS(context))),
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$label $i',
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_border_rounded,
            ),
            onPressed: () => onChanged(i),
          ),
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('People I met', style: CatchTextStyles.titleS(context)),
        ),
        IconButton(
          tooltip: 'Decrease people met',
          icon: const Icon(Icons.remove_circle_outline_rounded),
          onPressed: value <= 0 ? null : () => onChanged(value - 1),
        ),
        Text('$value', style: CatchTextStyles.titleM(context)),
        IconButton(
          tooltip: 'Increase people met',
          icon: const Icon(Icons.add_circle_outline_rounded),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}
