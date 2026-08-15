import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {signUpUserForEvent} from "./signUpUserForEvent";
import {catchNativeEventOrigin} from "../shared/testUtils";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  get id(): string {
    return this.path.split("/").at(-1)!;
  }

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
  constructor(
    readonly id: string,
    private readonly value: FakeData | undefined
  ) {}

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
    return new FakeSnapshot(ref.id, this.firestore.get(ref.path));
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

  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => {
      if (this.firestore.get(ref.path) !== undefined) {
        throw new Error(`Doc already exists: ${ref.path}`);
      }
      this.firestore.set(ref.path, data);
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

function event(overrides: FakeData = {}): FakeData {
  return {
    clubId: "club-1",
    eventOrigin: catchNativeEventOrigin(),
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
    locationDetails: null,
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy seaside event.",
    priceInPaise: 0,
    status: "active",
    cancelledAt: null,
    cancellationReason: null,
    discoveryCityName: "mumbai",
    discoveryMarketId: "in-mh-mumbai",
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
    name: "Runner One",
    firstName: "Runner",
    displayName: "Runner",
    dateOfBirth: admin.firestore.Timestamp.fromMillis(
      Date.parse("1996-01-01T00:00:00.000Z")
    ),
    gender: "man",
    phoneNumber: "+919900000001",
    countryCode: "+91",
    profileComplete: false,
    interestedInGenders: ["woman"],
    activityPreferences: runningPreferences({version: 1}),
    ...overrides,
  };
}

function runningPreferences(overrides: FakeData = {}): FakeData {
  return {
    running: {
      paceMinSecsPerKm: 300,
      paceMaxSecsPerKm: 420,
      preferredDistances: [],
      runningReasons: [],
      preferredRunTimes: [],
      ...overrides,
    },
  };
}

function pairInventoryPolicy(): FakeData {
  return {
    version: 1,
    admission: {
      format: "open",
      capacityLimit: 20,
      waitlistPolicy: {mode: "rankedOffer", offerWindowMinutes: 20},
      inviteRequired: false,
      membershipRequired: false,
      manualApprovalRequired: false,
      privateAccessPolicy: {
        mode: "none",
        inviteCodeHint: null,
        privateLinkEnabled: false,
      },
      cohortCapacityLimits: {},
      balancedRatioPolicy: null,
      crossPathsPairInventory: {
        enabled: true,
        reservedPairCapacity: 2,
        holdDurationMinutes: 15,
      },
    },
    pricing: {
      basePriceInPaise: 0,
      cohortAdjustmentsInPaise: {},
      demandPricingRules: [],
    },
    cancellation: {policyId: "standard"},
    settlement: {hostPayoutTiming: "afterEventCompletion"},
  };
}

test("signUpUserForEvent writes a signup activity notification", async () => {
  const db = firestore({
    "events/event-1": event(),
    "users/runner-1": user(),
  });

  await signUpUserForEvent(db, "event-1", "runner-1");

  const fake = db as unknown as FakeFirestore;
  const notification = fake.get(
    "notifications/runner-1/items/eventSignup_event-1"
  );
  const participation = fake.get("eventParticipations/event-1_runner-1");

  assert.equal(notification?.uid, "runner-1");
  assert.equal(notification?.type, "eventSignup");
  assert.equal(notification?.title, "You're booked");
  assert.equal(
    notification?.body,
    "Your 5 km event from Carter Road is confirmed."
  );
  assert.equal(notification?.eventId, "event-1");
  assert.equal(notification?.clubId, "club-1");
  assert.equal(notification?.readAt, null);
  assert.equal(participation?.status, "signedUp");
  assert.equal(
    fake.get(`userEventScheduleLocks/runner-1_${scheduleSlot(
      "2026-05-02T01:30:00.000Z"
    )}`)?.eventId,
    "event-1"
  );
});

test("signUpUserForEvent updates event discovery availability", async () => {
  const db = firestore({
    "events/event-1": event({
      capacityLimit: 1,
      discoveryCityName: "mumbai",
      discoveryMarketId: "in-mh-mumbai",
      discoveryAvailability: "open",
      discoveryHasOpenSpots: true,
    }),
    "users/runner-1": user(),
  });

  await signUpUserForEvent(db, "event-1", "runner-1");

  const fake = db as unknown as FakeFirestore;
  const updatedEvent = fake.get("events/event-1");
  assert.equal(updatedEvent?.discoveryCityName, "mumbai");
  assert.equal(updatedEvent?.discoveryMarketId, "in-mh-mumbai");
  assert.equal(updatedEvent?.discoveryHasOpenSpots, false);
  assert.equal(updatedEvent?.discoveryAvailability, "waitlist");
  assert.deepEqual(updatedEvent?.discoveryOpenCohorts, []);
  assert.deepEqual(updatedEvent?.discoveryWaitlistCohorts, [
    "menInterestedInWomen",
    "womenInterestedInMen",
    "queerOrOpen",
    "nonBinaryOrOther",
  ]);
});

test("signUpUserForEvent converts a pair hold into a booking and plan",
  async () => {
    const start = Date.parse("2027-05-02T01:30:00.000Z");
    const db = firestore({
      "events/event-1": event({
        startTime: admin.firestore.Timestamp.fromMillis(start),
        endTime: admin.firestore.Timestamp.fromMillis(start + 3600000),
        bookedCount: 1,
        cohortCounts: {womenInterestedInMen: 1},
        crossPathsPairHeldCount: 1,
        crossPathsPairConfirmedCount: 0,
        crossPathsPairHeldCohortCounts: {menInterestedInWomen: 1},
        eventPolicy: pairInventoryPolicy(),
      }),
      "users/runner-1": user(),
      "eventParticipations/event-1_attendee-1": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "attendee-1",
        status: "signedUp",
      },
      "crossPathsInvitations/invitation-1": {
        eventId: "event-1",
        senderUid: "runner-1",
        recipientUid: "attendee-1",
        participantIds: ["runner-1", "attendee-1"],
        status: "accepted",
        pairHoldId: "hold-1",
      },
      "crossPathsPairHolds/hold-1": {
        eventId: "event-1",
        invitationId: "invitation-1",
        organizerId: "club-1",
        requesterUid: "runner-1",
        attendeeUid: "attendee-1",
        participantIds: ["runner-1", "attendee-1"],
        status: "active",
        requesterBookingStatus: "held",
        attendeeBookingStatus: "confirmed",
        requesterCohortId: "menInterestedInWomen",
        attendeeCohortId: "womenInterestedInMen",
        requesterPriceInPaise: 0,
        attendeePriceInPaise: 0,
        currency: "INR",
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        expiresAt: admin.firestore.Timestamp.fromMillis(start - 3600000),
        confirmedAt: null,
        releasedAt: null,
        releaseReason: null,
        paymentId: null,
        conversationId: null,
      },
    });

    await signUpUserForEvent(db, "event-1", "runner-1", undefined, {
      crossPathsPairHoldId: "hold-1",
    });

    const fake = db as unknown as FakeFirestore;
    assert.equal(fake.get("crossPathsPairHolds/hold-1")?.status, "confirmed");
    assert.equal(
      fake.get("eventParticipations/event-1_runner-1")?.status,
      "signedUp"
    );
    assert.equal(
      fake.collectionDocs("matches")[0]?.data.conversationType,
      "crossPathsEventPlan"
    );
  });

