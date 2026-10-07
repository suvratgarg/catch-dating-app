import assert from "node:assert/strict";
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {inspectPredecessors, resolveMainBaseline} from "./main_ci_baseline.mjs";

const repository = "owner/catch";
const sourceSha = "c".repeat(40);
const earlierSha = "a".repeat(40);
const middleSha = "b".repeat(40);
const current = {id: 99, run_number: 10, run_attempt: 1, workflow_id: 7,
  path: ".github/workflows/ci.yml", name: "CI", event: "push", head_branch: "main",
  head_sha: sourceSha, status: "in_progress", conclusion: null,
  repository: {id: 1, full_name: repository}, head_repository: {id: 1, full_name: repository}};
const previous = (overrides = {}) => ({...structuredClone(current),
  id: 98, run_number: 9, head_sha: middleSha, ...overrides});
const successful = previous({id: 97, run_number: 8, head_sha: earlierSha,
  status: "completed", conclusion: "success"});

function setup(snapshots, extra = {}) {
  let requests = 0;
  const ancestry = [];
  const messages = [];
  return {ancestry, messages, options: {
    repository, runId: 99, runAttempt: 1, sourceSha, fallbackBase: "d".repeat(40),
    request: async (endpoint, options) => {
      if (endpoint === "repos/owner/catch/actions/runs/99") return structuredClone(current);
      assert.equal(endpoint, "repos/owner/catch/actions/workflows/7/runs?branch=main&event=push&per_page=100");
      assert.deepEqual(options, {paginate: true});
      return [{workflow_runs: snapshots[Math.min(requests++, snapshots.length - 1)]}];
    },
    ensureAncestor: (base, head) => ancestry.push([base, head]),
    sleep: async () => {},
    onWait: (message) => messages.push(message),
    ...extra,
  }};
}

test("validation starts from the latest completed success while older CI is active", async () => {
  const f = setup([[successful, previous(), previous({id: 100, run_number: 11})]]);
  const result = await resolveMainBaseline(f.options);
  assert.equal(result.baseSha, earlierSha);
  assert.equal(result.activePredecessors, 1);
  assert.equal(result.previousCiRunNumber, 8);
  assert.deepEqual(f.ancestry, [[earlierSha, sourceSha]]);
  assert.deepEqual(f.messages, []);
});

test("publication waits for the predecessor and uses its newly successful source", async () => {
  const f = setup([[successful, previous()], [successful, previous()],
    [successful, previous({status: "completed", conclusion: "success"})]], {wait: true});
  const result = await resolveMainBaseline(f.options);
  assert.equal(result.baseSha, middleSha);
  assert.equal(result.activePredecessors, 0);
  assert.deepEqual(f.ancestry, [[middleSha, sourceSha]]);
  assert.equal(f.messages.length, 1, "unchanged waiting state is not repeatedly reported");
});

test("a failed predecessor retains the older successful baseline for recovery", async () => {
  const f = setup([[successful, previous()],
    [successful, previous({status: "completed", conclusion: "failure"})]], {wait: true});
  assert.equal((await resolveMainBaseline(f.options)).baseSha, earlierSha);
});

test("foreign, PR, newer and other-workflow runs cannot change the baseline or block it", () => {
  const result = inspectPredecessors({current, repository, runs: [successful,
    previous({event: "pull_request"}), previous({head_repository: {id: 2, full_name: "foreign/catch"}}),
    previous({workflow_id: 8}), previous({path: ".github/workflows/other.yml"}),
    previous({run_number: 11}), previous({head_branch: "feature"}),
  ]});
  assert.deepEqual(result.active, []);
  assert.equal(result.previousSuccess.id, 97);
});

test("pagination prefers an active rerun to an older success for the same CI", () => {
  const result = inspectPredecessors({current, repository, runs: [
    previous({run_attempt: 2}), previous({status: "completed", conclusion: "success"}), successful,
  ]});
  assert.equal(result.active.length, 1);
  assert.equal(result.active[0].run_attempt, 2);
  assert.equal(result.previousSuccess.id, 97);
});

test("push-before is used only when no successful predecessor exists", async () => {
  const f = setup([[]]);
  const result = await resolveMainBaseline(f.options);
  assert.equal(result.baseSha, "d".repeat(40));
  assert.equal(result.previousCiRunId, null);
  await assert.rejects(resolveMainBaseline({...f.options, fallbackBase: "0".repeat(40)}), /Missing usable/);
});

test("missing, mismatched and non-ancestor identities fail before publication", async () => {
  const f = setup([[successful]]);
  for (const mutation of [
    {head_sha: earlierSha}, {run_attempt: 2}, {event: "pull_request"},
    {head_repository: {id: 2, full_name: repository}}, {path: ".github/workflows/other.yml"},
  ]) {
    await assert.rejects(resolveMainBaseline({...f.options,
      request: async () => ({...current, ...mutation})}), /not the exact/);
  }
  await assert.rejects(resolveMainBaseline({...f.options,
    ensureAncestor: () => { throw new Error("Non-ancestor history"); }}), /Non-ancestor/);
  await assert.rejects(resolveMainBaseline({...f.options,
    request: async (endpoint, options) => options ? {} : current}), /Malformed main CI/);
  await assert.rejects(resolveMainBaseline({...f.options,
    request: async () => { throw new Error("API unavailable"); }}), /API unavailable/);
});

