/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only durable project/UID/incarnation-bound capability authority. Missing records deny; no TTL, bootstrap, raw endpoint or credential. Mutations require an audited full-span Auth fence.
 */
export interface CatchWhatsappAppAuthorityDocument {
  schemaVersion: 1;
  projectId: string;
  uid: string;
  revision: number;
  incarnation: string | null;
  state: "denied" | "granting" | "active";
  authNotBeforeSeconds: number;
  updatedAtMillis: number;
  /**
   * @maxItems 3
   */
  capabilities: ("review" | "reply" | "receive")[];
  endpointHash: string | null;
  pending: {
    nonce: string;
    issuer: {
      projectId: string;
      uid: string;
      revision: number;
      incarnation: string;
      capability: "review" | "reply" | "receive";
      endpointHash: string | null;
    };
    /**
     * @minItems 1
     * @maxItems 3
     */
    capabilities: ("review" | "reply" | "receive")[];
    endpointHash: string | null;
    expiresAtMillis: number;
  } | null;
  grantedBy: {
    projectId: string;
    uid: string;
    revision: number;
    incarnation: string;
    capability: "review" | "reply" | "receive";
    endpointHash: string | null;
  } | null;
}
