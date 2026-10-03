import {getEmulatorFirestore} from "../shared/testing/emulatorFirestore";
import assert from "node:assert/strict";
import test from "node:test";
import {randomUUID} from "node:crypto";
import {initializeApp, deleteApp} from "firebase-admin/app";
import {baseSeed, request, now} from "../shared/testing/programFixtures";
import {listProgramGuestsHandler, upsertProgramGuestHandler,
  upsertProgramHouseholdHandler} from "./programGuests";

import {upsertProgramStayHandler, upsertProgramRoomBlockHandler,
  getProgramHotelRoomsHandler} from "./programRooms";

import {Timestamp} from "firebase-admin/firestore";
import type {ProgramDataDeps} from "../shared/programDataDeps";
import {ProgramLodgingStore} from "./programLodgingStore";
import {canonicalLodgingSource, saveCanonicalLodgingConfig} from
  "./programLodgingConfig";
import {manageProgramLodgingHandler} from "./programLodgingApi";

const enabled = Boolean(process.env.FIRESTORE_EMULATOR_HOST);

test("Firestore paginates equal names and serializes household moves",
  {skip: !enabled}, async () => {
    const id = randomUUID();
    const app = initializeApp({projectId: "demo-catch-rules"}, id);
    const db = getEmulatorFirestore(app);
    const programId = `household-test-${id}`;
    const organizerId = `household-org-${id}`;
    const seed = baseSeed();
    const deps = {firestore: () => db, checkRateLimit: async () => undefined,
      now: () => now} as never;
    const guestIds = [0, 1, 2].map((i) => `${programId}-guest-${i}`);
    const firstHousehold = `${programId}-household-first`;
    const secondHousehold = `${programId}-household-second`;
    const refs = [db.doc(`organizers/${organizerId}`),
      db.doc(`organizerPrograms/${programId}`),
      ...guestIds.map((guestId) => db.doc(`programGuests/${guestId}`)),
      db.doc(`programHouseholds/${firstHousehold}`),
      db.doc(`programHouseholds/${secondHousehold}`)];
    try {
      await db.doc(`organizers/${organizerId}`)
        .set(seed["organizers/org-1"]);
      await db.doc(`organizerPrograms/${programId}`)
        .set({...seed["organizerPrograms/program-1"], organizerId});
      await Promise.all(guestIds.map((guestId) =>
        db.doc(`programGuests/${guestId}`).set({
          ...seed["programGuests/guest-1"], programId, organizerId,
          displayName: "Same Name",
        })));
      // Raw fixture values have no acquisition proof and stay restricted.
      const unassigned = await listProgramGuestsHandler(request({programId,
        limit: 1}, "manager-1"), deps);
      assert.deepEqual(unassigned.guests, []);
      assert.equal(unassigned.nextCursor, guestIds[0]);
      for (const guestId of guestIds) {
        const existing = (await db.doc(`programGuests/${guestId}`).get())
          .data()!;
        await upsertProgramGuestHandler(request({programId, guestId,
          displayName: "Same Name", expectedRevision: existing.revision,
        }, "manager-1"), deps);
      }
      const seen: string[] = [];
      let cursor: string | null = null;
      do {
        const page = await listProgramGuestsHandler(request({programId,
          limit: 1, ...(cursor ? {cursor} : {})}, "manager-1"), deps);
        seen.push(...page.guests.map((guest) => guest.guestId));
        cursor = page.nextCursor;
        assert.ok(seen.length <= guestIds.length);
      } while (cursor);
      assert.deepEqual(seen, guestIds);
      const makeHousehold = (householdId: string, memberGuestIds: string[]) =>
        upsertProgramHouseholdHandler(request({programId, householdId,
          label: "Family", primaryContactName: "Contact", memberGuestIds,
        }, "manager-1"), deps);
      await makeHousehold(firstHousehold, [guestIds[0]]);
      await makeHousehold(secondHousehold, []);
      const before = (await db.doc(`programGuests/${guestIds[0]}`).get())
        .data()!;
      const edit = (householdId: string | null) =>
        upsertProgramGuestHandler(request({programId, guestId: guestIds[0],
          displayName: "Same Name", expectedRevision: before.revision,
          householdId}, "manager-1"), deps);
      const results = await Promise.allSettled([
        edit(secondHousehold), edit(null),
      ]);
      assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
      const guest = (await db.doc(`programGuests/${guestIds[0]}`).get())
        .data()!;
      const households = await db.getAll(
        db.doc(`programHouseholds/${firstHousehold}`),
        db.doc(`programHouseholds/${secondHousehold}`));
      for (const household of households) {
        assert.equal(household.data()!.memberGuestIds.includes(guestIds[0]),
          guest.householdId === household.id);
      }
    } finally {
      for (const name of ["workspaceFieldAssertions",
        "workspaceFieldDecisions"]) {
        const rows = await db.collection(name)
          .where("programId", "==", programId).limit(100).get();
        await Promise.all(rows.docs.map((row) => row.ref.delete()));
      }
      await Promise.all(refs.map((ref) => ref.delete()));
      await db.terminate();
      await deleteApp(app);
    }
  });

