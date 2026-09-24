import {createHash} from "crypto";
import {normalizeRosterPhone} from "./eventAttendees";

/** Structural adapter compatibility until the seat core is integrated. */
export class SeatIdentityAuthorityError extends Error {
  constructor(readonly code: "invalid" | "unavailable", message: string) {
    super(message);
  }
}

const ID = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/;
type AliasKind = "uid" | "phone" | "attendee" | "external" |
  "contactOrigin" | "contact";

/** References, never a caller's assertion that a phone or CRM merge is safe. */
export type SeatIdentitySubject =
  {kind: "verifiedUid"; uid: string} |
  {kind: "importAttendee"; attendeeId: string} |
  {kind: "crmOrigin"; originId: string; responseId: string};

/** Migration owns this revision and every alias document at that revision. */
export interface SeatIdentityMigration {
  eventId: string;
  organizerId: string;
  migrationRevision: number;
  state: "ready" | "unreconciled" | "revoked";
}

export interface SeatIdentityAlias {
  eventId: string;
  organizerId: string;
  kind: AliasKind;
  valueHash: string;
  canonicalKey: string;
  identityRevision: number;
  migrationRevision: number;
  state: "ready" | "ambiguous" | "retired";
}

/** Must be maintained from verified Auth evidence, never client-written. */
export interface SeatVerifiedPhoneProof {
  eventId: string;
  organizerId: string;
  uid: string;
  phoneE164: string | null;
  migrationRevision: number;
  state: "current" | "revoked";
}

export interface CanonicalSeatIdentity {
  key: string;
  revision: number;
}

function fail(message: string): never {
  throw new SeatIdentityAuthorityError("unavailable", message);
}

function validId(value: unknown): value is string {
  return typeof value === "string" && ID.test(value);
}

function hash(parts: string[]): string {
  return createHash("sha256").update(parts.join("\u001f")).digest("hex");
}

/** Hash persisted alias values exactly as the transaction resolver expects. */
export function seatIdentityValueHash(kind: AliasKind,
  value: string): string {
  return hash([kind, value]);
}

export function seatIdentityAliasId(eventId: string, kind: AliasKind,
  value: string): string {
  if (!validId(eventId) || !value || value.length > 512) {
    throw new SeatIdentityAuthorityError("invalid",
      "Invalid seat alias identity.");
  }
  return hash([eventId, kind, value]);
}

export function seatVerifiedPhoneProofId(eventId: string,
  uid: string): string {
  if (!validId(eventId) || !validId(uid)) {
    throw new SeatIdentityAuthorityError("invalid",
      "Invalid verified identity.");
  }
  return hash([eventId, "verifiedUid", uid]);
}

function currentPhone(value: unknown): string {
  if (typeof value !== "string") fail("Verified phone proof is missing.");
  const normalized = normalizeRosterPhone(value);
  if (normalized.issue || !normalized.value ||
      normalized.value !== value) fail("Verified phone proof is malformed.");
  return value;
}

