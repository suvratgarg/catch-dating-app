#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {loadAdminActionCatalog, publicAction} from "../admin/action-catalog.mjs";
import {
  callableBaseUrl,
  FirebaseAdminCallableClient,
} from "../admin/callable-client.mjs";
import {AdminActionReceiptStore} from "../admin/receipt-store.mjs";
import {hashValue} from "../platform/canonical-json.mjs";
import {asOperationsError, OperationsError} from "../platform/errors.mjs";

const cliDirectory = path.dirname(fileURLToPath(import.meta.url));
const operationsRoot = path.resolve(cliDirectory, "..", "..");
const defaultRepoRoot = path.resolve(operationsRoot, "..");

if (isMain()) {
  main(process.argv.slice(2)).then(({envelope, pretty}) => {
    process.stdout.write(`${JSON.stringify(envelope, null, pretty ? 2 : 0)}\n`);
  }).catch((error) => {
    const normalized = asOperationsError(error);
    process.stderr.write(`${JSON.stringify({
      schemaVersion: 1,
      program: "catch-admin",
      command: process.argv[2] ?? "help",
      ok: false,
      error: {
        code: normalized.code,
        message: normalized.message,
        details: normalized.details,
      },
    })}\n`);
    process.exitCode = normalized.exitCode;
  });
}

export async function main(argv, dependencies = {}) {
  const parsed = parseArguments(argv);
  const repoRoot = path.resolve(parsed.flags.repoRoot ?? defaultRepoRoot);
  const catalog = dependencies.catalog ?? await loadAdminActionCatalog({repoRoot});
  const pretty = parsed.flags.pretty === true;
  let data;
  if (parsed.command === "help") data = helpData();
  else if (parsed.command === "actions") {
    data = listActions(catalog, parsed.flags);
  } else if (parsed.command === "describe") {
    data = describeAction(catalog, parsed.subject);
  } else if (parsed.command === "workflows") {
    data = {workflows: catalog.workflows};
  } else if (parsed.command === "workflow") {
    data = describeWorkflow(catalog, parsed.subject);
  } else if (parsed.command === "loop") {
    data = validateWorkflowLoop(catalog, parsed.subject, parsed.flags);
  } else if (parsed.command === "run") {
    data = await runAction({
      catalog,
      actionId: parsed.subject,
      flags: parsed.flags,
      repoRoot,
      dependencies,
    });
  } else {
    throw new OperationsError(
      "ADMIN_CLI_COMMAND_UNKNOWN",
      `Unknown command: ${parsed.command}.`,
      {exitCode: 2}
    );
  }
  return {
    pretty,
    envelope: {
      schemaVersion: 1,
      program: "catch-admin",
      command: parsed.command,
      ok: true,
      data,
      warnings: [],
    },
  };
}

