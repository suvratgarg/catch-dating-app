import {createHash} from "node:crypto";
import {stableStringify} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";

const id = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u;
const hash = /^[a-f0-9]{64}$/u;
const digest = value => createHash("sha256")
  .update(stableStringify(value)).digest("hex");
const statuses = ["promoted", "skipped", "review_needed"];

export function historyDecisionTemplate(source) {
  invariant(id.test(source?.sourceId) && hash.test(source?.contentHash) &&
    id.test(source?.mappingVersion) && Array.isArray(source?.rows),
  "INVALID_HISTORY", "A frozen private source is required.");
  return {schemaVersion: 1, sourceHash: digest(source),
    promotionVersion: "history-v1", rows: []};
}

/** Every source row gets one explicit local disposition, including unresolved. */
export function freezeHistoryPromotion(source, decisions) {
  const template = historyDecisionTemplate(source);
  invariant(decisions?.schemaVersion === 1 &&
    decisions.sourceHash === template.sourceHash &&
    id.test(decisions.promotionVersion) && Array.isArray(decisions.rows),
  "HISTORY_SOURCE_CHANGED", "History decisions must bind the exact source.");
  const byId = new Map();
  const sourceIds = new Set(source.rows.map(row => row.sourceRowId));
  invariant(sourceIds.size === source.rows.length &&
    [...sourceIds].every(value => id.test(value)),
  "INVALID_HISTORY", "Source row IDs must be distinct and valid.");
  for (const decision of decisions.rows) {
    invariant(sourceIds.has(decision.sourceRowId) &&
      !byId.has(decision.sourceRowId) &&
      statuses.includes(decision.disposition),
    "INVALID_HISTORY", "Each decision must name one unique source row.");
    byId.set(decision.sourceRowId, structuredClone(decision));
  }
  const rows = source.rows.map(row => {
    const decision = byId.get(row.sourceRowId);
    const disposition = decision?.disposition ?? "review_needed";
    const reason = decision?.reason ?? "history_mapping_not_reviewed";
    const entries = decision?.entries ?? [];
    invariant(typeof reason === "string" && reason.trim() &&
      reason.length <= 300 && Array.isArray(entries) && entries.length <= 5,
    "INVALID_HISTORY", "A bounded review reason and entries are required.");
    if (disposition === "promoted") {
      invariant(id.test(row.organizerId) &&
        decision?.organizerId === row.organizerId &&
        id.test(decision.importId) && entries.length > 0,
      "INVALID_HISTORY", "Promotion needs reviewed canonical import lineage.");
    } else {
      invariant(entries.length === 0, "INVALID_HISTORY",
        "Only promoted rows can contain history entries.");
    }
    if (disposition === "skipped") {
      invariant(id.test(row.organizerId) &&
        decision?.organizerId === row.organizerId &&
        id.test(decision.importId), "INVALID_HISTORY",
      "A skipped accepted row needs its source import identity.");
    }
    if (disposition === "review_needed") {
      invariant((!decision?.importId && !decision?.organizerId) ||
        (id.test(row.organizerId) &&
          decision.organizerId === row.organizerId &&
          id.test(decision.importId)),
      "INVALID_HISTORY", "Pending rows need valid reviewed identity or none.");
    }
    const cells = new Map((row.originalCells ?? [])
      .map(cell => [cell.column, cell.value]));
    invariant(cells.size === (row.originalCells ?? []).length,
      "INVALID_HISTORY", "Source columns must be unique per row.");
    const selected = new Set();
    for (const entry of entries) {
      invariant(["activity", "observation", "benchmark"].includes(entry.kind) &&
        !selected.has(entry.sourceColumn) &&
        cells.get(entry.sourceColumn) === entry.sourceValue &&
        entry.sourceValue?.trim() &&
        (entry.dateSourceColumn === null ||
          cells.get(entry.dateSourceColumn) === entry.dateSourceValue),
      "INVALID_HISTORY", "History entry must cite an exact source cell.");
      selected.add(entry.sourceColumn);
    }
    return {sourceRowId: row.sourceRowId,
      organizerId: row.organizerId ?? null,
      importId: decision?.importId ?? null,
      disposition, reason, entries};
  });
  const packets = [];
  let packet = {sourceId: source.sourceId,
    contentHash: source.contentHash,
    mappingVersion: source.mappingVersion,
    promotionVersion: decisions.promotionVersion, rows: []};
  for (const row of rows.filter(item => item.importId !== null)) {
    const next = {...packet, rows: [...packet.rows, row]};
    if (next.rows.length > 10 ||
        Buffer.byteLength(JSON.stringify(next)) > 120_000) {
      if (packet.rows.length) packets.push(packet);
      packet = {...packet, rows: []};
    }
    packet.rows.push(row);
    invariant(packet.rows.length <= 10 &&
      Buffer.byteLength(JSON.stringify(packet)) <= 120_000,
    "INVALID_HISTORY", "One history row exceeds the callable packet bound.");
  }
  if (packet.rows.length) packets.push(packet);
  const counts = Object.fromEntries(statuses.map(status =>
    [status, rows.filter(row => row.disposition === status).length]));
  const material = {schemaVersion: 1, sourceHash: template.sourceHash,
    sourceId: source.sourceId, contentHash: source.contentHash,
    mappingVersion: source.mappingVersion,
    promotionVersion: decisions.promotionVersion,
    decisionHash: digest(decisions), rowCount: rows.length,
    counts, rows, packets};
  return {...material, planHash: digest(material)};
}

