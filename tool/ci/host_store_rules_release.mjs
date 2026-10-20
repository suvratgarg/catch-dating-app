#!/usr/bin/env node
// Fixed PR592 rules recovery. No Functions, index, Storage, IAM or cursor writes.
import assert from "node:assert/strict";
import fs from "node:fs";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {normalizeRulesContent} from "../firebase/check_rules_deployment_drift.mjs";

export const RELEASE = Object.freeze({
  sourceSha: "28703b2c6dfa7a2408b8d5789a2b46c6ebedcf9e",
  baseSha: "36dc3298043959fde2fefb5c1f760384f3254528",
  runId: 38760225469,
  artifactId: 11986523714,
  archiveHash: "85cbd05d178c9bad81ced63e9bc6d8c5c72a69bcfdce4d4c87a9958360eac5b7",
  beforeHash: "b25befe65bb6abdc9f3b956dc9ac38d70f06c509e910f593269f8cf67318ea5f",
  rulesHash: "311396cdd0a6f9c75f629976a79add891034ade4c7628a9f019a504f01ce7d56",
  project: "catch-dating-app-64e51",
});
export const hash = value => createHash("sha256").update(value).digest("hex");
export function rulesRequestHeaders(token, quotaProject) {
  assert.ok(token && !/[\r\n]/.test(token));
  // Service-account requests use their own project by default. Forcing the
  // user-project header additionally requires serviceusage.services.use.
  // Local user credentials can opt in without changing the production identity.
  if (quotaProject !== undefined) assert.equal(quotaProject, RELEASE.project);
  return {Authorization: `Bearer ${token}`,
    ...(quotaProject ? {"X-Goog-User-Project": quotaProject} : {})};
}
export function verifyAuthority(run, artifact) {
  assert.equal(run.id, RELEASE.runId);
  assert.equal(run.run_attempt, 1);
  assert.equal(run.workflow_id, 320377139);
  assert.equal(run.event, "push");
  assert.equal(run.head_branch, "main");
  assert.equal(run.head_sha, RELEASE.sourceSha);
  assert.equal(run.head_repository.full_name, "suvratgarg/catch-dating-app");
  assert.equal(run.status, "completed");
  assert.equal(run.conclusion, "success");
  assert.equal(artifact.id, RELEASE.artifactId);
  assert.equal(artifact.expired, false);
  assert.equal(artifact.name, `firebase-delivery-${RELEASE.sourceSha}-1`);
  assert.equal(artifact.digest, `sha256:${RELEASE.archiveHash}`);
  assert.equal(artifact.workflow_run.id, RELEASE.runId);
  assert.equal(artifact.workflow_run.head_sha, RELEASE.sourceSha);
}
export function verifyApproval(environment, history) {
  assert.equal(environment.name, "prod");
  const reviewers = environment.protection_rules
    .filter(r => r.type === "required_reviewers")
    .flatMap(r => r.reviewers).filter(r => r.type === "User")
    .map(r => r.reviewer.id);
  assert.ok(reviewers.length);
  const relevant = history.filter(h => h.environments.some(e =>
    e.id === environment.id && e.name === "prod"));
  assert.ok(relevant.length);
  assert.ok(relevant.every(h => h.state === "approved"));
  assert.ok(relevant.some(h => reviewers.includes(h.user?.id)));
}
export function verifyPlan(plan, rules) {
  assert.equal(plan.sourceSha, RELEASE.sourceSha);
  assert.equal(plan.baseSha, RELEASE.baseSha);
  assert.equal(String(plan.sourceCiRunId), String(RELEASE.runId));
  assert.equal(String(plan.sourceCiRunAttempt), "1");
  assert.ok(plan.stages.includes("firestore-rules"));
  assert.equal(plan.targets[plan.stages.indexOf("firestore-rules")], "firestore:rules");
  assert.equal(hash(rules), RELEASE.rulesHash);
  return {firestore: {rules: "firestore.rules"}};
}
export function verifyCurrentRules(historical, current) {
  const block = text => {
    const start = text.indexOf("    // Host list views");
    const end = text.indexOf("    // Organizer Audience/CRM", start);
    assert.ok(start >= 0 && end > start);
    return text.slice(start, end);
  };
  assert.equal(block(historical), block(current), "Host access policy changed since PR592.");
}
export function verifyLive(snapshot, phase, before) {
  assert.ok(["before", "after"].includes(phase));
  assert.equal(snapshot.project, RELEASE.project);
  assert.equal(snapshot.rulesHash, phase === "before" ? RELEASE.beforeHash : RELEASE.rulesHash,
    "Live rules changed; stop rather than overwrite another release.");
  if (before) assert.deepEqual(snapshot.otherReleases, before.otherReleases,
    "Unselected rules releases changed.");
  return snapshot;
}
async function snapshot() {
  const auth = spawnSync("gcloud", ["auth", "print-access-token"], {encoding: "utf8"});
  assert.equal(auth.status, 0);
  const token = auth.stdout.trim();
  assert.ok(token && !/[\r\n]/.test(token));
  const get = async suffix => {
    const response = await fetch(`https://firebaserules.googleapis.com/v1/${suffix}`, {
      headers: rulesRequestHeaders(token, process.env.CATCH_RULES_QUOTA_PROJECT),
      signal: AbortSignal.timeout(30000),
    });
    const body = await response.json();
    const reasons = (body.error?.details ?? []).map(detail => detail.reason)
      .filter(reason => typeof reason === "string" && /^[A-Z_]+$/.test(reason));
    assert.ok(response.ok, `Rules metadata HTTP ${response.status}: ${reasons.join(",")}`);
    return body;
  };
  const prefix = `projects/${RELEASE.project}`;
  const releases = [];
  let pageToken = "";
  const seen = new Set();
  do {
    assert.ok(!seen.has(pageToken) && seen.size < 20);
    seen.add(pageToken);
    const page = await get(`${prefix}/releases?${new URLSearchParams({
      pageSize: "100", ...(pageToken ? {pageToken} : {}),
    })}`);
    releases.push(...(page.releases ?? []));
    pageToken = page.nextPageToken ?? "";
  } while (pageToken);
  const selected = releases.filter(r => r.name === `${prefix}/releases/cloud.firestore`);
  assert.equal(selected.length, 1);
  assert.ok(selected[0].rulesetName.startsWith(`${prefix}/rulesets/`));
  const ruleset = await get(selected[0].rulesetName);
  assert.equal(ruleset.source.files.length, 1);
  return {
    project: RELEASE.project,
    release: selected[0],
    rulesHash: hash(normalizeRulesContent(ruleset.source.files[0].content)),
    otherReleases: releases.filter(r => r.name !== selected[0].name)
      .sort((a, b) => a.name.localeCompare(b.name)),
  };
}
const read = path => JSON.parse(fs.readFileSync(path, "utf8"));
export async function runCli([command, ...args]) {
  if (command === "authority") {
    assert.equal(args.length, 2);
    verifyAuthority(read(args[0]), read(args[1]));
  } else if (command === "approval") {
    assert.equal(args.length, 2);
    verifyApproval(read(args[0]), read(args[1]));
  } else if (command === "archive") {
    assert.equal(args.length, 1);
    assert.equal(hash(fs.readFileSync(args[0])), RELEASE.archiveHash);
  } else if (command === "prepare") {
    assert.equal(args.length, 2);
    const config = verifyPlan(read(args[0]), fs.readFileSync(`${args[1]}/firestore.rules`));
    // Keep the verified original package intact; deploy only a separate rules copy.
    fs.mkdirSync("build/host-rules-only", {recursive: false});
    fs.copyFileSync(`${args[1]}/firestore.rules`, "build/host-rules-only/firestore.rules");
    fs.writeFileSync("build/host-rules-only/firebase.json", JSON.stringify(config));
  } else if (command === "verify-rules") {
    assert.equal(args.length, 1);
    const rules = fs.readFileSync("build/host-rules-only/firestore.rules", "utf8");
    assert.equal(hash(rules), RELEASE.rulesHash);
    assert.deepEqual(read("build/host-rules-only/firebase.json"), {firestore: {rules: "firestore.rules"}});
    verifyCurrentRules(rules, fs.readFileSync(args[0], "utf8"));
  } else if (command === "before") {
    assert.equal(args.length, 1);
    fs.writeFileSync(args[0], JSON.stringify(verifyLive(await snapshot(), "before")), {flag: "wx"});
  } else if (command === "verify-before" || command === "after") {
    assert.equal(args.length, 1);
    const before = read(args[0]);
    verifyLive(before, "before");
    const live = verifyLive(await snapshot(), command === "after" ? "after" : "before", before);
    if (command === "verify-before") assert.deepEqual(live, before);
    else fs.writeFileSync("build/host-rules-receipt.json", JSON.stringify({
      schema: "catch.host-store-rules-release/v1", sourceSha: RELEASE.sourceSha,
      sourceCiRunId: RELEASE.runId, rulesHash: RELEASE.rulesHash,
      target: "firestore:rules", before, after: live,
    }, null, 2), {flag: "wx"});
  } else throw new Error("Unknown fixed release command");
  return {verified: command};
}
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runCli(process.argv.slice(2)).then(r => console.log(JSON.stringify(r))).catch(error => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
