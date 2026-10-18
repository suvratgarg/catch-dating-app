import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {
  activityNotificationId,
  allowsPushPreference,
  buildFcmMessage,
  createActivityNotificationIfAbsent,
  eventActivityNotificationCopy,
  eventCompanionReadyNotificationCopy,
  notificationProfileAvatar,
} from "./notifications";
import type {EventDocument, PublicProfileDocument} from
  "./generated/firestoreAdminTypes";

// Model only transaction callback replay: discarded attempts stage writes,
// but only the final successful callback's writes and return value commit.
function activityTransaction(existsByAttempt: boolean[], commitError?: Error) {
  type Write = {path: string; data: Record<string, unknown>};
  const attempts: Write[][] = [];
  const committed: Write[] = [];
  const ref = {path: "notifications/recipient/items/reminder"};
  const db = {
    collection: (collection: string) => {
      assert.equal(collection, "notifications");
      return {doc: (uid: string) => {
        assert.equal(uid, "recipient");
        return {collection: (items: string) => {
          assert.equal(items, "items");
          return {doc: (id: string) => {
            assert.equal(id, "reminder");
            return ref;
          }};
        }};
      }};
    },
    runTransaction: async (
      callback: (tx: FirebaseFirestore.Transaction) => Promise<unknown>,
    ) => {
      let result: unknown;
      for (const exists of existsByAttempt) {
        const writes: Write[] = [];
        attempts.push(writes);
        result = await callback({
          get: async (target: unknown) => {
            assert.equal(target, ref);
            return {exists};
          },
          create: (target: typeof ref, data: Record<string, unknown>) => {
            assert.equal(target, ref);
            writes.push({path: target.path, data});
          },
        } as unknown as FirebaseFirestore.Transaction);
      }
      if (commitError) throw commitError;
      committed.push(...attempts.at(-1)!);
      return result;
    },
  } as unknown as FirebaseFirestore.Firestore;
  return {db, attempts, committed};
}

const activity = {
  id: "reminder", uid: "recipient", type: "eventReminder" as const,
  title: "Reminder", body: "Starts soon", eventId: "event",
  organizerId: "organizer", createdAt: Timestamp.fromMillis(1234),
};

test("activity creation reports the committed new notification", async () => {
  const store = activityTransaction([false]);
  assert.equal(await createActivityNotificationIfAbsent(store.db, activity),
    true);
  assert.deepEqual(store.committed, [{
    path: "notifications/recipient/items/reminder",
    data: {uid: activity.uid, type: activity.type, title: activity.title,
      body: activity.body, eventId: activity.eventId,
      organizerId: activity.organizerId, createdAt: activity.createdAt,
      readAt: null},
  }]);
});

test("existing activity reports false without overwriting it", async () => {
  const store = activityTransaction([true]);
  assert.equal(await createActivityNotificationIfAbsent(store.db, activity),
    false);
  assert.deepEqual(store.attempts, [[]]);
  assert.deepEqual(store.committed, []);
});

test("aborted create then existing retry reports the committed false result",
  async () => {
    const store = activityTransaction([false, true]);
    assert.equal(await createActivityNotificationIfAbsent(store.db, activity),
      false);
    assert.equal(store.attempts.length, 2);
    assert.equal(store.attempts[0].length, 1);
    assert.deepEqual(store.attempts[1], []);
    assert.deepEqual(store.committed, []);
  });

test("failed activity commit rejects instead of reporting creation",
  async () => {
    const failure = new Error("commit failed");
    const store = activityTransaction([false], failure);
    await assert.rejects(createActivityNotificationIfAbsent(store.db, activity),
      (error: unknown) => error === failure);
    assert.equal(store.attempts[0].length, 1);
    assert.deepEqual(store.committed, []);
  });

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
