/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  generateEventSuccessRotationsHandler,
  overrideEventSuccessRotationsHandler,
} from "./generateEventSuccessRotations";
import {isHttpsError} from "../shared/testUtils";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  get id(): string {
    return this.path.split("/").at(-1) ?? "";
  }

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore, this.path);
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

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string,
    private readonly filters: Array<{
      field: string;
      operator: string;
      value: unknown;
    }> = []
  ) {}

  doc(docId: string) {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }

  where(field: string, operator: string, value: unknown) {
    return new FakeCollectionRef(this.firestore, this.path, [
      ...this.filters,
      {field, operator, value},
    ]);
  }

  async get() {
    return {
      docs: this.firestore.query(this.path, this.filters),
    };
  }
}

class FakeBatch {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  set(ref: FakeDocRef, data: FakeData, options?: {merge: boolean}) {
    this.writes.push(() => {
      if (options?.merge) {
        this.firestore.merge(ref.path, data);
      } else {
        this.firestore.set(ref.path, data);
      }
    });
  }

  delete(ref: FakeDocRef) {
    this.writes.push(() => {
      this.firestore.delete(ref.path);
    });
  }

  async commit() {
    for (const write of this.writes) write();
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return new FakeCollectionRef(this, collectionPath);
  }

  batch() {
    return new FakeBatch(this);
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : {...data};
  }

  set(path: string, data: FakeData) {
    this.docs[path] = {...data};
  }

  merge(path: string, data: FakeData) {
    this.docs[path] = {...(this.docs[path] ?? {}), ...data};
  }

  delete(path: string) {
    delete this.docs[path];
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
          throw new Error(`Unsupported operator ${filter.operator}`);
        });
      });
  }
}

function harness(overrides: Record<string, FakeData | undefined> = {}) {
  const firestore = new FakeFirestore({
    "events/event-1": {
      clubId: "club-1",
      status: "active",
      startTime: fakeTimestamp("2026-05-21T08:00:00.000Z"),
      endTime: fakeTimestamp("2026-05-21T09:00:00.000Z"),
    },
    "clubs/club-1": {
      hostUserId: "host-1",
      hostName: "Host",
      hostUserIds: [],
      hostProfiles: [],
    },
    "eventSuccessPlans/event-1": {
      eventId: "event-1",
      clubId: "club-1",
      selectedModuleIds: ["guided_rotations"],
    },
    ...overrides,
  });
  const rateLimitCalls: string[] = [];
  return {
    firestore,
    rateLimitCalls,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      serverTimestamp: () =>
        ({__serverTimestamp: true} as unknown as
          FirebaseFirestore.FieldValue),
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

test("generates default-cadence mutual-interest schedules", async () => {
  const {firestore, deps, rateLimitCalls} = harness({
    ...participation("man-1"),
    ...participation("man-2"),
    ...participation("woman-1"),
    ...participation("woman-2"),
    "users/man-1": user("man", ["woman"]),
    "users/man-2": user("man", ["woman"]),
    "users/woman-1": user("woman", ["man"]),
    "users/woman-2": user("woman", ["man"]),
  });

  const result = await generateEventSuccessRotationsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 4, roundCount: 2});
  assert.deepEqual(rateLimitCalls, ["host-1:generateEventSuccessRotations"]);
  const manOne = firestore.get(
    "eventSuccessAssignments/event-1_guided_rotations_man-1"
  );
  assert.equal(manOne?.displayTitle, "2 guided rotations");
  assert.deepEqual(manOne?.peerUids, ["woman-1", "woman-2"]);
  const slots = manOne?.rotationSlots as Array<Record<string, unknown>>;
  assert.equal(slots.length, 2);
  assert.equal(slots[0].compatibility, "mutual_interest");
  assert.equal(slots[0].label, "Round 1");
});