test("a stalled predecessor times out without providing any baseline", async () => {
  let time = 0;
  const f = setup([[successful, previous()]], {wait: true,
    now: () => time++, maxWaitMs: 1});
  await assert.rejects(resolveMainBaseline(f.options), /Timed out/);
  assert.deepEqual(f.ancestry, []);
});

const linearAncestry = (base, head) => {
  const history = [earlierSha, middleSha, sourceSha];
  return history.includes(base) && history.includes(head) && history.indexOf(base) <= history.indexOf(head);
};

test("a successful predecessor rerun cannot regress the verified validation floor", async () => {
  const planned = setup([[successful, previous({status: "completed", conclusion: "success"})]]);
  const validation = await resolveMainBaseline(planned.options);
  assert.equal(validation.baseSha, middleSha);
  for (const conclusion of ["failure", "cancelled", "timed_out", "skipped"]) {
    const f = setup([[successful, previous({run_attempt: 2})],
      [successful, previous({run_attempt: 2, status: "completed", conclusion})]],
    {wait: true, minimumBaseSha: validation.baseSha, isAncestor: linearAncestry});
    const result = await resolveMainBaseline(f.options);
    assert.equal(result.baseSha, middleSha, conclusion);
    assert.equal(result.previousCiRunId, null, "the older success must not be attributed to the retained floor");
    assert.equal(result.previousCiRunNumber, null);
    assert.equal(result.sourceSha, sourceSha);
    assert.equal(result.sourceCiRunId, "99");
    assert.equal(result.sourceCiRunAttempt, "1");
    assert.equal(f.messages.length, 1, "ordered publication still waits for the rerun");
  }
});

test("identical and newer successful baselines preserve or advance the validation floor", async () => {
  for (const [minimumBaseSha, expected] of [[middleSha, middleSha], [earlierSha, middleSha]]) {
    const f = setup([[successful, previous({status: "completed", conclusion: "success"})]],
      {wait: true, minimumBaseSha, isAncestor: linearAncestry});
    const result = await resolveMainBaseline(f.options);
    assert.equal(result.baseSha, expected);
    assert.equal(result.previousCiRunId, "98");
  }
});

test("push-before fallback is subject to the same monotone ancestry floor", async () => {
  for (const [fallbackBase, minimumBaseSha, expected] of [
    [earlierSha, middleSha, middleSha], [middleSha, earlierSha, middleSha], [middleSha, middleSha, middleSha],
  ]) {
    const f = setup([[]], {wait: true, fallbackBase, minimumBaseSha, isAncestor: linearAncestry});
    assert.equal((await resolveMainBaseline(f.options)).baseSha, expected);
  }
  const f = setup([[]], {wait: true, minimumBaseSha: middleSha, fallbackBase: "d".repeat(40),
    isAncestor: linearAncestry, ensureAncestor: (base, head) => {
      assert.ok(linearAncestry(base, head), "Non-ancestor fallback");
    }});
  await assert.rejects(resolveMainBaseline(f.options), /Non-ancestor fallback/);
});

test("incomparable successful history cannot be replaced by a validation floor", async () => {
  const f = setup([[successful]], {wait: true, minimumBaseSha: middleSha,
    isAncestor: () => false});
  await assert.rejects(resolveMainBaseline(f.options), /incompatible ancestry/);
});

test("invalid or unreachable validation floors fail before metadata reads or waits", async () => {
  let requests = 0;
  const f = setup([[successful, previous()]], {wait: true,
    request: async () => {requests++; throw new Error("Metadata should not be read");},
    ensureAncestor: () => {throw new Error("Unreachable validation floor");}});
  for (const minimumBaseSha of ["invalid", "0".repeat(40)]) {
    await assert.rejects(resolveMainBaseline({...f.options, minimumBaseSha}), /validation floor/);
  }
  await assert.rejects(resolveMainBaseline({...f.options, minimumBaseSha: middleSha}), /Unreachable validation floor/);
  assert.equal(requests, 0);
});

test("workflow derives the publication floor only after exact validation-plan verification", () => {
  const workflow = fs.readFileSync(new URL("../../.github/workflows/ci.yml", import.meta.url), "utf8");
  const finalizer = workflow.split("  finalize-plan:\n")[1].split("  package-firebase:\n")[0];
  const proof = finalizer.indexOf('node tool/ci/finalize_ci_plan.mjs validate "${proof_args[@]}"');
  const floor = finalizer.indexOf("jq -er '.baseSha' build/ci/validation/impact-plan.json");
  const resolve = finalizer.indexOf('baseline="$(node tool/ci/main_ci_baseline.mjs');
  assert.ok(proof >= 0 && floor > proof && resolve > floor);
  assert.match(finalizer, /--minimum-base-sha "\$validation_base_sha" --wait/);
});

test("CLI help and malformed invocations require no GitHub requests", () => {
  const run = (args) => spawnSync(process.execPath, ["tool/ci/main_ci_baseline.mjs", ...args], {encoding: "utf8"});
  assert.equal(run(["--help"]).status, 0);
  for (const args of [[], ["--unknown"], ["--run-id"], ["--wait", "--wait"]]) {
    const result = run(args);
    assert.notEqual(result.status, 0);
    assert.equal(result.stdout, "");
  }
});
