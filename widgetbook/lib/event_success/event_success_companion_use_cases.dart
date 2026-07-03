import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/event_success_companion_clock.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/labs/design_fixtures/event_success_companion_fixtures.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Route states',
  type: EventSuccessCompanionRouteScreen,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessCompanionRouteStates(BuildContext context) {
  return _CompanionCatalog(
    title: 'EventSuccessCompanionRouteScreen',
    contractId: 'screen.event_success.companion',
    children: [
      _StateCard(
        label: 'route loading',
        child: _DeviceFrame(
          child: _CompanionRouteScope(eventStream: _loadingStream<Event?>()),
        ),
      ),
      _StateCard(
        label: 'event load error',
        child: _DeviceFrame(
          child: _CompanionRouteScope(
            eventStream: _errorStream<Event?>('Event failed'),
          ),
        ),
      ),
      _StateCard(
        label: 'event not found',
        child: _DeviceFrame(
          child: _CompanionRouteScope(eventStream: Stream<Event?>.value(null)),
        ),
      ),
      _StateCard(
        label: 'sign in required',
        child: const _DeviceFrame(child: _CompanionRouteScope(uid: null)),
      ),
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _CompanionRouteScope(
            profileStream: _loadingStream<UserProfile?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile error',
        child: _DeviceFrame(
          child: _CompanionRouteScope(
            profileStream: _errorStream<UserProfile?>('Profile failed'),
          ),
        ),
      ),
      _StateCard(
        label: 'participation error',
        child: _DeviceFrame(
          child: _CompanionRouteScope(
            participationStream: _errorStream<EventParticipation?>(
              'Participation failed',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'no booking',
        child: _DeviceFrame(
          child: _CompanionRouteScope(
            participationStream: Stream<EventParticipation?>.value(null),
          ),
        ),
      ),
      _StateCard(
        label: 'plan loading',
        child: _DeviceFrame(
          child: _CompanionRouteScope(
            planStream: _loadingStream<EventSuccessPlan?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'plan error',
        child: _DeviceFrame(
          child: _CompanionRouteScope(
            planStream: _errorStream<EventSuccessPlan?>('Plan failed'),
          ),
        ),
      ),
      _StateCard(
        label: 'offline plan error',
        child: _DeviceFrame(
          child: _CompanionRouteScope(
            planStream: Stream<EventSuccessPlan?>.error(
              _companionOfflineException(action: 'load event guide'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'plan missing',
        child: const _DeviceFrame(child: _CompanionRouteScope(planValue: null)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: EventSuccessCompanionScreen,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessCompanionScreenStates(BuildContext context) {
  return _CompanionCatalog(
    title: 'EventSuccessCompanionScreen',
    contractId: 'screen.event_success.companion',
    children: [
      _StateCard(
        label: 'default live guide',
        child: _DeviceFrame(
          child: _CompanionScope(now: EventSuccessCompanionFixtures.now),
        ),
      ),
      _StateCard(
        label: 'self check-in',
        child: _DeviceFrame(
          child: _CompanionScope(
            now: EventSuccessCompanionFixtures.socialStart.subtract(
              const Duration(minutes: 5),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'pre-arrival planning',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.revealUnlockedPlan,
            event: EventSuccessCompanionFixtures.racketEvent,
            participation: EventSuccessCompanionFixtures.signedUpParticipation(
              event: EventSuccessCompanionFixtures.racketEvent,
            ),
            now: EventSuccessCompanionFixtures.racketStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'First Hello start',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.firstHelloPlan,
            now: EventSuccessCompanionFixtures.socialStart.subtract(
              const Duration(minutes: 5),
            ),
            onStartArrivalMission: () async {},
            onSkipArrivalMission: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'First Hello assigned',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.firstHelloPlan,
            arrivalMission: EventSuccessCompanionFixtures.arrivalMission,
            now: EventSuccessCompanionFixtures.socialStart.subtract(
              const Duration(minutes: 5),
            ),
            onCompleteArrivalMission: (_, _) async {},
          ),
        ),
      ),
      _StateCard(
        label: 'compatibility questionnaire',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.questionnairePlan,
            now: EventSuccessCompanionFixtures.socialStart.add(
              const Duration(minutes: 30),
            ),
            onSaveCompatibilityAnswers: (_) async {},
          ),
        ),
      ),
      _StateCard(
        label: 'compatibility saved',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.questionnairePlan,
            compatibilityResponse:
                EventSuccessCompanionFixtures.compatibilityResponse,
            now: EventSuccessCompanionFixtures.socialStart.add(
              const Duration(minutes: 30),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'live step context',
        child: _DeviceFrame(
          child: _CompanionScope(
            event: EventSuccessCompanionFixtures.racketEvent,
            plan: EventSuccessCompanionFixtures.liveStepContextPlan,
            participation: EventSuccessCompanionFixtures.attendedParticipation(
              event: EventSuccessCompanionFixtures.racketEvent,
            ),
            rotationAssignment:
                EventSuccessCompanionFixtures.rotationAssignment,
            rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
            now: EventSuccessCompanionFixtures.racketStart.add(
              const Duration(minutes: 25),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'social prompt',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.socialPromptPlan,
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            now: EventSuccessCompanionFixtures.socialStart.add(
              const Duration(minutes: 12),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'conversation cues',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.conversationCuesPlan,
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            now: EventSuccessCompanionFixtures.socialStart.add(
              const Duration(minutes: 50),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'assigned starter pod',
        child: _DeviceFrame(
          child: _CompanionScope(
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            assignment: EventSuccessCompanionFixtures.microPodAssignment,
            assignmentPeerProfiles: EventSuccessCompanionFixtures.peers,
            now: EventSuccessCompanionFixtures.socialStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'starter pod loading peers',
        child: _DeviceFrame(
          child: _CompanionScope(
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            assignment: EventSuccessCompanionFixtures.microPodAssignment,
            assignmentPeersLoading: true,
            now: EventSuccessCompanionFixtures.socialStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'starter pod opted out',
        child: _DeviceFrame(
          child: _CompanionScope(
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            microPodsOptedOut: true,
            now: EventSuccessCompanionFixtures.socialStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'table group rotations',
        child: _DeviceFrame(
          child: _CompanionScope(
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            assignment: EventSuccessCompanionFixtures.tableAssignment,
            assignmentPeerProfiles: EventSuccessCompanionFixtures.peers,
            now: EventSuccessCompanionFixtures.socialStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'rotation schedule',
        child: _DeviceFrame(
          child: _CompanionScope(
            event: EventSuccessCompanionFixtures.racketEvent,
            plan: EventSuccessCompanionFixtures.rotationSchedulePlan,
            participation: EventSuccessCompanionFixtures.attendedParticipation(
              event: EventSuccessCompanionFixtures.racketEvent,
            ),
            rotationAssignment:
                EventSuccessCompanionFixtures.rotationAssignment,
            rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
            now: EventSuccessCompanionFixtures.racketStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'rotation loading peers',
        child: _DeviceFrame(
          child: _CompanionScope(
            event: EventSuccessCompanionFixtures.racketEvent,
            plan: EventSuccessCompanionFixtures.rotationSchedulePlan,
            participation: EventSuccessCompanionFixtures.attendedParticipation(
              event: EventSuccessCompanionFixtures.racketEvent,
            ),
            rotationAssignment:
                EventSuccessCompanionFixtures.rotationAssignment,
            rotationPeersLoading: true,
            now: EventSuccessCompanionFixtures.racketStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'rotation opted out',
        child: _DeviceFrame(
          child: _CompanionScope(
            event: EventSuccessCompanionFixtures.racketEvent,
            plan: EventSuccessCompanionFixtures.rotationSchedulePlan,
            participation: EventSuccessCompanionFixtures.attendedParticipation(
              event: EventSuccessCompanionFixtures.racketEvent,
            ),
            guidedRotationsOptedOut: true,
            now: EventSuccessCompanionFixtures.racketStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'live reveal locked',
        child: _DeviceFrame(
          child: _CompanionScope(
            event: EventSuccessCompanionFixtures.racketEvent,
            plan: EventSuccessCompanionFixtures.revealCountingDownPlan,
            participation: EventSuccessCompanionFixtures.attendedParticipation(
              event: EventSuccessCompanionFixtures.racketEvent,
            ),
            rotationAssignment:
                EventSuccessCompanionFixtures.rotationAssignment,
            rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
            now: EventSuccessCompanionFixtures.racketStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'live reveal unlocked',
        child: _DeviceFrame(
          child: _CompanionScope(
            event: EventSuccessCompanionFixtures.racketEvent,
            plan: EventSuccessCompanionFixtures.revealUnlockedPlan,
            participation: EventSuccessCompanionFixtures.attendedParticipation(
              event: EventSuccessCompanionFixtures.racketEvent,
            ),
            rotationAssignment:
                EventSuccessCompanionFixtures.rotationAssignment,
            rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
            now: EventSuccessCompanionFixtures.racketStart.subtract(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'wingman request',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.wingmanPlan,
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            wingmanRequestCandidates: EventSuccessCompanionFixtures.peers,
            now: EventSuccessCompanionFixtures.socialStart.add(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'wingman request submitted',
        child: _DeviceFrame(
          child: _CompanionScope(
            plan: EventSuccessCompanionFixtures.wingmanPlan,
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            wingmanRequestCandidates: EventSuccessCompanionFixtures.peers,
            wingmanRequest: EventSuccessCompanionFixtures.wingmanRequest,
            now: EventSuccessCompanionFixtures.socialStart.add(
              const Duration(hours: 1),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'afterglow feedback',
        child: _DeviceFrame(
          child: _CompanionScope(
            participation:
                EventSuccessCompanionFixtures.attendedParticipation(),
            existingFeedback: EventSuccessCompanionFixtures.feedback,
            now: EventSuccessCompanionFixtures.socialEvent.endTime.add(
              const Duration(hours: 2),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _CompanionScope(
              participation:
                  EventSuccessCompanionFixtures.attendedParticipation(),
              assignment: EventSuccessCompanionFixtures.microPodAssignment,
              assignmentPeerProfiles: EventSuccessCompanionFixtures.peers,
              now: EventSuccessCompanionFixtures.socialStart.subtract(
                const Duration(hours: 1),
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _CompanionScope(
              event: EventSuccessCompanionFixtures.racketEvent,
              plan: EventSuccessCompanionFixtures.revealUnlockedPlan,
              participation:
                  EventSuccessCompanionFixtures.attendedParticipation(
                    event: EventSuccessCompanionFixtures.racketEvent,
                  ),
              rotationAssignment:
                  EventSuccessCompanionFixtures.rotationAssignment,
              rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
              now: EventSuccessCompanionFixtures.racketStart.subtract(
                const Duration(hours: 1),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Loading body',
  type: EventSuccessCompanionLoadingBody,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessCompanionLoadingBodyState(BuildContext context) {
  return _CompanionCatalog(
    title: 'EventSuccessCompanionLoadingBody',
    contractId: 'state.event_success.companion.loading',
    children: [
      _StateCard(
        label: 'route skeleton',
        child: _DeviceFrame(
          child: Builder(
            builder: (context) {
              final t = CatchTokens.of(context);
              return Scaffold(
                backgroundColor: t.bg,
                body: const EventSuccessCompanionLoadingBody(),
              );
            },
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Feedback form',
  type: EventSuccessFeedbackForm,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessFeedbackFormStates(BuildContext context) {
  return _CompanionCatalog(
    title: 'EventSuccessFeedbackForm',
    contractId: 'component.event_success.companion.feedback_form',
    children: [
      _StateCard(
        label: 'new private feedback',
        child: _DeviceFrame(child: _feedbackFormPreview()),
      ),
      _StateCard(
        label: 'saved private feedback',
        child: _DeviceFrame(
          child: _feedbackFormPreview(
            existingFeedback: EventSuccessCompanionFixtures.feedback,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Feedback rating row',
  type: RatingRow,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessFeedbackRatingRowStates(BuildContext context) {
  return _CompanionCatalog(
    title: 'RatingRow',
    contractId: 'component.event_success.companion.feedback.rating_row',
    children: [
      _StateCard(
        label: 'partial rating',
        child: _DeviceFrame(
          child: _feedbackPartPreview(
            RatingRow(label: 'Welcome', value: 3, onChanged: (_) {}),
          ),
        ),
      ),
      _StateCard(
        label: 'max rating',
        child: _DeviceFrame(
          child: _feedbackPartPreview(
            RatingRow(label: 'Structure', value: 5, onChanged: (_) {}),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Feedback counter row',
  type: CounterRow,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessFeedbackCounterRowStates(BuildContext context) {
  return _CompanionCatalog(
    title: 'CounterRow',
    contractId: 'component.event_success.companion.feedback.counter_row',
    children: [
      _StateCard(
        label: 'zero count',
        child: _DeviceFrame(
          child: _feedbackPartPreview(CounterRow(value: 0, onChanged: (_) {})),
        ),
      ),
      _StateCard(
        label: 'active count',
        child: _DeviceFrame(
          child: _feedbackPartPreview(CounterRow(value: 4, onChanged: (_) {})),
        ),
      ),
    ],
  );
}

class _CompanionRouteScope extends StatelessWidget {
  const _CompanionRouteScope({
    this.uid = EventSuccessCompanionFixtures.viewerUid,
    this.eventStream,
    this.profileStream,
    this.participationStream,
    this.planValue,
    this.planStream,
  });

  final String? uid;
  final Stream<Event?>? eventStream;
  final Stream<UserProfile?>? profileStream;
  final Stream<EventParticipation?>? participationStream;
  final EventSuccessPlan? planValue;
  final Stream<EventSuccessPlan?>? planStream;

  @override
  Widget build(BuildContext context) {
    final event = EventSuccessCompanionFixtures.socialEvent;
    final profile = EventSuccessCompanionFixtures.viewer;
    final plan = planValue ?? EventSuccessCompanionFixtures.basePlan;
    final participation = EventSuccessCompanionFixtures.signedUpParticipation(
      event: event,
    );
    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(uid)),
        watchEventProvider(
          event.id,
        ).overrideWith((ref) => eventStream ?? Stream<Event?>.value(event)),
        watchUserProfileProvider.overrideWith(
          (ref) => profileStream ?? Stream<UserProfile?>.value(profile),
        ),
        watchEventParticipationProvider(event.id, uid ?? '').overrideWith(
          (ref) =>
              participationStream ??
              Stream<EventParticipation?>.value(participation),
        ),
        watchEventSuccessPlanProvider(event.id).overrideWith(
          (ref) => planStream ?? Stream<EventSuccessPlan?>.value(plan),
        ),
        eventSuccessCompanionClockProvider.overrideWith(
          (ref) => Stream<DateTime>.value(EventSuccessCompanionFixtures.now),
        ),
        eventSuccessLiveEffectsControllerProvider.overrideWith(
          (ref) => _NoopEventSuccessLiveEffectsController(),
        ),
      ],
      child: EventSuccessCompanionRouteScreen(
        clubId: event.clubId,
        eventId: event.id,
      ),
    );
  }
}

class _CompanionScope extends StatelessWidget {
  const _CompanionScope({
    this.event,
    this.plan,
    this.participation,
    this.wingmanRequestCandidates = const [],
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

  final Event? event;
  final EventSuccessPlan? plan;
  final EventParticipation? participation;
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
  Widget build(BuildContext context) {
    final resolvedEvent = event ?? EventSuccessCompanionFixtures.socialEvent;
    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(
          const AsyncData<String?>(EventSuccessCompanionFixtures.viewerUid),
        ),
        eventSuccessLiveEffectsControllerProvider.overrideWith(
          (ref) => _NoopEventSuccessLiveEffectsController(),
        ),
      ],
      child: EventSuccessCompanionScreen(
        event: resolvedEvent,
        plan: plan ?? EventSuccessCompanionFixtures.basePlan,
        userProfile: EventSuccessCompanionFixtures.viewer,
        participation:
            participation ??
            EventSuccessCompanionFixtures.signedUpParticipation(
              event: resolvedEvent,
            ),
        wingmanRequestCandidates: wingmanRequestCandidates,
        wingmanRequest: wingmanRequest,
        compatibilityResponse: compatibilityResponse,
        existingFeedback: existingFeedback,
        assignment: assignment,
        assignmentPeerProfiles: assignmentPeerProfiles,
        assignmentPeersLoading: assignmentPeersLoading,
        microPodsOptedOut: microPodsOptedOut,
        rotationAssignment: rotationAssignment,
        rotationPeerProfiles: rotationPeerProfiles,
        rotationPeersLoading: rotationPeersLoading,
        guidedRotationsOptedOut: guidedRotationsOptedOut,
        arrivalMission: arrivalMission,
        now: now,
        onSaveCompatibilityAnswers: onSaveCompatibilityAnswers,
        onStartArrivalMission: onStartArrivalMission,
        onCompleteArrivalMission: onCompleteArrivalMission,
        onSkipArrivalMission: onSkipArrivalMission,
      ),
    );
  }
}

Widget _feedbackFormPreview({EventSuccessFeedback? existingFeedback}) {
  return Builder(
    builder: (context) {
      final t = CatchTokens.of(context);
      return ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(
            const AsyncData<String?>(EventSuccessCompanionFixtures.viewerUid),
          ),
        ],
        child: Scaffold(
          backgroundColor: t.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: CatchInsets.content,
              child: IgnorePointer(
                child: EventSuccessFeedbackForm(
                  event: EventSuccessCompanionFixtures.socialEvent,
                  userProfile: EventSuccessCompanionFixtures.viewer,
                  actionState: const EventSuccessFeedbackActionState(),
                  onSubmitFeedback: (_) async {},
                  existingFeedback: existingFeedback,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _feedbackPartPreview(Widget child) {
  return Builder(
    builder: (context) {
      final t = CatchTokens.of(context);
      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: Padding(
            padding: CatchInsets.content,
            child: IgnorePointer(child: StagePanel(child: child)),
          ),
        ),
      );
    },
  );
}

Stream<T> _loadingStream<T>() => Stream<T>.empty();

Stream<T> _errorStream<T>(String message) =>
    Stream<T>.error(StateError(message), StackTrace.empty);

NetworkException _companionOfflineException({required String action}) {
  return obviousOfflineException(
    context: BackendErrorContext(
      service: BackendService.firestore,
      action: action,
      resource: 'eventSuccessCompanion',
    ),
  );
}

class _NoopEventSuccessLiveEffectsController
    extends EventSuccessLiveEffectsController {
  @override
  Future<void> play(EventSuccessLiveEffectKind kind) async {}

  @override
  Future<void> playAmbientBed(EventSuccessAmbientBed bed) async {}

  @override
  Future<void> stopAmbientBed() async {}

  @override
  Future<void> dispose() async {}
}

class _CompanionCatalog extends StatelessWidget {
  const _CompanionCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: CatchTextStyles.titleL(context)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH24,
            for (final child in children) ...[child, gapH20],
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: 760, child: child),
          ),
        ),
      ),
    );
  }
}

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context);
    return MediaQuery(
      data: base.copyWith(
        textScaler: textScaler ?? base.textScaler,
        disableAnimations: disableAnimations || base.disableAnimations,
      ),
      child: child,
    );
  }
}
