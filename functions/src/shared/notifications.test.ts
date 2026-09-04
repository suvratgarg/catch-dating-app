import assert from "node:assert/strict";
import test from "node:test";
import {
  activityNotificationId,
  allowsPushPreference,
  buildFcmMessage,
  notificationProfileAvatar,
} from "./notifications";
import type {PublicProfileDocument} from "./generated/firestoreAdminTypes";

test("arrival wire preserves role, recipient, identity and ids", () => {
  const message = buildFcmMessage({
    token: "address", title: "Ananya", body: "Hello", type: "message",
    matchId: "thread", messageId: "message", notificationId: "arrival-id",
    recipientUid: "recipient", appRole: "host", actorName: "Ananya",
    actorAvatarUrl: "https://images.example/avatar.jpg",
  });
  assert.deepEqual(message.data, {
    type: "message", matchId: "thread", messageId: "message",
    notificationId: "arrival-id", recipientUid: "recipient", appRole: "host",
    actorName: "Ananya", actorAvatarUrl: "https://images.example/avatar.jpg",
  });
  assert.deepEqual(message.notification, {title: "Ananya", body: "Hello"});
  assert.deepEqual(message.apns, {payload: {aps: {sound: "default"}}});
  assert.deepEqual(buildFcmMessage({
    token: "address", title: "Reminder", body: "Soon", type: "eventReminder",
    eventId: "event",
  }).data, {type: "eventReminder", eventId: "event"});
});

test("push avatar excludes unapproved photos and prefers thumbnails", () => {
  const profile = {profilePhotos: [
    {url: "pending", moderation: {status: "pending"}},
    {url: "rejected", moderation: {status: "rejected"}},
    {url: "approved", thumbnailUrl: "thumbnail",
      moderation: {status: "approved"}},
  ]} as PublicProfileDocument;
  assert.equal(notificationProfileAvatar(profile), "thumbnail");
  assert.equal(notificationProfileAvatar(undefined), undefined);
});

test("Cross Paths invitation push is explicit opt-in", () => {
  assert.equal(allowsPushPreference({}, "crossPathsInvitations"), false);
  assert.equal(allowsPushPreference({
    prefsCrossPathsInvitations: false,
  }, "crossPathsInvitations"), false);
  assert.equal(allowsPushPreference({
    prefsCrossPathsInvitations: true,
  }, "crossPathsInvitations"), true);
});

test("Cross Paths activity notification ids are deterministic", () => {
  assert.equal(
    activityNotificationId("crossPathsInvitation", "invitation-1"),
    "crossPathsInvitation_invitation-1"
  );
});
