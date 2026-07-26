import assert from "node:assert/strict";
import test from "node:test";
import {
  assertOrganizerCapability,
  organizerSupplyCapabilitiesFor,
  verifiedOrganizerSupplyCapabilities,
} from "./organizerSupplyCapabilities";

test("unclaimed organizers are read-only, claimable, and reviewable after end",
  () => {
    const capabilities = organizerSupplyCapabilitiesFor({
      ownershipState: "programmatic",
      claimState: "unclaimed",
    });
    assert.deepEqual(capabilities, {
      mode: "unclaimed_read_only",
      bookable: false,
      paymentsEnabled: false,
      waitlistEnabled: false,
      hostContactEnabled: false,
      claimable: true,
      reviewPolicy: "after_event_end",
    });
    assert.throws(
      () => assertOrganizerCapability(capabilities, "booking"),
      (error) => (error as {code?: string}).code === "failed-precondition"
    );
  });

test("claimed organizers receive the managed capability ceiling", () => {
  const capabilities = organizerSupplyCapabilitiesFor({
    ownershipState: "claimed",
    claimState: "claimed",
  });
  assert.equal(capabilities.mode, "claimed_managed");
  assert.equal(capabilities.bookable, true);
  assert.equal(capabilities.claimable, false);
  assert.doesNotThrow(
    () => assertOrganizerCapability(capabilities, "host_contact")
  );
});

test("stored capability broadening fails closed", () => {
  assert.throws(
    () => verifiedOrganizerSupplyCapabilities({
      ownership: {state: "programmatic"},
      claim: {state: "unclaimed"},
      supplyCapabilities: {
        mode: "unclaimed_read_only",
        bookable: true,
        paymentsEnabled: false,
        waitlistEnabled: false,
        hostContactEnabled: false,
        claimable: true,
        reviewPolicy: "after_event_end",
      },
    }),
    (error) => (error as {code?: string}).code === "failed-precondition"
  );
});

test("legacy organizers derive the same capability policy", () => {
  assert.equal(
    verifiedOrganizerSupplyCapabilities({
      ownership: {state: "programmatic"},
      claim: {state: "claimPending"},
    }).claimable,
    false
  );
});
