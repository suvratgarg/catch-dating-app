import assert from "node:assert/strict";
import test from "node:test";
import {
  photoPromptCatalog,
  profilePromptCatalog,
} from "./generated/schema_contract_registry.mjs";
import {validateSeedDocuments} from "./seed_demo_data.mjs";

const profilePrompt = profilePromptCatalog.prompts[0];
const photoPrompt = photoPromptCatalog.prompts[0];
const dateOfBirthIso = "1990-01-01T00:00:00.000Z";

test("seed document validation accepts valid profile and run docs", () => {
  const result = validateSeedDocuments({
    docs: [
      {path: "users/runner-1", data: validUserProfileDoc()},
      {path: "publicProfiles/runner-1", data: validPublicProfileDoc()},
      {path: "runClubs/club-1", data: validRunClubDoc()},
      {
        path: "runClubMemberships/club-1_runner-1",
        data: validRunClubMembershipDoc(),
      },
      {path: "runs/run-1", data: validRunDoc()},
      {
        path: "runParticipations/run-1_runner-1",
        data: validRunParticipationDoc(),
      },
      {path: "savedRuns/runner-1_run-1", data: validSavedRunDoc()},
    ],
  });

  assert.deepEqual(result, {
    users: 1,
    publicProfiles: 1,
    runClubs: 1,
    runClubMemberships: 1,
    runs: 1,
    runParticipations: 1,
    runClubScheduleLocks: 0,
    userRunScheduleLocks: 0,
    savedRuns: 1,
    payments: 0,
    swipes: 0,
    matches: 0,
    chatMessages: 0,
    reviews: 0,
    activityNotifications: 0,
    seedManifests: 0,
    profilePromptAnswers: 2,
    photoPromptAnswers: 2,
    projectionPairs: 1,
  });
});

test("seed profile validation rejects legacy bio fields", () => {
  assert.throws(
    () => validateSeedDocuments({
      docs: [
        {
          path: "users/runner-1",
          data: {...validUserProfileDoc(), bio: "legacy freeform bio"},
        },
      ],
    }),
    /users\/runner-1 failed schema validation/
  );
});

test("seed profile validation rejects stale prompt ids before writes", () => {
  const user = validUserProfileDoc();
  user.profilePrompts = [
    {
      promptId: "deletedPrompt",
      prompt: profilePrompt.title,
      answer: "An answer that should not be written.",
    },
  ];

  assert.throws(
    () => validateSeedDocuments({
      docs: [{path: "users/runner-1", data: user}],
    }),
    /uses unknown profile prompt id: deletedPrompt/
  );
});

test("seed profile validation rejects overlong prompt answers", () => {
  const user = validUserProfileDoc();
  user.profilePrompts = [
    {
      promptId: profilePrompt.id,
      prompt: profilePrompt.title,
      answer: "a".repeat(301),
    },
  ];

  assert.throws(
    () => validateSeedDocuments({
      docs: [{path: "users/runner-1", data: user}],
    }),
    /users\/runner-1\.profilePrompts\[0\] failed schema validation/
  );
});

test("seed profile validation rejects mismatched public projections", () => {
  const publicProfile = validPublicProfileDoc();
  publicProfile.name = "Wrong Name";

  assert.throws(
    () => validateSeedDocuments({
      docs: [
        {path: "users/runner-1", data: validUserProfileDoc()},
        {path: "publicProfiles/runner-1", data: publicProfile},
      ],
    }),
    /publicProfiles\/runner-1 projection mismatch/
  );
});

test("seed run validation rejects stale enum values before writes", () => {
  assert.throws(
    () => validateSeedDocuments({
      docs: [
        {
          path: "runs/run-1",
          data: {...validRunDoc(), pace: "walk"},
        },
      ],
    }),
    /runs\/run-1 failed schema validation/
  );
});

