import {CallableOptions} from "firebase-functions/v2/https";

export const appCheckCallableOptions: CallableOptions = {
  enforceAppCheck: true,
  invoker: "public",
};

/**
 * Adds Firebase Secret Manager bindings to the shared App Check callable
 * policy.
 * @param {Array} secrets Secret bindings.
 * @return {CallableOptions} Callable options with App Check and secrets.
 */
export function appCheckCallableOptionsWithSecrets(
  secrets: NonNullable<CallableOptions["secrets"]>
): CallableOptions {
  return {
    ...appCheckCallableOptions,
    secrets,
  };
}
