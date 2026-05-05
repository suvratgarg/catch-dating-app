const fs = require("node:fs");
const path = require("node:path");
const {after, before, beforeEach, describe, it} = require("node:test");
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {
  Timestamp,
  arrayRemove,
  arrayUnion,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  increment,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} = require("firebase/firestore");

const projectRoot = path.resolve(__dirname, "..", "..");
const firestoreRules = fs.readFileSync(
  path.join(projectRoot, "firestore.rules"),
  "utf8",
);

const projectId = "demo-catch-rules";

let testEnv;

function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function runClub(overrides = {}) {
  return {
    name: "Sunset Striders",
    description: "Easy city loops.",
    location: "mumbai",
    area: "Bandra",
    hostUserId: "host-1",
    hostName: "Priya",
    hostAvatarUrl: null,
    createdAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
    imageUrl: null,
    tags: [],
    memberUserIds: ["host-1"],
    memberCount: 1,
    rating: 0,
    reviewCount: 0,
    nextRunAt: null,
    nextRunLabel: null,
    ...overrides,
  };
}

function run(overrides = {}) {
  return {
    runClubId: "club-1",
    startTime: Timestamp.fromDate(new Date("2026-05-02T01:30:00.000Z")),
    endTime: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
    meetingPoint: "Carter Road",
    startingPointLat: null,
    startingPointLng: null,
    locationDetails: null,
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy seaside run.",
    priceInPaise: 0,
    signedUpUserIds: [],
    attendedUserIds: [],
    waitlistUserIds: [],
    constraints: {},
    genderCounts: {},
    ...overrides,
  };
}

function userProfile(overrides = {}) {
  return {
    name: "Runner One",
    email: "",
    bio: "",
    instagramHandle: null,
    phoneNumber: "+919999999999",
    dateOfBirth: Timestamp.fromDate(new Date("1998-01-01T00:00:00.000Z")),
    gender: "woman",
    profileComplete: true,
    photoUrls: [],
    city: "mumbai",
    latitude: null,
    longitude: null,
    joinedRunClubIds: [],
    savedRunIds: [],
    interestedInGenders: ["man"],
    minAgePreference: 24,
    maxAgePreference: 34,
    height: null,
    occupation: null,
    company: null,
    education: null,
    religion: null,
    languages: [],
    relationshipGoal: null,
    drinking: null,
    smoking: null,
    workout: null,
    diet: null,
    children: null,
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 420,
    preferredDistances: [],
    runningReasons: [],
    prefsNewCatches: true,
    prefsRunReminders: true,
    prefsWeeklyDigest: false,
    prefsShowOnMap: true,
    ...overrides,
  };
}

function match(overrides = {}) {
  return {
    user1Id: "runner-1",
    user2Id: "runner-2",
    participantIds: ["runner-1", "runner-2"],
    runId: "run-1",
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    lastMessageAt: null,
    lastMessagePreview: null,
    lastMessageSenderId: null,
    unreadCounts: { "runner-1": 2, "runner-2": 1 },
    status: "active",
    blockedBy: null,
    blockedAt: null,
    ...overrides,
  };
}

function swipe(overrides = {}) {
  return {
    swiperId: "runner-1",
    targetId: "runner-2",
    runId: "run-1",
    direction: "like",
    createdAt: serverTimestamp(),
    ...overrides,
  };
}

function review(overrides = {}) {
  return {
    runClubId: "club-1",
    runId: "run-1",
    reviewerUserId: "runner-1",
    reviewerName: "Runner One",
    rating: 5,
    comment: "Great run.",
    createdAt: Timestamp.fromDate(new Date("2026-05-02T05:00:00.000Z")),
    ...overrides,
  };
}

function runReviewId(runId, reviewerUserId) {
  return `${runId}~${reviewerUserId}`;
}

async function seed(pathSegments, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), ...pathSegments), data);
  });
}

