import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {eventAttendeeId} from "../events/eventAttendees";
import {
  approveEventRuntimeClaimHandler,
  claimEventRuntimeAccessHandler,
  completedRuntimeFieldIds,
  eventRuntimeParticipantId,
  getEventRuntimeBootstrapHandler,
  requiredRuntimeFieldIds,
  submitEventRuntimeProfileHandler,
} from "./eventRuntime";

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
  get exists(): boolean {
    return this.firestore.get(this.path) !== undefined;
  }
  data(): FakeData | undefined {
    return this.firestore.get(this.path);
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string,
    private readonly filters: Array<{
      field: string;
      value: unknown;
    }> = [],
    private readonly limitCount?: number
  ) {}
  doc(id: string): FakeDocRef {
    return new FakeDocRef(this.firestore, `${this.path}/${id}`);
  }
  where(field: string, operator: string, value: unknown): FakeCollectionRef {
    assert.equal(operator, "==");
    return new FakeCollectionRef(
      this.firestore,
      this.path,
      [...this.filters, {field, value}],
      this.limitCount
    );
  }
  limit(count: number): FakeCollectionRef {
    return new FakeCollectionRef(
      this.firestore,
      this.path,
      this.filters,
      count
    );
  }
  async get() {
    const docs = this.firestore.query(this.path, this.filters)
      .slice(0, this.limitCount);
    return {docs, empty: docs.length === 0, size: docs.length};
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];
  constructor(private readonly firestore: FakeFirestore) {}
  async get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore, ref.path);
  }
  create(ref: FakeDocRef, data: FakeData): void {
    this.writes.push(() => {
      if (this.firestore.get(ref.path) !== undefined) {
        throw new Error(`Document exists: ${ref.path}`);
      }
      this.firestore.set(ref.path, data);
    });
  }
  set(ref: FakeDocRef, data: FakeData, options?: {merge: boolean}): void {
    this.writes.push(() => {
      if (options?.merge) {
        this.firestore.set(ref.path, {
          ...(this.firestore.get(ref.path) ?? {}),
          ...data,
        });
      } else {
        this.firestore.set(ref.path, data);
      }
    });
  }
  update(ref: FakeDocRef, data: FakeData): void {
    this.writes.push(() => {
      const current = this.firestore.get(ref.path);
      if (!current) throw new Error(`Document missing: ${ref.path}`);
      this.firestore.set(ref.path, {...current, ...data});
    });
  }
  commit(): void {
    for (const write of this.writes) write();
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}
  collection(path: string): FakeCollectionRef {
    return new FakeCollectionRef(this, path);
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
    return data ? {...data} : undefined;
  }
  set(path: string, data: FakeData): void {
    this.docs[path] = {...data};
  }
  query(
    collection: string,
    filters: Array<{field: string; value: unknown}>
  ): FakeSnapshot[] {
    const prefix = `${collection}/`;
    return Object.entries(this.docs)
      .filter(([path, data]) =>
        data !== undefined &&
        path.startsWith(prefix) &&
        !path.slice(prefix.length).includes("/"))
      .filter(([, data]) => filters.every(({field, value}) =>
        nestedValue(data!, field) === value))
      .map(([path]) => new FakeSnapshot(this, path));
  }
}

function nestedValue(data: FakeData, path: string): unknown {
  return path.split(".").reduce<unknown>((value, segment) =>
    typeof value === "object" && value !== null ?
      (value as FakeData)[segment] : undefined, data);
}

function timestamp(iso = "2026-08-11T10:00:00.000Z") {
  return admin.firestore.Timestamp.fromDate(new Date(iso));
}

function event(overrides: FakeData = {}): FakeData {
  return {
    clubId: "organizer-1",
    organizerId: "organizer-1",
    startTime: timestamp("2026-08-11T12:00:00.000Z"),
    endTime: timestamp("2026-08-11T15:00:00.000Z"),
    meetingPoint: "The Courtyard",
    meetingLocation: {
      name: "The Courtyard",
      latitude: 19.1,
      longitude: 72.8,
    },
    eventFormat: {
      version: 1,
      activityKind: "singlesMixer",
      interactionModel: "freeFormMixer",
      customActivityLabel: "Wednesday Social",
    },
    status: "active",
    runtimeAccess: {
      enabled: true,
      publicRuntimeId: "runtime_123456789012345678901234",
      walkInPolicy: "deny",
      termsVersion: "event-runtime-v1",
    },
    ...overrides,
  };
}

function organizer(): FakeData {
  return {
    hostUserId: "host-1",
    ownerUserId: "host-1",
    hostUserIds: ["host-1"],
    hostProfiles: [],
  };
}

