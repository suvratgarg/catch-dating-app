import assert from "node:assert/strict";
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
const site = "projects/catch-dating-app-64e51/sites/catch-dating-app-64e51";
export function liveVersionName(releases) {
  const release = releases.releases?.[0];
  assert.ok(release?.version?.name?.startsWith(`${site}/versions/`), "No concrete live Hosting version");
  assert.match(release.version.name.slice(`${site}/versions/`.length), /^[a-z0-9]+$/u);
  return release.version.name;
}
export function usesNextRuntime(version) {
  assert.equal(version.status, "FINALIZED", "Live Hosting version is not finalized");
  assert.ok(Array.isArray(version.config?.rewrites), "Live Hosting rewrites missing");
  return version.config.rewrites.some(rule => rule.run?.serviceId === "catch-website-next");
}
export async function readLiveHosting() {
  const token = spawnSync("gcloud", ["auth", "print-access-token"], {encoding: "utf8"});
  assert.equal(token.status, 0, "Cannot obtain OIDC-backed Hosting read token");
  async function get(path) {
    const response = await fetch(`https://firebasehosting.googleapis.com/v1beta1/${path}`, {
      headers: {Authorization: `Bearer ${token.stdout.trim()}`, "x-goog-user-project": "catch-dating-app-64e51"},
      signal: AbortSignal.timeout(20_000)});
    assert.equal(response.status, 200, `Hosting metadata read failed (${response.status})`); return response.json();
  }
  const releases = await get(`${site}/channels/live/releases?pageSize=1`);
  const version = await get(liveVersionName(releases)); usesNextRuntime(version);
  return {version, release: releases.releases[0]};
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const mode = process.argv[2], current = await readLiveHosting();
  if (mode === "legacy-guard") {
    const retired = usesNextRuntime(current.version);
    fs.appendFileSync(process.env.GITHUB_OUTPUT, `retired=${retired}\n`);
    console.log(retired ? "Next.js owns live Hosting; static marketing promotion is retired." : "Static marketing Hosting remains the serving runtime.");
  } else if (mode === "snapshot") {
    fs.writeFileSync("build/next-promote/rollback.json", JSON.stringify(current), {flag: "wx"});
    console.log(`Preserved rollback version ${current.version.name}`);
  } else if (mode === "assert-current") {
    const prior = JSON.parse(fs.readFileSync("build/next-promote/rollback.json", "utf8"));
    assert.equal(current.version.name, prior.version.name, "Live Hosting changed during preparation; do not overwrite it");
  } else if (mode === "verify-next") {
    assert.ok(usesNextRuntime(current.version));
    assert.match(process.env.EXPECTED_HOSTING_VERSION ?? "", /^[a-z0-9]+$/u);
    assert.equal(current.version.name, `${site}/versions/${process.env.EXPECTED_HOSTING_VERSION}`);
    fs.writeFileSync("build/next-promote/production-hosting.json", JSON.stringify(current));
  } else throw new Error("Expected legacy-guard, snapshot, assert-current or verify-next");
}
