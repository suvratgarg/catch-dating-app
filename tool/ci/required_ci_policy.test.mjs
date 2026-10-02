import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {extractSteps} from "../harness/lib/workflow_steps.mjs";

const root = fileURLToPath(new URL("../../", import.meta.url));
const ci = fs.readFileSync(path.join(root, ".github/workflows/ci.yml"), "utf8");
const required = ci.slice(ci.indexOf("\n  required:\n"));
assert.ok(required.startsWith("\n  required:\n"), "missing Required CI job");
const steps = extractSteps(required);
function command(name) {
  const step = steps.find((entry) => entry.name === name);
  assert.ok(step?.run, `missing Required CI command ${name}`);
  return step.run;
}
const selectedLanes = ["tools", "contracts", "functions", "firestore-rules", "flutter",
  "visual-integration", "admin", "marketing", "operations", "docs-policy", "app-builds"];
const dependencies = [...required.matchAll(/^      - ([a-z-]+)$/gmu)].map((match) => match[1]);
const successfulNeeds = () => Object.fromEntries(dependencies.map((job) =>
  [job, {result: ["admission", "plan", ...selectedLanes].includes(job) ? "success" : "skipped"}]));
function run(name, env = {}, cwd = root) {
  return spawnSync("bash", ["-e", "-o", "pipefail", "-c", command(name)], {
    cwd, encoding: "utf8", timeout: 10000,
    env: {...process.env, NODE_OPTIONS: "", EVENT_NAME: "pull_request", GITHUB_REF: "refs/pull/42/merge",
      DEPLOY_REQUIRED: "false", NEEDS_JSON: JSON.stringify(successfulNeeds()), ...env},
  });
}
function passed(result) {
  assert.equal(result.status, 0, result.stderr || result.stdout || result.error?.message);
}
function failed(result) {
  assert.notEqual(result.status, 0, result.stdout);
  assert.equal(result.error, undefined);
}

test("Required CI retains every automated dependency without the human source gate", () => {
  assert.deepEqual(dependencies, ["admission", "plan", "finalize-plan", ...selectedLanes, "package-firebase"]);
  assert.doesNotMatch(ci, /backend-review|Backend source review|BACKEND_REVIEW_REQUIRED/u);
  passed(run("Require every selected lane"));
  const needs = successfulNeeds();
  for (const lane of selectedLanes) needs[lane].result = "skipped";
  passed(run("Require every selected lane", {NEEDS_JSON: JSON.stringify(needs)}));
});

for (const lane of selectedLanes) {
  for (const result of ["failure", "cancelled"]) {
    test(`Required CI rejects ${lane}=${result}`, () => {
      const needs = successfulNeeds();
      needs[lane].result = result;
      const output = run("Require every selected lane", {NEEDS_JSON: JSON.stringify(needs)});
      failed(output);
      assert.match(output.stdout, new RegExp(`${lane}=${result}`, "u"));
    });
  }
}

for (const result of ["failure", "cancelled", "skipped", "", undefined]) {
  test(`Required CI rejects planning without success (${String(result)})`, () => {
    const needs = successfulNeeds();
    if (result === undefined) delete needs.plan;
    else needs.plan.result = result;
    failed(run("Require every selected lane", {NEEDS_JSON: JSON.stringify(needs)}));
  });
}

for (const admitted of ["false", "", "True"]) {
  test(`Required CI rejects deferred admission (${JSON.stringify(admitted)})`, () => {
    failed(run("Refuse deferred PR validation", {ADMITTED: admitted}));
  });
}
test("Required CI accepts the explicit admitted output", () => {
  passed(run("Refuse deferred PR validation", {ADMITTED: "true"}));
});

