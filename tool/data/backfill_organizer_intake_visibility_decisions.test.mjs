import assert from "node:assert/strict";
import test from "node:test";
import {
  applyOrganizerIntakeVisibilityRepairPlan,
  buildOrganizerIntakeVisibilityRepairPlan,
  visibilityPatchForDecision,
} from "./backfill_organizer_intake_visibility_decisions.mjs";

test("legacy decisions receive explicit equivalent visibility", () => {
  assert.deepEqual(visibilityPatchForDecision({
    decision: "approve_public",
    appVisibility: "hidden",
  }), {
    status: "repair",
    patch: {publishStatus: "published", indexStatus: "indexed"},
  });
  assert.deepEqual(visibilityPatchForDecision({decision: "hold"}), {
    status: "repair",
    patch: {publishStatus: "draft", indexStatus: "noindex"},
  });
  assert.deepEqual(visibilityPatchForDecision({decision: "suppress"}), {
    status: "repair",
    patch: {publishStatus: "suppressed", indexStatus: "noindex"},
  });
});

test("current and partially populated decisions are distinguished", () => {
  assert.deepEqual(visibilityPatchForDecision({
    decision: "approve_public",
    publishStatus: "draft",
    indexStatus: "noindex",
  }), {status: "current"});
  assert.equal(visibilityPatchForDecision({
    decision: "approve_public",
    publishStatus: "published",
  }).status, "invalid");
});

test("repair plan is dry-run inspectable and applies patches", async () => {
  const firestore = fakeFirestore({
    afterfly: {decision: "approve_public", appVisibility: "hidden"},
    held: {decision: "hold", appVisibility: "hidden"},
    current: {
      decision: "approve_public",
      publishStatus: "draft",
      indexStatus: "noindex",
      appVisibility: "hidden",
    },
  });
  const plan = await buildOrganizerIntakeVisibilityRepairPlan(firestore);

  assert.deepEqual(plan.summary, {
    decisionsScanned: 3,
    repairsNeeded: 2,
    alreadyCurrent: 1,
    invalid: 0,
    repairs: [
      {
        path: "organizerIntakeReviewDecisions/afterfly",
        entityId: "afterfly",
        decision: "approve_public",
        patch: {publishStatus: "published", indexStatus: "indexed"},
      },
      {
        path: "organizerIntakeReviewDecisions/held",
        entityId: "held",
        decision: "hold",
        patch: {publishStatus: "draft", indexStatus: "noindex"},
      },
    ],
    invalidDocuments: [],
  });

  await applyOrganizerIntakeVisibilityRepairPlan(firestore, plan);
  assert.deepEqual(firestore.data.afterfly, {
    decision: "approve_public",
    appVisibility: "hidden",
    publishStatus: "published",
    indexStatus: "indexed",
  });
  assert.deepEqual(firestore.data.current, {
    decision: "approve_public",
    publishStatus: "draft",
    indexStatus: "noindex",
    appVisibility: "hidden",
  });
});

function fakeFirestore(initial) {
  const data = structuredClone(initial);
  return {
    data,
    collection: () => ({
      get: async () => ({
        size: Object.keys(data).length,
        docs: Object.entries(data).map(([id, value]) => ({
          id,
          ref: {path: `organizerIntakeReviewDecisions/${id}`},
          data: () => structuredClone(value),
        })),
      }),
    }),
    doc: (documentPath) => ({
      path: documentPath,
      update: (patch) => {
        const id = documentPath.split("/").at(-1);
        data[id] = {...data[id], ...structuredClone(patch)};
      },
    }),
    batch: () => {
      const writes = [];
      return {
        update: (ref, patch) => writes.push(() => ref.update(patch)),
        commit: async () => {
          for (const write of writes) write();
        },
      };
    },
  };
}
