/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {sendEventRemindersHandler} from "./sendEventReminders";
import type {FcmParams} from "../shared/notifications";

type FakeData = Record<string, unknown>;
type Operator = "==" | ">=" | "<";

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(docId(this.path), this.firestore.get(this.path));
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

  entries() {
    return Object.entries(this.docs);
  }

  query(collectionPath: string, filters: FakeFilter[]): FakeSnapshot[] {
    const prefix = `${collectionPath}/`;
    return Object.entries(this.docs)
      .filter(([path, value]) =>
        path.startsWith(prefix) &&
        value !== undefined &&
        !path.slice(prefix.length).includes("/")
      )
      .map(([path, value]) => new FakeSnapshot(docId(path), value))
      .filter((snap) => {
        const data = snap.data() ?? {};
        return filters.every((filter) =>
          matchesFilter(data[filter.field], filter.operator, filter.value)
        );
      });
  }
}

interface FakeFilter {
  field: string;
  operator: Operator;
  value: unknown;
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string,
    private readonly filters: FakeFilter[] = []
  ) {}

  doc(docId: string) {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }

  where(field: string, operator: Operator, value: unknown) {
    return new FakeCollectionRef(this.firestore, this.path, [
      ...this.filters,
      {field, operator, value},
    ]);
  }

  async get() {
    return {empty: this.firestore.query(this.path, this.filters).length === 0,
      docs: this.firestore.query(this.path, this.filters)};
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return new FakeSnapshot(docId(ref.path), this.firestore.get(ref.path));
  }

  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => {
      if (this.firestore.get(ref.path) !== undefined) {
        throw new Error(`Doc already exists: ${ref.path}`);
      }
      this.firestore.set(ref.path, data);
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function matchesFilter(
  actual: unknown,
  operator: Operator,
  expected: unknown
): boolean {
  if (operator === "==") return actual === expected;
  const actualMillis = timestampMillis(actual);
  const expectedMillis = timestampMillis(expected);
  if (actualMillis === null || expectedMillis === null) return false;
  if (operator === ">=") return actualMillis >= expectedMillis;
  return actualMillis < expectedMillis;
}

function timestampMillis(value: unknown): number | null {
  if (value instanceof admin.firestore.Timestamp) return value.toMillis();
  if (
    typeof value === "object" &&
    value !== null &&
    "toMillis" in value &&
    typeof value.toMillis === "function"
  ) {
    return value.toMillis();
  }
  return null;
}

function docId(path: string): string {
  return path.split("/").at(-1) ?? "";
}

function harness(initialDocs: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initialDocs);
  const notifications: FcmParams[] = [];
  return {
    firestore,
    notifications,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      now: () => new Date("2026-05-02T01:00:00.000Z"),
      timestampFromDate: (date: Date) =>
        admin.firestore.Timestamp.fromDate(date),
      serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
      sendNotification: async (notification: FcmParams) => {
        notifications.push(notification);
      },
    },
  };
}

function ts(iso: string) {
  return admin.firestore.Timestamp.fromDate(new Date(iso));
}

test("sendEventRemindersHandler creates durable reminders and push once",
  async () => {
    const h = harness({
      "events/event-1": {
        clubId: "club-1",
        startTime: ts("2026-05-02T01:20:00.000Z"),
        distanceKm: 5,
        meetingPoint: "Carter Road",
        status: "active",
      },
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
      "users/runner-1": {
        fcmToken: "token-1",
        prefsEventReminders: true,
      },
      "users/runner-2": {
        fcmToken: "token-2",
        prefsEventReminders: false,
      },
    });

    await sendEventRemindersHandler(h.deps);
    await sendEventRemindersHandler(h.deps);

    const runner1Notification = h.firestore.get(
      "notifications/runner-1/items/eventReminder_event-1"
    );
    const runner2Notification = h.firestore.get(
      "notifications/runner-2/items/eventReminder_event-1"
    );

    assert.equal(runner1Notification?.type, "eventReminder");
    assert.equal(runner2Notification?.type, "eventReminder");
    assert.deepEqual(h.notifications, [{
      token: "token-1",
      title: "Your event starts soon",
      body: "Your 5 km event from Carter Road starts in about 15 minutes.",
      type: "eventReminder",
      eventId: "event-1",
      clubId: "club-1",
    }]);
  }
);
