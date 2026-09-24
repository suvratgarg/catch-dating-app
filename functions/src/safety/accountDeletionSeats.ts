import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventParticipationDocument} from
  "../shared/generated/firestoreAdminTypes";
import {readSeatMigrationWriterFence} from
  "../events/seatMigrationPaged";
import {FirestoreSeatIdentityAuthority, seatIdentityAliasId,
  seatVerifiedPhoneProofId} from
  "../events/seatIdentityAuthority";
import {applyFirestoreSeat, deriveEventSeatPolicy, FirestoreSeatTransaction,
  prepareFirestoreSeat} from "../events/seatAuthority/firestoreAdapter";

const ID = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/u;

function unavailable(message: string): never {
  throw new HttpsError("failed-precondition", message);
}

function decrement(value: unknown, label: string): number {
  if (!Number.isSafeInteger(value) || Number(value) < 1) {
    unavailable(`${label} needs reconciliation before account deletion.`);
  }
  return Number(value) - 1;
}

function legacyEventPatch(participation: EventParticipationDocument):
  Record<string, unknown> {
  switch (participation.status) {
  case "signedUp": {
    const patch: Record<string, unknown> = {
      bookedCount: admin.firestore.FieldValue.increment(-1),
    };
    if (participation.genderAtSignup) {
      patch[`genderCounts.${participation.genderAtSignup}`] =
        admin.firestore.FieldValue.increment(-1);
    }
    return patch;
  }
  case "waitlisted":
    return {waitlistedCount: admin.firestore.FieldValue.increment(-1)};
  case "attended":
    return {checkedInCount: admin.firestore.FieldValue.increment(-1)};
  default:
    return {};
  }
}

/**
 * Each participation is removed under the same migration fence as booking.
 * The caller must finish this before unlinking retained Host attendees.
 */
