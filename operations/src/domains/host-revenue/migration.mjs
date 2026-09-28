import fs from "node:fs/promises";
import {createHash} from "node:crypto";
import {stableStringify} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";

const digest = (value) => createHash("sha256").update(stableStringify(value)).digest("hex");
const id = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u;
const hash = /^[a-f0-9]{64}$/u;
const dispositions = ["created", "matched", "duplicate", "unresolved", "rejected"];

/** No model inference: freeze caller-reviewed identities and original lineage. */
export function freezeMigration({sourceId, contentHash, mappingVersion, rows}) {
  invariant(id.test(sourceId) && id.test(mappingVersion) && hash.test(contentHash),
    "INVALID_MIGRATION", "A versioned source and artifact hash are required.");
  invariant(Array.isArray(rows) && rows.length > 0 && rows.length <= 2000,
    "INVALID_MIGRATION", "Provide 1–2000 mapped source rows.");
  const seen = new Set();
  const groups = new Map();
  const packets = [];
  let packet = {sourceId, contentHash, mappingVersion, rows: []};
  for (const original of rows) {
    const row = structuredClone(original);
    invariant(id.test(row.sourceRowId) && !seen.has(row.sourceRowId),
      "INVALID_MIGRATION", "Each frozen source row needs a unique lineage ID.");
    seen.add(row.sourceRowId);
    invariant(row.organizerId === null || id.test(row.organizerId),
      "INVALID_MIGRATION", "Identity must be reviewed or explicitly unresolved.");
    invariant(row.cohortIds === undefined ||
      (Array.isArray(row.cohortIds) && row.cohortIds.length <= 30 &&
        row.cohortIds.every(value => id.test(value)) &&
        new Set(row.cohortIds).size === row.cohortIds.length),
    "INVALID_MIGRATION", "Cohort memberships must be reviewed IDs.");
    // Preserve each canonical organizer's source rows in one transaction. Null
    // identities remain independent review work and cannot merge by accident.
    const key = row.organizerId === null ? `unresolved:${row.sourceRowId}` :
      `organizer:${row.organizerId}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(row);
  }
  for (const group of groups.values()) {
    const next = {...packet, rows: [...packet.rows, ...group]};
    // Callable boundary is 128 KiB; leave space for request and preview hashes.
    if (next.rows.length > 25 || Buffer.byteLength(JSON.stringify(next)) > 120_000) {
      invariant(packet.rows.length > 0 || group.length > 25,
        "INVALID_MIGRATION", "A source row is too large.");
      if (packet.rows.length) packets.push(packet);
      packet = {...packet, rows: []};
    }
    packet.rows.push(...group);
    invariant(packet.rows.length <= 25 && Buffer.byteLength(JSON.stringify(packet)) <= 120_000,
      "DEPENDENT_MIGRATION_BATCHES",
      "One organizer exceeds a packet limit; review a smaller private source partition.");
  }
  if (packet.rows.length) packets.push(packet);
  const material = {schemaVersion: 1, sourceId, contentHash, mappingVersion,
    rowCount: rows.length, packets};
  return {...material, manifestHash: digest(material)};
}

export function assertFrozenMigration(manifest) {
  invariant(manifest?.schemaVersion === 1 && Array.isArray(manifest.packets),
    "INVALID_MIGRATION", "Frozen source manifest is invalid.");
  const rebuilt = freezeMigration({...manifest,
    rows: manifest.packets.flatMap((packet) => packet.rows)});
  invariant(stableStringify(rebuilt) === stableStringify(manifest),
    "MIGRATION_CHANGED", "Frozen source or batch boundaries changed; review again.");
}

export async function reviewMigration(manifest, client, timing = {}) {
  client = pacedClient(client, timing);
  assertFrozenMigration(manifest);
  const batches = [];
  for (let index = 0; index < manifest.packets.length; index += 1) {
    const packet = manifest.packets[index];
    const preview = await client.invoke("adminPreviewSalesImport", packet);
    assertResult(preview, packet, false);
    invariant(hash.test(preview.previewHash), "INVALID_PREVIEW", "Missing server preview hash.");
    batches.push({index, previewHash: preview.previewHash, rows: preview.rows,
      counts: preview.counts});
  }
  const material = {schemaVersion: 1, manifestHash: manifest.manifestHash, batches};
  return {...material, reviewHash: digest(material)};
}

/** Uses the existing Operations lease/checkpoint owner and authoritative Sales receipts. */
export async function applyReviewedMigration({manifest, review, approvedReviewHash,
  client, store, owner, now = () => new Date().toISOString(), afterCommit, timing = {}}) {
  client = pacedClient(client, timing);
  assertFrozenMigration(manifest);
  const {reviewHash, ...reviewMaterial} = review;
  invariant(reviewHash === approvedReviewHash && reviewHash === digest(reviewMaterial) &&
    review.manifestHash === manifest.manifestHash && review.batches.length === manifest.packets.length,
  "MIGRATION_REVIEW_CHANGED", "Approve the exact frozen server review before applying.");
  review.batches.forEach((batch, index) => {
    invariant(batch.index === index && hash.test(batch.previewHash),
      "INVALID_REVIEW", "Reviewed batches are missing or reordered.");
    assertResult({...batch, packetRowCount: batch.rows.length, effectsApplied: false},
      manifest.packets[index], false);
  });
  invariant(review.batches.every(batch => batch.counts.unresolved === 0 &&
    batch.counts.rejected === 0), "MIGRATION_INCOMPLETE",
  "Resolve every source identity and rejected row before applying a migration.");
  const runId = `migration-${manifest.manifestHash.slice(0, 40)}`;
  let lease = await store.acquireLease(runId, {owner, ttlMs: 120_000, now: now()});
  const results = [];
  try {
    for (let index = 0; index < manifest.packets.length; index += 1) {
      lease = await store.renewLease(lease, {ttlMs: 120_000, now: now()});
      const packet = manifest.packets[index];
      const preview = review.batches[index];
      const requestId = `migration-${digest({manifestHash: manifest.manifestHash,
        reviewHash, index}).slice(0, 48)}`;
      // Never trust a local checkpoint as proof of the database effect.
      let result;
      try {
        const response = await client.invoke("adminGetSalesReceipt", {requestId});
        result = response.receipt;
      } catch (error) {
        if (error?.code !== "ADMIN_CALLABLE_NOT_FOUND") throw error;
      }
      if (!result) {
        result = await client.invoke("adminApplySalesImport", {...packet, requestId,
          previewHash: preview.previewHash});
      }
      assertResult(result, packet, true);
      invariant(result.receipt?.requestId === requestId && typeof result.importId === "string",
        "INVALID_RECEIPT", "Sales receipt does not match the frozen batch.");
      await afterCommit?.({index, result});
      await store.putCheckpoint(runId, `batch-${index}`, {
        manifestHash: manifest.manifestHash, reviewHash, requestId,
        importId: result.importId, counts: result.counts, completedAt: now(),
      }, {lease, now: now()});
      results.push(result);
    }
  } finally {
    await store.releaseLease(lease);
  }
  const counts = Object.fromEntries(dispositions.map((key) => [key,
    results.reduce((sum, result) => sum + result.counts[key], 0)]));
  return {manifestHash: manifest.manifestHash, reviewHash, rowCount: manifest.rowCount,
    batchesCompleted: results.length, counts,
    resolved: counts.unresolved === 0 && counts.rejected === 0,
    receipts: results.map((result) => ({importId: result.importId,
      requestId: result.receipt.requestId}))};
}

function assertResult(result, packet, applied) {
  invariant(result && result.effectsApplied === applied &&
    result.packetRowCount === packet.rows.length && Array.isArray(result.rows) &&
    result.rows.length === packet.rows.length,
  "INVALID_RECEIPT", "Server result does not cover every source row.");
  const counts = Object.fromEntries(dispositions.map((key) => [key, 0]));
  result.rows.forEach((row, index) => {
    invariant(row.sourceRowId === packet.rows[index].sourceRowId &&
      row.organizerId === packet.rows[index].organizerId && dispositions.includes(row.disposition),
    "INVALID_RECEIPT", "Server result is bound to different source material.");
    counts[row.disposition] += 1;
  });
  invariant(stableStringify(counts) === stableStringify(result.counts),
    "INVALID_RECEIPT", "Import counts do not reconcile with the row dispositions.");
}

export async function readPrivateJson(file) {
  const stat = await fs.stat(file);
  invariant(stat.size <= 20_000_000, "INVALID_MIGRATION", "Private artifact exceeds 20 MB.");
  return JSON.parse(await fs.readFile(file, "utf8"));
}

// Match the existing employee callable budgets. Each invocation, including a
// not-found receipt, consumes a slot; uncertain mutations are never retried here.
function pacedClient(client, {clock = Date.now,
  wait = (ms) => new Promise(resolve => setTimeout(resolve, ms))} = {}) {
  const last = new Map();
  return {async invoke(name, payload) {
    const interval = name === "adminApplySalesImport" ? 3100 : 1050;
    const delay = Math.max(0, (last.get(name) ?? -Infinity) + interval - clock());
    if (delay) await wait(delay);
    last.set(name, clock());
    return client.invoke(name, payload);
  }};
}
