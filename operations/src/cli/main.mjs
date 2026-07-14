#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  assertPersistedInventory,
  OperationsEngine,
} from "../platform/engine.mjs";
import {CLI_COMMANDS} from "../platform/cli-contract.mjs";
import {asOperationsError, OperationsError} from "../platform/errors.mjs";
import {buildAdminProjection, queueProjection, summarizeRun, validateCanonicalProjection} from "../platform/read-models.mjs";
import {FileOperationsStore} from "../platform/storage/file-store.mjs";
import {
  WORKFLOW_REGISTRY,
  workflowDescriptor,
} from "../workflows/registry.mjs";

const cliDirectory = path.dirname(fileURLToPath(import.meta.url));
const operationsRoot = path.resolve(cliDirectory, "..", "..");
const defaultRepoRoot = path.resolve(operationsRoot, "..");
export {CLI_COMMANDS};

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

  const clock = createCliClock(parsed.flags.now, dependencies.systemClock);
  const leaseClock = createCliClock(undefined, dependencies.systemClock);
  const now = clock().toISOString();
  const repoRoot = path.resolve(parsed.flags.repoRoot ?? defaultRepoRoot);
  const stateDir = path.resolve(parsed.flags.stateDir ?? path.join(operationsRoot, ".state"));
  const registry = dependencies.workflowRegistry ?? WORKFLOW_REGISTRY;
  const workflowFor = (workflowId) => resolveWorkflow({
    workflowId,
    registry,
    repoRoot,
    injected: dependencies.workflow,
    command: parsed.command,
  });
  if (parsed.command === "plan") {
    const workflow = workflowFor(parsed.flags.workflow ?? "supply-intake");
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
  const engineFor = (workflow) => dependencies.engine ??
    new OperationsEngine({
      store,
      workflow,
      clock,
      leaseClock,
      workerId: parsed.flags.worker ?? `cli-${process.pid}`,
    });
  const command = parsed.command;
  let data;

  if (command === "run") {
    const planFromFile = parsed.flags.plan ?
      await readPlan(parsed.flags.plan) : null;
    const workflowId = planFromFile?.workflowId ??
      parsed.flags.workflow ?? "supply-intake";
    if (parsed.flags.workflow && planFromFile &&
        parsed.flags.workflow !== planFromFile.workflowId) {
      throw new OperationsError(
        "WORKFLOW_MISMATCH",
        "--workflow does not match the supplied plan."
      );
    }
    const workflow = workflowFor(workflowId);
    const plan = planFromFile ?? await createPlan(
      workflow,
      parsed.flags,
      now
    );
    const engine = engineFor(workflow);
    const result = await engine.start(plan, {requestedRunId: parsed.flags.run});
    data = await statusData(store, result.run.runId, workflow);
    data.idempotentReplay = result.idempotentReplay;
  } else if (command === "resume") {
    requireFlag(parsed.flags, "run");
    const current = await store.requireRun(parsed.flags.run);
    const workflow = workflowFor(current.workflowId);
    assertRequestedWorkflow(parsed.flags.workflow, current.workflowId);
    const engine = engineFor(workflow);
    const result = await engine.resume(current.runId, current.plan);
    data = await statusData(store, result.run.runId, workflow);
    data.idempotentReplay = result.idempotentReplay;
  } else if (command === "queue") {
    requireFlag(parsed.flags, "run");
    const run = await store.requireRun(parsed.flags.run);
    const workflow = workflowFor(run.workflowId);
    assertRequestedWorkflow(parsed.flags.workflow, run.workflowId);
    workflow.assertPlan(run.plan);
    const lifecycleFilter = queueLifecycle(
      parsed.flags.lifecycle,
      workflow
    );
    if (parsed.flags.stage &&
        !workflow.primaryStages.includes(parsed.flags.stage)) {
      throw new OperationsError(
        "INVALID_ARGUMENT",
        "--stage must be declared by the selected workflow.",
        {exitCode: 2}
      );
    }
    const inventory = await store.listWorkItems({runId: parsed.flags.run});
    assertPersistedInventory(run, inventory);
    assertWorkflowItems(workflow, inventory);
    const items = inventory.filter((item) =>
      (!parsed.flags.stage || item.primaryStage === parsed.flags.stage) &&
      (!parsed.flags.owner || item.owner === parsed.flags.owner) &&
      (!parsed.flags.source ||
        item.source?.sourceProfileId === parsed.flags.source) &&
      (!lifecycleFilter.statuses ||
        lifecycleFilter.statuses.includes(item.lifecycleStatus)));
    data = {
      runId: parsed.flags.run,
      filters: {
        stage: parsed.flags.stage ?? null,
        owner: parsed.flags.owner ?? null,
        sourceProfileId: parsed.flags.source ?? null,
        lifecycleStatus: lifecycleFilter.label,
        resolvedLifecycleStatuses: lifecycleFilter.statuses,
      },
      total: items.length,
      items: queueProjection(items, {
        limit: positiveInteger(parsed.flags.limit, 100),
        includeTerminal: true,
        primaryStages: run.plan?.workflowContract?.primaryStages,
        lifecycleSemantics:
          run.plan?.workflowContract?.lifecycleSemantics,
      }),
    };
  } else if (command === "status") {
    requireFlag(parsed.flags, "run");
    const run = await store.requireRun(parsed.flags.run);
    const workflow = workflowFor(run.workflowId);
    assertRequestedWorkflow(parsed.flags.workflow, run.workflowId);
    data = await statusData(store, parsed.flags.run, workflow);
  } else if (command === "promote") {
    requireFlag(parsed.flags, "run");
    const run = await store.requireRun(parsed.flags.run);
    const workflow = workflowFor(run.workflowId);
    assertRequestedWorkflow(parsed.flags.workflow, run.workflowId);
    const engine = engineFor(workflow);
    data = {receipt: await engine.promotionReceipt(parsed.flags.run)};
  } else if (command === "reconcile") {
    requireFlag(parsed.flags, "run");
    const run = await store.requireRun(parsed.flags.run);
    const workflow = workflowFor(run.workflowId);
    assertRequestedWorkflow(parsed.flags.workflow, run.workflowId);
    const engine = engineFor(workflow);
    const reconciliation = await engine.reconcile(parsed.flags.run);
    data = {
      reconciliation,
      ...(await statusData(store, reconciliation.runId, workflow)),
    };
  } else if (command === "export-admin") {
    requireFlag(parsed.flags, "run");
    let run = await store.requireRun(parsed.flags.run);
    const workflow = workflowFor(run.workflowId);
    assertRequestedWorkflow(parsed.flags.workflow, run.workflowId);
    workflow.assertPlan(run.plan);
    if (run.status !== "completed") {
      throw new OperationsError(
        "RUN_NOT_COMPLETED",
        "Only immutable completed run snapshots can be exported."
      );
    }
    run = await engineFor(workflow).repairCompletedRun(run.runId);
    const [items, actions, checkpoints] = await Promise.all([
      store.listWorkItems({runId: run.runId}),
      store.listActions(run.runId),
      store.listCheckpoints(run.runId),
    ]);
    assertPersistedInventory(run, items);
    assertWorkflowItems(workflow, items);
    const projection = buildAdminProjection(run, items, actions, checkpoints);
    const contractValidation = await validateCanonicalProjection({repoRoot, projection, requireContracts: true});
    const written = await store.putAdminProjection(run.runId, projection);
    data = {artifactPath: written.path, contractValidation, artifact: projection};
  } else if (command === "learn") {
    const descriptor = requireWorkflowDescriptor(
      parsed.flags.workflow ?? "supply-intake",
      registry
    );
    assertCommandSupported(descriptor, "learn");
    if (typeof descriptor.createLearner !== "function") {
      throw new OperationsError(
        "WORKFLOW_NOT_EXECUTABLE",
        `Workflow ${descriptor.workflowId} has no learner factory.`
      );
    }
    const learner = dependencies.learner ?? descriptor.createLearner({
      store,
      clock,
    });
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

export function createCliClock(nowOverride, systemClock = () => new Date()) {
  if (nowOverride !== undefined) {
    const fixed = new Date(nowOverride);
    if (Number.isNaN(fixed.valueOf())) {
      throw new OperationsError("INVALID_ARGUMENT", "--now must be an ISO-8601 timestamp.", {exitCode: 2});
    }
    return () => new Date(fixed.valueOf());
  }
  return () => {
    const current = systemClock();
    const date = current instanceof Date ? current : new Date(current);
    if (Number.isNaN(date.valueOf())) {
      throw new OperationsError("INVALID_CLOCK", "System clock returned an invalid timestamp.");
    }
    return date;
  };
}

async function createPlan(workflow, flags, now) {
  return workflow.createPlan({
    market: flags.market ?? "mumbai",
    through: flags.through ?? defaultThrough(now),
    now,
  });
}

function resolveWorkflow({workflowId, registry, repoRoot, injected, command}) {
  const descriptor = requireWorkflowDescriptor(workflowId, registry);
  assertCommandSupported(descriptor, command);
  if (injected) {
    if (injected.workflowId !== workflowId) {
      throw new OperationsError(
        "WORKFLOW_MISMATCH",
        `Injected workflow ${injected.workflowId} cannot handle ${workflowId}.`
      );
    }
    return injected;
  }
  if (typeof descriptor.createWorkflow !== "function") {
    throw new OperationsError(
      "WORKFLOW_NOT_EXECUTABLE",
      `Workflow ${workflowId} has no executable factory.`
    );
  }
  return descriptor.createWorkflow({repoRoot});
}

function assertCommandSupported(descriptor, command) {
  if (!descriptor.commands?.includes(command)) {
    throw new OperationsError(
      "WORKFLOW_COMMAND_UNSUPPORTED",
      `Workflow ${descriptor.workflowId} does not support ${command}.`,
      {exitCode: 2}
    );
  }
}

function requireWorkflowDescriptor(workflowId, registry) {
  const descriptor = workflowDescriptor(workflowId, registry);
  if (!descriptor) {
    throw new OperationsError(
      "WORKFLOW_NOT_REGISTERED",
      `Workflow ${workflowId} is not registered.`,
      {exitCode: 2}
    );
  }
  return descriptor;
}

function assertRequestedWorkflow(requested, actual) {
  if (requested && requested !== actual) {
    throw new OperationsError(
      "WORKFLOW_MISMATCH",
      `Run belongs to ${actual}, not ${requested}.`,
      {exitCode: 2}
    );
  }
}

function assertWorkflowItems(workflow, items) {
  for (const item of items) workflow.assertWorkItem(item);
}

async function statusData(store, runId, workflow) {
  const run = await store.requireRun(runId);
  workflow.assertPlan(run.plan);
  const [items, actions, checkpoints] = await Promise.all([
    store.listWorkItems({runId}),
    store.listActions(runId),
    store.listCheckpoints(runId),
  ]);
  assertPersistedInventory(run, items);
  assertWorkflowItems(workflow, items);
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
  if (!CLI_COMMANDS.includes(first)) throw new OperationsError("UNKNOWN_COMMAND", `Unknown command: ${first}.`, {exitCode: 2});
  const subcommand = first === "learn" && values[0] && !values[0].startsWith("--") ? values.shift() : null;
  return {command: first, subcommand, flags: parseFlags(values)};
}

function parseFlags(argv) {
  const booleanFlags = new Set(["--pretty"]);
  const valueFlags = new Set([
    "--limit",
    "--lifecycle",
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
    "--workflow",
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

function queueLifecycle(value, workflow) {
  const lifecycleStatuses = workflow?.lifecycleStatuses;
  const activeStatuses = workflow?.lifecycleSemantics?.activeStatuses;
  if (!Array.isArray(lifecycleStatuses) ||
      !Array.isArray(activeStatuses) || activeStatuses.length === 0 ||
      activeStatuses.some((status) => !lifecycleStatuses.includes(status))) {
    throw new OperationsError(
      "INVALID_WORKFLOW",
      "Queueable workflows must declare active lifecycle semantics."
    );
  }
  if (value === undefined) {
    return {label: "active", statuses: [...activeStatuses]};
  }
  if (value === "all") return {label: "all", statuses: null};
  if (!lifecycleStatuses.includes(value)) {
    throw new OperationsError(
      "INVALID_ARGUMENT",
      "--lifecycle must be all or a lifecycle declared by the workflow.",
      {exitCode: 2}
    );
  }
  return {label: value, statuses: [value]};
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
      commands: [...CLI_COMMANDS],
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
