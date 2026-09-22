import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";

import {FlightStatusSnapshot} from "./aeroDataBox";
import {
  createFlightSubscription,
  deleteFlightSubscription,
  FlightAlertAuthError,
  flightAlertCallbackUrl,
  flightAlertWebhookHandler,
  pushedFlights,
  syncLegAlertSubscription,
} from "./flightAlerts";
import {refreshTravelLeg} from "./flightRefresh";
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

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(private readonly firestore: MiniFirestore,
    readonly path: string) {}
  async get() {
    const data = this.firestore.docs.get(this.path);
    return {exists: data !== undefined, data: () => data,
      id: this.path.split("/").pop()!};
  }
  async update(data: FakeData) {
    const existing = this.firestore.docs.get(this.path);
    if (!existing) throw new Error(`missing ${this.path}`);
    this.firestore.docs.set(this.path, {...existing, ...data});
  }
}

class MiniFirestore {
  readonly docs = new Map<string, FakeData>();
  constructor(seed: Record<string, FakeData>) {
    for (const [k, v] of Object.entries(seed)) this.docs.set(k, v);
  }
  collection(path: string) {
    return {
      doc: (id: string) => new FakeDocRef(this, `${path}/${id}`),
    };
  }
}

function pushBody(overrides: Record<string, unknown> = {}) {
  return {
    flights: [{
      number: "AI 847",
      status: "Delayed",
      lastUpdatedUtc: new Date(NOW - 30_000).toISOString(),
      arrival: {
        terminal: "3",
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
  const flight = {status: "Delayed", arrival: {terminal: "3"}};
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
    assert.equal(stored.revision, 4);
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

test("hot legs subscribe once and settled legs release the subscription",
  async () => {
    const calls: string[] = [];
    const alerts = {
      apiKey: () => "k",
      secret: () => "s3cret",
      baseUrl: () => "https://example.test/hook",
      createSubscription: async (args: {
        flightNumber: string; callbackUrl: string;
      }) => {
        calls.push(`create:${args.flightNumber}`);
        assert.ok(args.callbackUrl.includes("key=s3cret"));
        assert.ok(args.callbackUrl.includes("leg=leg-1"));
        return "sub_7";
      },
      deleteSubscription: async (args: {subscriptionId: string}) => {
        calls.push(`delete:${args.subscriptionId}`);
      },
    };

    const firestore = new MiniFirestore({
      "programTravelLegs/leg-1": leg() as unknown as FakeData,
      "programTravelLegs/leg-2":
        leg({flightAlertSubscriptionId: "sub_7"}) as unknown as FakeData,
    });
    const legRef = new FakeDocRef(firestore, "programTravelLegs/leg-1");
    await syncLegAlertSubscription(
      legRef as never, leg(), "hot", "leg-1", alerts);
    assert.deepEqual(calls, ["create:AI847"]);
    assert.equal(
      (firestore.docs.get("programTravelLegs/leg-1") as FakeData)
        .flightAlertSubscriptionId,
      "sub_7");

    // Already-subscribed hot legs do not subscribe twice.
    await syncLegAlertSubscription(
      legRef as never,
      leg({flightAlertSubscriptionId: "sub_7"}), "hot", "leg-1", alerts);
    assert.deepEqual(calls, ["create:AI847"]);

    const leg2Ref = new FakeDocRef(firestore, "programTravelLegs/leg-2");
    await syncLegAlertSubscription(
      leg2Ref as never,
      leg({flightAlertSubscriptionId: "sub_7"}), "settled", "leg-2", alerts);
    assert.deepEqual(calls, ["create:AI847", "delete:sub_7"]);
    assert.equal(
      (firestore.docs.get("programTravelLegs/leg-2") as FakeData)
        .flightAlertSubscriptionId,
      null);
  });

test("a subscription create failure leaves the leg unsubscribed", async () => {
  const firestore = new MiniFirestore({
    "programTravelLegs/leg-1": leg() as unknown as FakeData,
  });
  const legRef = new FakeDocRef(firestore, "programTravelLegs/leg-1");
  await syncLegAlertSubscription(
    legRef as never, leg(), "hot", "leg-1", {
      apiKey: () => "k",
      secret: () => "s",
      baseUrl: () => "https://example.test",
      createSubscription: async () => {
        throw new Error("provider down");
      },
      deleteSubscription: async () => {},
    });
  const stored = firestore.docs.get("programTravelLegs/leg-1") as FakeData;
  assert.equal(stored.flightAlertSubscriptionId, null);
});

test("settling a leg inside the sweep releases its subscription", async () => {
  const calls: string[] = [];
  const firestore = new MiniFirestore({
    "programTravelLegs/leg-1": leg({
      actualArrivalAt: ts(NOW - 1000),
      flightStatus: "landed",
      flightAlertSubscriptionId: "sub_3",
    }) as unknown as FakeData,
  });
  const outcome = await refreshTravelLeg(firestore as never, "leg-1", {
    now: () => new Date(NOW),
    apiKey: () => "k",
    fetchStatus: async () => {
      throw new Error("settled legs must not be polled");
    },
    syncAlert: async (legRef, legDoc, tier, legId) => {
      assert.equal(tier, "settled");
      await syncLegAlertSubscription(legRef, legDoc, tier, legId, {
        apiKey: () => "k",
        secret: () => "s",
        baseUrl: () => "https://example.test",
        createSubscription: async () => null,
        deleteSubscription: async ({subscriptionId}) => {
          calls.push(`delete:${subscriptionId}`);
        },
      });
    },
  });
  assert.equal(outcome, "settled");
  assert.deepEqual(calls, ["delete:sub_3"]);
  const stored = firestore.docs.get("programTravelLegs/leg-1") as FakeData;
  assert.equal(stored.flightAlertSubscriptionId, null);
});

test("entering the hot window inside the sweep subscribes the leg",
  async () => {
    const calls: string[] = [];
    const firestore = new MiniFirestore({
      "programTravelLegs/leg-1": leg() as unknown as FakeData,
      "organizerPrograms/program-1": {timezone: "Asia/Kolkata"},
    });
    const snapshot: FlightStatusSnapshot = {
      status: "enroute",
      scheduledArrivalMillis: NOW + 2 * 3600_000,
      estimatedArrivalMillis: NOW + 2 * 3600_000,
      actualArrivalMillis: null,
      arrivalTerminal: "3",
      baggageBelt: null,
      providerUpdatedAtMillis: NOW - 10_000,
    };
    const outcome = await refreshTravelLeg(firestore as never, "leg-1", {
      now: () => new Date(NOW),
      apiKey: () => "k",
      fetchStatus: async () => snapshot,
      syncAlert: async (legRef, legDoc, tier, legId) => {
        assert.equal(tier, "hot");
        await syncLegAlertSubscription(legRef, legDoc, tier, legId, {
          apiKey: () => "k",
          secret: () => "s",
          baseUrl: () => "https://example.test",
          createSubscription: async () => {
            calls.push("create");
            return "sub_5";
          },
          deleteSubscription: async () => {},
        });
      },
    });
    assert.equal(outcome, "updated");
    assert.deepEqual(calls, ["create"]);
  });
