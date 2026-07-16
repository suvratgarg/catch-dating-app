import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {checkScreenTopBarContracts} from "./check_screen_top_bar_contracts.mjs";

test("accepts registered app-bar, tab-root, geometry, and hero contracts", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'July 2026'));",
    contract: screenContract(),
    rawSource: "Widget build() => SliverAppBar();",
    rawChromeExceptions: [heroException()],
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
  assert.equal(result.rootHeaderCount, 1);
  assert.equal(result.rawChromeCount, 1);
});

test("accepts the shared tabbed scaffold as a canonical root-header owner", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'Fallback'));",
    contract: screenContract(),
    rootSurface: rootSurface({owner: "CatchTabbedScreenScaffold"}),
    rootSource: `
      class RootHeader {
        Widget build() => CatchTabbedScreenScaffold(
          title: 'Profile',
          tabRail: rail,
          body: body,
        );
      }
    `,
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
});

test("flags the known-bad screen fixture when compact chrome replaces the screen title voice", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Calendar'));",
    contract: screenContract(),
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "wrong-app-bar-expression"));
  assert.ok(hasFinding(result, "missing-canonical-owner"));
});

test("flags a new app bar until its screen-chrome role is registered", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'Calendar'));",
    contract: screenContract(),
    extraSource: "Scaffold(appBar: CatchTopBar(title: 'New route'));",
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(
    result.findings.some(
      (finding) =>
        finding.code === "unregistered-app-bar" &&
        finding.path === "lib/new/new_screen.dart",
    ),
  );
});

test("flags a raw Material app bar even when a manifest entry tries to bless it", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: AppBar(title: const Text('Calendar')));",
    contract: screenContract({expression: "AppBar", owner: "AppBar"}),
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "role-owner-drift"));
  assert.ok(hasFinding(result, "role-expression-drift"));
  assert.ok(hasFinding(result, "unregistered-raw-chrome"));
});

test("does not let a compact contract bless raw chrome", () => {
  const root = fixtureRoot({
    source: `
      Widget decoy() => CatchTopBar(title: 'Elsewhere');
      Widget build() => Scaffold(appBar: AppBar(title: const Text('Raw')));
    `,
    contract: compactContract({expression: "AppBar"}),
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "role-expression-drift"));
  assert.ok(hasFinding(result, "missing-canonical-owner"));
});

test("does not count a canonical call outside a helper-owned appBar", () => {
  const root = fixtureRoot({
    source: `
      PreferredSizeWidget helper() => AppBar(title: const Text('Raw'));
      Widget decoy() => CatchTopBar(title: 'Elsewhere');
      Widget build() => Scaffold(appBar: helper());
    `,
    contract: compactContract({expression: "helper"}),
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "role-expression-drift"));
  assert.ok(hasFinding(result, "missing-canonical-owner"));
});

test("flags every tab-root branch that lacks a root-header contract", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'Calendar'));",
    contract: screenContract(),
    rootHeaders: [],
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "missing-root-headers"));
  assert.ok(hasFinding(result, "unregistered-root-header"));
});

test("flags a custom tab-root header that does not delegate to the canonical owner", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'Calendar'));",
    contract: screenContract(),
    rootSource: `
      class RootHeader {
        Widget build() => Text('Today', style: CatchTextStyles.headlineS(context));
      }
    `,
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "missing-root-header-owner"));
  assert.ok(hasFinding(result, "local-root-title-style"));
});

test("flags root-header text-scale and geometry overrides", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'Calendar'));",
    contract: screenContract(),
    rootSurface: rootSurface({owner: "CatchScreenTopBar"}),
    rootSource: `
      class RootHeader {
        Widget build() => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
          child: CatchScreenTopBar(
            title: 'Chats',
            height: 56,
            contentPadding: EdgeInsets.zero,
          ),
        );
      }
    `,
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "root-title-text-scale-override"));
  assert.ok(hasFinding(result, "root-header-geometry-override"));
});

