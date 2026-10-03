import assert from "node:assert/strict";
import test from "node:test";
import {SecretVersionReferenceGuard} from
  "../../shared/secretVersionReference";
import {SmsCredentialStore} from "./gupshupSmsProvider";
import type {SmsConfig} from "./smsProtocol";

const start = Date.parse("2026-09-06T14:30:00Z");

function config(senderId = "sms-sender-1"): SmsConfig {
  return {schemaVersion: 1, senderId, revision: 1, provider: "gupshup",
    senderIdentity: "catchPlatform", country: "IN", status: "ready",
    mask: "CATCHS", principalEntityId: "100100100100",
    credentialVersion: "projects/catchdates-dev/secrets/EVENT_SMS/versions/1",
    activation: {useCaseApprovalId: "fixture-use-case",
      senderApprovalId:
      "fixture-sender", approvedAt: start - 1000,
      validUntil: start + 3_600_000},
    maxSegments: 3, quote: {revision: 1, currency: "INR",
      maxMicrosPerSegment: 500_000, validUntil: start + 3_600_000},
    templates: [{templateId: "fixture-joining", revision: 1,
      purpose: "joiningUpdate", dltTemplateId: "100200200200",
      status: "approved",
      parts: [{kind: "literal", text: "Catch: "},
        {kind: "variable", name: "instruction", maxCharacters: 180},
        {kind: "literal", text: " Reply: "},
        {kind: "variable", name: "responseUrl", maxCharacters: 160}]}]};
}

test("SMS credential references cannot cross projects or follow aliases",
  async () => {
    const calls: string[] = [];
    const client = {accessSecretVersion: async ({name}: {name: string}) => {
      calls.push(name);
      return [{payload: {data: Buffer.from(JSON.stringify({
        schema: "catch.event-sms-credential/v1", senderId: "sms-sender-1",
        userid: "123", password: "fake-password",
      }))}}];
    }};
    const store = new SmsCredentialStore(client as never,
      new SecretVersionReferenceGuard(() => "catchdates-dev",
        async () => "123456"));
    const sender = config();
    for (const credentialVersion of [
      sender.credentialVersion.replace("catchdates-dev", "foreign-project"),
      sender.credentialVersion.replace("catchdates-dev", "654321"),
      sender.credentialVersion.replace("/1", "/latest"),
      sender.credentialVersion + "\n",
    ]) {
      await assert.rejects(store.access({...sender, credentialVersion}));
    }
    assert.deepEqual(calls, []);
    const local = await store.access(sender);
    assert.equal(local.senderId, sender.senderId);
    await store.access({...sender, credentialVersion:
      sender.credentialVersion.replace("catchdates-dev", "123456")});
    assert.equal(calls.length, 2);
    await assert.rejects(store.access({...sender, senderId: "foreign-sender"}),
      /^Error: SMS sender credential unavailable$/);
  });

test("missing runtime project cannot reach SMS credential I/O", async () => {
  const store = new SmsCredentialStore({accessSecretVersion: async () => {
    assert.fail("No credential read without runtime project authority");
  }} as never, new SecretVersionReferenceGuard(() => undefined));
  await assert.rejects(store.access(config()),
    /^Error: SMS sender credential unavailable$/);
});
