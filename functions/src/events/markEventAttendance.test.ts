/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {markEventAttendanceHandler} from "./markEventAttendance";
import type {FcmParams} from "../shared/notifications";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(this.path));
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

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string
  ) {}

  doc(docId: string): FakeDocRef {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string): FakeCollectionRef {
    return new FakeCollectionRef(this, collectionPath);
  }

  batch(): FakeBatch {
    return new FakeBatch(this);
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : {...data};
  }

  merge(path: string, data: FakeData): void {
    this.docs[path] = {...(this.docs[path] ?? {}), ...data};
  }
}

class FakeBatch {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  update(ref: FakeDocRef, data: FakeData): void {
    this.writes.push(() => this.firestore.merge(ref.path, data));
  }

  set(ref: FakeDocRef, data: FakeData): void {
    this.writes.push(() => this.firestore.merge(ref.path, data));
  }

  async commit(): Promise<void> {
    for (const write of this.writes) write();
  }
}

test(
  "markEventAttendanceHandler sends companion-ready push after host check-in",
  async () => {
    const h = buildHarness();

    const result = await markEventAttendanceHandler(
      callableRequest({eventId: "event-1", userId: "runner-1"}),
      h.deps
    );

    assert.deepEqual(result, {userId: "runner-1", attended: true});
    assert.deepEqual(h.notifications, [{
      token: "token-1",
      title: "Your event companion is ready",
      body: "Open the live guide for your 5 km event from Bandstand.",
      type: "eventCompanionReady",
      eventId: "event-1",
      clubId: "club-1",
    }]);
  }
);

test(
  "markEventAttendanceHandler skips companion-ready push without a saved plan",
  async () => {
    const h = buildHarness({"eventSuccessPlans/event-1": undefined});

    await markEventAttendanceHandler(
      callableRequest({eventId: "event-1", userId: "runner-1"}),
      h.deps
    );

    assert.deepEqual(h.notifications, []);
  }
);

test(
  "markEventAttendanceHandler skips companion-ready push when attendee " +
    "opted out",
  async () => {
    const h = buildHarness({
      "users/runner-1": {
        fcmToken: "token-1",
        prefsRunStatusUpdates: false,
      },
    });

    await markEventAttendanceHandler(
      callableRequest({eventId: "event-1", userId: "runner-1"}),
      h.deps
    );

    assert.deepEqual(h.notifications, []);
  }
);

function buildHarness(overrides: Record<string, FakeData | undefined> = {}) {
  const notifications: FcmParams[] = [];
  const firestore = new FakeFirestore({
    "events/event-1": eventDoc(),
    "clubs/club-1": {hostUserId: "host-1"},
    "eventParticipations/event-1_runner-1": {
      eventId: "event-1",
      clubId: "club-1",
      uid: "runner-1",
      status: "signedUp",
    },
    "eventSuccessPlans/event-1": {
      eventId: "event-1",
      clubId: "club-1",
      selectedModuleIds: ["qr_check_in"],
      contextualOpenersEnabled: false,
    },
    "users/runner-1": {
      fcmToken: "token-1",
      prefsRunStatusUpdates: true,
    },
    ...overrides,
  });

  return {
    firestore,
    notifications,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      now: () => new Date("2026-05-02T10:55:00.000Z"),
      increment: (value: number) =>
        ({__op: "increment", value}) as unknown as FirebaseFirestore.FieldValue,
      checkRateLimit: async () => undefined,
      recordSignalFacts: async () => undefined,
      sendNotification: async (notification: FcmParams) => {
        notifications.push(notification);
      },
    },
  };
}

function eventDoc(): FakeData {
  return {
    clubId: "club-1",
    status: "active",
    startTime: timestamp("2026-05-02T11:00:00.000Z"),
    endTime: timestamp("2026-05-02T12:00:00.000Z"),
    meetingPoint: "Bandstand",
    distanceKm: 5,
  };
}

function timestamp(isoString: string): FirebaseFirestore.Timestamp {
  return admin.firestore.Timestamp.fromDate(new Date(isoString));
}

function callableRequest(data: FakeData): CallableRequest<unknown> {
  return {
    auth: {uid: "host-1"},
    data,
  } as CallableRequest<unknown>;
}
