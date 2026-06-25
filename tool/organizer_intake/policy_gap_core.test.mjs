import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerPolicyGapRegister} from "./lib/policy_gap_core.mjs";

test("buildOrganizerPolicyGapRegister reports disabled policy gaps", () => {
  const register = buildOrganizerPolicyGapRegister(sampleInputs());

  assert.equal(register.summary.gaps, 6);
  assert.equal(register.summary.decisionRequired, 6);
  assert.equal(register.summary.blockedByPolicy, 5);
  assert.equal(register.summary.reviewDecisions, 0);
  assert.equal(register.summary.reviewNotReviewed, 6);
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
    source_resolution: 1,
  });
});

test("buildOrganizerPolicyGapRegister exposes source mention resolution policy inputs", () => {
  const register = buildOrganizerPolicyGapRegister(sampleInputs());
  const gap = register.gaps.find((entry) =>
    entry.gapId === "source_mention_resolution_policy"
  );

  assert.equal(gap.status, "decision_required");
  assert.equal(gap.defaultPosition, "disabled_until_policy_approved");
  assert.equal(gap.evidence.llmStatus, "disabled");
  assert.equal(gap.evidence.candidatePairs, 3);
  assert.equal(gap.evidence.needsHumanReview, 1);
  assert.deepEqual(gap.evidence.stableProviderEventPlatforms, ["luma"]);
  assert.match(gap.requiredInputs.join("\n"), /monthly LLM spend cap/);
  assert.match(
    gap.blockedArtifacts.join("\n"),
    /source_mention_resolution_clusters/
  );
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
  assert.equal(register.summary.reviewNotReviewed, 5);
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
    sourceMentionResolution: {
      extractedMentions: {
        summary: {
          mentions: 8,
        },
      },
      resolutionCandidates: {
        summary: {
          candidates: 8,
        },
      },
      resolutionClusters: {
        summary: {
          candidatePairs: 3,
          clusters: 5,
          llmReviewQueued: 1,
          needsHumanReviewClusters: 1,
          warnings: 0,
        },
      },
      resolutionPolicy: {
        blockingKeys: [
          {id: "hard:eventUrl"},
          {id: "date-city"},
        ],
        hardKeyPolicy: {
          stableProviderEventPlatforms: ["luma"],
        },
        llm: {
          status: "disabled",
        },
        thresholds: {
          autoAttach: 0.9,
          llmAdjudicationMinScore: 0.45,
          maxClusterSizeForLlm: 8,
          maxPairsPerBlockingKey: 400,
          needsHumanReview: 0.45,
          probableDuplicate: 0.72,
        },
      },
    },
  };
}
