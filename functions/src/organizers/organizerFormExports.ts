import {exportFirestoreResponseQuery, validateFirestoreResponseExport} from
  "../organizerResponseQuery/firestoreAdapter";
import {createHash} from "crypto";
import * as admin from "firebase-admin";
import ExcelJS from "exceljs";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from
  "../shared/callableOptions";
import {normalizePayloadStrings} from
  "../shared/callablePayloadNormalization";
import {requireAuth} from "../shared/auth";
import type {
  OrganizerFormDocument,
  OrganizerFormExportDocument,
  OrganizerFormResponseDocument,
  OrganizerFormVersionDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {RequestOrganizerFormExportCallablePayload} from
  "../shared/generated/requestOrganizerFormExportCallablePayload";
import type {RequestOrganizerFormExportCallableResponse} from
  "../shared/generated/requestOrganizerFormExportCallableResponse";
import {
  validateRequestOrganizerFormExportCallablePayload,
} from
  "../shared/generated/validators/requestOrganizerFormExportInput";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";

interface FormExportDeps {
  firestore: () => FirebaseFirestore.Firestore;
  storageBucket: () => ReturnType<ReturnType<typeof admin.storage>["bucket"]>;
  checkRateLimit: typeof checkRateLimit;
  timestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: FormExportDeps = {
  firestore: () => admin.firestore(),
  storageBucket: () => admin.storage().bucket(),
  checkRateLimit,
  timestamp: () => admin.firestore.Timestamp.now(),
};

const exportLifetimeMs = 24 * 60 * 60 * 1000;
const downloadLifetimeMs = 15 * 60 * 1000;
const exportPageSize = 250;
const maxExportRows = 10_000;
const maxExportScannedResponses = 50_000;

interface ExportRow {
  values: Map<string, string | number | boolean | null>;
}

/** Creates an idempotent async export receipt or refreshes its status. */
export async function requestOrganizerFormExportHandler(
  request: CallableRequest<unknown>,
  deps: FormExportDeps = defaultDeps
): Promise<RequestOrganizerFormExportCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    RequestOrganizerFormExportCallablePayload
  >(
    request,
    validateRequestOrganizerFormExportCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["organizerId", "formId", "requestId"],
      nullableStringFields: ["versionId"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "requestOrganizerFormExport");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  if (data.fromMillis !== null && data.toMillis !== null &&
      data.fromMillis > data.toMillis) {
    throw new HttpsError(
      "invalid-argument",
      "The export start must be before the end."
    );
  }
  const formSnap = await db.collection("organizerForms").doc(data.formId).get();
  const form = formSnap.exists ? requireDoc<OrganizerFormDocument>(
    formSnap,
    "OrganizerFormDocument"
  ) : null;
  if (!form || form.organizerId !== data.organizerId) {
    throw new HttpsError("not-found", "Form not found.");
  }
  if (data.versionId) {
    const versionSnap = await db.collection("organizerFormVersions")
      .doc(data.versionId).get();
    const version = versionSnap.exists ?
      versionSnap.data() as OrganizerFormVersionDocument : null;
    if (!version || version.organizerId !== data.organizerId ||
        version.formId !== data.formId) {
      throw new HttpsError("not-found", "Form version not found.");
    }
  }
  const typedQuery = data.responseQuery ?? null;
  if (typedQuery) {
    if (!data.expectedResultHash || !data.expectedQueryHash ||
        data.fromMillis !== null ||
        data.toMillis !== null || data.versionId !== typedQuery.versionId ||
        data.organizerId !== typedQuery.organizerId ||
        data.formId !== typedQuery.formId ||
        JSON.stringify([...data.statuses].sort()) !==
        JSON.stringify([...typedQuery.statuses].sort())) {
      throw new HttpsError("invalid-argument",
        "Export scope and filters must match the response query.");
    }
    await validateFirestoreResponseExport({db, actorUid,
      organizerId: data.organizerId, formId: data.formId,
      versionId: typedQuery.versionId}, typedQuery, data.expectedQueryHash);
  } else if (data.expectedResultHash != null ||
      data.expectedQueryHash != null) {
    throw new HttpsError("invalid-argument", "Export query is required.");
  }
  const exportId = deterministicExportId(
    data.organizerId,
    data.formId,
    data.requestId
  );
  const exportRef = db.collection("organizerFormExports").doc(exportId);
  let document = await db.runTransaction(async (tx) => {
    await requireOrganizerManager({db, organizerId: data.organizerId,
      actorUid, transaction: tx});
    if ((await tx.get(db.collection("deletedUsers").doc(actorUid))).exists) {
      throw new HttpsError("permission-denied", "Account is deleted.");
    }
    const snapshot = await tx.get(exportRef);
    if (snapshot.exists) {
      const existing = requireDoc<OrganizerFormExportDocument>(
        snapshot,
        "OrganizerFormExportDocument"
      );
      assertSameExport(existing, data, actorUid);
      return existing;
    }
    const now = deps.timestamp();
    const created: OrganizerFormExportDocument = {
      organizerId: data.organizerId,
      formId: data.formId,
      requestedByUid: actorUid,
      requestId: data.requestId,
      format: data.format,
      responseQuery: typedQuery,
      expectedResultHash: data.expectedResultHash ?? null,
      expectedQueryHash: data.expectedQueryHash ?? null,
      statuses: data.statuses,
      versionId: data.versionId,
      fromMillis: data.fromMillis,
      toMillis: data.toMillis,
      status: "pending",
      rowCount: 0,
      storagePath: null,
      errorCode: null,
      errorMessage: null,
      createdAt: now,
      updatedAt: now,
      completedAt: null,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + exportLifetimeMs
      ),
    };
    tx.create(exportRef, created);
    return created;
  });
  if (document.expiresAt.toMillis() <= deps.timestamp().toMillis() &&
      document.status === "completed") {
    await exportRef.update({status: "expired", updatedAt: deps.timestamp()});
    document = {...document, status: "expired"};
  }
  return exportProjection(exportId, document, deps);
}

/** Builds one bounded, private CSV/XLSX object from an export receipt. */
export async function processOrganizerFormExport(
  exportId: string,
  deps: FormExportDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const exportRef = db.collection("organizerFormExports").doc(exportId);
  const document = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(exportRef);
    if (!snapshot.exists) return null;
    const current = requireDoc<OrganizerFormExportDocument>(
      snapshot,
      "OrganizerFormExportDocument"
    );
    if (current.status !== "pending") return null;
    tx.update(exportRef, {status: "running", updatedAt: deps.timestamp()});
    return current;
  });
  if (!document) return;
  try {
    const rows: ExportRow[] = [];
    const columns = new Map<string, string>([
      ["response_id", "Response ID"],
      ["form_id", "Form ID"],
      ["version_id", "Version ID"],
      ["version", "Version"],
      ["status", "Status"],
      ["submitted_at", "Submitted at"],
      ["withdrawn_at", "Withdrawn at"],
      ["identity_kind", "Identity kind"],
      ["display_name", "Display name"],
      ["email", "Email"],
      ["phone_e164", "Phone"],
      ["identity_origin", "Identity origin"],
      ["source_link_id", "Source link ID"],
      ["consent_version", "Consent version"],
      ["completion_millis", "Completion milliseconds"],
    ]);
    const versions = new Map<string, OrganizerFormVersionDocument>();
    let last: FirebaseFirestore.QueryDocumentSnapshot | null = null;
    let exhausted = false;
    let scanned = 0;
    if (document.responseQuery) {
      const query = document.responseQuery;
      if (!document.expectedResultHash || !document.expectedQueryHash ||
          query.organizerId !==
          document.organizerId || query.formId !== document.formId ||
          query.versionId !== document.versionId) {
        throw new HttpsError("failed-precondition", "Invalid export scope.");
      }
      const result = await exportFirestoreResponseQuery({db,
        actorUid: document.requestedByUid, organizerId: document.organizerId,
        formId: document.formId, versionId: query.versionId}, query,
      document.expectedResultHash, document.expectedQueryHash);
      for (const field of result.fieldCatalog) {
        columns.set(`v${result.version}_${field.questionId}`,
          `Version ${result.version}: ${field.label}`);
      }
      for (const {row, document: response} of result.rows) {
        const values = baseExportValues(row.id, response, result.version);
        for (const field of result.fieldCatalog) {
          const key = `v${result.version}_${field.questionId}`;
          const answer = row.answers[field.questionId] ?? null;
          const attachment = field.kind === "file" ||
            field.kind === "signature";
          values.set(key, attachment ?
            (answer === null || answer === "" ||
              (Array.isArray(answer) && answer.length === 0) ?
              null : "Attached") : exportAnswer(answer));
        }
        rows.push({values});
      }
      exhausted = true;
    }
    while (!exhausted) {
      // Reserve one read beyond the scan budget to prove exhaustion.
      const pageSize = Math.min(exportPageSize,
        maxExportScannedResponses - scanned + 1);
      let query: FirebaseFirestore.Query = db
        .collection("organizerFormResponses")
        .where("organizerId", "==", document.organizerId)
        .where("formId", "==", document.formId)
        .orderBy("submittedAt", "asc")
        .orderBy(admin.firestore.FieldPath.documentId(), "asc")
        .limit(pageSize);
      if (last) query = query.startAfter(last);
      const snapshot = await query.get();
      if (snapshot.empty) break;
      for (const doc of snapshot.docs) {
        scanned += 1;
        if (scanned > maxExportScannedResponses) {
          throw new HttpsError("resource-exhausted",
            "Export scan exceeds 50,000 responses. Narrow the filters.");
        }
        last = doc;
        const response = requireDoc<OrganizerFormResponseDocument>(
          doc,
          "OrganizerFormResponseDocument"
        );
        if (!exportIncludesResponse(document, response)) continue;
        // A further matching row proves the bounded export would be partial.
        // Fail the receipt before writing an apparently complete file.
        if (rows.length === maxExportRows) {
          throw new HttpsError("resource-exhausted",
            "Export exceeds 10,000 responses. Narrow the filters.");
        }
        let version = versions.get(response.versionId);
        if (!version) {
          const versionSnap = await db.collection("organizerFormVersions")
            .doc(response.versionId).get();
          version = requireDoc<OrganizerFormVersionDocument>(
            versionSnap,
            "OrganizerFormVersionDocument"
          );
          versions.set(response.versionId, version);
        }
        const values = baseExportValues(doc.id, response, version.version);
        for (const answer of response.answerSnapshots) {
          const key = `v${version.version}_${answer.key}`;
          if (!columns.has(key)) {
            columns.set(key, `Version ${version.version}: ${answer.label}`);
          }
          values.set(key, exportAnswer(answer.answer));
        }
        rows.push({values});
      }
      exhausted = snapshot.size < pageSize;
    }
    const buffer = document.format === "csv" ?
      Buffer.from(csvFor(columns, rows), "utf8") :
      await xlsxFor(columns, rows);
    const storagePath = `organizer-form-exports/${document.organizerId}/` +
      `${exportId}.${document.format}`;
    await deps.storageBucket().file(storagePath).save(buffer, {
      resumable: false,
      contentType: document.format === "csv" ?
        "text/csv; charset=utf-8" :
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      metadata: {
        cacheControl: "private, no-store",
        metadata: {exportId, organizerId: document.organizerId},
      },
    });
    const now = deps.timestamp();
    await exportRef.update({
      status: "completed",
      rowCount: rows.length,
      storagePath,
      errorCode: null,
      errorMessage: null,
      updatedAt: now,
      completedAt: now,
    });
  } catch (error) {
    await exportRef.update({
      status: "failed",
      errorCode: error instanceof HttpsError && error.code === "aborted" &&
        (error.details as {reason?: string})?.reason ===
          "response-query-stale" ? "response-query-stale" : "export_failed",
      errorMessage: sanitizeError(error),
      updatedAt: deps.timestamp(),
    });
    throw error;
  }
}

