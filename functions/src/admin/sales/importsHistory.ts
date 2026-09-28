import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {canonical} from "./imports";
import {assertSalesPrivacyOpen,
  assertSalesPrivacyOpenRead} from "../salesPrivacy/model";
import type {SalesPrincipal} from "./types";

const identifier = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u;
const hash = /^[a-f0-9]{64}$/u;
const exactDate = new RegExp(
  "^(\\d{4})-(\\d\\d)-(\\d\\d)T(\\d\\d):(\\d\\d):(\\d\\d)" +
  "(?:\\.\\d+)?(?:Z|[+-](\\d\\d):(\\d\\d))$", "u");
const digest = (value: string): string => createHash("sha256")
  .update(value).digest("hex");
const invalid = (message: string): never => {
  throw new HttpsError("invalid-argument", message);
};

function exactSourceInstant(value: string): string | null {
  const match = exactDate.exec(value);
  if (!match) return null;
  const [, yearText, monthText, dayText, hourText, minuteText,
    secondText, offsetHourText, offsetMinuteText] = match;
  const year = Number(yearText);
  const month = Number(monthText);
  const day = Number(dayText);
  const hour = Number(hourText);
  const minute = Number(minuteText);
  const second = Number(secondText);
  const offsetHour = Number(offsetHourText ?? 0);
  const offsetMinute = Number(offsetMinuteText ?? 0);
  const leapYear = year % 4 === 0 &&
    (year % 100 !== 0 || year % 400 === 0);
  const days = [31, leapYear ? 29 : 28, 31, 30, 31, 30,
    31, 31, 30, 31, 30, 31];
  if (year < 1 || month < 1 || month > 12 ||
      day < 1 || day > days[month - 1] ||
      hour > 23 || minute > 59 || second > 59 ||
      offsetHour > 23 || offsetMinute > 59) return null;
  const instant = Date.parse(value);
  return Number.isFinite(instant) ? new Date(instant).toISOString() : null;
}

export interface HistoryEntry {
  sourceColumn: string;
  sourceValue: string;
  kind: "activity" | "observation" | "benchmark";
  occurredAt: string | null;
  dateSourceColumn: string | null;
  dateSourceValue: string | null;
}
export interface HistoryRow {
  importId: string;
  sourceRowId: string;
  organizerId: string;
  disposition: "promoted" | "skipped" | "review_needed";
  reason: string;
  entries: HistoryEntry[];
}
export interface HistoryPacket {
  sourceId: string;
  contentHash: string;
  mappingVersion: string;
  promotionVersion: string;
  rows: HistoryRow[];
}
export interface HistoryApply extends HistoryPacket {
  requestId: string;
  previewHash: string;
}

function assertOwner(principal: SalesPrincipal): void {
  if (!principal.uid || principal.clientId ||
      !principal.roles.includes("adminOwner")) {
    throw new HttpsError("permission-denied",
      "Current Admin Owner authority is required for history promotion.");
  }
}
function assertEmployee(principal: SalesPrincipal): void {
  if (!principal.uid || principal.clientId ||
      !principal.roles.some((role) => role === "adminOwner" ||
        role === "admin")) {
    throw new HttpsError("permission-denied",
      "Current Sales employee authority is required for imported history.");
  }
}

