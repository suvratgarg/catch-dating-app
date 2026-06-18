import assert from "node:assert/strict";
import test from "node:test";
import {
  buildClaimTargetSyncPreview,
  buildClaimTargetSyncActions,
  changedPublicRefreshPatch,
  isOwnerBoundClubDoc,
  publicRefreshPatch,
} from "./lib/claim_target_sync_core.mjs";

test("buildClaimTargetSyncActions creates missing claim targets", () => {
  const actions = buildClaimTargetSyncActions([claimTarget()], new Map());

  assert.equal(actions.length, 1);
  assert.equal(actions[0].status, "create");
  assert.equal(actions[0].merge, false);
  assert.equal(actions[0].writeData.claim.state, "unclaimed");
});

test("buildClaimTargetSyncActions refreshes only public fields for unclaimed docs", () => {
  const target = claimTarget();
  const actions = buildClaimTargetSyncActions(
    [target],
    new Map([
      [
        "clubs/afterfly",
        {
          claim: {state: "claimPending", lastClaimRequestId: "request-1"},
          memberCount: 12,
          ownerUserId: null,
        },
      ],
    ])
  );

  assert.equal(actions[0].status, "refresh");
  assert.equal(actions[0].merge, true);
  assert.equal(actions[0].writeData.name, "AFTER FLY");
  assert.equal(actions[0].writeData.publicPage.canonicalPath, "/organizers/afterfly/");
  assert.equal(Object.hasOwn(actions[0].writeData, "claim"), false);
  assert.equal(Object.hasOwn(actions[0].writeData, "memberCount"), false);
  assert.equal(Object.hasOwn(actions[0].writeData, "ownerUserId"), false);
});

test("buildClaimTargetSyncActions skips unclaimed docs already in sync", () => {
  const target = claimTarget();
  const actions = buildClaimTargetSyncActions(
    [target],
    new Map([["clubs/afterfly", {...target.clubDocument}]])
  );

  assert.equal(actions[0].status, "in_sync");
  assert.equal(actions[0].merge, false);
  assert.equal(actions[0].writeData, null);
});

test("buildClaimTargetSyncActions skips owner-bound docs", () => {
  const actions = buildClaimTargetSyncActions(
    [claimTarget()],
    new Map([
      [
        "clubs/afterfly",
        {
          claim: {state: "claimed"},
          ownerUserId: "owner-1",
        },
      ],
    ])
  );

  assert.equal(actions[0].status, "skip_owner_bound");
  assert.equal(actions[0].writeData, null);
});

test("publicRefreshPatch excludes ownership and aggregate fields", () => {
  const patch = publicRefreshPatch(clubDocument());

  assert.equal(patch.name, "AFTER FLY");
  assert.equal(patch.appVisibility, "hidden");
  assert.equal(Object.hasOwn(patch, "ownership"), false);
  assert.equal(Object.hasOwn(patch, "claim"), false);
  assert.equal(Object.hasOwn(patch, "rating"), false);
});

test("changedPublicRefreshPatch normalizes timestamp-shaped values", () => {
  const generatedPatch = {
    name: "AFTER FLY",
    provenance: {
      origin: "scraper",
      lastVerifiedAt: {_seconds: 1781740800, _nanoseconds: 0},
    },
  };
  const existingDoc = {
    name: "AFTER FLY",
    provenance: {
      origin: "scraper",
      lastVerifiedAt: {
        toMillis: () => 1781740800000,
      },
    },
  };

  assert.deepEqual(changedPublicRefreshPatch(generatedPatch, existingDoc), {});
});

test("isOwnerBoundClubDoc detects claimed and verified ownership states", () => {
  assert.equal(isOwnerBoundClubDoc({ownerUserId: "owner-1"}), true);
  assert.equal(isOwnerBoundClubDoc({hostUserId: "host-1"}), true);
  assert.equal(isOwnerBoundClubDoc({ownership: {state: "claimed"}}), true);
  assert.equal(isOwnerBoundClubDoc({claim: {state: "verified"}}), true);
  assert.equal(isOwnerBoundClubDoc({claim: {state: "claimPending"}}), false);
});

test("buildClaimTargetSyncPreview produces durable review actions", () => {
  const preview = buildClaimTargetSyncPreview({
    claimTargetPlan: {targets: [claimTarget()]},
    existingDocs: new Map(),
    existingDocsSource: "fixture",
  });

  assert.equal(preview.summary.targets, 1);
  assert.equal(preview.summary.creates, 1);
  assert.equal(preview.summary.writesNeeded, 1);
  assert.equal(preview.mode.previewOnly, true);
  assert.equal(preview.mode.remoteWrites, 0);
  assert.equal(preview.actions[0].status, "create");
  assert.equal(preview.actions[0].writesRemoteData, true);
  assert(preview.actions[0].writeFields.includes("publicPage"));
  assert.match(preview.commands.firestoreDryRun, /sync_claim_targets_to_firestore/);
});

function claimTarget() {
  return {
    entityId: "afterfly",
    path: "clubs/afterfly",
    clubDocument: clubDocument(),
  };
}

function clubDocument() {
  return {
    name: "AFTER FLY",
    description: "AFTER FLY organizer profile.",
    location: "indore",
    area: "Indore",
    hostUserId: null,
    ownerUserId: null,
    memberCount: 0,
    rating: 0,
    reviewCount: 0,
    appVisibility: "hidden",
    ownership: {state: "programmatic"},
    claim: {state: "unclaimed", claimHref: "/organizers/afterfly/#claim"},
    publicPage: {canonicalPath: "/organizers/afterfly/"},
    publicProfile: {headline: "AFTER FLY"},
  };
}