function baseExportValues(
  responseId: string,
  response: OrganizerFormResponseDocument,
  version: number
): Map<string, string | number | boolean | null> {
  return new Map<string, string | number | boolean | null>([
    ["response_id", responseId],
    ["form_id", response.formId],
    ["version_id", response.versionId],
    ["version", version],
    ["status", response.status],
    ["submitted_at", response.submittedAt.toDate().toISOString()],
    ["withdrawn_at", response.withdrawnAt?.toDate().toISOString() ?? null],
    ["identity_kind", response.identityKind],
    ["display_name", response.identity.displayName],
    ["email", response.identity.email],
    ["phone_e164", response.identity.phoneE164],
    ["identity_origin", response.identity.origin],
    ["source_link_id", response.sourceLinkId],
    ["consent_version", response.consentVersion],
    ["completion_millis", response.completionMillis],
  ]);
}

function exportIncludesResponse(
  document: OrganizerFormExportDocument,
  response: OrganizerFormResponseDocument
): boolean {
  const submittedAt = response.submittedAt.toMillis();
  return document.statuses.includes(response.status) &&
    (!document.versionId || response.versionId === document.versionId) &&
    (document.fromMillis === null || submittedAt >= document.fromMillis) &&
    (document.toMillis === null || submittedAt <= document.toMillis);
}

