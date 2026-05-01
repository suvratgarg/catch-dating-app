const {execFileSync} = require("node:child_process");
const https = require("node:https");

const region = "asia-south1";
const callableServices = [
  "blockuser",
  "cancelrunsignup",
  "createrazorpayorder",
  "joinrunwaitlist",
  "markrunattendance",
  "reportuser",
  "requestaccountdeletion",
  "signupforfreerun",
  "unblockuser",
  "verifyrazorpaypayment",
];

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

function parseFirstJsonObject(text) {
  const start = text.indexOf("{");
  if (start === -1) {
    throw new Error("Firebase CLI did not return JSON.");
  }

  let depth = 0;
  let inString = false;
  let escaped = false;
  for (let i = start; i < text.length; i += 1) {
    const char = text[i];
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
      if (depth === 0) {
        return JSON.parse(text.slice(start, i + 1));
      }
    }
  }

  throw new Error("Firebase CLI JSON was incomplete.");
}

function cloudRunRequest({method, projectId, service, action, token, body}) {
  const path = `/v2/projects/${projectId}/locations/${region}` +
    `/services/${service}:${action}`;

  return new Promise((resolve, reject) => {
    const request = https.request({
      hostname: "run.googleapis.com",
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
            `${method} ${path} failed with ${response.statusCode}: ${data}`,
          ));
          return;
        }
        resolve(data.length === 0 ? {} : JSON.parse(data));
      });
    });

    request.on("error", reject);
    if (body) {
      request.write(JSON.stringify(body));
    }
    request.end();
  });
}

async function ensurePublicInvoker({projectId, service, token}) {
  const policy = await cloudRunRequest({
    method: "GET",
    projectId,
    service,
    action: "getIamPolicy",
    token,
  });

  policy.bindings ??= [];
  let binding = policy.bindings.find((entry) => entry.role === "roles/run.invoker");
  if (!binding) {
    binding = {role: "roles/run.invoker", members: []};
    policy.bindings.push(binding);
  }

  if (binding.members.includes("allUsers")) {
    console.log(`${projectId}/${service}: already public`);
    return;
  }

  binding.members.push("allUsers");
  binding.members.sort();

  await cloudRunRequest({
    method: "POST",
    projectId,
    service,
    action: "setIamPolicy",
    token,
    body: {policy},
  });
  console.log(`${projectId}/${service}: granted allUsers run.invoker`);
}

async function main() {
  const projectIds = process.argv.slice(2);
  if (projectIds.length === 0) {
    throw new Error("Usage: node scripts/set-callable-invokers-public.cjs <project-id> [...]");
  }

  const token = firebaseAccessToken();
  for (const projectId of projectIds) {
    for (const service of callableServices) {
      await ensurePublicInvoker({projectId, service, token});
    }
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
