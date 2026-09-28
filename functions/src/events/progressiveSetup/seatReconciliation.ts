import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument} from
  "../../shared/generated/firestoreAdminTypes";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {validateUpdatePrivateEventDetailsCallablePayload} from
  "../../shared/generated/validators/updatePrivateEventDetailsInput";
import {projectManagerEventSetupDefaults} from
  "../../organizers/eventSetupDefaults/service";
import {eventSetupDefaultsDependencies} from
  "../../organizers/eventSetupDefaults/dependencies";
import {canonicalJson} from "../eventSetupPreferences/resolve";
import {advanceEventSeatLedgerMigration, PagedSeatBootstrapDeps,
  PagedSeatBootstrapCommand, SeatMigrationProgress} from
  "../seatMigrationPaged";
import type {UpdatePrivateEventDetailsCommand} from "./details";
import {eventListingTermsPatch} from "./listingTerms";
import {assertPrivacyReady, assertReceipt, authorizeSetupManager,
  hashRequest, receiptFor, requireRevision, ProgressiveSetupDependencies,
  ProgressiveSetupResult} from "./service";

export interface SeatReconciliationDependencies extends
  ProgressiveSetupDependencies {
  auth: PagedSeatBootstrapDeps["auth"];
  nowMillis: () => number;
}

export type PrivateSeatReconciliationResult =
  {kind: "progress"; progress: SeatMigrationProgress} |
  {kind: "complete"; receipt: ProgressiveSetupResult};

/** The journaled admission-settings command owns every resumable page.
 * Reviewed missing terms and the normal details receipt become visible only
 * in the same transaction that activates the reconciled seat ledger.
 */
