/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventApprovalNotificationAttempt {
  schemaVersion: 1;
  attemptId: string;
  intentId: string;
  intentRevision: 1;
  ordinal: number;
  createdAt: number;
  state:
    | {
        kind: "reserved";
        at: number;
        reconcileAfter: number;
      }
    | {
        kind: "unknown";
        at: number;
        providerMessageId: string | null;
        reason: "timeout" | "connectionLost" | "workerInterrupted";
        reconcileAfter: number;
      }
    | {
        kind: "accepted" | "delivered" | "read";
        at: number;
        providerMessageId: string | null;
      }
    | {
        kind: "failed";
        at: number;
        providerMessageId: string | null;
        classification:
          | "technical"
          | "policy"
          | "suppressed"
          | "invalidRecipient";
        evidenceId: string | null;
      }
    | {
        kind: "revoked";
        at: number;
        providerMessageId: string | null;
        evidenceId: string | null;
      }
    | {
        kind: "notDispatched";
        at: number;
        reason:
          | "superseded"
          | "expired"
          | "permissionRevoked"
          | "reservationExpired"
          | "permitExpired"
          | "campaignEnded"
          | "recipientWithdrawn";
      };
  authorization: {
    permissionRevision: string;
    checkedAt: number;
    validUntil: number;
    instructionRevision: number;
  };
  mode: "live";
  context: {
    mode: "live";
    applicationId: string;
    organizerId: string;
    eventId: string;
    uid: string;
    sourceResponseId: string;
    approvedAtMillis: number;
    approvalRevision: number;
  };
  binding: {
    routeId: "approvalWhatsapp" | "approvalSms" | "approvalEmail";
    senderId: string;
    bindingRevision: number;
    recipientEndpointId: string;
    fallbackOwner: "catch";
  };
}