/** Single-transaction resolver; it never creates aliases. */
export class FirestoreSeatIdentityAuthority {
  async resolve(params: {
    db: FirebaseFirestore.Firestore;
    tx: FirebaseFirestore.Transaction;
    eventId: string;
    organizerId: string;
    subject: SeatIdentitySubject;
  }): Promise<CanonicalSeatIdentity | null> {
    const {db, tx, eventId, organizerId, subject} = params;
    if (!validId(eventId) || !validId(organizerId) || !subject ||
        !["verifiedUid", "importAttendee", "crmOrigin"]
          .includes(subject.kind)) {
      throw new SeatIdentityAuthorityError("invalid",
        "Invalid seat identity scope.");
    }
    const read = async (collection: string, id: string) =>
      (await tx.get(db.collection(collection).doc(id))).data();
    const ledger = await read("eventSeatLedgers", eventId);
    if (!ledger || ledger.eventId !== eventId ||
        ledger.state !== "ready" ||
        !Number.isSafeInteger(ledger.migrationRevision) ||
        ledger.migrationRevision < 1) fail("Seat migration is not ready.");
    const revision = ledger.migrationRevision as number;
    const aliases: Array<[AliasKind, string]> = [];
    if (subject.kind === "verifiedUid") {
      if (!validId(subject.uid)) {
        throw new SeatIdentityAuthorityError("invalid",
          "Invalid participant UID.");
      }
      const proof = await read("eventSeatVerifiedPhones",
        seatVerifiedPhoneProofId(eventId, subject.uid));
      if (!proof || proof.eventId !== eventId ||
          proof.organizerId !== organizerId || proof.uid !== subject.uid ||
          proof.state !== "current" ||
          proof.migrationRevision !== revision) {
        fail("Current verified identity proof is unavailable.");
      }
      aliases.push(["uid", subject.uid]);
      if (proof.phoneE164 !== null) {
        aliases.push(["phone", currentPhone(proof.phoneE164)]);
      }
    } else if (subject.kind === "importAttendee") {
      if (!validId(subject.attendeeId)) {
        throw new SeatIdentityAuthorityError("invalid",
          "Invalid attendee identity.");
      }
      const attendee = await read("eventAttendees", subject.attendeeId);
      if (!attendee || attendee.eventId !== eventId ||
          attendee.organizerId !== organizerId ||
          !["hostImport", "hostManual", "providerSync", "webOtp",
            "catchBooking"].includes(attendee.source) ||
          !["registered", "checkedIn", "invited", "waitlisted"]
            .includes(attendee.status)) {
        fail("Current attendee source is unavailable.");
      }
      aliases.push(["attendee", subject.attendeeId]);
      if (attendee.externalReference !== null) {
        if (typeof attendee.externalReference !== "string" ||
            !attendee.externalReference.trim()) {
          fail("Imported reference is malformed.");
        }
        aliases.push(["external", attendee.externalReference.trim()
          .toLowerCase()]);
      }
      if (attendee.phoneE164 !== null) {
        aliases.push(["phone", currentPhone(attendee.phoneE164)]);
      }
      if (attendee.linkedUid !== null) {
        if (!validId(attendee.linkedUid)) fail("Attendee UID is malformed.");
        aliases.push(["uid", attendee.linkedUid]);
      }
    } else {
      if (!validId(subject.originId) || !validId(subject.responseId)) {
        throw new SeatIdentityAuthorityError("invalid",
          "Invalid contact origin.");
      }
      const origin = await read("organizerContactOrigins", subject.originId);
      if (!origin || origin.organizerId !== organizerId ||
          !(origin.eventId === eventId ||
            origin.eventId === null && origin.sourceKind === "hostForm" &&
            origin.sourceEntityKind === "hostFormResponse" &&
            origin.sourceEntityId === subject.responseId &&
            origin.responseId === subject.responseId) ||
          !validId(origin.currentContactId) ||
          !validId(origin.originContactId)) {
        fail("Current contact origin is unavailable.");
      }
      const contact = await read("organizerContacts",
        origin.currentContactId);
      if (!contact || contact.organizerId !== organizerId ||
          contact.deletedAt !== null || contact.hiddenAt != null ||
          contact.mergedIntoContactId !== null ||
          !["unlinked", "verified"].includes(contact.identityState) ||
          !Array.isArray(contact.ambiguousCandidateContactIds) ||
          contact.ambiguousCandidateContactIds.length > 0) {
        fail("Current CRM survivor is unavailable.");
      }
      aliases.push(["contactOrigin", subject.originId],
        ["contact", origin.currentContactId]);
      if (contact.linkedUid !== null) {
        if (!validId(contact.linkedUid) ||
            contact.identityState !== "verified") {
          fail("CRM linked UID is not verified.");
        }
        aliases.push(["uid", contact.linkedUid]);
      }
    }
    let canonical: CanonicalSeatIdentity | null = null;
    for (const [kind, value] of aliases) {
      const aliasId = seatIdentityAliasId(eventId, kind, value);
      const alias = await read("eventSeatIdentityAliases", aliasId);
      if (!alias || alias.eventId !== eventId ||
          alias.organizerId !== organizerId || alias.kind !== kind ||
          alias.valueHash !== seatIdentityValueHash(kind, value) ||
          alias.state !== "ready" ||
          alias.migrationRevision !== revision ||
          !validId(alias.canonicalKey) ||
          !Number.isSafeInteger(alias.identityRevision) ||
          alias.identityRevision < 1) {
        fail("Seat alias is missing, stale or ambiguous.");
      }
      if (canonical && (canonical.key !== alias.canonicalKey ||
          canonical.revision !== alias.identityRevision)) {
        fail("Seat aliases disagree; reconcile identity first.");
      }
      canonical = {key: alias.canonicalKey,
        revision: alias.identityRevision};
    }
    return canonical;
  }
}

