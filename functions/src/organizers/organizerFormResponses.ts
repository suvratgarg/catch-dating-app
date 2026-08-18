import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {BeginOrganizerFormResponseCallablePayload} from
  "../shared/generated/beginOrganizerFormResponseCallablePayload";
import {BeginOrganizerFormResponseCallableResponse} from
  "../shared/generated/beginOrganizerFormResponseCallableResponse";
import {CreateOrganizerFormShareLinkCallablePayload} from
  "../shared/generated/createOrganizerFormShareLinkCallablePayload";
import {CreateOrganizerFormShareLinkCallableResponse} from
  "../shared/generated/createOrganizerFormShareLinkCallableResponse";
import {GetOrganizerFormShareAssetsCallablePayload} from
  "../shared/generated/getOrganizerFormShareAssetsCallablePayload";
import {GetOrganizerFormShareAssetsCallableResponse} from
  "../shared/generated/getOrganizerFormShareAssetsCallableResponse";
import {GetPublicOrganizerFormCallablePayload} from
  "../shared/generated/getPublicOrganizerFormCallablePayload";
import {GetPublicOrganizerFormCallableResponse} from
  "../shared/generated/getPublicOrganizerFormCallableResponse";
import {SaveOrganizerFormResponseDraftCallablePayload} from
  "../shared/generated/saveOrganizerFormResponseDraftCallablePayload";
import {SaveOrganizerFormResponseDraftCallableResponse} from
  "../shared/generated/saveOrganizerFormResponseDraftCallableResponse";
import {SubmitOrganizerFormResponseCallablePayload} from
  "../shared/generated/submitOrganizerFormResponseCallablePayload";
import {SubmitOrganizerFormResponseCallableResponse} from
  "../shared/generated/submitOrganizerFormResponseCallableResponse";
import {WithdrawOrganizerFormResponseCallablePayload} from
  "../shared/generated/withdrawOrganizerFormResponseCallablePayload";
import {WithdrawOrganizerFormResponseCallableResponse} from
  "../shared/generated/withdrawOrganizerFormResponseCallableResponse";
import {
  ClubDocument,
  OrganizerDocument,
  OrganizerFormDocument,
  OrganizerFormResponseDocument,
  OrganizerFormResponseDraftDocument,
  OrganizerFormShareLinkDocument,
  OrganizerFormVersionDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  validateBeginOrganizerFormResponseCallablePayload,
  validateCreateOrganizerFormShareLinkCallablePayload,
  validateGetOrganizerFormShareAssetsCallablePayload,
  validateGetPublicOrganizerFormCallablePayload,
  validateSaveOrganizerFormResponseDraftCallablePayload,
  validateSubmitOrganizerFormResponseCallablePayload,
  validateWithdrawOrganizerFormResponseCallablePayload,
} from "../shared/generated/schemaValidators";
import {appCheckCallableOptionsWithLimits} from
  "../shared/callableOptions";
import {normalizePayloadStrings} from
  "../shared/callablePayloadNormalization";
import {requireAuth} from "../shared/auth";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";

type FormDefinition = OrganizerFormVersionDocument["definition"];
type PublicFormProjection = GetPublicOrganizerFormCallableResponse;
type AnswerMap = OrganizerFormResponseDraftDocument["answers"];
type Question = FormDefinition["sections"][number]["questions"][number];

interface OrganizerFormResponseDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  timestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: OrganizerFormResponseDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  timestamp: () => admin.firestore.Timestamp.now(),
};

const responseDraftLifetimeMs = 7 * 24 * 60 * 60 * 1000;
const publicFormsOrigin = "https://catchdates.com";

