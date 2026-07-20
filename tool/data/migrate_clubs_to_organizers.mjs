#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {isDeepStrictEqual} from "node:util";
import {fileURLToPath} from "node:url";
import {
  applyFirestoreEmulatorHost,
  assertProdWriteAllowed,
  resolveFirebaseProjectId,
} from "../lib/firebase_project.mjs";
import {parseCommonArgs} from "../lib/cli_args.mjs";
import {createFunctionsRequire, fromRepo} from "../lib/repo_paths.mjs";
import {validateOrganizerDocument} from
  "../contracts/generated/schema_contract_validators.mjs";

const requireFromFunctions = createFunctionsRequire();
const admin = requireFromFunctions("firebase-admin");

export const organizerReferenceCollections = Object.freeze([
  "eventBroadcasts",
  "eventInviteLinks",
  "eventParticipations",
  "eventPrivateAccess",
  "eventSafetyReports",
  "eventSuccessArrivalMissions",
  "eventSuccessAssignments",
  "eventSuccessCompatibilityResponses",
  "eventSuccessFeedback",
  "eventSuccessPlans",
  "eventSuccessPreferences",
  "eventSuccessScorecards",
  "eventSuccessWingmanRequests",
  "eventWaitlistOffers",
  "events",
  "matches",
  "reviews",
  "userEventScheduleLocks",
]);

if (isMain()) await main();

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  if (args.apply && !args.confirm_migration) {
    throw new Error("--apply requires --confirm-migration.");
  }
  if (args.apply && !args.backup_file) {
    throw new Error("--apply requires --backup-file <path>.");
  }
  const backupFile = args.apply ? resolveBackupFile(args.backup_file) : null;

  const projectId = resolveFirebaseProjectId({
    env: args.env,
    project: args.project,
  });
  assertProdWriteAllowed({
    env: args.env,
    projectId,
    apply: args.apply,
    allowProd: args.allowProd,
    action: "migrate clubs to organizers in",
  });
  applyFirestoreEmulatorHost(args.emulatorHost);

  const storageBucket = args.include_storage ? resolveStorageBucket({
    env: args.env,
    projectId,
    storageBucket: args.storage_bucket,
  }) : null;
  const app = admin.initializeApp({
    projectId,
    ...(storageBucket ? {storageBucket} : {}),
  }, "clubs-to-organizers-migration");
  try {
    const db = app.firestore();
    const inventory = await readMigrationInventory(db);
    const planOptions = {
      repairLegacyMemberCounts: args.repair_legacy_member_counts === true,
      validateOrganizerSchemas: true,
    };
    const firestorePlan = buildClubsToOrganizersPlan(inventory, planOptions);
    const bucket = storageBucket ?
      admin.storage(app).bucket(storageBucket) : null;
    const storagePlan = bucket ? await buildStorageMigrationPlan(bucket) : null;
    const summary = summarizePlan(firestorePlan, storagePlan, projectId);
    printOutput(summary, args.json);

    if (!args.apply) {
      console.log("\nDry run only. No Firestore documents or Storage objects changed.");
      return;
    }
    if (firestorePlan.blockers.length > 0) {
      throw new Error(
        `Refusing to apply with ${firestorePlan.blockers.length} blocker(s).`
      );
    }

    writeBackup(backupFile, {projectId, inventory, storagePlan, summary});
    await applyClubsToOrganizersPlan(db, firestorePlan);
    if (bucket && storagePlan) await applyStorageMigrationPlan(bucket, storagePlan);

    const verificationInventory = await readMigrationInventory(db);
    const verification = buildClubsToOrganizersPlan(
      verificationInventory,
      planOptions
    );
    if (verification.blockers.length > 0 || verification.writes.length > 0) {
      throw new Error(
        "Post-apply parity failed: " +
        `${verification.blockers.length} blocker(s), ` +
        `${verification.writes.length} remaining write(s).`
      );
    }
    if (bucket) {
      const storageVerification = await buildStorageMigrationPlan(bucket);
      if (storageVerification.blockers.length > 0 ||
          storageVerification.copies.length > 0) {
        throw new Error(
          "Post-apply Storage parity failed: " +
          `${storageVerification.blockers.length} blocker(s), ` +
          `${storageVerification.copies.length} remaining copy operation(s).`
        );
      }
    }
    console.log("\nApply complete; Firestore parity recheck has zero writes and blockers.");
  } finally {
    await app.delete();
  }
}

