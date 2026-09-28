import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  buildRsvpTravelLegDoc,
  dedupeTravelBlocks,
  rsvpTravelBlockRejection,
  rsvpTravelLegId,
  type RsvpTravelBlockInput,
  type RsvpTravelLegContext,
} from "./rsvpTravelBlocks";

const NOW = admin.firestore.Timestamp.fromMillis(1_800_000_000_000);
const CTX: RsvpTravelLegContext = {
  programId: "program-1",
  organizerId: "org-1",
  householdId: "hh-1",
  now: NOW,
};

const block = (patch: Partial<RsvpTravelBlockInput> = {}):
  RsvpTravelBlockInput => ({
  guestId: "g-1",
  kind: "inbound",
  flightNumber: "UA123",
  carrierCode: "UA",
  originIata: "SFO",
  destinationIata: "DEL",
  scheduledArrivalAtMillis: 1_800_500_000_000,
  pickupPointId: null,
  destinationHotelId: "hotel-1",
  destinationLabel: null,
  passengers: 2,
  luggageUnits: 3,
  ...patch,
});

const existingLeg = (patch: Partial<ProgramTravelLegDocument> = {}):
  ProgramTravelLegDocument => ({
  programId: "program-1",
  organizerId: "org-1",
  guestId: "g-1",
  partyId: "party-9",
  kind: "inbound",
  flightNumber: "UA123",
  carrierCode: "UA",
  originIata: "SFO",
  destinationIata: "DEL",
  scheduledArrivalAt:
      admin.firestore.Timestamp.fromMillis(1_800_500_000_000),
  estimatedArrivalAt:
      admin.firestore.Timestamp.fromMillis(1_800_500_600_000),
  actualArrivalAt: null,
  flightStatus: "delayed",
  flightInstanceId: "inst-1",
  international: true,
  pickupPointId: "pickup-1",
  destinationHotelId: "hotel-1",
  destinationLabel: null,
  readiness: "expected",
  readyAt: null,
  claimedByUid: null,
  claimedAt: null,
  manualCurbAt: null,
  manualCurbNote: null,
  passengers: 4,
  luggageUnits: 5,
  requiredCapabilities: ["childSeat"],
  dedicatedVehicle: true,
  source: "formResponse",
  createdAt: admin.firestore.Timestamp.fromMillis(1_700_000_000_000),
  updatedAt: admin.firestore.Timestamp.fromMillis(1_700_000_000_000),
  revision: 7,
  arrivalTerminal: "T3",
  flightRefreshedAt:
      admin.firestore.Timestamp.fromMillis(1_799_000_000_000),
  flightNextRefreshAt:
      admin.firestore.Timestamp.fromMillis(1_800_100_000_000),
  flightAlertSubscriptionId: "sub-1",
  flightProviderUpdatedAt:
      admin.firestore.Timestamp.fromMillis(1_799_000_000_000),
  flightAlertFlightNumber: "UA123",
  flightAlertLease: {token: "lease-1",
    expiresAt: admin.firestore.Timestamp.fromMillis(
      1_900_000_000_000)},
  ...patch,
});

test("leg ids are deterministic per household, guest and kind", () => {
  assert.equal(rsvpTravelLegId("hh-1", "g-1", "inbound"),
    "rsvp_hh-1_g-1_inbound");
  assert.equal(rsvpTravelLegId("hh-1", "g-1", "outbound"),
    "rsvp_hh-1_g-1_outbound");
  assert.notEqual(rsvpTravelLegId("hh-2", "g-1", "inbound"),
    rsvpTravelLegId("hh-1", "g-1", "inbound"));
});

