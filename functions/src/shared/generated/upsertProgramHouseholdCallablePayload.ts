/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update a household/party grouping for program guests.
 */
export interface UpsertProgramHouseholdCallablePayload {
  programId: string;
  householdId?: string;
  expectedRevision?: number;
  label: string;
  primaryContactName: string;
  primaryPhoneE164?: string | null;
  primaryEmail?: string | null;
  /**
   * @minItems 1
   * @maxItems 50
   */
  memberGuestIds: string[];
  deliveryPreference?: "whatsapp" | "sms" | "email" | "none";
}
