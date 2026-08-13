#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {createAppStoreConnectToken} from "./set_xcode_cloud_workflow_state.mjs";

const apiRoot = "https://api.appstoreconnect.apple.com/v1";
const resourceIdPattern = /^[A-Za-z0-9-]+$/u;
const decimalIdPattern = /^[1-9][0-9]*$/u;
const digestPattern = /^[0-9a-f]{64}$/u;
const buildNumberPattern = /^\d+(?:\.\d+){0,2}$/u;

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function assertResourceId(value, label) {
  assert(typeof value === "string" && resourceIdPattern.test(value), `${label} is invalid`);
  return value;
}

function assertDecimalId(value, label) {
  const normalized = String(value ?? "");
  assert(decimalIdPattern.test(normalized), `${label} is invalid`);
  return normalized;
}

function assertShortText(value, label) {
  assert(
    typeof value === "string" && value.length > 0 && value.length <= 300 &&
      !/[\r\n\0]/u.test(value),
    `${label} must be a short single-line string`,
  );
  return value;
}

async function requestJson(fetchImpl, url, token, options = {}) {
  const response = await fetchImpl(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${token}`,
      ...(options.body ? {"Content-Type": "application/json"} : {}),
      ...(options.headers ?? {}),
    },
  });
  const text = await response.text();
  const payload = text ? JSON.parse(text) : {};
  if (!response.ok) {
    const detail = payload.errors
      ?.map((error) => error.detail)
      .filter(Boolean)
      .join("; ") || response.statusText;
    throw new Error(`App Store Connect API ${response.status}: ${detail}`);
  }
  return payload;
}

async function requestAll(fetchImpl, url, token, label) {
  const data = [];
  const visited = new Set();
  let next = url;
  while (next) {
    assert(!visited.has(next), `${label} returned a pagination loop`);
    assert(visited.size < 20, `${label} exceeded 20 App Store Connect pages`);
    visited.add(next);
    const payload = await requestJson(fetchImpl, next, token);
    assert(Array.isArray(payload?.data), `${label} returned invalid data`);
    data.push(...payload.data);
    next = payload?.links?.next ?? null;
    if (next) {
      const parsed = new URL(next);
      assert(parsed.origin === apiRoot.replace("/v1", "") && parsed.pathname.startsWith("/v1/"),
        `${label} returned an invalid next link`);
    }
  }
  return data;
}

async function groupBuildIds({groupId, token, fetchImpl}) {
  const entries = await requestAll(
    fetchImpl,
    `${apiRoot}/betaGroups/${encodeURIComponent(groupId)}/relationships/builds?limit=200`,
    token,
    `Beta group ${groupId} builds`,
  );
  return entries.map((entry) => {
    assert(entry?.type === "builds", `Beta group ${groupId} returned a non-build linkage`);
    return assertResourceId(entry.id, "Beta group build id");
  });
}

async function groupTesterCount({groupId, token, fetchImpl}) {
  const testers = await requestAll(
    fetchImpl,
    `${apiRoot}/betaGroups/${encodeURIComponent(groupId)}/relationships/betaTesters?limit=200`,
    token,
    `Beta group ${groupId} testers`,
  );
  for (const entry of testers) {
    assert(entry?.type === "betaTesters", `Beta group ${groupId} returned a non-tester linkage`);
    assertResourceId(entry.id, "Beta tester id");
  }
  return testers.length;
}

export async function distributeTestFlightBuild({
  appId,
  buildId,
  buildNumber,
  releaseTarget,
  packageArtifactId,
  signedArtifactSha256,
  promotionRunId,
  promotionRunAttempt,
  token,
  fetchImpl = fetch,
  apply = false,
  now = () => new Date(),
}) {
  assertDecimalId(appId, "App Store Connect app id");
  assertResourceId(buildId, "App Store Connect build id");
  assert(buildNumberPattern.test(String(buildNumber)), "Apple build number is invalid");
  assert(String(buildNumber).length <= 18, "Apple build number exceeds 18 characters");
  assert(/^(consumer|host)-ios$/u.test(releaseTarget), "Release target must be an iOS target");
  assertDecimalId(packageArtifactId, "Package artifact id");
  assert(digestPattern.test(signedArtifactSha256), "Signed artifact SHA-256 is invalid");
  assertDecimalId(promotionRunId, "Promotion run id");
  assertDecimalId(promotionRunAttempt, "Promotion run attempt");
  assert(
    typeof token === "string" && token.length >= 20 && token.length <= 2000 &&
      !/[\s\0]/u.test(token),
    "App Store Connect token is invalid",
  );

  const buildPayload = await requestJson(
    fetchImpl,
    `${apiRoot}/builds/${encodeURIComponent(buildId)}?fields%5Bbuilds%5D=version%2CprocessingState`,
    token,
  );
  assert(buildPayload?.data?.type === "builds" && buildPayload.data.id === buildId,
    "App Store Connect did not return the exact build");
  assert(String(buildPayload.data.attributes?.version ?? "") === String(buildNumber),
    "App Store Connect build number does not match the exact package");
  assert(buildPayload.data.attributes?.processingState === "VALID",
    "Only a VALID App Store Connect build can be distributed");

  const appPayload = await requestJson(
    fetchImpl,
    `${apiRoot}/builds/${encodeURIComponent(buildId)}/relationships/app`,
    token,
  );
  assert(appPayload?.data?.type === "apps" && String(appPayload.data.id) === String(appId),
    "App Store Connect build belongs to a different app");

  const groups = await requestAll(
    fetchImpl,
    `${apiRoot}/apps/${encodeURIComponent(appId)}/betaGroups?` +
      "fields%5BbetaGroups%5D=name%2CisInternalGroup%2ChasAccessToAllBuilds&limit=200",
    token,
    `App ${appId} beta groups`,
  );
  const inspected = [];
  for (const group of groups) {
    assert(group?.type === "betaGroups", "App Store Connect returned a non-beta-group resource");
    const groupId = assertResourceId(group.id, "Beta group id");
    const name = assertShortText(group.attributes?.name, `Beta group ${groupId} name`);
    const isInternalGroup = group.attributes?.isInternalGroup === true;
    if (!isInternalGroup) continue;
    const testerCount = await groupTesterCount({groupId, token, fetchImpl});
    const buildIds = await groupBuildIds({groupId, token, fetchImpl});
    const hasAccessToAllBuilds = group.attributes?.hasAccessToAllBuilds === true;
    inspected.push({
      id: groupId,
      name,
      testerCount,
      hasAccessToAllBuilds,
      hadBuildAccess: hasAccessToAllBuilds || buildIds.includes(buildId),
    });
  }

  const selectedGroups = inspected
    .filter((group) => group.testerCount > 0)
    .sort((left, right) => left.name.localeCompare(right.name) || left.id.localeCompare(right.id));
  assert(selectedGroups.length > 0,
    `App ${appId} has no existing internal TestFlight group with testers`);

  const missingGroups = selectedGroups.filter((group) => !group.hadBuildAccess);
  if (apply && missingGroups.length > 0) {
    await requestJson(
      fetchImpl,
      `${apiRoot}/builds/${encodeURIComponent(buildId)}/relationships/betaGroups`,
      token,
      {
        method: "POST",
        body: JSON.stringify({
          data: missingGroups.map((group) => ({type: "betaGroups", id: group.id})),
        }),
      },
    );
  }

  const confirmedGroups = [];
  for (const group of selectedGroups) {
    const hasBuildAccess = group.hasAccessToAllBuilds
      ? true
      : apply
        ? (await groupBuildIds({groupId: group.id, token, fetchImpl})).includes(buildId)
      : group.hadBuildAccess;
    if (apply) {
      assert(hasBuildAccess,
        `App Store Connect did not confirm build ${buildId} in internal group ${group.id}`);
    }
    confirmedGroups.push({...group, hasBuildAccess});
  }

  return {
    $schema: "catch.testflight-internal-distribution/v1",
    createdAt: now().toISOString(),
    policy: "all-existing-internal-groups-with-testers",
    applied: apply,
    operation: missingGroups.length === 0
      ? "already-associated"
      : apply ? "associated" : "would-associate",
    releaseTarget,
    appId: String(appId),
    buildId,
    buildNumber: String(buildNumber),
    packageArtifactId: String(packageArtifactId),
    signedArtifactSha256,
    promotionRunId: String(promotionRunId),
    promotionRunAttempt: String(promotionRunAttempt),
    selectedGroupCount: confirmedGroups.length,
    groups: confirmedGroups,
  };
}

function parseArgs(argv) {
  const options = {};
  const valueFlags = new Set([
    "--app-id",
    "--build-id",
    "--build-number",
    "--release-target",
    "--package-artifact-id",
    "--signed-artifact-sha256",
    "--promotion-run-id",
    "--promotion-run-attempt",
    "--key-id",
    "--issuer-id",
    "--key-path",
    "--receipt",
  ]);
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (valueFlags.has(arg)) {
      const value = argv[index + 1];
      assert(value && !value.startsWith("--"), `${arg} requires a value`);
      const key = arg.slice(2).replaceAll("-", "_");
      assert(options[key] === undefined, `${arg} was supplied more than once`);
      options[key] = value;
      index += 1;
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
  console.log(`Usage: node tool/platform/distribute_testflight_build.mjs \\
  --app-id ID --build-id ID --build-number N --release-target TARGET \\
  --package-artifact-id ID --signed-artifact-sha256 SHA256 \\
  --promotion-run-id ID --promotion-run-attempt N \\
  --key-id ID --issuer-id ID --key-path PATH [--receipt PATH] \\
  [--apply --allow-prod]`);
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const options = parseArgs(process.argv.slice(2));
    if (options.help) {
      printHelp();
      process.exit(0);
    }
    for (const required of [
      "app_id", "build_id", "build_number", "release_target", "package_artifact_id",
      "signed_artifact_sha256", "promotion_run_id", "promotion_run_attempt",
      "key_id", "issuer_id", "key_path",
    ]) {
      assert(options[required], `--${required.replaceAll("_", "-")} is required`);
    }
    if (options.apply) {
      assert(options.allow_prod, "Production TestFlight distribution requires --allow-prod");
    } else {
      assert(!options.allow_prod, "--allow-prod is only valid with --apply");
    }
    const privateKey = fs.readFileSync(path.resolve(options.key_path), "utf8");
    const token = createAppStoreConnectToken({
      keyId: options.key_id,
      issuerId: options.issuer_id,
      privateKey,
    });
    const result = await distributeTestFlightBuild({
      appId: options.app_id,
      buildId: options.build_id,
      buildNumber: options.build_number,
      releaseTarget: options.release_target,
      packageArtifactId: options.package_artifact_id,
      signedArtifactSha256: options.signed_artifact_sha256,
      promotionRunId: options.promotion_run_id,
      promotionRunAttempt: options.promotion_run_attempt,
      token,
      apply: options.apply === true,
    });
    if (options.receipt) {
      const receiptPath = path.resolve(options.receipt);
      assert(!fs.existsSync(receiptPath), "Distribution receipt output already exists");
      fs.mkdirSync(path.dirname(receiptPath), {recursive: true, mode: 0o700});
      fs.writeFileSync(receiptPath, `${JSON.stringify(result, null, 2)}\n`, {
        encoding: "utf8",
        flag: "wx",
        mode: 0o600,
      });
    }
    console.log(JSON.stringify(result));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
