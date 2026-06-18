import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  buildReviewedDecisionAnswerPacketRegister,
  checkReviewedDecisionAnswerPacketRegister,
  renderReviewedDecisionAnswerPacketRegisterMarkdown,
} from "./reviewed_decision_answer_packets.mjs";
import {fingerprintDecisionAnswerPacket} from
  "./lib/decision_answer_packet_fingerprint.mjs";

test("register reports no reviewed packets", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-answer-packets-"));
  const register = buildReviewedDecisionAnswerPacketRegister({root});
  const result = checkReviewedDecisionAnswerPacketRegister(register);

  assert.equal(result.ok, true);
  assert.equal(result.summary.status, "no_reviewed_packets");
  assert.equal(result.summary.packets, 0);
  assert.match(result.warnings.join("\n"), /No reviewed/);
});

test("register reports fresh incomplete reviewed packet", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-answer-packets-"));
  const source = sourcePacket();
  const sourcePath = writeSourceJson(source);
  const reviewed = reviewedPacket({
    source,
    sourcePath,
  });
  writeJson(root, "2026-06-18-review.json", reviewed);

  const register = buildReviewedDecisionAnswerPacketRegister({root});
  const result = checkReviewedDecisionAnswerPacketRegister(register);

  assert.equal(result.ok, true, result.errors.join("\n"));
  assert.equal(register.summary.status, "awaiting_answers");
  assert.equal(register.summary.awaitingAnswers, 1);
  assert.equal(register.entries[0].sourceFreshness, "fresh");
});

test("register reports complete packet ready to apply", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-answer-packets-"));
  const source = sourcePacket();
  const sourcePath = writeSourceJson(source);
  const reviewed = reviewedPacket({
    decision: "hold",
    note: "Hold for now.",
    source,
    sourcePath,
  });
  writeJson(root, "2026-06-18-review.json", reviewed);

  const register = buildReviewedDecisionAnswerPacketRegister({root});
  const result = checkReviewedDecisionAnswerPacketRegister(register, {
    requireReady: true,
  });
  const markdown = renderReviewedDecisionAnswerPacketRegisterMarkdown(register);

  assert.equal(result.ok, true, result.errors.join("\n"));
  assert.equal(register.summary.status, "ready_to_apply");
  assert.equal(register.summary.readyToApply, 1);
  assert.match(markdown, /ready_to_apply/);
});

test("register can require one selected reviewed packet", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-answer-packets-"));
  const source = sourcePacket();
  const sourcePath = writeSourceJson(source);
  writeJson(root, "2026-06-18-incomplete.json", reviewedPacket({
    source,
    sourcePath,
  }));
  const readyPacket = writeJson(root, "2026-06-18-ready.json", reviewedPacket({
    decision: "hold",
    note: "Hold for now.",
    source,
    sourcePath,
  }));

  const register = buildReviewedDecisionAnswerPacketRegister({
    packet: readyPacket,
    root,
  });
  const result = checkReviewedDecisionAnswerPacketRegister(register, {
    requireReady: true,
  });

  assert.equal(result.ok, true, result.errors.join("\n"));
  assert.equal(register.summary.packets, 1);
  assert.equal(register.summary.readyToApply, 1);
  assert.equal(register.entries[0].path.endsWith("2026-06-18-ready.json"), true);
});

test("register rejects stale reviewed packet", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-answer-packets-"));
  const source = sourcePacket();
  const sourcePath = writeSourceJson({
    ...source,
    summary: {changed: true},
  });
  const reviewed = reviewedPacket({
    decision: "hold",
    note: "Hold for now.",
    source,
    sourcePath,
  });
  writeJson(root, "2026-06-18-review.json", reviewed);

  const register = buildReviewedDecisionAnswerPacketRegister({root});
  const result = checkReviewedDecisionAnswerPacketRegister(register);

  assert.equal(result.ok, false);
  assert.equal(register.summary.status, "invalid_packets");
  assert.equal(register.summary.stale, 1);
  assert.match(result.errors.join("\n"), /sourceFingerprint/);
});

function reviewedPacket({
  decision = null,
  note = "",
  source,
  sourcePath,
}) {
  const packet = sourcePacket();
  packet.answerTemplate.reviewer = "admin";
  packet.answerTemplate.decidedAt = "2026-06-18";
  packet.answerTemplate.answers[0].decision = decision;
  packet.answerTemplate.answers[0].note = note;
  packet.reviewDraft = {
    createdAt: "2026-06-18",
    reviewer: "admin",
    slug: "review",
    sourcePacket: sourcePath,
    sourceFingerprint: {
      algorithm: "sha256",
      value: fingerprintDecisionAnswerPacket(source),
    },
  };
  return packet;
}

function sourcePacket() {
  return {
    schemaVersion: 1,
    summary: {answerSlots: 1},
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

function writeJson(root, filename, value) {
  const file = path.join(root, filename);
  fs.writeFileSync(file, JSON.stringify(value, null, 2));
  return file;
}

function writeSourceJson(value) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-answer-source-"));
  return writeJson(root, "source.json", value);
}
