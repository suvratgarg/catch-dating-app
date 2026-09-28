import assert from "node:assert/strict";
import {readFileSync, mkdtempSync, writeFileSync, rmSync} from "node:fs";
import {tmpdir} from "node:os";
import {resolve} from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {createRevenuePreflight, MAX_INPUT_BYTES} from
  "../src/domains/host-revenue/preflight.mjs";
import {readBoundedInput} from "../src/domains/host-revenue/preflight-cli.mjs";

const fixturePath = fileURLToPath(new URL("../src/domains/host-revenue/fixtures/normalized-review.json", import.meta.url));
const cliPath = fileURLToPath(new URL("../src/domains/host-revenue/preflight-cli.mjs", import.meta.url));
const repoRoot = resolve(fileURLToPath(new URL("../../", import.meta.url)));
const policyPath = fileURLToPath(new URL("../src/domains/host-revenue/fixtures/example-policy.json", import.meta.url));
const {policy: FIT_POLICY, evaluateFit, preflightJson} = createRevenuePreflight(JSON.parse(readFileSync(policyPath, "utf8")));
const fixture = JSON.parse(readFileSync(fixturePath, "utf8"));
const copy = (value) => structuredClone(value);
const report = (value) => preflightJson(Buffer.from(JSON.stringify(value)));
const codes = (row) => row.reviewReasons.map(({code}) => code);

test("canonical shadow weights and complete factor arithmetic", () => {
  assert.deepEqual(FIT_POLICY.factors.map(({id, weight}) => [id, weight]), [
    ["fragmentation", 14], ["spend", 14], ["consolidation", 14],
    ["recurrence", 14], ["complexity", 14], ["buyerAccess", 14], ["productFit", 16],
  ]);
  assert.equal(FIT_POLICY.factors.reduce((sum, factor) => sum + factor.weight, 0), 100);
  assert.equal(FIT_POLICY.status, "shadow");
  const base = copy(fixture.rows[0].factors);
  const withValues = (value) => Object.fromEntries(Object.entries(base).map(([id, factor]) =>
    [id, {...factor, value}]));
  assert.equal(evaluateFit(withValues(5)).score, 100);
  assert.equal(evaluateFit(withValues(0)).score, 0);
  for (const {id, weight} of FIT_POLICY.factors) {
    const factors = withValues(0);
    factors[id].value = 5;
    assert.equal(evaluateFit(factors).score, weight, id);
  }
  assert.throws(() => { FIT_POLICY.factors[0].weight = 1; }, TypeError);
});

test("unknown is explicit and null; direct evaluator rejects malformed factors", () => {
  const factors = copy(fixture.rows[0].factors);
  factors.spend = {state: "unknown", reason: "Spend unobserved"};
  assert.deepEqual(evaluateFit(factors).missingFactors, ["spend"]);
  assert.equal(evaluateFit(factors).score, null);
  for (const bad of [
    (f) => { delete f.spend; },
    (f) => { f.spend.value = -1; },
    (f) => { f.spend.value = 6; },
    (f) => { f.spend.value = 1.5; },
    (f) => { f.spend.value = "NaN"; },
    (f) => { f.spend.value = Number.NaN; },
    (f) => { f.engagement = {state: "known", value: 5, evidenceRefs: ["river-id"]}; },
    (f) => { f.spend = {state: "unknown"}; },
  ]) {
    const invalid = copy(fixture.rows[0].factors);
    bad(invalid);
    assert.throws(() => evaluateFit(invalid), /Invalid factors/);
  }
});

test("fixture is useful, deterministic, and never grants outreach authority", () => {
  const bytes = readFileSync(fixturePath);
  const first = preflightJson(bytes);
  assert.deepEqual(preflightJson(bytes), first);
  assert.match(first.inputHash, /^[a-f0-9]{64}$/);
  assert.equal(first.effectsApplied, false);
  assert.equal(first.runtimeAuthority, "read_only");
  assert.equal(first.rows[0].fit.score, 63.2);
  assert.equal(first.rows[0].evidence.sufficient, true);
  assert.equal(first.rows[0].outreachEligibility.status, "not_assessed");
  assert.equal(first.rows[1].fit.score, null);
  assert.equal(first.rows[1].fit.status, "needsResearch");
  assert.deepEqual(first.rows[1].cohortIds, ["sample-a", "sample-b"]);
  assert.deepEqual(first.rows[1].historicalScores[0].original, {total: 43, unit: "source_sheet_points"});
  assert.equal(first.rows[1].historicalScores[0].comparableToCurrent, false);
  assert.ok(codes(first.rows[1]).includes("unsupported_historical_model"));
  assert.ok(first.rows.every((row) => ["blocked", "not_assessed"].includes(row.outreachEligibility.status)));
});

