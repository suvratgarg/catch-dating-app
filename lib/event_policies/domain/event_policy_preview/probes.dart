import 'package:catch_dating_app/event_policies/domain/event_policy.dart';

class EventPolicyPreviewScenario {
  const EventPolicyPreviewScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.policy,
    required this.roster,
    required this.probes,
    this.cancellationProbes = const [],
  });

  final String id;
  final String title;
  final String description;
  final EventPolicyBundle policy;
  final EventRosterSnapshot roster;
  final List<EventPolicyPreviewProbe> probes;
  final List<EventPolicyCancellationPreviewProbe> cancellationProbes;
}

class EventPolicyPreviewProbe {
  const EventPolicyPreviewProbe({
    required this.id,
    required this.label,
    required this.attendee,
    this.hasValidInvite = false,
    this.isClubMember = false,
  });

  final String id;
  final String label;
  final EventAttendeeProfile attendee;
  final bool hasValidInvite;
  final bool isClubMember;

  EventAdmissionRequest toAdmissionRequest() {
    return EventAdmissionRequest(
      attendee: attendee,
      hasValidInvite: hasValidInvite,
      isClubMember: isClubMember,
    );
  }
}

class EventPolicyCancellationPreviewProbe {
  const EventPolicyCancellationPreviewProbe({
    required this.id,
    required this.label,
    required this.actor,
    required this.beforeStart,
    required this.paidAmount,
    this.isWaitlisted = false,
  });

  final String id;
  final String label;
  final EventCancellationActor actor;
  final Duration beforeStart;
  final MoneyAmount paidAmount;
  final bool isWaitlisted;

  EventCancellationRequest toCancellationRequest() {
    return EventCancellationRequest(
      actor: actor,
      paidAmount: paidAmount,
      beforeStart: beforeStart,
      isWaitlisted: isWaitlisted,
    );
  }
}