// This suite is selected by the strict test:rules runner, so these races
// cannot silently lose recurring emulator coverage.
test("Firestore serializes room sharing and cross-hotel assignments",
  {skip: !enabled}, async () => {
    const id = randomUUID();
    const app = initializeApp({projectId: "demo-catch-rules"}, id);
    const db = getEmulatorFirestore(app);
    const programId = `rooms-${id}`;
    const organizerId = `rooms-org-${id}`;
    const seed = baseSeed();
    const deps = {firestore: () => db, checkRateLimit: async () => undefined,
      now: () => now} as never;
    const guests = [0, 1, 2, 3].map((i) => `${programId}-guest-${i}`);
    const hotels = [0, 1].map((i) => `${programId}-hotel-${i}`);
    const refs = [db.doc(`organizers/${organizerId}`),
      db.doc(`organizerPrograms/${programId}`),
      ...guests.map((guestId) => db.doc(`programGuests/${guestId}`)),
      ...hotels.map((hotelId) => db.doc(`programHotels/${hotelId}`))];
    try {
      await refs[0].set(seed["organizers/org-1"]);
      await refs[1].set({...seed["organizerPrograms/program-1"], organizerId});
      for (const guestId of guests) {
        await db.doc(`programGuests/${guestId}`).set({
          ...seed["programGuests/guest-1"], programId, organizerId,
        });
      }
      for (const hotelId of hotels) {
        await db.doc(`programHotels/${hotelId}`).set({
          ...seed["programHotels/hotel-1"], programId, organizerId,
        });
      }
      const assign = (guestId: string, hotelId: string,
        patch: Record<string, unknown> = {}) => upsertProgramStayHandler(
        request({programId, guestId, hotelId, ...patch}, "manager-1"), deps);
      // No inbound travel rows exist: lodging works independently.
      const crossHotel = await Promise.allSettled(hotels.map((hotelId) =>
        assign(guests[0], hotelId)));
      const booked = crossHotel.filter((r) => r.status === "fulfilled");
      assert.equal(booked.length, 1);
      const block = await upsertProgramRoomBlockHandler(request({
        programId, hotelId: hotels[0], label: "Verified twin", totalRooms: 1,
        maxOccupantsPerRoom: 2, heldForGroupIds: [],
        startsAtMillis: now.toMillis(),
        endsAtMillis: now.toMillis() + 3 * 86400000,
      }, "manager-1"), deps);
      const first = await assign(guests[1], hotels[0], {
        roomBlockId: block.entityId, roomLabel: "101",
      });
      const join = await Promise.allSettled(guests.slice(2).map((guestId) =>
        assign(guestId, hotels[0], {roomBlockId: block.entityId,
          shareWithStayId: first.entityId,
          shareWithStayRevision: first.revision})));
      assert.equal(join.filter((r) => r.status === "fulfilled").length, 1);
      const board = await getProgramHotelRoomsHandler(request({programId,
        hotelId: hotels[0]}, "manager-1"), deps);
      const occupied = board.roomBlocks.find((b) =>
        b.roomBlockId === block.entityId)!;
      assert.equal(occupied.assignedCount, 1);
      assert.equal(occupied.remainingRooms, 0);
      const roommates = board.stays.filter((s) =>
        s.roomBlockId === block.entityId);
      assert.equal(roommates.length, 2);
      assert.equal(new Set(roommates.map((s) => s.roomOccupancyId)).size, 1);
      await assert.rejects(assign(guests[1], hotels[0], {
        stayId: first.entityId, roomLabel: "Missing revision",
      }), (error: unknown) =>
        (error as {code: string}).code === "failed-precondition");
    } finally {
      for (const name of ["programStays", "programRoomBlocks"]) {
        const rows = await db.collection(name)
          .where("programId", "==", programId).limit(100).get();
        await Promise.all(rows.docs.map((row) => row.ref.delete()));
      }
      await Promise.all(refs.map((ref) => ref.delete()));
      await db.terminate();
      await deleteApp(app);
    }
  });

