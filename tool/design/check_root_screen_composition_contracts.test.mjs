import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {checkRootScreenCompositionContracts} from "./check_root_screen_composition_contracts.mjs";

test("accepts a registered shell branch with a semantic terminal owner", () => {
  const root = fixtureRoot({
    ownerSource:
      "SafeArea(bottom: false, child: CustomScrollView(slivers: [CatchSliverTerminalPadding()]));",
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.deepEqual(result.findings, []);
});

test("accepts a primary-rail root that delegates scroll ownership to the shared shell", () => {
  const root = fixtureRoot({
    ownerSource: `
      class ExamplePage extends Widget implements CatchRootScreenPageOwner {
        CatchScreenBodyLayout get bodyLayout => CatchScreenBodyLayout.standard;
        Widget build(BuildContext context) => CatchRootScreenPageScrollView(
          bodyLayout: bodyLayout,
        );
      }
      CatchRootScreenScaffold.withPrimaryRail(
        body: CatchRootScreenBody.single(
          page: CatchRootScreenPageSpec.scroll(
            bodyLayout: CatchScreenBodyLayout.standard,
            page: ExamplePage(),
          ),
        ),
      );
    `,
    requires: [
      {text: "CatchRootScreenScaffold.withPrimaryRail", minimumOccurrences: 1},
      {text: "CatchRootScreenPageScrollView", minimumOccurrences: 1},
      {text: "implements CatchRootScreenPageOwner", minimumOccurrences: 1},
      {text: "CatchRootScreenBody.single", minimumOccurrences: 1},
      {text: "CatchRootScreenPageSpec.scroll", minimumOccurrences: 1},
    ],
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.deepEqual(result.findings, []);
});

test("rejects the superseded parallel tabbed-root API", () => {
  const root = fixtureRoot({
    ownerSource: `
      SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CatchSliverTerminalPadding(),
            SliverToBoxAdapter(child: CatchTabbedScreenScaffold()),
          ],
        ),
      );
    `,
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.ok(
    result.findings.some(
      (finding) => finding.code === "legacy-root-layout-symbol",
    ),
  );
});

test("accepts a root screen with an explicit semantic body role", () => {
  const root = fixtureRoot({
    ownerSource: `
      CatchRootScreenScaffold(
        bodyLayout: CatchScreenBodyLayout.standard,
        slivers: const [SliverToBoxAdapter(child: Text("Body"))],
      );
    `,
    requires: [
      {text: "CatchRootScreenScaffold", minimumOccurrences: 1},
      {
        text: "bodyLayout: CatchScreenBodyLayout.standard",
        minimumOccurrences: 1,
      },
    ],
    forbids: [{text: "CustomScrollView("}],
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.deepEqual(result.findings, []);
});

test("flags a root screen that bypasses semantic composition", () => {
  const root = fixtureRoot({
    ownerSource: "SafeArea(child: CustomScrollView());",
    requires: [
      {text: "CatchRootScreenScaffold", minimumOccurrences: 1},
      {
        text: "bodyLayout: CatchScreenBodyLayout.standard",
        minimumOccurrences: 1,
      },
    ],
    forbids: [{text: "CustomScrollView("}],
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.ok(
    result.findings.some(
      (finding) => finding.code === "missing-required-text",
    ),
  );
  assert.ok(
    result.findings.some((finding) => finding.code === "forbidden-text"),
  );
});

test("flags a state branch that escapes an otherwise valid root owner", () => {
  const root = fixtureRoot({
    ownerSource: `
      return switch (state) {
        ScreenState.loaded => CatchRootScreenScaffold(
          bodyLayout: CatchScreenBodyLayout.standard,
        ),
        ScreenState.error => CatchErrorScaffold(),
      };
    `,
    requires: [
      {text: "CatchRootScreenScaffold", minimumOccurrences: 1},
      {
        text: "bodyLayout: CatchScreenBodyLayout.standard",
        minimumOccurrences: 1,
      },
    ],
    forbids: [{text: "CatchErrorScaffold"}],
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.ok(
    result.findings.some(
      (finding) =>
        finding.code === "forbidden-text" &&
        finding.message.includes("CatchErrorScaffold"),
    ),
  );
});

test("accepts lifecycle-owned StatefulShellBranch key member access", () => {
  const root = fixtureRoot({
    ownerSource:
      "SafeArea(bottom: false, child: CustomScrollView(slivers: [CatchSliverTerminalPadding()]));",
    routerBranchKey: "keys.home",
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.deepEqual(result.findings, []);
});

test("flags the known-bad root screen fixture when terminal padding is missing", () => {
  const root = fixtureRoot({
    ownerSource: "SafeArea(bottom: false, child: CustomScrollView());",
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.ok(
    result.findings.some(
      (finding) => finding.code === "missing-required-text",
    ),
  );
});

test("flags a shell that bypasses the shared adaptive scaffold", () => {
  const root = fixtureRoot({
    ownerSource:
      "SafeArea(bottom: false, child: CustomScrollView(slivers: [CatchSliverTerminalPadding()]));",
    shellSource: "return Scaffold(body: navigationShell);",
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.ok(
    result.findings.some(
      (finding) =>
        finding.code === "missing-required-text" &&
        finding.path === "lib/core/presentation/app_shell.dart" &&
        finding.message.includes("CatchAdaptiveTabScaffold"),
    ),
  );
});

test("flags a new StatefulShellBranch until it is registered", () => {
  const root = fixtureRoot({
    ownerSource:
      "SafeArea(bottom: false, child: CustomScrollView(slivers: [CatchSliverTerminalPadding()]));",
    extraRouterSource: `
      StatefulShellBranch(
        navigatorKey: _newShellKey,
        routes: [],
      ),
    `,
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.ok(
    result.findings.some(
      (finding) =>
        finding.code === "unregistered-branch" &&
        finding.message.includes("_newShellKey"),
    ),
  );
});

test("flags a raw SliverFillRemaining empty state in presentation code", () => {
  const root = fixtureRoot({
    ownerSource:
      "SafeArea(bottom: false, child: CustomScrollView(slivers: [CatchSliverTerminalPadding()]));",
    stateSource: `
      SliverFillRemaining(
        child: CatchEmptyState(title: "Nothing here"),
      );
    `,
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.ok(
    result.findings.some(
      (finding) =>
        finding.code === "raw-sliver-state-viewport" &&
        finding.path === "lib/example/presentation/example_screen.dart",
    ),
  );
});

function fixtureRoot({
  ownerSource,
  shellSource = "return CatchAdaptiveTabScaffold(body: navigationShell);",
  extraRouterSource = "",
  stateSource,
  routerBranchKey = "_homeShellKey",
  requires = [
    {text: "bottom: false", minimumOccurrences: 1},
    {text: "CatchSliverTerminalPadding", minimumOccurrences: 1},
  ],
  forbids = [],
}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-tab-root-"));
  write(
    root,
    "lib/routing/go_router.dart",
    `
      StatefulShellBranch(
        navigatorKey: ${routerBranchKey},
        routes: [GoRoute(name: Routes.home.name)],
      ),
      ${extraRouterSource}
    `,
  );
  write(root, "lib/core/presentation/app_shell.dart", shellSource);
  write(root, "lib/home/home_screen.dart", ownerSource);
  if (stateSource != null) {
    write(root, "lib/example/presentation/example_screen.dart", stateSource);
  }
  write(
    root,
    "tool/design/root_screen_composition_contracts.json",
    JSON.stringify({
      schemaVersion: 2,
      logicalName: "fixture",
      routerPath: "lib/routing/go_router.dart",
      shells: [
        {
          path: "lib/core/presentation/app_shell.dart",
          requires: [{text: "CatchAdaptiveTabScaffold", minimumOccurrences: 1}],
        },
      ],
      branches: [
        {
          branchKey: routerBranchKey,
          routeName: "Routes.home.name",
          owners: [
            {
              path: "lib/home/home_screen.dart",
              requires,
              forbids,
            },
          ],
        },
      ],
    }),
  );
  return root;
}

function write(root, relativePath, contents) {
  const absolutePath = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(absolutePath), {recursive: true});
  fs.writeFileSync(absolutePath, contents);
}
