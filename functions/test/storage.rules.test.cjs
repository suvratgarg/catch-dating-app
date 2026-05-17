const fs = require("node:fs");
const path = require("node:path");
const {after, before, beforeEach, describe, it} = require("node:test");
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {Timestamp, doc, setDoc} = require("firebase/firestore");

const projectRoot = path.resolve(__dirname, "..", "..");
const firestoreRules = fs.readFileSync(
  path.join(projectRoot, "firestore.rules"),
  "utf8",
);
const storageRules = fs.readFileSync(
  path.join(projectRoot, "storage.rules"),
  "utf8",
);

const projectId = "demo-catch-rules";
const bucketUrl = `gs://${projectId}.appspot.com`;

let testEnv;

function authedStorage(uid) {
  return testEnv.authenticatedContext(uid).storage(bucketUrl);
}

function unauthenticatedStorage() {
  return testEnv.unauthenticatedContext().storage(bucketUrl);
}

function match(overrides = {}) {
  return {
    user1Id: "runner-1",
    user2Id: "runner-2",
    eventIds: ["event-1"],
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    lastMessageAt: null,
    lastMessagePreview: null,
    lastMessageSenderId: null,
    unreadCounts: {"runner-1": 0, "runner-2": 0},
    status: "active",
    blockedBy: null,
    blockedAt: null,
    ...overrides,
  };
}

function club(overrides = {}) {
  return {
    hostUserId: "host-1",
    ...overrides,
  };
}

async function seedFirestore(pathSegments, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), ...pathSegments), data);
  });
}

async function seedStorageFile(objectPath) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context
      .storage(bucketUrl)
      .ref(objectPath)
      .putString("seeded", "raw", {contentType: "image/jpeg"});
  });
}

function uploadImage(storage, objectPath, {contentType = "image/jpeg"} = {}) {
  return storage
    .ref(objectPath)
    .putString("image-bytes", "raw", {contentType});
}

describe("storage.rules", () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId,
      firestore: {
        rules: firestoreRules,
        host: "127.0.0.1",
        port: 8080,
      },
      storage: {
        rules: storageRules,
        host: "127.0.0.1",
        port: 9199,
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await testEnv.clearStorage();
  });

  after(async () => {
    await testEnv.cleanup();
  });

  describe("chat images", () => {
    it("allows active match participants to upload using user1Id/user2Id", async () => {
      await seedFirestore(["matches", "match-1"], match());

      await assertSucceeds(
        uploadImage(
          authedStorage("runner-1"),
          "matches/match-1/images/message-1_123.jpg",
        ),
      );
      await assertSucceeds(
        uploadImage(
          authedStorage("runner-2"),
          "matches/match-1/images/message-2_123.jpg",
        ),
      );
    });

    it("keeps legacy participantIds working during data backfill", async () => {
      await seedFirestore(
        ["matches", "legacy-match"],
        match({
          user1Id: null,
          user2Id: null,
          participantIds: ["runner-1", "runner-2"],
        }),
      );

      await assertSucceeds(
        uploadImage(
          authedStorage("runner-1"),
          "matches/legacy-match/images/message-1_123.jpg",
        ),
      );
    });

    it("denies non-participants, blocked matches, anonymous users, and non-images", async () => {
      await seedFirestore(["matches", "match-1"], match());
      await seedFirestore(
        ["matches", "blocked-match"],
        match({status: "blocked"}),
      );

      await assertFails(
        uploadImage(
          authedStorage("runner-3"),
          "matches/match-1/images/message-1_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "matches/blocked-match/images/message-1_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          unauthenticatedStorage(),
          "matches/match-1/images/message-1_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "matches/match-1/images/message-1_123.txt",
          {contentType: "text/plain"},
        ),
      );
    });

    it("allows only participants to read chat images", async () => {
      await seedFirestore(["matches", "match-1"], match());
      await seedStorageFile("matches/match-1/images/message-1_123.jpg");

      await assertSucceeds(
        authedStorage("runner-2")
          .ref("matches/match-1/images/message-1_123.jpg")
          .getMetadata(),
      );
      await assertFails(
        authedStorage("runner-3")
          .ref("matches/match-1/images/message-1_123.jpg")
          .getMetadata(),
      );
    });
  });

  describe("event photos", () => {
    it("allows only the club host to upload event photos", async () => {
      await seedFirestore(["clubs", "club-1"], club());

      await assertSucceeds(
        uploadImage(
          authedStorage("host-1"),
          "clubs/club-1/events/event-1/photo.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "clubs/club-1/events/event-1/photo.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          unauthenticatedStorage(),
          "clubs/club-1/events/event-1/photo.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("host-1"),
          "clubs/club-1/events/event-1/photo.txt",
          {contentType: "text/plain"},
        ),
      );
    });
  });
});
