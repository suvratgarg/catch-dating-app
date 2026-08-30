import assert from "node:assert/strict";
import test from "node:test";
import {resolveIndividualCommunicationPlan} from
  "./organizerCommunicationPlan";

const baseContact = {
  contactId: "contact-1",
  displayName: "Asha",
  linkedUid: null,
  identityState: "unlinked" as const,
  ambiguousCandidateCount: 0,
  phoneE164: "+919876543210",
  whatsappStatus: "unknown" as const,
  whatsappAdminSuppressed: false,
};

test("Catch chat is recommended while handoff remains available", () => {
  const plan = resolveIndividualCommunicationPlan({
    ...baseContact,
    linkedUid: "user-1",
    identityState: "verified",
  });

  assert.equal(plan.outcome, "inCatch");
  assert.equal(plan.recommendedRouteId, "catchChat");
  assert.deepEqual(plan.routes, [
    {
      routeId: "catchChat",
      executionMode: "managedDelivery",
      availability: "available",
      blocker: null,
    },
    {
      routeId: "personalWhatsappHandoff",
      executionMode: "externalHandoff",
      availability: "available",
      blocker: null,
    },
  ]);
});

test("an unlinked contact with a phone resolves to host final send", () => {
  const plan = resolveIndividualCommunicationPlan(baseContact);

  assert.equal(plan.outcome, "byHand");
  assert.equal(plan.recommendedRouteId, "personalWhatsappHandoff");
  assert.equal(plan.routes[0].blocker, "catchAccountRequired");
  assert.equal(plan.routes[1].availability, "available");
});

test("identity ambiguity blocks Catch chat without a fake delivery", () => {
  const plan = resolveIndividualCommunicationPlan({
    ...baseContact,
    linkedUid: "user-1",
    identityState: "ambiguous",
    ambiguousCandidateCount: 2,
  });

  assert.equal(plan.outcome, "byHand");
  assert.equal(plan.routes[0].blocker, "identityAmbiguous");
});

test("manual handoff fails closed for every endpoint authority blocker", () => {
  for (const [facts, blocker] of [
    [{phoneE164: null}, "missingPhone"],
    [{whatsappAdminSuppressed: true}, "organizerSuppressed"],
    [{whatsappStatus: "optedOut" as const}, "contactOptedOut"],
  ] as const) {
    const plan = resolveIndividualCommunicationPlan({
      ...baseContact,
      ...facts,
    });
    assert.equal(plan.outcome, "unavailable");
    assert.equal(plan.recommendedRouteId, null);
    assert.equal(plan.routes[1].blocker, blocker);
  }
});

test("unknown permission is not rewritten as a marketing grant", () => {
  const plan = resolveIndividualCommunicationPlan(baseContact);

  assert.equal(plan.routes[1].availability, "available");
  assert.equal(plan.routes[1].executionMode, "externalHandoff");
  assert.equal(baseContact.whatsappStatus, "unknown");
});
