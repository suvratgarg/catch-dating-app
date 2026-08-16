#!/usr/bin/env node
/**
 * Refuse to deploy from a working tree that is behind its remote.
 *
 * On 2026-08-15 a Firestore rules deploy was run from a local `main` that was
 * 17 commits behind `origin/main`. The deploy succeeded, and silently removed
 * five `match` blocks from the live ruleset — a production authorization
 * regression caused entirely by trusting a branch *name* instead of measuring
 * the ref. Nothing in the deploy path looked at the remote.
 *
 * This check closes that path. It is deliberately narrow: it fails only when it
 * can *prove* the deploying ref is missing commits that the remote has. If the
 * remote is unavailable, or the ref is unrelated to any remote branch, it says
 * so and allows the deploy — a guard that blocks on ambiguity would be routed
 * around, and a routed-around guard protects nothing.
 *
 *   node tool/firebase/check_deploy_ref.mjs --env prod
 *   node tool/firebase/check_deploy_ref.mjs --env prod --allow-behind   # override
 */

import {spawnSync} from "node:child_process";
import process from "node:process";

const git = (...args) => {
  const result = spawnSync("git", args, {encoding: "utf8"});
  return {
    ok: result.status === 0,
    out: (result.stdout ?? "").trim(),
    err: (result.stderr ?? "").trim(),
  };
};

/**
 * @returns {{verdict: "behind"|"current"|"unknown", detail: string,
 *            behindBy?: number, remoteRef?: string}}
 */
export function inspectDeployRef({runGit = git} = {}) {
  const head = runGit("rev-parse", "HEAD");
  if (!head.ok) return {verdict: "unknown", detail: "not a git repository"};

  const branch = runGit("rev-parse", "--abbrev-ref", "HEAD");
  const named = branch.ok && branch.out !== "HEAD" ? branch.out : null;

  // Prefer the branch's configured upstream; fall back to origin/<branch>, then
  // to origin/main for detached deploys (CI checks out a SHA).
  const candidates = [];
  if (named) {
    const upstream = runGit("rev-parse", "--abbrev-ref", `${named}@{upstream}`);
    if (upstream.ok && upstream.out) candidates.push(upstream.out);
    candidates.push(`origin/${named}`);
  }
  candidates.push("origin/main");

  const remoteRef = candidates.find((ref) => runGit("rev-parse", "--verify", "-q", ref).ok);
  if (!remoteRef) {
    return {verdict: "unknown", detail: "no remote-tracking ref available to compare against"};
  }

  // Commits the remote has that HEAD does not. Anything above zero means the
  // deploy would publish an older view of the world than the remote records.
  const behind = runGit("rev-list", "--count", `HEAD..${remoteRef}`);
  if (!behind.ok) {
    return {verdict: "unknown", detail: `could not compare against ${remoteRef}`, remoteRef};
  }
  const behindBy = Number.parseInt(behind.out, 10);
  if (!Number.isFinite(behindBy)) {
    return {verdict: "unknown", detail: `unparseable rev-list output`, remoteRef};
  }
  if (behindBy === 0) {
    return {verdict: "current", detail: `up to date with ${remoteRef}`, behindBy: 0, remoteRef};
  }
  return {
    verdict: "behind",
    behindBy,
    remoteRef,
    detail: `HEAD is missing ${behindBy} commit(s) present on ${remoteRef}`,
  };
}

function main() {
  const argv = process.argv.slice(2);
  const env = argv[argv.indexOf("--env") + 1] ?? "unknown";
  const allowBehind = argv.includes("--allow-behind");

  // A stale remote-tracking ref would make a behind branch look current, which
  // is the exact failure being guarded against. Refresh before comparing.
  spawnSync("git", ["fetch", "origin", "--quiet"], {stdio: "ignore"});

  const result = inspectDeployRef();

  if (result.verdict === "behind") {
    const head = git("rev-parse", "--short", "HEAD").out;
    console.error(
      `\nRefusing to deploy to ${env}: ${result.detail}.\n\n` +
      `  HEAD          ${head}\n` +
      `  ${result.remoteRef.padEnd(13)} ${git("rev-parse", "--short", result.remoteRef).out}\n\n` +
      `Deploying would publish an older configuration than the remote records —\n` +
      `on 2026-08-15 exactly this removed five match blocks from the live\n` +
      `Firestore ruleset. Fast-forward first:\n\n` +
      `  git merge --ff-only ${result.remoteRef}\n\n` +
      `If you intend to deploy this older ref, re-run with --allow-behind.\n`,
    );
    if (!allowBehind) process.exit(1);
    console.error("--allow-behind set; continuing against an outdated ref.\n");
    return;
  }

  if (result.verdict === "unknown") {
    console.warn(`Deploy ref check skipped: ${result.detail}.`);
    return;
  }
  console.log(`Deploy ref check passed: ${result.detail}.`);
}

if (import.meta.url === `file://${process.argv[1]}`) main();
