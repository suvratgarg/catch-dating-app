import assert from "node:assert/strict";
import test from "node:test";
import {randomUUID} from "node:crypto";
import {initializeApp, deleteApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {baseSeed, request, now} from "../shared/testing/programFixtures";
import {listProgramGuestsHandler, upsertProgramGuestHandler,
  upsertProgramHouseholdHandler} from "./programGuests";

const enabled = Boolean(process.env.FIRESTORE_EMULATOR_HOST);

test("Firestore paginates equal names and serializes household moves",
  {skip: !enabled}, async () => {
    const id = randomUUID();
    const app = initializeApp({projectId: "demo-catch-rules"}, id);
    const db = getFirestore(app);
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
      await Promise.all(refs.map((ref) => ref.delete()));
      await db.terminate();
      await deleteApp(app);
    }
  });
