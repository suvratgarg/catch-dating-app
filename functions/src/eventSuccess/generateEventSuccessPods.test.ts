/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {generateEventSuccessPodsHandler} from "./generateEventSuccessPods";
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
    "events/event-1": {clubId: "club-1", status: "active"},
    "clubs/club-1": {
      hostUserId: "host-1",
      hostName: "Host",
      hostUserIds: [],
      hostProfiles: [],
    },
    "eventSuccessPlans/event-1": {
      eventId: "event-1",
      clubId: "club-1",
      selectedModuleIds: ["micro_pods"],
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

test("generates micro-pod assignments for active participants", async () => {
  const {firestore, deps, rateLimitCalls} = harness({
    "eventParticipations/event-1_runner-1": {
      eventId: "event-1",
      uid: "runner-1",
      status: "attended",
    },
    "eventParticipations/event-1_runner-2": {
      eventId: "event-1",
      uid: "runner-2",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-3": {
      eventId: "event-1",
      uid: "runner-3",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-4": {
      eventId: "event-1",
      uid: "runner-4",
      status: "waitlisted",
    },
    "eventSuccessAssignments/event-1_micro_pods_old-runner": {
      eventId: "event-1",
      moduleId: "micro_pods",
      uid: "old-runner",
    },
  });

  const result = await generateEventSuccessPodsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 3, podCount: 1});
  assert.deepEqual(rateLimitCalls, ["host-1:generateEventSuccessPods"]);
  const runnerOne = firestore.get(
    "eventSuccessAssignments/event-1_micro_pods_runner-1"
  );
  assert.equal(runnerOne?.displayTitle, "Pod A");
  assert.deepEqual(runnerOne?.peerUids, ["runner-2", "runner-3"]);
  assert.equal(runnerOne?.source, "server_v1");
  assert.equal(
    firestore.get("eventSuccessAssignments/event-1_micro_pods_old-runner"),
    undefined
  );
});

test("keeps blocked participant pairs out of the same pod", async () => {
  const {firestore, deps} = harness({
    "eventParticipations/event-1_runner-1": {
      eventId: "event-1",
      uid: "runner-1",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-2": {
      eventId: "event-1",
      uid: "runner-2",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-3": {
      eventId: "event-1",
      uid: "runner-3",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-4": {
      eventId: "event-1",
      uid: "runner-4",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-5": {
      eventId: "event-1",
      uid: "runner-5",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-6": {
      eventId: "event-1",
      uid: "runner-6",
      status: "signedUp",
    },
    "blocks/runner-3__runner-1": {
      blockerUserId: "runner-3",
      blockedUserId: "runner-1",
    },
  });

  const result = await generateEventSuccessPodsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 6, podCount: 2});
  const runnerOne = firestore.get(
    "eventSuccessAssignments/event-1_micro_pods_runner-1"
  );
  const runnerThree = firestore.get(
    "eventSuccessAssignments/event-1_micro_pods_runner-3"
  );
  assert.equal(runnerOne?.displayTitle, "Pod A");
  assert.equal(runnerThree?.displayTitle, "Pod B");
  assert.ok(!(runnerOne?.peerUids as string[]).includes("runner-3"));
  assert.ok(!(runnerThree?.peerUids as string[]).includes("runner-1"));
});

test("uses saved unit size for generated pod count", async () => {
  const {deps} = harness({
    "eventSuccessPlans/event-1": {
      eventId: "event-1",
      clubId: "club-1",
      selectedModuleIds: ["micro_pods"],
      structureConfig: {
        unitKind: "teams",
        unitSize: 3,
        unitCount: null,
      },
    },
    ...Object.fromEntries(
      Array.from({length: 7}, (_, index) => [
        `eventParticipations/event-1_runner-${index + 1}`,
        {
          eventId: "event-1",
          uid: `runner-${index + 1}`,
          status: "signedUp",
        },
      ])
    ),
  });

  const result = await generateEventSuccessPodsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 7, podCount: 3});
});

