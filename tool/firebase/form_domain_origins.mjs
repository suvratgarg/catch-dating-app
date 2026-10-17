import {hostingDomainTarget} from "./form_domain_hosting.mjs";
import {mergeUploadCors} from "./form_upload_identity.mjs";

const object = (value) => value !== null && typeof value === "object" && !Array.isArray(value);
const strings = (value) => Array.isArray(value) && value.every((item) => typeof item === "string");

export function formOriginTarget(input) {
  const hosting = hostingDomainTarget(input);
  if (typeof input.appId !== "string" || !new RegExp(`^1:${hosting.projectNumber}:web:[a-z0-9]+$`, "u").test(input.appId) ||
      typeof input.siteKey !== "string" || !/^[A-Za-z0-9_-]{20,200}$/u.test(input.siteKey) ||
      typeof input.bucket !== "string" || !/^[a-z0-9][a-z0-9.-]{1,220}[a-z0-9]$/u.test(input.bucket)) {
    throw new Error("Exact website app, Enterprise site key and upload bucket are required.");
  }
  return Object.freeze({...hosting, appId: input.appId, siteKey: input.siteKey,
    bucket: input.bucket, origin: `https://${hosting.hostname}`});
}

function urls(target) {
  return {
    auth: `https://identitytoolkit.googleapis.com/admin/v2/projects/${target.projectNumber}/config`,
    appCheck: `https://firebaseappcheck.googleapis.com/v1/projects/${target.projectNumber}/apps/${target.appId}/recaptchaEnterpriseConfig`,
    key: `https://recaptchaenterprise.googleapis.com/v1/projects/${target.projectNumber}/keys/${target.siteKey}`,
    bucket: `https://storage.googleapis.com/storage/v1/b/${target.bucket}`,
  };
}

async function requestData(request, method, url, data) {
  let response;
  try {
    response = await request({method, url, ...(data === undefined ? {} : {data}),
      responseType: "json", timeout: 30_000, maxRedirects: 0, retry: false,
      headers: {"Cache-Control": "no-cache"}});
  } catch {
    throw new Error(`Form origin ${method} failed; re-read status before retrying.`);
  }
  if (response?.status !== 200 || !object(response.data)) {
    throw new Error(`Form origin ${method} returned invalid metadata; re-read status before retrying.`);
  }
  return response.data;
}

function sameProjectName(target, name, suffix) {
  return [`projects/${target.projectNumber}/${suffix}`, `projects/${target.projectId}/${suffix}`].includes(name);
}

export function evaluateFormOrigins(input, state) {
  const target = formOriginTarget(input);
  if (!sameProjectName(target, state.auth?.name, "config") || !strings(state.auth?.authorizedDomains) ||
      !sameProjectName(target, state.appCheck?.name, `apps/${target.appId}/recaptchaEnterpriseConfig`) ||
      state.appCheck.siteKey !== target.siteKey ||
      !sameProjectName(target, state.key?.name, `keys/${target.siteKey}`) ||
      !object(state.key.webSettings) || state.key.webSettings.integrationType !== "SCORE" ||
      (state.key.webSettings.allowAllDomains != null && state.key.webSettings.allowAllDomains !== false) ||
      !strings(state.key.webSettings.allowedDomains) || state.key.webSettings.allowedDomains.length > 250 ||
      state.bucket?.name !== target.bucket || !/^[1-9][0-9]*$/u.test(state.bucket?.metageneration ?? "") ||
      (state.bucket.cors != null && (!Array.isArray(state.bucket.cors) || state.bucket.cors.some((rule) =>
        !object(rule) || !strings(rule.origin) || !strings(rule.method))))) {
    throw new Error("Unexpected website Auth/App Check/key/bucket configuration; refusing origin changes.");
  }
  const existingCors = state.bucket.cors ?? [];
  const cors = mergeUploadCors({origins: [target.origin]}, existingCors);
  const missing = [];
  if (!state.auth.authorizedDomains.includes(target.hostname)) missing.push("auth-domain");
  if (!state.key.webSettings.allowedDomains.includes(target.hostname)) missing.push("enterprise-domain");
  if (cors !== existingCors) missing.push("upload-cors");
  const ancestorGrants = state.key.webSettings.allowedDomains.filter((domain) =>
    target.hostname.endsWith(`.${domain.toLowerCase()}`));
  const wildcardCors = existingCors.some((rule) => rule.origin.includes("*"));
  return {ready: missing.length === 0, missing, ancestorGrants, wildcardCors};
}

