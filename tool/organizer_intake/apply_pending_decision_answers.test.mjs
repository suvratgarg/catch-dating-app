import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  buildPendingDecisionAnswerApplySteps,
  checkPendingDecisionAnswerApply,
  runPendingDecisionAnswerApply,
} from "./apply_pending_decision_answers.mjs";
import {fingerprintDecisionAnswerPacket} from
  "./lib/decision_answer_packet_fingerprint.mjs";

test("apply check blocks incomplete packets by default", () => {
  const result = checkPendingDecisionAnswerApply(packet());

  assert.equal(result.ok, false);
  assert.equal(result.summary.pendingAnswers, 1);
  assert.equal(result.steps.length, 0);
  assert(
    result.errors.some((error) =>
      error.includes("1 answer(s) are still pending"))
  );
});

test("apply check can allow partial generated packets without steps", () => {
  const result = checkPendingDecisionAnswerApply(packet(), {
    allowPartial: true,
  });

  assert.equal(result.ok, true);
  assert.equal(result.summary.status, "awaiting_answers");
  assert.equal(result.summary.applySteps, 0);
  assert.equal(result.warnings.length, 1);
});

test("apply steps always preflight before write commands", () => {
  const result = checkPendingDecisionAnswerApply(answeredPacket(), {
    write: true,
  });

  assert.equal(result.ok, true);
  assert.deepEqual(
    result.steps.map((step) => [step.mode, step.answerId]),
    [
      ["dry-run", "admin-publication:afterfly"],
      ["write", "admin-publication:afterfly"],
    ]
  );
  assert.match(
    result.steps[0].displayCommand,
    /review_decision\.mjs draft afterfly .* --dry-run/
  );
  assert.doesNotMatch(result.steps[1].displayCommand, /--dry-run/);
});

test("apply check accepts fresh reviewed answer packet source fingerprint", () => {
  const source = packet();
  const sourcePath = tempJson(source);
  const reviewed = answeredPacket();
  reviewed.reviewDraft = {
    sourcePacket: sourcePath,
    sourceFingerprint: {
      algorithm: "sha256",
      value: fingerprintDecisionAnswerPacket(source),
    },
  };

  const result = checkPendingDecisionAnswerApply(reviewed, {
    write: true,
  });

  assert.equal(result.ok, true, result.errors.join("\n"));
  assert.equal(result.summary.sourceFreshness, "fresh");
});

test("apply check rejects stale reviewed answer packet source fingerprint", () => {
  const sourcePath = tempJson({
    ...packet(),
    summary: {changed: true},
  });
  const reviewed = answeredPacket();
  reviewed.reviewDraft = {
    sourcePacket: sourcePath,
    sourceFingerprint: {
      algorithm: "sha256",
      value: fingerprintDecisionAnswerPacket(packet()),
    },
  };

  const result = checkPendingDecisionAnswerApply(reviewed);

  assert.equal(result.ok, false);
  assert.equal(result.summary.sourceFreshness, "stale");
  assert(
    result.errors.some((error) =>
      error.includes("sourceFingerprint does not match"))
  );
});

test("apply check can allow stale source after explicit override", () => {
  const reviewed = answeredPacket();
  reviewed.reviewDraft = {
    sourcePacket: "/tmp/missing-generated-answer-packet.json",
    sourceFingerprint: {
      algorithm: "sha256",
      value: "missing",
    },
  };

  const result = checkPendingDecisionAnswerApply(reviewed, {
    allowStaleSource: true,
  });

  assert.equal(result.ok, true, result.errors.join("\n"));
  assert.equal(result.summary.sourceFreshness, "not_enforced");
  assert.match(result.warnings.join("\n"), /not enforced/);
});

test("run applies dry-run commands through injectable runner", () => {
  const commands = [];
  const result = runPendingDecisionAnswerApply(answeredPacket(), {
    json: true,
    runner(command) {
      commands.push(command);
      return {status: 0, stdout: "", stderr: ""};
    },
  });

  assert.equal(result.ok, true);
  assert.equal(result.results.length, 1);
  assert.equal(commands.length, 1);
  assert.equal(commands[0][1], "tool/organizer_intake/review_decision.mjs");
  assert(commands[0].includes("--dry-run"));
});

test("run stops before write when dry-run preflight fails", () => {
  const commands = [];
  const result = runPendingDecisionAnswerApply(answeredPacket(), {
    json: true,
    write: true,
    runner(command) {
      commands.push(command);
      return {status: commands.length === 1 ? 1 : 0, stdout: "", stderr: ""};
    },
  });

  assert.equal(result.ok, false);
  assert.equal(result.results.length, 1);
  assert.equal(commands.length, 1);
  assert(commands[0].includes("--dry-run"));
});

test("buildPendingDecisionAnswerApplySteps normalizes node executable", () => {
  const result = checkPendingDecisionAnswerApply(answeredPacket());
  const steps = buildPendingDecisionAnswerApplySteps(result.plan);

  assert.equal(steps.length, 1);
  assert.notEqual(steps[0].command[0], "node");
  assert.equal(steps[0].command[1], "tool/organizer_intake/review_decision.mjs");
});

function answeredPacket() {
  const payload = packet();
  payload.answerTemplate.reviewer = "admin";
  payload.answerTemplate.decidedAt = "2026-06-18";
  payload.answerTemplate.answers[0] = {
    answerId: "admin-publication:afterfly",
    decision: "hold",
    note: "Hold until copy is checked.",
    acknowledgements: {},
    requiredInputsReviewed: [],
  };
  return payload;
}

function packet() {
  return {
    schemaVersion: 1,
    answerSlots: [
      {
        answerId: "admin-publication:afterfly",
        requestType: "admin_publication_decision",
        subjectId: "afterfly",
        subjectName: "AFTER FLY",
        decisionOptions: ["approve_public", "hold", "suppress"],
        requiredAcknowledgements: [],
        requiredInputs: [],
        safeDefaultPayload: {
          appVisibility: "hidden",
        },
      },
    ],
    answerTemplate: {
      reviewer: "",
      decidedAt: "YYYY-MM-DD",
      answers: [
        {
          answerId: "admin-publication:afterfly",
          decision: null,
          note: "",
          acknowledgements: {},
          requiredInputsReviewed: [],
        },
      ],
    },
  };
}

function tempJson(value) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-answer-source-"));
  const file = path.join(dir, "source.json");
  fs.writeFileSync(file, JSON.stringify(value, null, 2));
  return file;
}
