/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private durable program delivery outbox. The immutable intent and bounded attempt history survive moment-run completion and delayed provider callbacks. Recipient endpoints are references; transport credentials and guest bearer grants belong to their own private stores.
 */
export interface ProgramDeliveryMessageDocument {
  schemaVersion: 1;
  messageId: string;
  revision: number;
  intent: {
    schemaVersion: 1;
    intentId: string;
    revision: number;
    context: {
      mode: "live";
      programId: string;
      organizerId: string;
    };
    programId: string;
    recipient: {
      kind: "guest" | "household" | "staff";
      /**
       * Stable recipient identity inside the program (guest id, household id, or staff uid). Endpoint resolution lives in the facts reader, never in the intent.
       */
      recipientKey: string;
    };
    workflow: {
      kind: "programMoment";
      momentId: string;
      /**
       * Moment-run occurrence identity. Phase 3 refines this into an explicit occurrence key once anchor revisions exist.
       */
      runId: string;
    };
    createdAt: number;
    expiresAt: number;
    /**
     * @minItems 1
     * @maxItems 3
     */
    permittedRoutes: ("organizerProgramWhatsapp" | "catchProgramActivity")[];
    deliveryPolicy: {
      maxAttempts: number;
      maxAttemptsPerRoute: number;
      minimumRetrySeconds: number;
    };
    kind: "programReminder";
    title: string;
    body: string;
    /**
     * The program/moment fact revision this intent was issued under. Reservation authority expires with it.
     */
    instructionRevision: number;
  };
  lifecycle: "active" | "cancelled" | "superseded" | "responded";
  /**
   * @maxItems 6
   */
  attempts: {
    schemaVersion: 1;
    attemptId: string;
    intentId: string;
    intentRevision: number;
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
            | "responded"
            | "expired"
            | "permissionRevoked"
            | "reservationExpired"
            | "permitExpired"
            | "programEnded"
            | "rsvpChanged"
            | "recipientWithdrawn";
        };
    mode: "live";
    context: {
      mode: "live";
      programId: string;
      organizerId: string;
    };
    binding:
      | {
          routeId: "organizerProgramWhatsapp";
          transport: "whatsapp";
          senderIdentity: "organizerManaged";
          provider: "meta" | "gupshup" | "twilio";
          senderId: string;
          bindingRevision: number;
          recipientEndpointId: string;
          fallbackOwner: "catch" | "provider";
        }
      | {
          routeId: "catchProgramActivity";
          transport: "catchApp";
          senderIdentity: "catchPlatform";
          provider: "catchActivity" | "fcm";
          senderId: string;
          bindingRevision: number;
          recipientEndpointId: string;
          fallbackOwner: "catch";
        };
    authorization: {
      permissionRevision: string;
      checkedAt: number;
      validUntil: number;
      instructionRevision: number;
    };
  }[];
  deliveryConflict: boolean;
  createdAt: number;
  updatedAt: number;
}
