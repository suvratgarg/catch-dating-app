/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Permanent project-bound one-time operator setup slot. Never delete, reset or add TTL. Exact private reviewed plan/scope and replay digests bind source SHA, current account incarnations, Google identity, expected absence, fixed capabilities and server-owned readiness references. Phases journal non-atomic Auth/Firestore effects; unknown outcomes are reconciled without blind retry. Internal source only, no client writes or activation by this schema.
 */
export interface CatchWhatsappOperatorSetupOperationDocument {
  schemaVersion: 1;
  operationId: string;
  projectId: string;
  planId: string;
  planSha256: string;
  replaySha256: string;
  scopeSha256: string;
  actorUid: string;
  recipientUid: string;
  phase:
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
  updatedAtMillis: number;
}