test("uses the saved event-structure rotation cadence", async () => {
  const {firestore, deps} = harness({
    "events/event-1": {
      clubId: "club-1",
      status: "active",
      startTime: fakeTimestamp("2026-05-21T08:00:00.000Z"),
      endTime: fakeTimestamp("2026-05-21T08:45:00.000Z"),
    },
    "eventSuccessPlans/event-1": {
      eventId: "event-1",
      clubId: "club-1",
      selectedModuleIds: ["guided_rotations"],
      structureConfig: {
        unitKind: "pairs",
        unitSize: 2,
        rotationIntervalMinutes: 20,
        revealCountdownSeconds: 10,
      },
    },
    ...participation("man-1"),
    ...participation("man-2"),
    ...participation("man-3"),
    ...participation("woman-1"),
    ...participation("woman-2"),
    ...participation("woman-3"),
    "users/man-1": user("man", ["woman"]),
    "users/man-2": user("man", ["woman"]),
    "users/man-3": user("man", ["woman"]),
    "users/woman-1": user("woman", ["man"]),
    "users/woman-2": user("woman", ["man"]),
    "users/woman-3": user("woman", ["man"]),
  });

  const result = await generateEventSuccessRotationsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 6, roundCount: 2});
  const assignment = firestore.get(
    "eventSuccessAssignments/event-1_guided_rotations_man-1"
  );
  assert.match(String(assignment?.displaySubtitle), /20 min each/);
});

test(
  "uses questionnaire answers as an opt-in rotation ranking boost",
  async () => {
    const {firestore, deps} = harness({
      "eventSuccessPlans/event-1": {
        eventId: "event-1",
        clubId: "club-1",
        selectedModuleIds: [
          "guided_rotations",
          "compatibility_questionnaire",
        ],
        compatibilityAffectsRanking: true,
      },
      ...participation("man-1"),
      ...participation("woman-1"),
      ...participation("woman-2"),
      "users/man-1": user("man", ["woman"]),
      "users/woman-1": user("woman", ["man"]),
      "users/woman-2": user("woman", ["man"]),
      ...compatibilityResponse("man-1", [
        "event_energy_new_people",
        "first_conversation_activity",
      ]),
      ...compatibilityResponse("woman-1", [
        "event_energy_quiet_chemistry",
        "first_conversation_joke",
      ]),
      ...compatibilityResponse("woman-2", [
        "event_energy_new_people",
        "first_conversation_activity",
      ]),
    });

    await generateEventSuccessRotationsHandler(callableRequest("host-1"), deps);

    const manOne = firestore.get(
      "eventSuccessAssignments/event-1_guided_rotations_man-1"
    );
    const slots = manOne?.rotationSlots as Array<Record<string, unknown>>;
    assert.equal(slots[0].peerUid, "woman-2");
    assert.equal(slots[0].compatibility, "questionnaire_match");
  }
);

test(
  "ignores questionnaire answers when ranking opt-in is disabled",
  async () => {
    const {firestore, deps} = harness({
      "eventSuccessPlans/event-1": {
        eventId: "event-1",
        clubId: "club-1",
        selectedModuleIds: [
          "guided_rotations",
          "compatibility_questionnaire",
        ],
        compatibilityAffectsRanking: false,
      },
      ...participation("man-1"),
      ...participation("woman-1"),
      ...participation("woman-2"),
      "users/man-1": user("man", ["woman"]),
      "users/woman-1": user("woman", ["man"]),
      "users/woman-2": user("woman", ["man"]),
      ...compatibilityResponse("man-1", [
        "event_energy_new_people",
        "first_conversation_activity",
      ]),
      ...compatibilityResponse("woman-2", [
        "event_energy_new_people",
        "first_conversation_activity",
      ]),
    });

    await generateEventSuccessRotationsHandler(callableRequest("host-1"), deps);

    const manOne = firestore.get(
      "eventSuccessAssignments/event-1_guided_rotations_man-1"
    );
    const slots = manOne?.rotationSlots as Array<Record<string, unknown>>;
    assert.equal(slots[0].peerUid, "woman-1");
    assert.equal(slots[0].compatibility, "mutual_interest");
  }
);

test(
  "ignores questionnaire answers unless the module is selected",
  async () => {
    const {firestore, deps} = harness({
      "eventSuccessPlans/event-1": {
        eventId: "event-1",
        clubId: "club-1",
        selectedModuleIds: ["guided_rotations"],
        compatibilityAffectsRanking: true,
      },
      ...participation("man-1"),
      ...participation("woman-1"),
      ...participation("woman-2"),
      "users/man-1": user("man", ["woman"]),
      "users/woman-1": user("woman", ["man"]),
      "users/woman-2": user("woman", ["man"]),
      ...compatibilityResponse("man-1", [
        "event_energy_new_people",
        "first_conversation_activity",
      ]),
      ...compatibilityResponse("woman-2", [
        "event_energy_new_people",
        "first_conversation_activity",
      ]),
    });

    await generateEventSuccessRotationsHandler(callableRequest("host-1"), deps);

    const manOne = firestore.get(
      "eventSuccessAssignments/event-1_guided_rotations_man-1"
    );
    const slots = manOne?.rotationSlots as Array<Record<string, unknown>>;
    assert.equal(slots[0].peerUid, "woman-1");
    assert.equal(slots[0].compatibility, "mutual_interest");
  }
);

