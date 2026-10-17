import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import {mkdtemp, mkdir, readFile, writeFile, rm, symlink} from "node:fs/promises";
import {tmpdir} from "node:os";
import path from "node:path";
import test from "node:test";
import {assertPinnedDomainRunner, domainServiceFixture, domainFixtureModule, domainProxyUrl, domainScenarioNames, assertNoSymlinks, extractSnapshot, publishCaptures, scenarioNames,
  selectScenarios, validateOutput} from "./rsvpPublicFormSyntheticCapture.mjs";

async function temporary(t) {
  const root = await mkdtemp(path.join(tmpdir(), "rsvp-capture-test-"));
  t.after(() => rm(root, {recursive: true, force: true}));
  return root;
}

test("scenario selection fails closed for empty, unknown, and repeated names", () => {
  assert.deepEqual(selectScenarios(undefined), scenarioNames);
  assert.deepEqual(selectScenarios("purpose-review-mobile, audience-form-desktop"),
    ["purpose-review-mobile", "audience-form-desktop"]);
  for (const invalid of ["", " ", "unknown", "purpose-review-mobile,", "purpose-review-mobile,purpose-review-mobile"]) {
    assert.throws(() => selectScenarios(invalid), /unique known scenarios/);
  }
});

test("renderer snapshot reads committed dependencies even when the source checkout is dirty", async (t) => {
  const root = await temporary(t);
  const source = path.join(root, "repo");
  const snapshot = path.join(root, "snapshot");
  await mkdir(source); await mkdir(snapshot);
  const git = (...args) => execFileSync("git", args, {cwd: source, encoding: "utf8"}).trim();
  git("init", "-q");
  git("config", "user.name", "Fixture"); git("config", "user.email", "fixture@example.com");
  git("config", "core.hooksPath", "/dev/null");
  for (const file of ["package.json", "package-lock.json", "admin/package.json", "website/src/shared/ui/primitives.ts", "packages/web-config/styles/tokens.css", "functions/src/shared/generated/fixture.ts"]) {
    await mkdir(path.dirname(path.join(source, file)), {recursive: true});
    await writeFile(path.join(source, file), file.endsWith("json") ? "{}" : "committed content");
  }
  git("add", "."); git("commit", "-qm", "Pinned renderer fixture");
  const sha = git("rev-parse", "HEAD");
  await writeFile(path.join(source, "website/src/shared/ui/primitives.ts"), "DIRTY renderer");
  await writeFile(path.join(source, "packages/web-config/styles/tokens.css"), "DIRTY shared tokens");
  await writeFile(path.join(source, "website/src/untracked.ts"), "untracked renderer");
  const result = extractSnapshot(source, sha, snapshot, path.join(root, "snapshot.tar"));
  assert.equal(result.sourceSha, sha);
  assert.equal(result.sourceTree, git("rev-parse", "HEAD^{tree}"));
  assert.match(result.packageLockSha256, /^[a-f0-9]{64}$/);
  assert.equal(await readFile(path.join(snapshot, "website/src/shared/ui/primitives.ts"), "utf8"), "committed content");
  assert.equal(await readFile(path.join(snapshot, "packages/web-config/styles/tokens.css"), "utf8"), "committed content");
  await assert.rejects(readFile(path.join(snapshot, "website/src/untracked.ts")), {code: "ENOENT"});
  assert.throws(() => extractSnapshot(source, "HEAD", snapshot, path.join(root, "invalid.tar")), /full commit SHA/);
});

test("archived source cannot escape through a symlink", async (t) => {
  const root = await temporary(t);
  await symlink(tmpdir(), path.join(root, "outside"));
  assert.throws(() => assertNoSymlinks(root), /contains a symlink/);
});

test("capture output must be a fresh absolute directory", async (t) => {
  const root = await temporary(t);
  assert.throws(() => validateOutput("relative", root), /absolute new directory/);
  assert.throws(() => validateOutput(root, root), /already exists/);
  assert.doesNotThrow(() => validateOutput(path.join(root, "result"), path.join(root, "elsewhere")));
});

test("partial selection publishes its exact manifest alongside captures and preserves existing evidence", async (t) => {
  const root = await temporary(t);
  const staging = path.join(root, "staging");
  const output = path.join(root, "output");
  await mkdir(staging);
  await writeFile(path.join(staging, "purpose-review-mobile.png"), "synthetic screenshot bytes");
  const manifest = {sourceSha: "a".repeat(40), scenarios: [{name: "purpose-review-mobile", file: "purpose-review-mobile.png"}]};
  await publishCaptures(staging, output, manifest);
  assert.deepEqual(JSON.parse(await readFile(path.join(output, "manifest.json"), "utf8")), manifest);
  await assert.rejects(readFile(path.join(staging, "manifest.json")), {code: "ENOENT"});
  const next = path.join(root, "next"); await mkdir(next);
  await assert.rejects(publishCaptures(next, output, {sourceSha: "b".repeat(40)}), /refusing to replace/);
  assert.deepEqual(JSON.parse(await readFile(path.join(output, "manifest.json"), "utf8")), manifest);
});


