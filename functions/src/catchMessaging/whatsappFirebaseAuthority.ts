import type {Auth} from "firebase-admin/auth";
import type {GoogleAuth} from "google-auth-library";
import type {CatchAuthorityIdentity, CatchFirebaseObservation,
  CatchVerifiedSession} from "./whatsappAppAuthority";
import {catchEndpointHash} from "./whatsappReply";

const scope = "https://www.googleapis.com/auth/identitytoolkit";
const origin = "https://identitytoolkit.googleapis.com";
const fields = "users(localId,createdAt,validSince,disabled," +
  "customAttributes,phoneNumber,tenantId)";
const lifetimeMillis = 30000;
function deny(): never {
  throw new Error("Catch app authority unavailable.");
}
function record(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) deny();
  return value as Record<string, unknown>;
}
function integer(value: unknown): value is number {
  return typeof value === "number" && Number.isSafeInteger(value) && value >= 0;
}
function identity(value: CatchAuthorityIdentity): void {
  if (typeof value.projectId !== "string" ||
      !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(value.projectId) ||
      typeof value.uid !== "string" ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(value.uid)) deny();
}
function int64(value: unknown, scale: number): number {
  if (typeof value !== "string" || !/^(0|[1-9][0-9]{0,18})$/u.test(value)) {
    deny();
  }
  const result = Number(value) * scale;
  if (!integer(result)) deny();
  return result;
}

export interface CatchFirebaseLookupRequest {
  projectId: string;
  url: string;
  method: "POST";
  body: {localId: string[]};
  fields: string;
  timeoutMillis: number;
  signal: AbortSignal;
  redirect: "error";
  retry: false;
}
/** Server-owned injection; never populate from callable request JSON. */
export interface CatchFirebaseLookupTransport {
  getProjectId(): Promise<string>;
  lookup(request: CatchFirebaseLookupRequest): Promise<unknown>;
}

/** Lazy ADC: construction/import performs no credential lookup or network call.
 * Uses Google's fixed HTTPS origin, OAuth and a projected protected lookup.
 * No SDK private internals or rounded UserMetadata.creationTime are used.
 */
export function createCatchGoogleFirebaseLookupTransport():
CatchFirebaseLookupTransport {
  let authPromise: Promise<GoogleAuth> | undefined;
  const auth = () => {
    authPromise ??= import("google-auth-library").then(({GoogleAuth}) =>
      new GoogleAuth({scopes: [scope]}));
    return authPromise;
  };
  return {
    async getProjectId() {
      try {
        return await (await auth()).getProjectId();
      } catch {
        deny();
      }
    },
    async lookup(request) {
      try {
        identity({projectId: request.projectId, uid: request.body.localId[0]});
        const expectedUrl = origin + "/v1/projects/" + request.projectId +
          "/accounts:lookup";
        if (request.url !== expectedUrl || request.method !== "POST" ||
            request.body.localId.length !== 1 || request.fields !== fields ||
            request.timeoutMillis !== lifetimeMillis ||
            request.retry !== false ||
            request.redirect !== "error") deny();
        const google = await auth();
        if (await google.getProjectId() !== request.projectId) deny();
        const headers = await google.getRequestHeaders(expectedUrl);
        if (request.signal.aborted) deny();
        headers.set("Content-Type", "application/json");
        const url = new URL(expectedUrl);
        url.searchParams.set("fields", fields);
        // No fetch retry; every redirect is an error.
        const response = await fetch(url, {method: "POST", headers,
          body: JSON.stringify({localId: [request.body.localId[0]]}),
          redirect: "error",
          signal: request.signal});
        if (!response.ok) deny();
        return await response.json();
      } catch {
        deny();
      }
    },
  };
}

export interface CatchFirebaseAuthorityOptions {
  projectId: string;
  transport: CatchFirebaseLookupTransport;
  /** Project-default Admin Auth verifies signatures and revocation. */
  auth: Pick<Auth, "app" | "verifyIdToken"> & {tenantId?: string};
  now?: () => number;
}

/** Protected current-account read and authenticated session evidence.
 * Evidence is transient; tokens, raw claims and provider errors stay private.
 * These reads do not fence concurrent external Firebase account mutations.
 */
