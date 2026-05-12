#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";
import {
  assertScheduleCompliance,
  buildScheduleLockDocs,
} from "./demo_schedule_policy.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const admin = requireFromFunctions("firebase-admin");

const DEFAULT_SEED_PREFIX = "demo_beta_2026";
const DEFAULT_MAX_BATCH_WRITES = 450;
const MATCH_MESSAGE_LIMIT = 18;

const cityData = {
  mumbai: {label: "Mumbai", lat: 19.076, lng: 72.8777, areas: ["Bandra", "Marine Drive", "Powai"]},
  delhi: {label: "Delhi", lat: 28.7041, lng: 77.1025, areas: ["Lodhi Garden", "Hauz Khas", "India Gate"]},
  bangalore: {label: "Bangalore", lat: 12.9716, lng: 77.5946, areas: ["Cubbon Park", "Indiranagar", "Jayanagar"]},
  hyderabad: {label: "Hyderabad", lat: 17.385, lng: 78.4867, areas: ["Necklace Road", "Gachibowli", "Jubilee Hills"]},
  chennai: {label: "Chennai", lat: 13.0827, lng: 80.2707, areas: ["Besant Nagar", "Marina", "Adyar"]},
  kolkata: {label: "Kolkata", lat: 22.5726, lng: 88.3639, areas: ["Maidan", "Salt Lake", "New Town"]},
  pune: {label: "Pune", lat: 18.5204, lng: 73.8567, areas: ["Koregaon Park", "Baner", "Viman Nagar"]},
  ahmedabad: {label: "Ahmedabad", lat: 23.0225, lng: 72.5714, areas: ["Riverfront", "Satellite", "Bodakdev"]},
  indore: {label: "Indore", lat: 22.7196, lng: 75.8577, areas: ["Race Course Road", "Vijay Nagar", "Rajwada"]},
};

const allCities = Object.keys(cityData);

const scenarios = {
  smoke: {
    description: "Small seed for quick local/dev checks.",
    cities: ["mumbai", "bangalore", "indore"],
    usersPerCity: 4,
    clubsPerCity: 1,
    runsPerClub: 5,
    anchorsPerRun: 2,
  },
  "beta-full": {
    description: "Full TestFlight-style world across every supported city.",
    cities: allCities,
    usersPerCity: 8,
    clubsPerCity: 2,
    runsPerClub: 8,
    anchorsPerRun: 4,
  },
  "city-dense": {
    description: "Dense one-city discovery, map, and list stress scenario.",
    cities: ["mumbai"],
    usersPerCity: 36,
    clubsPerCity: 5,
    runsPerClub: 8,
    anchorsPerRun: 5,
  },
  "empty-edge-cases": {
    description: "Sparse world with empty, expired, cancelled, and waitlist states.",
    cities: ["mumbai", "delhi", "bangalore", "indore"],
    usersPerCity: 4,
    clubsPerCity: 1,
    runsPerClub: 7,
    anchorsPerRun: 1,
  },
  "paid-flow-demo": {
    description: "Paid booking, payment history, refund, and sign-up-failed states.",
    cities: ["mumbai", "bangalore", "delhi", "indore"],
    usersPerCity: 6,
    clubsPerCity: 1,
    runsPerClub: 6,
    anchorsPerRun: 3,
    preferPaidRuns: true,
  },
};

const firstNames = [
  "Aarav", "Aditi", "Kabir", "Mira", "Rohan", "Naina", "Vivaan", "Isha",
  "Arjun", "Sara", "Dev", "Tara", "Neel", "Anika", "Reyansh", "Zoya",
  "Kian", "Diya", "Rudra", "Kiara", "Yash", "Avni", "Vihaan", "Sia",
];
const lastNames = [
  "Mehta", "Rao", "Kapoor", "Shah", "Iyer", "Khan", "Patel", "Menon",
  "Gupta", "Nair", "Bose", "Reddy", "Malhotra", "Joshi", "Pillai", "Sethi",
];
const occupations = [
  "Product designer", "Founder", "Data analyst", "Architect", "Doctor",
  "Brand strategist", "Software engineer", "Lawyer", "Fitness coach",
  "Consultant", "Filmmaker", "Teacher",
];
const companies = [
  "Freelance", "Urban Loop", "Northstar", "Founders Office", "Studio Run",
  "Cloudline", "Stride Labs", "Independent",
];
const bios = [
  "Easy kilometres, strong coffee, and plans that start on time.",
  "Training for a faster 10K and always up for post-run breakfast.",
  "I like neighbourhood routes, clean playlists, and low-pressure chats.",
  "Weekend long runs, weekday strength sessions, and new city corners.",
  "Mostly here for good routes, kind people, and a reason to wake up early.",
  "Race curious, brunch serious, and happiest near a waterfront route.",
];
const profilePhotos = [
  "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80",
  "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=900&q=80",
  "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80",
  "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=900&q=80",
  "https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=900&q=80",
  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80",
  "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=900&q=80",
  "https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=900&q=80",
];
const clubImages = [
  "https://images.unsplash.com/photo-1552674605-db6ffd4facb5?auto=format&fit=crop&w=1400&q=80",
  "https://images.unsplash.com/photo-1486218119243-13883505764c?auto=format&fit=crop&w=1400&q=80",
  "https://images.unsplash.com/photo-1546483875-ad9014c88eba?auto=format&fit=crop&w=1400&q=80",
  "https://images.unsplash.com/photo-1571008887538-b36bb32f4571?auto=format&fit=crop&w=1400&q=80",
];

const meetingPointData = {
  mumbai: [
    {label: "Bandra Carter Road amphitheatre", lat: 19.0704, lng: 72.8220, detail: "Meet beside the amphitheatre steps facing the promenade."},
    {label: "Marine Drive police gymkhana gate", lat: 18.9432, lng: 72.8234, detail: "Meet near the sea-facing gate before the promenade warm-up."},
    {label: "Powai lake garden entrance", lat: 19.1197, lng: 72.9052, detail: "Meet at the garden entrance opposite the lake path."},
  ],
  delhi: [
    {label: "Lodhi Garden gate 1", lat: 28.5933, lng: 77.2209, detail: "Meet just inside gate 1 near the stone benches."},
    {label: "Hauz Khas deer park gate", lat: 28.5494, lng: 77.2001, detail: "Meet at the deer park entrance before the loop."},
    {label: "India Gate lawns east side", lat: 28.6129, lng: 77.2295, detail: "Meet on the east lawn path facing India Gate."},
  ],
  bangalore: [
    {label: "Cubbon Park Queen's statue", lat: 12.9763, lng: 77.5929, detail: "Meet near the Queen's statue before the park loop."},
    {label: "Indiranagar 100 ft road metro gate", lat: 12.9784, lng: 77.6408, detail: "Meet outside the metro gate on the service-road side."},
    {label: "Jayanagar 4th block bus stand", lat: 12.9250, lng: 77.5938, detail: "Meet near the bus stand entrance before the neighbourhood route."},
  ],
  hyderabad: [
    {label: "Necklace Road People's Plaza", lat: 17.4239, lng: 78.4738, detail: "Meet at the plaza entrance facing Hussain Sagar."},
    {label: "Gachibowli stadium gate", lat: 17.4401, lng: 78.3489, detail: "Meet outside the main stadium gate."},
    {label: "Jubilee Hills check post", lat: 17.4326, lng: 78.4071, detail: "Meet near the check-post pavement before the hill route."},
  ],
  chennai: [
    {label: "Besant Nagar beach police booth", lat: 12.9995, lng: 80.2668, detail: "Meet beside the beach police booth before the promenade run."},
    {label: "Marina lighthouse entrance", lat: 13.0500, lng: 80.2824, detail: "Meet near the lighthouse entrance facing the service road."},
    {label: "Adyar theosophical gate", lat: 13.0067, lng: 80.2574, detail: "Meet outside the gate before the shaded loop."},
  ],
  kolkata: [
    {label: "Maidan Victoria Memorial north gate", lat: 22.5600, lng: 88.3426, detail: "Meet at the north gate before the Maidan loop."},
    {label: "Salt Lake Central Park gate", lat: 22.5867, lng: 88.4171, detail: "Meet by the Central Park gate near the lake path."},
    {label: "New Town Eco Park gate 1", lat: 22.5810, lng: 88.4765, detail: "Meet outside gate 1 before the long loop."},
  ],
  pune: [
    {label: "Koregaon Park lane 5 corner", lat: 18.5362, lng: 73.8938, detail: "Meet at the lane 5 corner before the tree-lined route."},
    {label: "Baner hill trail gate", lat: 18.5590, lng: 73.7868, detail: "Meet at the trail gate before the hill warm-up."},
    {label: "Viman Nagar jogging track gate", lat: 18.5679, lng: 73.9143, detail: "Meet outside the jogging track gate."},
  ],
  ahmedabad: [
    {label: "Sabarmati Riverfront event centre", lat: 23.0300, lng: 72.5800, detail: "Meet at the event-centre entrance on the riverfront path."},
    {label: "Satellite prahladnagar garden gate", lat: 23.0301, lng: 72.5178, detail: "Meet by the garden gate before the neighbourhood route."},
    {label: "Bodakdev sindhu bhavan corner", lat: 23.0396, lng: 72.5130, detail: "Meet at the corner pavement near the cafe row."},
  ],
  indore: [
    {label: "Race Course Road main gate", lat: 22.7274, lng: 75.8818, detail: "Meet by the main gate on the Race Course Road side."},
    {label: "Vijay Nagar main gate", lat: 22.7533, lng: 75.8937, detail: "Meet outside the Vijay Nagar main gate before the service-road loop."},
    {label: "Rajwada square clock tower", lat: 22.7196, lng: 75.8577, detail: "Meet near the clock tower side of Rajwada square."},
  ],
};

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

