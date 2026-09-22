import {createFlightSubscription, deleteFlightSubscription,
  flightAlertCallbackUrl} from "./flightSubscriptions";
import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";

import {
  FlightAlertAuthError,
  flightAlertWebhookHandler,
  pushedFlights,
} from "./flightAlerts";
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
    flightAlertSubscriptionId: null,
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

import {FakeFirestore as MiniFirestore, type FakeData} from
  "../shared/testing/programFirestore";

function pushBody(overrides: Record<string, unknown> = {}) {
  return {
    flights: [{
      number: "AI 847",
      departure: {airport: {iata: "BOM"}},
      status: "Delayed",
      lastUpdatedUtc: new Date(NOW - 30_000).toISOString(),
      arrival: {
        airport: {iata: "DEL"}, terminal: "3",
        scheduledTime: {
          utc: new Date(NOW + 2 * 60 * 60 * 1000).toISOString(),
        },
        revisedTime: {
          utc: new Date(NOW + 2 * 60 * 60 * 1000 + 900_000).toISOString(),
        },
        ...overrides,
      },
    }],
  };
}

const webhookDeps = (firestore: MiniFirestore) => ({
  firestore: () => firestore as never as FirebaseFirestore.Firestore,
  secret: () => "s3cret",
  now: () => new Date(NOW),
});

test("flightAlertCallbackUrl embeds the secret and leg id", () => {
  const url = flightAlertCallbackUrl(
    "https://asia-south1-demo.cloudfunctions.net/flightAlertWebhook",
    "s3cret", "leg-1");
  assert.ok(url.includes("key=s3cret"));
  assert.ok(url.includes("leg=leg-1"));
});

test("createFlightSubscription posts the callback url and parses the id",
  async () => {
    let seenUrl = "";
    let seenBody = "";
    const id = await createFlightSubscription({
      flightNumber: "ai-847",
      callbackUrl: "https://example.test/hook?key=k&leg=l1",
      apiKey: "key",
      fetchImpl: async (url, init) => {
        seenUrl = url;
        seenBody = init.body ?? "";
        assert.equal(init.method, "POST");
        return {
          status: 200,
          json: async () => ({subscription: {id: "sub_9"}}),
        };
      },
    });
    assert.equal(id, "sub_9");
    assert.ok(seenUrl.includes("/subscriptions/webhook/FlightByNumber/AI847"));
    assert.ok(seenUrl.includes("useCredits=true"));
    const parsed = JSON.parse(seenBody) as {url?: string};
    assert.equal(parsed.url, "https://example.test/hook?key=k&leg=l1");
  });

test("createFlightSubscription returns null on a duplicate or miss",
  async () => {
    for (const status of [204, 404, 409]) {
      const id = await createFlightSubscription({
        flightNumber: "AI847", callbackUrl: "https://x.test", apiKey: "k",
        fetchImpl: async () => ({status, json: async () => null}),
      });
      assert.equal(id, null);
    }
  });

test("deleteFlightSubscription treats a missing subscription as done",
  async () => {
    await deleteFlightSubscription({
      subscriptionId: "sub_9", apiKey: "k",
      fetchImpl: async () => ({status: 404, json: async () => null}),
    });
  });

test("pushedFlights accepts the contract, array and bare shapes", () => {
  const flight = pushBody().flights[0];
  assert.equal(pushedFlights({flights: [flight]}).length, 1);
  assert.equal(pushedFlights({flight}).length, 1);
  assert.equal(pushedFlights([flight]).length, 1);
  assert.equal(pushedFlights(flight).length, 1);
  assert.equal(pushedFlights({nope: true}).length, 0);
  assert.equal(pushedFlights(null).length, 0);
});

test("the webhook rejects an unknown secret", async () => {
  const firestore = new MiniFirestore({
    "programTravelLegs/leg-1": leg() as unknown as FakeData,
  });
  await assert.rejects(
    flightAlertWebhookHandler(
      {key: "wrong", leg: "leg-1"}, pushBody(), webhookDeps(firestore)),
    FlightAlertAuthError,
  );
});