/** Resolves only the active immutable definition and bounded organizer copy. */
export async function getPublicOrganizerFormHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormResponseDeps = defaultDeps
): Promise<GetPublicOrganizerFormCallableResponse> {
  const data = validateCallableWithAjv<GetPublicOrganizerFormCallablePayload>(
    request,
    validateGetPublicOrganizerFormCallablePayload,
    normalizePublicFormPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(
    db,
    request.auth?.uid ?? `public-form:${data.publicFormId}`,
    "getPublicOrganizerForm"
  );
  const resolved = await resolvePublicForm(db, data.publicFormId, deps);
  await resolveSourceLink(db, resolved.formId, data.sourceToken);
  return resolved.projection;
}

/** Starts an idempotent, version-bound response draft. */
export async function beginOrganizerFormResponseHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormResponseDeps = defaultDeps
): Promise<BeginOrganizerFormResponseCallableResponse> {
  const data = validateCallableWithAjv<
    BeginOrganizerFormResponseCallablePayload
  >(
    request,
    validateBeginOrganizerFormResponseCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["publicFormId", "requestId"],
      nullableStringFields: ["sourceToken"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(
    db,
    request.auth?.uid ?? `public-form:${data.publicFormId}`,
    "beginOrganizerFormResponse"
  );
  const resolved = await resolvePublicForm(db, data.publicFormId, deps);
  assertAcceptingResponses(resolved.projection);
  const identity = requireResponseIdentity(
    request,
    resolved.version.definition.identityPolicy
  );
  const sourceLinkId = await resolveSourceLink(
    db,
    resolved.formId,
    data.sourceToken
  );
  const draftId = deterministicId(
    "formdraft",
    resolved.formId,
    identity.uid ?? "anonymous",
    data.requestId
  );
  const draftToken = identity.uid === null ? bearerToken(
    "form-draft-token",
    resolved.formId,
    data.requestId
  ) : null;
  const draftRef = db.collection("organizerFormResponseDrafts").doc(draftId);
  const draft = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(draftRef);
    if (snapshot.exists) {
      const existing = requireDoc<OrganizerFormResponseDraftDocument>(
        snapshot,
        "OrganizerFormResponseDraftDocument"
      );
      if (existing.formId !== resolved.formId ||
          existing.versionId !== resolved.versionId ||
          existing.respondentUid !== identity.uid ||
          (draftToken !== null &&
            existing.draftTokenHash !== hashToken(draftToken))) {
        throw new HttpsError(
          "already-exists",
          "Response draft already exists."
        );
      }
      if (existing.status !== "active") {
        throw new HttpsError(
          "failed-precondition",
          "This response draft is no longer editable."
        );
      }
      if (existing.expiresAt.toMillis() <= deps.timestamp().toMillis()) {
        throw new HttpsError(
          "deadline-exceeded",
          "This response draft has expired. Start a new response."
        );
      }
      return existing;
    }
    const now = deps.timestamp();
    const created: OrganizerFormResponseDraftDocument = {
      organizerId: resolved.form.organizerId,
      formId: resolved.formId,
      versionId: resolved.versionId,
      publicFormId: resolved.form.publicFormId,
      status: "active",
      revision: 1,
      identityKind: identity.kind,
      respondentUid: identity.uid,
      draftTokenHash: draftToken === null ? null : hashToken(draftToken),
      answers: {},
      consentAccepted: false,
      consentVersion: resolved.version.definition.consent.consentVersion,
      sourceLinkId,
      createdAt: now,
      updatedAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + responseDraftLifetimeMs
      ),
      submittedResponseId: null,
    };
    tx.create(draftRef, created);
    if (sourceLinkId) {
      tx.update(db.collection("organizerFormShareLinks").doc(sourceLinkId), {
        startCount: admin.firestore.FieldValue.increment(1),
      });
    }
    return created;
  });
  return {
    draftId,
    draftToken,
    form: resolved.projection,
    revision: draft.revision,
    answers: draft.answers,
    consentAccepted: draft.consentAccepted,
    identityKind: draft.identityKind,
    expiresAtMillis: draft.expiresAt.toMillis(),
  };
}

