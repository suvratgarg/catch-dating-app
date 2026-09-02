import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {checkRootScreenCompositionContracts} from "./check_root_screen_composition_contracts.mjs";

test("accepts a registered adaptive shell branch", () => {
  const root = fixtureRoot({
    ownerSource:
      "SafeArea(bottom: false, child: CustomScrollView(slivers: [CatchSliverTerminalPadding()]));",
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

test("accepts lifecycle-owned StatefulShellBranch key member access", () => {
  const root = fixtureRoot({
    ownerSource:
      "SafeArea(bottom: false, child: CustomScrollView(slivers: [CatchSliverTerminalPadding()]));",
    routerBranchKey: "keys.home",
  });
  const result = checkRootScreenCompositionContracts({root});
  assert.deepEqual(result.findings, []);
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
      schemaVersion: 3,
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
