import assert from "node:assert/strict";
import test from "node:test";
import {
  crossPathsProfileFingerprint,
  effectiveCrossPathsShowcaseEligibility,
  evaluateCrossPathsShowcaseReadiness,
} from "./showcaseEligibility";

test("showcase readiness uses neutral profile gates", () => {
  const readiness = evaluateCrossPathsShowcaseReadiness(readyProfile());

  assert.equal(readiness.automaticStatus, "ready");
  assert.deepEqual(readiness.reasonCodes, []);
  assert.match(readiness.profileFingerprint, /^[a-f0-9]{64}$/u);
});

test("showcase readiness returns coarse objective blocker codes", () => {
  const profile = readyProfile();
  profile.profilePhotos = [
    photo("one", "pending"),
    {...photo("two", "approved"), thumbnailUrl: ""},
  ];
  profile.profilePrompts = [{prompt: "A prompt", answer: ""}];
  delete profile.relationshipGoal;

  const readiness = evaluateCrossPathsShowcaseReadiness(profile);

  assert.equal(readiness.automaticStatus, "blocked");
  assert.deepEqual(readiness.reasonCodes, [
    "insufficient_photos",
    "broken_media",
    "photo_moderation_pending",
    "incomplete_prompts",
    "missing_relationship_goal",
  ]);
});

test("a profile edit invalidates an earlier approval", () => {
  const profile = readyProfile();
  const readiness = evaluateCrossPathsShowcaseReadiness(profile);
  const stored = {
    status: "eligible" as const,
    reasonCodes: [],
    ruleVersion: 1,
    reviewVersion: 1,
    profileFingerprint: readiness.profileFingerprint,
    reviewChecklist: {
      primaryPortraitClear: true,
      profileRepresentsCurrentMember: true,
      showcasePolicyReviewed: true,
    },
    reviewNote: "Reviewed.",
    reviewedByUid: "reviewer-1",
    reviewedAt: fakeTimestamp(),
    updatedAt: fakeTimestamp(),
  };
  assert.equal(
    effectiveCrossPathsShowcaseEligibility(readiness, stored).status,
    "eligible"
  );

  profile.occupation = "Product designer";
  const changed = evaluateCrossPathsShowcaseReadiness(profile);
  const effective = effectiveCrossPathsShowcaseEligibility(changed, stored);

  assert.equal(effective.status, "needsReview");
  assert.deepEqual(effective.reasonCodes, ["profile_changed"]);
});

test("profile fingerprint is stable across object key ordering", () => {
  assert.equal(
    crossPathsProfileFingerprint({name: "Rhea", age: 28}),
    crossPathsProfileFingerprint({age: 28, name: "Rhea"})
  );
});

function readyProfile(): Record<string, unknown> {
  return {
    name: "Rhea",
    age: 28,
    gender: "woman",
    relationshipGoal: "longTermRelationship",
    profilePhotos: [
      photo("one", "approved"),
      photo("two", "approved"),
      photo("three", "approved"),
    ],
    profilePrompts: [
      {prompt: "Ideal Sunday", answer: "A long walk and dosa."},
      {prompt: "Together we could", answer: "Try every quiz night."},
      {prompt: "I am known for", answer: "Making the plan happen."},
    ],
  };
}

function photo(id: string, status: string): Record<string, unknown> {
  return {
    id,
    url: `https://images.example/${id}.jpg`,
    thumbnailUrl: `https://images.example/${id}-thumb.jpg`,
    storagePath: `profiles/rhea/${id}.jpg`,
    thumbnailStoragePath: `profiles/rhea/${id}-thumb.jpg`,
    moderation: {status},
  };
}

function fakeTimestamp() {
  return {
    toMillis: () => Date.parse("2026-08-05T10:00:00.000Z"),
  } as unknown as FirebaseFirestore.Timestamp;
}
