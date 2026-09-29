/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ProgramDeliveryAttempt {
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
}