function assertPacket(packet: HistoryPacket): void {
  if (!packet || !identifier.test(packet.sourceId) ||
      !hash.test(packet.contentHash) ||
      !identifier.test(packet.mappingVersion) ||
      !identifier.test(packet.promotionVersion) ||
      !Array.isArray(packet.rows) || packet.rows.length < 1 ||
      packet.rows.length > 10 ||
      Buffer.byteLength(JSON.stringify(packet)) > 120_000) {
    invalid("History packet must be a bounded, versioned private source.");
  }
  const seen = new Set<string>();
  for (const row of packet.rows) {
    if (!identifier.test(row.importId) ||
        !identifier.test(row.sourceRowId) ||
        !identifier.test(row.organizerId) ||
        seen.has(row.sourceRowId) ||
        !["promoted", "skipped", "review_needed"].includes(row.disposition) ||
        typeof row.reason !== "string" || !row.reason.trim() ||
        row.reason.length > 300 || !Array.isArray(row.entries) ||
        row.entries.length > 5 ||
        (row.disposition === "promoted") !== (row.entries.length > 0)) {
      invalid("Every source row needs one reviewed disposition.");
    }
    seen.add(row.sourceRowId);
    const selected = new Set<string>();
    for (const entry of row.entries) {
      if (!["activity", "observation", "benchmark"].includes(entry.kind) ||
          typeof entry.sourceColumn !== "string" ||
          !entry.sourceColumn.trim() || entry.sourceColumn.length > 160 ||
          selected.has(entry.sourceColumn) ||
          typeof entry.sourceValue !== "string" ||
          !entry.sourceValue.trim() || entry.sourceValue.length > 2000 ||
          (entry.occurredAt === null) !==
            (entry.dateSourceColumn === null &&
              entry.dateSourceValue === null)) {
        invalid("History entries need distinct, nonempty source cells.");
      }
      selected.add(entry.sourceColumn);
      if (entry.occurredAt !== null &&
          (typeof entry.dateSourceColumn !== "string" ||
            typeof entry.dateSourceValue !== "string" ||
            exactSourceInstant(entry.dateSourceValue) !== entry.occurredAt)) {
        invalid("Only an exact source timestamp may become occurrence time.");
      }
    }
  }
}

type Read = (ref: FirebaseFirestore.DocumentReference) =>
  Promise<FirebaseFirestore.DocumentSnapshot>;
interface Evaluated {
  previewHash: string;
  dispositions: Array<{sourceRowId: string; organizerId: string;
    status: "promoted" | "skipped" | "review_needed" | "duplicate";
    recordIds: string[]}>;
  writes: Array<{ref: FirebaseFirestore.DocumentReference;
    value: Record<string, unknown>}>;
}

