/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Read or complete the authenticated account with minimal identity. Phone ownership comes from Firebase Auth, never payload data.
 */
export type ManageWebsiteAccountCallablePayload =
  | {
      action: "read";
      organizerId?: string;
      eventId?: string;
    }
  | {
      action: "complete";
      displayName: string;
      /**
       * Optional real birth date. Omission preserves existing data; no placeholder is synthesized.
       */
      dateOfBirth?: string;
      expectedProfileRevision: number;
      organizerId?: string;
      eventId?: string;
      expectedUid: string;
    };
