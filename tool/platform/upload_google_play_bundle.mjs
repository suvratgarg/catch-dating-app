#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const apiRoot = "https://androidpublisher.googleapis.com/androidpublisher/v3";
const uploadRoot = "https://androidpublisher.googleapis.com/upload/androidpublisher/v3";

export async function uploadGooglePlayBundle({
  packageName,
  bundlePath,
  accessToken,
  track = "qa",
  releaseName,
  fetchImpl = fetch,
}) {
  if (!packageName) throw new Error("packageName is required");
  if (!accessToken) throw new Error("Google Play access token is required");
  if (track === "production") throw new Error("This tool cannot publish to the production track");
  if (track !== "qa") throw new Error(`Unsupported Play track '${track}'; use qa for internal testing`);
  if (!fs.existsSync(bundlePath)) throw new Error(`Android App Bundle does not exist: ${bundlePath}`);

  const encodedPackage = encodeURIComponent(packageName);
  const authHeaders = {Authorization: `Bearer ${accessToken}`};
  let editId;
  try {
    const edit = await requestJson(fetchImpl, `${apiRoot}/applications/${encodedPackage}/edits`, {
      method: "POST",
      headers: {...authHeaders, "Content-Type": "application/json"},
      body: "{}",
    });
    editId = edit.id;
    if (!editId) throw new Error("Google Play did not return an edit id");

    const bundle = await requestJson(
      fetchImpl,
      `${uploadRoot}/applications/${encodedPackage}/edits/${encodeURIComponent(editId)}/bundles?uploadType=media`,
      {
        method: "POST",
        headers: {...authHeaders, "Content-Type": "application/octet-stream"},
        body: fs.readFileSync(bundlePath),
      },
    );
    const versionCode = String(bundle.versionCode ?? "");
    if (!/^\d+$/u.test(versionCode)) {
      throw new Error(`Google Play returned invalid version code '${versionCode}'`);
    }

    await requestJson(
      fetchImpl,
      `${apiRoot}/applications/${encodedPackage}/edits/${encodeURIComponent(editId)}/tracks/${encodeURIComponent(track)}`,
      {
        method: "PUT",
        headers: {...authHeaders, "Content-Type": "application/json"},
        body: JSON.stringify({
          track,
          releases: [{
            name: releaseName || `GitHub internal ${versionCode}`,
            versionCodes: [versionCode],
            status: "completed",
          }],
        }),
      },
    );

    await requestJson(
      fetchImpl,
      `${apiRoot}/applications/${encodedPackage}/edits/${encodeURIComponent(editId)}:commit?changesInReviewBehavior=ERROR_IF_IN_REVIEW`,
      {
        method: "POST",
        headers: authHeaders,
      },
    );
    return {packageName, track, versionCode, editId};
  } catch (error) {
    if (editId) {
      await fetchImpl(
        `${apiRoot}/applications/${encodedPackage}/edits/${encodeURIComponent(editId)}`,
        {method: "DELETE", headers: authHeaders},
      ).catch(() => {});
    }
    throw error;
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

function parseArgs(argv) {
  const options = {track: "qa"};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (["--package-name", "--bundle", "--track", "--release-name"].includes(arg)) {
      const value = argv[index + 1];
      if (!value) throw new Error(`${arg} requires a value`);
      options[arg.slice(2).replaceAll("-", "_")] = value;
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
  console.log(`Usage: node tool/platform/upload_google_play_bundle.mjs \\
  --package-name <id> --bundle <app.aab> [--track qa] \\
  --apply --allow-prod

Requires GOOGLE_PLAY_ACCESS_TOKEN. Production-track publishing is intentionally unsupported.`);
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      printHelp();
      process.exit(0);
    }
    if (!args.apply || !args.allow_prod) {
      throw new Error("Play uploads require both --apply and --allow-prod");
    }
    for (const required of ["package_name", "bundle"]) {
      if (!args[required]) throw new Error(`--${required.replaceAll("_", "-")} is required`);
    }
    const result = await uploadGooglePlayBundle({
      packageName: args.package_name,
      bundlePath: path.resolve(args.bundle),
      accessToken: process.env.GOOGLE_PLAY_ACCESS_TOKEN,
      track: args.track,
      releaseName: args.release_name,
    });
    console.log(`Uploaded ${result.packageName} version ${result.versionCode} to Play ${result.track}.`);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
