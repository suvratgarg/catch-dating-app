/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One organizer-owned cross-event campaign with frozen approval and aggregate delivery state.
 */
export interface OrganizerCampaignDocument {
  organizerId: string;
  createdByUid: string;
  messageClass: "eventFollowUp" | "organizerUpdate" | "organizerPromotion";
  channel: "whatsapp";
  status:
    | "draft"
    | "previewed"
    | "approved"
    | "scheduled"
    | "resolving"
    | "sending"
    | "completed"
    | "partiallyFailed"
    | "cancelled"
    | "blocked";
  name: string;
  /**
   * Legacy read compatibility only. New campaign writes use savedAudienceId and persist an empty array.
   *
   * @maxItems 5
   */
  segmentIds: (
    | "first_time_attendee"
    | "repeat_attendee"
    | "regular"
    | "lapsed_regular"
    | "reliable_attendee"
    | "advocate"
    | "high_impact_advocate"
    | "whatsapp_reachable"
  )[];
  /**
   * Customers-owned reusable audience used by every new campaign. Null or absent only on legacy segment-authored campaigns.
   */
  savedAudienceId?: string | null;
  savedAudienceRevision?: number | null;
  savedAudienceDefinitionHash?: string | null;
  connectionId: string;
  templateId: string;
  templateVariables: {
    [k: string]: string;
  };
  eventId: string | null;
  inviteDestinationKind:
    | null
    | "catchEvent"
    | "eventRuntime"
    | "externalBooking"
    | "marketingLanding";
  scheduledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Exact audience-state hash stored by preview and required unchanged at approval; retained as the frozen recipient snapshot hash after approval.
   */
  recipientSnapshotHash: string | null;
  contentHash: string;
  audienceCounts: {
    total: number;
    reachable: number;
    optedOut: number;
    invalid: number;
    duplicate: number;
    unsupported: number;
    frequencyCapped: number;
    providerBlocked: number;
    unknown: number;
  };
  deliveryCounts: {
    pending: number;
    suppressed: number;
    accepted: number;
    sent: number;
    delivered: number;
    read: number;
    failed: number;
    replied: number;
    optedOut: number;
  };
  revision: number;
  leaseOwner: string | null;
  leaseExpiresAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  approvedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  dispatchedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  cancelledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  automationOrigin?: {
    ruleId: string;
    ruleRevision: number;
    actionId: string;
    sourceId: string;
    eventKind:
      | "submitted"
      | "withdrawn"
      | "applicationAccepted"
      | "eventAttended";
    contactId: string;
  };
}
