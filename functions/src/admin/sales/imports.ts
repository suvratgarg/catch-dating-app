import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {newSalesAccount} from "./account";
import type {SalesPrincipal} from "./types";

export interface ImportRow {
  sourceRowId: string;
  organizerId: string | null;
  name: string;
  researchStatus: string;
  summary?: string | null;
  originalScore?: Record<string, string | number | boolean | null> | null;
}
export interface ImportPacket {
  sourceId: string;
  contentHash: string;
  mappingVersion: string;
  rows: ImportRow[];
}
export interface ImportApply extends ImportPacket {
  requestId: string;
  previewHash: string;
}
interface RowDecision {
  sourceRowId: string;
  organizerId: string | null;
  disposition: "created" | "matched" | "duplicate" | "unresolved" | "rejected";
  reason: string;
  accountRevision: number | null;
}

function sha(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

function canonical(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonical).join(",")}]`;
  if (value && typeof value === "object") {
    return `{${Object.entries(value)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, child]) => `${JSON.stringify(key)}:${canonical(child)}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
}

function assertEmployee(principal: SalesPrincipal): void {
  if (principal.clientId) {
    throw new HttpsError(
      "permission-denied",
      "Reviewed imports require an employee session.",
    );
  }
}

async function evaluateRows(
  db: FirebaseFirestore.Firestore,
  packet: ImportPacket,
  get: (
    ref: FirebaseFirestore.DocumentReference,
  ) => Promise<FirebaseFirestore.DocumentSnapshot>,
): Promise<RowDecision[]> {
  const seenRows = new Set<string>();
  const seenOrganizers = new Set<string>();
  const decisions: RowDecision[] = [];
  for (const row of packet.rows) {
    const sourceKey = `${packet.sourceId}\u0000${row.sourceRowId}`;
    const base = {sourceRowId: row.sourceRowId, organizerId: row.organizerId};
    if (seenRows.has(sourceKey)) {
      decisions.push({
        ...base,
        disposition: "duplicate",
        reason: "repeated_source_row",
        accountRevision: null,
      });
      continue;
    }
    seenRows.add(sourceKey);
    if (!row.organizerId) {
      decisions.push({
        ...base,
        disposition: "unresolved",
        reason: "identity_unresolved",
        accountRevision: null,
      });
      continue;
    }
    if (seenOrganizers.has(row.organizerId)) {
      decisions.push({
        ...base,
        disposition: "duplicate",
        reason: "repeated_organizer",
        accountRevision: null,
      });
      continue;
    }
    seenOrganizers.add(row.organizerId);
    const sourceRef = db.collection("salesImportRows").doc(sha(sourceKey));
    const organizerRef = db.collection("organizers").doc(row.organizerId);
    const accountRef = db
      .collection("organizerSalesAccounts")
      .doc(row.organizerId);
    const [sourceSnap, organizerSnap, accountSnap] = await Promise.all([
      get(sourceRef),
      get(organizerRef),
      get(accountRef),
    ]);
    if (sourceSnap.exists) {
      const changed =
        sourceSnap.data()?.sourceContentHash !== packet.contentHash;
      decisions.push({
        ...base,
        disposition: changed ? "rejected" : "duplicate",
        reason: changed ? "source_content_conflict" : "source_row_imported",
        accountRevision: null,
      });
    } else if (!organizerSnap.exists) {
      decisions.push({
        ...base,
        disposition: "rejected",
        reason: "canonical_organizer_missing",
        accountRevision: null,
      });
    } else if (
      accountSnap.exists &&
      accountSnap.data()?.classification !== "sales_private"
    ) {
      decisions.push({
        ...base,
        disposition: "rejected",
        reason: "account_contract_invalid",
        accountRevision: null,
      });
    } else if (accountSnap.exists) {
      decisions.push({
        ...base,
        disposition: "matched",
        reason: "existing_private_account",
        accountRevision: Number(accountSnap.data()?.revision),
      });
    } else {
      decisions.push({
        ...base,
        disposition: "created",
        reason: "new_private_companion",
        accountRevision: 0,
      });
    }
  }
  return decisions;
}

function previewHash(packet: ImportPacket, decisions: RowDecision[]): string {
  return sha(canonical({packet, decisions}));
}

/** Read-only preview with one disposition per source row. */
export async function previewSalesImport(
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  packet: ImportPacket,
): Promise<Record<string, unknown>> {
  assertEmployee(principal);
  const decisions = await evaluateRows(db, packet, (ref) => ref.get());
  return {
    previewHash: previewHash(packet, decisions),
    rows: decisions,
    counts: countDecisions(decisions),
    packetRowCount: packet.rows.length,
    scope: "reviewed_batch",
    effectsApplied: false,
  };
}

export async function applySalesImport(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: ImportApply,
  now: string,
): Promise<Record<string, unknown>> {
  assertEmployee(principal);
  const packet: ImportPacket = {
    sourceId: input.sourceId,
    contentHash: input.contentHash,
    mappingVersion: input.mappingVersion,
    rows: input.rows,
  };
  const decisions = await evaluateRows(db, packet, (ref) => tx.get(ref));
  if (previewHash(packet, decisions) !== input.previewHash) {
    throw new HttpsError(
      "aborted",
      "Import changed since the reviewed preview.",
    );
  }
  const importKey = `${principal.uid}\u0000${input.requestId}`;
  const importId = `import-${sha(importKey).slice(0, 24)}`;
  const jobRef = db.collection("salesImportJobs").doc(importId);
  const jobSnap = await tx.get(jobRef);
  if (jobSnap.exists) {
    throw new HttpsError("already-exists", "Import job already exists.");
  }
  const createdIds = [
    ...new Set(
      decisions
        .filter(
          (decision) =>
            decision.disposition === "created" && decision.organizerId,
        )
        .map((decision) => decision.organizerId as string),
    ),
  ];
  const canonicalSnapshots = await Promise.all(
    createdIds.map(
      async (id) =>
        [id, await tx.get(db.collection("organizers").doc(id))] as const,
    ),
  );
  const canonicalById = new Map(canonicalSnapshots);
  for (let index = 0; index < input.rows.length; index += 1) {
    const row = input.rows[index];
    const decision = decisions[index];
    const lineage = {
      schemaVersion: 1,
      classification: "sales_private",
      importId,
      sourceId: input.sourceId,
      sourceRowId: row.sourceRowId,
      sourceContentHash: input.contentHash,
      mappingVersion: input.mappingVersion,
      organizerId: row.organizerId,
      disposition: decision.disposition,
      reason: decision.reason,
      originalScore: row.originalScore ?? null,
      originalResearchStatus: row.researchStatus,
      originalSummary: row.summary ?? null,
      importedAt: now,
      importedBy: principal.uid,
    };
    tx.create(
      jobRef.collection("rows").doc(String(index).padStart(3, "0")),
      lineage,
    );
    if (
      decision.disposition !== "created" &&
      decision.disposition !== "matched"
    ) {
      continue;
    }
    const sourceKey = `${input.sourceId}\u0000${row.sourceRowId}`;
    tx.create(db.collection("salesImportRows").doc(sha(sourceKey)), lineage);
    if (decision.disposition === "created" && row.organizerId) {
      const canonicalSnap = canonicalById.get(row.organizerId);
      if (!canonicalSnap?.exists) {
        throw new HttpsError(
          "aborted",
          "Canonical organizer changed during import review.",
        );
      }
      tx.create(
        db.collection("organizerSalesAccounts").doc(row.organizerId),
        newSalesAccount(
          row.organizerId,
          canonicalSnap.data() ?? {},
          principal.uid,
          now,
          "needs_research",
        ),
      );
    }
  }
  const counts = countDecisions(decisions);
  tx.create(jobRef, {
    schemaVersion: 1,
    classification: "sales_private",
    importId,
    sourceId: input.sourceId,
    contentHash: input.contentHash,
    mappingVersion: input.mappingVersion,
    previewHash: input.previewHash,
    rowCount: input.rows.length,
    counts,
    status: "applied",
    createdAt: now,
    createdBy: principal.uid,
  });
  return {
    importId,
    counts,
    rows: decisions,
    packetRowCount: input.rows.length,
    scope: "reviewed_batch",
    effectsApplied: true,
  };
}

function countDecisions(
  decisions: RowDecision[],
): Record<RowDecision["disposition"], number> {
  const counts = {
    created: 0,
    matched: 0,
    duplicate: 0,
    unresolved: 0,
    rejected: 0,
  };
  for (const row of decisions) counts[row.disposition] += 1;
  return counts;
}
