import assert from "node:assert/strict";
import test from "node:test";
import {buildExternalEventLocationResolutionQueue} from
  "./lib/event_location_resolution_core.mjs";

test("location resolution queue creates tasks for missing coordinates", () => {
  const queue = buildExternalEventLocationResolutionQueue(candidateQueue([
    candidate(),
  ]));

  assert.equal(queue.summary.candidates, 1);
  assert.equal(queue.summary.tasks, 1);
  assert.equal(queue.summary.missingExactCoordinates, 1);
  assert.equal(queue.tasks[0].candidateId, "batch-1:event-1");
  assert.equal(queue.tasks[0].resolutionQuery, "Indore, Indore, MP, IN, indore, IN");
  assert.ok(queue.tasks[0].blockers.includes("missing_exact_coordinates"));
  assert.ok(queue.tasks[0].blockers.includes(
    "location_resolution_provider_disabled"
  ));
});

test("location resolution queue skips candidates with exact coordinates", () => {
  const queue = buildExternalEventLocationResolutionQueue(candidateQueue([
    candidate({
      location: {
        address: "Nehru Stadium, Indore, MP, IN",
        citySlug: "indore",
        countryCode: "IN",
        latitude: 22.7161,
        longitude: 75.8552,
        name: "Nehru Stadium",
      },
    }),
  ]));

  assert.equal(queue.summary.candidates, 1);
  assert.equal(queue.summary.tasks, 0);
});

test("location resolution queue reports missing location text", () => {
  const queue = buildExternalEventLocationResolutionQueue(candidateQueue([
    candidate({
      location: {
        address: null,
        citySlug: "indore",
        countryCode: "IN",
        name: null,
      },
    }),
  ]));

  assert.equal(queue.summary.missingLocationText, 1);
  assert.equal(queue.tasks[0].resolutionQuery, "indore, IN");
  assert.ok(queue.tasks[0].blockers.includes("missing_location_text"));
});

function candidateQueue(candidates) {
  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: ["batch-1"],
      reviewDecisionBatches: [],
    },
    summary: {
      candidates: candidates.length,
    },
    candidates,
  };
}

function candidate(overrides = {}) {
  return {
    batchId: "batch-1",
    candidateId: "batch-1:event-1",
    entityId: "afterfly",
    eventUrl: "https://luma.com/event-1",
    location: {
      address: "Indore, MP, IN",
      citySlug: "indore",
      countryCode: "IN",
      name: "Indore",
    },
    platform: "luma",
    sourceEventKey: "luma:event:event-1",
    sourceUrl: "https://luma.com/event-1",
    startAt: "2025-03-15T18:00:00+05:30",
    title: "Takeoff: Run + Rave",
    ...overrides,
  };
}