export function createCatchFirebaseAuthority(options:
CatchFirebaseAuthorityOptions): {
  observe(uid: string): Promise<CatchFirebaseObservation>;
  verifySession(uid: string, idToken: string): Promise<CatchVerifiedSession>;
} {
  const now = options.now ?? Date.now;
  const validate = (uid: string) => {
    identity({projectId: options.projectId, uid});
    if (options.auth.app.options.projectId !== options.projectId ||
        options.auth.tenantId !== undefined) deny();
  };
  const bounded = async <T>(operation: (signal: AbortSignal) => Promise<T>) => {
    const controller = new AbortController();
    let timer: ReturnType<typeof setTimeout> | undefined;
    try {
      return await Promise.race([operation(controller.signal),
        new Promise<never>((_resolve, reject) => {
          timer = setTimeout(() => {
            controller.abort();
            reject(new Error("Catch app authority unavailable."));
          }, lifetimeMillis);
        })]);
    } catch {
      deny();
    } finally {
      if (timer) clearTimeout(timer);
    }
  };
  return {
    async observe(uid) {
      try {
        validate(uid);
        const started = now();
        if (!integer(started)) deny();
        const response = await bounded(async (signal) => {
          if (await options.transport.getProjectId() !== options.projectId) {
            deny();
          }
          if (signal.aborted) deny();
          return options.transport.lookup({projectId: options.projectId,
            url: origin + "/v1/projects/" + options.projectId +
              "/accounts:lookup", method: "POST", body: {localId: [uid]},
            fields, timeoutMillis: lifetimeMillis, signal,
            redirect: "error", retry: false});
        });
        const completed = now();
        if (!integer(completed) || completed < started ||
            completed - started > lifetimeMillis) deny();
        const users = record(response).users;
        if (!Array.isArray(users) || users.length !== 1) deny();
        const user = record(users[0]);
        if (user.localId !== uid || user.tenantId !== undefined ||
            ("disabled" in user && user.disabled !== false)) deny();
        const creationTimeMillis = int64(user.createdAt, 1);
        // Identity Toolkit omits enabled/default fields. Like Admin UserRecord,
        // absent validSince means no revocation cutoff; zero is that sentinel,
        // not an invented account/session time. Present values stay strict.
        const tokensValidAfterMillis = "validSince" in user ?
          int64(user.validSince, 1000) : 0;
        if (creationTimeMillis > started || tokensValidAfterMillis > started) {
          deny();
        }
        let claims: Record<string, unknown> = {};
        if (user.customAttributes !== undefined) {
          if (typeof user.customAttributes !== "string" ||
              user.customAttributes.length > 1000) deny();
          claims = record(JSON.parse(user.customAttributes));
        }
        let endpointHash: string | null = null;
        if (user.phoneNumber !== undefined) {
          if (typeof user.phoneNumber !== "string" ||
              !/^\+[1-9][0-9]{6,14}$/u.test(user.phoneNumber)) deny();
          endpointHash = catchEndpointHash(user.phoneNumber);
        }
        return {projectId: options.projectId, uid, creationTimeMillis,
          observedAtMillis: started, disabled: false,
          relevantRoles: (["adminOwner", "support"] as const)
            .filter((role) => claims[role] === true),
          endpointHash, tokensValidAfterMillis};
      } catch {
        deny();
      }
    },
    async verifySession(uid, idToken) {
      try {
        validate(uid);
        if (typeof idToken !== "string" || !idToken ||
            idToken.length > 16384) deny();
        const token = record(await bounded(() =>
          options.auth.verifyIdToken(idToken, true)));
        const time = now();
        const firebase = record(token.firebase);
        const expectedIssuer = "https://securetoken.google.com/" +
          options.projectId;
        if (!integer(time) || token.aud !== options.projectId ||
            token.iss !== expectedIssuer ||
            token.uid !== uid || token.sub !== uid ||
            firebase.tenant !== undefined || token.tenant_id !== undefined ||
            !integer(token.auth_time) || !integer(token.iat) ||
            !integer(token.exp) ||
            !integer(token.auth_time * 1000) || !integer(token.iat * 1000) ||
            !integer(token.exp * 1000) || token.auth_time > token.iat ||
            token.iat * 1000 > time || token.exp * 1000 <= time ||
            token.exp <= token.iat) deny();
        return {projectId: options.projectId, uid,
          authTimeSeconds: token.auth_time, expiresAtSeconds: token.exp};
      } catch {
        deny();
      }
    },
  };
}
