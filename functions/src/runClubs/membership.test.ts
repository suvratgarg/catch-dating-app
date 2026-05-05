/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {joinRunClubHandler, leaveRunClubHandler} from "./membership";

type FakeData = Record<string, unknown>;
type SentinelKind = "arrayUnion" | "arrayRemove";

interface Sentinel {
  kind: SentinelKind;
  value: string;
}

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

  update(ref: FakeDocRef, patch: FakeData) {
    this.writes.push(() => {
      const current = this.firestore.get(ref.path);
      if (current === undefined) {
        throw new Error(`Missing doc for update: ${ref.path}`);
      }
      this.firestore.set(ref.path, applyPatch(current, patch));
    });
  }

  set(ref: FakeDocRef, data: FakeData, options?: {merge: boolean}) {
    this.writes.push(() => {
      if (options?.merge) {
        this.firestore.set(
          ref.path,
          applyPatch(this.firestore.get(ref.path) ?? {}, data)
        );
        return;
      }
      this.firestore.set(ref.path, applyPatch({}, data));
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function applyPatch(current: FakeData, patch: FakeData): FakeData {
  const next = {...current};
  for (const [field, value] of Object.entries(patch)) {
    if (isSentinel(value)) {
      const values = Array.isArray(next[field]) ?
        [...(next[field] as string[])] :
        [];
      if (value.kind === "arrayUnion") {
        next[field] = values.includes(value.value) ?
          values :
          [...values, value.value];
      } else {
        next[field] = values.filter((item) => item !== value.value);
      }
    } else {
      next[field] = value;
    }
  }
  return next;
}

function isSentinel(value: unknown): value is Sentinel {
  return typeof value === "object" &&
    value !== null &&
    "kind" in value &&
    "value" in value;
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
      arrayUnion: (value: string) =>
        ({kind: "arrayUnion", value}) as unknown as
          FirebaseFirestore.FieldValue,
      arrayRemove: (value: string) =>
        ({kind: "arrayRemove", value}) as unknown as
          FirebaseFirestore.FieldValue,
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
  uid: string | null,
  data: Record<string, unknown>
): CallableRequest<unknown> {
  return {
    auth: uid ? {uid, token: {}} as CallableRequest["auth"] : undefined,
    data,
    rawRequest: {} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function user(overrides: FakeData = {}): FakeData {
  return {
    profileComplete: true,
    joinedRunClubIds: [],
    ...overrides,
  };
}

function club(overrides: FakeData = {}): FakeData {
  return {
    hostUserId: "host-1",
    memberUserIds: ["host-1"],
    memberCount: 1,
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("joinRunClubHandler joins the club and mirrors the user projection",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "users/runner-1": user(),
    });

    await joinRunClubHandler(
      request("runner-1", {clubId: "club-1"}),
      h.deps
    );

    assert.deepEqual(h.firestore.get("runClubs/club-1")?.memberUserIds, [
      "host-1",
      "runner-1",
    ]);
    assert.deepEqual(h.rateLimitCalls, ["runner-1:joinRunClub"]);
    assert.equal(h.firestore.get("runClubs/club-1")?.memberCount, 2);
    assert.deepEqual(h.firestore.get("users/runner-1")?.joinedRunClubIds, [
      "club-1",
    ]);
  }
);

test("joinRunClubHandler is idempotent and repairs stale memberCount",
  async () => {
    const h = harness({
      "runClubs/club-1": club({
        memberUserIds: ["host-1", "runner-1"],
        memberCount: 99,
      }),
      "users/runner-1": user(),
    });

    await joinRunClubHandler(
      request("runner-1", {clubId: "club-1"}),
      h.deps
    );

    assert.deepEqual(h.firestore.get("runClubs/club-1")?.memberUserIds, [
      "host-1",
      "runner-1",
    ]);
    assert.equal(h.firestore.get("runClubs/club-1")?.memberCount, 2);
    assert.deepEqual(h.firestore.get("users/runner-1")?.joinedRunClubIds, [
      "club-1",
    ]);
  }
);

test("leaveRunClubHandler leaves the club and mirrors the user projection",
  async () => {
    const h = harness({
      "runClubs/club-1": club({
        memberUserIds: ["host-1", "runner-1"],
        memberCount: 2,
      }),
      "users/runner-1": user({joinedRunClubIds: ["club-1", "club-2"]}),
    });

    await leaveRunClubHandler(
      request("runner-1", {clubId: "club-1"}),
      h.deps
    );

    assert.deepEqual(h.firestore.get("runClubs/club-1")?.memberUserIds, [
      "host-1",
    ]);
    assert.deepEqual(h.rateLimitCalls, ["runner-1:leaveRunClub"]);
    assert.equal(h.firestore.get("runClubs/club-1")?.memberCount, 1);
    assert.deepEqual(h.firestore.get("users/runner-1")?.joinedRunClubIds, [
      "club-2",
    ]);
  }
);

test("leaveRunClubHandler is idempotent and repairs stale user projection",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "users/runner-1": user({joinedRunClubIds: ["club-1", "club-2"]}),
    });

    await leaveRunClubHandler(
      request("runner-1", {clubId: "club-1"}),
      h.deps
    );

    assert.deepEqual(h.firestore.get("runClubs/club-1")?.memberUserIds, [
      "host-1",
    ]);
    assert.equal(h.firestore.get("runClubs/club-1")?.memberCount, 1);
    assert.deepEqual(h.firestore.get("users/runner-1")?.joinedRunClubIds, [
      "club-2",
    ]);
  }
);

test("leaveRunClubHandler rejects host leave attempts",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "users/host-1": user({joinedRunClubIds: ["club-1"]}),
    });

    await assert.rejects(
      () => leaveRunClubHandler(request("host-1", {clubId: "club-1"}), h.deps),
      (error) => assertHttpsCode(error, "failed-precondition")
    );

    assert.deepEqual(h.firestore.get("runClubs/club-1")?.memberUserIds, [
      "host-1",
    ]);
    assert.deepEqual(h.firestore.get("users/host-1")?.joinedRunClubIds, [
      "club-1",
    ]);
  }
);

test("membership handlers reject missing auth, missing docs, and bad profiles",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "users/incomplete": user({profileComplete: false}),
      "users/deleted": user(),
      "deletedUsers/deleted": {deletedAt: "now"},
    });

    await assert.rejects(
      () => joinRunClubHandler(request(null, {clubId: "club-1"}), h.deps),
      (error) => assertHttpsCode(error, "unauthenticated")
    );
    await assert.rejects(
      () => joinRunClubHandler(
        request("runner-1", {clubId: "missing"}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "not-found")
    );
    await assert.rejects(
      () => joinRunClubHandler(request("missing", {clubId: "club-1"}), h.deps),
      (error) => assertHttpsCode(error, "not-found")
    );
    await assert.rejects(
      () => joinRunClubHandler(
        request("incomplete", {clubId: "club-1"}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
    await assert.rejects(
      () => joinRunClubHandler(request("deleted", {clubId: "club-1"}), h.deps),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  }
);
