import assert from "node:assert/strict";
import test from "node:test";
import {probePage} from "./probeProduction.mjs";

const contract = {
  path: "/privacy/",
  title: "Privacy policy | Catch",
  canonicalPath: "/privacy/",
  markers: ["Privacy policy"],
};

test("production probe accepts the expected route contract", async () => {
  const result = await probePage({
    baseUrl: "https://catchdates.com",
    contract,
    timeoutMs: 100,
    fetchImpl: async () => new Response(
      '<title>Privacy policy | Catch</title><link rel="canonical" href="https://catchdates.com/privacy/" /><h1>Privacy policy</h1>',
      {status: 200}
    ),
  });

  assert.equal(result.ok, true);
  assert.deepEqual(result.findings, []);
});

test("production probe reports status, metadata, and content drift", async () => {
  const result = await probePage({
    baseUrl: "https://catchdates.com",
    contract,
    timeoutMs: 100,
    fetchImpl: async () => new Response("not found", {status: 404}),
  });

  assert.equal(result.ok, false);
  assert.deepEqual(result.findings, [
    "expected HTTP 200, received 404",
    "missing title: Privacy policy | Catch",
    "missing canonical: https://catchdates.com/privacy/",
    "missing marker: Privacy policy",
  ]);
});

