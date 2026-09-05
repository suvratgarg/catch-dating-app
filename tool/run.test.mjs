import test from "node:test";
import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {createRequire} from "node:module";
import {
  supportedToolPlatforms,
  toolSupportsPlatform,
  validateToolPlatforms,
} from "./lib/tool_platform.mjs";

const repositoryRoot = process.cwd();
const require = createRequire(import.meta.url);

function run(args, {cwd = repositoryRoot, env = process.env} = {}) {
  return spawnSync("node", ["tool/run.mjs", ...args], {
    cwd,
    encoding: "utf8",
    env,
  });
}

test("help describes the manifest runner without a duplicate impact planner", () => {
  const result = run(["help"]);
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /check \[--category name\]/u);
  assert.match(result.stdout, /affected-tools/u);
  assert.match(result.stdout, /run <tool-id>/u);
  assert.doesNotMatch(result.stdout, /\bimpacted\b/u);
  assert.doesNotMatch(result.stdout, /authority|lease|phase/u);
});

test("unknown commands and empty filtered selections fail clearly", () => {
  const unknown = run(["not-a-command"]);
  assert.equal(unknown.status, 64);
  assert.match(unknown.stderr, /Unknown command: not-a-command/u);

  const empty = run(["check", "--category", "definitely-missing"]);
  assert.equal(empty.status, 64);
  assert.match(empty.stderr, /No active tools matched category definitely-missing/u);
});

test("repository manifest is valid and active tools are executable", () => {
  const validation = run(["check", "--manifest-only"]);
  assert.equal(validation.status, 0, validation.stderr);
  assert.equal(validation.stdout, "Tool manifest validation passed.\n");

  const manifest = JSON.parse(fs.readFileSync("tool/tools_manifest.json", "utf8"));
  const vacuous = manifest.tools
    .filter((tool) => tool.status === "active")
    .filter((tool) =>
      !Array.isArray(tool.checks) ||
      tool.checks.length === 0 ||
      tool.checks.some((check) => typeof check !== "string" || check.trim() === "")
    )
    .map((tool) => tool.id);
  assert.deepEqual(vacuous, []);
});