export async function reconcilePrivateEventSeats(params: {
  actorUid: string;
  command: UpdatePrivateEventDetailsCommand;
  deps: SeatReconciliationDependencies;
  pageBudget?: number;
}): Promise<PrivateSeatReconciliationResult> {
  const {actorUid, command, deps} = params;
  if (!/^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/.test(actorUid)) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
  if (!validateUpdatePrivateEventDetailsCallablePayload(command) ||
      !command.details.admissionTerms ||
      Object.keys(command.details).length !== 1) {
    throw new HttpsError("invalid-argument",
      "Review admission settings separately before reconciling guests.");
  }
  assertPrivacyReady(deps);
  if (deps.freshEventSeatWritersReady?.() !== true) {
    throw new HttpsError("failed-precondition",
      "Seat accounting is not ready for this event.");
  }
  const {db} = deps;
  const hash = hashRequest("details", command);
  const reviewedRequestHash = hashRequest("details", {actorUid, command});
  const eventRef = db.collection("events").doc(command.eventId);
  const receiptRef = receiptFor(db, actorUid, command.organizerId,
    command.requestId);
  const runRef = db.collection("eventSeatMigrationRuns").doc(command.eventId);
  const authorize = async (tx: FirebaseFirestore.Transaction) => {
    const [organizerSnap, deletedSnap, eventSnap] = await Promise.all([
      tx.get(db.collection("organizers").doc(command.organizerId)),
      tx.get(db.collection("deletedUsers").doc(actorUid)), tx.get(eventRef),
    ]);
    const organizer = authorizeSetupManager(organizerSnap, deletedSnap,
      actorUid);
    const event = eventSnap.data();
    if (!event || event.organizerId !== command.organizerId ||
        event.clubId !== command.organizerId) {
      throw new HttpsError("not-found", "Event not found.");
    }
    return {organizer, event};
  };
  const resultFor = (raw: Record<string, unknown>): ProgressiveSetupResult => {
    assertReceipt(raw, "details", actorUid, command.organizerId, hash,
      command.eventId);
    return {eventId: command.eventId,
      setupRevision: raw.appliedRevision as number, replayed: true};
  };
  const prepare: NonNullable<PagedSeatBootstrapDeps["prepareReviewedEvent"]> =
    async ({tx, event}) => {
      const {organizer} = await authorize(tx);
      const [defaultsSnap, receiptSnap, runSnap] = await Promise.all([
        tx.get(db.collection("organizerEventSetupDefaults")
          .doc(command.organizerId)), tx.get(receiptRef), tx.get(runRef),
      ]);
      if (receiptSnap.exists) {
        resultFor(receiptSnap.data()!);
        throw new HttpsError("failed-precondition",
          "Admission settings were already saved. Reload the event.");
      }
      if (!validateEventDocument(event) ||
          event.publicationState !== "private" ||
          event.publicRegistrationEnabled !== false ||
          event.status !== "active") {
        throw new HttpsError("failed-precondition",
          "Only active private events can be reconciled here.");
      }
      if (requireRevision(event) !== command.expectedSetupRevision) {
        throw new HttpsError("aborted", "Event setup changed. Reload it.");
      }
      const defaults = projectManagerEventSetupDefaults(command.organizerId,
        organizer, defaultsSnap.data(), eventSetupDefaultsDependencies(db));
      if (!runSnap.exists &&
          defaults.preferencesHash !== command.reviewedDefaultsHash) {
        throw new HttpsError("aborted",
          "Organizer defaults changed. Review them before saving.");
      }
      const termsPatch = eventListingTermsPatch(
        event as unknown as EventDocument, command.details.admissionTerms!);
      // A migration may fill missing choices, never rewrite an existing guest
      // commitment or weaken an existing admission policy.
      for (const key of ["capacityLimit", "priceInPaise", "currency",
        "eventPolicy", "constraints"] as const) {
        if (event[key] !== undefined &&
            canonicalJson(event[key]) !== canonicalJson(termsPatch[key])) {
          throw new HttpsError("failed-precondition",
            "Keep existing admission settings while reconciling guests.");
        }
      }
      const revision = command.expectedSetupRevision + 1;
      return {patch: {...termsPatch, setupRevision: revision},
        finish: () => {
          // Timestamp transforms belong to the write, not the candidate
          // EventDocument that the migration validates before activation.
          tx.update(eventRef, {updatedAt: deps.serverTimestamp()});
          tx.create(receiptRef, {operation: "details", actorUid,
            organizerId: command.organizerId, eventId: command.eventId,
            requestHash: hash, appliedRevision: revision,
            createdAt: deps.serverTimestamp()});
        }};
    };
  const initial = await db.runTransaction(async (tx) => {
    await authorize(tx);
    const [runSnap, receiptSnap] = await Promise.all([
      tx.get(runRef), tx.get(receiptRef),
    ]);
    const prior = receiptSnap.exists ? resultFor(receiptSnap.data()!) : null;
    const run = runSnap.data();
    if (run && (run.eventId !== command.eventId ||
        run.organizerId !== command.organizerId ||
        run.reviewedRequestHash !== reviewedRequestHash)) {
      throw new HttpsError("failed-precondition",
        "Resume the original guest reconciliation request.");
    }
    // A normal details save may already have completed this exact command.
    if (prior && !run) return {prior, migration: null};
    const migration: PagedSeatBootstrapCommand = {
      eventId: command.eventId, organizerId: command.organizerId,
      migrationRevision: run?.migrationRevision ?? 1,
      asOfMillis: run?.asOfMillis ?? deps.nowMillis(), reviewedRequestHash,
    };
    return {prior, migration};
  });
  if (!initial.migration) return {kind: "complete", receipt: initial.prior!};
  const progress = await advanceEventSeatLedgerMigration({
    command: initial.migration, pageBudget: params.pageBudget,
    deps: {db, auth: deps.auth,
      allWritersIntegrated: deps.freshEventSeatWritersReady,
      authorizeTransaction: async (tx) => {
        await authorize(tx);
      },
      prepareReviewedEvent: prepare},
  });
  // Do not skip bounded cleanup merely because the final receipt exists.
  if (progress.phase !== "complete") return {kind: "progress", progress};
  const receipt = await db.runTransaction(async (tx) => {
    await authorize(tx);
    const saved = (await tx.get(receiptRef)).data();
    if (!saved) {
      throw new HttpsError("internal",
        "Reconciled admission settings have no receipt.");
    }
    return {...resultFor(saved), replayed: initial.prior !== null};
  });
  return {kind: "complete", receipt};
}
