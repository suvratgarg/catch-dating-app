import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {checkTabRootScrollContracts} from "./check_tab_root_scroll_contracts.mjs";

test("accepts a registered shell branch with a semantic terminal owner", () => {
  const root = fixtureRoot({
    ownerSource:
      "SafeArea(bottom: false, child: CustomScrollView(slivers: [CatchSliverTerminalPadding()]));",
  });
  const result = checkTabRootScrollContracts({root});
  assert.deepEqual(result.findings, []);
});

test("accepts a tab root that delegates scroll ownership to the shared shell", () => {
  const root = fixtureRoot({
    ownerSource:
      "CatchTabbedScreenScaffold(body: CatchTabbedPageScrollView());",
    requires: [
      {text: "CatchTabbedScreenScaffold", minimumOccurrences: 1},
      {text: "CatchTabbedPageScrollView", minimumOccurrences: 1},
    ],
  });
  const result = checkTabRootScrollContracts({root});
  assert.deepEqual(result.findings, []);
});

test("flags the known-bad tab root fixture when terminal padding is missing", () => {
  const root = fixtureRoot({
    ownerSource: "SafeArea(bottom: false, child: CustomScrollView());",
  });
  const result = checkTabRootScrollContracts({root});
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
  const result = checkTabRootScrollContracts({root});
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
  const result = checkTabRootScrollContracts({root});
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
  const result = checkTabRootScrollContracts({root});
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
  requires = [
    {text: "bottom: false", minimumOccurrences: 1},
    {text: "CatchSliverTerminalPadding", minimumOccurrences: 1},
  ],
}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-tab-root-"));
  write(
    root,
    "lib/routing/go_router.dart",
    `
      StatefulShellBranch(
        navigatorKey: _homeShellKey,
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
    "tool/design/tab_root_scroll_contracts.json",
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
          branchKey: "_homeShellKey",
          routeName: "Routes.home.name",
          owners: [
            {
              path: "lib/home/home_screen.dart",
              requires,
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
