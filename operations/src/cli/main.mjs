#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {OperationsEngine} from "../platform/engine.mjs";
import {asOperationsError, OperationsError} from "../platform/errors.mjs";
import {buildAdminProjection, queueProjection, summarizeRun, validateCanonicalProjection} from "../platform/read-models.mjs";
import {FileOperationsStore} from "../platform/storage/file-store.mjs";
import {SupplyIntakeLearner} from "../workflows/supply-intake/learning.mjs";
import {SupplyIntakeWorkflow} from "../workflows/supply-intake/workflow.mjs";

const cliDirectory = path.dirname(fileURLToPath(import.meta.url));
const operationsRoot = path.resolve(cliDirectory, "..", "..");
const defaultRepoRoot = path.resolve(operationsRoot, "..");
const COMMANDS = ["plan", "run", "resume", "queue", "status", "promote", "reconcile", "learn", "export-admin"];

if (isMain()) {
  main(process.argv.slice(2)).then(({envelope, pretty}) => {
    process.stdout.write(`${JSON.stringify(envelope, null, pretty ? 2 : 0)}\n`);
  }).catch((error) => {
    const normalized = asOperationsError(error);
    const envelope = errorEnvelope(normalized, process.argv.slice(2));
    process.stderr.write(`${JSON.stringify(envelope)}\n`);
    process.exitCode = normalized.exitCode;
  });
}

export async function main(argv, dependencies = {}) {
  const parsed = parseArguments(argv);
  if (parsed.command === "help") return {envelope: helpEnvelope(), pretty: parsed.flags.pretty};

  const now = parsed.flags.now ?? new Date().toISOString();
  const clock = () => new Date(now);
  const repoRoot = path.resolve(parsed.flags.repoRoot ?? defaultRepoRoot);
  const stateDir = path.resolve(parsed.flags.stateDir ?? path.join(operationsRoot, ".state"));
  const workflow = dependencies.workflow ?? new SupplyIntakeWorkflow({repoRoot});
  if (parsed.command === "plan") {
    return {
      pretty: parsed.flags.pretty,
      envelope: {
        schemaVersion: 1,
        program: "catch-operations",
        command: "plan",
        ok: true,
        data: {plan: await createPlan(workflow, parsed.flags, now)},
        warnings: [],
      },
    };
  }
  const store = dependencies.store ?? await new FileOperationsStore(stateDir).initialize();
  const engine = dependencies.engine ?? new OperationsEngine({store, workflow, clock, workerId: parsed.flags.worker ?? `cli-${process.pid}`});
  const learner = dependencies.learner ?? new SupplyIntakeLearner({store, clock});
  const command = parsed.command;
  let data;

  if (command === "run") {
    const plan = parsed.flags.plan ? await readPlan(parsed.flags.plan) : await createPlan(workflow, parsed.flags, now);
    const result = await engine.start(plan, {requestedRunId: parsed.flags.run});
    data = await statusData(store, result.run.runId);
    data.idempotentReplay = result.idempotentReplay;
  } else if (command === "resume") {
    requireFlag(parsed.flags, "run");
    const current = await store.requireRun(parsed.flags.run);
    const result = await engine.resume(current.runId, current.plan);
    data = await statusData(store, result.run.runId);
    data.idempotentReplay = result.idempotentReplay;
  } else if (command === "queue") {
    requireFlag(parsed.flags, "run");
    await store.requireRun(parsed.flags.run);
    const items = await store.listWorkItems({
      runId: parsed.flags.run,
      stage: parsed.flags.stage,
      owner: parsed.flags.owner,
      sourceProfileId: parsed.flags.source,
    });
    data = {
      runId: parsed.flags.run,
      filters: {stage: parsed.flags.stage ?? null, owner: parsed.flags.owner ?? null, sourceProfileId: parsed.flags.source ?? null},
      total: items.length,
      items: queueProjection(items, {limit: positiveInteger(parsed.flags.limit, 100)}),
    };
  } else if (command === "status") {
    requireFlag(parsed.flags, "run");
    data = await statusData(store, parsed.flags.run);
  } else if (command === "promote") {
    requireFlag(parsed.flags, "run");
    data = {receipt: await engine.promotionReceipt(parsed.flags.run)};
  } else if (command === "reconcile") {
    requireFlag(parsed.flags, "run");
    data = {reconciliation: await engine.reconcile(parsed.flags.run), ...(await statusData(store, parsed.flags.run))};
  } else if (command === "export-admin") {
    requireFlag(parsed.flags, "run");
    const run = await store.requireRun(parsed.flags.run);
    const [items, actions, checkpoints] = await Promise.all([
      store.listWorkItems({runId: run.runId}),
      store.listActions(run.runId),
      store.listCheckpoints(run.runId),
    ]);
    const projection = buildAdminProjection(run, items, actions, checkpoints);
    const contractValidation = await validateCanonicalProjection({repoRoot, projection, requireContracts: true});
    const written = await store.putAdminProjection(run.runId, projection);
    data = {artifactPath: written.path, contractValidation, artifact: projection};
  } else if (command === "learn") {
    data = await runLearn(parsed.subcommand, parsed.flags, learner);
  } else {
    throw new OperationsError("UNKNOWN_COMMAND", `Unknown command: ${command}.`, {exitCode: 2});
  }

  return {
    pretty: parsed.flags.pretty,
    envelope: {
      schemaVersion: 1,
      program: "catch-operations",
      command: command === "learn" ? `learn.${parsed.subcommand}` : command,
      ok: true,
      data,
      warnings: [],
    },
  };
}

