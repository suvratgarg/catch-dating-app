#!/usr/bin/env node
import assert from "node:assert/strict";
import test from "node:test";
import {
  collisionKeyFor,
  conceptMetrics,
  conceptTopologyProblems,
  newWidgetPolicyIssues,
  normalizeSymbol,
  publicWidgetNamingProblems,
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

test("new core widgets require canonical names and component contracts", () => {
  assert.deepEqual(
    newWidgetPolicyIssues(
      {
        name: "ScreenShell",
        file: "lib/core/widgets/screen_shell.dart",
        visibility: "public",
      },
      {
        widgetbookCovered: true,
        catalogMentioned: true,
        componentContracted: false,
      },
    ),
    ["noncanonical-core-widget-name", "missing-component-contract"],
  );
});

test("package widgets retain canonical names and required contracts", () => {
  assert.deepEqual(newWidgetPolicyIssues({
    name: "Surface", file: "packages/catch_ui/lib/src/primitives/surface.dart",
    visibility: "public",
  }, {widgetbookCovered: true, catalogMentioned: true, componentContracted: false}),
  ["noncanonical-core-widget-name", "missing-component-contract"]);
});

test("new private widgets remain a blocking destination", () => {
  assert.deepEqual(
    newWidgetPolicyIssues(
      {
        name: "_LocalShell",
        file: "lib/example/presentation/example.dart",
        visibility: "private",
      },
      {
        widgetbookCovered: false,
        catalogMentioned: false,
        componentContracted: false,
      },
    ),
    ["private-widget-class"],
  );
});

test("ungoverned normalized names and exact public duplicates fail", () => {
  const base = {
    classKind: "widget",
    visibility: "public",
    conceptRole: "composition",
    conceptId: null,
    collisionKey: "screen_shell",
  };
  const problems = publicWidgetNamingProblems([
    {...base, name: "CatchScreenShell", file: "lib/core/a.dart"},
    {...base, name: "ScreenShellView", file: "lib/feature/b.dart"},
    {...base, name: "CatchScreenShell", file: "lib/feature/c.dart"},
  ]).join("\n");
  assert.match(problems, /ungoverned normalized widget collision screen_shell/u);
  assert.match(problems, /duplicate public widget class CatchScreenShell/u);
});

test("registered concept members may intentionally share a normalized collision", () => {
  assert.deepEqual(
    publicWidgetNamingProblems([
      {
        classKind: "widget",
        visibility: "public",
        name: "CatchBadge",
        file: "lib/core/badge.dart",
        conceptRole: "concept",
        conceptId: "catch.badge",
        collisionKey: "catch.badge",
      },
      {
        classKind: "widget",
        visibility: "public",
        name: "BadgeView",
        file: "lib/core/privacy_badge.dart",
        conceptRole: "member",
        conceptId: "catch.badge",
        collisionKey: "catch.badge",
      },
    ]),
    [],
  );
});

test("canonical and uncontracted public widgets cannot evade normalized collisions", () => {
  const rows = [
    {
      name: "CatchBadge",
      file: "lib/core/widgets/catch_badge.dart",
      classKind: "widget",
      visibility: "public",
      conceptRole: "concept",
      conceptId: "catch.badge",
      collisionKey: collisionKeyFor({
        conceptRole: "concept",
        conceptId: "catch.badge",
        symbol: "CatchBadge",
      }),
    },
    {
      name: "BadgeView",
      file: "lib/features/badges/badge_view.dart",
      classKind: "widget",
      visibility: "public",
      conceptRole: "unclassified",
      conceptId: null,
      collisionKey: collisionKeyFor({
        conceptRole: "unclassified",
        conceptId: null,
        symbol: "BadgeView",
      }),
    },
  ];

  assert.deepEqual(publicWidgetNamingProblems(rows), [
    "ungoverned normalized widget collision badge: BadgeView, CatchBadge",
  ]);
});

test("exact public widget names collide across shared Consumer and Host roots", () => {
  const base = {
    name: "CatchCrossRootPanel",
    classKind: "widget",
    visibility: "public",
    conceptRole: "composition",
    conceptId: null,
  };

  assert.deepEqual(publicWidgetNamingProblems([
    {...base, file: "lib/core/widgets/catch_cross_root_panel.dart"},
    {...base, file: "apps/consumer/lib/cross_root_panel.dart"},
    {...base, file: "apps/host/lib/cross_root_panel.dart"},
  ]), [
    "duplicate public widget class CatchCrossRootPanel: " +
      "apps/consumer/lib/cross_root_panel.dart, apps/host/lib/cross_root_panel.dart, " +
      "lib/core/widgets/catch_cross_root_panel.dart",
  ]);
});

test("normalized public widget names collide across production roots", () => {
  const base = {
    classKind: "widget",
    visibility: "public",
    conceptRole: "composition",
    conceptId: null,
  };

  assert.deepEqual(publicWidgetNamingProblems([
    {
      ...base,
      name: "CatchCrossRootPanelWidget",
      file: "lib/core/widgets/catch_cross_root_panel.dart",
    },
    {
      ...base,
      name: "CrossRootPanelView",
      file: "apps/consumer/lib/cross_root_panel.dart",
    },
  ]), [
    "ungoverned normalized widget collision cross_root_panel: " +
      "CatchCrossRootPanelWidget, CrossRootPanelView",
  ]);
});

test("one governed concept family may span all production roots", () => {
  const governed = {
    classKind: "widget",
    visibility: "public",
    conceptId: "catch.cross_root_panel",
  };

  assert.deepEqual(publicWidgetNamingProblems([
    {
      ...governed,
      name: "CatchCrossRootPanel",
      file: "lib/core/widgets/catch_cross_root_panel.dart",
      conceptRole: "concept",
    },
    {
      ...governed,
      name: "CrossRootPanelView",
      file: "apps/consumer/lib/cross_root_panel.dart",
      conceptRole: "member",
    },
    {
      ...governed,
      name: "CrossRootPanelWidget",
      file: "apps/host/lib/cross_root_panel.dart",
      conceptRole: "member",
    },
  ]), []);
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
