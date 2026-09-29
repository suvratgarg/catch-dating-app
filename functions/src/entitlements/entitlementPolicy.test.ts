import assert from "node:assert/strict";
import test from "node:test";
import {
  evaluateSoftLimit,
  grantIsActive,
  grantRemaining,
  resolveSkuLimits,
  selectConsumableGrant,
  type EntitlementGrantLike,
  type EntitlementSkuCatalog,
} from "./entitlementPolicy";

const grant: EntitlementGrantLike = {
  grantId: "g1",
  sku: "wedding_pro",
  unit: "program",
  quantityTotal: 3,
  quantityConsumed: 1,
  validFromMillis: 1_000,
  validUntilMillis: 9_000,
  grantedAtMillis: 500,
  revokedAtMillis: null,
};

const catalog: EntitlementSkuCatalog = {
  catalogVersion: 1,
  skus: {
    wedding_pro: {
      label: "Wedding Pro",
      unit: "program",
      priceMinor: 5999900,
      currency: "INR",
      limits: {
        guests: 400,
        functions: 10,
        staffAssignments: 30,
        momentsPerFunction: null,
      },
      capabilitiesAllowed: [
        "arrivalsTransport", "accommodation", "forms", "messaging",
      ],
      includedFlightDays: 0,
      includedWaConversations: 0,
      stakeholderSeats: 6,
    },
  },
};

test("grantRemaining and grantIsActive respect windows and revocation", () => {
  assert.equal(grantRemaining(grant), 2);
  assert.equal(grantIsActive(grant, 5_000), true);
  assert.equal(grantIsActive(grant, 999), false); // before validFrom
  assert.equal(grantIsActive(grant, 9_000), false); // expired at boundary
  assert.equal(grantIsActive({...grant, revokedAtMillis: 2_000}, 5_000),
    false);
  assert.equal(grantIsActive({...grant, quantityConsumed: 3}, 5_000), false);
  assert.equal(grantIsActive({...grant, validUntilMillis: null}, 99_000),
    true);
});

test("selectConsumableGrant picks the soonest-expiring active grant", () => {
  const later = {...grant, grantId: "g2", validUntilMillis: 20_000,
    grantedAtMillis: 600};
  const revoked = {...grant, grantId: "g3", validUntilMillis: 5_000,
    revokedAtMillis: 1_500};
  const otherSku = {...grant, grantId: "g4", sku: "wedding_essentials",
    validUntilMillis: 1_000};
  const picked = selectConsumableGrant({grants: [later, revoked, otherSku,
    grant]}, {sku: "wedding_pro", unit: "program"}, 5_000);
  assert.equal(picked?.grantId, "g1");
  assert.equal(selectConsumableGrant({grants: [later, revoked]},
    {sku: "wedding_essentials", unit: "program"}, 5_000), null);
  // Tie on validUntil falls back to grantedAt then grantId.
  const tie = selectConsumableGrant({grants: [
    {...grant, grantId: "gb", grantedAtMillis: 700},
    {...grant, grantId: "ga", grantedAtMillis: 700},
  ]}, {sku: "wedding_pro", unit: "program"}, 5_000);
  assert.equal(tie?.grantId, "ga");
});

test("resolveSkuLimits returns the catalog limits or null", () => {
  assert.deepEqual(resolveSkuLimits(catalog, "wedding_pro"), {
    guests: 400,
    functions: 10,
    staffAssignments: 30,
    momentsPerFunction: null,
  });
  assert.equal(resolveSkuLimits(catalog, "nope"), null);
});

test("evaluateSoftLimit distinguishes unlimited, within and over", () => {
  assert.deepEqual(evaluateSoftLimit({used: 412, limit: null}),
    {state: "unlimited"});
  assert.deepEqual(evaluateSoftLimit({used: 400, limit: 400}),
    {state: "within", remaining: 0});
  assert.deepEqual(evaluateSoftLimit({used: 412, limit: 400}),
    {state: "over", overBy: 12});
});

test("invalid ints and millis fail fast", () => {
  for (const bad of [-1, 0.5, NaN, Infinity]) {
    assert.throws(() => grantRemaining({...grant, quantityTotal: bad}),
      RangeError);
    assert.throws(() => grantIsActive(grant, bad), RangeError);
    assert.throws(() => evaluateSoftLimit({used: bad, limit: 3}),
      RangeError);
    assert.throws(() => evaluateSoftLimit({used: 0, limit: bad}),
      RangeError);
  }
});
