/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {signUpUserForRun} from "./signUpUserForRun";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  collection(collectionPath: string) {
    return {
      doc: (docId: string) => new FakeDocRef(
        this.firestore,
        `${this.path}/${collectionPath}/${docId}`
      ),
    };
  }
}

class FakeQuery {
  private readonly filters: Array<[string, string, unknown]> = [];

  constructor(
    private readonly firestore: FakeFirestore,
    private readonly collectionPath: string
  ) {}

  where(field: string, op: string, value: unknown): FakeQuery {
    this.filters.push([field, op, value]);
    return this;
  }

  async get() {
    return {
      docs: this.firestore
        .collectionDocs(this.collectionPath)
        .filter((doc) => this.matches(doc.data))
        .map((doc) => ({
          ref: new FakeDocRef(this.firestore, doc.path),
          data: () => ({...doc.data}),
        })),
    };
  }

  private matches(data: FakeData): boolean {
    return this.filters.every(([field, op, value]) => {
      if (op === "==") return data[field] === value;
      if (op === "in" && Array.isArray(value)) {
        return value.includes(data[field]);
      }
      throw new Error(`Unsupported query op ${op}`);
    });
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
      doc: (docId: string) => new FakeDocRef(
        this,
        `${collectionPath}/${docId}`
      ),
      where: (field: string, op: string, value: unknown) =>
        new FakeQuery(this, collectionPath).where(field, op, value),
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

  collectionDocs(
    collectionPath: string
  ): Array<{path: string; data: FakeData}> {
    return Object.entries(this.docs)
      .filter(([path, data]) =>
        data !== undefined &&
        path.startsWith(`${collectionPath}/`) &&
        !path.slice(collectionPath.length + 1).includes("/"))
      .map(([path, data]) => ({path, data: data as FakeData}));
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef | FakeQuery): Promise<FakeSnapshot | {
    docs: Array<{ref: FakeDocRef; data: () => FakeData}>;
  }> {
    if (ref instanceof FakeQuery) return ref.get();
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

  set(ref: FakeDocRef, data: FakeData, _options?: {merge: boolean}) {
    void _options;
    this.writes.push(() => {
      const current = this.firestore.get(ref.path) ?? {};
      this.firestore.set(ref.path, {...current, ...data});
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function firestore(initialDocs: Record<string, FakeData | undefined>) {
  return new FakeFirestore(initialDocs) as unknown as
    FirebaseFirestore.Firestore;
}

function run(overrides: FakeData = {}): FakeData {
  return {
    runClubId: "club-1",
    startTime: admin.firestore.Timestamp.fromMillis(
      Date.parse("2026-05-02T01:30:00.000Z")
    ),
    endTime: admin.firestore.Timestamp.fromMillis(
      Date.parse("2026-05-02T02:30:00.000Z")
    ),
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
    bookedCount: 0,
    checkedInCount: 0,
    waitlistedCount: 0,
    constraints: {minAge: 0, maxAge: 99, maxMen: null, maxWomen: null},
    genderCounts: {},
    ...overrides,
  };
}

function user(overrides: FakeData = {}): FakeData {
  return {
    dateOfBirth: admin.firestore.Timestamp.fromMillis(
      Date.parse("1996-01-01T00:00:00.000Z")
    ),
    gender: "man",
    ...overrides,
  };
}

test("signUpUserForRun writes a signup activity notification", async () => {
  const db = firestore({
    "runs/run-1": run(),
    "users/runner-1": user(),
  });

  await signUpUserForRun(db, "run-1", "runner-1");

  const fake = db as unknown as FakeFirestore;
  const notification = fake.get(
    "notifications/runner-1/items/runSignup_run-1"
  );
  const participation = fake.get("runParticipations/run-1_runner-1");

  assert.equal(notification?.uid, "runner-1");
  assert.equal(notification?.type, "runSignup");
  assert.equal(notification?.title, "You're booked");
  assert.equal(
    notification?.body,
    "Your 5 km run from Carter Road is confirmed."
  );
  assert.equal(notification?.runId, "run-1");
  assert.equal(notification?.runClubId, "club-1");
  assert.equal(notification?.readAt, null);
  assert.equal(participation?.status, "signedUp");
});

test("signUpUserForRun writes a waitlist promotion notification", async () => {
  const db = firestore({
    "runs/run-1": run({
      waitlistedCount: 1,
    }),
    "users/runner-1": user(),
    "runParticipations/run-1_runner-1": {
      runId: "run-1",
      runClubId: "club-1",
      uid: "runner-1",
      status: "waitlisted",
    },
  });

  await signUpUserForRun(db, "run-1", "runner-1");

  const fake = db as unknown as FakeFirestore;
  const notification = fake.get(
    "notifications/runner-1/items/waitlistPromotion_run-1"
  );

  assert.equal(notification?.uid, "runner-1");
  assert.equal(notification?.type, "waitlistPromotion");
  assert.equal(notification?.title, "You're in");
  assert.equal(
    notification?.body,
    "A spot opened for your 5 km run from Carter Road."
  );
  assert.equal(notification?.runId, "run-1");
  assert.equal(notification?.runClubId, "club-1");
  assert.equal(notification?.readAt, null);
});

test("signUpUserForRun rejects cancelled runs", async () => {
  const db = firestore({
    "runs/run-1": run({status: "cancelled"}),
    "users/runner-1": user(),
  });

  await assert.rejects(
    () => signUpUserForRun(db, "run-1", "runner-1"),
    (error) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "failed-precondition"
  );
});