describe("firestore.rules", () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId,
      firestore: {
        rules: firestoreRules,
        host: "127.0.0.1",
        port: 8080,
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  after(async () => {
    await testEnv.cleanup();
  });

  describe("runClubs", () => {
    it("denies direct club creates because creation is callable-owned", async () => {
      await assertFails(
        setDoc(doc(authedDb("host-1"), "runClubs", "club-1"), runClub()),
      );
    });

    it("allows hosts to update club profile fields only", async () => {
      await seed(["runClubs", "club-1"], runClub());

      await assertSucceeds(
        updateDoc(doc(authedDb("host-1"), "runClubs", "club-1"), {
          description: "Updated city loops.",
          tags: ["easy"],
          instagramHandle: "@sunsetstriders",
        }),
      );
    });

    it("rejects the older incomplete RunClub schema", async () => {
      const legacyClub = {
        name: "Legacy Club",
        description: "Old shape.",
        location: "mumbai",
        hostUserId: "host-1",
        createdAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
        imageUrl: null,
        memberUserIds: ["host-1"],
        rating: 0,
        reviewCount: 0,
      };

      await assertFails(
        setDoc(doc(authedDb("host-1"), "runClubs", "club-legacy"), legacyClub),
      );
    });

    it("denies direct member joins because membership is callable-owned", async () => {
      await seed(["runClubs", "club-1"], runClub());

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "runClubs", "club-1"),
          runClub({
            memberUserIds: ["host-1", "runner-1"],
            memberCount: 2,
          }),
        ),
      );
    });

    it("rejects member updates that tamper with club profile fields", async () => {
      await seed(["runClubs", "club-1"], runClub());

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "runClubs", "club-1"),
          runClub({
            hostName: "Mallory",
            memberUserIds: ["host-1", "runner-1"],
            memberCount: 2,
          }),
        ),
      );
    });

    it("rejects member updates with stale memberCount", async () => {
      await seed(["runClubs", "club-1"], runClub());

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "runClubs", "club-1"),
          runClub({
            memberUserIds: ["host-1", "runner-1"],
            memberCount: 1,
          }),
        ),
      );
    });

    it("denies direct member leaves because membership is callable-owned", async () => {
      await seed(
        ["runClubs", "club-1"],
        runClub({
          memberUserIds: ["host-1", "runner-1", "runner-2"],
          memberCount: 3,
        }),
      );

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "runClubs", "club-1"),
          runClub({
            memberUserIds: ["host-1", "runner-2"],
            memberCount: 2,
          }),
        ),
      );
    });

    it("rejects members removing another club member", async () => {
      await seed(
        ["runClubs", "club-1"],
        runClub({
          memberUserIds: ["host-1", "runner-1", "runner-2"],
          memberCount: 3,
        }),
      );

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "runClubs", "club-1"),
          runClub({
            memberUserIds: ["host-1", "runner-1"],
            memberCount: 2,
          }),
        ),
      );
    });

    it("denies joining via updateDoc with FieldValue operations", async () => {
      await seed(["runClubs", "club-1"], runClub());

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "runClubs", "club-1"), {
          memberUserIds: arrayUnion("runner-1"),
          memberCount: increment(1),
        }),
      );
    });

    it("denies leaving via updateDoc with FieldValue operations", async () => {
      await seed(
        ["runClubs", "club-1"],
        runClub({
          memberUserIds: ["host-1", "runner-1", "runner-2"],
          memberCount: 3,
        }),
      );

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "runClubs", "club-1"), {
          memberUserIds: arrayRemove("runner-1"),
          memberCount: increment(-1),
        }),
      );
    });

    it("denies direct club deletes", async () => {
      await seed(["runClubs", "club-1"], runClub());

      await assertFails(
        deleteDoc(doc(authedDb("host-1"), "runClubs", "club-1")),
      );
    });
  });

  describe("public config", () => {
    it("allows public reads of config/cities and denies other config docs", async () => {
      await seed(["config", "cities"], {
        cityNames: ["mumbai", "indore"],
        cities: [],
      });
      await seed(["config", "private"], {secret: true});

      await assertSucceeds(getDoc(doc(testEnv.unauthenticatedContext().firestore(), "config", "cities")));
      await assertFails(getDoc(doc(authedDb("runner-1"), "config", "private")));
    });
  });

  describe("users", () => {
    it("allows owners to create the current UserProfile schema without legacy sexualOrientation", async () => {
      await assertSucceeds(
        setDoc(doc(authedDb("runner-1"), "users", "runner-1"), userProfile()),
      );
    });

    it("denies direct profile edits but allows runtime FCM token updates", async () => {
      await seed(["users", "runner-1"], userProfile());

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          instagramHandle: "@runnerone",
          prefsWeeklyDigest: true,
        }),
      );
      await assertSucceeds(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          fcmToken: "token-1",
        }),
      );
    });

    it("tolerates retained server-owned lifecycle fields on profile updates", async () => {
      await seed(["users", "runner-1"], userProfile({
        deleted: false,
        deletedAt: null,
      }));

      await assertSucceeds(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          fcmToken: "token-1",
        }),
      );
    });

    it("denies direct profile field updates regardless of field shape", async () => {
      await seed(["users", "runner-1"], userProfile());
      const userRef = doc(authedDb("runner-1"), "users", "runner-1");

      await assertFails(updateDoc(userRef, {name: "Runner Updated"}));
      await assertFails(updateDoc(userRef, {photoUrls: ["https://example.test/a.jpg"]}));
      await assertFails(updateDoc(userRef, {prefsWeeklyDigest: true}));
      await assertFails(updateDoc(userRef, {dateOfBirth: "1998-01-01"}));
    });

    it("denies direct joined club projection changes", async () => {
      await seed(["users", "runner-1"], userProfile({
        joinedRunClubIds: ["club-1"],
      }));

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          joinedRunClubIds: arrayUnion("club-2"),
        }),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          joinedRunClubIds: ["club-9", "club-10", "club-11"],
        }),
      );
    });

    it("denies client writes to account-deletion lifecycle fields", async () => {
      await seed(["users", "runner-1"], userProfile());

      await assertFails(
        setDoc(doc(authedDb("runner-2"), "users", "runner-2"), userProfile({
          deleted: false,
        })),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          deleted: true,
        }),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          deletedAt: serverTimestamp(),
        }),
      );
    });

    it("denies owner updates after account-deletion tombstone exists", async () => {
      await seed(["users", "runner-1"], userProfile({
        deleted: true,
        deletedAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
      }));
      await seed(["deletedUsers", "runner-1"], {
        uid: "runner-1",
        deletedAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
      });

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          prefsWeeklyDigest: true,
        }),
      );
    });
  });

  describe("onboarding drafts", () => {
    it("allows only the owner to read, write, and delete their draft", async () => {
      const draft = {
        step: 2,
        draftVersion: 0,
        firstName: "Runner",
        lastName: "One",
        dateOfBirth: null,
        phoneNumber: "9999999999",
        countryCode: "+91",
        gender: "woman",
        interestedInGenders: ["man"],
        instagramHandle: null,
      };

      await assertSucceeds(
        setDoc(doc(authedDb("runner-1"), "onboarding_drafts", "runner-1"), draft),
      );
      await assertSucceeds(
        setDoc(doc(authedDb("runner-1"), "onboarding_drafts", "runner-1"), {
          ...draft,
          futureStepPayload: {canEvolveWithoutRulesDeploy: true},
        }),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "onboarding_drafts", "runner-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-2"), "onboarding_drafts", "runner-1")),
      );
      await assertSucceeds(
        deleteDoc(doc(authedDb("runner-1"), "onboarding_drafts", "runner-1")),
      );
    });
  });

  describe("chat and match writes", () => {
    it("allows participants to create messages but keeps match previews server-owned", async () => {
      await seed(["matches", "match-1"], match());

      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-1"), "chats", "match-1", "messages", "message-1"),
          {
            senderId: "runner-1",
            text: "hello",
            sentAt: serverTimestamp(),
          },
        ),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "matches", "match-1"), {
          lastMessagePreview: "client-owned preview",
        }),
      );
    });

    it("denies messages from non-participants and blocked matches", async () => {
      await seed(["matches", "match-1"], match());
      await seed(["matches", "blocked-match"], match({status: "blocked"}));

      await assertFails(
        setDoc(
          doc(authedDb("runner-3"), "chats", "match-1", "messages", "message-1"),
          {
            senderId: "runner-3",
            text: "hello",
            sentAt: serverTimestamp(),
          },
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "chats", "blocked-match", "messages", "message-1"),
          {
            senderId: "runner-1",
            text: "hello",
            sentAt: serverTimestamp(),
          },
        ),
      );
    });

    it("allows participants to reset only their own unread count", async () => {
      await seed(["matches", "match-1"], match());

      await assertSucceeds(
        updateDoc(doc(authedDb("runner-1"), "matches", "match-1"), {
          "unreadCounts.runner-1": 0,
        }),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "matches", "match-1"), {
          "unreadCounts.runner-2": 0,
        }),
      );
    });
  });

  describe("swipes", () => {
    it("allows attended users to create valid outgoing swipes", async () => {
      await seed(["publicProfiles", "runner-2"], {name: "Runner Two"});
      await seed(["runs", "run-1"], run({
        attendedUserIds: ["runner-1", "runner-2"],
      }));

      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-1"), "swipes", "runner-1", "outgoing", "runner-2"),
          swipe(),
        ),
      );
    });

    it("denies malformed swipe payloads", async () => {
      await seed(["publicProfiles", "runner-2"], {name: "Runner Two"});
      await seed(["runs", "run-1"], run({
        attendedUserIds: ["runner-1", "runner-2"],
      }));

      const swipeRef = doc(
        authedDb("runner-1"),
        "swipes",
        "runner-1",
        "outgoing",
        "runner-2",
      );

      await assertFails(setDoc(swipeRef, swipe({swiperId: "runner-3"})));
      await assertFails(setDoc(swipeRef, swipe({targetId: "runner-3"})));
      await assertFails(setDoc(swipeRef, swipe({direction: "superlike"})));
      await assertFails(setDoc(swipeRef, swipe({runId: 123})));
      await assertFails(setDoc(swipeRef, {...swipe(), extraField: true}));
    });

    it("denies swipes outside the eligible run candidate relationship", async () => {
      await seed(["publicProfiles", "runner-1"], {name: "Runner One"});
      await seed(["publicProfiles", "runner-2"], {name: "Runner Two"});
      await seed(["publicProfiles", "runner-3"], {name: "Runner Three"});
      await seed(["runs", "run-1"], run({
        attendedUserIds: ["runner-1", "runner-2"],
      }));
      await seed(["runs", "run-2"], run({
        attendedUserIds: ["runner-1"],
      }));

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "swipes", "runner-1", "outgoing", "runner-1"),
          swipe({targetId: "runner-1"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "swipes", "runner-1", "outgoing", "runner-3"),
          swipe({targetId: "runner-3"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "swipes", "runner-1", "outgoing", "runner-2"),
          swipe({runId: "run-2"}),
        ),
      );

      await seed(["blocks", "runner-2__runner-1"], {
        blockerUserId: "runner-2",
        blockedUserId: "runner-1",
      });
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "swipes", "runner-1", "outgoing", "runner-2"),
          swipe(),
        ),
      );
    });
  });

  describe("reviews", () => {
    it("allows attended users to create deterministic run reviews", async () => {
      await seed(["runClubs", "club-1"], runClub());
      await seed(["users", "runner-1"], userProfile());
      await seed(["runs", "run-1"], run({
        attendedUserIds: ["runner-1"],
      }));

      await assertSucceeds(
        setDoc(
          doc(
            authedDb("runner-1"),
            "reviews",
            runReviewId("run-1", "runner-1"),
          ),
          review(),
        ),
      );
    });

    it("denies malformed or non-attendee run review creates", async () => {
      await seed(["runClubs", "club-1"], runClub());
      await seed(["users", "runner-1"], userProfile());
      await seed(["users", "runner-2"], userProfile({
        name: "Runner Two",
      }));
      await seed(["runs", "run-1"], run({
        attendedUserIds: ["runner-1"],
      }));

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "reviews", "random-review"),
          review(),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "reviews",
            runReviewId("run-1", "runner-1"),
          ),
          review({runId: null}),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "reviews",
            runReviewId("run-1", "runner-1"),
          ),
          review({reviewerName: "Not Runner One"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-2"),
            "reviews",
            runReviewId("run-1", "runner-2"),
          ),
          review({
            reviewerUserId: "runner-2",
            reviewerName: "Runner Two",
          }),
        ),
      );
    });

    it("allows authors to update or delete only their own review content", async () => {
      await seed(
        ["reviews", runReviewId("run-1", "runner-1")],
        review(),
      );
      await seed(
        ["reviews", runReviewId("run-1", "runner-2")],
        review({
          reviewerUserId: "runner-2",
          reviewerName: "Runner Two",
        }),
      );

      const ownReviewRef = doc(
        authedDb("runner-1"),
        "reviews",
        runReviewId("run-1", "runner-1"),
      );

      await assertSucceeds(
        updateDoc(ownReviewRef, {
          rating: 4,
          comment: "Updated review.",
          updatedAt: serverTimestamp(),
        }),
      );
      await assertFails(updateDoc(ownReviewRef, {runId: "run-2"}));
      await assertFails(
        updateDoc(
          doc(
            authedDb("runner-1"),
            "reviews",
            runReviewId("run-1", "runner-2"),
          ),
          {
            rating: 1,
            comment: "Tampered review.",
            updatedAt: serverTimestamp(),
          },
        ),
      );
      await assertSucceeds(deleteDoc(ownReviewRef));
    });
  });

  describe("runs", () => {
    it("denies direct run creates because creation is callable-owned", async () => {
      await seed(["runClubs", "club-1"], runClub());

      await assertFails(
        setDoc(doc(authedDb("host-1"), "runs", "run-new"), run()),
      );
    });

    it("denies direct host run detail edits because updates are callable-owned", async () => {
      await seed(["runClubs", "club-1"], runClub());
      await seed(["runs", "run-1"], run());

      await assertFails(
        updateDoc(doc(authedDb("host-1"), "runs", "run-1"), {
          startTime: Timestamp.fromDate(new Date("2026-05-02T02:00:00.000Z")),
          endTime: Timestamp.fromDate(new Date("2026-05-02T03:00:00.000Z")),
          meetingPoint: "Joggers Park gate",
          startingPointLat: 19.0701,
          startingPointLng: 72.8267,
          locationDetails: "Meet by the main entrance.",
          distanceKm: 6,
          pace: "moderate",
          description: "Updated route and timing.",
        }),
      );
    });

    it("denies hosts changing booking-sensitive or ownership run fields", async () => {
      await seed(["runClubs", "club-1"], runClub());
      await seed(["runs", "run-1"], run({
        waitlistUserIds: ["runner-1"],
      }));

      const runRef = doc(authedDb("host-1"), "runs", "run-1");

      await assertFails(updateDoc(runRef, {waitlistUserIds: ["runner-2"]}));
      await assertFails(updateDoc(runRef, {runClubId: "club-2"}));
      await assertFails(updateDoc(runRef, {capacityLimit: 50}));
      await assertFails(updateDoc(runRef, {priceInPaise: 10000}));
      await assertFails(updateDoc(runRef, {constraints: {gender: "woman"}}));
      await assertFails(updateDoc(runRef, {signedUpUserIds: ["runner-1"]}));
      await assertFails(updateDoc(runRef, {attendedUserIds: ["runner-1"]}));
      await assertFails(updateDoc(runRef, {genderCounts: {woman: 1}}));
    });

    it("allows waitlisted users to remove themselves", async () => {
      await seed(["runs", "run-1"], run({
        waitlistUserIds: ["runner-1", "runner-2"],
      }));

      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-1"), "runs", "run-1"),
          run({waitlistUserIds: ["runner-2"]}),
        ),
      );
    });

    it("rejects waitlisted users removing another waitlisted user", async () => {
      await seed(["runs", "run-1"], run({
        waitlistUserIds: ["runner-1", "runner-2"],
      }));

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "runs", "run-1"),
          run({waitlistUserIds: ["runner-1"]}),
        ),
      );
    });

    it("denies direct run deletes", async () => {
      await seed(["runClubs", "club-1"], runClub());
      await seed(["runs", "run-1"], run());

      await assertFails(
        deleteDoc(doc(authedDb("host-1"), "runs", "run-1")),
      );
    });
  });

  describe("safety privacy rules", () => {
    it("denies profile reads after either user blocks the other", async () => {
      await seed(["users", "target-1"], {name: "Target"});
      await seed(["publicProfiles", "target-1"], {name: "Target"});
      await seed(["blocks", "target-1__viewer-1"], {
        blockerUserId: "target-1",
        blockedUserId: "viewer-1",
      });

      await assertFails(getDoc(doc(authedDb("viewer-1"), "users", "target-1")));
      await assertFails(
        getDoc(doc(authedDb("viewer-1"), "publicProfiles", "target-1")),
      );
    });

    it("denies reads for deleted private and public profiles", async () => {
      await seed(["users", "target-1"], {name: "Target"});
      await seed(["publicProfiles", "target-1"], {name: "Target"});
      await seed(["deletedUsers", "target-1"], {
        uid: "target-1",
        deletedAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
      });

      await assertFails(getDoc(doc(authedDb("viewer-1"), "users", "target-1")));
      await assertFails(
        getDoc(doc(authedDb("viewer-1"), "publicProfiles", "target-1")),
      );
    });

    it("allows users to read only block edges involving themselves", async () => {
      await seed(["blocks", "user-1__user-2"], {
        blockerUserId: "user-1",
        blockedUserId: "user-2",
      });

      await assertSucceeds(
        getDoc(doc(authedDb("user-1"), "blocks", "user-1__user-2")),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("user-2"), "blocks", "user-1__user-2")),
      );
      await assertFails(
        getDoc(doc(authedDb("user-3"), "blocks", "user-1__user-2")),
      );
    });

    it("keeps reports, deletion tombstones, and event receipts server-owned", async () => {
      await seed(["reports", "report-1"], {reportedUserId: "target-1"});
      await seed(["deletedUsers", "target-1"], {uid: "target-1"});
      await seed(["functionEventReceipts", "event-1"], {
        handler: "onMessageCreated",
      });

      await assertFails(getDoc(doc(authedDb("user-1"), "reports", "report-1")));
      await assertFails(
        setDoc(doc(authedDb("user-1"), "reports", "report-2"), {
          reportedUserId: "target-1",
        }),
      );
      await assertFails(
        getDoc(doc(authedDb("target-1"), "deletedUsers", "target-1")),
      );
      await assertFails(
        deleteDoc(doc(authedDb("target-1"), "deletedUsers", "target-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("user-1"), "functionEventReceipts", "event-1")),
      );
      await assertFails(
        setDoc(doc(authedDb("user-1"), "functionEventReceipts", "event-2"), {
          handler: "onMessageCreated",
        }),
      );
    });

    it("hides blocked matches from participants", async () => {
      await seed(["matches", "match-1"], {
        user1Id: "user-1",
        user2Id: "user-2",
        participantIds: ["user-1", "user-2"],
        status: "blocked",
      });

      await assertFails(getDoc(doc(authedDb("user-1"), "matches", "match-1")));
    });

    it("allows participants to query their active matches by user fields", async () => {
      await seed(["matches", "match-1"], {
        user1Id: "user-1",
        user2Id: "user-2",
        participantIds: ["user-1", "user-2"],
        status: "active",
        createdAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
      });

      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("user-1"), "matches"),
            where("user1Id", "==", "user-1"),
            where("status", "==", "active"),
            orderBy("createdAt", "desc"),
          ),
        ),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("user-2"), "matches"),
            where("user2Id", "==", "user-2"),
            where("status", "==", "active"),
            orderBy("createdAt", "desc"),
          ),
        ),
      );
      await assertFails(
        getDocs(
          query(
            collection(authedDb("user-3"), "matches"),
            where("user1Id", "==", "user-1"),
            where("status", "==", "active"),
            orderBy("createdAt", "desc"),
          ),
        ),
      );
    });
  });

});
