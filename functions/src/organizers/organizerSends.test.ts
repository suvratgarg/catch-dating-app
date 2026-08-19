import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {ListOrganizerCampaignsCallableResponse} from
  "../shared/generated/listOrganizerCampaignsCallableResponse";
import {
  decodeOrganizerSendCursor,
  encodeOrganizerSendCursor,
  sortOrganizerSendRows,
} from "./organizerSends";

type SendRow = ListOrganizerCampaignsCallableResponse["sends"][number];

const campaign = (id: string, activityAtMillis: number): SendRow => ({
  kind: "campaign",
  campaignId: id,
  name: "Regulars",
  status: "completed",
  segmentIds: ["regular"],
  templateId: "template-1",
  templateName: "Regular invite",
  audienceCounts: {
    total: 1,
    reachable: 1,
    optedOut: 0,
    invalid: 0,
    duplicate: 0,
    unsupported: 0,
    frequencyCapped: 0,
    providerBlocked: 0,
    unknown: 0,
  },
  deliveryCounts: {
    pending: 0,
    suppressed: 0,
    accepted: 1,
    sent: 1,
    delivered: 1,
    read: 0,
    failed: 0,
    replied: 0,
    optedOut: 0,
  },
  scheduledAtMillis: null,
  dispatchedAtMillis: activityAtMillis,
  activityAtMillis,
});

const announcement = (id: string, activityAtMillis: number): SendRow => ({
  kind: "announcement",
  broadcastId: id,
  eventId: "event-1",
  eventName: "Friday run",
  audience: "booked",
  recipientCount: 8,
  sentAtMillis: activityAtMillis,
  partialFailure: false,
  activityAtMillis,
});

const followerUpdate = (id: string, activityAtMillis: number): SendRow => ({
  kind: "followerUpdate",
  postId: id,
  eventId: null,
  audience: "followers",
  status: "active",
  deliveryStatus: "completed",
  recipientCount: 10,
  excludedCount: 1,
  activityAvailableCount: 9,
  pushAttemptedCount: 8,
  pushAcceptedCount: 8,
  pushFailedCount: 0,
  pushUnknownCount: 0,
  createdAtMillis: activityAtMillis,
  activityAtMillis,
});

test("Sends rows mix kinds in stable reverse chronology", () => {
  assert.deepEqual(
    sortOrganizerSendRows([
      campaign("campaign-a", 100),
      announcement("broadcast-a", 300),
      campaign("campaign-z", 300),
      followerUpdate("post-y", 300),
    ]).map((row) => {
      switch (row.kind) {
      case "campaign": return row.campaignId;
      case "announcement": return row.broadcastId;
      case "followerUpdate": return row.postId;
      }
    }),
    ["post-y", "campaign-z", "broadcast-a", "campaign-a"],
  );
});

test("Sends cursor round trips the union ordering key", () => {
  const row = announcement("broadcast-1", 1720000000000);
  assert.deepEqual(decodeOrganizerSendCursor(encodeOrganizerSendCursor(row)), {
    activityAtMillis: 1720000000000,
    sendId: "broadcast-1",
  });
  assert.throws(
    () => decodeOrganizerSendCursor("not-a-cursor"),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "invalid-argument",
  );
});

test("Sends cursor round trips a follower update ordering key", () => {
  const row = followerUpdate("post-1", 1720000000001);
  assert.deepEqual(decodeOrganizerSendCursor(encodeOrganizerSendCursor(row)), {
    activityAtMillis: 1720000000001,
    sendId: "post-1",
  });
});
