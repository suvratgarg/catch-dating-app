import type {CallableOptions} from "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from "./callableOptions";

/** Keeps upload signing isolated from the shared runtime service account. */
export function appCheckCallableOptionsForFormUpload(
  limits: Parameters<typeof appCheckCallableOptionsWithLimits>[0]
): CallableOptions {
  return {
    ...appCheckCallableOptionsWithLimits(limits),
    // Firebase expands this shorthand using the selected deploy project.
    serviceAccount: "catch-form-upload@",
  };
}
