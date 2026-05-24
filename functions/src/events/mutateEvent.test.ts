/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  cancelEventHandler,
  createEventHandler,
  deleteEventHandler,
  updateEventHandler,
} from "./mutateEvent";
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

function event(overrides: FakeData = {}): FakeData {
  return {
    clubId: "club-1",
    startTime: ts("2026-05-02T01:30:00.000Z"),
    endTime: ts("2026-05-02T02:30:00.000Z"),
    meetingPoint: "Carter Road",
    startingPointLat: 19.07,
    startingPointLng: 72.82,
    locationDetails: null,
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy seaside event.",
    priceInPaise: 0,
    status: "active",
    cancelledAt: null,
    cancellationReason: null,
    constraints: {minAge: 0, maxAge: 99, maxMen: null, maxWomen: null},
    genderCounts: {},
    cohortCounts: {},
    waitlistedCohortCounts: {},
    ...overrides,
  };
}

function payload(overrides: FakeData = {}): FakeData {
  return {
    eventId: "event-1",
    clubId: "club-1",
    startTimeMillis: Date.parse("2026-05-02T01:30:00.000Z"),
    endTimeMillis: Date.parse("2026-05-02T02:30:00.000Z"),
    meetingPoint: "Carter Road",
    startingPointLat: 19.07,
    startingPointLng: 72.82,
    locationDetails: null,
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy seaside event.",
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

test("createEventHandler creates a server-owned event for the club host",
  async () => {
    const h = harness({"clubs/club-1": club()});

    const result = await createEventHandler(
      request("host-1", payload()),
      h.deps
    );

    assert.deepEqual(result, {eventId: "event-1"});
    assert.deepEqual(h.rateLimitCalls, ["host-1:createEvent"]);
    assert.deepEqual(h.firestore.get("events/event-1"), {
      clubId: "club-1",
      startTime: ts("2026-05-02T01:30:00.000Z"),
      endTime: ts("2026-05-02T02:30:00.000Z"),
      meetingPoint: "Carter Road",
      meetingLocation: {
        name: "Carter Road",
        address: null,
        placeId: null,
        latitude: 19.07,
        longitude: 72.82,
        notes: null,
      },
      startingPointLat: 19.07,
      startingPointLng: 72.82,
      locationDetails: null,
      photoUrl: null,
      eventFormat: {
        version: 1,
        activityKind: "socialRun",
        interactionModel: "pacePods",
      },
      distanceKm: 5,
      pace: "easy",
      capacityLimit: 20,
      description: "Easy seaside event.",
      priceInPaise: 0,
      currency: "INR",
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      status: "active",
      cancelledAt: null,
      cancellationReason: null,
      constraints: {minAge: 21, maxAge: 35, maxMen: 10, maxWomen: null},
      eventPolicy: {
        version: 1,
        admission: {
          format: "fixedCohortCaps",
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
          cohortCapacityLimits: {menInterestedInWomen: 10},
          balancedRatioPolicy: null,
        },
        pricing: {
          basePriceInPaise: 0,
          cohortAdjustmentsInPaise: {},
          demandPricingRules: [],
        },
        cancellation: {policyId: "standard"},
        settlement: {hostPayoutTiming: "afterEventCompletion"},
      },
      genderCounts: {},
      cohortCounts: {},
      waitlistedCohortCounts: {},
    });
  }
);

test("createEventHandler accepts client event-policy snapshots", async () => {
  const h = harness({"clubs/club-1": club()});

  const eventPolicy = {
    version: 1,
    admission: {
      format: "balancedRatio",
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
      balancedRatioPolicy: {
        leftCohortId: "menInterestedInWomen",
        rightCohortId: "womenInterestedInMen",
        maxSkew: 1,
        openingBufferPerCohort: 1,
        outOfRatioCohortPolicy: "admitWithinGeneralCapacity",
      },
    },
    pricing: {
      basePriceInPaise: 40000,
      cohortAdjustmentsInPaise: {},
      demandPricingRules: [],
    },
    cancellation: {policyId: "strict"},
    settlement: {hostPayoutTiming: "afterEventCompletion"},
  };

  const result = await createEventHandler(
    request("host-1", payload({
      capacityLimit: 20,
      priceInPaise: 40000,
      constraints: {minAge: 0, maxAge: 99, maxMen: null, maxWomen: null},
      eventPolicy,
    })),
    h.deps
  );

  assert.deepEqual(result, {eventId: "event-1"});
  assert.deepEqual(h.firestore.get("events/event-1")?.eventPolicy, eventPolicy);
  assert.equal(h.firestore.get("events/event-1")?.priceInPaise, 40000);
  assert.equal(h.firestore.get("events/event-1")?.capacityLimit, 20);
});

test("createEventHandler creates event success plans atomically", async () => {
  const h = harness({"clubs/club-1": club()});

  await createEventHandler(
    request("host-1", payload({
      eventSuccessDefaults: {
        enabled: true,
        playbookId: "social_run_light",
        selectedModuleIds: [
          "social_missions",
          "qr_check_in",
          "micro_pods",
          "host_analytics",
          "decomposed_feedback",
        ],
        structureConfig: {
          unitKind: "wholeGroup",
          unitSize: 20,
          unitCount: 1,
          rotationIntervalMinutes: null,
          revealCountdownSeconds: 10,
        },
        hostGoal: "Help everyone meet two new people.",
        wingmanRequestsEnabled: true,
        contextualOpenersEnabled: true,
        compatibilityAffectsRanking: false,
        questionnaireConfig: {templateId: "balanced"},
        attendeePrompt: "Ask what route they want to try next.",
      },
    })),
    h.deps
  );

  const eventDoc = h.firestore.get("events/event-1");
  const plan = h.firestore.get("eventSuccessPlans/event-1");
  assert.equal(eventDoc?.clubId, "club-1");
  assert.equal(plan?.eventId, "event-1");
  assert.equal(plan?.clubId, "club-1");
  assert.equal(plan?.playbookId, "social_run_light");
  assert.deepEqual(plan?.selectedModuleIds, [
    "decomposed_feedback",
    "host_analytics",
    "micro_pods",
    "qr_check_in",
    "social_missions",
  ]);
  assert.equal(plan?.targetAttendeeCount, 20);
  assert.equal(plan?.hostGoal, "Help everyone meet two new people.");
  assert.equal(plan?.wingmanRequestsEnabled, false);
  assert.equal(plan?.contextualOpenersEnabled, false);
  assert.equal(plan?.compatibilityAffectsRanking, false);
  assert.equal(plan?.attendeePrompt, "Ask what route they want to try next.");
  assert.equal(plan?.status, "setup");
  assert.equal(plan?.createdAt, plan?.updatedAt);
});

test(
  "createEventHandler derives event success booleans from modules",
  async () => {
    const h = harness({"clubs/club-1": club()});

    await createEventHandler(
      request("host-1", payload({
        eventSuccessDefaults: {
          enabled: true,
          selectedModuleIds: [
            "qr_check_in",
            "wingman_requests",
            "contextual_openers",
            "compatibility_questionnaire",
          ],
          wingmanRequestsEnabled: false,
          contextualOpenersEnabled: false,
          compatibilityAffectsRanking: true,
        },
      })),
      h.deps
    );

    const plan = h.firestore.get("eventSuccessPlans/event-1");
    assert.equal(plan?.wingmanRequestsEnabled, true);
    assert.equal(plan?.contextualOpenersEnabled, true);
    assert.equal(plan?.compatibilityAffectsRanking, true);
  }
);

test("createEventHandler defaults pub quiz teams from capacity", async () => {
  const h = harness({"clubs/club-1": club()});

  await createEventHandler(
    request("host-1", payload({
      capacityLimit: 50,
      distanceKm: 0,
      eventFormat: {
        version: 1,
        activityKind: "pubQuiz",
        interactionModel: "teamRotations",
        defaultPlaybookId: "pub_quiz_team_mixer",
      },
      eventSuccessDefaults: {
        enabled: true,
        playbookId: "pub_quiz_team_mixer",
        selectedModuleIds: ["qr_check_in", "micro_pods", "live_reveal"],
        structureConfig: {
          unitKind: "teams",
          unitSize: 5,
          unitCount: 3,
          rotationIntervalMinutes: null,
          revealCountdownSeconds: 10,
        },
        hostGoal: "Balance trivia teams.",
      },
    })),
    h.deps
  );

  const plan = h.firestore.get("eventSuccessPlans/event-1");
  assert.equal(plan?.targetAttendeeCount, 50);
  assert.deepEqual(plan?.structureConfig, {
    unitKind: "teams",
    unitSize: 5,
    unitCount: null,
    rotationIntervalMinutes: null,
    revealCountdownSeconds: 10,
  });
});

test("createEventHandler uses event-success primitives for custom formats",
  async () => {
    const h = harness({"clubs/club-1": club()});

    await createEventHandler(
      request("host-1", payload({
        capacityLimit: 40,
        distanceKm: 0,
        eventFormat: {
          version: 1,
          activityKind: "openActivity",
          interactionModel: "openFormat",
          customActivityLabel: "Trivia night",
          eventSuccessPrimitives: {
            phoneAvailability: "plannedPauses",
            rotationSuitability: "plannedBreaks",
            assignmentAlgorithm: "teamBalancer",
            compatibilityPolicy: "questionnaireClueOnly",
          },
        },
        eventSuccessDefaults: {
          enabled: true,
          hostGoal: "Balance trivia teams.",
        },
      })),
      h.deps
    );

    const eventDoc = h.firestore.get("events/event-1");
    const plan = h.firestore.get("eventSuccessPlans/event-1");
    assert.deepEqual(eventDoc?.eventFormat, {
      version: 1,
      activityKind: "openActivity",
      interactionModel: "openFormat",
      customActivityLabel: "Trivia night",
      eventSuccessPrimitives: {
        phoneAvailability: "plannedPauses",
        rotationSuitability: "plannedBreaks",
        assignmentAlgorithm: "teamBalancer",
        compatibilityPolicy: "questionnaireClueOnly",
      },
    });
    assert.equal(plan?.playbookId, "pub_quiz_team_mixer");
    assert.deepEqual(plan?.selectedModuleIds, [
      "contextual_openers",
      "decomposed_feedback",
      "host_analytics",
      "host_script",
      "live_reveal",
      "micro_pods",
      "qr_check_in",
      "safety_controls",
      "social_missions",
      "wingman_requests",
    ]);
    assert.deepEqual(plan?.structureConfig, {
      unitKind: "teams",
      unitSize: 5,
      unitCount: null,
      rotationIntervalMinutes: null,
      revealCountdownSeconds: 10,
    });
    assert.equal(plan?.compatibilityAffectsRanking, false);
  }
);

test("createEventHandler rejects orphan-prone event success plan conflicts",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "eventSuccessPlans/event-1": {eventId: "event-1"},
    });

    await assert.rejects(
      () => createEventHandler(
        request("host-1", payload({
          eventSuccessDefaults: {
            enabled: true,
            playbookId: "social_run_light",
            selectedModuleIds: ["qr_check_in"],
            hostGoal: "Help attendees meet.",
          },
        })),
        h.deps
      ),
      (error) => assertHttpsCode(error, "already-exists")
    );
    assert.equal(h.firestore.get("events/event-1"), undefined);
  }
);

