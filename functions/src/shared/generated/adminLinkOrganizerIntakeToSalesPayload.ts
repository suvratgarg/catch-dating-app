/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Links an employee-reviewed Supply Intake canonical organizer decision to its private Sales account; no organizer, publication or ownership mutation.
 */
export interface AdminLinkOrganizerIntakeToSalesPayload {
  workItemId: string;
  candidateId: string;
  expectedWorkItemRevision: number;
  expectedCandidateHash: string;
  organizerId: string;
  curationPath: string;
  requestId: string;
}