test("the webhook applies a matching push through the write-back guards",
  async () => {
    const firestore = new MiniFirestore({
      "programTravelLegs/leg-1": leg() as unknown as FakeData,
      "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
    });
    const outcome = await flightAlertWebhookHandler(
      {key: "s3cret", leg: "leg-1"}, pushBody(), webhookDeps(firestore));
    assert.equal(outcome, "applied");
    const stored = firestore.docs.get("programTravelLegs/leg-1")! as unknown as
      ProgramTravelLegDocument;
    assert.equal(stored.flightStatus, "delayed");
    assert.equal(stored.arrivalTerminal, "3");
    assert.equal(stored.estimatedArrivalAt!.toMillis(),
      NOW + 2 * 3600_000 + 900_000);
    assert.ok(stored.revision > 3);
  });

test("a push for a different service date does not touch the leg",
  async () => {
    const firestore = new MiniFirestore({
      "programTravelLegs/leg-1": leg() as unknown as FakeData,
      "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
    });
    const outcome = await flightAlertWebhookHandler(
      {key: "s3cret", leg: "leg-1"},
      pushBody({
        scheduledTime: {
          utc: new Date(NOW + 26 * 60 * 60 * 1000).toISOString(),
        },
      }),
      webhookDeps(firestore));
    assert.equal(outcome, "no-match");
    const stored = firestore.docs.get("programTravelLegs/leg-1")! as unknown as
      ProgramTravelLegDocument;
    assert.equal(stored.flightStatus, "scheduled");
    assert.equal(stored.revision, 3);
  });

test("a push for a different flight number is ignored", async () => {
  const firestore = new MiniFirestore({
    "programTravelLegs/leg-1": leg() as unknown as FakeData,
    "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
  });
  const body = pushBody();
  (body.flights[0] as {number: string}).number = "UK 955";
  const outcome = await flightAlertWebhookHandler(
    {key: "s3cret", leg: "leg-1"}, body, webhookDeps(firestore));
  assert.equal(outcome, "no-match");
});

test("a push cannot un-land an already landed leg", async () => {
  const landed = leg({
    actualArrivalAt: ts(NOW - 600_000),
    flightStatus: "landed",
  });
  const firestore = new MiniFirestore({
    "programTravelLegs/leg-1": landed as unknown as FakeData,
    "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
  });
  const outcome = await flightAlertWebhookHandler(
    {key: "s3cret", leg: "leg-1"}, pushBody(), webhookDeps(firestore));
  assert.equal(outcome, "applied");
  const stored = firestore.docs.get("programTravelLegs/leg-1")! as unknown as
    ProgramTravelLegDocument;
  assert.equal(stored.flightStatus, "landed");
  assert.equal(stored.actualArrivalAt!.toMillis(), NOW - 600_000);
});

test("missing or malformed pushes answer without writing", async () => {
  const firestore = new MiniFirestore({
    "programTravelLegs/leg-1": leg() as unknown as FakeData,
    "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
  });
  assert.equal(
    await flightAlertWebhookHandler(
      {key: "s3cret", leg: "leg-1"}, null, webhookDeps(firestore)),
    "no-match");
  assert.equal(
    await flightAlertWebhookHandler(
      {key: "s3cret"}, pushBody(), webhookDeps(firestore)),
    "no-match");
  assert.equal(
    await flightAlertWebhookHandler(
      {key: "s3cret", leg: "gone"}, pushBody(), webhookDeps(firestore)),
    "missing-leg");
});


test("landing pushes keep a scheduler cursor until subscriptions are released",
  async () => {
    const firestore = new MiniFirestore({
      "programTravelLegs/leg-1": leg({flightAlertSubscriptionId: "sub-live",
        flightAlertFlightNumber: "AI847"}) as unknown as FakeData,
    });
    const body = pushBody({runwayTime:
      {utc: new Date(NOW - 1000).toISOString()}});
    body.flights[0].status = "Arrived";
    assert.equal(await flightAlertWebhookHandler(
      {key: "s3cret", leg: "leg-1"}, body, webhookDeps(firestore)), "applied");
    const stored = firestore.getDoc("programTravelLegs/leg-1")!;
    assert.equal(stored.flightStatus, "landed");
    assert.equal(stored.flightAlertSubscriptionId, "sub-live");
    assert.ok(stored.flightNextRefreshAt);
  });
