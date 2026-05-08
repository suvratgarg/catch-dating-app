/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  archiveRunClubHandler,
  deleteRunClubHandler,
  updateRunClubHandler,
} from "./mutateRunClub";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(this.path), this);
  }
}

class FakeSnapshot {
  constructor(
    private readonly value: FakeData | undefined,
    readonly ref?: FakeDocRef
  ) {}

  get exists(): boolean {
    return this.value !== undefined;
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : {...this.value};
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string,
    private readonly filters: Array<{field: string; value: unknown}> = [],
    private readonly limitCount?: number
  ) {}

  doc(docId: string) {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }

  where(field: string, operator: string, value: unknown) {
    if (operator !== "==") {
      throw new Error(`Unsupported fake query operator: ${operator}`);
    }
    return new FakeCollectionRef(this.firestore, this.path, [
      ...this.filters,
      {field, value},
    ], this.limitCount);
  }

  limit(count: number) {
    return new FakeCollectionRef(
      this.firestore,
      this.path,
      this.filters,
      count
    );
  }

  async get() {
    const docs = this.firestore.query(this.path, this.filters);
    const limitedDocs =
      this.limitCount === undefined ? docs : docs.slice(0, this.limitCount);
    return {docs: limitedDocs, empty: limitedDocs.length === 0};
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return new FakeCollectionRef(this, collectionPath);
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

  set(path: string, data: FakeData | undefined) {
    this.docs[path] = data;
  }

  query(
    collectionPath: string,
    filters: Array<{field: string; value: unknown}>
  ): FakeSnapshot[] {
    const prefix = `${collectionPath}/`;
    return Object.entries(this.docs)
      .filter(([path, value]) =>
        path.startsWith(prefix) &&
        value !== undefined &&
        !path.slice(prefix.length).includes("/")
      )
      .map(([path, value]) =>
        new FakeSnapshot(
          value,
          new FakeDocRef(this, path)
        )
      )
      .filter((snap) => {
        const data = snap.data() ?? {};
        return filters.every((filter) => data[filter.field] === filter.value);
      });
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef | FakeCollectionRef) {
    if (ref instanceof FakeCollectionRef) {
      return ref.get();
    }
    return new FakeSnapshot(this.firestore.get(ref.path), ref);
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

  delete(ref: FakeDocRef) {
    this.writes.push(() => this.firestore.set(ref.path, undefined));
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
      serverTimestamp: () => ({kind: "serverTimestamp"} as unknown) as
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

function club(overrides: FakeData = {}): FakeData {
  return {
    hostUserId: "host-1",
    name: "Indore Striders",
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("archiveRunClubHandler marks a hosted club archived", async () => {
  const h = harness({"runClubs/club-1": club()});

  const result = await archiveRunClubHandler(
    request("host-1", {clubId: "club-1", reason: "No longer active."}),
    h.deps
  );

  assert.deepEqual(result, {archived: true});
  assert.deepEqual(h.rateLimitCalls, ["host-1:archiveRunClub"]);
  const updated = h.firestore.get("runClubs/club-1");
  assert.equal(updated?.status, "archived");
  assert.equal(updated?.archived, true);
  assert.equal(updated?.archiveReason, "No longer active.");
});

test("updateRunClubHandler updates hosted club profile fields", async () => {
  const h = harness({"runClubs/club-1": club({description: "Old"})});

  const result = await updateRunClubHandler(
    request("host-1", {
      clubId: "club-1",
      fields: {
        description: "Updated city loops.",
        tags: ["easy"],
        instagramHandle: "@indorestriders",
      },
    }),
    h.deps
  );

  assert.deepEqual(result, {updated: true});
  assert.deepEqual(h.rateLimitCalls, ["host-1:updateRunClub"]);
  const updated = h.firestore.get("runClubs/club-1");
  assert.equal(updated?.description, "Updated city loops.");
  assert.deepEqual(updated?.tags, ["easy"]);
  assert.equal(updated?.instagramHandle, "@indorestriders");
});

test("updateRunClubHandler rejects non-host updates", async () => {
  const h = harness({"runClubs/club-1": club()});

  await assert.rejects(
    () => updateRunClubHandler(
      request("runner-1", {
        clubId: "club-1",
        fields: {description: "Nope."},
      }),
      h.deps
    ),
    (error) => assertHttpsCode(error, "permission-denied")
  );
});

test("updateRunClubHandler rejects server-owned field updates", async () => {
  const h = harness({"runClubs/club-1": club()});

  await assert.rejects(
    () => updateRunClubHandler(
      request("host-1", {
        clubId: "club-1",
        fields: {memberCount: 100},
      }),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
});

test("deleteRunClubHandler hard-deletes only unused clubs", async () => {
  const h = harness({
    "runClubs/club-1": club(),
    "runClubHostClaims/host-1": {
      uid: "host-1",
      clubId: "club-1",
    },
    "runClubMemberships/club-1_host-1": {
      clubId: "club-1",
      uid: "host-1",
      role: "host",
    },
  });

  const result = await deleteRunClubHandler(
    request("host-1", {clubId: "club-1"}),
    h.deps
  );

  assert.deepEqual(result, {deleted: true});
  assert.deepEqual(h.rateLimitCalls, ["host-1:deleteRunClub"]);
  assert.equal(h.firestore.get("runClubs/club-1"), undefined);
  assert.equal(h.firestore.get("runClubHostClaims/host-1"), undefined);
  assert.equal(
    h.firestore.get("runClubMemberships/club-1_host-1"),
    undefined
  );
});

test(
  "deleteRunClubHandler rejects clubs with activity or members",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "runClubMemberships/club-1_host-1": {
        clubId: "club-1",
        uid: "host-1",
        role: "host",
      },
      "runClubMemberships/club-1_runner-1": {
        clubId: "club-1",
        uid: "runner-1",
        role: "member",
      },
    });

    await assert.rejects(
      () => deleteRunClubHandler(
        request("host-1", {clubId: "club-1"}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
    assert.notEqual(h.firestore.get("runClubs/club-1"), undefined);
  }
);