if (args.listScenarios) {
  printScenarios();
  process.exit(0);
}

const scenario = scenarios[args.scenario];
if (!scenario) {
  throw new Error(`Unknown scenario "${args.scenario}". Use --list-scenarios.`);
}

const projectId = resolveProjectId(args);
const isProdTarget = isProductionTarget(args, projectId);
if (args.apply && isProdTarget && !args.allowProd) {
  throw new Error(
    "Refusing to write to prod without --allow-prod. Rerun only if this is intentional."
  );
}
if (args.resetSynthetic && !args.apply) {
  throw new Error("--reset-synthetic only makes sense with --apply.");
}
if (args.deleteOnly && !args.apply) {
  throw new Error("--delete-only requires --apply.");
}
if (args.deleteOnly && !args.resetSynthetic) {
  throw new Error("--delete-only requires --reset-synthetic.");
}
if (args.appendAnchors && args.resetSynthetic) {
  throw new Error("--append-anchors cannot be combined with --reset-synthetic.");
}
if (args.appendAnchors && args.deleteOnly) {
  throw new Error("--append-anchors cannot be combined with --delete-only.");
}
if (args.emulatorHost) {
  process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
}

admin.initializeApp({projectId});
const db = admin.firestore();

const anchorSpecs = loadAnchorSpecs(args);
const anchorProfiles = await loadAnchorProfiles(db, anchorSpecs);
const missingPublicProfileIds = await findMissingPublicProfiles(
  db,
  anchorProfiles.map((profile) => profile.uid)
);
const seed = buildSeed({
  scenarioName: args.scenario,
  scenario,
  seedPrefix: args.seedPrefix,
  anchorProfiles,
  now: args.appendAnchors ?
    await readExistingSeedTime(db, `${args.seedPrefix}_${args.scenario}`) :
    new Date(),
  includeScheduleLocks: args.includeScheduleLocks,
});
const writePlan = args.appendAnchors ?
  await createAppendWritePlan({db, seed, anchorProfiles}) :
  createWritePlan(seed);

if (args.json) {
  console.log(JSON.stringify(summary({args, projectId, scenario, anchorProfiles, seed, writePlan, missingPublicProfileIds}), null, 2));
} else {
  printSummary({args, projectId, scenario, anchorProfiles, seed, writePlan, missingPublicProfileIds});
}

if (!args.apply) {
  if (!args.json) {
    console.log("\nDry run only. Re-run with --apply to write these documents.");
  }
  process.exit(0);
}

const resetReport = args.resetSynthetic ?
  await resetSyntheticData({
    db,
    manifestId: seed.manifestId,
    seedPrefix: args.seedPrefix,
    fallbackPaths: writePlan.paths,
  }) :
  {deleted: 0, source: "skipped"};
if (args.deleteOnly) {
  if (!args.json) {
    console.log("\nSynthetic seed data deleted.");
    console.log(`Reset source: ${resetReport.source}`);
    console.log(`Deleted docs: ${resetReport.deleted}`);
  }
  process.exit(0);
}
const writeReport = await applyWritePlan({db, docs: writePlan.docs});
await db.collection("seedRuns").doc(seed.manifestId).set(
  writePlan.manifest ?? seed.manifest
);

if (!args.json) {
  console.log("\nSeed applied.");
  console.log(`Reset source: ${resetReport.source}`);
  console.log(`Deleted docs: ${resetReport.deleted}`);
  console.log(`Written docs: ${writeReport.written}`);
  console.log(`Manifest: seedRuns/${seed.manifestId}`);
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    scenario: "beta-full",
    seedPrefix: DEFAULT_SEED_PREFIX,
    anchorUsers: [],
    anchorPhones: [],
    anchorFile: null,
    apply: false,
    allowProd: false,
    resetSynthetic: false,
    deleteOnly: false,
    appendAnchors: false,
    emulatorHost: null,
    json: false,
    includeScheduleLocks: false,
    help: false,
    listScenarios: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--list-scenarios") parsed.listScenarios = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--include-schedule-locks") parsed.includeScheduleLocks = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--dry-run") parsed.apply = false;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--reset-synthetic") parsed.resetSynthetic = true;
    else if (arg === "--delete-only") parsed.deleteOnly = true;
    else if (arg === "--append-anchors") parsed.appendAnchors = true;
    else if (arg === "--emulator") parsed.emulatorHost = "127.0.0.1:8080";
    else if (arg === "--emulator-host") parsed.emulatorHost = requireValue(argv, ++i, arg);
    else if (arg === "--env") parsed.env = requireValue(argv, ++i, arg);
    else if (arg === "--project") parsed.project = requireValue(argv, ++i, arg);
    else if (arg === "--scenario") parsed.scenario = requireValue(argv, ++i, arg);
    else if (arg === "--seed-prefix") parsed.seedPrefix = requireValue(argv, ++i, arg);
    else if (arg === "--anchor-users") parsed.anchorUsers = splitCsv(requireValue(argv, ++i, arg));
    else if (arg === "--anchor-phones") parsed.anchorPhones = splitCsv(requireValue(argv, ++i, arg));
    else if (arg === "--anchor-file") parsed.anchorFile = requireValue(argv, ++i, arg);
    else throw new Error(`Unknown argument: ${arg}`);
  }

  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function splitCsv(value) {
  return value.split(",").map((item) => item.trim()).filter(Boolean);
}

function resolveProjectId(parsed) {
  if (parsed.project) return parsed.project;
  const firebaserc = JSON.parse(fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8"));
  if (parsed.env) {
    const project = firebaserc.projects?.[parsed.env];
    if (!project) throw new Error(`No Firebase project alias found for env: ${parsed.env}`);
    return project;
  }
  return firebaserc.projects?.dev ?? "catchdates-dev";
}

function isProductionTarget(parsed, projectId) {
  const firebaserc = JSON.parse(fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8"));
  return parsed.env === "prod" || projectId === firebaserc.projects?.prod;
}

function loadAnchorSpecs(parsed) {
  const result = {
    users: new Set(parsed.anchorUsers),
    phones: new Set(parsed.anchorPhones),
  };
  if (!parsed.anchorFile) {
    return {
      users: [...result.users],
      phones: [...result.phones],
    };
  }

  const filePath = path.resolve(process.cwd(), parsed.anchorFile);
  const raw = fs.readFileSync(filePath, "utf8");
  if (filePath.endsWith(".json")) {
    const json = JSON.parse(raw);
    for (const uid of json.uids ?? json.users ?? []) result.users.add(uid);
    for (const phone of json.phones ?? json.phoneNumbers ?? []) result.phones.add(phone);
  } else {
    for (const line of raw.split(/\r?\n/)) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith("#")) continue;
      if (trimmed.startsWith("+")) result.phones.add(trimmed);
      else result.users.add(trimmed);
    }
  }
  return {
    users: [...result.users],
    phones: [...result.phones],
  };
}

async function loadAnchorProfiles(firestore, anchorSpecs) {
  const byUid = new Map();
  for (const uid of anchorSpecs.users) {
    const doc = await firestore.collection("users").doc(uid).get();
    if (!doc.exists) throw new Error(`Anchor user not found: users/${uid}`);
    byUid.set(uid, anchorProfileFromUserDoc(uid, doc.data()));
  }
  for (const phone of anchorSpecs.phones) {
    const snap = await firestore.collection("users")
      .where("phoneNumber", "==", phone)
      .limit(2)
      .get();
    if (snap.empty) throw new Error(`Anchor phone number not found in users: ${phone}`);
    if (snap.size > 1) throw new Error(`Anchor phone number matched multiple users: ${phone}`);
    const doc = snap.docs[0];
    byUid.set(doc.id, anchorProfileFromUserDoc(doc.id, doc.data()));
  }
  return [...byUid.values()].sort((a, b) => a.uid.localeCompare(b.uid));
}

function anchorProfileFromUserDoc(uid, data) {
  const firstName = data.firstName || firstWord(data.displayName || data.name || "Runner");
  const displayName = data.displayName || firstName;
  const gender = validGender(data.gender) ? data.gender : "other";
  return {
    uid,
    firstName,
    name: data.name || displayName,
    displayName,
    gender,
    city: validCity(data.city) ? data.city : "mumbai",
    latitude: typeof data.latitude === "number" ? data.latitude : cityData.mumbai.lat,
    longitude: typeof data.longitude === "number" ? data.longitude : cityData.mumbai.lng,
    age: ageFromTimestamp(data.dateOfBirth) ?? 30,
    photoUrls: Array.isArray(data.photoUrls) ? data.photoUrls : [],
    source: "anchor",
  };
}