test("flags local geometry on a screen-role Scaffold app bar", () => {
  const root = fixtureRoot({
    source: `
      Scaffold(
        appBar: CatchScreenTopBar(
          title: 'Calendar',
          contentPadding: EdgeInsets.zero,
        ),
      );
    `,
    contract: screenContract(),
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "screen-chrome-geometry-override"));
});

test("flags raw sliver chrome until a durable hero exception is registered", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'Calendar'));",
    contract: screenContract(),
    rawSource: "Widget build() => SliverAppBar();",
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "unregistered-raw-chrome"));
});

test("flags an aliased or non-zero canonical screen-title inset", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'Calendar'));",
    contract: screenContract(),
    tokenSource:
      "static const EdgeInsets screenTitleBlock = pageHeaderCompact;",
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "screen-geometry-not-owned"));
});

function hasFinding(result, code) {
  return result.findings.some((finding) => finding.code === code);
}

function screenContract({
  expression = "CatchScreenTopBar",
  owner = "CatchScreenTopBar",
} = {}) {
  return {
    path: "lib/calendar/calendar_screen.dart",
    role: "screen",
    expression,
    owner,
  };
}

function compactContract({expression = "CatchTopBar"} = {}) {
  return {
    path: "lib/calendar/calendar_screen.dart",
    role: "compact",
    expression,
    owner: "CatchTopBar",
  };
}

function rootSurface({owner = "CatchScreenHeaderTitle.block"} = {}) {
  return {
    path: "lib/root/root_header.dart",
    symbol: "RootHeader",
    owner,
  };
}

function heroException() {
  return {
    path: "lib/hero/hero_header.dart",
    expression: "SliverAppBar",
    occurrences: 1,
    reason: "Detail media hero owns collapsing photo chrome.",
  };
}

function fixtureRoot({
  source,
  contract,
  extraSource,
  rootSource = `
    class RootHeader {
      Widget build() => CatchScreenHeaderTitle.block(title: 'Home');
    }
  `,
  rootSurface: configuredRootSurface = rootSurface(),
  rootHeaders,
  rawSource,
  rawChromeExceptions = [],
  tokenSource = `
    static const EdgeInsets screenTitleBlock = EdgeInsets.fromLTRB(
      CatchSpacing.s5,
      CatchSpacing.s0,
      CatchSpacing.s5,
      CatchSpacing.s3,
    );
  `,
}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-screen-chrome-"));
  write(root, contract.path, source);
  write(root, configuredRootSurface.path, rootSource);
  write(root, "lib/core/theme/catch_tokens.dart", tokenSource);
  if (extraSource != null) {
    write(root, "lib/new/new_screen.dart", extraSource);
  }
  if (rawSource != null) {
    write(root, "lib/hero/hero_header.dart", rawSource);
  }

  const configuredRootHeaders =
    rootHeaders ??
    [
      {
        branchKey: "_dashboardShellKey",
        routeName: "Routes.dashboardScreen.name",
        surfaces: [configuredRootSurface],
      },
    ];
  write(
    root,
    "tool/design/tab_root_scroll_contracts.json",
    JSON.stringify({
      schemaVersion: 1,
      branches: [
        {
          branchKey: "_dashboardShellKey",
          routeName: "Routes.dashboardScreen.name",
          owners: [],
        },
      ],
    }),
  );
  write(
    root,
    "tool/design/screen_top_bar_contracts.json",
    JSON.stringify({
      schemaVersion: 2,
      logicalName: "fixture",
      tabRootManifestPath: "tool/design/tab_root_scroll_contracts.json",
      screenGeometry: {
        tokenPath: "lib/core/theme/catch_tokens.dart",
        token: "screenTitleBlock",
        topInset: "CatchSpacing.s0",
      },
      contracts: [contract],
      rootHeaders: configuredRootHeaders,
      rawChromeExceptions,
    }),
  );
  return root;
}

function write(root, relativePath, contents) {
  const absolutePath = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(absolutePath), {recursive: true});
  fs.writeFileSync(absolutePath, contents);
}
