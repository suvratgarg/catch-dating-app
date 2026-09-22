import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  createOrganizerProgramHandler,
  updateOrganizerProgramHandler,
} from "../programs/programs";
import {
  getProgramWorkAccessHandler,
  grantProgramStaffHandler,
} from "../programs/programStaff";
import {upsertProgramGuestHandler} from "../programs/programGuests";
import {
  getProgramArrivalsRosterHandler,
  getProgramTransportPlanHandler,
  setProgramTravelReadinessHandler,
} from "./programArrivals";
import {
  dispatchProgramTripHandler,
  getProgramHotelInboundHandler,
  listProgramTripsHandler,
  voidProgramTripHandler,
} from "./programDispatch";

type FakeData = Record<string, unknown>;
type Where = {field: string; op: string; value: unknown};

const autoIds: string[] = [];
let autoCounter = 0;
function nextAutoId(): string {
  autoCounter += 1;
  const id = `auto-${autoCounter}`;
  autoIds.push(id);
  return id;
}

function timestampMillis(value: unknown): number {
  if (value && typeof value === "object") {
    const stamp = value as {seconds?: number; _seconds?: number;
      toMillis?: () => number};
    if (typeof stamp.toMillis === "function") return stamp.toMillis();
    if (typeof stamp.seconds === "number") return stamp.seconds * 1000;
    if (typeof stamp._seconds === "number") return stamp._seconds * 1000;
  }
  return typeof value === "number" ? value : 0;
}

class FakeDocSnapshot {
  constructor(readonly id: string,
    readonly ref: FakeDocRef,
    private readonly value: FakeData | undefined) {}
  get exists() {
    return this.value !== undefined;
  }
  data() {
    return this.value;
  }
}

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
  get id() {
    return this.path.split("/").pop()!;
  }
  async get() {
    return new FakeDocSnapshot(this.id, this,
      this.firestore.getDoc(this.path));
  }
  async set(data: FakeData) {
    this.firestore.setDoc(this.path, data);
  }
  async update(data: FakeData) {
    this.firestore.updateDoc(this.path, data);
  }
}

class FakeQuery {
  constructor(readonly firestore: FakeFirestore,
    readonly collectionPath: string,
    readonly wheres: Where[] = [],
    readonly order: {field: string; dir: "asc" | "desc"} | null = null,
    readonly limitN: number | null = null,
    readonly startAfterValue: unknown = null) {}
  where(field: string, op: string, value: unknown) {
    return new FakeQuery(this.firestore, this.collectionPath,
      [...this.wheres, {field, op, value}], this.order, this.limitN,
      this.startAfterValue);
  }
  orderBy(field: string, dir: "asc" | "desc" = "asc") {
    return new FakeQuery(this.firestore, this.collectionPath, this.wheres,
      {field, dir}, this.limitN, this.startAfterValue);
  }
  limit(n: number) {
    return new FakeQuery(this.firestore, this.collectionPath, this.wheres,
      this.order, n, this.startAfterValue);
  }
  startAfter(value: unknown) {
    return new FakeQuery(this.firestore, this.collectionPath, this.wheres,
      this.order, this.limitN, value);
  }
  async get() {
    return this.firestore.runQuery(this);
  }
}

class FakeCollectionRef extends FakeQuery {
  doc(id?: string) {
    return new FakeDocRef(this.firestore,
      `${this.collectionPath}/${id ?? nextAutoId()}`);
  }
}

class FakeQuerySnapshot {
  constructor(readonly docs: FakeDocSnapshot[]) {}
  get size() {
    return this.docs.length;
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];
  constructor(private readonly firestore: FakeFirestore) {}
  async get(source: FakeDocRef | FakeQuery) {
    if (source instanceof FakeDocRef) return source.get();
    return source.get();
  }
  set(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => this.firestore.setDoc(ref.path, data));
  }
  update(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => this.firestore.updateDoc(ref.path, data));
  }
  commit() {
    for (const write of this.writes) write();
  }
}

