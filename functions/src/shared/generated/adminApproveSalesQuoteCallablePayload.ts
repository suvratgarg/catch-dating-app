/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Strict private Sales commercial request; current role, scope, revision and evidence policy are transactional.
 */
export interface AdminApproveSalesQuoteCallablePayload {
  organizerId: string;
  opportunityId: string;
  requestId: string;
  expectedRevision: number;
  termVersion: number;
  evidence: {
    evidenceId: string;
  };
}
