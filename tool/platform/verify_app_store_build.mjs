#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {createAppStoreConnectToken} from "./set_xcode_cloud_workflow_state.mjs";

const apiRoot = "https://api.appstoreconnect.apple.com/v1";

export function compareAppleBuildNumbers(left, right) {
  const leftParts = parseBuildNumber(left);
  const rightParts = parseBuildNumber(right);
  const length = Math.max(leftParts.length, rightParts.length);
  for (let index = 0; index < length; index += 1) {
    const leftPart = leftParts[index] ?? 0n;
    const rightPart = rightParts[index] ?? 0n;
    if (leftPart < rightPart) return -1;
    if (leftPart > rightPart) return 1;
  }
  return 0;
}

export function assertCandidateAboveBuilds(candidate, builds) {
  parseBuildNumber(candidate);
  if (candidate.length > 18) throw new Error("Apple build number exceeds 18 characters");
  const blockers = builds
    .map((build) => String(build.attributes?.version ?? ""))
    .filter(Boolean)
    .filter((existing) => compareAppleBuildNumbers(candidate, existing) <= 0);
  if (blockers.length > 0) {
    throw new Error(
      `Candidate Apple build ${candidate} is not above existing build(s): ${blockers.join(", ")}`,
    );
  }
  return {candidate, inspectedBuildCount: builds.length};
}

export async function listAppBuilds({appId, token, fetchImpl = fetch}) {
  const query = new URLSearchParams({
    "filter[app]": appId,
    "fields[builds]": "version,processingState,uploadedDate",
    sort: "-uploadedDate",
    limit: "200",
  });
  const response = await requestJson(fetchImpl, `${apiRoot}/builds?${query}`, token);
  return response.data ?? [];
}

export async function waitForProcessedBuild({
  appId,
  buildNumber,
  token,
  tokenProvider = async () => token,
  fetchImpl = fetch,
  sleepImpl = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds)),
  timeoutMs = 45 * 60 * 1000,
  pollMs = 30 * 1000,
}) {
  const startedAt = Date.now();
  while (Date.now() - startedAt <= timeoutMs) {
    const query = new URLSearchParams({
      "filter[app]": appId,
      "filter[version]": buildNumber,
      "fields[builds]": "version,processingState,uploadedDate",
      limit: "2",
    });
    const requestToken = await tokenProvider();
    if (!requestToken) throw new Error("App Store Connect token provider returned no token");
    const response = await requestJson(fetchImpl, `${apiRoot}/builds?${query}`, requestToken);
    const builds = response.data ?? [];
    if (builds.length > 1) {
      throw new Error(`App Store Connect returned multiple builds for ${appId}/${buildNumber}`);
    }
    const build = builds[0];
    const state = build?.attributes?.processingState;
    if (state === "VALID") {
      return {
        $schema: "catch.app-store-build-processing/v1",
        appId,
        buildId: build.id,
        buildNumber,
        processingState: state,
        uploadedDate: build.attributes?.uploadedDate ?? null,
      };
    }
    if (state && state !== "PROCESSING") {
      throw new Error(`App Store build ${appId}/${buildNumber} entered ${state}`);
    }
    await sleepImpl(pollMs);
  }
  throw new Error(`Timed out waiting for App Store build ${appId}/${buildNumber} to process`);
}

async function requestJson(fetchImpl, url, token) {
  const response = await fetchImpl(url, {headers: {Authorization: `Bearer ${token}`}});
  const text = await response.text();
  const payload = text ? JSON.parse(text) : {};
  if (!response.ok) {
    const detail = payload.errors?.map((error) => error.detail).filter(Boolean).join("; ") || response.statusText;
    throw new Error(`App Store Connect API ${response.status}: ${detail}`);
  }
  return payload;
}

function parseBuildNumber(value) {
  const source = String(value);
  if (!/^\d+(?:\.\d+){0,2}$/u.test(source)) {
    throw new Error(`Apple build number '${source}' is not numeric`);
  }
  return source.split(".").map((part) => BigInt(part));
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  return index >= 0 ? args[index + 1] : null;
}

function hasFlag(args, flag) {
  return args.includes(flag);
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const args = process.argv.slice(2);
    if (hasFlag(args, "--help") || hasFlag(args, "-h")) {
      console.log("Usage: node tool/platform/verify_app_store_build.mjs --app-id ID --build-number N --key-id ID --issuer-id ID --key-path PATH <--check-candidate|--wait-processed> [--receipt PATH]");
      process.exit(0);
    }
    const appId = valueAfter(args, "--app-id");
    const buildNumber = valueAfter(args, "--build-number");
    const keyId = valueAfter(args, "--key-id");
    const issuerId = valueAfter(args, "--issuer-id");
    const keyPath = valueAfter(args, "--key-path");
    if (![appId, buildNumber, keyId, issuerId, keyPath].every(Boolean)) {
      throw new Error("App id, build number, key id, issuer id, and key path are required");
    }
    const checkCandidate = hasFlag(args, "--check-candidate");
    const waitProcessed = hasFlag(args, "--wait-processed");
    if (checkCandidate === waitProcessed) throw new Error("Choose exactly one verification mode");
    const privateKey = fs.readFileSync(path.resolve(keyPath), "utf8");
    const tokenProvider = async () => createAppStoreConnectToken({keyId, issuerId, privateKey});
    const result = checkCandidate
      ? assertCandidateAboveBuilds(
          buildNumber,
          await listAppBuilds({appId, token: await tokenProvider()}),
        )
      : await waitForProcessedBuild({appId, buildNumber, tokenProvider});
    const githubRunId = valueAfter(args, "--github-run-id");
    if (waitProcessed && githubRunId) result.githubRunId = githubRunId;
    const receiptPath = valueAfter(args, "--receipt");
    if (receiptPath) {
      const resolved = path.resolve(receiptPath);
      fs.mkdirSync(path.dirname(resolved), {recursive: true});
      fs.writeFileSync(resolved, `${JSON.stringify(result, null, 2)}\n`);
    }
    console.log(JSON.stringify(result));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
