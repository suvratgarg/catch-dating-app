import {HttpsError} from "firebase-functions/v2/https";
import type {PrivateEventSetupCallableResponse} from
  "../../shared/generated/privateEventSetupCallableResponse";
import {validateGetPrivateEventSetupCallablePayload} from
  "../../shared/generated/validators/getPrivateEventSetupInput";
import {validatePrivateEventSetupCallableResponse} from
  "../../shared/generated/validators/privateEventSetupOutput";
import {projectEventPreferences} from "./preferences";
import {authorizeSetupManager} from "./service";

/** Reads a manager projection without decoding a fully configured event. */
export async function getPrivateEventSetup(params: {
  actorUid: string;
  command: unknown;
  db: FirebaseFirestore.Firestore;
}): Promise<PrivateEventSetupCallableResponse> {
  const {actorUid, db} = params;
  if (!actorUid) throw new HttpsError("unauthenticated", "Sign in first.");
  const command = params.command;
  if (!validateGetPrivateEventSetupCallablePayload(command)) {
    throw new HttpsError("invalid-argument", "Invalid event setup request.");
  }
  return db.runTransaction(async (tx) => {
    const [organizer, deleted, eventSnap, preferencesSnap] = await Promise.all([
      tx.get(db.collection("organizers").doc(command.organizerId)),
      tx.get(db.collection("deletedUsers").doc(actorUid)),
      tx.get(db.collection("events").doc(command.eventId)),
      tx.get(db.collection("eventSetupPreferences").doc(command.eventId)),
    ]);
    authorizeSetupManager(organizer, deleted, actorUid);
    const event = eventSnap.data();
    if (!event || event.organizerId !== command.organizerId ||
        event.clubId !== command.organizerId) {
      throw new HttpsError("not-found", "Event not found.");
    }
    if (event.publicationState !== "private") {
      throw new HttpsError("failed-precondition",
        "Use the published event editor for this event.");
    }
    const result: unknown = {
      eventId: command.eventId,
      organizerId: command.organizerId,
      setupRevision: event.setupRevision,
      eventPreferences: projectEventPreferences(preferencesSnap.data(),
        command.organizerId, command.eventId),
      name: event.name,
      city: {cityId: event.eventCityId, marketId: event.eventMarketId},
      localDate: event.eventLocalDate,
      localStartTime: event.eventLocalStartTime,
      timezone: event.eventTimezone,
      startTimeMillis: event.startTime?.toMillis?.(),
      publicationState: event.publicationState,
      status: event.status,
      setupDefaults: event.setupDefaults,
      detailsConfigured: event.endTime !== undefined ||
        event.meetingLocation !== undefined ||
        event.eventSuccessPlanId !== undefined,
    };
    if (!validatePrivateEventSetupCallableResponse(result)) {
      throw new HttpsError("failed-precondition",
        "Event setup is incomplete or invalid. Contact support.");
    }
    return result as PrivateEventSetupCallableResponse;
  });
}
