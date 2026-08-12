import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  attendeeInviteLinkId,
  eventInviteToken,
  inviteLinkTokenHash,
  resolveEventInviteLandingHandler,
} from "./inviteLinks";

type FakeData = Record<string, unknown>;

class FakeTimestamp {
  constructor(readonly millis: number) {}
  toMillis() {
    return this.millis;
  }
}

class FakeSnapshot {
  constructor(
    readonly ref: FakeDocRef,
    private readonly value: FakeData | undefined
  ) {}
  get exists() {
    return this.value !== undefined;
  }
  data() {
    return this.value;
  }
}

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
  async get() {
    return new FakeSnapshot(this, this.firestore.get(this.path));
  }
}

class FakeCollectionRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
  doc(id: string) {
    return new FakeDocRef(this.firestore, `${this.path}/${id}`);
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];
  constructor(private readonly firestore: FakeFirestore) {}
  async get(ref: FakeDocRef) {
    return ref.get();
  }
  set(ref: FakeDocRef, data: FakeData, options?: {merge?: boolean}) {
    this.writes.push(() => this.firestore.set(ref.path, data, options));
  }
  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => this.firestore.create(ref.path, data));
  }
  commit() {
    for (const write of this.writes) write();
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}
  collection(path: string) {
    return new FakeCollectionRef(this, path);
  }
  get(path: string) {
    return this.docs[path];
  }
  set(path: string, data: FakeData, options?: {merge?: boolean}) {
    this.docs[path] = options?.merge ?
      {...this.docs[path], ...data} : {...data};
  }
  create(path: string, data: FakeData) {
    if (this.docs[path]) throw new Error(`Document exists: ${path}`);
    this.docs[path] = {...data};
  }
  async runTransaction<T>(callback: (tx: FakeTransaction) => Promise<T>) {
    const tx = new FakeTransaction(this);
    const result = await callback(tx);
    tx.commit();
    return result;
  }
  paths(prefix: string) {
    return Object.keys(this.docs).filter((path) => path.startsWith(prefix));
  }
}

function request(inviteToken: string, sessionId = "session-12345678") {
  return {
    data: {inviteToken, sessionId},
    rawRequest: {},
  } as CallableRequest<unknown>;
}

test("attendee referral links are stable and event scoped", () => {
  const first = attendeeInviteLinkId("event-1", "user-1");
  assert.equal(first, attendeeInviteLinkId("event-1", "user-1"));
  assert.notEqual(first, attendeeInviteLinkId("event-2", "user-1"));
  assert.notEqual(first, attendeeInviteLinkId("event-1", "user-2"));
  assert.match(first, /^eal_[a-f0-9]{48}$/u);
});

test("versioned invite bearer tokens are random and hashable", () => {
  const first = eventInviteToken("invite-1");
  const second = eventInviteToken("invite-1");
  assert.notEqual(first, second);
  assert.match(first, /^v2_invite-1_[A-Za-z0-9_-]{43}$/u);
  assert.match(inviteLinkTokenHash(first), /^[a-f0-9]{64}$/u);
  assert.notEqual(inviteLinkTokenHash(first), inviteLinkTokenHash(second));
});

test("invite landing verifies its token and bounds projection", async () => {
  const token = eventInviteToken("invite-1");
  const now = new FakeTimestamp(Date.parse("2026-08-12T12:00:00.000Z"));
  const firestore = new FakeFirestore({
    "eventInviteLinks/invite-1": {
      contractVersion: 2,
      eventId: "event-1",
      clubId: "organizer-1",
      organizerId: "organizer-1",
      destinationKind: "externalBooking",
      tokenHash: inviteLinkTokenHash(token),
      disabledAt: null,
      attributionWindowEndsAt: new FakeTimestamp(
        Date.parse("2026-08-20T12:00:00.000Z")
      ),
    },
    "events/event-1": {
      clubId: "organizer-1",
      organizerId: "organizer-1",
      status: "active",
      startTime: new FakeTimestamp(Date.parse("2026-08-16T13:00:00.000Z")),
      endTime: new FakeTimestamp(Date.parse("2026-08-16T16:00:00.000Z")),
      meetingPoint: "The Courtyard",
      meetingLocation: {name: "The Courtyard"},
      eventFormat: {
        activityKind: "singlesMixer",
        customActivityLabel: "Sunday Social",
      },
      eventOrigin: {
        mode: "externalCompanion",
        provider: "luma",
        externalEventUrl: "https://lu.ma/sunday?utm_campaign=host",
      },
    },
  });
  const deps = {
    firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
    checkRateLimit: async () => undefined,
    timestamp: () => now as unknown as FirebaseFirestore.Timestamp,
    serverTimestamp: () => ({serverTimestamp: true}) as unknown as
      FirebaseFirestore.FieldValue,
    increment: (value: number) => ({increment: value}) as unknown as
      FirebaseFirestore.FieldValue,
  };

  const result = await resolveEventInviteLandingHandler(request(token), deps);

  assert.deepEqual(result, {
    eventId: "event-1",
    title: "Sunday Social",
    startTimeMillis: Date.parse("2026-08-16T13:00:00.000Z"),
    endTimeMillis: Date.parse("2026-08-16T16:00:00.000Z"),
    locationName: "The Courtyard",
    destinationKind: "externalBooking",
    destinationUrl: "https://lu.ma/sunday?utm_campaign=host&utm_source=" +
      "catch&utm_medium=organizer_invite&catch_ref=invite-1",
    sourceLabel: "Luma",
  });
  assert.equal(firestore.paths("eventInviteTouches/").length, 1);

  await assert.rejects(
    resolveEventInviteLandingHandler(request(`${token.slice(0, -1)}A`), deps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "not-found"
  );
});
