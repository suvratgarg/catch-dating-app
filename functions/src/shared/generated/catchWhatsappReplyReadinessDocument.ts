/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private externally reviewed historical STOP clearance for one Catch sender/recipient endpoint. Complete evidence from sender inception (coverage starts at epoch) through verified atomic STOP ingress is required; empty or expired receipt queries are never proof. This feature only reads the record; it cannot attest, provision, refresh or activate it. No TTL or raw endpoint.
 */
export interface CatchWhatsappReplyReadinessDocument {
  schemaVersion: 1;
  readinessId: string;
  wabaId: string;
  phoneNumberId: string;
  recipientUid: string;
  endpointHash: string;
  purpose: "serviceSupport";
  state: "ready" | "revoked";
  completeHistory: true;
  historyFromMillis: 0;
  coveredThroughMillis: number;
  atomicIngressStartedAtMillis: number;
  evidenceSha256: string;
  reviewedByUid: string;
  reviewedAtMillis: number;
  expiresAtMillis: number;
}
