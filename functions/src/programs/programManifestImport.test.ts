import {validateProgramGuestDocument} from
  "../shared/generated/validators/programGuestDocument";
import {validateProgramTravelLegDocument} from
  "../shared/generated/validators/programTravelLegDocument";
import {validateProgramHouseholdDocument} from
  "../shared/generated/validators/programHouseholdDocument";
import {validateProgramTravelPartyDocument} from
  "../shared/generated/validators/programTravelPartyDocument";
import {validateTransportOperationReceiptDocument} from
  "../shared/generated/validators/transportOperationReceiptDocument";
import type {ValidateFunction} from "ajv";

const validators: Record<string, ValidateFunction> = {
  programGuests: validateProgramGuestDocument,
  programTravelLegs: validateProgramTravelLegDocument,
  programHouseholds: validateProgramHouseholdDocument,
  programTravelParties: validateProgramTravelPartyDocument,
  transportOperationReceipts: validateTransportOperationReceiptDocument,
};
import assert from "node:assert/strict";
import test from "node:test";

import {importProgramManifestHandler} from "./programManifestImport";
import {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";

import {seed, request, deps, row, ts, NOW} from "./programManifestFixture";
import {FakeFirestore as MiniFirestore} from
  "../shared/testing/programFirestore";

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
  assert.equal(response.guestsCreated, 0);
  assert.equal(response.rowErrors.length, 2);
  assert.match(response.rowErrors[1].message, /Duplicate/);
});