/** Saves a complete answer snapshot under an optimistic revision guard. */
export async function saveOrganizerFormResponseDraftHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormResponseDeps = defaultDeps
): Promise<SaveOrganizerFormResponseDraftCallableResponse> {
  const data = validateCallableWithAjv<
    SaveOrganizerFormResponseDraftCallablePayload
  >(
    request,
    validateSaveOrganizerFormResponseDraftCallablePayload,
    normalizeDraftMutationPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(
    db,
    request.auth?.uid ?? `form-draft:${data.draftId}`,
    "saveOrganizerFormResponseDraft"
  );
  const draftRef = db.collection("organizerFormResponseDrafts")
    .doc(data.draftId);
  const draft = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(draftRef);
    const current = requireActiveDraft(
      snapshot,
      request,
      data.draftToken,
      deps
    );
    if (current.revision !== data.expectedRevision) {
      throw new HttpsError(
        "aborted",
        "This response changed on another tab. Reload and try again."
      );
    }
    const version = await getVersion(tx, db, current.versionId);
    validateAnswerShape(version.definition, data.answers, false);
    const now = deps.timestamp();
    const updated: OrganizerFormResponseDraftDocument = {
      ...current,
      revision: current.revision + 1,
      answers: data.answers,
      consentAccepted: data.consentAccepted,
      updatedAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + responseDraftLifetimeMs
      ),
    };
    tx.set(draftRef, updated);
    return updated;
  });
  return {
    draftId: data.draftId,
    revision: draft.revision,
    expiresAtMillis: draft.expiresAt.toMillis(),
  };
}

/** Submits one draft exactly once while retaining its immutable version. */
export async function submitOrganizerFormResponseHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormResponseDeps = defaultDeps
): Promise<SubmitOrganizerFormResponseCallableResponse> {
  const data = validateCallableWithAjv<
    SubmitOrganizerFormResponseCallablePayload
  >(
    request,
    validateSubmitOrganizerFormResponseCallablePayload,
    normalizeDraftMutationPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(
    db,
    request.auth?.uid ?? `form-draft:${data.draftId}`,
    "submitOrganizerFormResponse"
  );
  const responseId = deterministicId("formresponse", data.draftId);
  const withdrawalToken = bearerToken(
    "form-withdrawal-token",
    responseId,
    data.requestId
  );
  const draftRef = db.collection("organizerFormResponseDrafts")
    .doc(data.draftId);
  const responseRef = db.collection("organizerFormResponses")
    .doc(responseId);
  const result = await db.runTransaction(async (tx) => {
    const [draftSnap, responseSnap] = await Promise.all([
      tx.get(draftRef),
      tx.get(responseRef),
    ]);
    if (responseSnap.exists) {
      const response = requireDoc<OrganizerFormResponseDocument>(
        responseSnap,
        "OrganizerFormResponseDocument"
      );
      requireResponseAuthority(response, request, withdrawalToken);
      const version = await getVersion(tx, db, response.versionId);
      return {response, version};
    }
    const draft = requireActiveDraft(
      draftSnap,
      request,
      data.draftToken,
      deps
    );
    if (draft.revision !== data.expectedRevision) {
      throw new HttpsError(
        "aborted",
        "This response changed on another tab. Reload and try again."
      );
    }
    const [formSnap, version] = await Promise.all([
      tx.get(db.collection("organizerForms").doc(draft.formId)),
      getVersion(tx, db, draft.versionId),
    ]);
    const form = requireDoc<OrganizerFormDocument>(
      formSnap,
      "OrganizerFormDocument"
    );
    const availability = availabilityFor(form, version, deps.timestamp());
    if (availability.status !== "active") {
      throw new HttpsError("failed-precondition", availability.message);
    }
    if (!draft.consentAccepted) {
      throw new HttpsError(
        "failed-precondition",
        "Review and accept the form consent before submitting."
      );
    }
    validateAnswerShape(version.definition, draft.answers, true);
    const now = deps.timestamp();
    const response: OrganizerFormResponseDocument = {
      organizerId: draft.organizerId,
      formId: draft.formId,
      versionId: draft.versionId,
      publicFormId: draft.publicFormId,
      draftId: data.draftId,
      status: "submitted",
      identityKind: draft.identityKind,
      respondentUid: draft.respondentUid,
      withdrawalTokenHash: draft.respondentUid === null ?
        hashToken(withdrawalToken) : null,
      answers: draft.answers,
      answerSnapshots: answerSnapshots(version.definition, draft.answers),
      consentVersion: draft.consentVersion,
      sourceLinkId: draft.sourceLinkId,
      submittedAt: now,
      withdrawnAt: null,
    };
    tx.create(responseRef, response);
    tx.set(draftRef, {
      ...draft,
      status: "submitted",
      submittedResponseId: responseId,
      updatedAt: now,
    } satisfies OrganizerFormResponseDraftDocument);
    tx.update(db.collection("organizerForms").doc(draft.formId), {
      submittedResponseCount: admin.firestore.FieldValue.increment(1),
      lastResponseAt: now,
      updatedAt: now,
    });
    if (draft.sourceLinkId) {
      tx.update(
        db.collection("organizerFormShareLinks").doc(draft.sourceLinkId),
        {submissionCount: admin.firestore.FieldValue.increment(1)}
      );
    }
    return {response, version};
  });
  return responseReceipt(
    responseId,
    result.response,
    result.version,
    result.response.respondentUid === null ? withdrawalToken : null
  );
}

/** Withdraws a submitted response without deleting its audit envelope. */
export async function withdrawOrganizerFormResponseHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormResponseDeps = defaultDeps
): Promise<WithdrawOrganizerFormResponseCallableResponse> {
  const data = validateCallableWithAjv<
    WithdrawOrganizerFormResponseCallablePayload
  >(
    request,
    validateWithdrawOrganizerFormResponseCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["responseId", "requestId"],
      nullableStringFields: ["withdrawalToken"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(
    db,
    request.auth?.uid ?? `form-response:${data.responseId}`,
    "withdrawOrganizerFormResponse"
  );
  const responseRef = db.collection("organizerFormResponses")
    .doc(data.responseId);
  const response = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(responseRef);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Form response not found.");
    }
    const current = requireDoc<OrganizerFormResponseDocument>(
      snapshot,
      "OrganizerFormResponseDocument"
    );
    requireResponseAuthority(current, request, data.withdrawalToken);
    if (current.status === "withdrawn") return current;
    const now = deps.timestamp();
    const withdrawn: OrganizerFormResponseDocument = {
      ...current,
      status: "withdrawn",
      withdrawnAt: now,
    };
    tx.set(responseRef, withdrawn);
    tx.update(db.collection("organizerForms").doc(current.formId), {
      submittedResponseCount: admin.firestore.FieldValue.increment(-1),
      updatedAt: now,
    });
    return withdrawn;
  });
  return {
    responseId: data.responseId,
    status: "withdrawn",
    withdrawnAtMillis: response.withdrawnAt!.toMillis(),
  };
}

