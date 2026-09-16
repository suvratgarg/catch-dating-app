/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private resumable delivery coordination for one published automatic message. The outbox owns provider attempts; a checkpoint never grants dispatch authority.
 */
export interface EventAssistanceDeliveryWork {
  schemaVersion: 1;
  kind: "liveMessageDelivery";
  messageId: string;
  intentHash: string;
  threadId: string;
  scope: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    attendeeId: string;
    episodeId: string;
  };
  createdAt: number;
  expiresAt: number;
  checkpoint:
    | {
        phase: "queued";
        reason: null;
        dueAt: number;
        messageRevision: number;
        messageHash: string;
        failures: 0;
        evaluations: 0;
      }
    | {
        phase: "complete";
        reason:
          | "delivered"
          | "responded"
          | "cancelled"
          | "superseded"
          | "expired"
          | "eventClosed"
          | "permissionRevoked"
          | "guestPresent"
          | "guestDeclined"
          | "notAdmitted"
          | "hostStopped"
          | "participationInactive";
        dueAt: null;
        messageRevision: number;
        messageHash: string;
        failures: number;
        evaluations: number;
      }
    | {
        phase: "receipt";
        reason: "providerPending";
        dueAt: number;
        messageRevision: number;
        messageHash: string;
        failures: number;
        evaluations: number;
      }
    | {
        phase: "retry";
        reason:
          | "retryBackoff"
          | "eventFactsStale"
          | "routeFactsStale"
          | "workerUnavailable";
        dueAt: number;
        messageRevision: number;
        messageHash: string;
        failures: number;
        evaluations: number;
      }
    | {
        phase: "review";
        reason:
          | "noEligibleRoute"
          | "attemptLimit"
          | "policyRejected"
          | "recipientNeedsReview"
          | "providerOwnsFallback"
          | "conflictingDeliveryEvidence"
          | "providerPending"
          | "workerUnavailable"
          | "recoveryLimit"
          | "eventFactsStale"
          | "routeFactsStale";
        dueAt: number;
        messageRevision: number;
        messageHash: string;
        failures: number;
        evaluations: number;
      };
}
