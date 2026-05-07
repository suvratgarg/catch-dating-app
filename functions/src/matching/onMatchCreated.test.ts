/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import type {sendFcmNotification} from "../shared/notifications";
import {onMatchCreatedHandler} from "./onMatchCreated";

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

  async set(data: FakeData): Promise<void> {
    this.firestore.set(this.path, data);
  }
}

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}

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

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : structuredClone(data);
  }

  set(path: string, data: FakeData) {
    this.docs[path] = structuredClone(data);
  }
}

function event() {
  return {
    params: {matchId: "match-1"},
    data: {
      data: () => ({
        user1Id: "runner-1",
        user2Id: "runner-2",
        participantIds: ["runner-1", "runner-2"],
        runId: "run-1",
        createdAt: {seconds: 0, nanoseconds: 0},
        unreadCounts: {"runner-1": 0, "runner-2": 0},
        status: "active",
      }),
    },
  };
}

function harness() {
  const firestore = new FakeFirestore({
    "users/runner-1": {fcmToken: "token-1"},
    "users/runner-2": {fcmToken: "token-2"},
    "publicProfiles/runner-1": {name: "Runner One"},
    "publicProfiles/runner-2": {name: "Runner Two"},
  });
  const notifications: Notification[] = [];

  return {
    firestore,
    notifications,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      serverTimestamp: () =>
        ({kind: "serverTimestamp"}) as unknown as FirebaseFirestore.FieldValue,
      sendNotification: async (notification: Notification) => {
        notifications.push(notification);
      },
    },
  };
}

test(
  "onMatchCreatedHandler writes user-scoped activity notifications and pushes",
  async () => {
    const h = harness();

    await onMatchCreatedHandler(event(), h.deps);

    assert.deepEqual(
      h.firestore.get("notifications/runner-1/items/match_match-1"),
      {
        uid: "runner-1",
        type: "match",
        title: "It's a catch",
        body: "You and Runner Two matched. Say hi!",
        createdAt: {kind: "serverTimestamp"},
        matchId: "match-1",
        runId: "run-1",
        actorUid: "runner-2",
        actorName: "Runner Two",
        readAt: null,
      }
    );
    assert.deepEqual(
      h.firestore.get("notifications/runner-2/items/match_match-1"),
      {
        uid: "runner-2",
        type: "match",
        title: "It's a catch",
        body: "You and Runner One matched. Say hi!",
        createdAt: {kind: "serverTimestamp"},
        matchId: "match-1",
        runId: "run-1",
        actorUid: "runner-1",
        actorName: "Runner One",
        readAt: null,
      }
    );
    assert.deepEqual(h.notifications, [
      {
        token: "token-1",
        title: "It's a catch",
        body: "You and Runner Two matched. Say hi!",
        type: "match",
        matchId: "match-1",
      },
      {
        token: "token-2",
        title: "It's a catch",
        body: "You and Runner One matched. Say hi!",
        type: "match",
        matchId: "match-1",
      },
    ]);
  }
);
