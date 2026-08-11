/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned public join configuration for the no-download Event Success runtime.
 */
export interface EventRuntimeAccess {
  enabled: boolean;
  publicRuntimeId: string | null;
  walkInPolicy: "deny" | "hostApproval" | "autoCreate";
  termsVersion: string;
}
