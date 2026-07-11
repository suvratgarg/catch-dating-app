#!/usr/bin/env node

import path from "node:path";
import {fileURLToPath} from "node:url";

const apiRoot = "https://androidpublisher.googleapis.com/androidpublisher/v3";

export async function probeGooglePlayAccess({
  packageName,
  accessToken,
  track = "qa",
  fetchImpl = fetch,
}) {
  if (!packageName) throw new Error("packageName is required");
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
    await requestJson(
      fetchImpl,
      `${apiRoot}/applications/${encodedPackage}/edits/${encodeURIComponent(editId)}/tracks/${track}`,
      {headers},
    );
    return {packageName, track, editId, accessVerified: true, committed: false};
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

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  return index >= 0 ? args[index + 1] : null;
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const args = process.argv.slice(2);
    if (args.includes("--help") || args.includes("-h")) {
      console.log("Usage: node tool/platform/probe_google_play_access.mjs --package-name ID --track qa --apply --allow-prod");
      process.exit(0);
    }
    if (!args.includes("--apply") || !args.includes("--allow-prod")) {
      throw new Error("Play access probes require both --apply and --allow-prod");
    }
    const result = await probeGooglePlayAccess({
      packageName: valueAfter(args, "--package-name"),
      accessToken: process.env.GOOGLE_PLAY_ACCESS_TOKEN,
      track: valueAfter(args, "--track") || "qa",
    });
    console.log(JSON.stringify(result));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
