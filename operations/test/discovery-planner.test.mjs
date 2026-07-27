import assert from "node:assert/strict";
import test from "node:test";
import {
  planDiscoveryQueries,
} from "../src/workflows/supply-intake/discovery-planner.mjs";

test("Mumbai discovery planning is deterministic and bounded by reviewed policy",
  async () => {
    const candidate = {
      candidateId: "courtside",
      displayName: "Courtside",
      categoryId: "racket_sport_social",
      citySlug: "mumbai",
      state: "candidate",
      priority: "p1",
    };
    const first = await planDiscoveryQueries({
      market: "mumbai",
      organizerCandidates: [candidate, candidate],
    });
    const second = await planDiscoveryQueries({
      market: "mumbai",
      organizerCandidates: [candidate, candidate],
    });

    assert.deepEqual(second, first);
    assert.equal(first.plannerId, "operations-supply-discovery-v1");
    assert.equal(first.market, "mumbai");
    assert.equal(
      first.planned.filter((entry) =>
        entry.planKind === "generic_city_category").length,
      13
    );
    assert.equal(
      first.planned.filter((entry) =>
        entry.planKind === "candidate_verification").length,
      5
    );
    assert.equal(new Set(first.planned.map((entry) => entry.runKey)).size, 18);
    assert.ok(first.planned.some((entry) =>
      entry.runKey ===
        "web_search|\"courtside\" mumbai|mumbai|racket_sport_social|courtside"
    ));
  });

test("candidate verification rejects out-of-market and unreviewed candidates",
  async () => {
    const result = await planDiscoveryQueries({
      market: "indore",
      organizerCandidates: [
        {
          candidateId: "wrong-market",
          displayName: "Wrong Market",
          citySlug: "mumbai",
          state: "candidate",
          priority: "p1",
        },
        {
          candidateId: "wrong-state",
          displayName: "Wrong State",
          citySlug: "indore",
          state: "raw",
          priority: "p1",
        },
        {
          candidateId: "wrong-priority",
          displayName: "Wrong Priority",
          citySlug: "indore",
          state: "candidate",
          priority: "p3",
        },
      ],
    });

    assert.equal(
      result.planned.filter((entry) =>
        entry.planKind === "candidate_verification").length,
      0
    );
    assert.ok(result.planned.length > 0);
    assert.ok(result.planned.every((entry) => entry.citySlug === "indore"));
  });
