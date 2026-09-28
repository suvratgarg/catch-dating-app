
import * as admin from "firebase-admin";
import {onCall} from "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from "../../shared/callableOptions";
import {checkRateLimit} from "../../shared/rateLimit";
import {currentSalesEmployee} from "../sales/callables";
import {getSalesFunnel} from "./service";

export const adminGetSalesFunnelReport = onCall(
  appCheckCallableOptionsWithLimits({concurrency: 5, maxInstances: 3,
    memory: "256MiB", timeoutSeconds: 60}), async (request) => {
    const principal = await currentSalesEmployee(request);
    const db = admin.firestore();
    await checkRateLimit(db, principal.uid, "sales-funnel-report",
      {maxRequests: 4, windowMs: 60000});
    return getSalesFunnel({db, now: () => new Date(), authorize: async () => {
      await currentSalesEmployee(request);
    }}, principal, request.data);
  });
