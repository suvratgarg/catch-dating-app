import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {
  eventAgeEligibility,
  assertPublicEventAge,
} from "./eventProfileRequirements";
import {newAccountProfile} from "./websiteAccount";
import {
  isBookingReadyUserProfile,
  isSocialReadyUserProfile,
} from "../shared/profileReadiness";
import type {EventDocument} from "../shared/generated/firestoreAdminTypes";
const now = new Date("2026-10-18T12:00:00Z");
const profile = newAccountProfile("Ada", "+919876543210");
const event = (minAge = 0, maxAge = 99) =>
  ({constraints: {minAge, maxAge}}) as EventDocument;
test("unrestricted booking needs only account identity", async () => {
  assert.equal(eventAgeEligibility(event(), profile, now), null);
  assert.equal(isBookingReadyUserProfile(profile, event()), true);
  assert.equal(isSocialReadyUserProfile(profile), false);
  await assertPublicEventAge({
    db: {} as FirebaseFirestore.Firestore,
    tx: {} as FirebaseFirestore.Transaction,
    uid: "guest",
    event: event(),
    nowMillis: now.getTime(),
  });
});
test("actual birthdays enforce age boundaries", () => {
  assert.equal(
    eventAgeEligibility(event(18), profile, now)?.needsDateOfBirth,
    true
  );
  assert.equal(isBookingReadyUserProfile(profile, event(18)), false);
  for (const [birthday, allowed] of [
    ["2008-10-18", true],
    ["2008-10-19", false],
    ["1995-10-18", false],
  ] as const) {
    assert.equal(
      eventAgeEligibility(
        event(18, 30),
        {...profile, dateOfBirth: Timestamp.fromDate(new Date(birthday))},
        now
      )?.eligible,
      allowed
    );
  }
});
test("admission age guard reads current stored birthday", async () => {
  let stored = profile;
  const tx = {get: async () => ({data: () => stored})};
  const db = {collection: () => ({doc: () => "users/guest"})};
  const input = {
    db: db as unknown as FirebaseFirestore.Firestore,
    tx: tx as unknown as FirebaseFirestore.Transaction,
    uid: "guest",
    event: event(18),
    nowMillis: now.getTime(),
  };
  await assert.rejects(assertPublicEventAge(input), {
    code: "failed-precondition",
  });
  stored = {
    ...profile,
    dateOfBirth: Timestamp.fromDate(new Date("2000-01-01")),
  };
  await assertPublicEventAge(input);
  stored = {
    ...profile,
    dateOfBirth: Timestamp.fromDate(new Date("2010-01-01")),
  };
  await assert.rejects(assertPublicEventAge(input), {
    code: "failed-precondition",
  });
});
