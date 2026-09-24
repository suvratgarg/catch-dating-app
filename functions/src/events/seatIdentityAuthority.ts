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
