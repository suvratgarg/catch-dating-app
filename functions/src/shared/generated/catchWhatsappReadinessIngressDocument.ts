/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only audited atomic-ingress cutover evidence; not an enablement flag. Approval pins evidence digest; transaction checks identity and state. No writer or live ingress attestation is provided.
 */
export interface CatchWhatsappReadinessIngressDocument {
  schemaVersion: 1;
  ingressId: string;
  projectId: string;
  wabaId: string;
  phoneNumberId: string;
  state: "active" | "revoked";
  atomicIngressStartedAtMillis: number;
  evidenceSha256: string;
  verifiedAtMillis: number;
}