test("createEventHandler stores invite codes in host-private access docs",
  async () => {
    const h = harness({"clubs/club-1": club()});
    const eventPolicy = {
      version: 1,
      admission: {
        format: "inviteOnly",
        capacityLimit: 12,
        waitlistPolicy: {mode: "rankedOffer", offerWindowMinutes: 20},
        inviteRequired: true,
        membershipRequired: false,
        manualApprovalRequired: false,
        privateAccessPolicy: {
          mode: "inviteCode",
          inviteCodeHint: "CA...HI",
          privateLinkEnabled: true,
        },
        cohortCapacityLimits: {},
        balancedRatioPolicy: null,
      },
      pricing: {
        basePriceInPaise: 0,
        cohortAdjustmentsInPaise: {},
        demandPricingRules: [],
      },
      cancellation: {policyId: "standard"},
      settlement: {hostPayoutTiming: "afterEventCompletion"},
    };

    const result = await createEventHandler(
      request("host-1", payload({
        capacityLimit: 12,
        constraints: {minAge: 0, maxAge: 99, maxMen: null, maxWomen: null},
        eventPolicy,
        privateAccess: {inviteCode: " CATCH-DELHI "},
      })),
      h.deps
    );

    const createdEvent = h.firestore.get("events/event-1");
    const privateAccess = h.firestore.get("eventPrivateAccess/event-1");
    assert.deepEqual(result, {eventId: "event-1"});
    assert.deepEqual(createdEvent?.eventPolicy, eventPolicy);
    assert.equal(JSON.stringify(createdEvent).includes("CATCH-DELHI"), false);
    assert.equal(privateAccess?.eventId, "event-1");
    assert.equal(privateAccess?.clubId, "club-1");
    assert.equal(privateAccess?.inviteCode, "CATCH-DELHI");
    assert.notEqual(privateAccess?.createdAt, undefined);
  }
);

