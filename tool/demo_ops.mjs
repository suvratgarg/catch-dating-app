#!/usr/bin/env node
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {
  DEFAULT_DEMO_OPS_PREFIX,
  DEFAULT_SEED_PREFIX,
  applyDeletePlan,
  applyDocPlan,
  buildDemoChecklist,
  buildHostAccountPlan,
  buildLaunchCleanupPlan,
  buildMakeRunFullPlan,
  buildMatchPhonePlan,
  buildMarkAttendedPlan,
  buildPromoteWaitlistPlan,
  buildRefundPlan,
  buildResetUserDemoStatePlan,
  buildUnreadMessagePlan,
  buildValidateDemoStateReport,
  buildWarmGroupPlans,
  buildWarmUserPlan,
  isProductionTarget,
  listScenarioConfigs,
  loadGoldenAccounts,
  loadScenarioConfig,
  loadFirebaseAdmin,
  resolveProjectId,
  splitCsv,
  writeManifest,
} from "./demo_ops_core.mjs";
import {
  applyRunAggregateRepairPlan,
  buildRunAggregateRepairPlan,
} from "./recompute_run_aggregate_counts.mjs";
import {
  applyMemberCountRepairPlan,
  buildMemberCountRepairPlan,
} from "./recompute_run_club_member_counts.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const admin = loadFirebaseAdmin();

if (isMain()) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const {command, args} = parseArgs(argv);
  if (!command || args.help) {
    printHelp();
    return;
  }
  if (command === "list-commands") {
    printCommands();
    return;
  }
  if (command === "scenario-info") {
    printScenarioInfo(args);
    return;
  }
  if (command === "list-golden-accounts") {
    printGoldenAccounts(args);
    return;
  }
  if (command === "seed-world" || command === "append-user") {
    runSeedCommand(command, args);
    return;
  }

  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }
  const projectId = resolveProjectId(args);
  guardProdWrite({args, projectId});
  admin.initializeApp({projectId});
  const db = admin.firestore();

  if (command === "match-phones") {
    await runMatchPhones({db, args, projectId});
  } else if (command === "warm-user") {
    await runWarmUser({db, args, projectId});
  } else if (command === "warm-group") {
    await runWarmGroup({db, args, projectId});
  } else if (command === "reset-user-demo-state") {
    await runResetUserDemoState({db, args, projectId});
  } else if (command === "validate-demo-state") {
    await runValidateDemoState({db, args, projectId});
  } else if (command === "demo-checklist") {
    await runDemoChecklist({db, args, projectId});
  } else if (command === "cleanup-demo-data") {
    await runCleanupDemoData({db, args, projectId});
  } else if (command === "make-run-full") {
    await runWritePlan({
      db,
      args,
      projectId,
      title: "Demo make run full plan",
      plan: await buildMakeRunFullPlan({
        db,
        admin,
        runId: requireArg(args, "runId", "--run-id"),
        seedPrefix: args.seedPrefix,
      }),
      repair: true,
    });
  } else if (command === "mark-attended") {
    await runWritePlan({
      db,
      args,
      projectId,
      title: "Demo mark attended plan",
      plan: await buildMarkAttendedPlan({
        db,
        admin,
        phone: requireArg(args, "phone", "--phone"),
        runId: requireArg(args, "runId", "--run-id"),
        seedPrefix: args.seedPrefix,
      }),
      repair: true,
    });
  } else if (command === "promote-waitlist") {
    await runWritePlan({
      db,
      args,
      projectId,
      title: "Demo promote waitlist plan",
      plan: await buildPromoteWaitlistPlan({
        db,
        admin,
        phone: requireArg(args, "phone", "--phone"),
        runId: requireArg(args, "runId", "--run-id"),
        seedPrefix: args.seedPrefix,
      }),
      repair: true,
    });
  } else if (command === "create-unread-message") {
    await runWritePlan({
      db,
      args,
      projectId,
      title: "Demo unread message plan",
      plan: await buildUnreadMessagePlan({
        db,
        admin,
        fromPhone: requireArg(args, "fromPhone", "--from-phone"),
        toPhone: requireArg(args, "toPhone", "--to-phone"),
        text: args.text,
        seedPrefix: args.seedPrefix,
      }),
    });
  } else if (command === "create-refund") {
    await runWritePlan({
      db,
      args,
      projectId,
      title: "Demo refund payment plan",
      plan: await buildRefundPlan({
        db,
        admin,
        phone: requireArg(args, "phone", "--phone"),
        runId: requireArg(args, "runId", "--run-id"),
        seedPrefix: args.seedPrefix,
      }),
    });
  } else if (command === "create-host-account") {
    await runWritePlan({
      db,
      args,
      projectId,
      title: "Demo host account plan",
      plan: await buildHostAccountPlan({
        db,
        admin,
        phone: requireArg(args, "phone", "--phone"),
        seedPrefix: args.seedPrefix,
      }),
      repair: true,
    });
  } else {
    throw new Error(`Unknown command: ${command}`);
  }
}

