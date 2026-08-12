import assert from "node:assert/strict";
import test from "node:test";
import type {
  EventDocument,
  OrganizerCampaignDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  campaignVariables,
  hasReachableCampaignRecipient,
} from "./organizerCampaigns";

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
