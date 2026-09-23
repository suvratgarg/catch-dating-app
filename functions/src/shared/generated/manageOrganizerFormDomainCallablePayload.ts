/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only reservation, DNS verification, or revocation request. Hosting and certificate state cannot be supplied by clients.
 */
export type ManageOrganizerFormDomainCallablePayload =
  | {
      action: "reserve";
      hostname: string;
      organizerId: string;
      formId: string;
    }
  | {
      action: "verify";
      hostname: string;
      organizerId: string;
    }
  | {
      action: "revoke";
      hostname: string;
      organizerId: string;
    };
