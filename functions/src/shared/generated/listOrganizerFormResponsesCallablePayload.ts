/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized bounded response inbox query.
 */
export interface ListOrganizerFormResponsesCallablePayload {
  organizerId: string;
  formId: string | null;
  versionId: string | null;
  /**
   * @maxItems 2
   */
  statuses: ("submitted" | "withdrawn")[];
  /**
   * @maxItems 4
   */
  identityKinds: (
    | "anonymous"
    | "emailVerified"
    | "phoneVerified"
    | "catchAccount"
  )[];
  sourceLinkId: string | null;
  query: string | null;
  fromMillis: number | null;
  toMillis: number | null;
  cursor: string | null;
  limit: number;
}
