import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {decideFormPaymentObservation} from "./formPaymentState";
import type {FormProviderPayment} from "./razorpayFormProvider";

const state: Parameters<typeof decideFormPaymentObservation>[0] = {
  status: "checkoutReady", providerOrderId: "order_one",
  providerPaymentId: null,
  amountPaise: 20000, currency: "INR", refundedAmountPaise: 0,
  responseId: null, reservationReleased: false, capturedAt: null,
};
const payment: FormProviderPayment = {id: "pay_one", orderId: "order_one",
  amount: 20000, currency: "INR", status: "captured", captured: true,
  amountRefunded: 0};

test("authorized payments cannot finalize; captured payment can", () => {
  assert.equal(decideFormPaymentObservation(state, {...payment,
    status: "authorized", captured: false}).action, "none");
  assert.equal(decideFormPaymentObservation(state, payment).action, "finalize");
});

test("a failed payment attempt does not prevent a later capture on its order",
  () => {
    const failed = decideFormPaymentObservation(state, {...payment,
      status: "failed", captured: false});
    assert.equal(failed.status, "failed");
    assert.equal(failed.providerPaymentId, null);
    assert.equal(decideFormPaymentObservation({...state, status: failed.status},
      {...payment, id: "pay_second"}).action, "finalize");
  });

test("replaying captured or older observations cannot submit twice", () => {
  const submitted = {...state, status: "submitted" as const,
    responseId: "response", providerPaymentId: payment.id,
    reservationReleased: true, capturedAt: Timestamp.fromMillis(1000)};
  for (const observation of [payment,
    {...payment, status: "failed" as const, captured: false},
    {...payment, status: "authorized" as const, captured: false}]) {
    const decision = decideFormPaymentObservation(submitted, observation);
    assert.equal(decision.action, "none");
    assert.equal(decision.status, "submitted");
  }
});

test("capture after a released reservation requires refund, not admission",
  () => {
    assert.equal(decideFormPaymentObservation({...state, status: "expired",
      reservationReleased: true}, payment).action, "refund");
  });

test("duplicate captures preserve the first payment and require review", () => {
  const decision = decideFormPaymentObservation({...state,
    status: "submitted", responseId: "response", providerPaymentId: "pay_first",
    capturedAt: Timestamp.fromMillis(1000)}, payment);
  assert.equal(decision.action, "review");
  assert.equal(decision.providerPaymentId, "pay_first");
});

test("refunds are monotonic and do not erase the response link", () => {
  const submitted = {...state, status: "submitted" as const,
    responseId: "response", providerPaymentId: payment.id,
    capturedAt: Timestamp.fromMillis(1000)};
  assert.equal(decideFormPaymentObservation(submitted, {...payment,
    status: "refunded", amountRefunded: 20000}).status, "refunded");
  const partial = decideFormPaymentObservation(submitted, {...payment,
    amountRefunded: 10000});
  assert.equal(partial.refundedAmountPaise, 10000);
  const stale = decideFormPaymentObservation({...submitted,
    refundedAmountPaise: 10000}, payment);
  assert.equal(stale.refundedAmountPaise, 10000);
  assert.equal(stale.action, "none");
});

test("foreign orders, currencies and amounts fail closed", () => {
  for (const patch of [{orderId: "order_other"}, {currency: "USD"},
    {amount: 10000}, {amountRefunded: -1}, {amountRefunded: 30000}]) {
    assert.throws(() => decideFormPaymentObservation(state,
      {...payment, ...patch}),
    /does not match/u);
  }
});
