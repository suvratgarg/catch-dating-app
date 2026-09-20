/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type SetEventAssistanceParticipationCallablePayload = {
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
    kind: "setParticipation";
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
    payload:
      | {
          attendeeId: string;
          state: "active";
          resumeAtUnit: null;
          episodeId: string | null;
          expectedParticipationRevision: number;
        }
      | {
          attendeeId: string;
          state: "temporaryBreak";
          resumeAtUnit: string | null;
          episodeId: string | null;
          expectedParticipationRevision: number;
        }
      | {
          attendeeId: string;
          state: "departed";
          resumeAtUnit: null;
          episodeId: string | null;
          expectedParticipationRevision: number;
        };
  };
  expectedSourceHash: string;
};
