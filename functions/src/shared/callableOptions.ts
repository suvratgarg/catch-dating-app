import {CallableOptions} from "firebase-functions/v2/https";

/** Only the isolated demo suite may omit the live App Check service. */
export function enforceAppCheckForRuntime(env: NodeJS.ProcessEnv): boolean {
  return !(env.FUNCTIONS_EMULATOR === "true" &&
    env.GCLOUD_PROJECT === "demo-catch" &&
    env.FIREBASE_AUTH_EMULATOR_HOST === "127.0.0.1:9099" &&
    env.FIRESTORE_EMULATOR_HOST === "127.0.0.1:8080" &&
    env.FIREBASE_STORAGE_EMULATOR_HOST === "127.0.0.1:9199");
}

export const appCheckCallableOptions: CallableOptions = {
  enforceAppCheck: enforceAppCheckForRuntime(process.env),
  invoker: "public",
};

/** Applies narrow runtime ceilings without forking App Check/invoker policy. */
export function appCheckCallableOptionsWithLimits(
  limits: Pick<
    CallableOptions,
    "concurrency" | "maxInstances" | "memory" | "timeoutSeconds"
  >
): CallableOptions {
  return {
    ...appCheckCallableOptions,
    ...limits,
  };
}

/**
 * Adds Firebase Secret Manager bindings to the shared App Check callable
 * policy.
 * @param {Array} secrets Secret bindings.
 * @return {CallableOptions} Callable options with App Check and secrets.
 */
export function appCheckCallableOptionsWithSecrets(
  secrets: NonNullable<CallableOptions["secrets"]>,
  limits: Pick<
    CallableOptions,
    "concurrency" | "maxInstances" | "timeoutSeconds"
  > = {}
): CallableOptions {
  return {
    ...appCheckCallableOptions,
    ...limits,
    secrets,
  };
}
