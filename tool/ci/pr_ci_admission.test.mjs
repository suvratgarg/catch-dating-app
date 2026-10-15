import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {execFileSync, spawnSync} from "node:child_process";
import {ADMISSION_LABEL, isAdmissionEvent, resolveAdmission} from "./pr_ci_admission.mjs";

const repository = "example/catch";
const headSha = "a".repeat(40);
const baseSha = "b".repeat(40);
const runId = 1000;
const run = (id = runId) => ({id, event: "pull_request", head_sha: headSha, path: ".github/workflows/ci.yml", display_title: "CI PR #42"});
const label = {name: ADMISSION_LABEL};
const row = (number) => ({number, labels: [label], pull_request: {url: "unused"}});
function fixture({changePr = {}, mainSha = baseSha, pages = [[row(42)]], runs = [run()], fail = false,
  reevaluation} = {}) {
  const defaultPr = {number: 42, state: "open", draft: false, labels: [label],
    base: {ref: "main", repo: {full_name: repository}},
    head: {sha: headSha, repo: {full_name: repository}}};
  const initial = {changePr, mainSha, pages, runs, fail};
  const snapshots = [initial, {...initial, ...reevaluation}];
  let evaluation = -1;
  const requested = [];
  const reads = [];
  const observations = [];
  const request = async (endpoint, options) => {
    requested.push(endpoint);
    reads.push({endpoint, fresh: options?.fresh === true});
    if (endpoint.endsWith("/pulls/42")) evaluation += 1;
    const current = snapshots[evaluation % 2];
    if (current.fail) throw new Error("API unavailable");
    if (endpoint.endsWith("/pulls/42")) return {...defaultPr, ...current.changePr};
    if (endpoint.endsWith("/branches/main")) return {commit: {sha: current.mainSha}};
    if (endpoint.includes("/actions/workflows/")) return {workflow_runs: current.runs};
    const page = Number(new URL(`https://api.github.com/${endpoint}`).searchParams.get("page"));
    assert.ok(page > 0);
    return current.pages[page - 1] ?? [];
  };
  return {repository, number: 42, headSha, baseSha, runId, request, requested, reads,
    observe: (observation) => observations.push(observation), observations};
}

test("only the sole admitted ready PR on exact head and main can validate", async () => {
  assert.deepEqual(await resolveAdmission(fixture()), {
    admitted: true, code: "admitted",
    reason: "Sole admitted PR and latest eligible run match tested head and current main",
  });
});

for (const [name, options, code] of [
  ["label removed or ordinary unadmitted update", {changePr: {labels: []}}, "awaiting_label"],
  ["draft converted while waiting", {changePr: {draft: true}}, "draft_pr"],
  ["closed PR", {changePr: {state: "closed"}}, "ineligible_pr"],
  ["new head after queued event", {changePr: {head: {sha: "c".repeat(40), repo: {full_name: repository}}}}, "stale_head"],
  ["main advanced since tested merge", {mainSha: "c".repeat(40)}, "stale_main"],
  ["different target branch", {changePr: {base: {ref: "release", repo: {full_name: repository}}}}, "ineligible_pr"],
  ["foreign head repository", {changePr: {head: {sha: headSha, repo: {full_name: "other/catch"}}}}, "ineligible_pr"],
  ["zero labels after state changed between reads", {pages: [[]]}, "admission_list_empty"],
  ["two PRs admitted", {pages: [[row(42), row(43)]]}, "admission_conflict"],
]) {
  test(`deny ${name}`, async () => {
    const result = await resolveAdmission(fixture(options));
    assert.equal(result.admitted, false);
    assert.equal(result.code, code);
  });
}

