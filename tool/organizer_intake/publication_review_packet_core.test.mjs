import assert from "node:assert/strict";
import test from "node:test";
import {buildPublicationReviewPackets} from
  "./lib/publication_review_packet_core.mjs";

test("publication packets separate manual approval from data blockers", () => {
  const packets = buildPublicationReviewPackets({
    canonicalHostEntities: {
      entries: [host()],
    },
    canonicalEvidenceIndex: {
      records: [
        evidenceRecord({
          evidenceId: "evidence-afterfly-luma",
          surfaceId: "afterfly-luma",
          status: "resolved_artifact",
        }),
      ],
    },
    entityList: [entity()],
    reviewQueue: {
      items: [
        {
          entityId: "afterfly",
          taskType: "promotion_review",
          blockers: ["manual_admin_review_required"],
          gates: gates(true),
          reviewDecision: null,
        },
      ],
    },
    projectionPlan: {
      entries: [
        {
          entityId: "afterfly",
          projectionStatus: "blocked",
          publishStatus: "blocked",
          indexStatus: "noindex",
          appVisibility: "hidden",
          canonicalPath: "/organizers/afterfly/",
          legacyPaths: [],
          blockedBy: ["manual_admin_review_required"],
        },
      ],
    },
    claimTargetPlan: {targets: []},
  });

  assert.equal(packets.summary.packets, 1);
  assert.equal(packets.summary.readyForManualPublicationReview, 1);
  assert.equal(packets.summary.blockedByData, 0);
  const [packet] = packets.packets;
  assert.equal(packet.status, "ready_for_manual_publication_review");
  assert.deepEqual(packet.dataBlockers, []);
  assert.deepEqual(packet.evidenceBlockers, []);
  assert.equal(packet.approvalChecklist.identityReviewed, true);
  assert.equal(packet.approvalChecklist.mediaRightsReviewed, true);
  assert.equal(packet.publicPresence.canonicalPath, "/organizers/afterfly/");
  assert.equal(packet.evidenceReview.totalRecords, 1);
  assert.equal(packet.evidenceReview.artifactBackedRecords, 1);
  assert.equal(packet.evidenceReview.records[0].surface.platform, "luma");
  assert.equal(packet.evidenceReview.records[0].artifact.artifactKind, "reviewed_source_reference");
  assert.equal(packet.evidenceReview.records[0].reviewerUse.artifactAvailable, true);
  assert.equal(packet.adminDecision.defaultAppVisibility, "hidden");
  assert(packet.nextActions.includes("record_manual_publication_decision"));
});

test("publication packets include bounded reviewer evidence details", () => {
  const records = [
    evidenceRecord({
      evidenceId: "evidence-afterfly-luma",
      surfaceId: "afterfly-luma",
      status: "resolved_artifact",
      artifact: {
        artifactId: "afterfly-luma-artifact",
        path: "tool/organizer_intake/evidence/afterfly-luma.json",
        artifactKind: "reviewed_source_reference",
        storageClass: "reviewed_source_reference",
        sizeBytes: 512,
        sha256: "abc123def4567890",
        containsRawProviderPayload: false,
        firestoreMode: "not_applicable_local_source_reference",
        retentionStatus: "repo_reviewed",
        storageAction: "not_required",
      },
    }),
    evidenceRecord({
      evidenceId: "evidence-afterfly-instagram-manual",
      surfaceId: "afterfly-instagram",
      platform: "instagram",
      status: "manual_report_without_artifact",
      artifact: null,
      ref: null,
      description: "Reviewer saw a current Instagram profile.",
      riskFlags: ["manual_report_without_artifact"],
    }),
  ];

  const packets = buildPublicationReviewPackets({
    canonicalHostEntities: {
      entries: [host()],
    },
    canonicalEvidenceIndex: {records},
    entityList: [entity()],
    reviewQueue: {
      items: [
        {
          entityId: "afterfly",
          taskType: "promotion_review",
          blockers: ["manual_admin_review_required"],
          gates: gates(true),
          reviewDecision: null,
        },
      ],
    },
    projectionPlan: {entries: []},
    claimTargetPlan: {targets: []},
  });

  const [packet] = packets.packets;
  assert.equal(packet.evidenceReview.totalRecords, 2);
  assert.equal(packet.evidenceReview.shownRecords, 2);
  assert.equal(packet.evidenceReview.truncated, false);
  assert.equal(packet.evidenceReview.artifactBackedRecords, 1);
  assert.equal(packet.evidenceReview.manualReportsWithoutArtifacts, 1);
  assert.deepEqual(
    packet.evidenceReview.records.map((record) => record.evidenceId),
    [
      "evidence-afterfly-instagram-manual",
      "evidence-afterfly-luma",
    ]
  );
  const manualRecord = packet.evidenceReview.records[0];
  assert.equal(manualRecord.surface.platform, "instagram");
  assert.equal(manualRecord.evidence.description, "Reviewer saw a current Instagram profile.");
  assert.equal(manualRecord.artifact, null);
  assert.equal(manualRecord.reviewerUse.manualReportWithoutArtifact, true);
  assert.equal(manualRecord.nextAction, "review_evidence_reference");
});