export async function readMigrationInventory(db) {
  const collections = [
    "clubs",
    "organizers",
    "clubMemberships",
    "organizerTeamMemberships",
    "organizerFollows",
    "clubHostClaims",
    "clubClaimRequests",
    "organizerClaimRequests",
    "clubScheduleLocks",
    "organizerScheduleLocks",
    "publicRouteReservations",
    ...organizerReferenceCollections,
  ];
  const entries = await Promise.all(collections.map(async (name) => [
    name,
    await readCollection(db.collection(name)),
  ]));
  const notificationItems = await readCollectionGroup(db, "items", (doc) =>
    doc.data()?.clubId != null || doc.data()?.organizerId != null
  );
  const clubPosts = [];
  for (const club of entries.find(([name]) => name === "clubs")?.[1] ?? []) {
    const posts = await readCollection(db.doc(club.path).collection("posts"));
    clubPosts.push(...posts);
  }
  const organizerPosts = [];
  for (const organizer of
    entries.find(([name]) => name === "organizers")?.[1] ?? []) {
    const posts = await readCollection(
      db.doc(organizer.path).collection("posts")
    );
    organizerPosts.push(...posts);
  }
  return {
    collections: Object.fromEntries(entries),
    notificationItems,
    clubPosts,
    organizerPosts,
  };
}

async function readCollection(ref) {
  const snapshot = await ref.get();
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    path: doc.ref.path,
    data: doc.data(),
  }));
}

async function readCollectionGroup(db, name, predicate) {
  if (typeof db.collectionGroup !== "function") return [];
  const snapshot = await db.collectionGroup(name).get();
  return snapshot.docs
    .filter(predicate)
    .map((doc) => ({id: doc.id, path: doc.ref.path, data: doc.data()}));
}