for (const [name, pages, code] of [
  ["empty", [[]], "admission_list_empty"],
  ["missing current", [[row(43)]], "admission_current_missing"],
  ["stale previous PR", [[row(42), row(43)]], "admission_conflict"],
]) {
  test(`one fresh complete re-evaluation recovers a transient ${name} list`, async () => {
    const input = fixture({pages, reevaluation: {pages: [[row(42)]]}});
    assert.equal((await resolveAdmission(input)).admitted, true);
    assert.equal(input.observations.length, 2);
    assert.equal(input.observations[0].code, code);
    assert.equal(input.observations[0].retry, true);
    assert.equal(input.observations[1].code, "admitted");
    assert.deepEqual(input.observations[1].observedPRNumbers, [42]);
    assert.equal(input.reads.filter((read) => read.fresh).length, 4);
    assert.ok(input.reads.filter((read) => read.fresh).some((read) => read.endpoint.endsWith("/pulls/42")));
    assert.ok(input.reads.filter((read) => read.fresh).some((read) => read.endpoint.endsWith("/branches/main")));
    assert.ok(input.reads.filter((read) => read.fresh).some((read) => read.endpoint.includes("/issues?")));
    assert.ok(input.reads.filter((read) => read.fresh).some((read) => read.endpoint.includes("/actions/workflows/")));
  });
}

test("persistent empty, missing-current and genuine dual lists remain distinct and bounded", async () => {
  for (const [pages, code, observed] of [
    [[[]], "admission_list_empty", []],
    [[[row(43)]], "admission_current_missing", [43]],
    [[[row(43), row(42)]], "admission_conflict", [42, 43]],
  ]) {
    const input = fixture({pages});
    const result = await resolveAdmission(input);
    assert.equal(result.admitted, false);
    assert.equal(result.code, code);
    assert.equal(input.observations.length, 2);
    assert.deepEqual(input.observations.map((observation) => observation.observedPRNumbers), [observed, observed]);
    assert.deepEqual(input.observations.map((observation) => observation.retry), [true, false]);
    assert.equal(input.requested.filter((url) => url.includes("/actions/workflows/")).length, 0);
  }
});

test("fresh retry preserves pagination and cannot hide a second-page admission", async () => {
  const issues = Array.from({length: 99}, (_, i) => ({number: i + 100, labels: [label]}));
  const input = fixture({pages: [[]], reevaluation: {pages: [[row(42), ...issues], [row(43)]]}});
  const result = await resolveAdmission(input);
  assert.equal(result.code, "admission_conflict");
  assert.deepEqual(input.observations.map((observation) => observation.pageCount), [1, 2]);
  assert.deepEqual(input.observations[1].observedPRNumbers, [42, 43]);
  assert.ok(input.reads.some((read) => read.fresh && read.endpoint.endsWith("page=2")));
});

test("persistent second-page conflict is scanned fully on both evaluations", async () => {
  const issues = Array.from({length: 99}, (_, i) => ({number: i + 100, labels: [label]}));
  const input = fixture({pages: [[row(42), ...issues], [row(43)]]});
  assert.equal((await resolveAdmission(input)).code, "admission_conflict");
  assert.deepEqual(input.observations.map((observation) => observation.pageCount), [2, 2]);
  assert.deepEqual(input.observations.map((observation) => observation.listComplete), [true, true]);
});

for (const [name, reevaluation, code] of [
  ["label", {changePr: {labels: []}}, "awaiting_label"],
  ["head", {changePr: {head: {sha: "c".repeat(40), repo: {full_name: repository}}}}, "stale_head"],
  ["main", {mainSha: "c".repeat(40)}, "stale_main"],
  ["run", {runs: [run(1001), run()]}, "superseded_run"],
  ["closed PR", {changePr: {state: "closed"}}, "ineligible_pr"],
  ["draft", {changePr: {draft: true}}, "draft_pr"],
  ["missing run", {runs: []}, "unverified_run"],
  ["invalid run", {runs: [run("1001"), run()]}, "invalid_run_identity"],
]) {
  test(`a moving ${name} during retry cannot acquire admission`, async () => {
    const input = fixture({pages: [[]], reevaluation: {pages: [[row(42)]], ...reevaluation}});
    const result = await resolveAdmission(input);
    assert.equal(result.admitted, false);
    assert.equal(result.code, code);
    assert.equal(input.observations.length, 2);
    assert.equal(input.observations[1].code, code);
    assert.equal(input.observations[1].retry, false);
  });
}

