import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from
  "../shared/callableOptions";
import {validateQueryOrganizerFormResponsesCallablePayload} from
  "../shared/generated/validators/queryOrganizerFormResponsesInput";
import {validateQueryOrganizerFormResponsesCallableResponse} from
  "../shared/generated/validators/queryOrganizerFormResponsesOutput";
import {validateCallableWithAjv} from "../shared/validation";
import {requireAuth} from "../shared/auth";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {resolveFirestoreResponseIds, runFirestoreResponseQuery} from
  "./firestoreAdapter";
import type {ResponseQueryPage} from "./firestoreAdapter";

interface QueryCallableDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
}

const defaultDeps: QueryCallableDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
};

/**
 * Both keys need explicit RATE_LIMITS registration with these ceilings when
 * the callable is registered. Per-organizer budget is charged only after
 * manager and deletion checks so outsiders cannot exhaust another Host's
 * interactive query allowance.
 */
const actorQueryRateLimit = {maxRequests: 12, windowMs: 60_000};
const organizerQueryRateLimit = {maxRequests: 60, windowMs: 60_000};

function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new HttpsError("invalid-argument",
      "Response query must be an object.");
  }
  return value as Record<string, unknown>;
}

function scopeId(value: unknown): string {
  if (typeof value !== "string" ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(value)) {
    throw new HttpsError("invalid-argument",
      "Response query scope is invalid.");
  }
  return value;
}

function scopeOf(db: FirebaseFirestore.Firestore, actorUid: string,
  query: unknown) {
  const data = object(query);
  return {db, actorUid, organizerId: scopeId(data.organizerId),
    formId: scopeId(data.formId), versionId: scopeId(data.versionId)};
}

async function authorizeAndRateLimit(deps: QueryCallableDeps,
  scope: ReturnType<typeof scopeOf>): Promise<void> {
  const {db, actorUid, organizerId} = scope;
  await deps.checkRateLimit(db, actorUid, "queryOrganizerFormResponses",
    actorQueryRateLimit);
  await requireOrganizerManager({db, actorUid, organizerId});
  if ((await db.collection("deletedUsers").doc(actorUid).get()).exists) {
    throw new HttpsError("permission-denied",
      "Deleted accounts cannot query form responses.");
  }
  await deps.checkRateLimit(db, organizerId,
    "queryOrganizerFormResponsesOrg", organizerQueryRateLimit);
}

/**
 * Callable handler for a bare HostResponseQueryRequest.toJson() payload.
 * The exported endpoint enforces App Check and bounded execution options.
 */
export async function queryOrganizerFormResponsesHandler(
  request: CallableRequest<unknown>,
  deps: QueryCallableDeps = defaultDeps,
): Promise<ResponseQueryPage> {
  const actorUid = requireAuth(request);
  const db = deps.firestore();
  const input = validateCallableWithAjv(request,
    validateQueryOrganizerFormResponsesCallablePayload);
  const scope = scopeOf(db, actorUid, input);
  await authorizeAndRateLimit(deps, scope);
  const result = await runFirestoreResponseQuery(scope, input);
  if (!validateQueryOrganizerFormResponsesCallableResponse(result)) {
    throw new HttpsError("internal", "Response query returned invalid data.");
  }
  return result;
}

/**
 * Write boundaries call this with the reviewed query and selected IDs.
 * Returned IDs are only a current selection, not mutation authority: the
 * write must check its own source, identity, revision and destination policy.
 */
export async function resolveOrganizerResponseSelectionHandler(
  request: CallableRequest<unknown>,
  deps: QueryCallableDeps = defaultDeps,
): Promise<{responseIds: string[]; resultHash: string}> {
  const actorUid = requireAuth(request);
  const data = object(request.data);
  if (Object.keys(data).some((key) => ![
    "query", "requestedIds", "expectedResultHash"].includes(key)) ||
      !Array.isArray(data.requestedIds) ||
      data.requestedIds.length > 5_000 ||
      data.requestedIds.some((id) => typeof id !== "string" ||
        !/^[A-Za-z0-9_-]{1,128}$/u.test(id)) ||
      typeof data.expectedResultHash !== "string" ||
      !/^[a-f0-9]{64}$/u.test(data.expectedResultHash)) {
    throw new HttpsError("invalid-argument",
      "Response selection is invalid.");
  }
  const db = deps.firestore();
  const scope = scopeOf(db, actorUid, data.query);
  await authorizeAndRateLimit(deps, scope);
  const responseIds = await resolveFirestoreResponseIds(scope, data.query,
    data.requestedIds, data.expectedResultHash);
  return {responseIds, resultHash: data.expectedResultHash};
}

export const queryOrganizerFormResponses = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 10,
    concurrency: 4}),
  (request) => queryOrganizerFormResponsesHandler(request),
);