export function buildClubsToOrganizersPlan(
  inventory,
  {
    repairLegacyMemberCounts = false,
    validateOrganizerSchemas = false,
  } = {}
) {
  const writesByTarget = new Map();
  const blockers = [];
  const collections = inventory.collections ?? {};
  const targetById = indexById(collections.organizers);
  const clubsById = indexById(collections.clubs);
  const followerCounts = activeLegacyFollowerCounts(collections.clubMemberships);

  for (const club of collections.clubs ?? []) {
    const expected = canonicalOrganizerDocument(club.id, club.data, {
      followerCount: followerCounts.get(club.id) ?? 0,
    });
    const target = targetById.get(club.id)?.data;
    const repairFollowerCount = repairLegacyMemberCounts &&
      target !== undefined &&
      target.followerCount === legacyDerivedFollowerCount(club.data) &&
      target.followerCount !== expected.followerCount;
    if (repairFollowerCount) {
      queueMerge(
        writesByTarget,
        `organizers/${club.id}`,
        {followerCount: expected.followerCount},
        club.path,
        "canonical_follower_count_repair"
      );
    }
    if (validateOrganizerSchemas) {
      queueOrganizerSchemaValidation(
        blockers,
        `organizers/${club.id}`,
        {...(target ?? {}), ...expected}
      );
    }
    queueFullDocument({
      writesByTarget,
      blockers,
      sourcePath: club.path,
      targetPath: `organizers/${club.id}`,
      expected,
      existing: repairFollowerCount ?
        {...target, followerCount: expected.followerCount} : target,
      kind: "organizer",
    });
  }

  if (repairLegacyMemberCounts) {
    queueLegacyMemberCountRepairs(collections, writesByTarget, blockers);
  }

  const teamTargets = indexById(collections.organizerTeamMemberships);
  const followTargets = indexById(collections.organizerFollows);
  for (const membership of collections.clubMemberships ?? []) {
    const organizerId = requiredLegacyId(membership, "clubId", blockers);
    const uid = requiredLegacyId(membership, "uid", blockers);
    if (!organizerId || !uid) continue;
    if (membership.data.role === "member") {
      const expected = canonicalOrganizerFollow(membership.data, organizerId, uid);
      queueFullDocument({
        writesByTarget,
        blockers,
        sourcePath: membership.path,
        targetPath: `organizerFollows/${organizerId}_${uid}`,
        expected,
        existing: followTargets.get(`${organizerId}_${uid}`)?.data,
        kind: "follow",
      });
    } else {
      const expected = canonicalOrganizerTeamMembership(
        membership.data,
        organizerId,
        uid
      );
      queueFullDocument({
        writesByTarget,
        blockers,
        sourcePath: membership.path,
        targetPath: `organizerTeamMemberships/${organizerId}_${uid}`,
        expected,
        existing: teamTargets.get(`${organizerId}_${uid}`)?.data,
        kind: "team",
      });
    }
  }

  for (const claim of collections.clubHostClaims ?? []) {
    const organizerId = requiredLegacyId(claim, "clubId", blockers);
    const uid = requiredLegacyId(claim, "uid", blockers);
    if (!organizerId || !uid) continue;
    const targetId = `${organizerId}_${uid}`;
    if (writesByTarget.has(`organizerTeamMemberships/${targetId}`) ||
        teamTargets.has(targetId)) continue;
    const club = clubsById.get(organizerId)?.data;
    const expected = {
      organizerId,
      uid,
      role: club?.ownerUserId === uid || club?.hostUserId === uid ?
        "owner" : "manager",
      status: "active",
      createdAt: claim.data.createdAt,
      removedAt: null,
    };
    queueFullDocument({
      writesByTarget,
      blockers,
      sourcePath: claim.path,
      targetPath: `organizerTeamMemberships/${targetId}`,
      expected,
      existing: teamTargets.get(targetId)?.data,
      kind: "team_from_legacy_claim",
    });
  }

  copyRenamedCollection({
    source: collections.clubClaimRequests,
    targets: collections.organizerClaimRequests,
    targetCollection: "organizerClaimRequests",
    rename: {clubId: "organizerId"},
    kind: "claim_request",
    writesByTarget,
    blockers,
  });
  copyRenamedCollection({
    source: collections.clubScheduleLocks,
    targets: collections.organizerScheduleLocks,
    targetCollection: "organizerScheduleLocks",
    rename: {clubId: "organizerId"},
    transform: (data) => ({...data, ownerType: "organizer"}),
    kind: "schedule_lock",
    writesByTarget,
    blockers,
  });

  const organizerPostsByPath = new Map(
    (inventory.organizerPosts ?? []).map((post) => [post.path, post])
  );
  for (const post of inventory.clubPosts ?? []) {
    const segments = post.path.split("/");
    const organizerId = segments[0] === "clubs" ? segments[1] : null;
    if (!organizerId) {
      blockers.push({path: post.path, reasons: ["unexpected club post path"]});
      continue;
    }
    const targetPath = `organizers/${organizerId}/posts/${post.id}`;
    queueFullDocument({
      writesByTarget,
      blockers,
      sourcePath: post.path,
      targetPath,
      expected: post.data,
      existing: organizerPostsByPath.get(targetPath)?.data,
      kind: "post",
    });
  }

  for (const collectionName of organizerReferenceCollections) {
    queueOrganizerIdPatches(
      collections[collectionName],
      writesByTarget,
      blockers,
      collectionName
    );
  }
  queueOrganizerIdPatches(
    inventory.notificationItems,
    writesByTarget,
    blockers,
    "notification_items"
  );

  for (const reservation of collections.publicRouteReservations ?? []) {
    const data = reservation.data ?? {};
    if (data.ownerCollection !== "clubs" &&
        !String(data.targetPath ?? "").startsWith("clubs/")) continue;
    const organizerId = data.ownerId ?? String(data.targetPath).split("/")[1];
    if (!organizerId) {
      blockers.push({path: reservation.path, reasons: ["missing organizer id"]});
      continue;
    }
    queueMerge(writesByTarget, reservation.path, {
      ownerType: "organizer",
      ownerCollection: "organizers",
      ownerId: organizerId,
      targetPath: `organizers/${organizerId}`,
      lastVerifiedSource: "clubsToOrganizersMigration",
    }, reservation.path, "route_reservation");
  }

  return {
    writes: [...writesByTarget.values()].sort((a, b) =>
      a.targetPath.localeCompare(b.targetPath)
    ),
    blockers,
    summary: summarizeFirestore(writesByTarget, blockers, collections),
  };
}

