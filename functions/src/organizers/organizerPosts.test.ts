import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerFollowerDelivery} from "./organizerPosts";

const delivery = (overrides: Partial<Parameters<
  typeof buildOrganizerFollowerDelivery
>[0]> = {}) => buildOrganizerFollowerDelivery({
  uid: "follower-1",
  followPushNotificationsEnabled: true,
  user: {fcmToken: "token-1", prefsClubUpdates: true},
  organizerId: "organizer-1",
  authorUid: "host-1",
  organizerName: "Sunday Social",
  postId: "post-1",
  text: "Meet by the east gate.",
  eventId: "event-1",
  ...overrides,
});

test("follower updates build the durable Organizer Activity route", () => {
  const result = delivery({
    followPushNotificationsEnabled: false,
    user: {prefsClubUpdates: false},
  });

  assert.deepEqual(result.activity, {
    id: "organizerUpdate_post-1",
    uid: "follower-1",
    type: "organizerUpdate",
    title: "New update from Sunday Social",
    body: "Meet by the east gate.",
    eventId: "event-1",
    organizerId: "organizer-1",
    postId: "post-1",
    actorUid: "host-1",
    actorName: "Sunday Social",
  });
  assert.equal(result.push, null);
});

test("follower push needs both follow-level and user-level permission", () => {
  assert.equal(delivery().push?.token, "token-1");
  assert.equal(delivery({followPushNotificationsEnabled: false}).push, null);
  assert.equal(
    delivery({user: {fcmToken: "token-1", prefsClubUpdates: false}}).push,
    null,
  );
  assert.equal(delivery({user: {prefsClubUpdates: true}}).push, null);
});
