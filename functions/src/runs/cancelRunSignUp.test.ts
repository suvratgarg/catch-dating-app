/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {cancelRunSignUpHandler} from "./cancelRunSignUp";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  get id(): string {
    return this.path.split("/").at(-1) ?? "";
  }

  collection(collectionPath: string) {
    return new FakeCollectionRef(
      this.firestore,
      `${this.path}/${collectionPath}`
    );
  }

  async update(patch: FakeData) {
    this.firestore.merge(this.path, patch);
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

  merge(path: string, patch: FakeData) {
    this.docs[path] = {...(this.docs[path] ?? {}), ...patch};
  }

  query(
    collectionPath: string,
    filters: Array<{field: string; operator: string; value: unknown}>,
    order?: {field: string; direction: "asc" | "desc"},
    limitCount?: number
  ): FakeSnapshot[] {
    const prefix = `${collectionPath}/`;
    const snapshots = Object.entries(this.docs)
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
          throw new Error(`Unsupported fake query operator ${filter.operator}`);
        });
      });
    if (order) {
      snapshots.sort((a, b) => {
        const left = sortableValue(a.data()?.[order.field]);
        const right = sortableValue(b.data()?.[order.field]);
        return order.direction === "asc" ? left - right : right - left;
      });
    }
    return limitCount === undefined ?
      snapshots :
      snapshots.slice(0, limitCount);
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
    private readonly order?: {field: string; direction: "asc" | "desc"},
    private readonly limitCount?: number
  ) {}

  doc(docId: string) {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }

  where(field: string, operator: string, value: unknown) {
    return new FakeCollectionRef(
      this.firestore,
      this.path,
      [...this.filters, {field, operator, value}],
      this.order,
      this.limitCount
    );
  }

  orderBy(field: string, direction: "asc" | "desc") {
    return new FakeCollectionRef(
      this.firestore,
      this.path,
      this.filters,
      {field, direction},
      this.limitCount
    );
  }

  limit(count: number) {
    return new FakeCollectionRef(
      this.firestore,
      this.path,
      this.filters,
      this.order,
      count
    );
  }

  async get() {
    const docs = this.firestore.query(
      this.path,
      this.filters,
      this.order,
      this.limitCount
    );
    return {docs, empty: docs.length === 0};
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(
    ref: FakeDocRef | FakeCollectionRef
  ): Promise<FakeSnapshot | {docs: FakeSnapshot[]; empty: boolean}> {
    if (ref instanceof FakeCollectionRef) return ref.get();
    return new FakeSnapshot(this.firestore, ref.path);
  }

  update(ref: FakeDocRef, patch: FakeData) {
    this.writes.push(() => this.firestore.merge(ref.path, patch));
  }

  set(ref: FakeDocRef, data: FakeData, _options?: {merge: boolean}) {
    void _options;
    this.writes.push(() => this.firestore.merge(ref.path, data));
  }

  delete(ref: FakeDocRef) {
    this.writes.push(() => this.firestore.set(ref.path, undefined));
  }

  commit() {
    for (const write of this.writes) write();
  }
}

test(
  "cancelRunSignUpHandler keeps paid waitlist users pending payment",
  async () => {
    const h = harness({
      "runs/run-1": run({
        priceInPaise: 25000,
        bookedCount: 1,
        waitlistedCount: 1,
      }),
      "users/runner-1": user(),
      "users/runner-2": user({gender: "woman", interestedInGenders: ["man"]}),
      "runParticipations/run-1_runner-1": participation("runner-1", "signedUp"),
      "runParticipations/run-1_runner-2":
        participation("runner-2", "waitlisted"),
      "payments/pay-1": payment(),
    });

    await cancelRunSignUpHandler(request("runner-1"), h.deps);

    assert.equal(
      h.firestore.get("runParticipations/run-1_runner-1")?.status,
      "cancelled"
    );
    assert.equal(
      h.firestore.get("runParticipations/run-1_runner-2")?.status,
      "waitlisted"
    );
    assert.equal(h.firestore.get("runs/run-1")?.bookedCount, 0);
    assert.equal(h.firestore.get("runs/run-1")?.waitlistedCount, 1);
    assert.deepEqual(h.refunds, [{
      paymentId: "pay_123",
      amountInPaise: 25000,
    }]);
    assert.equal(h.firestore.get("payments/pay-1")?.status, "refunded");
    assert.deepEqual(h.notifications, []);
  }
);

