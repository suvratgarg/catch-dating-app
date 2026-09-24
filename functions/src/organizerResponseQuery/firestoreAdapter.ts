import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerFormDocument, OrganizerFormResponseDocument,
  OrganizerFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {requireDoc} from "../shared/validation";
import {compileResponseQuery, materializeResponseQuery, pageResponseQuery,
  resolveSelectedResponseIds, responseQueryFieldCatalog} from "./query";
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
  fieldCatalog: ReturnType<typeof responseQueryFieldCatalog>;
  items: ResponseQueryDisplayRow[];
  total: number;
  nextCursor: string | null;
  selectedIds: string[];
  queryHash: string;
  resultHash: string;
}

const maxScanBytes = 8 * 1024 * 1024;
const maxScanMillis = 25_000;

/**
 * Reads one Firestore snapshot. The existing organizer/form index keeps the
 * scan bounded; version is checked against the immutable published version
 * and every row, so a large multi-version form fails rather than truncates.
 */
export function firestoreResponseQuerySource(scope: Scope):
  ResponseQuerySource {
  return {readAll: (maxRows) => scope.db.runTransaction(async (tx) => {
    await requireOrganizerManager({db: scope.db, actorUid: scope.actorUid,
      organizerId: scope.organizerId, transaction: tx});
    const versionSnap = await tx.get(scope.db
      .collection("organizerFormVersions").doc(scope.versionId));
    if (!versionSnap.exists) {
      throw new HttpsError("not-found", "Published form version not found.");
    }
    const version = requireDoc<OrganizerFormVersionDocument>(versionSnap,
      "OrganizerFormVersionDocument");
    if (version.organizerId !== scope.organizerId ||
        version.formId !== scope.formId) {
      throw new HttpsError("not-found", "Published form version not found.");
    }
    const rows: ResponseQueryRow[] = [];
    let last: FirebaseFirestore.QueryDocumentSnapshot | null = null;
    let bytes = 0;
    const started = Date.now();
    const pageSize = 25;
    while (rows.length <= maxRows) {
      if (Date.now() - started > maxScanMillis) {
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
      if (Date.now() - started > maxScanMillis) {
        throw new HttpsError("resource-exhausted",
          "Response query exceeded its 25-second scan limit.");
      }
      if (page.empty) break;
      for (const doc of page.docs) {
        last = doc;
        bytes += Buffer.byteLength(JSON.stringify(doc.data()), "utf8");
        if (bytes > maxScanBytes) {
          throw new HttpsError("resource-exhausted",
            "Response query exceeds the 8 MiB interactive scan limit.");
        }
        const response = requireDoc<OrganizerFormResponseDocument>(doc,
          "OrganizerFormResponseDocument");
        if (response.organizerId !== scope.organizerId ||
            response.formId !== scope.formId) {
          throw new HttpsError("permission-denied",
            "Response query read outside its form scope.");
        }
        // Every scanned form row spends budget, even another version.
        rows.push({id: doc.id, organizerId: response.organizerId,
          formId: response.formId, versionId: response.versionId,
          status: response.status,
          submittedAtMillis: response.submittedAt.toMillis(),
          withdrawnAtMillis: response.withdrawnAt?.toMillis() ?? null,
          identityKind: response.identityKind, identity: response.identity,
          sourceLinkId: response.sourceLinkId,
          answers: response.answers});
        if (rows.length > maxRows) return rows;
      }
      if (page.size < limit) break;
    }
    return rows.filter((row) => row.versionId === scope.versionId);
  }, {readOnly: true})};
}

/** Prepares the manager-authorized, version-bound query. */
async function prepare(scope: Scope, input: unknown) {
  await requireOrganizerManager({db: scope.db, actorUid: scope.actorUid,
    organizerId: scope.organizerId});
  const [versionSnap, formSnap] = await Promise.all([
    scope.db.collection("organizerFormVersions").doc(scope.versionId).get(),
    scope.db.collection("organizerForms").doc(scope.formId).get(),
  ]);
  if (!versionSnap.exists) {
    throw new HttpsError("not-found", "Published form version not found.");
  }
  const version = requireDoc<OrganizerFormVersionDocument>(versionSnap,
    "OrganizerFormVersionDocument");
  if (!formSnap.exists) {
    throw new HttpsError("not-found", "Form not found.");
  }
  const form = requireDoc<OrganizerFormDocument>(formSnap,
    "OrganizerFormDocument");
  if (version.organizerId !== scope.organizerId ||
      version.formId !== scope.formId ||
      form.organizerId !== scope.organizerId) {
    throw new HttpsError("not-found", "Published form version not found.");
  }
  const query = compileResponseQuery(input, version.definition);
  if (query.spec.organizerId !== scope.organizerId ||
      query.spec.formId !== scope.formId ||
      query.spec.versionId !== scope.versionId) {
    throw new HttpsError("permission-denied",
      "Response query scope does not match its authority.");
  }
  return {query, form, version};
}

export async function runFirestoreResponseQuery(scope: Scope,
  input: unknown): Promise<ResponseQueryPage> {
  const {query, form, version} = await prepare(scope, input);
  const result = await materializeResponseQuery(query,
    firestoreResponseQuerySource(scope),
    {formTitle: form.title, version: version.version});
  const page = pageResponseQuery(query, result);
  return {...page, items: page.items.map((row) => ({
    responseId: row.id,
    formId: row.formId,
    formTitle: form.title,
    versionId: row.versionId,
    version: version.version,
    status: row.status,
    identityKind: row.identityKind,
    identity: {displayName: row.identity.displayName,
      email: row.identity.email, phoneE164: row.identity.phoneE164,
      origin: row.identity.origin},
    sourceLinkId: row.sourceLinkId,
    submittedAtMillis: row.submittedAtMillis,
    withdrawnAtMillis: row.withdrawnAtMillis,
  })), form: {formId: scope.formId, title: form.title,
    versionId: scope.versionId, version: version.version},
  fieldCatalog: responseQueryFieldCatalog(version.definition),
  selectedIds: result.selectedIds,
  queryHash: query.hash, resultHash: result.resultHash};
}

/** Re-evaluates current results before acting on explicit selected IDs. */
export async function resolveFirestoreResponseIds(scope: Scope,
  input: unknown, requestedIds: string[], expectedResultHash: string) {
  const {query, form, version} = await prepare(scope, input);
  const result = await materializeResponseQuery(query,
    firestoreResponseQuerySource(scope),
    {formTitle: form.title, version: version.version});
  return resolveSelectedResponseIds(query, result, requestedIds,
    expectedResultHash);
}