async function evaluate(db: FirebaseFirestore.Firestore, packet: HistoryPacket,
  read: Read, checkPrivacy: (organizerId: string) => Promise<void>,
  now: string): Promise<Evaluated> {
  assertPacket(packet);
  const dispositions: Evaluated["dispositions"] = [];
  const writes: Evaluated["writes"] = [];
  const proof: unknown[] = [];
  const accounts = new Map<string, FirebaseFirestore.DocumentSnapshot>();
  // All proof and target reads finish before the caller performs any write.
  for (const row of packet.rows) {
    const sourceKey = digest(`${packet.sourceId}\u0000${row.sourceRowId}`);
    const lineage = await read(db.collection("salesImportRows").doc(sourceKey));
    const source = lineage.data();
    const job = await read(db.collection("salesImportJobs").doc(row.importId));
    const jobData = job.data();
    let account = accounts.get(row.organizerId);
    if (!account) {
      account = await read(db.collection("organizerSalesAccounts")
        .doc(row.organizerId));
      accounts.set(row.organizerId, account);
      await checkPrivacy(row.organizerId);
    }
    const current = account.data();
    if (!lineage.exists || source?.importId !== row.importId ||
        source?.sourceId !== packet.sourceId ||
        source?.sourceRowId !== row.sourceRowId ||
        source?.sourceContentHash !== packet.contentHash ||
        source?.mappingVersion !== packet.mappingVersion ||
        source?.organizerId !== row.organizerId ||
        !["created", "matched"].includes(source?.disposition) ||
        !job.exists || jobData?.status !== "applied" ||
        jobData?.sourceId !== packet.sourceId ||
        jobData?.contentHash !== packet.contentHash ||
        jobData?.mappingVersion !== packet.mappingVersion) {
      throw new HttpsError("failed-precondition",
        "Accepted source-row import proof is missing or changed.");
    }
    if (!account.exists || current?.classification !== "sales_private" ||
        current?.researchStatus === "archived" ||
        current?.suppressionStatus !== "clear") {
      throw new HttpsError("failed-precondition",
        "Private account is archived or privacy restricted.");
    }
    const cells = source.originalCells as
      Array<{column: string; value: string}> | null;
    const byColumn = new Map((cells ?? []).map((cell) =>
      [cell.column, cell.value]));
    if (byColumn.size !== (cells ?? []).length) {
      throw new HttpsError("failed-precondition",
        "Source column identity is ambiguous.");
    }
    const recordIds: string[] = [];
    const rowHash = digest(canonical({packet: {
      sourceId: packet.sourceId, contentHash: packet.contentHash,
      mappingVersion: packet.mappingVersion,
      promotionVersion: packet.promotionVersion}, row}));
    const rowKey = `${packet.sourceId}\u0000${row.sourceRowId}` +
      `\u0000${packet.promotionVersion}`;
    const rowId = `history-row-${digest(rowKey).slice(0, 40)}`;
    const rowRef = db.collection("salesImportHistoryRows").doc(rowId);
    const priorRow = await read(rowRef);
    if (priorRow.exists && priorRow.data()?.reviewHash !== rowHash) {
      throw new HttpsError("already-exists",
        "This source row has a conflicting reviewed history mapping.");
    }
    for (const entry of row.entries) {
      if (byColumn.get(entry.sourceColumn) !== entry.sourceValue ||
          (entry.dateSourceColumn !== null &&
            byColumn.get(entry.dateSourceColumn) !== entry.dateSourceValue)) {
        throw new HttpsError("failed-precondition",
          "Reviewed history does not match preserved source cells.");
      }
      const recordKey = `${packet.sourceId}\u0000${row.sourceRowId}` +
        `\u0000${entry.sourceColumn}`;
      const recordId = `history-${digest(recordKey).slice(0, 40)}`;
      recordIds.push(recordId);
      const ref = db.collection("salesImportHistoryRecords").doc(recordId);
      const existing = await read(ref);
      const relativeChronology = entry.sourceColumn === "First touch" ?
        "first_touch" : entry.sourceColumn === "Last touch" ?
          "last_touch" : "unspecified";
      const material = {sourceId: packet.sourceId, sourceRowId: row.sourceRowId,
        sourceContentHash: packet.contentHash, importId: row.importId,
        organizerId: row.organizerId, kind: entry.kind,
        sourceColumn: entry.sourceColumn, sourceValue: entry.sourceValue,
        relativeChronology,
        dateCertainty: entry.occurredAt === null ? "unknown" : "source_exact",
        occurredAt: entry.occurredAt,
        dateSourceColumn: entry.dateSourceColumn,
        dateSourceValue: entry.dateSourceValue};
      const contentHash = digest(canonical(material));
      if (existing.exists && existing.data()?.contentHash !== contentHash) {
        throw new HttpsError("already-exists",
          "A source cell was previously promoted with different meaning.");
      }
      if (!existing.exists) {
        writes.push({ref, value: {
          schemaVersion: 1, classification: "sales_private", recordId,
          ...material, contentHash, promotionVersion: packet.promotionVersion,
          recordedAt: now, recordedBy: "reviewed_import",
          providerConfirmed: false, currentFitAuthority: false,
          contactAuthority: false, sendAuthority: false,
        }});
      }
      proof.push({recordId, contentHash, existing: existing.exists});
    }
    if (!priorRow.exists) {
      writes.push({ref: rowRef, value: {
        schemaVersion: 1, classification: "sales_private", rowId,
        sourceId: packet.sourceId, sourceRowId: row.sourceRowId,
        sourceContentHash: packet.contentHash, importId: row.importId,
        organizerId: row.organizerId,
        promotionVersion: packet.promotionVersion,
        disposition: row.disposition, reason: row.reason, recordIds,
        reviewHash: rowHash, reviewedAt: now,
      }});
    }
    dispositions.push({sourceRowId: row.sourceRowId,
      organizerId: row.organizerId,
      status: priorRow.exists ? "duplicate" : row.disposition, recordIds});
    proof.push({rowId, rowHash, existing: priorRow.exists,
      accountRevision: current?.revision,
      suppressionStatus: current?.suppressionStatus,
      sourceHash: digest(canonical(source)),
      jobHash: digest(canonical(jobData))});
  }
  return {previewHash: digest(canonical({packet, proof})),
    dispositions, writes};
}

export async function previewSalesImportHistory(
  db: FirebaseFirestore.Firestore, principal: SalesPrincipal,
  packet: HistoryPacket): Promise<Record<string, unknown>> {
  assertOwner(principal);
  const evaluated = await evaluate(db, packet, (ref) => ref.get(),
    (organizerId) => assertSalesPrivacyOpenRead(db, organizerId), "");
  return {previewHash: evaluated.previewHash,
    rows: evaluated.dispositions, packetRowCount: packet.rows.length,
    effectsApplied: false};
}

