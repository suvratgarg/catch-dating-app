import fs from "node:fs";
import {fromRepo} from "./repo_paths.mjs";

export function readFirebaseProjectAliases(
  firebaseRcPath = fromRepo(".firebaserc")
) {
  const firebaserc = JSON.parse(fs.readFileSync(firebaseRcPath, "utf8"));
  return firebaserc.projects ?? {};
}

export function resolveFirebaseProjectId({
  env,
  project,
  defaultEnv = "dev",
  fallbackProjectId = "catchdates-dev",
  firebaseRcPath = fromRepo(".firebaserc"),
} = {}) {
  if (project) return project;

  if (env || defaultEnv) {
    const projects = readFirebaseProjectAliases(firebaseRcPath);
    const selectedEnv = env ?? defaultEnv;
    const resolved = projects[selectedEnv];
    if (!resolved) {
      throw new Error(`No Firebase project alias found for env: ${selectedEnv}`);
    }
    return resolved;
  }

  return process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    fallbackProjectId;
}

export function isFirebaseProductionTarget({
  env,
  projectId,
  project,
  firebaseRcPath = fromRepo(".firebaserc"),
} = {}) {
  const projects = readFirebaseProjectAliases(firebaseRcPath);
  const resolvedProjectId = projectId ?? project;
  return env === "prod" || resolvedProjectId === projects.prod;
}

export function applyFirestoreEmulatorHost(emulatorHost) {
  if (emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = emulatorHost;
  }
}

export function assertProdWriteAllowed({
  env,
  projectId,
  project,
  apply,
  allowProd,
  confirmProd,
  action,
} = {}) {
  if (!apply) return;
  const approved = allowProd || confirmProd;
  if (approved) return;
  if (!isFirebaseProductionTarget({env, projectId, project})) return;
  throw new Error(
    `Refusing to ${action ?? "write"} prod without --allow-prod or ` +
      "--confirm-prod. Run a dry run first, then rerun intentionally."
  );
}
