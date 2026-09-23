import assert from "node:assert/strict";
import test from "node:test";
import {FormPaymentRuntimeConfig} from "./formPaymentRuntimeConfig";

const version = "projects/catch-test/secrets/FORM_PARTNER/versions/1";
const config = {schema: "catch.form-razorpay-partner/v1",
  clientId: "client", clientSecret: "private", mode: "test",
  credentialSecretId: "FORM_MERCHANT_CREDENTIALS"};

test("unconfigured, foreign and floating config references never read secrets",
  async () => {
    let reads = 0;
    const loader = new FormPaymentRuntimeConfig("catch-test", async () => {
      reads++;
      return JSON.stringify(config);
    });
    for (const ref of ["", version.replace("catch-test", "foreign-project"),
      version.replace("/1", "/latest"), version.replace("/1", "/01")]) {
      await assert.rejects(loader.load(ref), /not configured/u);
    }
    assert.equal(reads, 0);
  });

test("configuration owns the callback and bounds credential caching",
  async () => {
    let reads = 0;
    let now = 1000;
    const loader = new FormPaymentRuntimeConfig("catch-test", async () => {
      reads++;
      return JSON.stringify(config);
    }, () => now);
    const [first, second] = await Promise.all([loader.load(version),
      loader.load(version)]);
    assert.equal(reads, 1);
    assert.equal(first.callbackUrl,
      "https://asia-south1-catch-test.cloudfunctions.net/" +
      "organizerFormPaymentOauthCallback");
    assert.equal(first.mode, "test");
    assert.equal(second.webhookBaseUrl,
      "https://asia-south1-catch-test.cloudfunctions.net/" +
      "organizerFormPaymentWebhook");
    now += 60_000;
    await loader.load(version);
    assert.equal(reads, 2);
  });

test("failed config loads are sanitized and retryable", async () => {
  let calls = 0;
  const loader = new FormPaymentRuntimeConfig("catch-test", async () => {
    if (calls++ === 0) throw new Error("Backend error private-secret");
    return JSON.stringify(config);
  });
  await assert.rejects(loader.load(version), (error: Error) => {
    assert.equal(error.message.includes("private-secret"), false);
    return true;
  });
  assert.equal((await loader.load(version)).mode, "test");
  for (const patch of [{mode: "unknown"}, {callbackUrl: "https://foreign.test"},
    {credentialSecretId: "../OTHER"}, {clientSecret: " "}, {schema: "other"}]) {
    await assert.rejects(new FormPaymentRuntimeConfig("catch-test", async () =>
      JSON.stringify({...config, ...patch})).load(version), /not configured/u);
  }
});

test("concurrent readers cannot expose secret errors", async () => {
  const loader = new FormPaymentRuntimeConfig("catch-test", async () => {
    throw new Error("private-secret-backend-error");
  });
  const results = await Promise.allSettled([loader.load(version),
    loader.load(version)]);
  for (const result of results) {
    assert.equal(result.status, "rejected");
    if (result.status === "rejected") {
      assert.match(String(result.reason), /not configured/u);
      assert.doesNotMatch(String(result.reason), /private-secret/u);
    }
  }
});
