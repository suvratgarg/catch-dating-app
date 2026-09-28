/* eslint-disable max-len */
import * as admin from "firebase-admin";
import {CallableRequest, onCall} from "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from "../../shared/callableOptions";
import {checkRateLimit} from "../../shared/rateLimit";
import {currentSalesEmployee} from "../sales/callables";
import {listFitQueue, refreshFitQueue, refreshFitQueueBatch,
  type FitQueueDeps} from "./service";

const options = appCheckCallableOptionsWithLimits({concurrency: 10,
  maxInstances: 5, memory: "256MiB", timeoutSeconds: 30});

async function context(request: CallableRequest<unknown>, action: string) {
  const principal = await currentSalesEmployee(request);
  const db = admin.firestore();
  await checkRateLimit(db, principal.uid, `sales-fit-queue:${action}`,
    {maxRequests: action === "refresh.batch" ? 3 :
      action === "refresh" ? 15 : 40, windowMs: 60_000});
  const deps: FitQueueDeps = {db, now: () => new Date(),
    authorize: async () => {
      await currentSalesEmployee(request);
    }};
  return {principal, deps};
}

export const adminListSalesFitQueue = onCall(options, async (request) => {
  const {principal, deps} = await context(request, "list");
  return listFitQueue(deps, principal, request.data);
});
export const adminRefreshSalesFitQueue = onCall(options, async (request) => {
  const {principal, deps} = await context(request, "refresh");
  return refreshFitQueue(deps, principal, request.data);
});
export const adminRefreshSalesFitQueueBatch = onCall(options, async (request) => {
  const {principal, deps} = await context(request, "refresh.batch");
  return refreshFitQueueBatch(deps, principal, request.data);
});