test("malformed or failed fresh reads never use the earlier snapshot or retry again", async () => {
  for (const reevaluation of [{fail: true}, {pages: [{}]}, {pages: [[{number: 43}]]},
    {changePr: {labels: null}}]) {
    const input = fixture({pages: [[]], reevaluation});
    await assert.rejects(resolveAdmission(input), /API unavailable|Invalid admission list|Missing current PR labels/u);
    assert.equal(input.observations.length, 2);
    assert.equal(input.observations[1].code, "read_error");
    assert.equal(input.observations[1].retry, false);
    assert.equal(input.requested.filter((url) => url.endsWith("/pulls/42")).length, 2);
  }
});

test("pagination bound fails closed with incomplete evidence and no retry", async () => {
  const issues = Array.from({length: 99}, (_, i) => ({number: i + 100, labels: [label]}));
  const input = fixture({pages: Array.from({length: 100}, () => [row(42), ...issues])});
  await assert.rejects(resolveAdmission(input), /Admission pagination exceeded/u);
  assert.equal(input.observations.length, 1);
  assert.equal(input.observations[0].pageCount, 100);
  assert.equal(input.observations[0].listComplete, false);
  assert.equal(input.reads.some((read) => read.fresh), false);
});

test("observations include only safe expected identifiers and observed PR numbers", async () => {
  const input = fixture({changePr: {title: "private-title", body: "private-body"},
    pages: [[{number: 77, labels: [label]}, row(42)]]});
  assert.equal((await resolveAdmission(input)).admitted, true);
  assert.deepEqual(input.observations, [{repository, number: 42, headSha, baseSha, runId,
    evaluation: 1, fresh: false, pageCount: 1, listComplete: true,
    observedPRNumbers: [42], code: "admitted", retry: false}]);
  assert.doesNotMatch(JSON.stringify(input.observations), /private-title|private-body/u);
});

test("paginate all admissions so a later page cannot hide another PR", async () => {
  const issues = Array.from({length: 99}, (_, i) => ({number: i + 100, labels: [label]}));
  const input = fixture({pages: [[row(42), ...issues], [row(43)]]});
  assert.equal((await resolveAdmission(input)).admitted, false);
  assert.ok(input.requested.some((url) => url.endsWith("page=2")));
  assert.equal((await resolveAdmission(fixture({pages: [[row(42), ...issues], []]}))).admitted, true);
});

test("API failures and malformed responses fail closed", async () => {
  await assert.rejects(resolveAdmission(fixture({fail: true})), /API unavailable/u);
  await assert.rejects(resolveAdmission(fixture({pages: [{}]})), /Invalid admission list/u);
  await assert.rejects(resolveAdmission(fixture({pages: [[{number: 43}]]})), /Invalid admission list entry/u);
  await assert.rejects(resolveAdmission(fixture({changePr: {labels: null}})), /Missing current PR labels/u);
  for (const invalid of [null, {number: 0, labels: [label]}, {number: -1, labels: [label]},
    {number: "42", labels: [label]}]) {
    const input = fixture({pages: [[invalid]]});
    await assert.rejects(resolveAdmission(input), /Invalid admission list entry/u);
    assert.equal(input.observations.length, 1);
    assert.equal(input.reads.some((read) => read.fresh), false);
  }
});

test("invalid identities never call GitHub", async () => {
  const input = fixture();
  assert.equal((await resolveAdmission({...input, headSha: "HEAD"})).admitted, false);
  assert.equal((await resolveAdmission({...input, repository: "../other"})).admitted, false);
  assert.equal((await resolveAdmission({...input, headSha: "HEAD"})).code, "invalid_identity");
  assert.equal(input.requested.length, 0);
});

test("final recheck revokes an initially eligible snapshot", async () => {
  const input = fixture();
  assert.equal((await resolveAdmission(input)).admitted, true);
  assert.equal((await resolveAdmission(fixture({changePr: {labels: []}}))).admitted, false);
  assert.equal((await resolveAdmission(fixture({mainSha: "d".repeat(40)}))).admitted, false);
});