export async function runAction({
  catalog,
  actionId,
  flags,
  repoRoot,
  dependencies = {},
}) {
  const action = requireAction(catalog, actionId);
  if (action.controlPlane) {
    throw new OperationsError(
      "ADMIN_ACTION_CONTROL_PLANE_ONLY",
      `${actionId} is reserved for CLI receipt orchestration.`,
      {exitCode: 2}
    );
  }
  const payload = await readPayload(flags, action);
  catalog.validateRequest(action.actionId, payload);
  const target = action.targetField ? valueAt(payload, action.targetField) : null;
  const apply = action.kind === "read" ? !flags.dryRun : flags.apply === true;
  if (!apply) {
    return {
      mode: "dry-run",
      action: publicAction(action),
      target,
      requestHash: hashValue(payload),
      confirmationRequired: action.confirmation ?? "none",
      wouldInvoke: action.callable,
    };
  }
  assertConfirmation(action, target, flags);
  const executionId = flags.executionId ?? crypto.randomUUID();
  const now = dependencies.now ?? (() => new Date());
  const startedAt = now().toISOString();
  const requestHash = hashValue(payload);
  const client = dependencies.client ?? liveClient(flags, dependencies);
  const receiptStore = dependencies.receiptStore ?? new AdminActionReceiptStore(
    path.resolve(flags.receiptDir ?? path.join(operationsRoot, ".state", "admin-actions"))
  );
  const baseReceipt = {
    schemaVersion: 1,
    executionId,
    actionId: action.actionId,
    callable: action.callable,
    target,
    requestHash,
    startedAt,
  };
  try {
    await recordRemote(client, {
      executionId,
      actionId: action.actionId,
      callable: action.callable,
      status: "started",
      requestHash,
      target,
      cliVersion: catalog.catalogVersion,
    });
  } catch (error) {
    const normalized = asOperationsError(error);
    const receiptPath = await receiptStore.put({
      ...baseReceipt,
      status: "failed",
      finishedAt: now().toISOString(),
      error: {code: normalized.code, message: normalized.message},
      remoteReceiptStatus: "not-started",
    });
    throw new OperationsError(
      "ADMIN_ACTION_RECEIPT_START_FAILED",
      "The remote receipt could not start, so the admin action was not invoked.",
      {
        cause: error,
        details: {
          actionCompleted: false,
          executionId,
          receiptPath,
          remoteErrorCode: normalized.code,
        },
        exitCode: normalized.exitCode,
      }
    );
  }
  let response;
  try {
    response = await client.invoke(action.callable, payload, {executionId});
  } catch (error) {
    const normalized = asOperationsError(error);
    const finishedAt = now().toISOString();
    const terminalStatus = isIndeterminateCallableError(normalized) ?
      "indeterminate" : "failed";
    const remoteFailureRecorded = await recordTerminalBestEffort(client, {
      executionId,
      actionId: action.actionId,
      callable: action.callable,
      status: terminalStatus,
      requestHash,
      target,
      errorCode: normalized.code,
      errorMessage: normalized.message,
      cliVersion: catalog.catalogVersion,
    });
    const receiptPath = await receiptStore.put({
      ...baseReceipt,
      status: terminalStatus,
      finishedAt,
      error: {code: normalized.code, message: normalized.message},
      remoteReceiptStatus: remoteFailureRecorded ?
        terminalStatus : "started-only",
    });
    throw new OperationsError(normalized.code, normalized.message, {
      cause: error,
      details: {
        ...normalized.details,
        actionCompleted: terminalStatus === "indeterminate" ? null : false,
        executionId,
        receiptPath,
        remoteReceiptStatus: remoteFailureRecorded ?
          terminalStatus : "started-only",
      },
      exitCode: normalized.exitCode,
    });
  }
  const responseHash = hashValue(response);
  let remoteReceiptError = null;
  try {
    await recordRemote(client, {
      executionId,
      actionId: action.actionId,
      callable: action.callable,
      status: "succeeded",
      requestHash,
      responseHash,
      target,
      cliVersion: catalog.catalogVersion,
    });
  } catch (error) {
    remoteReceiptError = asOperationsError(error);
  }
  const finishedAt = now().toISOString();
  const receiptPath = await receiptStore.put({
    ...baseReceipt,
    status: "succeeded",
    responseHash,
    finishedAt,
    remoteReceiptStatus: remoteReceiptError ? "started-only" : "succeeded",
  });
  if (remoteReceiptError) {
    throw new OperationsError(
      "ADMIN_ACTION_RECEIPT_INCOMPLETE",
      "The admin action succeeded, but its remote receipt did not become terminal.",
      {
        cause: remoteReceiptError,
        details: {
          actionCompleted: true,
          executionId,
          receiptPath,
          remoteErrorCode: remoteReceiptError.code,
        },
      }
    );
  }
  return {
    mode: "live",
    executionId,
    action: publicAction(action),
    target,
    response,
    requestHash,
    responseHash,
    receiptPath,
    remotelyVisible: true,
  };
}

function listActions(catalog, flags) {
  const actions = catalog.actions.filter((action) =>
    (flags.includeInternal || !action.controlPlane) &&
    (!flags.workflow || action.workflowIds.includes(flags.workflow)) &&
    (!flags.kind || action.kind === flags.kind)
  );
  return {total: actions.length, actions: actions.map(publicAction)};
}

function describeAction(catalog, actionId) {
  const action = requireAction(catalog, actionId);
  return {action: publicAction(action), example: action.example};
}

function describeWorkflow(catalog, workflowId) {
  const workflow = requireWorkflow(catalog, workflowId);
  return {
    workflow,
    actions: workflow.actions.map((actionId) =>
      publicAction(requireAction(catalog, actionId))),
  };
}

