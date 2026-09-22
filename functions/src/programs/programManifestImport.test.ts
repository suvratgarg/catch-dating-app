import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {CallableRequest} from "firebase-functions/v2/https";

import {importProgramManifestHandler} from "./programManifestImport";
import {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";

const ts = (millis: number) => admin.firestore.Timestamp.fromMillis(millis);
const NOW = 1_800_000_000_000;

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(private readonly store: MiniFirestore,
    readonly path: string) {}
  async get() {
    const data = this.store.docs.get(this.path);
    return {exists: data !== undefined, data: () => data,
      id: this.path.split("/").pop()!};
  }
}

class MiniFirestore {
  readonly docs = new Map<string, FakeData>();
  constructor(seed: Record<string, FakeData>) {
    for (const [k, v] of Object.entries(seed)) this.docs.set(k, v);
  }
  doc(path: string) {
    return new FakeDocRef(this, path);
  }
  collection(path: string) {
    return {
      doc: (id?: string) =>
        new FakeDocRef(this, `${path}/${id ?? `auto-${this.docs.size}`}`),
      where: (field: string, op: string, value: unknown) => ({
        get: async () => {
          const prefix = `${path}/`;
          const docs = [] as Array<{id: string; data: () => FakeData}>;
          for (const [p, data] of this.docs) {
            if (!p.startsWith(prefix) ||
                p.slice(prefix.length).includes("/")) continue;
            if (op === "==" && data[field] === value) {
              docs.push({id: p.slice(prefix.length), data: () => data});
            }
          }
          return {docs};
        },
      }),
    };
  }
  batch() {
    const writes: Array<() => void> = [];
    return {
      set: (ref: FakeDocRef, data: FakeData) => {
        writes.push(() => this.docs.set(ref.path, {...data}));
      },
      commit: async () => {
        for (const write of writes) write();
      },
    };
  }
}

function seed(): Record<string, FakeData> {
  return {
    "organizerPrograms/program-1": {
      organizerId: "org-1", timezone: "Asia/Kolkata",
    },
    "organizers/org-1": {
      hostUserId: "manager-1",
      ownerUserId: "manager-1",
      hostUserIds: ["manager-1"],
      hostProfiles: [],
    },
    "programHotels/hotel-1": {
      programId: "program-1", organizerId: "org-1", name: "Taj Palace",
      active: true,
    },
    "programPickupPoints/pickup-1": {
      programId: "program-1", organizerId: "org-1", label: "DEL T3 Arrivals",
      kind: "airport", active: true,
    },
  };
}

function request(data: unknown, uid = "manager-1") {
  return {data, auth: {uid}} as CallableRequest<unknown>;
}

function deps(store: MiniFirestore) {
  return {
    firestore: () => store as unknown as FirebaseFirestore.Firestore,
    checkRateLimit: async () => undefined,
    now: () => ts(NOW),
  } as never;
}

const row = {
  displayName: "Rohan Sharma",
  phoneE164: "+919900001111",
  householdLabel: "Sharma Family",
  partyLabel: "Sharma party",
  flightNumber: "AI-847",
  originIata: "BOM",
  destinationIata: "DEL",
  scheduledArrivalAtMillis: NOW + 2 * 3600_000,
  pickupPointLabel: "DEL T3 Arrivals",
  destinationHotelName: "Taj Palace",
  passengers: 2,
  luggageUnits: 3,
};

test("preview plans writes without touching storage", async () => {
  const store = new MiniFirestore(seed());
  const response = await importProgramManifestHandler(request({
    programId: "program-1", mode: "preview",
    clientOperationId: "import-op-0001", rows: [row],
  }), deps(store));
  assert.equal(response.guestsCreated, 1);
  assert.equal(response.legsCreated, 1);
  assert.equal(response.householdsCreated, 1);
  assert.equal(response.partiesCreated, 1);
  assert.equal(store.docs.size, 4);
});

