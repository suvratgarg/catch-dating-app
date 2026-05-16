/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  cancelRunHandler,
  createRunHandler,
  deleteRunHandler,
  updateRunHandler,
} from "./mutateRun";
import type {FcmParams} from "../shared/notifications";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  get id(): string {
    return this.path.split("/").at(-1) ?? "";
  }

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore, this.path);
  }

  async set(data: FakeData, _options?: {merge: boolean}) {
    void _options;
    this.firestore.merge(this.path, data);
  }

  collection(collectionPath: string) {
    return new FakeCollectionRef(
      this.firestore,
      `${this.path}/${collectionPath}`
    );
  }
}

class FakeSnapshot {
  constructor(
    private readonly firestore: FakeFirestore,
    readonly path: string
  ) {}

  get id(): string {
    return this.path.split("/").at(-1) ?? "";
  }

  get ref(): FakeDocRef {
    return new FakeDocRef(this.firestore, this.path);
  }

  get exists(): boolean {
    return this.firestore.get(this.path) !== undefined;
  }

  data(): FakeData | undefined {
    const value = this.firestore.get(this.path);
    return value === undefined ? undefined : {...value};
  }
}

class FakeFirestore {
  autoId = 0;

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

  set(path: string, data: FakeData) {
    this.docs[path] = data;
  }

  merge(path: string, data: FakeData) {
    this.docs[path] = {...(this.docs[path] ?? {}), ...data};
  }

  query(
    collectionPath: string,
    filters: Array<{field: string; operator: string; value: unknown}>
  ): FakeSnapshot[] {
    const prefix = `${collectionPath}/`;
    return Object.entries(this.docs)
      .filter(([path, value]) =>
        path.startsWith(prefix) &&
        value !== undefined &&
        !path.slice(prefix.length).includes("/")
      )
      .map(([path]) => new FakeSnapshot(this, path))
      .filter((snap) => {
        const data = snap.data() ?? {};
        return filters.every((filter) => {
          if (filter.operator === "==") {
            return data[filter.field] === filter.value;
          }
          if (filter.operator === "in" && Array.isArray(filter.value)) {
            return filter.value.includes(data[filter.field]);
          }
          throw new Error(
            `Unsupported fake query operator: ${filter.operator}`
          );
        });
      });
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string,
    private readonly filters: Array<{
      field: string;
      operator: string;
      value: unknown;
    }> = [],
    private readonly limitCount?: number
  ) {}

  doc(docId?: string) {
    const id = docId ?? `auto-${++this.firestore.autoId}`;
    return new FakeDocRef(this.firestore, `${this.path}/${id}`);
  }

