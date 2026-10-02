import assert from "node:assert/strict";
import {test} from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {assertCatchReplyEnabled, authorizeCatchReply, catchReplyHash,
  parseCatchReplyInput} from "./whatsappReply";
import type {CatchReplyConfig, CatchAuthUser} from "./whatsappReply";

const config: CatchReplyConfig = {enabled: true, atomicStopIngressReady: true,
  wabaId: "123", phoneNumberId: "456", actorUid: "agent",
  recipientUid: "participant", recipientE164: "+919000000001",
  credentialVersionResource:
    "projects/demo-catch/secrets/CATCH_WHATSAPP_ACCESS_TOKEN/versions/1",
  graphVersion: "v23.0", readinessEvidenceHash: "d".repeat(64)};
const request = (token: Record<string, unknown> = {support: true,
  auth_time: 1800000000}) => ({auth: {uid: "agent", token}}) as
  unknown as CallableRequest<unknown>;
const recipient = {disabled: false, phoneNumber: config.recipientE164};
const getUser = async (uid: string): Promise<CatchAuthUser> => uid === "agent" ?
  {disabled: false, customClaims: {support: true}} : recipient;

test("Catch replies require both explicit outbound and atomic ingress gates",
  () => {
    for (const patch of [{enabled: false}, {enabled: undefined},
      {atomicStopIngressReady: false}, {atomicStopIngressReady: undefined}]) {
      assert.throws(() => assertCatchReplyEnabled({...config, ...patch}));
    }
    assert.doesNotThrow(() => assertCatchReplyEnabled(config));
  });

test("only an explicit, closed service-support request is accepted", () => {
  const input = {purpose: "serviceSupport", inboundEventId: "cwhe_" +
    "a".repeat(64), reviewedInboundTextHash: catchReplyHash("Please help"),
  confirmSupportRequest: true, body: "Here is the help requested."};
  assert.deepEqual(parseCatchReplyInput(input), input);
  for (const patch of [{purpose: "marketing"}, {purpose: "eventOperations"},
    {confirmSupportRequest: false}, {reviewedInboundTextHash: ""},
    {body: " "}, {body: "x".repeat(4097)}, {recipientUid: "foreign"},
    {organizerId: "org"}, {inboundEventId: "../foreign"}]) {
    assert.throws(() => parseCatchReplyInput({...input, ...patch}));
  }
  const parsed = parseCatchReplyInput(input);
  input.body = "Changed after review";
  assert.notEqual(parsed.body, input.body);
});

test("current support role, actor scope and verified recipient are required",
  async () => {
    await authorizeCatchReply(request(), config, getUser);
    await assert.rejects(authorizeCatchReply({} as CallableRequest<unknown>,
      config, getUser));
    await assert.rejects(authorizeCatchReply(request({admin: true,
      auth_time: 1800000000}), config, getUser));
    await assert.rejects(authorizeCatchReply(request(), {...config,
      actorUid: "foreign"}, getUser));
    for (const actor of [{disabled: true, customClaims: {support: true}},
      {disabled: false, customClaims: {support: false}},
      {disabled: false, customClaims: {support: true}, tokensValidAfterTime:
        "2030-01-01T00:00:00Z"}]) {
      await assert.rejects(authorizeCatchReply(request(), config,
        async (uid) => uid === "agent" ? actor : recipient));
    }
    for (const person of [{disabled: true, phoneNumber: config.recipientE164},
      {disabled: false, phoneNumber: "+919000000002"}]) {
      await assert.rejects(authorizeCatchReply(request(), config,
        async (uid) => uid === "agent" ? await getUser(uid) : person));
    }
  });
