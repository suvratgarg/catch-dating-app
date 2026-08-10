import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {
  assertPublicRegistrationEligibility,
  eventAttendeeId,
  mergeOrganizerCommunicationPreference,
  normalizeRosterPhone,
  onboardingDraftSeed,
  prepareImportRows,
  publicRegistrationStatus,
} from "./eventAttendees";

test("normalizeRosterPhone accepts E.164 and Indian local numbers", () => {
  assert.deepEqual(normalizeRosterPhone("+44 7700 900123"), {
    value: "+447700900123",
    issue: null,
  });
  assert.deepEqual(normalizeRosterPhone("98765 43210"), {
    value: "+919876543210",
    issue: null,
  });
  assert.equal(normalizeRosterPhone("123").value, null);
  assert.match(normalizeRosterPhone("123").issue ?? "", /country code/);
});

test("public registration fails closed and keeps idempotent retries", () => {
  const eligible = {
    organizerVisibility: "discoverable",
    organizerPublishStatus: "published",
    eventStatus: "active",
    eventEndTimeMs: Date.now() + 60_000,
    publicRegistrationEnabled: true,
    admissionFormat: "open",
    inviteRequired: false,
    membershipRequired: false,
    manualApprovalRequired: false,
    priceInPaise: 0,
  };
  assert.doesNotThrow(() => assertPublicRegistrationEligibility(eligible));
  assert.throws(
    () => assertPublicRegistrationEligibility({
      ...eligible,
      organizerVisibility: "hidden",
    }),
    /has not published/u
  );
  assert.throws(
    () => assertPublicRegistrationEligibility({
      ...eligible,
      publicRegistrationEnabled: false,
    }),
    /not enabled/u
  );
  assert.throws(
    () => assertPublicRegistrationEligibility({
      ...eligible,
      priceInPaise: 100,
    }),
    /cannot bypass payment/u
  );
  assert.throws(
    () => assertPublicRegistrationEligibility({
      ...eligible,
      admissionFormat: "inviteOnly",
    }),
    /open-admission/u
  );
});

test("public registration fills open capacity then uses the waitlist", () => {
  assert.equal(publicRegistrationStatus({
    activeCount: 19,
    capacityLimit: 20,
    existingStatus: undefined,
  }), "registered");
  assert.equal(publicRegistrationStatus({
    activeCount: 20,
    capacityLimit: 20,
    existingStatus: undefined,
  }), "waitlisted");
  assert.equal(publicRegistrationStatus({
    activeCount: 20,
    capacityLimit: 20,
    existingStatus: "registered",
  }), "registered");
});

test("prepareImportRows deduplicates event-scoped contact identity", () => {
  const result = prepareImportRows({
    eventId: "event-1",
    importKey: "import-key-1",
    rows: [
      {
        rowId: "1",
        displayName: "  Asha   Shah ",
        phone: "+91 98765 43210",
        email: null,
        externalReference: null,
        ticketType: "General",
        status: "registered",
      },
      {
        rowId: "2",
        displayName: "Asha duplicate",
        phone: "9876543210",
        email: null,
        externalReference: null,
        ticketType: null,
        status: "registered",
      },
    ],
  });

  assert.equal(result.prepared.length, 1);
  assert.equal(result.prepared[0].displayName, "Asha Shah");
  assert.equal(result.prepared[0].phoneE164, "+919876543210");
  assert.deepEqual(result.errors.map((error) => error.code), [
    "duplicate-row",
  ]);
});

test("eventAttendeeId is stable and event-isolated", () => {
  const stable = eventAttendeeId("event-1", "email:asha@example.com");
  assert.equal(stable, eventAttendeeId("event-1", "email:asha@example.com"));
  assert.notEqual(
    stable,
    eventAttendeeId("event-2", "email:asha@example.com")
  );
  assert.match(stable, /^att_[a-f0-9]{48}$/);
});

test("OTP registration seeds a private account draft without a profile", () => {
  assert.deepEqual(onboardingDraftSeed({
    displayName: "Asha Shah",
    phoneE164: "+919876543210",
  }), {
    step: 1,
    draftVersion: 2,
    firstName: "Asha Shah",
    lastName: "",
    phoneNumber: "9876543210",
    countryCode: "+91",
  });
});

test("registration consent only adds explicit channel grants", () => {
  const now = admin.firestore.Timestamp.fromMillis(10);
  assert.equal(mergeOrganizerCommunicationPreference({
    organizerId: "organizer-1",
    uid: "user-1",
    eventId: "event-1",
    now,
  }), null);

  const preference = mergeOrganizerCommunicationPreference({
    organizerId: "organizer-1",
    uid: "user-1",
    eventId: "event-1",
    organizerUpdates: {
      whatsapp: true,
      sms: false,
      termsVersion: "organizer-updates-v1",
    },
    now,
  });
  assert.equal(preference?.whatsapp.status, "optedIn");
  assert.equal(preference?.sms.status, "unknown");

  const replay = mergeOrganizerCommunicationPreference({
    existing: preference!,
    organizerId: "organizer-1",
    uid: "user-1",
    eventId: "event-2",
    organizerUpdates: {
      whatsapp: false,
      sms: false,
      termsVersion: "organizer-updates-v1",
    },
    now: admin.firestore.Timestamp.fromMillis(20),
  });
  assert.equal(replay, null);
  assert.equal(preference?.whatsapp.status, "optedIn");
});
