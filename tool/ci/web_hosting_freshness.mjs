#!/usr/bin/env node

import fs from "node:fs";

const shaPattern = /^[0-9a-f]{40}$/u;
const idPattern = /^[1-9][0-9]*$/u;

function safeId(value) {
  const text = value == null ? "" : String(value);
  return idPattern.test(text) ? text : "<invalid>";
}

function safeSha(value) {
  return typeof value === "string" && shaPattern.test(value)
    ? value
    : "<invalid>";
}

function safeLabel(value) {
  return typeof value === "string" && /^[A-Za-z0-9._/-]{1,64}$/u.test(value)
    ? value
    : "<invalid>";
}

function safeInteger(value) {
  return Number.isSafeInteger(value) && value > 0 ? value : null;
}

function projectRun(run) {
  return {
    id: safeId(run?.id),
    runNumber: safeInteger(run?.runNumber),
    sha: safeSha(run?.sha),
    branch: safeLabel(run?.branch),
    event: safeLabel(run?.event),
  };
}

/** Evaluate every existing last-moment source/freshness predicate. */
export function evaluatePromotionFreshness(evidence) {
  const expected = evidence?.expected ?? {};
  const actual = evidence?.actual ?? {};
  const sourceRun = actual.sourceRun ?? {};
  const latestRuns = Array.isArray(actual.latestRuns) ? actual.latestRuns : [];
  const latest = latestRuns.length === 1 ? latestRuns[0] : {};
  const expectedRunId = String(expected.runId ?? "");
  const expectedSourceSha = expected.sourceSha;
  const expectedAttempt = expected.runAttempt;
  const expectedRunNumber = expected.runNumber;
  const sourceMainSha = actual.mainSha;

  const checks = {
    sourceShaFormat: typeof expectedSourceSha === "string" &&
      shaPattern.test(expectedSourceSha),
    sourceIsAncestorOfMain: actual.sourceIsAncestor === true,
    recoverySourceEqualsCurrentMain: expected.recovery !== true ||
      sourceMainSha === expectedSourceSha,
    producerRunIdentity: String(sourceRun.id ?? "") === expectedRunId,
    producerAttempt: sourceRun.runAttempt === expectedAttempt,
    producerSourceSha: sourceRun.headSha === expectedSourceSha,
    producerEvent: sourceRun.event === "push",
    producerBranch: sourceRun.branch === "main",
    latestRunCountIsOne: latestRuns.length === 1,
    latestRunIdentity: String(latest.id ?? "") === expectedRunId,
    latestRunNumber: latest.runNumber === expectedRunNumber,
    latestRunSourceSha: latest.sha === expectedSourceSha,
    latestRunBranch: latest.branch === "main",
    latestRunEvent: latest.event === "push",
  };
  const expectedView = {
    sourceSha: safeSha(expectedSourceSha),
    runId: safeId(expected.runId),
    runAttempt: safeInteger(expectedAttempt),
    workflowId: safeId(expected.workflowId),
    runNumber: safeInteger(expectedRunNumber),
    recovery: expected.recovery === true,
  };
  const actualView = {
    mainSha: safeSha(sourceMainSha),
    sourceIsAncestor: actual.sourceIsAncestor === true,
    sourceRun: {
      id: safeId(sourceRun.id),
      runAttempt: safeInteger(sourceRun.runAttempt),
      headSha: safeSha(sourceRun.headSha),
      event: safeLabel(sourceRun.event),
      branch: safeLabel(sourceRun.branch),
    },
    latestRunCount: latestRuns.length,
    // The GitHub endpoint is requested with per_page=1; cap diagnostic output
    // if an unexpected/malformed response returns an unbounded array.
    latestRuns: latestRuns.slice(0, 2).map(projectRun),
  };
  const failedChecks = Object.entries(checks)
    .filter(([, passed]) => passed !== true)
    .map(([name]) => name);

  return {
    passed: failedChecks.length === 0,
    failedChecks,
    checks,
    expected: expectedView,
    actual: actualView,
  };
}

if (process.argv[2] === "evaluate") {
  try {
    const evidence = JSON.parse(fs.readFileSync(0, "utf8"));
    process.stdout.write(`${JSON.stringify(evaluatePromotionFreshness(evidence))}\n`);
  } catch {
    // Never echo source API responses, malformed payloads, or environment data.
    process.stdout.write(`${JSON.stringify({
      passed: false,
      failedChecks: ["evidenceCouldNotBeEvaluated"],
      checks: {evidenceCouldNotBeEvaluated: false},
      expected: null,
      actual: null,
    })}\n`);
  }
} else if (process.argv[1] === new URL(import.meta.url).pathname) {
  process.stderr.write("Usage: node web_hosting_freshness.mjs evaluate < evidence.json\n");
  process.exitCode = 64;
}