export function canonicalOrganizerDocument(
  organizerId,
  club,
  {followerCount = club?.followerCount ?? club?.memberCount ?? 0} = {}
) {
  const canonicalSource = {...(club ?? {})};
  delete canonicalSource.memberCount;
  const organizerPhotos = club?.organizerPhotos ?? club?.clubPhotos ?? [];
  const canonicalPath = canonicalOrganizerPath(
    club?.publicPage?.canonicalPath,
    organizerId
  );
  return pruneUndefined({
    ...canonicalSource,
    organizerPhotos,
    followerCount,
    organizerType: canonicalOrganizerType(club),
    organizerTypeUpdatedAt:
      club?.organizerTypeUpdatedAt ?? club?.createdAt ?? null,
    organizerTypeUpdatedByUid:
      club?.organizerTypeUpdatedByUid ??
      club?.ownerUserId ??
      club?.hostUserId ??
      null,
    publicCategoryLabel:
      club?.publicCategoryLabel ?? club?.displayCategory ?? null,
    publicPage: club?.publicPage ? {...club.publicPage, canonicalPath} : undefined,
  });
}

function activeLegacyFollowerCounts(memberships = []) {
  const counts = new Map();
  for (const membership of memberships) {
    const organizerId = membership.data?.clubId;
    if (typeof organizerId !== "string" || !organizerId.trim()) continue;
    if (membership.data?.role !== "member" ||
        membership.data?.status !== "active") continue;
    counts.set(organizerId, (counts.get(organizerId) ?? 0) + 1);
  }
  return counts;
}

function legacyDerivedFollowerCount(club) {
  return club?.followerCount ?? club?.memberCount ?? 0;
}

function queueOrganizerSchemaValidation(blockers, documentPath, data) {
  if (validateOrganizerDocument(schemaSerializableFirestoreData(data))) return;
  const reasons = (validateOrganizerDocument.errors ?? [])
    .slice(0, 5)
    .map((error) =>
      `schema ${error.instancePath || "/"} ${error.message ?? "is invalid"}`
    );
  blockers.push({
    path: documentPath,
    reasons: reasons.length > 0 ? reasons : ["organizer schema validation failed"],
  });
}

function schemaSerializableFirestoreData(value) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  if (isTimestampLike(value)) {
    const seconds = value.seconds ?? value._seconds;
    const nanoseconds = value.nanoseconds ?? value._nanoseconds;
    return {_seconds: seconds, _nanoseconds: nanoseconds};
  }
  if (Array.isArray(value)) {
    return value.map((item) => schemaSerializableFirestoreData(item));
  }
  if (typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .map(([key, item]) => [key, schemaSerializableFirestoreData(item)])
        .filter(([, item]) => item !== undefined)
    );
  }
  return value;
}

function isTimestampLike(value) {
  if (!value || typeof value !== "object") return false;
  const seconds = value.seconds ?? value._seconds;
  const nanoseconds = value.nanoseconds ?? value._nanoseconds;
  return Number.isInteger(seconds) && Number.isInteger(nanoseconds) &&
    (typeof value.toDate === "function" ||
      Object.keys(value).every((key) => [
        "seconds",
        "nanoseconds",
        "_seconds",
        "_nanoseconds",
      ].includes(key)));
}

function queueLegacyMemberCountRepairs(collections, writesByTarget, blockers) {
  const activeCounts = new Map();
  for (const membership of collections.clubMemberships ?? []) {
    if (membership.data?.status !== "active") continue;
    const organizerId = requiredLegacyId(membership, "clubId", blockers);
    if (!organizerId) continue;
    activeCounts.set(organizerId, (activeCounts.get(organizerId) ?? 0) + 1);
  }
  for (const club of collections.clubs ?? []) {
    const memberCount = activeCounts.get(club.id) ?? 0;
    if (club.data?.memberCount === memberCount) continue;
    queueMerge(
      writesByTarget,
      club.path,
      {memberCount},
      club.path,
      "legacy_member_count_repair"
    );
  }
}

