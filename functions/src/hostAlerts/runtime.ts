import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {defineBoolean, defineSecret, defineString} from
  "firebase-functions/params";
import {ResendEmailProvider} from "../email/resendEmailProvider";
import {dispatchHostAlerts, enqueueHostAlert} from "./delivery";

// The credential binding and start cutoff need a reviewed runtime release.
// These functions are deliberately not exported by the deployment index yet.
const enabled = defineBoolean("CATCH_HOST_OPERATOR_ALERTS_ENABLED",
  {default: false});
const start = defineString("CATCH_HOST_OPERATOR_ALERTS_SINCE",
  {default: ""});
const token = defineSecret("CATCH_HOST_OPERATOR_ALERTS_RESEND_KEY");
function configuration() {
  const since = Date.parse(start.value());
  return {enabled: enabled.value() && Number.isSafeInteger(since) && since > 0,
    since};
}

export const onHostApplicationAccepted = onDocumentCreated({
  document: "salesInboundIntents/{intentId}", region: "asia-south1",
  retry: true, maxInstances: 2,
}, async (event) => {
  const config = configuration();
  if (!config.enabled) return;
  await enqueueHostAlert({...config, db: admin.firestore(),
    intentId: event.params.intentId});
});

export const dispatchHostApplicationAlerts = onSchedule({
  schedule: "every 1 minutes", region: "asia-south1", maxInstances: 1,
  timeoutSeconds: 300, retryCount: 0, secrets: [token],
}, async () => {
  const config = configuration();
  if (!config.enabled) return;
  await dispatchHostAlerts({...config, db: admin.firestore(),
    provider: new ResendEmailProvider(token.value())});
});
