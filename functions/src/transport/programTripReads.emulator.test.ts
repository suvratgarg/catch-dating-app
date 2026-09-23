import assert from "node:assert/strict";
import test from "node:test";
import {randomUUID} from "node:crypto";
import {initializeApp, deleteApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {baseSeed, request, now} from "../shared/testing/programFixtures";
import {getProgramHotelInboundHandler} from "./programTripReads";

const enabled = Boolean(process.env.FIRESTORE_EMULATOR_HOST);

test("Firestore hotel cursors retain timestamp ties and mixed readiness rows",
  {skip: !enabled}, async () => {
    const id = randomUUID();
    const app = initializeApp({projectId: "demo-catch-rules"}, id);
    const db = getFirestore(app);
    const programId = `hotel-test-${id}`;
    const organizerId = `hotel-org-${id}`;
    const hotelId = `hotel-${id}`;
    const seed = baseSeed();
    const deps = {firestore: () => db, checkRateLimit: async () => undefined,
      now: () => now} as never;
    const tripIds = [0, 1, 2].map((i) => `${programId}-trip-${i}`);
    const legIds = [0, 1, 2].map((i) => `${programId}-leg-${i}`);
    const refs = [db.doc(`organizers/${organizerId}`),
      db.doc(`organizerPrograms/${programId}`),
      db.doc(`programHotels/${hotelId}`),
      ...tripIds.map((tripId) => db.doc(`transportTrips/${tripId}`)),
      ...legIds.map((legId) => db.doc(`programTravelLegs/${legId}`))];
    const read = (cursors = {}) => getProgramHotelInboundHandler(request({
      programId, hotelId, limit: 1, ...cursors,
    }, "manager-1"), deps);
    try {
      const batch = db.batch();
      batch.set(refs[0], seed["organizers/org-1"]);
      batch.set(refs[1], {...seed["organizerPrograms/program-1"], organizerId});
      batch.set(refs[2], {...seed["programHotels/hotel-1"],
        programId, organizerId});
      for (let i = 0; i < 3; i++) {
        batch.set(db.doc(`transportTrips/${tripIds[i]}`), {
          programId, organizerId, destinationHotelId: hotelId,
          pickupPointId: "unused", departedAt: new Timestamp(now.seconds, 123),
          status: "enRoute", legIds: [], plateDisplay: `TEST ${i}`,
          vehicleClassId: "sedan", vendorNameSnapshot: null,
          passengerCount: 0, revision: 1,
        });
        batch.set(db.doc(`programTravelLegs/${legIds[i]}`), {
          ...seed["programTravelLegs/leg-1"], programId, organizerId,
          destinationHotelId: hotelId, guestId: `${programId}-guest-${i}`,
          readiness: i === 1 ? "ready" : "expected",
        });
      }
      await batch.commit();
      const first = await read();
      assert.equal(first.trips[0].tripId, tripIds[0]);
      assert.equal(first.expectedLegs[0].legId, legIds[0]);
      await db.doc(`transportTrips/${tripIds[0]}`).update({status: "arrived"});
      await db.doc(`programTravelLegs/${legIds[0]}`).delete();
      const second = await read({tripCursor: first.nextTripCursor,
        expectedCursor: first.nextExpectedCursor});
      assert.equal(second.trips[0].tripId, tripIds[1]);
      assert.equal(second.expectedLegs[0].legId, legIds[1]);
      const third = await read({tripCursor: second.nextTripCursor,
        expectedCursor: second.nextExpectedCursor});
      assert.equal(third.trips[0].tripId, tripIds[2]);
      assert.equal(third.expectedLegs[0].legId, legIds[2]);
      assert.equal(third.nextTripCursor, null);
      assert.equal(third.nextExpectedCursor, null);
    } finally {
      await Promise.all(refs.map((ref) => ref.delete()));
      await db.terminate();
      await deleteApp(app);
    }
  });
