import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {EventDocument} from "../../shared/generated/firestoreAdminTypes";
import {eventId} from "../../organizerFormAdmission/admissionTestFixture";
import {setup, capturedFixture} from "./offerPaymentTestFixture";
import {offerCancellationPolicy, offerGuestCancellationQuote} from
  "./offerCancellationPolicy";
import {reserveOfferPayment, parseOfferPayment, OFFER_PAYMENT_COLLECTION}
  from "./offerPaymentReservation";

test("cash deadline uses each canonical event policy", async () => {
  const start = 100 * 24 * 3600_000;
  for (const [policyId, hours] of [["flexible", 6], ["standard", 24],
    ["strict", 72]] as const) {
    const event = {startTime: Timestamp.fromMillis(start), capacityLimit: 10,
      priceInPaise: 10000, eventPolicy: {version: 2, admission:
        {capacityLimit: 10},
      pricing: {basePriceInPaise: 10000}, cancellation: {policyId}}} as
          unknown as EventDocument;
    assert.deepEqual(offerCancellationPolicy(event), {
      refundDeadlineMillis: start - hours * 3600_000, eventStartsAtMillis:
        start});
  }
});

test("changed reviewed terms fail before any hold or payment write",
  async () => {
    const h = await setup();
    const policy = offerCancellationPolicy(h.store.get(`events/${eventId}`) as
    unknown as EventDocument);
    const before = JSON.stringify([...h.store.rows]);
    await assert.rejects(reserveOfferPayment({db: h.store.db(), grantId:
    h.invitation.grantId,
    uid: "recipient1", requestId: "checkout_request1", routing: h.routing,
    cancellationPolicy: {...policy, refundDeadlineMillis:
      policy.refundDeadlineMillis + 1},
    nowMillis: () => 2000, loadCurrentAuthUser: h.auth}), {code:
      "failed-precondition"});
    assert.equal(JSON.stringify([...h.store.rows]), before);
  });

test("cash deadline is inclusive; event start closes cancellation",
  async () => {
    const h = await capturedFixture(); await h.finalize();
    const row = h.store.get(`${OFFER_PAYMENT_COLLECTION}/${h.paymentId}`)!;
    row.cancellationPolicy = {refundDeadlineMillis: 3000, eventStartsAtMillis:
    5000};
    const payment = parseOfferPayment(row, h.paymentId);
    assert.deepEqual(offerGuestCancellationQuote(payment, 3000),
      {refundAmountPaise: 10000});
    assert.deepEqual(offerGuestCancellationQuote(payment, 3001),
      {refundAmountPaise: 0});
    assert.equal(offerGuestCancellationQuote(payment, 5000), null);
  });

test("minimal and external offers use cash terms without inventing base price",
  () => {
    const start = 100 * 24 * 3600_000;
    for (const fields of [{}, {priceInPaise: 0,
      eventPolicy: {cancellation: {policyId: "notApplicable"}}}]) {
      const event = {startTime: Timestamp.fromMillis(start), ...fields} as
        unknown as EventDocument;
      const before = JSON.stringify(event);
      assert.deepEqual(offerCancellationPolicy(event), {
        refundDeadlineMillis: start - 24 * 3600_000,
        eventStartsAtMillis: start});
      assert.equal(JSON.stringify(event), before);
    }
  });
