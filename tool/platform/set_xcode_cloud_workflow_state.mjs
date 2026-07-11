#!/usr/bin/env node

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const apiRoot = "https://api.appstoreconnect.apple.com/v1";

export function createAppStoreConnectToken({keyId, issuerId, privateKey, now = Date.now()}) {
  if (!keyId || !issuerId || !privateKey) throw new Error("App Store Connect JWT inputs are required");
  const issuedAt = Math.floor(now / 1000);
  const header = base64urlJson({alg: "ES256", kid: keyId, typ: "JWT"});
  const payload = base64urlJson({
    iss: issuerId,
    iat: issuedAt,
    exp: issuedAt + 1200,
    aud: "appstoreconnect-v1",
  });
  const unsigned = `${header}.${payload}`;
  const signature = crypto.sign("sha256", Buffer.from(unsigned), {
    key: privateKey,
    dsaEncoding: "ieee-p1363",
  }).toString("base64url");
  return `${unsigned}.${signature}`;
}

export function selectXcodeCloudWorkflow(workflows, workflowName) {
  const matches = workflows.filter((workflow) => workflow.attributes?.name === workflowName);
  if (matches.length !== 1) {
    throw new Error(`Expected one Xcode Cloud workflow named '${workflowName}'; found ${matches.length}`);
  }
  return matches[0];
}

export async function setXcodeCloudWorkflowState({
  appId,
  workflowName,
  enabled,
  token,
  fetchImpl = fetch,
  apply = false,
}) {
  const headers = {Authorization: `Bearer ${token}`, "Content-Type": "application/json"};
  const product = await requestJson(fetchImpl, `${apiRoot}/apps/${encodeURIComponent(appId)}/ciProduct`, {headers});
  const productId = product.data?.id;
  if (!productId) throw new Error(`App ${appId} does not have an Xcode Cloud product`);
  const response = await requestJson(
    fetchImpl,
    `${apiRoot}/ciProducts/${encodeURIComponent(productId)}/workflows?fields%5BciWorkflows%5D=name,isEnabled&limit=200`,
    {headers},
  );
  const workflow = selectXcodeCloudWorkflow(response.data ?? [], workflowName);
  const current = Boolean(workflow.attributes?.isEnabled);
  if (current === enabled || !apply) {
    return {appId, workflowId: workflow.id, workflowName, previousEnabled: current, enabled, changed: false};
  }
  const updated = await requestJson(fetchImpl, `${apiRoot}/ciWorkflows/${encodeURIComponent(workflow.id)}`, {
    method: "PATCH",
    headers,
    body: JSON.stringify({
      data: {
        type: "ciWorkflows",
        id: workflow.id,
        attributes: {isEnabled: enabled},
      },
    }),
  });
  if (updated.data?.id !== workflow.id || Boolean(updated.data?.attributes?.isEnabled) !== enabled) {
    throw new Error(
      `App Store Connect did not confirm Xcode Cloud workflow '${workflowName}' isEnabled=${enabled}`,
    );
  }
  return {appId, workflowId: workflow.id, workflowName, previousEnabled: current, enabled, changed: true};
}

async function requestJson(fetchImpl, url, options) {
  const response = await fetchImpl(url, options);
  const text = await response.text();
  const payload = text ? JSON.parse(text) : {};
  if (!response.ok) {
    const detail = payload.errors?.map((error) => error.detail).filter(Boolean).join("; ") || response.statusText;
    throw new Error(`App Store Connect API ${response.status}: ${detail}`);
  }
  return payload;
}

function base64urlJson(value) {
  return Buffer.from(JSON.stringify(value)).toString("base64url");
}

function parseArgs(argv) {
  const options = {};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (["--app-id", "--workflow-name", "--key-id", "--issuer-id", "--key-path"].includes(arg)) {
      const value = argv[index + 1];
      if (!value) throw new Error(`${arg} requires a value`);
      options[arg.slice(2).replaceAll("-", "_")] = value;
      index += 1;
    } else if (arg === "--enable") {
      options.enabled = true;
    } else if (arg === "--disable") {
      options.enabled = false;
    } else if (arg === "--apply") {
      options.apply = true;
    } else if (arg === "--allow-prod") {
      options.allow_prod = true;
    } else if (arg === "--help" || arg === "-h") {
      options.help = true;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return options;
}

function printHelp() {
  console.log(`Usage: node tool/platform/set_xcode_cloud_workflow_state.mjs \\
  --app-id <id> --workflow-name <name> --key-id <id> --issuer-id <id> \\
  --key-path <AuthKey.p8> <--enable|--disable> [--apply --allow-prod]`);
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      printHelp();
      process.exit(0);
    }
    for (const required of ["app_id", "workflow_name", "key_id", "issuer_id", "key_path"]) {
      if (!args[required]) throw new Error(`--${required.replaceAll("_", "-")} is required`);
    }
    if (args.enabled === undefined) throw new Error("Choose exactly one of --enable or --disable");
    if (args.apply && !args.allow_prod) throw new Error("Production changes require --allow-prod");
    const privateKey = fs.readFileSync(path.resolve(args.key_path), "utf8");
    const token = createAppStoreConnectToken({
      keyId: args.key_id,
      issuerId: args.issuer_id,
      privateKey,
    });
    const result = await setXcodeCloudWorkflowState({
      appId: args.app_id,
      workflowName: args.workflow_name,
      enabled: args.enabled,
      token,
      apply: args.apply,
    });
    console.log(JSON.stringify(result));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