export function canonicalOrganizerType(club) {
  const value = club?.organizerType;
  if (["club", "community", "individual", "eventProducer", "venue", "brand"]
    .includes(value)) return value;
  switch (club?.entityKind) {
  case "creatorCommunity": return "community";
  case "eventOrganizer": return "eventProducer";
  case "venue": return "venue";
  case "brand": return "brand";
  default: return "club";
  }
}

function canonicalOrganizerFollow(data, organizerId, uid) {
  return pruneUndefined({
    organizerId,
    uid,
    status: data.status === "active" ? "active" : "inactive",
    pushNotificationsEnabled: data.pushNotificationsEnabled ?? true,
    followedAt: data.joinedAt,
    unfollowedAt: data.leftAt ?? data.deletedAt ?? null,
  });
}

function canonicalOrganizerTeamMembership(data, organizerId, uid) {
  return pruneUndefined({
    organizerId,
    uid,
    role: data.role === "owner" ? "owner" : "manager",
    status: data.status === "active" ? "active" : "removed",
    createdAt: data.joinedAt,
    removedAt: data.leftAt ?? data.deletedAt ?? null,
  });
}

function copyRenamedCollection(options) {
  const targets = indexById(options.targets);
  for (const source of options.source ?? []) {
    const renamed = renameKeys(source.data, options.rename);
    const expected = options.transform ? options.transform(renamed) : renamed;
    queueFullDocument({
      writesByTarget: options.writesByTarget,
      blockers: options.blockers,
      sourcePath: source.path,
      targetPath: `${options.targetCollection}/${source.id}`,
      expected,
      existing: targets.get(source.id)?.data,
      kind: options.kind,
    });
  }
}

function queueOrganizerIdPatches(entries, writesByTarget, blockers, kind) {
  for (const entry of entries ?? []) {
    const clubId = entry.data?.clubId;
    if (clubId == null) continue;
    if (typeof clubId !== "string" || !clubId.trim()) {
      blockers.push({path: entry.path, reasons: ["clubId is not a document id"]});
      continue;
    }
    if (entry.data.organizerId === clubId) continue;
    if (entry.data.organizerId != null && entry.data.organizerId !== clubId) {
      blockers.push({
        path: entry.path,
        reasons: ["organizerId conflicts with legacy clubId"],
      });
      continue;
    }
    queueMerge(
      writesByTarget,
      entry.path,
      {organizerId: clubId},
      entry.path,
      kind
    );
  }
}

function queueFullDocument(options) {
  const expected = pruneUndefined(options.expected);
  if (options.existing === undefined) {
    options.writesByTarget.set(options.targetPath, {
      targetPath: options.targetPath,
      sourcePath: options.sourcePath,
      kind: options.kind,
      merge: false,
      data: expected,
    });
    return;
  }
  const patch = missingOrEqualPatch(options.existing, expected);
  if (patch.conflicts.length > 0) {
    options.blockers.push({
      path: options.targetPath,
      sourcePath: options.sourcePath,
      reasons: patch.conflicts,
    });
    return;
  }
  if (Object.keys(patch.missing).length > 0) {
    queueMerge(
      options.writesByTarget,
      options.targetPath,
      patch.missing,
      options.sourcePath,
      options.kind
    );
  }
}

function queueMerge(writesByTarget, targetPath, data, sourcePath, kind) {
  const existing = writesByTarget.get(targetPath);
  writesByTarget.set(targetPath, {
    targetPath,
    sourcePath: existing?.sourcePath ?? sourcePath,
    kind: existing?.kind ?? kind,
    merge: true,
    data: {...(existing?.data ?? {}), ...data},
  });
}

function missingOrEqualPatch(existing, expected) {
  const missing = {};
  const conflicts = [];
  for (const [key, value] of Object.entries(expected)) {
    if (!(key in existing)) missing[key] = value;
    else if (!isDeepStrictEqual(existing[key], value)) {
      conflicts.push(`${key} differs between source and target`);
    }
  }
  return {missing, conflicts};
}