test("only the newest admission event for the same head can run expensive checks", async () => {
  const input = fixture({runs: [run(1001), run(1000)]});
  assert.equal((await resolveAdmission(input)).admitted, false);
  assert.equal((await resolveAdmission(input)).code, "superseded_run");
  assert.equal((await resolveAdmission({...input, runId: 1001})).admitted, true);
  assert.equal((await resolveAdmission(fixture({runs: []}))).admitted, false);
});

test("missing current-run evidence is distinct from an observed newer admission", async () => {
  for (const runs of [[], [run(999)]]) {
    const result = await resolveAdmission(fixture({runs}));
    assert.equal(result.admitted, false);
    assert.equal(result.code, "unverified_run");
    assert.match(result.reason, /Current admission run 1000 is absent/u);
  }
  assert.equal((await resolveAdmission(fixture({runs: [run(1001)]}))).code,
    "superseded_run");
});

test("malformed eligible run identities fail closed without claiming a newer run", async () => {
  for (const id of [null, "1001", 0, 1.5, Number.MAX_SAFE_INTEGER + 1]) {
    const result = await resolveAdmission(fixture({runs: [run(id), run()]}));
    assert.equal(result.admitted, false);
    assert.equal(result.code, "invalid_run_identity");
  }
});

test("unrelated labels neither admit nor supersede a current full run", async () => {
  for (const action of ["labeled", "unlabeled"]) {
    assert.equal(isAdmissionEvent({action, label: {name: "documentation"}}), false);
    assert.equal(isAdmissionEvent({action, label: {name: ADMISSION_LABEL}}), true);
  }
  assert.equal(isAdmissionEvent({action: "synchronize"}), true);
  const unrelated = {...run(1001), display_title: "CI pull_request"};
  assert.equal((await resolveAdmission(fixture({runs: [unrelated, run()]}))).admitted, true);
});

test("unrelated events publish a reason code and still block required validation", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-admission-status-"));
  try {
    const eventPath = path.join(root, "event.json");
    const outputPath = path.join(root, "output.txt");
    const summaryPath = path.join(root, "summary.md");
    fs.writeFileSync(eventPath, JSON.stringify({action: "labeled",
      label: {name: "documentation"}}));
    const result = spawnSync(process.execPath,
      ["tool/ci/pr_ci_admission.mjs", "--require"], {
        encoding: "utf8", env: {...process.env, GITHUB_EVENT_PATH: eventPath,
          GITHUB_OUTPUT: outputPath, GITHUB_STEP_SUMMARY: summaryPath},
      });
    assert.equal(result.status, 1);
    assert.match(fs.readFileSync(outputPath, "utf8"),
      /^admitted=false\nreason_code=unrelated_event\n$/u);
    assert.match(fs.readFileSync(summaryPath, "utf8"),
      /PR CI admission \[unrelated_event\]/u);
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
});