  where(field: string, operator: string, value: unknown) {
    if (operator !== "==" && operator !== "in") {
      throw new Error(`Unsupported fake query operator: ${operator}`);
    }
    return new FakeCollectionRef(this.firestore, this.path, [
      ...this.filters,
      {field, operator, value},
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
    return {
      docs: limitedDocs,
      empty: limitedDocs.length === 0,
    };
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(
    ref: FakeDocRef | FakeCollectionRef
  ): Promise<FakeSnapshot | {docs: FakeSnapshot[]; empty: boolean}> {
    if (ref instanceof FakeCollectionRef) {
      return ref.get();
    }
    return new FakeSnapshot(this.firestore, ref.path);
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

  set(ref: FakeDocRef, data: FakeData, _options?: {merge: boolean}) {
    void _options;
    this.writes.push(() => {
      this.firestore.set(ref.path, data);
    });
  }

  delete(ref: FakeDocRef) {
    this.writes.push(() => {
      this.firestore.set(ref.path, undefined as unknown as FakeData);
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function harness(initialDocs: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initialDocs);
  const rateLimitCalls: string[] = [];
  const notifications: FcmParams[] = [];
  return {
    firestore,
    rateLimitCalls,
    notifications,
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
      sendNotification: async (notification: FcmParams) => {
        notifications.push(notification);
      },
      serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
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
    status: "active",
    cancelledAt: null,
    cancellationReason: null,
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
      photoUrl: null,
      distanceKm: 5,
      pace: "easy",
      capacityLimit: 20,
      description: "Easy seaside run.",
      priceInPaise: 0,
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      status: "active",
      cancelledAt: null,
      cancellationReason: null,
      constraints: {minAge: 21, maxAge: 35, maxMen: 10, maxWomen: null},
      genderCounts: {},
    });
  }
);

test("createRunHandler accepts an uploaded run photo URL", async () => {
  const h = harness({"runClubs/club-1": club()});

  await createRunHandler(
    request("host-1", payload({
      photoUrl: "https://img.example/runs/run-1.jpg",
    })),
    h.deps
  );

  assert.equal(
    h.firestore.get("runs/run-1")?.photoUrl,
    "https://img.example/runs/run-1.jpg"
  );
});

test("createRunHandler notifies active club members about a new run",
  async () => {
    const h = harness({
      "runClubs/club-1": club({name: "Indore Striders"}),
      "runClubMemberships/club-1_host-1": {
        clubId: "club-1",
        uid: "host-1",
        status: "active",
      },
      "runClubMemberships/club-1_runner-1": {
        clubId: "club-1",
        uid: "runner-1",
        status: "active",
        pushNotificationsEnabled: true,
      },
      "runClubMemberships/club-1_runner-2": {
        clubId: "club-1",
        uid: "runner-2",
        status: "active",
        pushNotificationsEnabled: false,
      },
      "runClubMemberships/club-1_runner-3": {
        clubId: "club-1",
        uid: "runner-3",
        status: "left",
      },
      "users/runner-1": {fcmToken: "token-1", prefsClubUpdates: true},
      "users/runner-2": {fcmToken: "token-2", prefsClubUpdates: true},
      "users/runner-3": {fcmToken: "token-3", prefsClubUpdates: true},
    });

    await createRunHandler(request("host-1", payload()), h.deps);

    const runner1Notification = h.firestore.get(
      "notifications/runner-1/items/clubUpdate_run-1"
    );
    const runner2Notification = h.firestore.get(
      "notifications/runner-2/items/clubUpdate_run-1"
    );
    const hostNotification = h.firestore.get(
      "notifications/host-1/items/clubUpdate_run-1"
    );
    const leftMemberNotification = h.firestore.get(
      "notifications/runner-3/items/clubUpdate_run-1"
    );

    assert.equal(runner1Notification?.uid, "runner-1");
    assert.equal(runner1Notification?.type, "clubUpdate");
    assert.equal(runner1Notification?.title, "Indore Striders posted a run");
    assert.equal(runner1Notification?.body, "5 km from Carter Road.");
    assert.equal(runner1Notification?.runId, "run-1");
    assert.equal(runner1Notification?.runClubId, "club-1");
    assert.equal(runner1Notification?.readAt, null);
    assert.equal(runner2Notification?.uid, "runner-2");
    assert.equal(hostNotification, undefined);
    assert.equal(leftMemberNotification, undefined);
    assert.deepEqual(h.notifications, [{
      token: "token-1",
      title: "Indore Striders posted a run",
      body: "5 km from Carter Road.",
      type: "clubUpdate",
      runId: "run-1",
      runClubId: "club-1",
    }]);
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

test("createRunHandler rejects run-club schedule conflicts", async () => {
  const h = harness({
    "runClubs/club-1": club(),
    "runs/overlapping": run({
      startTime: ts("2026-05-02T01:00:00.000Z"),
      endTime: ts("2026-05-02T02:00:00.000Z"),
    }),
  });

  await assert.rejects(
    () => createRunHandler(request("host-1", payload()), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});

test("createRunHandler allows adjacent run-club schedules", async () => {
  const h = harness({
    "runClubs/club-1": club(),
    "runs/adjacent": run({
      startTime: ts("2026-05-02T02:30:00.000Z"),
      endTime: ts("2026-05-02T03:30:00.000Z"),
    }),
  });

  await createRunHandler(request("host-1", payload()), h.deps);

  assert.equal(h.firestore.get("runs/run-1")?.runClubId, "club-1");
});

test("createRunHandler rejects runs over the shared max duration", async () => {
  const h = harness({"runClubs/club-1": club()});

  await assert.rejects(
    () => createRunHandler(request("host-1", payload({
      startTimeMillis: Date.parse("2026-05-02T01:30:00.000Z"),
      endTimeMillis: Date.parse("2026-05-02T05:31:00.000Z"),
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
        photoUrl: "https://img.example/runs/run-1.jpg",
        description: "Updated route.",
      },
    }),
    h.deps
  );

  const updated = h.firestore.get("runs/run-1");
  assert.deepEqual(result, {updated: true});
  assert.deepEqual(h.rateLimitCalls, ["host-1:updateRun"]);
  assert.equal(updated?.meetingPoint, "Joggers Park");
  assert.equal(updated?.photoUrl, "https://img.example/runs/run-1.jpg");
  assert.equal(updated?.description, "Updated route.");
  assert.equal(updated?.capacityLimit, 12);
});

test("updateRunHandler notifies participants for location changes",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "runs/run-1": run(),
      "runParticipations/run-1_runner-1": {
        runId: "run-1",
        runClubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
      },
      "runParticipations/run-1_runner-2": {
        runId: "run-1",
        runClubId: "club-1",
        uid: "runner-2",
        status: "waitlisted",
      },
      "runParticipations/run-1_runner-3": {
        runId: "run-1",
        runClubId: "club-1",
        uid: "runner-3",
        status: "cancelled",
      },
      "users/runner-1": {fcmToken: "token-1", prefsRunStatusUpdates: true},
      "users/runner-2": {fcmToken: "token-2", prefsRunStatusUpdates: false},
      "users/runner-3": {fcmToken: "token-3", prefsRunStatusUpdates: true},
    });

    await updateRunHandler(
      request("host-1", {
        runId: "run-1",
        fields: {
          meetingPoint: "Joggers Park",
        },
      }),
      h.deps
    );

    const runner1Notification = h.firestore.get(
      "notifications/runner-1/items/runUpdated_run-1"
    );
    const runner2Notification = h.firestore.get(
      "notifications/runner-2/items/runUpdated_run-1"
    );
    const runner3Notification = h.firestore.get(
      "notifications/runner-3/items/runUpdated_run-1"
    );

    assert.equal(runner1Notification?.uid, "runner-1");
    assert.equal(runner1Notification?.type, "runUpdated");
    assert.equal(runner1Notification?.title, "Run details changed");
    assert.equal(
      runner1Notification?.body,
      "Check the latest time and meeting point for your 5 km run."
    );
    assert.equal(runner1Notification?.runId, "run-1");
    assert.equal(runner1Notification?.runClubId, "club-1");
    assert.equal(runner2Notification?.uid, "runner-2");
    assert.equal(runner3Notification, undefined);
    assert.deepEqual(h.notifications, [{
      token: "token-1",
      title: "Run details changed",
      body: "Check the latest time and meeting point for your 5 km run.",
      type: "runUpdated",
      runId: "run-1",
      runClubId: "club-1",
    }]);
  }
);

test("updateRunHandler rejects schedule changes once participants exist",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "runs/run-1": run(),
      "runParticipations/run-1_runner-1": {
        runId: "run-1",
        runClubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
      },
    });

    await assert.rejects(
      () => updateRunHandler(
        request("host-1", {
          runId: "run-1",
          fields: {
            startTimeMillis: Date.parse("2026-05-02T02:00:00.000Z"),
            endTimeMillis: Date.parse("2026-05-02T03:00:00.000Z"),
          },
        }),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  }
);

test("updateRunHandler skips participant notifications for copy-only edits",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "runs/run-1": run(),
      "runParticipations/run-1_runner-1": {
        runId: "run-1",
        runClubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
      },
      "users/runner-1": {fcmToken: "token-1", prefsRunStatusUpdates: true},
    });

    await updateRunHandler(
      request("host-1", {
        runId: "run-1",
        fields: {description: "New route notes."},
      }),
      h.deps
    );

    assert.equal(
      h.firestore.get("notifications/runner-1/items/runUpdated_run-1"),
      undefined
    );
    assert.deepEqual(h.notifications, []);
  }
);

test("cancelRunHandler marks the run cancelled and notifies participants",
  async () => {
    const h = harness({
      "runClubs/club-1": club(),
      "runs/run-1": run(),
      "runParticipations/run-1_runner-1": {
        runId: "run-1",
        runClubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
      },
      "runParticipations/run-1_runner-2": {
        runId: "run-1",
        runClubId: "club-1",
        uid: "runner-2",
        status: "waitlisted",
      },
      "users/runner-1": {fcmToken: "token-1", prefsRunStatusUpdates: true},
      "users/runner-2": {fcmToken: "token-2", prefsRunStatusUpdates: false},
    });

    const result = await cancelRunHandler(
      request("host-1", {
        runId: "run-1",
        reason: "Storm warning.",
      }),
      h.deps
    );

    const updated = h.firestore.get("runs/run-1");
    const runner1Notification = h.firestore.get(
      "notifications/runner-1/items/runCancelled_run-1"
    );
    const runner2Notification = h.firestore.get(
      "notifications/runner-2/items/runCancelled_run-1"
    );

    assert.deepEqual(result, {cancelled: true});
    assert.deepEqual(h.rateLimitCalls, ["host-1:cancelRun"]);
    assert.equal(updated?.status, "cancelled");
    assert.equal(updated?.cancellationReason, "Storm warning.");
    assert.equal(runner1Notification?.uid, "runner-1");
    assert.equal(runner1Notification?.type, "runCancelled");
    assert.equal(runner1Notification?.title, "Run cancelled");
    assert.equal(
      runner1Notification?.body,
      "Your 5 km run from Carter Road has been cancelled."
    );
    assert.equal(runner2Notification?.uid, "runner-2");
    assert.deepEqual(h.notifications, [{
      token: "token-1",
      title: "Run cancelled",
      body: "Your 5 km run from Carter Road has been cancelled.",
      type: "runCancelled",
      runId: "run-1",
      runClubId: "club-1",
    }]);

    await cancelRunHandler(
      request("host-1", {runId: "run-1"}),
      h.deps
    );
    assert.equal(h.notifications.length, 1);
  }
);

test("deleteRunHandler hard-deletes only unused runs", async () => {
  const h = harness({
    "runClubs/club-1": club(),
    "runs/run-1": run(),
  });

  const result = await deleteRunHandler(
    request("host-1", {runId: "run-1"}),
    h.deps
  );

  assert.deepEqual(result, {deleted: true});
  assert.deepEqual(h.rateLimitCalls, ["host-1:deleteRun"]);
  assert.equal(h.firestore.get("runs/run-1"), undefined);
});

test("deleteRunHandler rejects runs with user activity", async () => {
  const h = harness({
    "runClubs/club-1": club(),
    "runs/run-1": run(),
    "runParticipations/run-1_runner-1": {
      runId: "run-1",
      uid: "runner-1",
      status: "signedUp",
    },
  });

  await assert.rejects(
    () => deleteRunHandler(request("host-1", {runId: "run-1"}), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
  assert.notEqual(h.firestore.get("runs/run-1"), undefined);
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

test("updateRunHandler rejects cancelled runs", async () => {
  const h = harness({
    "runClubs/club-1": club(),
    "runs/run-1": run({status: "cancelled"}),
  });

  await assert.rejects(
    () => updateRunHandler(request("host-1", {
      runId: "run-1",
      fields: {description: "No changes allowed."},
    }), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});
