import {getFirestore} from "firebase-admin/firestore";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {RcsCallbackConsumer} from "./rcsCallbackConsumer";

// The consumer re-reads authenticated inbox evidence and its conflict fence;
// the trigger body is never a source of guest or delivery authority.
export const onEventAssistanceRcsCallbackCreated = onDocumentCreated({
  document: "eventAssistanceRcsCallbacks/{callbackId}", retry: true,
  timeoutSeconds: 60,
}, async (event) => {
  await new RcsCallbackConsumer(getFirestore()).consume(
    event.params.callbackId);
});
