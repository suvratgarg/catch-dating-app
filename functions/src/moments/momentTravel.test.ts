import assert from "node:assert/strict";
import test from "node:test";
import type {AnchorFacts, MomentDefinition} from "./momentModel";
import {
  buildTravelContext,
  guestTravelLeadMinutes,
  haversineTravelMinutes,
  maxTravelLeadMinutes,
  type TravelEstimateContext,
} from "./momentTravel";

const venue = {latitude: 26.9, longitude: 75.8};
const nearHotel = {latitude: 26.95, longitude: 75.82};
const farHotel = {latitude: 27.5, longitude: 76.4};

const facts: AnchorFacts = {
  scope: {
    startsAtMillis: 1_000_000, endsAtMillis: 9_000_000,
    rsvpDeadlineAtMillis: null, revision: 1, messagingEnabled: true,
    cancelled: false,
  },
  functions: {
    sangeet: {
      startsAtMillis: 2_000_000, endsAtMillis: 2_400_000, revision: 7,
      cancelled: false, venueLocation: venue,
    },
    lawn: {
      startsAtMillis: 3_000_000, endsAtMillis: 3_400_000, revision: 2,
      cancelled: false, venueLocation: null,
    },
  },
  travelLegs: {},
  travel: {
    groupHotelIds: {sideA: "hotelFar", family: "hotelNear", unlinked: ""},
    hotelLocations: {hotelFar: farHotel, hotelNear: nearHotel},
  },
};

const moment: MomentDefinition = {
  momentId: "m1",
  scope: {kind: "program", programId: "prog"},
  name: "Sangeet starts soon",
  initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: 0,
  },
  sense: "audience",
  audience: {
    kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
    householdDedupe: true, travelTimeLead: true,
  },
  action: {kind: "push", notificationType: "organizerUpdate",
    preferenceKey: "eventReminders"},
  status: "armed",
  approval: {approvedByUid: "mgr", approvedAtMillis: 1},
  origin: "organizer",
  revision: 1,
};

/** Deterministic minutes: identity of the origin hotel, not the math. */
const cannedEstimator = (origin: {latitude: number}): number =>
  origin.latitude === nearHotel.latitude ? 5 : 40;

const ctx = (m = moment, f = facts): TravelEstimateContext | null =>
  buildTravelContext(m, f, cannedEstimator);

test("haversine estimate is the boarding buffer at zero distance and " +
  "grows with distance", () => {
  assert.equal(haversineTravelMinutes(venue, venue), 10);
  assert.ok(haversineTravelMinutes(nearHotel, venue) > 10);
  assert.ok(
    haversineTravelMinutes(farHotel, venue) >
      haversineTravelMinutes(nearHotel, venue));
});

test("buildTravelContext gates on program scope, kind, flag, and facts",
  () => {
    assert.ok(ctx() !== null);
    assert.equal(ctx({
      ...moment,
      scope: {kind: "event", eventId: "ev"},
    }), null);
    assert.equal(ctx({...moment, audience: {
      kind: "households", rsvpPendingOnly: false,
    }}), null);
    assert.equal(ctx({...moment, audience: {
      kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
      householdDedupe: true, travelTimeLead: false,
    }}), null);
    const noTravel: AnchorFacts = {...facts, travel: undefined};
    assert.equal(ctx(moment, noTravel), null);
  });

test("maxTravelLeadMinutes takes the farthest hotel-linked group", () => {
  assert.equal(maxTravelLeadMinutes(ctx()!), 40);
  // A function without a venue pin disables leads entirely.
  assert.equal(maxTravelLeadMinutes(ctx({
    ...moment,
    audience: {
      kind: "functionGuests", functionId: "lawn", rsvp: ["attending"],
      householdDedupe: true, travelTimeLead: true,
    },
  }, facts)!), 0);
  // No hotel-linked groups -> no lead.
  const bare: AnchorFacts = {...facts, travel: {
    groupHotelIds: {}, hotelLocations: {},
  }};
  assert.equal(maxTravelLeadMinutes(ctx(moment, bare)!), 0);
});

test("guestTravelLeadMinutes resolves the guest's hotel via their groups",
  () => {
    assert.equal(guestTravelLeadMinutes(["sideA"], ctx()!), 40);
    assert.equal(guestTravelLeadMinutes(["family"], ctx()!), 5);
    // Multi-hotel membership keeps the conservative (largest) estimate.
    assert.equal(
      guestTravelLeadMinutes(["sideA", "family"], ctx()!), 40);
    // No hotel link, dangling link, or missing coords -> nominal due.
    assert.equal(guestTravelLeadMinutes(["unlinked"], ctx()!), 0);
    assert.equal(guestTravelLeadMinutes([], ctx()!), 0);
    assert.equal(guestTravelLeadMinutes(["unknownGroup"], ctx()!), 0);
  });