// Real Admin transactions, selected by the existing strict runner. Synthetic
// event fixtures have no flight records and never contact a guest/provider.
test("Firestore lodging commits one publication and rolls back prepared writes",
  {skip: !enabled}, async () => {
    const id = randomUUID();
    const app = initializeApp({projectId: "demo-catch-rules"}, id);
    const db = getEmulatorFirestore(app);
    const programId = `lodging-${id}`;
    const organizerId = `lodging-org-${id}`;
    const hotelId = `lodging-hotel-${id}`;
    const blockId = `lodging-block-${id}`;
    const guestIds = [0, 1].map((i) => `lodging-guest-${id}-${i}`);
    const seed = baseSeed();
    const scope = {programId, organizerId};
    const start = Date.parse("2026-10-01T00:00:00Z");
    const end = Date.parse("2026-10-03T00:00:00Z");
    const dependencies: ProgramDataDeps = {firestore: () => db,
      checkRateLimit: async () => undefined, now: () => now};
    const config = {revision: 1, ...scope,
      demand: guestIds.map((guestId) => ({guestId, startsAtMillis: start,
        endsAtMillis: end, beds: 1, requiredFeatures: []})),
      parties: [{id: "party", guestIds, confirmed: true, priority: 0,
        requiredRoomType: null, pin: null}], groupParents: [],
      rooms: [{id: "room", hotelId, zoneId: "wing", building: null,
        floor: "1", wing: null, roomType: "standard", beds: 2,
        maxOccupants: 2, verifiedFeatures: [], resourceIds: ["room"],
        position: null}], inventory: [{id: "unit", contractId: blockId,
        physicalRoomId: "room", provisional: null,
        availability: [{arrival: "2026-10-01", departure: "2026-10-03"}]}],
      labels: [{inventoryId: "unit", roomLabel: "101"}]};
    const fields = {demand: config.demand, parties: config.parties,
      groupParents: config.groupParents, rooms: config.rooms,
      inventory: config.inventory, labels: config.labels};
    const source = canonicalLodgingSource(dependencies);
    const store = new ProgramLodgingStore(dependencies, source);
    const roots = [db.doc(`organizers/${organizerId}`),
      db.doc(`organizerPrograms/${programId}`)];
    const collections = ["programGuests", "programHotels", "programRoomBlocks",
      "programStays", "programLodgingConfigs", "programLodgingSourceVersions",
      "programLodgingProposals", "programLodgingWorkflows",
      "programLodgingReceipts"];
    try {
      await roots[0].set(seed["organizers/org-1"]);
      await roots[1].set({...seed["organizerPrograms/program-1"], organizerId});
      for (const guestId of guestIds) {
        await db.doc(`programGuests/${guestId}`).set({
          ...seed["programGuests/guest-1"], ...scope});
      }
      await db.doc(`programHotels/${hotelId}`).set({
        ...seed["programHotels/hotel-1"], ...scope});
      await db.doc(`programRoomBlocks/${blockId}`).set({...scope, hotelId,
        label: "Synthetic block", roomType: "standard", totalRooms: 1,
        assignedCount: 0, maxOccupantsPerRoom: 2, heldForGroupIds: [],
        startsAt: Timestamp.fromMillis(start),
        endsAt: Timestamp.fromMillis(end),
        createdAt: now, updatedAt: now, revision: 1});
      await db.doc(`programLodgingConfigs/${programId}`).set(config);
      const configEdits = await Promise.allSettled([0, 1].map(() =>
        saveCanonicalLodgingConfig(dependencies, programId, "manager-1",
          fields, 1, [])));
      assert.equal(configEdits.filter((r) =>
        r.status === "fulfilled").length, 1);
      const rejected = configEdits.find((r) => r.status === "rejected");
      assert.ok(rejected?.status === "rejected" &&
        rejected.reason.code === "aborted" &&
        rejected.reason.message ===
          "Record changed since you loaded it. Reload and retry.",
      JSON.stringify(rejected?.status === "rejected" ?
        {code: rejected.reason.code, message: rejected.reason.message} :
        {status: "missing rejected contender"}));
      assert.equal((await db.doc(`programLodgingConfigs/${programId}`).get())
        .data()!.revision, 2);
      const review = await manageProgramLodgingHandler(request({programId,
        action: "preview"}, "manager-1"), dependencies);
      assert.equal(review.kind, "proposal");
      if (review.kind !== "proposal") throw new Error("Missing review");
      const proposal = review.proposal;
      assert.equal(proposal.placements.length, 1);
      await store.save(programId, "manager-1", proposal);
      await store.transition(programId, "manager-1", {proposalId: proposal.id,
        operationId: "approve", action: "approve", hotelId: null,
        expectedWorkflowRevision: 0});
      const command = {proposalId: proposal.id, operationId: "publish",
        action: "publishGuests" as const, hotelId: null,
        expectedWorkflowRevision: 1};
      // Wait for every contender before fixture teardown, including failures.
      const contenders = await Promise.allSettled([0, 1].map(() =>
        store.transition(programId, "manager-1", command)));
      assert.ok(contenders.every((r) => r.status === "fulfilled"),
        JSON.stringify(contenders.map((r) => r.status === "rejected" ?
          {status: r.status, code: r.reason.code, message: r.reason.message} :
          {status: r.status, replayed: r.value.replayed})));
      const applied = contenders.filter((r) => r.status === "fulfilled" &&
        !r.value.replayed);
      assert.equal(applied.length, 1);
      const stays = await db.collection("programStays")
        .where("programId", "==", programId).get();
      assert.equal(stays.size, 2);
      assert.equal(new Set(stays.docs.map((d) =>
        d.data().roomOccupancyId)).size, 1);
      assert.ok(stays.docs.every((d) => d.data().lodgingPartyId === "party" &&
        d.data().lodgingInventoryId === "unit"));
      assert.equal((await db.doc(`programRoomBlocks/${blockId}`).get())
        .data()!.assignedCount, 1);
      assert.equal((await db.doc(`programLodgingWorkflows/${programId}`).get())
        .data()!.workflow.revision, 2);
      const receipts = await db.collection("programLodgingReceipts")
        .where("programId", "==", programId).get();
      assert.equal(receipts.size, 2); // one approval and one publication
      assert.equal(receipts.docs.filter((d) =>
        d.data().receipt.operationId === "publish").length, 1);

      const next = await store.preview(programId, "manager-1");
      await store.save(programId, "manager-1", next);
      await store.transition(programId, "manager-1", {proposalId: next.id,
        operationId: "approve-next", action: "approve", hotelId: null,
        expectedWorkflowRevision: 2});
      const observedRefs = [db.doc(`programLodgingWorkflows/${programId}`),
        db.doc(`programLodgingSourceVersions/${programId}`),
        db.doc(`programRoomBlocks/${blockId}`), ...stays.docs.map((d) => d.ref),
        ...guestIds.map((g) => db.doc(`programGuests/${g}`))];
      const before = (await db.getAll(...observedRefs)).map((d) => d.data());
      const failing = new ProgramLodgingStore(dependencies, async (...args) => {
        const loaded = await source(...args);
        return {...loaded, publish: (p) => {
          loaded.publish(p);
          throw new Error("Injected failure after prepared native writes");
        }};
      });
      await assert.rejects(failing.transition(programId, "manager-1", {
        proposalId: next.id, operationId: "rollback", action: "publishGuests",
        hotelId: null, expectedWorkflowRevision: 3}), /Injected failure/);
      assert.deepEqual((await db.getAll(...observedRefs)).map((d) => d.data()),
        before);
      assert.equal((await db.collection("programLodgingReceipts")
        .where("programId", "==", programId).get()).size, 3);
      await db.doc(`programGuests/${guestIds[0]}`).update({
        displayName: "Changed during review"});
      await assert.rejects(store.save(programId, "manager-1", next), /Stale/);
    } finally {
      for (const name of collections) {
        const rows = await db.collection(name)
          .where("programId", "==", programId).limit(100).get();
        await Promise.all(rows.docs.map((row) => row.ref.delete()));
      }
      await Promise.all(roots.map((ref) => ref.delete()));
      await db.terminate();
      await deleteApp(app);
    }
  });