test("list exposes active tools only", () => {
  const result = run(["list", "--category", "marketing", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const tools = JSON.parse(result.stdout);
  assert.ok(tools.length > 0);
  assert.ok(tools.every((tool) => tool.status === "active"));
  assert.ok(tools.every((tool) => tool.category === "marketing"));
});

test("direct check selection rejects inactive and unknown ids", () => {
  const manifest = JSON.parse(fs.readFileSync("tool/tools_manifest.json", "utf8"));
  const activeId = manifest.tools.find((tool) => tool.status === "active")?.id;
  const inactiveId = manifest.tools.find((tool) => tool.status !== "active")?.id;
  assert.ok(activeId);

  const mixed = run(["check", activeId, "definitely-missing"]);
  assert.equal(mixed.status, 64);
  assert.match(mixed.stderr, /Unknown or inactive tool ids: definitely-missing/u);
  assert.doesNotMatch(mixed.stdout, /==>/u);

  if (inactiveId) {
    const inactive = run(["check", inactiveId]);
    assert.equal(inactive.status, 64);
    assert.match(inactive.stderr, /Unknown or inactive tool ids/u);
  }
});

test("platform declarations remain deterministic", () => {
  const darwinOnly = {id: "fixture:darwin-only", platforms: ["darwin"]};
  assert.equal(toolSupportsPlatform(darwinOnly, "darwin"), true);
  assert.equal(toolSupportsPlatform(darwinOnly, "linux"), false);
  assert.equal(toolSupportsPlatform({id: "fixture:anywhere"}, "linux"), true);
  assert.deepEqual(validateToolPlatforms(darwinOnly), []);
  assert.deepEqual(
    validateToolPlatforms({platforms: ["darwin", "darwin"]}),
    ["platforms must not contain duplicates"],
  );
  assert.deepEqual(
    validateToolPlatforms({platforms: ["plan9"]}),
    ['platforms contains unsupported value "plan9"'],
  );
  assert.deepEqual([...supportedToolPlatforms], ["darwin", "linux", "win32"]);
});

test("affected-tool routing selects owners and mandatory guards", () => {
  const manifest = JSON.parse(fs.readFileSync("tool/tools_manifest.json", "utf8"));
  const mandatory = manifest.ciImpact.mandatoryCheckIds;
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_metadata.mjs,tool/docs/check_doc_metadata.test.mjs",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const plan = JSON.parse(result.stdout);
  assert.equal(plan.mode, "affected");
  assert.ok(plan.ownersByPath["tool/docs/check_doc_metadata.mjs"].includes("docs:metadata"));
  assert.ok(mandatory.every((id) => plan.toolIds.includes(id)));
  assert.deepEqual(plan.unmappedPaths, []);
});

test("shared glob dependency selects every consuming tool", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/lib/path_glob.mjs",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const plan = JSON.parse(result.stdout);
  assert.deepEqual(plan.ownersByPath["tool/lib/path_glob.mjs"], [
    "agent:context-pack",
    "agent:harness-v2",
    "meta:repository-root-hygiene",
  ]);
  assert.equal(plan.full, true);
});

test("mobile evidence and target contracts select producer-promoter compatibility gates", () => {
  for (const changedPath of [
    "tool/platform/check_mobile_package.mjs",
    "tool/platform/verify_android_release_bundle.mjs",
    "tool/platform/verify_ios_release_identity.mjs",
  ]) {
    const result = run(["affected-tools", "--paths", changedPath, "--json"]);
    assert.equal(result.status, 0, result.stderr);
    const plan = JSON.parse(result.stdout);
    for (const expected of [
      "ci:mobile-release-package",
      "ci:mobile-release-workflow",
      "ci:mobile-promotion-core",
      "ci:mobile-promotion-workflow",
    ]) {
      assert.ok(plan.toolIds.includes(expected), `${changedPath} must select ${expected}`);
    }
  }

  const targets = run([
    "affected-tools",
    "--paths",
    "tool/app_targets.json",
    "--json",
  ]);
  assert.equal(targets.status, 0, targets.stderr);
  assert.ok(JSON.parse(targets.stdout).toolIds.includes("platform:app-targets"));
});

test("affected-tool routing preserves mode and escalates control-plane changes", () => {
  const routed = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_metadata.mjs",
    "--mode",
    "main",
    "--json",
  ]);
  assert.equal(routed.status, 0, routed.stderr);
  assert.equal(JSON.parse(routed.stdout).harnessMode, "main");

  for (const changedPath of ["tool/run.mjs", ".github/workflows/tools-ci.yml"]) {
    const full = run(["affected-tools", "--paths", changedPath, "--json"]);
    assert.equal(full.status, 0, full.stderr);
    assert.equal(JSON.parse(full.stdout).mode, "full");
  }
});

test("full affected-tool execution refuses before dispatch", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/run.mjs",
    "--check",
  ]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /selected full mode; run the full category matrix/u);
  assert.doesNotMatch(result.stdout, /==>/u);
});

test("unknown Harness ownership refuses affected-tool execution before dispatch", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "unowned/example.txt",
    "--check",
  ]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /selected full mode; run the full category matrix/u);
  assert.doesNotMatch(result.stdout, /==>/u);
});

test("affected-tool GitHub output contains bounded control signals", (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-tool-output-"));
  context.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const outputPath = path.join(directory, "github-output");
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_metadata.mjs",
    "--github-output",
    outputPath,
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const output = fs.readFileSync(outputPath, "utf8");
  assert.match(output, /^tool_mode=affected$/mu);
  assert.match(output, /^affected=true$/mu);
  assert.match(output, /^full=false$/mu);
  assert.match(output, /^repository_view=full$/mu);
  assert.match(output, /^setup_requirements=\["node"\]$/mu);
  assert.doesNotMatch(output, /docs:metadata/u);
});

test("the runner executes manifest checks without task authority metadata", (context) => {
  const fixture = createRunnerFixture(context);
  const result = run(["check", "fixture:check"], {cwd: fixture});
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /==> fixture:check: node tool\/check\.mjs/u);
  assert.match(result.stdout, /fixture-check/u);
  assert.match(result.stdout, /Tool checks passed/u);
  assert.doesNotMatch(result.stderr, /authority|lease|phase|managed task/iu);
});

test("direct tool execution forwards shell-sensitive arguments safely", (context) => {
  const fixture = createRunnerFixture(context);
  const result = run(["run", "fixture:check", "two words", "it's-safe"], {
    cwd: fixture,
  });
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(JSON.parse(result.stdout), ["two words", "it's-safe"]);
});