test("createEventHandler accepts an uploaded event photo URL", async () => {
  const h = harness({"clubs/club-1": club()});

  await createEventHandler(
    request("host-1", payload({
      photoUrl: "https://img.example/events/event-1.jpg",
    })),
    h.deps
  );

  assert.equal(
    h.firestore.get("events/event-1")?.photoUrl,
    "https://img.example/events/event-1.jpg"
  );
});

test("createEventHandler notifies active club members about a new event",
  async () => {
    const h = harness({
      "clubs/club-1": club({name: "Indore Striders"}),
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
      "clubMemberships/club-1_runner-2": {
        clubId: "club-1",
        uid: "runner-2",
        status: "active",
        pushNotificationsEnabled: false,
      },
      "clubMemberships/club-1_runner-3": {
        clubId: "club-1",
        uid: "runner-3",
        status: "left",
      },
      "users/runner-1": {fcmToken: "token-1", prefsClubUpdates: true},
      "users/runner-2": {fcmToken: "token-2", prefsClubUpdates: true},
      "users/runner-3": {fcmToken: "token-3", prefsClubUpdates: true},
    });

    await createEventHandler(request("host-1", payload()), h.deps);

    const runner1Notification = h.firestore.get(
      "notifications/runner-1/items/clubUpdate_event-1"
    );
    const runner2Notification = h.firestore.get(
      "notifications/runner-2/items/clubUpdate_event-1"
    );
    const hostNotification = h.firestore.get(
      "notifications/host-1/items/clubUpdate_event-1"
    );
    const leftMemberNotification = h.firestore.get(
      "notifications/runner-3/items/clubUpdate_event-1"
    );

    assert.equal(runner1Notification?.uid, "runner-1");
    assert.equal(runner1Notification?.type, "clubUpdate");
    assert.equal(runner1Notification?.title, "Indore Striders posted an event");
    assert.equal(runner1Notification?.body, "5 km from Carter Road.");
    assert.equal(runner1Notification?.eventId, "event-1");
    assert.equal(runner1Notification?.clubId, "club-1");
    assert.equal(runner1Notification?.readAt, null);
    assert.equal(runner2Notification?.uid, "runner-2");
    assert.equal(hostNotification, undefined);
    assert.equal(leftMemberNotification, undefined);
    assert.deepEqual(h.notifications, [{
      token: "token-1",
      title: "Indore Striders posted an event",
      body: "5 km from Carter Road.",
      type: "clubUpdate",
      eventId: "event-1",
      clubId: "club-1",
    }]);
  }
);

