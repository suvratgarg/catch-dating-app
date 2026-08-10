#!/usr/bin/env node

import path from "node:path";
import {fileURLToPath} from "node:url";

const apiRoot = "https://androidpublisher.googleapis.com/androidpublisher/v3";

export async function probeGooglePlayAccess({
  packageName,
  accessToken,
  track = "qa",
  requireGoogleGroupTesters = false,
  fetchImpl = fetch,
}) {
  if (!/^[A-Za-z0-9][A-Za-z0-9._]*$/u.test(packageName ?? "")) {
    throw new Error("packageName is invalid");
  }
  if (!accessToken) throw new Error("Google Play access token is required");
  if (track !== "qa") throw new Error("Play access probes are restricted to the qa track");
  const encodedPackage = encodeURIComponent(packageName);
  const headers = {Authorization: `Bearer ${accessToken}`};
  let editId;
  try {
    const edit = await requestJson(fetchImpl, `${apiRoot}/applications/${encodedPackage}/edits`, {
      method: "POST",
      headers: {...headers, "Content-Type": "application/json"},
      body: "{}",
    });
    editId = edit.id;
    if (!editId) throw new Error("Google Play did not return an edit id");
    const trackPayload = await requestJson(
      fetchImpl,
      `${apiRoot}/applications/${encodedPackage}/edits/${encodeURIComponent(editId)}/tracks/${track}`,
      {headers},
    );
    if (trackPayload.track !== track) {
      throw new Error(`Google Play returned the wrong track for ${packageName}`);
    }
    const testerPayload = await requestJson(
      fetchImpl,
      `${apiRoot}/applications/${encodedPackage}/edits/${encodeURIComponent(editId)}/testers/${track}`,
      {headers},
    );
    const rawGoogleGroups = testerPayload.googleGroups ?? [];
    if (!Array.isArray(rawGoogleGroups) || rawGoogleGroups.some(
      (value) => typeof value !== "string" ||
        !/^[^@\s]+@[^@\s]+\.[^@\s]+$/u.test(value),
    )) {
      throw new Error(`Google Play returned invalid ${track} tester groups for ${packageName}`);
    }
    const googleGroups = [...new Set(rawGoogleGroups)].sort();
    if (requireGoogleGroupTesters && googleGroups.length === 0) {
      throw new Error(
        `Google Play ${track} for ${packageName} has no machine-verifiable Google Group testers`,
      );
    }
    return {
      packageName,
      track,
      appRecordVerified: true,
      editAccessVerified: true,
      trackAccessVerified: true,
      testerAccessVerified: true,
      googleGroupTesterCount: googleGroups.length,
      committed: false,
    };
  } finally {
    if (editId) {
      const response = await fetchImpl(
        `${apiRoot}/applications/${encodedPackage}/edits/${encodeURIComponent(editId)}`,
        {method: "DELETE", headers},
      );
      if (!response.ok) {
        throw new Error(`Google Play edit cleanup failed with ${response.status}`);
      }
    }
  }
}

export async function probeGooglePlayFleetReadiness({
  packageNames,
  accessToken,
  track = "qa",
  requireGoogleGroupTesters = true,
  fetchImpl = fetch,
}) {
  if (!Array.isArray(packageNames) || packageNames.length === 0) {
    throw new Error("At least one Google Play package name is required");
  }
  const unique = [...new Set(packageNames)];
  if (unique.length !== packageNames.length) {
    throw new Error("Google Play package names must be unique");
  }
  const packages = [];
  for (const packageName of unique) {
    packages.push(await probeGooglePlayAccess({
      packageName,
      accessToken,
      track,
      requireGoogleGroupTesters,
      fetchImpl,
    }));
  }
  return {ready: true, track, packages};
}

async function requestJson(fetchImpl, url, options) {
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
    const detail = payload.error?.message || payload.message || payload.raw || response.statusText;
    throw new Error(`Google Play API ${response.status}: ${detail}`);
  }
  return payload;
}

function valuesAfter(args, flag) {
  const values = [];
  for (let index = 0; index < args.length; index += 1) {
    if (args[index] === flag) {
      const value = args[index + 1];
      if (!value || value.startsWith("--")) {
        throw new Error(`${flag} requires a value`);
      }
      values.push(value);
      index += 1;
    }
  }
  return values;
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const args = process.argv.slice(2);
    if (args.includes("--help") || args.includes("-h")) {
      console.log("Usage: node tool/platform/probe_google_play_access.mjs --package-name ID [--package-name ID ...] --track qa --require-google-group-testers --apply --allow-prod");
      process.exit(0);
    }
    if (!args.includes("--apply") || !args.includes("--allow-prod")) {
      throw new Error("Play access probes require both --apply and --allow-prod");
    }
    if (!args.includes("--require-google-group-testers")) {
      throw new Error("Play fleet readiness requires --require-google-group-testers");
    }
    const result = await probeGooglePlayFleetReadiness({
      packageNames: valuesAfter(args, "--package-name"),
      accessToken: process.env.GOOGLE_PLAY_ACCESS_TOKEN,
      track: valuesAfter(args, "--track")[0] || "qa",
      requireGoogleGroupTesters: true,
    });
    console.log(JSON.stringify(result));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
