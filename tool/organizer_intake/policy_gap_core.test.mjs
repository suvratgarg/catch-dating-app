import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerPolicyGapRegister} from "./lib/policy_gap_core.mjs";

test("buildOrganizerPolicyGapRegister reports disabled policy gaps", () => {
  const register = buildOrganizerPolicyGapRegister(sampleInputs());

  assert.equal(register.summary.gaps, 5);
  assert.equal(register.summary.decisionRequired, 5);
  assert.equal(register.summary.blockedByPolicy, 4);
  assert.equal(register.summary.reviewDecisions, 0);
  assert.equal(register.summary.reviewNotReviewed, 5);
  assert.equal(register.gaps[0].gapId, "external_event_import_write_policy");
  assert.equal(register.gaps[0].severity, "critical");
  assert.equal(register.gaps[0].status, "decision_required");
  assert.equal(register.gaps[0].decisionStatus, "not_reviewed");
  assert.equal(register.gaps[0].reviewDecision, null);
  assert.deepEqual(register.summary.gapsByArea, {
    crawl: 1,
    event_import: 2,
    location_resolution: 1,
    naming: 1,
  });
});

test("buildOrganizerPolicyGapRegister marks enabled import authority ready", () => {
  const inputs = sampleInputs();
  inputs.externalEventImportPlan.policy.writeEnabled = true;
  inputs.externalEventImportExecutionPlan.policy.writeEnabled = true;
  inputs.externalEventImportExecutionPlan.policy.authorityModel =
    "admin_import_service";
  inputs.externalEventImportPlan.actions[0].blockers = [
    "global_external_event_import_disabled",
  ];

  const register = buildOrganizerPolicyGapRegister(inputs);
  const importGap = register.gaps.find((gap) =>
    gap.gapId === "external_event_import_write_policy"
  );

  assert.equal(importGap.status, "ready");
  assert.equal(importGap.defaultPosition, "enabled_by_policy");
});

test("buildOrganizerPolicyGapRegister applies reviewed policy decisions without enabling behavior", () => {
  const baseRegister = buildOrganizerPolicyGapRegister(sampleInputs());
  const crawlGap = baseRegister.gaps.find((gap) =>
    gap.gapId === "recurring_event_crawl_policy"
  );

  const register = buildOrganizerPolicyGapRegister({
    ...sampleInputs(),
    policyGapDecisionBatches: [
      {
        schemaVersion: 1,
        policyGapDecisionBatchId: "2026-06-17-crawl-policy-accept",
        decidedAt: "2026-06-17",
        reviewer: "product",
        decisions: [
          {
            gapId: "recurring_event_crawl_policy",
            decision: "accept",
            note: "Policy direction reviewed; implementation remains disabled.",
            requiredInputsReviewed: crawlGap.requiredInputs,
          },
        ],
      },
    ],
  });
  const reviewedGap = register.gaps.find((gap) =>
    gap.gapId === "recurring_event_crawl_policy"
  );

  assert.equal(register.errors.length, 0);
  assert.equal(register.summary.reviewAccepted, 1);
  assert.equal(register.summary.reviewNotReviewed, 4);
  assert.equal(reviewedGap.decisionStatus, "accepted");
  assert.equal(reviewedGap.status, "decision_required");
  assert.equal(reviewedGap.defaultPosition, "disabled_until_policy_approved");
  assert.equal(reviewedGap.reviewDecision.missingRequiredInputs.length, 0);
});

test("buildOrganizerPolicyGapRegister rejects incomplete accepted policy decisions", () => {
  const register = buildOrganizerPolicyGapRegister({
    ...sampleInputs(),
    policyGapDecisionBatches: [
      {
        schemaVersion: 1,
        policyGapDecisionBatchId: "2026-06-17-crawl-policy-incomplete",
        decidedAt: "2026-06-17",
        reviewer: "product",
        decisions: [
          {
            gapId: "recurring_event_crawl_policy",
            decision: "accept",
            note: "Incomplete acceptance should fail.",
            requiredInputsReviewed: ["platform allowlist and fallback order"],
          },
        ],
      },
    ],
  });
  const reviewedGap = register.gaps.find((gap) =>
    gap.gapId === "recurring_event_crawl_policy"
  );

  assert.equal(reviewedGap.decisionStatus, "invalid");
  assert.match(register.errors.join("\n"), /cannot be accepted/);
});

function sampleInputs() {
  return {
    eventCrawlPlan: {
      policy: {schedulerEnabled: false},
      summary: {
        approvedSurfaces: 0,
        blockers: {global_recurring_crawl_disabled: 2},
        crawlCapableSurfaces: 2,
      },
    },
    externalEventCandidateQueue: {
      summary: {
        approvedForImport: 1,
      },
    },
    externalEventLocationResolutionQueue: {
      policy: {
        provider: "googlePlaces",
        providerLookupEnabled: false,
      },
      summary: {
        missingExactCoordinates: 1,
        tasks: 1,
      },
    },
    externalEventImportPlan: {
      policy: {writeEnabled: false},
      summary: {
        proposedCreates: 1,
        writeReady: 0,
      },
      actions: [
        {
          blockers: [
            "global_external_event_import_disabled",
            "requires_capacity_policy",
            "requires_event_defaults_policy",
          ],
        },
      ],
    },
    externalEventImportExecutionPlan: {
      policy: {
        authorityModel: "disabled",
        writeEnabled: false,
      },
      summary: {
        wouldCreate: 0,
      },
    },
  };
}