test("staff without coordinator duty cannot import", async () => {
  const store = new MiniFirestore({
    ...seed(),
    "programStaffGrants/program-1__greeter-1": {
      programId: "program-1", organizerId: "org-1", uid: "greeter-1",
      status: "active", duties: [{duty: "airportGreeter",
        pickupPointIds: [], hotelIds: [], expiresAtMillis: NOW + 3600_000}],
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

test("multirow imports create distinct people and complete group membership",
  async () => {
    const store = new MiniFirestore(seed());
    await importProgramManifestHandler(request({
      programId: "program-1", mode: "commit",
      clientOperationId: "import-multirow-0001",
      rows: [row, {...row, displayName: "Priya Sharma"}],
    }), deps(store));
    const entries = (collection: string) => [...store.docs.entries()]
      .filter(([key]) => key.startsWith(`${collection}/`));
    const guests = entries("programGuests");
    const legs = entries("programTravelLegs");
    assert.equal(guests.length, 2);
    assert.equal(legs.length, 2);
    const ids = guests.map(([key]) => key.split("/").pop()).sort();
    assert.deepEqual(entries("programHouseholds")[0][1].memberGuestIds, ids);
    assert.deepEqual(entries("programTravelParties")[0][1].legIds,
      entries("programTravelLegs").map(([path]) => path.split("/")[1]).sort());
    assert.deepEqual(legs.map(([, leg]) => leg.guestId).sort(), ids);
  });

test("different external references preserve distinct same-name guests",
  async () => {
    const store = new MiniFirestore(seed());
    for (const externalReference of ["person-A", "person-B"]) {
      await importProgramManifestHandler(request({
        programId: "program-1", mode: "commit",
        clientOperationId: `import-${externalReference}`,
        rows: [{...row, externalReference}],
      }), deps(store));
    }
    const guests = [...store.docs.entries()]
      .filter(([key]) => key.startsWith("programGuests/"));
    assert.deepEqual(guests.map(([, guest]) => guest.externalReference).sort(),
      ["person-A", "person-B"]);
    const ambiguous = await importProgramManifestHandler(request({
      programId: "program-1", mode: "preview",
      clientOperationId: "import-ambiguous", rows: [row],
    }), deps(store));
    assert.equal(ambiguous.guestsUpdated, 0);
    assert.match(ambiguous.rowErrors[0].message, /Ambiguous/);
  });

test("an existing name alone never authorizes a guest merge", async () => {
  const store = new MiniFirestore(seed());
  await importProgramManifestHandler(request({
    programId: "program-1", mode: "commit",
    clientOperationId: "import-original",
    rows: [row],
  }), deps(store));
  const result = await importProgramManifestHandler(request({
    programId: "program-1", mode: "commit",
    clientOperationId: "import-name-only",
    rows: [{displayName: row.displayName, phoneE164: "+919999999999"}],
  }), deps(store));
  assert.equal(result.guestsUpdated, 0);
  assert.equal(result.guestsCreated, 0);
  assert.match(result.rowErrors[0].message, /Name alone/);
});

test("failed later chunks resume without duplicating rows or losing groups",
  async () => {
    const store = new MiniFirestore(seed());
    const payload = {
      programId: "program-1", mode: "commit",
      clientOperationId: "resume-import-1",
      rows: Array.from({length: 65}, (_, index) => ({
        ...row, displayName: `Guest ${index}`,
        externalReference: `ref-${index}`,
        householdLabel: `Family ${index % 2}`, partyLabel: `Party ${index % 2}`,
      })),
    };
    store.beforeCommit = async () => {
      if (store.transactionCommits === 1) throw new Error("connection lost");
    };
    await assert.rejects(importProgramManifestHandler(request(payload),
      deps(store)), /connection lost/);
    const records = (collection: string) => [...store.docs.entries()]
      .filter(([key]) => key.startsWith(`${collection}/`));
    assert.equal(records("programGuests").length, 33);
    assert.equal(records("programTravelLegs").length, 33);
    assert.equal((records("programHouseholds")[0][1].memberGuestIds as string[])
      .length, 33);
    assert.equal(records("programTravelParties").length, 1);
    assert.equal((records("programTravelParties")[0][1].legIds as string[])
      .length, 33);
    assert.deepEqual(records("transportOperationReceipts")[0][1]
      .completedRowIndices, Array.from({length: 33}, (_, i) => i * 2));
    store.beforeCommit = undefined;
    const resumed = await importProgramManifestHandler(request(payload),
      deps(store));
    assert.equal(resumed.guestsCreated, 65);
    assert.equal(resumed.legsCreated, 65);
    assert.equal(resumed.householdsCreated, 2);
    assert.equal(resumed.partiesCreated, 2);
    assert.equal(records("programGuests").length, 65);
    assert.equal(records("programTravelLegs").length, 65);
    assert.equal((records("programHouseholds")[0][1].memberGuestIds as string[])
      .length, 33);
    const replay = await importProgramManifestHandler(request(payload),
      deps(store));
    assert.deepEqual(replay, {...resumed, alreadyApplied: true});
  });

test("concurrent retries commit a manifest only once", async () => {
  const store = new MiniFirestore(seed());
  const payload = {
    programId: "program-1", mode: "commit",
    clientOperationId: "concurrent-import",
    rows: [{...row, externalReference: "ref-one"}],
  };
  const results = await Promise.all([
    importProgramManifestHandler(request(payload), deps(store)),
    importProgramManifestHandler(request(payload), deps(store)),
  ]);
  assert.deepEqual(results.map((r) => r.alreadyApplied).sort(), [false, true]);
  assert.equal([...store.docs.keys()]
    .filter((key) => key.startsWith("programGuests/")).length, 1);
});

test("duplicate source rows across chunk boundaries remain row errors",
  async () => {
    const store = new MiniFirestore(seed());
    const rows = Array.from({length: 50}, (_, index) => ({
      ...row, displayName: `Guest ${index}`,
      externalReference: `ref-${index}`,
      householdLabel: `Family ${index}`, partyLabel: `Party ${index}`,
    }));
    rows.push({...rows[0], partyLabel: "Duplicate party"});
    const result = await importProgramManifestHandler(request({
      programId: "program-1", mode: "commit",
      clientOperationId: "boundary-import", rows,
    }), deps(store));
    assert.equal(result.guestsCreated, 50);
    assert.equal(result.rowErrors[0].index, 50);
  });

test("preview and chunked commit reject groups exceeding the contract limit",
  async () => {
    const store = new MiniFirestore(seed());
    const payload = {
      programId: "program-1", clientOperationId: "group-limit-import",
      rows: Array.from({length: 51}, (_, i) => ({
        ...row, displayName: `Guest ${i}`, externalReference: `ref-${i}`,
      })),
    };
    const preview = await importProgramManifestHandler(
      request({...payload, mode: "preview"}), deps(store));
    const committed = await importProgramManifestHandler(
      request({...payload, mode: "commit"}), deps(store));
    assert.deepEqual(committed, {...preview, mode: "commit"});
    assert.equal(committed.guestsCreated, 0);
    assert.equal(new Set(committed.rowErrors.map((issue) => issue.index))
      .size, 51);
    assert.equal(store.docs.size, 5); // receipt only
  });

test("imports refuse to replace dispatched journeys", async () => {
  const store = new MiniFirestore(seed());
  const payload = {programId: "program-1", mode: "commit", rows: [row]};
  await importProgramManifestHandler(request({...payload,
    clientOperationId: "dispatch-seed"}), deps(store));
  const [path, leg] = [...store.docs.entries()]
    .find(([key]) => key.startsWith("programTravelLegs/"))!;
  store.updateDoc(path, {readiness: "dispatched"});
  const response = await importProgramManifestHandler(request({...payload,
    rows: [{...row, passengers: 15}],
    clientOperationId: "dispatch-overwrite"}), deps(store));
  assert.match(response.rowErrors[0].message, /dispatched/);
  assert.deepEqual(store.getDoc(path), {...leg, readiness: "dispatched"});
});

test("scheduled ground legs re-import without duplicates", async () => {
  const store = new MiniFirestore(seed());
  const payload = {programId: "program-1", mode: "commit",
    rows: [{...row, externalReference: "ground-guest", flightNumber: null}]};
  await importProgramManifestHandler(request({...payload,
    clientOperationId: "ground-seed"}), deps(store));
  const response = await importProgramManifestHandler(request({...payload,
    clientOperationId: "ground-reimport"}), deps(store));
  assert.equal(response.legsCreated, 0);
  assert.equal(response.legsUpdated, 1);
});

test("ambiguous group labels never silently pick a household", async () => {
  const store = new MiniFirestore({...seed(),
    "programHouseholds/first": {programId: "program-1", label: "Sharma Family",
      memberGuestIds: []},
    "programHouseholds/second": {programId: "program-1", label: "Sharma Family",
      memberGuestIds: []},
  });
  const response = await importProgramManifestHandler(request({
    programId: "program-1", mode: "commit", rows: [row],
    clientOperationId: "ambiguous-household",
  }), deps(store));
  assert.equal(response.guestsCreated, 0);
  assert.match(response.rowErrors[0].message, /Ambiguous household/);
});


test("materialized imports satisfy the generated document contracts",
  async () => {
    const store = new MiniFirestore(seed());
    await importProgramManifestHandler(request({
      programId: "program-1", mode: "commit", rows: [row],
      clientOperationId: "contract-import",
    }), deps(store));
    for (const [path, data] of store.docs) {
      const collection = path.split("/")[0];
      const validate = validators[collection];
      if (validate) {
        assert.ok(validate(data),
          `${path}: ${JSON.stringify(validate.errors)}`);
      }
    }
  });

for (const partyLabel of [undefined, row.partyLabel]) {
  test(`import refuses party route change (label ${partyLabel})`, async () => {
    const store = new MiniFirestore({...seed(),
      "programHotels/other": {programId: "program-1", organizerId: "org-1",
        name: "Other Hotel", active: true},
    });
    await importProgramManifestHandler(request({programId: "program-1",
      mode: "commit", clientOperationId: "seed-party", rows: [row],
    }), deps(store));
    const changed = {...row, partyLabel, destinationHotelName: "Other Hotel"};
    for (const mode of ["preview", "commit"]) {
      const result = await importProgramManifestHandler(request({
        programId: "program-1", mode, clientOperationId: "change-party-route",
        rows: [changed],
      }), deps(store));
      assert.equal(result.legsUpdated, 0);
      assert.ok(result.rowErrors.some((issue) => /before changing route/
        .test(issue.message)));
    }
    assert.equal([...store.docs.entries()].find(([path]) =>
      path.startsWith("programTravelLegs/"))![1].destinationHotelId, "hotel-1");
  });
}

test("party-only imports create explicit unresolved journeys", async () => {
  const store = new MiniFirestore(seed());
  const result = await importProgramManifestHandler(request({
    programId: "program-1", mode: "commit", clientOperationId: "party-only",
    rows: [{displayName: "Asha", externalReference: "asha",
      partyLabel: "Arrival group"}],
  }), deps(store));
  assert.equal(result.legsCreated, 1);
  const leg = [...store.docs.entries()].find(([path]) =>
    path.startsWith("programTravelLegs/"))!;
  const party = [...store.docs.entries()].find(([path]) =>
    path.startsWith("programTravelParties/"))![1];
  assert.deepEqual(party.legIds, [leg[0].split("/")[1]]);
  assert.equal(leg[1].scheduledArrivalAt, null);
  assert.equal(leg[1].pickupPointId, null);
});

test("import rejects incompatible routes in a new party", async () => {
  const store = new MiniFirestore({...seed(),
    "programHotels/other": {programId: "program-1", organizerId: "org-1",
      name: "Other Hotel", active: true},
  });
  const payload = {programId: "program-1", clientOperationId: "split-party",
    rows: [row, {...row, displayName: "Other guest",
      destinationHotelName: "Other Hotel"}]};
  const preview = await importProgramManifestHandler(
    request({...payload, mode: "preview"}), deps(store));
  const commit = await importProgramManifestHandler(
    request({...payload, mode: "commit"}), deps(store));
  assert.deepEqual(commit.rowErrors, preview.rowErrors);
  assert.equal(commit.guestsCreated, 0);
  assert.equal(commit.rowErrors.length, 2);
  assert.match(commit.rowErrors[1].message, /same pickup and destination/);
});
