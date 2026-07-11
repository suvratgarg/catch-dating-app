#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {resolveFirebaseProjectId} from "./firebase_project_resolver.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");

export function validateClientCallableDependencies({
  manifest,
  appRole,
  environment,
  envDefines,
  appConfigSource,
  functionTargets,
}) {
  if (manifest?.version !== 1 || !Array.isArray(manifest.dependencies)) {
    throw new Error("Client callable dependency manifest must use version 1.");
  }
  const matching = manifest.dependencies.filter(
    (entry) => entry.appRole === appRole && entry.environment === environment,
  );
  for (const entry of matching) {
    for (const field of ["id", "dartDefine", "callable", "region"]) {
      if (typeof entry[field] !== "string" || entry[field].trim() === "") {
        throw new Error(`Dependency entry is missing ${field}.`);
      }
    }
    const rawFlag = envDefines[entry.dartDefine];
    if (rawFlag !== "true" && rawFlag !== "false") {
      throw new Error(
        `${entry.dartDefine} must be the string "true" or "false" in ` +
          `${environment}.json.`,
      );
    }
    if (!appConfigSource.includes(`'${entry.dartDefine}'`) &&
        !appConfigSource.includes(`"${entry.dartDefine}"`)) {
      throw new Error(`${entry.dartDefine} is not declared in AppConfig.`);
    }
    if (!functionTargets.includes(`functions:${entry.callable}`)) {
      throw new Error(
        `${entry.callable} is not exported from functions/src/index.ts.`,
      );
    }
  }
  return matching.map((entry) => ({
    ...entry,
    enabled: envDefines[entry.dartDefine] === "true",
  }));
}

export async function probeCallable({
  projectId,
  region,
  callable,
  fetchImpl = fetch,
}) {
  const url = `https://${region}-${projectId}.cloudfunctions.net/${callable}`;
  const response = await fetchImpl(url, {
    method: "POST",
    redirect: "manual",
    headers: {"content-type": "application/json"},
    body: JSON.stringify({data: {}}),
  });
  if (response.status >= 300 && response.status < 400) {
    throw new Error(`${callable} returned an unexpected redirect.`);
  }
  const contentType = response.headers.get("content-type") ?? "";
  if (!contentType.includes("application/json")) {
    throw new Error(
      `${callable} did not return a Firebase callable JSON response ` +
        `(HTTP ${response.status}).`,
    );
  }
  let payload;
  try {
    payload = await response.json();
  } catch {
    throw new Error(`${callable} returned malformed JSON.`);
  }
  const status = payload?.error?.status;
  if (status !== "UNAUTHENTICATED" && status !== "FAILED_PRECONDITION") {
    throw new Error(
      `${callable} live probe failed (HTTP ${response.status}, ` +
        `status ${status ?? "missing"}).`,
    );
  }
  return {url, httpStatus: response.status, callableStatus: status};
}

function readJson(relativePath) {
  return JSON.parse(fs.readFileSync(path.join(repoRoot, relativePath), "utf8"));
}

function sourceFunctionTargets() {
  const source = fs.readFileSync(
    path.join(repoRoot, "functions/src/index.ts"),
    "utf8",
  );
  const names = [];
  for (const match of source.matchAll(/export\s*\{([\s\S]*?)\}\s*from\s*["']/g)) {
    for (const rawPart of match[1].split(",")) {
      const part = rawPart.trim();
      if (!part) continue;
      const alias = part.match(/\s+as\s+([A-Za-z_$][\w$]*)$/)?.[1];
      const name = alias ?? part.match(/^([A-Za-z_$][\w$]*)/)?.[1];
      if (name) names.push(`functions:${name}`);
    }
  }
  return names;
}

function parseArgs(argv) {
  const values = {};
  const flags = new Set();
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--verify-live") {
      flags.add(arg);
    } else if (arg.startsWith("--")) {
      values[arg.slice(2)] = argv[index + 1];
      index += 1;
    }
  }
  return {values, flags};
}

async function main() {
  const {values, flags} = parseArgs(process.argv.slice(2));
  const appRole = values.role;
  const environment = values.environment;
  if (!appRole || !environment) {
    throw new Error(
      "Usage: check_client_callable_dependencies.mjs " +
        "--role <consumer|host> --environment <dev|staging|prod> " +
        "[--verify-live] [--project <id>]",
    );
  }
  const dependencies = validateClientCallableDependencies({
    manifest: readJson("tool/firebase/client_callable_dependencies.json"),
    appRole,
    environment,
    envDefines: readJson(`tool/env/dart_defines/${environment}.json`),
    appConfigSource: fs.readFileSync(
      path.join(repoRoot, "lib/core/app_config.dart"),
      "utf8",
    ),
    functionTargets: sourceFunctionTargets(),
  });
  const enabled = dependencies.filter((entry) => entry.enabled);
  if (!flags.has("--verify-live") || enabled.length === 0) {
    for (const entry of dependencies) {
      process.stdout.write(
        `${entry.id}: ${entry.enabled ? "enabled (static check)" : "disabled"}\n`,
      );
    }
    return;
  }
  const projectId = values.project ?? resolveFirebaseProjectId({
    env: environment,
    firebaseRcPath: path.join(repoRoot, ".firebaserc"),
  });
  for (const entry of enabled) {
    const result = await probeCallable({
      projectId,
      region: entry.region,
      callable: entry.callable,
    });
    process.stdout.write(
      `${entry.id}: live (${result.httpStatus} ${result.callableStatus})\n`,
    );
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main().catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  });
}
