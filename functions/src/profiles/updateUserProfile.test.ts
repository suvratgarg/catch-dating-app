/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {updateUserProfileHandler} from "./updateUserProfile";

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

  update(ref: FakeDocRef, patch: FakeData) {
    this.writes.push(() => {
      const current = this.firestore.get(ref.path);
      if (current === undefined) {
        throw new Error(`Missing doc for update: ${ref.path}`);
      }
      this.firestore.set(ref.path, {...current, ...patch});
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function harness(initialDocs: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initialDocs);
  return {
    firestore,
    deps: {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      timestampFromMillis: (millis: number) =>
        ({kind: "timestamp", millis}) as unknown as
          FirebaseFirestore.Timestamp,
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

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("updateUserProfileHandler validates and applies profile patches",
  async () => {
    const h = harness({
      "users/runner-1": {name: "Runner One", profileComplete: false},
    });

    await updateUserProfileHandler(
      request("runner-1", {
        fields: {
          name: "Runner Updated",
          displayName: "Runner R.",
          dateOfBirth: 946684800000,
          gender: "woman",
          photoUrls: ["https://example.test/profile.jpg"],
          paceMinSecsPerKm: 300,
          prefsWeeklyDigest: true,
        },
      }),
      h.deps
    );

    assert.deepEqual(h.firestore.get("users/runner-1"), {
      name: "Runner Updated",
      displayName: "Runner R.",
      profileComplete: false,
      dateOfBirth: {kind: "timestamp", millis: 946684800000},
      gender: "woman",
      photoUrls: ["https://example.test/profile.jpg"],
      paceMinSecsPerKm: 300,
      prefsWeeklyDigest: true,
    });
  }
);

test("updateUserProfileHandler rejects invalid payloads", async () => {
  const h = harness({"users/runner-1": {name: "Runner One"}});

  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {dateOfBirth: "1998-01-01"}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {unknownField: true}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {displayName: "   "}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(request("runner-1", {fields: {}}), h.deps),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
  await assert.rejects(
    updateUserProfileHandler(
      request(null, {fields: {name: "Runner Updated"}}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "unauthenticated")
  );
});

test("updateUserProfileHandler rejects unsafe account states", async () => {
  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {name: "Runner Updated"}}),
      harness({}).deps
    ),
    (error) => assertHttpsCode(error, "not-found")
  );

  await assert.rejects(
    updateUserProfileHandler(
      request("runner-1", {fields: {name: "Runner Updated"}}),
      harness({
        "users/runner-1": {name: "Runner One"},
        "deletedUsers/runner-1": {uid: "runner-1"},
      }).deps
    ),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});
