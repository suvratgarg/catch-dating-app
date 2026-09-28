import {
  assertPaymentRouteSnapshot,
  type PaymentRoutingSnapshot,
} from "../../payments/paymentRouting";
import {assertRazorpayCollectionRoutingCurrent} from
  "../../payments/razorpayCollectionRouting";
import {createHash} from "node:crypto";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {ConfigureEventRegistrationCallablePayload as Command} from
  "../../shared/generated/configureEventRegistrationCallablePayload";
import type {ConfigureEventRegistrationCallableResponse as Result} from
  "../../shared/generated/configureEventRegistrationCallableResponse";
import {validateEventRegistrationReceiptDocument} from
  "../../shared/generated/validators/eventRegistrationReceiptDocument";
import {validateConfigureEventRegistrationCallablePayload} from
  "../../shared/generated/validators/configureEventRegistrationInput";
import {readRegistrationManager} from "./authority";
import {canonicalJson} from "../eventSetupPreferences/resolve";
import {readSeatMigrationWriterFence} from "../seatMigrationPaged";
import {
  assertPublicRegistrationPolicy,
  registrationUnavailable,
} from "./policy";

/** An explicit, revision-checked opt-in; origin and booking provenance survive
 * every transition. Closing remains possible even after the event ends.
 */
export async function configureEventRegistration(input: {
  db: FirebaseFirestore.Firestore;
  actorUid: string;
  command: Command;
  nowMillis?: () => number;
  routing?: PaymentRoutingSnapshot;
}): Promise<Result> {
  const {db, actorUid, command} = input;
  if (
    !validateConfigureEventRegistrationCallablePayload(command) ||
    !/^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/u.test(actorUid)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid registration change.",
    );
  }
  const requestHash = createHash("sha256")
    .update(canonicalJson({actorUid, ...command}))
    .digest("hex");
  const receiptId = registrationChangeReceiptId(command);
  return db.runTransaction(async (tx) => {
    const eventRef = db.collection("events").doc(command.eventId);
    const receiptRef = db
      .collection("eventRegistrationReceipts")
      .doc(receiptId);
    const [{event, organizer}, receiptSnap] = await Promise.all([
      readRegistrationManager({
        db,
        tx,
        actorUid,
        eventId: command.eventId,
        organizerId: command.organizerId,
      }),
      tx.get(receiptRef),
    ]);
    if (receiptSnap.exists) {
      const receipt = receiptSnap.data();
      if (
        !validateEventRegistrationReceiptDocument(receipt) ||
        receipt.requestHash !== requestHash ||
        receipt.actorUid !== actorUid ||
        receipt.eventId !== command.eventId ||
        receipt.organizerId !== command.organizerId
      ) {
        throw new HttpsError(
          "already-exists",
          "Request identity was reused.",
        );
      }
      return {
        eventId: command.eventId,
        registrationRevision: receipt.registrationRevision,
        mode: receipt.mode,
        replayed: true,
      };
    }
    const revision = event.publicRegistrationRevision ?? 0;
    if (
      revision !== command.expectedRegistrationRevision ||
      revision >= Number.MAX_SAFE_INTEGER
    ) {
      throw new HttpsError(
        "aborted",
        "Registration changed. Refresh and retry.",
      );
    }
    const now = (input.nowMillis ?? Date.now)();
    if (command.mode !== "closed") {
      assertPublicRegistrationPolicy(event, organizer, command.mode, now);
      if (
        command.mode === "paid" &&
        (await readSeatMigrationWriterFence({
          db,
          tx,
          eventId: command.eventId,
        })) !== "ready"
      ) {
        registrationUnavailable(
          "Reconcile event seats before opening checkout.",
        );
      }
    }
    if (command.mode === "paid") {
      if (!input.routing) {
        registrationUnavailable("Configure event payments first.");
      }
      assertPaymentRouteSnapshot(input.routing, {
        organizerId: command.organizerId,
        purpose: "eventAdmission",
        currency: "INR",
        amountMinor: event.priceInPaise!,
      });
      await assertRazorpayCollectionRoutingCurrent({
        db,
        tx,
        snapshot: input.routing,
        nowMillis: now,
      });
    }
    const next = revision + 1;
    const receipt = {
      organizerId: command.organizerId,
      eventId: command.eventId,
      actorUid,
      requestHash,
      registrationRevision: next,
      mode: command.mode,
      createdAt: Timestamp.fromMillis(now),
    };
    if (!validateEventRegistrationReceiptDocument(receipt)) {
      throw new HttpsError("internal", "Invalid registration receipt.");
    }
    tx.update(eventRef, {
      publicRegistrationMode: command.mode,
      publicRegistrationEnabled: command.mode !== "closed",
      publicRegistrationRevision: next,
      updatedAt: Timestamp.fromMillis(now),
    });
    tx.create(receiptRef, receipt);
    return {
      eventId: command.eventId,
      registrationRevision: next,
      mode: command.mode,
      replayed: false,
    };
  });
}

export function registrationChangeReceiptId(
  command: Pick<Command, "organizerId" | "requestId">,
): string {
  return createHash("sha256")
    .update(JSON.stringify([command.organizerId, command.requestId]))
    .digest("hex");
}
