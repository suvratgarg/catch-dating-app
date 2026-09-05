#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const {spawnSync} = require("node:child_process");
const {prepareFunctionsParamsForDeploy} = require("../../tool/firebase/prepare_functions_params_for_deploy.mjs");

const projectId = "demo-catch";
const emulatorPorts = {auth: 9099, functions: 5001, firestore: 8080, storage: 9199};

function prepareLocalEmulators(repoRoot, directory) {
  const source = path.join(repoRoot, "functions");
  if (!fs.existsSync(path.join(source, "lib/index.js")) || !fs.existsSync(path.join(source, "node_modules"))) {
    throw new Error("Install Functions dependencies and build Functions before starting emulators.");
  }
  const functionsRoot = path.join(directory, "functions");
  fs.mkdirSync(functionsRoot, {recursive: true});
  fs.cpSync(path.join(source, "lib"), path.join(functionsRoot, "lib"), {recursive: true});
  fs.copyFileSync(path.join(source, "package.json"), path.join(functionsRoot, "package.json"));
  fs.symlinkSync(path.join(source, "node_modules"), path.join(functionsRoot, "node_modules"), "dir");
  const readiness = JSON.parse(fs.readFileSync(path.join(repoRoot, "tool/firebase/environment_readiness.json"), "utf8"));
  const names = [...new Set(readiness.requirements.filter((entry) => entry.kind === "secret-version").map((entry) => entry.name))].sort();
  if (!names.length || names.some((name) => !/^[A-Z][A-Z0-9_]+$/.test(name))) throw new Error("Invalid local secret inventory.");
  const secrets = Object.fromEntries(names.map((name) => [name,
    name === "ORGANIZER_WHATSAPP_ACCESS_TOKENS" ? "{}" : "local-emulator-placeholder-never-a-live-secret",
  ]));
  fs.writeFileSync(path.join(functionsRoot, ".secret.local"), Object.entries(secrets).map(([name, value]) => `${name}=${value}\n`).join(""));
  prepareFunctionsParamsForDeploy({functionsDir: functionsRoot, projectId, environment: {}});
  const sourceConfig = JSON.parse(fs.readFileSync(path.join(repoRoot, "firebase.json"), "utf8"));
  const config = {
    functions: {source: "functions"},
    firestore: {rules: path.join(repoRoot, sourceConfig.firestore.rules), indexes: path.join(repoRoot, sourceConfig.firestore.indexes)},
    storage: {rules: path.join(repoRoot, sourceConfig.storage.rules)},
    emulators: {
      ...Object.fromEntries(Object.entries(emulatorPorts).map(([name, port]) => [name, {host: "127.0.0.1", port}])),
      ui: {enabled: true, host: "127.0.0.1", port: 4000},
      singleProjectMode: true,
    },
  };
  const configPath = path.join(directory, "firebase.json");
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  return {configPath, secrets};
}

function emulatorEnvironment(inherited, directory, secrets) {
  return {
    ...inherited, ...secrets,
    GCLOUD_PROJECT: projectId,
    GOOGLE_CLOUD_PROJECT: projectId,
    GOOGLE_CLOUD_QUOTA_PROJECT: projectId,
    // Prevent external Google API clients from finding the developer's ADC.
    GOOGLE_APPLICATION_CREDENTIALS: path.join(directory, "no-cloud-credentials.json"),
    META_WHATSAPP_ENABLED: "false",
  };
}

function run(args = process.argv.slice(2)) {
  if (args.length && (args.length !== 2 || args[0] !== "--exec" || !args[1])) {
    throw new Error("Usage: npm --prefix functions run serve [-- --exec '<local test command>']");
  }
  const repoRoot = path.resolve(__dirname, "../..");
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-local-emulators-"));
  try {
    const {configPath, secrets} = prepareLocalEmulators(repoRoot, directory);
    const command = args.length ? "emulators:exec" : "emulators:start";
    const firebaseArgs = [command, "--project", projectId, "--config", configPath,
      "--only", Object.keys(emulatorPorts).join(","), "--non-interactive"];
    if (args.length) firebaseArgs.push(args[1]);
    console.log(`Starting isolated ${projectId}: Auth, Functions, Firestore and Storage. External integrations use placeholders.`);
    const result = spawnSync("firebase", firebaseArgs, {
      cwd: repoRoot, stdio: "inherit", env: emulatorEnvironment(process.env, directory, secrets),
    });
    if (result.error) throw result.error;
    return result.status ?? 1;
  } finally {
    fs.rmSync(directory, {recursive: true, force: true});
  }
}

if (require.main === module) {
  try {process.exitCode = run();} catch (error) {console.error(error.message); process.exitCode = 1;}
}
module.exports = {prepareLocalEmulators, emulatorEnvironment};
