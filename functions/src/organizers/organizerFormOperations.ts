import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from
  "../shared/callableOptions";
import {normalizePayloadStrings} from
  "../shared/callablePayloadNormalization";
import {requireAuth} from "../shared/auth";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import type {ListOrganizerFormResponsesCallablePayload} from
  "../shared/generated/listOrganizerFormResponsesCallablePayload";
import type {ListOrganizerFormResponsesCallableResponse} from
  "../shared/generated/listOrganizerFormResponsesCallableResponse";
import type {GetOrganizerFormResponseDetailCallablePayload} from
  "../shared/generated/getOrganizerFormResponseDetailCallablePayload";
import type {GetOrganizerFormResponseDetailCallableResponse} from
  "../shared/generated/getOrganizerFormResponseDetailCallableResponse";
import type {GetOrganizerFormAnalyticsCallablePayload} from
  "../shared/generated/getOrganizerFormAnalyticsCallablePayload";
import type {GetOrganizerFormAnalyticsCallableResponse} from
  "../shared/generated/getOrganizerFormAnalyticsCallableResponse";
import type {
  OrganizerApplicationDocument,
  OrganizerContactOriginDocument,
  OrganizerFormAggregateDocument,
  OrganizerFormAssetDocument,
  OrganizerFormConversionReceiptDocument,
  OrganizerFormDocument,
  OrganizerFormResponseDocument,
  OrganizerFormShareLinkDocument,
  OrganizerFormVersionDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  validateGetOrganizerFormAnalyticsCallablePayload,
} from
  "../shared/generated/validators/getOrganizerFormAnalyticsInput";
import {
  validateGetOrganizerFormResponseDetailCallablePayload,
} from
  "../shared/generated/validators/getOrganizerFormResponseDetailInput";
import {
  validateListOrganizerFormResponsesCallablePayload,
} from
  "../shared/generated/validators/listOrganizerFormResponsesInput";

import {genericFormApplicationId} from "./organizerApplicationAccess";
import {organizerContactOriginId} from "../shared/organizerContactOrigins";

type ResponseRow = ListOrganizerFormResponsesCallableResponse["items"][number];

interface OrganizerFormOperationsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  storageBucket: () => ReturnType<ReturnType<typeof admin.storage>["bucket"]>;
  checkRateLimit: typeof checkRateLimit;
  timestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: OrganizerFormOperationsDeps = {
  firestore: () => admin.firestore(),
  storageBucket: () => admin.storage().bucket(),
  checkRateLimit,
  timestamp: () => admin.firestore.Timestamp.now(),
};

const maxResponseScan = 500;
const responseScanPageSize = 100;
const privacyThreshold = 5;
const downloadLifetimeMs = 15 * 60 * 1000;

interface ResponseCursor {
  version: 1;
  organizerId: string;
  filterHash: string;
  submittedAtMillis: number;
  responseId: string;
}