/** Creates a manager-owned source link with an opaque stable token. */
export async function createOrganizerFormShareLinkHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormResponseDeps = defaultDeps
): Promise<CreateOrganizerFormShareLinkCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    CreateOrganizerFormShareLinkCallablePayload
  >(
    request,
    validateCreateOrganizerFormShareLinkCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["organizerId", "formId", "label", "requestId"],
      nullableStringFields: ["source"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "createOrganizerFormShareLink");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const formSnap = await db.collection("organizerForms").doc(data.formId).get();
  const form = requireOwnedPublishedForm(formSnap, data.organizerId);
  const linkId = deterministicId(
    "formlink",
    data.organizerId,
    data.formId,
    actorUid,
    data.requestId
  );
  const sourceToken = linkId;
  const linkRef = db.collection("organizerFormShareLinks").doc(linkId);
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(linkRef);
    if (snapshot.exists) {
      const existing = requireDoc<OrganizerFormShareLinkDocument>(
        snapshot,
        "OrganizerFormShareLinkDocument"
      );
      if (existing.organizerId !== data.organizerId ||
          existing.formId !== data.formId || existing.label !== data.label ||
          existing.source !== data.source) {
        throw new HttpsError("already-exists", "Share link already exists.");
      }
      return;
    }
    const created: OrganizerFormShareLinkDocument = {
      organizerId: data.organizerId,
      formId: data.formId,
      publicFormId: form.publicFormId,
      label: data.label,
      source: data.source,
      tokenHash: hashToken(sourceToken),
      createdByUid: actorUid,
      createdAt: deps.timestamp(),
      openCount: 0,
      startCount: 0,
      submissionCount: 0,
    };
    tx.create(linkRef, created);
  });
  return {
    linkId,
    label: data.label,
    source: data.source,
    sourceToken,
    url: publicFormUrl(form.publicFormId, sourceToken),
  };
}