test("createEventHandler rejects unsafe creation states", async () => {
  const h = harness({
    "clubs/club-1": club(),
    "events/existing": event(),
    "deletedUsers/deleted-host": {deletedAt: "now"},
  });

  await assert.rejects(
    () => createEventHandler(request(null, payload()), h.deps),
    (error) => assertHttpsCode(error, "unauthenticated")
  );
  await assert.rejects(
    () => createEventHandler(request("host-1", payload({
      eventId: "existing",
    })), h.deps),
    (error) => assertHttpsCode(error, "already-exists")
  );
  await assert.rejects(
    () => createEventHandler(request("runner-1", payload()), h.deps),
    (error) => assertHttpsCode(error, "permission-denied")
  );
  await assert.rejects(
    () => createEventHandler(request("deleted-host", payload()), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
  await assert.rejects(
    () => createEventHandler(request("host-1", payload({
      startingPointLng: null,
    })), h.deps),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
});

test("createEventHandler rejects club schedule conflicts", async () => {
  const h = harness({
    "clubs/club-1": club(),
    "events/overlapping": event({
      startTime: ts("2026-05-02T01:00:00.000Z"),
      endTime: ts("2026-05-02T02:00:00.000Z"),
    }),
  });

  await assert.rejects(
    () => createEventHandler(request("host-1", payload()), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});

test("createEventHandler allows adjacent club schedules", async () => {
  const h = harness({
    "clubs/club-1": club(),
    "events/adjacent": event({
      startTime: ts("2026-05-02T02:30:00.000Z"),
      endTime: ts("2026-05-02T03:30:00.000Z"),
    }),
  });

  await createEventHandler(request("host-1", payload()), h.deps);

  assert.equal(h.firestore.get("events/event-1")?.clubId, "club-1");
});

test("createEventHandler rejects events over the shared max duration", async (
) => {
  const h = harness({"clubs/club-1": club()});

  await assert.rejects(
    () => createEventHandler(request("host-1", payload({
      startTimeMillis: Date.parse("2026-05-02T01:30:00.000Z"),
      endTimeMillis: Date.parse("2026-05-02T05:31:00.000Z"),
    })), h.deps),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
});

test("updateEventHandler updates only host-editable event fields", async () => {
  const h = harness({
    "clubs/club-1": club(),
    "events/event-1": event({capacityLimit: 12}),
  });

  const result = await updateEventHandler(
    request("host-1", {
      eventId: "event-1",
      fields: {
        startTimeMillis: Date.parse("2026-05-02T02:00:00.000Z"),
        endTimeMillis: Date.parse("2026-05-02T03:00:00.000Z"),
        meetingPoint: "Joggers Park",
        photoUrl: "https://img.example/events/event-1.jpg",
        description: "Updated route.",
      },
    }),
    h.deps
  );

  const updated = h.firestore.get("events/event-1");
  assert.deepEqual(result, {updated: true});
  assert.deepEqual(h.rateLimitCalls, ["host-1:updateEvent"]);
  assert.equal(updated?.meetingPoint, "Joggers Park");
  assert.equal(updated?.photoUrl, "https://img.example/events/event-1.jpg");
  assert.equal(updated?.description, "Updated route.");
  assert.equal(updated?.capacityLimit, 12);
});

test("updateEventHandler notifies participants for location changes",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "events/event-1": event(),
      "eventParticipations/event-1_runner-1": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
      },
      "eventParticipations/event-1_runner-2": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "runner-2",
        status: "waitlisted",
      },
      "eventParticipations/event-1_runner-3": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "runner-3",
        status: "cancelled",
      },
      "users/runner-1": {fcmToken: "token-1", prefsRunStatusUpdates: true},
      "users/runner-2": {fcmToken: "token-2", prefsRunStatusUpdates: false},
      "users/runner-3": {fcmToken: "token-3", prefsRunStatusUpdates: true},
    });

    await updateEventHandler(
      request("host-1", {
        eventId: "event-1",
        fields: {
          meetingPoint: "Joggers Park",
        },
      }),
      h.deps
    );

    const runner1Notification = h.firestore.get(
      "notifications/runner-1/items/eventUpdated_event-1"
    );
    const runner2Notification = h.firestore.get(
      "notifications/runner-2/items/eventUpdated_event-1"
    );
    const runner3Notification = h.firestore.get(
      "notifications/runner-3/items/eventUpdated_event-1"
    );

    assert.equal(runner1Notification?.uid, "runner-1");
    assert.equal(runner1Notification?.type, "eventUpdated");
    assert.equal(runner1Notification?.title, "Event details changed");
    assert.equal(
      runner1Notification?.body,
      "Check the latest time and meeting point for your 5 km event."
    );
    assert.equal(runner1Notification?.eventId, "event-1");
    assert.equal(runner1Notification?.clubId, "club-1");
    assert.equal(runner2Notification?.uid, "runner-2");
    assert.equal(runner3Notification, undefined);
    assert.deepEqual(h.notifications, [{
      token: "token-1",
      title: "Event details changed",
      body: "Check the latest time and meeting point for your 5 km event.",
      type: "eventUpdated",
      eventId: "event-1",
      clubId: "club-1",
    }]);
  }
);

