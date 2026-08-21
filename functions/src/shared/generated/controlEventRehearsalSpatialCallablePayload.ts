/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Previews or persists one synthetic actor placement inside an isolated dress rehearsal.
 */
export interface ControlEventRehearsalSpatialCallablePayload {
  sessionId: string;
  expectedRevision: number;
  clientActionId: string;
  actorId: string;
  action: "reassign" | "confirmPosition" | "releasePinned";
  destinationUnitId: string | null;
  scope: "thisRound" | "pinned" | null;
}
