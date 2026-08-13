/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ResolveEventSuccessLateArrivalCallableResponse {
  status: "insertedIntoOpenPair" | "extendedUnit" | "heldForNextRound";
  targetRoundIndex: number;
  revision: number;
  assignmentDraftRevision: number;
  reason: string;
  replayed: boolean;
}