function validateWorkflowLoop(catalog, workflowId, flags) {
  const workflows = flags.all ? catalog.workflows : [
    requireWorkflow(catalog, workflowId),
  ];
  return {
    mode: "contract-loop",
    liveEffects: false,
    workflows: workflows.map((workflow) => ({
      workflowId: workflow.workflowId,
      label: workflow.label,
      guiPath: workflow.guiPath,
      blockedCapabilities: workflow.blockedCapabilities ?? [],
      steps: workflow.actions.map((actionId, index) => {
        const action = requireAction(catalog, actionId);
        catalog.validateRequest(actionId, action.example);
        return {
          step: index + 1,
          actionId,
          callable: action.callable,
          kind: action.kind,
          result: "schema-valid",
          requestHash: hashValue(action.example),
          confirmationRequired: action.confirmation ?? "none",
        };
      }),
    })),
  };
}

function assertConfirmation(action, target, flags) {
  if (action.kind !== "mutation") return;
  if (flags.confirm !== action.actionId) {
    throw new OperationsError(
      "ADMIN_ACTION_CONFIRMATION_REQUIRED",
      `Live mutation requires --confirm ${action.actionId}.`,
      {exitCode: 2}
    );
  }
  if (action.confirmation === "action-and-target" &&
      String(flags.confirmTarget ?? "") !== String(target ?? "")) {
    throw new OperationsError(
      "ADMIN_ACTION_TARGET_CONFIRMATION_REQUIRED",
      `Live mutation requires --confirm-target matching ${action.targetField}.`,
      {exitCode: 2, details: {targetField: action.targetField}}
    );
  }
}

async function readPayload(flags, action) {
  if (flags.input && flags.json) {
    throw new OperationsError(
      "ADMIN_CLI_INPUT_AMBIGUOUS",
      "Use only one of --input or --json.",
      {exitCode: 2}
    );
  }
  if (flags.input) {
    return JSON.parse(await fs.readFile(path.resolve(flags.input), "utf8"));
  }
  if (flags.json) return JSON.parse(flags.json);
  if (flags.example) return structuredClone(action.example);
  if (action.kind === "read") return {};
  throw new OperationsError(
    "ADMIN_CLI_INPUT_REQUIRED",
    "Mutation input is required through --input or --json.",
    {exitCode: 2}
  );
}

function liveClient(flags, dependencies) {
  const env = dependencies.env ?? process.env;
  return new FirebaseAdminCallableClient({
    baseUrl: callableBaseUrl({
      baseUrl: flags.baseUrl ?? env.CATCH_ADMIN_FUNCTIONS_BASE_URL,
      project: flags.project ?? env.CATCH_ADMIN_FIREBASE_PROJECT,
      region: flags.region ?? env.CATCH_ADMIN_FIREBASE_REGION,
    }),
    idToken: flags.idToken ?? env.CATCH_ADMIN_ID_TOKEN,
    appCheckToken: flags.appCheckToken ?? env.CATCH_ADMIN_APP_CHECK_TOKEN,
    timeoutMs: positiveInteger(flags.timeoutMs, 30_000, 1_000, 120_000),
    fetchImpl: dependencies.fetchImpl,
  });
}

async function recordRemote(client, payload) {
  await client.invoke("adminRecordActionExecution", payload, {
    executionId: payload.executionId,
  });
}

async function recordTerminalBestEffort(client, payload) {
  try {
    await recordRemote(client, payload);
    return true;
  } catch {
    // The primary callable failure remains authoritative; the local receipt
    // preserves the failed attempt when the remote receipt cannot advance.
    return false;
  }
}

function isIndeterminateCallableError(error) {
  return [
    "ADMIN_CALLABLE_TIMEOUT",
    "ADMIN_CALLABLE_NETWORK_ERROR",
    "ADMIN_CALLABLE_INVALID_RESPONSE",
  ].includes(error.code) || error.code.startsWith("ADMIN_CALLABLE_HTTP_");
}

function requireAction(catalog, actionId) {
  if (!actionId) {
    throw new OperationsError(
      "ADMIN_ACTION_REQUIRED",
      "An admin action id is required.",
      {exitCode: 2}
    );
  }
  const action = catalog.actionsById.get(actionId);
  if (!action) {
    throw new OperationsError(
      "ADMIN_ACTION_UNKNOWN",
      `Unknown admin action: ${actionId}.`,
      {exitCode: 2}
    );
  }
  return action;
}

