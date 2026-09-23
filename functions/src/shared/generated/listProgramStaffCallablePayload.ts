/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only staff inventory in stable staff-identity order.
 */
export interface ListProgramStaffCallablePayload {
  programId: string;
  limit?: number;
  /**
   * Staff UID continuation returned by the preceding page. Ordering survives renewal and revocation.
   */
  cursor?: string;
}
