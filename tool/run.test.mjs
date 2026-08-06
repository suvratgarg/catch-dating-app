import test from "node:test";
import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  supportedToolPlatforms,
  toolSupportsPlatform,
  validateToolPlatforms,
} from "./lib/tool_platform.mjs";

function run(args) {
  return spawnSync("node", ["tool/run.mjs", ...args], {
    cwd: process.cwd(),
    encoding: "utf8",
  });
}

test("filtered checks fail when a category matches no tools", () => {
  const result = run(["check", "--category", "definitely-missing"]);
  assert.equal(result.status, 64);
  assert.match(result.stderr, /No active tools matched category definitely-missing/);
});

test("category checks select active tools only", () => {
  const result = run(["list", "--category", "marketing", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const tools = JSON.parse(result.stdout);
  assert.ok(tools.length > 0);
  assert.ok(tools.every((tool) => tool.status === "active"));
});

test("direct checks cannot select inactive tool ids", () => {
  const result = run(["check", "audit:widget-function-migrator"]);
  assert.equal(result.status, 64);
  assert.match(result.stderr, /No active tools matched tool ids/u);
});

test("platform-specific tools run only on declared operating systems", () => {
  const tool = {id: "fixture:darwin-only", platforms: ["darwin"]};
  assert.equal(toolSupportsPlatform(tool, "darwin"), true);
  assert.equal(toolSupportsPlatform(tool, "linux"), false);
  assert.equal(toolSupportsPlatform({id: "fixture:anywhere"}, "linux"), true);
  assert.deepEqual(validateToolPlatforms(tool), []);
  assert.deepEqual(
    validateToolPlatforms({platforms: ["darwin", "darwin"]}),
    ["platforms must not contain duplicates"],
  );
  assert.deepEqual(
    validateToolPlatforms({platforms: ["plan9"]}),
    ['platforms contains unsupported value "plan9"'],
  );
  assert.deepEqual(
    [...supportedToolPlatforms],
    ["darwin", "linux", "win32"],
  );
});

test("impact routing reports the owning relationship and checks", () => {
  const result = run(["impacted", "--paths", "contracts/firestore/users.schema.json", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.relationships.includes("backend-contracts"));
  assert.ok(payload.toolIds.includes("contracts:validate-schemas"));
  assert.ok(payload.ciTargets.includes("contracts"));
  assert.deepEqual(payload.mobileReleaseRoles, []);
  assert.deepEqual(payload.deployGroups, ["backend-contracts"]);
  assert.equal(payload.deployRequired, true);
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("impact routing includes field inventory for Flutter design consumers", () => {
  const result = run(["impacted", "--paths", "lib/routing/go_router.dart", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.relationships.includes("design-system"));
  assert.ok(payload.toolIds.includes("design:flutter-field-surface-inventory"));
  assert.deepEqual(payload.mobileReleaseRoles, ["consumer", "host"]);
  assert.deepEqual(payload.buildTargets, ["consumer-web-smoke", "host-web-smoke"]);
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("impact routing keeps admin-only work out of Flutter and mobile release lanes", () => {
  const result = run(["impacted", "--paths", "admin/src/app/App.tsx", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.ciTargets.includes("admin"));
  assert.ok(!payload.ciTargets.includes("flutter"));
  assert.deepEqual(payload.mobileReleaseRoles, []);
});

test("impact routing preserves role ownership for independent app packages", () => {
  const result = run([
    "impacted",
    "--paths",
    "apps/host/lib/host_platform_app.dart",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.relationships.includes("flutter-app"));
  assert.deepEqual(payload.appRoles, ["host"]);
  assert.deepEqual(payload.mobileReleaseRoles, ["host"]);
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("impact routing treats ordinary root documentation as owned", () => {
  const result = run(["impacted", "--paths", "README.md", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.deepEqual(payload.ciTargets, ["docs"]);
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("generated localization and notification copy avoid unrelated mobile releases", () => {
  for (const changedPath of [
    "lib/l10n/generated/app_localizations.dart",
    "copy/notifications_en.json",
  ]) {
    const result = run(["impacted", "--paths", changedPath, "--json"]);
    assert.equal(result.status, 0, result.stderr);
    const payload = JSON.parse(result.stdout);
    assert.deepEqual(payload.mobileReleaseRoles, []);
  }
});

test("impact routing fails closed for an unmapped changed path", () => {
  const result = run(["impacted", "--paths", "unowned/example.txt", "--json"]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Unmapped changed paths/);
});

test("impact routing includes untracked files", (context) => {
  const probe = path.join(process.cwd(), "unowned-impact-probe.tmp");
  fs.writeFileSync(probe, "probe\n");
  context.after(() => fs.rmSync(probe, {force: true}));
  const result = run(["impacted", "--json"]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /unowned-impact-probe\.tmp/);
});

test("affected-tool routing selects the checker and mandatory guards", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs,tool/docs/check_doc_version_monotonic.test.mjs",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "affected");
  assert.deepEqual(payload.toolIds, [
    "agent:readiness",
    "docs:version-monotonic",
    "meta:enforcement-integrity",
    "meta:repository-root-hygiene",
    "meta:test-inventory",
  ]);
  assert.deepEqual(payload.unmappedPaths, []);
});

test("affected-tool routing ignores companion files owned by other lanes", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs,docs/audit_registry/passes.jsonl,tool/README.md",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "affected");
  assert.deepEqual(payload.toolLanePaths, [
    "tool/docs/check_doc_version_monotonic.mjs",
  ]);
  assert.deepEqual(payload.ignoredPaths, [
    "docs/audit_registry/passes.jsonl",
    "tool/README.md",
  ]);
});

test("affected-tool routing cannot ignore declared full-impact companions", () => {
  for (const fullPath of ["pubspec.lock", "functions/package-lock.json"]) {
    const result = run([
      "affected-tools",
      "--paths",
      `tool/docs/check_doc_version_monotonic.mjs,${fullPath}`,
      "--json",
    ]);
    assert.equal(result.status, 0, result.stderr);
    const payload = JSON.parse(result.stdout);
    assert.equal(payload.mode, "full");
    assert.ok(
      payload.fullReasons.includes(`control-plane path changed: ${fullPath}`),
    );
  }
});

test("affected-tool routing fails closed for any unmapped lane input", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "design/screens/catch.screens.json",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "full");
  assert.deepEqual(payload.unmappedPaths, ["design/screens/catch.screens.json"]);

  const execution = run([
    "affected-tools",
    "--paths",
    "design/screens/catch.screens.json",
    "--check",
  ]);
  assert.equal(execution.status, 1);
  assert.match(execution.stderr, /run the full category matrix/u);
});

test("affected-tool routing keeps control-plane and explicit full runs full", () => {
  for (const args of [
    ["--paths", ".github/workflows/tools-ci.yml"],
    ["--paths", "tool/ci/check_toolchain_consistency.sh"],
    ["--paths", "tool/harness.mjs"],
    ["--paths", "docs/README.md", "--full"],
  ]) {
    const result = run(["affected-tools", ...args, "--json"]);
    assert.equal(result.status, 0, result.stderr);
    assert.equal(JSON.parse(result.stdout).mode, "full");
  }
});

test("affected-tool routing preserves the requested Harness mode", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs",
    "--mode",
    "main",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  assert.equal(JSON.parse(result.stdout).harnessMode, "main");
});

test("active tool entries cannot be vacuous", () => {
  const manifest = JSON.parse(fs.readFileSync("tool/tools_manifest.json", "utf8"));
  const empty = manifest.tools
    .filter((tool) => tool.status === "active")
    .filter((tool) => !Array.isArray(tool.checks) || tool.checks.length === 0)
    .map((tool) => tool.id);
  assert.deepEqual(empty, []);
});

test("affected-tool GitHub outputs carry bounded control signals only", (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-tool-impact-"));
  context.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const outputPath = path.join(directory, "github-output");
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs",
    "--github-output",
    outputPath,
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const output = fs.readFileSync(outputPath, "utf8");
  assert.equal(output, "tool_mode=affected\naffected=true\nfull=false\n");
  assert.doesNotMatch(output, /docs:version-monotonic/u);
});
