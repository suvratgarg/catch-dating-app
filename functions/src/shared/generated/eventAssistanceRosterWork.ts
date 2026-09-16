/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private resumable roster enrollment bound to current manager runtime permission. Enrollment never infers attendance or sends messages.
 */
export interface EventAssistanceRosterWork {
  schemaVersion: 1;
  kind: "liveRosterEnrollment";
  signalId: string;
  source: {
    eventId: string;
    collection:
      | "eventAttendees"
      | "eventAssistanceGuests"
      | "eventAssistanceRuntimeConfigs";
    documentId: string;
    occurredAt: number;
  };
  scope: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    attendeeId: string | null;
  };
  expiresAt: number;
  checkpoint: {
    phase: "scan" | "retry" | "complete" | "review" | "expired" | "stopped";
    cursor: string | null;
    visited: number;
    dueAt: number | null;
    /**
     * @maxItems 100
     */
    failures: {
      reason: "busy" | "unavailable";
      attendeeId: string;
    }[];
    retries: number;
    stopReason:
      | null
      | "missing"
      | "paused"
      | "configurationChanged"
      | "sourceChanged"
      | "expired"
      | "eventClosed";
  };
  runtimeBinding: {
    runtimeId: string;
    revision: number;
  };
}
