import {HttpsError} from "firebase-functions/v2/https";
import {validateEventDocument} from
  "../shared/generated/validators/eventDocument";
import {planEventSeatMigration, SeatMigrationAttendee,
  SeatMigrationContact, SeatMigrationContactOrigin,
  SeatMigrationFormReceipt, SeatMigrationParticipation, SeatMigrationPlan,
  SeatMigrationVerifiedPhone} from "./seatMigration";
import {seatVerifiedPhoneProofId} from "./seatIdentityAuthority";
import {normalizeRosterPhone} from "./eventAttendees";
import {deriveEventSeatPolicy} from "./seatAuthority/firestoreAdapter";
import {formConversionReceiptId} from
  "../organizers/organizerFormAdmissionIdentity";
import {organizerContactOriginId} from
  "../shared/organizerContactOrigins";

/** Conservative single-transaction bootstrap limit, not event capacity. */
export const SEAT_BOOTSTRAP_SOURCE_LIMIT = 40;
export const SEAT_BOOTSTRAP_WRITE_LIMIT = 400;
const ID = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/;

export interface SeatMigrationStoreDependencies {
  db: FirebaseFirestore.Firestore;
  /** Firebase Admin Auth, never a client or users/{uid} phone assertion. */
  auth: {getUser: (uid: string) => Promise<{uid: string;
    phoneNumber?: string | null}>};
  /** Trusted deployment dependency; absent means no bootstrap. */
  allWritersIntegrated?: () => boolean;
}

export interface SeatMigrationBootstrapCommand {
  eventId: string;
  organizerId: string;
  migrationRevision: number;
  asOfMillis: number;
}

function unavailable(message: string): never {
  throw new HttpsError("failed-precondition", message);
}

async function completeQuery(tx: FirebaseFirestore.Transaction,
  query: FirebaseFirestore.Query, name: string):
  Promise<FirebaseFirestore.QueryDocumentSnapshot[]> {
  const snapshot = await tx.get(query.limit(SEAT_BOOTSTRAP_SOURCE_LIMIT + 1));
  if (snapshot.size > SEAT_BOOTSTRAP_SOURCE_LIMIT) {
    unavailable(`${name} exceeds one-transaction bootstrap limit.`);
  }
  return snapshot.docs;
}

async function stagedQuery(tx: FirebaseFirestore.Transaction,
  query: FirebaseFirestore.Query, name: string):
  Promise<FirebaseFirestore.QueryDocumentSnapshot[]> {
  const snap = await tx.get(query.limit(SEAT_BOOTSTRAP_WRITE_LIMIT + 1));
  if (snap.size > SEAT_BOOTSTRAP_WRITE_LIMIT) {
    unavailable(`${name} exceeds reconciliation read limit.`);
  }
  return snap.docs;
}

function canonical(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === "object") {
    const row = value as Record<string, unknown>;
    return Object.fromEntries(Object.keys(row).sort()
      .map((key) => [key, canonical(row[key])]));
  }
  return value;
}

function sameDocument(left: unknown, right: unknown): boolean {
  return JSON.stringify(canonical(left)) === JSON.stringify(canonical(right));
}

/** Extracts an exact event target from an existing conversion receipt. */
function formReceipt(raw: FirebaseFirestore.DocumentData,
  organizerId: string): SeatMigrationFormReceipt | null {
  if (raw.organizerId !== organizerId ||
      raw.kind !== "eventAttendeeProposal" ||
      typeof raw.formId !== "string" ||
      typeof raw.responseId !== "string" ||
      !["completed", "failed", "pending"].includes(raw.status) ||
      !Array.isArray(raw.fields)) {
    unavailable("Form admission receipt is malformed.");
  }
  const targets = raw.fields.filter((field: unknown) => field &&
    typeof field === "object" &&
    (field as {destinationField?: unknown}).destinationField === "eventId");
  if (targets.length !== 1 || typeof targets[0].value !== "string") {
    unavailable("Form admission target is unavailable.");
  }
  return {organizerId, eventId: targets[0].value,
    formId: raw.formId, responseId: raw.responseId, status: raw.status};
}

type ReadyPlan = Extract<SeatMigrationPlan, {state: "ready"}>;

