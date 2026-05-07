/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {createRunClubHandler} from "./createRunClub";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  readonly id: string;

  constructor(readonly firestore: FakeFirestore, readonly path: string) {
    this.id = path.split("/").at(-1) ?? "";
  }
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
      doc: (docId = "generated-club-id") => new FakeDocRef(
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
      if (this.firestore.get(ref.path) !== undefined) {
        throw new Error(`Doc already exists: ${ref.path}`);
      }
      this.firestore.set(ref.path, applyPatch({}, data));
    });
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

  set(ref: FakeDocRef, patch: FakeData, options?: {merge?: boolean}) {
    this.writes.push(() => {
      const current = options?.merge ?
        this.firestore.get(ref.path) ?? {} :
        {};
      this.firestore.set(ref.path, applyPatch(current, patch));
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function applyPatch(current: FakeData, patch: FakeData): FakeData {
  const next = {...current};
  for (const [field, value] of Object.entries(patch)) {
    if (isArrayUnion(value)) {
      const values = Array.isArray(next[field]) ?
        [...(next[field] as string[])] :
        [];
      next[field] = values.includes(value.value) ?
        values :
        [...values, value.value];
    } else {
      next[field] = value;
    }
  }
  return next;
}

function isArrayUnion(value: unknown): value is {kind: string; value: string} {
  return typeof value === "object" &&
    value !== null &&
    "kind" in value &&
    (value as {kind: string}).kind === "arrayUnion";
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
      serverTimestamp: () =>
        ({kind: "serverTimestamp"}) as unknown as FirebaseFirestore.FieldValue,
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

function profile(overrides: FakeData = {}): FakeData {
  return {
    profileComplete: true,
    name: "Asha Runner",
    photoUrls: ["https://example.com/avatar.jpg"],
    ...overrides,
  };
}

function payload(overrides: FakeData = {}): FakeData {
  return {
    clubId: "club-1",
    name: "Morning Miles",
    description: "Easy weekday runs.",
    location: "mumbai",
    area: "Bandra",
    imageUrl: "https://example.com/cover.jpg",
    instagramHandle: "@morningmiles",
    phoneNumber: "+91 99999 99999",
    email: "hello@example.com",
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("createRunClubHandler creates a club and host membership edge",
  async () => {
    const h = harness({"users/host-1": profile()});

    const result = await createRunClubHandler(
      request("host-1", payload()),
      h.deps
    );

    assert.deepEqual(result, {clubId: "club-1"});
    assert.deepEqual(h.rateLimitCalls, ["host-1:createRunClub"]);
    assert.deepEqual(h.firestore.get("runClubs/club-1"), {
      name: "Morning Miles",
      description: "Easy weekday runs.",
      location: "mumbai",
      area: "Bandra",
      hostUserId: "host-1",
      hostName: "Asha Runner",
      hostAvatarUrl: "https://example.com/avatar.jpg",
      createdAt: {kind: "serverTimestamp"},
      imageUrl: "https://example.com/cover.jpg",
      tags: [],
      memberCount: 1,
      rating: 0,
      reviewCount: 0,
      nextRunAt: null,
      nextRunLabel: null,
      instagramHandle: "@morningmiles",
      phoneNumber: "+91 99999 99999",
      email: "hello@example.com",
    });
    assert.deepEqual(
      {
        clubId: h.firestore.get("runClubMemberships/club-1_host-1")?.clubId,
        uid: h.firestore.get("runClubMemberships/club-1_host-1")?.uid,
        role: h.firestore.get("runClubMemberships/club-1_host-1")?.role,
        status: h.firestore.get("runClubMemberships/club-1_host-1")?.status,
      },
      {
        clubId: "club-1",
        uid: "host-1",
        role: "host",
        status: "active",
      }
    );
  }
);

test("createRunClubHandler can generate the club id server-side", async () => {
  const h = harness({"users/host-1": profile({photoUrls: []})});

  const result = await createRunClubHandler(
    request("host-1", payload({clubId: undefined, imageUrl: undefined})),
    h.deps
  );

  assert.deepEqual(result, {clubId: "generated-club-id"});
  assert.equal(
    h.firestore.get("runClubs/generated-club-id")?.hostAvatarUrl,
    null
  );
  assert.equal(h.firestore.get("runClubs/generated-club-id")?.imageUrl, null);
  assert.equal(
    h.firestore.get("runClubMemberships/generated-club-id_host-1")?.status,
    "active"
  );
});

test("createRunClubHandler rejects unsafe creation states", async () => {
  const h = harness({
    "runClubs/existing": {name: "Existing"},
    "users/host-1": profile(),
    "users/incomplete": profile({profileComplete: false}),
    "users/deleted": profile(),
    "deletedUsers/deleted": {deletedAt: "now"},
  });

  await assert.rejects(
    () => createRunClubHandler(request(null, payload()), h.deps),
    (error) => assertHttpsCode(error, "unauthenticated")
  );
  await assert.rejects(
    () => createRunClubHandler(
      request("host-1", payload({clubId: "existing"})),
      h.deps
    ),
    (error) => assertHttpsCode(error, "already-exists")
  );
  await assert.rejects(
    () => createRunClubHandler(request("missing", payload()), h.deps),
    (error) => assertHttpsCode(error, "not-found")
  );
  await assert.rejects(
    () => createRunClubHandler(request("incomplete", payload()), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
  await assert.rejects(
    () => createRunClubHandler(request("deleted", payload()), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});