const source = "a".repeat(40), head = "b".repeat(40), base = "c".repeat(40);
const repository = "owner/repo", runId = "1000", attempt = "2", runNumber = "77";
function admissionFixture() {
  const prefix = `repos/${repository}`;
  const label = {name: "ci:admitted"};
  return {
    [`${prefix}/pulls/42`]: {number: 42, state: "open", draft: false, labels: [label],
      head: {sha: head, repo: {full_name: repository}}, base: {ref: "main", repo: {full_name: repository}}},
    [`${prefix}/branches/main`]: {commit: {sha: base}},
    [`${prefix}/issues?state=open&labels=ci%3Aadmitted&per_page=100&page=1`]:
      [{number: 42, labels: [label], pull_request: {url: "unused"}}],
    [`${prefix}/actions/workflows/ci.yml/runs?event=pull_request&head_sha=${head}&per_page=100`]:
      {workflow_runs: [{id: Number(runId), event: "pull_request", head_sha: head,
        path: ".github/workflows/ci.yml", display_title: "CI PR #42"}]},
  };
}
function liveAdmission(mutate = () => {}, {parents = `${base} ${head}`, unavailable = false} = {}) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-required-admission-"));
  try {
    const values = admissionFixture();
    mutate(values);
    const event = path.join(directory, "event.json");
    fs.writeFileSync(event, JSON.stringify({action: "synchronize", number: 42, pull_request: {head: {sha: head}}}));
    const hook = path.join(directory, "github.mjs");
    fs.writeFileSync(hook, `
      import assert from "node:assert/strict";
      import childProcess from "node:child_process";
      import {syncBuiltinESMExports} from "node:module";
      childProcess.execFileSync = (command, args) => {
        assert.equal(command, "git");
        assert.deepEqual(args, ["show", "-s", "--format=%P", "${source}"]);
        return ${JSON.stringify(parents)};
      };
      syncBuiltinESMExports();
      const values = ${JSON.stringify(values)};
      globalThis.fetch = async (url) => {
        const endpoint = url.slice("https://api.github.com/".length);
        assert.ok(Object.hasOwn(values, endpoint), endpoint);
        return {ok: ${!unavailable}, status: 503, json: async () => values[endpoint]};
      };
    `);
    return run("Recheck live PR admission and tested source", {
      NODE_OPTIONS: `--import=${hook}`, GITHUB_EVENT_PATH: event, GITHUB_EVENT_NAME: "pull_request",
      GITHUB_SHA: source, GITHUB_REPOSITORY: repository, GITHUB_RUN_ID: runId,
      GITHUB_OUTPUT: path.join(directory, "output"), GITHUB_STEP_SUMMARY: path.join(directory, "summary"),
    });
  } finally {
    fs.rmSync(directory, {recursive: true, force: true});
  }
}
test("Required CI executes live --require admission on the exact tested source", () => {
  passed(liveAdmission());
});
for (const [label, mutate] of [
  ["removed label", (v) => {v[`repos/${repository}/pulls/42`].labels = [];}],
  ["changed PR head", (v) => {v[`repos/${repository}/pulls/42`].head.sha = "d".repeat(40);}],
  ["advanced main", (v) => {v[`repos/${repository}/branches/main`].commit.sha = "d".repeat(40);}],
  ["newer admission run", (v) => {Object.values(v).find((entry) => entry.workflow_runs).workflow_runs.push({
    id: 1001, event: "pull_request", head_sha: head, path: ".github/workflows/ci.yml", display_title: "CI PR #42"});}],
]) {
  test(`Required CI live recheck rejects ${label}`, () => {failed(liveAdmission(mutate));});
}
test("Required CI live recheck rejects unavailable evidence and mismatched merge parents", () => {
  failed(liveAdmission(undefined, {unavailable: true}));
  failed(liveAdmission(undefined, {parents: `${base} ${"d".repeat(40)}`}));
});

function mainGuard({mutateNeeds = () => {}, mutateArtifacts = () => {}, deployRequired = true} = {}) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-required-artifacts-"));
  try {
    const needs = successfulNeeds();
    needs["finalize-plan"].result = "success";
    needs["package-firebase"].result = deployRequired ? "success" : "skipped";
    mutateNeeds(needs);
    const artifacts = [{id: 12, name: `harness-plan-${runNumber}-${runId}-${source}-${attempt}`,
      digest: `sha256:${"d".repeat(64)}`, expired: false}];
    if (deployRequired) artifacts.push({id: 13, name: `firebase-delivery-${source}-${attempt}`,
      digest: `sha256:${"e".repeat(64)}`, expired: false});
    mutateArtifacts(artifacts);
    const gh = path.join(directory, "gh");
    fs.writeFileSync(gh, '#!/bin/sh\nprintf "%s\\n" "$FIXTURE_ARTIFACT_PAGES"\n', {mode: 0o755});
    const output = path.join(directory, "output");
    const result = run("Require every selected lane", {
      PATH: `${directory}:${process.env.PATH}`, EVENT_NAME: "push", GITHUB_REF: "refs/heads/main",
      GITHUB_REPOSITORY: repository, GITHUB_RUN_ID: runId, GITHUB_RUN_ATTEMPT: attempt,
      GITHUB_RUN_NUMBER: runNumber, SOURCE_SHA: source, GITHUB_OUTPUT: output,
      DEPLOY_REQUIRED: String(deployRequired), NEEDS_JSON: JSON.stringify(needs),
      FIXTURE_ARTIFACT_PAGES: JSON.stringify([{artifacts}]),
    });
    return {...result, output: fs.existsSync(output) ? fs.readFileSync(output, "utf8") : ""};
  } finally {
    fs.rmSync(directory, {recursive: true, force: true});
  }
}
test("Required CI main retains same-source/run/attempt artifact authority", () => {
  const result = mainGuard();
  passed(result);
  assert.match(result.output, /plan_artifact_id=12/u);
  assert.match(result.output, /package_artifact_id=13/u);
  passed(mainGuard({deployRequired: false}));
});
for (const job of ["finalize-plan", "package-firebase"]) {
  test(`Required CI main rejects skipped ${job}`, () => {
    failed(mainGuard({mutateNeeds: (needs) => {needs[job].result = "skipped";}}));
  });
}
for (const index of [0, 1]) {
  for (const [label, mutate] of [
    ["absent", (artifacts) => {artifacts.splice(index, 1);}],
    ["expired", (artifacts) => {artifacts[index].expired = true;}],
    ["older attempt", (artifacts) => {artifacts[index].name = artifacts[index].name.replace(/-2$/u, "-1");}],
    ["different source", (artifacts) => {artifacts[index].name = artifacts[index].name.replace(source, head);}],
    ["duplicate", (artifacts) => {artifacts.push({...artifacts[index], id: 99});}],
    ["missing digest", (artifacts) => {delete artifacts[index].digest;}],
  ]) {
    test(`Required CI rejects ${index === 0 ? "plan" : "package"} artifact ${label}`, () => {
      failed(mainGuard({mutateArtifacts: mutate}));
    });
  }
}
test("Required CI rejects a plan from another source CI run", () => {
  failed(mainGuard({mutateArtifacts: (artifacts) => {artifacts[0].name = artifacts[0].name.replace(`-${runId}-`, "-999-");}}));
});
