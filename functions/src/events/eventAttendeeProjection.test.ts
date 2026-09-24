import assert from "node:assert/strict";
import test from "node:test";
import {createHash} from "node:crypto";
import {
  participationStatus,
  projectEventParticipationToAttendee,
  projectedParticipationStatus,
} from "./eventAttendeeProjection";
import {eventAttendeeId} from "./eventAttendees";
import {seatIdentityAliasId, seatIdentityValueHash,
  seatVerifiedPhoneProofId} from "./seatIdentityAuthority";
import type {EventParticipationDocument} from
  "../shared/generated/firestoreAdminTypes";

type FakeData = Record<string, unknown>;

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}
  get exists() {
    return this.value !== undefined;
  }
  data() {
    return this.value === undefined ? undefined : {...this.value};
  }
}

class FakeDocRef {
  constructor(
    private readonly firestore: FakeFirestore,
    readonly path: string
  ) {}
  async get() {
    return new FakeSnapshot(this.firestore.get(this.path));
  }
  async set(data: FakeData) {
    this.firestore.set(this.path, data);
  }
  get id() {
    return this.path.split("/").at(-1)!;
  }
}

class FakeQuery {
  constructor(private readonly firestore: FakeFirestore,
    private readonly collection: string,
    private readonly filters: Array<[string, unknown]>,
    private readonly max = Infinity) {}
  where(field: string, _operator: string, value: unknown) {
    return new FakeQuery(this.firestore, this.collection,
      [...this.filters, [field, value]], this.max);
  }
  limit(max: number) {
    return new FakeQuery(this.firestore, this.collection,
      this.filters, max);
  }
  docs() {
    return this.firestore.entries(this.collection).filter(([, data]) =>
      this.filters.every(([field, value]) => data[field] === value))
      .slice(0, this.max).map(([id, data]) => ({
        ref: new FakeDocRef(this.firestore, `${this.collection}/${id}`),
        data: () => data,
      }));
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}
  collection(path: string) {
    return {
      doc: (id: string) => new FakeDocRef(this, `${path}/${id}`),
      where: (field: string, _operator: string, value: unknown) =>
        new FakeQuery(this, path, [[field, value]]),
    };
  }
  entries(collection: string): Array<[string, FakeData]> {
    return Object.entries(this.docs).filter(([path, data]) =>
      path.startsWith(`${collection}/`) &&
      !path.slice(collection.length + 1).includes("/") && data !== undefined)
      .map(([path, data]) => [path.slice(collection.length + 1),
        data as FakeData]);
  }
  async runTransaction<T>(callback: (tx: {
    get: (ref: FakeDocRef | FakeQuery) => Promise<FakeSnapshot | {
      docs: Array<{ref: FakeDocRef; data: () => FakeData}>;
      size: number}>;
    set: (ref: FakeDocRef, data: FakeData) => void;
  }) => Promise<T>): Promise<T> {
    const writes: Array<() => void> = [];
    const result = await callback({
      get: async (ref) => ref instanceof FakeQuery ?
        {docs: ref.docs(), size: ref.docs().length} : ref.get(),
      set: (ref, data) => writes.push(() => this.set(ref.path, data)),
    });
    writes.forEach((write) => write());
    return result;
  }
  get(path: string) {
    const value = this.docs[path];
    return value === undefined ? undefined : {...value};
  }
  set(path: string, data: FakeData) {
    this.docs[path] = {...data};
  }
}

function participation(
  overrides: Partial<EventParticipationDocument> = {}
): EventParticipationDocument {
  const timestamp = {toMillis: () => 1_000} as
    FirebaseFirestore.Timestamp;
  return {
    eventId: "event-1",
    clubId: "organizer-1",
    organizerId: "organizer-1",
    uid: "user-1",
    status: "signedUp",
    createdAt: timestamp,
    updatedAt: timestamp,
    signedUpAt: timestamp,
    waitlistedAt: null,
    attendedAt: null,
    cancelledAt: null,
    deletedAt: null,
    inviteLinkId: null,
    inviteCapturedAt: null,
    ...overrides,
  } as EventParticipationDocument;
}

function projectionHarness(params: {
  docs?: Record<string, FakeData | undefined>;
  authPhone?: string;
}) {
  const firestore = new FakeFirestore(params.docs ?? {});
  const timestamp = {toMillis: () => 2_000} as
    FirebaseFirestore.Timestamp;
  return {
    firestore,
    deps: {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      auth: () => ({
        getUser: async () => ({phoneNumber: params.authPhone}),
      }) as unknown as import("firebase-admin").auth.Auth,
      timestamp: () => timestamp,
    },
  };
}

test("participationStatus preserves the operational roster lifecycle", () => {
  assert.equal(participationStatus("signedUp"), "registered");
  assert.equal(participationStatus("waitlisted"), "waitlisted");
  assert.equal(participationStatus("attended"), "checkedIn");
  assert.equal(participationStatus("cancelled"), "cancelled");
  assert.equal(participationStatus("deleted"), "cancelled");
  assert.equal(participationStatus(undefined), "cancelled");
});

