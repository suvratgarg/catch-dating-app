/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only organizer-scoped contact correction, suppression, or hiding request.
 */
export type MutateOrganizerContactCallablePayload = {
  [k: string]: unknown;
} & {
  organizerId: string;
  contactId: string;
  expectedRevision: number;
  displayNameOverride?: string | null;
  whatsappAdminSuppressed?: boolean;
  hidden?: boolean;
};
