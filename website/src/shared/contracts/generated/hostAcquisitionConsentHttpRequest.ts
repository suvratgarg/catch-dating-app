/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Anonymous device-specific grant or withdrawal. Capability is 32 random bytes and must never be logged. Old intake analytics is not this permission.
 */
export type HostAcquisitionConsentHTTPRequest = {
  [k: string]: unknown;
} & {
  action: "grant" | "revoke";
  capability: string;
  choice?: {
    version: 1;
    purpose: "host_acquisition_measurement";
    analytics: true;
    advertising: boolean;
    chosenAt: number;
  };
};
