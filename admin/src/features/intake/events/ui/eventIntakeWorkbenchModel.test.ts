import {describe, expect, it} from "vitest";
import type {
  EventIntakeCandidate,
  EventIntakeSourceResult,
} from "../../../../shared/types/adminTypes";
import {
  bridgeIsStale,
  buildEventIntakeEditDiff,
  candidateChecks,
  eventCandidateStage,
  eventWhenLabel,
  recordsForStage,
} from "./eventIntakeWorkbenchModel";

const now = new Date("2026-07-27T08:00:00.000Z");

function candidate(
  id: string,
  patch: Partial<EventIntakeCandidate> = {}
): EventIntakeCandidate {
  return {
    id,
    title: id,
    category: "social",
    neighborhood: "Bandra",
    venue: "Court",
    startDate: "2026-07-28",
    endDate: "2026-07-28",
    expiresAt: "2026-07-28T18:00:00.000Z",
    time: "18:00",
    price: "Free",
    sourceResultIds: [],
    sourceUrl: "https://example.com/event",
    sourceLabel: "Official",
    reviewState: "new",
    requiresVerification: false,
    explicitSinglesEvent: false,
    whySinglesFriendly: "",
    publicDescription: "A current event.",
    scores: {},
    sourceCoverage: {
      sourceResultIds: [],
      matchedSourceResults: 0,
      hasSourceUrl: true,
      hasManualInstagramReference: false,
    },
    sourceStatus: "source_backed",
    publishability: "reviewable_needs_verification",
    dedupe: {
      normalizedEventKey: id,
      canonicalCandidateId: id,
      duplicateCandidateIds: [],
    },
    score: 0,
    warnings: [],
    attribution: {
      state: "attributed",
      organizerEvidence: {name: "Organizer", url: null},
      match: {
        decision: "matched",
        policyId: "test",
        threshold: 1,
        rationale: "fixture",
        matchedEntityId: "organizer-1",
        score: 1,
        matchingSignals: [],
        blockingKeys: [],
      },
    },
    ...patch,
  };
}

describe("event intake workbench model", () => {
  it("assigns every candidate to one exclusive stage", () => {
    const values = [
      candidate("verify"),
      candidate("resolve", {sourceUrl: null}),
      candidate("ready", {reviewState: "approved"}),
      candidate("passed", {expiresAt: "2026-07-26T18:00:00.000Z"}),
    ];
    expect(values.map((value) => eventCandidateStage(value, now))).toEqual([
      "verify",
      "resolve",
      "ready",
      "passed",
    ]);
    const active = (["verify", "resolve", "ready"] as const).flatMap((stage) =>
      recordsForStage([], values, stage, now));
    expect(new Set(active.map((record) => record.value.id)).size).toBe(3);
  });

  it("blocks and labels passed events from Operations expiry", () => {
    const value = candidate("passed", {
      expiresAt: "2026-07-26T18:00:00.000Z",
    });
    expect(candidateChecks(value, now)).toContainEqual(expect.objectContaining({
      id: "event_has_not_passed",
      passed: false,
    }));
    expect(eventWhenLabel(value, now)).toContain("passed");
  });

  it("sorts upcoming candidates before later candidates", () => {
    const records = recordsForStage([], [
      candidate("later", {expiresAt: "2026-07-30T18:00:00.000Z"}),
      candidate("sooner", {expiresAt: "2026-07-28T18:00:00.000Z"}),
    ], "verify", now);
    expect(records.map((record) => record.value.id)).toEqual([
      "sooner",
      "later",
    ]);
  });

  it("emits changed fields only with before and after values", () => {
    expect(buildEventIntakeEditDiff(
      {title: "Before", venue: "Court"},
      {title: "After", venue: "Court", ignored: "value"},
      ["title", "venue"]
    )).toEqual({
      title: {before: "Before", after: "After"},
    });
  });

  it("names stale bridge state", () => {
    expect(bridgeIsStale(
      "2026-07-10T00:00:00.000Z",
      7,
      now
    )).toBe(true);
    expect(bridgeIsStale(
      "2026-07-27T00:00:00.000Z",
      7,
      now
    )).toBe(false);
  });

  it("keeps source leads in Incoming only", () => {
    const source = {
      id: "source-1",
      title: "Source",
    } as EventIntakeSourceResult;
    expect(recordsForStage([source], [], "incoming", now)).toEqual([
      {kind: "source", value: source},
    ]);
    expect(recordsForStage([source], [], "verify", now)).toEqual([]);
  });
});
