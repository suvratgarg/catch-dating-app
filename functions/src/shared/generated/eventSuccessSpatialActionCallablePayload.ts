/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revision-fenced Host spatial-control action.
 */
export interface EventSuccessSpatialActionCallablePayload {
  eventId: string;
  expectedRevision: number;
  action:
    | "previewReassignment"
    | "reassign"
    | "confirmPosition"
    | "releasePinned";
  moduleId: "micro_pods" | "guided_rotations";
  uid: string;
  destinationUnitId?: string;
  scope?: "thisRound" | "pinned";
}
