import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {
  eventVenueSessionPolicy,
  signEventVenueSessionToken,
  verifyEventVenueSessionToken,
  type EventVenueSessionClaims,
} from "./venueSessions";

const key = "0123456789abcdef0123456789abcdef";
const claims: EventVenueSessionClaims = {
  version: 1,
  eventId: "event-1",
  organizerId: "organizer-1",
  sessionId: "session_123456789012345678901234",
  issuedAtMillis: 1_000,
  expiresAtMillis: 91_000,
};

test("venue-session policy uses reviewed defaults and bounded overrides",
  () => {
    assert.deepEqual(eventVenueSessionPolicy({}), {
      ttlSeconds: 90,
      refreshSeconds: 60,
    });
    assert.deepEqual(eventVenueSessionPolicy({
      EVENT_VENUE_SESSION_TTL_SECONDS: "120",
      EVENT_VENUE_SESSION_REFRESH_SECONDS: "75",
    }), {
      ttlSeconds: 120,
      refreshSeconds: 75,
    });
    assert.deepEqual(eventVenueSessionPolicy({
      EVENT_VENUE_SESSION_TTL_SECONDS: "60",
      EVENT_VENUE_SESSION_REFRESH_SECONDS: "60",
    }), eventVenueSessionPolicy({}));
  }
);

test("valid signed venue session verifies for its exact event", () => {
  const token = signEventVenueSessionToken(claims, key);
  assert.deepEqual(verifyEventVenueSessionToken({
    token,
    eventId: "event-1",
    nowMillis: 90_000,
    key,
  }), claims);
});

test("expired venue session is rejected", () => {
  const token = signEventVenueSessionToken(claims, key);
  assert.throws(
    () => verifyEventVenueSessionToken({
      token,
      eventId: "event-1",
      nowMillis: 91_000,
      key,
    }),
    (error) => error instanceof HttpsError &&
      error.code === "failed-precondition" &&
      error.message.includes("expired")
  );
});

test("tampered or cross-event venue sessions are rejected", () => {
  const token = signEventVenueSessionToken(claims, key);
  const tampered = `${token.slice(0, -1)}x`;
  assert.throws(
    () => verifyEventVenueSessionToken({
      token: tampered,
      eventId: "event-1",
      nowMillis: 50_000,
      key,
    }),
    (error) => error instanceof HttpsError &&
      error.code === "failed-precondition"
  );
  assert.throws(
    () => verifyEventVenueSessionToken({
      token,
      eventId: "event-2",
      nowMillis: 50_000,
      key,
    }),
    (error) => error instanceof HttpsError &&
      error.code === "failed-precondition"
  );
});