async function createPlan(workflow, flags, now) {
  return workflow.createPlan({
    market: flags.market ?? "mumbai",
    through: flags.through ?? defaultThrough(now),
    now,
  });
}

async function statusData(store, runId) {
  const run = await store.requireRun(runId);
  const [items, actions, checkpoints] = await Promise.all([
    store.listWorkItems({runId}),
    store.listActions(runId),
    store.listCheckpoints(runId),
  ]);
  return summarizeRun(run, items, actions, checkpoints);
}

async function runLearn(subcommand, flags, learner) {
  if (subcommand === "propose") {
    requireFlag(flags, "source");
    return {proposal: await learner.propose(flags.source)};
  }
  if (subcommand === "evaluate") {
    requireFlag(flags, "proposal");
    return {evaluation: await learner.evaluate(flags.proposal)};
  }
  if (subcommand === "canary") {
    requireFlag(flags, "proposal");
    return {canary: await learner.canary(flags.proposal)};
  }
  if (subcommand === "status") return learner.status();
  throw new OperationsError("UNKNOWN_SUBCOMMAND", `Unknown learn subcommand: ${subcommand ?? "<missing>"}.`, {exitCode: 2});
}

function parseArguments(argv) {
  const values = [...argv];
  const first = values.shift() ?? "help";
  if (first === "help" || first === "--help" || first === "-h") return {command: "help", subcommand: null, flags: parseFlags(values)};
  if (!COMMANDS.includes(first)) throw new OperationsError("UNKNOWN_COMMAND", `Unknown command: ${first}.`, {exitCode: 2});
  const subcommand = first === "learn" && values[0] && !values[0].startsWith("--") ? values.shift() : null;
  return {command: first, subcommand, flags: parseFlags(values)};
}

function parseFlags(argv) {
  const booleanFlags = new Set(["--pretty"]);
  const valueFlags = new Set([
    "--limit",
    "--market",
    "--now",
    "--owner",
    "--plan",
    "--proposal",
    "--repo-root",
    "--run",
    "--source",
    "--stage",
    "--state-dir",
    "--through",
    "--worker",
  ]);
  const result = {};
  for (let index = 0; index < argv.length; index += 1) {
    const flag = argv[index];
    if (booleanFlags.has(flag)) result[camel(flag)] = true;
    else if (valueFlags.has(flag)) {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new OperationsError("INVALID_ARGUMENT", `${flag} requires a value.`, {exitCode: 2});
      result[camel(flag)] = value;
      index += 1;
    } else {
      throw new OperationsError("INVALID_ARGUMENT", `Unknown argument: ${flag}.`, {exitCode: 2});
    }
  }
  return result;
}

function camel(flag) {
  return flag.slice(2).replace(/-([a-z])/g, (_match, character) => character.toUpperCase());
}

function requireFlag(flags, name) {
  if (!flags[name]) throw new OperationsError("MISSING_ARGUMENT", `--${name.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`)} is required.`, {exitCode: 2});
}

async function readPlan(file) {
  const parsed = JSON.parse(await fs.readFile(path.resolve(file), "utf8"));
  return parsed.plan ?? parsed.data?.plan ?? parsed;
}

function positiveInteger(value, fallback) {
  if (value === undefined) return fallback;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 1 || parsed > 10_000) {
    throw new OperationsError("INVALID_ARGUMENT", "--limit must be an integer between 1 and 10000.", {exitCode: 2});
  }
  return parsed;
}

function defaultThrough(now) {
  const date = new Date(now);
  date.setUTCDate(date.getUTCDate() + 14);
  return date.toISOString().slice(0, 10);
}

function helpEnvelope() {
  return {
    schemaVersion: 1,
    program: "catch-operations",
    command: "help",
    ok: true,
    data: {
      usage: "node operations/src/cli/main.mjs <command> [flags]",
      commands: [...COMMANDS],
      learnSubcommands: ["propose", "evaluate", "canary", "status"],
      contract: "All commands emit a JSON envelope. Only shadow execution is available.",
    },
    warnings: [],
  };
}

function errorEnvelope(error, argv) {
  return {
    schemaVersion: 1,
    program: "catch-operations",
    command: argv[0] ?? "help",
    ok: false,
    error: {code: error.code, message: error.message, details: error.details},
  };
}

function isMain() {
  return process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
}
