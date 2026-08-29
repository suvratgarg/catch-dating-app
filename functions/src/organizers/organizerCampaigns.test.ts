import assert from "node:assert/strict";
import test from "node:test";
import type {
  EventDocument,
  OrganizerCampaignDocument,
  OrganizerCommunicationPreferenceDocument,
  OrganizerContactDocument,
  OrganizerContactTraitDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  campaignVariables,
  evaluateAudienceRows,
  hasReachableCampaignRecipient,
} from "./organizerCampaigns";
import * as admin from "firebase-admin";

test("campaign preview rejects empty and fully excluded audiences", () => {
  assert.equal(hasReachableCampaignRecipient([]), false);
  assert.equal(
    hasReachableCampaignRecipient([
      {eligibility: "excluded"},
      {eligibility: "excluded"},
    ]),
    false,
  );
  assert.equal(
    hasReachableCampaignRecipient([
      {eligibility: "excluded"},
      {eligibility: "eligible"},
    ]),
    true,
  );
});

test(
  "campaign invite variables distinguish full links from URL suffixes",
  () => {
    const campaign = {
      eventId: "event-1",
      templateVariables: {first_name: "Maya"},
    } as unknown as OrganizerCampaignDocument;
    const event = {} as EventDocument;
    const token = "v2_invite-1_abcdefghijklmnopqrstuvwxyz12345678901234567";

    assert.deepEqual(
      campaignVariables(campaign, token, event, ["first_name", "invite_url"]),
      {
        first_name: "Maya",
        invite_url: `https://catchdates.com/invite/${token}`,
      },
    );
    assert.deepEqual(
      campaignVariables(campaign, token, event, ["first_name", "invite_token"]),
      {first_name: "Maya", invite_token: encodeURIComponent(token)},
    );
  }
);

test("campaign eligibility fails closed for an incomplete legacy grant", () => {
  const now = admin.firestore.Timestamp.fromMillis(10_000);
  const contact = {
    organizerId: "organizer-1",
    linkedUid: "user-1",
    phoneE164: "+919876543210",
    identityState: "verified",
    identityConfidence: "verified",
    deletedAt: null,
    hiddenAt: null,
  } as OrganizerContactDocument;
  const trait = {
    segmentIds: ["repeat_attendee"],
  } as OrganizerContactTraitDocument;
  const preference = {
    organizerId: "organizer-1",
    uid: "user-1",
    whatsapp: {
      status: "optedIn",
      evidenceStatus: "incomplete",
      currentReceiptId: "legacy-receipt",
    },
  } as OrganizerCommunicationPreferenceDocument;
  const [row] = evaluateAudienceRows([{
    contactId: "contact-1",
    contact,
    trait,
    preference,
    channelState: null,
  }], now, ["repeat_attendee"]);
  assert.equal(row.eligibility, "excluded");
  assert.equal(row.exclusionReason, "unknownPermission");
  preference.whatsapp.evidenceStatus = "complete";
  const [eligible] = evaluateAudienceRows([{
    contactId: "contact-1",
    contact,
    trait,
    preference,
    channelState: null,
  }], now, ["repeat_attendee"]);
  assert.equal(eligible.eligibility, "eligible");
});
