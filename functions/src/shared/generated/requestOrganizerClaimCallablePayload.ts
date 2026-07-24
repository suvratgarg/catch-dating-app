/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by requestOrganizerClaim.
 */
export interface RequestOrganizerClaimCallablePayload {
  organizerId: string;
  requesterName: string;
  requesterRole:
    | "owner"
    | "founder"
    | "manager"
    | "marketer"
    | "venueManager"
    | "other";
  businessEmail?: string | null;
  businessPhone?: string | null;
  /**
   * @maxItems 8
   */
  proofUrls?: string[];
  message?: string | null;
}
