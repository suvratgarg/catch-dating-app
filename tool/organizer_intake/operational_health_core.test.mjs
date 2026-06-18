import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerOperationalHealthReport} from
  "./lib/operational_health_core.mjs";

test("operational health rolls organizer intake into deterministic workstreams", () => {
  const report = buildOrganizerOperationalHealthReport({
    canonicalEvidenceIndex: {
      summary: {
        manualReportsWithoutArtifacts: 1,
        rawProviderArtifacts: 2,
        records: 9,
        resolvedArtifactRefs: 7,
        surfaces: 8,
        surfacesWithoutEvidence: 0,
      },
    },
    canonicalHostEntities: {
      summary: {
        indexed: 0,
        publicPublished: 0,
      },
    },
    claimTargetSyncPreview: {
      commands: {
        firestoreDryRun:
          "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs --env dev",
        localFixturePreview:
          "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs --fixture empty.json",
      },
      mode: {remoteWrites: 0},
      summary: {
        creates: 0,
        refreshes: 0,
        skippedOwnerBound: 0,
        targets: 0,
        writesNeeded: 0,
      },
    },
    eventCrawlPlan: {
      summary: {
        approvedSurfaces: 0,
        blockedSurfaces: 2,
        blockers: {recurring_crawl_policy_missing: 2},
        crawlCapableSurfaces: 2,
      },
    },
    eventCrawlRunPlan: {
      policy: {
        networkEnabled: false,
        schedulerEnabled: false,
      },
      summary: {
        blocked: 2,
        blockers: {network_disabled: 2},
        candidateSurfaces: 2,
        wouldFetch: 0,
      },
    },
    operatorActionQueue: {
      actions: [
        {
          actionId: "policy-decision:recurring_event_crawl_policy",
          actionType: "policy_decision",
          blockers: ["event_crawl_plan"],
          commands: ["node tool/organizer_intake/policy_gap_decision.mjs list"],
          nextAction: "Choose crawl policy.",
          priority: "p0",
          status: "requires_policy_input",
        },
        {
          actionId: "publication-review:afterfly",
          actionType: "publication_review",
          blockers: [],
          commands: ["node tool/organizer_intake/review_decision.mjs list"],
          nextAction: "Record manual publication decision.",
          priority: "p0",
          status: "requires_admin_decision",
        },
        {
          actionId: "workflow-gate:claim_target_sync",
          actionType: "workflow_gate",
          blockers: ["waiting"],
          commands: [
            "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs --fixture empty.json",
          ],
          nextAction: "Wait for public projection.",
          priority: "p2",
          status: "waiting:claim_target_sync",
        },
      ],
      summary: {
        actions: 3,
        actionsByPriority: {p0: 2, p2: 1},
        adminDecisionsRequired: 1,
        policyInputsRequired: 1,
        waitingActions: 1,
      },
    },
    policyDecisionPackets: {
      summary: {
        accepted: 0,
        held: 0,
        packets: 1,
        questions: 2,
        rejected: 0,
        unansweredQuestions: 2,
      },
    },
    policyGapRegister: {
      summary: {
        decisionRequired: 1,
        gaps: 1,
      },
    },
    publicationDecisionImpactPreview: {
      summary: {
        wouldCreateClaimTargets: 1,
        wouldIndex: 1,
        wouldPublish: 1,
      },
    },
    publicationReviewPackets: {
      summary: {
        blockedByData: 0,
        manualReportsWithoutArtifacts: 1,
        packets: 1,
        readyForManualPublicationReview: 1,
      },
    },
    rawArtifactStorageManifest: {
      summary: {
        artifacts: 3,
        blockers: {
          object_storage_bucket_missing: 1,
          retention_policy_missing: 1,
        },
        firestoreRawStorageAllowed: false,
        rawProviderPayloads: 1,
        remoteUploadBlocked: 1,
        remoteUploadReady: 0,
        retentionDecisionRequired: 1,
        totalBytes: 1024,
      },
    },
    workflowReadiness: {
      commands: {
        localPromotionPreview:
          "node tool/organizer_intake/run_promotion_pipeline.mjs",
      },
      gates: [
        {
          id: "public_projection",
          nextAction: "Record admin decision.",
          status: "waiting",
        },
        {
          id: "claim_target_sync",
          nextAction: "Wait for projection.",
          status: "waiting",
        },
      ],
      summary: {
        blocked: 1,
        localPromotionPipelineReady: true,
        policyNeeded: 1,
        publicProjectionReady: false,
        ready: 4,
        waiting: 2,
      },
    },
  });

  assert.equal(report.schemaVersion, 1);
  assert.equal(report.summary.healthStatus, "p0_action_required");
  assert.equal(report.summary.workstreams, 9);
  assert.equal(report.summary.operatorActions, 3);
  assert.equal(report.summary.adminDecisionsRequired, 1);
  assert.equal(report.summary.policyInputsRequired, 1);
  assert.equal(report.summary.highestPriority, "p0");
  assert.equal(report.summary.workstreamsByStatus.requires_admin_decision, 1);
  assert.equal(report.summary.workstreamsByStatus.requires_policy_input, 1);
  assert.equal(report.summary.policyBlockedWorkstreams, 2);
  assert.equal(report.summary.workstreamsByStatus.blocked_by_policy, 1);
  assert.equal(report.summary.workstreamsByStatus.disabled_by_policy, 1);
  assert.equal(report.workstreams[0].id, "policy_decisions");
  assert.equal(report.workstreams[1].id, "publication_review");

  const publication = report.workstreams.find((stream) =>
    stream.id === "publication_review"
  );
  assert.equal(publication.status, "requires_admin_decision");
  assert.equal(publication.metrics.readyForManualReview, 1);
  assert.equal(publication.metrics.wouldPublish, 1);
  assert.deepEqual(publication.nextActions, [
    "Record manual publication decision.",
  ]);

  const storage = report.workstreams.find((stream) =>
    stream.id === "raw_artifact_storage"
  );
  assert.equal(storage.status, "blocked_by_policy");
  assert.equal(storage.metrics.firestoreRawStorageAllowed, false);
  assert.deepEqual(storage.blockers, [
    "object_storage_bucket_missing",
    "retention_policy_missing",
  ]);
});
