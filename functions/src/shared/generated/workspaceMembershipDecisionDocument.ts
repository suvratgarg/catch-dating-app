/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable explicit membership selection, preserving previous evidence identity and reviewed guest revision. Canonical programGuests.groupIds remains membership truth, updated with this decision in one authorized transaction.
 */
export interface WorkspaceMembershipDecisionDocument {
  schemaVersion: 1;
  organizerId: string;
  programId: string;
  workspaceRef: {
    kind: "program";
    id: string;
  };
  relationshipRef: {
    kind: "programGuest";
    id: string;
  };
  groupId: string;
  selectedAssertionId: string;
  previousAssertionId: string | null;
  relationshipRevision: number;
  actorUid: string;
  observedAtMillis: number;
}
