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

test("manager refresh is merchant-bound before any credential access",
  async () => {
    const h = harness();
    const connectionId = `rpc_${"a".repeat(32)}`;
    const path = `organizerPaymentConnections/${connectionId}`;
    const connection = h.store.records.get(
      "organizerPaymentConnections/connection")!;
    h.store.records.set(path, {...connection, organizerId: "another-org"});
    const input = request({organizerId: "org", action: "refresh",
      connectionId}, "host");
    await assert.rejects(manageOrganizerFormPaymentConnectionHandler(input,
      h.deps), /unavailable/u);
    assert.equal(h.runtimeCalls(), 0);
    h.store.records.set(path, {...connection});
    h.deps.configured = () => true;
    let refreshes = 0;
    h.deps.runtime = async () => ({credentials: {
      access: async (binding: unknown) => {
        assert.deepEqual(binding, {organizerId: "org", connectionId,
          accountId: "acc_merchant", mode: "test"});
        refreshes++;
      }}} as unknown as Awaited<ReturnType<typeof h.deps.runtime>>);
    const result = await manageOrganizerFormPaymentConnectionHandler(
      input, h.deps);
    assert.equal(refreshes, 1);
    assert.equal(result.available, true);
    assert.equal(result.connections.find((value) =>
      value.connectionId === connectionId)?.status,
    "ready");
    h.store.records.set(path, {...connection, status: "disconnected"});
    await manageOrganizerFormPaymentConnectionHandler(input, h.deps);
    assert.equal(refreshes, 1,
      "Checking a disconnected account cannot reconnect it");
  });
