import * as admin from "firebase-admin";
import type {Firestore} from "firebase-admin/firestore";
import {defineSecret} from "firebase-functions/params";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {hostServerMeasurementEnabled} from "./consentHttp";
import {deliverHostMetaLead, HOST_DELIVERY_COLLECTION} from "./metaDelivery";
import {createHostMetaSender} from "./metaSender";

// A separate reviewed release is required after test-event acceptance.
export const hostMetaDeliveryEnabled = false;
const metaToken = defineSecret("CATCH_HOST_META_CONVERSIONS_TOKEN");

/** Twenty sequential, ten-second sends fit below the 300-second invocation.
 * The compound due-work index is a deployment prerequisite. Reservations and
 * live consent checks remain inside deliverHostMetaLead; query snapshots are
 * never authority to send. Counts contain no identifiers or provider bodies. */
export async function dispatchDueHostMetaLeads(input: {
  enabled: boolean;
  db: Firestore;
  send: Parameters<typeof deliverHostMetaLead>[0]["send"];
  now?: () => number;
}): Promise<{examined: number; accepted: number; unknown: number}> {
  const counts = {examined: 0, accepted: 0, unknown: 0};
  if (!input.enabled) return counts;
  const now = input.now ?? Date.now;
  const due = await input.db.collection(HOST_DELIVERY_COLLECTION)
    .where("status", "in", ["pending", "sending"])
    .where("nextAttemptAt", "<=", now())
    .orderBy("nextAttemptAt", "asc").limit(20).get();
  for (const row of due.docs) {
    const outcome = await deliverHostMetaLead({db: input.db, eventId: row.id,
      enabled: true, send: input.send, now});
    counts.examined++;
    if (outcome === "accepted") counts.accepted++;
    if (outcome === "unknown") counts.unknown++;
  }
  return counts;
}

export const dispatchHostAcquisitionMeta = onSchedule({
  schedule: "every 1 minutes", region: "asia-south1", maxInstances: 1,
  timeoutSeconds: 300, retryCount: 0, secrets: [metaToken],
}, async () => {
  if (!hostServerMeasurementEnabled || !hostMetaDeliveryEnabled) return;
  const token = metaToken.value();
  if (!token || /[\r\n]/u.test(token)) {
    throw new Error("Host acquisition credential unavailable.");
  }
  await dispatchDueHostMetaLeads({enabled: true, db: admin.firestore(),
    send: createHostMetaSender({token: () => token})});
});
