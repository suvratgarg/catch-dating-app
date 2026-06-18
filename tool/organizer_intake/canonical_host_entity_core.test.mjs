import assert from "node:assert/strict";
import test from "node:test";
import {buildCanonicalHostEntityRegistry} from
  "./lib/canonical_host_entity_core.mjs";

test("canonical registry separates host entity from legacy club projection", () => {
  const registry = buildCanonicalHostEntityRegistry({
    entityList: [afterflyEntity()],
    projectionPlan: {
      entries: [
        {
          entityId: "afterfly",
          projectionStatus: "ready",
          publishStatus: "published",
          indexStatus: "indexed",
          appVisibility: "hidden",
          canonicalPath: "/organizers/afterfly/",
          legacyPaths: ["/organizers/indore/afterfly-run-club/"],
          pageMode: "singleEntity",
          publicListing: {
            id: "afterfly",
            status: "unclaimed",
          },
          reviewDecision: {
            decision: "approve_public",
            decidedAt: "2026-06-17",
          },
          blockedBy: [],
        },
      ],
    },
    claimTargetPlan: {
      targets: [
        {
          entityId: "afterfly",
          clubId: "afterfly",
          path: "clubs/afterfly",
          claimState: "unclaimed",
          appVisibility: "hidden",
          writeMode: "create_or_refresh_unclaimed_public_fields",
          sourceHash: "abc123",
        },
      ],
    },
    dedupeIndex: {
      dedupeKeys: [
        {
          entityId: "afterfly",
          type: "surface",
          value: "luma:event:pxgmph3b",
          strength: "strong",
        },
        {
          entityId: "afterfly",
          type: "legacyClubId",
          value: "afterfly-run-club-indore",
          strength: "strong",
        },
      ],
      conflicts: [],
    },
    reviewQueue: {items: []},
    curationState: {
      attachedSurfaces: [],
      mergedEntities: [],
      suppressedEntities: [],
      surfaceDecisions: [],
      splitSurfaces: [],
    },
  });

  assert.equal(registry.naming.publicEntityLabel, "Host");
  assert.equal(registry.naming.canonicalDataModel, "OrganizerEntity");
  assert.equal(registry.naming.legacyCompatibilityModel, "Club");
  assert.equal(registry.summary.entities, 1);
  assert.equal(registry.summary.publicPublished, 1);
  assert.equal(registry.summary.indexed, 1);
  assert.equal(registry.summary.claimTargets, 1);
  assert.equal(registry.summary.legacyClubProjected, 1);

  const [entry] = registry.entries;
  assert.equal(entry.canonicalHostId, "afterfly");
  assert.equal(entry.publicPresence.publishStatus, "published");
  assert.equal(entry.publicPresence.indexStatus, "indexed");
  assert.equal(entry.claim.claimState, "unclaimed");
  assert.equal(entry.claim.claimTargetPath, "clubs/afterfly");
  assert.equal(entry.legacyClubCompatibility.collection, "clubs");
  assert.equal(entry.legacyClubCompatibility.documentId, "afterfly");
  assert.equal(entry.legacyClubCompatibility.status, "ready_for_unclaimed_projection");
  assert.deepEqual(entry.surfaceInventory.primarySurfaceIds, [
    "afterfly-instagram-primary",
    "afterfly-luma-takeoff-run-rave",
  ]);
  assert.equal(entry.surfaceInventory.eventSourceSurfaceIds.length, 1);
  assert.equal(entry.surfaceInventory.socialProfileSurfaceIds.length, 1);
  assert.equal(entry.dedupe.strongKeys, 2);
  assert(entry.nextActions.includes("eligible_for_claim_outreach"));
  assert(entry.nextActions.includes("keep_app_hidden_until_claim_or_app_approval"));
  assert(entry.nextActions.includes("keep_recurring_crawl_disabled_until_policy_approval"));
});