test("Consumer projection does not undo a Host check-in", () => {
  assert.equal(
    projectedParticipationStatus("registered", "checkedIn"),
    "checkedIn"
  );
  assert.equal(
    projectedParticipationStatus("cancelled", "checkedIn"),
    "cancelled"
  );
});

test(
  "Consumer booking never projects private profile contact fields",
  async () => {
    const h = projectionHarness({
      authPhone: "+919876543210",
      docs: {
        "users/user-1": {
          phoneNumber: "+918888888888",
          email: "private@example.test",
        },
        "publicProfiles/user-1": {name: "Asha"},
      },
    });

    await projectEventParticipationToAttendee(
      undefined,
      participation(),
      h.deps
    );

    const attendeeId = eventAttendeeId(
      "event-1",
      "phone:+919876543210"
    );
    const attendee = h.firestore.get(`eventAttendees/${attendeeId}`);
    assert.equal(attendee?.displayName, "Asha");
    assert.equal(attendee?.linkedUid, "user-1");
    assert.equal(attendee?.phoneE164, null);
    assert.equal(attendee?.email, null);
  }
);

test(
  "Consumer booking preserves contact fields already held by organizer",
  async () => {
    const attendeeId = eventAttendeeId(
      "event-1",
      "phone:+919876543210"
    );
    const timestamp = {toMillis: () => 500} as FirebaseFirestore.Timestamp;
    const h = projectionHarness({
      authPhone: "+919876543210",
      docs: {
        "publicProfiles/user-1": {name: "Asha"},
        [`eventAttendees/${attendeeId}`]: {
          eventId: "event-1",
          clubId: "organizer-1",
          organizerId: "organizer-1",
          displayName: "Imported Asha",
          searchName: "imported asha",
          source: "hostImport",
          status: "registered",
          linkedUid: null,
          phoneE164: "+919876543210",
          email: "organizer-record@example.test",
          createdAt: timestamp,
          registeredAt: timestamp,
        },
      },
    });

    await projectEventParticipationToAttendee(
      undefined,
      participation(),
      h.deps
    );

    const attendee = h.firestore.get(`eventAttendees/${attendeeId}`);
    assert.equal(attendee?.source, "hostImport");
    assert.equal(attendee?.phoneE164, "+919876543210");
    assert.equal(attendee?.email, "organizer-record@example.test");
    assert.equal(attendee?.linkedUid, "user-1");
  }
);

test("ready projection follows current reserved source without changing seats",
  async () => {
    const phone = "+919876543210";
    const eventId = "event-1";
    const uid = "user-1";
    const key = "uid_1";
    const current = participation();
    const reservationId = createHash("sha256")
      .update(`${eventId}\u001f${key}`).digest("hex");
    const docs: Record<string, FakeData | undefined> = {
      [`eventParticipations/${eventId}_${uid}`]: current as unknown as
        FakeData,
      [`eventSeatMigrationFences/${eventId}`]: {eventId,
        migrationRevision: 1, state: "ready"},
      [`eventSeatLedgers/${eventId}`]: {eventId, migrationRevision: 1,
        state: "ready", occupied: 1},
      [`eventSeatReservations/${reservationId}`]: {eventId,
        canonicalKey: key, identityRevision: 1, active: true},
      [`eventSeatVerifiedPhones/${seatVerifiedPhoneProofId(eventId, uid)}`]: {
        eventId, organizerId: "organizer-1", uid, phoneE164: phone,
        migrationRevision: 1, state: "current"},
      [`publicProfiles/${uid}`]: {name: "Asha"},
    };
    for (const [kind, value] of [["uid", uid],
      ["phone", phone]] as const) {
      docs[`eventSeatIdentityAliases/${seatIdentityAliasId(eventId,
        kind, value)}`] = {eventId, organizerId: "organizer-1",
        kind, valueHash: seatIdentityValueHash(kind, value),
        canonicalKey: key, identityRevision: 1, migrationRevision: 1,
        state: "ready"};
    }
    const h = projectionHarness({docs, authPhone: phone});
    await projectEventParticipationToAttendee(undefined,
      participation({status: "cancelled"}), h.deps);
    const attendeeId = eventAttendeeId(eventId, `phone:${phone}`);
    assert.equal(h.firestore.get(`eventAttendees/${attendeeId}`)?.status,
      "registered");
    assert.equal(h.firestore.get(`eventAttendees/${attendeeId}`)?.source,
      "catchBooking");
    assert.equal(h.firestore.get(`eventAttendees/${attendeeId}`)?.phoneE164,
      null);
    assert.equal(h.firestore.get(`eventSeatLedgers/${eventId}`)?.occupied, 1);
    h.firestore.set(`eventParticipations/${eventId}_${uid}`, {
      ...current, status: "cancelled"});
    h.firestore.set(`eventSeatReservations/${reservationId}`, {eventId,
      canonicalKey: key, identityRevision: 1, active: false});
    h.firestore.set(`eventSeatLedgers/${eventId}`, {eventId,
      migrationRevision: 1, state: "ready", occupied: 0});
    await projectEventParticipationToAttendee(undefined, current, h.deps);
    assert.equal(h.firestore.get(`eventAttendees/${attendeeId}`)?.status,
      "cancelled");
    assert.equal(h.firestore.get(`eventSeatLedgers/${eventId}`)?.occupied, 0);
  });
