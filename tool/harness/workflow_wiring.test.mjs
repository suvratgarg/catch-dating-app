import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";
import {planAffectedToolChecks, toolsOwnUiLintSmoke, uniqueToolChecks} from "../lib/tool_impact.mjs";
import {planAffected} from "./lib/component_graph.mjs";
import {createRepositorySnapshot} from "../lib/repository_snapshot.mjs";

const repositorySnapshot = createRepositorySnapshot();
const graph = repositorySnapshot.readJson(
  "tool/harness/component_graph.json",
  {required: true},
);
const toolsManifest = repositorySnapshot.readJson(
  "tool/tools_manifest.json",
  {required: true},
);
const workflow = (name) => repositorySnapshot.readText(
  `.github/workflows/${name}`,
  {required: true},
);
const retiredPlanner = ["plan", "ci.mjs"].join("_");
const retiredUiWrapperNames = [
  "check_sizing.sh",
  "check_ui_allow_debt.sh",
  "check_ui_local_constant_wrappers.sh",
  "check_ui_system_raw_values.sh",
];
const retiredDerivedAuditPaths = [
  "docs/audit_registry/definition_catalog.json",
  "docs/audit_registry/consolidation_candidates.json",
  "docs/audit_registry/l10n_key_usage.json",
  "tool/audit/definition_catalog.py",
  "docs/audit_registry/widget_antipattern_scan.json",
  "tool/scan_widget_antipatterns.py",
  "tool/migrate_widget_functions.py",
];
const retiredProviderGraphPaths = [
  "docs/generated/provider_graph/README.md",
  "docs/generated/provider_graph/provider_graph.html",
  "docs/generated/provider_graph/provider_graph.json",
  "docs/generated/provider_graph/provider_graph.mmd",
];
const retiredReactDependencyGraphPaths = [
  "docs/generated/react_dependency_graph/README.md",
  "docs/generated/react_dependency_graph/react_dependency_graph.json",
  "docs/generated/react_dependency_graph/react_dependency_graph.mmd",
];
const livePolicyAuthorityPaths = [
  "AGENTS.md",
  "docs/README.md",
  "docs/agent_operating_model.md",
  "docs/app_architecture.md",
  "tool/README.md",
  "tool/policy/rules.json",
  "tool/tools_manifest.json",
];
const liveReactDependencyGraphAuthorityPaths = [
  ...livePolicyAuthorityPaths,
  "docs/web_surface_architecture.md",
  ".github/workflows/admin-website.yml",
  ".github/workflows/marketing-website.yml",
  ".github/workflows/react-surface-validation.yml",
];
const toolPreflightCheckoutClosure = [
  "/tool/",
  "/.github/actions/load-toolchain/action.yml",
  "/functions/package.json",
  "/pubspec.yaml",
  "/.github/workflows/app-build-matrix.yml",
  "/.github/workflows/mobile-internal-promote.yml",
  "/.github/workflows/mobile-internal-release.yml",
  "/.github/workflows/visual-integration-ci.yml",
];
const affectedIndexCheckoutClosure = [
  "/tool/",
  "/.github/actions/load-toolchain/action.yml",
];
const fastGateCheckoutClosure = [
  "/.github/actions/load-toolchain/action.yml",
  "/tool/ci/toolchain.env",
  "/tool/lib/repo_paths.mjs",
  "/tool/test/check_flutter_test_size.mjs",
  "/tool/test/flutter_test_size_baseline.json",
  "/test/",
  "/integration_test/",
];

function namedStep(source, name) {
  const marker = `      - name: ${name}`;
  const start = source.indexOf(marker);
  assert.notEqual(start, -1, `missing workflow step ${name}`);
  const end = source.indexOf("\n      - ", start + marker.length);
  return source.slice(start, end === -1 ? source.length : end);
}

function literalSparsePaths(step) {
  const match = /sparse-checkout: \|\n((?: {12}\S.*(?:\n|$))+)/u.exec(step);
  assert.ok(match, "missing literal sparse-checkout block");
  return match[1]
    .trimEnd()
    .split("\n")
    .map((line) => line.trim());
}

