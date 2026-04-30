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
  deleteDoc,
  doc,
  getDoc,
  setDoc,
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
    it("allows hosts to create the current RunClub schema", async () => {
      await assertSucceeds(
        setDoc(doc(authedDb("host-1"), "runClubs", "club-1"), runClub()),
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

    it("allows members to join when memberCount matches memberUserIds", async () => {
      await seed(["runClubs", "club-1"], runClub());

      await assertSucceeds(
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

    it("keeps reports and deletion tombstones server-owned", async () => {
      await seed(["reports", "report-1"], {reportedUserId: "target-1"});
      await seed(["deletedUsers", "target-1"], {uid: "target-1"});

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
    });

    it("hides blocked matches from participants", async () => {
      await seed(["matches", "match-1"], {
        user1Id: "user-1",
        user2Id: "user-2",
        status: "blocked",
      });

      await assertFails(getDoc(doc(authedDb("user-1"), "matches", "match-1")));
    });
  });

  describe("app config", () => {
    it("allows unauthenticated clients to read the force-update config", async () => {
      await seed(["config", "app_config"], {
        minimumSupportedVersion: "1.0.0",
        latestVersion: "1.0.0",
      });

      await assertSucceeds(
        getDoc(
          doc(
            testEnv.unauthenticatedContext().firestore(),
            "config",
            "app_config",
          ),
        ),
      );
    });

    it("does not expose other config documents", async () => {
      await seed(["config", "internal_flags"], {
        enabled: true,
      });

      await assertFails(
        getDoc(
          doc(
            testEnv.unauthenticatedContext().firestore(),
            "config",
            "internal_flags",
          ),
        ),
      );
      await assertFails(
        getDoc(doc(authedDb("user-1"), "config", "internal_flags")),
      );
    });
  });
});
