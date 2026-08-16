/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe state returned after an organizer-scoped contact mutation.
 */
export interface MutateOrganizerContactCallableResponse {
  organizerId: string;
  contactId: string;
  displayName: string;
  displayNameOverride: string | null;
  whatsappAdminSuppressed: boolean;
  hidden: boolean;
  /**
   * @maxItems 5
   */
  manualTags?: {
    tagId: string;
    label: string;
  }[];
  revision: number;
}
