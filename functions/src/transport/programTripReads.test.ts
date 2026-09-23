import assert from "node:assert/strict";
import test from "node:test";
import {baseSeed, deps, now, request} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {listProgramTripsHandler} from "./programTripReads";

test("trip ledger does not expose another dispatch station's passengers",
  async () => {
    const seed = baseSeed();
    seed["programStaffGrants/program-1__dispatcher-1"].duties = [{
      duty: "transportDispatcher",
      expiresAtMillis: 1_800_086_400_000,
      pickupPointIds: ["pp-t3"], hotelIds: [],
    }];
    for (const [id, pickupPointId, legId] of [
      ["visible", "pp-t3", "leg-1"], ["hidden", "pp-t1", "leg-2"],
    ]) {
      seed[`transportTrips/${id}`] = {
        programId: "program-1", organizerId: "org-1", pickupPointId,
        destinationHotelId: "hotel-1", destinationLabel: "Taj Palace",
        vehicleClassId: "suv", plateDisplay: "DL1T4471", vendorId: null,
        vendorNameSnapshot: null, kind: "guestTransfer", status: "enRoute",
        passengerCount: 1, departedAt: now, arrivedAt: null, voidReason: null,
        legIds: [legId], revision: 1,
      };
    }
    const db = new FakeFirestore(seed);
    const result = await listProgramTripsHandler(
      request({programId: "program-1"}, "dispatcher-1"), deps(db));
    assert.deepEqual(result.trips.map((trip) => trip.tripId), ["visible"]);
    assert.deepEqual(result.trips[0].guestNames, ["Rohan Sharma"]);
  });

test("trip ledger applies each granted scope before unioning duties",
  async () => {
    const seed = baseSeed();
    seed["programStaffGrants/program-1__dispatcher-1"].duties = [{
      duty: "reconciliationViewer", expiresAtMillis: 1_800_086_400_000,
      pickupPointIds: ["pp-t3"], hotelIds: ["hotel-2"],
    }, {
      duty: "transportDispatcher",
      expiresAtMillis: 1_800_086_400_000,
      pickupPointIds: ["pp-t1"], hotelIds: [],
    }];
    for (const [id, pickupPointId, hotel] of [
      ["a", "pp-t3", "hotel-1"], ["b", "pp-t3", "hotel-2"],
      ["c", "pp-t1", "hotel-1"],
    ]) {
      seed[`transportTrips/${id}`] = {
        programId: "program-1", pickupPointId, destinationHotelId: hotel,
        legIds: [], departedAt: now,
      };
    }
    const result = await listProgramTripsHandler(
      request({programId: "program-1"}, "dispatcher-1"),
      deps(new FakeFirestore(seed)));
    assert.deepEqual(
      result.trips.map((trip) => trip.tripId).sort(), ["b", "c"]);
  });

test("a busy unassigned station cannot crowd assigned trips out of the page",
  async () => {
    const seed = baseSeed();
    seed["programStaffGrants/program-1__dispatcher-1"].duties = [{
      duty: "transportDispatcher",
      expiresAtMillis: 1_800_086_400_000,
      pickupPointIds: ["pp-t3"], hotelIds: [],
    }];
    for (let index = 0; index < 205; index++) {
      seed[`transportTrips/hidden-${index}`] = {
        programId: "program-1", pickupPointId: "pp-t1",
        destinationHotelId: "hotel-1", legIds: [], departedAt: now,
      };
    }
    seed["transportTrips/visible"] = {
      programId: "program-1", pickupPointId: "pp-t3",
      destinationHotelId: "hotel-1", legIds: [], departedAt: now,
    };
    const result = await listProgramTripsHandler(
      request({programId: "program-1"}, "dispatcher-1"),
      deps(new FakeFirestore(seed)));
    assert.deepEqual(result.trips.map((trip) => trip.tripId), ["visible"]);
  });
