/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Body-free durable semantic collision fence captured only after authenticated exact-sender ingress. Hashes never establish source completeness, consent or STOP absence. Blocked events cannot be reactivated; no TTL.
 */
export interface CatchWhatsappIngressEvidenceDocument {
  schemaVersion: 1;
  eventId: string;
  wabaId: string;
  phoneNumberId: string;
  endpointHash: string | null;
  materialSha256: string;
  eventKind: "inbound" | "status";
  classification: "text" | "stop" | "status" | "ambiguous";
  ambiguity:
    | (
        | "unresolved-endpoint"
        | "truncated-text"
        | "unsupported-message"
        | "missing-text"
        | "invalid-status-errors"
      )
    | null;
  state: "accepted" | "blocked";
  receivedAtMillis: number;
}