async function runMatchPhones({db, args, projectId}) {
  const plan = await buildMatchPhonePlan({
    db,
    admin,
    phoneA: requireArg(args, "phoneA", "--phone-a"),
    phoneB: requireArg(args, "phoneB", "--phone-b"),
    runId: args.runId,
    viaSwipes: args.viaSwipes,
    direct: !args.viaSwipesOnly,
    withMessages: args.withMessages,
    seedPrefix: args.seedPrefix,
  });
  if (args.apply) await applyDocPlan({db, docs: plan.docs});
  const manifest = await writeManifest({db, admin, plan, apply: args.apply});
  printPlan({
    args,
    projectId,
    title: "Demo match phone plan",
    plan,
    manifest,
    appliedSummary: args.apply ? {written: plan.docs.length} : null,
  });
}

async function runWarmUser({db, args, projectId}) {
  const plan = await buildWarmUserPlan({
    db,
    admin,
    phone: requireArg(args, "phone", "--phone"),
    seedPrefix: args.seedPrefix,
    syntheticMatchCount: args.syntheticMatches,
  });
  let aggregateSummary = null;
  if (args.apply) {
    await applyDocPlan({db, docs: plan.docs});
    aggregateSummary = await repairAggregates(db);
  }
  const manifest = await writeManifest({db, admin, plan, apply: args.apply});
  printPlan({
    args,
    projectId,
    title: "Demo warm user plan",
    plan,
    manifest,
    appliedSummary: args.apply ? {written: plan.docs.length, aggregateSummary} : null,
  });
}

async function runWarmGroup({db, args, projectId}) {
  const phones = phonesFromArgs(args);
  if (phones.length < 2) throw new Error("warm-group requires at least two phones.");
  const plans = await buildWarmGroupPlans({
    db,
    admin,
    phones,
    seedPrefix: args.seedPrefix,
  });
  const docs = [];
  const manifests = [];
  for (const plan of plans) {
    docs.push(...plan.docs);
  }
  if (args.apply) await applyDocPlan({db, docs});
  for (const plan of plans) {
    manifests.push(await writeManifest({db, admin, plan, apply: args.apply}));
  }
  printPlan({
    args,
    projectId,
    title: "Demo warm group plan",
    plan: {
      command: "warm-group",
      phones,
      pairCount: plans.length,
      docs,
      matchIds: plans.map((plan) => plan.matchId),
    },
    manifest: {count: manifests.length, manifests: manifests.map((item) => item.operationId)},
    appliedSummary: args.apply ? {written: docs.length} : null,
  });
}

async function runResetUserDemoState({db, args, projectId}) {
  const plan = await buildResetUserDemoStatePlan({
    db,
    phone: args.phone,
    uid: args.uid,
  });
  let aggregateSummary = null;
  if (args.apply) {
    await applyDeletePlan({db, paths: plan.paths});
    aggregateSummary = await repairAggregates(db);
  }
  printPlan({
    args,
    projectId,
    title: "Demo reset user state plan",
    plan,
    manifest: {pathCount: plan.paths.length},
    appliedSummary: args.apply ? {deleted: plan.paths.length, aggregateSummary} : null,
  });
}

