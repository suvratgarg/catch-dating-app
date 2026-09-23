/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revoke a program staff grant with revision fencing. Manager-only.
 */
export interface RevokeProgramStaffCallablePayload {
  programId: string;
  uid: string;
  expectedRevision: number;
}
