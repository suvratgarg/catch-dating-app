import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
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
import {updatePrivateEventPreferences as updatePreferences} from
  "./preferences";
import {validateUpdatePrivateEventPreferencesCallablePayload} from
  "../../shared/generated/validators/updatePrivateEventPreferencesInput";
import {getPrivateEventSetup as readSetup} from "./readModel";

import {assertPrivateEventBasicsEditable} from "./commitments";
import {listPrivateEventSetups as listSetups} from "./listPrivateEventSetups";
import {validateListPrivateEventSetupsCallablePayload} from
  "../../shared/generated/validators/listPrivateEventSetupsInput";
import {validatePrivateEventSetupListCallableResponse} from
  "../../shared/generated/validators/privateEventSetupListOutput";

import {updatePrivateEventDetails as updateDetails} from "./details";
import {validateUpdatePrivateEventDetailsCallablePayload} from
  "../../shared/generated/validators/updatePrivateEventDetailsInput";
import {validatePrivateEventSetupMutationCallableResponse} from
  "../../shared/generated/validators/privateEventSetupMutationOutput";

import {listOfferEventTargets as listOfferTargets} from
  "./listOfferEventTargets";
import {validateListOfferEventTargetsCallablePayload} from
  "../../shared/generated/validators/listOfferEventTargetsInput";
import {validateOfferEventTargetListCallableResponse} from
  "../../shared/generated/validators/offerEventTargetListOutput";

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
    assertBasicsEditable: assertPrivateEventBasicsEditable,
  }),
};

// This compatibility release still permits legacy public event lists. Never
// create or mutate a private event through a production callable until the
// published-only rules and clients are deployed together. Injectable service
// dependencies remain available only to isolated tests.
function assertProductionPrivateSetupClosed(deps: SetupCallableDependencies) {
  if (deps === defaultDeps) {
    throw new HttpsError("failed-precondition",
      "Private event setup is not yet available.");
  }
}

/** Authenticated entry point; transaction owns final manager authority. */
export async function createPrivateEventSetupHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateCreatePrivateEventSetupCallablePayload);
  assertProductionPrivateSetupClosed(deps);
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
  assertProductionPrivateSetupClosed(deps);
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

/** Saves a reviewed event-local settings snapshot in private storage. */
export async function updatePrivateEventPreferencesHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateUpdatePrivateEventPreferencesCallablePayload);
  assertProductionPrivateSetupClosed(deps);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "updatePrivateEventPreferences");
  return updatePreferences({actorUid, command, deps: deps.service(db)});
}

export const updatePrivateEventPreferences = onCall(appCheckCallableOptions,
  (request) => updatePrivateEventPreferencesHandler(request));

/** Bounded manager list that also works for basics-only private events. */
export async function listPrivateEventSetupsHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateListPrivateEventSetupsCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listPrivateEventSetups");
  const result = await listSetups({actorUid, command, db});
  if (!validatePrivateEventSetupListCallableResponse(result)) {
    throw new HttpsError("internal", "Invalid private event list response.");
  }
  return result;
}

export const listPrivateEventSetups = onCall(appCheckCallableOptions,
  (request) => listPrivateEventSetupsHandler(request));

/** Adds optional details without publishing or activating paid admission. */
export async function updatePrivateEventDetailsHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateUpdatePrivateEventDetailsCallablePayload);
  assertProductionPrivateSetupClosed(deps);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "updatePrivateEventDetails");
  const result = await updateDetails({actorUid, command,
    deps: deps.service(db)});
  if (!validatePrivateEventSetupMutationCallableResponse(result)) {
    throw new HttpsError("internal", "Invalid event setup result.");
  }
  return result;
}
export const updatePrivateEventDetails = onCall(appCheckCallableOptions,
  (request) => updatePrivateEventDetailsHandler(request));

/** Lists owned upcoming event choices; selecting never authorizes admission. */
export async function listOfferEventTargetsHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateListOfferEventTargetsCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listOfferEventTargets");
  const result = await listOfferTargets({actorUid, command, db});
  if (!validateOfferEventTargetListCallableResponse(result)) {
    throw new HttpsError("internal", "Invalid event target list response.");
  }
  return result;
}
export const listOfferEventTargets = onCall(appCheckCallableOptions,
  (request) => listOfferEventTargetsHandler(request));
