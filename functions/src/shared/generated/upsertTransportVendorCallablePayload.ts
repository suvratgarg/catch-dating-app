/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update an organizer-level transport vendor and bind it to programs.
 */
export interface UpsertTransportVendorCallablePayload {
  organizerId: string;
  vendorId?: string;
  expectedRevision?: number;
  name: string;
  contactName?: string | null;
  phoneE164?: string | null;
  /**
   * @maxItems 100
   */
  programIds?: string[];
  active?: boolean;
  notes?: string | null;
}