test("signUpUserForEvent writes a waitlist promotion notification", async (
) => {
  const db = firestore({
    "events/event-1": event({
      waitlistedCount: 1,
    }),
    "users/runner-1": user(),
    "eventParticipations/event-1_runner-1": {
      eventId: "event-1",
      clubId: "club-1",
      uid: "runner-1",
      status: "waitlisted",
    },
  });

  await signUpUserForEvent(db, "event-1", "runner-1");

  const fake = db as unknown as FakeFirestore;
  const notification = fake.get(
    "notifications/runner-1/items/waitlistPromotion_event-1"
  );

  assert.equal(notification?.uid, "runner-1");
  assert.equal(notification?.type, "waitlistPromotion");
  assert.equal(notification?.title, "You're in");
  assert.equal(
    notification?.body,
    "A spot opened for your 5 km event from Carter Road."
  );
  assert.equal(notification?.eventId, "event-1");
  assert.equal(notification?.clubId, "club-1");
  assert.equal(notification?.readAt, null);
});

test("signUpUserForEvent rejects cancelled events", async () => {
  const db = firestore({
    "events/event-1": event({status: "cancelled"}),
    "users/runner-1": user(),
  });

  await assert.rejects(
    () => signUpUserForEvent(db, "event-1", "runner-1"),
    (error) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "failed-precondition"
  );
});

