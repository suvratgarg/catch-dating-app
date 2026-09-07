/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SetEventAssistanceGroupStaffCallablePayload {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  phoneNumber: string;
  expectedUid: string;
  expectedRevision: number;
  expectedSourceHash: string;
  requestId: string;
  decision:
    | {
        kind: "assign";
        duty: "lead" | "pacer" | "sweep";
        expiresAtMillis: number;
      }
    | {
        kind: "remove";
      };
}
