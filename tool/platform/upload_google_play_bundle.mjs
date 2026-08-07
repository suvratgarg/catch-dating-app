#!/usr/bin/env node

import {createHash} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const apiRoot = "https://androidpublisher.googleapis.com/androidpublisher/v3";
const uploadRoot = "https://androidpublisher.googleapis.com/upload/androidpublisher/v3";
const versionCodeRe = /^[1-9][0-9]*$/u;
const sha256Re = /^[0-9a-f]{64}$/u;

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function validateInputs({packageName, versionCode, sha256, accessToken, track}) {
  assert(typeof packageName === "string" &&
    /^[A-Za-z0-9][A-Za-z0-9._]*$/u.test(packageName),
  "Google Play package name is invalid");
  const expectedVersionCode = String(versionCode ?? "");
  assert(versionCodeRe.test(expectedVersionCode) &&
    Number(expectedVersionCode) <= 2_100_000_000,
  "Expected Google Play version code is invalid");
  assert(sha256Re.test(sha256 ?? ""), "Expected AAB SHA-256 is invalid");
  assert(accessToken, "Google Play access token is required");
  assert(track === "qa", "Google Play internal delivery is restricted to the qa track");
  return expectedVersionCode;
}

function readExactBundle(bundlePath, expectedSha256) {
  const resolved = path.resolve(bundlePath);
  const linkStat = fs.lstatSync(resolved);
  assert(linkStat.isFile() && !linkStat.isSymbolicLink(),
    "Android App Bundle must be a regular non-symlink file");
  const descriptor = fs.openSync(
    resolved,
    fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW ?? 0),
  );
  let bytes;
  try {
    const before = fs.fstatSync(descriptor, {bigint: true});
    assert(before.isFile(), "Android App Bundle must be a regular file");
    bytes = fs.readFileSync(descriptor);
    const after = fs.fstatSync(descriptor, {bigint: true});
    assert(
      before.dev === after.dev && before.ino === after.ino && before.size === after.size &&
        before.mtimeNs === after.mtimeNs,
      "Android App Bundle changed while it was being read",
    );
  } finally {
    fs.closeSync(descriptor);
  }
  const actualSha256 = createHash("sha256").update(bytes).digest("hex");
  assert(actualSha256 === expectedSha256,
    "Local Android App Bundle SHA-256 does not match the authority digest");
  return bytes;
}

async function requestJson(fetchImpl, url, options, label) {
  const response = await fetchImpl(url, options);
  const text = await response.text();
  let payload = {};
  if (text) {
    try {
      payload = JSON.parse(text);
    } catch {
      payload = {raw: text};
    }
  }
  if (!response.ok) {
    const detail = payload.error?.message || payload.message || payload.raw ||
      response.statusText;
    throw new Error(`${label} ${response.status}: ${detail}`);
  }
  return payload;
}

async function createEdit({packageName, accessToken, fetchImpl}) {
  const payload = await requestJson(
    fetchImpl,
    `${apiRoot}/applications/${encodeURIComponent(packageName)}/edits`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: "{}",
    },
    "Google Play edit creation",
  );
  const editId = String(payload.id ?? "");
  assert(/^[A-Za-z0-9._-]+$/u.test(editId), "Google Play returned an invalid edit id");
  return editId;
}

async function deleteEdit({packageName, editId, accessToken, fetchImpl}) {
  if (!editId) return;
  const response = await fetchImpl(
    `${apiRoot}/applications/${encodeURIComponent(packageName)}/edits/` +
      encodeURIComponent(editId),
    {method: "DELETE", headers: {Authorization: `Bearer ${accessToken}`}},
  );
  if (!response.ok && response.status !== 404) {
    throw new Error(`Google Play edit cleanup failed with ${response.status}`);
  }
}

function completedReleaseMatches(trackPayload, expectedVersionCode) {
  const releases = (trackPayload.releases ?? []).filter(
    (release) => (release.versionCodes ?? []).map(String).includes(expectedVersionCode),
  );
  const completed = releases.filter((release) => release.status === "completed");
  assert(completed.length <= 1,
    "Google Play qa contains duplicate completed releases for the expected version");
  if (completed.length === 1) {
    assert(releases.length === 1,
      "Google Play qa contains conflicting release states for the expected version");
    return true;
  }
  return false;
}

