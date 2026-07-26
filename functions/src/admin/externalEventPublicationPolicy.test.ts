import assert from "node:assert/strict";
import test from "node:test";
import {
  assertExternalEventOrganizerAuthority,
  assertMatchingPublicationReceipt,
  publicationInputHash,
  publicationReceiptId,
} from "./externalEventPublicationPolicy";

test("publication receipt ids are stable and action scoped", () => {
  assert.equal(
    publicationReceiptId("admin-1", "publish", "candidate:1:apply"),
    publicationReceiptId("admin-1", "publish", "candidate:1:apply")
  );
  assert.notEqual(
    publicationReceiptId("admin-1", "publish", "candidate:1:apply"),
    publicationReceiptId("admin-1", "takedown", "candidate:1:apply")
  );
});

test("publication input hashes ignore object property order", () => {
  assert.equal(
    publicationInputHash({a: 1, b: {c: 2}}),
    publicationInputHash({b: {c: 2}, a: 1})
  );
});

test("receipt key reuse with different input fails", () => {
  assert.throws(
    () => assertMatchingPublicationReceipt(
      {action: "publish", inputHash: "a", idempotencyKey: "same-key"},
      {action: "publish", inputHash: "b", idempotencyKey: "same-key"}
    ),
    (error) => (error as {code?: string}).code === "already-exists"
  );
});

test("external event authority enforces organizer market and capabilities",
  () => {
    const document = {
      canonicalHostId: "organizer-1",
      discovery: {citySlug: "mumbai", countryCode: "IN"},
      organizerCapabilities: {
        mode: "unclaimed_read_only",
        bookable: false,
        paymentsEnabled: false,
        waitlistEnabled: false,
        hostContactEnabled: false,
        claimable: true,
        reviewPolicy: "after_event_end",
      },
      booking: {
        catchBookingEnabled: false,
        catchPaymentsEnabled: false,
        catchReservationsEnabled: false,
        catchWaitlistEnabled: false,
      },
    };
    assert.doesNotThrow(() => assertExternalEventOrganizerAuthority(
      "event-1",
      document as never,
      "organizer-1",
      {
        locationMarketId: "in-mh-mumbai",
        appVisibility: "discoverable",
        ownership: {state: "programmatic"},
        claim: {state: "unclaimed"},
        supplyCapabilities: document.organizerCapabilities,
      }
    ));
    assert.throws(
      () => assertExternalEventOrganizerAuthority(
        "event-1",
        document as never,
        "organizer-1",
        {
          locationMarketId: "in-mp-indore",
          appVisibility: "discoverable",
          ownership: {state: "programmatic"},
          claim: {state: "unclaimed"},
          supplyCapabilities: document.organizerCapabilities,
        }
      ),
      (error) => (error as {code?: string}).code === "failed-precondition"
    );
  });
