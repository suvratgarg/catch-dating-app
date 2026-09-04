import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  assertOrganizerEventVenueSource,
  organizerEventVenueDocumentId,
  upsertOrganizerEventVenueHandler,
} from "./organizerEventVenues";

type FakeData = Record<string, unknown>;

class FakeSnapshot {
  constructor(
    private readonly docs: Map<string, FakeData>,
    readonly path: string
  ) {}

  get exists(): boolean {
    return this.docs.has(this.path);
  }

  data(): FakeData | undefined {
    const value = this.docs.get(this.path);
    return value === undefined ? undefined : {...value};
  }
}

class FakeDocRef {
  constructor(
    private readonly docs: Map<string, FakeData>,
    readonly path: string
  ) {}

  get(): Promise<FakeSnapshot> {
    return Promise.resolve(new FakeSnapshot(this.docs, this.path));
  }
}

class FakeCollectionRef {
  constructor(
    private readonly docs: Map<string, FakeData>,
    private readonly path: string
  ) {}

  doc(id: string): FakeDocRef {
    return new FakeDocRef(this.docs, `${this.path}/${id}`);
  }
}

class FakeTransaction {
  constructor(private readonly docs: Map<string, FakeData>) {}

  get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return ref.get();
  }

  set(ref: FakeDocRef, data: FakeData): void {
    this.docs.set(ref.path, {...data});
  }
}

class FakeFirestore {
  readonly docs = new Map<string, FakeData>();

  collection(path: string): FakeCollectionRef {
    return new FakeCollectionRef(this.docs, path);
  }

  runTransaction<T>(
    callback: (transaction: FakeTransaction) => Promise<T>
  ): Promise<T> {
    return callback(new FakeTransaction(this.docs));
  }
}

function request(
  uid: string,
  overrides: Record<string, unknown> = {}
): CallableRequest<unknown> {
  return {
    auth: {uid},
    data: {
      organizerId: "organizer-1",
      label: "  Bandstand steps  ",
      meetingLocation: {
        name: "  Sea-facing gate  ",
        address: "  Bandra West  ",
        placeId: " place-1 ",
        latitude: 19.046,
        longitude: 72.819,
        notes: "  Meet outside  ",
      },
      defaultEventCapacity: 24,
      ...overrides,
    },
  } as CallableRequest<unknown>;
}

function organizer() {
  return {
    ownerUserId: "owner-1",
    hostUserId: "owner-1",
    hostUserIds: ["owner-1", "manager-1"],
    hostProfiles: [],
  };
}

test("venue ids use the organizer-scoped deterministic document key", () => {
  assert.equal(
    organizerEventVenueDocumentId("organizer-1", "venue-1"),
    "organizer-1_venue-1"
  );
});

test("manager can create a normalized reusable venue", async () => {
  const firestore = new FakeFirestore();
  firestore.docs.set("organizers/organizer-1", organizer());
  const now = {toMillis: () => 1_000};

  const result = await upsertOrganizerEventVenueHandler(
    request("manager-1"),
    {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      now: () => now as unknown as FirebaseFirestore.Timestamp,
      randomVenueId: () => "venue-1",
    }
  );

  assert.deepEqual(result.venue, {
    organizerId: "organizer-1",
    venueId: "venue-1",
    label: "Bandstand steps",
    meetingLocation: {
      name: "Sea-facing gate",
      address: "Bandra West",
      placeId: "place-1",
      latitude: 19.046,
      longitude: 72.819,
      notes: "Meet outside",
    },
    defaultEventCapacity: 24,
    status: "active",
  });
  assert.deepEqual(
    firestore.docs.get("organizerEventVenues/organizer-1_venue-1"),
    {...result.venue, createdAt: now, updatedAt: now}
  );
});

test("non-manager cannot create an organizer venue", async () => {
  const firestore = new FakeFirestore();
  firestore.docs.set("organizers/organizer-1", organizer());

  await assert.rejects(
    upsertOrganizerEventVenueHandler(request("runner-1"), {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      now: () => ({}) as FirebaseFirestore.Timestamp,
      randomVenueId: () => "venue-1",
    }),
    (error: {code?: string}) => error.code === "permission-denied"
  );
  assert.equal(firestore.docs.has(
    "organizerEventVenues/organizer-1_venue-1"
  ), false);
});

test("whitespace-only venue names fail before writing", async () => {
  const firestore = new FakeFirestore();

  await assert.rejects(
    upsertOrganizerEventVenueHandler(request("manager-1", {label: "   "}), {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      now: () => ({}) as FirebaseFirestore.Timestamp,
      randomVenueId: () => "venue-1",
    }),
    (error: {code?: string}) => error.code === "invalid-argument"
  );
  assert.equal(firestore.docs.size, 0);
});

test(
  "event provenance requires an active matching same-organizer venue",
  () => {
    const venue = {
      organizerId: "organizer-1",
      venueId: "venue-1",
      label: "Bandstand steps",
      meetingLocation: {
        name: "Sea-facing gate",
        placeId: "place-1",
        latitude: 19.046,
        longitude: 72.819,
      },
      defaultEventCapacity: 24,
      status: "active" as const,
      createdAt: {} as FirebaseFirestore.Timestamp,
      updatedAt: {} as FirebaseFirestore.Timestamp,
    };
    assert.doesNotThrow(() => assertOrganizerEventVenueSource({
      venue,
      organizerId: "organizer-1",
      venueId: "venue-1",
      meetingLocation: {
        ...venue.meetingLocation,
        name: "North entrance",
        notes: "Event-specific instructions",
      },
    }));
    assert.throws(() => assertOrganizerEventVenueSource({
      venue,
      organizerId: "organizer-2",
      venueId: "venue-1",
      meetingLocation: venue.meetingLocation,
    }), (error: {code?: string}) => error.code === "permission-denied");
    assert.throws(() => assertOrganizerEventVenueSource({
      venue: {...venue, status: "archived"},
      organizerId: "organizer-1",
      venueId: "venue-1",
      meetingLocation: venue.meetingLocation,
    }), (error: {code?: string}) => error.code === "failed-precondition");
    assert.throws(() => assertOrganizerEventVenueSource({
      venue,
      organizerId: "organizer-1",
      venueId: "venue-1",
      meetingLocation: {...venue.meetingLocation, latitude: 19.05},
    }), (error: {code?: string}) => error.code === "failed-precondition");
  }
);
