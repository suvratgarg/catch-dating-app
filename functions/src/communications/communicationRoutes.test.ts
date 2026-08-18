import assert from "node:assert/strict";
import test from "node:test";
import {communicationRoutes} from "./communicationRoutes";

test("the route registry covers every supported communication route", () => {
  assert.deepEqual(Object.keys(communicationRoutes).sort(), [
    "catchChat",
    "catchEventAnnouncement",
    "catchWhatsapp",
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
  assert.equal(handoff.observability, "none");
  assert.equal(handoff.requiresHostFinalSend, true);
});
