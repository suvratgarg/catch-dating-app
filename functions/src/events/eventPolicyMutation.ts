import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument} from "../shared/generated/firestoreAdminTypes";
import {deriveEventSeatPolicy} from "./seatAuthority/firestoreAdapter";
import {heldSeatCount, SeatLedger} from "./seatAuthority/seatAuthority";

/** Keep permitted event policy edits atomic with their capacity authority. */
export async function prepareEventMutationLedger(
  db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction,
  eventId: string,
  before: EventDocument,
  after: EventDocument
): Promise<{update: SeatLedger | null; reserved: number}> {
  const snap = await tx.get(db.collection("eventSeatLedgers").doc(eventId));
  const ledger = snap.data() as SeatLedger | undefined;
  let previous;
  let next;
  try {
    previous = deriveEventSeatPolicy(before);
    next = deriveEventSeatPolicy(after);
  } catch {
    throw new HttpsError("failed-precondition",
      "Invalid seat capacity policy.");
  }
  if (!ledger || ledger.eventId !== eventId || ledger.state !== "ready" ||
      ledger.capacity !== previous.capacity ||
      ledger.policyHash !== previous.policyHash ||
      ledger.policyVersion !== previous.policyVersion ||
      !Number.isSafeInteger(ledger.occupied) || ledger.occupied < 0 ||
      ledger.occupied > ledger.capacity ||
      !Number.isSafeInteger(ledger.revision) || ledger.revision < 1 ||
      ledger.revision >= Number.MAX_SAFE_INTEGER ||
      !Number.isSafeInteger(ledger.capacityRevision) ||
      ledger.capacityRevision < 1 ||
      ledger.capacityRevision >= Number.MAX_SAFE_INTEGER ||
      !Number.isSafeInteger(ledger.migrationRevision) ||
      ledger.migrationRevision < 1 || next.capacity < ledger.occupied) {
    throw new HttpsError("failed-precondition",
      "Seat capacity needs reconciliation before this edit.");
  }
  const reserved = ledger.occupied + heldSeatCount(ledger);
  if (next.capacity < reserved) {
    throw new HttpsError("failed-precondition",
      "Capacity cannot be smaller than confirmed seats and checkout holds.");
  }
  if (previous.policyHash === next.policyHash) {
    return {update: null, reserved};
  }
  if (reserved > 0) {
    throw new HttpsError("failed-precondition",
      "Events with reserved seats cannot change admission policy.");
  }
  return {reserved, update: {...ledger,
    capacity: next.capacity, policyHash: next.policyHash,
    policyVersion: next.policyVersion, revision: ledger.revision + 1,
    capacityRevision: ledger.capacityRevision + 1}};
}