function newerTrackVersionCodes(trackPayload, expectedVersionCode) {
  return (trackPayload.releases ?? []).flatMap(
    (release) => (release.versionCodes ?? []).map(String),
  ).filter((value) => versionCodeRe.test(value))
    .filter((value) => BigInt(value) > BigInt(expectedVersionCode));
}

async function readEditState({packageName, editId, accessToken, track, fetchImpl}) {
  const encodedPackage = encodeURIComponent(packageName);
  const encodedEdit = encodeURIComponent(editId);
  const headers = {Authorization: `Bearer ${accessToken}`};
  const trackPayload = await requestJson(
    fetchImpl,
    `${apiRoot}/applications/${encodedPackage}/edits/${encodedEdit}/tracks/` +
      encodeURIComponent(track),
    {headers},
    "Google Play track read",
  );
  const bundlePayload = await requestJson(
    fetchImpl,
    `${apiRoot}/applications/${encodedPackage}/edits/${encodedEdit}/bundles`,
    {headers},
    "Google Play bundle read",
  );
  return {trackPayload, bundles: bundlePayload.bundles ?? []};
}

function classifyState(state, expectedVersionCode, expectedSha256) {
  const bundles = state.bundles.filter(
    (bundle) => String(bundle.versionCode ?? "") === expectedVersionCode,
  );
  assert(bundles.length <= 1,
    "Google Play returned duplicate bundles for the expected version code");
  if (bundles.length === 1) {
    const remoteSha256 = String(bundles[0].sha256 ?? "").toLowerCase();
    assert(remoteSha256 === expectedSha256,
      `Google Play version ${expectedVersionCode} is bound to different AAB bytes`);
  }
  const completed = completedReleaseMatches(state.trackPayload, expectedVersionCode);
  assert(!completed || bundles.length === 1,
    "Google Play qa references a completed version missing from bundle inventory");
  const newer = newerTrackVersionCodes(state.trackPayload, expectedVersionCode);
  assert(newer.length === 0,
    `Google Play qa contains newer version code(s): ${newer.join(", ")}`);
  if (completed) return "already-promoted";
  if (bundles.length === 1) return "resume-required";
  return "upload-required";
}

export async function preflightGooglePlayBundle({
  packageName,
  versionCode,
  sha256,
  accessToken,
  track = "qa",
  fetchImpl = fetch,
}) {
  const expectedVersionCode = validateInputs({
    packageName,
    versionCode,
    sha256,
    accessToken,
    track,
  });
  const editId = await createEdit({packageName, accessToken, fetchImpl});
  try {
    const state = await readEditState({
      packageName,
      editId,
      accessToken,
      track,
      fetchImpl,
    });
    return {
      action: classifyState(state, expectedVersionCode, sha256),
      packageName,
      track,
      versionCode: expectedVersionCode,
      sha256,
    };
  } finally {
    await deleteEdit({packageName, editId, accessToken, fetchImpl});
  }
}

