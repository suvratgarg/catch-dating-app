import assert from "node:assert/strict";
import test from "node:test";
import {
  participationStatus,
  projectEventParticipationToAttendee,
  projectedParticipationStatus,
} from "./eventAttendeeProjection";
import {eventAttendeeId} from "./eventAttendees";
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
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}
  collection(path: string) {
    return {
      doc: (id: string) => new FakeDocRef(this, `${path}/${id}`),
    };
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
