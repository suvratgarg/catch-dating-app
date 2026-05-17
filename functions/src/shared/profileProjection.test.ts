/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {UserProfileDoc} from "./firestore";
import {profilePromptCatalog} from "./generated/schemaRegistry";
import {
  normalizePhotoUrls,
  publicDisplayName,
  publicAvatarUrl,
  publicProfileFromUserProfileDoc,
} from "./profileProjection";

function timestamp(date: Date) {
  return {toDate: () => date} as FirebaseFirestore.Timestamp;
}

function completeUser(overrides: Partial<UserProfileDoc> = {}): UserProfileDoc {
  return {
    profileComplete: true,
    name: "Asha Runner",
    firstName: "Asha",
    lastName: "Runner",
    displayName: "Asha Host",
    dateOfBirth: timestamp(new Date("1996-01-01T00:00:00.000Z")),
    gender: "woman",
    phoneNumber: "+919900000001",
    email: "asha@example.test",
    profilePrompts: [{
      promptId: " perfectRun ",
      prompt: " A perfect event with me looks like... ",
      answer: "Morning runner\n\n\nCoffee after.",
    }],
    photoPrompts: [{
      photoIndex: 0,
      promptId: " proofIRun ",
      prompt: " Proof I actually event ",
      caption: "Race morning\n\n\nFinish-line smile.",
    }],
    photoUrls: ["https://example.test/full.jpg"],
    photoThumbnailUrls: ["https://example.test/thumb.jpg"],
    city: "mumbai",
    interestedInGenders: ["man"],
    minAgePreference: 24,
    maxAgePreference: 42,
    languages: ["english"],
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 420,
    preferredDistances: ["fiveK"],
    runningReasons: ["fitness"],
    preferredRunTimes: ["morning"],
    prefsNewCatches: true,
    prefsMessages: true,
    prefsEventReminders: true,
    prefsRunStatusUpdates: true,
    prefsClubUpdates: true,
    prefsWeeklyDigest: false,
    prefsShowOnMap: true,
    ...overrides,
  };
}

test("publicDisplayName uses editable display name with safe fallbacks", () => {
  assert.equal(publicDisplayName(completeUser()), "Asha Host");
  assert.equal(
    publicDisplayName(completeUser({displayName: " ", firstName: "Asha"})),
    "Asha"
  );
  assert.equal(
    publicDisplayName(completeUser({
      displayName: " ",
      firstName: " ",
      name: "Asha Runner",
    })),
    "Asha"
  );
});

test("public photo URLs are trimmed and invalid values are dropped", () => {
  assert.deepEqual(
    normalizePhotoUrls([
      " https://example.test/one.jpg ",
      "",
      "not a url",
      "https://example.test/two.jpg",
    ]),
    [
      "https://example.test/one.jpg",
      "https://example.test/two.jpg",
    ]
  );
  assert.equal(
    publicAvatarUrl(completeUser({
      photoThumbnailUrls: ["bad thumbnail"],
      photoUrls: [" https://example.test/full.jpg "],
    })),
    "https://example.test/full.jpg"
  );
});

test("publicProfileFromUserProfileDoc drops invalid photo URLs", () => {
  const profile = publicProfileFromUserProfileDoc(completeUser({
    photoUrls: ["not a url", "https://example.test/full.jpg"],
    photoThumbnailUrls: [
      "https://example.test/thumb.jpg",
      "bad thumbnail",
    ],
  }));

  assert.deepEqual(profile.photoUrls, ["https://example.test/full.jpg"]);
  assert.deepEqual(profile.photoThumbnailUrls, [
    "https://example.test/thumb.jpg",
  ]);
});

test(
  "publicProfileFromUserProfileDoc projects public fields and metadata",
  () => {
    const profile = publicProfileFromUserProfileDoc(completeUser({
      synthetic: true,
      seedPrefix: "demo_beta_2026",
      scenario: "smoke",
      height: 168,
      occupation: "Designer",
      company: "Stride Labs",
      relationshipGoal: "relationship",
    } as Partial<UserProfileDoc>));

    assert.equal(profile.name, "Asha Host");
    assert.equal(profile.synthetic, true);
    assert.equal(profile.seedPrefix, "demo_beta_2026");
    assert.equal(profile.scenario, "smoke");
    assert.equal(Object.hasOwn(profile, "demoOps"), false);
    assert.deepEqual(profile.profilePrompts, [{
      promptId: "perfectRun",
      prompt: "A perfect event with me looks like...",
      answer: "Morning runner\n\nCoffee after.",
    }]);
    assert.deepEqual(profile.photoPrompts, [{
      photoIndex: 0,
      promptId: "proofIRun",
      prompt: "Proof I actually event",
      caption: "Race morning\n\nFinish-line smile.",
    }]);
    assert.equal(profile.height, 168);
    assert.equal(profile.occupation, "Designer");
    assert.equal(profile.company, "Stride Labs");
    assert.equal(profile.relationshipGoal, "relationship");
    assert.deepEqual(profile.preferredRunTimes, ["morning"]);
  }
);

test("publicProfileFromUserProfileDoc migrates legacy bio via catalog fallback",
  () => {
    const defaultPrompt = profilePromptCatalog.prompts.find(
      (prompt) => prompt.id === profilePromptCatalog.defaultPromptIds[0]
    ) ?? profilePromptCatalog.prompts[0];
    const profile = publicProfileFromUserProfileDoc(completeUser({
      profilePrompts: [],
      bio: "Old bio\n\n\nstill useful",
    } as Partial<UserProfileDoc>));

    assert.deepEqual(profile.profilePrompts, [{
      promptId: defaultPrompt.id,
      prompt: defaultPrompt.title,
      answer: "Old bio\n\nstill useful",
    }]);
  }
);
