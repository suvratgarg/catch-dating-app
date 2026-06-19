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
const cliPath = path.join(testDir, "review_decision.mjs");

test("review decision draft requires and consumes ready publication packet", async () => {
  const fixture = writeFixture({
    packetOverrides: {
      evidenceSummary: {manualReportsWithoutArtifacts: 1},
    },
  });

  const result = await runDraft(fixture, [
    "--confirm-publication-checklist",
    "--confirm-manual-reports-reviewed",
  ]);

  assert.match(result.stdout, /Would write/);
  assert.match(result.stdout, /"decision": "approve_public"/);
  assert.match(result.stdout, /"crawlDisabledReviewed": true/);
  assert.match(result.stdout, /"manualReportsReviewed": true/);
  assert.match(result.stdout, /"appVisibility": "hidden"/);
});

test("review decision dry-run ignores existing generated decisions", async () => {
  const fixture = writeFixture({
    itemOverrides: {
      reviewDecision: {decision: "approve_public"},
    },
    packetOverrides: {
      status: "published",
      adminDecision: {
        allowedDecisions: ["approve_public", "hold", "suppress"],
        currentDecision: {decision: "approve_public"},
      },
    },
  });

  const result = await runDraft(fixture, [
    "--confirm-publication-checklist",
    "--confirm-manual-reports-reviewed",
  ]);

  assert.match(result.stdout, /Would write/);
  assert.match(result.stdout, /"decision": "approve_public"/);
  assert.equal(result.stderr, "");
});

test("review decision draft rejects blocked publication packets", async () => {
  const fixture = writeFixture({
    packetOverrides: {
      status: "blocked_by_data",
      dataBlockers: ["owner_safe_public_draft"],
      approvalChecklist: {
        ...completeChecklist(),
        ownerSafeCopyReviewed: false,
      },
    },
  });

  await assert.rejects(
    () => runDraft(fixture, [
      "--confirm-publication-checklist",
    ]),
    (error) => {
      assert.equal(error.code, 1);
      assert.match(error.stderr, /not ready for public approval/);
      assert.match(error.stderr, /owner_safe_public_draft/);
      return true;
    }
  );
});

test("review decision draft requires manual report acknowledgement", async () => {
  const fixture = writeFixture({
    packetOverrides: {
      evidenceSummary: {manualReportsWithoutArtifacts: 2},
    },
  });

  await assert.rejects(
    () => runDraft(fixture, [
      "--confirm-publication-checklist",
    ]),
    (error) => {
      assert.equal(error.code, 64);
      assert.match(error.stderr, /confirm-manual-reports-reviewed/);
      return true;
    }
  );
});

async function runDraft(fixture, extraArgs = []) {
  return execFileAsync(process.execPath, [
    cliPath,
    "draft",
    "afterfly",
    "--decision",
    "approve_public",
    "--reviewer",
    "codex-dry-run",
    "--date",
    "2026-06-17",
    "--note",
    "Manual publication QA complete.",
    "--queue",
    fixture.queuePath,
    "--publication-packets",
    fixture.packetPath,
    "--decisions-root",
    fixture.decisionsRoot,
    "--dry-run",
    ...extraArgs,
  ], {cwd: repoRoot});
}

function writeFixture({
  itemOverrides = {},
  packetOverrides = {},
} = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "review-decision-"));
  const queuePath = path.join(root, "admin_review_queue.json");
  const packetPath = path.join(root, "publication_review_packets.json");
  const decisionsRoot = path.join(root, "review_decisions");
  fs.mkdirSync(decisionsRoot, {recursive: true});

  fs.writeFileSync(queuePath, `${JSON.stringify({
    summary: {total: 1, readyForManualApproval: 0},
    items: [
      {
        entityId: "afterfly",
        displayName: "AFTER FLY",
        reviewDecision: null,
        ...itemOverrides,
      },
    ],
  }, null, 2)}\n`);
  fs.writeFileSync(packetPath, `${JSON.stringify({
    packets: [
      {
        packetId: "publication-review-afterfly",
        entityId: "afterfly",
        status: "ready_for_manual_publication_review",
        dataBlockers: [],
        evidenceBlockers: [],
        approvalChecklist: completeChecklist(),
        evidenceSummary: {manualReportsWithoutArtifacts: 0},
        publicPresence: {appVisibility: "hidden"},
        adminDecision: {
          allowedDecisions: ["approve_public", "hold", "suppress"],
          currentDecision: null,
        },
        ...packetOverrides,
      },
    ],
  }, null, 2)}\n`);

  return {decisionsRoot, packetPath, queuePath};
}

function completeChecklist() {
  return {
    crawlDisabledReviewed: true,
    identityReviewed: true,
    marketScopeReviewed: true,
    mediaRightsReviewed: true,
    ownerSafeCopyReviewed: true,
    surfaceInventoryReviewed: true,
  };
}