test("documented eight-factor historical object keeps buyerAccess without comparison", () => {
  const input = copy(fixture);
  input.rows[0].historicalScores = [{
    modelId: "example-history", modelVersion: "example-v1",
    original: {fragmentation: 4, replacement: 3, buyerAccess: 2, engagement: 1,
      sourceBand: "P2"},
  }];
  const result = report(input).rows[0];
  assert.equal(result.disposition, "evaluated");
  assert.equal(result.historicalScores[0].support, "documented_historical");
  assert.equal(result.historicalScores[0].original.buyerAccess, 2);
  assert.equal(result.historicalScores[0].comparableToCurrent, false);
});

test("duplicate source rows and canonical organizer across cohorts require reconciliation", () => {
  const input = copy(fixture);
  const same = copy(input.rows[0]);
  same.sourceRowId = "new-row";
  same.sourceRef.location = "Sample B!3";
  same.cohortIds = ["sample-b"];
  input.rows.push(same);
  let result = report(input);
  assert.ok(result.rows.slice(0, 1).every((row) => codes(row).includes("repeated_organizer_id")));
  assert.ok(codes(result.rows[2]).includes("repeated_organizer_id"));
  assert.equal(result.rows[2].disposition, "review_required");
  assert.deepEqual(result.rows[2].cohortIds, ["sample-b"]);
  input.rows[2].sourceRowId = input.rows[0].sourceRowId;
  result = report(input);
  assert.ok(codes(result.rows[0]).includes("duplicate_source_row_id"));
  assert.ok(codes(result.rows[2]).includes("duplicate_source_row_id"));
  assert.equal(result.rows[0].disposition, "invalid_input");
});

test("duplicate source identity still invalidates a valid peer when the other row has bad factors", () => {
  const input = copy(fixture);
  const malformed = copy(input.rows[0]);
  malformed.factors.spend.value = 7;
  input.rows.push(malformed);
  const result = report(input);
  assert.ok(codes(result.rows[0]).includes("duplicate_source_row_id"));
  assert.ok(codes(result.rows[2]).includes("duplicate_source_row_id"));
  assert.equal(result.rows[0].disposition, "invalid_input");
  assert.equal(result.rows[0].fit, null);
});

test("explicit identity conflicts and evidence conflicts are surfaced, never merged", () => {
  const input = copy(fixture);
  const second = copy(input.rows[0]);
  second.sourceRowId = "other-row";
  second.organizerId = "org-other";
  second.sourceRef.location = "Sample C!13";
  input.rows.push(second);
  let result = report(input);
  assert.ok(codes(result.rows[0]).includes("conflicting_identity_key"));
  assert.ok(codes(result.rows[2]).includes("conflicting_identity_key"));
  input.rows[2].identityKeys = [{kind: "domain", value: "other.example"}];
  input.rows[2].evidenceRefs[0].sourceRef.location = "different";
  result = report(input);
  assert.ok(codes(result.rows[0]).includes("conflicting_evidence"));
  assert.ok(codes(result.rows[2]).includes("conflicting_evidence"));
  assert.equal(result.rows[2].disposition, "invalid_input");
});

test("organizer and candidate IDs cannot collide through their string prefix", () => {
  const input = copy(fixture);
  input.rows[0].organizerId = "candidate:foo";
  const candidate = copy(input.rows[0]);
  delete candidate.organizerId;
  candidate.candidateId = "foo";
  candidate.sourceRowId = "candidate-foo-row";
  candidate.sourceRef.location = "Sample C!15";
  input.rows.push(candidate);
  const result = report(input);
  assert.ok(codes(result.rows[0]).includes("conflicting_identity_key"));
  assert.ok(codes(result.rows[2]).includes("conflicting_identity_key"));
  assert.equal(result.rows[0].outreachEligibility.status, "blocked");
});

