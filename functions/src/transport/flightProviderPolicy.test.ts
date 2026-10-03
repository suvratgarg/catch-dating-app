import assert from "node:assert/strict";
import test from "node:test";
import {readFlightProviderPolicy, pilotAllowsProgram, reserveFlightPoll,
  runFlightPoll, type FlightProviderPolicy} from "./flightProviderPolicy";

const now = Date.parse("2026-10-03T12:00:00Z");
const policy: FlightProviderPolicy = {
  schema: "catch.flight-policy/v1", mode: "polling-pilot",
  programIds: ["pilot"], legIds: ["leg-1"],
  startsAt: "2026-10-03T11:00:00Z", expiresAt: "2026-10-03T13:00:00Z",
  maxRequestsPerDay: 2,
};

test("only an explicit bounded unexpired polling pilot is accepted", () => {
  assert.deepEqual(readFlightProviderPolicy(JSON.stringify(policy), now),
    policy);
  for (const value of [null, [], {}, {...policy, mode: "active"},
    {...policy, mode: "alerts"}, {...policy, extra: true},
    {...policy, programIds: []}, {...policy, programIds: ["*"]},
    {...policy, programIds: ["a", "a"]}, {...policy, legIds: []},
    {...policy, legIds: ["bad/id"]}, {...policy, maxRequestsPerDay: 101},
    {...policy, maxRequestsPerDay: 0}, {...policy, maxRequestsPerDay: 1.5},
    {...policy, expiresAt: "2026-10-05T00:00:00Z"}]) {
    assert.equal(readFlightProviderPolicy(JSON.stringify(value), now), null);
  }
  for (const raw of ["", " ", "not-json"]) {
    assert.equal(readFlightProviderPolicy(raw, now), null);
  }
  assert.equal(pilotAllowsProgram(policy, "other", now), false);
  assert.equal(pilotAllowsProgram(policy, "pilot", now), true);
  assert.equal(pilotAllowsProgram(policy, "pilot",
    Date.parse(policy.expiresAt)), false);
  assert.equal(pilotAllowsProgram(policy, "pilot",
    Date.parse(policy.startsAt) - 1), false);
});

// Serial transactional fake, shared across simulated callable/sweep instances.
function budgetStore() {
  const docs = new Map<string, Record<string, unknown>>();
  let pending = Promise.resolve();
  const db = {
    collection: () => ({doc: (id: string) => id}),
    runTransaction: (callback: (tx: unknown) => Promise<void>) => {
      const result = pending.then(() => callback({
        getAll: async (...ids: string[]) => ids.map((id) => ({
          exists: docs.has(id), data: () => docs.get(id),
        })),
        set: (id: string, value: Record<string, unknown>) =>
          docs.set(id, value),
      }));
      pending = result.catch(() => undefined);
      return result;
    },
  };
  return {db: db as unknown as FirebaseFirestore.Firestore, docs};
}

test("shared request budget admits one concurrent attempt and counts failures",
  async () => {
    const {db, docs} = budgetStore();
    const results = await Promise.allSettled([
      reserveFlightPoll(db, policy, now), reserveFlightPoll(db, policy, now),
    ]);
    assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
    // The reserved request may fail at the provider; no refund occurs.
    await reserveFlightPoll(db, policy, now + 1000);
    await assert.rejects(reserveFlightPoll(db, policy, now + 2000),
      {code: "resource-exhausted"});
    assert.equal([...docs.values()].find((v) =>
      v.action === "flightPollDay")?.count, 2);
    await assert.rejects(reserveFlightPoll(db, policy,
      Date.parse(policy.expiresAt)), {code: "failed-precondition"});
  });

test("corrupt budget state fails closed", async () => {
  const {db, docs} = budgetStore();
  docs.set(`flight-provider_flightPollDay_${Math.floor(now / 86_400_000)}`,
    {count: "invalid"});
  await assert.rejects(reserveFlightPoll(db, policy, now),
    {code: "resource-exhausted"});
});

test("a delayed reservation cannot dispatch after pilot expiry", async () => {
  let clock = now;
  let calls = 0;
  await assert.rejects(runFlightPoll(policy, () => clock, async () => {
    clock = Date.parse(policy.expiresAt);
  }, async () => {
    calls++;
  }), {code: "failed-precondition"});
  assert.equal(calls, 0);
  await runFlightPoll(policy, () => now, async () => undefined,
    async () => {
      calls++;
    });
  assert.equal(calls, 1);
});

for (const scenario of [
  {name: "second", start: "2026-10-03T12:00:00.900Z",
    end: "2026-10-03T12:00:01.100Z", maxRequestsPerDay: 2,
    startsAt: "2026-10-03T11:00:00Z", expiresAt: "2026-10-03T13:00:00Z"},
  {name: "midnight", start: "2026-10-03T23:59:59.900Z",
    end: "2026-10-04T00:00:00.100Z", maxRequestsPerDay: 1,
    startsAt: "2026-10-03T23:00:00Z", expiresAt: "2026-10-04T01:00:00Z"},
]) {
  test(`${scenario.name} rollover retains the old debit without dispatch`,
    async () => {
      const {db, docs} = budgetStore();
      const windowPolicy = {...policy,
        startsAt: scenario.startsAt, expiresAt: scenario.expiresAt,
        maxRequestsPerDay: scenario.maxRequestsPerDay};
      const start = Date.parse(scenario.start);
      let clock = start;
      const calls: number[] = [];
      const poll = async () => {
        calls.push(clock);
      };
      await assert.rejects(runFlightPoll(windowPolicy, () => clock,
        async (reservedAt) => {
          await reserveFlightPoll(db, windowPolicy, reservedAt);
          // Simulate a Firestore reservation completing in the next window.
          clock = Date.parse(scenario.end);
        }, poll), {code: "resource-exhausted",
        message: "Flight pilot reservation window elapsed."});
      assert.deepEqual(calls, []);
      assert.equal(docs.get(`flight-provider_flightPollSecond_${
        Math.floor(start / 1000)}`)?.count, 1);
      assert.equal(docs.get(`flight-provider_flightPollDay_${
        Math.floor(start / 86_400_000)}`)?.count, 1);

      // A new invocation may reserve in the new window; the old invocation
      // must not dispatch beside it. No internal retry or refund occurs.
      const fresh = () => runFlightPoll(windowPolicy, () => clock,
        (reservedAt) => reserveFlightPoll(db, windowPolicy, reservedAt), poll);
      await fresh();
      assert.deepEqual(calls, [Date.parse(scenario.end)]);
      await assert.rejects(fresh(), {code: "resource-exhausted"});
      clock += 1000;
      await assert.rejects(fresh(), {code: "resource-exhausted"});
      assert.equal(calls.length, 1);
    });
}

test("a backwards clock crossing a window cannot dispatch", async () => {
  const {db, docs} = budgetStore();
  let clock = now;
  let calls = 0;
  await assert.rejects(runFlightPoll(policy, () => clock,
    async (reservedAt) => {
      await reserveFlightPoll(db, policy, reservedAt);
      clock -= 1000;
    }, async () => {
      calls++;
    }), {code: "resource-exhausted"});
  assert.equal(calls, 0);
  assert.equal(docs.get(`flight-provider_flightPollDay_${
    Math.floor(now / 86_400_000)}`)?.count, 1);
});