function exportAnswer(
  value: OrganizerFormResponseDocument["answers"][string]
): string | number | boolean | null {
  return Array.isArray(value) ? value.join(" | ") : value;
}

function csvFor(columns: Map<string, string>, rows: ExportRow[]): string {
  const keys = [...columns.keys()];
  const lines = [keys.map((key) => csvCell(columns.get(key)!)).join(",")];
  for (const row of rows) {
    lines.push(keys.map((key) =>
      csvCell(row.values.get(key) ?? null)).join(","));
  }
  return `\ufeff${lines.join("\r\n")}\r\n`;
}

function csvCell(value: string | number | boolean | null): string {
  const safe = spreadsheetSafe(value);
  return `"${String(safe ?? "").replaceAll("\"", "\"\"")}"`;
}

async function xlsxFor(
  columns: Map<string, string>,
  rows: ExportRow[]
): Promise<Buffer> {
  const workbook = new ExcelJS.Workbook();
  workbook.creator = "Catch Host Forms";
  workbook.created = new Date();
  const worksheet = workbook.addWorksheet("Responses", {
    views: [{state: "frozen", ySplit: 1}],
  });
  worksheet.columns = [...columns].map(([key, header]) => ({
    key,
    header,
    width: Math.min(48, Math.max(14, header.length + 2)),
  }));
  for (const row of rows) {
    worksheet.addRow(Object.fromEntries([...row.values].map(([key, value]) =>
      [key, spreadsheetSafe(value)])));
  }
  worksheet.getRow(1).font = {bold: true};
  worksheet.autoFilter = {
    from: {row: 1, column: 1},
    to: {row: 1, column: columns.size},
  };
  const output = await workbook.xlsx.writeBuffer();
  return Buffer.from(output);
}

