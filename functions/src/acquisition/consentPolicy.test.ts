import {strict as assert} from "node:assert";
import {test} from "node:test";
import {
  hasCurrentHostConsent, hostConsentKey, hostMetaDispatchDecision,
  HOST_ATTRIBUTION_LIFETIME_MS, HOST_META_DELIVERY_LIFETIME_MS,
  newHostConsentAuthority, parseHostConsentChoice,
  type HostConsentChoice, type HostMetaDispatchState,
} from "./consentPolicy";

const now = 1792512000000;
const choice: HostConsentChoice = {version: 1,
  purpose: "host_acquisition_measurement", analytics: true,
  advertising: true, chosenAt: now};
const state: HostMetaDispatchState = {
  eventId: `host_lead_${now}_12345678-1234-4567-8123-123456789012`,
  acceptedAt: now, attempts: 0, nextAttemptAt: now, status: "pending",
};

test("old intake consent and ambiguous purpose cannot authorize sends", () => {
  for (const value of [null, [], {analytics: true, marketing: true},
    {...choice, version: 4}, {...choice, purpose: "consumer"},
    {...choice, advertising: "true"}, {...choice, email: "sentinel"},
    {...choice, chosenAt: now + 1}, {...choice, chosenAt: now - 300001},
    {...choice, analytics: false}]) {
    assert.equal(parseHostConsentChoice(value, now), null);
  }
  assert.deepEqual(parseHostConsentChoice(choice, now), choice);
});

test("capability hashes use domain separation and bounded input", () => {
  const capability = "a".repeat(64);
  assert.match(hostConsentKey(capability)!, /^[a-f0-9]{64}$/u);
  assert.notEqual(hostConsentKey(capability), capability);
  assert.notEqual(hostConsentKey(capability), hostConsentKey("b".repeat(64)));
  for (const value of [null, "a".repeat(63), "A".repeat(64), "secret/email"]) {
    assert.equal(hostConsentKey(value), null);
  }
});

test("permission expiry cannot be extended by retries", () => {
  const grant = newHostConsentAuthority(choice, now + 1000);
  assert.equal(grant.expiresAt, now + HOST_ATTRIBUTION_LIFETIME_MS);
  assert.equal(hasCurrentHostConsent(grant, now + 1000, "advertising"), true);
  assert.equal(hasCurrentHostConsent(grant, grant.expiresAt, "advertising"),
    false);
  assert.equal(hasCurrentHostConsent({...grant, expiresAt: grant.expiresAt + 1},
    now + 1000, "advertising"), false);
  assert.equal(hasCurrentHostConsent(grant, now - 1, "advertising"), false);
});

test("analytics-only, revocation and malformed server rows fail closed", () => {
  const grant = newHostConsentAuthority(choice, now);
  assert.equal(hasCurrentHostConsent({...grant, advertising: false}, now,
    "analytics"), true);
  for (const candidate of [{...grant, advertising: false},
    {...grant, revokedAt: now}, {...grant, revokedAt: undefined},
    {...grant, acceptedAt: now + 1}, {...grant, version: 2},
    {...grant, chosenAt: NaN}, {...grant, expiresAt: Infinity}]) {
    assert.equal(hasCurrentHostConsent(candidate, now, "advertising"), false);
  }
});

test("disabled gate does not inspect consent or queued private context", () => {
  const input = {enabled: false, now,
    get consent(): never {
      throw new Error("Must not read consent.");
    },
    get state(): never {
      throw new Error("Must not read a queued event.");
    }};
  assert.deepEqual(hostMetaDispatchDecision(input),
    {kind: "stop", reason: "disabled"});
});

test("dispatch requires permission and an accepted Host identity", () => {
  const consent = newHostConsentAuthority(choice, now);
  const decide = (overrides: Partial<HostMetaDispatchState>) =>
    hostMetaDispatchDecision({enabled: true, consent, now,
      state: {...state, ...overrides}});
  assert.deepEqual(decide({}), {kind: "dispatch"});
  assert.deepEqual(decide({nextAttemptAt: now + 1}), {kind: "wait"});
  const otherId = state.eventId.replace("host_lead", "catch");
  for (const overrides of [{eventId: otherId},
    {acceptedAt: now - 1}, {attempts: -1}, {attempts: 0.5}]) {
    assert.deepEqual(decide(overrides), {kind: "stop", reason: "invalid"});
  }
  assert.deepEqual(hostMetaDispatchDecision({enabled: true,
    consent: {...consent, revokedAt: now}, state, now}),
  {kind: "stop", reason: "consent"});
});

test("delivery never blindly retries accepted or uncertain sends", () => {
  const consent = newHostConsentAuthority(choice, now);
  for (const status of ["sending", "accepted", "unknown", "stopped"] as const) {
    assert.deepEqual(hostMetaDispatchDecision({enabled: true, consent, now,
      state: {...state, status}}),
    {kind: "stop", reason: "terminal_or_inflight"});
  }
  assert.deepEqual(hostMetaDispatchDecision({enabled: true, consent, now,
    state: {...state, attempts: 5}}),
  {kind: "stop", reason: "attempt_limit"});
  assert.deepEqual(hostMetaDispatchDecision({enabled: true, consent, state,
    now: now + HOST_META_DELIVERY_LIFETIME_MS}),
  {kind: "stop", reason: "expired"});
});
