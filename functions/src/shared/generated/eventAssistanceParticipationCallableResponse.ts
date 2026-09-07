/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceParticipationCallableResponse {
  outcome: "read" | "applied" | "replayed";
  operationRevision: number | null;
  view: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    attendeeId: string;
    serverTime: number;
    sourceHash: string;
    freshness: "uninitialized" | "current" | "sourceChanged";
    revision: number;
    episodeId: string | null;
    participation:
      | (
          | {
              state: "active";
              resumeAtUnit: null;
            }
          | {
              state: "temporaryBreak";
              resumeAtUnit: string | null;
            }
          | {
              state: "departed";
              resumeAtUnit: null;
            }
        )
      | null;
    canChange: boolean;
    checkedIn: boolean;
    /**
     * @maxItems 40
     */
    resumeUnits: {
      unitId: string;
      label: string;
    }[];
  };
}
