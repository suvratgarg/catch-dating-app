/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded attendee fanout for one trusted plan-change or post-event source. The work binds a reviewed policy revision and grants no provider authority by itself.
 */
export interface EventAssistanceOperationalNoticeFanout {
  schemaVersion: 1;
  kind: "operationalNoticeFanout";
  signalId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  source: {
    kind: "planChange" | "followUp";
    sourceId: string;
    revision: number;
    occurredAt: number;
    validUntil: number;
  };
  policyBinding: {
    groupId: "event:whole";
    workflowKind: "planChangeCommunication" | "postEventFollowUp";
    settingId: string;
    settingRevision: number;
  };
  expiresAt: number;
  checkpoint: {
    phase: "scan" | "retry" | "complete" | "review" | "expired" | "stopped";
    cursor: string | null;
    visited: number;
    published: number;
    skipped: number;
    dueAt: number | null;
    /**
     * @maxItems 100
     */
    failures: {
      attendeeId: string;
      reason: "unavailable";
    }[];
    retries: number;
    stopReason: null | "policyUnavailable" | "policyChanged" | "sourceChanged";
  };
}
