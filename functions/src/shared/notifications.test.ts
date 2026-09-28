import assert from "node:assert/strict";
import test from "node:test";
import {
  activityNotificationId,
  allowsPushPreference,
  buildFcmMessage,
  eventActivityNotificationCopy,
  eventCompanionReadyNotificationCopy,
  notificationProfileAvatar,
} from "./notifications";
import type {EventDocument, PublicProfileDocument} from
  "./generated/firestoreAdminTypes";

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

test("incomplete private event notification copy uses authored facts", () => {
  const event = {name: "  Evening walk  ", publicationState: "private"} as
    EventDocument;
  const reminder = eventActivityNotificationCopy("eventReminder", event);
  assert.match(reminder.body, /Evening walk/);
  assert.match(reminder.body, /Venue to be confirmed/);
  const companion = eventCompanionReadyNotificationCopy(event);
  assert.match(companion.body, /Evening walk/);
});

test("non-distance notifications ignore legacy distance", () => {
  for (const distanceKm of [0, 5]) {
    const event = {name: "Friday quiz", distanceKm,
      eventFormat: {activityKind: "pubQuiz"},
      meetingLocation: {name: "Clubhouse"}} as EventDocument;
    for (const copy of [eventActivityNotificationCopy("eventCancelled", event),
      eventActivityNotificationCopy("eventUpdated", event),
      eventCompanionReadyNotificationCopy(event)]) {
      assert.match(copy.body, /Friday quiz/);
      assert.doesNotMatch(copy.body, /km/);
    }
  }
});
test("distance copy rejects zero or invalid values", () => {
  for (const activityKind of ["socialRun", "running", "walking", "cycling"]) {
    const event = {distanceKm: 5.5,
      eventFormat: {activityKind}} as EventDocument;
    assert.match(eventActivityNotificationCopy("eventReminder", event).body,
      /5\.5 km/);
  }
  for (const distanceKm of [0, -1, Number.NaN]) {
    assert.doesNotMatch(eventActivityNotificationCopy("eventReminder",
      {name: "Morning run", distanceKm} as EventDocument).body, /km/);
  }
});
