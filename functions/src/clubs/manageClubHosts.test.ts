/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {addClubHostHandler, removeClubHostHandler} from "./manageClubHosts";

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
    photoUrls: [],
    photoThumbnailUrls: [],
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
