import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument} from
  "../../shared/generated/firestoreAdminTypes";
import type {SetEventPublicationCallablePayload as Command} from
  "../../shared/generated/setEventPublicationCallablePayload";
import type {EventPublicationCallableResponse as Result} from
  "../../shared/generated/eventPublicationCallableResponse";
import {validateSetEventPublicationCallablePayload} from
  "../../shared/generated/validators/setEventPublicationInput";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {requireConfiguredEvent} from "../configuredEvent";
import {eventDiscoveryProjection} from "../eventDiscoveryProjection";
import {claimClubScheduleInTransaction} from "../scheduleConflicts";
import {
  assertPrivacyReady, assertReceipt, authorizeSetupManager, hashRequest,
  receiptFor, requireRevision, ProgressiveSetupDependencies,
} from "./service";

/** Publication changes visibility. Registration is enabled separately.
 * The same transaction fences manager, revision, schedule and command replay.
 * Canonical event triggers own search and next-event projection retries.
 */
export async function setEventPublication(params: {
  actorUid: string;
  command: Command;
  deps: ProgressiveSetupDependencies;
  nowMillis?: () => number;
}): Promise<Result> {
  const {actorUid, command, deps} = params;
  if (!/^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/.test(actorUid) ||
      !validateSetEventPublicationCallablePayload(command)) {
    throw new HttpsError("invalid-argument", "Invalid publication change.");
  }
  assertPrivacyReady(deps);
  const operation = command.publicationState === "published" ?
    "publish" : "unpublish";
  const hash = hashRequest(operation, command);
  const {db} = deps;
  return db.runTransaction(async (tx) => {
    const eventRef = db.collection("events").doc(command.eventId);
    const receiptRef = receiptFor(db, actorUid, command.organizerId,
      command.requestId);
    const [organizerSnap, deletedSnap, eventSnap, receiptSnap] =
      await Promise.all([
        tx.get(db.collection("organizers").doc(command.organizerId)),
        tx.get(db.collection("deletedUsers").doc(actorUid)),
        tx.get(eventRef), tx.get(receiptRef),
      ]);
    const organizer = authorizeSetupManager(organizerSnap, deletedSnap,
      actorUid);
    const event = eventSnap.data();
    if (!event || event.organizerId !== command.organizerId ||
        event.clubId !== command.organizerId) {
      throw new HttpsError("not-found", "Event not found.");
    }
    if (receiptSnap.exists) {
      const receipt = receiptSnap.data()!;
      assertReceipt(receipt, operation, actorUid, command.organizerId,
        hash, command.eventId);
      return {eventId: command.eventId,
        setupRevision: receipt.appliedRevision as number,
        publicationState: command.publicationState, replayed: true};
    }
    const revision = requireRevision(event);
    if (revision !== command.expectedSetupRevision) {
      throw new HttpsError("aborted", "Event changed. Review it again.");
    }
    if (event.publicationState !== "private" &&
        event.publicationState !== "published") {
      throw new HttpsError("failed-precondition",
        "Event publication needs review.");
    }
    if (event.publicationState === command.publicationState) {
      throw new HttpsError("failed-precondition",
        "This publication change has already been made. Refresh the event.");
    }
    const registrationRevision = event.publicRegistrationRevision ?? 0;
    if (!Number.isSafeInteger(registrationRevision) ||
        registrationRevision < 0 ||
        registrationRevision >= Number.MAX_SAFE_INTEGER) {
      throw new HttpsError("failed-precondition",
        "Event registration needs review.");
    }
    const patch: Record<string, unknown> = {
      publicationState: command.publicationState,
      setupRevision: revision + 1,
      // A stale enable command cannot reopen registration after unpublish.
      publicRegistrationEnabled: false,
      publicRegistrationMode: "closed",
      publicRegistrationRevision: registrationRevision + 1,
      updatedAt: deps.timestampFromMillis((params.nowMillis ?? Date.now)()),
    };
    if (operation === "publish") {
      const now = (params.nowMillis ?? Date.now)();
      if (!Number.isSafeInteger(now) || event.status !== "active" ||
          event.startTime?.toMillis?.() <= now ||
          organizer.appVisibility !== "discoverable") {
        throw new HttpsError("failed-precondition",
          "Publishing needs a future active event and visible organizer.");
      }
      const configured = requireConfiguredEvent(event as EventDocument);
      if (event.firstPublishedAt === undefined) {
        patch.firstPublishedAt = deps.timestampFromMillis(now);
      }
      Object.assign(patch, eventDiscoveryProjection({event: configured,
        clubLocationMarketId: event.eventMarketId}));
    }
    // Validating the target enforces the complete published schema, and the
    // private schema when unpublishing. It never invents missing terms.
    if (!validateEventDocument({...event, ...patch})) {
      throw new HttpsError("failed-precondition",
        "Complete the event details and admission terms before publishing.");
    }
    if (operation === "publish") {
      // This helper performs the final reads before writing schedule locks.
      await claimClubScheduleInTransaction(tx, db, {
        organizerId: command.organizerId, clubId: command.organizerId,
        eventId: command.eventId,
        startTimeMillis: event.startTime.toMillis(),
        endTimeMillis: event.endTime.toMillis(),
      });
    }
    tx.update(eventRef, patch);
    tx.create(receiptRef, {operation, actorUid,
      organizerId: command.organizerId, eventId: command.eventId,
      requestHash: hash, appliedRevision: revision + 1,
      createdAt: deps.serverTimestamp()});
    return {eventId: command.eventId, setupRevision: revision + 1,
      publicationState: command.publicationState, replayed: false};
  });
}
