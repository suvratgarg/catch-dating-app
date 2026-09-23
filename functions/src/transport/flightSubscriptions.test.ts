import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {syncLegAlertSubscription, FlightAlertDeps,
  flightAlertCallbackUrl} from "./flightSubscriptions";
import {refreshTravelLeg} from "./flightRefresh";

const NOW = 1_800_000_000_000;
const ts = (millis: number) => admin.firestore.Timestamp.fromMillis(millis);
const path = "programTravelLegs/leg-1";
const base = {programId: "p1", flightNumber: "AI847", destinationIata: "DEL",
  scheduledArrivalAt: ts(NOW + 2 * 3600_000), flightStatus: "scheduled",
  readiness: "expected", actualArrivalAt: null, flightAlertSubscriptionId: null,
  flightNextRefreshAt: ts(NOW)};

type Subscription =
  Awaited<ReturnType<FlightAlertDeps["listSubscriptions"]>>[0];
function fixture(overrides = {}) {
  const store = new FakeFirestore({[path]: {...base, ...overrides}});
  const remote = new Map<string, Subscription>();
  let clock = NOW;
  let created = 0;
  const deleted: string[] = [];
  const alerts: FlightAlertDeps = {
    now: () => new Date(clock), apiKey: () => "key", secret: () => "secret",
    baseUrl: () => "https://example.test/flightAlertWebhook",
    listSubscriptions: async () => [...remote.values()],
    createSubscription: async ({flightNumber, callbackUrl}) => {
      const id = `sub-${++created}`;
      remote.set(id, {id, isActive: true,
        subject: {type: "FlightByNumber", id: flightNumber},
        subscriber: {type: "Webhook", id: callbackUrl}});
      return id;
    },
    deleteSubscription: async ({subscriptionId}) => {
      deleted.push(subscriptionId);
      remote.delete(subscriptionId);
    },
  };
  const sync = () => syncLegAlertSubscription(store.doc(path) as never, alerts);
  const data = () => store.getDoc(path)!;
  return {store, remote, alerts, sync, data, deleted,
    created: () => created, advance: () => {
      clock += 16 * 60_000;
    }};
}

test("hot legs subscribe once and landing releases the remote subscription",
  async () => {
    const f = fixture();
    await f.sync();
    await f.sync();
    assert.equal(f.created(), 1);
    f.store.updateDoc(path, {actualArrivalAt: ts(NOW - 1000)});
    await f.sync();
    assert.deepEqual(f.deleted, ["sub-1"]);
    assert.equal(f.data().flightAlertSubscriptionId, null);
    assert.equal(f.data().flightNextRefreshAt, null);
  });

test("concurrent sweep and manual refresh hold one subscription lease",
  async () => {
    const f = fixture();
    await Promise.all([f.sync(), f.sync()]);
    assert.equal(f.created(), 1);
    assert.equal(f.data().flightAlertSubscriptionId, "sub-1");
  });

test("failed deletion retains the id and a retryable cursor", async () => {
  const f = fixture();
  await f.sync();
  f.store.updateDoc(path, {actualArrivalAt: ts(NOW - 1000)});
  const original = f.alerts.deleteSubscription;
  f.alerts.deleteSubscription = async () => {
    throw new Error("offline");
  };
  await f.sync();
  assert.equal(f.data().flightAlertSubscriptionId, "sub-1");
  assert.ok(f.data().flightNextRefreshAt);
  f.advance();
  f.alerts.deleteSubscription = original;
  await f.sync();
  assert.equal(f.data().flightAlertSubscriptionId, null);
  assert.equal(f.remote.size, 0);
});

test("an uncertain create is recovered from the provider before retrying",
  async () => {
    const f = fixture();
    const original = f.alerts.createSubscription;
    f.alerts.createSubscription = async (args) => {
      await original(args);
      throw new Error("response lost");
    };
    await f.sync();
    assert.equal(f.data().flightAlertFlightNumber, "AI847");
    assert.equal(f.remote.size, 1);
    f.advance();
    f.alerts.createSubscription = original;
    await f.sync();
    assert.equal(f.created(), 1);
    assert.equal(f.data().flightAlertSubscriptionId, "sub-1");
  });

test("rebooking during create preserves cleanup and replaces the old subject",
  async () => {
    const f = fixture();
    const original = f.alerts.createSubscription;
    f.alerts.createSubscription = async (args) => {
      const id = await original(args);
      f.store.updateDoc(path, {flightNumber: "AI999"});
      return id;
    };
    await f.sync();
    assert.equal(f.data().flightAlertFlightNumber, "AI847");
    f.alerts.createSubscription = original;
    await f.sync();
    assert.deepEqual(f.deleted, ["sub-1"]);
    await f.sync();
    assert.equal(f.data().flightAlertFlightNumber, "AI999");
    assert.equal(f.remote.size, 1);
  });

test("a settled polling pass retries cleanup without polling the flight",
  async () => {
    const f = fixture();
    await f.sync();
    f.store.updateDoc(path, {actualArrivalAt: ts(NOW - 1000)});
    await refreshTravelLeg(f.store as never, "leg-1", {
      now: () => new Date(NOW), apiKey: () => "key",
      fetchStatus: async () => {
        throw new Error("must not poll");
      },
      syncAlert: async (ref) => syncLegAlertSubscription(ref, f.alerts),
    });
    assert.equal(f.remote.size, 0);
    assert.equal(f.data().flightNextRefreshAt, null);
  });

test("callback secret rotation removes the old provider subscription",
  async () => {
    const f = fixture();
    await f.sync();
    f.alerts.secret = () => "rotated";
    await f.sync();
    assert.equal(f.remote.size, 1);
    assert.deepEqual(f.deleted, ["sub-1"]);
    assert.equal([...f.remote.values()][0].subscriber.id,
      flightAlertCallbackUrl(f.alerts.baseUrl(), "rotated", "leg-1"));
  });
