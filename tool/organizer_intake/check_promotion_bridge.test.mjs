import assert from "node:assert/strict";
import test from "node:test";
import {checkPromotionBridge} from "./check_promotion_bridge.mjs";

test("checkPromotionBridge accepts aligned public projection, website listing, and claim target", () => {
  const result = checkPromotionBridge(bridgeFixture());

  assert.deepEqual(result.errors, []);
  assert.deepEqual(result.warnings, []);
  assert.deepEqual(result.summary, {
    approvedProjections: 1,
    pilotEligibleProjections: 1,
    pilotSuppressedProjections: 0,
    canonicalHostEntities: 1,
    claimTargets: 1,
    claimTargetSyncPreviewWrites: 1,
    organizerIntakeListings: 1,
    websiteListings: 1,
  });
});

test("checkPromotionBridge requires waitlist-market organizers to stay out of website listings", () => {
  const fixture = bridgeFixture();
  const waitlistEntry = {
    ...structuredClone(fixture.projectionPlan.entries[0]),
    entityId: "bhag",
    legacyPaths: ["/organizers/delhi-ncr/bhag-club/"],
    publicListing: {
      ...structuredClone(fixture.projectionPlan.entries[0].publicListing),
      id: "bhag",
      path: "/organizers/bhag/",
      markets: [{marketSlug: "delhi-ncr", displayName: "Delhi NCR"}],
    },
  };
  fixture.projectionPlan.entries.push(waitlistEntry);
  fixture.canonicalHostEntities.entries.push({
    canonicalHostId: "bhag",
    entityId: "bhag",
    publicPresence: {
      canonicalPath: "/organizers/bhag/",
      indexStatus: "indexed",
      publishStatus: "published",
    },
    claim: {claimTargetPath: "clubs/bhag"},
    legacyClubCompatibility: {documentId: "bhag"},
  });
  fixture.claimTargetPlan.targets.push({
    claimState: "unclaimed",
    clubDocument: {
      claim: {state: "unclaimed"},
      ownership: {state: "programmatic"},
      publicPage: {canonicalPath: "/organizers/bhag/"},
    },
    entityId: "bhag",
    path: "clubs/bhag",
  });
  fixture.claimTargetSyncPreview.actions.push({
    entityId: "bhag",
    path: "clubs/bhag",
    status: "create",
    merge: false,
    reason: "missing_claim_target",
    requiresFirestoreDryRun: true,
  });
  fixture.claimTargetSyncPreview.summary.targets = 2;
  fixture.claimTargetSyncPreview.summary.creates = 2;
  fixture.claimTargetSyncPreview.summary.writesNeeded = 2;

  const suppressed = checkPromotionBridge(fixture);
  assert.deepEqual(suppressed.errors, []);
  assert.equal(suppressed.summary.pilotSuppressedProjections, 1);

  fixture.hostListings.push({
    dataOrigin: "organizerIntake",
    id: "bhag",
    indexing: "index, follow",
    legacyPaths: ["/organizers/delhi-ncr/bhag-club/"],
    path: "/organizers/bhag/",
    status: "unclaimed",
  });
  const leaked = checkPromotionBridge(fixture);
  assert.match(leaked.errors.join("\n"), /waitlist-market organizer leaked/);
});

test("checkPromotionBridge rejects legacy duplicate listings for canonical organizers", () => {
  const fixture = bridgeFixture();
  fixture.hostListings.push({
    dataOrigin: "scrapedSeed",
    id: "afterfly-run-club-indore",
    indexing: "noindex, follow",
    legacyPaths: [],
    path: "/organizers/indore/afterfly-run-club/",
    status: "unclaimed",
  });

  const result = checkPromotionBridge(fixture);

  assert.match(
    result.errors.join("\n"),
    /legacy path still has a generated listing/
  );
});

test("checkPromotionBridge rejects approved projections without canonical host entities", () => {
  const fixture = bridgeFixture();
  fixture.canonicalHostEntities.entries = [];

  const result = checkPromotionBridge(fixture);

  assert.match(result.errors.join("\n"), /missing canonical host entity/);
});

test("checkPromotionBridge rejects stale claim-target sync previews", () => {
  const fixture = bridgeFixture();
  fixture.claimTargetSyncPreview.actions = [];
  fixture.claimTargetSyncPreview.summary = {
    creates: 0,
    refreshes: 0,
    skippedOwnerBound: 0,
    targets: 0,
    writesNeeded: 0,
  };

  const result = checkPromotionBridge(fixture);

  assert.match(
    result.errors.join("\n"),
    /missing claim-target sync preview action/
  );
  assert.match(
    result.errors.join("\n"),
    /claim-target sync preview targets 0 does not match claim target plan 1/
  );
});

function bridgeFixture() {
  return {
    canonicalHostEntities: {
      entries: [
        {
          canonicalHostId: "afterfly",
          entityId: "afterfly",
          publicPresence: {
            canonicalPath: "/organizers/afterfly/",
            indexStatus: "indexed",
            publishStatus: "published",
          },
          claim: {
            claimTargetPath: "clubs/afterfly",
          },
          legacyClubCompatibility: {
            documentId: "afterfly",
          },
        },
      ],
    },
    claimTargetPlan: {
      targets: [
        {
          claimState: "unclaimed",
          clubDocument: {
            claim: {state: "unclaimed"},
            ownership: {state: "programmatic"},
            publicPage: {canonicalPath: "/organizers/afterfly/"},
          },
          entityId: "afterfly",
          path: "clubs/afterfly",
        },
      ],
    },
    claimTargetSyncPreview: {
      schemaVersion: 1,
      mode: {
        previewOnly: true,
        remoteReads: 0,
        remoteWrites: 0,
      },
      summary: {
        creates: 1,
        refreshes: 0,
        skippedOwnerBound: 0,
        targets: 1,
        writesNeeded: 1,
      },
      actions: [
        {
          entityId: "afterfly",
          path: "clubs/afterfly",
          status: "create",
          merge: false,
          reason: "missing_claim_target",
          requiresFirestoreDryRun: true,
        },
      ],
    },
    hostListings: [
      {
        dataOrigin: "organizerIntake",
        id: "afterfly",
        indexing: "index, follow",
        legacyPaths: ["/organizers/indore/afterfly-run-club/"],
        path: "/organizers/afterfly/",
        status: "unclaimed",
      },
    ],
    projectionPlan: {
      entries: [
        {
          entityId: "afterfly",
          indexStatus: "indexed",
          legacyPaths: ["/organizers/indore/afterfly-run-club/"],
          projectionStatus: "ready",
          publicListing: {
            id: "afterfly",
            indexing: "index, follow",
            markets: [{marketSlug: "indore", displayName: "Indore"}],
            path: "/organizers/afterfly/",
            status: "unclaimed",
          },
          publishStatus: "published",
        },
      ],
    },
  };
}