test("same-run React sharing preserves standalone checks and exact command boundaries", (context) => {
  const fixture = createRunnerFixture(context);
  const bin = path.join(fixture, "bin");
  fs.mkdirSync(bin);
  fs.writeFileSync(path.join(bin, "npm"), '#!/bin/sh\nprintf "%s\\n" "$*" >> browser-runs.txt\n', {mode: 0o755});
  fs.mkdirSync(path.join(fixture, "tool/web"));
  fs.writeFileSync(path.join(fixture, "tool/web/check_storybook_visuals.mjs"),
    'import fs from "node:fs"; fs.appendFileSync("browser-runs.txt", `visual ${process.argv.slice(2).join(" ")}\\n`);\n');
  fs.writeFileSync(path.join(fixture, "tool/build_contract.mjs"),
    'import fs from "node:fs"; fs.appendFileSync("browser-runs.txt", `contract ${process.argv[2]}\\n`); if (process.env.FAIL_BUILD_CONTRACT) process.exit(23);\n');
  const a11y = "npm --workspace catch-marketing run test:storybook:a11y";
  const visuals = "npm --workspace catch-marketing run build:storybook && node tool/web/check_storybook_visuals.mjs --surface website --check";
  const siteBuild = "npm --prefix website run build";
  const storybookBuild = "npm --workspace catch-marketing run build:storybook";
  mutateFixtureManifest(fixture, (manifest) => {
    const template = manifest.tools[0];
    manifest.tools.push(
      {...template, id: "marketing:website-storybook-a11y", checks: [a11y]},
      {...template, id: "web:storybook-visuals", path: "tool/web/check_storybook_visuals.mjs",
        checks: ["node tool/web/check_storybook_visuals.mjs --self-test", visuals]},
      {...template, id: "marketing:website-build", path: "tool/build_contract.mjs",
        checks: ["node tool/build_contract.mjs postbuild", siteBuild]},
      {...template, id: "marketing:website-storybook",
        checks: ["node tool/build_contract.mjs storybook-config", storybookBuild]},
    );
  });
  const args = ["check", "marketing:website-storybook-a11y", "web:storybook-visuals",
    "marketing:website-build", "marketing:website-storybook"];
  const env = {...process.env, PATH: `${bin}${path.delimiter}${process.env.PATH}`, GITHUB_ACTIONS: "true"};
  const receipt = path.join(fixture, "browser-runs.txt");
  const standalone = run(args, {cwd: fixture, env});
  assert.equal(standalone.status, 0, standalone.stderr);
  assert.deepEqual(fs.readFileSync(receipt, "utf8").trim().split("\n"), [
    "--workspace catch-marketing run test:storybook:a11y",
    "visual --self-test",
    "--workspace catch-marketing run build:storybook",
    "visual --surface website --check",
    "contract postbuild",
    "--prefix website run build",
    "contract storybook-config",
    "--workspace catch-marketing run build:storybook",
  ]);
  fs.unlinkSync(receipt);
  const shared = run([...args, "--marketing-checks-in-react"], {cwd: fixture, env});
  assert.equal(shared.status, 0, shared.stderr);
  assert.equal(fs.readFileSync(receipt, "utf8"),
    "visual --self-test\ncontract postbuild\ncontract storybook-config\n");
  assert.equal(shared.stdout.match(/provided by the required same-run React marketing lane/g)?.length, 4);
  const failedContract = run([...args, "--marketing-checks-in-react"], {
    cwd: fixture, env: {...env, FAIL_BUILD_CONTRACT: "true"},
  });
  assert.equal(failedContract.status, 23);
  assert.doesNotMatch(failedContract.stdout, /Tool checks passed/u);

  // A changed command cannot inherit the old command's passing evidence.
  mutateFixtureManifest(fixture, (manifest) => {
    manifest.tools.find((tool) => tool.id === "marketing:website-storybook-a11y")
      .checks = [`${a11y} -- --changed`];
    for (const [id, command] of [
      ["marketing:website-build", siteBuild],
      ["marketing:website-storybook", storybookBuild],
    ]) {
      const tool = manifest.tools.find((entry) => entry.id === id);
      tool.checks = tool.checks.map((check) => check === command ? `${check} -- --changed` : check);
    }
  });
  fs.unlinkSync(receipt);
  const changed = run([...args, "--marketing-checks-in-react"], {cwd: fixture, env});
  assert.equal(changed.status, 0, changed.stderr);
  assert.match(fs.readFileSync(receipt, "utf8"), /test:storybook:a11y -- --changed/u);
  assert.match(fs.readFileSync(receipt, "utf8"), /--prefix website run build -- --changed/u);
  assert.match(fs.readFileSync(receipt, "utf8"), /run build:storybook -- --changed/u);
  fs.unlinkSync(receipt);
  const outsideCi = run([...args, "--marketing-checks-in-react"], {
    cwd: fixture, env: {...env, GITHUB_ACTIONS: "false"},
  });
  assert.equal(outsideCi.status, 64);
  assert.match(outsideCi.stderr, /requires the same-run CI marketing lane/u);
  assert.equal(fs.existsSync(receipt), false);
});

