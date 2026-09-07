/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type ResolveEventAssistanceAccountabilityCallablePayload = {
  command?: {
    context?: {
      mode?: "live";
      [k: string]: unknown;
    };
    [k: string]: unknown;
  };
  [k: string]: unknown;
} & {
  groupId: string;
  command: {
    kind: "resolveAccountability";
    context:
      | {
          mode: "live";
          eventId: string;
          organizerId: string;
        }
      | {
          mode: "rehearsal";
          rehearsalId: string;
          virtualEventId: string;
          clockId: string;
        };
    eventId: string;
    operationId: string;
    payload: {
      attendeeId: string;
      /**
       * Current assistance episode, or explicit absence. The command adapter separately fences the canonical physical check-in.
       */
      episodeId: string | null;
      disposition: "returned" | "departed" | "unresolved";
    };
  };
  expectedSourceHash: string;
};
