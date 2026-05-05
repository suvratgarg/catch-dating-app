/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {createRunHandler, updateRunHandler} from "./mutateRun";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  get id(): string {
    return this.path.split("/").at(-1) ?? "";
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
  private autoId = 0;

  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return {
      doc: (docId?: string) => new FakeDocRef(
        this,
        `${collectionPath}/${docId ?? `auto-${++this.autoId}`}`
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
      this.firestore.set(ref.path, data);
    });
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
  const rateLimitCalls: string[] = [];
  return {
    firestore,
    rateLimitCalls,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      timestampFromMillis: (millis: number) =>
        admin.firestore.Timestamp.fromMillis(millis),
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
    ...overrides,
  };
}

function run(overrides: FakeData = {}): FakeData {
  return {
    runClubId: "club-1",
    startTime: ts("2026-05-02T01:30:00.000Z"),
    endTime: ts("2026-05-02T02:30:00.000Z"),
    meetingPoint: "Carter Road",
    startingPointLat: null,
    startingPointLng: null,
    locationDetails: null,
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy seaside run.",
    priceInPaise: 0,
    signedUpUserIds: [],
    attendedUserIds: [],
    waitlistUserIds: [],
    constraints: {minAge: 0, maxAge: 99, maxMen: null, maxWomen: null},
    genderCounts: {},
    ...overrides,
  };
}

function payload(overrides: FakeData = {}): FakeData {
  return {
    runId: "run-1",
    runClubId: "club-1",
    startTimeMillis: Date.parse("2026-05-02T01:30:00.000Z"),
    endTimeMillis: Date.parse("2026-05-02T02:30:00.000Z"),
    meetingPoint: "Carter Road",
    startingPointLat: 19.07,
    startingPointLng: 72.82,
    locationDetails: null,
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy seaside run.",
    priceInPaise: 0,
    constraints: {minAge: 21, maxAge: 35, maxMen: 10, maxWomen: null},
    ...overrides,
  };
}

function ts(iso: string): FirebaseFirestore.Timestamp {
  return admin.firestore.Timestamp.fromDate(new Date(iso));
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("createRunHandler creates a server-owned run for the club host",
  async () => {
    const h = harness({"runClubs/club-1": club()});

    const result = await createRunHandler(
      request("host-1", payload()),
      h.deps
    );

    assert.deepEqual(result, {runId: "run-1"});
    assert.deepEqual(h.rateLimitCalls, ["host-1:createRun"]);
    assert.deepEqual(h.firestore.get("runs/run-1"), {
      runClubId: "club-1",
      startTime: ts("2026-05-02T01:30:00.000Z"),
      endTime: ts("2026-05-02T02:30:00.000Z"),
      meetingPoint: "Carter Road",
      startingPointLat: 19.07,
      startingPointLng: 72.82,
      locationDetails: null,
      distanceKm: 5,
      pace: "easy",
      capacityLimit: 20,
      description: "Easy seaside run.",
      priceInPaise: 0,
      signedUpUserIds: [],
      attendedUserIds: [],
      waitlistUserIds: [],
      constraints: {minAge: 21, maxAge: 35, maxMen: 10, maxWomen: null},
      genderCounts: {},
    });
  }
);

test("createRunHandler rejects unsafe creation states", async () => {
  const h = harness({
    "runClubs/club-1": club(),
    "runs/existing": run(),
    "deletedUsers/deleted-host": {deletedAt: "now"},
  });

  await assert.rejects(
    () => createRunHandler(request(null, payload()), h.deps),
    (error) => assertHttpsCode(error, "unauthenticated")
  );
  await assert.rejects(
    () => createRunHandler(request("host-1", payload({
      runId: "existing",
    })), h.deps),
    (error) => assertHttpsCode(error, "already-exists")
  );
  await assert.rejects(
    () => createRunHandler(request("runner-1", payload()), h.deps),
    (error) => assertHttpsCode(error, "permission-denied")
  );
  await assert.rejects(
    () => createRunHandler(request("deleted-host", payload()), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
  await assert.rejects(
    () => createRunHandler(request("host-1", payload({
      startingPointLng: null,
    })), h.deps),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
});

test("updateRunHandler updates only host-editable run fields", async () => {
  const h = harness({
    "runClubs/club-1": club(),
    "runs/run-1": run({capacityLimit: 12}),
  });

  const result = await updateRunHandler(
    request("host-1", {
      runId: "run-1",
      fields: {
        startTimeMillis: Date.parse("2026-05-02T02:00:00.000Z"),
        endTimeMillis: Date.parse("2026-05-02T03:00:00.000Z"),
        meetingPoint: "Joggers Park",
        description: "Updated route.",
      },
    }),
    h.deps
  );

  const updated = h.firestore.get("runs/run-1");
  assert.deepEqual(result, {updated: true});
  assert.deepEqual(h.rateLimitCalls, ["host-1:updateRun"]);
  assert.equal(updated?.meetingPoint, "Joggers Park");
  assert.equal(updated?.description, "Updated route.");
  assert.equal(updated?.capacityLimit, 12);
});

test("updateRunHandler rejects non-host and server-owned field edits",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "runs/run-1": run(),
    });

    await assert.rejects(
      () => updateRunHandler(request("runner-1", {
        runId: "run-1",
        fields: {description: "Nope."},
      }), h.deps),
      (error) => assertHttpsCode(error, "permission-denied")
    );
    await assert.rejects(
      () => updateRunHandler(request("host-1", {
        runId: "run-1",
        fields: {capacityLimit: 99},
      }), h.deps),
      (error) => assertHttpsCode(error, "invalid-argument")
    );
    await assert.rejects(
      () => updateRunHandler(request("host-1", {
        runId: "run-1",
        fields: {
          startTimeMillis: Date.parse("2026-05-02T03:00:00.000Z"),
        },
      }), h.deps),
      (error) => assertHttpsCode(error, "invalid-argument")
    );
  }
);
