import assert from "node:assert/strict";
import test from "node:test";
import type {EntitlementSkuCatalog, SkuLimits} from "./entitlementPolicy";
import {
  disallowedCapabilities,
  evaluateProgramUsage,
  momentsWithinFunctionCeiling,
  resolveProgramCeiling,
} from "./programLimits";

const limits: SkuLimits = {
  guests: 150,
  functions: 5,
  staffAssignments: 10,
  momentsPerFunction: 3,
};

const catalog: EntitlementSkuCatalog = {
  catalogVersion: 1,
  skus: {
    wedding_essentials: {
      label: "Wedding Essentials",
      unit: "program",
      priceMinor: 2499900,
      currency: "INR",
      limits,
      capabilitiesAllowed: ["forms", "messaging"],
      includedFlightDays: 0,
      includedWaConversations: 0,
      stakeholderSeats: 2,
    },
  },
};

test("usage inside every limit is ok", () => {
  assert.deepEqual(
    evaluateProgramUsage(limits,
      {guests: 150, functions: 5, staffAssignments: 10}),
    {state: "ok"},
  );
});

test("any breach soft-blocks and reports each overage in order", () => {
  const verdict = evaluateProgramUsage(limits,
    {guests: 151, functions: 5, staffAssignments: 12});
  assert.equal(verdict.state, "softBlock");
  if (verdict.state !== "softBlock") return;
  assert.deepEqual(verdict.breaches, [
    {dimension: "guests", limit: 150, used: 151, overBy: 1},
    {dimension: "staffAssignments", limit: 10, used: 12, overBy: 2},
  ]);
});

test("null limits are unlimited", () => {
  const open: SkuLimits = {
    guests: null,
    functions: null,
    staffAssignments: null,
    momentsPerFunction: null,
  };
  assert.deepEqual(
    evaluateProgramUsage(open,
      {guests: 100000, functions: 500, staffAssignments: 999}),
    {state: "ok"},
  );
});

test("moment ceiling applies per function", () => {
  assert.equal(momentsWithinFunctionCeiling(limits, 3), true);
  assert.equal(momentsWithinFunctionCeiling(limits, 4), false);
  assert.equal(momentsWithinFunctionCeiling(
    {...limits, momentsPerFunction: null}, 400), true);
});

test("disallowed capabilities are sorted and deduped", () => {
  assert.deepEqual(
    disallowedCapabilities(["forms", "messaging"],
      ["messaging", "arrivalsTransport", "forms", "arrivalsTransport"]),
    ["arrivalsTransport"],
  );
  assert.deepEqual(
    disallowedCapabilities(["forms"], ["forms"]), []);
});

test("snapshot wins over catalog; missing dims fall back", () => {
  const ceiling = resolveProgramCeiling(catalog, {
    sku: "wedding_essentials",
    limits: {
      guests: 175, functions: null,
      staffAssignments: null, momentsPerFunction: null,
    },
    capabilitiesAllowed: ["forms"],
  });
  assert.equal(ceiling?.limits.guests, 175);
  assert.equal(ceiling?.limits.functions, 5);
  assert.equal(ceiling?.limits.momentsPerFunction, 3);
  assert.deepEqual(ceiling?.capabilitiesAllowed, ["forms"]);
});

test("empty snapshot capabilities fall back to catalog ceiling", () => {
  const ceiling = resolveProgramCeiling(catalog, {
    sku: "wedding_essentials", limits, capabilitiesAllowed: [],
  });
  assert.deepEqual(ceiling?.capabilitiesAllowed, ["forms", "messaging"]);
});

test("null snapshot yields no ceiling", () => {
  assert.equal(resolveProgramCeiling(catalog, null), null);
});
