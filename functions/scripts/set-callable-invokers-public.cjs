const {execFileSync} = require("node:child_process");
const https = require("node:https");
const {GoogleAuth} = require("google-auth-library");

const region = "asia-south1";

function firebaseAccessToken() {
  const output = execFileSync("firebase", ["login:list", "--json"], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
  const payload = parseFirstJsonObject(output);
  const token = payload.result?.find((entry) => entry.tokens?.access_token)
    ?.tokens.access_token;
  if (!token) {
    throw new Error("Unable to read an access token from Firebase CLI auth.");
  }
  return token;
}

async function accessToken() {
  try {
    const client = await new GoogleAuth({
      scopes: ["https://www.googleapis.com/auth/cloud-platform"],
    }).getClient();
    const result = await client.getAccessToken();
    const token = typeof result === "string" ? result : result?.token;
    if (token) return token;
  } catch (error) {
    process.stderr.write(
      `ADC unavailable; falling back to Firebase CLI auth: ${error.message}\n`,
    );
  }
  return firebaseAccessToken();
}

function parseFirstJsonObject(text) {
  const start = text.indexOf("{");
  if (start === -1) throw new Error("Firebase CLI did not return JSON.");
  let depth = 0;
  let inString = false;
  let escaped = false;
  for (let index = start; index < text.length; index += 1) {
    const char = text[index];
    if (escaped) {
      escaped = false;
      continue;
    }
    if (char === "\\") {
      escaped = true;
      continue;
    }
    if (char === "\"") {
      inString = !inString;
      continue;
    }
    if (inString) continue;
    if (char === "{") depth += 1;
    if (char === "}") {
      depth -= 1;
      if (depth === 0) return JSON.parse(text.slice(start, index + 1));
    }
  }
  throw new Error("Firebase CLI JSON was incomplete.");
}

function requestJson({hostname, method, path, token, body}) {
  return new Promise((resolve, reject) => {
    const request = https.request({
      hostname,
      method,
      path,
      headers: {
        "Authorization": `Bearer ${token}`,
        "Content-Type": "application/json",
      },
    }, (response) => {
      let data = "";
      response.setEncoding("utf8");
      response.on("data", (chunk) => {
        data += chunk;
      });
      response.on("end", () => {
        if (response.statusCode < 200 || response.statusCode >= 300) {
          reject(new Error(
            `${method} ${hostname}${path} failed with ` +
              `${response.statusCode}: ${data}`,
          ));
          return;
        }
        resolve(data.length === 0 ? {} : JSON.parse(data));
      });
    });
    request.on("error", reject);
    if (body) request.write(JSON.stringify(body));
    request.end();
  });
}

async function listCallableServices({
  projectId,
  token,
  request = requestJson,
}) {
  const services = new Set();
  let pageToken = "";
  do {
    const query = new URLSearchParams({pageSize: "100"});
    if (pageToken) query.set("pageToken", pageToken);
    const payload = await request({
      hostname: "cloudfunctions.googleapis.com",
      method: "GET",
      path: `/v2/projects/${projectId}/locations/${region}/functions?${query}`,
      token,
    });
    for (const fn of payload.functions ?? []) {
      const callable = fn.labels?.["deployment-callable"];
      const service = fn.serviceConfig?.service;
      if ((callable === "true" || callable === true) &&
          typeof service === "string" && service.length > 0) {
        services.add(service);
      }
    }
    pageToken = payload.nextPageToken ?? "";
  } while (pageToken);
  return [...services].sort();
}

function cloudRunPolicyPath(service, action) {
  if (!/^projects\/[^/]+\/locations\/[^/]+\/services\/[^/]+$/.test(service)) {
    throw new Error(`Invalid Cloud Run service resource: ${service}`);
  }
  const resource = service;
  return `/v2/${resource}:${action}`;
}

async function ensurePublicInvoker({
  service,
  token,
  request = requestJson,
}) {
  const policy = await request({
    hostname: "run.googleapis.com",
    method: "GET",
    path:
      `${cloudRunPolicyPath(service, "getIamPolicy")}` +
      "?options.requestedPolicyVersion=3",
    token,
  });
  policy.bindings ??= [];
  let binding = policy.bindings.find(
    (entry) => entry.role === "roles/run.invoker",
  );
  if (!binding) {
    binding = {role: "roles/run.invoker", members: []};
    policy.bindings.push(binding);
  }
  binding.members ??= [];
  if (binding.members.includes("allUsers")) return false;
  binding.members.push("allUsers");
  binding.members.sort();
  await request({
    hostname: "run.googleapis.com",
    method: "POST",
    path: cloudRunPolicyPath(service, "setIamPolicy"),
    token,
    body: {policy},
  });
  return true;
}

async function syncProject({projectId, token, request = requestJson}) {
  const services = await listCallableServices({projectId, token, request});
  if (services.length === 0) {
    throw new Error(
      `No deployed callable Cloud Run services found in ${projectId}/${region}.`,
    );
  }
  for (const service of services) {
    const changed = await ensurePublicInvoker({service, token, request});
    process.stdout.write(
      `${projectId}/${service.split("/").at(-1)}: ` +
        `${changed ? "granted allUsers run.invoker" : "already public"}\n`,
    );
  }
}

async function main() {
  const projectIds = process.argv.slice(2);
  if (projectIds.length === 0) {
    throw new Error(
      "Usage: node scripts/set-callable-invokers-public.cjs " +
        "<project-id> [...]",
    );
  }
  const token = await accessToken();
  for (const projectId of projectIds) {
    await syncProject({projectId, token});
  }
}

module.exports = {
  cloudRunPolicyPath,
  ensurePublicInvoker,
  listCallableServices,
  parseFirstJsonObject,
  syncProject,
};

if (require.main === module) {
  main().catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  });
}
