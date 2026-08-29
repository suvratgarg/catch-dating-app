import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  assertPublicRegistrationEligibility,
  attendanceReceiptId,
  eventAttendeeId,
  mergeOrganizerCommunicationPreference,
  normalizeRosterPhone,
  onboardingDraftSeed,
  prepareImportRows,
  publicRegistrationStatus,
  setEventAttendeeAttendanceHandler,
} from "./eventAttendees";

type FakeData = Record<string, unknown>;

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
    return new FakeSnapshot(ref, this.firestore.get(ref.path));
  }
  update(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => this.firestore.update(ref.path, data));
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
  update(path: string, data: FakeData) {
    const existing = this.docs[path];
    if (!existing) throw new Error(`Document missing: ${path}`);
    this.docs[path] = {...existing, ...data};
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
}

function attendanceRequest(data: Record<string, unknown>) {
  return {
    auth: {uid: "host-1", token: {}},
    data,
    rawRequest: {},
  } as CallableRequest<unknown>;
}

test("normalizeRosterPhone accepts E.164 and Indian local numbers", () => {
  assert.deepEqual(normalizeRosterPhone("+44 7700 900123"), {
    value: "+447700900123",
    issue: null,
  });
  assert.deepEqual(normalizeRosterPhone("98765 43210"), {
    value: "+919876543210",
    issue: null,
  });
  assert.equal(normalizeRosterPhone("123").value, null);
  assert.match(normalizeRosterPhone("123").issue ?? "", /country code/);
});

test("public registration fails closed and keeps idempotent retries", () => {
  const eligible = {
    organizerVisibility: "discoverable",
    organizerPublishStatus: "published",
    eventStatus: "active",
    eventEndTimeMs: Date.now() + 60_000,
    publicRegistrationEnabled: true,
    admissionFormat: "open",
    inviteRequired: false,
    membershipRequired: false,
    manualApprovalRequired: false,
    priceInPaise: 0,
  };
  assert.doesNotThrow(() => assertPublicRegistrationEligibility(eligible));
  assert.throws(
    () => assertPublicRegistrationEligibility({
      ...eligible,
      organizerVisibility: "hidden",
    }),
    /has not published/u
  );
  assert.throws(
    () => assertPublicRegistrationEligibility({
      ...eligible,
      publicRegistrationEnabled: false,
    }),
    /not enabled/u
  );
  assert.throws(
    () => assertPublicRegistrationEligibility({
      ...eligible,
      priceInPaise: 100,
    }),
    /cannot bypass payment/u
  );
  assert.throws(
    () => assertPublicRegistrationEligibility({
      ...eligible,
      admissionFormat: "inviteOnly",
    }),
    /open-admission/u
  );
});

test("public registration fills open capacity then uses the waitlist", () => {
  assert.equal(publicRegistrationStatus({
    activeCount: 19,
    capacityLimit: 20,
    existingStatus: undefined,
  }), "registered");
  assert.equal(publicRegistrationStatus({
    activeCount: 20,
    capacityLimit: 20,
    existingStatus: undefined,
  }), "waitlisted");
  assert.equal(publicRegistrationStatus({
    activeCount: 20,
    capacityLimit: 20,
    existingStatus: "registered",
  }), "registered");
});

test("prepareImportRows deduplicates event-scoped contact identity", () => {
  const result = prepareImportRows({
    eventId: "event-1",
    importKey: "import-key-1",
    rows: [
      {
        rowId: "1",
        displayName: "  Asha   Shah ",
        phone: "+91 98765 43210",
        email: null,
        externalReference: null,
        arrivalGroup: null,
        ticketType: "General",
        status: "registered",
      },
      {
        rowId: "2",
        displayName: "Asha duplicate",
        phone: "9876543210",
        email: null,
        externalReference: null,
        arrivalGroup: null,
        ticketType: null,
        status: "registered",
      },
    ],
  });

  assert.equal(result.prepared.length, 1);
  assert.equal(result.prepared[0].displayName, "Asha Shah");
  assert.equal(result.prepared[0].phoneE164, "+919876543210");
  assert.deepEqual(result.errors.map((error) => error.code), [
    "duplicate-row",
  ]);
});