test("commit writes guests, legs, household, party and a receipt",
  async () => {
    const store = new MiniFirestore(seed());
    const response = await importProgramManifestHandler(request({
      programId: "program-1", mode: "commit",
      clientOperationId: "import-op-0001", rows: [row],
    }), deps(store));
    assert.equal(response.guestsCreated, 1);
    const guest = [...store.docs.entries()].find(([k]) =>
      k.startsWith("programGuests/"))!;
    const guestData = guest[1];
    assert.equal(guestData.displayName, "Rohan Sharma");
    const leg = [...store.docs.entries()].find(([k]) =>
      k.startsWith("programTravelLegs/"))![1] as unknown as
      ProgramTravelLegDocument;
    assert.equal(leg.flightNumber, "AI847");
    assert.equal(leg.destinationHotelId, "hotel-1");
    assert.equal(leg.pickupPointId, "pickup-1");
    assert.ok(leg.flightNextRefreshAt);
    const receipt = [...store.docs.entries()].find(([k]) =>
      k.includes("transportOperationReceipts/"))!;
    assert.ok(receipt[1].resultJson);
  });

test("commit replays the original result for the same operation id",
  async () => {
    const store = new MiniFirestore(seed());
    const args = {
      programId: "program-1", mode: "commit" as const,
      clientOperationId: "import-op-0001", rows: [row],
    };
    const first = await importProgramManifestHandler(
      request(args), deps(store));
    const docsAfterFirst = store.docs.size;
    const second = await importProgramManifestHandler(
      request(args), deps(store));
    assert.equal(second.alreadyApplied, true);
    assert.deepEqual(
      {...second, alreadyApplied: false},
      {...first, alreadyApplied: false});
    assert.equal(store.docs.size, docsAfterFirst);
  });

test("re-import updates the same guest and leg without duplicating",
  async () => {
    const store = new MiniFirestore(seed());
    const args = {
      programId: "program-1", mode: "commit" as const,
      rows: [row],
    };
    await importProgramManifestHandler(
      request({...args, clientOperationId: "import-op-0001"}), deps(store));
    const second = await importProgramManifestHandler(request({
      ...args, clientOperationId: "import-op-0002",
      rows: [{...row, externalReference: "crm-42",
        phoneE164: "+919900009999"}],
    }), deps(store));
    // No externalReference on the existing guest: falls back to
    // name+flight+day matching and updates rather than creating.
    assert.equal(second.guestsCreated, 0);
    assert.equal(second.guestsUpdated, 1);
    assert.equal(second.legsUpdated, 1);
    const guest = [...store.docs.values()].find((data) =>
      data.displayName === "Rohan Sharma")!;
    assert.equal(guest.phoneE164, "+919900009999");
    assert.equal(guest.externalReference, "crm-42");
  });

test("unknown pickup point and hotel names are row errors, not writes",
  async () => {
    const store = new MiniFirestore(seed());
    const response = await importProgramManifestHandler(request({
      programId: "program-1", mode: "commit",
      clientOperationId: "import-op-0001",
      rows: [{...row, pickupPointLabel: "Nowhere",
        destinationHotelName: "No hotel"}],
    }), deps(store));
    assert.equal(response.rowErrors.length, 2);
    assert.equal(response.guestsCreated, 0);
    assert.equal(store.docs.size, 5); // receipt only
  });

test("same-name rows without references are not merged", async () => {
  const store = new MiniFirestore(seed());
  const response = await importProgramManifestHandler(request({
    programId: "program-1", mode: "commit",
    clientOperationId: "import-op-0001",
    rows: [
      {...row, flightNumber: null, scheduledArrivalAtMillis: null},
      {...row, flightNumber: null, scheduledArrivalAtMillis: null},
    ],
  }), deps(store));
  assert.equal(response.guestsCreated, 1);
  assert.equal(response.rowErrors.length, 1);
  assert.match(response.rowErrors[0].message, /Duplicate/);
});

test("staff without coordinator duty cannot import", async () => {
  const store = new MiniFirestore({
    ...seed(),
    "programStaffGrants/program-1__greeter-1": {
      programId: "program-1", organizerId: "org-1", uid: "greeter-1",
      status: "active", duties: [{duty: "airportGreeter"}],
      expiresAt: ts(NOW + 3600_000),
    },
  });
  await assert.rejects(
    importProgramManifestHandler(request({
      programId: "program-1", mode: "commit",
      clientOperationId: "import-op-0001", rows: [row],
    }, "greeter-1"), deps(store)),
    (error: unknown) =>
      error instanceof Error && error.message.includes("programCoordinator"),
  );
});
