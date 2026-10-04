import type {ValidateFunction} from "ajv";
import {validateCallableWithAjv} from "../shared/validation";
import {validateRegisterSalesPartnerCallablePayload} from "../shared/generated/validators/registerSalesPartnerInput";
import {validateNominateSalesOrganizerCallablePayload} from "../shared/generated/validators/nominateSalesOrganizerInput";
import {validateGetSalesPartnerWorkspaceCallablePayload} from "../shared/generated/validators/getSalesPartnerWorkspaceInput";
import {validateDecideSalesPartnerAssignmentCallablePayload} from "../shared/generated/validators/decideSalesPartnerAssignmentInput";
import {validateAdminAssignSalesPartnerCallablePayload} from "../shared/generated/validators/adminAssignSalesPartnerInput";
import {validateAdminRevokeSalesPartnerAccessCallablePayload} from "../shared/generated/validators/adminRevokeSalesPartnerAccessInput";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {currentSalesEmployee} from "../admin/sales/callables";
import {adminRolesFromToken} from "../admin/adminAuth";
import type {PartnerActor, PartnerDeps} from "./model";
import {assignPartner, decideAssignment, getPartnerWorkspace,
  nominateOrganizer, registerPartner, revokePartnerAccess} from "./service";

export async function currentPartnerActor(request: CallableRequest<unknown>,
  getUser = (uid: string) => admin.auth().getUser(uid)): Promise<PartnerActor> {
  const uid = requireAuth(request);
  const user = await getUser(uid);
  const authTime = request.auth?.token.auth_time;
  const validAfter = user.tokensValidAfterTime ? Date.parse(user.tokensValidAfterTime) : 0;
  if (user.disabled || typeof authTime !== "number" || !Number.isSafeInteger(authTime) ||
      !Number.isFinite(validAfter) || authTime * 1000 < validAfter) {
    throw new HttpsError("permission-denied", "Partner session was revoked; sign in again.");
  }
  return {uid, roles: adminRolesFromToken(user.customClaims)};
}
function callable(action: string, employee: boolean, validator: ValidateFunction,
  service: (deps: PartnerDeps, actor: PartnerActor, payload: unknown) => Promise<unknown>) {
  return onCall(appCheckCallableOptionsWithLimits({concurrency: 10, maxInstances: 5,
    memory: "256MiB", timeoutSeconds: 30}), async (request) => {
    const payload = validateCallableWithAjv(request, validator);
    const actor = await (employee ? currentSalesEmployee(request) : currentPartnerActor(request));
    const db = admin.firestore();
    await checkRateLimit(db, actor.uid, `partner:${action}`, {maxRequests: 20, windowMs: 60000});
    return service({db, now: () => new Date(), checkAuth: async (expected, staff) => {
      const current = await (staff ? currentSalesEmployee(request) : currentPartnerActor(request));
      if (current.uid !== expected.uid) throw new HttpsError("permission-denied", "Partner identity changed.");
    }}, actor, payload);
  });
}
export const registerSalesPartner = callable("register", false, validateRegisterSalesPartnerCallablePayload, registerPartner);
export const nominateSalesOrganizer = callable("nominate", false, validateNominateSalesOrganizerCallablePayload, nominateOrganizer);
export const getSalesPartnerWorkspace = callable("workspace", false, validateGetSalesPartnerWorkspaceCallablePayload, getPartnerWorkspace);
export const decideSalesPartnerAssignment = callable("assignment.decide", false, validateDecideSalesPartnerAssignmentCallablePayload, decideAssignment);
export const adminAssignSalesPartner = callable("assign", true, validateAdminAssignSalesPartnerCallablePayload, assignPartner);
export const adminRevokeSalesPartnerAccess = callable("revoke", true, validateAdminRevokeSalesPartnerAccessCallablePayload, revokePartnerAccess);