export async function uploadGooglePlayBundle({
  packageName,
  bundlePath,
  versionCode,
  sha256,
  accessToken,
  track = "qa",
  releaseName,
  fetchImpl = fetch,
}) {
  const expectedVersionCode = validateInputs({
    packageName,
    versionCode,
    sha256,
    accessToken,
    track,
  });
  const bundleBytes = readExactBundle(bundlePath, sha256);

  const encodedPackage = encodeURIComponent(packageName);
  const headers = {Authorization: `Bearer ${accessToken}`};
  let editId;
  let verificationEditId;
  let committed = false;
  try {
    editId = await createEdit({packageName, accessToken, fetchImpl});
    const initial = await readEditState({
      packageName,
      editId,
      accessToken,
      track,
      fetchImpl,
    });
    const preflight = classifyState(initial, expectedVersionCode, sha256);
    if (preflight === "already-promoted") {
      return {
        operation: "already-promoted",
        packageName,
        track,
        versionCode: expectedVersionCode,
        sha256,
      };
    }

    let operation = "resumed";
    if (preflight === "upload-required") {
      const upload = await requestJson(
        fetchImpl,
        `${uploadRoot}/applications/${encodedPackage}/edits/` +
          `${encodeURIComponent(editId)}/bundles?uploadType=media`,
        {
          method: "POST",
          headers: {...headers, "Content-Type": "application/octet-stream"},
          body: bundleBytes,
        },
        "Google Play bundle upload",
      );
      const returnedVersionCode = String(upload.versionCode ?? "");
      const returnedSha256 = String(upload.sha256 ?? "").toLowerCase();
      assert(returnedVersionCode === expectedVersionCode,
        `Google Play returned version code ${returnedVersionCode}; ` +
        `expected ${expectedVersionCode}. Refusing track mutation.`);
      assert(returnedSha256 === sha256,
        "Google Play upload response SHA-256 does not match the authority AAB digest");
      operation = "uploaded";
    }

    const trackPayload = await requestJson(
      fetchImpl,
      `${apiRoot}/applications/${encodedPackage}/edits/` +
        `${encodeURIComponent(editId)}/tracks/${encodeURIComponent(track)}`,
      {
        method: "PUT",
        headers: {...headers, "Content-Type": "application/json"},
        body: JSON.stringify({
          track,
          releases: [{
            name: releaseName || `GitHub exact ${expectedVersionCode}`,
            versionCodes: [expectedVersionCode],
            status: "completed",
          }],
        }),
      },
      "Google Play track update",
    );
    assert(trackPayload.track === track &&
      completedReleaseMatches(trackPayload, expectedVersionCode),
    "Google Play track update did not echo one completed exact qa release");
    assert(newerTrackVersionCodes(trackPayload, expectedVersionCode).length === 0,
      "Google Play track update retained a newer qa version; refusing commit");
    await requestJson(
      fetchImpl,
      `${apiRoot}/applications/${encodedPackage}/edits/` +
        `${encodeURIComponent(editId)}:commit?changesInReviewBehavior=ERROR_IF_IN_REVIEW`,
      {method: "POST", headers},
      "Google Play edit commit",
    );
    committed = true;

    verificationEditId = await createEdit({packageName, accessToken, fetchImpl});
    const verified = await readEditState({
      packageName,
      editId: verificationEditId,
      accessToken,
      track,
      fetchImpl,
    });
    assert(classifyState(verified, expectedVersionCode, sha256) === "already-promoted",
      "Google Play post-commit readback lacks the exact completed qa AAB");
    return {
      operation,
      packageName,
      track,
      versionCode: expectedVersionCode,
      sha256,
    };
  } finally {
    if (verificationEditId) {
      await deleteEdit({
        packageName,
        editId: verificationEditId,
        accessToken,
        fetchImpl,
      }).catch(() => {});
    }
    if (editId && !committed) {
      await deleteEdit({packageName, editId, accessToken, fetchImpl}).catch(() => {});
    }
  }
}

function parseArgs(argv) {
  const options = {track: "qa"};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if ([
      "--package-name",
      "--bundle",
      "--track",
      "--release-name",
      "--expected-version-code",
      "--expected-sha256",
    ].includes(arg)) {
      const value = argv[index + 1];
      if (!value) throw new Error(`${arg} requires a value`);
      options[arg.slice(2).replaceAll("-", "_")] = value;
      index += 1;
    } else if (arg === "--preflight") {
      options.preflight = true;
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
  console.log(`Usage: node tool/platform/upload_google_play_bundle.mjs \\
  --package-name <id> --expected-version-code <code> \\
  --expected-sha256 <hex> --track qa \\
  (--preflight | --bundle <app.aab> --apply --allow-prod)

Requires GOOGLE_PLAY_ACCESS_TOKEN. Production-track publishing is unsupported.`);
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      printHelp();
      process.exit(0);
    }
    if (!args.allow_prod) throw new Error("Play operations require --allow-prod");
    if (args.preflight === Boolean(args.apply)) {
      throw new Error("Choose exactly one of --preflight or --apply");
    }
    for (const required of ["package_name", "expected_version_code", "expected_sha256"]) {
      if (!args[required]) throw new Error(`Missing required option ${required}`);
    }
    const common = {
      packageName: args.package_name,
      versionCode: args.expected_version_code,
      sha256: args.expected_sha256,
      accessToken: process.env.GOOGLE_PLAY_ACCESS_TOKEN,
      track: args.track,
    };
    const result = args.preflight
      ? await preflightGooglePlayBundle(common)
      : await uploadGooglePlayBundle({
          ...common,
          bundlePath: args.bundle,
          releaseName: args.release_name,
        });
    console.log(JSON.stringify({ok: true, result}));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
