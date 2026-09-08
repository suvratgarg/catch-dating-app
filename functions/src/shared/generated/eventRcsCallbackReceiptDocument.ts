/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventRcsCallbackReceiptDocument {
  schemaVersion: 1;
  callbackId: string;
  callbackHash: string;
  processedAt: number;
  outcome:
    | {
        kind: "delivery";
        messageId: string;
        attemptId: string;
        disposition: "applied" | "duplicateOrOlder" | "conflictingEvidence";
      }
    | {
        kind: "reply";
        messageId: string;
        attemptId: string;
        result: "accepted" | "replayed";
      }
    | {
        kind: "ignored";
        reason:
          | "subscription"
          | "unstructured"
          | "guestPage"
          | "unknownSuggestion"
          | "unconfirmedRevocation"
          | "unrelatedMessage";
      }
    | {
        kind: "rejected";
        reason:
          | "unavailable"
          | "scopeMismatch"
          | "staleIntent"
          | "invalidChoice"
          | "expired"
          | "alreadyResponded"
          | "noLongerNeeded"
          | "factsStale"
          | "guestStateChanged";
      };
}