test(
  "uses event duration and removes opted-out stale assignments",
  async () => {
    const {firestore, deps} = harness({
      "events/event-1": {
        clubId: "club-1",
        status: "active",
        startTime: fakeTimestamp("2026-05-21T08:00:00.000Z"),
        endTime: fakeTimestamp("2026-05-21T08:30:00.000Z"),
      },
      ...participation("man-1"),
      ...participation("woman-1"),
      ...participation("woman-2"),
      "users/man-1": user("man", ["woman"]),
      "users/woman-1": user("woman", ["man"]),
      "users/woman-2": user("woman", ["man"]),
      "eventSuccessPreferences/event-1_woman-2": {
        eventId: "event-1",
        uid: "woman-2",
        guidedRotationsOptedOut: true,
      },
      "eventSuccessAssignments/event-1_guided_rotations_woman-2": {
        eventId: "event-1",
        moduleId: "guided_rotations",
        uid: "woman-2",
      },
    });

    const result = await generateEventSuccessRotationsHandler(
      callableRequest("host-1"),
      deps
    );

    assert.deepEqual(result, {assignmentCount: 2, roundCount: 1});
    assert.equal(
      firestore.get("eventSuccessAssignments/event-1_guided_rotations_woman-2"),
      undefined
    );
  }
);

test("keeps blocked participant pairs out of rotations", async () => {
  const {firestore, deps} = harness({
    ...participation("man-1"),
    ...participation("man-2"),
    ...participation("woman-1"),
    ...participation("woman-2"),
    "users/man-1": user("man", ["woman"]),
    "users/man-2": user("man", ["woman"]),
    "users/woman-1": user("woman", ["man"]),
    "users/woman-2": user("woman", ["man"]),
    "blocks/woman-1__man-1": {
      blockerUserId: "woman-1",
      blockedUserId: "man-1",
    },
  });

  await generateEventSuccessRotationsHandler(callableRequest("host-1"), deps);

  const manOne = firestore.get(
    "eventSuccessAssignments/event-1_guided_rotations_man-1"
  );
  assert.ok(!(manOne?.peerUids as string[]).includes("woman-1"));
});

test("rotates breaks before exhausting mutual-interest pairs", async () => {
  const {firestore, deps} = harness({
    "events/event-1": {
      clubId: "club-1",
      status: "active",
      startTime: fakeTimestamp("2026-05-21T08:00:00.000Z"),
      endTime: fakeTimestamp("2026-05-21T08:45:00.000Z"),
    },
    ...participation("man-1"),
    ...participation("man-2"),
    ...participation("woman-1"),
    ...participation("woman-2"),
    ...participation("nb-1"),
    "users/man-1": user("man", ["woman"]),
    "users/man-2": user("man", ["woman"]),
    "users/woman-1": user("woman", ["man"]),
    "users/woman-2": user("woman", ["man"]),
    "users/nb-1": user("nonbinary", ["woman"]),
  });

  const result = await generateEventSuccessRotationsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 5, roundCount: 3});
  const nonbinaryAttendee = firestore.get(
    "eventSuccessAssignments/event-1_guided_rotations_nb-1"
  );
  const slots = nonbinaryAttendee?.rotationSlots as
    Array<Record<string, unknown>>;
  assert.equal(slots.length, 2);
  assert.equal(slots[0].compatibility, "one_way_interest");
  assert.equal(slots[1].compatibility, "one_way_interest");
});

test("rejects rotation generation when the module is disabled", async () => {
  const {deps} = harness({
    "eventSuccessPlans/event-1": {
      eventId: "event-1",
      clubId: "club-1",
      selectedModuleIds: ["micro_pods"],
    },
  });

  await assert.rejects(
    () => generateEventSuccessRotationsHandler(callableRequest("host-1"), deps),
    (error) => {
      isHttpsError(error, "failed-precondition", "Guided rotations");
      return true;
    }
  );
});

