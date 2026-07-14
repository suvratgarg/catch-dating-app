/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One exclusively staged unit of work. Task flags are orthogonal and may overlap.
 */
export type OperationWorkItem = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  workItemId: string;
  workflowId: string;
  runId: string;
  entityKind: string;
  externalKey: string | null;
  revision: number;
  candidateHash: string;
  primaryStage: string;
  lifecycleStatus:
    | "queued"
    | "in_progress"
    | "waiting"
    | "ready"
    | "published"
    | "terminal";
  outcome: string | null;
  /**
   * @maxItems 40
   */
  taskFlags: string[];
  /**
   * @maxItems 40
   */
  blockerCodes: string[];
  /**
   * @maxItems 40
   */
  warningCodes: string[];
  priority: number;
  attemptCount: number;
  /**
   * @maxItems 100
   */
  evidenceRefs: {
    artifactId: string;
    contentHash: string;
    observedAt: string;
    locator: string | null;
  }[];
  /**
   * @maxItems 200
   */
  fieldProvenance: {
    field: string;
    artifactId: string;
    contentHash: string;
    locator: string | null;
    extractedBy: "deterministic" | "model" | "human";
    extractorVersion: string;
    confidence: number | null;
  }[];
  normalizedPayload: {
    [k: string]: unknown;
  };
  decisionId: string | null;
  publicationPlanId: string | null;
  createdAt: string;
  updatedAt: string;
  staleAt: string | null;
  expiresAt: string | null;
};
