/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceDeliveryAttempt =
  | {
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
            kind: "accepted";
            at: number;
            providerMessageId: string;
          }
        | {
            kind: "delivered";
            at: number;
            providerMessageId: string;
          }
        | {
            kind: "read";
            at: number;
            providerMessageId: string;
          }
        | {
            kind: "failed";
            at: number;
            providerMessageId: string | null;
            classification:
              | "technical"
              | "invalidRecipient"
              | "policy"
              | "suppressed";
            evidenceId: string;
          }
        | {
            kind: "revoked";
            at: number;
            providerMessageId: string;
            evidenceId: string;
          }
        | {
            kind: "notDispatched";
            at: number;
            reason:
              | "superseded"
              | "eventClosed"
              | "responded"
              | "expired"
              | "permissionRevoked"
              | "hostStopped";
          };
      mode: "live";
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      binding:
        | {
            routeId: "catchEventSms";
            transport: "sms";
            senderIdentity: "catchPlatform";
            provider: "sinch" | "gupshup";
            senderId: string;
            bindingRevision: number;
            recipientEndpointId: string;
            fallbackOwner: "catch" | "provider";
          }
        | {
            routeId: "catchEventRcs";
            transport: "rcs";
            senderIdentity: "catchPlatform";
            provider: "sinch" | "gupshup";
            senderId: string;
            bindingRevision: number;
            recipientEndpointId: string;
            fallbackOwner: "catch" | "provider";
          }
        | {
            routeId: "organizerEventWhatsapp";
            transport: "whatsapp";
            senderIdentity: "organizerManaged";
            provider: "meta";
            senderId: string;
            bindingRevision: number;
            recipientEndpointId: string;
            fallbackOwner: "catch" | "provider";
          };
      authorization: {
        permissionRevision: string;
        checkedAt: number;
        validUntil: number;
        instructionRevision: number;
      };
    }
  | {
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
            kind: "accepted";
            at: number;
            providerMessageId: string;
          }
        | {
            kind: "delivered";
            at: number;
            providerMessageId: string;
          }
        | {
            kind: "read";
            at: number;
            providerMessageId: string;
          }
        | {
            kind: "failed";
            at: number;
            providerMessageId: string | null;
            classification:
              | "technical"
              | "invalidRecipient"
              | "policy"
              | "suppressed";
            evidenceId: string;
          }
        | {
            kind: "revoked";
            at: number;
            providerMessageId: string;
            evidenceId: string;
          }
        | {
            kind: "notDispatched";
            at: number;
            reason:
              | "superseded"
              | "eventClosed"
              | "responded"
              | "expired"
              | "permissionRevoked"
              | "hostStopped";
          };
      mode: "rehearsal";
      context: {
        mode: "rehearsal";
        rehearsalId: string;
        virtualEventId: string;
        clockId: string;
      };
      routeId: "catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp";
      authorization: {
        permissionRevision: string;
        checkedAt: number;
        validUntil: number;
        instructionRevision: number;
      };
    };
