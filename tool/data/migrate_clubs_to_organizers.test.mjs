import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  applyStorageMigrationPlan,
  buildClubsToOrganizersPlan,
  buildStorageMigrationPlan,
  canonicalOrganizerDocument,
  canonicalOrganizerType,
  resolveStorageBucket,
  resolveBackupFile,
} from "./migrate_clubs_to_organizers.mjs";

const timestamp = {seconds: 1, nanoseconds: 0};

function entry(path, data) {
  return {id: path.split("/").at(-1), path, data};
}

function inventory(overrides = {}) {
  return {
    collections: {
      clubs: [],
      organizers: [],
      clubMemberships: [],
      organizerTeamMemberships: [],
      organizerFollows: [],
      clubHostClaims: [],
      clubClaimRequests: [],
      organizerClaimRequests: [],
      clubScheduleLocks: [],
      organizerScheduleLocks: [],
      publicRouteReservations: [],
      ...overrides,
    },
    notificationItems: [],
    clubPosts: [],
    organizerPosts: [],
  };
}

test("canonical organizer type maps legacy values and defaults to club", () => {
  assert.equal(canonicalOrganizerType({}), "club");
  assert.equal(
    canonicalOrganizerType({entityKind: "creatorCommunity"}),
    "community"
  );
  assert.equal(
    canonicalOrganizerType({entityKind: "eventOrganizer"}),
    "eventProducer"
  );
  assert.equal(canonicalOrganizerType({organizerType: "individual"}), "individual");
});

test("storage bucket resolution supports environment config and override", () => {
  assert.equal(resolveStorageBucket({
    env: "dev",
    projectId: "catchdates-dev",
  }), "catchdates-dev.firebasestorage.app");
  assert.equal(resolveStorageBucket({
    projectId: "custom-project",
  }), "custom-project.firebasestorage.app");
  assert.equal(resolveStorageBucket({
    env: "dev",
    projectId: "catchdates-dev",
    storageBucket: "explicit.appspot.com",
  }), "explicit.appspot.com");
});

test("backup path must be in an existing directory outside the repository", () => {
  const sandbox = fs.mkdtempSync(path.join(os.tmpdir(), "organizer-backup-"));
  const root = path.join(sandbox, "repo");
  const secure = path.join(sandbox, "secure");
  const shared = path.join(sandbox, "shared");
  fs.mkdirSync(root);
  fs.mkdirSync(secure, {mode: 0o700});
  fs.mkdirSync(shared, {mode: 0o755});
  fs.chmodSync(secure, 0o700);
  fs.chmodSync(shared, 0o755);

  assert.equal(
    resolveBackupFile(path.join(secure, "backup.json"), {root}),
    path.join(fs.realpathSync(secure), "backup.json")
  );
  assert.throws(
    () => resolveBackupFile(path.join(root, "backup.json"), {root}),
    /outside the repository/u
  );
  assert.throws(
    () => resolveBackupFile(path.join(sandbox, "missing", "backup.json"), {root}),
    /must already exist/u
  );
  if (process.platform !== "win32") {
    assert.throws(
      () => resolveBackupFile(path.join(shared, "backup.json"), {root}),
      /owner-restricted/u
    );
  }
});

test("canonical organizer document writes canonical aliases and route", () => {
  const organizer = canonicalOrganizerDocument("run-club", {
    name: "Run Club",
    clubPhotos: [{id: "photo-1"}],
    memberCount: 12,
    entityKind: "club",
    createdAt: timestamp,
    ownerUserId: "owner-1",
    publicPage: {canonicalPath: "/clubs/run-club"},
  });
  assert.equal(organizer.organizerType, "club");
  assert.equal(organizer.followerCount, 12);
  assert.deepEqual(organizer.organizerPhotos, [{id: "photo-1"}]);
  assert.equal(organizer.publicPage.canonicalPath, "/organizers/run-club/");
  assert.equal(organizer.organizerTypeUpdatedByUid, "owner-1");
});

