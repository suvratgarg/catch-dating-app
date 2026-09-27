import * as admin from "firebase-admin";
import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {appCheckCallableOptionsWithLimits,
  appCheckCallableOptionsWithSecrets} from "../shared/callableOptions";
import {Identity} from "./model";
import {DemoDeps, adminGetBlueprint, adminGetCapability, adminGetInvitation,
  adminListBlueprints, adminListInvitations, advanceSession,
  getPreview, getSession, issueInvitation, reviewBlueprint,
  revokeInvitation, saveBlueprint, startSession,
  withdrawBlueprint} from "./service";

const demoGrantKey = defineSecret("SALES_DEMO_GRANT_KEY");
function deps(): DemoDeps {
  return {db: admin.firestore(), now: () => new Date(),
    getUser: (uid) => admin.auth().getUser(uid),
    tokenKey: () => Buffer.from(demoGrantKey.value(), "base64url")};
}
function identity(request: CallableRequest<unknown>): Identity {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in to try this demo.");
  }
  return {uid: request.auth.uid, token: request.auth.token};
}

/** Public read-only projection; link unfurls never materialize a session. */
export const getSalesDemoPreview = onCall(
  appCheckCallableOptionsWithLimits({maxInstances: 10}),
  async (request) => getPreview(deps(), request.data));
export const startSalesDemo = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) =>
    startSession(deps(), identity(request), request.data));
export const getSalesDemoSession = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) =>
    getSession(deps(), identity(request), request.data));
export const advanceSalesDemo = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) =>
    advanceSession(deps(), identity(request), request.data));
export const adminSaveSalesDemoBlueprint = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) => saveBlueprint(deps(), identity(request), request.data));
export const adminReviewSalesDemoBlueprint = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) => reviewBlueprint(deps(), identity(request), request.data));
export const adminWithdrawSalesDemoBlueprint = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) => withdrawBlueprint(deps(), identity(request),
    request.data));
export const adminIssueSalesDemoInvitation = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) => issueInvitation(deps(), identity(request), request.data));
export const adminRevokeSalesDemoInvitation = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) => revokeInvitation(deps(), identity(request), request.data));
export const adminGetSalesDemoBlueprint = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) => adminGetBlueprint(deps(), identity(request),
    request.data));
export const adminGetSalesDemoInvitation = onCall(
  appCheckCallableOptionsWithSecrets([demoGrantKey], {maxInstances: 10}),
  async (request) => adminGetInvitation(deps(), identity(request),
    request.data));
export const adminGetSalesDemoCapability = onCall(
  appCheckCallableOptionsWithLimits({maxInstances: 10}),
  async (request) => adminGetCapability(deps(), identity(request),
    request.data));
export const adminListSalesDemoBlueprints = onCall(
  appCheckCallableOptionsWithLimits({maxInstances: 10}),
  async (request) => adminListBlueprints(deps(), identity(request),
    request.data));
export const adminListSalesDemoInvitations = onCall(
  appCheckCallableOptionsWithLimits({maxInstances: 10}),
  async (request) => adminListInvitations(deps(), identity(request),
    request.data));

/** Bounded cleanup of expired synthetic state and trial receipts. */
export const expireSalesDemos = onSchedule({schedule: "every 60 minutes",
  timeZone: "UTC", maxInstances: 1}, async () => {
  const db = admin.firestore();
  const cutoff = new Date().toISOString();
  for (const collection of ["salesDemoSessions", "salesDemoReceipts"]) {
    const expired = await db.collection(collection)
      .where("expiresAt", "<=", cutoff).limit(200).get();
    if (expired.empty) continue;
    const batch = db.batch();
    expired.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }
});
