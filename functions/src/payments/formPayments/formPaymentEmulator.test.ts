import assert from "node:assert/strict";
import test from "node:test";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import {createFormPaymentFixture} from "./formPaymentTestStore";
import {reserveFormPayment, finalizeCapturedFormPayment,
  expireFormPaymentReservation} from "./formPaymentSubmission";

const emulator = process.env.FIRESTORE_EMULATOR_HOST;

test("Firestore serializes payment reservations, finalization and late capture",
  {skip: !emulator}, async () => {
    assert.match(emulator!, /^(127\.0\.0\.1|localhost):[0-9]+$/u);
    const app = initializeApp({projectId: "demo-catch-form-payments"},
      `form-payments-${Date.now()}`);
    const db = getFirestore(app);
    const fixture = createFormPaymentFixture();
    const collections = ["organizerForms", "organizerFormVersions",
      "organizerFormResponseDrafts", "organizerPaymentConnections",
      "organizerFormPayments", "organizerFormResponses"];
    try {
      for (const name of collections) {
        await db.recursiveDelete(db.collection(name));
      }
      const seed = db.batch();
      for (const [path, value] of fixture.store.records) {
        seed.set(db.doc(path), value);
      }
      await seed.commit();
      const now = Timestamp.fromMillis(1000);
      const reserve = () => reserveFormPayment({db, request: fixture.request,
        data: fixture.data, now});
      const [first, replay] = await Promise.all([reserve(), reserve()]);
      assert.equal(first.paymentId, replay.paymentId);
      assert.equal((await db.doc("organizerForms/form").get())
        .get("pendingPaymentCount"), 1);
      await db.doc("organizerFormResponseDrafts/other").set({
        ...fixture.draft, respondentUid: "other"});
      await assert.rejects(reserveFormPayment({db, now,
        data: {...fixture.data, draftId: "other"},
        request: {auth: {uid: "other",
          token: {phone_number: "+919000000002"}}} as
          unknown as CallableRequest<unknown>,
      }));
      const paymentRef = db.doc(`organizerFormPayments/${first.paymentId}`);
      await paymentRef.update({status: "captured", capturedAt: now,
        providerOrderId: "order_one", providerPaymentId: "pay_one"});
      await Promise.all([
        finalizeCapturedFormPayment({db, now, paymentId: first.paymentId}),
        finalizeCapturedFormPayment({db, now, paymentId: first.paymentId}),
      ]);
      const form = await db.doc("organizerForms/form").get();
      assert.equal(form.get("pendingPaymentCount"), 0);
      assert.equal(form.get("submittedResponseCount"), 1);
      assert.equal(
        (await db.collection("organizerFormResponses").get()).size, 1);
      assert.equal((await paymentRef.get()).get("reservationReleased"), true);

      // A separate frozen checkout expires. Later captured funds must not
      // create another response, even if two recovery workers race.
      await db.doc("organizerForms/form").update({submittedResponseCount: 0});
      const late = await reserveFormPayment({db, now,
        data: {...fixture.data, draftId: "other"},
        request: {auth: {uid: "other",
          token: {phone_number: "+919000000002"}}} as
          unknown as CallableRequest<unknown>});
      await expireFormPaymentReservation({db, paymentId: late.paymentId,
        now: late.payment.checkoutExpiresAt});
      const lateRef = db.doc(`organizerFormPayments/${late.paymentId}`);
      await lateRef.update({status: "captured", capturedAt: now,
        providerOrderId: "order_late", providerPaymentId: "pay_late"});
      await Promise.all([
        finalizeCapturedFormPayment({db, now, paymentId: late.paymentId}),
        finalizeCapturedFormPayment({db, now, paymentId: late.paymentId}),
      ]);
      assert.equal((await lateRef.get()).get("status"), "refundPending");
      assert.equal(
        (await db.collection("organizerFormResponses").get()).size, 1);
      assert.equal((await db.doc("organizerForms/form").get())
        .get("pendingPaymentCount"), 0);
    } finally {
      for (const name of collections) {
        await db.recursiveDelete(db.collection(name));
      }
      await deleteApp(app);
    }
  });