async function findMissingPublicProfiles(firestore, uids) {
  const missing = [];
  for (const uid of uids) {
    const doc = await firestore.collection("publicProfiles").doc(uid).get();
    if (!doc.exists) missing.push(uid);
  }
  return missing;
}

function buildSeed({
  scenarioName,
  scenario,
  seedPrefix,
  anchorProfiles,
  now,
  includeScheduleLocks = false,
}) {
  const seedId = `${seedPrefix}_${scenarioName}`;
  const seedMarker = {
    synthetic: true,
    seedPrefix,
    scenario: scenarioName,
  };
  const users = buildSyntheticUsers({scenario, seedPrefix, seedMarker});
  const clubs = [];
  const memberships = [];
  const runs = [];
  const participations = [];
  const savedRuns = [];
  const swipes = [];
  const matches = [];
  const messages = [];
  const payments = [];
  const reviews = [];
  const notifications = [];

  for (const city of scenario.cities) {
    const cityAnchors = anchorProfiles.filter((person) => person.city === city);
    const syntheticCityUsers = users.filter((person) => person.city === city);
    for (let clubIndex = 0; clubIndex < scenario.clubsPerCity; clubIndex += 1) {
      const host = syntheticCityUsers[clubIndex % syntheticCityUsers.length] ?? users[clubIndex % users.length];
      const club = buildClub({seedPrefix, seedMarker, city, clubIndex, host});
      clubs.push(club);

      const clubMembers = uniqueByUid([
        host,
        ...cityAnchors.slice(0, scenario.anchorsPerRun),
        ...rotate(syntheticCityUsers, clubIndex).slice(0, Math.min(10, syntheticCityUsers.length)),
      ]);
      for (const member of clubMembers) {
        memberships.push(buildMembership({seedMarker, clubId: club.id, uid: member.uid, role: member.uid === host.uid ? "host" : "member", now}));
      }

      for (let runIndex = 0; runIndex < scenario.runsPerClub; runIndex += 1) {
        const run = buildRun({
          seedPrefix,
          seedMarker,
          city,
          club,
          runIndex,
          clubIndex,
          now,
          preferPaid: scenario.preferPaidRuns,
        });
        const roster = buildRoster({run, runIndex, clubMembers, anchorProfiles: cityAnchors});
        applyRosterAggregates(run, roster);
        runs.push(run);
        for (const rosterEntry of roster) {
          participations.push(buildParticipation({seedMarker, run, entry: rosterEntry, now}));
          if (rosterEntry.paymentState) {
            payments.push(buildPayment({seedPrefix, seedMarker, run, uid: rosterEntry.person.uid, state: rosterEntry.paymentState, now}));
          }
        }
        for (const anchor of cityAnchors.slice(0, Math.min(2, cityAnchors.length))) {
          if (runIndex === 0 || runIndex === 1) {
            savedRuns.push(buildSavedRun({seedMarker, uid: anchor.uid, runId: run.id, now}));
          }
        }
        if (run.kind === "pastOpen") {
          const relationshipDocs = buildSwipeMatchDocs({
            seedPrefix,
            seedMarker,
            run,
            roster,
            anchorProfiles,
            now,
          });
          swipes.push(...relationshipDocs.swipes);
          matches.push(...relationshipDocs.matches);
          messages.push(...relationshipDocs.messages);
          notifications.push(...relationshipDocs.notifications);
        }
        if (run.kind === "pastOld") {
          reviews.push(...buildReviews({seedPrefix, seedMarker, club, run, roster, now}));
        }
      }
    }
  }

  updateClubAggregates({clubs, memberships, reviews, runs});
  notifications.push(...buildGeneralNotifications({seedMarker, anchorProfiles, clubs, runs, now}));
  payments.push(...buildPaymentHistoryEdges({seedPrefix, seedMarker, anchorProfiles, runs, now}));
  assertScheduleCompliance({runs, participations});
  assertRunCoordinateQuality({runs});
  const scheduleLocks = includeScheduleLocks ?
    buildScheduleLockDocs({runs, participations}) :
    [];

  const docs = [
    ...users.flatMap((user) => [
      {path: `users/${user.uid}`, data: user.userDoc},
      {path: `publicProfiles/${user.uid}`, data: user.publicProfileDoc},
    ]),
    ...clubs.map((club) => ({path: `runClubs/${club.id}`, data: club.doc})),
    ...memberships.map((membership) => ({path: `runClubMemberships/${membership.id}`, data: membership.doc})),
    ...runs.map((run) => ({path: `runs/${run.id}`, data: run.doc})),
    ...participations.map((participation) => ({path: `runParticipations/${participation.id}`, data: participation.doc})),
    ...scheduleLocks,
    ...savedRuns.map((savedRun) => ({path: `savedRuns/${savedRun.id}`, data: savedRun.doc})),
    ...swipes.map((swipe) => ({path: `swipes/${swipe.swiperId}/outgoing/${swipe.targetId}`, data: swipe.doc})),
    ...matches.map((match) => ({path: `matches/${match.id}`, data: match.doc})),
    ...messages.map((message) => ({path: `matches/${message.matchId}/messages/${message.id}`, data: message.doc})),
    ...payments.map((payment) => ({path: `payments/${payment.id}`, data: payment.doc})),
    ...reviews.map((review) => ({path: `reviews/${review.id}`, data: review.doc})),
    ...notifications.map((notification) => ({
      path: `notifications/${notification.uid}/items/${notification.id}`,
      data: notification.doc,
    })),
  ];
  const uniqueDocs = uniqueDocsByPath(docs);
  const manifestId = seedId.replace(/[^A-Za-z0-9_-]/g, "_");
  const manifest = {
    ...seedMarker,
    seedId,
    manifestId,
    generatedAt: admin.firestore.Timestamp.fromDate(now),
    anchorUserIds: anchorProfiles.map((profile) => profile.uid),
    counts: countDocs(uniqueDocs),
    paths: uniqueDocs.map((doc) => doc.path),
  };

  return {
    seedId,
    manifestId,
    docs: uniqueDocs,
    manifest,
    counts: manifest.counts,
  };
}

