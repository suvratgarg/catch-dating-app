#!/usr/bin/env node
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fromRepo} from "../lib/repo_paths.mjs";

const expectedExtensions = [
  "bq-host-clubs",
  "bq-host-event-invite-links",
  "bq-host-event-participations",
  "bq-host-events",
  "bq-host-matches",
  "bq-host-payments",
  "bq-host-reviews",
  "bq-host-saved-events",
];

const expectedTables = [
  "host_analytics_events",
  "mart_host_event_daily",
];

const expectedRawViews = [
  "clubs_raw_latest",
  "event_invite_links_raw_latest",
  "event_participations_raw_latest",
  "events_raw_latest",
  "matches_raw_latest",
  "payments_raw_latest",
  "reviews_raw_latest",
  "saved_events_raw_latest",
];

const expectedFunctions = [
  "getHostAnalytics",
  "adminGetHostAnalytics",
  "recordOrganizerAnalyticsEvent",
];

const defaultScheduleDisplayName = "Catch host analytics daily mart refresh";

const args = parseArgs(process.argv.slice(2));
const projectId = args.projectId ?? resolveProjectId(args.env);
const status = {
  projectId,
  dataset: "catch_analytics",
  location: args.location,
  scheduleDisplayName: args.scheduleDisplayName,
  checks: {},
  missing: [],
  warnings: [],
};

checkBigQueryDatasetAndTables();
checkScheduledQuery();
checkExtensions();
checkFunctions();

const ok = status.missing.length === 0;
if (args.json) {
  console.log(JSON.stringify({...status, ok}, null, 2));
} else {
  printHumanStatus(ok);
}

process.exit(ok ? 0 : 1);

function checkBigQueryDatasetAndTables() {
  const result = run("bq", [
    `--project_id=${projectId}`,
    "--format=json",
    "ls",
    status.dataset,
  ]);

  if (result.exitCode !== 0) {
    status.checks.bigQuery = {
      ok: false,
      datasetExists: false,
      tables: [],
      error: conciseError(result),
    };
    missing("bigquery.dataset", `Missing BigQuery dataset ${status.dataset}.`);
    return;
  }

  const parsed = parseJson(result.stdout, []);
  const tableIds = parsed
    .map((entry) => entry?.tableReference?.tableId)
    .filter((value) => typeof value === "string")
    .sort();
  const missingTables = expectedTables.filter((table) =>
    !tableIds.includes(table)
  );
  const missingRawViews = expectedRawViews.filter((view) =>
    !tableIds.includes(view)
  );

  status.checks.bigQuery = {
    ok: missingTables.length === 0 && missingRawViews.length === 0,
    datasetExists: true,
    tables: tableIds,
    missingTables,
    missingRawViews,
  };

  for (const table of missingTables) {
    missing("bigquery.table", `Missing BigQuery table ${status.dataset}.${table}.`);
  }
  for (const view of missingRawViews) {
    missing("bigquery.raw_view", `Missing Firestore export view ${status.dataset}.${view}.`);
  }
  if (missingTables.length === 0) {
    checkMartRows();
  }
}

function checkMartRows() {
  const result = run("bq", [
    `--project_id=${projectId}`,
    "--location",
    args.location,
    "--format=json",
    "query",
    "--use_legacy_sql=false",
    martStatusSql(),
  ]);

  if (result.exitCode !== 0) {
    status.checks.martRows = {
      ok: false,
      error: conciseError(result),
    };
    missing("bigquery.mart_query", "Unable to query host analytics mart rows.");
    return;
  }

  const parsed = parseJson(result.stdout, []);
  const row = parsed[0] ?? {};
  const rowCount = numberValue(row.row_count);
  const maxRefreshedAt = typeof row.max_refreshed_at === "string" ?
    row.max_refreshed_at :
    null;
  status.checks.martRows = {
    ok: rowCount > 0,
    rowCount,
    maxRefreshedAt,
  };

  if (rowCount <= 0) {
    missing(
      "bigquery.mart_rows",
      "Host analytics mart exists but has no rows yet.",
    );
  }
}

function martStatusSql() {
  return `
SELECT
  COUNT(1) AS row_count,
  CAST(MAX(refreshed_at) AS STRING) AS max_refreshed_at
FROM \`${projectId}.${status.dataset}.mart_host_event_daily\``;
}

function checkScheduledQuery() {
  const result = run("bq", [
    `--project_id=${projectId}`,
    "--format=json",
    "ls",
    "--transfer_config",
    `--transfer_location=${args.location}`,
  ]);

  if (result.exitCode !== 0) {
    status.checks.schedule = {
      ok: false,
      matches: [],
      error: conciseError(result),
    };
    missing("bigquery.schedule", "Unable to inspect BigQuery scheduled queries.");
    return;
  }

  const configs = parseJson(result.stdout, []);
  const matches = configs.filter((config) =>
    config?.displayName === args.scheduleDisplayName &&
    config?.dataSourceId === "scheduled_query"
  );
  const failedMatches = matches.filter((config) => config?.state === "FAILED");
  status.checks.schedule = {
    ok: matches.length === 1 && failedMatches.length === 0,
    matches: matches.map((config) => ({
      name: config.name ?? config.transferConfigName ?? null,
      displayName: config.displayName,
      state: config.state ?? null,
    })),
  };

  if (matches.length === 0) {
    missing(
      "bigquery.schedule",
      `Missing scheduled query ${args.scheduleDisplayName}.`,
    );
  } else if (matches.length > 1) {
    missing(
      "bigquery.schedule_duplicate",
      `Found ${matches.length} scheduled queries named ${args.scheduleDisplayName}.`,
    );
  } else if (failedMatches.length > 0) {
    missing(
      "bigquery.schedule_failed",
      `Scheduled query ${args.scheduleDisplayName} is in FAILED state.`,
    );
  }
}

