#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";
import {
  assertNoUserRunScheduleConflictInFirestore,
  buildRunClubScheduleLockDocs,
  buildUserRunScheduleLockDocs,
} from "./demo_schedule_policy.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);

export const DEFAULT_DEMO_OPS_PREFIX = "demo_ops_2026";
export const DEFAULT_SEED_PREFIX = "demo_beta_2026";
export const DEMO_MANIFEST_COLLECTION = "demoOpsRuns";
export const DEFAULT_MAX_BATCH_WRITES = 450;
export const DEFAULT_GOLDEN_ACCOUNTS_FILE =
  "tool/demo_seed/golden_accounts.example.json";

const cityLabels = {
  mumbai: "Mumbai",
  delhi: "Delhi",
  bangalore: "Bangalore",
  hyderabad: "Hyderabad",
  chennai: "Chennai",
  kolkata: "Kolkata",
  pune: "Pune",
  ahmedabad: "Ahmedabad",
  indore: "Indore",
};

export function loadFirebaseAdmin() {
  return requireFromFunctions("firebase-admin");
}

export function resolveProjectId({env, project}) {
  if (project) return project;
  const firebaserc = JSON.parse(
    fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
  );
  if (env) {
    const resolved = firebaserc.projects?.[env];
    if (!resolved) throw new Error(`No Firebase project alias found for env: ${env}`);
    return resolved;
  }
  return firebaserc.projects?.dev ?? "catchdates-dev";
}

export function isProductionTarget({env, projectId}) {
  const firebaserc = JSON.parse(
    fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
  );
  return env === "prod" || projectId === firebaserc.projects?.prod;
}

export function normalizePhone(raw) {
  const value = String(raw ?? "").replace(/\s+/g, "").trim();
  if (!/^\+[1-9]\d{7,14}$/.test(value)) {
    throw new Error(`Invalid E.164 phone number: ${raw}`);
  }
  return value;
}

export function splitCsv(value) {
  if (!value) return [];
  return String(value).split(",").map((item) => item.trim()).filter(Boolean);
}

export function matchIdFor(uidA, uidB) {
  if (!uidA || !uidB || uidA === uidB) {
    throw new Error("A match requires two distinct user IDs.");
  }
  return [uidA, uidB].sort().join("_");
}

export function demoOperationId({command, seedPrefix, subject}) {
  const normalizedSubject = subject.replace(/[^A-Za-z0-9_-]/g, "_");
  return `${seedPrefix}_${command}_${normalizedSubject}`;
}

export function timestampFromDate(admin, date) {
  return admin.firestore.Timestamp.fromDate(date);
}

export function offsetDate(baseDate, {minutes = 0, hours = 0, days = 0} = {}) {
  return new Date(
    baseDate.getTime() +
      minutes * 60 * 1000 +
      hours * 60 * 60 * 1000 +
      days * 24 * 60 * 60 * 1000
  );
}

export function buildDemoMarker({admin, command, operationId, seedPrefix, now}) {
  return {
    demoOps: true,
    demoOpsCommand: command,
    demoOpsId: operationId,
    seedPrefix,
    synthetic: true,
    createdAt: timestampFromDate(admin, now),
  };
}

export async function resolveUserByPhone(db, phone) {
  const normalizedPhone = normalizePhone(phone);
  const snap = await db.collection("users")
    .where("phoneNumber", "==", normalizedPhone)
    .limit(2)
    .get();
  if (snap.empty) {
    throw new Error(`No users document found for phone ${normalizedPhone}.`);
  }
  if (snap.size > 1) {
    throw new Error(`Phone ${normalizedPhone} matched multiple users.`);
  }
  const doc = snap.docs[0];
  return {uid: doc.id, phoneNumber: normalizedPhone, data: doc.data()};
}

export async function requirePublicProfile(db, uid) {
  const doc = await db.collection("publicProfiles").doc(uid).get();
  if (!doc.exists) {
    throw new Error(
      `Missing publicProfiles/${uid}. Complete onboarding or repair profile sync first.`
    );
  }
  return {uid, data: doc.data()};
}

export async function resolveUsersByPhones(db, phones) {
  const users = [];
  for (const phone of phones) {
    const user = await resolveUserByPhone(db, phone);
    await requirePublicProfile(db, user.uid);
    users.push(user);
  }
  return users;
}

export async function findSharedAttendedRunId(db, uidA, uidB) {
  const [aSnap, bSnap] = await Promise.all([
    db.collection("runParticipations")
      .where("uid", "==", uidA)
      .where("status", "==", "attended")
      .get(),
    db.collection("runParticipations")
      .where("uid", "==", uidB)
      .where("status", "==", "attended")
      .get(),
  ]);
  const bRunIds = new Set(bSnap.docs.map((doc) => doc.data().runId));
  const shared = aSnap.docs
    .map((doc) => doc.data().runId)
    .filter((runId) => typeof runId === "string" && bRunIds.has(runId));
  return shared.sort()[0] ?? null;
}

export async function findDemoRuns(db, {now = new Date()} = {}) {
  const snap = await db.collection("runs").get();
  const runs = snap.docs
    .map((doc) => ({id: doc.id, path: doc.ref.path, data: doc.data()}))
    .filter((run) => run.data.status !== "cancelled")
    .filter((run) => typeof run.data.startTime?.toDate === "function");

  const upcoming = runs
    .filter((run) => run.data.startTime.toDate() > now)
    .sort((a, b) => a.data.startTime.toMillis() - b.data.startTime.toMillis());
  const past = runs
    .filter((run) => run.data.startTime.toDate() <= now)
    .sort((a, b) => b.data.startTime.toMillis() - a.data.startTime.toMillis());
  const paidUpcoming = upcoming.filter((run) => Number(run.data.priceInPaise ?? 0) > 0);

  return {upcoming, past, paidUpcoming};
}

