import {createHash} from "crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerDocument} from
  "../../shared/generated/firestoreAdminTypes";
import {isOrganizerManager} from "../../shared/organizerHosts";
import {validateCreatePrivateEventSetupCallablePayload} from
  "../../shared/generated/validators/createPrivateEventSetupInput";
import {validateUpdatePrivateEventBasicsCallablePayload} from
  "../../shared/generated/validators/updatePrivateEventBasicsInput";
import {requireDoc} from "../../shared/validation";
import {
  normalizePrivateEventBasics,
  PrivateEventBasicsInput,
} from "./basics";
import {OrganizerSetupDefaults} from "./defaults";

export interface CreatePrivateEventSetupCommand {
  organizerId: string;
  requestId: string;
  basics: PrivateEventBasicsInput;
}

export interface UpdatePrivateEventBasicsCommand extends
  CreatePrivateEventSetupCommand {
  eventId: string;
  expectedSetupRevision: number;
}

export interface ProgressiveSetupResult {
  eventId: string;
  setupRevision: number;
  replayed: boolean;
}

export interface ProgressiveSetupDependencies {
  db: FirebaseFirestore.Firestore;
  /** Trusted deployment gate; it is never read from a client command. */
  privacyMigrationReady: () => boolean;
  timestampFromMillis: (millis: number) => FirebaseFirestore.Timestamp;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  /** Integration must fence roster, offer and payment commitments in tx. */
  assertBasicsEditable?: (params: {
    tx: FirebaseFirestore.Transaction;
    db: FirebaseFirestore.Firestore;
    eventId: string;
    event: Record<string, unknown>;
  }) => Promise<void>;
}

/** Creates one private canonical events/{id} document and durable receipt. */
export async function createPrivateEventSetup(params: {
  actorUid: string;
  command: CreatePrivateEventSetupCommand;
  deps: ProgressiveSetupDependencies;
}): Promise<ProgressiveSetupResult> {
  const {actorUid, command, deps} = params;
  if (!validateCreatePrivateEventSetupCallablePayload(command)) {
    throw new HttpsError("invalid-argument", "Invalid event setup request.");
  }
  assertPrivacyReady(deps);
  assertCommandIds(actorUid, command.organizerId, command.requestId);
  const db = deps.db;
  const receiptRef = receiptFor(db, actorUid, command.organizerId,
    command.requestId);
  const eventRef = db.collection("events").doc();
  const organizerRef = db.collection("organizers").doc(command.organizerId);
  const deletedRef = db.collection("deletedUsers").doc(actorUid);
  const requestHash = hashRequest("create", command);
  return db.runTransaction(async (tx) => {
    const [receiptSnap, organizerSnap, deletedSnap] = await Promise.all([
      tx.get(receiptRef), tx.get(organizerRef), tx.get(deletedRef),
    ]);
    const organizer = authorizeSetupManager(
      organizerSnap, deletedSnap, actorUid
    );
    if (receiptSnap.exists) {
      const receipt = receiptSnap.data() as Record<string, unknown>;
      assertReceipt(receipt, "create", actorUid, command.organizerId,
        requestHash);
      const priorEventId = receipt.eventId as string;
      const currentSnap = await tx.get(db.collection("events")
        .doc(priorEventId));
      const current = currentSnap.data() as Record<string, unknown> | undefined;
      if (!current || current.organizerId !== command.organizerId) {
        throw new HttpsError("failed-precondition", "Event is unavailable.");
      }
      return {eventId: priorEventId,
        setupRevision: receipt.appliedRevision as number, replayed: true};
    }
    const basics = normalizePrivateEventBasics({
      basics: command.basics,
      defaults: organizerDefaults(organizer),
    });
    const event = {
      clubId: command.organizerId,
      organizerId: command.organizerId,
      name: basics.name,
      eventCityId: basics.eventCityId,
      eventMarketId: basics.eventMarketId,
      eventLocalDate: basics.eventLocalDate,
      eventLocalStartTime: basics.eventLocalStartTime,
      eventTimezone: basics.eventTimezone,
      startTime: deps.timestampFromMillis(basics.startTimeMillis),
      setupDefaults: basics.setupDefaults,
      setupRevision: 1,
      publicationState: "private",
      publicRegistrationEnabled: false,
      status: "active",
      cancelledAt: null,
      cancellationReason: null,
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      genderCounts: {},
      cohortCounts: {},
      waitlistedCohortCounts: {},
    };
    tx.create(eventRef, event);
    tx.create(receiptRef, {
      operation: "create",
      actorUid,
      organizerId: command.organizerId,
      requestHash,
      eventId: eventRef.id,
      appliedRevision: 1,
      createdAt: deps.serverTimestamp(),
    });
    return {eventId: eventRef.id, setupRevision: 1, replayed: false};
  });
}