function requireWorkflow(catalog, workflowId) {
  if (!workflowId) {
    throw new OperationsError(
      "ADMIN_WORKFLOW_REQUIRED",
      "An admin workflow id is required unless --all is used.",
      {exitCode: 2}
    );
  }
  const workflow = catalog.workflowsById.get(workflowId);
  if (!workflow) {
    throw new OperationsError(
      "ADMIN_WORKFLOW_UNKNOWN",
      `Unknown admin workflow: ${workflowId}.`,
      {exitCode: 2}
    );
  }
  return workflow;
}

function valueAt(value, key) {
  const result = value?.[key];
  return typeof result === "string" || typeof result === "number" ?
    String(result) : null;
}

function parseArguments(argv) {
  const values = [...argv];
  const command = values.shift() ?? "help";
  if (["help", "--help", "-h"].includes(command)) {
    return {command: "help", subject: null, flags: parseFlags(values)};
  }
  const takesSubject = new Set(["describe", "workflow", "loop", "run"]);
  const subject = takesSubject.has(command) && values[0] &&
      !values[0].startsWith("--") ? values.shift() : null;
  return {command, subject, flags: parseFlags(values)};
}

function parseFlags(argv) {
  const booleans = new Set([
    "--all", "--apply", "--dry-run", "--example", "--include-internal",
    "--pretty",
  ]);
  const values = new Set([
    "--app-check-token", "--base-url", "--confirm", "--confirm-target",
    "--execution-id", "--id-token", "--input", "--json", "--kind",
    "--project", "--receipt-dir", "--region", "--repo-root", "--timeout-ms",
    "--workflow",
  ]);
  const flags = {};
  for (let index = 0; index < argv.length; index += 1) {
    const flag = argv[index];
    if (booleans.has(flag)) flags[camel(flag)] = true;
    else if (values.has(flag)) {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) {
        throw new OperationsError(
          "ADMIN_CLI_ARGUMENT_INVALID",
          `${flag} requires a value.`,
          {exitCode: 2}
        );
      }
      flags[camel(flag)] = value;
      index += 1;
    } else {
      throw new OperationsError(
        "ADMIN_CLI_ARGUMENT_INVALID",
        `Unknown argument: ${flag}.`,
        {exitCode: 2}
      );
    }
  }
  if (flags.apply && flags.dryRun) {
    throw new OperationsError(
      "ADMIN_CLI_ARGUMENT_INVALID",
      "--apply and --dry-run cannot be combined.",
      {exitCode: 2}
    );
  }
  return flags;
}

function camel(flag) {
  return flag.slice(2).replace(/-([a-z])/gu, (_match, letter) =>
    letter.toUpperCase());
}

function positiveInteger(value, fallback, minimum, maximum) {
  if (value === undefined) return fallback;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < minimum || parsed > maximum) {
    throw new OperationsError(
      "ADMIN_CLI_ARGUMENT_INVALID",
      `Expected an integer between ${minimum} and ${maximum}.`,
      {exitCode: 2}
    );
  }
  return parsed;
}

function helpData() {
  return {
    usage: "node operations/src/admin-cli/main.mjs <command> [subject] [flags]",
    commands: ["actions", "describe", "workflows", "workflow", "loop", "run"],
    examples: [
      "node operations/src/admin-cli/main.mjs actions --workflow safety --pretty",
      "node operations/src/admin-cli/main.mjs describe safety.decide --pretty",
      "node operations/src/admin-cli/main.mjs loop --all --pretty",
      "node operations/src/admin-cli/main.mjs run overview.get --project <id>",
      "node operations/src/admin-cli/main.mjs run events.update --input payload.json --apply --confirm events.update --confirm-target <event-id>",
    ],
    safety: "Reads execute unless --dry-run is set. Mutations are dry-run unless --apply and the catalog confirmation policy are satisfied.",
    authentication: "Live calls require CATCH_ADMIN_ID_TOKEN and CATCH_ADMIN_APP_CHECK_TOKEN (or matching flags).",
  };
}

function isMain() {
  return process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
}
