/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or revise an organizer moment. New moments land as drafts; revising an existing moment keeps its scope (immutable) and drops it back to draft with approval cleared, requiring re-arm.
 */
export interface UpsertOrganizerMomentCallablePayload {
  scope: {
    kind: "event" | "program";
    /**
     * Required when kind=event; must be null otherwise.
     */
    eventId?: string | null;
    /**
     * Required when kind=program; must be null otherwise.
     */
    programId?: string | null;
  };
  /**
   * Existing moment to revise; null/omitted creates a new moment.
   */
  momentId?: string | null;
  name: string;
  initiation: {
    kind: "manual" | "scheduled" | "anchored" | "triggered";
    /**
     * Scheduled fire time; required when kind=scheduled.
     */
    atMillis?: number | null;
    /**
     * Required when kind=anchored.
     */
    anchorKind?:
      | (
          | "scopeStart"
          | "scopeEnd"
          | "functionStart"
          | "functionEnd"
          | "rsvpDeadline"
          | "travelLegTime"
        )
      | null;
    /**
     * Function/leg id for scoped anchors; null anchors to the scope itself.
     */
    anchorId?: string | null;
    /**
     * Minutes relative to the anchor; negative is before.
     */
    offsetMinutes?: number | null;
    /**
     * Required when kind=triggered.
     */
    triggerKind?: ("lateArrivalAtHotel" | "flightDisrupted") | null;
    /**
     * Optional function scope for triggered moments.
     */
    functionId?: string | null;
  };
  sense: "individual" | "audience";
  audience: {
    kind:
      | "subject"
      | "eventParticipants"
      | "functionGuests"
      | "households"
      | "staffDuty";
    /**
     * eventParticipants: participation statuses included.
     *
     * @maxItems 4
     */
    statuses?: "signedUp"[] | null;
    /**
     * functionGuests: the function whose guests resolve.
     */
    functionId?: string | null;
    /**
     * functionGuests: RSVP states included.
     *
     * @maxItems 4
     */
    rsvp?: ("attending" | "maybe")[] | null;
    /**
     * functionGuests: one send per household when true (default).
     */
    householdDedupe?: boolean | null;
    /**
     * households: restrict to households with a pending member.
     */
    rsvpPendingOnly?: boolean | null;
    /**
     * staffDuty: duty whose grant holders resolve.
     */
    duty?: string | null;
    /**
     * staffDuty: optional function/pickupPoint/hotel ids; null means all.
     *
     * @maxItems 50
     */
    scopeIds?: string[] | null;
  };
  action: {
    kind: "sendTemplate" | "push" | "staffAttention";
    /**
     * sendTemplate: organizerSenderConnections doc id.
     */
    connectionId?: string | null;
    /**
     * sendTemplate: organizerMessageTemplates doc id.
     */
    templateId?: string | null;
    /**
     * sendTemplate: template variable substitutions.
     */
    variables?: {
      [k: string]: string;
    } | null;
    /**
     * push: activity/push type written to the feed.
     */
    notificationType?: string | null;
    /**
     * push: user notification preference gating FCM.
     */
    preferenceKey?: string | null;
    /**
     * staffAttention: duty the attention item targets.
     */
    duty?: string | null;
    /**
     * staffAttention: attention severity.
     */
    severity?: "info" | "warning" | "urgent" | null;
    /**
     * staffAttention: rendered attention title.
     */
    titleTemplate?: string | null;
  };
}