test(
  "prepareImportRows preserves group tickets with shared buyer contact",
  () => {
    const result = prepareImportRows({
      eventId: "event-1",
      importKey: "eventbrite-import",
      rows: [
        {
          rowId: "2",
          displayName: "Asha Shah",
          phone: null,
          email: "buyer@example.com",
          externalReference: "attendee-7a",
          arrivalGroup: "order-7",
          ticketType: "General",
          status: "registered",
        },
        {
          rowId: "3",
          displayName: "Ravi Rao",
          phone: null,
          email: "buyer@example.com",
          externalReference: "attendee-7b",
          arrivalGroup: "order-7",
          ticketType: "General",
          status: "registered",
        },
      ],
    });

    assert.equal(result.errors.length, 0);
    assert.equal(result.prepared.length, 2);
    assert.notEqual(
      result.prepared[0].attendeeId,
      result.prepared[1].attendeeId
    );
    assert.deepEqual(
      result.prepared.map((row) => row.arrivalGroup),
      ["order-7", "order-7"]
    );
  }
);

test("shared imported order totals are allocated once across guests", () => {
  const result = prepareImportRows({
    eventId: "event-1",
    importKey: "order-revenue-import",
    rows: [
      {
        rowId: "2",
        displayName: "Asha Shah",
        phone: null,
        email: "asha@example.com",
        externalReference: "attendee-a",
        arrivalGroup: "order-7",
        ticketType: "General",
        revenueAmountMinor: 10001,
        revenueCurrency: "INR",
        revenueSource: "hostImport",
        status: "registered",
      },
      {
        rowId: "3",
        displayName: "Ravi Rao",
        phone: null,
        email: "ravi@example.com",
        externalReference: "attendee-b",
        arrivalGroup: "order-7",
        ticketType: "General",
        revenueAmountMinor: 10001,
        revenueCurrency: "INR",
        revenueSource: "hostImport",
        status: "registered",
      },
    ],
  });

  assert.equal(result.errors.length, 0);
  assert.deepEqual(
    result.prepared.map((row) => row.revenueAmountMinor),
    [5001, 5000]
  );
  assert.deepEqual(
    result.prepared.map((row) => row.revenueAllocation),
    ["sharedOrder", "sharedOrder"]
  );
  assert.equal(
    result.prepared.reduce(
      (total, row) => total + (row.revenueAmountMinor ?? 0),
      0
    ),
    10001
  );
});

test("spreadsheet rows without stable identity are rejected", () => {
  const result = prepareImportRows({
    eventId: "event-1",
    importKey: "csv-import",
    format: "csv",
    rows: [{
      rowId: "2",
      displayName: "Name only",
      phone: null,
      email: null,
      externalReference: null,
      arrivalGroup: null,
      ticketType: null,
      status: "registered",
    }],
  });

  assert.equal(result.prepared.length, 0);
  assert.deepEqual(result.errors.map((error) => error.code), [
    "missing-stable-identity",
  ]);
});

test("manual rows may use an import-scoped row identity", () => {
  const result = prepareImportRows({
    eventId: "event-1",
    importKey: "manual-import",
    format: "manual",
    rows: [{
      rowId: "manual",
      displayName: "Walk in",
      phone: null,
      email: null,
      externalReference: null,
      arrivalGroup: null,
      ticketType: null,
      status: "registered",
    }],
  });

  assert.equal(result.errors.length, 0);
  assert.equal(result.prepared.length, 1);
});

test("eventAttendeeId is stable and event-isolated", () => {
  const stable = eventAttendeeId("event-1", "email:asha@example.com");
  assert.equal(stable, eventAttendeeId("event-1", "email:asha@example.com"));
  assert.notEqual(
    stable,
    eventAttendeeId("event-2", "email:asha@example.com")
  );
  assert.match(stable, /^att_[a-f0-9]{48}$/);
});

test("OTP registration seeds a private account draft without a profile", () => {
  assert.deepEqual(onboardingDraftSeed({
    displayName: "Asha Shah",
    phoneE164: "+919876543210",
  }), {
    step: 1,
    draftVersion: 2,
    firstName: "Asha Shah",
    lastName: "",
    phoneNumber: "9876543210",
    countryCode: "+91",
  });
});

