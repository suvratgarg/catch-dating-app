import {getEventRcsPreference, listEventRcsPreferences, setEventRcsPreference} from "../../firebase";
import type {EventRcsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventRcsPreferenceOutput";
import type {SetEventRcsPreferenceCallablePayload as Submission} from "../../shared/contracts/generated/setEventRcsPreferenceInput";
import {eventRcsMessagingCopy as copy} from "../../content/eventMessaging";
import {rcsPreferenceOptions, rcsPreferenceResponse} from "./rcsPreferenceModel";
import type {SenderPreferencePort} from "./senderPreferencePort";

export const rcsPreferencePort: SenderPreferencePort<Response, Submission> = {
  channel: "rcs", copy,
  list: async (scope) => rcsPreferenceOptions(await listEventRcsPreferences(scope), scope, scope.cursor),
  read: async (scope) => rcsPreferenceResponse(await getEventRcsPreference(scope), scope, "read"),
  write: async (input) => rcsPreferenceResponse(await setEventRcsPreference(input), input, "mutation"),
  reviewKey: (view) => view.reviewHash,
  submission: (scope, requestId, view, decision) => ({...scope, requestId,
    expectedRevision: view.revision, decision: decision === "grant" ? {
      kind: "grant", copyVersion: view.consent.version, reviewHash: view.reviewHash,
    } : {kind: "revoke"}}),
};