async function runValidateDemoState({db, args, projectId}) {
  const phones = args.phone ? [args.phone] : phonesFromArgs(args);
  const reports = [];
  if (args.uid) {
    reports.push(await buildValidateDemoStateReport({db, uid: args.uid}));
  }
  for (const phone of phones) {
    reports.push(await buildValidateDemoStateReport({db, phone}));
  }
  if (reports.length === 0) {
    throw new Error("validate-demo-state requires --phone, --phones, --phone-file, or --uid.");
  }
  printPlan({
    args,
    projectId,
    title: "Demo state validation",
    plan: {
      command: "validate-demo-state",
      reports,
      readyCount: reports.filter((report) => report.demoReady).length,
      issueCount: reports.reduce((sum, report) => sum + report.issues.length, 0),
    },
    manifest: null,
    appliedSummary: null,
  });
}

async function runDemoChecklist({db, args, projectId}) {
  const phones = args.phone ? [args.phone] : phonesFromArgs(args);
  const reports = [];
  if (args.uid) reports.push(await buildDemoChecklist({db, uid: args.uid}));
  for (const phone of phones) {
    reports.push(await buildDemoChecklist({db, phone}));
  }
  if (reports.length === 0) {
    throw new Error("demo-checklist requires --phone, --phones, --phone-file, or --uid.");
  }
  printPlan({
    args,
    projectId,
    title: "Demo checklist",
    plan: {
      command: "demo-checklist",
      reports,
    },
    manifest: null,
    appliedSummary: null,
  });
}

async function runCleanupDemoData({db, args, projectId}) {
  const plan = await buildLaunchCleanupPlan({
    db,
    seedPrefixes: args.seedPrefixes.length > 0 ?
      args.seedPrefixes :
      undefined,
  });
  if (args.apply) await applyDeletePlan({db, paths: plan.paths});
  printPlan({
    args,
    projectId,
    title: "Demo cleanup plan",
    plan,
    manifest: {pathCount: plan.paths.length},
    appliedSummary: args.apply ? {deleted: plan.paths.length} : null,
  });
}

async function runWritePlan({db, args, projectId, title, plan, repair = false}) {
  let aggregateSummary = null;
  if (args.apply) {
    await applyDocPlan({db, docs: plan.docs});
    if (repair) aggregateSummary = await repairAggregates(db);
  }
  const manifest = await writeManifest({db, admin, plan, apply: args.apply});
  printPlan({
    args,
    projectId,
    title,
    plan,
    manifest,
    appliedSummary: args.apply ? {written: plan.docs.length, aggregateSummary} : null,
  });
}

async function repairAggregates(db) {
  const runPlan = await buildRunAggregateRepairPlan(db);
  const clubPlan = await buildMemberCountRepairPlan(db);
  await applyRunAggregateRepairPlan(db, runPlan);
  await applyMemberCountRepairPlan(db, clubPlan);
  return {
    runRepairs: runPlan.summary.repairsNeeded,
    runWarnings: runPlan.summary.warnings.length,
    clubRepairs: clubPlan.summary.repairsNeeded,
    clubWarnings: clubPlan.summary.warnings.length,
  };
}

