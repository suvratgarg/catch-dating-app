import assert from "node:assert/strict";
import {createHmac} from "node:crypto";
import test from "node:test";
import {
  mintHouseholdToken,
  verifyHouseholdToken,
} from "./rsvpLinkTokens";

const SECRET = "test-signing-secret";
const NOW = 1_700_000_000_000;
const PARAMS = {
  programId: "program-1",
  householdId: "household-1",
  expiresAtMillis: NOW + 60_000,
};

function signed(payloadJson: string): string {
  const encoded = Buffer.from(payloadJson, "utf8").toString("base64url");
  const signature = createHmac("sha256", SECRET).update(encoded)
    .digest("base64url");
  return `${encoded}.${signature}`;
}

test("minted tokens verify and round-trip their payload", () => {
  const token = mintHouseholdToken(PARAMS, SECRET);
  const result = verifyHouseholdToken(token, SECRET, NOW);
  assert.deepEqual(result, {ok: true, payload: {v: 1, ...PARAMS}});
});

test("payload carries only ids and expiry, never PII", () => {
  const token = mintHouseholdToken(PARAMS, SECRET);
  const [encoded] = token.split(".");
  const payload = JSON.parse(
    Buffer.from(encoded, "base64url").toString("utf8")) as
      Record<string, unknown>;
  assert.deepEqual(Object.keys(payload).sort(),
    ["expiresAtMillis", "householdId", "programId", "v"]);
});

test("verify rejects structurally malformed tokens", () => {
  for (const token of ["", "abc", "a.b.c", ".sig", "payload."]) {
    assert.deepEqual(verifyHouseholdToken(token, SECRET, NOW),
      {ok: false, reason: "malformed"});
  }
});

test("verify rejects signed payloads with a bad shape", () => {
  // A valid signature over non-JSON still fails closed.
  assert.deepEqual(
    verifyHouseholdToken(signed("not json"), SECRET, NOW),
    {ok: false, reason: "malformed"});
  const cases = [
    JSON.stringify({v: 2, ...PARAMS}),
    JSON.stringify({v: 1, householdId: "h", expiresAtMillis: 1}),
    JSON.stringify({v: 1, ...PARAMS, programId: "x".repeat(181)}),
    JSON.stringify({v: 1, ...PARAMS, expiresAtMillis: "soon"}),
    JSON.stringify([1, 2, 3]),
  ];
  for (const body of cases) {
    assert.deepEqual(verifyHouseholdToken(signed(body), SECRET, NOW),
      {ok: false, reason: "malformed"});
  }
});

test("verify rejects bad signatures", () => {
  const token = mintHouseholdToken(PARAMS, SECRET);
  const [encoded, signature] = token.split(".");
  // A forged payload under the original signature.
  const forged = `${Buffer.from(JSON.stringify({
    v: 1,
    programId: "program-1",
    householdId: "household-2",
    expiresAtMillis: PARAMS.expiresAtMillis,
  }), "utf8").toString("base64url")}.${signature}`;
  assert.deepEqual(verifyHouseholdToken(forged, SECRET, NOW),
    {ok: false, reason: "badSignature"});
  // A same-length but wrong signature exercises timingSafeEqual.
  const other = `${encoded}.${"a".repeat(signature.length)}`;
  assert.deepEqual(verifyHouseholdToken(other, SECRET, NOW),
    {ok: false, reason: "badSignature"});
  // The wrong secret never verifies.
  assert.deepEqual(verifyHouseholdToken(token, "other-secret", NOW),
    {ok: false, reason: "badSignature"});
});

test("verify enforces the exclusive expiry", () => {
  const token = mintHouseholdToken(PARAMS, SECRET);
  assert.equal(
    verifyHouseholdToken(token, SECRET, PARAMS.expiresAtMillis - 1).ok,
    true);
  assert.deepEqual(
    verifyHouseholdToken(token, SECRET, PARAMS.expiresAtMillis),
    {ok: false, reason: "expired"});
  assert.deepEqual(
    verifyHouseholdToken(token, SECRET, PARAMS.expiresAtMillis + 1),
    {ok: false, reason: "expired"});
});

test("mint refuses out-of-shape inputs", () => {
  assert.throws(
    () => mintHouseholdToken({...PARAMS, programId: ""}, SECRET),
    RangeError);
  assert.throws(() => mintHouseholdToken(
    {...PARAMS, householdId: "x".repeat(181)}, SECRET), RangeError);
  assert.throws(
    () => mintHouseholdToken({...PARAMS, expiresAtMillis: 0}, SECRET),
    RangeError);
  assert.throws(
    () => mintHouseholdToken({...PARAMS, expiresAtMillis: 1.5}, SECRET),
    RangeError);
  assert.throws(() => mintHouseholdToken(PARAMS, ""), RangeError);
});

test("verify refuses a missing secret or clock", () => {
  const token = mintHouseholdToken(PARAMS, SECRET);
  assert.throws(() => verifyHouseholdToken(token, "", NOW), RangeError);
  assert.throws(
    () => verifyHouseholdToken(token, SECRET, Number.NaN), RangeError);
});