/**
 * Read-only preparation for a Catch UID whose current phone comes from Admin
 * Auth, not a form or client assertion. Writes are staged only after the
 * booking transaction has completed every other authority read.
 */
export async function prepareCatchUidSeatIdentity(params: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  eventId: string;
  organizerId: string;
  uid: string;
  currentAuthPhoneNumber: string | null;
}): Promise<{identity: CanonicalSeatIdentity; apply: () => void}> {
  const {db, tx, eventId, organizerId, uid} = params;
  if (![eventId, organizerId, uid].every(validId)) {
    throw new SeatIdentityAuthorityError("invalid",
      "Invalid Catch seat scope.");
  }
  const phone = params.currentAuthPhoneNumber === null ? null :
    currentPhone(params.currentAuthPhoneNumber);
  const ledgerSnap = await tx.get(db.collection("eventSeatLedgers")
    .doc(eventId));
  const ledger = ledgerSnap.data();
  if (!ledger || ledger.eventId !== eventId || ledger.state !== "ready" ||
      !Number.isSafeInteger(ledger.migrationRevision) ||
      ledger.migrationRevision < 1) fail("Seat migration is not ready.");
  const uidAliasRef = db.collection("eventSeatIdentityAliases")
    .doc(seatIdentityAliasId(eventId, "uid", uid));
  const proofRef = db.collection("eventSeatVerifiedPhones")
    .doc(seatVerifiedPhoneProofId(eventId, uid));
  const phoneAliasRef = phone === null ? null :
    db.collection("eventSeatIdentityAliases")
      .doc(seatIdentityAliasId(eventId, "phone", phone));
  const [uidAliasSnap, proofSnap, phoneAliasSnap] = await Promise.all([
    tx.get(uidAliasRef), tx.get(proofRef),
    phoneAliasRef ? tx.get(phoneAliasRef) : Promise.resolve(null),
  ]);
  const uidAlias = uidAliasSnap.data();
  const proof = proofSnap.data();
  const phoneAlias = phoneAliasSnap?.data();
  if (uidAlias || proof) {
    if (!uidAlias || !proof || proof.phoneE164 !== phone) {
      fail("Current Auth phone and persisted seat identity disagree.");
    }
    const identity = await new FirestoreSeatIdentityAuthority().resolve({
      db, tx, eventId, organizerId, subject: {kind: "verifiedUid", uid},
    });
    if (!identity) fail("Current Catch seat identity is unavailable.");
    return {identity, apply: () => undefined};
  }
  if (phone === null) {
    fail("A verified current phone is required to enroll a new Catch seat.");
  }
  if (phoneAlias) {
    fail("This phone already has a guest seat; link it before reserving.");
  }
  const key = "uid_" + hash([eventId, uid]).slice(0, 48);
  const aliasBase = {eventId, organizerId, canonicalKey: key,
    identityRevision: 1, migrationRevision: ledger.migrationRevision,
    state: "ready"};
  let applied = false;
  return {identity: {key, revision: 1}, apply: () => {
    if (applied) throw new Error("Catch identity enrollment already staged.");
    applied = true;
    tx.create(uidAliasRef, {...aliasBase, kind: "uid",
      valueHash: seatIdentityValueHash("uid", uid)});
    tx.create(phoneAliasRef!, {...aliasBase, kind: "phone",
      valueHash: seatIdentityValueHash("phone", phone)});
    tx.create(proofRef, {eventId, organizerId, uid,
      phoneE164: phone, migrationRevision: ledger.migrationRevision,
      state: "current"});
  }};
}

