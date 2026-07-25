import assert from "node:assert/strict";
import test from "node:test";
import {
  applyOrganizerCandidateProvenanceRepairPlan,
  buildOrganizerCandidateProvenanceRepairPlan,
} from "./backfill_organizer_candidate_provenance.mjs";

test("repairs persisted organizer candidates without external source files",
  async () => {
    const firestore = fakeFirestore({
      "wi-courtside": candidateWorkItem(),
      "wi-event": {workflowId: "supply-intake", entityKind: "event"},
    });
    const plan = await buildOrganizerCandidateProvenanceRepairPlan(firestore);
    assert.equal(plan.summary.workItemsScanned, 2);
    assert.equal(plan.summary.candidateItems, 1);
    assert.equal(plan.summary.repairsNeeded, 1);
    assert.deepEqual(
      plan.repairs[0].patch.fieldProvenance.map((entry) => entry.field),
      [
        "sourceEntity.title",
        "intake.candidate.title",
        "intake.candidate.canonicalUrl",
        "intake.candidate.snippet",
        "intake.candidate.queryIntent.marketSlug",
        "intake.candidate.reviewContext.formats",
        "intake.candidate.reviewContext.reviewNotes",
        "intake.candidate.reviewContext.verifiedAt",
      ]
    );
    await applyOrganizerCandidateProvenanceRepairPlan(firestore, plan);
    assert.equal(
      firestore.data["wi-courtside"].fieldProvenance.length,
      8
    );
  });

function candidateWorkItem() {
  return {
    workflowId: "supply-intake",
    entityKind: "organizer",
    evidenceRefs: [{
      artifactId: "artifact-courtside",
      contentHash: "a".repeat(64),
      locator: "firestore:organizerCandidates/courtside",
    }],
    fieldProvenance: [{
      field: "sourceEntity.title",
      artifactId: "artifact-courtside",
      contentHash: "a".repeat(64),
      locator: "firestore:organizerCandidates/courtside",
      extractedBy: "deterministic",
      extractorVersion: "supply-intake-v0.1.0",
      confidence: 0.7,
    }],
    normalizedPayload: {
      confidence: {overall: 0.8},
      intake: {
        recordType: "organizer_search_candidate",
        candidate: {
          candidateId: "courtside",
          title: "Courtside",
          canonicalUrl: "https://courtside.example/",
          snippet: "Padel community.",
          queryIntent: {marketSlug: "mumbai"},
          reviewContext: {
            formats: ["Padel"],
            reviewNotes: "Verify cadence.",
            verifiedAt: "2026-07-24",
          },
        },
      },
    },
  };
}

function fakeFirestore(initial) {
  const data = structuredClone(initial);
  return {
    data,
    collection: () => ({
      get: async () => ({
        size: Object.keys(data).length,
        docs: Object.entries(data).map(([id, value]) => ({
          id,
          ref: {path: `operationWorkItems/${id}`},
          data: () => structuredClone(value),
        })),
      }),
    }),
    doc: (documentPath) => ({
      update: (patch) => {
        const id = documentPath.split("/").at(-1);
        data[id] = {...data[id], ...structuredClone(patch)};
      },
    }),
    batch: () => {
      const writes = [];
      return {
        update: (ref, patch) => writes.push(() => ref.update(patch)),
        commit: async () => writes.forEach((write) => write()),
      };
    },
  };
}
