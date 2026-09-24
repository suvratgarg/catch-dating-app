import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventFormatSnapshot, OrganizerEventVenueDocument} from
  "../../shared/generated/firestoreAdminTypes";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {requireDoc} from "../../shared/validation";
import {EVENT_MAX_DURATION_MINUTES} from "../../shared/businessRules";
import {organizerEventVenueDocumentId,
  assertOrganizerEventVenueSource} from "../organizerEventVenues";
import {canonicalJson} from "../eventSetupPreferences/resolve";
import {projectManagerEventSetupDefaults} from
  "../../organizers/eventSetupDefaults/service";
import {eventSetupDefaultsDependencies} from
  "../../organizers/eventSetupDefaults/dependencies";
import {assertPrivateEventBasicsEditable} from "./commitments";
import {assertPrivacyReady, authorizeSetupManager, receiptFor,
  requireRevision, ProgressiveSetupDependencies,
  ProgressiveSetupResult} from "./service";

type Decision<T> = {mode: "set"; value: T} | {mode: "clear"};
type Inheritable<T> = Decision<T> | {mode: "inherit"};

export interface UpdatePrivateEventDetailsCommand {
  organizerId: string;
  eventId: string;
  requestId: string;
  expectedSetupRevision: number;
  /** GET manager defaults.preferencesHash, never a client-computed hash. */
  reviewedDefaultsHash: string;
  details: {
    durationMinutes?: Inheritable<number>;
    venue?: Inheritable<{name: string}>;
    eventFormat?: Decision<EventFormatSnapshot>;
  };
}

const ID = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/;
const REQUEST_ID = /^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$/;

function validateCommand(command: UpdatePrivateEventDetailsCommand): void {
  if (!command || !ID.test(command.organizerId) ||
      !ID.test(command.eventId) || !REQUEST_ID.test(command.requestId) ||
      !Number.isSafeInteger(command.expectedSetupRevision) ||
      command.expectedSetupRevision < 1 ||
      !/^[a-f0-9]{64}$/.test(command.reviewedDefaultsHash) ||
      !command.details || typeof command.details !== "object" ||
      Array.isArray(command.details) ||
      Object.keys(command.details).length === 0 ||
      Object.keys(command.details).some((key) =>
        !["durationMinutes", "venue", "eventFormat"].includes(key))) {
    throw new HttpsError("invalid-argument", "Invalid event details.");
  }
  for (const [key, decision] of Object.entries(command.details)) {
    if (!decision || typeof decision !== "object" ||
        !["set", "clear", "inherit"].includes(decision.mode) ||
        (key === "eventFormat" && decision.mode === "inherit") ||
        (decision.mode === "set" && decision.value === undefined) ||
        (decision.mode !== "set" && "value" in decision)) {
      throw new HttpsError("invalid-argument", "Invalid detail decision.");
    }
  }
}

function duration(value: unknown): number {
  if (!Number.isInteger(value) || (value as number) < 15 ||
      (value as number) > EVENT_MAX_DURATION_MINUTES) {
    throw new HttpsError("invalid-argument", "Invalid event duration.");
  }
  return value as number;
}

function venueName(value: unknown): string {
  if (!value || typeof value !== "object" ||
      Object.keys(value).join(",") !== "name" ||
      typeof (value as {name?: unknown}).name !== "string") {
    throw new HttpsError("invalid-argument", "Invalid event venue.");
  }
  const name = (value as {name: string}).name.trim();
  if (!name || name.length > 240) {
    throw new HttpsError("invalid-argument", "Invalid event venue.");
  }
  return name;
}

function requestHash(command: UpdatePrivateEventDetailsCommand): string {
  return createHash("sha256").update(canonicalJson(["details", command]))
    .digest("hex");
}