export function assertHistoryPlan(plan) {
  const {planHash, ...material} = plan ?? {};
  const accepted = plan?.rows?.filter(row => row.importId !== null) ?? [];
  const counts = Object.fromEntries(statuses.map(status =>
    [status, plan?.rows?.filter(row =>
      row.disposition === status).length ?? -1]));
  invariant(hash.test(planHash) && digest(material) === planHash &&
    Array.isArray(plan.rows) && plan.rows.length === plan.rowCount &&
    Array.isArray(plan.packets) &&
    stableStringify(plan.counts) === stableStringify(counts) &&
    stableStringify(plan.packets.flatMap(packet => packet.rows)) ===
      stableStringify(accepted) &&
    plan.packets.every(packet => packet.sourceId === plan.sourceId &&
      packet.contentHash === plan.contentHash &&
      packet.mappingVersion === plan.mappingVersion &&
      packet.promotionVersion === plan.promotionVersion &&
      packet.rows.length > 0 && packet.rows.length <= 10 &&
      Buffer.byteLength(JSON.stringify(packet)) <= 120_000),
  "HISTORY_PLAN_CHANGED", "Frozen history plan changed since review.");
}

function assertServerRows(result, packet, effectsApplied) {
  invariant(result?.effectsApplied === effectsApplied &&
    hash.test(result.previewHash) &&
    result.packetRowCount === packet.rows.length &&
    Array.isArray(result.rows) && result.rows.length === packet.rows.length,
  "INVALID_HISTORY_RECEIPT", "Server did not account for every packet row.");
  result.rows.forEach((row, index) => {
    invariant(row.sourceRowId === packet.rows[index].sourceRowId &&
      row.organizerId === packet.rows[index].organizerId &&
      [packet.rows[index].disposition, "duplicate"].includes(row.status) &&
      Array.isArray(row.recordIds),
    "INVALID_HISTORY_RECEIPT", "Server history row differs from review.");
  });
}

function pacedClient(client, {clock = Date.now,
  wait = ms => new Promise(resolve => setTimeout(resolve, ms))} = {}) {
  let last = -Infinity;
  return {async invoke(name, payload) {
    const interval = name === "adminApplySalesImportHistory" ? 3100 : 1050;
    const delay = Math.max(0, last + interval - clock());
    if (delay) await wait(delay);
    last = clock();
    return client.invoke(name, payload);
  }};
}

export async function reviewHistoryPromotion(plan, client, timing = {}) {
  assertHistoryPlan(plan);
  client = pacedClient(client, timing);
  const batches = [];
  for (let index = 0; index < plan.packets.length; index += 1) {
    const result = await client.invoke("adminPreviewSalesImportHistory",
      plan.packets[index]);
    assertServerRows(result, plan.packets[index], false);
    batches.push({index, previewHash: result.previewHash,
      rows: result.rows});
  }
  const material = {schemaVersion: 1, planHash: plan.planHash, batches};
  return {...material, reviewHash: digest(material)};
}

export async function applyReviewedHistoryPromotion({plan, review,
  approvedReviewHash, client, store, owner = "sales-history-promotion",
  now = () => new Date().toISOString(), timing = {}}) {
  assertHistoryPlan(plan);
  client = pacedClient(client, timing);
  const {reviewHash, ...material} = review ?? {};
  invariant(hash.test(reviewHash) && reviewHash === approvedReviewHash &&
    digest(material) === reviewHash && review.planHash === plan.planHash &&
    review.batches.length === plan.packets.length,
  "HISTORY_REVIEW_CHANGED", "Approve the exact server history review.");
  const runId = `history-${plan.planHash.slice(0, 40)}`;
  let lease = await store.acquireLease(runId, {owner, ttlMs: 120_000,
    now: now()});
  const results = [];
  try {
    for (let index = 0; index < plan.packets.length; index += 1) {
      lease = await store.renewLease(lease, {ttlMs: 120_000, now: now()});
      const packet = plan.packets[index];
      const batch = review.batches[index];
      invariant(batch.index === index && hash.test(batch.previewHash),
        "INVALID_HISTORY_REVIEW", "History batches are missing or reordered.");
      assertServerRows({previewHash: batch.previewHash, rows: batch.rows,
        packetRowCount: packet.rows.length, effectsApplied: false},
      packet, false);
      const requestId = `history-${digest({planHash: plan.planHash,
        reviewHash, index}).slice(0, 48)}`;
      const result = await client.invoke("adminApplySalesImportHistory",
        {...packet, requestId, previewHash: batch.previewHash});
      assertServerRows(result, packet, true);
      invariant(result.receipt?.requestId === requestId &&
        Number.isInteger(result.recordsCreated),
      "INVALID_HISTORY_RECEIPT", "History receipt is not bound to this run.");
      await store.putCheckpoint(runId, `batch-${index}`, {requestId,
        previewHash: batch.previewHash, completedAt: now()}, {lease,
        now: now()});
      results.push(result);
    }
  } finally {
    await store.releaseLease(lease);
  }
  return {planHash: plan.planHash, reviewHash, rowCount: plan.rowCount,
    counts: plan.counts, batchesCompleted: results.length,
    recordsCreated: results.reduce((sum, item) =>
      sum + item.recordsCreated, 0),
    complete: plan.counts.review_needed === 0};
}
