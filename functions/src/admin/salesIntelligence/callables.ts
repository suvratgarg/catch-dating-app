/* eslint-disable max-len */
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from "../../shared/callableOptions";
import {checkRateLimit} from "../../shared/rateLimit";
import {currentSalesEmployee} from "../sales/callables";
import type {SalesPrincipal} from "../sales/types";
import {getDraftJob} from "./job";
import {generateSalesOutreachDraft} from "./runtime";
import {buildOutreachInput, copyOutreachDraft, getIntelligenceCatalog,
  getIntelligenceScore, getOutreachDraft, listOutreachDrafts,
  reviewIntelligenceClause, reviewOutreachDraft,
  saveFactorAssessment,
  saveIntelligenceClause, saveIntelligencePolicy,
  saveScoreSnapshot, type IntelligenceDeps} from "./service";

const limits = {concurrency: 10, maxInstances: 5,
  memory: "256MiB" as const, timeoutSeconds: 30};

async function context(request: CallableRequest<unknown>, action: string,
  mutation: boolean): Promise<{principal: SalesPrincipal; deps: IntelligenceDeps}> {
  const principal = await currentSalesEmployee(request);
  const db = admin.firestore();
  await checkRateLimit(db, principal.uid, `sales-intelligence:${action}`,
    {maxRequests: action === "draft.generate" ? 5 : mutation ? 15 : 40,
      windowMs: 60_000});
  return {principal, deps: {db, now: () => new Date(),
    authorize: async (_principal, owner) => {
      const current = await currentSalesEmployee(request);
      if (owner && !current.roles.includes("adminOwner")) {
        throw new HttpsError("permission-denied", "Admin Owner review is required.");
      }
    }}};
}
function write(action: string, service: (deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) => Promise<unknown>) {
  return onCall(appCheckCallableOptionsWithLimits(limits), async (request) => {
    const {principal, deps} = await context(request, action, true);
    return service(deps, principal, request.data);
  });
}
function read(action: string, service: (deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) => Promise<unknown>) {
  return onCall(appCheckCallableOptionsWithLimits(limits), async (request) => {
    const {principal, deps} = await context(request, action, false);
    return service(deps, principal, request.data);
  });
}

export const adminSaveSalesIntelligencePolicy = write("policy.save", saveIntelligencePolicy);
export const adminSaveSalesFactorAssessment = write("assessment.save", saveFactorAssessment);
export const adminSaveSalesIntelligenceClause = write("clause.save", saveIntelligenceClause);
export const adminReviewSalesIntelligenceClause = write("clause.review", reviewIntelligenceClause);
export const adminSaveSalesScoreSnapshot = write("score.snapshot", saveScoreSnapshot);
export const adminReviewSalesOutreachDraft = write("draft.review", reviewOutreachDraft);
export const adminCopySalesOutreachDraft = write("draft.copy", copyOutreachDraft);
export const adminGenerateSalesOutreachDraft =
  write("draft.generate", generateSalesOutreachDraft);
export const adminGetSalesIntelligenceScore = read("score.get", getIntelligenceScore);
export const adminGetSalesIntelligenceCatalog =
  read("catalog.get", getIntelligenceCatalog);
export const adminBuildSalesOutreachInput = read("draft.input", buildOutreachInput);
export const adminGetSalesOutreachDraftJob = read("draft.job", getDraftJob);
export const adminGetSalesOutreachDraft = read("draft.get", getOutreachDraft);
export const adminListSalesOutreachDrafts = read("draft.list", listOutreachDrafts);