test("dedupe keeps the last block per guest and journey kind", () => {
  const deduped = dedupeTravelBlocks([
    block({guestId: "g-1", kind: "inbound", flightNumber: "UA111"}),
    block({guestId: "g-2", kind: "inbound", flightNumber: "UA222"}),
    block({guestId: "g-1", kind: "inbound", flightNumber: "UA999"}),
    block({guestId: "g-1", kind: "outbound", flightNumber: "UA777"}),
  ]);
  assert.equal(deduped.size, 3);
  assert.equal(deduped.get("g-1:inbound")!.flightNumber, "UA999");
  assert.equal(deduped.get("g-2:inbound")!.flightNumber, "UA222");
  assert.equal(deduped.get("g-1:outbound")!.flightNumber, "UA777");
  assert.equal(dedupeTravelBlocks(null).size, 0);
  assert.equal(dedupeTravelBlocks(undefined).size, 0);
});

test("blocks need a destination and a scheduled arrival", () => {
  assert.equal(rsvpTravelBlockRejection(block()), null);
  assert.equal(
    rsvpTravelBlockRejection(
      block({destinationHotelId: null, destinationLabel: null})),
    "missingDestination");
  assert.equal(
    rsvpTravelBlockRejection(
      block({destinationHotelId: null, destinationLabel: "  "})),
    "missingDestination");
  assert.equal(
    rsvpTravelBlockRejection(
      block({destinationHotelId: null,
        destinationLabel: "Private villa"})),
    null);
  assert.equal(
    rsvpTravelBlockRejection(block({scheduledArrivalAtMillis: null})),
    "arrivalRequired");
});

test("new legs default provenance, seats and journey state", () => {
  const doc = buildRsvpTravelLegDoc(
    block({passengers: null, luggageUnits: null, flightNumber: null}),
    CTX);
  assert.equal(doc.programId, "program-1");
  assert.equal(doc.organizerId, "org-1");
  assert.equal(doc.guestId, "g-1");
  assert.equal(doc.kind, "inbound");
  assert.equal(doc.source, "formResponse");
  assert.equal(doc.passengers, 1);
  assert.equal(doc.luggageUnits, 0);
  assert.deepEqual(doc.requiredCapabilities, []);
  assert.equal(doc.dedicatedVehicle, false);
  assert.equal(doc.readiness, "expected");
  assert.equal(doc.partyId, null);
  assert.equal(doc.flightStatus, "unknown");
  assert.equal(doc.createdAt, NOW);
  assert.equal(doc.updatedAt, NOW);
  assert.equal(doc.revision >= 1, true);
});

test("a flight block derives scheduled status and timestamps", () => {
  const doc = buildRsvpTravelLegDoc(block(), CTX);
  assert.equal(doc.flightStatus, "scheduled");
  assert.equal(doc.scheduledArrivalAt!.toMillis(), 1_800_500_000_000);
  assert.equal(doc.destinationHotelId, "hotel-1");
  assert.equal(doc.passengers, 2);
  assert.equal(doc.luggageUnits, 3);
});

test("resubmits preserve planner enrichment and party membership",
  () => {
    const prior = existingLeg();
    const doc = buildRsvpTravelLegDoc(
      block({flightNumber: "UA456", passengers: 3}), CTX, prior);
    // The block replaces itinerary fields.
    assert.equal(doc.flightNumber, "UA456");
    assert.equal(doc.passengers, 3);
    assert.equal(doc.luggageUnits, 3);
    // Ops routing survives even though the block does not name it.
    assert.equal(doc.pickupPointId, "pickup-1");
    // Planner-owned state always survives.
    assert.equal(doc.partyId, "party-9");
    assert.equal(doc.flightInstanceId, "inst-1");
    assert.equal(doc.arrivalTerminal, "T3");
    assert.equal(doc.flightAlertSubscriptionId, "sub-1");
    assert.equal(doc.flightAlertLease?.token, "lease-1");
    assert.deepEqual(doc.requiredCapabilities, ["childSeat"]);
    assert.equal(doc.dedicatedVehicle, true);
    assert.equal(doc.international, true);
    // Identity fields are never rewritten by a resubmit.
    assert.equal(doc.source, "formResponse");
    assert.equal(doc.createdAt, prior.createdAt);
    // nextRevision is lamport-style: max(prior + 1, now millis).
    assert.equal(doc.revision, NOW.toMillis());
    assert.equal(doc.updatedAt, NOW);
  });
