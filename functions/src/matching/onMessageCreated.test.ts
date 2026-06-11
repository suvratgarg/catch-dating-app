import assert from "node:assert/strict";
import test from "node:test";
import type {sendFcmNotification} from "../shared/notifications";
import {onMessageCreatedHandler} from "./onMessageCreated";

type FakeData = Record<string, unknown>;
type Notification = Parameters<typeof sendFcmNotification>[0];

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(this.path));
  }

  collection(collectionPath: string) {
    return {
      doc: (docId: string) => new FakeDocRef(
        this.firestore,
        `${this.path}/${collectionPath}/${docId}`
      ),
    };
  }
}

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}

  get exists(): boolean {
    return this.value !== undefined;
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : structuredClone(this.value);
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return {
      doc: (docId: string) => new FakeDocRef(
        this,
        `${collectionPath}/${docId}`
      ),
    };
  }

  async runTransaction<T>(
    callback: (tx: FakeTransaction) => Promise<T>
  ): Promise<T> {
    const tx = new FakeTransaction(this);
    const result = await callback(tx);
    tx.commit();
    return result;
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : structuredClone(data);
  }

  set(path: string, data: FakeData) {
    this.docs[path] = structuredClone(data);
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(ref.path));
  }

  update(ref: FakeDocRef, patch: FakeData) {
    this.writes.push(() => {
      const current = this.firestore.get(ref.path);
      assert(current, `Missing doc for update: ${ref.path}`);
      this.firestore.set(ref.path, applyPatch(current, patch));
    });
  }

  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => {
      assert.equal(this.firestore.get(ref.path), undefined);
      this.firestore.set(ref.path, applyPatch({}, data));
    });
  }

  set(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => {
      const current = this.firestore.get(ref.path) ?? {};
      this.firestore.set(ref.path, applyPatch(current, data));
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function applyPatch(current: FakeData, patch: FakeData): FakeData {
  const next = structuredClone(current);
  for (const [fieldPath, value] of Object.entries(patch)) {
    setField(next, fieldPath, value);
  }
  return next;
}

function setField(target: FakeData, fieldPath: string, value: unknown) {
  const parts = fieldPath.split(".");
  let cursor: FakeData = target;
  for (const part of parts.slice(0, -1)) {
    const existing = cursor[part];
    if (!isRecord(existing)) {
      cursor[part] = {};
    }
    cursor = cursor[part] as FakeData;
  }

  const finalPart = parts.at(-1) ?? fieldPath;
  cursor[finalPart] = value;
}

function isRecord(value: unknown): value is FakeData {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function event(eventId: string) {
  return {
    id: eventId,
    params: {matchId: "match-1", messageId: "message-1"},
    data: {
      data: () => ({
        senderId: "runner-1",
        text: "Hello there",
        sentAt: {seconds: 1, nanoseconds: 0},
      }),
    },
  };
}

function harness({eventIds = ["event-1"]}: {eventIds?: string[]} = {}) {
  const firestore = new FakeFirestore({
    "matches/match-1": {
      user1Id: "runner-1",
      user2Id: "runner-2",
      participantIds: ["runner-1", "runner-2"],
      eventIds,
      createdAt: {seconds: 0, nanoseconds: 0},
      lastMessageAt: null,
      lastMessagePreview: null,
      lastMessageSenderId: null,
      unreadCounts: {"runner-1": 0, "runner-2": 1},
      status: "active",
    },
    "publicProfiles/runner-1": {name: "Runner One"},
    "users/runner-2": {fcmToken: "token-2"},
  });
  const notifications: Notification[] = [];
  const scorecardRefreshes: string[] = [];

  return {
    firestore,
    notifications,
    scorecardRefreshes,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      serverTimestamp: () =>
        ({kind: "serverTimestamp"}) as unknown as FirebaseFirestore.FieldValue,
      sendNotification: async (notification: Notification) => {
        notifications.push(notification);
      },
      refreshScorecard: async (eventId: string) => {
        scorecardRefreshes.push(eventId);
      },
    },
  };
}

test("onMessageCreatedHandler updates match metadata and notifies recipient",
  async () => {
    const h = harness();

    await onMessageCreatedHandler(event("event-1"), h.deps);

    assert.deepEqual(h.firestore.get("matches/match-1"), {
      user1Id: "runner-1",
      user2Id: "runner-2",
      participantIds: ["runner-1", "runner-2"],
      eventIds: ["event-1"],
      createdAt: {seconds: 0, nanoseconds: 0},
      lastMessageAt: {seconds: 1, nanoseconds: 0},
      lastMessagePreview: "Hello there",
      lastMessageSenderId: "runner-1",
      unreadCounts: {"runner-1": 0, "runner-2": 1},
      status: "active",
    });
    assert.deepEqual(
      h.firestore.get("functionEventReceipts/onMessageCreated_event-1"),
      {
        handler: "onMessageCreated",
        eventId: "event-1",
        matchId: "match-1",
        messageId: "message-1",
        createdAt: {kind: "serverTimestamp"},
      }
    );
    assert.equal(
      h.firestore.get("notifications/runner-2/items/message_match-1_message-1"),
      undefined
    );
    assert.equal(h.notifications.length, 1);
    assert.deepEqual(h.scorecardRefreshes, ["event-1"]);
  }
);

test("onMessageCreatedHandler applies a retried event once", async () => {
  const h = harness();

  await onMessageCreatedHandler(event("event-1"), h.deps);
  await onMessageCreatedHandler(event("event-1"), h.deps);

  assert.deepEqual(
    h.firestore.get("matches/match-1")?.unreadCounts,
    {"runner-1": 0, "runner-2": 1}
  );
  assert.equal(h.notifications.length, 1);
  assert.deepEqual(h.scorecardRefreshes, ["event-1"]);
});

test("onMessageCreatedHandler refreshes every event attached to the match",
  async () => {
    const h = harness({eventIds: ["event-1", "event-2"]});

    await onMessageCreatedHandler(event("event-1"), h.deps);

    assert.deepEqual(h.scorecardRefreshes, ["event-1", "event-2"]);
  }
);
