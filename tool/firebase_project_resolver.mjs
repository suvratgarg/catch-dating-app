import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");

export function resolveFirebaseProjectId({
  env,
  project,
  defaultEnv = "dev",
  firebaseRcPath = path.join(repoRoot, ".firebaserc"),
} = {}) {
  if (project) return project;

  const projects = readFirebaseProjectAliases(firebaseRcPath);
  const selectedEnv = env ?? defaultEnv;
  const resolved = projects[selectedEnv];
  if (!resolved) {
    throw new Error(`No Firebase project alias found for env: ${selectedEnv}`);
  }
  return resolved;
}

export function isFirebaseProductionTarget({
  env,
  projectId,
  project,
  firebaseRcPath = path.join(repoRoot, ".firebaserc"),
} = {}) {
  const projects = readFirebaseProjectAliases(firebaseRcPath);
  const resolvedProjectId = projectId ?? project;
  return env === "prod" || resolvedProjectId === projects.prod;
}

export function readFirebaseProjectAliases(firebaseRcPath) {
  const firebaserc = JSON.parse(fs.readFileSync(firebaseRcPath, "utf8"));
  return firebaserc.projects ?? {};
}