/** Reconcile only this exact event's staged, still-unavailable snapshot. */
async function stageReconciledPlan(params: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  ledgerRef: FirebaseFirestore.DocumentReference;
  eventId: string;
  organizerId: string;
  priorLedger: FirebaseFirestore.DocumentData | undefined;
  plan: ReadyPlan;
}): Promise<{revision: number; capacityRevision: number}> {
  const {db, tx, ledgerRef, eventId, organizerId, priorLedger,
    plan} = params;
  const collections = ["eventSeatReservations",
    "eventSeatIdentityAliases", "eventSeatVerifiedPhones"] as const;
  const planned = [new Map(plan.reservations.map((entry) =>
    [entry.id, entry.value])),
  new Map(plan.aliases.map((entry) => [entry.id, entry.value])),
  new Map(plan.verifiedPhoneProofs.map((value) =>
    [seatVerifiedPhoneProofId(eventId, value.uid), value]))] as Array<
    Map<string, FirebaseFirestore.DocumentData>>;
  const staged = priorLedger ? await Promise.all(collections.map((name) =>
    stagedQuery(tx, db.collection(name).where("eventId", "==", eventId),
      name))) : [[], [], []] as FirebaseFirestore.QueryDocumentSnapshot[][];
  if (priorLedger) {
    if (staged.reduce((count, docs) => count + docs.length, 0) + 1 >
        SEAT_BOOTSTRAP_WRITE_LIMIT) {
      unavailable("Staged seat evidence exceeds reconciliation limit.");
    }
    const reservations = staged[0];
    if (reservations.length !== priorLedger.occupied ||
        reservations.some((doc) => {
          const row = doc.data();
          return row.eventId !== eventId || row.active !== true ||
            row.identityRevision !== 1 ||
            !ID.test(String(row.canonicalKey));
        })) {
      unavailable("Staged seat reservations need manual reconciliation.");
    }
    for (let index = 1; index < staged.length; index++) {
      for (const doc of staged[index]) {
        const row = doc.data();
        if (row.eventId !== eventId || row.organizerId !== organizerId ||
            row.migrationRevision !== priorLedger.migrationRevision ||
            index === 1 && (row.state !== "ready" ||
              row.identityRevision !== 1) ||
            index === 2 && row.state !== "current") {
          unavailable("Staged identity evidence needs reconciliation.");
        }
      }
    }
  }
  const operations: Array<() => void> = [];
  for (let index = 0; index < collections.length; index++) {
    const collection = db.collection(collections[index]);
    const old = new Map(staged[index].map((doc) => [doc.id, doc.data()]));
    const next = planned[index];
    for (const [id] of old) {
      if (!next.has(id)) operations.push(() => tx.delete(collection.doc(id)));
    }
    for (const [id, value] of next) {
      if (!old.has(id)) {
        operations.push(() => tx.create(collection.doc(id), value));
      } else if (!sameDocument(old.get(id), value)) {
        operations.push(() => tx.set(collection.doc(id), value));
      }
    }
  }
  const revision = priorLedger ? priorLedger.revision + 1 : 1;
  const capacityRevision = priorLedger ?
    priorLedger.capacityRevision +
      (priorLedger.policyHash === plan.ledger.policyHash ? 0 : 1) : 1;
  if (operations.length + 1 > SEAT_BOOTSTRAP_WRITE_LIMIT) {
    unavailable("Seat reconciliation exceeds one-transaction write budget.");
  }
  const ledger = {...plan.ledger, revision, capacityRevision,
    state: "unreconciled"};
  if (priorLedger) tx.set(ledgerRef, ledger);
  else tx.create(ledgerRef, ledger);
  for (const operation of operations) operation();
  return {revision, capacityRevision};
}

/**
 * Server-only initial bootstrap. A caller still owns rollout, source-writer
 * migration and index installation. Auth is re-read before readiness.
 */
