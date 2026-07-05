import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {createClubPostHandler} from "./clubPosts";
import {FcmParams} from "../shared/notifications";

type FakeData = Record<string, unknown>;
type Filter = {field: string; op: string; value: unknown};

class FakeDocRef {
  readonly id: string;

  constructor(readonly firestore: FakeFirestore, readonly path: string) {
    this.id = path.split("/").at(-1) ?? "";
  }

  collection(collectionPath: string) {
    return new FakeCollection(this.firestore, `${this.path}/${collectionPath}`);
  }

  async get() {
    return new FakeSnapshot(this.firestore.get(this.path));
  }

  async set(data: FakeData, options?: {merge?: boolean}) {
    this.firestore.set(this.path, data, options);
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

class FakeQuerySnapshot {
  constructor(readonly docs: Array<{data: () => FakeData}>) {}
}

class FakeCollection {
  constructor(
    private readonly firestore: FakeFirestore,
    readonly path: string
  ) {}

  doc(docId = "generated-post-id") {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }

  where(field: string, op: string, value: unknown) {
    return new FakeQuery(this.firestore, this.path, [{field, op, value}]);
  }
}

class FakeQuery {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly collectionPath: string,
    private readonly filters: Filter[]
  ) {}

  where(field: string, op: string, value: unknown) {
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      [...this.filters, {field, op, value}]
    );
  }

  async get(): Promise<FakeQuerySnapshot> {
    return new FakeQuerySnapshot(
      this.firestore.query(this.collectionPath, this.filters).map((data) => ({
        data: () => ({...data}),
      }))
    );
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return new FakeCollection(this, collectionPath);
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

  set(path: string, data: FakeData, options?: {merge?: boolean}) {
    const current = options?.merge === true ? this.docs[path] : undefined;
    this.docs[path] = current === undefined ?
      {...data} :
      {...current, ...data};
  }

  create(path: string, data: FakeData) {
    if (this.docs[path] !== undefined) {
      throw new Error(`Doc already exists: ${path}`);
    }
    this.docs[path] = data;
  }

  query(collectionPath: string, filters: Filter[]): FakeData[] {
    return Object.entries(this.docs)
      .filter(([path]) => parentCollection(path) === collectionPath)
      .map(([, data]) => data)
      .filter((data): data is FakeData => data !== undefined)
      .filter((data) => filters.every((filter) => matchesFilter(data, filter)))
      .map((data) => ({...data}));
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(refOrQuery: FakeDocRef | FakeQuery) {
    if (refOrQuery instanceof FakeQuery) return refOrQuery.get();
    return new FakeSnapshot(this.firestore.get(refOrQuery.path));
  }

  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => this.firestore.create(ref.path, {...data}));
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function parentCollection(path: string): string {
  const parts = path.split("/");
  return parts.slice(0, -1).join("/");
}

function matchesFilter(data: FakeData, filter: Filter): boolean {
  const value = data[filter.field];
  if (filter.op === "==") return value === filter.value;
  if (filter.op === ">=") {
    return toMillis(value) >= toMillis(filter.value);
  }
  throw new Error(`Unsupported fake query op: ${filter.op}`);
}

function toMillis(value: unknown): number {
  if (typeof value === "object" && value !== null && "millis" in value) {
    return Number((value as {millis: number}).millis);
  }
  if (typeof value === "object" && value !== null && "toMillis" in value) {
    return Number((value as {toMillis: () => number}).toMillis());
  }
  return Number.NaN;
}

function harness(initialDocs: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initialDocs);
  const rateLimitCalls: string[] = [];
  const sentPushes: FcmParams[] = [];
  const now = new Date("2026-07-05T12:00:00.000Z");
  return {
    firestore,
    rateLimitCalls,
    sentPushes,
    now,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      now: () => now,
      timestampFromMillis: (millis: number) =>
        ({millis}) as unknown as FirebaseFirestore.Timestamp,
      serverTimestamp: () =>
        ({kind: "serverTimestamp"}) as unknown as FirebaseFirestore.FieldValue,
      checkRateLimit: async (
        _db: FirebaseFirestore.Firestore,
        uid: string,
        action: string
      ) => {
        rateLimitCalls.push(`${uid}:${action}`);
      },
      sendNotification: async (params: FcmParams) => {
        sentPushes.push(params);
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
    name: "Race Course Road",
    hostUserId: "host-1",
    hostUserIds: ["host-1"],
    ...overrides,
  };
}

function recentPost(index: number): FakeData {
  return {
    authorUid: "host-1",
    text: `Recent ${index}`,
    createdAt: {millis: Date.parse("2026-07-04T12:00:00.000Z")},
    audience: "followers",
    status: "active",
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("createClubPostHandler writes a post and fans out follower activity",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "clubMemberships/club-1_host-1": {
        clubId: "club-1",
        uid: "host-1",
        status: "active",
      },
      "clubMemberships/club-1_runner-1": {
        clubId: "club-1",
        uid: "runner-1",
        status: "active",
        pushNotificationsEnabled: true,
      },
      "users/runner-1": {
        fcmToken: "token-1",
        prefsClubUpdates: true,
      },
    });

    const result = await createClubPostHandler(
      request("host-1", {
        clubId: "club-1",
        text: " Meet ten minutes early. ",
      }),
      h.deps
    );

    assert.deepEqual(h.rateLimitCalls, ["host-1:createClubPost"]);
    assert.deepEqual(result, {
      postId: "generated-post-id",
      remainingWeeklyQuota: 2,
    });
    assert.equal(
      h.firestore.get("clubs/club-1/posts/generated-post-id")?.text,
      "Meet ten minutes early."
    );
    assert.equal(
      h.firestore.get(
        "notifications/runner-1/items/clubUpdate_generated-post-id"
      )?.postId,
      "generated-post-id"
    );
    assert.equal(h.sentPushes.length, 1);
    assert.equal(h.sentPushes[0].postId, "generated-post-id");
  }
);

test("createClubPostHandler enforces three active posts per rolling week",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "clubs/club-1/posts/post-1": recentPost(1),
      "clubs/club-1/posts/post-2": recentPost(2),
      "clubs/club-1/posts/post-3": recentPost(3),
    });

    await assert.rejects(
      () => createClubPostHandler(
        request("host-1", {
          clubId: "club-1",
          text: "Fourth post",
        }),
        h.deps
      ),
      (error) => assertHttpsCode(error, "resource-exhausted")
    );
  }
);