test("evidence equality ignores JSON object-key order locally and across rows", () => {
  const input = copy(fixture);
  const reordered = copy(input.rows[0].evidenceRefs[0]);
  reordered.sourceRef = {location: reordered.sourceRef.location,
    documentId: reordered.sourceRef.documentId, sourceId: reordered.sourceRef.sourceId};
  input.rows[0].evidenceRefs.push(reordered);
  const other = copy(input.rows[0]);
  other.sourceRowId = "other-evidence-row";
  other.sourceRef.location = "Sample C!14";
  other.organizerId = "org-other-evidence";
  other.identityKeys = [{kind: "domain", value: "other-evidence.example"}];
  other.evidenceRefs = [reordered, ...other.evidenceRefs.slice(1)];
  input.rows.push(other);
  const result = report(input);
  assert.ok(result.rows.every((row) => !codes(row).includes("conflicting_evidence")));
  assert.equal(result.rows[0].disposition, "evaluated");
  assert.equal(result.rows[2].disposition, "evaluated");
});

test("malformed evidence entries are reported without crashing or tainting valid peers", () => {
  for (const badEntry of [null, {evidenceId: "river-id", sourceRef: "invalid"}]) {
    const input = copy(fixture);
    const malformed = copy(input.rows[0]);
    malformed.sourceRowId = "malformed-evidence-row";
    malformed.organizerId = "org-malformed-evidence";
    malformed.identityKeys = [];
    malformed.evidenceRefs.unshift(badEntry);
    input.rows.push(malformed);
    const result = report(input);
    assert.equal(result.rows[0].disposition, "evaluated");
    assert.equal(result.rows[2].disposition, "invalid_input");
    assert.ok(codes(result.rows[2]).includes("invalid_input"));
    assert.ok(!codes(result.rows[0]).includes("conflicting_evidence"));
  }
});

test("missing references and duplicated operating source do not imply evidence sufficiency", () => {
  const missing = copy(fixture);
  missing.rows[0].factors.spend.evidenceRefs = ["missing-ref"];
  const invalid = report(missing).rows[0];
  assert.ok(codes(invalid).includes("missing_evidence_ref"));
  assert.equal(invalid.fit, null);
  assert.equal(invalid.sourcePointer.location, "Sample C!12");
  const duplicateSource = copy(fixture);
  duplicateSource.rows[0].evidenceRefs[3].sourceRootId = "river-form";
  const reviewed = report(duplicateSource).rows[0];
  assert.equal(reviewed.evidence.distinctOperatingSignals, 2);
  assert.equal(reviewed.evidence.distinctOperatingSources, 1);
  assert.equal(reviewed.evidence.sufficient, false);
  assert.equal(reviewed.outreachEligibility.status, "blocked");
  const duplicateSignal = copy(fixture);
  duplicateSignal.rows[0].qualification.operatingSignals[1].signalId = "applications";
  const sameSignal = report(duplicateSignal).rows[0];
  assert.equal(sameSignal.evidence.distinctOperatingSignals, 1);
  assert.equal(sameSignal.evidence.distinctOperatingSources, 2);
  assert.equal(sameSignal.evidence.sufficient, false);
  assert.equal(sameSignal.outreachEligibility.status, "blocked");
});

test("strict rows reject missing factor, unknown fields, security fields and bad ratings", () => {
  for (const edit of [
    (row) => { delete row.factors.productFit; },
    (row) => { row.factors.spend.value = 1.2; },
    (row) => { row.factors.spend.value = 6; },
    (row) => { row.factors.spend.value = "NaN"; },
    (row) => { row.factors.spend.send = true; },
    (row) => { row.paymentStatus = "paid"; },
    (row) => { row.qualification.owner = "someone"; },
    (row) => { row.historicalScores = [{modelId: "legacy", modelVersion: "v1", original: {nested: {publish: true}}}]; },
    (row) => { row.historicalScores = [{modelId: "legacy", modelVersion: "v1", original: {nested: {ownerId: "x"}}}]; },
    (row) => { row.historicalScores = [{modelId: "legacy", modelVersion: "v1", original: {nested: {sendNow: true}}}]; },
  ]) {
    const input = copy(fixture);
    edit(input.rows[0]);
    const result = report(input).rows[0];
    assert.equal(result.disposition, "invalid_input");
    assert.equal(result.fit, null);
    assert.equal(result.outreachEligibility.status, "blocked");
  }
});