test("updateEventHandler rejects schedule changes once participants exist",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "events/event-1": event(),
      "eventParticipations/event-1_runner-1": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
      },
    });

    await assert.rejects(
      () => updateEventHandler(
        request("host-1", {
          eventId: "event-1",
          fields: {
            startTimeMillis: Date.parse("2026-05-02T02:00:00.000Z"),
            endTimeMillis: Date.parse("2026-05-02T03:00:00.000Z"),
          },
        }),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
    await assert.rejects(
      () => updateEventHandler(
        request("host-1", {
          eventId: "event-1",
          fields: {capacityLimit: 99},
        }),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  }
);

test("updateEventHandler skips participant notifications for copy-only edits",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "events/event-1": event(),
      "eventParticipations/event-1_runner-1": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
      },
      "users/runner-1": {fcmToken: "token-1", prefsRunStatusUpdates: true},
    });

    await updateEventHandler(
      request("host-1", {
        eventId: "event-1",
        fields: {description: "New route notes."},
      }),
      h.deps
    );

    assert.equal(
      h.firestore.get("notifications/runner-1/items/eventUpdated_event-1"),
      undefined
    );
    assert.deepEqual(h.notifications, []);
  }
);

test("cancelEventHandler marks the event cancelled and notifies participants",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "events/event-1": event(),
      "eventParticipations/event-1_runner-1": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "runner-1",
        status: "signedUp",
      },
      "eventParticipations/event-1_runner-2": {
        eventId: "event-1",
        clubId: "club-1",
        uid: "runner-2",
        status: "waitlisted",
      },
      "users/runner-1": {fcmToken: "token-1", prefsRunStatusUpdates: true},
      "users/runner-2": {fcmToken: "token-2", prefsRunStatusUpdates: false},
    });

    const result = await cancelEventHandler(
      request("host-1", {
        eventId: "event-1",
        reason: "Storm warning.",
      }),
      h.deps
    );

    const updated = h.firestore.get("events/event-1");
    const runner1Notification = h.firestore.get(
      "notifications/runner-1/items/eventCancelled_event-1"
    );
    const runner2Notification = h.firestore.get(
      "notifications/runner-2/items/eventCancelled_event-1"
    );

    assert.deepEqual(result, {cancelled: true});
    assert.deepEqual(h.rateLimitCalls, ["host-1:cancelEvent"]);
    assert.equal(updated?.status, "cancelled");
    assert.equal(updated?.cancellationReason, "Storm warning.");
    assert.equal(runner1Notification?.uid, "runner-1");
    assert.equal(runner1Notification?.type, "eventCancelled");
    assert.equal(runner1Notification?.title, "Event cancelled");
    assert.equal(
      runner1Notification?.body,
      "Your 5 km event from Carter Road has been cancelled."
    );
    assert.equal(runner2Notification?.uid, "runner-2");
    assert.deepEqual(h.notifications, [{
      token: "token-1",
      title: "Event cancelled",
      body: "Your 5 km event from Carter Road has been cancelled.",
      type: "eventCancelled",
      eventId: "event-1",
      clubId: "club-1",
    }]);

    await cancelEventHandler(
      request("host-1", {eventId: "event-1"}),
      h.deps
    );
    assert.equal(h.notifications.length, 1);
  }
);