/** Returns a bounded, cursor-paginated organizer response inbox. */
export async function listOrganizerFormResponsesHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormOperationsDeps = defaultDeps
): Promise<ListOrganizerFormResponsesCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    ListOrganizerFormResponsesCallablePayload
  >(
    request,
    validateListOrganizerFormResponsesCallablePayload,
    normalizeResponseListPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listOrganizerFormResponses");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const filterHash = hashJson({
    formId: data.formId,
    versionId: data.versionId,
    statuses: [...data.statuses].sort(),
    identityKinds: [...data.identityKinds].sort(),
    sourceLinkId: data.sourceLinkId,
    query: data.query?.trim().toLowerCase() ?? null,
    fromMillis: data.fromMillis,
    toMillis: data.toMillis,
  });
  const cursor = decodeResponseCursor(data.cursor, {
    organizerId: data.organizerId,
    filterHash,
  });
  const matched: FirebaseFirestore.QueryDocumentSnapshot[] = [];
  let scanned = 0;
  let lastScanned: FirebaseFirestore.QueryDocumentSnapshot | null = null;
  let hasMore = false;
  while (matched.length < data.limit && scanned < maxResponseScan) {
    let query: FirebaseFirestore.Query = db
      .collection("organizerFormResponses")
      .where("organizerId", "==", data.organizerId)
      .orderBy("submittedAt", "desc")
      .orderBy(admin.firestore.FieldPath.documentId(), "desc")
      .limit(responseScanPageSize);
    if (lastScanned) {
      query = query.startAfter(lastScanned);
    } else if (cursor) {
      query = query.startAfter(
        admin.firestore.Timestamp.fromMillis(cursor.submittedAtMillis),
        cursor.responseId
      );
    }
    const page = await query.get();
    if (page.empty) break;
    for (const doc of page.docs) {
      scanned += 1;
      lastScanned = doc;
      const response = requireDoc<OrganizerFormResponseDocument>(
        doc,
        "OrganizerFormResponseDocument"
      );
      if (matchesResponse(response, data)) matched.push(doc);
      if (matched.length === data.limit || scanned === maxResponseScan) break;
    }
    if (matched.length === data.limit || scanned === maxResponseScan) {
      hasMore = true;
      break;
    }
    if (page.size < responseScanPageSize) break;
  }
  const items = await responseRows(db, matched);
  return {
    organizerId: data.organizerId,
    items,
    nextCursor: hasMore && lastScanned ? encodeResponseCursor({
      version: 1,
      organizerId: data.organizerId,
      filterHash,
      submittedAtMillis: (lastScanned.data().submittedAt as
        FirebaseFirestore.Timestamp).toMillis(),
      responseId: lastScanned.id,
    }) : null,
  };
}

