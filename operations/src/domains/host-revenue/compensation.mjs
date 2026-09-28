import {createHash} from "node:crypto";
import {stableStringify} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";

const id = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u;
const hash = /^[a-f0-9]{64}$/u;
const digest = value => createHash("sha256")
  .update(stableStringify(value)).digest("hex");

/** One organizer only. The server owns proof, blockers and the plan hash. */
export async function previewReviewedCompensation(client, {importId, organizerId}) {
  invariant(id.test(importId) && id.test(organizerId), "INVALID_COMPENSATION",
    "Provide one applied import ID and one canonical organizer ID.");
  const plan = await client.invoke("adminPreviewSalesImportCompensation",
    {importId, organizerId});
  invariant(plan?.importId === importId && plan.organizerId === organizerId &&
    hash.test(plan.previewHash) &&
    ["archive_companion", "remove_cohorts", "blocked"].includes(plan.mode) &&
    Array.isArray(plan.blockers) && Array.isArray(plan.cohortIdsRemoved) &&
    typeof plan.alreadyCompensated === "boolean",
  "INVALID_COMPENSATION", "Server compensation preview is incomplete.");
  return plan;
}

/** Stable retry ID and existing Operations lease/checkpoint around one action. */
export async function applyReviewedCompensation({plan, approvedPreviewHash,
  reason, client, store, owner = "reviewed-sales-compensation",
  now = () => new Date().toISOString()}) {
  invariant(plan && id.test(plan.importId) && id.test(plan.organizerId) &&
    hash.test(plan.previewHash) && plan.previewHash === approvedPreviewHash &&
    ["archive_companion", "remove_cohorts"].includes(plan.mode) &&
    Array.isArray(plan.blockers) && plan.blockers.length === 0 &&
    plan.alreadyCompensated === false,
  "COMPENSATION_REVIEW_CHANGED",
  "Approve a current unblocked server plan for one organizer.");
  invariant(typeof reason === "string" && reason.trim() === reason &&
    reason.length > 0 && reason.length <= 2000,
  "INVALID_COMPENSATION", "A reviewed reason is required.");
  const requestId = `compensation-${digest({importId: plan.importId,
    organizerId: plan.organizerId, previewHash: plan.previewHash,
    reason}).slice(0, 48)}`;
  const runId = `compensation-${digest({importId: plan.importId,
    organizerId: plan.organizerId}).slice(0, 40)}`;
  const lease = await store.acquireLease(runId, {owner, ttlMs: 120_000,
    now: now()});
  try {
    // A repeated uncertain call uses the same actor/request receipt. The
    // server recomputes account, lineage and dependencies inside its tx.
    const result = await client.invoke("adminApplySalesImportCompensation",
      {importId: plan.importId, organizerId: plan.organizerId,
        requestId, previewHash: plan.previewHash, reason});
    invariant(result?.importId === plan.importId &&
      result.organizerId === plan.organizerId &&
      ["compensated", "already_compensated"].includes(result.status) &&
      result.receipt?.requestId === requestId,
    "INVALID_COMPENSATION_RECEIPT",
    "Sales compensation receipt does not match the reviewed action.");
    await store.putCheckpoint(runId, "effect", {importId: plan.importId,
      organizerId: plan.organizerId, previewHash: plan.previewHash,
      requestId, status: result.status, completedAt: now()},
    {lease, now: now()});
    return result;
  } finally {
    await store.releaseLease(lease);
  }
}
