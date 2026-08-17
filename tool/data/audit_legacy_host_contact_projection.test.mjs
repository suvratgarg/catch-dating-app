import assert from "node:assert/strict";
import test from "node:test";
import {
  buildLegacyHostContactProjectionAudit,
  classifyLegacyContactProjection,
} from "./audit_legacy_host_contact_projection.mjs";

test("classifies only exact unprovenanced private contact matches as high confidence", () => {
  const result = classifyLegacyContactProjection({
    source: "catchBooking",
    linkedUid: "user-1",
    phoneE164: "+919876543210",
    email: "Person@Example.com",
    importId: null,
    sourceRowId: null,
    externalReference: null,
  }, {
    phoneNumber: "+91 98765 43210",
    email: "person@example.com",
  });
  assert.equal(result.classification, "highConfidencePrivateProjection");
  assert.deepEqual(result.projectedFields, ["phoneE164", "email"]);
  assert.deepEqual(result.reasons, []);
});

test("keeps organizer-supplied or mismatched contacts for human reconciliation", () => {
  const result = classifyLegacyContactProjection({
    source: "catchBooking",
    linkedUid: "user-1",
    phoneE164: "+919999999999",
    email: "person@example.com",
    importId: "import-1",
  }, {
    phoneNumber: "+919876543210",
    email: "person@example.com",
  });
  assert.equal(result.classification, "humanReconciliationRequired");
  assert.deepEqual(result.projectedFields, ["email"]);
  assert.deepEqual(result.mismatchedFields, ["phoneE164"]);
  assert.deepEqual(result.reasons, [
    "operationalContactProvenance",
    "privateProfileMismatch",
  ]);
});

test("builds PII-free organizer and downstream projection counts", async () => {
  const db = fakeFirestore({
    eventAttendees: {
      "attendee-1": attendee({organizerId: "organizer-a"}),
      "attendee-2": attendee({
        organizerId: "organizer-a",
        linkedUid: "user-2",
        phoneE164: "+919999999999",
      }),
      "attendee-3": attendee({
        organizerId: "organizer-b",
        source: "hostImport",
      }),
    },
    users: {
      "user-1": {phoneNumber: "+919876543210", email: null},
      "user-2": {phoneNumber: "+919876543210", email: null},
    },
    organizerContactEventEdges: {
      "attendee-1": {contactId: "contact-1"},
      "attendee-2": {contactId: "contact-1"},
    },
  });
  const plan = await buildLegacyHostContactProjectionAudit(db);
  assert.equal(plan.catchBookingRowsScanned, 2);
  assert.equal(plan.highConfidenceCount, 1);
  assert.equal(plan.humanReconciliationCount, 1);
  assert.equal(plan.projectedEdgeCount, 2);
  assert.equal(plan.affectedContactCount, 1);
  assert.deepEqual(plan.organizers, [{
    organizerId: "organizer-a",
    highConfidenceCount: 1,
    humanReconciliationCount: 1,
    projectedEdgeCount: 2,
    affectedContactCount: 1,
  }]);
});

function attendee(overrides = {}) {
  return {
    organizerId: "organizer-a",
    eventId: "event-1",
    source: "catchBooking",
    linkedUid: "user-1",
    phoneE164: "+919876543210",
    email: null,
    importId: null,
    sourceRowId: null,
    externalReference: null,
    ...overrides,
  };
}

function fakeFirestore(collections) {
  const refs = new Map();
  const ref = (collectionName, id) => {
    const key = `${collectionName}/${id}`;
    if (!refs.has(key)) refs.set(key, {collectionName, id});
    return refs.get(key);
  };
  return {
    collection: (collectionName) => ({
      doc: (id) => ref(collectionName, id),
      where: (field, operator, expected) => query(
        collectionName,
        [[field, operator, expected]]
      ),
    }),
    getAll: async (...documentRefs) => documentRefs.map((documentRef) => {
      const value = collections[documentRef.collectionName]?.[documentRef.id];
      return {
        id: documentRef.id,
        exists: value !== undefined,
        data: () => value === undefined ? undefined : structuredClone(value),
      };
    }),
  };

  function query(collectionName, clauses) {
    return {
      where: (field, operator, expected) => query(
        collectionName,
        [...clauses, [field, operator, expected]]
      ),
      get: async () => {
        const docs = Object.entries(collections[collectionName] ?? {})
          .filter(([, value]) => clauses.every(([field, operator, expected]) => {
            assert.equal(operator, "==");
            return value[field] === expected;
          }))
          .map(([id, value]) => ({
            id,
            data: () => structuredClone(value),
          }));
        return {size: docs.length, docs};
      },
    };
  }
}