test("blocked entities stay private and retain review next actions", () => {
  const registry = buildCanonicalHostEntityRegistry({
    entityList: [blockedEntity()],
    projectionPlan: {entries: []},
    claimTargetPlan: {targets: []},
    dedupeIndex: {dedupeKeys: [], conflicts: []},
    reviewQueue: {
      items: [
        {
          entityId: "quiet-run",
          blockers: ["manual_admin_review_required"],
        },
      ],
    },
    curationState: {
      attachedSurfaces: [],
      mergedEntities: [],
      suppressedEntities: [],
      surfaceDecisions: [],
      splitSurfaces: [],
    },
  });

  assert.equal(registry.summary.publicPublished, 0);
  assert.equal(registry.summary.pendingManualReview, 1);
  assert.equal(registry.summary.legacyClubProjected, 0);
  const [entry] = registry.entries;
  assert.equal(entry.publicPresence.publishStatus, "blocked");
  assert.equal(entry.publicPresence.indexStatus, "noindex");
  assert.equal(entry.claim.claimTargetPath, null);
  assert.equal(
    entry.legacyClubCompatibility.status,
    "not_projected_until_public_approval"
  );
  assert.deepEqual(entry.publicPresence.blockedBy, [
    "manual_admin_review_required",
  ]);
  assert(entry.nextActions.includes("resolve_review_blockers"));
});

function afterflyEntity() {
  return {
    entityId: "afterfly",
    displayName: "AFTER FLY",
    canonicalSlug: "afterfly",
    aliases: ["Afterfly"],
    entityKind: "eventOrganizer",
    priority: "p0",
    reviewStatus: "needs_admin_review",
    relationshipToCatch: "unclaimed",
    activityDefaults: {
      primaryActivityKind: "socialRun",
      supportedActivityKinds: ["socialRun"],
      confidence: "medium",
      derivedFromSurfaceIds: ["afterfly-luma-takeoff-run-rave"],
    },
    geographicScope: {
      kind: "city",
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
    publicListingIntent: {
      canonicalPath: "/organizers/afterfly/",
      legacyPaths: ["/organizers/indore/afterfly-run-club/"],
      pageMode: "singleEntity",
    },
    surfaces: [
      {
        surfaceId: "afterfly-luma-takeoff-run-rave",
        platform: "luma",
        surfaceKind: "eventListing",
        url: "https://luma.com/pxgmph3b",
        normalizedKey: "luma:event:pxgmph3b",
        role: "primary",
        status: "active",
        confidence: {entityMatch: "high", ownership: "medium", city: "high"},
        crawl: {
          eventDiscoveryStatus: "disabled",
          policy: "manualOnly",
          supportsEventExtraction: true,
        },
        evidenceRefs: [
          {
            type: "hostDiscoveryRun",
            ref: "tool/host_discovery/runs/afterfly.json",
            description: "Source evidence.",
          },
        ],
        notes: "Source event page.",
      },
      {
        surfaceId: "afterfly-instagram-primary",
        platform: "instagram",
        surfaceKind: "socialProfile",
        url: "https://instagram.com/afterfly.in",
        normalizedKey: "instagram:afterfly.in",
        role: "primary",
        status: "active",
        confidence: {entityMatch: "high", ownership: "medium", city: "medium"},
        crawl: {
          eventDiscoveryStatus: "disabled",
          policy: "manualOnly",
          supportsEventExtraction: false,
        },
        evidenceRefs: [],
        notes: "Social profile.",
      },
    ],
    dedupeHints: [],
    reviewNotes: [],
  };
}

function blockedEntity() {
  return {
    ...afterflyEntity(),
    entityId: "quiet-run",
    displayName: "Quiet Run",
    canonicalSlug: "quiet-run",
    aliases: ["Quiet Run"],
    priority: "p1",
    publicListingIntent: {
      canonicalPath: "/organizers/quiet-run/",
      legacyPaths: [],
      pageMode: "singleEntity",
    },
    surfaces: [
      {
        ...afterflyEntity().surfaces[1],
        surfaceId: "quiet-run-instagram",
        normalizedKey: "instagram:quietrun",
      },
    ],
    activityDefaults: {
      primaryActivityKind: "running",
      supportedActivityKinds: ["running"],
      confidence: "low",
      derivedFromSurfaceIds: ["quiet-run-instagram"],
    },
  };
}
