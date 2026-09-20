import {getEventAssistanceSmsPreference, listEventSmsPreferences, setEventAssistanceSmsPreference} from "../../firebase";
import type {EventAssistanceSmsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventAssistanceSmsPreferenceCallableResponse";
import type {SetEventAssistanceSmsPreferenceCallablePayload as Payload} from "../../shared/contracts/generated/setEventAssistanceSmsPreferenceCallablePayload";
import {eventMessagingCopy as copy} from "../../content/eventMessaging";
import {smsPreferenceOptions, smsPreferenceResponse} from "./smsPreferenceModel";
import type {SenderPreferencePort} from "./senderPreferencePort";

type Submission = Payload & {senderId: string};
const invalidReceipt = () => new Error("SMS preference decision was not confirmed");
export const smsPreferencePort: SenderPreferencePort<Response, Submission> = {
  channel: "sms", copy,
  list: async (scope) => smsPreferenceOptions(await listEventSmsPreferences(scope), scope, scope.cursor),
  read: async (scope) => smsPreferenceResponse(await getEventAssistanceSmsPreference(scope), scope, "read"),
  write: async (input) => {
    const result = smsPreferenceResponse(await setEventAssistanceSmsPreference(input), input, "mutation");
    // A successful write must confirm this command. A replay returns current state.
    if (result.outcome === "applied" && (result.view.revision !== (input.expectedRevision ?? 0) + 1 ||
        (input.decision.kind === "grant" ? result.view.preference !== "enabled" :
          !["disabled", "notSet"].includes(result.view.preference)))) {
      throw invalidReceipt();
    }
    return result;
  },
  reviewKey: (view) => view.reviewHash,
  submission: (scope, requestId, view, decision) => ({...scope, requestId,
    expectedRevision: view.revision, expectedReviewHash: view.reviewHash,
    decision: decision === "grant" ? {kind: "grant", copyVersion: view.consent.version} : {kind: "revoke"}}),
};
