import {createHash} from "crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {validateEventDocument} from
  "../shared/generated/validators/eventDocument";
import {canonicalJson, eventPaymentTermsFromPreferences,
  resolveEventPreferences} from "../events/eventSetupPreferences/resolve";
import {EventPreferenceError, EventPreferenceIntents,
  OrganizerEventDefaults} from "../events/eventSetupPreferences/types";
import {projectEventPreferences} from
  "../events/progressiveSetup/preferences";
import {authorizeSetupManager} from "../events/progressiveSetup/service";
import {projectManagerEventSetupDefaults} from
  "../organizers/eventSetupDefaults/service";
import {eventSetupDefaultsDependencies} from
  "../organizers/eventSetupDefaults/dependencies";

export interface ConfigureEventOfferPreferencesCommand {
  organizerId: string;
  eventId: string;
  requestId: string;
  expectedPreferencesRevision: number;
  expectedEventSourceRevision: number;
  reviewedDefaultsHash: string;
  intents: EventPreferenceIntents;
}

export interface EventOfferConfigurationDependencies {
  db: FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  /** A trusted deployment dependency, never a client-supplied switch. */
  configurationReady?: () => boolean;
}

export interface EventOfferConfigurationResult {
  eventId: string;
  preferencesRevision: number;
  replayed: boolean;
}

const ID = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/;
const REQUEST_ID = /^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$/;
const FIELDS = new Set(["usualDurationMinutes", "preferredVenueId",
  "offerValidityMinutes", "admissionPreset", "collectionPreference",
  "currency", "offerMessageTemplate", "paymentInstructions",
  "reusablePaymentPage", "expectedAmountMinor"]);

function validateCommand(command: ConfigureEventOfferPreferencesCommand) {
  if (!command || Object.keys(command).sort().join(",") !==
      "eventId,expectedEventSourceRevision,expectedPreferencesRevision," +
      "intents,organizerId,requestId,reviewedDefaultsHash" ||
      !ID.test(command.organizerId) ||
      !ID.test(command.eventId) || !REQUEST_ID.test(command.requestId) ||
      !Number.isSafeInteger(command.expectedPreferencesRevision) ||
      command.expectedPreferencesRevision < 0 ||
      !Number.isSafeInteger(command.expectedEventSourceRevision) ||
      command.expectedEventSourceRevision < 1 ||
      !/^[a-f0-9]{64}$/.test(command.reviewedDefaultsHash) ||
      !command.intents || typeof command.intents !== "object" ||
      Array.isArray(command.intents) ||
      Object.keys(command.intents).length !== FIELDS.size ||
      Object.keys(command.intents).some((key) => !FIELDS.has(key))) {
    throw new HttpsError("invalid-argument", "Invalid event offer settings.");
  }
  for (const [key, intent] of Object.entries(command.intents)) {
    if (!intent || typeof intent !== "object" ||
        !["set", "clear", "inherit"].includes(intent.mode) ||
        key === "expectedAmountMinor" && intent.mode === "inherit" ||
        intent.mode === "set" && !Object.hasOwn(intent, "value") ||
        intent.mode !== "set" && Object.hasOwn(intent, "value") ||
        Object.keys(intent).sort().join(",") !==
          (intent.mode === "set" ? "mode,value" : "mode")) {
      throw new HttpsError("invalid-argument", "Invalid setting decision.");
    }
  }
}

function digest(value: unknown): string {
  return createHash("sha256").update(canonicalJson(value)).digest("hex");
}

/** Mirrors the offer adapter; absent legacy revisions fail. */
function sourceRevision(event: FirebaseFirestore.DocumentData): number {
  const revision = Number.isSafeInteger(event.setupRevision) &&
    event.setupRevision > 0 ? event.setupRevision :
    event.updatedAt?.toMillis?.();
  if (!Number.isSafeInteger(revision) || revision < 1) {
    throw new HttpsError("failed-precondition",
      "Event has no stable offer source revision.");
  }
  return revision;
}