function buildSyntheticUsers({scenario, seedPrefix, seedMarker}) {
  const users = [];
  const usedDisplayNames = new Set();
  let index = 0;
  for (const city of scenario.cities) {
    const cityMeta = cityData[city];
    for (let cityUserIndex = 0; cityUserIndex < scenario.usersPerCity; cityUserIndex += 1) {
      const uid = `${seedPrefix}_user_${String(index + 1).padStart(3, "0")}`;
      const firstName = firstNames[index % firstNames.length];
      const lastName = lastNames[(index * 3) % lastNames.length];
      const gender = ["woman", "man", "woman", "man", "nonBinary", "woman", "man", "other"][index % 8];
      const age = 23 + (index % 16);
      const displayName = uniqueSyntheticDisplayName({
        firstName,
        lastName,
        city,
        usedDisplayNames,
      });
      const lat = cityMeta.lat + (((index % 7) - 3) * 0.008);
      const lng = cityMeta.lng + ((((index + 3) % 7) - 3) * 0.008);
      const repetition = Math.floor(index / firstNames.length);
      const photo = profilePhotos[(index + repetition) % profilePhotos.length];
      const userDoc = {
        ...seedMarker,
        name: `${firstName} ${lastName}`,
        firstName,
        lastName,
        displayName,
        dateOfBirth: dateOfBirthForAge(age, index),
        gender,
        phoneNumber: `+919900${String(index + 1).padStart(6, "0")}`,
        profileComplete: true,
        email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}.${index + 1}@example.test`,
        bio: bios[index % bios.length],
        instagramHandle: `${firstName.toLowerCase()}runs${index + 1}`,
        photoUrls: [photo],
        city,
        latitude: lat,
        longitude: lng,
        interestedInGenders: interestedInFor(gender, index),
        minAgePreference: 22,
        maxAgePreference: 42,
        height: 155 + (index % 38),
        occupation: occupations[index % occupations.length],
        company: companies[index % companies.length],
        education: ["bachelors", "masters", "someCollege", "phd", "tradeSchool"][index % 5],
        religion: ["hindu", "muslim", "christian", "sikh", "jain", "nonReligious"][index % 6],
        languages: languageSet(city, index),
        relationshipGoal: ["relationship", "casual", "marriage", "friendship", "unsure"][index % 5],
        drinking: ["never", "socially", "often"][index % 3],
        smoking: ["never", "occasionally", "never"][index % 3],
        workout: ["sometimes", "often", "everyday"][index % 3],
        diet: ["omnivore", "vegetarian", "vegan", "jain"][index % 4],
        children: ["dontHave", "wantSomeday", "dontWant"][index % 3],
        paceMinSecsPerKm: 275 + (index % 5) * 15,
        paceMaxSecsPerKm: 375 + (index % 5) * 20,
        preferredDistances: [["fiveK", "tenK"], ["tenK"], ["halfMarathon"], ["fiveK", "halfMarathon"]][index % 4],
        runningReasons: [["fitness", "social"], ["community", "mindfulness"], ["challenge", "raceTraining"]][index % 3],
        prefsNewCatches: true,
        prefsMessages: true,
        prefsRunReminders: true,
        prefsRunStatusUpdates: true,
        prefsClubUpdates: true,
        prefsWeeklyDigest: index % 3 === 0,
        prefsShowOnMap: true,
      };
      users.push({
        uid,
        firstName,
        name: userDoc.name,
        displayName,
        gender,
        city,
        age,
        latitude: lat,
        longitude: lng,
        photoUrls: [photo],
        source: "synthetic",
        userDoc,
        publicProfileDoc: publicProfileFromUserDoc(userDoc),
      });
      index += 1;
    }
  }
  return users;
}

function uniqueSyntheticDisplayName({firstName, lastName, city, usedDisplayNames}) {
  const base = `${firstName} ${lastName}`;
  if (!usedDisplayNames.has(base)) {
    usedDisplayNames.add(base);
    return base;
  }

  const cityLabel = cityData[city]?.label ?? city;
  let candidate = `${base} (${cityLabel})`;
  let suffix = 2;
  while (usedDisplayNames.has(candidate)) {
    candidate = `${base} (${cityLabel} ${suffix})`;
    suffix += 1;
  }
  usedDisplayNames.add(candidate);
  return candidate;
}

function publicProfileFromUserDoc(userDoc) {
  return {
    synthetic: userDoc.synthetic,
    seedPrefix: userDoc.seedPrefix,
    scenario: userDoc.scenario,
    name: userDoc.displayName || userDoc.firstName || firstWord(userDoc.name),
    age: ageFromTimestamp(userDoc.dateOfBirth) ?? 30,
    bio: userDoc.bio,
    gender: userDoc.gender,
    photoUrls: userDoc.photoUrls,
    city: userDoc.city,
    height: userDoc.height,
    occupation: userDoc.occupation,
    company: userDoc.company,
    education: userDoc.education,
    religion: userDoc.religion,
    languages: userDoc.languages,
    relationshipGoal: userDoc.relationshipGoal,
    drinking: userDoc.drinking,
    smoking: userDoc.smoking,
    workout: userDoc.workout,
    diet: userDoc.diet,
    children: userDoc.children,
    paceMinSecsPerKm: userDoc.paceMinSecsPerKm,
    paceMaxSecsPerKm: userDoc.paceMaxSecsPerKm,
    preferredDistances: userDoc.preferredDistances,
    runningReasons: userDoc.runningReasons,
  };
}

function buildClub({seedPrefix, seedMarker, city, clubIndex, host}) {
  const cityMeta = cityData[city];
  const area = cityMeta.areas[clubIndex % cityMeta.areas.length];
  const id = `${seedPrefix}_club_${city}_${String(clubIndex + 1).padStart(2, "0")}`;
  return {
    id,
    city,
    doc: {
      ...seedMarker,
      name: `${area} Run Collective`,
      description: `Social ${cityMeta.label} runs for easy kilometres, coffee stops, and reliable weekend training.`,
      location: city,
      area,
      hostUserId: host.uid,
      hostName: host.displayName || host.firstName,
      hostAvatarUrl: host.photoUrls?.[0] ?? null,
      createdAt: admin.firestore.Timestamp.fromDate(daysFromNow(-35 - clubIndex)),
      imageUrl: clubImages[clubIndex % clubImages.length],
      tags: ["social", clubIndex % 2 === 0 ? "beginner-friendly" : "tempo", cityMeta.label.toLowerCase()],
      memberCount: 0,
      rating: 0,
      reviewCount: 0,
      nextRunAt: null,
      nextRunLabel: null,
      instagramHandle: `${area.toLowerCase().replace(/\s+/g, "")}runs`,
      phoneNumber: `+918800${String(clubIndex + 1).padStart(6, "0")}`,
      email: `${area.toLowerCase().replace(/\s+/g, ".")}@catch.demo`,
      status: "active",
      archived: false,
      archivedAt: null,
      archiveReason: null,
    },
  };
}

function buildMembership({seedMarker, clubId, uid, role, now}) {
  return {
    id: `${clubId}_${uid}`,
    doc: {
      ...seedMarker,
      clubId,
      uid,
      role,
      status: "active",
      pushNotificationsEnabled: true,
      joinedAt: admin.firestore.Timestamp.fromDate(offsetDate(now, {days: -18})),
      leftAt: null,
      deletedAt: null,
    },
  };
}

function buildRun({seedPrefix, seedMarker, city, club, runIndex, clubIndex, now, preferPaid}) {
  const cityMeta = cityData[city];
  const patterns = [
    {kind: "upcomingFree", offsetHours: 30, price: 0, capacity: 12, durationMinutes: 70},
    {kind: "upcomingPaid", offsetHours: 84, price: preferPaid ? 79900 : 29900, capacity: 10, durationMinutes: 80},
    {kind: "upcomingFull", offsetHours: 168, price: preferPaid ? 49900 : 0, capacity: 6, durationMinutes: 60},
    {kind: "upcomingWaitlist", offsetHours: 336, price: 0, capacity: 5, durationMinutes: 65},
    {kind: "pastOpen", offsetHours: -8, price: 0, capacity: 14, durationMinutes: 60},
    {kind: "pastOld", offsetHours: -120, price: preferPaid ? 39900 : 0, capacity: 14, durationMinutes: 75},
    {kind: "cancelled", offsetHours: 220, price: 0, capacity: 10, durationMinutes: 70},
    {kind: "upcomingFree", offsetHours: 504, price: 0, capacity: 16, durationMinutes: 90},
  ];
  const pattern = patterns[runIndex % patterns.length];
  const start = offsetDate(now, {hours: pattern.offsetHours + clubIndex * 8 + runIndex * 2});
  const end = offsetDate(start, {minutes: pattern.durationMinutes});
  const id = `${seedPrefix}_run_${city}_${String(clubIndex + 1).padStart(2, "0")}_${String(runIndex + 1).padStart(2, "0")}`;
  const pace = ["easy", "moderate", "fast", "competitive"][runIndex % 4];
  const meetingPoint = meetingPointForRun({city, clubIndex, runIndex});
  return {
    id,
    clubId: club.id,
    city,
    kind: pattern.kind,
    priceInPaise: pattern.price,
    doc: {
      ...seedMarker,
      runClubId: club.id,
      startTime: admin.firestore.Timestamp.fromDate(start),
      endTime: admin.firestore.Timestamp.fromDate(end),
      meetingPoint: meetingPoint.label,
      startingPointLat: meetingPoint.lat,
      startingPointLng: meetingPoint.lng,
      locationDetails: meetingPoint.detail,
      distanceKm: [3, 5, 7, 10, 12, 15][runIndex % 6],
      pace,
      capacityLimit: pattern.capacity,
      description: `${cityMeta.label} ${pace} run with a seeded roster for end-to-end testing.`,
      priceInPaise: pattern.price,
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      status: pattern.kind === "cancelled" ? "cancelled" : "active",
      cancelledAt: pattern.kind === "cancelled" ?
        admin.firestore.Timestamp.fromDate(offsetDate(now, {days: -1})) :
        null,
      cancellationReason: pattern.kind === "cancelled" ? "Demo cancellation state." : null,
      constraints: {
        minAge: 21,
        maxAge: 45,
        maxMen: runIndex % 3 === 0 ? 8 : null,
        maxWomen: runIndex % 4 === 0 ? 8 : null,
      },
      genderCounts: {},
    },
  };
}

function meetingPointForRun({city, clubIndex, runIndex}) {
  const points = meetingPointData[city] ?? [];
  if (points.length === 0) {
    const cityMeta = cityData[city];
    return {
      label: `${cityMeta.label} demo meeting point`,
      lat: cityMeta.lat,
      lng: cityMeta.lng,
      detail: "Meet near the Catch demo pacer.",
    };
  }
  return points[(clubIndex + runIndex) % points.length];
}

function assertRunCoordinateQuality({runs}) {
  const issues = [];
  for (const run of runs) {
    if (run.doc.status === "cancelled") continue;
    const lat = run.doc.startingPointLat;
    const lng = run.doc.startingPointLng;
    if (typeof lat !== "number" || typeof lng !== "number") {
      issues.push(`${run.id}: missing exact starting coordinates`);
      continue;
    }

    const knownPoint = (meetingPointData[run.city] ?? []).find(
      (point) => point.label === run.doc.meetingPoint
    );
    if (!knownPoint) {
      issues.push(`${run.id}: meeting point is not in the curated venue catalog`);
      continue;
    }
    if (Math.abs(knownPoint.lat - lat) > 0.000001 ||
        Math.abs(knownPoint.lng - lng) > 0.000001) {
      issues.push(`${run.id}: coordinates do not match curated venue catalog`);
    }
  }

  if (issues.length > 0) {
    throw new Error(
      "Demo run coordinates are not map/check-in ready:\n" +
        issues.map((issue) => `- ${issue}`).join("\n")
    );
  }
}

function buildRoster({run, runIndex, clubMembers, anchorProfiles}) {
  if (run.kind === "cancelled") return [];
  const members = uniqueByUid([...anchorProfiles, ...rotate(clubMembers, runIndex)]);
  const signedCount = run.kind === "upcomingFull" || run.kind === "upcomingWaitlist" ?
    run.doc.capacityLimit :
    Math.min(run.doc.capacityLimit - 1, 6 + (runIndex % 4));
  const attendedCount = run.kind === "pastOpen" || run.kind === "pastOld" ?
    Math.min(run.doc.capacityLimit, Math.max(6, members.length)) :
    0;
  const roster = [];

  if (attendedCount > 0) {
    for (const person of members.slice(0, attendedCount)) {
      roster.push({person, status: "attended"});
    }
    return roster;
  }

  for (const person of members.slice(0, signedCount)) {
    roster.push({
      person,
      status: "signedUp",
      paymentState: run.priceInPaise > 0 ? "completed" : null,
    });
  }
  if (run.kind === "upcomingWaitlist") {
    for (const person of members.slice(signedCount, signedCount + 3)) {
      roster.push({person, status: "waitlisted"});
    }
  }
  if (run.kind === "upcomingFree" && members[signedCount]) {
    roster.push({person: members[signedCount], status: "cancelled"});
  }
  return roster;
}

function applyRosterAggregates(run, roster) {
  const booked = roster.filter((entry) => entry.status === "signedUp" || entry.status === "attended");
  const attended = roster.filter((entry) => entry.status === "attended");
  const waitlisted = roster.filter((entry) => entry.status === "waitlisted");
  run.doc.bookedCount = booked.length;
  run.doc.checkedInCount = attended.length;
  run.doc.waitlistedCount = waitlisted.length;
  run.doc.genderCounts = {};
  for (const entry of booked) {
    const gender = entry.person.gender || "other";
    run.doc.genderCounts[gender] = (run.doc.genderCounts[gender] ?? 0) + 1;
  }
}

function buildParticipation({seedMarker, run, entry, now}) {
  const createdAt = offsetDate(now, {days: -8, minutes: stableNumber(`${run.id}_${entry.person.uid}`, 180)});
  const statusTime = entry.status === "attended" ?
    admin.firestore.Timestamp.fromDate(offsetDate(run.doc.endTime.toDate(), {minutes: 5})) :
    null;
  return {
    id: `${run.id}_${entry.person.uid}`,
    doc: {
      ...seedMarker,
      runId: run.id,
      runClubId: run.clubId,
      uid: entry.person.uid,
      status: entry.status,
      createdAt: admin.firestore.Timestamp.fromDate(createdAt),
      updatedAt: admin.firestore.Timestamp.fromDate(offsetDate(now, {hours: -2})),
      signedUpAt: ["signedUp", "attended"].includes(entry.status) ?
        admin.firestore.Timestamp.fromDate(createdAt) :
        null,
      waitlistedAt: entry.status === "waitlisted" ?
        admin.firestore.Timestamp.fromDate(createdAt) :
        null,
      attendedAt: statusTime,
      cancelledAt: entry.status === "cancelled" ?
        admin.firestore.Timestamp.fromDate(offsetDate(now, {days: -1})) :
        null,
      deletedAt: null,
      genderAtSignup: entry.person.gender || "other",
      paymentId: entry.paymentState ? paymentIdFor(run.id, entry.person.uid, entry.paymentState) : null,
    },
  };
}

function buildSavedRun({seedMarker, uid, runId, now}) {
  return {
    id: `${uid}_${runId}`,
    doc: {
      ...seedMarker,
      uid,
      runId,
      savedAt: admin.firestore.Timestamp.fromDate(offsetDate(now, {hours: -6})),
      removedAt: null,
    },
  };
}

function buildSwipeMatchDocs({seedPrefix, seedMarker, run, roster, anchorProfiles, now}) {
  const attendedPeople = roster.filter((entry) => entry.status === "attended").map((entry) => entry.person);
  const anchors = anchorProfiles.filter((anchor) => attendedPeople.some((person) => person.uid === anchor.uid));
  const syntheticTargets = attendedPeople.filter((person) => person.source === "synthetic");
  const swipes = [];
  const matches = [];
  const messages = [];
  const notifications = [];

  for (const [anchorIndex, anchor] of anchors.entries()) {
    const targets = rotate(syntheticTargets, anchorIndex).slice(0, 4);
    for (const [targetIndex, target] of targets.entries()) {
      const direction = targetIndex === 3 ? "pass" : "like";
      swipes.push(swipeDoc({seedMarker, swiper: anchor, target, run, direction, now, offsetMinutes: targetIndex}));
      if (direction === "like" && targetIndex < 2) {
        swipes.push(swipeDoc({seedMarker, swiper: target, target: anchor, run, direction: "like", now, offsetMinutes: targetIndex + 5}));
        const match = matchDoc({seedMarker, userA: anchor, userB: target, run, now});
        matches.push(match);
        const builtMessages = buildMessages({seedPrefix, seedMarker, match, anchor, target, now});
        messages.push(...builtMessages);
        notifications.push(notificationDoc({
          seedMarker,
          uid: anchor.uid,
          id: `match_${match.id}`,
          type: "match",
          title: "New catch",
          body: `${target.displayName || target.firstName} liked you back.`,
          createdAt: offsetDate(now, {hours: -4, minutes: targetIndex}),
          matchId: match.id,
          runId: run.id,
          actorUid: target.uid,
          actorName: target.displayName || target.firstName,
        }));
      }
    }
  }
  return {swipes, matches, messages, notifications};
}

function swipeDoc({seedMarker, swiper, target, run, direction, now, offsetMinutes}) {
  return {
    swiperId: swiper.uid,
    targetId: target.uid,
    doc: {
      ...seedMarker,
      swiperId: swiper.uid,
      targetId: target.uid,
      runId: run.id,
      direction,
      createdAt: admin.firestore.Timestamp.fromDate(offsetDate(now, {hours: -3, minutes: offsetMinutes})),
    },
  };
}

function matchDoc({seedMarker, userA, userB, run, now}) {
  const [user1Id, user2Id] = [userA.uid, userB.uid].sort();
  const id = `${user1Id}_${user2Id}`;
  return {
    id,
    user1Id,
    user2Id,
    doc: {
      ...seedMarker,
      user1Id,
      user2Id,
      runIds: [run.id],
      createdAt: admin.firestore.Timestamp.fromDate(offsetDate(now, {hours: -3})),
      lastMessageAt: null,
      lastMessagePreview: null,
      lastMessageSenderId: null,
      unreadCounts: {[user1Id]: 0, [user2Id]: 1},
      status: "active",
      blockedBy: null,
      blockedAt: null,
      participantIds: [user1Id, user2Id],
    },
  };
}

function buildMessages({seedPrefix, seedMarker, match, anchor, target, now}) {
  const snippets = [
    {sender: target, text: `That ${cityData[target.city]?.label ?? "city"} route was fun. Same pace next time?`},
    {sender: anchor, text: "Definitely. I liked the last 2 km push."},
    {sender: target, text: "Coffee after the weekend run?"},
  ].slice(0, MATCH_MESSAGE_LIMIT);
  return snippets.map((snippet, index) => {
    const id = `${seedPrefix}_msg_${match.id}_${String(index + 1).padStart(2, "0")}`;
    const sentAt = offsetDate(now, {hours: -2, minutes: index * 7});
    match.doc.lastMessageAt = admin.firestore.Timestamp.fromDate(sentAt);
    match.doc.lastMessagePreview = snippet.text;
    match.doc.lastMessageSenderId = snippet.sender.uid;
    return {
      matchId: match.id,
      id,
      doc: {
        ...seedMarker,
        senderId: snippet.sender.uid,
        text: snippet.text,
        imageUrl: null,
        sentAt: admin.firestore.Timestamp.fromDate(sentAt),
      },
    };
  });
}

function buildReviews({seedPrefix, seedMarker, club, run, roster, now}) {
  return roster
    .filter((entry) => entry.status === "attended")
    .slice(0, 4)
    .map((entry, index) => {
      const id = `${run.id}~${entry.person.uid}`;
      return {
        id,
        clubId: club.id,
        rating: 4 + (index % 2),
        doc: {
          ...seedMarker,
          runClubId: club.id,
          runId: run.id,
          reviewerUserId: entry.person.uid,
          reviewerName: entry.person.name || entry.person.displayName || "Runner",
          rating: 4 + (index % 2),
          comment: "Well organized demo run with clear pacing and a friendly group.",
          createdAt: admin.firestore.Timestamp.fromDate(offsetDate(now, {days: -2, minutes: index})),
          updatedAt: null,
        },
      };
    });
}

function buildPayment({seedPrefix, seedMarker, run, uid, state, now}) {
  const id = paymentIdFor(run.id, uid, state);
  return {
    id,
    doc: {
      ...seedMarker,
      userId: uid,
      orderId: `${seedPrefix}_order_${run.id}_${uid}`,
      paymentId: id,
      runId: run.id,
      amount: run.priceInPaise || 29900,
      currency: "INR",
      status: state,
      signUpFailed: state === "failed",
      createdAt: admin.firestore.Timestamp.fromDate(offsetDate(now, {days: -1})),
    },
  };
}

function buildPaymentHistoryEdges({seedPrefix, seedMarker, anchorProfiles, runs, now}) {
  const paidRuns = runs.filter((run) => run.priceInPaise > 0);
  const result = [];
  for (const [index, anchor] of anchorProfiles.entries()) {
    const run = paidRuns[index % paidRuns.length];
    if (!run) continue;
    result.push(buildPayment({seedPrefix, seedMarker, run, uid: anchor.uid, state: "refunded", now}));
    result.push(buildPayment({seedPrefix, seedMarker, run, uid: anchor.uid, state: "failed", now}));
  }
  return result;
}

function buildGeneralNotifications({seedMarker, anchorProfiles, clubs, runs, now}) {
  const result = [];
  const upcoming = runs.find((run) => run.kind === "upcomingFree") ?? runs[0];
  const paid = runs.find((run) => run.kind === "upcomingPaid") ?? upcoming;
  const club = clubs[0];
  for (const anchor of anchorProfiles) {
    if (upcoming) {
      result.push(notificationDoc({
        seedMarker,
        uid: anchor.uid,
        id: `runReminder_${upcoming.id}`,
        type: "runReminder",
        title: "Run coming up",
        body: "Your demo run starts tomorrow morning.",
        createdAt: offsetDate(now, {hours: -1}),
        runId: upcoming.id,
        runClubId: upcoming.clubId,
      }));
    }
    if (paid) {
      result.push(notificationDoc({
        seedMarker,
        uid: anchor.uid,
        id: `runSignup_${paid.id}`,
        type: "runSignup",
        title: "Spot confirmed",
        body: "Your paid demo run booking is confirmed.",
        createdAt: offsetDate(now, {hours: -5}),
        runId: paid.id,
        runClubId: paid.clubId,
        readAt: offsetDate(now, {hours: -4}),
      }));
    }
    if (club) {
      result.push(notificationDoc({
        seedMarker,
        uid: anchor.uid,
        id: `clubUpdate_${club.id}`,
        type: "clubUpdate",
        title: `${club.doc.name} update`,
        body: "New demo runs were added for this week.",
        createdAt: offsetDate(now, {days: -1}),
        runClubId: club.id,
      }));
    }
  }
  return result;
}

function notificationDoc({
  seedMarker,
  uid,
  id,
  type,
  title,
  body,
  createdAt,
  readAt = null,
  matchId = null,
  runId = null,
  runClubId = null,
  actorUid = null,
  actorName = null,
}) {
  return {
    uid,
    id,
    doc: {
      ...seedMarker,
      uid,
      type,
      title,
      body,
      createdAt: admin.firestore.Timestamp.fromDate(createdAt),
      readAt: readAt ? admin.firestore.Timestamp.fromDate(readAt) : null,
      matchId,
      runId,
      runClubId,
      actorUid,
      actorName,
    },
  };
}

function updateClubAggregates({clubs, memberships, reviews, runs}) {
  const membersByClub = groupBy(memberships, (membership) => membership.doc.clubId);
  const reviewsByClub = groupBy(reviews, (review) => review.clubId);
  const upcomingByClub = groupBy(
    runs
      .filter((run) => run.doc.status === "active" && run.doc.startTime.toDate() > new Date())
      .sort((a, b) => a.doc.startTime.toMillis() - b.doc.startTime.toMillis()),
    (run) => run.clubId
  );
  for (const club of clubs) {
    const activeMembers = (membersByClub.get(club.id) ?? [])
      .filter((membership) => membership.doc.status === "active");
    const clubReviews = reviewsByClub.get(club.id) ?? [];
    const totalRating = clubReviews.reduce((sum, review) => sum + review.rating, 0);
    const nextRun = upcomingByClub.get(club.id)?.[0];
    club.doc.memberCount = activeMembers.length;
    club.doc.reviewCount = clubReviews.length;
    club.doc.rating = clubReviews.length > 0 ?
      Number((totalRating / clubReviews.length).toFixed(1)) :
      0;
    club.doc.nextRunAt = nextRun?.doc.startTime ?? null;
    club.doc.nextRunLabel = nextRun ? nextRun.doc.meetingPoint : null;
  }
}

function createWritePlan(seed) {
  return {
    docs: seed.docs,
    paths: seed.docs.map((doc) => doc.path),
  };
}

async function readExistingSeedTime(firestore, seedId) {
  const manifestId = seedId.replace(/[^A-Za-z0-9_-]/g, "_");
  const snap = await firestore.collection("seedRuns").doc(manifestId).get();
  if (!snap.exists) {
    throw new Error(
      `--append-anchors requires an existing seedRuns/${manifestId} manifest. ` +
      "Run a full seed first."
    );
  }
  const generatedAt = snap.data().generatedAt;
  if (!generatedAt || typeof generatedAt.toDate !== "function") {
    throw new Error(`seedRuns/${manifestId} is missing generatedAt.`);
  }
  return generatedAt.toDate();
}

async function createAppendWritePlan({db: firestore, seed, anchorProfiles}) {
  const manifestRef = firestore.collection("seedRuns").doc(seed.manifestId);
  const manifestSnap = await manifestRef.get();
  if (!manifestSnap.exists) {
    throw new Error(
      `--append-anchors requires an existing ${manifestRef.path} manifest. ` +
      "Run a full seed first."
    );
  }

  const existingManifest = manifestSnap.data();
  const existingAnchorIds = new Set(existingManifest.anchorUserIds ?? []);
  const currentAnchorIds = anchorProfiles.map((profile) => profile.uid);
  const mergedAnchorIds = new Set([...existingAnchorIds, ...currentAnchorIds]);
  const newAnchorIds = currentAnchorIds.filter((uid) => !existingAnchorIds.has(uid));
  const existingPaths = new Set(existingManifest.paths ?? []);

  if (newAnchorIds.length === 0) {
    return {
      docs: [],
      paths: [],
      manifest: {
        ...seed.manifest,
        anchorUserIds: [...mergedAnchorIds].sort(),
        paths: [...existingPaths].sort(),
        counts: countDocs([...existingPaths].map((docPath) => ({path: docPath}))),
      },
      append: {
        existingAnchorIds: [...existingAnchorIds].sort(),
        newAnchorIds,
        existingPathCount: existingPaths.size,
        finalPathCount: existingPaths.size,
      },
    };
  }

  const newAnchorSet = new Set(newAnchorIds);
  const newAnchorMatchIds = new Set(
    seed.docs
      .filter((doc) => doc.path.startsWith("matches/") &&
        !doc.path.includes("/messages/") &&
        (newAnchorSet.has(doc.data.user1Id) || newAnchorSet.has(doc.data.user2Id)))
      .map((doc) => doc.path.split("/")[1])
  );
  let docs = seed.docs.filter((doc) =>
    isNewAnchorRelationshipDoc(doc, newAnchorSet, newAnchorMatchIds)
  );
  const existingTargetFilter = await filterAppendDocsForExistingTargets(
    firestore,
    docs
  );
  docs = existingTargetFilter.docs;
  docs = await normalizeAppendParticipationsForCapacity(firestore, docs);
  const aggregateUpdates = buildAppendAggregateUpdates(docs);
  const mergedPaths = new Set([...existingPaths, ...docs.map((doc) => doc.path)]);

  return {
    docs: [...docs, ...aggregateUpdates],
    paths: docs.map((doc) => doc.path),
    manifest: {
      ...seed.manifest,
      anchorUserIds: [...mergedAnchorIds].sort(),
      paths: [...mergedPaths].sort(),
      counts: countDocs([...mergedPaths].map((docPath) => ({path: docPath}))),
      appendMode: true,
      appendedAnchorUserIds: newAnchorIds,
    },
    append: {
      existingAnchorIds: [...existingAnchorIds].sort(),
      newAnchorIds,
      existingPathCount: existingPaths.size,
      finalPathCount: mergedPaths.size,
      skippedMissingTargetCount: existingTargetFilter.skippedPaths.length,
      skippedMissingTargetPaths: existingTargetFilter.skippedPaths,
    },
  };
}

function isNewAnchorRelationshipDoc(doc, newAnchorSet, newAnchorMatchIds) {
  const parts = doc.path.split("/");
  if (doc.path.startsWith("runClubMemberships/")) {
    return newAnchorSet.has(doc.data.uid);
  }
  if (doc.path.startsWith("runParticipations/")) {
    return newAnchorSet.has(doc.data.uid);
  }
  if (doc.path.startsWith("userRunScheduleLocks/")) {
    return newAnchorSet.has(doc.data.uid);
  }
  if (doc.path.startsWith("savedRuns/")) {
    return newAnchorSet.has(doc.data.uid);
  }
  if (doc.path.startsWith("payments/")) {
    return newAnchorSet.has(doc.data.userId);
  }
  if (doc.path.startsWith("swipes/")) {
    return newAnchorSet.has(doc.data.swiperId) ||
      newAnchorSet.has(doc.data.targetId);
  }
  if (parts[0] === "matches" && parts.length === 2) {
    return newAnchorSet.has(doc.data.user1Id) ||
      newAnchorSet.has(doc.data.user2Id);
  }
  if (parts[0] === "matches" && parts[2] === "messages") {
    return newAnchorMatchIds.has(parts[1]);
  }
  if (parts[0] === "notifications" && parts[2] === "items") {
    return newAnchorSet.has(parts[1]);
  }
  return false;
}

async function filterAppendDocsForExistingTargets(firestore, docs) {
  const runIds = new Set();
  const clubIds = new Set();

  for (const doc of docs) {
    collectString(doc.data.runId, runIds);
    collectString(doc.data.runClubId, clubIds);
    collectString(doc.data.clubId, clubIds);
    if (Array.isArray(doc.data.runIds)) {
      for (const runId of doc.data.runIds) collectString(runId, runIds);
    }
  }

  const [existingRunIds, existingClubIds] = await Promise.all([
    existingDocumentIds(firestore, "runs", runIds),
    existingDocumentIds(firestore, "runClubs", clubIds),
  ]);

  const skippedPaths = [];
  let kept = docs.filter((doc) => {
    const hasExistingTargets = docTargetsExist(doc, {
      existingRunIds,
      existingClubIds,
    });
    if (!hasExistingTargets) skippedPaths.push(doc.path);
    return hasExistingTargets;
  });

  const keptMatchIds = new Set(
    kept
      .filter((doc) => {
        const parts = doc.path.split("/");
        return parts[0] === "matches" && parts.length === 2;
      })
      .map((doc) => doc.path.split("/")[1])
  );

  kept = kept.filter((doc) => {
    const parts = doc.path.split("/");
    const isMessage = parts[0] === "matches" && parts[2] === "messages";
    if (!isMessage || keptMatchIds.has(parts[1])) return true;
    skippedPaths.push(doc.path);
    return false;
  });

  return {docs: kept, skippedPaths};
}

async function existingDocumentIds(firestore, collection, ids) {
  const existing = new Set();
  await Promise.all([...ids].map(async (id) => {
    const snap = await firestore.collection(collection).doc(id).get();
    if (snap.exists) existing.add(id);
  }));
  return existing;
}

function docTargetsExist(doc, {existingRunIds, existingClubIds}) {
  if (!stringTargetExists(doc.data.runId, existingRunIds)) return false;
  if (!stringTargetExists(doc.data.runClubId, existingClubIds)) return false;
  if (!stringTargetExists(doc.data.clubId, existingClubIds)) return false;
  if (Array.isArray(doc.data.runIds)) {
    return doc.data.runIds.every((runId) =>
      stringTargetExists(runId, existingRunIds)
    );
  }
  return true;
}

function collectString(value, target) {
  if (typeof value === "string" && value.length > 0) target.add(value);
}

function stringTargetExists(value, existingIds) {
  return typeof value !== "string" ||
    value.length === 0 ||
    existingIds.has(value);
}

async function normalizeAppendParticipationsForCapacity(firestore, docs) {
  const removedPaymentIds = new Set();
  const participationsByRun = groupBy(
    docs.filter((doc) =>
      doc.path.startsWith("runParticipations/") &&
      (doc.data.status === "signedUp" || doc.data.status === "attended")
    ),
    (doc) => doc.data.runId
  );

  for (const [runId, participationDocs] of participationsByRun.entries()) {
    const runSnap = await firestore.collection("runs").doc(runId).get();
    const run = runSnap.data();
    if (!run || !Number.isInteger(run.capacityLimit)) continue;

    let bookedCount = Number.isInteger(run.bookedCount) ? run.bookedCount : 0;
    for (const doc of participationDocs) {
      if (bookedCount < run.capacityLimit) {
        bookedCount += 1;
        continue;
      }

      if (doc.data.paymentId) removedPaymentIds.add(doc.data.paymentId);
      doc.data.status = "waitlisted";
      doc.data.signedUpAt = null;
      doc.data.attendedAt = null;
      doc.data.paymentId = null;
      doc.data.waitlistedAt = doc.data.createdAt;
    }
  }

  if (removedPaymentIds.size === 0) return docs;
  return docs.filter((doc) =>
    !doc.path.startsWith("payments/") ||
    !removedPaymentIds.has(doc.path.split("/")[1])
  );
}

function buildAppendAggregateUpdates(docs) {
  const runUpdates = new Map();
  const clubUpdates = new Map();

  for (const doc of docs) {
    if (doc.path.startsWith("runClubMemberships/") &&
        doc.data.status === "active") {
      const clubUpdate = mapEntry(clubUpdates, `runClubs/${doc.data.clubId}`);
      clubUpdate.memberCount = (clubUpdate.memberCount ?? 0) + 1;
    }

    if (!doc.path.startsWith("runParticipations/")) continue;
    const runUpdate = mapEntry(runUpdates, `runs/${doc.data.runId}`);
    if (doc.data.status === "signedUp" || doc.data.status === "attended") {
      runUpdate.bookedCount = (runUpdate.bookedCount ?? 0) + 1;
      const gender = doc.data.genderAtSignup ?? "other";
      const genderKey = `genderCounts.${gender}`;
      runUpdate[genderKey] = (runUpdate[genderKey] ?? 0) + 1;
    }
    if (doc.data.status === "attended") {
      runUpdate.checkedInCount = (runUpdate.checkedInCount ?? 0) + 1;
    }
    if (doc.data.status === "waitlisted") {
      runUpdate.waitlistedCount = (runUpdate.waitlistedCount ?? 0) + 1;
    }
  }

  return [
    ...[...clubUpdates.entries()].map(([docPath, increments]) => ({
      path: docPath,
      op: "update",
      data: incrementPatch(increments),
    })),
    ...[...runUpdates.entries()].map(([docPath, increments]) => ({
      path: docPath,
      op: "update",
      data: incrementPatch(increments),
    })),
  ];
}

function mapEntry(map, key) {
  if (!map.has(key)) map.set(key, {});
  return map.get(key);
}

function incrementPatch(increments) {
  return Object.fromEntries(
    Object.entries(increments).map(([key, value]) => [
      key,
      admin.firestore.FieldValue.increment(value),
    ])
  );
}

async function resetSyntheticData({db: firestore, manifestId, seedPrefix, fallbackPaths}) {
  const manifestRef = firestore.collection("seedRuns").doc(manifestId);
  const manifestSnap = await manifestRef.get();
  const manifestPaths = manifestSnap.exists && Array.isArray(manifestSnap.data().paths) ?
    manifestSnap.data().paths :
    fallbackPaths;
  const orphanMessagePaths = await syntheticMatchMessagePaths({
    db: firestore,
    seedPrefix,
  });
  const paths = [...new Set([
    ...manifestPaths,
    ...orphanMessagePaths,
    manifestRef.path,
  ])];
  let deleted = 0;
  for (const chunk of chunks(paths, DEFAULT_MAX_BATCH_WRITES)) {
    const batch = firestore.batch();
    for (const docPath of chunk) {
      batch.delete(firestore.doc(docPath));
      deleted += 1;
    }
    await batch.commit();
  }
  return {
    deleted,
    source: manifestSnap.exists ? `seedRuns/${manifestId}` : "current generated plan",
  };
}

async function syntheticMatchMessagePaths({db: firestore, seedPrefix}) {
  const snap = await firestore.collectionGroup("messages").get();
  return snap.docs
    .filter((doc) => doc.ref.parent.parent?.id.includes(seedPrefix))
    .map((doc) => doc.ref.path);
}

async function applyWritePlan({db: firestore, docs}) {
  let written = 0;
  for (const chunk of chunks(docs, DEFAULT_MAX_BATCH_WRITES)) {
    const batch = firestore.batch();
    for (const doc of chunk) {
      if (doc.op === "update") {
        batch.update(firestore.doc(doc.path), doc.data);
      } else {
        batch.set(firestore.doc(doc.path), doc.data);
      }
      written += 1;
    }
    await batch.commit();
  }
  return {written};
}

function printSummary({args, projectId, scenario, anchorProfiles, seed, writePlan, missingPublicProfileIds}) {
  const identityDiagnostics = syntheticPublicIdentityDiagnostics(seed.docs);
  console.log("Catch demo data seed plan");
  console.log(`Project: ${projectId}`);
  if (args.emulatorHost) console.log(`Emulator: ${args.emulatorHost}`);
  console.log(`Scenario: ${args.scenario} - ${scenario.description}`);
  console.log(`Seed prefix: ${args.seedPrefix}`);
  console.log(`Mode: ${args.apply ? "apply" : "dry-run"}`);
  if (args.deleteOnly) console.log("Delete only: yes");
  if (args.appendAnchors) {
    console.log("Append anchors: yes");
    console.log(`New anchor users: ${writePlan.append?.newAnchorIds.length ?? 0}`);
  }
  console.log(`Reset synthetic first: ${args.resetSynthetic ? "yes" : "no"}`);
  console.log(`Anchor users: ${anchorProfiles.length}`);
  if (missingPublicProfileIds.length > 0) {
    console.log(`Warning: missing publicProfiles for anchors: ${missingPublicProfileIds.join(", ")}`);
  }
  console.log("\nDocument counts:");
  for (const [collection, count] of Object.entries(seed.counts)) {
    console.log(`- ${collection}: ${count}`);
  }
  console.log(`\nTotal docs to write: ${writePlan.docs.length}`);
  if (identityDiagnostics.duplicateNamePhotoPairs > 0) {
    console.log(
      `Warning: ${identityDiagnostics.duplicateNamePhotoPairs} duplicate synthetic public name/photo pairs generated.`
    );
  }
  console.log(`Manifest: seedRuns/${seed.manifestId}`);
}

function summary({args, projectId, scenario, anchorProfiles, seed, writePlan, missingPublicProfileIds}) {
  return {
    projectId,
    emulatorHost: args.emulatorHost,
    scenario: args.scenario,
    scenarioDescription: scenario.description,
    seedPrefix: args.seedPrefix,
    apply: args.apply,
    resetSynthetic: args.resetSynthetic,
    deleteOnly: args.deleteOnly,
    appendAnchors: args.appendAnchors,
    includeScheduleLocks: args.includeScheduleLocks,
    append: writePlan.append ?? null,
    anchorUserIds: anchorProfiles.map((profile) => profile.uid),
    missingPublicProfileIds,
    syntheticPublicIdentityDiagnostics: syntheticPublicIdentityDiagnostics(seed.docs),
    counts: seed.counts,
    totalDocsToWrite: writePlan.docs.length,
    manifestPath: `seedRuns/${seed.manifestId}`,
  };
}

function printScenarios() {
  console.log("Available demo seed scenarios:");
  for (const [name, scenario] of Object.entries(scenarios)) {
    console.log(`- ${name}: ${scenario.description}`);
  }
}

function printHelp() {
  console.log(`
Seed deterministic Catch demo data with the Firebase Admin SDK.

Usage:
  node tool/seed_demo_data.mjs --env dev --scenario smoke
  node tool/seed_demo_data.mjs --env dev --scenario beta-full --anchor-users uid1,uid2 --apply --reset-synthetic
  node tool/seed_demo_data.mjs --env prod --scenario beta-full --anchor-file anchors.txt --apply --allow-prod --reset-synthetic

Options:
  --env <dev|staging|prod>       Resolve project id from .firebaserc.
  --project <firebase-project>   Explicit Firebase/GCP project id.
  --scenario <name>              Scenario to generate. Default: beta-full.
  --list-scenarios               Print scenario names and exit.
  --seed-prefix <prefix>         Stable document prefix. Default: ${DEFAULT_SEED_PREFIX}.
  --anchor-users <uid,...>       Real TestFlight user UIDs to seed around.
  --anchor-phones <phone,...>    Resolve real users by users.phoneNumber.
  --anchor-file <path>           Newline file, or JSON with uids/users and phones.
  --dry-run                      Print plan only. Default.
  --apply                        Write documents.
  --reset-synthetic              Delete previous manifest docs before writing.
  --delete-only                  Delete previous manifest docs and exit. Requires
                                 --apply --reset-synthetic.
  --append-anchors               Add only newly listed anchors to an existing
                                 seed manifest without recreating old anchors.
  --include-schedule-locks       Also write denormalized schedule lock docs.
                                 Usually unnecessary for demo worlds because
                                 Functions query canonical run/participation docs.
  --allow-prod                   Required when writing to the prod Firebase project.
  --emulator                     Use FIRESTORE_EMULATOR_HOST=127.0.0.1:8080.
  --emulator-host <host:port>    Use a custom Firestore emulator host.
  --json                         Emit machine-readable summary.
`);
}

function uniqueDocsByPath(docs) {
  const byPath = new Map();
  for (const doc of docs) byPath.set(doc.path, doc);
  return [...byPath.values()].sort((a, b) => a.path.localeCompare(b.path));
}

function countDocs(docs) {
  const counts = {};
  for (const doc of docs) {
    const key = countKeyForPath(doc.path);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(counts).sort());
}

function countKeyForPath(docPath) {
  if (/^matches\/[^/]+\/messages\//.test(docPath)) return "messages";
  if (/^swipes\/[^/]+\/outgoing\//.test(docPath)) return "swipes";
  if (/^notifications\/[^/]+\/items\//.test(docPath)) return "notifications";
  return docPath.split("/")[0];
}

function syntheticPublicIdentityDiagnostics(docs) {
  const seen = new Map();
  const duplicates = [];

  for (const doc of docs) {
    if (!doc.path.startsWith("publicProfiles/")) continue;
    if (doc.data.synthetic !== true) continue;
    const name = normalizedPublicName(doc.data.name);
    const firstPhoto = Array.isArray(doc.data.photoUrls) ? doc.data.photoUrls[0] : null;
    if (!name || typeof firstPhoto !== "string" || firstPhoto.length === 0) continue;
    const key = `${name}|${firstPhoto}`;
    const firstPath = seen.get(key);
    if (firstPath) {
      duplicates.push({firstPath, duplicatePath: doc.path, name: doc.data.name});
    } else {
      seen.set(key, doc.path);
    }
  }

  return {
    duplicateNamePhotoPairs: duplicates.length,
    duplicateSamples: duplicates.slice(0, 10),
  };
}

function normalizedPublicName(value) {
  return typeof value === "string" ? value.trim().toLowerCase() : "";
}

function groupBy(items, keyFn) {
  const result = new Map();
  for (const item of items) {
    const key = keyFn(item);
    if (!result.has(key)) result.set(key, []);
    result.get(key).push(item);
  }
  return result;
}

function uniqueByUid(items) {
  const byUid = new Map();
  for (const item of items) {
    if (item?.uid) byUid.set(item.uid, item);
  }
  return [...byUid.values()];
}

function rotate(items, offset) {
  if (items.length === 0) return [];
  const start = offset % items.length;
  return [...items.slice(start), ...items.slice(0, start)];
}

function chunks(items, size) {
  const result = [];
  for (let index = 0; index < items.length; index += size) {
    result.push(items.slice(index, index + size));
  }
  return result;
}

function dateOfBirthForAge(age, index) {
  const date = new Date(Date.UTC(new Date().getUTCFullYear() - age, index % 12, 10 + (index % 18), 0, 0, 0));
  return admin.firestore.Timestamp.fromDate(date);
}

function ageFromTimestamp(timestamp) {
  if (!timestamp || typeof timestamp.toDate !== "function") return null;
  const dob = timestamp.toDate();
  const now = new Date();
  let age = now.getFullYear() - dob.getFullYear();
  const monthDiff = now.getMonth() - dob.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && now.getDate() < dob.getDate())) {
    age -= 1;
  }
  return age;
}

function firstWord(value) {
  return String(value || "Runner").trim().split(/\s+/)[0] || "Runner";
}

function validGender(value) {
  return ["man", "woman", "nonBinary", "other"].includes(value);
}

function validCity(value) {
  return Object.prototype.hasOwnProperty.call(cityData, value);
}

function interestedInFor(gender, index) {
  if (gender === "man") return ["woman", "nonBinary"];
  if (gender === "woman") return ["man", "nonBinary"];
  if (index % 2 === 0) return ["man", "woman", "nonBinary"];
  return ["man", "woman", "nonBinary", "other"];
}

function languageSet(city, index) {
  const cityLanguage = {
    mumbai: "marathi",
    delhi: "hindi",
    bangalore: "kannada",
    hyderabad: "telugu",
    chennai: "tamil",
    kolkata: "bengali",
    pune: "marathi",
    ahmedabad: "gujarati",
    indore: "hindi",
  }[city] ?? "hindi";
  return index % 3 === 0 ? ["english", cityLanguage] : ["english", "hindi"];
}

function daysFromNow(days) {
  return offsetDate(new Date(), {days});
}

function offsetDate(date, {days = 0, hours = 0, minutes = 0}) {
  return new Date(date.getTime() + (((days * 24 + hours) * 60 + minutes) * 60 * 1000));
}

function stableNumber(value, mod) {
  let hash = 0;
  for (let index = 0; index < value.length; index += 1) {
    hash = ((hash << 5) - hash + value.charCodeAt(index)) | 0;
  }
  return Math.abs(hash) % mod;
}

function paymentIdFor(runId, uid, state) {
  return `${runId}_${uid}_${state}`;
}
