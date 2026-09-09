/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type ResolveEventAssistanceCaseCallablePayload = {
  command?: {
    context?: {
      mode?: "live";
      [k: string]: unknown;
    };
    [k: string]: unknown;
  };
  [k: string]: unknown;
} & {
  command: {
    kind: "resolveAssistance";
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
      caseId: string;
      outcome: "resolved" | "declined" | "transferred";
      /**
       * Current organizer manager UID receiving a transferred request; otherwise the authenticated resolving manager UID.
       */
      owner: string;
      expectedRevision: number;
    };
  };
  expectedSourceHash: string;
};
