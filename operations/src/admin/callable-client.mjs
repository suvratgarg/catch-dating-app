import {OperationsError} from "../platform/errors.mjs";

export class FirebaseAdminCallableClient {
  constructor({
    baseUrl,
    idToken,
    appCheckToken,
    timeoutMs = 30_000,
    fetchImpl = globalThis.fetch,
  }) {
    if (!baseUrl) {
      throw new OperationsError(
        "ADMIN_CLI_CONFIGURATION_INVALID",
        "A Firebase callable base URL is required.",
        {exitCode: 2}
      );
    }
    if (!idToken) {
      throw new OperationsError(
        "ADMIN_CLI_AUTH_REQUIRED",
        "A Firebase ID token is required for live admin actions.",
        {exitCode: 2}
      );
    }
    if (!appCheckToken) {
      throw new OperationsError(
        "ADMIN_CLI_APP_CHECK_REQUIRED",
        "A Firebase App Check token is required for live admin actions.",
        {exitCode: 2}
      );
    }
    this.baseUrl = baseUrl.replace(/\/$/u, "");
    this.idToken = idToken;
    this.appCheckToken = appCheckToken;
    this.timeoutMs = timeoutMs;
    this.fetchImpl = fetchImpl;
  }

  async invoke(callable, payload, {executionId} = {}) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);
    let response;
    try {
      response = await this.fetchImpl(`${this.baseUrl}/${callable}`, {
        method: "POST",
        headers: {
          "authorization": `Bearer ${this.idToken}`,
          "content-type": "application/json",
          "x-firebase-appcheck": this.appCheckToken,
          ...(executionId ? {
            "x-catch-actor-type": "agent_cli",
            "x-catch-execution-id": executionId,
          } : {}),
        },
        body: JSON.stringify({data: payload}),
        signal: controller.signal,
      });
    } catch (error) {
      const timedOut = error?.name === "AbortError";
      throw new OperationsError(
        timedOut ? "ADMIN_CALLABLE_TIMEOUT" : "ADMIN_CALLABLE_NETWORK_ERROR",
        timedOut ?
          `Admin callable ${callable} timed out.` :
          `Admin callable ${callable} could not be reached.`,
        {cause: error}
      );
    } finally {
      clearTimeout(timeout);
    }
    let body;
    try {
      body = await response.json();
    } catch (error) {
      throw new OperationsError(
        "ADMIN_CALLABLE_INVALID_RESPONSE",
        `Admin callable ${callable} returned non-JSON output.`,
        {cause: error, details: {status: response.status}}
      );
    }
    if (!response.ok || body?.error) {
      const remote = body?.error ?? {};
      throw new OperationsError(
        normalizeRemoteCode(remote.status, response.status),
        typeof remote.message === "string" ?
          remote.message : `Admin callable ${callable} failed.`,
        {
          details: {
            callable,
            httpStatus: response.status,
            remoteStatus: remote.status ?? null,
          },
        }
      );
    }
    if (Object.hasOwn(body ?? {}, "result")) return body.result;
    if (Object.hasOwn(body ?? {}, "data")) return body.data;
    throw new OperationsError(
      "ADMIN_CALLABLE_INVALID_RESPONSE",
      `Admin callable ${callable} returned no result envelope.`,
      {details: {status: response.status}}
    );
  }
}

export function callableBaseUrl({baseUrl, project, region = "asia-south1"}) {
  if (baseUrl) return baseUrl;
  if (!project) {
    throw new OperationsError(
      "ADMIN_CLI_PROJECT_REQUIRED",
      "--project or CATCH_ADMIN_FIREBASE_PROJECT is required.",
      {exitCode: 2}
    );
  }
  if (!/^[a-z][a-z0-9-]{3,62}$/u.test(project)) {
    throw new OperationsError(
      "ADMIN_CLI_PROJECT_INVALID",
      "Firebase project id has an invalid format.",
      {exitCode: 2}
    );
  }
  if (!/^[a-z]+(?:-[a-z]+)+[0-9]$/u.test(region)) {
    throw new OperationsError(
      "ADMIN_CLI_REGION_INVALID",
      "Firebase region has an invalid format.",
      {exitCode: 2}
    );
  }
  return `https://${region}-${project}.cloudfunctions.net`;
}

function normalizeRemoteCode(status, httpStatus) {
  if (typeof status === "string" && status.length > 0) {
    return `ADMIN_CALLABLE_${status.toUpperCase().replace(/-/gu, "_")}`;
  }
  return `ADMIN_CALLABLE_HTTP_${httpStatus}`;
}
