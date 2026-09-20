import {getFirestore} from "firebase-admin/firestore";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {operationContentHash} from "../../operations/durableActions";
import {validateEventRuntimeParticipantDocument} from
  "../../shared/generated/validators/eventRuntimeParticipantDocument";
import {EventRuntimeRequiredDataStore} from "./runtimeRequiredDataStore";

type Store = Pick<EventRuntimeRequiredDataStore, "review" | "request">;
interface Dependencies {
  store: () => Store;
}
const defaults: Dependencies = {
  store: () => new EventRuntimeRequiredDataStore(getFirestore()),
};

/** Converts an accepted participant change into a typed system command. */
export async function requestMissingRuntimeData(
  participantId: string,
  value: unknown,
  deps: Dependencies = defaults
) {
  if (!validateEventRuntimeParticipantDocument(value)) {
    throw new HttpsError("failed-precondition",
      "Runtime participant source is invalid.");
  }
  if (participantId !== `${value.eventId}_${value.uid}`) {
    throw new HttpsError("failed-precondition",
      "Runtime participant identity is invalid.");
  }
  if (value.accessStatus !== "needsInput" || !value.eventAttendeeId) {
    return null;
  }
  const context = {mode: "live" as const, eventId: value.eventId,
    organizerId: value.organizerId};
  const store = deps.store();
  const view = await store.review(context, value.eventAttendeeId);
  const missingFieldIds = view.requiredFieldIds.filter((field) =>
    !view.completedFieldIds.includes(field));
  if (!missingFieldIds.length) return null;
  const operationId = "required-data:" + operationContentHash([
    context, value.eventAttendeeId, view.sourceHash,
    view.profileRevision, missingFieldIds,
  ]);
  return store.request({kind: "requestRequiredData", context,
    eventId: context.eventId, operationId, payload: {
      attendeeId: value.eventAttendeeId,
      fieldIds: missingFieldIds,
      expiresAt: view.validUntil,
      expectedProfileRevision: view.profileRevision,
      expectedRequestRevision: view.requestRevision,
      expectedSourceHash: view.sourceHash,
    }});
}

export const onEventRuntimeParticipantWritten = onDocumentWritten({
  document: "eventRuntimeParticipants/{participantId}",
  retry: true,
  timeoutSeconds: 60,
  maxInstances: 5,
}, async (event) => {
  if (!event.data?.after.exists) return;
  await requestMissingRuntimeData(event.params.participantId,
    event.data.after.data());
});
