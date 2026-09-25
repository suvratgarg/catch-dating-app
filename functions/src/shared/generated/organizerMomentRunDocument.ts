/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned planned/fired run for a moment. Deterministic runId encodes moment + anchor revision + due time (or subject/requestKey for triggered/manual), making replans, retries, and sweep overlap idempotent.
 */
export interface OrganizerMomentRunDocument {
  runId: string;
  momentId: string;
  dueAtMillis: number;
  anchorRevision: number;
  status:
    | "planned"
    | "resolving"
    | "dispatched"
    | "skipped"
    | "superseded"
    | "failed";
  targetFunctionId?: string | null;
  /**
   * Triggered runs: the fact's subject (e.g. travel leg id).
   */
  subjectId?: string | null;
  /**
   * Skip/failure reason written at run transition.
   */
  reason?: string | null;
  recipients?: number | null;
  sent?: number | null;
  /**
   * Suppression reason -> recipient count rollup.
   */
  suppressed?: {
    [k: string]: number;
  } | null;
  suppressedNoEndpoint?: number | null;
}
