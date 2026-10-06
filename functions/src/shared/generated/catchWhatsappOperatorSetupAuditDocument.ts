/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create-only, no-TTL private operator setup phase audit. Authority seeds, root activation, receive prepare/finalize and readiness effects commit with their phase/audit in one Firestore transaction. Auth claim replacement remains separately journaled; hashes provide binding, not independent authentication. No token, raw claims, archive or plaintext contact content. Auth-dispatch-intent receipt precedes the external Auth call and permanently consumes its dispatch permit; it is not proof that Auth committed.
 */
export interface CatchWhatsappOperatorSetupAuditDocument {
  schemaVersion: 1;
  auditId: string;
  operationId: string;
  projectId: string;
  actorUid: string;
  planSha256: string;
  scopeSha256: string;
  fromPhase:
    | (
        | "reserved"
        | "auth-intent"
        | "auth-confirmed"
        | "seeded"
        | "root-active"
        | "prepare-intent"
        | "prepared"
        | "finalize-intent"
        | "complete"
        | "publish-intent"
        | "published"
        | "readiness-intent"
        | "ready"
        | "revoke-intent"
        | "revoked"
      )
    | null;
  toPhase:
    | "reserved"
    | "auth-intent"
    | "auth-confirmed"
    | "seeded"
    | "root-active"
    | "prepare-intent"
    | "prepared"
    | "finalize-intent"
    | "complete"
    | "publish-intent"
    | "published"
    | "readiness-intent"
    | "ready"
    | "revoke-intent"
    | "revoked";
  revision: number;
  atMillis: number;
  beforeSha256: string | null;
  afterSha256: string;
  effectSha256: string | null;
  receiptKind: "phase" | "auth-dispatch-intent";
}
