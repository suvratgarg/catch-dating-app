/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable private join from exact reviewed Supply Intake candidate and canonical identity decision to the Sales companion account.
 */
export interface SalesIntakeLinkDocument {
  schemaVersion: 1;
  classification: "sales_private";
  linkId: string;
  workItemId: string;
  candidateId: string;
  sourceRunId: string;
  sourceWorkItemRevision: number;
  sourceCandidateHash: string;
  organizerId: string;
  curationPath: string;
  curationOperationType: "create_entity_draft" | "attach_surface";
  curationReviewedByUid: string;
  curationReviewedAt: string;
  linkedByUid: string;
  linkedAt: string;
}
