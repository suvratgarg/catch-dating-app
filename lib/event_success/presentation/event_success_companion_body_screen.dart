part of 'event_success_companion_screen.dart';

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
    this.arrivalMission,
    this.now,
    this.compatibilityActionState =
        const CompatibilityQuestionnaireActionState(),
    this.firstHelloActionState = const FirstHelloActionState(),
    this.selfCheckInActionState = const SelfCheckInActionState(),
    this.isSavingMicroPodsOptOut = false,
    this.isSavingGuidedRotationsOptOut = false,
    this.wingmanActionState = const WingmanRequestActionState(),
    this.feedbackActionState = const EventSuccessFeedbackActionState(),
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
    this.onPlayLiveEffect,
    this.onPlayAmbientBed,
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
  final CompatibilityQuestionnaireActionState compatibilityActionState;
  final FirstHelloActionState firstHelloActionState;
  final SelfCheckInActionState selfCheckInActionState;
  final bool isSavingMicroPodsOptOut;
  final bool isSavingGuidedRotationsOptOut;
  final WingmanRequestActionState wingmanActionState;
  final EventSuccessFeedbackActionState feedbackActionState;
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
  final Future<void> Function(EventSuccessLiveEffectKind kind)?
  onPlayLiveEffect;
  final Future<void> Function(EventSuccessAmbientBed bed)? onPlayAmbientBed;

  @override
  State<EventSuccessCompanionScreen> createState() =>
      _EventSuccessCompanionScreenState();
}

class _EventSuccessCompanionScreenState
    extends State<EventSuccessCompanionScreen> {
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
    final compatibilityActionState = widget.compatibilityActionState;
    final firstHelloActionState = widget.firstHelloActionState;
    final selfCheckInActionState = widget.selfCheckInActionState;
    final microPodsActionState = AssignmentOptOutActionState(
      optedOut: widget.microPodsOptedOut,
      isSaving: widget.isSavingMicroPodsOptOut,
    );
    final guidedRotationsActionState = AssignmentOptOutActionState(
      optedOut: widget.guidedRotationsOptedOut,
      isSaving: widget.isSavingGuidedRotationsOptOut,
    );
    final wingmanActionState = widget.wingmanActionState;
    final feedbackActionState = widget.feedbackActionState;
    void setMicroPodsIncluded(bool include) {
      (widget.onSetMicroPodsIncluded ?? _noopIncludeChange)(include);
    }

    void setGuidedRotationsIncluded(bool include) {
      (widget.onSetGuidedRotationsIncluded ?? _noopIncludeChange)(include);
    }

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
          onSelfCheckIn: widget.onSelfCheckIn ?? _noopFuture,
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
          onPlayCompleteEffect: _playCompleteGuideEffect,
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
              _noopSaveCompatibilityAnswers,
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
          onIncludeChanged: setMicroPodsIncluded,
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
          onIncludeChanged: setGuidedRotationsIncluded,
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
          isSavingOptOut: isRotations
              ? guidedRotationsActionState.isSaving
              : microPodsActionState.isSaving,
          onIncludeChanged: isRotations
              ? setGuidedRotationsIncluded
              : setMicroPodsIncluded,
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
          onSaveRequest: widget.onSaveWingmanRequest ?? _noopSaveWingmanRequest,
          onWithdrawRequest: widget.onWithdrawWingmanRequest ?? _noopFuture,
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
          onSubmitFeedback: widget.onSubmitFeedback ?? _noopSubmitFeedback,
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
        onSelfCheckIn: widget.onSelfCheckIn ?? _noopFuture,
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

  Future<void> Function()? get _playCompleteGuideEffect {
    final onPlayLiveEffect = widget.onPlayLiveEffect;
    if (onPlayLiveEffect == null) return null;
    return () => onPlayLiveEffect(EventSuccessLiveEffectKind.guideComplete);
  }

  void _playMomentEffectOnce(EventSuccessCompanionScreenState screenState) {
    if (_lastEffectKey == screenState.effectKey) return;
    _lastEffectKey = screenState.effectKey;
    final effect = screenState.presentation.effectKind;
    final bed = screenState.presentation.ambientBed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Switch the ambient bed first so the one-shot lands over the new
      // soundscape, not the previous moment's bed.
      final onPlayAmbientBed = widget.onPlayAmbientBed;
      if (onPlayAmbientBed != null) {
        unawaited(onPlayAmbientBed(bed));
      }
      if (effect != null) {
        final onPlayLiveEffect = widget.onPlayLiveEffect;
        if (onPlayLiveEffect != null) {
          unawaited(onPlayLiveEffect(effect));
        }
      }
    });
  }
}