test("registration consent only adds explicit channel grants", () => {
  const now = admin.firestore.Timestamp.fromMillis(10);
  assert.equal(mergeOrganizerCommunicationPreference({
    organizerId: "organizer-1",
    uid: "user-1",
    eventId: "event-1",
    now,
  }), null);

  const preference = mergeOrganizerCommunicationPreference({
    organizerId: "organizer-1",
    uid: "user-1",
    eventId: "event-1",
    organizerUpdates: {
      whatsapp: true,
      sms: false,
      termsVersion: "organizer-updates-v1",
    },
    now,
  });
  assert.equal(preference?.whatsapp.status, "optedIn");
  assert.equal(preference?.whatsapp.evidenceStatus, "complete");
  assert.match(preference?.whatsapp.currentReceiptId ?? "", /^ocpr_/);
  assert.equal(preference?.sms.status, "unknown");
  assert.equal(preference?.sms.evidenceStatus, "notApplicable");

  const replay = mergeOrganizerCommunicationPreference({
    existing: preference!,
    organizerId: "organizer-1",
    uid: "user-1",
    eventId: "event-2",
    organizerUpdates: {
      whatsapp: false,
      sms: false,
      termsVersion: "organizer-updates-v1",
    },
    now: admin.firestore.Timestamp.fromMillis(20),
  });
  assert.equal(replay, null);
  assert.equal(preference?.whatsapp.status, "optedIn");
});

test("absolute attendance replays and preserves prior state", async () => {
  const now = admin.firestore.Timestamp.fromMillis(1_000);
  const firestore = new FakeFirestore({
    "events/event-1": {
      clubId: "organizer-1",
      organizerId: "organizer-1",
      status: "active",
    },
    "organizers/organizer-1": {
      hostUserId: "host-1",
      ownerUserId: "host-1",
      hostUserIds: ["host-1"],
      hostProfiles: [],
    },
    "eventAttendees/attendee-1": {
      eventId: "event-1",
      status: "waitlisted",
      attendanceRevision: 0,
      preCheckInStatus: null,
    },
  });
  const deps = {
    firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
    checkRateLimit: async () => undefined,
    timestamp: () => now,
  };
  const checkIn = attendanceRequest({
    eventId: "event-1",
    attendeeId: "attendee-1",
    desiredCheckedIn: true,
    expectedRevision: 0,
    clientOperationId: "operation-check-in-1",
  });

  assert.deepEqual(await setEventAttendeeAttendanceHandler(checkIn, deps), {
    attendeeId: "attendee-1",
    checkedIn: true,
    acceptedRevision: 1,
    replayed: false,
    changed: true,
  });
  assert.equal(firestore.get("eventAttendees/attendee-1")?.status, "checkedIn");
  assert.equal(
    firestore.get("eventAttendees/attendee-1")?.preCheckInStatus,
    "waitlisted"
  );
  assert.deepEqual(await setEventAttendeeAttendanceHandler(checkIn, deps), {
    attendeeId: "attendee-1",
    checkedIn: true,
    acceptedRevision: 1,
    replayed: true,
    changed: true,
  });
  await assert.rejects(
    setEventAttendeeAttendanceHandler(attendanceRequest({
      eventId: "event-1",
      attendeeId: "attendee-1",
      desiredCheckedIn: false,
      expectedRevision: 0,
      clientOperationId: "operation-stale-undo-1",
    }), deps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "aborted"
  );
  const undo = await setEventAttendeeAttendanceHandler(attendanceRequest({
    eventId: "event-1",
    attendeeId: "attendee-1",
    desiredCheckedIn: false,
    expectedRevision: 1,
    clientOperationId: "operation-current-undo-1",
  }), deps);
  assert.equal(undo.acceptedRevision, 2);
  assert.equal(
    firestore.get("eventAttendees/attendee-1")?.status,
    "waitlisted"
  );
  assert.equal(
    firestore.get("eventAttendees/attendee-1")?.preCheckInStatus,
    null
  );
  assert.match(attendanceReceiptId({
    eventId: "event-1",
    actorUid: "host-1",
    clientOperationId: "operation-check-in-1",
  }), /^ear_[a-f0-9]{48}$/u);
});
