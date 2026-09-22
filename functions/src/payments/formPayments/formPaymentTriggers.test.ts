import assert from "node:assert/strict";
import test from "node:test";
import {createHmac} from "node:crypto";
import type {Request} from "firebase-functions/v2/https";
import type {Response} from "express";
import {createFormPaymentFixture} from "./formPaymentTestStore";
import {organizerFormPaymentOauthCallbackHandler,
  organizerFormPaymentWebhookHandler} from "./formPaymentTriggers";
import type {formPaymentRuntime} from "./formPaymentRuntime";

function response() {
  const state = {status: 0, body: "", headers: {} as Record<string, string>};
  const res = {
    set: (key: string | Record<string, string>, value?: string) => {
      Object.assign(state.headers,
        typeof key === "string" ? {[key]: value} : key); return res;
    },
    status: (value: number) => {
      state.status = value; return res;
    },
    type: () => res,
    send: (value: string) => {
      state.body = value; return res;
    },
  };
  return {state, res: res as unknown as Response};
}

test("HTTP acknowledgement requires a durable verified webhook receipt",
  async () => {
    const h = createFormPaymentFixture();
    const id = `rpc_${"a".repeat(32)}`;
    h.store.records.set(`organizerPaymentConnections/${id}`,
      {...h.store.records.get("organizerPaymentConnections/connection")});
    const secret = "s".repeat(43);
    const rawBody = Buffer.from(JSON.stringify({entity: "event",
      account_id: "acc_merchant", event: "payment.captured",
      payload: {payment: {entity: {entity: "payment", id: "pay_one",
        order_id: "order_one"}}}}));
    let signature = createHmac("sha256", secret).update(rawBody).digest("hex");
    const req = {method: "POST", rawBody, query: {connectionId: id},
      get: (name: string) => name === "x-razorpay-signature" ?
        signature : "event_one"} as unknown as Request;
    const runtime = (async () => ({db: h.db,
      vault: {access: async () => ({webhookSecret: secret})},
    })) as unknown as typeof formPaymentRuntime;
    const first = response();
    h.store.failNextCommit = true;
    await organizerFormPaymentWebhookHandler(req, first.res, runtime);
    assert.equal(first.state.status, 503);
    const retry = response();
    await organizerFormPaymentWebhookHandler(req, retry.res, runtime);
    assert.equal(retry.state.status, 200);
    assert.equal([...h.store.records.keys()].filter((path) =>
      path.startsWith("organizerFormPaymentWebhooks/")).length, 1);
    signature = "0".repeat(64);
    const forged = response();
    await organizerFormPaymentWebhookHandler(req, forged.res, runtime);
    assert.equal(forged.state.status, 400);
  });

test("OAuth callback contains no provider secrets or arbitrary redirects",
  async () => {
    const runtime = (async () => ({connections: {complete: async () => {
      throw new Error("private provider access_token");
    }}})) as unknown as typeof formPaymentRuntime;
    const result = response();
    await organizerFormPaymentOauthCallbackHandler({method: "GET",
      query: {state: "state", code: "code", redirect: "https://attacker.test"},
    } as unknown as Request, result.res, runtime);
    assert.equal(result.state.status, 400);
    assert.equal(result.state.body.includes("access_token"), false);
    assert.equal(result.state.body.includes("attacker"), false);
    assert.equal(result.state.headers["Referrer-Policy"], "no-referrer");
  });
