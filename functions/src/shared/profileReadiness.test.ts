import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {isAccountReadyUserProfile, isSocialReadyUserProfile} from
  "./profileReadiness";
import type {UserProfileDocument} from "./generated/firestoreAdminTypes";
import {missingProfileFields} from "./generated/profileRequirements";

test("account identity needs no social profile fields", () => {
  const minimal = {name: "Ada", phoneNumber: "+919876543210"};
  assert.equal(isAccountReadyUserProfile(minimal), true);
  assert.equal(isSocialReadyUserProfile({...minimal,
    profileComplete: false} as UserProfileDocument), false);
  assert.equal(isSocialReadyUserProfile({...minimal,
    profileComplete: true} as UserProfileDocument), false);
  assert.equal(isAccountReadyUserProfile({...minimal,
    dateOfBirth: Timestamp.fromDate(new Date())}), true);
});

test("missing identity and deleted accounts are not ready", () => {
  assert.equal(isAccountReadyUserProfile({phoneNumber: "+919876543210"}),
    false);
  assert.equal(isAccountReadyUserProfile({name: "Ada"}), false);
  const minimal = {name: "Ada", phoneNumber: "+919876543210"};
  assert.equal(isAccountReadyUserProfile({...minimal, deleted: true}), false);
  assert.equal(isAccountReadyUserProfile({...minimal,
    deletedAt: Timestamp.now()}), false);
});

test("event-specific age and cohort requirements", () => {
  const present = new Set(["name", "phoneNumber"]);
  assert.deepEqual(missingProfileFields("organizerFollow",
    (field) => present.has(field)), []);
  assert.deepEqual(missingProfileFields("eventBooking",
    (field) => present.has(field)), []);
  assert.deepEqual(missingProfileFields("eventBooking",
    (field) => present.has(field), ["ageRestricted"]), ["dateOfBirth"]);
  assert.deepEqual(missingProfileFields("eventBooking",
    (field) => present.has(field), ["cohortRestricted"]),
  ["gender", "interestedInGenders"]);
});