test("cancelRunSignUpHandler promotes free waitlist users", async () => {
  const h = harness({
    "runs/run-1": run({bookedCount: 1, waitlistedCount: 1}),
    "users/runner-1": user(),
    "users/runner-2": user({
      fcmToken: "token-2",
      gender: "woman",
      interestedInGenders: ["man"],
    }),
    "runParticipations/run-1_runner-1": participation("runner-1", "signedUp"),
    "runParticipations/run-1_runner-2": participation("runner-2", "waitlisted"),
  });

  await cancelRunSignUpHandler(request("runner-1"), h.deps);

  assert.equal(
    h.firestore.get("runParticipations/run-1_runner-2")?.status,
    "signedUp"
  );
  assert.equal(h.firestore.get("runs/run-1")?.bookedCount, 1);
  assert.equal(h.firestore.get("runs/run-1")?.waitlistedCount, 0);
  assert.equal(
    h.firestore.get("notifications/runner-2/items/waitlistPromotion_run-1")
      ?.type,
    "waitlistPromotion"
  );
  assert.deepEqual(h.notifications, [{
    token: "token-2",
    title: "You're in",
    body: "A spot opened for your 5 km run from Carter Road.",
    runId: "run-1",
    runClubId: "club-1",
  }]);
});

test(
  "cancelRunSignUpHandler honors the no-refund cancellation window",
  async () => {
    const h = harness({
      "runs/run-1": run({
        priceInPaise: 25000,
        bookedCount: 1,
        eventPolicy: eventPolicy({
          cancellation: {policyId: "strict"},
        }),
      }),
      "users/runner-1": user(),
      "runParticipations/run-1_runner-1": participation("runner-1", "signedUp"),
      "payments/pay-1": payment(),
    }, {
      nowMillis: Date.parse("2026-05-02T00:30:00.000Z"),
    });

    await cancelRunSignUpHandler(request("runner-1"), h.deps);

    assert.deepEqual(h.refunds, []);
    assert.equal(h.firestore.get("payments/pay-1")?.status, "completed");
  }
);

function harness(
  initialDocs: Record<string, FakeData | undefined>,
  options: {nowMillis?: number} = {}
) {
  const firestore = new FakeFirestore(initialDocs);
  const refunds: Array<{paymentId: string; amountInPaise: number}> = [];
  const notifications: Array<{
    token: string;
    title: string;
    body: string;
    runId: string;
    runClubId: string;
  }> = [];
  return {
    firestore,
    refunds,
    notifications,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      checkRateLimit: async () => undefined,
      nowMillis: () =>
        options.nowMillis ?? Date.parse("2026-05-01T00:00:00.000Z"),
      refundPayment: async (paymentId: string, amountInPaise: number) => {
        refunds.push({paymentId, amountInPaise});
      },
      sendNotification: async (push: {
        token: string;
        title: string;
        body: string;
        runId: string;
        runClubId: string;
      }) => {
        notifications.push(push);
      },
    },
  };
}

function request(uid: string): CallableRequest<unknown> {
  return {
    auth: {uid, token: {}} as CallableRequest["auth"],
    data: {runId: "run-1"},
    rawRequest: {} as CallableRequest["rawRequest"],
    acceptsStreaming: false,
  };
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
    constraints: {minAge: 0, maxAge: 99, maxMen: null, maxWomen: null},
    genderCounts: {man: 1},
    cohortCounts: {menInterestedInWomen: 1},
    ...overrides,
  };
}

function user(overrides: FakeData = {}): FakeData {
  return {
    gender: "man",
    interestedInGenders: ["woman"],
    ...overrides,
  };
}

function participation(uid: string, status: string): FakeData {
  return {
    runId: "run-1",
    runClubId: "club-1",
    uid,
    status,
    genderAtSignup: uid === "runner-2" ? "woman" : "man",
    cohortAtSignup: uid === "runner-2" ?
      "womenInterestedInMen" :
      "menInterestedInWomen",
    waitlistedAt: uid === "runner-2" ? 1 : null,
  };
}

function payment(): FakeData {
  return {
    userId: "runner-1",
    orderId: "order_123",
    paymentId: "pay_123",
    runId: "run-1",
    amount: 25000,
    currency: "INR",
    status: "completed",
    signUpFailed: false,
    createdAt: admin.firestore.Timestamp.fromMillis(1),
  };
}

function eventPolicy(overrides: FakeData = {}): FakeData {
  return {
    version: 1,
    admission: {
      format: "open",
      capacityLimit: 20,
      waitlistPolicy: {mode: "rankedOffer", offerWindowMinutes: 20},
      inviteRequired: false,
      membershipRequired: false,
      manualApprovalRequired: false,
      cohortCapacityLimits: {},
      balancedRatioPolicy: null,
    },
    pricing: {
      basePriceInPaise: 25000,
      cohortAdjustmentsInPaise: {},
      demandPricingRules: [],
    },
    cancellation: {policyId: "standard"},
    settlement: {hostPayoutTiming: "afterEventCompletion"},
    ...overrides,
  };
}

function sortableValue(value: unknown): number {
  if (typeof value === "number") return value;
  if (value && typeof value === "object" && "toMillis" in value &&
      typeof value.toMillis === "function") {
    return value.toMillis();
  }
  return 0;
}