function checkExtensions() {
  const result = run("firebase", [
    "ext:list",
    "--project",
    projectId,
    "--non-interactive",
  ]);

  if (result.exitCode !== 0) {
    status.checks.extensions = {
      ok: false,
      active: [],
      error: conciseError(result),
    };
    missing("firebase.extensions", "Unable to inspect Firebase extensions.");
    return;
  }

  const rows = result.stdout.split(/\r?\n/);
  const active = expectedExtensions.filter((instanceId) =>
    rows.some((row) => row.includes(instanceId) && row.includes("ACTIVE"))
  );
  const missingExtensions = expectedExtensions.filter((instanceId) =>
    !active.includes(instanceId)
  );

  status.checks.extensions = {
    ok: missingExtensions.length === 0,
    active,
    missing: missingExtensions,
  };

  for (const instanceId of missingExtensions) {
    missing("firebase.extension", `Missing active Firebase extension ${instanceId}.`);
  }
}

function checkFunctions() {
  const result = run("firebase", [
    "functions:list",
    "--project",
    projectId,
    "--json",
  ]);

  if (result.exitCode !== 0) {
    status.checks.functions = {
      ok: false,
      active: [],
      error: conciseError(result),
    };
    missing("firebase.functions", "Unable to inspect Firebase Functions.");
    return;
  }

  const parsed = parseJson(result.stdout, {result: []});
  const active = (parsed.result ?? [])
    .filter((fn) =>
      expectedFunctions.includes(fn?.id) &&
      fn?.state === "ACTIVE" &&
      fn?.region === "asia-south1"
    )
    .map((fn) => fn.id)
    .sort();
  const missingFunctions = expectedFunctions.filter((name) =>
    !active.includes(name)
  );

  status.checks.functions = {
    ok: missingFunctions.length === 0,
    active,
    missing: missingFunctions,
  };

  for (const name of missingFunctions) {
    missing("firebase.function", `Missing active asia-south1 Function ${name}.`);
  }
}

function run(command, commandArgs) {
  const result = spawnSync(command, commandArgs, {
    cwd: fromRepo("."),
    encoding: "utf8",
    env: {...process.env, NO_COLOR: "1", NO_UPDATE_NOTIFIER: "true"},
  });
  return {
    command: [command, ...commandArgs].join(" "),
    exitCode: result.status ?? 1,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
  };
}

function conciseError(result) {
  return (result.stderr || result.stdout || `exit ${result.exitCode}`)
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .slice(0, 3)
    .join(" ");
}

function numberValue(value) {
  if (typeof value === "number") return value;
  if (typeof value === "string") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : 0;
  }
  return 0;
}

function parseJson(text, fallback) {
  try {
    return text.trim() ? JSON.parse(text) : fallback;
  } catch (error) {
    status.warnings.push(`Unable to parse JSON: ${error.message}`);
    return fallback;
  }
}

function missing(id, detail) {
  status.missing.push({id, detail});
}

function resolveProjectId(env) {
  const rc = JSON.parse(fs.readFileSync(fromRepo(".firebaserc"), "utf8"));
  const projectId = rc.projects?.[env];
  if (!projectId) {
    console.error(`Firebase alias '${env}' is not configured in .firebaserc.`);
    process.exit(64);
  }
  return projectId;
}

function parseArgs(argv) {
  const parsed = {
    env: "prod",
    projectId: null,
    location: "asia-south1",
    scheduleDisplayName: defaultScheduleDisplayName,
    json: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--env") {
      parsed.env = requiredValue(argv, ++index, arg);
    } else if (arg === "--project-id") {
      parsed.projectId = requiredValue(argv, ++index, arg);
    } else if (arg === "--location") {
      parsed.location = requiredValue(argv, ++index, arg);
    } else if (arg === "--schedule-display-name") {
      parsed.scheduleDisplayName = requiredValue(argv, ++index, arg);
    } else if (arg === "--json") {
      parsed.json = true;
    } else if (arg === "--help" || arg === "-h") {
      printUsage();
      process.exit(0);
    } else {
      console.error(`Unknown argument: ${arg}`);
      printUsage();
      process.exit(64);
    }
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    console.error(`${flag} requires a value.`);
    process.exit(64);
  }
  return value;
}

function printUsage() {
  console.log(`Usage:
  node tool/analytics/host_analytics_live_status.mjs [options]

Options:
  --env <dev|staging|prod>       Firebase alias. Defaults to prod.
  --project-id <id>              Override the Firebase project id.
  --location <location>          BigQuery transfer location. Defaults to asia-south1.
  --schedule-display-name <name> Scheduled query display name.
  --json                         Print machine-readable status.
`);
}

function printHumanStatus(ok) {
  console.log(`Host analytics live status for ${projectId}: ${ok ? "ready" : "incomplete"}`);
  for (const item of status.missing) {
    console.log(`- ${item.detail}`);
  }
  if (status.missing.length === 0) {
    console.log("- BigQuery dataset, export views, scheduled refresh, extensions, and callables are present.");
  }
}