function requiredLegacyId(entry, key, blockers) {
  const value = entry.data?.[key];
  if (typeof value === "string" && value.trim()) return value;
  blockers.push({path: entry.path, reasons: [`missing ${key}`]});
  return null;
}

function renameKeys(data, rename) {
  const output = {};
  for (const [key, value] of Object.entries(data ?? {})) {
    output[rename[key] ?? key] = value;
  }
  return output;
}

function canonicalOrganizerPath(path, organizerId) {
  if (typeof path === "string" && path.startsWith("/organizers/")) return path;
  return `/organizers/${organizerId}/`;
}

function pruneUndefined(value) {
  return Object.fromEntries(
    Object.entries(value ?? {}).filter(([, item]) => item !== undefined)
  );
}

function indexById(entries = []) {
  return new Map(entries.map((entry) => [entry.id, entry]));
}

export async function applyClubsToOrganizersPlan(db, plan) {
  if (plan.blockers.length > 0) {
    throw new Error(`Refusing to apply with ${plan.blockers.length} blocker(s).`);
  }
  for (let index = 0; index < plan.writes.length; index += 400) {
    const batch = db.batch();
    for (const write of plan.writes.slice(index, index + 400)) {
      batch.set(db.doc(write.targetPath), write.data, {merge: write.merge});
    }
    await batch.commit();
  }
}