export async function deleteAccountEventParticipations(params: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  now: FirebaseFirestore.FieldValue;
  nowMillis: number;
}): Promise<void> {
  const {db, uid, now, nowMillis} = params;
  if (!ID.test(uid) || !Number.isSafeInteger(nowMillis) || nowMillis < 0) {
    unavailable("Account deletion seat scope is invalid.");
  }
  const participations = await db.collection("eventParticipations")
    .where("uid", "==", uid).get();
  for (const found of participations.docs) {
    await db.runTransaction(async (tx) => {
      const currentSnap = await tx.get(found.ref);
      const current = currentSnap.data() as EventParticipationDocument |
        undefined;
      if (!current) return;
      const eventId = current.eventId;
      if (current.uid !== uid || !ID.test(eventId)) {
        unavailable("Current participation identity is malformed.");
      }
      const eventRef = db.collection("events").doc(eventId);
      const eventSnap = await tx.get(eventRef);
      const event = eventSnap.data();
      const seatMode = await readSeatMigrationWriterFence({db, tx, eventId});
      const status = current.status;
      if (!["signedUp", "attended", "waitlisted", "cancelled", "deleted"]
        .includes(status)) {
        unavailable("Participation status is malformed.");
      }
      if (status === "deleted") {
        if (seatMode === "ready") {
          const uidAlias = (await tx.get(db.collection(
            "eventSeatIdentityAliases").doc(seatIdentityAliasId(eventId,
            "uid", uid)))).data();
          if (uidAlias?.state === "ready") {
            const reservation = await new FirestoreSeatTransaction(db, tx)
              .reservation(eventId, uidAlias.canonicalKey);
            if (reservation?.active) {
              unavailable("Deleted participation still owns an active seat.");
            }
          }
        }
        return;
      }
      if (seatMode === "legacy") {
        const patch = legacyEventPatch(current);
        if (Object.keys(patch).length > 0) {
          if (!event) unavailable("Event aggregate is unavailable.");
          tx.update(eventRef, patch);
        }
        tx.set(found.ref, {status: "deleted", updatedAt: now,
          deletedAt: now}, {merge: true});
        return;
      }
      if (!event || !ID.test(event.clubId) ||
          event.organizerId !== undefined &&
          event.organizerId !== event.clubId ||
          current.clubId !== event.clubId ||
          current.organizerId !== undefined &&
          current.organizerId !== event.clubId) {
        unavailable("Ready event or participation tenant is malformed.");
      }
      const ledgerTx = new FirestoreSeatTransaction(db, tx);
      const ledger = await ledgerTx.ledger(eventId);
      if (!ledger || ledger.state !== "ready" ||
          !Number.isSafeInteger(ledger.occupied) ||
          ledger.occupied < 0) {
        unavailable("Ready seat ledger is unavailable.");
      }
      const policy = deriveEventSeatPolicy(event);
      if (policy.organizerId !== event.clubId ||
          policy.capacity !== ledger.capacity ||
          policy.policyHash !== ledger.policyHash ||
          policy.policyVersion !== ledger.policyVersion) {
        unavailable("Event seat policy needs reconciliation.");
      }
      const active = status === "signedUp" || status === "attended";
      let retainHostSeat = false;
      const catchRows: FirebaseFirestore.QueryDocumentSnapshot[] = [];
      const identity = await new FirestoreSeatIdentityAuthority().resolve({
        db, tx, eventId, organizerId: event.clubId,
        subject: {kind: "verifiedUid", uid},
      });
      if (!identity) unavailable("Current Catch seat is unresolved.");
      const proofRef = db.collection("eventSeatVerifiedPhones")
        .doc(seatVerifiedPhoneProofId(eventId, uid));
      const proof = (await tx.get(proofRef)).data();
      const uidAliasRef = db.collection("eventSeatIdentityAliases")
        .doc(seatIdentityAliasId(eventId, "uid", uid));
      if (!proof || proof.state !== "current" ||
          !(proof.phoneE164 === null ||
            typeof proof.phoneE164 === "string")) {
        unavailable("Current verified phone proof is unavailable.");
      }
      let seatPreparation: Awaited<ReturnType<
        typeof prepareFirestoreSeat>> | null = null;
      if (active) {
        const reservation = await ledgerTx.reservation(eventId, identity.key);
        if (!reservation?.active ||
            reservation.identityRevision !== identity.revision) {
          unavailable("Current Catch reservation is unavailable.");
        }
        const guests = await tx.get(db.collection("eventAttendees")
          .where("eventId", "==", eventId)
          .where("linkedUid", "==", uid).limit(3));
        if (guests.docs.length > 2) {
          unavailable("Linked attendee sources need reconciliation.");
        }
        const independent = guests.docs.filter((guest) => {
          const row = guest.data();
          if (!["registered", "checkedIn"].includes(row.status)) {
            return false;
          }
          if (!["catchBooking", "hostImport", "hostManual", "webOtp",
            "providerSync"].includes(row.source)) {
            unavailable("Linked attendee source needs reconciliation.");
          }
          if (row.source === "catchBooking") {
            catchRows.push(guest);
            return false;
          }
          return true;
        });
        if (independent.length > 1 || catchRows.length > 1) {
          unavailable("Linked Host seats need reconciliation.");
        }
        for (const guest of [...independent, ...catchRows]) {
          const hostIdentity = await new FirestoreSeatIdentityAuthority()
            .resolve({db, tx, eventId, organizerId: event.clubId,
              subject: {kind: "importAttendee",
                attendeeId: guest.id}});
          if (!hostIdentity || hostIdentity.key !== identity.key ||
              hostIdentity.revision !== identity.revision) {
            unavailable("Linked attendee seat needs reconciliation.");
          }
        }
        retainHostSeat = independent.length === 1;
        if (!retainHostSeat) {
          const requestId = "delete_" + createHash("sha256")
            .update(`${eventId}\u001f${uid}\u001f${reservation.revision}`)
            .digest("hex").slice(0, 48);
          seatPreparation = await prepareFirestoreSeat({db, tx,
            identityAuthority: {resolve: async () => identity},
            command: {eventId, subject: {kind: "verifiedUid" as const, uid},
              operation: "release", requestId,
              expectedLedgerRevision: ledger.revision,
              expectedCapacityRevision: ledger.capacityRevision,
              expectedMigrationRevision: ledger.migrationRevision,
              expectedReservationRevision: reservation.revision,
              nowMillis}});
        }
      }
      const patch: Record<string, unknown> = {};
      if (active) {
        const expected = ledger.occupied - (retainHostSeat ? 0 : 1);
        if (expected < 0) unavailable("Seat count needs reconciliation.");
        patch.bookedCount = expected;
        if (current.genderAtSignup) {
          const genders = event.genderCounts;
          if (!genders || typeof genders !== "object" ||
              Array.isArray(genders)) {
            unavailable("Event gender counts need reconciliation.");
          }
          patch[`genderCounts.${current.genderAtSignup}`] = decrement(
            genders[current.genderAtSignup], "Event gender count");
        }
      }
      if (status === "attended") {
        patch.checkedInCount = decrement(event.checkedInCount,
          "Event check-in count");
      } else if (status === "waitlisted") {
        patch.waitlistedCount = decrement(event.waitlistedCount,
          "Event waitlist count");
      }
      // Every authority read, including imported-seat proof, precedes writes.
      if (seatPreparation) applyFirestoreSeat(seatPreparation);
      tx.update(uidAliasRef, {state: "retired"});
      tx.update(proofRef, {phoneE164: null, state: "revoked"});
      if (active && !retainHostSeat && proof.phoneE164 !== null) {
        tx.update(db.collection("eventSeatIdentityAliases")
          .doc(seatIdentityAliasId(eventId, "phone", proof.phoneE164)),
        {state: "retired"});
      }
      for (const catchRow of catchRows) {
        tx.update(catchRow.ref, {status: "cancelled", updatedAt: now});
      }
      if (Object.keys(patch).length > 0) tx.update(eventRef, patch);
      tx.set(found.ref, {status: "deleted", updatedAt: now,
        deletedAt: now}, {merge: true});
    });
  }
}
