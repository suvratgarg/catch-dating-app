import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  addClubHostHandler,
  removeClubHostHandler,
  transferClubOwnershipHandler,
} from "./manageClubHosts";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  get id(): string {
    return this.path.split("/").at(-1) ?? this.path;
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

class FakeQueryDocSnapshot extends FakeSnapshot {
  constructor(readonly id: string, value: FakeData) {
    super(value);
  }
}

class FakeQuerySnapshot {
  constructor(readonly docs: FakeQueryDocSnapshot[]) {}

  get empty(): boolean {
    return this.docs.length === 0;
  }
}

class FakeQuery {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly collectionPath: string,
    private readonly filters: Array<[string, unknown]> = [],
    private readonly maxDocs?: number
  ) {}

  where(field: string, op: string, value: unknown): FakeQuery {
    assert.equal(op, "==");
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      [...this.filters, [field, value]],
      this.maxDocs
    );
  }

  limit(maxDocs: number): FakeQuery {
    return new FakeQuery(
      this.firestore,
      this.collectionPath,
      this.filters,
      maxDocs
    );
  }

  async get(): Promise<FakeQuerySnapshot> {
    const docs = this.firestore
      .queryCollection(this.collectionPath, this.filters)
      .slice(0, this.maxDocs)
      .map(({id, data}) => new FakeQueryDocSnapshot(id, data));
    return new FakeQuerySnapshot(docs);
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    const query = new FakeQuery(this, collectionPath);
    return {
      doc: (docId: string) => new FakeDocRef(
        this,
        `${collectionPath}/${docId}`
      ),
      where: query.where.bind(query),
      limit: query.limit.bind(query),
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

  delete(path: string) {
    delete this.docs[path];
  }

  queryCollection(
    collectionPath: string,
    filters: Array<[string, unknown]>
  ): Array<{id: string; data: FakeData}> {
    const prefix = `${collectionPath}/`;
    return Object.entries(this.docs)
      .filter(([path, data]) =>
        path.startsWith(prefix) &&
        path.slice(prefix.length).split("/").length === 1 &&
        data !== undefined
      )
      .map(([path, data]) => ({
        id: path.slice(prefix.length),
        data: data as FakeData,
      }))
      .filter(({data}) =>
        filters.every(([field, value]) => data[field] === value)
      );
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
      this.firestore.set(ref.path, {
        ...(this.firestore.get(ref.path) ?? {}),
        ...patch,
      });
    });
  }

  set(ref: FakeDocRef, patch: FakeData, options?: {merge?: boolean}) {
    this.writes.push(() => {
      this.firestore.set(ref.path, {
        ...(options?.merge ? this.firestore.get(ref.path) ?? {} : {}),
        ...patch,
      });
    });
  }

  delete(ref: FakeDocRef) {
    this.writes.push(() => {
      this.firestore.delete(ref.path);
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
    hostUserId: "owner-1",
    hostName: "Owner",
    hostAvatarUrl: null,
    ownerUserId: "owner-1",
    hostUserIds: ["owner-1"],
    hostProfiles: [{
      uid: "owner-1",
      displayName: "Owner",
      avatarUrl: null,
      role: "owner",
    }],
    ...overrides,
  };
}

function user(overrides: FakeData = {}): FakeData {
  return {
    profileComplete: true,
    name: "Co Host",
    displayName: "Co Host",
    profilePhotos: [],
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("addClubHostHandler adds an existing user as co-host", async () => {
  const h = harness({
    "clubs/club-1": club(),
    "users/cohost-1": user(),
  });

  const result = await addClubHostHandler(
    request("owner-1", {clubId: "club-1", uid: "cohost-1"}),
    h.deps
  );

  assert.deepEqual(result, {added: true});
  assert.deepEqual(h.rateLimitCalls, ["owner-1:addClubHost"]);
  assert.deepEqual(h.firestore.get("clubs/club-1")?.hostUserIds, [
    "owner-1",
    "cohost-1",
  ]);
  assert.deepEqual(
    (h.firestore.get("clubs/club-1")?.hostProfiles as FakeData[]).at(-1),
    {
      uid: "cohost-1",
      displayName: "Co Host",
      avatarUrl: null,
      role: "host",
    }
  );
  assert.equal(
    h.firestore.get("clubMemberships/club-1_cohost-1")?.role,
    "host"
  );
});

test("addClubHostHandler resolves a co-host by normalized phone number",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "users/cohost-1": user({phoneNumber: "+919876543210"}),
    });

    const result = await addClubHostHandler(
      request("owner-1", {clubId: "club-1", phoneNumber: "98765 43210"}),
      h.deps
    );

    assert.deepEqual(result, {added: true});
    assert.deepEqual(h.firestore.get("clubs/club-1")?.hostUserIds, [
      "owner-1",
      "cohost-1",
    ]);
    assert.equal(
      h.firestore.get("clubMemberships/club-1_cohost-1")?.role,
      "host"
    );
  }
);

