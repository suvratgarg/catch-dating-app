import assert from "node:assert/strict";
import test from "node:test";
import {
  backfillReceiptId,
  buildOrganizerAudienceBackfillPlan,
} from "./backfill_organizer_audience.mjs";

test("audience backfill plan groups attendee work by organizer", async () => {
  const plan = await buildOrganizerAudienceBackfillPlan(fakeFirestore({
    eventAttendees: {
      "attendee-1": {organizerId: "organizer-b"},
      "attendee-2": {organizerId: "organizer-a"},
      "attendee-3": {organizerId: "organizer-b"},
      "attendee-invalid": {organizerId: null},
    },
  }));
  assert.equal(plan.attendeeCount, 4);
  assert.equal(plan.skippedInvalidOrganizerCount, 1);
  assert.deepEqual(plan.organizers.map((item) => [
    item.organizerId,
    item.attendeeCount,
  ]), [
    ["organizer-a", 1],
    ["organizer-b", 2],
  ]);
});

test("audience backfill plan can be organizer scoped", async () => {
  const plan = await buildOrganizerAudienceBackfillPlan(fakeFirestore({
    eventAttendees: {
      "attendee-1": {organizerId: "organizer-a"},
      "attendee-2": {organizerId: "organizer-b"},
    },
  }), "organizer-b");
  assert.deepEqual(plan.organizers.map((item) => item.organizerId), [
    "organizer-b",
  ]);
});

test("audience backfill discovers zero-attendee CRM organizers", async () => {
  const plan = await buildOrganizerAudienceBackfillPlan(fakeFirestore({
    organizerContacts: {
      "contact-1": {organizerId: "organizer-manual"},
    },
    organizerAudienceSummaries: {
      "organizer-stuck": {
        organizerId: "organizer-stuck",
        sourceCoverage: "partial",
      },
      "organizer-complete": {
        organizerId: "organizer-complete",
        sourceCoverage: "exact",
      },
    },
  }));

  assert.deepEqual(plan.organizers.map((item) => [
    item.organizerId,
    item.attendeeCount,
  ]), [
    ["organizer-manual", 0],
    ["organizer-stuck", 0],
  ]);
});

test("organizer-scoped backfill retains an empty organizer", async () => {
  const plan = await buildOrganizerAudienceBackfillPlan(
    fakeFirestore({}),
    "organizer-empty"
  );
  assert.deepEqual(plan.organizers.map((item) => [
    item.organizerId,
    item.attendeeCount,
  ]), [["organizer-empty", 0]]);
});

test("backfill receipt identity includes the canonical source revision", () => {
  const revision = {toMillis: () => 1234};
  assert.equal(
    backfillReceiptId("attendee-1", {updatedAt: revision}),
    "audience-backfill-v1:attendee-1:1234"
  );
});

function fakeFirestore(collections) {
  return {
    collection: (collectionName) => {
      assert.ok([
        "eventAttendees",
        "organizerContacts",
        "organizerAudienceSummaries",
      ].includes(collectionName));
      const allDocs = Object.entries(collections[collectionName] ?? {})
        .map(([id, value]) => ({
        id,
        data: () => structuredClone(value),
        }));
      return {
        get: async () => ({size: allDocs.length, docs: allDocs}),
        where: (field, operator, expected) => {
          assert.equal(field, "organizerId");
          assert.equal(operator, "==");
          const docs = allDocs.filter((doc) =>
            doc.data().organizerId === expected
          );
          return {get: async () => ({size: docs.length, docs})};
        },
      };
    },
  };
}
