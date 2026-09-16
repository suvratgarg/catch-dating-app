import assert from "node:assert/strict";
import test from "node:test";
import type {Request} from "firebase-functions/v2/https";
import type {Response} from "express";
import {eventAssistanceSmsDeliveryWebhookHandler as handler} from
  "./smsDeliveryWebhook";
import type {SmsReportResult} from "./smsDeliveryReports";

const report = {msg_id: "catchSms1" + "a".repeat(64),
  extra: "b".repeat(48), externalId: "123456-789012", deliveredTS: "1000000",
  status: "SUCCESS", cause: "SUCCESS", errCode: "000",
  phoneNo: "919999999999", noOfFrags: "1", mask: "CATCHS"};
const target = "/?" + new URLSearchParams(report);

function harness() {
  const replies: {status: number; body: unknown}[] = [];
  const headers: Record<string, string> = {};
  const received: Record<string, string>[] = [];
  const failures: unknown[][] = [];
  let status = 200;
  const response = {
    set: (key: string | Record<string, string>, value?: string) => {
      if (typeof key === "string") headers[key] = value!;
      else Object.assign(headers, key);
      return response;
    },
    status: (code: number) => {
      status = code; return response;
    },
    send: (body: unknown) => {
      replies.push({status, body}); return response;
    },
  };
  const request = {method: "GET", originalUrl: target, headers: {},
    rawBody: Buffer.alloc(0)};
  const control: {enabled: boolean; result: SmsReportResult;
    error: Error | null} = {enabled: true, result: {kind: "recorded",
      messageId: "private-message", disposition: "applied"}, error: null};
  const deps = {enabled: () => control.enabled,
    receive: async (query: Record<string, string>):
      Promise<SmsReportResult> => {
      received.push(query);
      if (control.error) throw control.error;
      return control.result;
    }, failed: (...args: unknown[]) => {
      failures.push(args);
    }};
  const run = (change: object = {}) => handler(
    {...request, ...change} as Request, response as unknown as Response, deps);
  return {run, received, replies, headers, failures, control, deps,
    request, response};
}

test("disabled callback does not inspect credentials or open the receiver",
  async () => {
    const h = harness();
    h.control.enabled = false;
    await handler({get originalUrl() {
      throw new Error("Must not inspect a disabled callback");
    }} as unknown as Request, h.response as unknown as Response, h.deps);
    assert.deepEqual(h.received, []);
    assert.deepEqual(h.failures, []);
    assert.deepEqual(h.replies, [{status: 503, body: "Unavailable"}]);
    assert.equal(h.headers["Retry-After"], "30");
  });

test("GET callbacks decode exact fields and never echo private report data",
  async () => {
    const h = harness();
    await h.run();
    assert.deepEqual({...h.received[0]}, report);
    assert.equal(Object.getPrototypeOf(h.received[0]), null);
    assert.deepEqual(h.replies, [{status: 200, body: "ok"}]);
    assert.match(h.headers["Cache-Control"], /no-store/);
    assert.equal(h.headers["Referrer-Policy"], "no-referrer");
    assert.equal(h.headers["Content-Type"], "text/plain; charset=utf-8");
    assert.equal(h.headers["X-Content-Type-Options"], "nosniff");
    assert.deepEqual(h.failures, []);
  });

test("POST, body credentials and forwarded identity cannot replace GET proof",
  async () => {
    const methods = ["POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"];
    for (const method of methods) {
      const h = harness();
      await h.run({method, body: report});
      assert.equal(h.replies[0].status, 405);
      assert.equal(h.headers.Allow, "GET");
      assert.deepEqual(h.received, []);
    }
    for (const change of [
      {rawBody: Buffer.from("body")}, {rawBody: ""},
      {headers: {"content-length": "1"}},
      {headers: {"transfer-encoding": "chunked"}},
      {originalUrl: "/", query: report, body: report},
      {originalUrl: "/?externalId=123456-789012", headers: {
        "authorization": report.extra, "x-forwarded-user": "provider"}},
    ]) {
      const h = harness();
      await h.run(change);
      assert.equal(h.replies[0].status, 400);
      assert.deepEqual(h.received, []);
    }
    const h = harness();
    await h.run({headers: {"content-length": "0"}});
    assert.equal(h.replies[0].status, 200);
  });

test("duplicate, nested, unexpected and malformed query fields fail before I/O",
  async () => {
    for (const suffix of [
      ...Object.keys(report).map((key) => "&" + key + "=" +
        report[key as keyof typeof report]),
      "&%6dsg_id=" + report.msg_id, "&extra[]=wrong", "&extra[0]=wrong",
      "&__proto__=provider", "&password=secret", "#fragment",
    ]) {
      const h = harness();
      await h.run({originalUrl: target + suffix});
      assert.equal(h.replies[0].status, 400, suffix);
      assert.deepEqual(h.received, []);
    }
    for (const [key, value] of [
      ["extra", "bad"], ["externalId", report.externalId + "\n"],
      ["status", "DELIVERED"], ["deliveredTS", "1.5"],
      ["phoneNo", "+919999999999"], ["cause", "SUCCESS\n"],
      ["errCode", "0\n"], ["mask", "CATCHS\n"],
    ]) {
      const h = harness();
      await h.run({originalUrl: "/?" + new URLSearchParams(
        {...report, [key]: value})});
      assert.equal(h.replies[0].status, 400, key);
      assert.deepEqual(h.received, []);
    }
  });

test("request target is byte bounded before decoding or accessing the store",
  async () => {
    for (const value of ["a".repeat(4097), "界".repeat(1400)]) {
      const h = harness();
      await h.run({originalUrl: "/?" + value});
      assert.equal(h.replies[0].status, 414);
      assert.deepEqual(h.received, []);
    }
  });

test("receiver rejection is opaque; indeterminate and duplicate reports ack",
  async () => {
    for (const result of [
      {kind: "rejected"}, {kind: "unconfirmed", messageId: "private-message"},
      ...["applied", "duplicateOrOlder", "conflictingEvidence"].map(
        (disposition) => ({kind: "recorded", messageId: "private-message",
          disposition})),
    ] as SmsReportResult[]) {
      const h = harness();
      h.control.result = result;
      await h.run();
      assert.deepEqual(h.replies, [result.kind === "rejected" ?
        {status: 403, body: "Invalid report"} : {status: 200, body: "ok"}]);
      assert.deepEqual(h.failures, []);
    }
  });

test("callback acknowledgement waits for the receiver's commit",
  async () => {
    const h = harness();
    let release!: (value: SmsReportResult) => void;
    const committed = new Promise<SmsReportResult>((resolve) => {
      release = resolve;
    });
    const running = handler(h.request as Request,
      h.response as unknown as Response, {...h.deps,
        receive: () => committed});
    await Promise.resolve();
    assert.deepEqual(h.replies, []);
    release(h.control.result);
    await running;
    assert.deepEqual(h.replies, [{status: 200, body: "ok"}]);
  });

test("transient failures request retry without logging credentials or errors",
  async () => {
    const h = harness();
    h.control.error = new Error(target + " private provider data");
    await h.run();
    assert.deepEqual(h.failures, [[]]);
    assert.deepEqual(h.replies, [{status: 503, body: "Unavailable"}]);
    assert.equal(h.headers["Retry-After"], "30");
    h.control.error = null;
    await h.run();
    assert.deepEqual(h.replies[1], {status: 200, body: "ok"});
    assert.deepEqual(h.failures, [[]]);
  });