function spreadsheetSafe(
  value: string | number | boolean | null
): string | number | boolean | null {
  if (typeof value !== "string") return value;
  return /^[=+\-@\t\r]/u.test(value) ? `'${value}` : value;
}

async function exportProjection(
  exportId: string,
  document: OrganizerFormExportDocument,
  deps: FormExportDeps
): Promise<RequestOrganizerFormExportCallableResponse> {
  let downloadUrl: string | null = null;
  if (document.status === "completed" && document.storagePath &&
      document.expiresAt.toMillis() > deps.timestamp().toMillis()) {
    [downloadUrl] = await deps.storageBucket().file(document.storagePath)
      .getSignedUrl({
        action: "read",
        expires: deps.timestamp().toMillis() + downloadLifetimeMs,
      });
  }
  return {
    exportId,
    status: document.status,
    format: document.format,
    rowCount: document.rowCount,
    downloadUrl,
    expiresAtMillis: document.expiresAt.toMillis(),
    errorMessage: document.errorMessage,
    errorCode: document.errorCode ?? null,
  };
}

function assertSameExport(
  existing: OrganizerFormExportDocument,
  data: RequestOrganizerFormExportCallablePayload,
  actorUid: string
): void {
  if (existing.organizerId !== data.organizerId ||
      existing.formId !== data.formId ||
      existing.requestedByUid !== actorUid ||
      existing.format !== data.format ||
      existing.versionId !== data.versionId ||
      existing.fromMillis !== data.fromMillis ||
      existing.toMillis !== data.toMillis ||
      canonicalJson(existing.responseQuery ?? null) !==
        canonicalJson(data.responseQuery ?? null) ||
      (existing.expectedQueryHash ?? null) !==
        (data.expectedQueryHash ?? null) ||
      (existing.expectedResultHash ?? null) !==
        (data.expectedResultHash ?? null) ||
      JSON.stringify([...existing.statuses].sort()) !==
        JSON.stringify([...data.statuses].sort())) {
    throw new HttpsError(
      "already-exists",
      "This export request ID was already used for different settings."
    );
  }
}

function deterministicExportId(
  organizerId: string,
  formId: string,
  requestId: string
): string {
  const digest = createHash("sha256")
    .update([organizerId, formId, requestId].join("\u001f"))
    .digest("hex").slice(0, 32);
  return `formexport_${digest}`;
}

function sanitizeError(error: unknown): string {
  const value = error instanceof Error ? error.message : "Export failed.";
  return value.replace(/[\r\n\t]/gu, " ").slice(0, 500);
}

export const requestOrganizerFormExport = onCall(
  appCheckCallableOptionsWithLimits({
    timeoutSeconds: 60,
    maxInstances: 20,
    concurrency: 20,
  }),
  (request) => requestOrganizerFormExportHandler(request)
);

export const onOrganizerFormExportRequested = onDocumentCreated(
  {
    document: "organizerFormExports/{exportId}",
    timeoutSeconds: 540,
    memory: "1GiB",
    maxInstances: 10,
  },
  async (event) => processOrganizerFormExport(event.params.exportId)
);

/** Object property order must not change idempotent request identity. */
function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  if (value && typeof value === "object") {
    const record = value as Record<string, unknown>;
    return `{${Object.keys(record).sort().map((key) =>
      `${JSON.stringify(key)}:${canonicalJson(record[key])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}
