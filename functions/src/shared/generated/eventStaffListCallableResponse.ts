/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only event staff list with masked phone data.
 */
export interface EventStaffListCallableResponse {
  eventId: string;
  /**
   * @maxItems 50
   */
  members: {
    uid: string;
    displayName: string;
    phoneLastFour: string;
    status: "active" | "revoked" | "expired";
    expiresAtMillis: number;
    revision: number;
  }[];
}
