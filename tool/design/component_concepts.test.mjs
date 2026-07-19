#!/usr/bin/env node
import assert from "node:assert/strict";
import test from "node:test";
import {
  collisionKeyFor,
  conceptMetrics,
  conceptTopologyProblems,
  normalizeSymbol,
} from "./component_concepts.mjs";

const primary = (id, symbol) => ({
  id,
  dart: {symbol},
  governance: {conceptRole: "concept", conceptId: id},
  contract: {members: []},
});

test("normalization deliberately forces comparable names into one namespace", () => {
  assert.equal(normalizeSymbol("CatchPrivacyBadge"), "privacy_badge");
  assert.equal(normalizeSymbol("PrivacyBadgeView"), "privacy_badge");
});

test("member collision keys resolve to the owning concept", () => {
  assert.equal(
    collisionKeyFor({conceptRole: "member", conceptId: "catch.badge", symbol: "CatchPrivacyBadge"}),
    "catch.badge",
  );
});

test("known-bad duplicate primaries and missing parents are rejected", () => {
  const bad = [
    primary("catch.badge", "CatchBadge"),
    {
      ...primary("catch.badge_alias", "CatchBadgeAlias"),
      governance: {conceptRole: "concept", conceptId: "catch.badge"},
    },
    {
      id: "catch.privacy_badge",
      dart: {symbol: "CatchPrivacyBadge"},
      governance: {
        conceptRole: "member",
        conceptId: "catch.missing",
        parentConceptId: "catch.missing",
      },
      contract: {members: []},
    },
  ];
  const problems = conceptTopologyProblems(bad).join("\n");
  assert.match(problems, /duplicate concept primary/u);
  assert.match(problems, /missing concept primary catch\.missing/u);
});

test("metrics count concepts rather than public contracts", () => {
  const components = [
    primary("catch.badge", "CatchBadge"),
    {
      id: "catch.privacy_badge",
      dart: {symbol: "CatchPrivacyBadge"},
      governance: {
        conceptRole: "member",
        conceptId: "catch.badge",
        parentConceptId: "catch.badge",
      },
      contract: {members: []},
    },
    {
      id: "catch.notification_row",
      dart: {symbol: "NotificationRow"},
      governance: {conceptRole: "composition"},
      contract: {members: []},
    },
  ];
  assert.deepEqual(
    conceptMetrics(components),
    {
      contractCount: 3,
      publicClassCount: 3,
      conceptCount: 1,
      memberCount: 1,
      membersPerConcept: 1,
      unclassifiedCount: 0,
      byConceptRole: {composition: 1, concept: 1, member: 1},
      collisionCount: 1,
      collisions: [{key: "catch.badge", symbols: ["CatchBadge", "CatchPrivacyBadge"]}],
      naming: {
        canonicalConceptNames: 1,
        documentedConceptNameExceptions: 0,
        undocumentedConceptNameExceptions: 0,
      },
    },
  );
});