function localModuleImports(source) {
  return [...source.matchAll(/(?:\bfrom\s+|\bimport\s*\(\s*)["'](\.[^"']+)["']/gu)]
    .map((match) => match[1]);
}

test("Flutter UI lint wiring uses one analyzer census and no legacy wrappers", () => {
  const flutter = workflow("flutter-ci.yml");
  assert.equal(
    [...flutter.matchAll(/dart analyze --format machine/gu)].length,
    0,
  );
  assert.match(flutter, /check_flutter_workspace_analysis\.mjs --root-diagnostics-dir/u);
  assert.match(flutter, /CATCH_UI_ANALYZE_OUTPUT_PATH=\/tmp\/catch-ui-root-analysis\/analyze.machine/u);
  assert.match(flutter, /check_catch_ui_lint_drift\.sh --check/u);
  assert.match(namedStep(flutter, "Catch UI lint plugin smoke check"),
    /if: \$\{\{ needs.test-plan.outputs.ui_lint_smoke == 'true' && !inputs.ui_lint_smoke_in_tools \}\}/u);
  for (const retired of retiredUiWrapperNames) {
    assert.doesNotMatch(flutter, new RegExp(retired.replace(".", "\\."), "u"));
  }
});

test("Flutter selection keeps full validation and bounds matrix outputs", () => {
  const ci = workflow("ci.yml");
  const flutter = workflow("flutter-ci.yml");
  assert.match(ci, /uses: \.\/\.github\/workflows\/flutter-ci.yml[\s\S]*?full: \$\{\{ needs.plan.outputs.full == 'true' \}\}/u);
  assert.match(flutter, /matrix: \$\{\{ fromJSON\(needs.test-plan.outputs.matrix\) \}\}/u);
  assert.match(namedStep(flutter, "Verify test selection safety"), /dart test tool\/harness\/lib\/flutter_test_selection_test.dart/u);
  assert.match(namedStep(flutter, "Select tests from committed dependency closures"), /--base "\$BASE_SHA" --head "\$SOURCE_SHA" --full "\$FULL"/u);
  assert.match(flutter, /TEST_PLAN_RESULT: \$\{\{ needs\['test-plan'\].result \}\}/u);
  assert.match(flutter, /"\$\{TEST_PLAN_RESULT\}" != "success"/u);
  assert.match(namedStep(flutter, "Unit & widget tests"), /\.sourceSha == \$sha/u);
});

test("Flutter analysis covers every pubspec and empty test selections fail closed", () => {
  const flutter = workflow("flutter-ci.yml");
  const aggregate = namedStep(flutter, "Analyze every Dart and Flutter package");
  assert.match(
    aggregate,
    /node tool\/ci\/check_flutter_workspace_analysis\.mjs/u,
  );
  assert.doesNotMatch(flutter, /flutter analyze/u);

  const shard = namedStep(flutter, "Unit & widget tests");
  assert.match(shard, /if \[\[ "\$\{count\}" == "0" \]\]; then/u);
  assert.match(shard, /No test files were selected for shard/u);
  assert.doesNotMatch(
    shard,
    /if \[\[ "\$\{count\}" == "0" \]\]; then\s+exit 0/u,
  );

  assert.match(shard, /flutter test[^\n]*--coverage/u);
  const coverage = namedStep(flutter, "Merge coverage without rerunning tests");
  assert.match(coverage, /--merge-shards coverage\/shards/u);
  assert.match(coverage, /--expected-shards "\$SHARD_TOTAL"/u);
  const coverageJob = flutter.slice(
    flutter.indexOf("  flutter-coverage:"), flutter.indexOf("  app-package-tests:"),
  );
  assert.match(coverageJob, /needs: \[test-plan, flutter-test-shards\]/u);
  assert.doesNotMatch(coverageJob, /flutter test|setup-flutter/u);
  assert.match(flutter, /name: flutter-coverage-shard-\$\{\{ github.run_id \}\}-\$\{\{ github.sha \}\}-\$\{\{ matrix.shard_index \}\}/u);
  assert.match(coverageJob, /pattern: flutter-coverage-shard-\$\{\{ github.run_id \}\}-\$\{\{ github.sha \}\}-\*/u);
});

test("Flutter CI runs Consumer and Host package tests as aggregate gates", () => {
  const flutter = workflow("flutter-ci.yml");
  assert.match(flutter, /^  app-package-tests:\n/mu);
  assert.match(
    flutter,
    /working-directory: apps\/consumer\n        run: flutter test --concurrency=1/u,
  );
  assert.match(
    flutter,
    /working-directory: apps\/host\n        run: flutter test --concurrency=1/u,
  );
  assert.match(flutter, /needs:\n(?:      - .*\n)*      - app-package-tests/u);
  assert.match(
    flutter,
    /APP_PACKAGES_RESULT: \$\{\{ needs\['app-package-tests'\]\.result \}\}/u,
  );
});

test("Flutter new-widget gate consumes the planner's exact reachable base", () => {
  const ci = workflow("ci.yml");
  const flutter = workflow("flutter-ci.yml");
  assert.match(
    flutter,
    /workflow_call:\s*\n\s+inputs:\s*\n\s+base_sha:\s*\n\s+required: true\s*\n\s+type: string/u,
  );
  assert.match(
    ci,
    /flutter:\s*\n[\s\S]*?uses: \.\/\.github\/workflows\/flutter-ci\.yml\s*\n\s+with:\s*\n\s+base_sha: \$\{\{ needs\.plan\.outputs\.base_sha \}\}/u,
  );

  const gate = namedStep(flutter, "New widget inventory gate");
  assert.match(gate, /BASE_SHA: \$\{\{ inputs\.base_sha \}\}/u);
  assert.match(gate, /git cat-file -e "\$\{BASE_SHA\}\^\{commit\}"/u);
  assert.match(
    gate,
    /git merge-base --is-ancestor "\$BASE_SHA" "\$GITHUB_SHA"/u,
  );
  assert.match(
    gate,
    /check_new_widget_inventory\.mjs[\s\S]*--base "\$BASE_SHA"[\s\S]*--check[\s\S]*--no-write/u,
  );

  const checkout = flutter.slice(0, flutter.indexOf("      - id: toolchain"));
  assert.match(checkout, /actions\/checkout@v6\s*\n\s+with:\s*\n\s+fetch-depth: 0/u);
});

test("resolved composition gate owns its authorities and both split suites", () => {
  const flutter = workflow("flutter-ci.yml");
  const gate = namedStep(flutter, "Catch UI resolved composition contracts");
  assert.match(
    gate,
    /dart run tool\/architecture\/check_ui_composition_contracts\.dart --check/u,
  );

  const tool = toolsManifest.tools.find(
    ({id}) => id === "architecture:ui-composition-contracts",
  );
  assert.ok(tool, "missing architecture:ui-composition-contracts manifest entry");
  for (const authority of [
    "test/tool/ui_composition_contracts_test.dart",
    "test/tool/ui_composition_ownership_test.dart",
    "design/screens/catch.screens.json",
    "design/screens/catch.screens.schema.json",
    "design/screens/screen_coverage.json",
    "tool/ui_capture/check_route_inventory.mjs",
    "tool/ui_capture/route_inventory.json",
    "tool/design/screen_top_bar_contracts.json",
    "lib/routing/go_router.dart",
    "lib/**",
    "apps/host/lib/**",
    "apps/consumer/lib/**",
  ]) {
    assert.ok(
      tool.impactPaths.includes(authority),
      `composition gate does not own ${authority}`,
    );
  }

  const suites = [
    "test/tool/ui_composition_contracts_test.dart",
    "test/tool/ui_composition_ownership_test.dart",
  ];
  const formatCheck = tool.checks.find((check) =>
    check.startsWith("dart format"),
  );
  assert.ok(formatCheck, "composition gate is missing its format check");
  for (const suite of suites) {
    assert.ok(formatCheck.includes(suite), `format check omits ${suite}`);
    assert.ok(
      tool.checks.includes(`dart test ${suite}`),
      `test check omits ${suite}`,
    );
  }
  assert.equal(
    tool.vacuityProof.path,
    "test/tool/ui_composition_ownership_test.dart",
  );
});

test("Flutter l10n ratchet derives JSON live and uploads ephemeral evidence", () => {
  const flutter = workflow("flutter-ci.yml");
  const scan = namedStep(
    flutter,
    "Localization catalog and getter usage ratchet",
  );
  assert.equal(
    [...flutter.matchAll(/check_l10n_key_usage\.mjs/gu)].length,
    1,
  );
  assert.match(scan, /mkdir -p build\/ci/u);
  assert.match(
    scan,
    /node tool\/copy\/check_l10n_key_usage\.mjs --check --json > build\/ci\/l10n-key-usage\.json/u,
  );
  assert.match(
    scan,
    /jq '\{summary: \.inventory\.summary, ratchet: \.ratchet\}' build\/ci\/l10n-key-usage\.json/u,
  );
  assert.doesNotMatch(
    flutter,
    /--check-inventory|--write-inventory|docs\/audit_registry\/l10n_key_usage\.json/u,
  );

  const upload = namedStep(
    flutter,
    "Upload localization key-usage evidence",
  );
  assert.match(upload, /if: always\(\)/u);
  assert.match(upload, /uses: actions\/upload-artifact@v7/u);
  assert.match(
    upload,
    /name: l10n-key-usage-\$\{\{ github\.sha \}\}/u,
  );
  assert.match(upload, /path: build\/ci\/l10n-key-usage\.json/u);
  assert.match(upload, /if-no-files-found: error/u);
  assert.match(upload, /retention-days: 14/u);
});

test("retired UI wrapper names have no live guidance consumers", () => {
  const guidancePaths = repositorySnapshot.listFiles().filter((relativePath) =>
    relativePath === "AGENTS.md" ||
    relativePath === "tool/README.md" ||
    relativePath === "design_context_pack/design_system/design_language.txt" ||
    (relativePath.startsWith("docs/") && relativePath.endsWith(".md"))
  );
  const sources = repositorySnapshot.readTexts(guidancePaths, {required: true});
  const offenders = [];
  for (const relativePath of guidancePaths) {
    const source = sources.get(relativePath);
    for (const retired of retiredUiWrapperNames) {
      if (source.includes(retired)) offenders.push(`${relativePath}: ${retired}`);
    }
  }
  assert.deepEqual(offenders, []);
});

test("retired derived audit artifacts stay out of live authorities", () => {
  for (const relativePath of retiredDerivedAuditPaths) {
    assert.equal(repositorySnapshot.exists(relativePath), false, relativePath);
  }
  const sources = repositorySnapshot.readTexts(livePolicyAuthorityPaths, {
    required: true,
  });
  const offenders = [];
  for (const relativePath of livePolicyAuthorityPaths) {
    const source = sources.get(relativePath);
    for (const retiredPath of retiredDerivedAuditPaths) {
      const retiredName = retiredPath.split("/").at(-1);
      if (source.includes(retiredName)) {
        offenders.push(`${relativePath}: ${retiredName}`);
      }
    }
  }
  assert.deepEqual(offenders, []);
});

test("retired provider graph snapshots stay absent from live authorities", () => {
  for (const relativePath of retiredProviderGraphPaths) {
    assert.equal(repositorySnapshot.exists(relativePath), false, relativePath);
  }
  const sources = repositorySnapshot.readTexts(livePolicyAuthorityPaths, {
    required: true,
  });
  const offenders = [];
  for (const relativePath of livePolicyAuthorityPaths) {
    const source = sources.get(relativePath);
    if (source.includes("docs/generated/provider_graph")) {
      offenders.push(relativePath);
    }
  }
  assert.deepEqual(offenders, []);
});

test("retired React graph snapshots stay absent while the live CI gate remains", () => {
  for (const relativePath of retiredReactDependencyGraphPaths) {
    assert.equal(repositorySnapshot.exists(relativePath), false, relativePath);
  }
  const sources = repositorySnapshot.readTexts(
    liveReactDependencyGraphAuthorityPaths,
    {required: true},
  );
  const offenders = [];
  for (const relativePath of liveReactDependencyGraphAuthorityPaths) {
    const source = sources.get(relativePath);
    if (source.includes("docs/generated/react_dependency_graph")) {
      offenders.push(relativePath);
    }
  }
  assert.deepEqual(offenders, []);
  assert.match(
    workflow("react-surface-validation.yml"),
    /node tool\/web\/react_dependency_graph\.mjs --check/u,
  );
});

test("required CI consumes every bounded Harness v2 target", () => {
  const ci = workflow("ci.yml");
  assert.match(ci, /name: Required CI/);
  assert.match(ci, /node tool\/harness\.mjs plan/);
  assert.doesNotMatch(ci, new RegExp(`${retiredPlanner}|harness\\.mjs shadow`));
  for (const target of graph.targets) {
    assert.match(ci, new RegExp(`steps\\.plan\\.outputs\\.${target}`));
  }
  assert.match(ci, /docs-policy:/);
  assert.match(ci, /- docs-policy/);
  assert.match(ci, /docs_checkout: \$\{\{ steps\.plan\.outputs\.docs_checkout \}\}/);
  assert.match(ci, /base_sha: \$\{\{ needs\.plan\.outputs\.base_sha \}\}/);
  assert.match(ci, /mode: \$\{\{ needs\.plan\.outputs\.mode \}\}/);
  assert.match(ci, /full: \$\{\{ needs\.plan\.outputs\.full == 'true' \}\}/);
});

test("planner and ordinary docs consume the graph-owned checkout closure", () => {
  const ci = workflow("ci.yml");
  const planner = namedStep(ci, "Checkout planner closure");
  assert.deepEqual(literalSparsePaths(planner), graph.ciCheckout.planner.paths);
  assert.match(
    planner,
    new RegExp(`timeout-minutes: ${graph.ciCheckout.planner.timeoutMinutes}`),
  );
  assert.match(
    planner,
    new RegExp(`fetch-depth: ${graph.ciCheckout.planner.fetchDepth}`),
  );
  assert.match(
    planner,
    new RegExp(`sparse-checkout-cone-mode: ${graph.ciCheckout.planner.coneMode}`),
  );

  const decode = namedStep(ci, "Decode graph-projected docs checkout");
  assert.match(decode, /DOCS_CHECKOUT: \$\{\{ needs\.plan\.outputs\.docs_checkout \}\}/);
  assert.match(decode, /fromJSON\(needs\.plan\.outputs\.docs_checkout\)\.mode == 'sparse'/);

  const ordinaryDocs = namedStep(ci, "Checkout ordinary-doc closure");
  assert.match(ordinaryDocs, /steps\.docs-checkout\.outcome == 'success'/);
  assert.match(ordinaryDocs, /steps\.docs-checkout\.outputs\.paths/);
  assert.match(ordinaryDocs, /steps\.docs-checkout\.outputs\.fetch_depth/);
  assert.match(ordinaryDocs, /steps\.docs-checkout\.outputs\.cone_mode/);
  assert.match(ordinaryDocs, /fromJSON\(steps\.docs-checkout\.outputs\.timeout_minutes\)/);

  const fullPolicy = namedStep(ci, "Checkout full policy closure");
  assert.match(fullPolicy, /needs\.plan\.outputs\.policy_docs == 'true'/);
  assert.match(fullPolicy, /fromJSON\(needs\.plan\.outputs\.docs_checkout\)\.mode == 'full'/);
  assert.match(fullPolicy, /timeout-minutes: 10/u);
  assert.doesNotMatch(fullPolicy, /sparse-checkout/);
  assert.match(
    fullPolicy,
    new RegExp(`fetch-depth: ${graph.ciCheckout.default.fetchDepth}`),
  );
});

test("policy-only CI wiring has one Harness owner with its required dependencies", () => {
  const ci = workflow("ci.yml");
  const policy = ci.slice(ci.indexOf("  docs-policy:"), ci.indexOf("  app-builds:"));
  const condition = "if: ${{ needs.plan.outputs.policy_docs == 'true' && needs.plan.outputs.tools != 'true' }}";
  const names = ["Load Harness toolchain", "Set up Harness Node.js",
    "Install Harness test dependencies", "Validate CI wiring in the policy lane"];
  const steps = names.map((name) => namedStep(policy, name));
  for (const step of steps) assert.ok(step.includes(condition), step);
  assert.match(steps[0], /id: policy-toolchain/u);
  assert.match(steps[0], /uses: \.\/\.github\/actions\/load-toolchain/u);
  assert.match(steps[1], /uses: actions\/setup-node@v6/u);
  assert.ok(steps[1].includes("node-version: ${{ steps.policy-toolchain.outputs.node-version }}"));
  assert.match(steps[2], /run: npm ci --ignore-scripts --workspaces=false/u);
  assert.match(steps[3], /run: node tool\/run\.mjs check agent:harness-v2/u);
  const order = ["Checkout full policy closure", ...names].map((name) => policy.indexOf(namedStep(policy, name)));
  assert.deepEqual(order, [...order].sort((a, b) => a - b));

  for (const file of ["firestore-rules-ci.yml", "contracts-ci.yml", "functions-ci.yml",
    "operations-ci.yml", "flutter-ci.yml", "visual-integration-ci.yml"]) {
    const changedPaths = [`.github/workflows/${file}`];
    const standalone = planAffected({changedPaths, graph, mode: "pr"});
    assert.ok(standalone.operations.ciTargets.includes("policy_docs"), file);
    assert.equal(standalone.operations.ciTargets.includes("tools"), false, file);
    assert.ok(standalone.operations.checkIds.includes("agent:harness-v2"), file);
    changedPaths.push("tool/design/check_platform_token_coverage.mjs");
    const mixed = planAffected({changedPaths, graph, mode: "pr"});
    assert.ok(mixed.operations.ciTargets.includes("tools"), file);
    assert.equal(planAffectedToolChecks({changedPaths, manifest: toolsManifest,
      componentGraph: graph, mode: "pr"}).mode, "full", file);
  }
  const docs = planAffected({changedPaths: ["docs/example.md"], graph, mode: "pr"});
  assert.deepEqual(docs.operations.ciTargets, ["docs"]);
});

test("planner reports Audience documentation impact before target fanout", () => {
  const ci = workflow("ci.yml");
  const report = namedStep(ci, "Report Audience documentation impact");
  assert.match(report, /BASE_SHA: \$\{\{ steps\.plan\.outputs\.base_sha \}\}/u);
  assert.match(report, /node tool\/design\/build_host_feature_responsibilities\.mjs\s*\\\n\s*--affected audience --base "\$BASE_SHA" --json/u);
  assert.match(report, /> build\/ci\/audience-doc-impact\.json/u);
  assert.match(report, /\$GITHUB_STEP_SUMMARY/u);
  // Source-only changes must receive advice even when the docs target is off.
  assert.doesNotMatch(report, /^\s+if:/mu);
  assert.ok(ci.indexOf(report) < ci.indexOf("\n  tools:"));
  const evidence = namedStep(ci, "Upload planner evidence");
  // Backend and mobile consumers require a one-file delivery plan archive.
  assert.match(evidence, /^\s+path: build\/ci\/impact-plan\.json$/mu);
  assert.doesNotMatch(evidence, /audience-doc-impact/u);
  assert.match(evidence, /retention-days: [1-9][0-9]*/u);
  const advice = namedStep(ci, "Upload Audience documentation advice");
  assert.match(advice, /name: audience-doc-impact-/u);
  assert.match(advice, /^\s+path: build\/ci\/audience-doc-impact\.json$/mu);
  assert.match(advice, /retention-days: 7/u);
  assert.doesNotMatch(advice, /harness-plan-/u);
});

test("planner sparse checkout contains its recursive local module closure", () => {
  const declared = new Set(
    graph.ciCheckout.planner.paths.map((entry) => entry.replace(/^\//u, "")),
  );
  const pending = [
    "tool/harness.mjs",
    "tool/design/build_host_feature_responsibilities.mjs",
  ];
  const visited = new Set();
  while (pending.length > 0) {
    const modulePath = pending.pop();
    if (visited.has(modulePath)) continue;
    visited.add(modulePath);
    const source = repositorySnapshot.readText(modulePath, {required: true});
    for (const specifier of localModuleImports(source)) {
      let importedPath = path.posix.normalize(
        path.posix.join(path.posix.dirname(modulePath), specifier),
      );
      if (path.posix.extname(importedPath) === "") importedPath += ".mjs";
      assert.ok(
        declared.has(importedPath),
        `${modulePath} imports ${importedPath}, which is absent from ciCheckout.planner.paths`,
      );
      if (importedPath.endsWith(".mjs")) pending.push(importedPath);
    }
  }
});

test("tools fanout selects exactly one affected or full execution path", () => {
  const tools = workflow("tools-ci.yml");
  assert.match(tools, /base_sha:\s*\n\s+required: true\s*\n\s+type: string/);
  assert.match(tools, /mode:\s*\n\s+required: true\s*\n\s+type: string/);
  assert.match(tools, /full:\s*\n\s+required: true\s*\n\s+type: boolean/);
  assert.match(tools, /node tool\/run\.mjs affected-tools/);
  assert.match(tools, /--mode "\$MODE"/);
  assert.match(
    tools,
    /needs\.preflight\.outputs\.tool_mode == 'affected'/,
  );
  assert.match(
    tools,
    /needs\.preflight\.outputs\.tool_mode == 'full'/,
  );
  assert.match(
    tools,
    /- affected-tools\s*\n\s+- fast-gates\s*\n\s+- tool-buckets/,
  );
  assert.match(
    tools,
    /Exactly one affected or full tool execution path must succeed/,
  );
  assert.match(
    tools,
    /strategy:\s*\n\s+fail-fast:\s+false\s*\n\s+matrix:/,
  );
  for (const bucket of [
    "core-audit",
    "lint-scanners",
    "contracts-data",
    "platform-env",
    "marketing-design",
    "organizer-intake",
  ]) {
    assert.match(tools, new RegExp(`name: ${bucket}`));
  }
});

test("fast structural ratchets block dependency-heavy full tool buckets", () => {
  const tools = workflow("tools-ci.yml");
  const fastJob = tools.match(
    /  fast-gates:\n(?<body>[\s\S]*?)\n  tool-buckets:/u,
  )?.groups?.body;
  assert.ok(fastJob, "fast-gates job must remain present");
  assert.match(fastJob, /needs: preflight/u);
  assert.match(
    fastJob,
    /if: \$\{\{ needs\.preflight\.outputs\.tool_mode == 'full' \}\}/u,
  );
  assert.match(fastJob, /timeout-minutes: 3/u);

  const checkout = namedStep(
    fastJob,
    "Checkout fast deterministic gate closure",
  );
  assert.deepEqual(literalSparsePaths(checkout), fastGateCheckoutClosure);
  assert.match(checkout, /timeout-minutes: 2/u);
  assert.match(checkout, /fetch-depth: 1/u);
  assert.match(checkout, /sparse-checkout-cone-mode: false/u);
  assert.match(fastJob, /uses: actions\/setup-node@v6/u);

  const ratchet = namedStep(
    fastJob,
    "Enforce Flutter test spec maintainability ratchet",
  );
  assert.match(
    ratchet,
    /node tool\/test\/check_flutter_test_size\.mjs --check/u,
  );
  assert.doesNotMatch(
    fastJob,
    /setup-flutter|flutter pub get|npm ci|playwright|apt-get/u,
  );

  const fullBuckets = tools.match(
    /  tool-buckets:\n(?<body>[\s\S]*?)\n  tools:/u,
  )?.groups?.body;
  assert.ok(fullBuckets, "tool-buckets job must remain present");
  assert.match(fullBuckets, /- preflight\s*\n\s+- fast-gates/u);
  assert.match(fullBuckets, /needs\.fast-gates\.result == 'success'/u);
  assert.match(
    fullBuckets,
    /timeout-minutes: \$\{\{ matrix\.name == 'lint-scanners' && 45 \|\| 30 \}\}/u,
  );
  assert.doesNotMatch(fullBuckets, /playwright install --with-deps/u);
  assert.match(fullBuckets, /if command -v rg >\/dev\/null 2>&1/u);
  assert.doesNotMatch(fullBuckets, /apt-get/u);
  assert.match(
    fullBuckets,
    /4cf9f2741e6c465ffdb7c26f38056a59e2a2544b51f7cc128ef28337eeae4d8e/u,
  );

  const resultJob = tools.match(/  tools:\n(?<body>[\s\S]*)$/u)?.groups?.body;
  assert.ok(resultJob, "tools result job must remain present");
  assert.match(resultJob, /FAST_GATES_RESULT/u);
  assert.match(
    resultJob,
    /AFFECTED_RESULT.*success.*FAST_GATES_RESULT.*skipped.*BUCKETS_RESULT.*skipped/u,
  );
  assert.match(
    resultJob,
    /AFFECTED_RESULT.*skipped.*FAST_GATES_RESULT.*success.*BUCKETS_RESULT.*success/u,
  );
});

test("tools materialize only the closure required by each repository view", () => {
  const tools = workflow("tools-ci.yml");
  assert.doesNotMatch(tools, /\n\s+filter:/u);
  assert.doesNotMatch(tools, /^\s+- name: Validate tool manifest\s*$/mu);

  const preflight = namedStep(tools, "Checkout tool preflight closure");
  assert.deepEqual(literalSparsePaths(preflight), toolPreflightCheckoutClosure);
  assert.match(preflight, /timeout-minutes: 3/u);
  assert.match(preflight, /fetch-depth: 0/u);
  assert.match(preflight, /sparse-checkout-cone-mode: false/u);

  const affectedJob = tools.match(
    /  affected-tools:\n(?<body>[\s\S]*?)\n  tool-buckets:/u,
  )?.groups?.body;
  assert.ok(affectedJob, "affected-tools job must remain present");

  const indexCheckout = namedStep(
    affectedJob,
    "Checkout affected index closure",
  );
  assert.match(
    indexCheckout,
    /if: \$\{\{ needs\.preflight\.outputs\.repository_view == 'index' \}\}/u,
  );
  assert.deepEqual(
    literalSparsePaths(indexCheckout),
    affectedIndexCheckoutClosure,
  );
  assert.match(indexCheckout, /timeout-minutes: 3/u);
  assert.match(indexCheckout, /fetch-depth: 0/u);
  assert.match(indexCheckout, /sparse-checkout-cone-mode: false/u);

  const fullCheckout = namedStep(
    affectedJob,
    "Checkout full affected repository",
  );
  assert.match(
    fullCheckout,
    /if: \$\{\{ needs\.preflight\.outputs\.repository_view != 'index' \}\}/u,
  );
  assert.match(fullCheckout, /timeout-minutes: 5/u);
  assert.match(fullCheckout, /fetch-depth: 0/u);
  assert.doesNotMatch(fullCheckout, /sparse-checkout/u);

  const fullBuckets = tools.match(
    /  tool-buckets:\n(?<body>[\s\S]*?)\n  tools:/u,
  )?.groups?.body;
  assert.ok(fullBuckets, "tool-buckets job must remain present");
  assert.match(
    fullBuckets,
    /- uses: actions\/checkout@v6\s+with:\s+fetch-depth: 0/u,
  );
  assert.doesNotMatch(fullBuckets, /sparse-checkout/u);
});

test("affected tools install only planner-declared setup requirements", () => {
  const tools = workflow("tools-ci.yml");
  assert.match(
    tools,
    /repository_view: \$\{\{ steps\.impact\.outputs\.repository_view \}\}/,
  );
  assert.match(
    tools,
    /setup_requirements: \$\{\{ steps\.impact\.outputs\.setup_requirements \}\}/,
  );
  const affectedJob = tools.match(
    /  affected-tools:\n(?<body>[\s\S]*?)\n  tool-buckets:/u,
  )?.groups?.body;
  assert.ok(affectedJob, "affected-tools job must remain present");
  assert.match(affectedJob, /- uses: actions\/setup-node@v6/u);
  assert.match(
    affectedJob,
    /cache: \$\{\{ \(contains\(fromJSON\(needs\.preflight\.outputs\.setup_requirements\), 'root-npm'\) \|\| contains\(fromJSON\(needs\.preflight\.outputs\.setup_requirements\), 'functions-npm'\)\) && 'npm' \|\| '' \}\}/u,
  );
  for (const [stepMarker, requirement] of [
    ["uses: ./.github/actions/setup-flutter", "flutter"],
    ["name: Install scanner dependencies", "ripgrep"],
    ["name: Resolve Flutter and standalone Dart tool dependencies", "flutter-pub"],
    ["run: npm ci", "root-npm"],
    ["run: npm --prefix functions ci", "functions-npm"],
    ["name: Install marketing design browser", "playwright"],
  ]) {
    const step = affectedJob.match(
      new RegExp(
        `      - ${escapeRegex(stepMarker)}(?<body>[\\s\\S]*?)(?=\\n      - |$)`,
        "u",
      ),
    )?.groups?.body;
    assert.ok(step != null, `${stepMarker} step must remain present`);
    assert.match(
      step,
      new RegExp(
        `if: \\$\\{\\{ contains\\(fromJSON\\(needs\\.preflight\\.outputs\\.setup_requirements\\), '${requirement}'\\) \\}\\}`,
        "u",
      ),
    );
  }
  assert.doesNotMatch(affectedJob, /playwright install --with-deps/u);
  assert.match(affectedJob, /if command -v rg >\/dev\/null 2>&1/u);
  assert.doesNotMatch(affectedJob, /apt-get/u);
  assert.match(
    affectedJob,
    /4cf9f2741e6c465ffdb7c26f38056a59e2a2544b51f7cc128ef28337eeae4d8e/u,
  );
  const pubSetup = affectedJob.match(
    /      - name: Resolve Flutter and standalone Dart tool dependencies(?<body>[\s\S]*?)(?=\n      - |$)/u,
  )?.groups?.body;
  assert.ok(pubSetup, "standalone Dart tool dependency setup must remain present");
  assert.match(pubSetup, /flutter pub get/u);
  assert.match(pubSetup, /dart pub get -C tool\/widget_dedupe/u);
});

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}

test("web smoke compiles dev roles without compiling production web", () => {
  const builds = workflow("app-build-matrix.yml");
  assert.match(builds, /inputs\.build_web \|\| inputs\.web_smoke/);
  assert.match(
    builds,
    /inputs\.build_web && contains\(fromJSON\(inputs\.app_roles\), 'consumer'\)/,
  );
  assert.match(
    builds,
    /inputs\.build_web && contains\(fromJSON\(inputs\.app_roles\), 'host'\)/,
  );
});

test("app builds fail fast on structure and fan iOS roles out in parallel", () => {
  const builds = workflow("app-build-matrix.yml");
  const roleValidation = namedStep(builds, "Validate requested app roles");
  assert.match(roleValidation, /length > 0/u);
  assert.match(roleValidation, /\. == "consumer" or \. == "host"/u);

  const structural = namedStep(builds, "Fail-fast app structural gates");
  for (const checkId of [
    "audit:dependency-direction",
    "audit:mutation-error-surfaces",
    "audit:route-string-literals",
    "audit:widget-cleanup",
  ]) {
    assert.match(structural, new RegExp(checkId, "u"));
  }
  assert.ok(
    builds.indexOf("Fail-fast app structural gates") <
      builds.indexOf("  ios:"),
  );

  const ios = builds.slice(builds.indexOf("\n  ios:\n"));
  assert.match(ios, /name: iOS \$\{\{ matrix\.role \}\} simulator build/u);
  assert.match(ios, /role: \$\{\{ fromJSON\(inputs\.app_roles\) \}\}/u);
  assert.match(ios, /if: \$\{\{ matrix\.role == 'consumer' \}\}/u);
  assert.match(ios, /if: \$\{\{ matrix\.role == 'host' \}\}/u);
  assert.doesNotMatch(ios, /contains\(fromJSON\(inputs\.app_roles\)/u);
});

test("Host iOS builds keep retired shell references out of strict wiring", () => {
  const builds = workflow("app-build-matrix.yml");
  const references = namedStep(
    builds,
    "Validate Host design reference manifest",
  );

  assert.match(references, /DP-HOST-HOME-004/u);
  assert.match(references, /Host Messaging/u);
  assert.match(references, /check_reference_screens\.mjs --check --summary/u);
  assert.doesNotMatch(references, /run_captures\.mjs/u);
  assert.doesNotMatch(references, /--compare|--strict/u);
  assert.doesNotMatch(references, /host_home_dashboard/u);
  assert.doesNotMatch(references, /host_home_events_list/u);
  assert.doesNotMatch(references, /host_inbox_queries/u);
  assert.doesNotMatch(references, /host_clubs_management/u);
});

test("mobile release workflow consumes the exact successful CI plan authority", () => {
  const mobile = workflow("mobile-internal-release.yml");
  assert.match(mobile, /catch\.ci-delivery-authority\/v3/);
  assert.match(mobile, /\.operations\.releaseTargets/);
  assert.match(mobile, /needs\.authorize\.outputs\.ios_targets/);
  assert.match(mobile, /needs\.authorize\.outputs\.android_targets/);
  assert.doesNotMatch(mobile, /node tool\/harness\.mjs plan/);
  assert.doesNotMatch(mobile, new RegExp(`mobile_release_roles|${retiredPlanner}`));
});

test("reusable fanout workflows cannot cancel sibling lanes", () => {
  for (const name of [
    "app-build-matrix.yml",
    "flutter-ci.yml",
    "operations-ci.yml",
    "tools-ci.yml",
    "visual-integration-ci.yml",
  ]) {
    const source = workflow(name);
    assert.doesNotMatch(
      source,
      /^concurrency:\s*\n\s+group:.*github\.workflow/m,
      `${name} must inherit concurrency from the CI orchestrator`,
    );
  }
});


test("shared UI lint engine runs once only when the same Tools plan owns it", () => {
  const owned = (changedPaths, full = false) => toolsOwnUiLintSmoke({
    plan: planAffected({changedPaths, graph, full, mode: full ? "nightly" : "pr"}), manifest: toolsManifest, componentGraph: graph,
  });
  assert.equal(owned([".github/workflows/ci.yml"]), true);
  assert.equal(owned([], true), true);
  assert.equal(owned(["tool/check_catch_ui_lints.sh"]), true);
  assert.equal(owned(["lib/main.dart"]), false);
  assert.equal(owned(["tool/docs/check_doc_metadata.mjs"]), false);
  assert.throws(() => toolsOwnUiLintSmoke({plan: {complete: false}}), /incomplete/);
  const changedManifest = structuredClone(toolsManifest);
  changedManifest.tools.find((tool) => tool.id === "lint:catch-ui-plugin-smoke").checks = ["true"];
  assert.throws(() => toolsOwnUiLintSmoke({
    plan: planAffected({changedPaths: [], graph, full: true, mode: "nightly"}), manifest: changedManifest, componentGraph: graph,
  }), /no longer provides/);
  const ci = workflow("ci.yml");
  assert.match(ci, /toolsOwnUiLintSmoke\(\{/u);
  assert.match(ci, /ui_lint_smoke_in_tools: \$\{\{ needs.plan.outputs.tools_owns_ui_lint_smoke == 'true' \}\}/u);
  const flutter = workflow("flutter-ci.yml");
  assert.match(flutter, /ui_lint_smoke_in_tools:[\s\S]*?default: false/u);
});

test("identical registered checks execute once while preserving first-owner order", () => {
  assert.deepEqual(uniqueToolChecks([
    {id: "first", checks: ["node shared.mjs", "node one.mjs"]},
    {id: "second", checks: ["node shared.mjs", "node two.mjs", "node one.mjs"]},
  ]), [
    {toolId: "first", command: "node shared.mjs"},
    {toolId: "first", command: "node one.mjs"},
    {toolId: "second", command: "node two.mjs"},
  ]);
  assert.match(repositorySnapshot.readText("tool/run.mjs", {required: true}), /uniqueToolChecks\(compatible\)/u);
});
