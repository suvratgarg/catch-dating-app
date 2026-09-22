import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";

import {
  fetchFlightStatus,
  normalizeFlightNumber,
  FlightStatusSnapshot,
} from "./aeroDataBox";
import {
  applyFlightSnapshot,
  flightRefreshTier,
  nextFlightRefreshAt,
  refreshDueFlightLegs,
  refreshTravelLeg,
} from "./flightRefresh";
import {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";

const ts = (millis: number) => admin.firestore.Timestamp.fromMillis(millis);
const NOW = 1_800_000_000_000;

function leg(overrides: Partial<ProgramTravelLegDocument> = {}):
  ProgramTravelLegDocument {
  return {
    programId: "program-1",
    organizerId: "org-1",
    guestId: "guest-1",
    partyId: null,
    kind: "inbound",
    flightNumber: "AI847",
    carrierCode: "AI",
    originIata: "BOM",
    destinationIata: "DEL",
    scheduledArrivalAt: ts(NOW + 2 * 60 * 60 * 1000),
    estimatedArrivalAt: null,
    actualArrivalAt: null,
    flightStatus: "scheduled",
    flightInstanceId: null,
    arrivalTerminal: null,
    flightRefreshedAt: null,
    flightNextRefreshAt: null,
    international: null,
    pickupPointId: "pickup-1",
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
    createdAt: ts(NOW - 1000),
    updatedAt: ts(NOW - 1000),
    revision: 3,
    ...overrides,
  } as ProgramTravelLegDocument;
}

function snapshot(overrides: Partial<FlightStatusSnapshot> = {}):
  FlightStatusSnapshot {
  return {
    status: "enroute",
    scheduledArrivalMillis: NOW + 2 * 60 * 60 * 1000,
    estimatedArrivalMillis: NOW + 2 * 60 * 60 * 1000 + 600_000,
    actualArrivalMillis: null,
    arrivalTerminal: "3",
    baggageBelt: "4",
    providerUpdatedAtMillis: NOW - 30_000,
    ...overrides,
  };
}

import {FakeFirestore as MiniFirestore, type FakeData} from
  "../shared/testing/programFirestore";

test("normalizeFlightNumber strips separators and uppercases", () => {
  assert.equal(normalizeFlightNumber("AI-847"), "AI847");
  assert.equal(normalizeFlightNumber("6e 2041"), "6E2041");
});

test("fetchFlightStatus maps provider fields to a normalized snapshot",
  async () => {
    const seen: string[] = [];
    const result = await fetchFlightStatus({
      flightNumber: "AI-847",
      dateLocal: "2026-02-14",
      apiKey: "key",
      fetchImpl: async (url) => {
        seen.push(url);
        return {
          status: 200,
          json: async () => [{
            number: "AI 847",
            status: "Delayed",
            lastUpdatedUtc: "2026-02-14T09:00:00Z",
            arrival: {
              terminal: "3",
              baggageBelt: "7",
              scheduledTime: {utc: "2026-02-14T10:00:00Z"},
              revisedTime: {utc: "2026-02-14T10:40:00Z"},
            },
          }],
        };
      },
    });
    assert.ok(seen[0].includes("/flights/number/AI847/2026-02-14"));
    assert.equal(result?.status, "delayed");
    assert.equal(result?.arrivalTerminal, "3");
    assert.equal(result?.estimatedArrivalMillis,
      Date.parse("2026-02-14T10:40:00Z"));
    assert.equal(result?.actualArrivalMillis, null);
  });

test("fetchFlightStatus returns null on empty or missing results",
  async () => {
    for (const status of [204, 404]) {
      const result = await fetchFlightStatus({
        flightNumber: "XX1", dateLocal: "2026-02-14", apiKey: "key",
        fetchImpl: async () => ({status, json: async () => []}),
      });
      assert.equal(result, null);
    }
    const empty = await fetchFlightStatus({
      flightNumber: "XX1", dateLocal: "2026-02-14", apiKey: "key",
      fetchImpl: async () => ({status: 200, json: async () => []}),
    });
    assert.equal(empty, null);
  });

test("flightRefreshTier keys cadence to arrival proximity", () => {
  const base = leg();
  assert.equal(flightRefreshTier(base, NOW), "hot");
  assert.equal(
    flightRefreshTier(leg({scheduledArrivalAt: ts(NOW + 12 * 3600_000)}),
      NOW),
    "warm");
  assert.equal(
    flightRefreshTier(leg({scheduledArrivalAt: ts(NOW + 48 * 3600_000)}),
      NOW),
    "cold");
  assert.equal(
    flightRefreshTier(leg({actualArrivalAt: ts(NOW - 1000)}), NOW),
    "settled");
  assert.equal(flightRefreshTier(leg({readiness: "arrived"}), NOW),
    "settled");
  assert.equal(flightRefreshTier(leg({flightNumber: null}), NOW),
    "settled");
});

test("nextFlightRefreshAt returns null for ground transport legs", () => {
  assert.equal(nextFlightRefreshAt(null, ts(NOW), new Date(NOW)), null);
  assert.ok(nextFlightRefreshAt("AI847", ts(NOW + 48 * 3600_000),
    new Date(NOW)));
});

test("applyFlightSnapshot updates timing and terminal", () => {
  const patch = applyFlightSnapshot(leg(), snapshot(), NOW);
  assert.equal(patch.flightStatus, "enroute");
  assert.equal(patch.arrivalTerminal, "3");
  assert.equal(patch.estimatedArrivalAt!.toMillis(),
    NOW + 2 * 3600_000 + 600_000);
});

test("a stale provider response cannot un-land an observed arrival", () => {
  const landed = leg({
    actualArrivalAt: ts(NOW - 600_000),
    flightStatus: "landed",
  });
  const patch = applyFlightSnapshot(landed,
    snapshot({status: "enroute", actualArrivalMillis: null}), NOW);
  assert.equal(patch.flightStatus, "landed");
  assert.equal(patch.actualArrivalAt, undefined);
});

test("cancellation propagates only before an observed landing", () => {
  const flying = leg();
  const cancelled = applyFlightSnapshot(flying,
    snapshot({status: "cancelled"}), NOW);
  assert.equal(cancelled.flightStatus, "cancelled");

  const landed = leg({actualArrivalAt: ts(NOW - 600_000)});
  const patch = applyFlightSnapshot(landed,
    snapshot({status: "cancelled"}), NOW);
  assert.equal(patch.flightStatus, "landed");
});

test("provider runway time lands a leg and settles the refresh cursor",
  async () => {
    const firestore = new MiniFirestore({
      "programTravelLegs/leg-1": leg() as unknown as FakeData,
      "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
    });
    const outcome = await refreshTravelLeg(
      firestore as never, "leg-1", {
        now: () => new Date(NOW),
        apiKey: () => "key",
        fetchStatus: async () => snapshot({
          status: "landed",
          actualArrivalMillis: NOW - 300_000,
        }),
      });
    assert.equal(outcome, "updated");
    const stored = firestore.docs.get("programTravelLegs/leg-1")! as unknown as
      ProgramTravelLegDocument;
    assert.equal(stored.flightStatus, "landed");
    assert.equal(stored.actualArrivalAt!.toMillis(), NOW - 300_000);
    assert.equal(stored.flightNextRefreshAt, null);
  });

test("a provider miss backs off without touching leg timing", async () => {
  const firestore = new MiniFirestore({
    "programTravelLegs/leg-1": leg() as unknown as FakeData,
    "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
  });
  const outcome = await refreshTravelLeg(firestore as never, "leg-1", {
    now: () => new Date(NOW),
    apiKey: () => "key",
    fetchStatus: async () => null,
  });
  assert.equal(outcome, "no-match");
  const stored = firestore.docs.get("programTravelLegs/leg-1")! as unknown as
    ProgramTravelLegDocument;
  assert.equal(stored.flightStatus, "scheduled");
  assert.equal(stored.estimatedArrivalAt, null);
  assert.equal(
    stored.flightNextRefreshAt!.toMillis(), NOW + 6 * 3600_000);
});

test("a provider failure retries on the backoff cursor", async () => {
  const firestore = new MiniFirestore({
    "programTravelLegs/leg-1": leg() as unknown as FakeData,
    "organizerPrograms/program-1": {},
  });
  const outcome = await refreshTravelLeg(firestore as never, "leg-1", {
    now: () => new Date(NOW),
    apiKey: () => "key",
    fetchStatus: async () => {
      throw new Error("provider down");
    },
  });
  assert.equal(outcome, "failed");
  const stored = firestore.docs.get("programTravelLegs/leg-1")! as unknown as
    ProgramTravelLegDocument;
  assert.equal(
    stored.flightNextRefreshAt!.toMillis(), NOW + 15 * 60_000);
});

test("the sweep only refreshes legs whose cursor is due", async () => {
  const firestore = new MiniFirestore({
    "programTravelLegs/due-1":
      leg({flightNextRefreshAt: ts(NOW - 1)}) as unknown as FakeData,
    "programTravelLegs/due-2":
      leg({flightNextRefreshAt: ts(NOW - 2)}) as unknown as FakeData,
    "programTravelLegs/future-1":
      leg({flightNextRefreshAt: ts(NOW + 3600_000)}) as
        unknown as FakeData,
    "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
  });
  const calls: string[] = [];
  const summary = await refreshDueFlightLegs(firestore as never, {
    now: () => new Date(NOW),
    apiKey: () => "key",
    fetchStatus: async ({flightNumber}) => {
      calls.push(flightNumber);
      return snapshot();
    },
  });
  assert.deepEqual(calls, ["AI847", "AI847"]);
  assert.equal(summary.updated, 2);
  const future = firestore.docs.get("programTravelLegs/future-1")! as unknown as
    ProgramTravelLegDocument;
  assert.equal(future.flightRefreshedAt, null);
});