test("publication packets block when evidence or data gates are incomplete", () => {
  const packets = buildPublicationReviewPackets({
    canonicalHostEntities: {
      entries: [host()],
    },
    canonicalEvidenceIndex: {
      records: [
        evidenceRecord({
          evidenceId: "evidence-afterfly-missing",
          surfaceId: "afterfly-luma",
          status: "missing_surface_evidence",
          riskFlags: ["surface_has_no_evidence_refs"],
        }),
      ],
    },
    entityList: [entity()],
    reviewQueue: {
      items: [
        {
          entityId: "afterfly",
          taskType: "promotion_review",
          blockers: [
            "manual_admin_review_required",
            "owner_safe_public_draft",
          ],
          gates: gates(false),
          reviewDecision: null,
        },
      ],
    },
    projectionPlan: {entries: []},
    claimTargetPlan: {targets: []},
  });

  assert.equal(packets.summary.blockedByData, 1);
  assert.equal(packets.summary.missingSurfaceEvidence, 1);
  const [packet] = packets.packets;
  assert.equal(packet.status, "blocked_by_data");
  assert.deepEqual(packet.dataBlockers, ["owner_safe_public_draft"]);
  assert.deepEqual(packet.evidenceBlockers, ["surface_missing_evidence"]);
  assert.equal(packet.approvalChecklist.ownerSafeCopyReviewed, false);
  assert.equal(packet.recommendedAction, "Resolve data or evidence blockers before publication approval.");
});

function host() {
  return {
    canonicalHostId: "afterfly",
    entityId: "afterfly",
    displayName: "AFTER FLY",
    priority: "p0",
    entityKind: "eventOrganizer",
    aliases: ["Afterfly"],
    activity: {
      primaryActivityKind: "socialRun",
      supportedActivityKinds: ["socialRun"],
      confidence: "medium",
      derivedFromSurfaceIds: ["afterfly-luma"],
    },
    geography: {
      scopeKind: "city",
      primaryMarketSlug: "indore",
      markets: [
        {
          marketSlug: "indore",
          displayName: "Indore",
          countryCode: "IN",
          eventFilter: {mode: "eventCity", citySlug: "indore"},
        },
      ],
      countryCodes: ["IN"],
    },
    publicPresence: {
      canonicalPath: "/organizers/afterfly/",
      legacyPaths: [],
      publishStatus: "blocked",
      indexStatus: "noindex",
      appVisibility: "hidden",
    },
    claim: {
      claimState: "unclaimed",
      claimTargetPath: null,
    },
    surfaceInventory: {
      surfaces: 1,
      active: 1,
      ambiguous: 0,
      rejected: 0,
      eventSourceSurfaceIds: ["afterfly-luma"],
    },
    curation: {
      attachedSurfaces: [],
      mergedFrom: [],
      mergedInto: null,
      suppressed: null,
      surfaceDecisions: [],
      splitSurfaces: [],
    },
  };
}

function entity() {
  return {
    entityId: "afterfly",
    publicDraft: {
      headline: "AFTER FLY organizer profile",
      summary: "AFTER FLY is an Indore organizer candidate with reviewed source evidence.",
      sourceSummary: "Reviewed event and social source evidence connect this profile to public organizer activity.",
      formats: ["Social runs"],
      missingEvidence: ["Admin publication decision"],
    },
  };
}

function evidenceRecord({
  artifact = {
    artifactId: "afterfly-artifact",
    path: "tool/organizer_intake/evidence/afterfly.json",
    artifactKind: "reviewed_source_reference",
    storageClass: "reviewed_source_reference",
    sizeBytes: 256,
    sha256: "1234567890abcdef",
    containsRawProviderPayload: false,
    firestoreMode: "not_applicable_local_source_reference",
    retentionStatus: "repo_reviewed",
    storageAction: "not_required",
  },
  description = "Reviewed source evidence.",
  evidenceId,
  platform = "luma",
  ref = "tool/organizer_intake/evidence/afterfly.json",
  riskFlags = [],
  status,
  surfaceId,
}) {
  return {
    evidenceId,
    entityId: "afterfly",
    riskFlags,
    surface: {
      surfaceId,
      platform,
      surfaceKind: "eventListing",
      role: "event_source",
      status: "active",
      url: `https://example.com/${surfaceId}`,
      normalizedKey: surfaceId,
      supportsEventExtraction: platform === "luma",
    },
    evidence: {
      status,
      type: "hostDiscoveryRun",
      ref,
      description,
    },
    artifact,
    correlatedCandidates: {
      searchCandidateIds: [`candidate-${surfaceId}`],
      externalEventCandidateIds: [],
    },
    nextAction:
      status === "resolved_artifact" ?
        "evidence_available_for_admin_review" :
        "review_evidence_reference",
  };
}

function gates(passed) {
  return [
    "identity_surface_present",
    "surface_inventory_reviewable",
    "owner_safe_public_draft",
    "market_model_present",
    "crawl_disabled_by_default",
  ].map((id) => ({
    id,
    passed,
    detail: id,
  }));
}
