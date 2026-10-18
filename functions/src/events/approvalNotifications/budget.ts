import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash as hash} from "../../operations/durableActions";
import type {EventApprovalNotificationSettingsDocument as Settings} from
  "../../shared/generated/eventApprovalNotificationSettingsDocument";
import {validateEventApprovalNotificationBudgetDocument as validBudget} from
  "../../shared/generated/validators/eventApprovalNotificationBudgetDocument";
import type {Binding} from "./model";
/** Conservative atomic debit includes unknown/rejected attempts; never credits
 * an uncertain send. All organizers sharing an email account share its caps. */
export async function prepareBudget(
  db: Firestore,
  tx: Transaction,
  config: Settings,
  route: Binding["routeId"],
  now: number,
) {
  const email = route === "approvalEmail";
  const accountId = email ?
    "email:" + config.email!.accountId :
    route === "approvalWhatsapp" ?
      "wa:" + config.whatsapp!.connectionId :
      "sms:" + config.sms!.accountId;
  const cost = email ?
    0 :
    route === "approvalWhatsapp" ?
      config.whatsapp!.maxCostMicros :
      config.sms!.maxCostMicros;
  if (!email && cost <= 0) return null;
  const date = new Date(now).toISOString();
  const periods = [date.slice(0, 10), date.slice(0, 7)];
  const refs = periods.map((period) =>
    db
      .collection("eventApprovalNotificationBudgets")
      .doc("eab_" + hash([accountId, period])),
  );
  const snapshots = await Promise.all(refs.map((ref) => tx.get(ref)));
  const next = snapshots.map((snap, index) => {
    const old = snap.data();
    if (
      snap.exists &&
      (!validBudget(old) ||
        old.accountId !== accountId ||
        old.period !== periods[index])
    ) {
      throw new Error("Invalid message budget");
    }
    const prior = validBudget(old) ? old : null;
    return {
      accountId,
      period: periods[index],
      count: (prior?.count ?? 0) + 1,
      costMicros: (prior?.costMicros ?? 0) + cost,
      updatedAtMillis: now,
    };
  });
  const counts = email ?
    [100, 3000] :
    [config.dailyPhoneLimit, config.monthlyPhoneLimit];
  const costs = [
    config.dailyCostLimitMicros,
    config.monthlyCostLimitMicros,
  ];
  if (
    next.some(
      (value, index) =>
        value.count > counts[index] ||
        (!email && value.costMicros > costs[index]),
    )
  ) {
    return null;
  }
  return () => next.forEach((value, index) => tx.set(refs[index], value));
}
