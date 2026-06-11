import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {startClubHostConversationHandler} from "./clubHostConversations";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
}

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}

  get exists(): boolean {
    return this.value !== undefined;
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : {...this.value};
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
    return data === undefined ? undefined : {...data};
  }

  set(path: string, data: FakeData) {
    this.docs[path] = data;
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(ref.path));
  }

  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => {
      assert.equal(this.firestore.get(ref.path), undefined);
      this.firestore.set(ref.path, data);
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function harness(initialDocs: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initialDocs);
  const rateLimitCalls: string[] = [];
  return {
    firestore,
    rateLimitCalls,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      serverTimestamp: () => "SERVER_TIMESTAMP" as never,
      checkRateLimit: async (
        _db: FirebaseFirestore.Firestore,
        uid: string,
        action: string
      ) => {
        rateLimitCalls.push(`${uid}:${action}`);
      },
    },
  };
}

function request(
  uid: string,
  data: Record<string, unknown>
): CallableRequest<unknown> {
  return {
    auth: {uid, token: {}} as CallableRequest["auth"],
    data,
    rawRequest: {} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function club(overrides: FakeData = {}): FakeData {
  return {
    name: "Sunday Run Club",
    hostUserId: "owner-1",
    ownerUserId: "owner-1",
    hostUserIds: ["owner-1", "host-1"],
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("startClubHostConversationHandler creates a host inquiry match",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
    });

    const result = await startClubHostConversationHandler(
      request("viewer-1", {clubId: "club-1", hostUid: "host-1"}),
      h.deps
    );

    assert.deepEqual(result, {matchId: "host-1_viewer-1"});
    assert.deepEqual(h.rateLimitCalls, [
      "viewer-1:startClubHostConversation",
    ]);
    assert.deepEqual(h.firestore.get("matches/host-1_viewer-1"), {
      user1Id: "host-1",
      user2Id: "viewer-1",
      participantIds: ["host-1", "viewer-1"],
      eventIds: [],
      createdAt: "SERVER_TIMESTAMP",
      lastMessageAt: null,
      lastMessagePreview: "Ask about Sunday Run Club",
      lastMessageSenderId: null,
      unreadCounts: {"host-1": 0, "viewer-1": 0},
      status: "active",
      blockedBy: null,
      blockedAt: null,
      conversationType: "clubHostInquiry",
      clubId: "club-1",
    });
  }
);

test("startClubHostConversationHandler reuses an existing active match",
  async () => {
    const existingMatch = {
      user1Id: "host-1",
      user2Id: "viewer-1",
      participantIds: ["host-1", "viewer-1"],
      eventIds: ["event-1"],
      createdAt: "CREATED_AT",
      unreadCounts: {},
      status: "active",
      conversationType: "match",
    };
    const h = harness({
      "clubs/club-1": club(),
      "matches/host-1_viewer-1": existingMatch,
    });

    const result = await startClubHostConversationHandler(
      request("viewer-1", {clubId: "club-1", hostUid: "host-1"}),
      h.deps
    );

    assert.deepEqual(result, {matchId: "host-1_viewer-1"});
    assert.deepEqual(
      h.firestore.get("matches/host-1_viewer-1"),
      existingMatch
    );
  }
);

test("startClubHostConversationHandler rejects non-host targets", async () => {
  const h = harness({"clubs/club-1": club()});

  await assert.rejects(
    () => startClubHostConversationHandler(
      request("viewer-1", {clubId: "club-1", hostUid: "other-1"}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "permission-denied")
  );
});
