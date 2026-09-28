import {reconcilePrivateEventSeats as reconcileSeats} from
  "./seatReconciliation";
import type {PagedSeatBootstrapDeps} from "../seatMigrationPaged";
import {validateReconcilePrivateEventSeatsCallablePayload} from
  "../../shared/generated/validators/reconcilePrivateEventSeatsInput";
import {validatePrivateSeatReconciliationCallableResponse} from
  "../../shared/generated/validators/privateSeatReconciliationOutput";
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
import {readPrivateEventReleaseReadiness, PrivateEventReleaseReadiness} from
  "../../shared/privateEventReleaseConfig";

import {setEventPublication as setPublication} from "./publication";
import {validateSetEventPublicationCallablePayload} from
  "../../shared/generated/validators/setEventPublicationInput";
import {validateEventPublicationCallableResponse} from
  "../../shared/generated/validators/eventPublicationOutput";

export interface SetupCallableDependencies {
  seatAuth?: PagedSeatBootstrapDeps["auth"];
  nowMillis?: () => number;
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  service: (db: FirebaseFirestore.Firestore,
    readiness?: PrivateEventReleaseReadiness) => ProgressiveSetupDependencies;
}

const defaultDeps: SetupCallableDependencies = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  service: (db, readiness) => ({
    db,
    privacyMigrationReady: () => readiness?.privacy === true,
    freshEventSeatWritersReady: () => readiness?.seatWriters === true,
    timestampFromMillis: admin.firestore.Timestamp.fromMillis,
    serverTimestamp: admin.firestore.FieldValue.serverTimestamp,
    assertBasicsEditable: assertPrivateEventBasicsEditable,
  }),
};

// The server fetches rollout authority after auth and payload validation. A
// missing or failed read closes production before any Firestore access.
async function requireProductionPrivacyReadiness(
  deps: SetupCallableDependencies
): Promise<PrivateEventReleaseReadiness | undefined> {
  if (deps === defaultDeps) {
    const readiness = await readPrivateEventReleaseReadiness();
    if (readiness.privacy) return readiness;
    throw new HttpsError("failed-precondition",
      "Private event setup is not yet available.");
  }
  return undefined;
}

/** Authenticated entry point; transaction owns final manager authority. */
export async function createPrivateEventSetupHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateCreatePrivateEventSetupCallablePayload);
  const readiness = await requireProductionPrivacyReadiness(deps);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "createPrivateEventSetup");
  return createSetup({actorUid, command, deps: deps.service(db, readiness)});
}

/** Keeps mutation request identity intact through the service receipt. */
export async function updatePrivateEventBasicsHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateUpdatePrivateEventBasicsCallablePayload);
  const readiness = await requireProductionPrivacyReadiness(deps);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "updatePrivateEventBasics");
  return updateBasics({actorUid, command, deps: deps.service(db, readiness)});
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
  const readiness = await requireProductionPrivacyReadiness(deps);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "updatePrivateEventPreferences");
  return updatePreferences({actorUid, command, deps: deps.service(db,
    readiness)});
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
  const readiness = await requireProductionPrivacyReadiness(deps);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "updatePrivateEventDetails");
  const result = await updateDetails({actorUid, command,
    deps: deps.service(db, readiness)});
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

/** Changes visibility; registration and guest state stay separate. */
export async function setEventPublicationHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateSetEventPublicationCallablePayload);
  const readiness = await requireProductionPrivacyReadiness(deps);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "setEventPublication");
  const result = await setPublication({actorUid, command,
    deps: deps.service(db, readiness)});
  if (!validateEventPublicationCallableResponse(result)) {
    throw new HttpsError("internal", "Invalid event publication result.");
  }
  return result;
}
export const setEventPublication = onCall(appCheckCallableOptions,
  (request) => setEventPublicationHandler(request));


/** Admission settings remain in the current flow while existing guests are
 * reconciled in bounded pages. The client retains the exact command on retry.
 */
export async function reconcilePrivateEventSeatsHandler(
  request: CallableRequest<unknown>, deps = defaultDeps
) {
  const actorUid = requireAuth(request);
  const command = validateCallableWithAjv(request,
    validateReconcilePrivateEventSeatsCallablePayload);
  const readiness = await requireProductionPrivacyReadiness(deps);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "reconcilePrivateEventSeats");
  const {discard, ...settings} = command;
  const result = await reconcileSeats({actorUid, command: settings, discard,
    deps: {...deps.service(db, readiness), auth: deps.seatAuth ?? admin.auth(),
      nowMillis: deps.nowMillis ?? Date.now}});
  if (!validatePrivateSeatReconciliationCallableResponse(result)) {
    throw new HttpsError("internal", "Invalid guest reconciliation result.");
  }
  return result;
}
export const reconcilePrivateEventSeats = onCall(appCheckCallableOptions,
  (request) => reconcilePrivateEventSeatsHandler(request));
