import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerPolicyDecisionPackets} from
  "./lib/policy_decision_packet_core.mjs";

test("buildOrganizerPolicyDecisionPackets converts unresolved gaps into input packets", () => {
  const packets = buildOrganizerPolicyDecisionPackets({
    gaps: [
      {
        gapId: "recurring_event_crawl_policy",
        area: "crawl",
        severity: "high",
        status: "decision_required",
        decisionStatus: "not_reviewed",
        decisionOwner: "product_ops",
        currentState: "2 crawl-capable surfaces; scheduler disabled.",
        requiredInputs: [
          "platform allowlist and fallback order",
          "monthly spend cap and per-run rate limits",
        ],
        unblockCriteria: ["event crawl plan policy.schedulerEnabled is true"],
        blockedArtifacts: ["tool/organizer_intake/generated/event_crawl_plan.json"],
        nextAction: "Choose crawl policy.",
        reviewDecision: null,
      },
    ],
  });

  assert.equal(packets.summary.packets, 1);
  assert.equal(packets.summary.decisionRequired, 1);
  assert.equal(packets.summary.unansweredQuestions, 2);
  assert.deepEqual(packets.summary.questionsByAnswerState, {
    needs_input: 2,
  });
  assert.equal(
    packets.packets[0].safeDefaultAction,
    "keep_scheduler_disabled"
  );
  assert.equal(
    packets.packets[0].questions[0].answerState,
    "needs_input"
  );
});

test("buildOrganizerPolicyDecisionPackets marks reviewed inputs from accepted decisions", () => {
  const packets = buildOrganizerPolicyDecisionPackets({
    gaps: [
      {
        gapId: "external_event_import_write_policy",
        area: "event_import",
        severity: "critical",
        status: "decision_required",
        decisionStatus: "accepted",
        decisionOwner: "product_ops",
        currentState: "1 approved candidate; writes disabled.",
        requiredInputs: [
          "write authority model and service identity",
          "rollback, correction, and takedown workflow",
        ],
        unblockCriteria: ["execution authorityModel is admin_import_service"],
        blockedArtifacts: [
          "tool/organizer_intake/generated/external_event_import_plan.json",
        ],
        nextAction: "Approve import authority.",
        reviewDecision: {
          policyGapDecisionBatchId: "2026-06-17-import-policy",
          decidedAt: "2026-06-17",
          reviewer: "admin",
          decision: "accept",
          note: "Reviewed policy inputs.",
          requiredInputsReviewed: [
            "write authority model and service identity",
          ],
          missingRequiredInputs: [
            "rollback, correction, and takedown workflow",
          ],
          unknownRequiredInputs: [],
        },
      },
    ],
  });

  assert.equal(packets.summary.accepted, 1);
  assert.deepEqual(
    packets.packets[0].questions.map((question) => question.answerState),
    ["reviewed", "needs_input"]
  );
  assert.equal(
    packets.packets[0].implementationGate,
    "import service authority, approval threshold, conflict policy, and rollback encoded"
  );
});