function attendee(overrides: FakeData = {}): FakeData {
  return {
    eventId: "event-1",
    clubId: "organizer-1",
    organizerId: "organizer-1",
    displayName: "Asha Shah",
    searchName: "asha shah",
    source: "hostImport",
    status: "registered",
    linkedUid: null,
    phoneE164: "+919876543210",
    email: null,
    externalReference: null,
    ticketType: null,
    importId: null,
    sourceRowId: null,
    createdAt: timestamp(),
    updatedAt: timestamp(),
    registeredAt: timestamp(),
    waitlistedAt: null,
    checkedInAt: null,
    cancelledAt: null,
    checkedInBy: null,
    linkedAt: null,
    ...overrides,
  };
}

function participant(overrides: FakeData = {}): FakeData {
  return {
    eventId: "event-1",
    clubId: "organizer-1",
    organizerId: "organizer-1",
    uid: "runner-1",
    eventAttendeeId: "attendee-1",
    identityVersion: 1,
    claimMethod: "verifiedPhone",
    accessStatus: "ready",
    requiredFieldIds: ["displayName"],
    completedFieldIds: ["displayName"],
    runtimeProfile: {
      displayName: "Asha Shah",
      gender: null,
      interestedInGenders: [],
      relationshipGoal: null,
      dateOfBirth: null,
    },
    consents: {
      runtimeTermsVersion: "event-runtime-v1",
      sensitiveDataTermsVersion: null,
      saveAsCatchPrefill: false,
    },
    claimedAt: timestamp(),
    readyAt: timestamp(),
    revokedAt: null,
    createdAt: timestamp(),
    updatedAt: timestamp(),
    ...overrides,
  };
}

