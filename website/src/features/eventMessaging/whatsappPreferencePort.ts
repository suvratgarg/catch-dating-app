import {getEventWhatsappPreference, listEventWhatsappPreferences, setEventWhatsappPreference} from "../../firebase";
import type {EventWhatsappPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventWhatsappPreferenceCallableResponse";
import type {SetEventWhatsappPreferenceCallablePayload as Submission} from "../../shared/contracts/generated/setEventWhatsappPreferenceCallablePayload";
import {eventWhatsappMessagingCopy as copy} from "../../content/eventMessaging";
import {whatsappPreferenceOptions, whatsappPreferenceResponse, whatsappReviewKey} from "./whatsappPreferenceModel";
import type {SenderPreferencePort} from "./senderPreferencePort";

export const whatsappPreferencePort: SenderPreferencePort<Response, Submission> = {
  channel: "whatsapp", copy,
  list: async (scope) => whatsappPreferenceOptions(await listEventWhatsappPreferences(scope), scope, scope.cursor),
  read: async (scope) => whatsappPreferenceResponse(await getEventWhatsappPreference(scope), scope, "read"),
  write: async (input) => whatsappPreferenceResponse(await setEventWhatsappPreference(input), input, "mutation"),
  reviewKey: whatsappReviewKey,
  submission: (scope, requestId, view, decision) => {
    if (decision === "grant" && !view.sender) throw new Error(copy.senderUnavailable);
    return {...scope, requestId, expectedRevision: view.revision, decision: decision === "grant" ? {
      kind: "grant", copyVersion: view.consent.version,
      reviewHash: view.reviewHash,
      senderHash: view.sender!.bindingHash, stopRecordHash: view.stopRecordHash,
    } : {kind: "revoke"}};
  },
};