test("deleteEventHandler hard-deletes only unused events", async () => {
  const h = harness({
    "clubs/club-1": club(),
    "events/event-1": event(),
  });

  const result = await deleteEventHandler(
    request("host-1", {eventId: "event-1"}),
    h.deps
  );

  assert.deepEqual(result, {deleted: true});
  assert.deepEqual(h.rateLimitCalls, ["host-1:deleteEvent"]);
  assert.equal(h.firestore.get("events/event-1"), undefined);
});

test("deleteEventHandler rejects events with user activity", async () => {
  const h = harness({
    "clubs/club-1": club(),
    "events/event-1": event(),
    "eventParticipations/event-1_runner-1": {
      eventId: "event-1",
      uid: "runner-1",
      status: "signedUp",
    },
  });

  await assert.rejects(
    () => deleteEventHandler(request("host-1", {eventId: "event-1"}), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
  assert.notEqual(h.firestore.get("events/event-1"), undefined);
});

test("updateEventHandler rejects non-host and server-owned field edits",
  async () => {
    const h = harness({
      "clubs/club-1": club(),
      "events/event-1": event(),
    });

    await assert.rejects(
      () => updateEventHandler(request("runner-1", {
        eventId: "event-1",
        fields: {description: "Nope."},
      }), h.deps),
      (error) => assertHttpsCode(error, "permission-denied")
    );
    await assert.rejects(
      () => updateEventHandler(request("host-1", {
        eventId: "event-1",
        fields: {bookedCount: 99},
      }), h.deps),
      (error) => assertHttpsCode(error, "invalid-argument")
    );
    await assert.rejects(
      () => updateEventHandler(request("host-1", {
        eventId: "event-1",
        fields: {
          startTimeMillis: Date.parse("2026-05-02T03:00:00.000Z"),
        },
      }), h.deps),
      (error) => assertHttpsCode(error, "invalid-argument")
    );
  }
);

test("updateEventHandler rejects cancelled events", async () => {
  const h = harness({
    "clubs/club-1": club(),
    "events/event-1": event({status: "cancelled"}),
  });

  await assert.rejects(
    () => updateEventHandler(request("host-1", {
      eventId: "event-1",
      fields: {description: "No changes allowed."},
    }), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});