/** Saves optional private details on the same canonical events/{id} record. */
export async function updatePrivateEventDetails(params: {
  actorUid: string;
  command: UpdatePrivateEventDetailsCommand;
  deps: ProgressiveSetupDependencies;
}): Promise<ProgressiveSetupResult> {
  const {actorUid, command, deps} = params;
  if (!ID.test(actorUid)) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
  validateCommand(command);
  assertPrivacyReady(deps);
  const {db} = deps;
  const eventRef = db.collection("events").doc(command.eventId);
  const receiptRef = receiptFor(db, actorUid, command.organizerId,
    command.requestId);
  const hash = requestHash(command);
  return db.runTransaction(async (tx) => {
    const [organizerSnap, deletedSnap, eventSnap, defaultsSnap, receiptSnap] =
      await Promise.all([
        tx.get(db.collection("organizers").doc(command.organizerId)),
        tx.get(db.collection("deletedUsers").doc(actorUid)),
        tx.get(eventRef),
        tx.get(db.collection("organizerEventSetupDefaults")
          .doc(command.organizerId)),
        tx.get(receiptRef),
      ]);
    const organizer = authorizeSetupManager(organizerSnap, deletedSnap,
      actorUid);
    const event = eventSnap.data();
    if (!event || event.organizerId !== command.organizerId ||
        event.clubId !== command.organizerId) {
      throw new HttpsError("not-found", "Event not found.");
    }
    if (receiptSnap.exists) {
      const receipt = receiptSnap.data();
      if (receipt?.operation !== "details" ||
          receipt.actorUid !== actorUid ||
          receipt.organizerId !== command.organizerId ||
          receipt.eventId !== command.eventId ||
          receipt.requestHash !== hash ||
          !Number.isSafeInteger(receipt.appliedRevision)) {
        throw new HttpsError("already-exists",
          "Request ID was used for another event change.");
      }
      return {eventId: command.eventId,
        setupRevision: receipt.appliedRevision,
        replayed: true};
    }
    if (!validateEventDocument(event) ||
        event.publicationState !== "private" ||
        event.publicRegistrationEnabled !== false ||
        event.status !== "active") {
      throw new HttpsError("failed-precondition",
        "Only active private event details can be edited here.");
    }
    const revision = requireRevision(event);
    if (revision !== command.expectedSetupRevision) {
      throw new HttpsError("aborted", "Event setup changed. Reload it.");
    }
    const defaults = projectManagerEventSetupDefaults(command.organizerId,
      organizer, defaultsSnap.data(), eventSetupDefaultsDependencies(db));
    if (defaults.preferencesHash !== command.reviewedDefaultsHash) {
      throw new HttpsError("aborted",
        "Organizer defaults changed. Review them before saving.");
    }
    const guard = deps.assertBasicsEditable ??
      assertPrivateEventBasicsEditable;
    await guard({tx, db, eventId: command.eventId, event});

    const venueDecision = command.details.venue;
    const preferredVenueId = venueDecision?.mode === "inherit" ?
      defaults.preferences.preferredVenueId : undefined;
    let savedVenue: OrganizerEventVenueDocument | undefined;
    if (venueDecision?.mode === "inherit") {
      if (!preferredVenueId || !ID.test(preferredVenueId)) {
        throw new HttpsError("failed-precondition",
          "Choose a venue before inheriting a saved place.");
      }
      const venueSnap = await tx.get(db.collection("organizerEventVenues")
        .doc(organizerEventVenueDocumentId(command.organizerId,
          preferredVenueId)));
      if (!venueSnap.exists) {
        throw new HttpsError("failed-precondition",
          "The saved place is unavailable.");
      }
      savedVenue = requireDoc<OrganizerEventVenueDocument>(venueSnap,
        "OrganizerEventVenueDocument");
      assertOrganizerEventVenueSource({venue: savedVenue,
        organizerId: command.organizerId, venueId: preferredVenueId,
        meetingLocation: savedVenue.meetingLocation});
    }

    const next: Record<string, unknown> = {...event};
    const patch: Record<string, unknown> = {};
    const drop = (key: string) => {
      delete next[key];
      patch[key] = admin.firestore.FieldValue.delete();
    };
    const set = (key: string, value: unknown) => {
      next[key] = value;
      patch[key] = value;
    };
    const durationDecision = command.details.durationMinutes;
    if (durationDecision) {
      if (durationDecision.mode === "clear") {
        drop("endTime");
      } else {
        const minutes = duration(durationDecision.mode === "inherit" ?
          defaults.preferences.usualDurationMinutes : durationDecision.value);
        const start = event.startTime as unknown as
          FirebaseFirestore.Timestamp;
        const startMillis = typeof start?.toMillis === "function" ?
          start.toMillis() : null;
        if (startMillis === null || !Number.isSafeInteger(startMillis)) {
          throw new HttpsError("failed-precondition",
            "Event start time needs review.");
        }
        set("endTime", deps.timestampFromMillis(startMillis +
          minutes * 60_000));
      }
    }
    if (venueDecision) {
      for (const key of ["meetingPoint", "meetingLocation", "sourceVenueId",
        "startingPointLat", "startingPointLng", "locationDetails"]) {
        drop(key);
      }
      if (venueDecision.mode === "set") {
        set("meetingPoint", venueName(venueDecision.value));
      } else if (venueDecision.mode === "inherit" && savedVenue) {
        set("meetingPoint", savedVenue.meetingLocation.name);
        set("meetingLocation", savedVenue.meetingLocation);
        set("sourceVenueId", preferredVenueId);
        set("startingPointLat", savedVenue.meetingLocation.latitude);
        set("startingPointLng", savedVenue.meetingLocation.longitude);
        set("locationDetails", savedVenue.meetingLocation.notes ?? null);
      }
    }
    const formatDecision = command.details.eventFormat;
    if (formatDecision?.mode === "clear") drop("eventFormat");
    if (formatDecision?.mode === "set") {
      set("eventFormat", formatDecision.value);
    }
    if (!validateEventDocument(next)) {
      throw new HttpsError("invalid-argument", "Invalid event details.");
    }
    tx.update(eventRef, {...patch, setupRevision: revision + 1,
      updatedAt: deps.serverTimestamp()});
    tx.create(receiptRef, {operation: "details", actorUid,
      organizerId: command.organizerId, eventId: command.eventId,
      requestHash: hash, appliedRevision: revision + 1,
      createdAt: deps.serverTimestamp()});
    return {eventId: command.eventId, setupRevision: revision + 1,
      replayed: false};
  });
}