/** Updates only basics on the same private canonical event. */
export async function updatePrivateEventBasics(params: {
  actorUid: string;
  command: UpdatePrivateEventBasicsCommand;
  deps: ProgressiveSetupDependencies;
}): Promise<ProgressiveSetupResult> {
  const {actorUid, command, deps} = params;
  if (!validateUpdatePrivateEventBasicsCallablePayload(command)) {
    throw new HttpsError("invalid-argument", "Invalid event basics request.");
  }
  assertPrivacyReady(deps);
  assertCommandIds(actorUid, command.organizerId, command.requestId);
  if (!/^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/.test(command.eventId) ||
      !Number.isSafeInteger(command.expectedSetupRevision) ||
      command.expectedSetupRevision < 1) {
    throw new HttpsError("invalid-argument", "Invalid event revision.");
  }
  if (!deps.assertBasicsEditable) {
    throw new HttpsError("failed-precondition",
      "Event commitment guard is not installed.");
  }
  const assertBasicsEditable = deps.assertBasicsEditable;
  const db = deps.db;
  const receiptRef = receiptFor(db, actorUid, command.organizerId,
    command.requestId);
  const eventRef = db.collection("events").doc(command.eventId);
  const organizerRef = db.collection("organizers").doc(command.organizerId);
  const deletedRef = db.collection("deletedUsers").doc(actorUid);
  const requestHash = hashRequest("update", command);
  return db.runTransaction(async (tx) => {
    const [receiptSnap, organizerSnap, deletedSnap, eventSnap] =
      await Promise.all([
        tx.get(receiptRef), tx.get(organizerRef), tx.get(deletedRef),
        tx.get(eventRef),
      ]);
    const organizer = authorizeSetupManager(
      organizerSnap, deletedSnap, actorUid
    );
    const event = eventSnap.data() as Record<string, unknown> | undefined;
    if (!event || event.organizerId !== command.organizerId) {
      throw new HttpsError("not-found", "Event not found.");
    }
    if (receiptSnap.exists) {
      const receipt = receiptSnap.data() as Record<string, unknown>;
      assertReceipt(receipt,
        "update", actorUid, command.organizerId, requestHash,
        command.eventId);
      return {eventId: command.eventId,
        setupRevision: receipt.appliedRevision as number, replayed: true};
    }
    if (event.publicationState !== "private" ||
        event.status !== "active") {
      throw new HttpsError("failed-precondition",
        "Only active private event basics can be edited here.");
    }
    if (event.endTime !== undefined ||
        event.meetingLocation !== undefined ||
        event.eventSuccessPlanId !== undefined) {
      throw new HttpsError("failed-precondition",
        "Use the event details editor after scheduling setup.");
    }
    const revision = requireRevision(event);
    if (revision !== command.expectedSetupRevision) {
      throw new HttpsError("aborted", "Event setup changed. Reload it.");
    }
    await assertBasicsEditable({tx, db, eventId: command.eventId,
      event});
    const basics = normalizePrivateEventBasics({
      basics: command.basics,
      defaults: organizerDefaults(organizer),
    });
    tx.update(eventRef, {
      name: basics.name,
      eventCityId: basics.eventCityId,
      eventMarketId: basics.eventMarketId,
      eventLocalDate: basics.eventLocalDate,
      eventLocalStartTime: basics.eventLocalStartTime,
      eventTimezone: basics.eventTimezone,
      startTime: deps.timestampFromMillis(basics.startTimeMillis),
      setupDefaults: basics.setupDefaults,
      setupRevision: revision + 1,
    });
    tx.create(receiptRef, {
      operation: "update",
      actorUid,
      organizerId: command.organizerId,
      requestHash,
      eventId: command.eventId,
      appliedRevision: revision + 1,
      createdAt: deps.serverTimestamp(),
    });
    return {eventId: command.eventId,
      setupRevision: revision + 1, replayed: false};
  });
}

