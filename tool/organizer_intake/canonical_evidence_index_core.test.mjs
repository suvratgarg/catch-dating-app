import assert from "node:assert/strict";
import test from "node:test";
import {buildCanonicalEvidenceIndex} from
  "./lib/canonical_evidence_index_core.mjs";

test("canonical evidence index resolves source refs and carries artifact hashes", () => {
  const index = buildCanonicalEvidenceIndex({
    canonicalHostEntities: canonicalHosts(),
    rawArtifactStorageManifest: rawArtifacts(),
    referencedArtifactFiles: [
      {
        path: "tool/host_discovery/runs/afterfly.json",
        sizeBytes: 42,
        sha256: "a".repeat(64),
      },
    ],
    curationState: {
      attachedSurfaces: [],
      surfaceDecisions: [
        {
          entityId: "afterfly",
          surfaceId: "afterfly-wrong-site",
          decision: "reject_wrong_entity",
          reason: "Different company.",
        },
      ],
      splitSurfaces: [],
    },
    reviewQueue: {
      items: [
        {
          entityId: "afterfly",
          taskType: "promotion_review",
          blockers: ["manual_admin_review_required"],
        },
      ],
    },
    searchResultCandidateQueue: {
      candidates: [
        {
          candidateId: "search:instagram",
          normalizedKey: "instagram:afterfly.in",
        },
      ],
    },
    externalEventCandidateQueue: {
      candidates: [
        {
          candidateId: "luma-event:pxgmph3b",
          entityId: "afterfly",
          platform: "luma",
          sourceSurfaceId: "afterfly-luma",
        },
      ],
    },
  });

  assert.equal(index.summary.hosts, 1);
  assert.equal(index.summary.surfaces, 3);
  assert.equal(index.summary.records, 3);
  assert.equal(index.summary.resolvedArtifactRefs, 2);
  assert.equal(index.summary.manualReportsWithoutArtifacts, 1);
  assert.equal(index.summary.rawProviderArtifacts, 1);
  assert.equal(index.summary.rawPayloadBytes, 128);
  assert.equal(index.summary.firestoreForbiddenArtifactRefs, 0);

  const resolved = index.records.find((record) =>
    record.surface.surfaceId === "afterfly-luma"
  );
  assert.equal(resolved.evidence.status, "resolved_artifact");
  assert.equal(resolved.artifact.sha256, "a".repeat(64));
  assert.equal(resolved.artifact.source, "evidence_ref_file");
  assert.equal(resolved.reviewState.reviewTaskType, "promotion_review");
  assert.deepEqual(resolved.correlatedCandidates.externalEventCandidateIds, [
    "luma-event:pxgmph3b",
  ]);

  const manual = index.records.find((record) =>
    record.surface.surfaceId === "afterfly-wrong-site"
  );
  assert.equal(manual.evidence.status, "manual_report_without_artifact");
  assert(manual.riskFlags.includes("manual_report_without_artifact"));
  assert(manual.riskFlags.includes("surface_rejected"));
  assert.equal(manual.reviewState.curation.decision, "reject_wrong_entity");

  const rawPayload = index.artifactCoverage.find((artifact) =>
    artifact.artifactKind === "raw_provider_payload"
  );
  assert.equal(rawPayload.containsRawProviderPayload, true);
  assert.equal(rawPayload.firestoreMode, "forbidden_raw_or_source_payload");
  assert.deepEqual(rawPayload.referencedByEvidenceIds, []);
});

test("canonical evidence index flags surfaces with no evidence refs", () => {
  const hosts = canonicalHosts();
  hosts.entries[0].surfaces = [
    {
      ...hosts.entries[0].surfaces[0],
      evidenceRefs: [],
      surfaceId: "afterfly-unbacked",
    },
  ];

  const index = buildCanonicalEvidenceIndex({
    canonicalHostEntities: hosts,
    rawArtifactStorageManifest: {artifacts: []},
  });

  assert.equal(index.summary.surfacesWithoutEvidence, 1);
  assert.equal(index.records[0].evidence.status, "missing_surface_evidence");
  assert(index.records[0].riskFlags.includes("surface_has_no_evidence_refs"));
  assert.equal(
    index.records[0].nextAction,
    "attach_reviewed_source_evidence_before_publication"
  );
});

function canonicalHosts() {
  return {
    entries: [
      {
        canonicalHostId: "afterfly",
        entityId: "afterfly",
        displayName: "AFTER FLY",
        publicPresence: {
          reviewStatus: "needs_admin_review",
          publishStatus: "blocked",
          indexStatus: "noindex",
          appVisibility: "hidden",
        },
        claim: {
          claimState: "unclaimed",
        },
        surfaces: [
          {
            surfaceId: "afterfly-luma",
            platform: "luma",
            surfaceKind: "eventListing",
            url: "https://luma.com/pxgmph3b",
            normalizedKey: "luma:event:pxgmph3b",
            role: "primary",
            status: "active",
            confidence: {
              entityMatch: "high",
              ownership: "medium",
              city: "high",
            },
            crawl: {
              supportsEventExtraction: true,
            },
            evidenceRefs: [
              {
                type: "hostDiscoveryRun",
                ref: "tool/host_discovery/runs/afterfly.json",
                description: "Reviewed host discovery run.",
              },
            ],
          },
          {
            surfaceId: "afterfly-instagram",
            platform: "instagram",
            surfaceKind: "socialProfile",
            url: "https://www.instagram.com/afterfly.in/",
            normalizedKey: "instagram:afterfly.in",
            role: "primary",
            status: "active",
            confidence: {
              entityMatch: "high",
              ownership: "medium",
              city: "medium",
            },
            crawl: {
              supportsEventExtraction: false,
            },
            evidenceRefs: [
              {
                type: "manualNote",
                ref: "tool/host_discovery/runs/afterfly.json",
                description: "Same reviewed run mentions Instagram.",
              },
            ],
          },
          {
            surfaceId: "afterfly-wrong-site",
            platform: "officialWebsite",
            surfaceKind: "wrongEntity",
            url: null,
            normalizedKey: null,
            role: "rejected",
            status: "rejected",
            confidence: {
              entityMatch: "low",
              ownership: "low",
              city: "low",
            },
            crawl: {
              supportsEventExtraction: false,
            },
            evidenceRefs: [
              {
                type: "userReportedSearchResult",
                ref: null,
                description: "User reported wrong first-party-looking site.",
              },
            ],
          },
        ],
      },
    ],
  };
}

function rawArtifacts() {
  return {
    artifacts: [
      {
        artifactId: "raw-afterfly",
        path: "tool/organizer_intake/fixtures/luma_event.afterfly.raw.json",
        artifactKind: "raw_provider_payload",
        storageClass: "raw_private_payload",
        sizeBytes: 128,
        sha256: "b".repeat(64),
        containsRawProviderPayload: true,
        firestoreMode: "forbidden_raw_or_source_payload",
        retention: {
          status: "decision_required",
          retentionDays: null,
          deletionMode: "not_configured",
        },
        storagePlan: {
          action: "blocked",
          remoteObjectKey: "organizer-intake/raw-private-payload/raw-afterfly.json",
          blockedBy: ["remote_object_storage_disabled"],
        },
      },
    ],
  };
}