test("removeClubHostHandler removes a co-host without removing membership",
  async () => {
    const h = harness({
      "clubs/club-1": club({
        hostUserIds: ["owner-1", "cohost-1"],
        hostProfiles: [
          {
            uid: "owner-1",
            displayName: "Owner",
            avatarUrl: null,
            role: "owner",
          },
          {
            uid: "cohost-1",
            displayName: "Co Host",
            avatarUrl: null,
            role: "host",
          },
        ],
      }),
      "clubMemberships/club-1_cohost-1": {
        clubId: "club-1",
        uid: "cohost-1",
        role: "host",
        status: "active",
      },
    });

    const result = await removeClubHostHandler(
      request("owner-1", {clubId: "club-1", uid: "cohost-1"}),
      h.deps
    );

    assert.deepEqual(result, {removed: true});
    assert.deepEqual(h.firestore.get("clubs/club-1")?.hostUserIds, [
      "owner-1",
    ]);
    assert.equal(
      h.firestore.get("clubMemberships/club-1_cohost-1")?.role,
      "member"
    );
  }
);

test("club host management rejects non-owner callers and owner removal",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "users/cohost-1": user(),
    });

    await assert.rejects(
      () => addClubHostHandler(
        request("cohost-1", {clubId: "club-1", uid: "cohost-1"}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "permission-denied")
    );
    await assert.rejects(
      () => removeClubHostHandler(
        request("owner-1", {clubId: "club-1", uid: "owner-1"}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  }
);

test("transferClubOwnershipHandler promotes an existing co-host",
  async () => {
    const h = harness({
      "clubs/club-1": club({
        hostUserIds: ["owner-1", "cohost-1"],
        hostProfiles: [
          {
            uid: "owner-1",
            displayName: "Owner",
            avatarUrl: null,
            role: "owner",
          },
          {
            uid: "cohost-1",
            displayName: "Co Host",
            avatarUrl: null,
            role: "host",
          },
        ],
      }),
      "users/cohost-1": user(),
      "clubHostClaims/owner-1": {uid: "owner-1", clubId: "club-1"},
      "clubMemberships/club-1_owner-1": {
        clubId: "club-1",
        uid: "owner-1",
        role: "owner",
        status: "active",
      },
      "clubMemberships/club-1_cohost-1": {
        clubId: "club-1",
        uid: "cohost-1",
        role: "host",
        status: "active",
      },
    });

    const result = await transferClubOwnershipHandler(
      request("owner-1", {clubId: "club-1", uid: "cohost-1"}),
      h.deps
    );

    const updatedClub = h.firestore.get("clubs/club-1");
    assert.deepEqual(result, {transferred: true});
    assert.equal(updatedClub?.ownerUserId, "cohost-1");
    assert.equal(updatedClub?.hostUserId, "cohost-1");
    assert.deepEqual(updatedClub?.hostUserIds, ["cohost-1", "owner-1"]);
    assert.equal(
      h.firestore.get("clubMemberships/club-1_owner-1")?.role,
      "host"
    );
    assert.equal(
      h.firestore.get("clubMemberships/club-1_cohost-1")?.role,
      "owner"
    );
    assert.equal(h.firestore.get("clubHostClaims/owner-1"), undefined);
    assert.deepEqual(h.firestore.get("clubHostClaims/cohost-1"), {
      uid: "cohost-1",
      clubId: "club-1",
    });
  }
);
