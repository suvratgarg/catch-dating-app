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

test("accepts canonical route-scaffold top-bar builders", () => {
  const root = fixtureRoot({
    source: `
      CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: 'Review history',
          leadingType: CatchTopBarLeading.back,
          divider: scrolledUnder,
        ),
        body: ListView(),
      );
    `,
    contract: compactContract({leading: "back"}),
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
});

test("resolves canonical root chrome owned by a StatefulWidget state", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchScreenTopBar(title: 'Fallback'));",
    contract: screenContract(),
    rootSurface: rootSurface({owner: "CatchScreenTopBar"}),
    rootSource: `
      class RootHeader extends StatefulWidget {
        State<RootHeader> createState() => _RootHeaderState();
      }
      class _RootHeaderState extends State<RootHeader> {
        Widget build(BuildContext context) =>
          CatchScreenTopBar(title: 'Chats');
      }
    `,
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
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

test("flags every noncanonical surface inside an aligned root adopter", () => {
  const trackedPath = "lib/root/chats_browse_header.dart";
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Details'));",
    contract: compactContract(),
    includeRootContracts: false,
    trackedRootSources: [
      {
        path: trackedPath,
        source: `
          class ChatsBrowseHeader extends StatelessWidget {
            Widget build(BuildContext context) =>
              CatchScreenTopBar(title: 'Chats');
          }
          class ChatsLegacyTopBar extends StatelessWidget {
            Widget build(BuildContext context) => Text(
              'Chats',
              style: CatchTextStyles.headline(context),
            );
          }
        `,
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "tracked-root-header-noncanonical-owner"));
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

test("does not let workspace and raw-exception entries bless Material AppBar", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: AppBar(title: const Text('Workspace')));",
    contract: {
      path: "lib/calendar/calendar_screen.dart",
      role: "workspace",
      expression: "AppBar",
      owner: "AppBar",
      reason: "This deliberately adversarial workspace entry has a reason.",
    },
    rawChromeExceptions: [
      {
        path: "lib/calendar/calendar_screen.dart",
        expression: "AppBar",
        occurrences: 1,
        reason: "This deliberately adversarial raw exception has a reason.",
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "workspace-owner-drift"));
  assert.ok(hasFinding(result, "workspace-raw-expression"));
  assert.ok(hasFinding(result, "invalid-raw-hero-expression"));
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

test("accepts an app-bar-only ownership manifest", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Edit photo'));",
    contract: compactContract(),
    includeRootContracts: false,
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
  assert.equal(result.rootHeaderCount, 0);
});

test("flags a pushed compact route that suppresses its required back action", () => {
  const root = fixtureRoot({
    source:
      "Scaffold(appBar: CatchTopBar(title: 'Host profile', showBackButton: false));",
    contract: compactContract({leading: "back"}),
    includeRootContracts: false,
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "missing-required-back-navigation"));
});

test("accepts an explicit back action on a pushed compact route", () => {
  const root = fixtureRoot({
    source: `Scaffold(appBar: CatchTopBar(
      title: 'Host profile',
      leadingType: CatchTopBarLeading.back,
    ));`,
    contract: compactContract({leading: "back"}),
    includeRootContracts: false,
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
});

test("flags a shell-covering editor pushed on a branch navigator", () => {
  const root = fixtureRoot({
    source: `
      Future<void> openEditor({required BuildContext context}) async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => Screen()));
      }
      Widget build() => Scaffold(appBar: CatchTopBar(title: 'Edit photo'));
    `,
    contract: compactContract(),
    includeRootContracts: false,
    routePresentations: [
      {
        path: "lib/calendar/calendar_screen.dart",
        symbol: "openEditor",
        navigator: "root",
        reason: "The full-screen editor must cover shell navigation chrome.",
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "route-under-shell-chrome"));
});

test("accepts a shell-covering editor pushed on the root navigator", () => {
  const root = fixtureRoot({
    source: `
      Future<void> openEditor({required BuildContext context}) async {
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => Screen()),
        );
      }
      Widget build() => Scaffold(appBar: CatchTopBar(title: 'Edit photo'));
    `,
    contract: compactContract(),
    includeRootContracts: false,
    routePresentations: [
      {
        path: "lib/calendar/calendar_screen.dart",
        symbol: "openEditor",
        navigator: "root",
        reason: "The full-screen editor must cover shell navigation chrome.",
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
});

test("flags an unregistered body-owned manual screen header", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Details'));",
    contract: compactContract(),
    includeRootContracts: false,
    manualSource: `
      class FeatureHeader extends StatelessWidget {
        Widget build(BuildContext context) => Text(
          'Feature',
          style: CatchTextStyles.headline(context),
        );
      }
    `,
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "unregistered-manual-header"));
});

test("accepts an exact content-header classification", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Details'));",
    contract: compactContract(),
    includeRootContracts: false,
    manualSource: `
      class FeatureHeader extends StatelessWidget {
        Widget build(BuildContext context) => Text(
          'Module',
          style: CatchTextStyles.titleL(context),
        );
      }
    `,
    manualHeaders: [
      {
        path: "lib/manual/header.dart",
        symbol: "FeatureHeader",
        role: "content",
        owner: "CatchTextStyles.titleL",
        reason: "This exact header labels content inside the route body.",
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
});

test("flags a manual screen role backed by content title styling", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Details'));",
    contract: compactContract(),
    includeRootContracts: false,
    manualSource: `
      class FeatureHeader extends StatelessWidget {
        Widget build(BuildContext context) => Text(
          'Feature',
          style: CatchTextStyles.titleL(context),
        );
      }
    `,
    manualHeaders: [
      {
        path: "lib/manual/header.dart",
        symbol: "FeatureHeader",
        role: "screen",
        owner: "CatchTextStyles.titleL",
        reason: "This invalid role must not promote content styling.",
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "manual-header-role-owner-drift"));
});

test("does not let a navigation header hide legacy debt as content", () => {
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Details'));",
    contract: compactContract(),
    includeRootContracts: false,
    manualSource: `
      class FeatureHeader extends StatelessWidget {
        Widget build(BuildContext context) => Row(children: [
          CatchIconButton.icon(icon: CatchIcons.arrowBackRounded),
          Text('Feature', style: CatchTextStyles.titleL(context)),
        ]);
      }
    `,
    manualHeaders: [
      {
        path: "lib/manual/header.dart",
        symbol: "FeatureHeader",
        role: "content",
        owner: "CatchTextStyles.titleL",
        reason: "This invalid content role still owns route navigation.",
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "content-header-owns-navigation"));
});

test("discovers canonical root chrome delegated through StatefulWidget State", () => {
  const trackedPath = "lib/root/chats_browse_header.dart";
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Details'));",
    contract: compactContract(),
    includeRootContracts: false,
    trackedRootSources: [
      {
        path: trackedPath,
        source: `
          class ChatsBrowseHeader extends StatefulWidget {
            State<ChatsBrowseHeader> createState() => _ChatsBrowseHeaderState();
          }
          class _ChatsBrowseHeaderState extends State<ChatsBrowseHeader> {
            Widget build(BuildContext context) =>
              CatchScreenTopBar(title: 'Chats');
          }
        `,
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
  assert.equal(result.trackedRootHeaderPathCount, 1);
  assert.equal(result.trackedRootSurfaceCount, 1);
});

test("discovers a canonical root HeaderContent surface", () => {
  const trackedPath = "lib/root/explore_header.dart";
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Details'));",
    contract: compactContract(),
    includeRootContracts: false,
    trackedRootSources: [
      {
        path: trackedPath,
        source: `
          class ExploreBrowseHeaderContent extends StatelessWidget {
            Widget build(BuildContext context) =>
              CatchScreenHeaderTitle.block(title: 'Explore');
          }
        `,
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.deepEqual(result.findings, []);
  assert.equal(result.trackedRootSurfaceCount, 1);
});

test("flags a tracked root Screen that drops its canonical owner", () => {
  const trackedPath = "lib/root/dashboard_home_screen.dart";
  const root = fixtureRoot({
    source: "Scaffold(appBar: CatchTopBar(title: 'Details'));",
    contract: compactContract(),
    includeRootContracts: false,
    trackedRootSources: [
      {
        path: trackedPath,
        source: `
          class DashboardHomeScreen extends StatelessWidget {
            Widget build(BuildContext context) =>
              CatchTopBar(title: 'Home');
          }
        `,
      },
    ],
  });

  const result = checkScreenTopBarContracts({root});

  assert.ok(hasFinding(result, "tracked-root-header-missing-owner"));
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

function compactContract({expression = "CatchTopBar", leading} = {}) {
  return {
    path: "lib/calendar/calendar_screen.dart",
    role: "compact",
    expression,
    owner: "CatchTopBar",
    ...(leading == null ? {} : {leading}),
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
  includeRootContracts = true,
  routePresentations = [],
  manualSource,
  manualHeaders = [],
  trackedRootSources = [],
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
  if (includeRootContracts) {
    write(root, configuredRootSurface.path, rootSource);
    write(root, "lib/core/theme/catch_tokens.dart", tokenSource);
  }
  if (extraSource != null) {
    write(root, "lib/new/new_screen.dart", extraSource);
  }
  if (rawSource != null) {
    write(root, "lib/hero/hero_header.dart", rawSource);
  }
  if (manualSource != null) {
    write(root, "lib/manual/header.dart", manualSource);
  }
  for (const trackedRootSource of trackedRootSources) {
    write(root, trackedRootSource.path, trackedRootSource.source);
  }
  if (trackedRootSources.length > 0) {
    write(
      root,
      "docs/audit_registry/architecture_pattern_adoption.json",
      JSON.stringify({
        patterns: [
          {
            id: "ARCH-SCREEN-CHROME-001",
            adopters: trackedRootSources.map((trackedRootSource) => ({
              path: trackedRootSource.path,
              status: "aligned",
            })),
          },
        ],
      }),
    );
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
  if (includeRootContracts) {
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
  }
  const manifest = {
    schemaVersion: 2,
    logicalName: "fixture",
    contracts: [contract],
    rawChromeExceptions,
    routePresentations,
    manualHeaders,
  };
  if (includeRootContracts) {
    manifest.tabRootManifestPath =
      "tool/design/tab_root_scroll_contracts.json";
    manifest.screenGeometry = {
      tokenPath: "lib/core/theme/catch_tokens.dart",
      token: "screenTitleBlock",
      topInset: "CatchSpacing.s0",
    };
    manifest.rootHeaders = configuredRootHeaders;
  }
  write(
    root,
    "tool/design/screen_top_bar_contracts.json",
    JSON.stringify(manifest),
  );
  return root;
}

function write(root, relativePath, contents) {
  const absolutePath = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(absolutePath), {recursive: true});
  fs.writeFileSync(absolutePath, contents);
}
