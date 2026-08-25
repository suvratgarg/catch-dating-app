import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {
  eventStaffGrantId,
  requireEventOperatorPermission,
} from "./eventOperatorAuthority";
import {
  EventDocument,
  EventStaffGrantDocument,
  OrganizerDocument,
} from "./generated/firestoreAdminTypes";

class FakeSnapshot {
  constructor(private readonly value: object | undefined) {}
  get exists() {
    return this.value !== undefined;
  }
  data() {
    return this.value;
  }
}

class FakeDocRef {
  constructor(
    readonly path: string,
    private readonly value: object | undefined
  ) {}
  async get() {
    return new FakeSnapshot(this.value);
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, object | undefined>) {}
  collection(path: string) {
    return {
      doc: (id: string) => new FakeDocRef(
        `${path}/${id}`,
        this.docs[`${path}/${id}`]
      ),
    };
  }
}

const now = admin.firestore.Timestamp.fromMillis(1_000);
const event = {
  organizerId: "organizer-1",
} as EventDocument;
const organizer = {
  hostUserId: "owner-1",
  ownerUserId: "owner-1",
  hostUserIds: [],
  hostProfiles: [],
} as unknown as OrganizerDocument;

function activeGrant(
  overrides: Partial<EventStaffGrantDocument> = {}
): EventStaffGrantDocument {
  return {
    organizerId: "organizer-1",
    eventId: "event-1",
    uid: "operator-1",
    displayName: "Operator",
    phoneLastFour: "1234",
    role: "checkInOperator",
    permissions: [
      "viewRoster",
      "setAttendance",
      "reviewRuntimeClaims",
      "publishLiveLocation",
    ],
    status: "active",
    createdBy: "owner-1",
    createdAt: now,
    expiresAt: admin.firestore.Timestamp.fromMillis(2_000),
    revokedBy: null,
    revokedAt: null,
    updatedAt: now,
    revision: 1,
    ...overrides,
  };
}

test("event staff grant ids are event and account scoped", () => {
  assert.equal(
    eventStaffGrantId("event-1", "operator-1"),
    "event-1__operator-1"
  );
});

test("organizer managers do not need a staff grant", async () => {
  const access = await requireEventOperatorPermission({
    db: new FakeFirestore({}) as unknown as FirebaseFirestore.Firestore,
    organizer,
    event,
    eventId: "event-1",
    actorUid: "owner-1",
    permission: "setAttendance",
    now,
  });
  assert.deepEqual(access, {role: "manager", grant: null});
});

test(
  "active event-scoped operators receive only granted permissions",
  async () => {
    const path = "eventStaffGrants/event-1__operator-1";
    const grant = activeGrant();
    const access = await requireEventOperatorPermission({
      db: new FakeFirestore({[path]: grant}) as unknown as
      FirebaseFirestore.Firestore,
      organizer,
      event,
      eventId: "event-1",
      actorUid: "operator-1",
      permission: "reviewRuntimeClaims",
      now,
    });
    assert.equal(access.role, "operator");
    assert.equal(access.grant, grant);
  }
);

test("revoked, expired, or cross-event grants fail closed", async () => {
  for (const grant of [
    activeGrant({status: "revoked"}),
    activeGrant({expiresAt: now}),
    activeGrant({eventId: "event-2"}),
  ]) {
    const path = "eventStaffGrants/event-1__operator-1";
    await assert.rejects(
      requireEventOperatorPermission({
        db: new FakeFirestore({[path]: grant}) as unknown as
          FirebaseFirestore.Firestore,
        organizer,
        event,
        eventId: "event-1",
        actorUid: "operator-1",
        permission: "setAttendance",
        now,
      }),
      (error: unknown) => error instanceof HttpsError &&
        error.code === "permission-denied"
    );
  }
});

test(
  "transaction reads are used when authority guards a transaction",
  async () => {
    const grant = activeGrant();
    let transactionRead = false;
    const transaction = {
      get: async (ref: FakeDocRef) => {
        transactionRead = ref.path === "eventStaffGrants/event-1__operator-1";
        return new FakeSnapshot(grant);
      },
    } as unknown as FirebaseFirestore.Transaction;
    await requireEventOperatorPermission({
      db: new FakeFirestore({}) as unknown as FirebaseFirestore.Firestore,
      organizer,
      event,
      eventId: "event-1",
      actorUid: "operator-1",
      permission: "viewRoster",
      now,
      transaction,
    });
    assert.equal(transactionRead, true);
  }
);
