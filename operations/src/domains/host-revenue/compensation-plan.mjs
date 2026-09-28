import {createHash} from "node:crypto";
import {stableStringify} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";
import {assertFrozenMigration} from "./migration.mjs";

const digest = value => createHash("sha256").update(stableStringify(value)).digest("hex");
const relatedKinds = ["otherImportRows", "contacts", "relationships", "evidence",
  "tasks", "opportunities", "stageHistory", "commercialRecords", "activities",
  "outreachProposals"];

/** Read-only inspection plan. No result from this function authorizes deletion. */
export function planMigrationCompensation({manifest, review, receipts, currentAccounts = {},
  relatedRecords = {}}) {
  assertFrozenMigration(manifest);
  const {reviewHash, ...reviewMaterial} = review ?? {};
  invariant(reviewHash === digest(reviewMaterial) &&
    review.manifestHash === manifest.manifestHash &&
    review.batches.length === manifest.packets.length,
  "INVALID_COMPENSATION", "The approved review must bind the frozen source.");
  invariant(Array.isArray(receipts) && receipts.length === manifest.packets.length,
    "INVALID_COMPENSATION", "Authoritative receipts are required for every batch.");
  const rows = [];
  const created = new Map();
  receipts.forEach((receipt, index) => {
    const packet = manifest.packets[index];
    const expectedRequestId = `migration-${digest({manifestHash: manifest.manifestHash,
      reviewHash, index}).slice(0, 48)}`;
    invariant(receipt?.effectsApplied === true && typeof receipt.importId === "string" &&
      receipt.receipt?.requestId === expectedRequestId &&
      Array.isArray(receipt.rows) && receipt.rows.length === packet.rows.length,
    "INVALID_COMPENSATION", "A complete applied Sales receipt is required.");
    receipt.rows.forEach((decision, rowIndex) => {
      const original = packet.rows[rowIndex];
      invariant(decision.sourceRowId === original.sourceRowId &&
        decision.organizerId === original.organizerId,
      "INVALID_COMPENSATION", "Receipt lineage differs from the frozen source.");
      if (!["created", "matched"].includes(decision.disposition)) return;
      rows.push({sourceRowId: original.sourceRowId, organizerId: original.organizerId,
        importId: receipt.importId,
        action: "inspect_lineage_only",
        condition: "Remove only through a separately reviewed domain action after current document and dependent-write checks."});
      if (decision.disposition === "created") {
        invariant(!created.has(original.organizerId), "INVALID_COMPENSATION",
          "An organizer was created in multiple batches.");
        created.set(original.organizerId, {importId: receipt.importId,
          sourceRowId: original.sourceRowId});
      }
    });
  });
  const accounts = [...created].map(([organizerId, origin]) => {
    const current = currentAccounts[organizerId];
    const related = relatedRecords[organizerId];
    const relatedComplete = relatedKinds.every(kind =>
      Number.isInteger(related?.[kind]) && related[kind] >= 0);
    const laterEdit = current && (current.revision !== 1 ||
      current.createdAt !== current.updatedAt);
    const linked = relatedComplete && relatedKinds.some(kind => related[kind] > 0);
    return {organizerId, ...origin,
      status: !current ? "current_read_required" : laterEdit ?
        "preserve_later_edits" : !relatedComplete ? "related_records_read_required" :
          linked ? "preserve_linked_records" : "manual_review_only",
      action: "manual_review_only"};
  });
  const material = {schemaVersion: 1, manifestHash: manifest.manifestHash,
    effectsApplied: false, executableRollback: false, accounts, rows};
  return {...material, planHash: digest(material)};
}
