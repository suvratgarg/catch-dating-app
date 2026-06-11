import assert from "node:assert/strict";
import test from "node:test";
import {
  ensureSuvbotThread,
  isSuvbotAction,
  suvbotActionCatalog,
  suvbotMatchId,
  SUVBOT_UID,
} from "./suvbot";

type FakeData = Record<string, unknown>;

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

class FakeBatch {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  set(ref: FakeDocRef, data: FakeData, _options?: unknown) {
    void _options;
    this.writes.push(() => {
      const current = this.firestore.get(ref.path) ?? {};
      this.firestore.set(ref.path, {...current, ...structuredClone(data)});
    });
  }

  async commit(): Promise<void> {
    for (const write of this.writes) write();
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

  batch(): FakeBatch {
    return new FakeBatch(this);
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : structuredClone(data);
  }

  set(path: string, data: FakeData) {
    this.docs[path] = structuredClone(data);
  }
}

const deps = {
  firestore: () => {
    throw new Error("not used");
  },
  serverTimestamp: () => ({kind: "serverTimestamp"}) as
    unknown as FirebaseFirestore.FieldValue,
  timestampFromDate: (date: Date) => ({date: date.toISOString()}) as
    unknown as FirebaseFirestore.Timestamp,
  now: () => new Date("2026-05-20T10:00:00.000Z"),
};

test("suvbotMatchId is deterministic", () => {
  assert.equal(suvbotMatchId("runner-1"), "suvbot_runner-1");
});

test("suvbotActionCatalog exposes backend-owned controls", () => {
  const actions = suvbotActionCatalog();
  const byId = new Map(actions.map((action) => [action.id, action]));

  assert.equal(byId.get("refreshDemoState")?.destructive, true);
  assert.equal(byId.get("clearDemoState")?.destructive, true);
  assert.equal(byId.get("resetChats")?.destructive, true);
  assert.equal(byId.get("resetBookings")?.destructive, true);
  assert.equal(byId.get("resetNotifications")?.destructive, true);
  assert.equal(byId.get("matchTesterByPhone")?.requiresText, true);
  assert.ok(byId.has("warmSignupState"));
  assert.ok(byId.has("warmPostEventState"));
  assert.ok(byId.has("warmChatState"));
  assert.ok(byId.has("warmPaymentState"));
  assert.ok(actions.every((action) => isSuvbotAction(action.id)));
  assert.equal(isSuvbotAction("message"), true);
  assert.equal(isSuvbotAction("unknown"), false);
});

test(
  "ensureSuvbotThread creates profile, match, and welcome message",
  async () => {
    const firestore = new FakeFirestore({});
    const result = await ensureSuvbotThread(
      firestore as unknown as FirebaseFirestore.Firestore,
      "runner-1",
      deps
    );

    assert.deepEqual(result, {matchId: "suvbot_runner-1", created: true});
    assert.equal(
      firestore.get(`publicProfiles/${SUVBOT_UID}`)?.name,
      "Suvbot"
    );
    assert.equal(
      firestore.get("matches/suvbot_runner-1")?.user1Id,
      SUVBOT_UID
    );
    assert.equal(
      firestore.get("matches/suvbot_runner-1/messages/suvbot_welcome")
        ?.senderId,
      SUVBOT_UID
    );
  }
);

test("ensureSuvbotThread preserves an existing thread", async () => {
  const firestore = new FakeFirestore({
    "matches/suvbot_runner-1": {
      user1Id: SUVBOT_UID,
      user2Id: "runner-1",
      lastMessagePreview: "Existing",
    },
  });
  const result = await ensureSuvbotThread(
    firestore as unknown as FirebaseFirestore.Firestore,
    "runner-1",
    deps
  );

  assert.deepEqual(result, {matchId: "suvbot_runner-1", created: false});
  assert.equal(
    firestore.get("matches/suvbot_runner-1")?.lastMessagePreview,
    "Existing"
  );
});