/**
 * Attaches a verified UID to an existing guest reservation, without taking a
 * second seat. The caller must pass the current callable Auth token phone and
 * use this exact transaction for its public-registration attendee write.
 * Distinct existing UID seats remain a manual reconciliation conflict.
 */
export async function prepareVerifiedUidGuestSeatLink(params: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  eventId: string;
  organizerId: string;
  attendeeId: string;
  uid: string;
  authTokenPhoneNumber: string;
  now: FirebaseFirestore.Timestamp;
}): Promise<{canonicalKey: string; ledgerRevision: number;
  replayed: boolean; apply: () => void}> {
  const {db, tx, eventId, organizerId, attendeeId, uid, now} = params;
  if (![eventId, organizerId, attendeeId, uid].every(validId)) {
    throw new SeatIdentityAuthorityError("invalid", "Invalid seat link.");
  }
  const normalized = normalizeRosterPhone(params.authTokenPhoneNumber);
  if (normalized.issue || !normalized.value ||
      normalized.value !== params.authTokenPhoneNumber) {
    fail("A current verified phone attendee is required.");
  }
  const eventRef = db.collection("events").doc(eventId);
  const ledgerRef = db.collection("eventSeatLedgers").doc(eventId);
  const attendeeRef = db.collection("eventAttendees").doc(attendeeId);
  const attendeeAliasRef = db.collection("eventSeatIdentityAliases")
    .doc(seatIdentityAliasId(eventId, "attendee", attendeeId));
  const phoneAliasRef = db.collection("eventSeatIdentityAliases")
    .doc(seatIdentityAliasId(eventId, "phone", normalized.value));
  const uidAliasRef = db.collection("eventSeatIdentityAliases")
    .doc(seatIdentityAliasId(eventId, "uid", uid));
  const proofRef = db.collection("eventSeatVerifiedPhones")
    .doc(seatVerifiedPhoneProofId(eventId, uid));
  const [eventSnap, ledgerSnap, attendeeSnap, attendeeAliasSnap,
    phoneAliasSnap, uidAliasSnap, proofSnap] = await Promise.all([
    tx.get(eventRef), tx.get(ledgerRef), tx.get(attendeeRef),
    tx.get(attendeeAliasRef), tx.get(phoneAliasRef), tx.get(uidAliasRef),
    tx.get(proofRef),
  ]);
  const event = eventSnap.data();
  const ledger = ledgerSnap.data();
  const attendee = attendeeSnap.data();
  const attendeeAlias = attendeeAliasSnap.data();
  const phoneAlias = phoneAliasSnap.data();
  const uidAlias = uidAliasSnap.data();
  const proof = proofSnap.data();
  if (!event || event.clubId !== organizerId ||
      event.organizerId !== undefined && event.organizerId !== organizerId ||
      event.status !== "active" || !ledger || ledger.eventId !== eventId ||
      ledger.state !== "ready" ||
      !Number.isSafeInteger(ledger.revision) || ledger.revision < 1 ||
      ledger.revision >= Number.MAX_SAFE_INTEGER ||
      !Number.isSafeInteger(ledger.migrationRevision) ||
      ledger.migrationRevision < 1 ||
      !attendee || attendee.eventId !== eventId ||
      attendee.organizerId !== organizerId ||
      !["hostImport", "hostManual", "providerSync"]
        .includes(attendee.source) ||
      !["registered", "checkedIn"].includes(attendee.status) ||
      attendee.phoneE164 !== normalized.value ||
      attendee.linkedUid !== null && attendee.linkedUid !== uid) {
    fail("Current guest seat source is unavailable.");
  }
  const matching = (alias: FirebaseFirestore.DocumentData | undefined,
    kind: AliasKind, value: string) => alias &&
      alias.eventId === eventId && alias.organizerId === organizerId &&
      alias.kind === kind &&
      alias.valueHash === seatIdentityValueHash(kind, value) &&
      alias.state === "ready" &&
      alias.migrationRevision === ledger.migrationRevision &&
      validId(alias.canonicalKey) &&
      Number.isSafeInteger(alias.identityRevision) &&
      alias.identityRevision >= 1;
  if (!matching(attendeeAlias, "attendee", attendeeId) ||
      !matching(phoneAlias, "phone", normalized.value) ||
      attendeeAlias!.canonicalKey !== phoneAlias!.canonicalKey ||
      attendeeAlias!.identityRevision !== phoneAlias!.identityRevision) {
    fail("Guest aliases are not reconciled.");
  }
  const key = attendeeAlias!.canonicalKey as string;
  const reference = attendee.externalReference;
  if (reference !== null &&
      (typeof reference !== "string" || !reference.trim())) {
    fail("Imported reference is malformed.");
  }
  const external = typeof reference === "string" ?
    reference.trim().toLowerCase() : null;
  const reservationId = hash([eventId, key]);
  const [reservationSnap, externalSnap] = await Promise.all([
    tx.get(db.collection("eventSeatReservations").doc(reservationId)),
    external === null ? Promise.resolve(null) :
      tx.get(db.collection("eventSeatIdentityAliases")
        .doc(seatIdentityAliasId(eventId, "external", external))),
  ]);
  const reservation = reservationSnap.data();
  if (external !== null) {
    const alias = externalSnap?.data();
    if (!matching(alias, "external", external) ||
        alias!.canonicalKey !== key ||
        alias!.identityRevision !== attendeeAlias!.identityRevision) {
      fail("Imported reference is not reconciled to this guest seat.");
    }
  }
  if (!reservation || reservation.eventId !== eventId ||
      reservation.canonicalKey !== key || reservation.active !== true ||
      reservation.identityRevision !== attendeeAlias!.identityRevision) {
    fail("Guest reservation is unavailable.");
  }
  if (uidAlias || proof || attendee.linkedUid === uid) {
    if (attendee.linkedUid !== uid ||
        !matching(uidAlias, "uid", uid) ||
        uidAlias!.canonicalKey !== key ||
        uidAlias!.identityRevision !== attendeeAlias!.identityRevision ||
        !proof || proof.eventId !== eventId ||
        proof.organizerId !== organizerId || proof.uid !== uid ||
        proof.phoneE164 !== normalized.value ||
        proof.migrationRevision !== ledger.migrationRevision ||
        proof.state !== "current") {
      fail("Verified UID already has another seat or stale evidence.");
    }
    return {canonicalKey: key, ledgerRevision: ledger.revision,
      replayed: true, apply: () => undefined};
  }
  let applied = false;
  return {canonicalKey: key, ledgerRevision: ledger.revision + 1,
    replayed: false, apply: () => {
      if (applied) throw new Error("Guest seat link already staged.");
      applied = true;
      tx.create(uidAliasRef, {eventId, organizerId, kind: "uid",
        valueHash: seatIdentityValueHash("uid", uid), canonicalKey: key,
        identityRevision: attendeeAlias!.identityRevision,
        migrationRevision: ledger.migrationRevision, state: "ready"});
      tx.create(proofRef, {eventId, organizerId, uid,
        phoneE164: normalized.value,
        migrationRevision: ledger.migrationRevision, state: "current"});
      tx.update(attendeeRef, {linkedUid: uid, linkedAt: now, updatedAt: now});
      tx.update(ledgerRef, {revision: ledger.revision + 1});
    }};
}

export async function linkVerifiedUidToGuestSeat(params: Parameters<
  typeof prepareVerifiedUidGuestSeatLink>[0]): Promise<{
  canonicalKey: string; ledgerRevision: number; replayed: boolean}> {
  const prepared = await prepareVerifiedUidGuestSeatLink(params);
  prepared.apply();
  return {canonicalKey: prepared.canonicalKey,
    ledgerRevision: prepared.ledgerRevision, replayed: prepared.replayed};
}
