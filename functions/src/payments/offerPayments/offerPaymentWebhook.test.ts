import assert from "node:assert/strict";
import test from "node:test";
import {setup} from "./offerPaymentTestFixture";
import {OFFER_PAYMENT_COLLECTION} from "./offerPaymentReservation";
import type {OrganizerEventOfferPaymentDocument as Payment} from
  "../../shared/generated/firestoreAdminTypes";
import {processVerifiedOfferPaymentOrder} from "./offerPaymentWebhook";

async function fixture() {
  const h = await setup();
  const {paymentId} = await h.reserve();
  const row = h.store.get(`${OFFER_PAYMENT_COLLECTION}/${paymentId}`)!;
  const db = {collection: (collection: string) => ({doc: (id: string) => ({
    get: async () => {
      assert.equal(collection, OFFER_PAYMENT_COLLECTION);
      assert.equal(id, paymentId);
      return {exists: true, data: () => row};
    },
  })})} as unknown as FirebaseFirestore.Firestore;
  const input = {db, order: {id: "order_one", receipt: paymentId, amount: 10000,
    currency: "INR" as const, status: "paid" as const},
  providerPaymentId: "pay_one", accountId: "acc_platform",
  mode: "test" as const, route: "razorpayRoute" as const};
  let reconciled = 0;
  const execution = async () => ({reconcile: async (id?: string) => {
    assert.equal(id, "pay_one"); reconciled++;
    return {...row, status: "admitted",
      providerOrderId: "order_one"} as Payment;
  }});
  return {input, execution, row, reconciled: () => reconciled};
}

test("signed offer order routes only to its frozen account, mode and amount",
  async () => {
    const h = await fixture();
    for (const patch of [{accountId: "acc_other"}, {mode: "live" as const},
      {route: "razorpayOAuth" as const},
      {order: {...h.input.order, amount: 999}}]) {
      await assert.rejects(processVerifiedOfferPaymentOrder(
        {...h.input, ...patch}, h.execution));
    }
    assert.equal(h.reconciled(), 0);
    assert.equal(await processVerifiedOfferPaymentOrder(h.input,
      h.execution), true);
    assert.equal(h.reconciled(), 1);
  });

test("offer webhook stays pending while order creation owns its lease",
  async () => {
    const h = await fixture();
    await assert.rejects(processVerifiedOfferPaymentOrder(h.input,
      async () => ({reconcile: async () => h.row as unknown as Payment})),
    /recovery is pending/u);
    assert.equal(await processVerifiedOfferPaymentOrder({...h.input,
      order: {...h.input.order, receipt: "unrelated"}}, h.execution), false);
    assert.equal(h.reconciled(), 0);
  });