test("lets hosts override rotation pairings", async () => {
  const {firestore, deps, rateLimitCalls} = harness({
    ...participation("man-1"),
    ...participation("man-2"),
    ...participation("woman-1"),
    "users/man-1": user("man", ["woman"]),
    "users/man-2": user("man", ["woman"]),
    "users/woman-1": user("woman", ["man"]),
  });

  const result = await overrideEventSuccessRotationsHandler(
    callableRequest("host-1", {
      eventId: "event-1",
      rounds: [
        {
          roundIndex: 0,
          pairings: [{uidA: "man-1", uidB: "man-2"}],
        },
        {
          roundIndex: 1,
          pairings: [{uidA: "man-1", uidB: "woman-1"}],
        },
      ],
    }),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 3, roundCount: 2});
  assert.deepEqual(rateLimitCalls, ["host-1:overrideEventSuccessRotations"]);
  const manOne = firestore.get(
    "eventSuccessAssignments/event-1_guided_rotations_man-1"
  );
  assert.equal(manOne?.source, "host_override_v1");
  assert.deepEqual(manOne?.peerUids, ["man-2", "woman-1"]);
  const slots = manOne?.rotationSlots as Array<Record<string, unknown>>;
  assert.equal(slots[0].compatibility, "host_override");
  assert.equal(slots[1].label, "Round 2");
});

test("rejects override pairings that repeat an attendee", async () => {
  const {deps} = harness({
    ...participation("man-1"),
    ...participation("man-2"),
    ...participation("woman-1"),
    "users/man-1": user("man", ["woman"]),
    "users/man-2": user("man", ["woman"]),
    "users/woman-1": user("woman", ["man"]),
  });

  await assert.rejects(
    () => overrideEventSuccessRotationsHandler(
      callableRequest("host-1", {
        eventId: "event-1",
        rounds: [
          {
            roundIndex: 0,
            pairings: [
              {uidA: "man-1", uidB: "woman-1"},
              {uidA: "man-1", uidB: "man-2"},
            ],
          },
        ],
      }),
      deps
    ),
    (error) => {
      isHttpsError(error, "invalid-argument", "only one partner");
      return true;
    }
  );
});

test("rejects override schedules without any pairs", async () => {
  const {deps} = harness({
    ...participation("man-1"),
    ...participation("woman-1"),
    "users/man-1": user("man", ["woman"]),
    "users/woman-1": user("woman", ["man"]),
  });

  await assert.rejects(
    () => overrideEventSuccessRotationsHandler(
      callableRequest("host-1", {
        eventId: "event-1",
        rounds: [
          {
            roundIndex: 0,
            pairings: [],
          },
        ],
      }),
      deps
    ),
    (error) => {
      isHttpsError(error, "invalid-argument", "at least one rotation pair");
      return true;
    }
  );
});

test("rejects override pairings for blocked attendees", async () => {
  const {deps} = harness({
    ...participation("man-1"),
    ...participation("woman-1"),
    "users/man-1": user("man", ["woman"]),
    "users/woman-1": user("woman", ["man"]),
    "blocks/woman-1__man-1": {
      blockerUserId: "woman-1",
      blockedUserId: "man-1",
    },
  });

  await assert.rejects(
    () => overrideEventSuccessRotationsHandler(
      callableRequest("host-1", {
        eventId: "event-1",
        rounds: [
          {
            roundIndex: 0,
            pairings: [{uidA: "man-1", uidB: "woman-1"}],
          },
        ],
      }),
      deps
    ),
    (error) => {
      isHttpsError(error, "failed-precondition", "Blocked attendees");
      return true;
    }
  );
});

function participation(uid: string): Record<string, FakeData> {
  return {
    [`eventParticipations/event-1_${uid}`]: {
      eventId: "event-1",
      uid,
      status: "signedUp",
    },
  };
}

function compatibilityResponse(
  uid: string,
  answerIds: string[]
): Record<string, FakeData> {
  return {
    [`eventSuccessCompatibilityResponses/event-1_${uid}`]: {
      eventId: "event-1",
      uid,
      answerIds,
    },
  };
}

function user(gender: string, interestedInGenders: string[]): FakeData {
  return {
    gender,
    interestedInGenders,
  };
}

function callableRequest(
  uid: string,
  data: Record<string, unknown> = {eventId: "event-1"}
): CallableRequest<unknown> {
  return {
    auth: {uid},
    data,
  } as CallableRequest<unknown>;
}

function fakeTimestamp(isoString: string) {
  const millis = Date.parse(isoString);
  return {
    toMillis: () => millis,
  };
}
