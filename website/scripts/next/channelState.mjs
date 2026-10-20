import assert from "node:assert/strict";
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
const site = "projects/catch-dating-app-64e51/sites/catch-dating-app-64e51";

export function channelVersion(channel, channelId, service) {
  assert.ok(["next-candidate", "next-release"].includes(channelId));
  assert.equal(service, channelId === "next-candidate" ? "catch-website-next-preview" : "catch-website-next");
  assert.equal(channel.name, `${site}/channels/${channelId}`);
  const version = channel.release?.version;
  assert.match(version?.name ?? "", new RegExp(`^${site}/versions/[a-z0-9]+$`, "u"));
  assert.equal(version.status, "FINALIZED");
  assert.equal(channel.release.type, "DEPLOY");
  const run = version.config?.rewrites?.at(-1)?.run;
  assert.equal(version.config?.rewrites?.at(-1)?.glob, "**");
  assert.equal(run?.serviceId, service);
  assert.equal(run?.region, "asia-south1");
  assert.match(run?.tag ?? "", /^[a-z0-9-]+$/u, "Hosting must pin a concrete runtime tag");
  assert.match(channel.url ?? "", new RegExp(`^https://catch-dating-app-64e51--${channelId}-[a-z0-9-]+\\.web\\.app$`, "u"));
  return {channelId, version: version.name.split("/").at(-1), url: channel.url, release: channel.release};
}

export async function readChannel(channelId, service, {runCommand = spawnSync, fetchImpl = fetch} = {}) {
  assert.ok(["next-candidate", "next-release"].includes(channelId));
  const token = runCommand("gcloud", ["auth", "print-access-token"], {encoding: "utf8"});
  assert.equal(token.status, 0); assert.ok(token.stdout.trim());
  const response = await fetchImpl(`https://firebasehosting.googleapis.com/v1beta1/${site}/channels/${channelId}`, {
    headers: {Authorization: `Bearer ${token.stdout.trim()}`}, signal: AbortSignal.timeout(20_000)});
  assert.equal(response.status, 200, "Cannot read the deployed Hosting channel");
  return channelVersion(await response.json(), channelId, service);
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [mode, channelId, service, output] = process.argv.slice(2);
  assert.ok(["record", "verify"].includes(mode));
  const current = await readChannel(channelId, service);
  if (mode === "record") fs.writeFileSync(output, JSON.stringify(current), {flag: "wx"});
  else {
    const prior = JSON.parse(fs.readFileSync(output, "utf8"));
    assert.equal(current.version, prior.version, "Candidate Hosting version changed after acceptance");
    assert.equal(current.url, prior.url);
    assert.deepEqual(current.release.version.config, prior.release.version.config);
  }
  console.log(JSON.stringify({channel: channelId, version: current.version, url: current.url}));
}
