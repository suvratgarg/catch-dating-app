import assert from "node:assert/strict";
import test from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {createFormPaymentFixture} from "./formPaymentTestStore";
import {getOrganizerFormPaymentHandler, prepareOrganizerFormPaymentHandler,
  manageOrganizerFormPaymentConnectionHandler} from "./formPaymentHandlers";

function request(data: unknown, uid = "person"): CallableRequest<unknown> {
  return {data, auth: {uid, token: {phone_number: "+919000000001"}}} as
    unknown as CallableRequest<unknown>;
}
function harness() {
  const h = createFormPaymentFixture();
  let runtimeCalls = 0;
  const deps: NonNullable<Parameters<
    typeof getOrganizerFormPaymentHandler>[1]> = {
      db: () => h.db, configured: () => false,
      runtime: async () => {
        runtimeCalls++; throw new Error("Provider not configured");
      }, rateLimit: async () => undefined,
      requireManager: async ({actorUid}) => {
        if (actorUid !== "host") throw new Error("Manager required");
      },
    };
  return {...h, deps, runtimeCalls: () => runtimeCalls};
}

test("another respondent cannot reconcile a payment or prepare a draft",
  async () => {
    const h = harness();
    const {paymentId} = await h.reserve();
    await assert.rejects(getOrganizerFormPaymentHandler(request({paymentId,
      callback: null}, "other"), h.deps), /unavailable/u);
    await assert.rejects(prepareOrganizerFormPaymentHandler(
      request(h.data, "other"), h.deps), /unavailable/u);
    assert.equal(h.runtimeCalls(), 0);
  });

test("completed receipt remains readable without provider configuration",
  async () => {
    const h = harness();
    const {paymentId} = await h.reserve();
    h.capture(paymentId);
    await h.finalize(paymentId);
    const value = await getOrganizerFormPaymentHandler(request({paymentId,
      callback: null}), h.deps);
    assert.equal(value.receipt?.completion.title, "Received");
    assert.equal(h.runtimeCalls(), 0);
  });

test("connection actions require manager authority before provider work",
  async () => {
    const h = harness();
    for (const action of ["begin", "disconnect", "list"]) {
      await assert.rejects(manageOrganizerFormPaymentConnectionHandler(
        request({organizerId: "org", action, connectionId: null}), h.deps),
      /Manager required/u);
    }
    assert.equal(h.runtimeCalls(), 0);
    await assert.rejects(getOrganizerFormPaymentHandler(request({
      paymentId: "../../other", callback: null}), h.deps));
    await assert.rejects(getOrganizerFormPaymentHandler({data: {}} as
      CallableRequest<unknown>, h.deps), /signed in/u);
  });
