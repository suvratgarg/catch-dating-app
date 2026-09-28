import test from "node:test";
import assert from "node:assert/strict";
import {ADMISSION_LABEL, isAdmissionEvent, resolveAdmission} from "./pr_ci_admission.mjs";

const repository = "example/catch";
const headSha = "a".repeat(40);
const baseSha = "b".repeat(40);
const runId = 1000;
const run = (id = runId) => ({id, event: "pull_request", head_sha: headSha, path: ".github/workflows/ci.yml", display_title: "CI PR #42"});
const label = {name: ADMISSION_LABEL};
const row = (number) => ({number, labels: [label], pull_request: {url: "unused"}});
function fixture({changePr = {}, mainSha = baseSha, pages = [[row(42)]], runs = [run()], fail = false} = {}) {
  const pr = {number: 42, state: "open", draft: false, labels: [label],
    base: {ref: "main", repo: {full_name: repository}},
    head: {sha: headSha, repo: {full_name: repository}}, ...changePr};
  const requested = [];
  const request = async (endpoint) => {
    requested.push(endpoint);
    if (fail) throw new Error("API unavailable");
    if (endpoint.endsWith("/pulls/42")) return pr;
    if (endpoint.endsWith("/branches/main")) return {commit: {sha: mainSha}};
    if (endpoint.includes("/actions/workflows/")) return {workflow_runs: runs};
    const page = Number(new URL(`https://api.github.com/${endpoint}`).searchParams.get("page"));
    assert.ok(page > 0);
    return pages[page - 1] ?? [];
  };
  return {repository, number: 42, headSha, baseSha, runId, request, requested};
}

test("only the sole admitted ready PR on exact head and main can validate", async () => {
  assert.equal((await resolveAdmission(fixture())).admitted, true);
});

for (const [name, options] of [
  ["label removed or ordinary unadmitted update", {changePr: {labels: []}}],
  ["draft converted while waiting", {changePr: {draft: true}}],
  ["closed PR", {changePr: {state: "closed"}}],
  ["new head after queued event", {changePr: {head: {sha: "c".repeat(40), repo: {full_name: repository}}}}],
  ["main advanced since tested merge", {mainSha: "c".repeat(40)}],
  ["different target branch", {changePr: {base: {ref: "release", repo: {full_name: repository}}}}],
  ["foreign head repository", {changePr: {head: {sha: headSha, repo: {full_name: "other/catch"}}}}],
  ["zero labels after state changed between reads", {pages: [[]]}],
  ["two PRs admitted", {pages: [[row(42), row(43)]]}],
]) {
  test(`deny ${name}`, async () => assert.equal((await resolveAdmission(fixture(options))).admitted, false));
}

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
});

test("invalid identities never call GitHub", async () => {
  const input = fixture();
  assert.equal((await resolveAdmission({...input, headSha: "HEAD"})).admitted, false);
  assert.equal((await resolveAdmission({...input, repository: "../other"})).admitted, false);
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
  assert.equal((await resolveAdmission({...input, runId: 1001})).admitted, true);
  assert.equal((await resolveAdmission(fixture({runs: []}))).admitted, false);
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