test("multiple categories keep order, deduplicate commands and reject any unknown category before execution", (context) => {
  const fixture = createRunnerFixture(context);
  mutateFixtureManifest(fixture, (manifest) => {
    const template = manifest.tools[0];
    manifest.tools.push({...template, id: "second:check", category: "second",
      checks: ["node tool/check.mjs", "node tool/check.mjs second"]});
  });
  const result = run(["check", "--category", "second", "--category", "fixture", "--category", "second"], {cwd: fixture});
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stdout.match(/^fixture-check$/gm)?.length, 1);
  assert.equal(result.stdout.match(/^\["second"\]$/gm)?.length, 1);
  assert.match(result.stdout, /==> second:check: node tool\/check.mjs\n/u);
  assert.ok(result.stdout.indexOf('["second"]') < result.stdout.indexOf('==> tool:runner'));
  const missing = run(["check", "--category", "fixture", "--category", "missing"], {cwd: fixture});
  assert.equal(missing.status, 64);
  assert.match(missing.stderr, /No active tools matched category missing/u);
  assert.doesNotMatch(missing.stdout, /==>/u);
  const noValue = run(["check", "--category", "fixture", "--category"], {cwd: fixture});
  assert.notEqual(noValue.status, 0);
  assert.match(noValue.stderr, /--category requires a value/u);
  assert.doesNotMatch(noValue.stdout, /==>/u);
});

test("manifest validation rejects vacuous tools before dispatch", (context) => {
  const fixture = createRunnerFixture(context);
  mutateFixtureManifest(fixture, (manifest) => {
    manifest.tools.find((tool) => tool.id === "fixture:check").checks = [];
  });
  const result = run(["check", "fixture:check"], {cwd: fixture});
  assert.equal(result.status, 1);
  assert.match(result.stderr, /fixture:check is active but defines no checks/u);
  assert.doesNotMatch(result.stdout, /==>/u);
});

test("manifest validation rejects malformed safety and platform metadata", (context) => {
  const fixture = createRunnerFixture(context);
  mutateFixtureManifest(fixture, (manifest) => {
    const tool = manifest.tools.find((entry) => entry.id === "fixture:check");
    tool.checkSafety = "remote-mutable";
    tool.platforms = ["plan9"];
  });
  const result = run(["check", "--manifest-only"], {cwd: fixture});
  assert.equal(result.status, 1);
  assert.match(result.stderr, /platforms contains unsupported value "plan9"/u);
  assert.match(result.stderr, /checkSafety must be one of local-readonly/u);
});

test("manifest validation rejects unknown guard ids", (context) => {
  const fixture = createRunnerFixture(context);
  mutateFixtureManifest(fixture, (manifest) => {
    manifest.ciImpact.mandatoryCheckIds = ["fixture:not-real"];
  });
  const result = run(["check", "--manifest-only"], {cwd: fixture});
  assert.equal(result.status, 1);
  assert.match(result.stderr, /references inactive or unknown id: fixture:not-real/u);
});

test("manifest validation rejects unregistered scripts and duplicate ids", (context) => {
  const fixture = createRunnerFixture(context);
  fs.writeFileSync(path.join(fixture, "tool/unregistered.mjs"), "export {};\n");
  mutateFixtureManifest(fixture, (manifest) => {
    manifest.tools.push({...manifest.tools[0]});
  });
  const result = run(["check", "--manifest-only"], {cwd: fixture});
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Duplicate tool id: fixture:check/u);
  assert.match(result.stderr, /Unmanaged tool script: tool\/unregistered\.mjs/u);
});

