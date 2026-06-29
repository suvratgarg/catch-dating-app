import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_eligibility.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

/// Pure Dart service class for Event domain business logic.
///
/// Keeps service-level logic out of the data model so [Event] and
/// [EventParticipation] remain focused on shape and serialization.
class EventService {
  EventService._();

  /// Returns fresh-viewer eligibility of [user] for [event].
  ///
  /// User-specific roster state lives in `eventParticipations`, so callers that
  /// know the viewer's participation edge should prefer a view-model seam that
  /// combines the event and participation before rendering action state.
  static EventEligibility eligibilityFor(
    Event event,
    UserProfile user, {
    DateTime? now,
    bool hasValidInvite = false,
  }) {
    final referenceNow = now ?? DateTime.now();
    if (!event.isUpcomingAt(referenceNow)) return const EventPast();
    if (user.age < event.constraints.minAge) {
      return AgeTooYoung(event.constraints.minAge);
    }
    if (user.age > event.constraints.maxAge) {
      return AgeTooOld(event.constraints.maxAge);
    }

    final policy = event.effectiveEventPolicy;
    if (event.signedUpCount >= policy.capacityLimit) return const EventFull();

    final decision = const EventPolicyEngine().decideAdmission(
      policy: policy,
      request: EventAdmissionRequest(
        attendee: EventAttendeeProfile.fromUserProfile(user),
        hasValidInvite: hasValidInvite,
      ),
      roster: EventRosterSnapshot(
        bookedCountsByCohort: event.effectiveCohortCounts,
      ),
    );

    if (decision.isBookable) return const Eligible();
    if (decision.isWaitlisted) return const EventFull();
    if (decision.reason == EventAdmissionDecisionReason.cohortCapReached ||
        decision.reason ==
            EventAdmissionDecisionReason.balancedRatioLimitReached) {
      return const GenderCapacityReached();
    }
    if (decision.reason == EventAdmissionDecisionReason.capacityFull) {
      return const EventFull();
    }
    if (decision.reason == EventAdmissionDecisionReason.inviteRequired) {
      return const EventInviteRequired();
    }
    return const GenderCapacityReached();
  }

  /// Returns a snapshot of participation eligibility booleans for
  /// [participation], optionally evaluated against [now] instead of the
  /// system clock.
  static ParticipationStatusSnapshot participationStatus(
    EventParticipation participation, {
    DateTime? now,
  }) {
    final referenceNow = now ?? DateTime.now();
    return ParticipationStatusSnapshot(
      hasHostApproval:
          participation.hostApprovalStatus ==
                  EventJoinRequestStatus.approved ||
              _isWaitlistOfferAcceptedAt(participation, referenceNow),
      hasOpenWaitlistOffer:
          participation.waitlistOfferStatus ==
                  EventWaitlistOfferStatus.active ||
              participation.waitlistOfferStatus ==
                  EventWaitlistOfferStatus.accepted,
      isWaitlistOfferActive:
          _isWaitlistOfferActiveAt(participation, referenceNow),
      isWaitlistOfferAccepted:
          _isWaitlistOfferAcceptedAt(participation, referenceNow),
    );
  }

  static bool _isWaitlistOfferActiveAt(
    EventParticipation participation,
    DateTime now,
  ) =>
      participation.status == EventParticipationStatus.waitlisted &&
      participation.waitlistOfferStatus == EventWaitlistOfferStatus.active &&
      _offerExpiresAfter(participation, now);

  static bool _isWaitlistOfferAcceptedAt(
    EventParticipation participation,
    DateTime now,
  ) =>
      participation.status == EventParticipationStatus.waitlisted &&
      participation.waitlistOfferStatus == EventWaitlistOfferStatus.accepted &&
      _offerExpiresAfter(participation, now);

  static bool _offerExpiresAfter(
    EventParticipation participation,
    DateTime now,
  ) =>
      participation.waitlistOfferExpiresAt != null &&
      participation.waitlistOfferExpiresAt!.isAfter(now);
}

/// The result of [EventService.participationStatus], bundling all participation
/// eligibility booleans into a single value so callers don't need to query the
/// service repeatedly.
class ParticipationStatusSnapshot {
  final bool hasHostApproval;
  final bool hasOpenWaitlistOffer;
  final bool isWaitlistOfferActive;
  final bool isWaitlistOfferAccepted;

  const ParticipationStatusSnapshot({
    required this.hasHostApproval,
    required this.hasOpenWaitlistOffer,
    required this.isWaitlistOfferActive,
    required this.isWaitlistOfferAccepted,
  });
}