test("plan splits host/member edges and patches dependent references", () => {
  const sourceClub = entry("clubs/club-1", {
    name: "Club One",
    clubPhotos: [],
    memberCount: 2,
    createdAt: timestamp,
    hostUserId: "owner-1",
  });
  const plan = buildClubsToOrganizersPlan(inventory({
    clubs: [sourceClub],
    clubMemberships: [
      entry("clubMemberships/club-1_owner-1", {
        clubId: "club-1",
        uid: "owner-1",
        role: "owner",
        status: "active",
        joinedAt: timestamp,
        leftAt: null,
        deletedAt: null,
      }),
      entry("clubMemberships/club-1_member-1", {
        clubId: "club-1",
        uid: "member-1",
        role: "member",
        status: "active",
        pushNotificationsEnabled: false,
        joinedAt: timestamp,
        leftAt: null,
        deletedAt: null,
      }),
    ],
    events: [entry("events/event-1", {clubId: "club-1"})],
  }));

  assert.equal(plan.blockers.length, 0);
  const writes = new Map(plan.writes.map((write) => [write.targetPath, write]));
  assert.equal(
    writes.get("organizerTeamMemberships/club-1_owner-1").data.role,
    "owner"
  );
  assert.equal(
    writes.get("organizerFollows/club-1_member-1").data.status,
    "active"
  );
  assert.deepEqual(writes.get("events/event-1").data, {organizerId: "club-1"});
});

test("plan blocks conflicting target authority instead of overwriting", () => {
  const source = entry("clubs/club-1", {
    name: "Source name",
    clubPhotos: [],
    memberCount: 0,
    createdAt: timestamp,
  });
  const target = entry("organizers/club-1", {
    ...canonicalOrganizerDocument("club-1", source.data),
    name: "Target name",
  });
  const plan = buildClubsToOrganizersPlan(inventory({
    clubs: [source],
    organizers: [target],
  }));
  assert.equal(plan.writes.length, 0);
  assert.equal(plan.blockers.length, 1);
  assert.match(plan.blockers[0].reasons.join(" "), /name differs/);
});

test("plan is idempotent when canonical target and reference already match", () => {
  const source = entry("clubs/club-1", {
    name: "Source name",
    clubPhotos: [],
    memberCount: 0,
    createdAt: timestamp,
  });
  const target = entry(
    "organizers/club-1",
    canonicalOrganizerDocument("club-1", source.data)
  );
  const plan = buildClubsToOrganizersPlan(inventory({
    clubs: [source],
    organizers: [target],
  }));
  assert.equal(plan.writes.length, 0);
  assert.equal(plan.blockers.length, 0);
});

test("storage plan copies missing targets and accepts checksum parity", async () => {
  const bucket = fakeBucket({
    "clubs/club-1/logo/logo.png": {crc32c: "same"},
    "clubs/club-1/photos/one.jpg": {crc32c: "copy-me"},
    "organizers/club-1/logo/logo.png": {crc32c: "same"},
  });

  const plan = await buildStorageMigrationPlan(bucket);

  assert.equal(plan.blockers.length, 0);
  assert.deepEqual(plan.copies, [{
    source: "clubs/club-1/photos/one.jpg",
    target: "organizers/club-1/photos/one.jpg",
    generation: null,
    crc32c: "copy-me",
  }]);
  await applyStorageMigrationPlan(bucket, plan);
  assert.deepEqual(bucket.copies, [{
    source: "clubs/club-1/photos/one.jpg",
    target: "organizers/club-1/photos/one.jpg",
    options: {preconditionOpts: {ifGenerationMatch: 0}},
  }]);
});

test("storage plan blocks conflicting or unverifiable targets", async () => {
  const bucket = fakeBucket({
    "clubs/club-1/logo/logo.png": {crc32c: "source"},
    "organizers/club-1/logo/logo.png": {crc32c: "target"},
    "clubs/club-1/photos/one.jpg": {md5Hash: "source-md5"},
    "organizers/club-1/photos/one.jpg": {crc32c: "target-crc"},
  });

  const plan = await buildStorageMigrationPlan(bucket);

  assert.equal(plan.copies.length, 0);
  assert.equal(plan.blockers.length, 2);
  assert.match(plan.blockers[0].reasons[0], /different crc32c checksum/);
  assert.match(plan.blockers[1].reasons[0], /no comparable checksum/);
});

function fakeBucket(initialObjects) {
  const objects = new Map(Object.entries(initialObjects));
  const copies = [];
  const file = (name) => ({
    name,
    metadata: objects.get(name),
    exists: async () => [objects.has(name)],
    getMetadata: async () => [objects.get(name)],
    copy: async (target, options) => {
      copies.push({source: name, target: target.name, options});
      objects.set(target.name, {...objects.get(name)});
    },
  });
  return {
    copies,
    file,
    getFiles: async ({prefix}) => [[...objects.entries()]
      .filter(([name]) => name.startsWith(prefix))
      .map(([name]) => file(name))],
  };
}