export async function buildStorageMigrationPlan(bucket) {
  const [files] = await bucket.getFiles({prefix: "clubs/"});
  const copies = [];
  const blockers = [];
  for (const file of files) {
    const targetName = file.name.replace(/^clubs\//, "organizers/");
    const targetFile = bucket.file(targetName);
    const [exists] = await targetFile.exists();
    if (exists) {
      const [targetMetadata] = await targetFile.getMetadata();
      const checksum = comparableStorageChecksum(
        file.metadata,
        targetMetadata
      );
      if (!checksum) {
        blockers.push({
          source: file.name,
          target: targetName,
          reasons: ["target object exists but no comparable checksum is available"],
        });
      } else if (checksum.source !== checksum.target) {
        blockers.push({
          source: file.name,
          target: targetName,
          reasons: [
            `target object exists with a different ${checksum.algorithm} checksum`,
          ],
        });
      }
      continue;
    }
    copies.push({
      source: file.name,
      target: targetName,
      generation: file.metadata?.generation ?? null,
      crc32c: file.metadata?.crc32c ?? null,
    });
  }
  return {copies, blockers, filesScanned: files.length};
}

function comparableStorageChecksum(source, target) {
  if (source?.crc32c && target?.crc32c) {
    return {
      algorithm: "crc32c",
      source: source.crc32c,
      target: target.crc32c,
    };
  }
  if (source?.md5Hash && target?.md5Hash) {
    return {
      algorithm: "md5",
      source: source.md5Hash,
      target: target.md5Hash,
    };
  }
  return null;
}

export async function applyStorageMigrationPlan(bucket, plan) {
  if (plan.blockers.length > 0) {
    throw new Error(`Refusing Storage apply with ${plan.blockers.length} blocker(s).`);
  }
  for (const copy of plan.copies) {
    await bucket.file(copy.source).copy(bucket.file(copy.target), {
      preconditionOpts: {ifGenerationMatch: 0},
    });
  }
}

function summarizeFirestore(writesByTarget, blockers, collections) {
  const byKind = {};
  for (const write of writesByTarget.values()) {
    byKind[write.kind] = (byKind[write.kind] ?? 0) + 1;
  }
  return {
    clubsScanned: collections.clubs?.length ?? 0,
    organizersPresent: collections.organizers?.length ?? 0,
    writesNeeded: writesByTarget.size,
    blockerCount: blockers.length,
    writesByKind: byKind,
  };
}

function summarizePlan(firestorePlan, storagePlan, projectId) {
  return {
    projectId,
    firestore: firestorePlan.summary,
    blockers: firestorePlan.blockers,
    storage: storagePlan ? {
      filesScanned: storagePlan.filesScanned,
      copiesNeeded: storagePlan.copies.length,
      blockerCount: storagePlan.blockers.length,
    } : {included: false},
  };
}

function writeBackup(path, payload) {
  fs.writeFileSync(path, `${JSON.stringify(payload, null, 2)}\n`, {
    flag: "wx",
    mode: 0o600,
  });
  console.log(`Wrote pre-apply backup to ${path}.`);
}

export function resolveBackupFile(candidate, {root = fromRepo()} = {}) {
  const backupPath = path.resolve(candidate);
  const parent = path.dirname(backupPath);
  if (!fs.existsSync(parent) || !fs.statSync(parent).isDirectory()) {
    throw new Error(
      `Backup directory must already exist: ${parent}. ` +
      "Create an owner-restricted directory outside the repository."
    );
  }
  const realRoot = fs.realpathSync(root);
  const realParent = fs.realpathSync(parent);
  if (realParent === realRoot || realParent.startsWith(`${realRoot}${path.sep}`)) {
    throw new Error(
      "--backup-file must be outside the repository because it contains " +
      "full Firestore documents."
    );
  }
  if (process.platform !== "win32" && (fs.statSync(realParent).mode & 0o077) !== 0) {
    throw new Error(
      `Backup directory must be owner-restricted (mode 0700): ${realParent}.`
    );
  }
  return path.join(realParent, path.basename(backupPath));
}

function printOutput(summary, json) {
  if (json) {
    console.log(JSON.stringify(summary, null, 2));
    return;
  }
  console.log("Clubs to organizers migration plan");
  console.log(`Project: ${summary.projectId}`);
  console.log(`Clubs scanned: ${summary.firestore.clubsScanned}`);
  console.log(`Organizers present: ${summary.firestore.organizersPresent}`);
  console.log(`Firestore writes needed: ${summary.firestore.writesNeeded}`);
  console.log(`Blockers: ${summary.firestore.blockerCount}`);
  if (summary.storage.included === false) {
    console.log("Storage: omitted (pass --include-storage to audit media copies)");
  } else {
    console.log(`Storage copies needed: ${summary.storage.copiesNeeded}`);
  }
  for (const blocker of summary.blockers) {
    console.log(`- BLOCKED ${blocker.path}: ${blocker.reasons.join("; ")}`);
  }
}

function parseArgs(argv) {
  return parseCommonArgs(argv, {
    booleanFlags: [
      "--confirm-migration",
      "--include-storage",
      "--repair-legacy-member-counts",
    ],
    valueFlags: ["--backup-file", "--storage-bucket"],
  });
}

export function resolveStorageBucket({env, projectId, storageBucket}) {
  if (storageBucket) return storageBucket;
  if (env) {
    const optionsPath = fromRepo(`lib/firebase_options_${env}.dart`);
    if (fs.existsSync(optionsPath)) {
      const source = fs.readFileSync(optionsPath, "utf8");
      const match = /storageBucket:\s*'([^']+)'/.exec(source);
      if (match) return match[1];
    }
  }
  return `${projectId}.firebasestorage.app`;
}

function printHelp() {
  console.log(`Usage: node tool/data/migrate_clubs_to_organizers.mjs [options]

Copies legacy club authorities into canonical organizer collections, splits
host/member edges into team/follow edges, adds organizerId compatibility fields,
updates route reservations, and optionally copies Storage media. Dry-run only by
default. This tool never deletes legacy data.

Options:
  --env <dev|staging|prod>  Resolve project id from .firebaserc.
  --project <id>            Firebase project override.
  --storage-bucket <name>   Override the resolved Firebase Storage bucket.
  --emulator                Use Firestore emulator at 127.0.0.1:8080.
  --include-storage         Audit/copy clubs/ media to organizers/ paths.
  --repair-legacy-member-counts
                            Recompute legacy counts from active memberships;
                            use only to repair compatibility aggregate drift.
  --json                    Print JSON summary.
  --apply                   Apply the planned additions and patches.
  --confirm-migration       Required with --apply.
  --backup-file <path>      Required unused path in an existing secure directory
                            outside the repository; contains full documents.
  --allow-prod              Required with --apply against production.
  -h, --help                Show this help.`);
}

function isMain() {
  return process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1];
}