function assertPrivacyReady(deps: ProgressiveSetupDependencies): void {
  if (!deps.privacyMigrationReady()) {
    throw new HttpsError("failed-precondition",
      "Private event privacy migration is not ready.");
  }
}

function assertCommandIds(
  actorUid: string, organizerId: string, requestId: string
): void {
  const id = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/;
  const request = /^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$/;
  if (!id.test(actorUid) || !id.test(organizerId) ||
      !request.test(requestId)) {
    throw new HttpsError("invalid-argument", "Invalid operation identity.");
  }
}

function receiptFor(db: FirebaseFirestore.Firestore, actorUid: string,
  organizerId: string, requestId: string): FirebaseFirestore.DocumentReference {
  const id = createHash("sha256")
    .update(JSON.stringify(["progressive-event-setup-v1", actorUid,
      organizerId, requestId]))
    .digest("hex");
  return db.collection("eventSetupReceipts").doc(id);
}

function hashRequest(operation: "create" | "update",
  command: CreatePrivateEventSetupCommand | UpdatePrivateEventBasicsCommand
): string {
  return createHash("sha256")
    .update(canonicalJson([operation, command]))
    .digest("hex");
}

function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(canonicalJson).join(",")}]`;
  }
  if (value && typeof value === "object") {
    const record = value as Record<string, unknown>;
    return `{${Object.keys(record).sort()
      .filter((key) => record[key] !== undefined)
      .map((key) => `${JSON.stringify(key)}:${canonicalJson(record[key])}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
}

function assertReceipt(receipt: Record<string, unknown>,
  operation: "create" | "update", actorUid: string,
  organizerId: string, requestHash: string,
  eventId?: string): void {
  if (receipt.operation !== operation || receipt.actorUid !== actorUid ||
      receipt.organizerId !== organizerId ||
      receipt.requestHash !== requestHash ||
      typeof receipt.eventId !== "string" ||
      !/^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/.test(receipt.eventId) ||
      !Number.isSafeInteger(receipt.appliedRevision) ||
      (receipt.appliedRevision as number) < 1 ||
      (eventId && receipt.eventId !== eventId)) {
    throw new HttpsError("already-exists",
      "Request ID was already used for another event change.");
  }
}

function requireRevision(event: Record<string, unknown>): number {
  const revision = event.setupRevision;
  if (!Number.isSafeInteger(revision) || (revision as number) < 1) {
    throw new HttpsError("failed-precondition",
      "Event has no progressive setup revision.");
  }
  return revision as number;
}

/** Authorizes transaction snapshots, including deleted accounts. */
export function authorizeSetupManager(
  organizerSnap: FirebaseFirestore.DocumentSnapshot,
  deletedSnap: FirebaseFirestore.DocumentSnapshot,
  actorUid: string): OrganizerDocument {
  if (deletedSnap.exists) {
    throw new HttpsError("failed-precondition",
      "This account cannot manage events.");
  }
  if (!organizerSnap.exists) {
    throw new HttpsError("not-found", "Organizer not found.");
  }
  const organizer = requireDoc<OrganizerDocument>(organizerSnap,
    "OrganizerDocument");
  if (!isOrganizerManager(organizer, actorUid)) {
    throw new HttpsError("permission-denied",
      "Only organizer owners and managers can manage events.");
  }
  if (organizer.archived || organizer.status !== "active") {
    throw new HttpsError("failed-precondition",
      "Organizer is not active.");
  }
  return organizer;
}

function organizerDefaults(organizer: OrganizerDocument):
  OrganizerSetupDefaults {
  const raw = organizer.hostDefaults as Record<string, unknown> | undefined;
  const timezone = raw?.timezone;
  const revision = raw?.revision;
  return {
    ...(organizer.locationCityId && organizer.locationMarketId ? {
      city: {cityId: organizer.locationCityId,
        marketId: organizer.locationMarketId},
    } : {}),
    ...(typeof timezone === "string" ? {timezone} : {}),
    ...(typeof revision === "number" ? {revision} : {}),
  };
}
