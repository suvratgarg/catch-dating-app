import assert from "node:assert/strict";
import test from "node:test";
import {RazorpayCredentialVault, type FormCredentialSecretStore,
  type RazorpayStoredCredential} from "./razorpayCredentialVault";

const credential: RazorpayStoredCredential = {
  organizerId: "organizer", connectionId: "connection",
  accountId: "acc_merchant",
  mode: "test", webhookSecret: "s".repeat(43), token: {
    accountId: "acc_merchant", accessToken: "access", refreshToken: "refresh",
    publicToken: "rzp_test_oauth_public", expiresAt: 1000,
  },
};
const parent = "projects/catch-test/secrets/FORM_RAZORPAY_TOKENS";

class MemorySecrets implements FormCredentialSecretStore {
  values = new Map<string, string>();
  reads = 0;
  async add(resource: string, value: string): Promise<string> {
    assert.equal(resource, parent);
    const version = `${resource}/versions/${this.values.size + 1}`;
    this.values.set(version, value);
    return version;
  }
  async read(version: string): Promise<string> {
    this.reads++;
    const value = this.values.get(version);
    if (!value) throw new Error("secret access provider detail");
    return value;
  }
  async disable(version: string): Promise<void> {
    this.values.delete(version);
  }
}

test("vault stores credentials outside Firestore with exact merchant binding",
  async () => {
    const store = new MemorySecrets();
    const vault = new RazorpayCredentialVault(
      "catch-test", "FORM_RAZORPAY_TOKENS",
      store);
    const version = await vault.save(credential);
    assert.equal(version, `${parent}/versions/1`);
    assert.deepEqual(await vault.access(version, credential), credential);
    for (const patch of [{organizerId: "another"}, {connectionId: "another"},
      {accountId: "acc_other"}, {mode: "live" as const}]) {
      await assert.rejects(vault.access(version, {...credential, ...patch}),
        /^Error: Organizer payment credential unavailable\.$/u);
    }
    await vault.disable(version);
    await assert.rejects(vault.access(version, credential),
      /^Error: Organizer payment credential unavailable\.$/u);
  });

test("vault rejects aliases, foreign projects and foreign secrets before reads",
  async () => {
    const store = new MemorySecrets();
    const vault = new RazorpayCredentialVault(
      "catch-test", "FORM_RAZORPAY_TOKENS",
      store);
    for (const version of [`${parent}/versions/latest`, `${parent}/versions/0`,
      `${parent}/versions/1/other`, `${parent}/versions/01`,
      "projects/foreign/secrets/FORM_RAZORPAY_TOKENS/versions/1",
      "projects/catch-test/secrets/OTHER_SECRET/versions/1"]) {
      await assert.rejects(vault.access(version, credential));
      await assert.rejects(vault.disable(version));
    }
    assert.equal(store.reads, 0);
  });

test("vault rejects malformed envelopes and mismatched token mode/account",
  async () => {
    const store = new MemorySecrets();
    const vault = new RazorpayCredentialVault(
      "catch-test", "FORM_RAZORPAY_TOKENS",
      store);
    const version = await vault.save(credential);
    for (const patch of [{schema: "wrong"}, {extra: "unexpected"},
      {token: {...credential.token, accountId: "acc_other"}},
      {token: {...credential.token, publicToken: "rzp_live_oauth_public"}},
      {token: {...credential.token, accessToken: " "}}]) {
      store.values.set(version, JSON.stringify({
        schema: "catch.organizer-razorpay/v1",
        ...credential, ...patch}));
      await assert.rejects(vault.access(version, credential));
    }
  });