function runSeedCommand(command, args) {
  const seedArgs = [];
  if (command === "append-user" &&
    !args.anchorFile &&
    args.anchorUsers.length === 0 &&
    args.anchorPhones.length === 0 &&
    !args.phone &&
    args.phones.length === 0) {
    throw new Error("append-user requires --phone, --phones, --anchor-phones, --anchor-users, or --anchor-file.");
  }
  if (args.env) seedArgs.push("--env", args.env);
  if (args.project) seedArgs.push("--project", args.project);
  if (args.scenario) seedArgs.push("--scenario", args.scenario);
  if (args.seedPrefix) seedArgs.push("--seed-prefix", args.seedPrefix);
  if (args.anchorFile) seedArgs.push("--anchor-file", args.anchorFile);
  if (args.anchorUsers.length > 0) seedArgs.push("--anchor-users", args.anchorUsers.join(","));
  const seedAnchorPhones = [...args.anchorPhones];
  if (command === "append-user" && args.phone) seedAnchorPhones.push(args.phone);
  if (command === "append-user") seedAnchorPhones.push(...args.phones);
  if (seedAnchorPhones.length > 0) seedArgs.push("--anchor-phones", seedAnchorPhones.join(","));
  if (args.emulatorHost) seedArgs.push("--emulator-host", args.emulatorHost);
  if (args.apply) seedArgs.push("--apply");
  if (args.allowProd) seedArgs.push("--allow-prod");
  if (args.resetSynthetic) seedArgs.push("--reset-synthetic");
  if (args.json) seedArgs.push("--json");
  if (command === "append-user") seedArgs.push("--append-anchors");

  const result = spawnSync(
    process.execPath,
    [path.join(toolDir, "seed_demo_data.mjs"), ...seedArgs],
    {stdio: "inherit"}
  );
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}