/** Returns immutable answers plus expiring private upload links. */
export async function getOrganizerFormResponseDetailHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormOperationsDeps = defaultDeps
): Promise<GetOrganizerFormResponseDetailCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    GetOrganizerFormResponseDetailCallablePayload
  >(
    request,
    validateGetOrganizerFormResponseDetailCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["organizerId", "responseId"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getOrganizerFormResponseDetail");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const responseSnap = await db.collection("organizerFormResponses")
    .doc(data.responseId).get();
  if (!responseSnap.exists) {
    throw new HttpsError("not-found", "Form response not found.");
  }
  const response = requireDoc<OrganizerFormResponseDocument>(
    responseSnap,
    "OrganizerFormResponseDocument"
  );
  if (response.organizerId !== data.organizerId) {
    throw new HttpsError("not-found", "Form response not found.");
  }
  const [formSnap, versionSnap, sourceSnap, conversionKinds] =
    await Promise.all([
      db.collection("organizerForms").doc(response.formId).get(),
      db.collection("organizerFormVersions").doc(response.versionId).get(),
      response.sourceLinkId ? db.collection("organizerFormShareLinks")
        .doc(response.sourceLinkId).get() : Promise.resolve(null),
      completedConversionKinds(db, data.responseId),
    ]);
  const form = requireOwnedForm(formSnap, data.organizerId);
  const version = requireOwnedVersion(
    versionSnap,
    data.organizerId,
    response.formId
  );
  const source = sourceSnap?.exists ?
    sourceSnap.data() as OrganizerFormShareLinkDocument : null;
  const row = responseRow(
    responseSnap.id,
    response,
    form,
    version,
    source?.label ?? null,
    conversionKinds
  );
  const questions = new Map(version.definition.sections.flatMap((section) =>
    section.questions).map((question) => [question.questionId, question]));
  const assetIds = response.answerSnapshots.flatMap((snapshot) => {
    const question = questions.get(snapshot.questionId);
    return question && (question.kind === "file" ||
      question.kind === "signature") && Array.isArray(snapshot.answer) ?
      snapshot.answer.filter((value): value is string =>
        typeof value === "string") : [];
  });
  const assetSnaps = assetIds.length === 0 ? [] : await db.getAll(
    ...assetIds.map((assetId) =>
      db.collection("organizerFormAssets").doc(assetId))
  );
  const assets = new Map(assetSnaps.filter((snap) => snap.exists).map((snap) =>
    [snap.id, snap.data() as OrganizerFormAssetDocument]));
  const expiresAtMillis = deps.timestamp().toMillis() + downloadLifetimeMs;
  const signedUrls = new Map<string, string>();
  await Promise.all([...assets.entries()].map(async ([assetId, asset]) => {
    if (asset.organizerId !== data.organizerId ||
        asset.draftId !== response.draftId || asset.status !== "ready") return;
    const [url] = await deps.storageBucket().file(asset.storagePath)
      .getSignedUrl({action: "read", expires: expiresAtMillis});
    signedUrls.set(assetId, url);
  }));
  const applicationId = genericFormApplicationId(data.responseId);
  const [applicationSnap, originSnap] = await Promise.all([
    db.collection("organizerApplications").doc(applicationId).get(),
    db.collection("organizerContactOrigins").doc(organizerContactOriginId({
      organizerId: data.organizerId, sourceKind: "hostForm",
      sourceEntityKind: "hostFormResponse", sourceEntityId: data.responseId,
    })).get(),
  ]);
  const application = applicationSnap.data() as
    OrganizerApplicationDocument | undefined;
  const origin = originSnap.data(
  ) as OrganizerContactOriginDocument | undefined;
  return {
    applicationId: application?.organizerId === data.organizerId ?
      applicationId : null,
    contactId: origin?.organizerId === data.organizerId ?
      origin.currentContactId : null,
    response: row,
    answers: response.answerSnapshots.map((snapshot) => {
      const question = questions.get(snapshot.questionId);
      if (!question) {
        throw new HttpsError(
          "failed-precondition",
          "The immutable response version is incomplete."
        );
      }
      const answerAssetIds = Array.isArray(snapshot.answer) ?
        snapshot.answer.filter((value): value is string =>
          assets.has(value)) : [];
      return {
        ...snapshot,
        privacyClass: question.privacyClass,
        hostPresentation: question.hostPresentation,
        origin: response.status === "withdrawn" ? "revoked" :
          response.identity.origin,
        assetDownloads: answerAssetIds.flatMap((assetId) => {
          const asset = assets.get(assetId);
          const downloadUrl = signedUrls.get(assetId);
          return asset && downloadUrl && asset.sizeBytes ? [{
            assetId,
            fileName: asset.originalFileName,
            contentType: asset.contentType,
            sizeBytes: asset.sizeBytes,
            downloadUrl,
            expiresAtMillis,
          }] : [];
        }),
      };
    }),
    consentVersion: response.consentVersion,
    completionMillis: response.completionMillis,
  };
}

/** Reads only precomputed version/question aggregates and source counters. */
export async function getOrganizerFormAnalyticsHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormOperationsDeps = defaultDeps
): Promise<GetOrganizerFormAnalyticsCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    GetOrganizerFormAnalyticsCallablePayload
  >(
    request,
    validateGetOrganizerFormAnalyticsCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["organizerId", "formId"],
      nullableStringFields: ["versionId"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getOrganizerFormAnalytics");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const formSnap = await db.collection("organizerForms").doc(data.formId).get();
  const form = requireOwnedForm(formSnap, data.organizerId);
  const versionId = data.versionId ?? form.activeVersionId;
  if (!versionId) {
    throw new HttpsError(
      "failed-precondition",
      "Publish this form before viewing analytics."
    );
  }
  const [versionSnap, aggregateSnap, sourceSnap] = await Promise.all([
    db.collection("organizerFormVersions").doc(versionId).get(),
    db.collection("organizerFormAggregates")
      .where("organizerId", "==", data.organizerId)
      .where("formId", "==", data.formId)
      .where("versionId", "==", versionId)
      .get(),
    db.collection("organizerFormShareLinks")
      .where("organizerId", "==", data.organizerId)
      .where("formId", "==", data.formId)
      .limit(200)
      .get(),
  ]);
  const version = requireOwnedVersion(
    versionSnap,
    data.organizerId,
    data.formId
  );
  const aggregates = aggregateSnap.docs.map((doc) =>
    doc.data() as OrganizerFormAggregateDocument);
  const funnel = aggregates.find((item) => item.scope === "version") ??
    emptyAggregate(data.organizerId, data.formId, versionId, deps.timestamp());
  const questionById = new Map(version.definition.sections.flatMap((section) =>
    section.questions).map((question) => [question.questionId, question]));
  const questions = aggregates.filter((item) => item.scope === "question" &&
      item.questionId && questionById.has(item.questionId))
    .map((item) => {
      const question = questionById.get(item.questionId!)!;
      const canAggregate = item.submissions >= privacyThreshold &&
        question.privacyClass !== "sensitive" &&
        !["shortText", "longText", "email", "phone", "signature", "file"]
          .includes(question.kind);
      return {
        questionId: question.questionId,
        label: question.label,
        kind: question.kind,
        privacyClass: question.privacyClass,
        responseCount: item.submissions,
        choiceCounts: canAggregate ? item.choiceCounts : [],
        numericCount: canAggregate ? item.numericCount : 0,
        numericSum: canAggregate ? item.numericSum : 0,
        numericMin: canAggregate ? item.numericMin : null,
        numericMax: canAggregate ? item.numericMax : null,
      };
    });
  return {
    organizerId: data.organizerId,
    formId: data.formId,
    versionId,
    version: version.version,
    opens: funnel.opens,
    starts: funnel.starts,
    submissions: funnel.submissions,
    withdrawals: funnel.withdrawals,
    completionRate: funnel.starts === 0 ? 0 :
      Math.min(1, funnel.submissions / funnel.starts),
    medianCompletionMillis: medianCompletion(funnel),
    questions,
    sources: sourceSnap.docs.map((doc) => {
      const source = doc.data() as OrganizerFormShareLinkDocument;
      return {
        sourceLinkId: doc.id,
        label: source.label,
        opens: source.openCount,
        starts: source.startCount,
        submissions: source.submissionCount,
      };
    }),
    privacyThreshold,
  };
}

function matchesResponse(
  response: OrganizerFormResponseDocument,
  data: ListOrganizerFormResponsesCallablePayload
): boolean {
  if (data.formId && response.formId !== data.formId) return false;
  if (data.versionId && response.versionId !== data.versionId) return false;
  if (data.statuses.length && !data.statuses.includes(response.status)) {
    return false;
  }
  if (data.identityKinds.length &&
      !data.identityKinds.includes(response.identityKind)) return false;
  if (data.sourceLinkId && response.sourceLinkId !== data.sourceLinkId) {
    return false;
  }
  const submittedAt = response.submittedAt.toMillis();
  if (data.fromMillis !== null && submittedAt < data.fromMillis) return false;
  if (data.toMillis !== null && submittedAt > data.toMillis) return false;
  const query = data.query?.trim().toLowerCase();
  if (query && ![
    response.identity.displayName,
    response.identity.email,
    response.identity.phoneE164,
    response.identity.searchName,
  ].some((value) => value?.toLowerCase().includes(query))) return false;
  return true;
}

async function responseRows(
  db: FirebaseFirestore.Firestore,
  snapshots: FirebaseFirestore.QueryDocumentSnapshot[]
): Promise<ResponseRow[]> {
  if (snapshots.length === 0) return [];
  const responses = snapshots.map((snap) =>
    requireDoc<OrganizerFormResponseDocument>(
      snap,
      "OrganizerFormResponseDocument"
    ));
  const formIds = [...new Set(responses.map((item) => item.formId))];
  const versionIds = [...new Set(responses.map((item) => item.versionId))];
  const sourceIds = [...new Set(responses.flatMap((item) =>
    item.sourceLinkId ? [item.sourceLinkId] : []))];
  const [formSnaps, versionSnaps, sourceSnaps, conversionsByResponseId] =
    await Promise.all([
      db.getAll(...formIds.map((id) =>
        db.collection("organizerForms").doc(id))),
      db.getAll(...versionIds.map((id) =>
        db.collection("organizerFormVersions").doc(id))),
      sourceIds.length ? db.getAll(...sourceIds.map((id) =>
        db.collection("organizerFormShareLinks").doc(id))) : [],
      completedConversionKindsForResponses(
        db,
        snapshots.map((snap) => snap.id)
      ),
    ]);
  const forms = new Map(formSnaps.filter((snap) => snap.exists).map((snap) =>
    [snap.id, snap.data() as OrganizerFormDocument]));
  const versions = new Map(versionSnaps.filter((snap) => snap.exists)
    .map((snap) => [snap.id, snap.data() as OrganizerFormVersionDocument]));
  const sources = new Map(sourceSnaps.filter((snap) => snap.exists)
    .map((snap) =>
      [snap.id, snap.data() as OrganizerFormShareLinkDocument]));
  return snapshots.flatMap((snap, index) => {
    const response = responses[index];
    const form = forms.get(response.formId);
    const version = versions.get(response.versionId);
    if (!form || !version) return [];
    return [responseRow(
      snap.id,
      response,
      form,
      version,
      response.sourceLinkId ? sources.get(response.sourceLinkId)?.label ??
        null : null,
      conversionsByResponseId.get(snap.id) ?? []
    )];
  });
}

function responseRow(
  responseId: string,
  response: OrganizerFormResponseDocument,
  form: OrganizerFormDocument,
  version: OrganizerFormVersionDocument,
  sourceLabel: string | null,
  conversionKinds: ResponseRow["conversionKinds"]
): ResponseRow {
  const questions = new Map(version.definition.sections.flatMap((section) =>
    section.questions).map((question) => [question.questionId, question]));
  return {
    responseId,
    formId: response.formId,
    formTitle: form.title,
    versionId: response.versionId,
    version: version.version,
    status: response.status,
    identityKind: response.identityKind,
    identity: response.identity,
    sourceLinkId: response.sourceLinkId,
    sourceLabel,
    submittedAtMillis: response.submittedAt.toMillis(),
    withdrawnAtMillis: response.withdrawnAt?.toMillis() ?? null,
    highlights: response.answerSnapshots.flatMap((snapshot) => {
      const question = questions.get(snapshot.questionId);
      return question && question.hostPresentation !== "detailOnly" ? [{
        questionId: snapshot.questionId,
        label: snapshot.label,
        answer: snapshot.answer,
      }] : [];
    }).slice(0, 12),
    conversionKinds,
  };
}

async function completedConversionKinds(
  db: FirebaseFirestore.Firestore,
  responseId: string
): Promise<ResponseRow["conversionKinds"]> {
  const snapshot = await db.collection("organizerFormConversionReceipts")
    .where("responseId", "==", responseId)
    .where("status", "==", "completed")
    .limit(4)
    .get();
  return snapshot.docs.map((doc) =>
    (doc.data() as OrganizerFormConversionReceiptDocument).kind);
}

async function completedConversionKindsForResponses(
  db: FirebaseFirestore.Firestore,
  responseIds: string[]
): Promise<Map<string, ResponseRow["conversionKinds"]>> {
  const byResponseId = new Map<string, ResponseRow["conversionKinds"]>();
  for (let offset = 0; offset < responseIds.length; offset += 30) {
    const ids = responseIds.slice(offset, offset + 30);
    if (ids.length === 0) continue;
    const snapshot = await db.collection("organizerFormConversionReceipts")
      .where("responseId", "in", ids)
      .where("status", "==", "completed")
      .get();
    for (const doc of snapshot.docs) {
      const receipt = doc.data() as OrganizerFormConversionReceiptDocument;
      const kinds = byResponseId.get(receipt.responseId) ?? [];
      if (!kinds.includes(receipt.kind)) kinds.push(receipt.kind);
      byResponseId.set(receipt.responseId, kinds);
    }
  }
  return byResponseId;
}

function requireOwnedForm(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  organizerId: string
): OrganizerFormDocument {
  if (!snapshot.exists) throw new HttpsError("not-found", "Form not found.");
  const form = requireDoc<OrganizerFormDocument>(
    snapshot,
    "OrganizerFormDocument"
  );
  if (form.organizerId !== organizerId) {
    throw new HttpsError("not-found", "Form not found.");
  }
  return form;
}

function requireOwnedVersion(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  organizerId: string,
  formId: string
): OrganizerFormVersionDocument {
  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Form version not found.");
  }
  const version = requireDoc<OrganizerFormVersionDocument>(
    snapshot,
    "OrganizerFormVersionDocument"
  );
  if (version.organizerId !== organizerId || version.formId !== formId) {
    throw new HttpsError("not-found", "Form version not found.");
  }
  return version;
}

