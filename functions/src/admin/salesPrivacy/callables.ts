/* eslint-disable max-len */
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from "../../shared/callableOptions";
import {checkRateLimit} from "../../shared/rateLimit";
import {currentSalesEmployee} from "../sales/callables";
import type {SalesPrincipal} from "../sales/types";
import {applySalesPrivacyBatch, getSalesPrivacyCase,
  previewSalesPrivacyPlan, restrictSalesOrganizer,
  reviewSalesPrivacyPlan, reviewSalesPrivacyPolicy,
  type PrivacyDeps} from "./service";

const limits = {concurrency: 6, maxInstances: 3,
  memory: "512MiB" as const, timeoutSeconds: 120};

async function context(request: CallableRequest<unknown>, action: string):
Promise<{principal: SalesPrincipal; deps: PrivacyDeps}> {
  const principal = await currentSalesEmployee(request);
  if (!principal.roles.includes("adminOwner") || principal.clientId) {
    throw new HttpsError("permission-denied",
      "Current Admin Owner authority is required for Sales privacy.");
  }
  const db = admin.firestore();
  await checkRateLimit(db, principal.uid, `sales-privacy:${action}`,
    {maxRequests: 12, windowMs: 60_000});
  return {principal, deps: {db, now: () => new Date(),
    authorizeOwner: async () => {
      const current = await currentSalesEmployee(request);
      if (!current.roles.includes("adminOwner") || current.clientId) {
        throw new HttpsError("permission-denied",
          "Current Admin Owner authority is required for Sales privacy.");
      }
    }}};
}

function privacyCallable(action: string, handler: (deps: PrivacyDeps,
  principal: SalesPrincipal, input: unknown) => Promise<unknown>) {
  return onCall(appCheckCallableOptionsWithLimits(limits), async (request) => {
    const {deps, principal} = await context(request, action);
    return handler(deps, principal, request.data);
  });
}

export const adminReviewSalesPrivacyPolicy = privacyCallable("policy.review",
  reviewSalesPrivacyPolicy);
export const adminRestrictSalesOrganizer = privacyCallable("organizer.restrict",
  restrictSalesOrganizer);
export const adminPreviewSalesPrivacyPlan = privacyCallable("plan.preview",
  previewSalesPrivacyPlan);
export const adminReviewSalesPrivacyPlan = privacyCallable("plan.review",
  reviewSalesPrivacyPlan);
export const adminApplySalesPrivacyBatch = privacyCallable("batch.apply",
  applySalesPrivacyBatch);
export const adminGetSalesPrivacyCase = privacyCallable("case.get",
  getSalesPrivacyCase);