/** Returns the canonical URL and a CSP-safe hosted iframe snippet. */
export async function getOrganizerFormShareAssetsHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerFormResponseDeps = defaultDeps
): Promise<GetOrganizerFormShareAssetsCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    GetOrganizerFormShareAssetsCallablePayload
  >(
    request,
    validateGetOrganizerFormShareAssetsCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["organizerId", "formId"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getOrganizerFormShareAssets");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const formSnap = await db.collection("organizerForms").doc(data.formId).get();
  const form = requireOwnedPublishedForm(formSnap, data.organizerId);
  const canonicalUrl = publicFormUrl(form.publicFormId, null);
  const embedUrl = `${canonicalUrl}?embed=1`;
  return {
    canonicalUrl,
    embedUrl,
    embedSnippet:
      `<iframe src="${embedUrl}" title="${escapeHtml(form.title)}" ` +
      "loading=\"lazy\" style=\"width:100%;min-height:720px;border:0\" " +
      "referrerpolicy=\"strict-origin-when-cross-origin\"></iframe>",
  };
}

interface ResolvedPublicForm {
  formId: string;
  versionId: string;
  form: OrganizerFormDocument;
  version: OrganizerFormVersionDocument;
  projection: PublicFormProjection;
}

async function resolvePublicForm(
  db: FirebaseFirestore.Firestore,
  publicFormId: string,
  deps: OrganizerFormResponseDeps
): Promise<ResolvedPublicForm> {
  const snapshot = await db.collection("organizerForms")
    .where("publicFormId", "==", publicFormId)
    .limit(2)
    .get();
  if (snapshot.size !== 1) {
    throw new HttpsError("not-found", "Form not found.");
  }
  const formSnap = snapshot.docs[0];
  const form = requireDoc<OrganizerFormDocument>(
    formSnap,
    "OrganizerFormDocument"
  );
  if (!form.activeVersionId || form.publishedVersion < 1) {
    throw new HttpsError("not-found", "Form not found.");
  }
  const [versionSnap, presentation] = await Promise.all([
    db.collection("organizerFormVersions").doc(form.activeVersionId).get(),
    organizerPresentation(db, form.organizerId),
  ]);
  const version = requireDoc<OrganizerFormVersionDocument>(
    versionSnap,
    "OrganizerFormVersionDocument"
  );
  if (version.formId !== formSnap.id ||
      version.organizerId !== form.organizerId) {
    throw new HttpsError("not-found", "Form not found.");
  }
  const availability = availabilityFor(form, version, deps.timestamp());
  return {
    formId: formSnap.id,
    versionId: versionSnap.id,
    form,
    version,
    projection: {
      publicFormId,
      formId: formSnap.id,
      versionId: versionSnap.id,
      version: version.version,
      availabilityStatus: availability.status,
      availabilityMessage: availability.message,
      organizer: presentation,
      definition: definitionToWire(version.definition),
    },
  };
}

async function organizerPresentation(
  db: FirebaseFirestore.Firestore,
  organizerId: string
): Promise<PublicFormProjection["organizer"]> {
  const canonical = await db.collection("organizers").doc(organizerId).get();
  if (canonical.exists) {
    const organizer = requireDoc<OrganizerDocument>(
      canonical,
      "OrganizerDocument"
    );
    return {
      organizerId,
      name: organizer.name,
      logoUrl: organizer.logoPhoto?.url ?? organizer.profileImageUrl ??
        organizer.imageUrl,
    };
  }
  const legacy = await db.collection("clubs").doc(organizerId).get();
  if (legacy.exists) {
    const organizer = requireDoc<ClubDocument>(legacy, "ClubDocument");
    return {
      organizerId,
      name: organizer.name,
      logoUrl: organizer.logoPhoto?.url ?? organizer.profileImageUrl ??
        organizer.imageUrl,
    };
  }
  return {organizerId, name: "Organizer", logoUrl: null};
}

function availabilityFor(
  form: OrganizerFormDocument,
  version: OrganizerFormVersionDocument,
  now: FirebaseFirestore.Timestamp
): {status: PublicFormProjection["availabilityStatus"]; message: string} {
  const closedCopy = version.definition.availability.closedMessage ??
    "This form is not accepting responses right now.";
  if (form.status === "archived") {
    return {status: "archived", message: closedCopy};
  }
  if (form.status === "paused") {
    return {status: "paused", message: closedCopy};
  }
  if (form.status !== "published") {
    return {status: "unavailable", message: closedCopy};
  }
  const opensAt = version.definition.availability.opensAt;
  if (opensAt && opensAt.toMillis() > now.toMillis()) {
    return {status: "notOpen", message: closedCopy};
  }
  const closesAt = version.definition.availability.closesAt;
  if (closesAt && closesAt.toMillis() <= now.toMillis()) {
    return {status: "closed", message: closedCopy};
  }
  const limit = version.definition.availability.responseLimit;
  if (limit !== null && form.submittedResponseCount >= limit) {
    return {status: "full", message: closedCopy};
  }
  return {status: "active", message: "This form is accepting responses."};
}

function assertAcceptingResponses(projection: PublicFormProjection): void {
  if (projection.availabilityStatus !== "active") {
    throw new HttpsError(
      "failed-precondition",
      projection.availabilityMessage ??
        "This form is not accepting responses right now."
    );
  }
}

function requireResponseIdentity(
  request: CallableRequest<unknown>,
  policy: FormDefinition["identityPolicy"]
): {
  kind: OrganizerFormResponseDraftDocument["identityKind"];
  uid: string | null;
} {
  if (policy === "anonymous") return {kind: "anonymous", uid: null};
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError(
      "unauthenticated",
      "Verify your identity before starting this form."
    );
  }
  const token = (request.auth?.token ?? {}) as Record<string, unknown>;
  const phoneVerified = typeof token.phone_number === "string" &&
    token.phone_number.length > 0;
  const emailVerified = token.email_verified === true &&
    typeof token.email === "string" && token.email.length > 0;
  if (policy === "phoneVerified" && !phoneVerified) {
    throw new HttpsError("failed-precondition", "Verify your phone number.");
  }
  if (policy === "emailVerified" && !emailVerified) {
    throw new HttpsError("failed-precondition", "Verify your email address.");
  }
  if (policy === "emailOrPhoneVerified" &&
      !phoneVerified && !emailVerified) {
    throw new HttpsError(
      "failed-precondition",
      "Verify your phone number or email address."
    );
  }
  return {
    uid,
    kind: phoneVerified ? "phoneVerified" :
      emailVerified ? "emailVerified" : "catchAccount",
  };
}

