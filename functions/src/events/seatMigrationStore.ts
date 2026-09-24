import {HttpsError} from "firebase-functions/v2/https";
import {validateEventDocument} from
  "../shared/generated/validators/eventDocument";
import {planEventSeatMigration, SeatMigrationAttendee,
  SeatMigrationContact, SeatMigrationContactOrigin,
  SeatMigrationFormReceipt, SeatMigrationParticipation,
  SeatMigrationVerifiedPhone} from "./seatMigration";
import {seatVerifiedPhoneProofId} from "./seatIdentityAuthority";
import {normalizeRosterPhone} from "./eventAttendees";
import {deriveEventSeatPolicy} from "./seatAuthority/firestoreAdapter";

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
    if (ledgerSnap.exists) {
      unavailable("Existing seat ledger needs reconciliation, not bootstrap.");
    }
    const [participationDocs, attendeeDocs, originDocs,
      receiptDocs] = await Promise.all([
      completeQuery(tx, db.collection("eventParticipations")
        .where("eventId", "==", command.eventId), "Participations"),
      completeQuery(tx, db.collection("eventAttendees")
        .where("eventId", "==", command.eventId), "Attendees"),
      completeQuery(tx, db.collection("organizerContactOrigins")
        .where("organizerId", "==", command.organizerId), "CRM origins"),
      completeQuery(tx, db.collection("organizerFormConversionReceipts")
        .where("organizerId", "==", command.organizerId)
        .where("kind", "==", "eventAttendeeProposal"),
      "Form admission receipts"),
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
    const origins = originDocs.map((doc) =>
      ({...doc.data(), id: doc.id} as SeatMigrationContactOrigin));
    const receipts = receiptDocs.map((doc) =>
      formReceipt(doc.data(), command.organizerId))
      .filter((row): row is SeatMigrationFormReceipt => row !== null);
    const relevantOrigins = origins.filter((origin) =>
      origin.eventId === command.eventId ||
      origin.eventId === null &&
        origin.sourceEntityKind === "hostFormResponse" &&
        receipts.some((receipt) =>
          receipt.eventId === command.eventId &&
          receipt.responseId === origin.responseId));
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
    const writes = 1 + plan.reservations.length + plan.aliases.length +
      plan.verifiedPhoneProofs.length;
    if (writes > SEAT_BOOTSTRAP_WRITE_LIMIT) {
      unavailable("Seat migration exceeds one-transaction write budget.");
    }
    if (deps.allWritersIntegrated?.() !== true) {
      unavailable("Seat writers are not integrated.");
    }
    // No resolver can use these records until Auth is revalidated below.
    tx.create(ledgerRef, {...plan.ledger, state: "unreconciled"});
    for (const reservation of plan.reservations) {
      tx.create(db.collection("eventSeatReservations").doc(reservation.id),
        reservation.value);
    }
    for (const alias of plan.aliases) {
      tx.create(db.collection("eventSeatIdentityAliases").doc(alias.id),
        alias.value);
    }
    for (const proof of plan.verifiedPhoneProofs) {
      tx.create(db.collection("eventSeatVerifiedPhones")
        .doc(seatVerifiedPhoneProofId(command.eventId, proof.uid)),
      proof);
    }
    return {eventId: command.eventId, occupied: plan.ledger.occupied,
      migrationRevision: command.migrationRevision,
      verifiedPhones, policyHash: plan.ledger.policyHash};
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
