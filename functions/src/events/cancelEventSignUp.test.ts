import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {createHash} from "crypto";
import {cancelEventSignUpHandler} from "./cancelEventSignUp";
import {deriveEventSeatPolicy} from "./seatAuthority/firestoreAdapter";
import {seatIdentityAliasId, seatIdentityValueHash,
  seatVerifiedPhoneProofId} from "./seatIdentityAuthority";

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
    if (this.writes.length > 0) {
      throw new Error("Firestore transaction read after first write.");
    }
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

  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => {
      if (this.firestore.get(ref.path) !== undefined) {
        throw new Error(`Already exists: ${ref.path}`);
      }
      this.firestore.set(ref.path, data);
    });
  }

  delete(ref: FakeDocRef) {
    this.writes.push(() => this.firestore.set(ref.path, undefined));
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function seatReservationPath(key: string): string {
  return "eventSeatReservations/" + createHash("sha256")
    .update(`event-1\u001f${key}`).digest("hex");
}

function readySeatDocs(sourceEvent: FakeData,
  uids: readonly string[]): Record<string, FakeData> {
  const policy = deriveEventSeatPolicy(sourceEvent);
  const rows: Record<string, FakeData> = {
    "eventSeatMigrationFences/event-1": {eventId: "event-1",
      migrationRevision: 1, state: "ready"},
    "eventSeatLedgers/event-1": {eventId: "event-1",
      capacity: policy.capacity, occupied: 1, revision: 1,
      capacityRevision: 1, policyVersion: policy.policyVersion,
      policyHash: policy.policyHash, migrationRevision: 1, state: "ready"},
  };
  for (const uid of uids) {
    rows[`eventSeatVerifiedPhones/${seatVerifiedPhoneProofId("event-1", uid)}`] = {
      eventId: "event-1", organizerId: "club-1", uid, phoneE164: null,
      migrationRevision: 1, state: "current",
    };
    rows[`eventSeatIdentityAliases/${seatIdentityAliasId("event-1", "uid", uid)}`] = {
      eventId: "event-1", organizerId: "club-1", kind: "uid",
      valueHash: seatIdentityValueHash("uid", uid),
      canonicalKey: `uid_${uid}`, identityRevision: 1,
      migrationRevision: 1, state: "ready",
    };
  }
  rows[seatReservationPath("uid_runner-1")] = {eventId: "event-1",
    canonicalKey: "uid_runner-1", identityRevision: 1,
    active: true, revision: 1, reservedAtMillis: 1,
    releasedAtMillis: null};
  return rows;
}

test(
  "cancelEventSignUpHandler keeps paid waitlist users pending payment",
  async () => {
    const h = harness({
      "events/event-1": event({
        priceInPaise: 25000,
        bookedCount: 1,
        waitlistedCount: 1,
      }),
      "users/runner-1": user(),
      "users/runner-2": user({gender: "woman", interestedInGenders: ["man"]}),
      "eventParticipations/event-1_runner-1": participation(
        "runner-1",
        "signedUp"
      ),
      "eventParticipations/event-1_runner-2":
        participation("runner-2", "waitlisted"),
      "payments/pay-1": payment(),
    });

    await cancelEventSignUpHandler(request("runner-1"), h.deps);

    assert.equal(
      h.firestore.get("eventParticipations/event-1_runner-1")?.status,
      "cancelled"
    );
    assert.equal(
      h.firestore.get("eventParticipations/event-1_runner-2")?.status,
      "waitlisted"
    );
    assert.equal(h.firestore.get("events/event-1")?.bookedCount, 0);
    assert.equal(h.firestore.get("events/event-1")?.waitlistedCount, 1);
    assert.deepEqual(h.refunds, [{
      paymentId: "pay_123",
      amountInPaise: 25000,
    }]);
    assert.equal(h.firestore.get("payments/pay-1")?.status, "refunded");
    assert.deepEqual(h.notifications, []);
  }
);

test("cancelEventSignUpHandler promotes free waitlist users", async () => {
  const h = harness({
    "events/event-1": event({bookedCount: 1, waitlistedCount: 1}),
    "users/runner-1": user(),
    "users/runner-2": user({
      fcmToken: "token-2",
      gender: "woman",
      interestedInGenders: ["man"],
    }),
    "eventParticipations/event-1_runner-1": participation(
      "runner-1",
      "signedUp"
    ),
    "eventParticipations/event-1_runner-2": participation(
      "runner-2",
      "waitlisted"
    ),
  });

  await cancelEventSignUpHandler(request("runner-1"), h.deps);

  assert.equal(
    h.firestore.get("eventParticipations/event-1_runner-2")?.status,
    "signedUp"
  );
  assert.equal(h.firestore.get("events/event-1")?.bookedCount, 1);
  assert.equal(h.firestore.get("events/event-1")?.waitlistedCount, 0);
  assert.equal(
    h.firestore.get("notifications/runner-2/items/waitlistPromotion_event-1")
      ?.type,
    "waitlistPromotion"
  );
  assert.deepEqual(h.notifications, [{
    token: "token-2",
    title: "You're in",
    body: "A spot opened for your 5 km event from Carter Road.",
    eventId: "event-1",
    clubId: "club-1",
    organizerId: "club-1",
  }]);
});

test("ready seat ledger transfers the final seat on cancellation",
  async () => {
    const sourceEvent = event({capacityLimit: 1, bookedCount: 1,
      waitlistedCount: 1});
    const h = harness({"events/event-1": sourceEvent,
      "users/runner-1": user(),
      "users/runner-2": user({gender: "woman",
        interestedInGenders: ["man"]}),
      "eventParticipations/event-1_runner-1":
        participation("runner-1", "signedUp"),
      "eventParticipations/event-1_runner-2":
        participation("runner-2", "waitlisted"),
      ...readySeatDocs(sourceEvent, ["runner-1", "runner-2"])});
    await cancelEventSignUpHandler(request("runner-1"), h.deps);
    await cancelEventSignUpHandler(request("runner-1"), h.deps);
    assert.equal(h.firestore.get("eventSeatLedgers/event-1")?.occupied, 1);
    assert.equal(h.firestore.get(seatReservationPath("uid_runner-1"))
      ?.active, false);
    assert.equal(h.firestore.get(seatReservationPath("uid_runner-2"))
      ?.active, true);
    assert.equal(h.firestore.get("eventParticipations/event-1_runner-2")
      ?.status, "signedUp");
  });

test("locked migration denies cancellation and promotion atomically",
  async () => {
    const sourceEvent = event({bookedCount: 1, waitlistedCount: 1});
    const rows = readySeatDocs(sourceEvent, ["runner-1", "runner-2"]);
    rows["eventSeatMigrationFences/event-1"].state = "locked";
    const h = harness({"events/event-1": sourceEvent,
      "users/runner-1": user(),
      "users/runner-2": user({gender: "woman",
        interestedInGenders: ["man"]}),
      "eventParticipations/event-1_runner-1":
        participation("runner-1", "signedUp"),
      "eventParticipations/event-1_runner-2":
        participation("runner-2", "waitlisted"), ...rows});
    await assert.rejects(() =>
      cancelEventSignUpHandler(request("runner-1"), h.deps));
    assert.equal(h.firestore.get("eventParticipations/event-1_runner-1")
      ?.status, "signedUp");
    assert.equal(h.firestore.get("eventParticipations/event-1_runner-2")
      ?.status, "waitlisted");
    assert.equal(h.firestore.get("eventSeatLedgers/event-1")?.occupied, 1);
  });

test("unresolved promoted seat rejects cancellation without partial writes",
  async () => {
    const sourceEvent = event({capacityLimit: 1, bookedCount: 1,
      waitlistedCount: 1});
    const h = harness({"events/event-1": sourceEvent,
      "users/runner-1": user(),
      "users/runner-2": user({gender: "woman",
        interestedInGenders: ["man"]}),
      "eventParticipations/event-1_runner-1":
        participation("runner-1", "signedUp"),
      "eventParticipations/event-1_runner-2":
        participation("runner-2", "waitlisted"),
      ...readySeatDocs(sourceEvent, ["runner-1"])});
    await assert.rejects(() =>
      cancelEventSignUpHandler(request("runner-1"), h.deps));
    assert.equal(h.firestore.get("eventParticipations/event-1_runner-1")
      ?.status, "signedUp");
    assert.equal(h.firestore.get("eventParticipations/event-1_runner-2")
      ?.status, "waitlisted");
    assert.equal(h.firestore.get("eventSeatLedgers/event-1")?.occupied, 1);
  });

test("private event cancellation does not auto-promote waitlist", async () => {
  const h = harness({
    "events/event-1": event({
      bookedCount: 1, waitlistedCount: 1,
      publicationState: "private", setupRevision: 1,
    }),
    "users/runner-1": user(),
    "users/runner-2": user({gender: "woman"}),
    "eventParticipations/event-1_runner-1": participation(
      "runner-1", "signedUp"
    ),
    "eventParticipations/event-1_runner-2": participation(
      "runner-2", "waitlisted"
    ),
  });

  await cancelEventSignUpHandler(request("runner-1"), h.deps);

  assert.equal(h.firestore.get("eventParticipations/event-1_runner-1")
    ?.status, "cancelled");
  assert.equal(h.firestore.get("eventParticipations/event-1_runner-2")
    ?.status, "waitlisted");
  assert.equal(h.firestore.get("events/event-1")?.bookedCount, 0);
  assert.equal(h.firestore.get("events/event-1")?.waitlistedCount, 1);
  assert.deepEqual(h.notifications, []);
});

test(
  "cancelEventSignUpHandler still refunds when promotion push fails",
  async () => {
    const h = harness({
      "events/event-1": event({bookedCount: 1, waitlistedCount: 1}),
      "users/runner-1": user(),
      "users/runner-2": user({
        fcmToken: "token-2",
        gender: "woman",
        interestedInGenders: ["man"],
      }),
      "eventParticipations/event-1_runner-1": participation(
        "runner-1",
        "signedUp"
      ),
      "eventParticipations/event-1_runner-2": participation(
        "runner-2",
        "waitlisted"
      ),
      "payments/pay-1": payment(),
    }, {
      sendNotificationError: new Error("FCM unavailable"),
    });

    await cancelEventSignUpHandler(request("runner-1"), h.deps);

    assert.equal(h.notifications.length, 1);
    assert.deepEqual(h.refunds, [{
      paymentId: "pay_123",
      amountInPaise: 25000,
    }]);
    assert.equal(h.firestore.get("payments/pay-1")?.status, "refunded");
  }
);

test(
  "cancelEventSignUpHandler honors the no-refund cancellation window",
  async () => {
    const h = harness({
      "events/event-1": event({
        priceInPaise: 25000,
        bookedCount: 1,
        eventPolicy: eventPolicy({
          cancellation: {policyId: "strict"},
        }),
      }),
      "users/runner-1": user(),
      "eventParticipations/event-1_runner-1": participation(
        "runner-1",
        "signedUp"
      ),
      "payments/pay-1": payment(),
    }, {
      nowMillis: Date.parse("2026-05-02T00:30:00.000Z"),
    });

    await cancelEventSignUpHandler(request("runner-1"), h.deps);

    assert.deepEqual(h.refunds, []);
    assert.equal(h.firestore.get("payments/pay-1")?.status, "completed");
  }
);

function harness(
  initialDocs: Record<string, FakeData | undefined>,
  options: {nowMillis?: number; sendNotificationError?: Error} = {}
) {
  const firestore = new FakeFirestore(initialDocs);
  const refunds: Array<{paymentId: string; amountInPaise: number}> = [];
  const notifications: Array<{
    token: string;
    title: string;
    body: string;
    eventId: string;
    clubId: string;
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
        eventId: string;
        clubId: string;
      }) => {
        notifications.push(push);
        if (options.sendNotificationError) {
          throw options.sendNotificationError;
        }
      },
    },
  };
}

function request(uid: string): CallableRequest<unknown> {
  return {
    auth: {uid, token: {}} as CallableRequest["auth"],
    data: {eventId: "event-1"},
    rawRequest: {} as CallableRequest["rawRequest"],
    acceptsStreaming: false,
  };
}

function event(overrides: FakeData = {}): FakeData {
  return {
    clubId: "club-1",
    startTime: admin.firestore.Timestamp.fromMillis(
      Date.parse("2026-05-02T01:30:00.000Z")
    ),
    endTime: admin.firestore.Timestamp.fromMillis(
      Date.parse("2026-05-02T02:30:00.000Z")
    ),
    meetingPoint: "Carter Road",
    meetingLocation: {
      name: "Carter Road",
      latitude: 19.0608,
      longitude: 72.8365,
    },
    startingPointLat: 19.0608,
    startingPointLng: 72.8365,
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy seaside event.",
    priceInPaise: 0,
    bookedCount: 0,
    checkedInCount: 0,
    waitlistedCount: 0,
    status: "active",
    cancelledAt: null,
    cancellationReason: null,
    discoveryCityName: "mumbai",
    discoveryMarketId: "in-mh-mumbai",
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
    eventId: "event-1",
    clubId: "club-1",
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
    eventId: "event-1",
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
