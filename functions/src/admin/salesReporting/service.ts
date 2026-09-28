/* eslint-disable max-len */
import type {Firestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesPrincipal} from "../sales/types";
import {summarizeFunnel, validateInput, type ReportRow} from "./model";

export interface FunnelDeps {db: Firestore; now: () => Date;
  authorize: () => Promise<void>}
export async function getSalesFunnel(deps: FunnelDeps,
  principal: SalesPrincipal, raw: unknown) {
  if (!principal.uid || principal.clientId || principal.organizerIds ||
      !principal.roles.some((role) => ["admin", "adminOwner"].includes(role))) {
    throw new HttpsError("permission-denied", "Company reporting requires a current employee session.");
  }
  const now = deps.now().toISOString();
  const input = validateInput(raw, now);
  await deps.authorize();
  const report = await deps.db.runTransaction(async (tx) => {
    const bounded = async (collection: string, limit: number, since?: string) => {
      let query: FirebaseFirestore.Query = deps.db.collection(collection);
      if (since) query = query.where("changedAt", ">=", since).where("changedAt", "<=", now);
      const snap = await tx.get(query.limit(limit + 1));
      if (snap.size > limit) {
        throw new HttpsError("resource-exhausted",
          "The reviewed report limit was exceeded. No partial company totals are shown.");
      }
      return snap.docs.map((doc) => ({id: doc.id, data: doc.data()} as ReportRow));
    };
    const [accounts, opportunities, tasks, history, restrictions] = await Promise.all([
      bounded("organizerSalesAccounts", 2000), bounded("salesOpportunities", 5000),
      bounded("salesTasks", 5000), bounded("salesOpportunityStageHistory", 5000, input.since),
      bounded("salesPrivacyRestrictions", 2000),
    ]);
    return summarizeFunnel(input, now, accounts, opportunities, tasks, history,
      new Set(restrictions.map((row) => row.id)));
  }, {readOnly: true});
  await deps.authorize();
  return report;
}