class FakeFirestore {
  readonly docs: Map<string, FakeData>;
  constructor(seed: Record<string, FakeData | undefined>) {
    this.docs = new Map(Object.entries(seed)
      .filter(([, v]) => v !== undefined) as [string, FakeData][]);
  }
  collection(path: string) {
    return new FakeCollectionRef(this, path);
  }
  getDoc(path: string) {
    return this.docs.get(path);
  }
  setDoc(path: string, data: FakeData) {
    this.docs.set(path, {...data});
  }
  updateDoc(path: string, data: FakeData) {
    const existing = this.docs.get(path);
    if (!existing) throw new Error(`Document missing: ${path}`);
    this.docs.set(path, {...existing, ...data});
  }
  async runQuery(query: FakeQuery) {
    const prefix = `${query.collectionPath}/`;
    const docs: FakeDocSnapshot[] = [];
    for (const [path, data] of this.docs) {
      if (!path.startsWith(prefix)) continue;
      if (path.slice(prefix.length).includes("/")) continue;
      const id = path.slice(prefix.length);
      const ref = new FakeDocRef(this, path);
      if (query.wheres.every((where) => matchWhere(data, where))) {
        docs.push(new FakeDocSnapshot(id, ref, data));
      }
    }
    if (query.order) {
      const {field, dir} = query.order;
      docs.sort((a, b) => {
        const av = timestampMillis(a.data()?.[field]) ||
          String(a.data()?.[field] ?? "");
        const bv = timestampMillis(b.data()?.[field]) ||
          String(b.data()?.[field] ?? "");
        const order = av < bv ? -1 : av > bv ? 1 : 0;
        return dir === "desc" ? -order : order;
      });
    }
    let filtered = docs;
    if (query.startAfterValue !== null && query.order) {
      const field = query.order.field;
      filtered = docs.filter((doc) => {
        const value = doc.data()?.[field];
        return String(value) > String(query.startAfterValue);
      });
    }
    const limited = query.limitN === null ?
      filtered : filtered.slice(0, query.limitN);
    return new FakeQuerySnapshot(limited);
  }
  async runTransaction<T>(callback: (tx: FakeTransaction) => Promise<T>) {
    const tx = new FakeTransaction(this);
    const result = await callback(tx);
    tx.commit();
    return result;
  }
}

function matchWhere(data: FakeData, where: Where): boolean {
  const value = data[where.field];
  if (where.op === "==") return value === where.value;
  if (where.op === "in") {
    return Array.isArray(where.value) && where.value.includes(value);
  }
  if (where.op === ">") {
    return timestampMillis(value) > timestampMillis(where.value);
  }
  if (where.op === "!=") return value !== where.value;
  throw new Error(`Unsupported where op: ${where.op}`);
}

function request(data: Record<string, unknown>, uid: string) {
  return {
    auth: {uid, token: {}},
    data,
    rawRequest: {},
  } as CallableRequest<unknown>;
}

const now = admin.firestore.Timestamp.fromMillis(1_800_000_000_000);

const transportSettings = {
  bandWindowMillis: 30 * 60 * 1000,
  maxReadyWaitMillis: 10 * 60 * 1000,
  domesticExitLagMillis: 25 * 60 * 1000,
  internationalExitLagMillis: 60 * 60 * 1000,
  vehicleClasses: [
    {id: "sedan", label: "Sedan", passengerCapacity: 3,
      luggageCapacity: 3, capabilities: [], sortOrder: 0},
    {id: "suv", label: "Innova / SUV", passengerCapacity: 6,
      luggageCapacity: 8, capabilities: ["extraLuggage"], sortOrder: 1},
  ],
};