function request(
  uid: string | null,
  data: FakeData,
  phone = "+919876543210"
): CallableRequest<unknown> {
  return {
    auth: uid ? {
      uid,
      token: {phone_number: phone},
    } as CallableRequest["auth"] : undefined,
    data,
    rawRequest: {} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function harness(initial: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initial);
  const limits: string[] = [];
  return {
    firestore,
    limits,
    deps: {
      firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
      timestamp,
      timestampFromMillis: (millis: number) =>
        admin.firestore.Timestamp.fromMillis(millis),
      checkRateLimit: async (
        _db: FirebaseFirestore.Firestore,
        uid: string,
        action: string
      ) => {
        limits.push(`${uid}:${action}`);
      },
    },
  };
}

function code(error: unknown, expected: string): boolean {
  return error instanceof HttpsError && error.code === expected;
}

test("plan-derived intake asks only for fields active modules need", () => {
  assert.deepEqual(requiredRuntimeFieldIds(null), ["displayName"]);
  assert.deepEqual(requiredRuntimeFieldIds({
    selectedModuleIds: ["first_hello_check_in"],
  } as never), ["displayName", "gender", "interestedInGenders"]);
  assert.deepEqual(completedRuntimeFieldIds({
    displayName: "Asha",
    gender: "woman",
    interestedInGenders: ["man"],
    relationshipGoal: null,
    dateOfBirth: null,
  }), ["displayName", "gender", "interestedInGenders"]);
});

test("bootstrap returns bounded event and own state", async () => {
  const h = harness({
    "events/event-1": event(),
    "eventRuntimeParticipants/event-1_runner-1": participant(),
    "eventAttendees/attendee-1": attendee({
      linkedUid: "runner-1",
      status: "checkedIn",
    }),
  });
  const result = await getEventRuntimeBootstrapHandler(request(
    "runner-1",
    {publicRuntimeId: "runtime_123456789012345678901234"}
  ), h.deps);
  assert.deepEqual(result.event, {
    publicRuntimeId: "runtime_123456789012345678901234",
    title: "Wednesday Social",
    startTimeMillis: Date.parse("2026-08-11T12:00:00.000Z"),
    endTimeMillis: Date.parse("2026-08-11T15:00:00.000Z"),
    locationName: "The Courtyard",
  });
  assert.equal(result.participant?.attendanceStatus, "checkedIn");
  assert.equal((result.event as FakeData).organizerId, undefined);
});

test("verified phone claims the matching imported attendee", async () => {
  const attendeeId = eventAttendeeId(
    "event-1",
    "phone:+919876543210"
  );
  const h = harness({
    "events/event-1": event(),
    [`eventAttendees/${attendeeId}`]: attendee(),
    "eventSuccessPlans/event-1": {
      selectedModuleIds: ["first_hello_check_in"],
    },
  });
  const result = await claimEventRuntimeAccessHandler(request("runner-1", {
    publicRuntimeId: "runtime_123456789012345678901234",
    displayName: "  Asha   Shah ",
    runtimeTermsVersion: "event-runtime-v1",
  }), h.deps);
  assert.equal(result.status, "needsInput");
  assert.equal(result.attendeeId, attendeeId);
  assert.deepEqual(result.requiredFieldIds, [
    "displayName",
    "gender",
    "interestedInGenders",
  ]);
  assert.equal(h.firestore.get(`eventAttendees/${attendeeId}`)?.linkedUid,
    "runner-1");
  assert.equal(h.firestore.get("users/runner-1"), undefined);
  assert.equal(h.firestore.get("eventParticipations/event-1_runner-1"),
    undefined);
});

test("unmatched numbers obey deny and Host approval policies", async () => {
  const denied = harness({"events/event-1": event()});
  await assert.rejects(
    () => claimEventRuntimeAccessHandler(request("runner-1", {
      publicRuntimeId: "runtime_123456789012345678901234",
      displayName: "Asha",
      runtimeTermsVersion: "event-runtime-v1",
    }), denied.deps),
    (error) => code(error, "permission-denied")
  );

  const pending = harness({
    "events/event-1": event({runtimeAccess: {
      enabled: true,
      publicRuntimeId: "runtime_123456789012345678901234",
      walkInPolicy: "hostApproval",
      termsVersion: "event-runtime-v1",
    }}),
  });
  const result = await claimEventRuntimeAccessHandler(request("runner-1", {
    publicRuntimeId: "runtime_123456789012345678901234",
    displayName: "Asha",
    runtimeTermsVersion: "event-runtime-v1",
  }), pending.deps);
  assert.equal(result.status, "pendingApproval");
  const claim = pending.firestore.get(
    "eventRuntimeClaimRequests/event-1_runner-1"
  );
  assert.equal(claim?.phoneLastFour, "3210");
  assert.equal(claim?.status, "pending");
});

test("profile submission requires sensitive consent and seeds only a draft",
  async () => {
    const runtimeParticipant = participant({
      accessStatus: "needsInput",
      requiredFieldIds: ["displayName", "gender", "interestedInGenders"],
      completedFieldIds: ["displayName"],
      readyAt: null,
    });
    const initial = {
      "events/event-1": event(),
      "eventRuntimeParticipants/event-1_runner-1": runtimeParticipant,
      "eventSuccessPlans/event-1": {
        selectedModuleIds: ["first_hello_check_in"],
      },
    };
    const h = harness(initial);
    const payload = {
      publicRuntimeId: "runtime_123456789012345678901234",
      runtimeTermsVersion: "event-runtime-v1",
      saveAsCatchPrefill: true,
      fields: {gender: "woman", interestedInGenders: ["man"]},
    };
    await assert.rejects(
      () => submitEventRuntimeProfileHandler(
        request("runner-1", payload), h.deps
      ),
      (error) => code(error, "failed-precondition")
    );
    const result = await submitEventRuntimeProfileHandler(
      request("runner-1", {
        ...payload,
        sensitiveDataTermsVersion: "sensitive-runtime-v1",
      }),
      h.deps
    );
    assert.equal(result.status, "ready");
    const draft = h.firestore.get("onboarding_drafts/runner-1");
    assert.equal(draft?.firstName, "Asha Shah");
    assert.equal(draft?.phoneNumber, "9876543210");
    assert.equal(draft?.gender, "woman");
    assert.equal(h.firestore.get("users/runner-1"), undefined);
  });

test("Host approval binds only a candidate from the same event", async () => {
  const attendeeId = eventAttendeeId(
    "event-1",
    "phone:+919876543210"
  );
  const h = harness({
    "events/event-1": event(),
    "organizers/organizer-1": organizer(),
    [`eventAttendees/${attendeeId}`]: attendee({status: "invited"}),
    "eventRuntimeParticipants/event-1_runner-1": participant({
      eventAttendeeId: attendeeId,
      accessStatus: "pendingApproval",
      readyAt: null,
    }),
    "eventRuntimeClaimRequests/event-1_runner-1": {
      eventId: "event-1",
      clubId: "organizer-1",
      organizerId: "organizer-1",
      uid: "runner-1",
      displayName: "Asha Shah",
      phoneLastFour: "3210",
      candidateAttendeeIds: [attendeeId],
      status: "pending",
      reviewedBy: null,
      reviewReason: null,
      createdAt: timestamp(),
      updatedAt: timestamp(),
      reviewedAt: null,
    },
  });
  await assert.rejects(
    () => approveEventRuntimeClaimHandler(request("host-1", {
      eventId: "event-1",
      uid: "runner-1",
      decision: "approve",
      attendeeId: "attendee-from-another-event",
    }), h.deps),
    (error) => code(error, "invalid-argument")
  );
  const result = await approveEventRuntimeClaimHandler(request("host-1", {
    eventId: "event-1",
    uid: "runner-1",
    decision: "approve",
    attendeeId,
  }), h.deps);
  assert.deepEqual(result, {status: "approved"});
  assert.equal(h.firestore.get(`eventAttendees/${attendeeId}`)?.linkedUid,
    "runner-1");
  assert.equal(h.firestore.get(
    "eventRuntimeClaimRequests/event-1_runner-1"
  )?.status, "approved");
});

test("runtime participant ids are deterministic and event scoped", () => {
  assert.equal(eventRuntimeParticipantId("event-1", "runner-1"),
    "event-1_runner-1");
});
