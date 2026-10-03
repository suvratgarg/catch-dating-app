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