test("domain scenarios are explicit and cannot borrow the visual controller fixture", () => {
  assert.deepEqual(selectScenarios(undefined), scenarioNames);
  assert.deepEqual(selectScenarios(domainScenarioNames.join(",")), domainScenarioNames);
  assert.throws(() => selectScenarios(`${scenarioNames[0]},${domainScenarioNames[0]}`), /separate batches/);
  assert.throws(() => selectScenarios(`${domainScenarioNames[0]},${domainScenarioNames[0]}`), /unique known/);
});

test("virtual custom-host requests can reach only the exact loopback fixture", () => {
  const local = "http://127.0.0.1:43210";
  assert.equal(domainProxyUrl("http://forms.client.example/f/other-public?fixture=1", local),
    `${local}/f/other-public?fixture=1`);
  for (const url of ["https://forms.client.example/f/a", "http://other.client.example/f/a",
    "http://forms.client.example.evil.test/f/a", "http://forms.client.example:3000/f/a",
    "http://user:password@forms.client.example/f/a", "http://127.0.0.1:43210/f/a",
    "https://firestore.googleapis.com/v1/projects/live", "file:///etc/passwd"]) {
    assert.equal(domainProxyUrl(url, local), null, url);
  }
  for (const origin of ["https://127.0.0.1:43210", "http://localhost:43210", "http://remote.test:43210",
    "http://127.0.0.1:43210/path", "http://user@127.0.0.1:43210", "http://127.0.0.1:43210/?x=1"]) {
    assert.throws(() => domainProxyUrl("http://forms.client.example/f/a", origin), /exact loopback/);
  }
});

test("anonymous synthetic service refuses wrong owners, stale revisions and missing consent", async () => {
  const api = domainServiceFixture();
  const publicInput = {publicFormId: "bound-public", sourceToken: null};
  await assert.rejects(api.getPublicOrganizerForm({...publicInput, publicFormId: "other"}), /Wrong synthetic form/);
  await assert.rejects(api.beginOrganizerFormResponse({...publicInput, sourceToken: "other", requestId: "start"}), /Wrong synthetic form/);
  await assert.rejects(api.beginOrganizerFormResponse(publicInput), /Missing synthetic start/);
  const form = await api.getPublicOrganizerForm(publicInput);
  form.definition.title = "Caller mutation";
  assert.equal((await api.getPublicOrganizerForm(publicInput)).definition.title, "Synthetic client application");
  const draft = await api.beginOrganizerFormResponse({...publicInput, requestId: "start"});
  const payload = {draftId: draft.draftId, draftToken: draft.draftToken,
    expectedRevision: draft.revision, requestId: "submit"};
  await assert.rejects(api.submitOrganizerFormResponse(payload), /lacks reviewed answer/);
  await assert.rejects(api.saveOrganizerFormResponseDraft({...payload, draftToken: "wrong"}), /Wrong synthetic draft/);
  const saved = await api.saveOrganizerFormResponseDraft({...payload,
    answers: {name: "Synthetic respondent"}, consentAccepted: false});
  await assert.rejects(api.submitOrganizerFormResponse({...payload, expectedRevision: saved.revision}), /lacks reviewed answer/);
  await assert.rejects(api.saveOrganizerFormResponseDraft({...payload,
    answers: {name: "Synthetic respondent"}, consentAccepted: true}), /Wrong synthetic draft/);
  const accepted = await api.saveOrganizerFormResponseDraft({...payload,
    expectedRevision: saved.revision, answers: {name: "Synthetic respondent"}, consentAccepted: true});
  const receipt = await api.submitOrganizerFormResponse({...payload, expectedRevision: accepted.revision});
  assert.equal(receipt.formId, "bound-form");
  assert.equal(receipt.versionId, "bound-version");
  assert.equal(receipt.status, "submitted");
  assert.equal(api.calls.filter((call) => call.name === "submit").length, 1);
  assert.throws(() => api.prepareOrganizerFormPayment({}), /Unexpected provider operation/);
  assert.throws(() => api.beginPublicEventPhoneVerification({}), /Unexpected provider operation/);
  assert.deepEqual(domainServiceFixture().calls, []);
});

test("generated browser fixture module has only synthetic callable exports", async () => {
  const previous = globalThis.window;
  try {
    globalThis.window = {};
    const source = domainFixtureModule();
    const module = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`);
    assert.equal(typeof module.getPublicOrganizerForm, "function");
    const state = await module.getPublicOrganizerForm({publicFormId: "bound-public", sourceToken: null});
    assert.equal(state.formId, "bound-form");
    assert.deepEqual(globalThis.window.__domainCalls.map((call) => call.name), ["get"]);
    assert.equal(Object.hasOwn(module, "usePublicFormController"), false);
  } finally {
    if (previous === undefined) delete globalThis.window;
    else globalThis.window = previous;
  }
});

test("domain runner bytes must match the committed renderer snapshot", async (t) => {
  const root = await temporary(t);
  const source = path.join(root, "website/scripts");
  await mkdir(source, {recursive: true});
  const pinned = path.join(source, "rsvpPublicFormSyntheticCapture.mjs");
  const runner = path.join(root, "runner.mjs");
  await writeFile(pinned, "committed runner");
  await writeFile(runner, "committed runner");
  assert.doesNotThrow(() => assertPinnedDomainRunner(root, runner));
  await writeFile(runner, "uncommitted fixture mutation");
  assert.throws(() => assertPinnedDomainRunner(root, runner), /exact committed source/);
});