export async function applySalesImportHistory(
  tx: FirebaseFirestore.Transaction, db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal, input: HistoryApply,
  now: string): Promise<Record<string, unknown>> {
  assertOwner(principal);
  const packet: HistoryPacket = {sourceId: input.sourceId,
    contentHash: input.contentHash, mappingVersion: input.mappingVersion,
    promotionVersion: input.promotionVersion, rows: input.rows};
  const evaluated = await evaluate(db, packet, (ref) => tx.get(ref),
    (organizerId) => assertSalesPrivacyOpen(tx, db, organizerId), now);
  if (evaluated.previewHash !== input.previewHash) {
    throw new HttpsError("aborted",
      "Imported history changed since the reviewed preview.");
  }
  for (const write of evaluated.writes) {
    tx.create(write.ref, {...write.value,
      ...(write.ref.path.startsWith("salesImportHistoryRecords/") ?
        {recordedBy: principal.uid} : {reviewedBy: principal.uid})});
  }
  return {previewHash: evaluated.previewHash,
    rows: evaluated.dispositions, packetRowCount: packet.rows.length,
    recordsCreated: evaluated.writes.filter((item) =>
      item.ref.path.startsWith("salesImportHistoryRecords/")).length,
    effectsApplied: true};
}

/** Current employee scope is checked again by the enclosing callable. */
export async function listSalesImportHistory(
  db: FirebaseFirestore.Firestore, principal: SalesPrincipal,
  input: {organizerId: string; limit?: number; cursor?: string},
): Promise<Record<string, unknown>> {
  assertEmployee(principal);
  if (!identifier.test(input.organizerId) ||
      (input.limit !== undefined && (!Number.isInteger(input.limit) ||
        input.limit < 1 || input.limit > 25)) ||
      (input.cursor !== undefined && !identifier.test(input.cursor))) {
    invalid("History list needs one organizer and a bounded page.");
  }
  await assertSalesPrivacyOpenRead(db, input.organizerId);
  const account = await db.collection("organizerSalesAccounts")
    .doc(input.organizerId).get();
  if (!account.exists || account.data()?.classification !== "sales_private" ||
      account.data()?.researchStatus === "archived" ||
      account.data()?.suppressionStatus !== "clear") {
    throw new HttpsError("not-found", "Imported history unavailable.");
  }
  let query = db.collection("salesImportHistoryRecords")
    .where("organizerId", "==", input.organizerId)
    .orderBy("__name__");
  if (input.cursor) query = query.startAfter(input.cursor);
  const page = await query.limit((input.limit ?? 25) + 1).get();
  const rows = page.docs.slice(0, input.limit ?? 25);
  return {records: rows.map((doc) => doc.data()),
    nextCursor: page.docs.length > rows.length ?
      rows.at(-1)?.id ?? null : null};
}

/** Row dispositions are separate from promoted records and paged by host. */
export async function listSalesImportHistoryRows(
  db: FirebaseFirestore.Firestore, principal: SalesPrincipal,
  input: {organizerId: string; limit?: number; cursor?: string},
): Promise<Record<string, unknown>> {
  assertEmployee(principal);
  if (!identifier.test(input.organizerId) ||
      (input.limit !== undefined && (!Number.isInteger(input.limit) ||
        input.limit < 1 || input.limit > 25)) ||
      (input.cursor !== undefined && !identifier.test(input.cursor))) {
    invalid("History row list needs one organizer and a bounded page.");
  }
  await assertSalesPrivacyOpenRead(db, input.organizerId);
  const account = await db.collection("organizerSalesAccounts")
    .doc(input.organizerId).get();
  if (!account.exists || account.data()?.classification !== "sales_private" ||
      account.data()?.researchStatus === "archived" ||
      account.data()?.suppressionStatus !== "clear") {
    throw new HttpsError("not-found", "Imported history unavailable.");
  }
  let query = db.collection("salesImportHistoryRows")
    .where("organizerId", "==", input.organizerId)
    .orderBy("__name__");
  if (input.cursor) query = query.startAfter(input.cursor);
  const page = await query.limit((input.limit ?? 25) + 1).get();
  const rows = page.docs.slice(0, input.limit ?? 25);
  return {rows: rows.map((doc) => doc.data()),
    nextCursor: page.docs.length > rows.length ?
      rows.at(-1)?.id ?? null : null};
}