export async function bootstrapEventSeatLedger(params: {
  command: SeatMigrationBootstrapCommand;
  deps: SeatMigrationStoreDependencies;
}): Promise<{eventId: string; occupied: number;
  migrationRevision: number}> {
  const {command, deps} = params;
  if (!command || !ID.test(command.eventId) ||
      !ID.test(command.organizerId) ||
      !Number.isSafeInteger(command.migrationRevision) ||
      command.migrationRevision < 1 ||
      !Number.isSafeInteger(command.asOfMillis) ||
      command.asOfMillis < 0) {
    throw new HttpsError("invalid-argument", "Invalid seat bootstrap.");
  }
  if (deps.allWritersIntegrated?.() !== true) {
    unavailable("Seat writers are not integrated.");
  }
  const {db} = deps;
  const staged = await db.runTransaction(async (tx) => {
    const eventRef = db.collection("events").doc(command.eventId);
    const ledgerRef = db.collection("eventSeatLedgers")
      .doc(command.eventId);
    const [eventSnap, ledgerSnap] = await Promise.all([
      tx.get(eventRef), tx.get(ledgerRef),
    ]);
    const event = eventSnap.data();
    if (!event || !validateEventDocument(event) ||
        event.clubId !== command.organizerId ||
        event.organizerId !== undefined &&
          event.organizerId !== command.organizerId) {
      unavailable("Canonical event source is unavailable.");
    }
    const priorLedger = ledgerSnap.data();
    if (ledgerSnap.exists && (!priorLedger ||
        priorLedger.state !== "unreconciled" ||
        priorLedger.eventId !== command.eventId ||
        priorLedger.migrationRevision !== command.migrationRevision ||
        !Number.isSafeInteger(priorLedger.revision) ||
        priorLedger.revision < 1 ||
        priorLedger.revision >= Number.MAX_SAFE_INTEGER ||
        !Number.isSafeInteger(priorLedger.capacityRevision) ||
        priorLedger.capacityRevision < 1 ||
        priorLedger.capacityRevision >= Number.MAX_SAFE_INTEGER)) {
      unavailable("Existing seat ledger needs explicit reconciliation.");
    }
    const [participationDocs, attendeeDocs, originDocs] = await Promise.all([
      completeQuery(tx, db.collection("eventParticipations")
        .where("eventId", "==", command.eventId), "Participations"),
      completeQuery(tx, db.collection("eventAttendees")
        .where("eventId", "==", command.eventId), "Attendees"),
      completeQuery(tx, db.collection("organizerContactOrigins")
        .where("eventId", "==", command.eventId), "Event CRM origins"),
    ]);
    const participations = participationDocs.map((doc) => doc.data() as
      SeatMigrationParticipation);
    const attendees = attendeeDocs.map((doc) =>
      ({...doc.data(), id: doc.id} as SeatMigrationAttendee));
    const uids = [...new Set([...participations.map((row) => row.uid),
      ...attendees.map((row) => row.linkedUid)
        .filter((uid): uid is string => uid !== null)])].sort();
    if (uids.length > SEAT_BOOTSTRAP_SOURCE_LIMIT ||
        uids.some((uid) => !ID.test(uid))) {
      unavailable("Auth identity source exceeds bootstrap limit.");
    }
    const verifiedPhones = await currentAuthSnapshot(deps.auth, uids);
    const responseIds = [...new Set(attendees
      .filter((row) => row.source === "hostManual" &&
        typeof row.externalReference === "string" &&
        row.sourceRowId === row.externalReference.slice(0, 120))
      .map((row) => row.externalReference!))];
    const receiptSnaps = await Promise.all(responseIds.map((responseId) =>
      tx.get(db.collection("organizerFormConversionReceipts")
        .doc(formConversionReceiptId(responseId, "eventAttendeeProposal",
          command.eventId)))));
    const receipts: SeatMigrationFormReceipt[] = [];
    const formOriginIds: string[] = [];
    receiptSnaps.forEach((snap, index) => {
      if (!snap.exists) return;
      const receipt = formReceipt(snap.data()!, command.organizerId);
      if (!receipt || receipt.eventId !== command.eventId ||
          receipt.responseId !== responseIds[index]) {
        unavailable("Form admission receipt target conflicts with attendee.");
      }
      receipts.push(receipt);
      formOriginIds.push(organizerContactOriginId({
        organizerId: command.organizerId, sourceKind: "hostForm",
        sourceEntityKind: "hostFormResponse",
        sourceEntityId: receipt.responseId}));
    });
    const formOriginSnaps = await Promise.all(formOriginIds.map((id) =>
      tx.get(db.collection("organizerContactOrigins").doc(id))));
    const origins = originDocs.map((doc) =>
      ({...doc.data(), id: doc.id} as SeatMigrationContactOrigin));
    const knownOrigins = new Set(origins.map((origin) => origin.id));
    formOriginSnaps.forEach((snap, index) => {
      if (!snap.exists) return;
      const id = formOriginIds[index];
      if (!knownOrigins.has(id)) {
        origins.push({...snap.data(), id} as SeatMigrationContactOrigin);
        knownOrigins.add(id);
      }
    });
    const relevantOrigins = origins;
    if (relevantOrigins.length > SEAT_BOOTSTRAP_SOURCE_LIMIT) {
      unavailable("Event CRM origins exceed bootstrap limit.");
    }
    const contactIds = [...new Set(relevantOrigins.map((origin) =>
      origin.currentContactId))];
    if (contactIds.some((id) => !ID.test(id))) {
      unavailable("CRM survivor reference is malformed.");
    }
    const contactSnaps = await Promise.all(contactIds.map((id) =>
      tx.get(db.collection("organizerContacts").doc(id))));
    const contacts: SeatMigrationContact[] = contactSnaps.map((snap, index) => {
      const raw = snap.data();
      if (!raw) unavailable("CRM survivor is missing.");
      return {id: contactIds[index], organizerId: raw.organizerId,
        linkedUid: raw.linkedUid, identityState: raw.identityState,
        deleted: raw.deletedAt !== null, hidden: raw.hiddenAt !== null,
        mergedIntoContactId: raw.mergedIntoContactId,
        ambiguousCandidateContactIds: raw.ambiguousCandidateContactIds};
    });
    const plan = planEventSeatMigration({eventId: command.eventId,
      organizerId: command.organizerId, event,
      migrationRevision: command.migrationRevision,
      asOfMillis: command.asOfMillis, participations, attendees,
      verifiedPhones, origins: relevantOrigins, contacts,
      formReceipts: receipts,
      sourceReadEvidence: {complete: true,
        participationRows: participationDocs.length,
        attendeeRows: attendeeDocs.length,
        originRows: relevantOrigins.length}});
    if (plan.state !== "ready") {
      unavailable(`Seat reconciliation blocked: ${plan.blockers.join(", ")}`);
    }
    if (deps.allWritersIntegrated?.() !== true) {
      unavailable("Seat writers are not integrated.");
    }
    const staged = await stageReconciledPlan({db, tx, ledgerRef,
      eventId: command.eventId, organizerId: command.organizerId,
      priorLedger, plan});
    return {eventId: command.eventId, occupied: plan.ledger.occupied,
      migrationRevision: command.migrationRevision,
      verifiedPhones, policyHash: plan.ledger.policyHash,
      revision: staged.revision,
      capacityRevision: staged.capacityRevision};
  });
  const current = await currentAuthSnapshot(deps.auth,
    staged.verifiedPhones.map((proof) => proof.uid));
  if (JSON.stringify(current) !== JSON.stringify(staged.verifiedPhones)) {
    unavailable("Auth identity changed during bootstrap; reconcile first.");
  }
  await db.runTransaction(async (tx) => {
    const eventSnap = await tx.get(db.collection("events")
      .doc(command.eventId));
    const ledgerRef = db.collection("eventSeatLedgers").doc(command.eventId);
    const ledgerSnap = await tx.get(ledgerRef);
    const event = eventSnap.data();
    const ledger = ledgerSnap.data();
    if (!event || !validateEventDocument(event) ||
        event.clubId !== command.organizerId ||
        event.organizerId !== undefined &&
          event.organizerId !== command.organizerId ||
        !ledger || ledger.state !== "unreconciled" ||
        ledger.eventId !== command.eventId ||
        ledger.migrationRevision !== command.migrationRevision ||
        ledger.occupied !== staged.occupied ||
        ledger.revision !== staged.revision ||
        ledger.capacityRevision !== staged.capacityRevision ||
        ledger.policyHash !== staged.policyHash ||
        deriveEventSeatPolicy(event).policyHash !== staged.policyHash ||
        deps.allWritersIntegrated?.() !== true) {
      unavailable("Seat source changed before activation.");
    }
    tx.update(ledgerRef, {state: "ready"});
  });
  return {eventId: staged.eventId, occupied: staged.occupied,
    migrationRevision: staged.migrationRevision};
}

async function currentAuthSnapshot(
  auth: SeatMigrationStoreDependencies["auth"], uids: string[]
): Promise<SeatMigrationVerifiedPhone[]> {
  const records = await Promise.all(uids.map((uid) => auth.getUser(uid)));
  return records.map((record, index) => {
    if (record.uid !== uids[index]) {
      unavailable("Auth UID source changed.");
    }
    const phone = record.phoneNumber ?? null;
    if (phone !== null) {
      const normalized = normalizeRosterPhone(phone);
      if (normalized.issue || normalized.value !== phone) {
        unavailable("Auth verified phone is malformed.");
      }
    }
    return {uid: record.uid, phoneE164: phone,
      verifiedByAuth: true};
  });
}