test("signUpUserForEvent rejects booking-incomplete profiles", async () => {
  const db = firestore({
    "events/event-1": event(),
    "users/runner-1": user({interestedInGenders: []}),
  });

  await assert.rejects(
    () => signUpUserForEvent(db, "event-1", "runner-1"),
    (error) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "failed-precondition"
  );
});

test("signUpUserForEvent requires run preferences for run events", async () => {
  const db = firestore({
    "events/event-1": event(),
    "users/runner-1": user({
      activityPreferences: runningPreferences({version: 0}),
    }),
  });

  await assert.rejects(
    () => signUpUserForEvent(db, "event-1", "runner-1"),
    (error) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "failed-precondition"
  );
});

test("signUpUserForEvent does not require run preferences for dinner events",
  async () => {
    const db = firestore({
      "events/event-1": event({
        eventFormat: {
          version: 1,
          activityKind: "dinner",
          interactionModel: "seatedTable",
        },
      }),
      "users/runner-1": user({
        activityPreferences: runningPreferences({version: 0}),
      }),
    });

    await signUpUserForEvent(db, "event-1", "runner-1");

    const fake = db as unknown as FakeFirestore;
    assert.equal(
      fake.get("eventParticipations/event-1_runner-1")?.status,
      "signedUp"
    );
  }
);

test("signUpUserForEvent rejects overlapping user bookings", async () => {
  const db = firestore({
    "events/event-1": event(),
    "events/event-2": event({
      clubId: "club-2",
      startTime: admin.firestore.Timestamp.fromMillis(
        Date.parse("2026-05-02T02:00:00.000Z")
      ),
      endTime: admin.firestore.Timestamp.fromMillis(
        Date.parse("2026-05-02T03:00:00.000Z")
      ),
    }),
    "users/runner-1": user(),
    "eventParticipations/event-2_runner-1": {
      eventId: "event-2",
      clubId: "club-2",
      uid: "runner-1",
      status: "signedUp",
    },
  });

  await assert.rejects(
    () => signUpUserForEvent(db, "event-1", "runner-1"),
    (error) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "failed-precondition"
  );
});

test("signUpUserForEvent allows adjacent user bookings", async () => {
  const db = firestore({
    "events/event-1": event(),
    "events/event-2": event({
      clubId: "club-2",
      startTime: admin.firestore.Timestamp.fromMillis(
        Date.parse("2026-05-02T02:30:00.000Z")
      ),
      endTime: admin.firestore.Timestamp.fromMillis(
        Date.parse("2026-05-02T03:30:00.000Z")
      ),
    }),
    "users/runner-1": user(),
    "eventParticipations/event-2_runner-1": {
      eventId: "event-2",
      clubId: "club-2",
      uid: "runner-1",
      status: "signedUp",
    },
  });

  await signUpUserForEvent(db, "event-1", "runner-1");

  const fake = db as unknown as FakeFirestore;
  assert.equal(
    fake.get("eventParticipations/event-1_runner-1")?.status,
    "signedUp"
  );
});

function scheduleSlot(iso: string): number {
  return Math.floor(Date.parse(iso) / 60000);
}
