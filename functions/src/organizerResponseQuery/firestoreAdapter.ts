import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {info} from "firebase-functions/logger";
import type {OrganizerFormDocument, OrganizerFormResponseDocument,
  OrganizerFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {requireDoc} from "../shared/validation";
import {compileResponseQuery, materializeResponseQuery, pageResponseQuery,
  resolveSelectedResponseIds, staleResponseQuery} from "./query";
import type {ResponseQueryRow, ResponseQuerySource} from "./query";

interface Scope {
  db: FirebaseFirestore.Firestore;
  actorUid: string;
  organizerId: string;
  formId: string;
  versionId: string;
}

/** Proposed callable-safe page shape; no answer or profile projection. */
export interface ResponseQueryDisplayRow {
  responseId: string;
  formId: string;
  formTitle: string;
  versionId: string;
  version: number;
  status: OrganizerFormResponseDocument["status"];
  identityKind: OrganizerFormResponseDocument["identityKind"];
  identity: Pick<OrganizerFormResponseDocument["identity"],
    "displayName" | "email" | "phoneE164" | "origin">;
  sourceLinkId: string | null;
  submittedAtMillis: number;
  withdrawnAtMillis: number | null;
}

export interface ResponseQueryPage {
  form: {formId: string; title: string; versionId: string; version: number};
  fieldCatalog: Awaited<ReturnType<typeof materializeResponseQuery>>[
    "fieldCatalog"];
  items: ResponseQueryDisplayRow[];
  total: number;
  nextCursor: string | null;
  selectedIds: string[];
  queryHash: string;
  resultHash: string;
}

const maxScanBytes = 8 * 1024 * 1024;
const maxScanMillis = 25_000;

export interface ResponseScanMetrics {
  fetchedRows: number;
  fetchedBytes: number;
  queryPages: number;
  elapsedMillis: number;
  outcome: "complete" | "rowLimit" | "byteLimit" | "timeLimit" | "failed";
}

interface ScanInstrumentation {
  now?: () => number;
  report?: (metrics: ResponseScanMetrics) => void;
}

/**
 * Reads one Firestore snapshot. The existing organizer/form index keeps the
 * scan bounded; version is checked against the immutable published version
 * and every row, so a large multi-version form fails rather than truncates.
 */
export function firestoreResponseQuerySource(scope: Scope,
  capture?: Map<string, OrganizerFormResponseDocument>,
  instrumentation: ScanInstrumentation = {}): ResponseQuerySource {
  return {readAll: async (maxRows) => {
    const now = instrumentation.now ?? Date.now;
    const started = now();
    const metrics: ResponseScanMetrics = {fetchedRows: 0, fetchedBytes: 0,
      queryPages: 0, elapsedMillis: 0, outcome: "failed"};
    try {
      const snapshot = await scope.db.runTransaction(async (tx) => {
        await requireOrganizerManager({db: scope.db, actorUid: scope.actorUid,
          organizerId: scope.organizerId, transaction: tx});
        if ((await tx.get(scope.db.collection("deletedUsers")
          .doc(scope.actorUid))).exists) {
          throw new HttpsError("permission-denied",
            "Deleted accounts cannot query form responses.");
        }
        const [versionSnap, formSnap] = await Promise.all([
          tx.get(scope.db.collection("organizerFormVersions")
            .doc(scope.versionId)),
          tx.get(scope.db.collection("organizerForms").doc(scope.formId)),
        ]);
        if (!versionSnap.exists) {
          throw new HttpsError("not-found",
            "Published form version not found.");
        }
        if (!formSnap.exists) {
          throw new HttpsError("not-found", "Form not found.");
        }
        const version = requireDoc<OrganizerFormVersionDocument>(versionSnap,
          "OrganizerFormVersionDocument");
        const form = requireDoc<OrganizerFormDocument>(formSnap,
          "OrganizerFormDocument");
        if (version.organizerId !== scope.organizerId ||
            version.formId !== scope.formId ||
            form.organizerId !== scope.organizerId) {
          throw new HttpsError("not-found",
            "Published form version not found.");
        }
        const metadata = {formTitle: form.title, version: version.version,
          definition: version.definition};
        capture?.clear();
        const rows: ResponseQueryRow[] = [];
        let last: FirebaseFirestore.QueryDocumentSnapshot | null = null;
        const pageSize = 25;
        while (rows.length <= maxRows) {
          if (now() - started > maxScanMillis) {
            metrics.outcome = "timeLimit";
            throw new HttpsError("resource-exhausted",
              "Response query exceeded its 25-second scan limit.");
          }
          const limit = Math.min(pageSize, maxRows - rows.length + 1);
          let query: FirebaseFirestore.Query = scope.db
            .collection("organizerFormResponses")
            .where("organizerId", "==", scope.organizerId)
            .where("formId", "==", scope.formId)
            .orderBy("submittedAt", "asc")
            .orderBy(admin.firestore.FieldPath.documentId(), "asc")
            .limit(limit);
          if (last) query = query.startAfter(last);
          const page = await tx.get(query);
          metrics.queryPages += 1;
          metrics.fetchedRows += page.size;
          metrics.fetchedBytes += page.docs.reduce((sum, doc) => sum +
            Buffer.byteLength(JSON.stringify(doc.data()), "utf8"), 0);
          if (now() - started > maxScanMillis) {
            metrics.outcome = "timeLimit";
            throw new HttpsError("resource-exhausted",
              "Response query exceeded its 25-second scan limit.");
          }
          if (metrics.fetchedBytes > maxScanBytes) {
            metrics.outcome = "byteLimit";
            throw new HttpsError("resource-exhausted",
              "Response query exceeds the 8 MiB interactive scan limit.");
          }
          if (page.empty) break;
          for (const doc of page.docs) {
            last = doc;
            const response = requireDoc<OrganizerFormResponseDocument>(doc,
              "OrganizerFormResponseDocument");
            if (response.organizerId !== scope.organizerId ||
                response.formId !== scope.formId) {
              throw new HttpsError("permission-denied",
                "Response query read outside its form scope.");
            }
            capture?.set(doc.id, response);
            // Every scanned form row spends budget, even another version.
            rows.push({id: doc.id, organizerId: response.organizerId,
              formId: response.formId, versionId: response.versionId,
              status: response.status,
              submittedAtMillis: response.submittedAt.toMillis(),
              withdrawnAtMillis: response.withdrawnAt?.toMillis() ?? null,
              identityKind: response.identityKind, identity: response.identity,
              sourceLinkId: response.sourceLinkId,
              answers: response.answers,
              consentVersion: response.consentVersion,
              completionMillis: response.completionMillis});
            if (rows.length > maxRows) {
              metrics.outcome = "rowLimit";
              return {...metadata, rows};
            }
          }
          if (page.size < limit) break;
        }
        return {...metadata, rows: rows.filter((row) =>
          row.versionId === scope.versionId)};
      }, {readOnly: true});
      if (metrics.outcome !== "rowLimit") metrics.outcome = "complete";
      return snapshot;
    } finally {
      metrics.elapsedMillis = Math.max(0, now() - started);
      // Only aggregate numbers and a closed outcome: never query, IDs, answers
      // or error text. This measures a scan, not billed reads or full latency.
      const report = instrumentation.report ?? ((value: ResponseScanMetrics) =>
        info("organizer_response_scan", value));
      try {
        report(metrics);
      } catch {
        // Observability must not change query results or mask source failures.
      }
    }
  }};
}

/** Prepares the manager-authorized, version-bound query. */
async function prepare(scope: Scope, input: unknown) {
  await requireOrganizerManager({db: scope.db, actorUid: scope.actorUid,
    organizerId: scope.organizerId});
  const versionSnap = await scope.db.collection("organizerFormVersions")
    .doc(scope.versionId).get();
  if (!versionSnap.exists) {
    throw new HttpsError("not-found", "Published form version not found.");
  }
  const version = requireDoc<OrganizerFormVersionDocument>(versionSnap,
    "OrganizerFormVersionDocument");
  if (version.organizerId !== scope.organizerId ||
      version.formId !== scope.formId) {
    throw new HttpsError("not-found", "Published form version not found.");
  }
  const query = compileResponseQuery(input, version.definition);
  if (query.spec.organizerId !== scope.organizerId ||
      query.spec.formId !== scope.formId ||
      query.spec.versionId !== scope.versionId) {
    throw new HttpsError("permission-denied",
      "Response query scope does not match its authority.");
  }
  return query;
}

export async function runFirestoreResponseQuery(scope: Scope,
  input: unknown): Promise<ResponseQueryPage> {
  const query = await prepare(scope, input);
  const result = await materializeResponseQuery(query,
    firestoreResponseQuerySource(scope));
  const page = pageResponseQuery(query, result);
  return {...page, items: page.items.map((row) => ({
    responseId: row.id,
    formId: row.formId,
    formTitle: result.formTitle,
    versionId: row.versionId,
    version: result.version,
    status: row.status,
    identityKind: row.identityKind,
    identity: {displayName: row.identity.displayName,
      email: row.identity.email, phoneE164: row.identity.phoneE164,
      origin: row.identity.origin},
    sourceLinkId: row.sourceLinkId,
    submittedAtMillis: row.submittedAtMillis,
    withdrawnAtMillis: row.withdrawnAtMillis,
  })), form: {formId: scope.formId, title: result.formTitle,
    versionId: scope.versionId, version: result.version},
  fieldCatalog: result.fieldCatalog,
  selectedIds: result.selectedIds,
  queryHash: query.hash, resultHash: result.resultHash};
}

/** Re-evaluates current results before acting on explicit selected IDs. */
export async function resolveFirestoreResponseIds(scope: Scope,
  input: unknown, requestedIds: string[], expectedResultHash: string) {
  const query = await prepare(scope, input);
  const result = await materializeResponseQuery(query,
    firestoreResponseQuerySource(scope));
  return resolveSelectedResponseIds(query, result, requestedIds,
    expectedResultHash);
}

/** Validates export semantics without scanning responses at request time. */
export async function validateFirestoreResponseExport(scope: Scope,
  input: unknown, expectedQueryHash: string): Promise<void> {
  const query = await prepare(scope, input);
  if (query.hash !== expectedQueryHash) staleResponseQuery();
  if (query.spec.cursor !== null) {
    throw new HttpsError("invalid-argument",
      "Export the complete query with a null page cursor.");
  }
}

/** Resolves ordered export rows from the same authorized query snapshot. */
export async function exportFirestoreResponseQuery(scope: Scope,
  input: unknown, expectedResultHash: string, expectedQueryHash: string) {
  const query = await prepare(scope, input);
  if (query.hash !== expectedQueryHash) staleResponseQuery();
  if (query.spec.cursor !== null) {
    throw new HttpsError("invalid-argument", "Export cursor must be null.");
  }
  const captured = new Map<string, OrganizerFormResponseDocument>();
  const result = await materializeResponseQuery(query,
    firestoreResponseQuerySource(scope, captured));
  if (result.resultHash !== expectedResultHash) staleResponseQuery();
  return {...result, rows: result.rows.map((row) => ({
    row, document: captured.get(row.id)!,
  }))};
}
