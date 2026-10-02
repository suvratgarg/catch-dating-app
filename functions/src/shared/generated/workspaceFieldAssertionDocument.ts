/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable per-field acquisition evidence, explicitly scoped to an existing program or community relationship. A contact pointer or UID does not disclose fields or verify endpoint ownership.
 */
export type WorkspaceFieldAssertionDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  workspaceRef:
    | {
        kind: "program";
        id: string;
      }
    | {
        kind: "community";
        id: string;
      };
  organizerId: string;
  relationshipRef: {
    kind: "programGuest" | "programHousehold" | "communityContact";
    id: string;
  };
  fieldKey: "displayName" | "phoneE164" | "email";
  value: string | null;
  sourceKind: "manualEntry" | "manifestRow";
  sourceId: string;
  sourceVersion: number;
  actorUid: string;
  observedAtMillis: number;
  disclosureBasis: "workspaceHostAcquisition";
  identityEvidenceRef: null;
  /**
   * Exact program retention index; null for community assertions. Must agree with workspaceRef.id in the domain writer.
   */
  programId: string | null;
};
