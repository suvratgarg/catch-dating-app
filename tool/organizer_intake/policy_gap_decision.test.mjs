import assert from "node:assert/strict";
import {execFile} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {promisify} from "node:util";

const execFileAsync = promisify(execFile);
const testDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(testDir, "..", "..");
const cliPath = path.join(testDir, "policy_gap_decision.mjs");

test("policy gap dry-run ignores existing decisions", async () => {
  const fixture = writeFixture({withExistingDecision: true});

  const result = await runDraft(fixture, ["--dry-run"]);

  assert.match(result.stdout, /Would write/);
  assert.match(result.stdout, /"gapId": "recurring_event_crawl_policy"/);
  assert.equal(result.stderr, "");
});

test("policy gap write rejects duplicate decisions", async () => {
  const fixture = writeFixture({withExistingDecision: true});

  await assert.rejects(
    () => runDraft(fixture),
    (error) => {
      assert.equal(error.code, 1);
      assert.match(error.stderr, /already exists/);
      assert.match(error.stderr, /existing-policy-decision\.json/);
      return true;
    }
  );
});

async function runDraft(fixture, extraArgs = []) {
  return execFileAsync(process.execPath, [
    cliPath,
    "draft",
    "recurring_event_crawl_policy",
    "--decision",
    "hold",
    "--reviewer",
    "codex-dry-run",
    "--date",
    "2026-06-17",
    "--note",
    "Need budget decision.",
    "--register",
    fixture.registerPath,
    "--decisions-root",
    fixture.decisionsRoot,
    ...extraArgs,
  ], {cwd: repoRoot});
}

function writeFixture({withExistingDecision = false} = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "policy-gap-decision-"));
  const registerPath = path.join(root, "organizer_policy_gap_register.json");
  const decisionsRoot = path.join(root, "policy_gap_decisions");
  fs.mkdirSync(decisionsRoot, {recursive: true});

  fs.writeFileSync(registerPath, `${JSON.stringify({
    summary: {
      gaps: 1,
      decisionRequired: 1,
      reviewDecisions: withExistingDecision ? 1 : 0,
    },
    gaps: [
      {
        gapId: "recurring_event_crawl_policy",
        area: "crawl",
        severity: "high",
        status: "decision_required",
        decisionStatus: withExistingDecision ? "held" : "not_reviewed",
        requiredInputs: ["budget cap"],
      },
    ],
  }, null, 2)}\n`);

  if (withExistingDecision) {
    fs.writeFileSync(
      path.join(decisionsRoot, "existing-policy-decision.json"),
      `${JSON.stringify({
        schemaVersion: 1,
        policyGapDecisionBatchId: "existing-policy-decision",
        decidedAt: "2026-06-18",
        reviewer: "fixture",
        decisions: [
          {
            gapId: "recurring_event_crawl_policy",
            decision: "hold",
            requiredInputsReviewed: [],
            note: "Already held.",
          },
        ],
      }, null, 2)}\n`
    );
  }

  return {registerPath, decisionsRoot};
}
