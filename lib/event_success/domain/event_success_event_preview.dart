import 'dart:math' as math;

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

/// IN DEVELOPMENT: read-only adapter from today's event model to the future
/// event-success preview layer.
///
/// This owns no persistence and performs no booking, attendance, matching, or
/// notification side effects. It exists so the preview can be tested against
/// real `Event`/`Club`/roster inputs before the backend contract is designed.
class EventSuccessEventPreview {
  const EventSuccessEventPreview({
    required this.event,
    required this.club,
    required this.playbook,
    required this.hostDraft,
    required this.livePlan,
    required this.attendeeState,
    required this.scorecard,
    required this.brief,
    required this.integrationNotes,
  });

  factory EventSuccessEventPreview.fromEvent({
    required Event event,
    Club? club,
    EventParticipationRoster? roster,
    UserProfile? viewer,
    DateTime? now,
    EventSuccessPlaybook? playbook,
  }) {
    final resolvedPlaybook = playbook ?? _playbookForEvent(event);
    final bookedCount = math.max(roster?.bookedCount ?? 0, event.signedUpCount);
    final checkedInCount = math.max(
      roster?.checkedInCount ?? 0,
      event.attendedCount,
    );
    final referenceNow = now ?? DateTime.now();
    final hostDraft = EventSuccessHostDraft.fromPlaybook(
      resolvedPlaybook,
      targetAttendeeCount: event.capacityLimit,
    );
    final scorecard = _scorecardFromEvent(
      bookedCount: bookedCount,
      checkedInCount: checkedInCount,
    );

    return EventSuccessEventPreview(
      event: event,
      club: club,
      playbook: resolvedPlaybook,
      hostDraft: hostDraft,
      livePlan: EventSuccessLivePlan.fromDraft(
        hostDraft,
        activeStepIndex: _activeStepIndex(
          playbook: resolvedPlaybook,
          event: event,
          now: referenceNow,
        ),
        bookedCount: bookedCount,
        checkedInCount: checkedInCount,
      ),
      attendeeState: _attendeeStateFromEvent(
        event: event,
        viewer: viewer,
        playbook: resolvedPlaybook,
        checkedInCount: checkedInCount,
        now: referenceNow,
      ),
      scorecard: scorecard,
      brief: const EventSuccessCoach().analyze(
        playbook: resolvedPlaybook,
        scorecard: scorecard,
      ),
      integrationNotes: [
        'Seeds host setup from Event.capacityLimit and the event format playbook.',
        'Uses roster counts when available, then falls back to Event.bookedCount and Event.checkedInCount.',
        'Keeps live guide tools read-only until persistence, privacy, and safety ownership are approved.',
      ],
    );
  }

  final Event event;
  final Club? club;
  final EventSuccessPlaybook playbook;
  final EventSuccessHostDraft hostDraft;
  final EventSuccessLivePlan livePlan;
  final EventSuccessAttendeeState attendeeState;
  final EventSuccessScorecard scorecard;
  final EventSuccessBrief brief;
  final List<String> integrationNotes;
}

EventSuccessPlaybook _playbookForEvent(Event event) {
  final playbookId = event.eventFormat.defaultPlaybookId;
  if (playbookId != null) {
    return EventSuccessPlaybookLibrary.byIdOrDefault(playbookId);
  }
  return EventSuccessPlaybookLibrary.forActivity(
        event.eventFormat.activityKind,
      ).firstOrNull ??
      EventSuccessPlaybookLibrary.socialRun;
}

int _activeStepIndex({
  required EventSuccessPlaybook playbook,
  required Event event,
  required DateTime now,
}) {
  if (playbook.runOfShow.isEmpty || now.isBefore(event.startTime)) return 0;

  final elapsedMinutes = now.difference(event.startTime).inMinutes;
  var cumulativeMinutes = 0;
  for (var i = 0; i < playbook.runOfShow.length; i++) {
    cumulativeMinutes += playbook.runOfShow[i].durationMinutes;
    if (elapsedMinutes < cumulativeMinutes) return i;
  }

  return playbook.runOfShow.length - 1;
}

EventSuccessAttendeeState _attendeeStateFromEvent({
  required Event event,
  required UserProfile? viewer,
  required EventSuccessPlaybook playbook,
  required int checkedInCount,
  required DateTime now,
}) {
  final firstName = viewer == null
      ? 'Attendee'
      : viewer.displayName.trim().isNotEmpty
      ? viewer.displayName.trim()
      : viewer.firstName.trim().isNotEmpty
      ? viewer.firstName.trim()
      : viewer.name.trim().isNotEmpty
      ? viewer.name.trim().split(RegExp(r'\s+')).first
      : 'Attendee';

  return EventSuccessAttendeeState(
    eventTitle: event.title,
    attendeeName: firstName,
    podLabel: _attendeePodLabel(event),
    prompt: playbook.activityType.isMovementHeavy
        ? 'Find someone running your pace and ask what route they want to try next.'
        : 'Find someone on your team and ask what brought them here.',
    wingmanRequestCandidates: const [
      WingmanRequestCandidate(
        displayName: 'Preview attendee',
        context: 'Will be replaced by checked-in people from this event',
      ),
    ],
    checkedIn: checkedInCount > 0,
    followUpOpen: !event.isUpcomingAt(now),
  );
}

String _attendeePodLabel(Event event) {
  if (event.eventFormat.isDistanceBased) {
    return '${event.pace.label} pace pod · ${event.distanceKm.toStringAsFixed(1)} km';
  }
  return event.eventFormat.interactionModel.label;
}

EventSuccessScorecard _scorecardFromEvent({
  required int bookedCount,
  required int checkedInCount,
}) {
  final introCount = checkedInCount <= 0
      ? 0
      : math.max(1, (checkedInCount * 0.45).round());
  final mutualMatches = checkedInCount <= 0
      ? 0
      : math.max(1, (checkedInCount * 0.06).round());
  final wingmanRequests = checkedInCount <= 0
      ? 0
      : math.max(1, (checkedInCount * 0.12).round());

  return EventSuccessScorecard(
    bookedCount: bookedCount,
    checkedInCount: checkedInCount,
    attendeesWhoMetTwoPlusPeople: introCount,
    mutualMatchCount: mutualMatches,
    chatStartedCount: (mutualMatches * 0.6).round(),
    repeatSignupCount: bookedCount <= 0 ? 0 : (bookedCount * 0.2).round(),
    averageWelcomeRating: 3.8,
    averageStructureRating: 3.4,
    safetyIncidentCount: 0,
    wingmanRequestCount: wingmanRequests,
  );
}