test("CLI logs both safe snapshots, bypasses caches on every fresh read and enforces the final decision", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-admission-retry-"));
  const toolPath = path.resolve("tool/ci/pr_ci_admission.mjs");
  const gitEnv = {...process.env, GIT_AUTHOR_NAME: "admission-fixture", GIT_AUTHOR_EMAIL: "fixture@example.test",
    GIT_COMMITTER_NAME: "admission-fixture", GIT_COMMITTER_EMAIL: "fixture@example.test",
    GIT_AUTHOR_DATE: "2026-10-07T00:00:00Z", GIT_COMMITTER_DATE: "2026-10-07T00:00:00Z"};
  const git = (args, input) => execFileSync("git", args, {cwd: root, encoding: "utf8", env: gitEnv, input}).trim();
  try {
    git(["init", "--quiet"]);
    const tree = git(["mktree"], "");
    const actualBase = git(["commit-tree", tree, "-m", "base"]);
    const actualHead = git(["commit-tree", tree, "-p", actualBase, "-m", "head"]);
    const testedMerge = git(["commit-tree", tree, "-p", actualBase, "-p", actualHead, "-m", "tested merge"]);
    const eventPath = path.join(root, "event.json");
    const outputPath = path.join(root, "output.txt");
    const summaryPath = path.join(root, "summary.md");
    const readsPath = path.join(root, "reads.json");
    const preloadPath = path.join(root, "fetch-fixture.mjs");
    fs.writeFileSync(eventPath, JSON.stringify({action: "labeled", label, number: 42,
      pull_request: {head: {sha: actualHead}}}));
    for (const recover of [true, false]) {
      fs.writeFileSync(outputPath, "");
      fs.writeFileSync(summaryPath, "");
      fs.writeFileSync(preloadPath, `import fs from "node:fs";
const config = ${JSON.stringify({repository, actualHead, actualBase, runId, recover, readsPath})};
let evaluation = 0;
const reads = [];
globalThis.fetch = async (url, options) => {
  const endpoint = new URL(url).pathname;
  reads.push({endpoint, cache: options.cache ?? null,
    cacheControl: options.headers["Cache-Control"] ?? null, pragma: options.headers.Pragma ?? null});
  fs.writeFileSync(config.readsPath, JSON.stringify(reads));
  let data;
  if (endpoint.endsWith("/pulls/42")) {
    evaluation += 1;
    data = {number: 42, state: "open", draft: false, labels: [{name: "ci:admitted"}],
      title: "private-title", body: "private-body",
      base: {ref: "main", repo: {full_name: config.repository}},
      head: {sha: config.actualHead, repo: {full_name: config.repository}}};
  } else if (endpoint.endsWith("/branches/main")) {
    data = {commit: {sha: config.actualBase}};
  } else if (endpoint.endsWith("/issues")) {
    data = evaluation === 2 && config.recover ? [{number: 42,
      labels: [{name: "ci:admitted"}], pull_request: {url: "unused"}}] : [];
  } else if (endpoint.endsWith("/runs")) {
    data = {workflow_runs: [{id: config.runId, event: "pull_request", head_sha: config.actualHead,
      path: ".github/workflows/ci.yml", display_title: "CI PR #42"}]};
  } else { throw new Error("Unexpected fixture endpoint"); }
  return {ok: true, json: async () => data};
};
`);
      const result = spawnSync(process.execPath, ["--import", preloadPath, toolPath, "--require"], {
        cwd: root, encoding: "utf8", env: {...process.env, GH_TOKEN: "", GITHUB_EVENT_PATH: eventPath,
          GITHUB_EVENT_NAME: "pull_request", GITHUB_REPOSITORY: repository, GITHUB_SHA: testedMerge,
          GITHUB_RUN_ID: String(runId), GITHUB_OUTPUT: outputPath, GITHUB_STEP_SUMMARY: summaryPath},
      });
      assert.equal(result.status, recover ? 0 : 1, result.stderr);
      assert.equal(fs.readFileSync(outputPath, "utf8"),
        `admitted=${recover}\nreason_code=${recover ? "admitted" : "admission_list_empty"}\n`);
      const observations = result.stdout.split("\n").filter((line) => line.startsWith("PR CI admission observation: "))
        .map((line) => JSON.parse(line.slice("PR CI admission observation: ".length)));
      assert.equal(observations.length, 2);
      assert.deepEqual(observations.map((item) => item.observedPRNumbers), [[], recover ? [42] : []]);
      assert.ok(observations.every((item) => item.headSha === actualHead && item.baseSha === actualBase &&
        item.runId === runId && item.number === 42 && item.repository === repository && item.pageCount === 1));
      const reads = JSON.parse(fs.readFileSync(readsPath, "utf8"));
      assert.ok(reads.slice(0, 3).every((read) => read.cache === null && read.cacheControl === null));
      assert.equal(reads.slice(3).length, recover ? 4 : 3);
      assert.ok(reads.slice(3).every((read) => read.cache === "no-store" &&
        read.cacheControl === "no-cache" && read.pragma === "no-cache"));
      assert.match(fs.readFileSync(summaryPath, "utf8"), /"observedPRNumbers":\[\]/u);
      assert.doesNotMatch(result.stdout + fs.readFileSync(summaryPath, "utf8"), /private-title|private-body|Authorization/u);
    }
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
});
