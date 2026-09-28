import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from
  "../../shared/callableOptions";
import {checkRateLimit} from "../../shared/rateLimit";
import {currentSalesEmployee} from "../sales/callables";
import {parseLinkIntakeToSalesInput} from "./schemas";
import {linkOrganizerIntakeToSales} from "./service";

export async function adminLinkOrganizerIntakeToSalesHandler(
  request: CallableRequest<unknown>,
): Promise<Record<string, unknown>> {
  const principal = await currentSalesEmployee(request);
  const input = parseLinkIntakeToSalesInput(request.data);
  const db = admin.firestore();
  await checkRateLimit(db, principal.uid, "adminLinkOrganizerIntakeToSales", {
    maxRequests: 30, windowMs: 60_000,
  });
  return linkOrganizerIntakeToSales(db, principal, input,
    new Date().toISOString(), async () => {
      const current = await currentSalesEmployee(request);
      if (current.uid !== principal.uid) {
        throw new HttpsError("permission-denied",
          "Sales employee identity changed during Intake review.");
      }
    });
}

export const adminLinkOrganizerIntakeToSales = onCall(
  appCheckCallableOptionsWithLimits({concurrency: 20, maxInstances: 10,
    memory: "256MiB", timeoutSeconds: 30}),
  adminLinkOrganizerIntakeToSalesHandler,
);
