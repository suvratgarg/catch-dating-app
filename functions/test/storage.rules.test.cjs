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

function uploadImage(
  storage,
  objectPath,
  {contentType = "image/jpeg", data = "image-bytes"} = {},
) {
  return storage
    .ref(objectPath)
    .putString(data, "raw", {contentType});
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
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "matches/match-1/images/message-1.jpg",
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

    it("denies participants from reading chat images for blocked matches", async () => {
      await seedFirestore(
        ["matches", "blocked-match"],
        match({status: "blocked"}),
      );
      await seedFirestore(["matches", "blocked-by-doc"], match());
      await seedFirestore(["blocks", "runner-1__runner-2"], {
        blockerUserId: "runner-1",
        blockedUserId: "runner-2",
        createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
      });
      await seedStorageFile("matches/blocked-match/images/message-1_123.jpg");
      await seedStorageFile("matches/blocked-by-doc/images/message-1_123.jpg");

      await assertFails(
        authedStorage("runner-1")
          .ref("matches/blocked-match/images/message-1_123.jpg")
          .getMetadata(),
      );
      await assertFails(
        authedStorage("runner-2")
          .ref("matches/blocked-by-doc/images/message-1_123.jpg")
          .getMetadata(),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "matches/blocked-by-doc/images/message-2_123.jpg",
        ),
      );
    });
  });

  describe("profile photos", () => {
    it("allows owner uploads with valid filenames and the exact max size", async () => {
      const maxImageBytes = 8 * 1024 * 1024;

      await assertSucceeds(
        uploadImage(
          authedStorage("runner-1"),
          "users/runner-1/photos/0_123.jpg",
          {data: "a".repeat(maxImageBytes)},
        ),
      );
    });

    it("denies invalid profile photo writes", async () => {
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "users/runner-2/photos/0_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "users/runner-1/photos/6_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "users/runner-1/photos/avatar_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "users/runner-1/photos/1_123.jpg",
          {data: "a".repeat((8 * 1024 * 1024) + 1)},
        ),
      );
    });
  });

  describe("hosted media staging", () => {
    it("denies new client uploads to hosted media", async () => {
      await assertFails(
        uploadImage(
          authedStorage("host-1"),
          "users/host-1/hostedMedia/club_club-1_profile_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "users/host-1/hostedMedia/club_club-1_profile_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          unauthenticatedStorage(),
          "users/host-1/hostedMedia/club_club-1_profile_123.jpg",
        ),
      );
    });

    it("allows public reads for hosted club and event media", async () => {
      await seedStorageFile(
        "users/host-1/hostedMedia/event_club-1_event-1_123.jpg",
      );

      await assertSucceeds(
        unauthenticatedStorage()
          .ref("users/host-1/hostedMedia/event_club-1_event-1_123.jpg")
          .getMetadata(),
      );
    });

    it("denies retired legacy club and event media paths", async () => {
      await assertFails(
        uploadImage(authedStorage("host-1"), "clubs/club-1/profile.jpg"),
      );
      await assertFails(
        uploadImage(
          authedStorage("host-1"),
          "clubs/club-1/events/event-1/photo.jpg",
        ),
      );
    });
  });

  describe("club and event media", () => {
    it("allows club hosts to upload club photos and logos", async () => {
      await seedFirestore(["clubs", "club-1"], {
        hostUserId: "owner-1",
        ownerUserId: "owner-1",
        hostUserIds: ["owner-1", "host-1"],
      });

      await assertSucceeds(
        uploadImage(authedStorage("host-1"), "clubs/club-1/photos/0_123.jpg"),
      );
      await assertSucceeds(
        uploadImage(authedStorage("owner-1"), "clubs/club-1/logo/123.jpg"),
      );
      await assertFails(
        uploadImage(authedStorage("runner-1"), "clubs/club-1/photos/0_123.jpg"),
      );
      await assertFails(
        uploadImage(
          authedStorage("host-1"),
          "clubs/club-1/logo/123.txt",
          {contentType: "text/plain"},
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("host-1"),
          "clubs/club-1/photos/6_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("owner-1"),
          "clubs/club-1/logo/logo_123.jpg",
        ),
      );
    });

    it("allows event club hosts to upload event photos after event creation", async () => {
      await seedFirestore(["clubs", "club-1"], {
        hostUserId: "owner-1",
        ownerUserId: "owner-1",
        hostUserIds: ["owner-1", "host-1"],
      });
      await seedFirestore(["events", "event-1"], {clubId: "club-1"});

      await assertSucceeds(
        uploadImage(authedStorage("host-1"), "events/event-1/photos/0_123.jpg"),
      );
      await assertFails(
        uploadImage(
          authedStorage("host-1"),
          "events/missing-event/photos/0_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("runner-1"),
          "events/event-1/photos/0_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("host-1"),
          "events/event-1/photos/6_123.jpg",
        ),
      );
      await assertFails(
        uploadImage(
          authedStorage("host-1"),
          "events/event-1/photos/photo_123.jpg",
        ),
      );
    });

    it("allows public reads for club logos and event photos", async () => {
      await seedStorageFile("clubs/club-1/logo/123.jpg");
      await seedStorageFile("clubs/club-1/logoThumbnails/123.jpg");
      await seedStorageFile("events/event-1/photos/0_123.jpg");

      await assertSucceeds(
        unauthenticatedStorage().ref("clubs/club-1/logo/123.jpg").getMetadata(),
      );
      await assertSucceeds(
        unauthenticatedStorage()
          .ref("clubs/club-1/logoThumbnails/123.jpg")
          .getMetadata(),
      );
      await assertSucceeds(
        unauthenticatedStorage()
          .ref("events/event-1/photos/0_123.jpg")
          .getMetadata(),
      );
    });
  });
});
