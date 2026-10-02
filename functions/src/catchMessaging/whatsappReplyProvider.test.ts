import assert from "node:assert/strict";
import {test} from "node:test";
import {prepareCatchReplyProvider} from "./whatsappReplyProvider";
import type {CatchReplyConfig} from "./whatsappReply";

const config: CatchReplyConfig = {enabled: true, atomicStopIngressReady: true,
  wabaId: "123", phoneNumberId: "456", actorUid: "agent",
  recipientUid: "participant", recipientE164: "+919000000001",
  credentialVersionResource:
    "projects/demo-catch/secrets/CATCH_WHATSAPP_ACCESS_TOKEN/versions/1",
  graphVersion: "v23.0"};
const envelope = {schema: "catch.whatsapp-sender-token/v1", wabaId: "123",
  phoneNumberId: "456", accessToken: "mock-token-not-a-live-credential"};

test("Catch adapter uses a bound envelope and only the exact text transport",
  async () => {
    const requests: RequestInit[] = [];
    const prepared = await prepareCatchReplyProvider(config, {
      readCredential: async (version) => {
        assert.equal(version, config.credentialVersionResource);
        return JSON.stringify(envelope);
      }, now: () => 1000,
      fetch: async (url, init) => {
        assert.equal(url.toString(),
          "https://graph.facebook.com/v23.0/456/messages");
        requests.push(init!);
        assert.equal(init?.redirect, "error");
        assert.deepEqual(JSON.parse(init!.body as string), {
          messaging_product: "whatsapp", recipient_type: "individual",
          to: "919000000001", type: "text",
          text: {preview_url: false, body: "Requested help"},
        });
        return new Response(JSON.stringify({messages: [{id: "wamid.saved"}]}));
      },
    });
    assert.equal(await prepared.send("Requested help", 2000), "wamid.saved");
    await assert.rejects(prepared.send("Requested help", 2000));
    assert.equal(requests.length, 1);
    const sentBody = JSON.stringify(requests[0].body);
    assert.equal(sentBody.includes(envelope.accessToken),

      false);
  });

test("disabled, foreign and unpinned credentials fail before dispatch",
  async () => {
    let reads = 0;
    const deps = {readCredential: async () => {
      reads++; return JSON.stringify(envelope);
    }, now: () => 1000, fetch: async () => {
      assert.fail("Unexpected provider call");
    }};
    for (const patch of [{enabled: false}, {atomicStopIngressReady: false},
      {credentialVersionResource: config.credentialVersionResource
        .replace("versions/1", "versions/latest")},
      {credentialVersionResource: config.credentialVersionResource
        .replace("CATCH_WHATSAPP_ACCESS_TOKEN",
          "ORGANIZER_WHATSAPP_ACCESS_TOKENS")},
      {graphVersion: "../foreign"}]) {
      await assert.rejects(prepareCatchReplyProvider({...config,
        ...patch}, deps));
    }
    assert.equal(reads, 0);
    for (const raw of ["raw-token", JSON.stringify({...envelope,
      wabaId: "999"}),
    JSON.stringify({...envelope, phoneNumberId: "999"}),
    JSON.stringify({...envelope, organizerId: "org"}),
    JSON.stringify({...envelope, accessToken: "unsafe token"})]) {
      await assert.rejects(prepareCatchReplyProvider(config, {...deps,
        readCredential: async () => raw}), /credential unavailable/);
    }
  });

test("deadline is checked immediately before transport; no automatic retry",
  async () => {
    let calls = 0;
    const deps = {readCredential: async () => JSON.stringify(envelope),
      now: () => 2000, fetch: async () => {
        calls++; throw new Error("private upstream detail");
      }};
    const expired = await prepareCatchReplyProvider(config, deps);
    await assert.rejects(expired.send("Requested help", 2000));
    assert.equal(calls, 0);
    const uncertain = await prepareCatchReplyProvider(config, deps);
    await assert.rejects(uncertain.send("Requested help", 3000));
    await assert.rejects(uncertain.send("Requested help", 3000));
    assert.equal(calls, 1);
  });
