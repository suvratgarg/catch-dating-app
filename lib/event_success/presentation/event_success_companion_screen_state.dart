import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_runtime.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/widgets.dart';

enum EventSuccessCompanionRouteStatus { loading, message, error, ready }

enum EventSuccessCompanionRetryIntent {
  event,
  uid,
  profile,
  participation,
  plan,
  arrivalMission,
  compatibility,
  feedback,
  assignment,
  rotationAssignment,
  preference,
  wingmanRequest,
  wingmanCandidates,
}

@immutable
class EventSuccessCompanionRouteMessage {
  const EventSuccessCompanionRouteMessage({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

@immutable
class EventSuccessCompanionRouteState {
  const EventSuccessCompanionRouteState._({
    required this.status,
    required this.message,
    required this.error,
    required this.errorContext,
    required this.retryIntent,
    required this.event,
    required this.uid,
    required this.profile,
    required this.participation,
    required this.plan,
    required this.referenceNow,
    required this.runtime,
    required this.eventEnded,
    required this.checkInOpen,
    required this.firstHelloAvailable,
    required this.activeArrivalMission,
    required this.compatibilityResponse,
    required this.attendeeMoment,
    required this.shouldLoadFeedback,
    required this.shouldLoadWingmanRequest,
    required this.shouldLoadAssignment,
    required this.shouldLoadRotations,
    required this.feedback,
    required this.wingmanRequestCandidates,
    required this.wingmanRequest,
    required this.assignment,
    required this.rotationAssignment,
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
  });

  factory EventSuccessCompanionRouteState.resolveCore({
    required CatchAsyncState<Event?> eventState,
    required Event? initialEvent,
    required CatchAsyncState<String?> uidState,
    required CatchAsyncState<UserProfile?>? profileState,
    required CatchAsyncState<EventParticipation?>? participationState,
    required CatchAsyncState<EventSuccessPlan?> planState,
    required DateTime referenceNow,
  }) {
    final event = eventState.value ?? initialEvent;
    if (eventState.status == CatchAsyncStatus.loading && event == null) {
      return EventSuccessCompanionRouteState.loading();
    }
    if (eventState.status == CatchAsyncStatus.error &&
        eventState.error != null) {
      return EventSuccessCompanionRouteState.error(
        error: eventState.error!,
        errorContext: AppErrorContext.event,
        retryIntent: EventSuccessCompanionRetryIntent.event,
      );
    }
    if (event == null) {
      return EventSuccessCompanionRouteState.message(
        title: 'Event not found',
        message: 'This event is no longer available.',
      );
    }

    if (uidState.status == CatchAsyncStatus.loading) {
      return EventSuccessCompanionRouteState.loading(event: event);
    }
    if (uidState.status == CatchAsyncStatus.error && uidState.error != null) {
      return EventSuccessCompanionRouteState.error(
        error: uidState.error!,
        errorContext: AppErrorContext.auth,
        retryIntent: EventSuccessCompanionRetryIntent.uid,
        event: event,
      );
    }
    final uid = uidState.value;
    if (uid == null) {
      return EventSuccessCompanionRouteState.message(
        title: 'Sign in required',
        message: 'Sign in to open your event companion.',
        event: event,
      );
    }

    final profile = profileState;
    final participation = participationState;
    if (profile == null ||
        participation == null ||
        profile.status == CatchAsyncStatus.loading ||
        participation.status == CatchAsyncStatus.loading ||
        planState.status == CatchAsyncStatus.loading) {
      return EventSuccessCompanionRouteState.loading(event: event, uid: uid);
    }
    if (profile.status == CatchAsyncStatus.error && profile.error != null) {
      return EventSuccessCompanionRouteState.error(
        error: profile.error!,
        errorContext: AppErrorContext.profile,
        retryIntent: EventSuccessCompanionRetryIntent.profile,
        event: event,
        uid: uid,
      );
    }
    if (participation.status == CatchAsyncStatus.error &&
        participation.error != null) {
      return EventSuccessCompanionRouteState.error(
        error: participation.error!,
        errorContext: AppErrorContext.event,
        retryIntent: EventSuccessCompanionRetryIntent.participation,
        event: event,
        uid: uid,
      );
    }
    if (planState.status == CatchAsyncStatus.error && planState.error != null) {
      return EventSuccessCompanionRouteState.error(
        error: planState.error!,
        errorContext: AppErrorContext.event,
        retryIntent: EventSuccessCompanionRetryIntent.plan,
        event: event,
        uid: uid,
      );
    }

    final userProfile = profile.value;
    final eventParticipation = participation.value;
    if (userProfile == null || eventParticipation == null) {
      return EventSuccessCompanionRouteState.message(
        title: 'No booking found',
        message: 'Book this event before opening the companion.',
        event: event,
        uid: uid,
      );
    }

    final plan = planState.value;
    if (plan == null) {
      return EventSuccessCompanionRouteState.message(
        title: 'Companion not available',
        message:
            'The host has not enabled the live event guide for this event yet.',
        event: event,
        uid: uid,
        profile: userProfile,
        participation: eventParticipation,
      );
    }

    final runtime = EventSuccessRuntime(
      plan: plan,
      event: event,
      now: referenceNow,
    );
    final eventEnded = !event.endTime.isAfter(referenceNow);
    final checkInOpen = isSelfCheckInOpenForParticipationStatus(
      event: event,
      status: eventParticipation.status,
      now: referenceNow,
    );
    final firstHelloAvailable = runtime.canShowFirstHelloCheckIn(
      participationStatus: eventParticipation.status,
      checkInOpen: checkInOpen,
      eventEnded: eventEnded,
      arrivalMissionAssigned: false,
      arrivalMissionStartAvailable: true,
    );

    return EventSuccessCompanionRouteState._(
      status: EventSuccessCompanionRouteStatus.ready,
      message: null,
      error: null,
      errorContext: null,
      retryIntent: null,
      event: event,
      uid: uid,
      profile: userProfile,
      participation: eventParticipation,
      plan: plan,
      referenceNow: referenceNow,
      runtime: runtime,
      eventEnded: eventEnded,
      checkInOpen: checkInOpen,
      firstHelloAvailable: firstHelloAvailable,
      activeArrivalMission: null,
      compatibilityResponse: null,
      attendeeMoment: null,
      shouldLoadFeedback: false,
      shouldLoadWingmanRequest: false,
      shouldLoadAssignment: false,
      shouldLoadRotations: false,
      feedback: null,
      wingmanRequestCandidates: const <PublicProfile>[],
      wingmanRequest: null,
      assignment: null,
      rotationAssignment: null,
      microPodsOptedOut: false,
      guidedRotationsOptedOut: false,
    );
  }

  factory EventSuccessCompanionRouteState.loading({Event? event, String? uid}) {
    return EventSuccessCompanionRouteState._empty(
      status: EventSuccessCompanionRouteStatus.loading,
      event: event,
      uid: uid,
    );
  }

  factory EventSuccessCompanionRouteState.message({
    required String title,
    required String message,
    Event? event,
    String? uid,
    UserProfile? profile,
    EventParticipation? participation,
  }) {
    return EventSuccessCompanionRouteState._empty(
      status: EventSuccessCompanionRouteStatus.message,
      message: EventSuccessCompanionRouteMessage(
        title: title,
        message: message,
      ),
      event: event,
      uid: uid,
      profile: profile,
      participation: participation,
    );
  }

  factory EventSuccessCompanionRouteState.error({
    required Object error,
    required AppErrorContext errorContext,
    required EventSuccessCompanionRetryIntent retryIntent,
    Event? event,
    String? uid,
  }) {
    return EventSuccessCompanionRouteState._empty(
      status: EventSuccessCompanionRouteStatus.error,
      error: error,
      errorContext: errorContext,
      retryIntent: retryIntent,
      event: event,
      uid: uid,
    );
  }

  factory EventSuccessCompanionRouteState._empty({
    required EventSuccessCompanionRouteStatus status,
    EventSuccessCompanionRouteMessage? message,
    Object? error,
    AppErrorContext? errorContext,
    EventSuccessCompanionRetryIntent? retryIntent,
    Event? event,
    String? uid,
    UserProfile? profile,
    EventParticipation? participation,
  }) {
    return EventSuccessCompanionRouteState._(
      status: status,
      message: message,
      error: error,
      errorContext: errorContext,
      retryIntent: retryIntent,
      event: event,
      uid: uid,
      profile: profile,
      participation: participation,
      plan: null,
      referenceNow: null,
      runtime: null,
      eventEnded: false,
      checkInOpen: false,
      firstHelloAvailable: false,
      activeArrivalMission: null,
      compatibilityResponse: null,
      attendeeMoment: null,
      shouldLoadFeedback: false,
      shouldLoadWingmanRequest: false,
      shouldLoadAssignment: false,
      shouldLoadRotations: false,
      feedback: null,
      wingmanRequestCandidates: const <PublicProfile>[],
      wingmanRequest: null,
      assignment: null,
      rotationAssignment: null,
      microPodsOptedOut: false,
      guidedRotationsOptedOut: false,
    );
  }

  final EventSuccessCompanionRouteStatus status;
  final EventSuccessCompanionRouteMessage? message;
  final Object? error;
  final AppErrorContext? errorContext;
  final EventSuccessCompanionRetryIntent? retryIntent;
  final Event? event;
  final String? uid;
  final UserProfile? profile;
  final EventParticipation? participation;
  final EventSuccessPlan? plan;
  final DateTime? referenceNow;
  final EventSuccessRuntime? runtime;
  final bool eventEnded;
  final bool checkInOpen;
  final bool firstHelloAvailable;
  final EventSuccessArrivalMission? activeArrivalMission;
  final EventSuccessCompatibilityResponse? compatibilityResponse;
  final EventSuccessAttendeeMoment? attendeeMoment;
  final bool shouldLoadFeedback;
  final bool shouldLoadWingmanRequest;
  final bool shouldLoadAssignment;
  final bool shouldLoadRotations;
  final EventSuccessFeedback? feedback;
  final List<PublicProfile> wingmanRequestCandidates;
  final EventSuccessWingmanRequest? wingmanRequest;
  final EventSuccessAssignment? assignment;
  final EventSuccessAssignment? rotationAssignment;
  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;

  bool get isReady => status == EventSuccessCompanionRouteStatus.ready;

  EventSuccessCompanionRouteState withArrivalMission(
    CatchAsyncState<EventSuccessArrivalMission?> arrivalMissionState,
  ) {
    if (!isReady) return this;
    if (arrivalMissionState.status == CatchAsyncStatus.loading) {
      return _withRouteStatus(EventSuccessCompanionRouteStatus.loading);
    }
    if (arrivalMissionState.status == CatchAsyncStatus.error &&
        arrivalMissionState.error != null) {
      return _withRouteStatus(
        EventSuccessCompanionRouteStatus.error,
        error: arrivalMissionState.error,
        errorContext: AppErrorContext.event,
        retryIntent: EventSuccessCompanionRetryIntent.arrivalMission,
      );
    }
    final arrivalMission = arrivalMissionState.value;
    return _copyWith(
      activeArrivalMission: arrivalMission?.isActive == true
          ? arrivalMission
          : null,
    );
  }

  EventSuccessCompanionRouteState withCompatibilityResponse(
    CatchAsyncState<EventSuccessCompatibilityResponse?> compatibilityState,
  ) {
    if (!isReady) return this;
    if (compatibilityState.status == CatchAsyncStatus.loading) {
      return _withRouteStatus(EventSuccessCompanionRouteStatus.loading);
    }
    if (compatibilityState.status == CatchAsyncStatus.error &&
        compatibilityState.error != null) {
      return _withRouteStatus(
        EventSuccessCompanionRouteStatus.error,
        error: compatibilityState.error,
        errorContext: AppErrorContext.event,
        retryIntent: EventSuccessCompanionRetryIntent.compatibility,
      );
    }

    final moment = runtime!.attendeeMoment(
      participationStatus: participation!.status,
      checkInOpen: checkInOpen,
      eventEnded: eventEnded,
      compatibilityResponseSaved: compatibilityState.value != null,
      arrivalMissionAssigned: activeArrivalMission != null,
      arrivalMissionStartAvailable: firstHelloAvailable,
    );

    return _copyWith(
      compatibilityResponse: compatibilityState.value,
      attendeeMoment: moment,
      shouldLoadFeedback: moment.showFeedback,
      shouldLoadWingmanRequest: moment.showWingmanRequest,
      shouldLoadAssignment:
          moment.showPodAssignment ||
          (moment.showLiveReveal &&
              moment.assignmentModuleId ==
                  EventSuccessModuleCatalog.microPods.id),
      shouldLoadRotations:
          moment.showRotationSchedule ||
          (moment.showLiveReveal &&
              moment.assignmentModuleId ==
                  EventSuccessModuleCatalog.guidedRotations.id),
    );
  }

  EventSuccessCompanionRouteState withMomentData({
    required CatchAsyncState<EventSuccessFeedback?> feedbackState,
    required CatchAsyncState<EventSuccessPreference?> preferenceState,
    required CatchAsyncState<List<PublicProfile>> wingmanCandidatesState,
    required CatchAsyncState<EventSuccessWingmanRequest?> wingmanRequestState,
    required CatchAsyncState<EventSuccessAssignment?> assignmentState,
    required CatchAsyncState<EventSuccessAssignment?> rotationState,
  }) {
    if (!isReady) return this;
    if (feedbackState.status == CatchAsyncStatus.loading ||
        preferenceState.status == CatchAsyncStatus.loading ||
        wingmanRequestState.status == CatchAsyncStatus.loading ||
        assignmentState.status == CatchAsyncStatus.loading ||
        rotationState.status == CatchAsyncStatus.loading) {
      return _withRouteStatus(EventSuccessCompanionRouteStatus.loading);
    }

    final error = _firstCompanionRouteError([
      (feedbackState, EventSuccessCompanionRetryIntent.feedback),
      (assignmentState, EventSuccessCompanionRetryIntent.assignment),
      (rotationState, EventSuccessCompanionRetryIntent.rotationAssignment),
      (preferenceState, EventSuccessCompanionRetryIntent.preference),
      (wingmanRequestState, EventSuccessCompanionRetryIntent.wingmanRequest),
      (
        wingmanCandidatesState,
        EventSuccessCompanionRetryIntent.wingmanCandidates,
      ),
    ]);
    if (error != null) {
      return _withRouteStatus(
        EventSuccessCompanionRouteStatus.error,
        error: error.$1,
        errorContext: AppErrorContext.event,
        retryIntent: error.$2,
      );
    }

    final preference = preferenceState.value;
    return _copyWith(
      feedback: feedbackState.value,
      wingmanRequestCandidates:
          wingmanCandidatesState.value ?? const <PublicProfile>[],
      wingmanRequest: wingmanRequestState.value,
      assignment: assignmentState.value,
      rotationAssignment: rotationState.value,
      microPodsOptedOut: preference?.microPodsOptedOut ?? false,
      guidedRotationsOptedOut: preference?.guidedRotationsOptedOut ?? false,
    );
  }

  EventSuccessCompanionRouteState _withRouteStatus(
    EventSuccessCompanionRouteStatus status, {
    Object? error,
    AppErrorContext? errorContext,
    EventSuccessCompanionRetryIntent? retryIntent,
  }) {
    return EventSuccessCompanionRouteState._(
      status: status,
      message: null,
      error: error,
      errorContext: errorContext,
      retryIntent: retryIntent,
      event: event,
      uid: uid,
      profile: profile,
      participation: participation,
      plan: plan,
      referenceNow: referenceNow,
      runtime: runtime,
      eventEnded: eventEnded,
      checkInOpen: checkInOpen,
      firstHelloAvailable: firstHelloAvailable,
      activeArrivalMission: activeArrivalMission,
      compatibilityResponse: compatibilityResponse,
      attendeeMoment: attendeeMoment,
      shouldLoadFeedback: shouldLoadFeedback,
      shouldLoadWingmanRequest: shouldLoadWingmanRequest,
      shouldLoadAssignment: shouldLoadAssignment,
      shouldLoadRotations: shouldLoadRotations,
      feedback: feedback,
      wingmanRequestCandidates: wingmanRequestCandidates,
      wingmanRequest: wingmanRequest,
      assignment: assignment,
      rotationAssignment: rotationAssignment,
      microPodsOptedOut: microPodsOptedOut,
      guidedRotationsOptedOut: guidedRotationsOptedOut,
    );
  }

  EventSuccessCompanionRouteState _copyWith({
    EventSuccessArrivalMission? activeArrivalMission,
    EventSuccessCompatibilityResponse? compatibilityResponse,
    EventSuccessAttendeeMoment? attendeeMoment,
    bool? shouldLoadFeedback,
    bool? shouldLoadWingmanRequest,
    bool? shouldLoadAssignment,
    bool? shouldLoadRotations,
    EventSuccessFeedback? feedback,
    List<PublicProfile>? wingmanRequestCandidates,
    EventSuccessWingmanRequest? wingmanRequest,
    EventSuccessAssignment? assignment,
    EventSuccessAssignment? rotationAssignment,
    bool? microPodsOptedOut,
    bool? guidedRotationsOptedOut,
  }) {
    return EventSuccessCompanionRouteState._(
      status: EventSuccessCompanionRouteStatus.ready,
      message: null,
      error: null,
      errorContext: null,
      retryIntent: null,
      event: event,
      uid: uid,
      profile: profile,
      participation: participation,
      plan: plan,
      referenceNow: referenceNow,
      runtime: runtime,
      eventEnded: eventEnded,
      checkInOpen: checkInOpen,
      firstHelloAvailable: firstHelloAvailable,
      activeArrivalMission: activeArrivalMission ?? this.activeArrivalMission,
      compatibilityResponse:
          compatibilityResponse ?? this.compatibilityResponse,
      attendeeMoment: attendeeMoment ?? this.attendeeMoment,
      shouldLoadFeedback: shouldLoadFeedback ?? this.shouldLoadFeedback,
      shouldLoadWingmanRequest:
          shouldLoadWingmanRequest ?? this.shouldLoadWingmanRequest,
      shouldLoadAssignment: shouldLoadAssignment ?? this.shouldLoadAssignment,
      shouldLoadRotations: shouldLoadRotations ?? this.shouldLoadRotations,
      feedback: feedback ?? this.feedback,
      wingmanRequestCandidates:
          wingmanRequestCandidates ?? this.wingmanRequestCandidates,
      wingmanRequest: wingmanRequest ?? this.wingmanRequest,
      assignment: assignment ?? this.assignment,
      rotationAssignment: rotationAssignment ?? this.rotationAssignment,
      microPodsOptedOut: microPodsOptedOut ?? this.microPodsOptedOut,
      guidedRotationsOptedOut:
          guidedRotationsOptedOut ?? this.guidedRotationsOptedOut,
    );
  }
}

(Object, EventSuccessCompanionRetryIntent)? _firstCompanionRouteError(
  Iterable<(CatchAsyncState<dynamic>, EventSuccessCompanionRetryIntent)> values,
) {
  for (final (value, intent) in values) {
    if (value.status == CatchAsyncStatus.error && value.error != null) {
      return (value.error!, intent);
    }
  }
  return null;
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

class EventSuccessMomentPresentation {
  EventSuccessMomentPresentation({
    required this.badgeLabel,
    required this.headline,
    required this.body,
    required this.privacyLine,
    required this.icon,
    required this.badgeTone,
    this.effectKind,
    this.ambientBed = EventSuccessAmbientBed.theatrical,
  });

  final String badgeLabel;
  final String headline;
  final String body;
  final String privacyLine;
  final IconData icon;
  final CatchBadgeTone badgeTone;
  final EventSuccessLiveEffectKind? effectKind;
  final EventSuccessAmbientBed ambientBed;

  static EventSuccessMomentPresentation forMoment({
    required Event event,
    required EventSuccessPlan plan,
    required EventSuccessAttendeeMoment moment,
    required bool attended,
    required bool showSelfCheckIn,
    required bool eventEnded,
  }) {
    final step = moment.activeStep;
    return switch (moment.kind) {
      EventSuccessAttendeeMomentKind.preArrival => EventSuccessMomentPresentation(
        badgeLabel: 'Before arrival',
        headline: 'Your event guide is warming up.',
        body:
            'When check-in opens, this screen turns into the live guide for ${event.locationName}.',
        privacyLine:
            'Pre-event details stay informational until the host starts the room.',
        icon: CatchIcons.eventAvailableOutlined,
        badgeTone: CatchBadgeTone.live,
        effectKind: EventSuccessLiveEffectKind.liveEntry,
      ),
      EventSuccessAttendeeMomentKind.selfCheckIn =>
        EventSuccessMomentPresentation(
          badgeLabel: 'Arrival cue',
          headline: 'Check in when you reach the venue.',
          body:
              'One tap tells the host you are in the room and ready for the live flow.',
          privacyLine:
              'Check-in only updates attendance and the event companion flow.',
          icon: CatchIcons.qrCode2Rounded,
          badgeTone: CatchBadgeTone.warning,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.firstHelloCheckIn =>
        EventSuccessMomentPresentation(
          badgeLabel: 'First Hello',
          headline: 'Your first arrival mission is live.',
          body:
              'Find one person, ask one tiny question, and let the room start with permission instead of pressure.',
          privacyLine:
              'This checks you in. Hosts do not see the individual answer.',
          icon: CatchIcons.wavingHandOutlined,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.compatibilityQuestionnaire =>
        EventSuccessMomentPresentation(
          badgeLabel: 'Match clues',
          headline: 'Add a few clues before the room moves.',
          body:
              'Quick answers help Catch shape prompts without turning the event into a form.',
          privacyLine: 'Hosts do not see individual match clue answers.',
          icon: CatchIcons.tuneRounded,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.liveStepContext =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Live now',
          headline: step?.title ?? 'Follow the host for the next beat.',
          body:
              step?.attendeeExperience ??
              'The host is pacing the room from live mode.',
          privacyLine:
              'Everyone sees the same room cue; personal details stay scoped to you.',
          icon: CatchIcons.locationOnOutlined,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
          ambientBed: EventSuccessAmbientBed.pulse,
        ),
      EventSuccessAttendeeMomentKind.socialPrompt =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Live prompt',
          headline: 'A fresh prompt just dropped.',
          body:
              step?.attendeeExperience ??
              'Use it if the room needs an easy next line.',
          privacyLine:
              'Prompts are shared guidance, not a public record of what you say.',
          icon: CatchIcons.chatBubbleOutlineRounded,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
          ambientBed: EventSuccessAmbientBed.pulse,
        ),
      EventSuccessAttendeeMomentKind.conversationCues =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Conversation cues',
          headline: 'Pick a cue and keep the room moving.',
          body:
              step?.attendeeExperience ??
              'These are light nudges for the current event moment.',
          privacyLine:
              'Conversation cues are suggestions only; nothing is sent for you.',
          icon: CatchIcons.forumOutlined,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
          ambientBed: EventSuccessAmbientBed.pulse,
        ),
      EventSuccessAttendeeMomentKind.assignment => EventSuccessMomentPresentation(
        badgeLabel: 'Your next group',
        headline: 'Your assignment is ready.',
        body:
            'Use it as a nudge into the next interaction, then let the room breathe.',
        privacyLine: 'Only your own assignment details appear on this screen.',
        icon: CatchIcons.groups2Outlined,
        badgeTone: CatchBadgeTone.success,
        effectKind: EventSuccessLiveEffectKind.stepChange,
        ambientBed: EventSuccessAmbientBed.pulse,
      ),
      EventSuccessAttendeeMomentKind.liveReveal => EventSuccessMomentPresentation(
        badgeLabel: 'Shared reveal',
        headline: _revealHeroHeadline(moment, plan),
        body:
            'The host controls the timing so the room unlocks together instead of leaking awkwardly.',
        privacyLine:
            'Your details stay hidden on this screen until the shared reveal moment.',
        icon: CatchIcons.boltRounded,
        badgeTone: CatchBadgeTone.live,
        effectKind: _revealHeroEffect(plan),
        // Cinematic owns the soundscape during anticipation/climax; the bed
        // resumes from the next moment's vibe.
        ambientBed: EventSuccessAmbientBed.silent,
      ),
      EventSuccessAttendeeMomentKind.wingmanRequest =>
        EventSuccessMomentPresentation(
          badgeLabel: 'Host help',
          headline: 'Ask for one specific intro.',
          body:
              'Choose someone you want help meeting and the host can use that as live facilitation context.',
          privacyLine:
              'Only the host sees this request; the other attendee is not notified.',
          icon: CatchIcons.volunteerActivismOutlined,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.stepChange,
          ambientBed: EventSuccessAmbientBed.pulse,
        ),
      EventSuccessAttendeeMomentKind.postEvent => EventSuccessMomentPresentation(
        badgeLabel: 'Afterglow',
        headline: 'Your afterglow is ready.',
        body:
            'Keep the useful parts of the room, send private feedback, and use event-specific openers when a match appears.',
        privacyLine:
            'This recap is private to you. Hosts only see safe aggregate coaching.',
        icon: CatchIcons.nightlightRound,
        badgeTone: CatchBadgeTone.success,
        effectKind: EventSuccessLiveEffectKind.guideComplete,
        ambientBed: EventSuccessAmbientBed.sunrise,
      ),
      EventSuccessAttendeeMomentKind.none => EventSuccessMomentPresentation(
        badgeLabel: eventEnded
            ? 'Wrapped'
            : attended
            ? 'Live now'
            : 'Booked',
        headline: _heroOrientationLine(
          event: event,
          attended: attended,
          showSelfCheckIn: showSelfCheckIn,
          eventEnded: eventEnded,
        ),
        body:
            'The host is running the room. Your next prompt or reveal appears here when it is time.',
        privacyLine:
            'Catch only shows the live details that are relevant to this event moment.',
        icon: CatchIcons.eventOutlined,
        badgeTone: CatchBadgeTone.neutral,
        effectKind: attended ? EventSuccessLiveEffectKind.liveEntry : null,
        ambientBed: eventEnded
            ? EventSuccessAmbientBed.sunrise
            : EventSuccessAmbientBed.theatrical,
      ),
    };
  }
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

bool _shouldUsePaperCompanionShell(EventSuccessAttendeeMomentKind kind) {
  return switch (kind) {
    EventSuccessAttendeeMomentKind.preArrival ||
    EventSuccessAttendeeMomentKind.selfCheckIn => true,
    _ => false,
  };
}

String _revealHeroHeadline(
  EventSuccessAttendeeMoment moment,
  EventSuccessPlan plan,
) {
  if (plan.revealStatus == EventSuccessRevealStatus.revealed) {
    if (moment.assignmentModuleId ==
        EventSuccessModuleCatalog.guidedRotations.id) {
      return 'Your rotation just unlocked.';
    }
    return 'Your group just unlocked.';
  }
  if (moment.assignmentModuleId ==
      EventSuccessModuleCatalog.guidedRotations.id) {
    return 'A rotation reveal is in motion.';
  }
  return 'A group reveal is in motion.';
}

EventSuccessLiveEffectKind _revealHeroEffect(EventSuccessPlan plan) {
  if (plan.revealStatus == EventSuccessRevealStatus.revealed) {
    return EventSuccessLiveEffectKind.assignmentRevealed;
  }
  return EventSuccessLiveEffectKind.countdownStart;
}

String _heroOrientationLine({
  required Event event,
  required bool attended,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (attended && eventEnded) {
    return 'Thanks for coming. A quick feedback prompt is below.';
  }
  if (attended) {
    return 'You\'re in. Watch this screen for prompts and partner reveals.';
  }
  if (showSelfCheckIn) {
    return 'Glad you\'re coming. Check in when you arrive at ${event.locationName}.';
  }
  return 'Glad you\'re coming. We\'ll guide you here once check-in opens.';
}