export async function readFormOrigins(input, {request}) {
  const target = formOriginTarget(input);
  const endpoints = urls(target);
  const values = await Promise.all(Object.values(endpoints).map((url) => requestData(request, "GET", url)));
  const state = Object.fromEntries(Object.keys(endpoints).map((key, index) => [key, values[index]]));
  return {state, ...evaluateFormOrigins(target, state)};
}

function removeCorsOrigin(cors, origin) {
  return cors.flatMap((rule) => {
    if (!rule.origin.includes(origin)) return [rule];
    const remaining = rule.origin.filter((item) => item !== origin);
    return remaining.length ? [{...rule, origin: remaining}] : [];
  });
}

export async function reconcileFormOrigins(input, {request, apply = false, remove = false, assertBinding}) {
  const target = formOriginTarget(input);
  if (typeof apply !== "boolean" || typeof remove !== "boolean") throw new Error("Origin modes must be boolean.");
  if (apply && typeof assertBinding !== "function") throw new Error("A current registry binding check is required.");
  const before = await readFormOrigins(target, {request});
  if (!apply) return {...before, applied: false};
  if (!remove && before.missing.includes("enterprise-domain") &&
      before.state.key.webSettings.allowedDomains.length >= 250) {
    throw new Error("Enterprise domain capacity reached; no broader grant was made.");
  }
  const endpoints = urls(target);
  // Auth and Enterprise expose no etag: serialize operators and console edits.
  // Re-read each entire state before the next field-masked update, preserving
  // unrelated entries. This is not a compare-and-swap promise for those APIs.
  for (const owner of ["auth", "key", "bucket"]) {
    await assertBinding();
    const current = await readFormOrigins(target, {request});
    await assertBinding();
    const state = current.state;
    let data; let url;
    if (owner === "auth") {
      const old = state.auth.authorizedDomains;
      const next = remove ? old.filter((domain) => domain !== target.hostname) :
        old.includes(target.hostname) ? old : [...old, target.hostname];
      if (JSON.stringify(old) === JSON.stringify(next)) continue;
      data = {authorizedDomains: next};
      url = `${endpoints.auth}?updateMask=authorizedDomains`;
    } else if (owner === "key") {
      const old = state.key.webSettings.allowedDomains;
      const next = remove ? old.filter((domain) => domain !== target.hostname) :
        old.includes(target.hostname) ? old : [...old, target.hostname];
      if (JSON.stringify(old) === JSON.stringify(next)) continue;
      if (next.length > 250) throw new Error("Enterprise domain capacity reached; no broader grant was made.");
      data = {name: state.key.name, webSettings: {allowedDomains: next}};
      url = `${endpoints.key}?updateMask=webSettings.allowedDomains`;
    } else {
      const old = state.bucket.cors ?? [];
      const next = remove ? removeCorsOrigin(old, target.origin) : mergeUploadCors({origins: [target.origin]}, old);
      if (JSON.stringify(old) === JSON.stringify(next)) continue;
      data = {cors: next};
      url = `${endpoints.bucket}?ifMetagenerationMatch=${state.bucket.metageneration}`;
    }
    await requestData(request, "PATCH", url, data);
  }
  await assertBinding();
  const after = await readFormOrigins(target, {request});
  await assertBinding();
  const exactRemoved = !after.state.auth.authorizedDomains.includes(target.hostname) &&
    !after.state.key.webSettings.allowedDomains.includes(target.hostname) &&
    !(after.state.bucket.cors ?? []).some((rule) => rule.origin.includes(target.origin));
  if (!remove && !after.ready) throw new Error("Custom origin configuration is not ready after update.");
  if (remove && !exactRemoved) throw new Error("Exact custom-origin entries remain after removal.");
  return {...after, applied: true, ...(remove ? {exactRemoved,
    providerTrustRemoved: after.ancestorGrants.length === 0 && !after.wildcardCors} : {})};
}
