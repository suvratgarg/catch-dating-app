import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  buildClaimTargetSyncPreview,
  buildClaimTargetSyncActions,
  changedPublicRefreshPatch,
  isOwnerBoundClubDoc,
  publicRefreshPatch,
} from "./lib/claim_target_sync_core.mjs";
import {buildReadinessReceipt, loadPlan} from "./sync_claim_targets_to_firestore.mjs";

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
  assert.equal(isOwnerBoundClubDoc({ownership: {state: "userCreated"}}), true);
  assert.equal(isOwnerBoundClubDoc({hostUserIds: ["manager"]}), true);
  assert.equal(isOwnerBoundClubDoc({ownership: {primaryHostUserId: "manager"}}), true);
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

test("buildReadinessReceipt binds live state to the exact claim target plan", (t) => {
  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-claim-target-plan-"));
  t.after(() => fs.rmSync(tmpRoot, {recursive: true, force: true}));
  const planPath = path.join(tmpRoot, "organizer_claim_targets.json");
  fs.writeFileSync(
    planPath,
    `${JSON.stringify({targets: [claimTarget()]}, null, 2)}\n`
  );
  const actions = buildClaimTargetSyncActions([claimTarget()], new Map());
  const receipt = buildReadinessReceipt({
    actions,
    fixture: null,
    generatedAt: "2026-07-11T00:00:00.000Z",
    planPath,
    projectId: "catchdates-dev",
    summary: summarizeActionsForTest(actions),
  });

  assert.equal(receipt.receiptType, "organizer_claim_target_readiness");
  assert.equal(receipt.projectId, "catchdates-dev");
  assert.equal(receipt.mode.source, "firestore_read");
  assert.equal(receipt.mode.remoteWrites, 0);
  assert.match(receipt.plan.sha256, /^[a-f0-9]{64}$/);
  assert.equal(receipt.actions[0].status, "create");
});


test("migration plan accepts explicit canonical targets and rejects identity or document aliases", (t) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-canonical-plan-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const planPath = path.join(root, "plan.json");
  const target = {entityId: "afterfly", path: "organizers/afterfly",
    claimState: "unclaimed", organizerDocument: canonicalOrganizerDocument()};
  fs.writeFileSync(planPath, JSON.stringify({schemaVersion: 1, targets: [target]}));
  const plan = loadPlan(planPath);
  const actions = buildClaimTargetSyncActions(plan.targets, new Map());
  assert.equal(actions[0].path, "organizers/afterfly");
  assert.equal(actions[0].writeData.claim.state, "unclaimed");
  assert.equal(buildClaimTargetSyncActions(plan.targets,
    new Map([[target.path, target.organizerDocument]]))[0].status, "in_sync");
  for (const change of [
    (target) => {target.path = "organizers/another-id";},
    (target) => {target.path = "organizers/afterfly/subcollection/doc";},
    (target) => {target.clubDocument = target.organizerDocument; delete target.organizerDocument;},
    (target) => {target.organizerDocument.claim.state = "claimed";},
    (target) => {target.organizerDocument.ownerUserId = "another-owner";},
  ]) {
    const invalid = structuredClone(target);
    change(invalid);
    fs.writeFileSync(planPath, JSON.stringify({schemaVersion: 1, targets: [invalid]}));
    assert.throws(() => loadPlan(planPath));
  }
});

function claimTarget() {
  return {
    entityId: "afterfly",
    path: "clubs/afterfly",
    clubDocument: clubDocument(),
  };
}

function canonicalOrganizerDocument() {
  const document = JSON.parse(fs.readFileSync(new URL(
    "../../contracts/fixtures/valid/club_doc.json", import.meta.url), "utf8"));
  delete document.memberCount;
  Object.assign(document, {organizerType: "eventProducer", organizerPhotos: [], followerCount: 0,
    hostUserId: null, ownerUserId: null, hostName: null, hostAvatarUrl: null,
    hostUserIds: [], hostProfiles: [], ownership: {state: "programmatic",
      ownerUserId: null, primaryHostUserId: null, hostUserIds: [], claimedAt: null, claimedByUid: null},
    claim: {state: "unclaimed", claimHref: null, lastClaimRequestId: null}});
  return document;
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

function summarizeActionsForTest(actions) {
  return {
    targets: actions.length,
    creates: actions.filter((action) => action.status === "create").length,
    refreshes: actions.filter((action) => action.status === "refresh").length,
    inSync: actions.filter((action) => action.status === "in_sync").length,
    skippedOwnerBound: actions.filter((action) =>
      action.status === "skip_owner_bound"
    ).length,
    writesNeeded: actions.filter((action) =>
      action.status === "create" || action.status === "refresh"
    ).length,
  };
}
