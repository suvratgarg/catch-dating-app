/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceRcsCallbackDocument {
  schemaVersion: 1;
  callbackId: string;
  evidence: {
    agentId: string;
    endpointHash: string;
    providerEventId: string;
    eventFamily: "message" | "userEvent" | "serverEvent";
    providerOccurredAt: string | null;
    receivedAt: number;
    receiptKey: string;
    payloadHash: string;
    observation:
      | {
          kind: "delivery";
          providerMessageId: string;
          status: "delivered" | "read";
        }
      | {
          kind: "expiration";
          providerMessageId: string;
          revocation: "confirmed" | "unconfirmed";
        }
      | {
          kind: "suggestion";
          source: "message" | "event";
          suggestionType: "reply" | "action" | "unspecified";
          correlation:
            | {
                kind: "choice";
                attemptId: string;
                choiceIndex: number;
              }
            | {
                kind: "guestPage";
                attemptId: string;
              }
            | {
                kind: "unrecognized";
              };
        }
      | {
          kind: "subscription";
          requested: "subscribe" | "unsubscribe";
          source: "event" | "keyword";
        }
      | {
          kind: "unstructuredMessage";
          content: "text" | "location" | "file";
        };
  };
  storedAt: number;
}