function parseArgs(argv) {
  const args = {
    env: null,
    project: null,
    scenario: "beta-full",
    seedPrefix: DEFAULT_DEMO_OPS_PREFIX,
    anchorUsers: [],
    anchorPhones: [],
    anchorFile: null,
    phone: null,
    phones: [],
    phoneFile: null,
    phoneA: null,
    phoneB: null,
    fromPhone: null,
    toPhone: null,
    uid: null,
    runId: null,
    text: "Can you check this demo chat?",
    syntheticMatches: 3,
    seedPrefixes: [],
    goldenFile: null,
    demoScenario: null,
    apply: false,
    allowProd: false,
    resetSynthetic: false,
    viaSwipes: false,
    viaSwipesOnly: false,
    withMessages: false,
    emulatorHost: null,
    json: false,
    help: false,
  };
  const command = argv[0];
  for (let i = 1; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") args.help = true;
    else if (arg === "--json") args.json = true;
    else if (arg === "--apply") args.apply = true;
    else if (arg === "--allow-prod") args.allowProd = true;
    else if (arg === "--reset-synthetic") args.resetSynthetic = true;
    else if (arg === "--via-swipes") args.viaSwipes = true;
    else if (arg === "--with-messages") args.withMessages = true;
    else if (arg === "--via-swipes-only") {
      args.viaSwipes = true;
      args.viaSwipesOnly = true;
      args.withMessages = false;
    } else if (arg === "--no-messages") args.withMessages = false;
    else if (arg === "--emulator") args.emulatorHost = "127.0.0.1:8080";
    else if (arg === "--emulator-host") args.emulatorHost = requireValue(argv, ++i, arg);
    else if (arg === "--env") args.env = requireValue(argv, ++i, arg);
    else if (arg === "--project") args.project = requireValue(argv, ++i, arg);
    else if (arg === "--scenario") args.scenario = requireValue(argv, ++i, arg);
    else if (arg === "--seed-prefix") args.seedPrefix = requireValue(argv, ++i, arg);
    else if (arg === "--anchor-file") args.anchorFile = requireValue(argv, ++i, arg);
    else if (arg === "--anchor-users") args.anchorUsers = splitCsv(requireValue(argv, ++i, arg));
    else if (arg === "--anchor-phones") args.anchorPhones = splitCsv(requireValue(argv, ++i, arg));
    else if (arg === "--phone") args.phone = requireValue(argv, ++i, arg);
    else if (arg === "--phones") args.phones = splitCsv(requireValue(argv, ++i, arg));
    else if (arg === "--phone-file") args.phoneFile = requireValue(argv, ++i, arg);
    else if (arg === "--phone-a") args.phoneA = requireValue(argv, ++i, arg);
    else if (arg === "--phone-b") args.phoneB = requireValue(argv, ++i, arg);
    else if (arg === "--from-phone") args.fromPhone = requireValue(argv, ++i, arg);
    else if (arg === "--to-phone") args.toPhone = requireValue(argv, ++i, arg);
    else if (arg === "--uid") args.uid = requireValue(argv, ++i, arg);
    else if (arg === "--run-id") args.runId = requireValue(argv, ++i, arg);
    else if (arg === "--text") args.text = requireValue(argv, ++i, arg);
    else if (arg === "--seed-prefixes") args.seedPrefixes = splitCsv(requireValue(argv, ++i, arg));
    else if (arg === "--golden-file") args.goldenFile = requireValue(argv, ++i, arg);
    else if (arg === "--demo-scenario") args.demoScenario = requireValue(argv, ++i, arg);
    else if (arg === "--synthetic-matches") {
      args.syntheticMatches = Number(requireValue(argv, ++i, arg));
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  if (command === "seed-world" || command === "append-user") {
    args.seedPrefix = args.seedPrefix === DEFAULT_DEMO_OPS_PREFIX ?
      DEFAULT_SEED_PREFIX :
      args.seedPrefix;
  }
  return {command, args};
}

function printScenarioInfo(args) {
  const scenarios = args.demoScenario ?
    [loadScenarioConfig(args.demoScenario)] :
    listScenarioConfigs();
  if (args.json) {
    console.log(JSON.stringify({scenarios}, null, 2));
    return;
  }
  console.log("Demo scenarios:");
  for (const scenario of scenarios) {
    console.log(`- ${scenario.id}: ${scenario.label}`);
    console.log(`  ${scenario.description}`);
  }
}

function printGoldenAccounts(args) {
  const accounts = loadGoldenAccounts(args.goldenFile ?? undefined);
  if (args.json) {
    console.log(JSON.stringify({accounts}, null, 2));
    return;
  }
  console.log("Golden demo accounts:");
  for (const account of accounts) {
    console.log(`- ${account.role}: ${account.phone} (${account.scenario})`);
  }
}

function phonesFromArgs(args) {
  const phones = [...args.phones];
  if (args.phoneFile) {
    const raw = fs.readFileSync(args.phoneFile, "utf8");
    phones.push(
      ...raw.split(/\r?\n/)
        .map((line) => line.trim())
        .filter((line) => line && !line.startsWith("#"))
    );
  }
  return phones;
}

function guardProdWrite({args, projectId}) {
  if (args.apply && isProductionTarget({env: args.env, projectId}) && !args.allowProd) {
    throw new Error("Refusing to write to prod without --allow-prod.");
  }
}

function requireArg(args, key, flag) {
  if (!args[key]) throw new Error(`${flag} is required.`);
  return args[key];
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function printPlan({args, projectId, title, plan, manifest, appliedSummary}) {
  if (args.json) {
    console.log(JSON.stringify({projectId, apply: args.apply, plan, manifest, appliedSummary}, null, 2));
    return;
  }
  console.log(title);
  console.log(`Project: ${projectId}`);
  console.log(`Mode: ${args.apply ? "apply" : "dry run"}`);
  if (plan.command) console.log(`Command: ${plan.command}`);
  if (plan.operationId) console.log(`Operation: ${plan.operationId}`);
  if (plan.uid) console.log(`User: ${plan.uid}`);
  if (plan.matchId) console.log(`Match: ${plan.matchId}`);
  if (plan.runId) console.log(`Run: ${plan.runId}`);
  if (plan.docs) console.log(`Docs to write: ${plan.docs.length}`);
  if (plan.paths) console.log(`Docs to delete: ${plan.paths.length}`);
  if (plan.pairCount) console.log(`Pairs: ${plan.pairCount}`);
  if (manifest?.operationId) {
    console.log(`Manifest: ${manifest.operationId}`);
  }
  if (appliedSummary) {
    console.log("\nApplied:");
    for (const [key, value] of Object.entries(appliedSummary)) {
      console.log(`- ${key}: ${JSON.stringify(value)}`);
    }
  } else if (plan.reports) {
    if (typeof plan.readyCount === "number") {
      console.log(`Ready users: ${plan.readyCount}/${plan.reports.length}`);
    }
    for (const report of plan.reports) {
      const status = report.demoReady ? "ready" : report.issues?.join("; ") ?? "review gaps";
      console.log(`- ${report.uid}: ${status}`);
      if (Array.isArray(report.canDemo)) {
        console.log(`  Can demo: ${report.canDemo.join(", ") || "nothing yet"}`);
      }
      if (Array.isArray(report.gaps) && report.gaps.length > 0) {
        console.log(`  Gaps: ${report.gaps.join(", ")}`);
      }
    }
  } else {
    console.log("\nDry run only. Re-run with --apply to write changes.");
  }
}

function printCommands() {
  console.log(`Demo ops commands:
- seed-world
- append-user
- match-phones
- warm-user
- warm-group
- reset-user-demo-state
- validate-demo-state
- demo-checklist
- cleanup-demo-data
- make-run-full
- mark-attended
- promote-waitlist
- create-unread-message
- create-refund
- create-host-account
- scenario-info
- list-golden-accounts`);
}

function printHelp() {
  console.log(`Catch demo operations CLI

Usage:
  node tool/demo_ops.mjs seed-world --env prod --anchor-file tool/demo_seed/beta_anchors.txt --apply --reset-synthetic --allow-prod
  node tool/demo_ops.mjs append-user --env prod --anchor-phones +919999999999 --apply --allow-prod
  node tool/demo_ops.mjs match-phones --env prod --phone-a +91... --phone-b +91... --apply --allow-prod
  node tool/demo_ops.mjs warm-user --env prod --phone +91... --apply --allow-prod
  node tool/demo_ops.mjs warm-group --env prod --phones +91...,+91...,+91... --apply --allow-prod
  node tool/demo_ops.mjs reset-user-demo-state --env prod --phone +91... --apply --allow-prod
  node tool/demo_ops.mjs validate-demo-state --env prod --phones +91...,+91...
  node tool/demo_ops.mjs cleanup-demo-data --env prod --allow-prod
  node tool/demo_ops.mjs demo-checklist --env prod --phone +91...
  node tool/demo_ops.mjs scenario-info --demo-scenario investor-demo

Common options:
  --env <dev|staging|prod>       Resolve project id from .firebaserc.
  --project <firebase-project>   Explicit project id.
  --apply                        Write/delete documents. Default is dry run.
  --allow-prod                   Required for prod writes.
  --json                         Machine-readable output.
  --emulator / --emulator-host   Use Firestore emulator.

Command options:
  --phone <phone>                One E.164 phone number.
  --phones <phone,...>           Comma-separated phone numbers.
  --phone-a / --phone-b          Pair for match-phones.
  --from-phone / --to-phone      Sender and recipient for unread-message.
  --run-id <runId>               Force match/shared run context.
  --text <message>               Demo chat message text.
  --via-swipes                   Also write reciprocal swipe likes.
  --via-swipes-only              Write reciprocal likes only; rely on trigger.
  --with-messages                Create starter chat messages for match-phones.
  --no-messages                  Deprecated; match-phones defaults to no messages.
  --synthetic-matches <n>        warm-user synthetic match count. Default: 3.
  --seed-prefixes <prefix,...>   cleanup-demo-data prefixes.
  --demo-scenario <name|path>    scenario-info target.
  --golden-file <path>           Golden account registry JSON.
  --anchor-file <path>           seed-world/append-user anchor file.
  --anchor-phones <phone,...>    seed-world/append-user real users.
  --anchor-users <uid,...>       seed-world/append-user real users.
  --scenario <name>              seed-world/append-user scenario. Default beta-full.
  --seed-prefix <prefix>         Demo operation or world seed prefix.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
