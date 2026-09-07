import assert from "node:assert/strict";
import test from "node:test";
import {communicationRoutes} from "./communicationRoutes";

test("the route registry covers every supported communication route", () => {
  assert.deepEqual(Object.keys(communicationRoutes).sort(), [
    "catchChat",
    "catchEventAnnouncement",
    "catchEventRcs",
    "catchEventSms",
    "catchWhatsapp",
    "organizerEventWhatsapp",
    "organizerFollowerUpdate",
    "organizerWhatsappCampaign",
    "personalWhatsappHandoff",
  ]);
});

test("organizer and Catch WhatsApp keep separate authority boundaries", () => {
  const organizer = communicationRoutes.organizerWhatsappCampaign;
  const catchPlatform = communicationRoutes.catchWhatsapp;

  assert.equal(organizer.transport, "whatsapp");
  assert.equal(catchPlatform.transport, "whatsapp");
  assert.notEqual(organizer.adapterKey, catchPlatform.adapterKey);
  assert.notEqual(organizer.senderIdentity, catchPlatform.senderIdentity);
  assert.notEqual(organizer.consentScope, catchPlatform.consentScope);
});

test("personal handoff remains host-sent and unobservable by Catch", () => {
  const handoff = communicationRoutes.personalWhatsappHandoff;

  assert.equal(handoff.deliveryMode, "externalHandoff");
  assert.equal(handoff.audienceScope, "singleContact");
  assert.equal(handoff.observability, "none");
  assert.equal(handoff.requiresHostFinalSend, true);
  assert.equal(handoff.supportsScheduling, false);
});

test("every route declares audience, reply, and scheduling semantics", () => {
  assert.deepEqual(
    Object.values(communicationRoutes).map((route) => route.audienceScope),
    [
      "singleContact",
      "organizerCrmSegment",
      "catchPermissionedAudience",
      "linkedCatchAccount",
      "eventRoster",
      "organizerFollowers",
      "eventRoster",
      "eventRoster",
      "eventRoster",
    ],
  );
  assert.equal(communicationRoutes.catchChat.supportsReplies, true);
  assert.equal(
    communicationRoutes.catchEventAnnouncement.supportsReplies,
    false,
  );
  assert.equal(
    communicationRoutes.organizerFollowerUpdate.supportsScheduling,
    false,
  );
  assert.equal(
    communicationRoutes.organizerWhatsappCampaign.supportsScheduling,
    true,
  );
});

test("automated event routes preserve service and sender boundaries", () => {
  for (const route of [communicationRoutes.catchEventSms,
    communicationRoutes.catchEventRcs,
    communicationRoutes.organizerEventWhatsapp]) {
    assert.equal(route.consentScope, "eventService");
    assert.equal(route.audienceScope, "eventRoster");
    assert.equal(route.requiresHostFinalSend, false);
    assert.equal(route.supportsScheduling, false);
  }
  assert.equal(communicationRoutes.catchEventSms.supportsReplies, false);
  assert.equal(communicationRoutes.organizerEventWhatsapp.senderIdentity,
    "organizerManaged");
  assert.equal(communicationRoutes.catchEventSms.senderIdentity,
    "catchPlatform");
});