test("uses saved fixed unit count when present", async () => {
  const {deps} = harness({
    "eventSuccessPlans/event-1": {
      eventId: "event-1",
      clubId: "club-1",
      selectedModuleIds: ["micro_pods"],
      structureConfig: {
        unitKind: "teams",
        unitSize: 5,
        unitCount: 4,
      },
    },
    ...Object.fromEntries(
      Array.from({length: 10}, (_, index) => [
        `eventParticipations/event-1_runner-${index + 1}`,
        {
          eventId: "event-1",
          uid: `runner-${index + 1}`,
          status: "signedUp",
        },
      ])
    ),
  });

  const result = await generateEventSuccessPodsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 10, podCount: 4});
});

test("excludes opted-out attendees from generated pods", async () => {
  const {firestore, deps} = harness({
    "eventParticipations/event-1_runner-1": {
      eventId: "event-1",
      uid: "runner-1",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-2": {
      eventId: "event-1",
      uid: "runner-2",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-3": {
      eventId: "event-1",
      uid: "runner-3",
      status: "signedUp",
    },
    "eventSuccessPreferences/event-1_runner-2": {
      eventId: "event-1",
      uid: "runner-2",
      microPodsOptedOut: true,
    },
    "eventSuccessAssignments/event-1_micro_pods_runner-2": {
      eventId: "event-1",
      moduleId: "micro_pods",
      uid: "runner-2",
    },
  });

  const result = await generateEventSuccessPodsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 2, podCount: 1});
  assert.deepEqual(
    firestore.get("eventSuccessAssignments/event-1_micro_pods_runner-1")
      ?.peerUids,
    ["runner-3"]
  );
  assert.equal(
    firestore.get("eventSuccessAssignments/event-1_micro_pods_runner-2"),
    undefined
  );
});

test("prefers checked-in attendees once a live pod can be formed", async () => {
  const {firestore, deps} = harness({
    "eventParticipations/event-1_runner-1": {
      eventId: "event-1",
      uid: "runner-1",
      status: "attended",
    },
    "eventParticipations/event-1_runner-2": {
      eventId: "event-1",
      uid: "runner-2",
      status: "attended",
    },
    "eventParticipations/event-1_runner-3": {
      eventId: "event-1",
      uid: "runner-3",
      status: "signedUp",
    },
    "eventParticipations/event-1_runner-4": {
      eventId: "event-1",
      uid: "runner-4",
      status: "signedUp",
    },
    "eventSuccessAssignments/event-1_micro_pods_runner-3": {
      eventId: "event-1",
      moduleId: "micro_pods",
      uid: "runner-3",
    },
  });

  const result = await generateEventSuccessPodsHandler(
    callableRequest("host-1"),
    deps
  );

  assert.deepEqual(result, {assignmentCount: 2, podCount: 1});
  assert.deepEqual(
    firestore.get("eventSuccessAssignments/event-1_micro_pods_runner-1")
      ?.peerUids,
    ["runner-2"]
  );
  assert.deepEqual(
    firestore.get("eventSuccessAssignments/event-1_micro_pods_runner-2")
      ?.peerUids,
    ["runner-1"]
  );
  assert.equal(
    firestore.get("eventSuccessAssignments/event-1_micro_pods_runner-3"),
    undefined
  );
  assert.equal(
    firestore.get("eventSuccessAssignments/event-1_micro_pods_runner-4"),
    undefined
  );
});

test("rejects non-host pod generation", async () => {
  const {deps} = harness();

  await assert.rejects(
    () => generateEventSuccessPodsHandler(callableRequest("runner-1"), deps),
    (error) => {
      isHttpsError(error, "permission-denied", "Only the club host");
      return true;
    }
  );
});

test("rejects pod generation when the module is disabled", async () => {
  const {deps} = harness({
    "eventSuccessPlans/event-1": {
      eventId: "event-1",
      clubId: "club-1",
      selectedModuleIds: ["host_script"],
    },
  });

  await assert.rejects(
    () => generateEventSuccessPodsHandler(callableRequest("host-1"), deps),
    (error) => {
      isHttpsError(error, "failed-precondition", "Micro-pods are not enabled");
      return true;
    }
  );
});

function callableRequest(uid: string): CallableRequest<unknown> {
  return {
    auth: {uid},
    data: {eventId: "event-1"},
  } as CallableRequest<unknown>;
}
