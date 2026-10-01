/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable explicit field-selection decision. Records the authorized reviewer and exact before/after assertion pointers without copying field values or granting identity proof.
 */
export type WorkspaceFieldDecisionDocument = {
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
  /**
   * Exact program retention index; null for community assertions. Must agree with workspaceRef.id in the domain writer.
   */
  programId: string | null;
  relationshipRef: {
    kind: "programGuest" | "programHousehold" | "communityContact";
    id: string;
  };
  fieldKey: "displayName" | "phoneE164" | "email";
  actorUid: string;
  observedAtMillis: number;
  selectedAssertionId: string;
  previousAssertionId: string | null;
  relationshipRevision: number;
};