test("bounded bytes and rows; actual npm command reads fixture and rejects oversized input", () => {
  assert.throws(() => preflightJson(Buffer.alloc(MAX_INPUT_BYTES + 1, 0x20)), /exceeds/);
  const tooMany = {schemaVersion: 1, rows: Array(501).fill(null)};
  assert.throws(() => report(tooMany), /Invalid input envelope/);
  const cli = spawnSync("npm", ["--silent", "--prefix", "operations", "run", "revenue:preflight",
    "--", "--input", fixturePath, "--policy", policyPath], {cwd: repoRoot, encoding: "utf8"});
  assert.equal(cli.status, 0, cli.stderr);
  assert.equal(JSON.parse(cli.stdout).rows[0].fit.score, 63.2);
  const dir = mkdtempSync(resolve(tmpdir(), "host-revenue-preflight-"));
  try {
    const file = resolve(dir, "oversized.json");
    writeFileSync(file, Buffer.alloc(MAX_INPUT_BYTES + 1, 0x20));
    const bad = spawnSync(process.execPath, [cliPath, "--input", file, "--policy", policyPath], {encoding: "utf8"});
    assert.equal(bad.status, 1);
    assert.match(bad.stderr, /exceeds/);
    assert.equal(bad.stdout, "");
  } finally { rmSync(dir, {recursive: true, force: true}); }
});

test("opened file read remains bounded even when content grows past initial stat", async () => {
  let readCalls = 0;
  const growingFile = {
    stat: async () => ({isFile: () => true, size: 1}),
    read: async (buffer, offset, length) => {
      readCalls++;
      assert.ok(buffer.length <= MAX_INPUT_BYTES + 1);
      buffer.fill(0x20, offset, offset + length);
      return {bytesRead: length};
    },
  };
  await assert.rejects(readBoundedInput(growingFile), /exceeds/);
  assert.equal(readCalls, 1);
  assert.throws(() => preflightJson(Buffer.from([0xff])), /valid UTF-8 JSON/);
});

test("CLI rejects a FIFO promptly without waiting for a writer", {skip: process.platform === "win32"}, () => {
  const dir = mkdtempSync(resolve(tmpdir(), "host-revenue-fifo-"));
  try {
    const fifo = resolve(dir, "input.fifo");
    const made = spawnSync("mkfifo", [fifo], {encoding: "utf8"});
    assert.equal(made.status, 0, made.stderr);
    const result = spawnSync(process.execPath, [cliPath, "--input", fifo, "--policy", policyPath],
      {encoding: "utf8", timeout: 1_500});
    assert.equal(result.status, 1, result.error?.message ?? result.stderr);
    assert.match(result.stderr, /regular file/);
  } finally { rmSync(dir, {recursive: true, force: true}); }
});


test("private policy is mandatory and independent evaluator instances cannot share weights", () => {
  const configuration = copy(FIT_POLICY);
  const other = copy(FIT_POLICY);
  other.factors[0].weight += 1;
  other.factors[1].weight -= 1;
  const evaluator = createRevenuePreflight(configuration);
  const alternate = createRevenuePreflight(other);
  configuration.factors[0].weight = 1;
  assert.equal(evaluator.policy.factors[0].weight, 14);
  assert.notEqual(evaluator.preflightJson(readFileSync(fixturePath)).policy.hash,
    alternate.preflightJson(readFileSync(fixturePath)).policy.hash);
  for (const invalid of [null, {}, {...copy(FIT_POLICY), arbitrary: true},
    {...copy(FIT_POLICY), status: "active"},
    {...copy(FIT_POLICY), factors: []},
    {...copy(FIT_POLICY), modelId: "x".repeat(97)}]) {
    assert.throws(() => createRevenuePreflight(invalid), /Invalid bounded/);
  }
  const missing = spawnSync(process.execPath, [cliPath, "--input", fixturePath], {encoding: "utf8"});
  assert.equal(missing.status, 1);
  assert.match(missing.stderr, /--policy/);
  assert.equal(missing.stdout, "");
});
