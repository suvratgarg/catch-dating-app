import * as admin from "firebase-admin";
import {CallableRequest, onCall} from "firebase-functions/v2/https";
import {requireAuth} from "../../shared/auth";
import {appCheckCallableOptions} from "../../shared/callableOptions";
import {checkRateLimit} from "../../shared/rateLimit";
import {validateCallableWithAjv} from "../../shared/validation";
import {validateCreatePrivateEventSetupCallablePayload} from
  "../../shared/generated/validators/createPrivateEventSetupInput";
import {validateUpdatePrivateEventBasicsCallablePayload} from
  "../../shared/generated/validators/updatePrivateEventBasicsInput";
import {validateGetPrivateEventSetupCallablePayload} from
  "../../shared/generated/validators/getPrivateEventSetupInput";
import {
  createPrivateEventSetup as createSetup,
  updatePrivateEventBasics as updateBasics,
  ProgressiveSetupDependencies,
} from "./service";
import {getPrivateEventSetup as readSetup} from "./readModel";

export interface SetupCallableDependencies {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  service: (db: FirebaseFirestore.Firestore) => ProgressiveSetupDependencies;
}

const defaultDeps: SetupCallableDependencies = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  service: (db) => ({
    db,
    // Must stay closed until canonical schema + rules/public readers migrate.
    // No request field or environment toggle can bypass this release boundary.
    privacyMigrationReady: () => false,
    timestampFromMillis: admin.firestore.Timestamp.fromMillis,
    serverTimestamp: admin.firestore.FieldValue.serverTimestamp,
  }),
};

/** Authenticated entry point; transaction owns final manager authority. */
export async function createPrivateEventSetupHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateCreatePrivateEventSetupCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "createPrivateEventSetup");
  return createSetup({actorUid, command, deps: deps.service(db)});
}

/** Keeps mutation request identity intact through the service receipt. */
export async function updatePrivateEventBasicsHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateUpdatePrivateEventBasicsCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "updatePrivateEventBasics");
  return updateBasics({actorUid, command, deps: deps.service(db)});
}

/** Returns only a manager-authorized whitelist of saved setup fields. */
export async function getPrivateEventSetupHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateGetPrivateEventSetupCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "getPrivateEventSetup");
  return readSetup({actorUid, command, db});
}

export const createPrivateEventSetup = onCall(appCheckCallableOptions,
  (request) => createPrivateEventSetupHandler(request));
export const updatePrivateEventBasics = onCall(appCheckCallableOptions,
  (request) => updatePrivateEventBasicsHandler(request));
export const getPrivateEventSetup = onCall(appCheckCallableOptions,
  (request) => getPrivateEventSetupHandler(request));