function createRunnerFixture(context) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-runner-"));
  context.after(() => fs.rmSync(root, {recursive: true, force: true}));
  for (const relativePath of [
    "tool/run.mjs",
    "tool/agent/lib/context_plan.mjs",
    "tool/harness/lib/component_graph.mjs",
    "tool/harness/lib/git_changes.mjs",
    "tool/lib/path_glob.mjs",
    "tool/lib/repo_paths.mjs",
    "tool/lib/repository_snapshot.mjs",
    "tool/lib/tool_impact.mjs",
    "tool/lib/tool_platform.mjs",
  ]) {
    const destination = path.join(root, relativePath);
    fs.mkdirSync(path.dirname(destination), {recursive: true});
    fs.copyFileSync(path.join(repositoryRoot, relativePath), destination);
  }
  fs.writeFileSync(
    path.join(root, "tool/check.mjs"),
    'console.log(process.argv.length > 2 ? JSON.stringify(process.argv.slice(2)) : "fixture-check");\n',
  );
  fs.writeFileSync(
    path.join(root, "tool/tools_manifest.json"),
    `${JSON.stringify(fixtureManifest(), null, 2)}\n`,
  );
  fs.writeFileSync(
    path.join(root, "tool/harness/component_graph.json"),
    `${JSON.stringify({
      components: [{
        id: "repo.harness",
        ownedPaths: {include: ["tool/run.mjs", "tool/harness/**"]},
      }],
    }, null, 2)}\n`,
  );
  runGit(root, ["init"]);
  runGit(root, ["config", "user.name", "Catch Runner Test"]);
  runGit(root, ["config", "user.email", "runner-test@example.com"]);
  runGit(root, ["add", "."]);
  runGit(root, ["commit", "-m", "runner fixture"]);
  return root;
}

function fixtureManifest() {
  const requirements = {repositoryView: "index", setup: ["node"]};
  return {
    ciImpact: {
      mandatoryCheckIds: ["fixture:check"],
      additionalFullPaths: ["package-lock.json"],
    },
    tools: [
      {
        id: "fixture:check",
        category: "fixture",
        path: "tool/check.mjs",
        status: "active",
        checks: ["node tool/check.mjs"],
        command: "node tool/check.mjs",
        checkSafety: "local-readonly",
        ciRequirements: requirements,
      },
      {
        id: "tool:runner",
        category: "fixture",
        path: "tool/run.mjs",
        status: "active",
        checks: ["node --check tool/run.mjs"],
        checkSafety: "local-readonly",
        ciRequirements: requirements,
      },
      {
        id: "fixture:inactive",
        category: "fixture",
        path: "tool/check.mjs",
        status: "archived",
        checks: ["node tool/check.mjs"],
      },
    ],
  };
}

function mutateFixtureManifest(root, callback) {
  const manifestPath = path.join(root, "tool/tools_manifest.json");
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  callback(manifest);
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
}

function runGit(cwd, args) {
  const result = spawnSync("git", args, {cwd, encoding: "utf8"});
  assert.equal(
    result.status,
    0,
    `git ${args.join(" ")} failed:\n${result.stderr || result.stdout}`,
  );
}


test("Tools preflight and execution retain reverted files from the same exact commit window", (context) => {
  const fixture = createRunnerFixture(context);
  fs.copyFileSync(path.join(repositoryRoot, "tool/harness/component_graph.json"),
    path.join(fixture, "tool/harness/component_graph.json"));
  const commit = () => {
    runGit(fixture, ["add", "."]); runGit(fixture, ["commit", "--quiet", "-m", "window fixture"]);
    return spawnSync("git", ["rev-parse", "HEAD"], {cwd: fixture, encoding: "utf8"}).stdout.trim();
  };
  const base = commit();
  const file = path.join(fixture, "tool/check.mjs");
  const original = fs.readFileSync(file, "utf8");
  fs.writeFileSync(file, original + "// transient edit\n"); commit();
  fs.writeFileSync(file, original); const head = commit();
  const args = ["affected-tools", "--base", base, "--head", head, "--mode", "main", "--commit-window"];
  const planned = run(args, {cwd: fixture});
  assert.equal(planned.status, 0, planned.stderr);
  const plan = JSON.parse(planned.stdout);
  assert.deepEqual(plan.changedPaths, ["tool/check.mjs"]);
  assert.equal(plan.mode, "affected");
  assert.deepEqual(plan.toolIds, ["fixture:check"]);
  const executed = run([...args, "--check"], {cwd: fixture});
  assert.equal(executed.status, 0, executed.stderr);
  assert.match(executed.stdout, /fixture-check/u);
  const invalid = run([...args, "--paths", "README.md"], {cwd: fixture});
  assert.notEqual(invalid.status, 0);
  assert.doesNotMatch(invalid.stdout, /==>/u);
});
