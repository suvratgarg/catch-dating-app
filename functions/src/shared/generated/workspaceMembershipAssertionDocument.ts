/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable source-labelled suggestion or manual membership evidence. Exact program/guest/group scope and program retention index are checked by the server. Import suggestions cannot overwrite selected manual inclusion or exclusion.
 */
export interface WorkspaceMembershipAssertionDocument {
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
  included: boolean;
  sourceKind: "manualEntry" | "manifestRow" | "contributorList";
  sourceId: string;
  sourceVersion: number;
  sourceLabel: string;
  actorUid: string;
  observedAtMillis: number;
}