function requireActiveDraft(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  request: CallableRequest<unknown>,
  draftToken: string | null,
  deps: OrganizerFormResponseDeps
): OrganizerFormResponseDraftDocument {
  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Response draft not found.");
  }
  const draft = requireDoc<OrganizerFormResponseDraftDocument>(
    snapshot,
    "OrganizerFormResponseDraftDocument"
  );
  if (draft.status !== "active") {
    throw new HttpsError(
      "failed-precondition",
      "This response draft is no longer editable."
    );
  }
  if (draft.expiresAt.toMillis() <= deps.timestamp().toMillis()) {
    throw new HttpsError("deadline-exceeded", "This response draft expired.");
  }
  if (draft.respondentUid !== null) {
    if (request.auth?.uid !== draft.respondentUid) {
      throw new HttpsError("permission-denied", "Response draft unavailable.");
    }
  } else if (!draftToken ||
      draft.draftTokenHash !== hashToken(draftToken)) {
    throw new HttpsError("permission-denied", "Response draft unavailable.");
  }
  return draft;
}

function requireResponseAuthority(
  response: OrganizerFormResponseDocument,
  request: CallableRequest<unknown>,
  withdrawalToken: string | null
): void {
  if (response.respondentUid !== null) {
    if (request.auth?.uid !== response.respondentUid) {
      throw new HttpsError("permission-denied", "Form response unavailable.");
    }
    return;
  }
  if (!withdrawalToken ||
      response.withdrawalTokenHash !== hashToken(withdrawalToken)) {
    throw new HttpsError("permission-denied", "Form response unavailable.");
  }
}

async function getVersion(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  versionId: string
): Promise<OrganizerFormVersionDocument> {
  const snapshot = await tx.get(
    db.collection("organizerFormVersions").doc(versionId)
  );
  return requireDoc<OrganizerFormVersionDocument>(
    snapshot,
    "OrganizerFormVersionDocument"
  );
}