function emptyAggregate(
  organizerId: string,
  formId: string,
  versionId: string,
  now: FirebaseFirestore.Timestamp
): OrganizerFormAggregateDocument {
  return {
    organizerId,
    formId,
    versionId,
    scope: "version",
    questionId: null,
    questionLabel: null,
    questionKind: null,
    privacyClass: null,
    opens: 0,
    starts: 0,
    submissions: 0,
    withdrawals: 0,
    completionMillisTotal: 0,
    completionBuckets: [],
    choiceCounts: [],
    numericCount: 0,
    numericSum: 0,
    numericMin: null,
    numericMax: null,
    updatedAt: now,
  };
}

function medianCompletion(
  aggregate: OrganizerFormAggregateDocument
): number | null {
  if (aggregate.submissions === 0 || aggregate.completionBuckets.length === 0) {
    return null;
  }
  const midpoint = Math.ceil(aggregate.submissions / 2);
  let cumulative = 0;
  for (const bucket of [...aggregate.completionBuckets]
    .sort((left, right) => left.upperBoundMillis - right.upperBoundMillis)) {
    cumulative += bucket.count;
    if (cumulative >= midpoint) return bucket.upperBoundMillis;
  }
  return aggregate.completionBuckets.at(-1)?.upperBoundMillis ?? null;
}

