/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceDeliveriesCallableResponse {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  serverTime: number;
  coverage: "page";
  /**
   * @maxItems 50
   */
  deliveries: (
    | {
        messageId: string;
        revision: number;
        reviewHash: string;
        createdAt: number;
        expiresAt: number;
        lifecycle: "active" | "cancelled" | "superseded" | "responded";
        deliveryStatus:
          | "notSubmitted"
          | "reserved"
          | "unknown"
          | "accepted"
          | "delivered"
          | "read"
          | "failed"
          | "notDispatched"
          | "conflictingEvidence"
          | "revoked";
        /**
         * @maxItems 6
         */
        attempts: {
          channel: "sms" | "whatsapp" | "rcs";
          state:
            | "reserved"
            | "unknown"
            | "accepted"
            | "delivered"
            | "read"
            | "failed"
            | "notDispatched"
            | "revoked";
          at: number;
        }[];
        coordination:
          | {
              kind: "untracked";
            }
          | {
              kind: "tracked";
              phase: "queued" | "retry" | "receipt" | "review" | "complete";
              reason: string | null;
              dueAt: number | null;
            };
        handling:
          | {
              kind: "automatic";
            }
          | {
              kind: "manual";
              actorUid: string;
              at: number;
              authority: "current" | "revoked";
            };
        availability: "current";
        attendeeId: string;
        /**
         * @maxItems 1
         */
        actions: "manualHandoff"[];
        purpose:
          | "joiningUpdate"
          | "joiningInstructions"
          | "planChanged"
          | "guestRequirement"
          | "assignmentChanged"
          | "participationCheck"
          | "eventCancelled"
          | "eventFinished"
          | "followUp";
      }
    | {
        messageId: string;
        revision: number;
        reviewHash: string;
        createdAt: number;
        expiresAt: number;
        lifecycle: "active" | "cancelled" | "superseded" | "responded";
        deliveryStatus:
          | "notSubmitted"
          | "reserved"
          | "unknown"
          | "accepted"
          | "delivered"
          | "read"
          | "failed"
          | "notDispatched"
          | "conflictingEvidence"
          | "revoked";
        /**
         * @maxItems 6
         */
        attempts: {
          channel: "sms" | "whatsapp" | "rcs";
          state:
            | "reserved"
            | "unknown"
            | "accepted"
            | "delivered"
            | "read"
            | "failed"
            | "notDispatched"
            | "revoked";
          at: number;
        }[];
        coordination:
          | {
              kind: "untracked";
            }
          | {
              kind: "tracked";
              phase: "queued" | "retry" | "receipt" | "review" | "complete";
              reason: string | null;
              dueAt: number | null;
            };
        handling:
          | {
              kind: "automatic";
            }
          | {
              kind: "manual";
              actorUid: string;
              at: number;
              authority: "current" | "revoked";
            };
        availability: "sourceChanged";
        attendeeId: null;
        /**
         * @maxItems 0
         */
        actions: "manualHandoff"[];
        purpose:
          | "joiningUpdate"
          | "joiningInstructions"
          | "planChanged"
          | "guestRequirement"
          | "assignmentChanged"
          | "participationCheck"
          | "eventCancelled"
          | "eventFinished"
          | "followUp";
      }
  )[];
  nextCursor: string | null;
}