export function validateAnswerShape(
  definition: FormDefinition,
  answers: AnswerMap,
  requireComplete: boolean
): void {
  const questions = definition.sections.flatMap((section) =>
    section.questions);
  const byId = new Map(questions.map((question) => [
    question.questionId,
    question,
  ]));
  for (const [questionId, answer] of Object.entries(answers)) {
    const question = byId.get(questionId);
    if (!question) {
      throw invalidAnswer("This form no longer recognizes one answer.");
    }
    validateQuestionAnswer(question, answer);
  }
  if (requireComplete) {
    for (const question of questions) {
      if (question.required && isEmptyAnswer(answers[question.questionId])) {
        throw invalidAnswer(`${question.label} is required.`);
      }
    }
  }
}

function validateQuestionAnswer(
  question: Question,
  answer: AnswerMap[string]
): void {
  if (isEmptyAnswer(answer)) return;
  const invalidType = () => invalidAnswer(
    `${question.label} has an invalid answer.`
  );
  switch (question.kind) {
  case "shortText":
  case "longText":
  case "date":
  case "phone":
  case "email":
  case "url":
  case "file":
  case "signature":
    if (typeof answer !== "string") throw invalidType();
    validateTextAnswer(question, answer);
    return;
  case "number":
    if (typeof answer !== "number" || !Number.isFinite(answer)) {
      throw invalidType();
    }
    if (question.validation.minNumber !== null &&
          answer < question.validation.minNumber) throw invalidType();
    if (question.validation.maxNumber !== null &&
          answer > question.validation.maxNumber) throw invalidType();
    return;
  case "boolean":
  case "acknowledgement":
    if (typeof answer !== "boolean") throw invalidType();
    if (question.required && answer !== true &&
          question.kind === "acknowledgement") throw invalidType();
    return;
  case "singleChoice": {
    if (typeof answer !== "string") throw invalidType();
    const allowed = new Set(question.options.map((option) => option.value));
    if (!allowed.has(answer)) throw invalidType();
    return;
  }
  case "multiChoice": {
    if (!Array.isArray(answer)) throw invalidType();
    const allowed = new Set(question.options.map((option) => option.value));
    if (answer.some((value) => !allowed.has(value))) throw invalidType();
    const min = question.validation.minSelections;
    const max = question.validation.maxSelections;
    if (min !== null && answer.length < min) throw invalidType();
    if (max !== null && answer.length > max) throw invalidType();
    return;
  }
  }
}

function validateTextAnswer(question: Question, answer: string): void {
  const value = answer.trim();
  const min = question.validation.minLength;
  const max = question.validation.maxLength;
  if (min !== null && value.length < min) throw invalidText(question);
  if (max !== null && value.length > max) throw invalidText(question);
  if (question.kind === "email" &&
      !/^[^\s@]+@[^\s@]+\.[^\s@]+$/u.test(value)) throw invalidText(question);
  if (question.kind === "phone" &&
      !/^\+[1-9][0-9]{7,14}$/u.test(value.replace(/[\s()-]/gu, ""))) {
    throw invalidText(question);
  }
  if (question.kind === "url") {
    try {
      const url = new URL(value);
      if (url.protocol !== "https:" && url.protocol !== "http:") {
        throw new Error("protocol");
      }
    } catch {
      throw invalidText(question);
    }
  }
  if (question.kind === "date" && !/^\d{4}-\d{2}-\d{2}$/u.test(value)) {
    throw invalidText(question);
  }
}

function invalidText(question: Question): HttpsError {
  return invalidAnswer(
    question.validation.customError ?? `${question.label} is invalid.`
  );
}

function invalidAnswer(message: string): HttpsError {
  return new HttpsError("invalid-argument", message);
}

function isEmptyAnswer(value: AnswerMap[string] | undefined): boolean {
  return value === undefined || value === null || value === "" ||
    (Array.isArray(value) && value.length === 0);
}

function answerSnapshots(
  definition: FormDefinition,
  answers: AnswerMap
): OrganizerFormResponseDocument["answerSnapshots"] {
  return definition.sections.flatMap((section) =>
    section.questions.flatMap((question) => {
      const answer = answers[question.questionId];
      return answer === undefined ? [] : [{
        questionId: question.questionId,
        key: question.key,
        label: question.label,
        kind: question.kind,
        answer,
      }];
    }));
}

function responseReceipt(
  responseId: string,
  response: OrganizerFormResponseDocument,
  version: OrganizerFormVersionDocument,
  withdrawalToken: string | null
): SubmitOrganizerFormResponseCallableResponse {
  return {
    responseId,
    formId: response.formId,
    versionId: response.versionId,
    status: response.status,
    submittedAtMillis: response.submittedAt.toMillis(),
    withdrawalToken,
    completion: version.definition.completion,
  };
}