test("seed decision validation rejects stale reaction target types", () => {
  assert.throws(
    () => validateSeedDocuments({
      docs: [
        {
          path: "swipes/runner-1/outgoing/runner-2",
          data: {
            synthetic: true,
            seedPrefix: "demo_test",
            scenario: "schema-test",
            swiperId: "runner-1",
            targetId: "runner-2",
            runId: "run-1",
            direction: "like",
            reactionTargetType: "genericCard",
            createdAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
          },
        },
      ],
    }),
    /swipes\/runner-1\/outgoing\/runner-2 failed schema validation/
  );
});

test("seed document validation accepts valid social and payment docs", () => {
  const result = validateSeedDocuments({
    docs: [
      {path: "payments/pay-1", data: validPaymentDoc()},
      {path: "swipes/runner-1/outgoing/runner-2", data: validSwipeDoc()},
      {path: "matches/runner-1_runner-2", data: validMatchDoc()},
      {
        path: "matches/runner-1_runner-2/messages/message-1",
        data: validChatMessageDoc(),
      },
      {path: "reviews/run-1~runner-1", data: validReviewDoc()},
      {
        path: "notifications/runner-1/items/match_runner-1_runner-2",
        data: validActivityNotificationDoc(),
      },
    ],
  });

  assert.equal(result.payments, 1);
  assert.equal(result.swipes, 1);
  assert.equal(result.matches, 1);
  assert.equal(result.chatMessages, 1);
  assert.equal(result.reviews, 1);
  assert.equal(result.activityNotifications, 1);
});

test("seed document validation accepts schedule locks and seed manifests", () => {
  const result = validateSeedDocuments({
    docs: [
      {
        path: "runClubScheduleLocks/club-1_494080",
        data: validRunClubScheduleLockDoc(),
      },
      {
        path: "userRunScheduleLocks/runner-1_494080",
        data: validUserRunScheduleLockDoc(),
      },
    ],
    manifest: validSeedRunManifestDoc(),
  });

  assert.equal(result.runClubScheduleLocks, 1);
  assert.equal(result.userRunScheduleLocks, 1);
  assert.equal(result.seedManifests, 1);
});

test("seed document validation rejects stale schedule lock owners", () => {
  assert.throws(
    () => validateSeedDocuments({
      docs: [
        {
          path: "runClubScheduleLocks/club-1_494080",
          data: {...validRunClubScheduleLockDoc(), ownerType: "user"},
        },
      ],
    }),
    /runClubScheduleLocks\/club-1_494080 failed schema validation/
  );
});

function validPaymentDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    userId: "runner-1",
    orderId: "order-1",
    paymentId: "pay-1",
    runId: "run-1",
    amount: 29900,
    currency: "INR",
    status: "completed",
    signUpFailed: false,
    createdAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
  };
}

function validSwipeDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    swiperId: "runner-1",
    targetId: "runner-2",
    runId: "run-1",
    direction: "like",
    reactionTargetId: "prompt-perfectRun",
    reactionTargetType: "profilePrompt",
    reactionTargetLabel: "A perfect run with me looks like...",
    reactionTargetPreview: "Easy kilometres and coffee after.",
    comment: "This sounds like my kind of run.",
    createdAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
  };
}

function validMatchDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    user1Id: "runner-1",
    user2Id: "runner-2",
    runIds: ["run-1"],
    createdAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    lastMessageAt: null,
    lastMessagePreview: null,
    lastMessageSenderId: null,
    unreadCounts: {"runner-1": 0, "runner-2": 0},
    status: "active",
    blockedBy: null,
    blockedAt: null,
    participantIds: ["runner-1", "runner-2"],
  };
}

function validChatMessageDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    senderId: "runner-1",
    text: "Coffee after the weekend run?",
    imageUrl: null,
    sentAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
  };
}

function validReviewDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    runClubId: "club-1",
    runId: "run-1",
    reviewerUserId: "runner-1",
    reviewerName: "Runner One",
    rating: 5,
    comment: "Well organized run with clear pacing.",
    createdAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    updatedAt: null,
  };
}

function validActivityNotificationDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    uid: "runner-1",
    type: "match",
    title: "New catch",
    body: "Runner Two liked you back.",
    createdAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    readAt: null,
    matchId: "runner-1_runner-2",
    runId: "run-1",
    runClubId: null,
    actorUid: "runner-2",
    actorName: "Runner Two",
  };
}

function validUserProfileDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    name: "Runner One",
    firstName: "Runner",
    lastName: "One",
    displayName: "Runner One",
    dateOfBirth: fakeTimestamp(dateOfBirthIso),
    gender: "woman",
    phoneNumber: "+919900000001",
    profileComplete: true,
    email: "runner.one@example.test",
    profilePrompts: [validProfilePromptAnswer()],
    photoUrls: ["https://example.test/runner-one.jpg"],
    photoThumbnailUrls: ["https://example.test/runner-one-thumb.jpg"],
    photoPrompts: [validPhotoPromptAnswer()],
    profilePhotos: validProfilePhotos(),
    city: "mumbai",
    latitude: 19.076,
    longitude: 72.8777,
    interestedInGenders: ["man"],
    minAgePreference: 24,
    maxAgePreference: 40,
    height: 168,
    occupation: "Designer",
    company: "Stride Labs",
    education: "bachelors",
    religion: "nonReligious",
    languages: ["english", "hindi"],
    relationshipGoal: "relationship",
    drinking: "socially",
    smoking: "never",
    workout: "often",
    diet: "omnivore",
    children: "dontHave",
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 420,
    preferredDistances: ["fiveK", "tenK"],
    runningReasons: ["fitness", "social"],
    preferredRunTimes: ["morning"],
    prefsNewCatches: true,
    prefsMessages: true,
    prefsRunReminders: true,
    prefsRunStatusUpdates: true,
    prefsClubUpdates: true,
    prefsWeeklyDigest: false,
    prefsShowOnMap: true,
  };
}

function validPublicProfileDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    name: "Runner One",
    age: ageFromIso(dateOfBirthIso),
    gender: "woman",
    profilePrompts: [validProfilePromptAnswer()],
    photoUrls: ["https://example.test/runner-one.jpg"],
    photoThumbnailUrls: ["https://example.test/runner-one-thumb.jpg"],
    photoPrompts: [validPhotoPromptAnswer()],
    profilePhotos: validProfilePhotos(),
    city: "mumbai",
    height: 168,
    occupation: "Designer",
    company: "Stride Labs",
    education: "bachelors",
    religion: "nonReligious",
    languages: ["english", "hindi"],
    relationshipGoal: "relationship",
    drinking: "socially",
    smoking: "never",
    workout: "often",
    diet: "omnivore",
    children: "dontHave",
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 420,
    preferredDistances: ["fiveK", "tenK"],
    runningReasons: ["fitness", "social"],
    preferredRunTimes: ["morning"],
  };
}

function validRunClubDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    name: "Race Course Run Collective",
    description: "Social Indore runs for easy kilometres and coffee stops.",
    location: "indore",
    area: "Race Course Road",
    hostUserId: "runner-1",
    hostName: "Runner One",
    hostAvatarUrl: "https://example.test/runner-one.jpg",
    createdAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    imageUrl: "https://example.test/club.jpg",
    tags: ["social", "indore"],
    memberCount: 1,
    rating: 0,
    reviewCount: 0,
    nextRunAt: null,
    nextRunLabel: null,
    instagramHandle: "racecourseruns",
    phoneNumber: "+918800000001",
    email: "race.course@example.test",
    status: "active",
    archived: false,
    archivedAt: null,
    archiveReason: null,
  };
}

function validRunClubMembershipDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    clubId: "club-1",
    uid: "runner-1",
    role: "member",
    status: "active",
    pushNotificationsEnabled: true,
    joinedAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    leftAt: null,
    deletedAt: null,
  };
}

function validRunDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    runClubId: "club-1",
    startTime: fakeTimestamp("2026-05-20T01:30:00.000Z"),
    endTime: fakeTimestamp("2026-05-20T02:40:00.000Z"),
    meetingPoint: "Race Course Road gate",
    startingPointLat: 22.7196,
    startingPointLng: 75.8577,
    locationDetails: "Meet near the main gate.",
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 12,
    description: "Easy social 5K with coffee after.",
    priceInPaise: 0,
    bookedCount: 1,
    checkedInCount: 0,
    waitlistedCount: 0,
    status: "active",
    cancelledAt: null,
    cancellationReason: null,
    constraints: {
      minAge: 21,
      maxAge: 45,
      maxMen: 8,
      maxWomen: null,
    },
    genderCounts: {
      woman: 1,
    },
  };
}

function validRunParticipationDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    runId: "run-1",
    runClubId: "club-1",
    uid: "runner-1",
    status: "signedUp",
    createdAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    updatedAt: fakeTimestamp("2026-05-01T00:05:00.000Z"),
    signedUpAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    waitlistedAt: null,
    attendedAt: null,
    cancelledAt: null,
    deletedAt: null,
    genderAtSignup: "woman",
    paymentId: null,
  };
}

function validSavedRunDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    uid: "runner-1",
    runId: "run-1",
    savedAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    removedAt: null,
  };
}

function validRunClubScheduleLockDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    ownerType: "runClub",
    ownerId: "club-1",
    slot: 494080,
    runId: "run-1",
    runClubId: "club-1",
    startTimeMillis: 1778889600000,
    endTimeMillis: 1778893800000,
  };
}

function validUserRunScheduleLockDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    ownerType: "user",
    ownerId: "runner-1",
    slot: 494080,
    runId: "run-1",
    runClubId: "club-1",
    uid: "runner-1",
    startTimeMillis: 1778889600000,
    endTimeMillis: 1778893800000,
  };
}

function validSeedRunManifestDoc() {
  return {
    synthetic: true,
    seedPrefix: "demo_test",
    scenario: "schema-test",
    seedId: "demo_test_schema-test",
    manifestId: "demo_test_schema-test",
    generatedAt: fakeTimestamp("2026-05-01T00:00:00.000Z"),
    anchorUserIds: ["runner-1"],
    counts: {
      users: 1,
      publicProfiles: 1,
    },
    paths: ["users/runner-1", "publicProfiles/runner-1"],
  };
}

function validProfilePromptAnswer() {
  return {
    promptId: profilePrompt.id,
    prompt: profilePrompt.title,
    answer: "Easy kilometres, good coffee, and a relaxed chat.",
  };
}

function validPhotoPromptAnswer() {
  return {
    photoIndex: 0,
    promptId: photoPrompt.id,
    prompt: photoPrompt.title,
    caption: "Race day, before the nerves kicked in.",
  };
}

function validProfilePhotos() {
  return [{
    id: "runner_one_0",
    url: "https://example.test/runner-one.jpg",
    thumbnailUrl: "https://example.test/runner-one-thumb.jpg",
    storagePath: "users/legacy/photos/0.jpg",
    thumbnailStoragePath: "users/legacy/photoThumbnails/0.jpg",
    prompt: validPhotoPromptAnswer(),
    moderation: null,
    position: 0,
    createdAt: fakeTimestamp("1970-01-01T00:00:00.000Z"),
    updatedAt: fakeTimestamp("1970-01-01T00:00:00.000Z"),
  }];
}

function fakeTimestamp(iso) {
  const date = new Date(iso);
  return {
    toDate: () => date,
    toMillis: () => date.getTime(),
  };
}

function ageFromIso(iso) {
  const dob = new Date(iso);
  const now = new Date();
  let age = now.getFullYear() - dob.getFullYear();
  const monthDiff = now.getMonth() - dob.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && now.getDate() < dob.getDate())) {
    age -= 1;
  }
  return age;
}