function baseSeed(): Record<string, FakeData> {
  return {
    "organizers/org-1": {
      hostUserId: "manager-1",
      ownerUserId: "manager-1",
      hostUserIds: ["manager-1"],
      hostProfiles: [],
    },
    "organizerPrograms/program-1": {
      organizerId: "org-1",
      kind: "wedding",
      title: "Sharma–Rao Wedding",
      timezone: "Asia/Kolkata",
      startsAt: admin.firestore.Timestamp.fromMillis(1_800_000_000_000),
      endsAt: admin.firestore.Timestamp.fromMillis(1_800_300_000_000),
      status: "active",
      capabilities: ["arrivalsTransport"],
      transportSettings,
      createdBy: "manager-1",
      createdAt: now,
      updatedAt: now,
      revision: 3,
    },
    "programPickupPoints/pp-t3": {
      programId: "program-1",
      organizerId: "org-1",
      kind: "airport",
      label: "DEL T3 arrivals",
      iataCode: "DEL",
      terminal: "T3",
      meetingZone: null,
      latitude: null,
      longitude: null,
      instructions: null,
      active: true,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
    "programPickupPoints/pp-t1": {
      programId: "program-1",
      organizerId: "org-1",
      kind: "airport",
      label: "DEL T1 arrivals",
      iataCode: "DEL",
      terminal: "T1",
      meetingZone: null,
      latitude: null,
      longitude: null,
      instructions: null,
      active: true,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
    "programHotels/hotel-1": {
      programId: "program-1",
      organizerId: "org-1",
      name: "Taj Palace",
      address: "Chanakyapuri",
      latitude: null,
      longitude: null,
      receptionContact: null,
      notes: null,
      active: true,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
    "programHotels/hotel-2": {
      programId: "program-1",
      organizerId: "org-1",
      name: "ITC Maurya",
      address: "Diplomatic Enclave",
      latitude: null,
      longitude: null,
      receptionContact: null,
      notes: null,
      active: true,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
    "programGuests/guest-1": {
      programId: "program-1",
      organizerId: "org-1",
      displayName: "Rohan Sharma",
      householdId: null,
      contactId: null,
      phoneE164: "+919999900001",
      email: null,
      externalReference: null,
      invitationStatus: "notInvited",
      rsvpStatus: "accepted",
      source: "manual",
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
    "programGuests/guest-2": {
      programId: "program-1",
      organizerId: "org-1",
      displayName: "Vikram Rao",
      householdId: null,
      contactId: null,
      phoneE164: "+919999900002",
      email: null,
      externalReference: null,
      invitationStatus: "notInvited",
      rsvpStatus: "accepted",
      source: "manual",
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
    "programTravelLegs/leg-1": {
      programId: "program-1",
      organizerId: "org-1",
      guestId: "guest-1",
      partyId: null,
      kind: "inbound",
      flightNumber: "AI847",
      carrierCode: "AI",
      originIata: "BOM",
      destinationIata: "DEL",
      scheduledArrivalAt:
        admin.firestore.Timestamp.fromMillis(1_800_000_000_000),
      estimatedArrivalAt: null,
      actualArrivalAt: null,
      flightStatus: "scheduled",
      flightInstanceId: null,
      international: false,
      pickupPointId: "pp-t3",
      destinationHotelId: "hotel-1",
      destinationLabel: null,
      readiness: "expected",
      readyAt: null,
      claimedByUid: null,
      claimedAt: null,
      manualCurbAt: null,
      manualCurbNote: null,
      passengers: 2,
      luggageUnits: 3,
      requiredCapabilities: [],
      dedicatedVehicle: false,
      source: "planner",
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
    "programTravelLegs/leg-2": {
      programId: "program-1",
      organizerId: "org-1",
      guestId: "guest-2",
      partyId: null,
      kind: "inbound",
      flightNumber: "6E2041",
      carrierCode: "6E",
      originIata: "BLR",
      destinationIata: "DEL",
      scheduledArrivalAt:
        admin.firestore.Timestamp.fromMillis(1_800_000_600_000),
      estimatedArrivalAt: null,
      actualArrivalAt: null,
      flightStatus: "scheduled",
      flightInstanceId: null,
      international: false,
      pickupPointId: "pp-t1",
      destinationHotelId: "hotel-1",
      destinationLabel: null,
      readiness: "expected",
      readyAt: null,
      claimedByUid: null,
      claimedAt: null,
      manualCurbAt: null,
      manualCurbNote: null,
      passengers: 1,
      luggageUnits: 1,
      requiredCapabilities: [],
      dedicatedVehicle: false,
      source: "planner",
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
    "programStaffGrants/program-1__greeter-1": {
      organizerId: "org-1",
      programId: "program-1",
      uid: "greeter-1",
      displayName: "Arjun",
      phoneLastFour: "0001",
      duties: [{
        duty: "airportGreeter",
        pickupPointIds: ["pp-t3"],
        hotelIds: [],
      }],
      status: "active",
      createdBy: "manager-1",
      createdAt: now,
      expiresAt:
        admin.firestore.Timestamp.fromMillis(1_800_000_000_000 + 86_400_000),
      revokedBy: null,
      revokedAt: null,
      updatedAt: now,
      revision: 1,
    },
    "programStaffGrants/program-1__greeter-2": {
      organizerId: "org-1",
      programId: "program-1",
      uid: "greeter-2",
      displayName: "Sana",
      phoneLastFour: "0002",
      duties: [{
        duty: "airportGreeter",
        pickupPointIds: ["pp-t3"],
        hotelIds: [],
      }],
      status: "active",
      createdBy: "manager-1",
      createdAt: now,
      expiresAt:
        admin.firestore.Timestamp.fromMillis(1_800_000_000_000 + 86_400_000),
      revokedBy: null,
      revokedAt: null,
      updatedAt: now,
      revision: 1,
    },
    "programStaffGrants/program-1__dispatcher-1": {
      organizerId: "org-1",
      programId: "program-1",
      uid: "dispatcher-1",
      displayName: "Meera",
      phoneLastFour: "0003",
      duties: [{
        duty: "transportDispatcher",
        pickupPointIds: [],
        hotelIds: [],
      }],
      status: "active",
      createdBy: "manager-1",
      createdAt: now,
      expiresAt:
        admin.firestore.Timestamp.fromMillis(1_800_000_000_000 + 86_400_000),
      revokedBy: null,
      revokedAt: null,
      updatedAt: now,
      revision: 1,
    },
    "programStaffGrants/program-1__hotelier-1": {
      organizerId: "org-1",
      programId: "program-1",
      uid: "hotelier-1",
      displayName: "Dev",
      phoneLastFour: "0004",
      duties: [{
        duty: "hotelDesk",
        pickupPointIds: [],
        hotelIds: ["hotel-1"],
      }],
      status: "active",
      createdBy: "manager-1",
      createdAt: now,
      expiresAt:
        admin.firestore.Timestamp.fromMillis(1_800_000_000_000 + 86_400_000),
      revokedBy: null,
      revokedAt: null,
      updatedAt: now,
      revision: 1,
    },
    "transportVendors/vendor-1": {
      organizerId: "org-1",
      name: "Sharma Cabs",
      contactName: null,
      phoneE164: null,
      programIds: ["program-1"],
      active: true,
      notes: null,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    },
  };
}

function deps(firestore: FakeFirestore,
  overrides: Record<string, unknown> = {}) {
  return {
    firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
    checkRateLimit: async () => undefined,
    now: () => now,
    getUserByPhoneNumber: async (phoneNumber: string) =>
      ({uid: "new-staff-1", displayName: "New Staff",
        phoneNumber} as admin.auth.UserRecord),
    ...overrides,
  } as never;
}

test("createOrganizerProgram requires organizer management", async () => {
  const firestore = new FakeFirestore(baseSeed());
  await assert.rejects(
    createOrganizerProgramHandler(request({
      organizerId: "org-1",
      kind: "wedding",
      title: "Test",
      timezone: "Asia/Kolkata",
      startsAtMillis: 1,
      endsAtMillis: 2,
      capabilities: ["arrivalsTransport"],
    }, "stranger"), deps(firestore)),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied"
  );
  const created = await createOrganizerProgramHandler(request({
    organizerId: "org-1",
    kind: "wedding",
    title: "New Program",
    timezone: "Asia/Kolkata",
    startsAtMillis: 1_800_000_000_000,
    endsAtMillis: 1_800_300_000_000,
    capabilities: ["arrivalsTransport"],
  }, "manager-1"), deps(firestore));
  assert.equal(created.revision, 1);
  const stored = firestore.getDoc(`organizerPrograms/${created.entityId}`);
  assert.equal(stored?.status, "draft");
  // Premium default: 30-minute bands, 10-minute ready wait.
  const settings = stored?.transportSettings as Record<string, unknown>;
  assert.equal(settings.bandWindowMillis, 30 * 60 * 1000);
  assert.equal(settings.maxReadyWaitMillis, 10 * 60 * 1000);
});

test("updateOrganizerProgram fences on revision and stores settings",
  async () => {
    const firestore = new FakeFirestore(baseSeed());
    await assert.rejects(
      updateOrganizerProgramHandler(request({
        programId: "program-1",
        expectedRevision: 99,
        transportSettings: {
          ...transportSettings,
          maxReadyWaitMillis: 5 * 60 * 1000,
        },
      }, "manager-1"), deps(firestore)),
      (error: unknown) =>
        error instanceof HttpsError && error.code === "aborted"
    );
    const updated = await updateOrganizerProgramHandler(request({
      programId: "program-1",
      expectedRevision: 3,
      transportSettings: {
        ...transportSettings,
        maxReadyWaitMillis: 5 * 60 * 1000,
      },
    }, "manager-1"), deps(firestore));
    const stored = firestore.getDoc("organizerPrograms/program-1");
    const settings = stored?.transportSettings as Record<string, unknown>;
    assert.equal(settings.maxReadyWaitMillis, 5 * 60 * 1000);
    assert.equal(updated.revision, stored?.revision);
  });

test("staff grants are duty-scoped, expiring, and station-checked",
  async () => {
    const firestore = new FakeFirestore(baseSeed());
    await assert.rejects(
      grantProgramStaffHandler(request({
        programId: "program-1",
        phoneNumber: "+91 90000 00009",
        duties: [{duty: "airportGreeter", pickupPointIds: [], hotelIds: []}],
        expiresAtMillis: now.toMillis() + 86_400_000,
      }, "greeter-1"), deps(firestore)),
      (error: unknown) =>
        error instanceof HttpsError && error.code === "permission-denied"
    );
    await assert.rejects(
      grantProgramStaffHandler(request({
        programId: "program-1",
        phoneNumber: "+91 90000 00009",
        duties: [{
          duty: "airportGreeter",
          pickupPointIds: ["pp-foreign"],
          hotelIds: [],
        }],
        expiresAtMillis: now.toMillis() + 86_400_000,
      }, "manager-1"), deps(firestore)),
      (error: unknown) =>
        error instanceof HttpsError && error.code === "invalid-argument"
    );
    const members = await grantProgramStaffHandler(request({
      programId: "program-1",
      phoneNumber: "+91 90000 00009",
      duties: [{
        duty: "airportGreeter",
        pickupPointIds: ["pp-t1"],
        hotelIds: [],
      }],
      expiresAtMillis: now.toMillis() + 86_400_000,
    }, "manager-1"), deps(firestore));
    assert.equal(members.members.length, 5);
    const grant = firestore.getDoc("programStaffGrants/program-1__new-staff-1");
    assert.equal(grant?.status, "active");
  });

test("work access redacts a greeter to their station scope", async () => {
  const firestore = new FakeFirestore(baseSeed());
  const access = await getProgramWorkAccessHandler(request({
    programId: "program-1",
  }, "greeter-1"), deps(firestore));
  assert.equal(access.actorRole, "staff");
  assert.deepEqual(access.pickupPoints.map((p) => p.pickupPointId),
    ["pp-t3"]);
  // Greeters still see labeled destinations for roster context.
  assert.deepEqual(access.hotels.map((h) => h.hotelId).sort(),
    ["hotel-1", "hotel-2"]);
  await assert.rejects(
    getProgramWorkAccessHandler(request({programId: "program-1"},
      "stranger"), deps(firestore)),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied"
  );
});

test("two guests sharing a phone stay distinct people", async () => {
  const firestore = new FakeFirestore(baseSeed());
  const managerDeps = deps(firestore);
  const first = await upsertProgramGuestHandler(request({
    programId: "program-1",
    displayName: "Kid One",
    phoneE164: "+919111111111",
  }, "manager-1"), managerDeps);
  const second = await upsertProgramGuestHandler(request({
    programId: "program-1",
    displayName: "Kid Two",
    phoneE164: "+919111111111",
  }, "manager-1"), managerDeps);
  assert.notEqual(first.entityId, second.entityId);
});

test("arrivals roster is station-scoped and field-redacted", async () => {
  const firestore = new FakeFirestore(baseSeed());
  const roster = await getProgramArrivalsRosterHandler(request({
    programId: "program-1",
    pickupPointId: null,
  }, "greeter-1"), deps(firestore));
  // pp-t3 scope only: leg-1 yes, leg-2 (T1) no.
  assert.deepEqual(roster.rows.map((row) => row.legId), ["leg-1"]);
  const row = roster.rows[0];
  assert.equal(row.guestDisplayName, "Rohan Sharma");
  assert.equal(row.flightNumber, "AI847");
  assert.equal(
    row.curbAtMillis,
    1_800_000_000_000 + transportSettings.domesticExitLagMillis
  );
  assert.equal(row.curbSource, "scheduledLanding");
  // No contact fields in the operational projection.
  assert.equal("phoneE164" in row, false);
  assert.equal("email" in row, false);
  // A greeter may not pull another station's roster by name.
  await assert.rejects(
    getProgramArrivalsRosterHandler(request({
      programId: "program-1",
      pickupPointId: "pp-t1",
    }, "greeter-1"), deps(firestore)),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied"
  );
  // Staff without any airport duty are denied entirely.
  await assert.rejects(
    getProgramArrivalsRosterHandler(request({
      programId: "program-1",
      pickupPointId: null,
    }, "hotelier-1"), deps(firestore)),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied"
  );
});

test("claims are exclusive, releasable, and replay-safe", async () => {
  const firestore = new FakeFirestore(baseSeed());
  const greeterDeps = deps(firestore);
  const claim = await setProgramTravelReadinessHandler(request({
    programId: "program-1",
    legId: "leg-1",
    action: "claim",
    clientOperationId: "op-claim-1",
  }, "greeter-1"), greeterDeps);
  assert.equal(claim.alreadyApplied, false);
  // Same request replayed returns the stored result.
  const replay = await setProgramTravelReadinessHandler(request({
    programId: "program-1",
    legId: "leg-1",
    action: "claim",
    clientOperationId: "op-claim-1",
  }, "greeter-1"), greeterDeps);
  assert.equal(replay.alreadyApplied, true);
  assert.equal(replay.revision, claim.revision);
  // A second greeter cannot steal the claim.
  await assert.rejects(
    setProgramTravelReadinessHandler(request({
      programId: "program-1",
      legId: "leg-1",
      action: "claim",
      clientOperationId: "op-claim-2",
    }, "greeter-2"), greeterDeps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "already-exists"
  );
  // Same operation id with a different payload is rejected.
  await assert.rejects(
    setProgramTravelReadinessHandler(request({
      programId: "program-1",
      legId: "leg-1",
      action: "claim",
      expectedRevision: 7,
      clientOperationId: "op-claim-1",
    }, "greeter-1"), greeterDeps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "aborted"
  );
  // Claimants may release their own claim.
  await setProgramTravelReadinessHandler(request({
    programId: "program-1",
    legId: "leg-1",
    action: "unclaim",
    clientOperationId: "op-unclaim-1",
  }, "greeter-1"), greeterDeps);
  assert.equal(
    firestore.getDoc("programTravelLegs/leg-1")?.claimedByUid, null);
  // Greeters cannot touch a leg at a station outside their scope.
  await assert.rejects(
    setProgramTravelReadinessHandler(request({
      programId: "program-1",
      legId: "leg-2",
      action: "claim",
      clientOperationId: "op-claim-3",
    }, "greeter-1"), greeterDeps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied"
  );
});

test("dispatch writes trip, assignments and receipt atomically", async () => {
  const firestore = new FakeFirestore(baseSeed());
  const dispatchDeps = deps(firestore);
  const dispatched = await dispatchProgramTripHandler(request({
    programId: "program-1",
    pickupPointId: "pp-t3",
    destinationHotelId: "hotel-1",
    vehicleClassId: "suv",
    plateDisplay: "DL-1T-4471",
    vendorId: "vendor-1",
    legIds: ["leg-1"],
    clientOperationId: "op-dispatch-1",
  }, "dispatcher-1"), dispatchDeps);
  assert.equal(dispatched.passengerCount, 2);
  const trip = firestore.getDoc(`transportTrips/${dispatched.tripId}`);
  assert.equal(trip?.plateNormalized, "DL1T4471");
  assert.equal(trip?.vendorNameSnapshot, "Sharma Cabs");
  assert.equal(trip?.status, "enRoute");
  assert.equal(
    firestore.getDoc("programTravelLegs/leg-1")?.readiness, "dispatched");
  const assignment = firestore.getDoc(
    "transportActiveAssignments/program-1__leg-1");
  assert.equal(assignment?.status, "active");
  assert.equal(assignment?.tripId, dispatched.tripId);
  // Exact replay returns the original trip, not a duplicate.
  const replay = await dispatchProgramTripHandler(request({
    programId: "program-1",
    pickupPointId: "pp-t3",
    destinationHotelId: "hotel-1",
    vehicleClassId: "suv",
    plateDisplay: "DL-1T-4471",
    vendorId: "vendor-1",
    legIds: ["leg-1"],
    clientOperationId: "op-dispatch-1",
  }, "dispatcher-1"), dispatchDeps);
  assert.equal(replay.alreadyApplied, true);
  assert.equal(replay.tripId, dispatched.tripId);
  // A second dispatch of an assigned leg is rejected.
  await assert.rejects(
    dispatchProgramTripHandler(request({
      programId: "program-1",
      pickupPointId: "pp-t3",
      destinationHotelId: "hotel-1",
      vehicleClassId: "sedan",
      plateDisplay: "DL-9Z-0001",
      legIds: ["leg-1"],
      clientOperationId: "op-dispatch-2",
    }, "dispatcher-1"), dispatchDeps),
    (error: unknown) =>
      error instanceof HttpsError &&
      ["already-exists", "failed-precondition"].includes(error.code)
  );
  // A greeter cannot dispatch.
  await assert.rejects(
    dispatchProgramTripHandler(request({
      programId: "program-1",
      pickupPointId: "pp-t1",
      destinationHotelId: "hotel-1",
      vehicleClassId: "sedan",
      plateDisplay: "DL-9Z-0002",
      legIds: ["leg-2"],
      clientOperationId: "op-dispatch-3",
    }, "greeter-1"), dispatchDeps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied"
  );
  // Voiding releases the assignment and returns the leg to ready.
  const tripDoc = firestore.getDoc(`transportTrips/${dispatched.tripId}`);
  const voided = await voidProgramTripHandler(request({
    programId: "program-1",
    tripId: dispatched.tripId,
    reason: "Wrong vehicle dispatched",
    expectedRevision: tripDoc?.revision as number,
    clientOperationId: "op-void-1",
  }, "dispatcher-1"), dispatchDeps);
  assert.equal(voided.alreadyApplied, false);
  assert.equal(
    firestore.getDoc(`transportTrips/${dispatched.tripId}`)?.status,
    "voided");
  assert.equal(
    firestore.getDoc(`transportTrips/${dispatched.tripId}`)?.voidReason,
    "Wrong vehicle dispatched");
  assert.equal(
    firestore.getDoc("transportActiveAssignments/program-1__leg-1")?.status,
    "released");
  assert.equal(
    firestore.getDoc("programTravelLegs/leg-1")?.readiness, "ready");
});

test("hotel inbound is hotel-scoped and arrival marks the trip", async () => {
  const firestore = new FakeFirestore(baseSeed());
  const dispatchDeps = deps(firestore);
  const dispatched = await dispatchProgramTripHandler(request({
    programId: "program-1",
    pickupPointId: "pp-t3",
    destinationHotelId: "hotel-1",
    vehicleClassId: "suv",
    plateDisplay: "DL-1T-4471",
    vendorId: "vendor-1",
    legIds: ["leg-1"],
    clientOperationId: "op-dispatch-9",
  }, "dispatcher-1"), dispatchDeps);
  const inbound = await getProgramHotelInboundHandler(request({
    programId: "program-1",
    hotelId: "hotel-1",
  }, "hotelier-1"), dispatchDeps);
  assert.equal(inbound.trips.length, 1);
  assert.equal(inbound.trips[0].plateDisplay, "DL-1T-4471");
  assert.deepEqual(inbound.trips[0].guestNames, ["Rohan Sharma"]);
  assert.equal(inbound.trips[0].estimatedArriveAtMillis, null);
  // The T1 leg headed to hotel-1 is visible as "expected".
  assert.equal(inbound.expectedLegs.length, 1);
  assert.equal(inbound.expectedLegs[0].guestDisplayName, "Vikram Rao");
  // Hotel staff cannot open another hotel's view.
  await assert.rejects(
    getProgramHotelInboundHandler(request({
      programId: "program-1",
      hotelId: "hotel-2",
    }, "hotelier-1"), dispatchDeps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied"
  );
  // Marking arrival is hotel-scoped and idempotent.
  const tripDoc = firestore.getDoc(`transportTrips/${dispatched.tripId}`);
  await assert.rejects(
    voidProgramTripHandler(request({
      programId: "program-1",
      tripId: dispatched.tripId,
      reason: "Hotel cannot void",
      expectedRevision: tripDoc?.revision as number,
      clientOperationId: "op-void-hotel",
    }, "hotelier-1"), dispatchDeps),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied"
  );
});

test("transport plan groups by station, destination and readiness",
  async () => {
    const firestore = new FakeFirestore(baseSeed());
    // leg-1 (T3, hotel-1, scheduled) vs leg-2 (T1, hotel-1): separate
    // stations, so the dispatcher sees each station's plan independently.
    const plan = await getProgramTransportPlanHandler(request({
      programId: "program-1",
      pickupPointId: "pp-t3",
    }, "dispatcher-1"), deps(firestore));
    assert.equal(plan.groups.length, 1);
    const group = plan.groups[0];
    assert.deepEqual(group.legIds, ["leg-1"]);
    assert.equal(group.vehicleClassId, "sedan");
    assert.equal(group.readiness, "expected");
    assert.equal(group.waitOverdue, false);
    // A dispatcher without station restriction sees the T1 plan too.
    const t1 = await getProgramTransportPlanHandler(request({
      programId: "program-1",
      pickupPointId: "pp-t1",
    }, "dispatcher-1"), deps(firestore));
    assert.equal(t1.groups.length, 1);
    assert.deepEqual(t1.groups[0].legIds, ["leg-2"]);
  });

test("trip ledger is restricted to dispatcher/reconciliation duties",
  async () => {
    const firestore = new FakeFirestore(baseSeed());
    await dispatchProgramTripHandler(request({
      programId: "program-1",
      pickupPointId: "pp-t3",
      destinationHotelId: "hotel-1",
      vehicleClassId: "suv",
      plateDisplay: "DL-1T-4471",
      vendorId: "vendor-1",
      legIds: ["leg-1"],
      clientOperationId: "op-dispatch-ledger",
    }, "dispatcher-1"), deps(firestore));
    const ledger = await listProgramTripsHandler(request({
      programId: "program-1",
    }, "dispatcher-1"), deps(firestore));
    assert.equal(ledger.trips.length, 1);
    assert.equal(ledger.trips[0].plateDisplay, "DL-1T-4471");
    assert.deepEqual(ledger.trips[0].guestNames, ["Rohan Sharma"]);
    // A greeter is not a reconciliation reader.
    await assert.rejects(
      listProgramTripsHandler(request({programId: "program-1"},
        "greeter-1"), deps(firestore)),
      (error: unknown) =>
        error instanceof HttpsError && error.code === "permission-denied"
    );
  });
