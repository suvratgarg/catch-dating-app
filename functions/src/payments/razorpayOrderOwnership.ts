import * as admin from "firebase-admin";

/** Provider notes are mutable. This discriminator trusts merchant custody,
 * and must be checked against frozen local context before domain effects.
 * Unmarked legacy records have no admitted origin witness yet.
 */
export interface RazorpayOwnershipContext {
  readonly projectId: string;
  readonly schema: "1";
}

const ownedEvidence = new WeakSet<object>();
const evidenceBrand: unique symbol = Symbol("resolvedRazorpayOwnership");

export interface OwnedRazorpayOrderEvidence {
  readonly orderId: string;
  readonly context: RazorpayOwnershipContext;
  readonly [evidenceBrand]: true;
}

export type RazorpayOwnershipResult =
  | {kind: "owned"; evidence: OwnedRazorpayOrderEvidence}
  | {kind: "foreign" | "unknown" | "invalid" | "conflict"};

/** Resolve explicit server runtime identities; never guess DEV or use a client
 * field. Missing, malformed or disagreeing authorities fail before creation.
 */
export function resolveRazorpayRuntimeProject(input: {
  adminProjectId?: unknown;
  gcloudProject?: unknown;
  legacyGcloudProject?: unknown;
}): string {
  const supplied = Object.values(input).filter((value) => value !== undefined);
  if (!supplied.length || supplied.some((value) => !isProjectId(value)) ||
      new Set(supplied).size !== 1) {
    throw new Error("Razorpay runtime ownership is unavailable.");
  }
  return supplied[0] as string;
}

export function razorpayRuntimeProject(): string {
  let adminProjectId: unknown;
  // Tests may not initialize the default Admin app. Production can resolve its
  // explicit environment authority, but disagreement with Admin always fails.
  try {
    adminProjectId = admin.app().options.projectId;
  } catch {
    adminProjectId = undefined;
  }
  return resolveRazorpayRuntimeProject({adminProjectId,
    gcloudProject: process.env.GCLOUD_PROJECT,
    legacyGcloudProject: process.env.GCLOUDPROJECT});
}

export function razorpayOwnershipNotes(projectId: string): {
  catchBookingProject: string; catchBookingSchema: "1";
} {
  const project = resolveRazorpayRuntimeProject({adminProjectId: projectId});
  return {catchBookingProject: project, catchBookingSchema: "1"};
}

/** Call only with the fetched provider order, never webhook/client notes.
 * Bare local pending/payment/refund existence cannot establish legacy origin.
 * Frozen context is optional for an own new order whose pending write failed.
 */
export function resolveRazorpayOrderOwnership(input: {
  runtimeProjectId: string;
  order: {id: unknown; notes?: unknown};
  frozenContexts?: readonly unknown[];
}): RazorpayOwnershipResult {
  const projectId = resolveRazorpayRuntimeProject({
    adminProjectId: input.runtimeProjectId,
  });
  const notes = record(input.order.notes);
  const hasProject = Object.hasOwn(notes, "catchBookingProject");
  const hasSchema = Object.hasOwn(notes, "catchBookingSchema");
  if (!hasProject && !hasSchema) return {kind: "unknown"};
  if (!isProjectId(notes.catchBookingProject) ||
      notes.catchBookingSchema !== "1" ||
      typeof input.order.id !== "string" || !input.order.id.length ||
      input.order.id.length > 240) return {kind: "invalid"};
  // A foreign marker cannot be overridden by cloned local identities/context.
  if (notes.catchBookingProject !== projectId) return {kind: "foreign"};
  for (const frozen of input.frozenContexts ?? []) {
    if (frozen === undefined) continue;
    const context = record(frozen);
    if (context.projectId !== projectId || context.schema !== "1") {
      return {kind: "conflict"};
    }
  }
  const context: RazorpayOwnershipContext = Object.freeze({
    projectId, schema: "1",
  });
  const evidence: OwnedRazorpayOrderEvidence = Object.freeze({
    orderId: input.order.id, context, [evidenceBrand]: true as const,
  });
  ownedEvidence.add(evidence);
  return {kind: "owned", evidence};
}

/** A caller boolean, JSON copy or type assertion cannot bypass this fence.
 * Provider payment truth and exact terminal record bindings remain separate.
 */
export function assertRazorpayOrderOwnership(input: {
  evidence: OwnedRazorpayOrderEvidence;
  orderId: string;
  runtimeProjectId: string;
}): RazorpayOwnershipContext {
  if (!ownedEvidence.has(input.evidence) ||
      input.evidence.orderId !== input.orderId ||
      input.evidence.context.projectId !== input.runtimeProjectId) {
    throw new Error("Razorpay order ownership needs reconciliation.");
  }
  return input.evidence.context;
}

function isProjectId(value: unknown): value is string {
  return typeof value === "string" && /^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u
    .test(value);
}

function record(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> : {};
}
