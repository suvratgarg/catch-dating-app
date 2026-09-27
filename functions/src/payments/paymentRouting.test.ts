import {strict as assert} from "node:assert";
import {test} from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {PaymentRoutingPolicyDocument as Policy} from
  "../shared/generated/firestoreAdminTypes";
import {organizerPaymentPolicyId, selectPaymentRoute, PaymentRoutingRegistry,
  type PaymentRouteSelection, type PaymentRouteBinding} from "./paymentRouting";

const route: PaymentRouteSelection = {route: "razorpayRoute", mode: "test",
  currency: "INR", merchantCountry: "IN"};
const oauth: PaymentRouteSelection = {...route, route: "razorpayOAuth"};
const app: Policy = {scope: "app", organizerId: null, revision: 4,
  formFee: route, eventAdmission: oauth, updatedAt: Timestamp.fromMillis(1)};
const organizer: Policy = {scope: "organizer", organizerId: "org", revision: 2,
  formFee: oauth, eventAdmission: null, updatedAt: Timestamp.fromMillis(1)};
const binding: PaymentRouteBinding = {bindingId: "binding1",
  merchantAccountId: "acc_catch", destinationAccountId: "acc_organizer",
  configurationVersion: "projects/test-project/secrets/route/versions/1",
  checkoutKey: "rzp_test_key", transferAmountMinor: 9500, settlementHold: true};

test("per-purpose overrides and null inheritance", () => {
  const fee = selectPaymentRoute({app, organizer, organizerId: "org",
    purpose: "formFee"});
  assert.equal(fee.selection.route, "razorpayOAuth");
  assert.equal(fee.policySource, "organizer");
  assert.equal(fee.appRevision, 4);
  assert.equal(fee.organizerRevision, 2);
  const event = selectPaymentRoute({app, organizer, organizerId: "org",
    purpose: "eventAdmission"});
  assert.equal(event.selection.route, "razorpayOAuth");
  assert.equal(event.policySource, "app");
});

test("disabled app choice never reopens legacy payments", () => {
  for (const disabled of [null, {route: "disabled" as const}]) {
    assert.throws(() => selectPaymentRoute({app: {...app, formFee: disabled},
      organizer: null, organizerId: "org", purpose: "formFee",
      legacySelection: oauth}), /disabled/);
  }
  assert.throws(() => selectPaymentRoute({app,
    organizer: {...organizer, formFee: {route: "disabled"}},
    organizerId: "org", purpose: "formFee"}), /disabled/);
  const legacy = selectPaymentRoute({app: null, organizer: null,
    organizerId: "org", purpose: "formFee", legacySelection: oauth});
  assert.equal(legacy.policySource, "legacy");
});

test("organizer scopes cannot collide or cross organizers", () => {
  assert.notEqual(organizerPaymentPolicyId("app"), "app");
  assert.notEqual(organizerPaymentPolicyId("org"),
    organizerPaymentPolicyId("Org"));
  assert.throws(() => organizerPaymentPolicyId("org/other"));
  assert.throws(() => selectPaymentRoute({app, organizer,
    organizerId: "other", purpose: "formFee"}), /scope mismatch/);
  assert.throws(() => selectPaymentRoute({app: {...app, organizerId: "org"},
    organizer: null, organizerId: "org", purpose: "formFee"}),
  /Invalid payment/);
});

test("unsupported Stripe does not fall back to Razorpay", async () => {
  let calls = 0;
  const registry = new PaymentRoutingRegistry({razorpayRoute: {
    prepare: async () => {
      calls++; return binding;
    },
    resume: async () => "route-runtime",
  }});
  const selected = selectPaymentRoute({app: {...app, formFee: {
    route: "stripeConnectDirect", mode: "live", currency: "USD",
    merchantCountry: "US"}}, organizer: null, organizerId: "org",
  purpose: "formFee"});
  await assert.rejects(registry.prepare({organizerId: "org", purpose: "formFee",
    currency: "USD", amountMinor: 10000, selected}), /not available yet/);
  assert.equal(calls, 0);
});

test("saved payments keep their route after settings switch", async () => {
  let prepares = 0;
  const resumed: string[] = [];
  const registry = new PaymentRoutingRegistry({razorpayRoute: {
    prepare: async () => {
      prepares++; return {...binding};
    },
    resume: async (snapshot) => {
      resumed.push(snapshot.configurationVersion);
      return snapshot.merchantAccountId;
    },
  }});
  const selected = selectPaymentRoute({app, organizer: null, organizerId: "org",
    purpose: "formFee"});
  const {snapshot} = await registry.prepare({organizerId: "org",
    purpose: "formFee", currency: "INR", amountMinor: 10000, selected});
  selected.selection.route = "razorpayOAuth";
  const saved = JSON.parse(JSON.stringify(snapshot));
  assert.equal(await registry.resume(saved, {organizerId: "org",
    purpose: "formFee", currency: "INR"}), "acc_catch");
  assert.equal(prepares, 1);
  assert.deepEqual(resumed, [binding.configurationVersion,
    binding.configurationVersion]);
  await assert.rejects(registry.resume(saved, {organizerId: "other",
    purpose: "formFee", currency: "INR"}), /routing mismatch/);
  await assert.rejects(registry.resume(saved, {organizerId: "org",
    purpose: "eventAdmission", currency: "INR"}), /routing mismatch/);
});

test("currency and collection accounts must match the route", async () => {
  const selected = selectPaymentRoute({app, organizer: null, organizerId: "org",
    purpose: "formFee"});
  for (const invalid of [{...binding, destinationAccountId: null},
    {...binding, destinationAccountId: binding.merchantAccountId}]) {
    const registry = new PaymentRoutingRegistry({razorpayRoute: {
      prepare: async () => invalid, resume: async () => "unused",
    }});
    await assert.rejects(registry.prepare({organizerId: "org",
      purpose: "formFee", currency: "INR", amountMinor: 10000, selected}),
    /collection account/);
    await assert.rejects(registry.prepare({organizerId: "org",
      purpose: "formFee", currency: "USD", amountMinor: 10000, selected}),
    /currency/);
  }
});