function normalizeResponseListPayload(value: unknown): unknown {
  return normalizePayloadStrings(value, {
    stringFields: ["organizerId"],
    nullableStringFields: [
      "formId",
      "versionId",
      "sourceLinkId",
      "query",
      "cursor",
    ],
  });
}

function hashJson(value: unknown): string {
  return createHash("sha256").update(JSON.stringify(value)).digest("hex");
}

function encodeResponseCursor(cursor: ResponseCursor): string {
  return Buffer.from(JSON.stringify(cursor)).toString("base64url");
}

function decodeResponseCursor(
  value: string | null,
  expected: Pick<ResponseCursor, "organizerId" | "filterHash">
): ResponseCursor | null {
  if (!value) return null;
  try {
    const parsed = JSON.parse(Buffer.from(value, "base64url").toString()) as
      ResponseCursor;
    if (parsed.version !== 1 || parsed.organizerId !== expected.organizerId ||
        parsed.filterHash !== expected.filterHash ||
        !Number.isInteger(parsed.submittedAtMillis) || !parsed.responseId) {
      throw new Error("invalid cursor");
    }
    return parsed;
  } catch {
    throw new HttpsError("invalid-argument", "Response cursor is invalid.");
  }
}

const managerCallableLimits = {
  concurrency: 20,
  maxInstances: 20,
  timeoutSeconds: 60,
} as const;

export const listOrganizerFormResponses = onCall(
  appCheckCallableOptionsWithLimits(managerCallableLimits),
  (request) => listOrganizerFormResponsesHandler(request)
);

export const getOrganizerFormResponseDetail = onCall(
  appCheckCallableOptionsWithLimits(managerCallableLimits),
  (request) => getOrganizerFormResponseDetailHandler(request)
);

export const getOrganizerFormAnalytics = onCall(
  appCheckCallableOptionsWithLimits(managerCallableLimits),
  (request) => getOrganizerFormAnalyticsHandler(request)
);
