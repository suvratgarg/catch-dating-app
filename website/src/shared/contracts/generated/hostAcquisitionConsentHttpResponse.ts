/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Permission handshake result. Disabled or revoked status never authorizes delivery.
 */
export type HostAcquisitionConsentHTTPResponse =
  | {
      ok: true;
      status: "active" | "revoked" | "disabled";
      expiresAt: number | null;
    }
  | {
      error: string;
    };