function requireOwnedPublishedForm(
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
  if (!form.activeVersionId || form.publishedVersion < 1 ||
      form.status === "archived") {
    throw new HttpsError(
      "failed-precondition",
      "Publish this form before sharing it."
    );
  }
  return form;
}

async function resolveSourceLink(
  db: FirebaseFirestore.Firestore,
  formId: string,
  sourceToken: string | null
): Promise<string | null> {
  if (!sourceToken) return null;
  const snapshot = await db.collection("organizerFormShareLinks")
    .doc(sourceToken)
    .get();
  if (!snapshot.exists) return null;
  const link = requireDoc<OrganizerFormShareLinkDocument>(
    snapshot,
    "OrganizerFormShareLinkDocument"
  );
  if (link.formId !== formId || link.tokenHash !== hashToken(sourceToken)) {
    return null;
  }
  return snapshot.id;
}

function publicFormUrl(
  publicFormId: string,
  sourceToken: string | null
): string {
  const url = new URL(`/f/${publicFormId}/`, publicFormsOrigin);
  if (sourceToken) url.searchParams.set("source", sourceToken);
  return url.toString();
}

function deterministicId(prefix: string, ...parts: string[]): string {
  const digest = createHash("sha256")
    .update(parts.join("\u0000"))
    .digest("hex")
    .slice(0, 32);
  return `${prefix}_${digest}`;
}

function bearerToken(namespace: string, ...parts: string[]): string {
  return createHash("sha256")
    .update([namespace, ...parts].join("\u0000"))
    .digest("base64url");
}

function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

function normalizePublicFormPayload(value: unknown): unknown {
  return normalizePayloadStrings(value, {
    stringFields: ["publicFormId"],
    nullableStringFields: ["sourceToken"],
  });
}

function normalizeDraftMutationPayload(value: unknown): unknown {
  return normalizePayloadStrings(value, {
    stringFields: ["draftId", "requestId"],
    nullableStringFields: ["draftToken"],
  });
}

function definitionToWire(
  definition: FormDefinition
): PublicFormProjection["definition"] {
  return {
    ...definition,
    availability: {
      ...definition.availability,
      opensAt: timestampToWire(definition.availability.opensAt),
      closesAt: timestampToWire(definition.availability.closesAt),
    },
  };
}

function timestampToWire(
  value: FirebaseFirestore.Timestamp | null
): PublicFormProjection["definition"]["availability"]["opensAt"] {
  return value ? {
    _seconds: value.seconds,
    _nanoseconds: value.nanoseconds,
  } : null;
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/gu, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    "\"": "&quot;",
    "'": "&#39;",
  })[character]!);
}

const publicCallableLimits = {
  timeoutSeconds: 60,
  maxInstances: 40,
};

export const getPublicOrganizerForm = onCall(
  appCheckCallableOptionsWithLimits(publicCallableLimits),
  (request) => getPublicOrganizerFormHandler(request)
);

export const beginOrganizerFormResponse = onCall(
  appCheckCallableOptionsWithLimits(publicCallableLimits),
  (request) => beginOrganizerFormResponseHandler(request)
);

export const saveOrganizerFormResponseDraft = onCall(
  appCheckCallableOptionsWithLimits(publicCallableLimits),
  (request) => saveOrganizerFormResponseDraftHandler(request)
);

export const submitOrganizerFormResponse = onCall(
  appCheckCallableOptionsWithLimits(publicCallableLimits),
  (request) => submitOrganizerFormResponseHandler(request)
);

export const withdrawOrganizerFormResponse = onCall(
  appCheckCallableOptionsWithLimits(publicCallableLimits),
  (request) => withdrawOrganizerFormResponseHandler(request)
);

export const createOrganizerFormShareLink = onCall(
  appCheckCallableOptionsWithLimits(publicCallableLimits),
  (request) => createOrganizerFormShareLinkHandler(request)
);

export const getOrganizerFormShareAssets = onCall(
  appCheckCallableOptionsWithLimits(publicCallableLimits),
  (request) => getOrganizerFormShareAssetsHandler(request)
);