/** Manager-only snapshot update. Existing offers and the event never change. */
export async function configureEventOfferPreferences(params: {
  actorUid: string;
  command: ConfigureEventOfferPreferencesCommand;
  deps: EventOfferConfigurationDependencies;
}): Promise<EventOfferConfigurationResult> {
  const {actorUid, command, deps} = params;
  if (!ID.test(actorUid)) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
  validateCommand(command);
  if (deps.configurationReady?.() !== true) {
    throw new HttpsError("failed-precondition",
      "Event offer configuration is not ready.");
  }
  const {db} = deps;
  const receiptId = digest(["event-offer-configuration-v1", actorUid,
    command.organizerId, command.requestId]);
  const requestHash = digest(["event-offer-configuration-v1", command]);
  const eventRef = db.collection("events").doc(command.eventId);
  const preferencesRef = db.collection("eventSetupPreferences")
    .doc(command.eventId);
  const receiptRef = db.collection("eventOfferConfigurationReceipts")
    .doc(receiptId);
  return db.runTransaction(async (tx) => {
    const [organizerSnap, deletedSnap, eventSnap, defaultsSnap,
      preferencesSnap, receiptSnap] = await Promise.all([
      tx.get(db.collection("organizers").doc(command.organizerId)),
      tx.get(db.collection("deletedUsers").doc(actorUid)),
      tx.get(eventRef),
      tx.get(db.collection("organizerEventSetupDefaults")
        .doc(command.organizerId)),
      tx.get(preferencesRef), tx.get(receiptRef),
    ]);
    const organizer = authorizeSetupManager(organizerSnap, deletedSnap,
      actorUid);
    const event = eventSnap.data();
    if (!event || event.clubId !== command.organizerId ||
        event.organizerId !== undefined &&
        event.organizerId !== command.organizerId) {
      throw new HttpsError("not-found", "Event not found.");
    }
    if (!validateEventDocument(event)) {
      throw new HttpsError("failed-precondition", "Event is malformed.");
    }
    if (receiptSnap.exists) {
      const receipt = receiptSnap.data();
      if (receipt?.actorUid !== actorUid ||
          receipt?.organizerId !== command.organizerId ||
          receipt?.eventId !== command.eventId ||
          receipt?.requestId !== command.requestId ||
          receipt?.requestHash !== requestHash ||
          !Number.isSafeInteger(receipt?.appliedPreferencesRevision) ||
          receipt.appliedPreferencesRevision < 1) {
        throw new HttpsError("already-exists",
          "Request ID was used for another offer setting.");
      }
      return {eventId: command.eventId,
        preferencesRevision: receipt.appliedPreferencesRevision,
        replayed: true};
    }
    if (event.status !== "active") {
      throw new HttpsError("failed-precondition",
        "Cancelled events cannot change offer settings.");
    }
    const currentSourceRevision = sourceRevision(event);
    const saved = projectEventPreferences(preferencesSnap.data(),
      command.organizerId, command.eventId);
    const revision = saved?.revision ?? 0;
    if (revision >= 1_000_000_000) {
      throw new HttpsError("failed-precondition",
        "Event preference revisions are exhausted.");
    }
    if (currentSourceRevision !== command.expectedEventSourceRevision ||
        revision !== command.expectedPreferencesRevision) {
      throw new HttpsError("aborted", "Event settings changed. Reload them.");
    }
    const projected = projectManagerEventSetupDefaults(command.organizerId,
      organizer, defaultsSnap.data(), eventSetupDefaultsDependencies(db));
    const hostDefaults = organizer.hostDefaults as
      Record<string, unknown> | undefined;
    const defaults: OrganizerEventDefaults = {
      revision: projected.preferencesRevision,
      ...(projected.timezone === null ? {} : {timezone: projected.timezone}),
      ...(hostDefaults?.eventPolicy ? {eventPolicy:
        hostDefaults.eventPolicy as
          OrganizerEventDefaults["eventPolicy"]} : {}),
      eventSetup: projected.preferences,
    };
    let preferences;
    try {
      preferences = resolveEventPreferences({defaults, intents: command.intents,
        reviewedDefaultsHash: command.reviewedDefaultsHash});
    } catch (error) {
      if (error instanceof EventPreferenceError) {
        throw new HttpsError(error.code === "stale" ? "aborted" :
          "invalid-argument", error.message);
      }
      throw error;
    }
    const paymentTerms = eventPaymentTermsFromPreferences(preferences,
      revision + 1);
    projectEventPreferences({organizerId: command.organizerId,
      eventId: command.eventId, revision: revision + 1,
      preferences, paymentTerms}, command.organizerId, command.eventId);
    tx.set(preferencesRef, {organizerId: command.organizerId,
      eventId: command.eventId, revision: revision + 1, preferences,
      paymentTerms, updatedByUid: actorUid, updatedAt: deps.serverTimestamp()});
    tx.create(receiptRef, {actorUid, organizerId: command.organizerId,
      eventId: command.eventId, requestId: command.requestId, requestHash,
      appliedPreferencesRevision: revision + 1,
      createdAt: deps.serverTimestamp()});
    return {eventId: command.eventId, preferencesRevision: revision + 1,
      replayed: false};
  });
}