export async function findSyntheticTargets(db, {excludeUid, limit = 3}) {
  const usersSnap = await db.collection("users")
    .where("synthetic", "==", true)
    .limit(Math.max(limit * 3, limit))
    .get();
  const targets = [];
  for (const doc of usersSnap.docs) {
    if (doc.id === excludeUid) continue;
    const profile = await db.collection("publicProfiles").doc(doc.id).get();
    if (!profile.exists) continue;
    targets.push({uid: doc.id, data: doc.data(), publicProfile: profile.data()});
    if (targets.length >= limit) break;
  }
  return targets;
}

export function loadScenarioConfig(nameOrPath) {
  const filePath = scenarioPath(nameOrPath);
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

export function listScenarioConfigs() {
  const scenariosDir = path.join(toolDir, "demo_seed", "scenarios");
  return fs.readdirSync(scenariosDir)
    .filter((file) => file.endsWith(".json"))
    .map((file) => loadScenarioConfig(path.join(scenariosDir, file)))
    .sort((a, b) => a.id.localeCompare(b.id));
}

export function loadGoldenAccounts(filePath = DEFAULT_GOLDEN_ACCOUNTS_FILE) {
  const resolvedPath = path.resolve(repoRoot, filePath);
  const json = JSON.parse(fs.readFileSync(resolvedPath, "utf8"));
  return json.accounts ?? [];
}

function scenarioPath(nameOrPath) {
  if (!nameOrPath) throw new Error("Scenario name or path is required.");
  const directPath = path.resolve(repoRoot, nameOrPath);
  if (fs.existsSync(directPath)) return directPath;
  const fromScenarioDir = path.join(
    toolDir,
    "demo_seed",
    "scenarios",
    `${nameOrPath}.json`
  );
  if (fs.existsSync(fromScenarioDir)) return fromScenarioDir;
  throw new Error(`Unknown demo scenario: ${nameOrPath}`);
}

export function buildSwipeDocs({admin, marker, uidA, uidB, runId, now}) {
  const createdAt = timestampFromDate(admin, now);
  return [
    {
      path: `swipes/${uidA}/outgoing/${uidB}`,
      data: {
        ...marker,
        swiperId: uidA,
        targetId: uidB,
        runId,
        direction: "like",
        createdAt,
      },
    },
    {
      path: `swipes/${uidB}/outgoing/${uidA}`,
      data: {
        ...marker,
        swiperId: uidB,
        targetId: uidA,
        runId,
        direction: "like",
        createdAt,
      },
    },
  ];
}

export function buildMatchDoc({admin, marker, uidA, uidB, runId, now}) {
  const [user1Id, user2Id] = [uidA, uidB].sort();
  return {
    path: `matches/${matchIdFor(uidA, uidB)}`,
    data: {
      ...marker,
      demoOpsEntityType: "matchThread",
      demoOpsDisposalPolicy: "deleteThreadWithMessages",
      user1Id,
      user2Id,
      participantIds: [user1Id, user2Id],
      runIds: runId ? [runId] : [],
      createdAt: timestampFromDate(admin, now),
      lastMessageAt: null,
      lastMessagePreview: null,
      lastMessageSenderId: null,
      unreadCounts: {[user1Id]: 0, [user2Id]: 0},
      status: "active",
      blockedBy: null,
      blockedAt: null,
    },
  };
}

export function starterMessagesForPair() {
  return [
    {sender: "b", text: "That was a fun run. Are you doing the next one?"},
    {sender: "a", text: "Yes. I wanted to try the weekend route too."},
    {sender: "b", text: "Perfect. Let's save a spot after the run."},
  ];
}

export function buildMessageDocs({
  admin,
  marker,
  matchId,
  uidA,
  uidB,
  messages,
  now,
}) {
  return messages.map((message, index) => {
    const senderId = message.sender === "a" ? uidA : uidB;
    return {
      path: `matches/${matchId}/messages/${marker.demoOpsId}_msg_${String(index + 1).padStart(2, "0")}`,
      data: {
        ...marker,
        demoOpsEntityType: "chatMessage",
        demoOpsDisposalPolicy: "deleteWithParentMatchThread",
        senderId,
        text: message.text,
        imageUrl: null,
        sentAt: timestampFromDate(admin, offsetDate(now, {minutes: index * 4})),
      },
    };
  });
}

export function buildMatchNotifications({
  admin,
  marker,
  matchId,
  uidA,
  uidB,
  nameA,
  nameB,
  runId,
  now,
  includeUidA = true,
  includeUidB = true,
}) {
  const docs = [];
  if (includeUidA) {
    docs.push({
      path: `notifications/${uidA}/items/match_${matchId}`,
      data: {
        ...marker,
        uid: uidA,
        type: "match",
        title: "It's a catch",
        body: `You and ${nameB} matched. Say hi!`,
        createdAt: timestampFromDate(admin, now),
        readAt: null,
        matchId,
        runId: runId ?? null,
        runClubId: null,
        actorUid: uidB,
        actorName: nameB,
      },
    });
  }
  if (includeUidB) {
    docs.push({
      path: `notifications/${uidB}/items/match_${matchId}`,
      data: {
        ...marker,
        uid: uidB,
        type: "match",
        title: "It's a catch",
        body: `You and ${nameA} matched. Say hi!`,
        createdAt: timestampFromDate(admin, now),
        readAt: null,
        matchId,
        runId: runId ?? null,
        runClubId: null,
        actorUid: uidA,
        actorName: nameA,
      },
    });
  }
  return docs;
}

export async function buildMatchPhonePlan({
  db,
  admin,
  phoneA,
  phoneB,
  runId,
  viaSwipes = false,
  direct = true,
  withMessages = false,
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  now = new Date(),
}) {
  const [userA, userB] = await resolveUsersByPhones(db, [phoneA, phoneB]);
  const [profileA, profileB] = await Promise.all([
    requirePublicProfile(db, userA.uid),
    requirePublicProfile(db, userB.uid),
  ]);
  const resolvedRunId = runId ?? await findSharedAttendedRunId(db, userA.uid, userB.uid);
  if (viaSwipes && !resolvedRunId) {
    throw new Error(
      "Cannot create reciprocal swipe demo without a shared attended run. " +
      "Pass --run-id or warm/reset the users into a shared attended run first."
    );
  }

  const matchId = matchIdFor(userA.uid, userB.uid);
  const relationshipCreatedAt = withMessages && direct ?
    offsetDate(now, {minutes: -15}) :
    now;
  const operationId = demoOperationId({
    command: "match",
    seedPrefix,
    subject: matchId,
  });
  const marker = buildDemoMarker({
    admin,
    command: "match-phones",
    operationId,
    seedPrefix,
    now: relationshipCreatedAt,
  });
  const docs = [];
  if (viaSwipes) {
    docs.push(...buildSwipeDocs({
      admin,
      marker,
      uidA: userA.uid,
      uidB: userB.uid,
      runId: resolvedRunId,
      now: relationshipCreatedAt,
    }));
  }
  if (direct) {
    docs.push(buildMatchDoc({
      admin,
      marker,
      uidA: userA.uid,
      uidB: userB.uid,
      runId: resolvedRunId,
      now: relationshipCreatedAt,
    }));
  }
  const nameA = publicName(profileA.data, userA.data);
  const nameB = publicName(profileB.data, userB.data);
  if (direct) {
    docs.push(...buildMatchNotifications({
      admin,
      marker,
      matchId,
      uidA: userA.uid,
      uidB: userB.uid,
      nameA,
      nameB,
      runId: resolvedRunId,
      now: relationshipCreatedAt,
    }));
  }
  if (withMessages && direct) {
    docs.push(...buildMessageDocs({
      admin,
      marker,
      matchId,
      uidA: userA.uid,
      uidB: userB.uid,
      messages: starterMessagesForPair({nameA, nameB}),
      now: offsetDate(now, {minutes: -12}),
    }));
  }

  return {
    command: "match-phones",
    operationId,
    matchId,
    phones: [userA.phoneNumber, userB.phoneNumber],
    users: [userA.uid, userB.uid],
    runId: resolvedRunId,
    direct,
    viaSwipes,
    docs: uniqueDocsByPath(docs),
  };
}

export async function buildWarmUserPlan({
  db,
  admin,
  phone,
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  syntheticMatchCount = 3,
  now = new Date(),
}) {
  const [user] = await resolveUsersByPhones(db, [phone]);
  const publicProfile = await requirePublicProfile(db, user.uid);
  const operationId = demoOperationId({
    command: "warm_user",
    seedPrefix,
    subject: user.uid,
  });
  const marker = buildDemoMarker({
    admin,
    command: "warm-user",
    operationId,
    seedPrefix,
    now,
  });
  const {upcoming, past, paidUpcoming} = await findDemoRuns(db, {now});
  const docs = [];

  for (const run of upcoming.slice(0, 3)) {
    docs.push({
      path: `savedRuns/${user.uid}_${run.id}`,
      data: {
        ...marker,
        uid: user.uid,
        runId: run.id,
        savedAt: timestampFromDate(admin, offsetDate(now, {hours: -2})),
        removedAt: null,
      },
    });
  }

  const signedUpRun = upcoming[0];
  const waitlistedRun = upcoming[1];
  const attendedRun = past[0];
  if (signedUpRun) {
    docs.push(...await buildParticipationDocsWithLocks({
      db,
      admin,
      marker,
      uid: user.uid,
      run: signedUpRun,
      status: "signedUp",
      genderAtSignup: user.data.gender,
      now,
    }));
  }
  if (waitlistedRun) {
    docs.push(...await buildParticipationDocsWithLocks({
      db,
      admin,
      marker,
      uid: user.uid,
      run: waitlistedRun,
      status: "waitlisted",
      genderAtSignup: user.data.gender,
      now,
    }));
  }
  if (attendedRun) {
    docs.push(...await buildParticipationDocsWithLocks({
      db,
      admin,
      marker,
      uid: user.uid,
      run: attendedRun,
      status: "attended",
      genderAtSignup: user.data.gender,
      now,
    }));
  }

  const paidRun = paidUpcoming[0];
  if (paidRun) {
    const paymentId = `${seedPrefix}_payment_${paidRun.id}_${user.uid}`;
    docs.push({
      path: `payments/${paymentId}`,
      data: {
        ...marker,
        userId: user.uid,
        orderId: `${seedPrefix}_order_${paidRun.id}_${user.uid}`,
        paymentId,
        runId: paidRun.id,
        amount: Number(paidRun.data.priceInPaise ?? 29900) || 29900,
        currency: "INR",
        status: "completed",
        signUpFailed: false,
        createdAt: timestampFromDate(admin, offsetDate(now, {days: -1})),
      },
    });
  }

  docs.push(...buildWarmNotifications({
    admin,
    marker,
    uid: user.uid,
    runs: {upcoming: signedUpRun, waitlisted: waitlistedRun, attended: attendedRun},
    now,
  }));

  const targets = await findSyntheticTargets(db, {
    excludeUid: user.uid,
    limit: syntheticMatchCount,
  });
  for (const target of targets) {
    const matchPlan = await buildDirectSyntheticMatchPlan({
      admin,
      marker,
      user,
      publicProfile,
      target,
      runId: attendedRun?.id ?? null,
      now,
    });
    docs.push(...matchPlan.docs);
  }

  return {
    command: "warm-user",
    operationId,
    phone: user.phoneNumber,
    uid: user.uid,
    syntheticMatches: targets.length,
    docs: uniqueDocsByPath(docs),
    aggregateRepairRecommended: true,
  };
}

export function buildParticipationDoc({
  admin,
  marker,
  uid,
  run,
  status,
  genderAtSignup = "other",
  now,
}) {
  const createdAt = offsetDate(now, {days: status === "attended" ? -10 : -2});
  const attendedAt = status === "attended" && typeof run.data.endTime?.toDate === "function" ?
    run.data.endTime.toDate() :
    null;
  return {
    path: `runParticipations/${run.id}_${uid}`,
    data: {
      ...marker,
      runId: run.id,
      runClubId: run.data.runClubId,
      uid,
      status,
      createdAt: timestampFromDate(admin, createdAt),
      updatedAt: timestampFromDate(admin, now),
      signedUpAt: ["signedUp", "attended"].includes(status) ?
        timestampFromDate(admin, createdAt) :
        null,
      waitlistedAt: status === "waitlisted" ? timestampFromDate(admin, createdAt) : null,
      attendedAt: attendedAt ? timestampFromDate(admin, attendedAt) : null,
      cancelledAt: null,
      deletedAt: null,
      genderAtSignup: typeof genderAtSignup === "string" ? genderAtSignup : "other",
      paymentId: null,
    },
  };
}

async function buildParticipationDocsWithLocks({
  db,
  admin,
  marker,
  uid,
  run,
  status,
  genderAtSignup = "other",
  now,
}) {
  await assertNoUserRunScheduleConflictInFirestore({db, uid, run});
  const participation = buildParticipationDoc({
    admin,
    marker,
    uid,
    run,
    status,
    genderAtSignup,
    now,
  });
  return [
    participation,
    ...buildUserRunScheduleLockDocs({run, participation}),
  ];
}

export function buildWarmNotifications({admin, marker, uid, runs, now}) {
  const docs = [];
  if (runs.upcoming) {
    docs.push({
      path: `notifications/${uid}/items/demoOps_runReminder_${runs.upcoming.id}`,
      data: {
        ...marker,
        uid,
        type: "runReminder",
        title: "Run coming up",
        body: "Your demo run is ready for tomorrow morning.",
        createdAt: timestampFromDate(admin, offsetDate(now, {hours: -1})),
        readAt: null,
        matchId: null,
        runId: runs.upcoming.id,
        runClubId: runs.upcoming.data.runClubId,
        actorUid: null,
        actorName: null,
      },
    });
  }
  if (runs.waitlisted) {
    docs.push({
      path: `notifications/${uid}/items/demoOps_waitlist_${runs.waitlisted.id}`,
      data: {
        ...marker,
        uid,
        type: "waitlistPromotion",
        title: "Waitlist moving",
        body: "You are near the top of the demo waitlist.",
        createdAt: timestampFromDate(admin, offsetDate(now, {hours: -4})),
        readAt: null,
        matchId: null,
        runId: runs.waitlisted.id,
        runClubId: runs.waitlisted.data.runClubId,
        actorUid: null,
        actorName: null,
      },
    });
  }
  return docs;
}

async function buildDirectSyntheticMatchPlan({
  admin,
  marker,
  user,
  publicProfile,
  target,
  runId,
  now,
}) {
  const matchId = matchIdFor(user.uid, target.uid);
  const nameA = publicName(publicProfile.data, user.data);
  const nameB = publicName(target.publicProfile, target.data);
  const relationshipCreatedAt = offsetDate(now, {minutes: -15});
  const docs = [
    buildMatchDoc({
      admin,
      marker,
      uidA: user.uid,
      uidB: target.uid,
      runId,
      now: relationshipCreatedAt,
    }),
    ...buildMatchNotifications({
      admin,
      marker,
      matchId,
      uidA: user.uid,
      uidB: target.uid,
      nameA,
      nameB,
      runId,
      now: relationshipCreatedAt,
      includeUidB: false,
    }),
    ...buildMessageDocs({
      admin,
      marker,
      matchId,
      uidA: user.uid,
      uidB: target.uid,
      messages: starterMessagesForPair({nameA, nameB}),
      now: offsetDate(now, {minutes: -12}),
    }),
  ];
  return {matchId, docs};
}

export async function buildWarmGroupPlans({
  db,
  admin,
  phones,
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  now = new Date(),
}) {
  const normalizedPhones = phones.map(normalizePhone);
  const plans = [];
  for (let i = 0; i < normalizedPhones.length; i += 1) {
    for (let j = i + 1; j < normalizedPhones.length; j += 1) {
      plans.push(await buildMatchPhonePlan({
        db,
        admin,
        phoneA: normalizedPhones[i],
        phoneB: normalizedPhones[j],
        direct: true,
        viaSwipes: false,
        withMessages: true,
        seedPrefix,
        now,
      }));
    }
  }
  return plans;
}

export async function buildMakeRunFullPlan({
  db,
  admin,
  runId,
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  now = new Date(),
}) {
  const runSnap = await db.collection("runs").doc(runId).get();
  if (!runSnap.exists) throw new Error(`Missing runs/${runId}.`);
  const run = {id: runSnap.id, path: runSnap.ref.path, data: runSnap.data()};
  const existing = await db.collection("runParticipations")
    .where("runId", "==", runId)
    .get();
  const activeCount = existing.docs
    .filter((doc) => ["signedUp", "attended"].includes(doc.data().status))
    .length;
  const capacity = Number(run.data.capacityLimit ?? activeCount);
  const slotsToFill = Math.max(0, capacity - activeCount);
  const targets = await findSyntheticTargets(db, {
    excludeUid: run.data.hostUserId,
    limit: slotsToFill,
  });
  const operationId = demoOperationId({
    command: "make_run_full",
    seedPrefix,
    subject: runId,
  });
  const marker = buildDemoMarker({
    admin,
    command: "make-run-full",
    operationId,
    seedPrefix,
    now,
  });
  const docs = [];
  for (const target of targets) {
    docs.push(...await buildParticipationDocsWithLocks({
      db,
      admin,
      marker,
      uid: target.uid,
      run,
      status: "signedUp",
      genderAtSignup: target.data.gender,
      now,
    }));
  }
  return {
    command: "make-run-full",
    operationId,
    runId,
    slotsToFill,
    docs: uniqueDocsByPath(docs),
    aggregateRepairRecommended: true,
  };
}

export async function buildMarkAttendedPlan({
  db,
  admin,
  phone,
  runId,
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  now = new Date(),
}) {
  const user = await resolveUserByPhone(db, phone);
  const runSnap = await db.collection("runs").doc(runId).get();
  if (!runSnap.exists) throw new Error(`Missing runs/${runId}.`);
  const operationId = demoOperationId({
    command: "mark_attended",
    seedPrefix,
    subject: `${runId}_${user.uid}`,
  });
  const marker = buildDemoMarker({
    admin,
    command: "mark-attended",
    operationId,
    seedPrefix,
    now,
  });
  const docs = await buildParticipationDocsWithLocks({
    db,
    admin,
    marker,
    uid: user.uid,
    run: {id: runSnap.id, path: runSnap.ref.path, data: runSnap.data()},
    status: "attended",
    genderAtSignup: user.data.gender,
    now,
  });
  return {
    command: "mark-attended",
    operationId,
    phone: user.phoneNumber,
    uid: user.uid,
    runId,
    docs,
    aggregateRepairRecommended: true,
  };
}

export async function buildPromoteWaitlistPlan({
  db,
  admin,
  phone,
  runId,
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  now = new Date(),
}) {
  const user = await resolveUserByPhone(db, phone);
  const runSnap = await db.collection("runs").doc(runId).get();
  if (!runSnap.exists) throw new Error(`Missing runs/${runId}.`);
  const operationId = demoOperationId({
    command: "promote_waitlist",
    seedPrefix,
    subject: `${runId}_${user.uid}`,
  });
  const marker = buildDemoMarker({
    admin,
    command: "promote-waitlist",
    operationId,
    seedPrefix,
    now,
  });
  const run = {id: runSnap.id, path: runSnap.ref.path, data: runSnap.data()};
  const docs = [
    ...await buildParticipationDocsWithLocks({
      db,
      admin,
      marker,
      uid: user.uid,
      run,
      status: "signedUp",
      genderAtSignup: user.data.gender,
      now,
    }),
    {
      path: `notifications/${user.uid}/items/demoOps_waitlistPromotion_${runId}`,
      data: {
        ...marker,
        uid: user.uid,
        type: "waitlistPromotion",
        title: "You're in",
        body: "A spot opened on your demo run.",
        createdAt: timestampFromDate(admin, now),
        readAt: null,
        matchId: null,
        runId,
        runClubId: run.data.runClubId,
        actorUid: null,
        actorName: null,
      },
    },
  ];
  return {
    command: "promote-waitlist",
    operationId,
    phone: user.phoneNumber,
    uid: user.uid,
    runId,
    docs,
    aggregateRepairRecommended: true,
  };
}

export async function buildUnreadMessagePlan({
  db,
  admin,
  fromPhone,
  toPhone,
  text = "Can you check this demo chat?",
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  now = new Date(),
}) {
  const [fromUser, toUser] = await resolveUsersByPhones(db, [fromPhone, toPhone]);
  const matchId = matchIdFor(fromUser.uid, toUser.uid);
  const matchSnap = await db.collection("matches").doc(matchId).get();
  if (!matchSnap.exists) {
    throw new Error(`Missing matches/${matchId}. Run match-phones first.`);
  }
  const operationId = demoOperationId({
    command: "unread_message",
    seedPrefix,
    subject: `${matchId}_${now.getTime()}`,
  });
  const marker = buildDemoMarker({
    admin,
    command: "create-unread-message",
    operationId,
    seedPrefix,
    now,
  });
  return {
    command: "create-unread-message",
    operationId,
    matchId,
    phones: [fromUser.phoneNumber, toUser.phoneNumber],
    users: [fromUser.uid, toUser.uid],
    docs: [{
      path: `matches/${matchId}/messages/${operationId}_msg_01`,
      data: {
        ...marker,
        senderId: fromUser.uid,
        text,
        imageUrl: null,
        sentAt: timestampFromDate(admin, now),
      },
    }],
    triggerExpected: "onMessageCreated updates unreadCounts and notifications.",
  };
}

export async function buildRefundPlan({
  db,
  admin,
  phone,
  runId,
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  now = new Date(),
}) {
  const user = await resolveUserByPhone(db, phone);
  const runSnap = await db.collection("runs").doc(runId).get();
  if (!runSnap.exists) throw new Error(`Missing runs/${runId}.`);
  const amount = Number(runSnap.data().priceInPaise ?? 29900) || 29900;
  const operationId = demoOperationId({
    command: "refund",
    seedPrefix,
    subject: `${runId}_${user.uid}`,
  });
  const marker = buildDemoMarker({
    admin,
    command: "create-refund",
    operationId,
    seedPrefix,
    now,
  });
  const paymentId = `${seedPrefix}_refund_${runId}_${user.uid}`;
  return {
    command: "create-refund",
    operationId,
    phone: user.phoneNumber,
    uid: user.uid,
    runId,
    docs: [{
      path: `payments/${paymentId}`,
      data: {
        ...marker,
        userId: user.uid,
        orderId: `${seedPrefix}_refund_order_${runId}_${user.uid}`,
        paymentId,
        runId,
        amount,
        currency: "INR",
        status: "refunded",
        signUpFailed: false,
        createdAt: timestampFromDate(admin, offsetDate(now, {days: -1})),
      },
    }],
  };
}

export async function buildHostAccountPlan({
  db,
  admin,
  phone,
  seedPrefix = DEFAULT_DEMO_OPS_PREFIX,
  now = new Date(),
}) {
  const user = await resolveUserByPhone(db, phone);
  const profile = await requirePublicProfile(db, user.uid);
  const operationId = demoOperationId({
    command: "host_account",
    seedPrefix,
    subject: user.uid,
  });
  const marker = buildDemoMarker({
    admin,
    command: "create-host-account",
    operationId,
    seedPrefix,
    now,
  });
  const clubId = `${seedPrefix}_host_club_${user.uid}`;
  const runId = `${seedPrefix}_host_run_${user.uid}_01`;
  const city = user.data.city ?? "mumbai";
  const docs = [
    {
      path: `runClubHostClaims/${user.uid}`,
      data: {
        ...marker,
        uid: user.uid,
        runClubId: clubId,
        createdAt: timestampFromDate(admin, now),
      },
    },
    {
      path: `runClubs/${clubId}`,
      data: {
        ...marker,
        name: `${publicName(profile.data, user.data)} Run Club`,
        description: "Demo host-owned run club for investor and beta walkthroughs.",
        location: city,
        area: cityLabel(city),
        hostUserId: user.uid,
        hostName: publicName(profile.data, user.data),
        hostAvatarUrl: firstPhoto(profile.data),
        createdAt: timestampFromDate(admin, now),
        imageUrl: null,
        tags: ["Demo", "Host tools"],
        memberCount: 1,
        rating: 0,
        reviewCount: 0,
        nextRunAt: timestampFromDate(admin, offsetDate(now, {days: 2})),
        nextRunLabel: `${cityLabel(city)} main gate`,
        instagramHandle: null,
        phoneNumber: user.phoneNumber,
        email: user.data.email ?? null,
        status: "active",
        archived: false,
        archivedAt: null,
        archiveReason: null,
      },
    },
    {
      path: `runClubMemberships/${clubId}_${user.uid}`,
      data: {
        ...marker,
        clubId,
        uid: user.uid,
        role: "host",
        status: "active",
        pushNotificationsEnabled: true,
        joinedAt: timestampFromDate(admin, now),
        leftAt: null,
        deletedAt: null,
      },
    },
    {
      path: `runs/${runId}`,
      data: {
        ...marker,
        runClubId: clubId,
        startTime: timestampFromDate(admin, offsetDate(now, {days: 2})),
        endTime: timestampFromDate(admin, offsetDate(now, {days: 2, hours: 1})),
        meetingPoint: `${cityLabel(city)} main gate`,
        startingPointLat: user.data.latitude ?? null,
        startingPointLng: user.data.longitude ?? null,
        locationDetails: "Demo host run created by demo ops.",
        distanceKm: 5,
        pace: "easy",
        capacityLimit: 12,
        description: "Host tools demo run with editable roster and attendance state.",
        priceInPaise: 0,
        bookedCount: 0,
        checkedInCount: 0,
        waitlistedCount: 0,
        status: "active",
        cancelledAt: null,
        cancellationReason: null,
        constraints: {minAge: 21, maxAge: 45, maxMen: null, maxWomen: null},
        genderCounts: {},
      },
    },
  ];
  docs.push(...buildRunClubScheduleLockDocs({
    run: {
      id: runId,
      data: docs.find((doc) => doc.path === `runs/${runId}`).data,
    },
  }));
  return {
    command: "create-host-account",
    operationId,
    phone: user.phoneNumber,
    uid: user.uid,
    runId,
    runClubId: clubId,
    docs,
    aggregateRepairRecommended: true,
  };
}

export async function buildResetUserDemoStatePlan({db, phone, uid}) {
  const resolved = uid ? {uid} : await resolveUserByPhone(db, phone);
  const userId = resolved.uid;
  const docs = [];
  const demoMatchIds = new Set();

  await collectManifestPaths(db, docs, userId);
  await collectTopLevelQueryPaths(db, docs, "runClubMemberships", "uid", userId);
  await collectTopLevelQueryPaths(db, docs, "runParticipations", "uid", userId);
  await collectTopLevelQueryPaths(db, docs, "userRunScheduleLocks", "uid", userId);
  await collectTopLevelQueryPaths(db, docs, "savedRuns", "uid", userId);
  await collectTopLevelQueryPaths(db, docs, "payments", "userId", userId);
  await collectMatchPaths(db, docs, demoMatchIds, userId);
  await collectOutgoingSwipePaths(db, docs, userId);
  await collectIncomingSwipePaths(db, docs, userId);
  await collectNotificationPaths(db, docs, userId, demoMatchIds);

  return {
    command: "reset-user-demo-state",
    uid: userId,
    phone: resolved.phoneNumber ?? null,
    paths: [...new Set(docs)].sort(),
    aggregateRepairRecommended: true,
  };
}

async function collectManifestPaths(db, docs, uid) {
  const snap = await db.collection(DEMO_MANIFEST_COLLECTION)
    .where("users", "array-contains", uid)
    .get();
  for (const doc of snap.docs) {
    const data = doc.data();
    if (Array.isArray(data.paths)) docs.push(...data.paths);
    docs.push(doc.ref.path);
  }
}

async function collectTopLevelQueryPaths(db, docs, collectionName, field, value) {
  const snap = await db.collection(collectionName).where(field, "==", value).get();
  for (const doc of snap.docs) {
    if (isDemoOwned(doc.data())) docs.push(doc.ref.path);
  }
}

async function collectMatchPaths(db, docs, demoMatchIds, uid) {
  const snap = await db.collection("matches")
    .where("participantIds", "array-contains", uid)
    .get();
  for (const doc of snap.docs) {
    if (!isDemoOwned(doc.data())) continue;
    demoMatchIds.add(doc.id);
    const messages = await doc.ref.collection("messages").get();
    for (const message of messages.docs) {
      docs.push(message.ref.path);
    }
    docs.push(doc.ref.path);
  }
}

async function collectOutgoingSwipePaths(db, docs, uid) {
  const snap = await db.collection("swipes").doc(uid).collection("outgoing").get();
  for (const doc of snap.docs) {
    if (isDemoOwned(doc.data())) docs.push(doc.ref.path);
  }
}

async function collectIncomingSwipePaths(db, docs, uid) {
  const swipersSnap = await db.collection("swipes").get();
  for (const swiperDoc of swipersSnap.docs) {
    if (swiperDoc.id === uid) continue;
    const outgoing = await swiperDoc.ref.collection("outgoing").get();
    for (const doc of outgoing.docs) {
      const data = doc.data();
      if (data.targetId === uid && isDemoOwned(data)) docs.push(doc.ref.path);
    }
  }
}

async function collectNotificationPaths(db, docs, uid, demoMatchIds = new Set()) {
  const snap = await db.collection("notifications").doc(uid).collection("items").get();
  for (const doc of snap.docs) {
    const data = doc.data();
    if (isDemoOwned(data) || demoMatchIds.has(data.matchId)) docs.push(doc.ref.path);
  }
}

export function isDemoOwned(data) {
  return data?.demoOps === true ||
    data?.synthetic === true ||
    typeof data?.seedPrefix === "string";
}

export async function buildValidateDemoStateReport({db, phone, uid}) {
  const resolved = uid ? {uid, phoneNumber: null} : await resolveUserByPhone(db, phone);
  const userId = resolved.uid;
  const [
    publicProfile,
    matches,
    participations,
    savedRuns,
    payments,
    notifications,
    outgoingSwipes,
  ] = await Promise.all([
    db.collection("publicProfiles").doc(userId).get(),
    db.collection("matches").where("participantIds", "array-contains", userId).get(),
    db.collection("runParticipations").where("uid", "==", userId).get(),
    db.collection("savedRuns").where("uid", "==", userId).get(),
    db.collection("payments").where("userId", "==", userId).get(),
    db.collection("notifications").doc(userId).collection("items").get(),
    db.collection("swipes").doc(userId).collection("outgoing").get(),
  ]);

  let messageCount = 0;
  for (const match of matches.docs) {
    const messages = await match.ref.collection("messages").get();
    messageCount += messages.size;
  }

  const counts = {
    activeMatches: matches.docs.filter((doc) => doc.data().status !== "blocked").length,
    messages: messageCount,
    participations: participations.size,
    attendedRuns: participations.docs.filter((doc) => doc.data().status === "attended").length,
    savedRuns: savedRuns.size,
    payments: payments.size,
    notifications: notifications.size,
    outgoingSwipes: outgoingSwipes.size,
  };
  const issues = [];
  if (!publicProfile.exists) issues.push(`Missing publicProfiles/${userId}.`);
  if (counts.activeMatches < 3) issues.push("Fewer than 3 active matches.");
  if (counts.messages < 3) issues.push("Fewer than 3 chat messages.");
  if (counts.participations < 3) issues.push("Fewer than 3 run participation edges.");
  if (counts.notifications < 3) issues.push("Fewer than 3 notifications.");

  return {
    uid: userId,
    phone: resolved.phoneNumber ?? null,
    publicProfileExists: publicProfile.exists,
    counts,
    demoReady: issues.length === 0,
    issues,
  };
}

export async function buildDemoChecklist({db, phone, uid}) {
  const report = await buildValidateDemoStateReport({db, phone, uid});
  const canDemo = [];
  const gaps = [];
  addCapability({
    canDemo,
    gaps,
    ok: report.publicProfileExists,
    label: "profile and public profile",
    gap: "public profile is missing",
  });
  addCapability({
    canDemo,
    gaps,
    ok: report.counts.participations > 0,
    label: "run detail and booking state",
    gap: "no run participation edges",
  });
  addCapability({
    canDemo,
    gaps,
    ok: report.counts.attendedRuns > 0,
    label: "post-run recap and swipe entry",
    gap: "no attended runs",
  });
  addCapability({
    canDemo,
    gaps,
    ok: report.counts.activeMatches > 0,
    label: "matches tab",
    gap: "no active matches",
  });
  addCapability({
    canDemo,
    gaps,
    ok: report.counts.messages > 0,
    label: "chat thread",
    gap: "no chat messages",
  });
  addCapability({
    canDemo,
    gaps,
    ok: report.counts.savedRuns > 0,
    label: "saved runs",
    gap: "no saved runs",
  });
  addCapability({
    canDemo,
    gaps,
    ok: report.counts.payments > 0,
    label: "payment history",
    gap: "no payment history",
  });
  addCapability({
    canDemo,
    gaps,
    ok: report.counts.notifications > 0,
    label: "activity notifications",
    gap: "no notifications",
  });
  return {...report, canDemo, gaps};
}

function addCapability({canDemo, gaps, ok, label, gap}) {
  if (ok) canDemo.push(label);
  else gaps.push(gap);
}

export async function buildLaunchCleanupPlan({
  db,
  seedPrefixes = [DEFAULT_DEMO_OPS_PREFIX, DEFAULT_SEED_PREFIX],
} = {}) {
  const paths = new Set();
  const topLevel = [
    "users",
    "publicProfiles",
    "runClubs",
    "runClubMemberships",
    "runClubHostClaims",
    "runs",
    "runParticipations",
    "runClubScheduleLocks",
    "userRunScheduleLocks",
    "savedRuns",
    "payments",
    "reviews",
    "matches",
    "seedRuns",
    DEMO_MANIFEST_COLLECTION,
  ];
  for (const collectionName of topLevel) {
    const snap = await db.collection(collectionName).get();
    for (const doc of snap.docs) {
      const data = doc.data();
      if (isDemoOwned(data) || hasDemoPrefix(doc.id, seedPrefixes)) {
        if (collectionName === "matches") {
          const messages = await doc.ref.collection("messages").get();
          for (const message of messages.docs) paths.add(message.ref.path);
        }
        paths.add(doc.ref.path);
      }
    }
  }

  const swipers = await db.collection("swipes").get();
  for (const swiperDoc of swipers.docs) {
    const outgoing = await swiperDoc.ref.collection("outgoing").get();
    for (const doc of outgoing.docs) {
      const data = doc.data();
      if (isDemoOwned(data) ||
        hasDemoPrefix(swiperDoc.id, seedPrefixes) ||
        hasDemoPrefix(doc.id, seedPrefixes)) {
        paths.add(doc.ref.path);
      }
    }
  }

  const notificationUsers = await db.collection("notifications").get();
  for (const userDoc of notificationUsers.docs) {
    const items = await userDoc.ref.collection("items").get();
    for (const doc of items.docs) {
      const data = doc.data();
      if (isDemoOwned(data) ||
        hasDemoPrefix(userDoc.id, seedPrefixes) ||
        hasDemoPrefix(doc.id, seedPrefixes) ||
        hasDemoPrefix(data.matchId, seedPrefixes) ||
        hasDemoPrefix(data.runId, seedPrefixes) ||
        hasDemoPrefix(data.runClubId, seedPrefixes)) {
        paths.add(doc.ref.path);
      }
    }
  }

  return {
    command: "cleanup-demo-data",
    paths: [...paths].sort(),
    seedPrefixes,
  };
}

function hasDemoPrefix(value, seedPrefixes) {
  return typeof value === "string" &&
    seedPrefixes.some((prefix) => value.startsWith(prefix));
}

export async function applyDocPlan({db, docs}) {
  let written = 0;
  for (const chunk of chunks(docs, DEFAULT_MAX_BATCH_WRITES)) {
    const batch = db.batch();
    for (const doc of chunk) {
      batch.set(db.doc(doc.path), doc.data, {merge: true});
      written += 1;
    }
    await batch.commit();
  }
  return {written};
}

export async function applyDeletePlan({db, paths}) {
  let deleted = 0;
  for (const chunk of chunks(paths, DEFAULT_MAX_BATCH_WRITES)) {
    const batch = db.batch();
    for (const docPath of chunk) {
      batch.delete(db.doc(docPath));
      deleted += 1;
    }
    await batch.commit();
  }
  return {deleted};
}

export async function writeManifest({db, admin, plan, apply, now = new Date()}) {
  const operationId = plan.operationId ??
    demoOperationId({
      command: plan.command ?? "operation",
      seedPrefix: DEFAULT_DEMO_OPS_PREFIX,
      subject: plan.uid ?? plan.matchId ?? String(now.getTime()),
    });
  const paths = plan.docs ? plan.docs.map((doc) => doc.path) : plan.paths ?? [];
  const manifest = {
    command: plan.command,
    operationId,
    applied: apply,
    createdAt: timestampFromDate(admin, now),
    users: plan.users ?? (plan.uid ? [plan.uid] : []),
    phones: plan.phones ?? (plan.phone ? [plan.phone] : []),
    matchId: plan.matchId ?? null,
    runId: plan.runId ?? null,
    paths,
    pathCount: paths.length,
  };
  if (apply) {
    await db.collection(DEMO_MANIFEST_COLLECTION).doc(operationId).set(manifest, {merge: true});
  }
  return manifest;
}

export function uniqueDocsByPath(docs) {
  const byPath = new Map();
  for (const doc of docs) byPath.set(doc.path, doc);
  return [...byPath.values()].sort((a, b) => a.path.localeCompare(b.path));
}

export function chunks(items, size) {
  const result = [];
  for (let i = 0; i < items.length; i += size) {
    result.push(items.slice(i, i + size));
  }
  return result;
}

export function publicName(publicProfile, userProfile = {}) {
  return publicProfile?.name ||
    userProfile.displayName ||
    userProfile.firstName ||
    userProfile.name ||
    "Someone";
}

export function firstPhoto(publicProfile = {}) {
  return Array.isArray(publicProfile.photoThumbnailUrls) &&
    publicProfile.photoThumbnailUrls.length > 0 ?
    publicProfile.photoThumbnailUrls[0] :
    Array.isArray(publicProfile.photoUrls) && publicProfile.photoUrls.length > 0 ?
      publicProfile.photoUrls[0] :
      null;
}

export function cityLabel(city) {
  return cityLabels[city] ?? "your city";
}
