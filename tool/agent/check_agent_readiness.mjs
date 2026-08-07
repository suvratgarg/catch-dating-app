#!/usr/bin/env node
import path from "node:path";
import {fileURLToPath} from "node:url";
import {scanDependencyDirection} from "../architecture/check_dependency_direction.mjs";
import {fromRepo} from "../lib/repo_paths.mjs";
import {createRepositorySnapshot} from "../lib/repository_snapshot.mjs";
import {buildInventory, renderInventory} from "../test_inventory.mjs";
import {collectLocalReadonlyCheckIds} from "../lib/tool_impact.mjs";

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli();

function runCli() {
  const args = parseArgs(process.argv.slice(2));
  const snapshot = createRepositorySnapshot({root: fromRepo()});
  const result = evaluateAgentReadiness({snapshot});

  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(
      `Agent readiness score: ${result.score}/100 (${result.passed}/${result.total} checks passed)`,
    );
    for (const failure of result.failures) {
      console.error(`- ${failure}`);
    }
    for (const warning of result.warnings) {
      console.error(`! ${warning}`);
    }
  }

  if (result.failed > 0) {
    process.exitCode = 1;
  }
}

export function evaluateAgentReadiness({snapshot}) {
  if (
    snapshot == null ||
    typeof snapshot.exists !== "function" ||
    typeof snapshot.listFiles !== "function" ||
    typeof snapshot.listPaths !== "function" ||
    typeof snapshot.readTexts !== "function"
  ) {
    throw new Error("Agent readiness requires a repository snapshot.");
  }

  const repositoryFiles = snapshot.listFiles();
  const skillMarkdownPaths = repositoryFiles.filter((relativePath) =>
    relativePath.startsWith("docs/agent_skills/") && relativePath.endsWith(".md"));
  const sourcePaths = [
    "AGENTS.md",
    "docs/README.md",
    "docs/agent_operating_model.md",
    "docs/agent_skills/skills_manifest.json",
    "docs/audit_registry/test_inventory.json",
    "tool/architecture/dependency_direction_baseline.json",
    "tool/README.md",
    "tool/tools_manifest.json",
    ...skillMarkdownPaths,
  ];
  const sources = snapshot.readTexts([...new Set(sourcePaths)]);
  const sourceFor = (relativePath) => sources.get(relativePath) ?? null;
  const readJson = (relativePath) => parseJsonSource(sourceFor(relativePath));
  const checks = [];
  const check = (ok, message) => {
    checks.push({ok: Boolean(ok), message});
  };
  const checkPath = (relativePath, message) => {
    check(
      Boolean(relativePath) && repositoryPathExists(snapshot, relativePath),
      message,
    );
  };
  const checkContains = (relativePath, needle, message) => {
    check(sourceFor(relativePath)?.includes(needle) === true, message);
  };

  const toolsManifest = readJson("tool/tools_manifest.json");
  const skillsManifest = readJson("docs/agent_skills/skills_manifest.json");

  checkPath("AGENTS.md", "Agent entrypoint exists.");
  checkPath("docs/agent_operating_model.md", "Agent operating model exists.");
  checkPath("docs/agent_skills/skills_manifest.json", "Skill manifest exists.");
  checkPath("tool/agent/context_pack.mjs", "Context pack tool exists.");
  checkPath("tool/agent/check_agent_readiness.mjs", "Readiness tool exists.");
  checkPath(
    "docs/audit_registry/test_inventory.json",
    "Canonical test inventory exists.",
  );
  checkContains(
    "AGENTS.md",
    "docs/agent_operating_model.md",
    "AGENTS.md routes to the operating model.",
  );
  checkContains(
    "AGENTS.md",
    "tool/agent/context_pack.mjs",
    "AGENTS.md names the context-pack tool.",
  );
  checkContains(
    "docs/agent_operating_model.md",
    "Parallel Worktree Delegation Contract",
    "Operating model defines parallel worktree delegation.",
  );
  checkContains(
    "docs/agent_operating_model.md",
    "pattern_delta",
    "Operating model requires pattern_delta in subagent results.",
  );
  checkContains(
    "docs/agent_operating_model.md",
    "Git Preservation And Reconciliation Contract",
    "Operating model defines Git preservation and reconciliation safety.",
  );
  checkContains(
    "docs/agent_operating_model.md",
    "tool/git/audit_merge_drops.mjs",
    "Operating model requires mechanical merge-drop audits.",
  );
  checkContains(
    "docs/README.md",
    "agent_operating_model.md",
    "Docs index includes the operating model.",
  );
  checkContains(
    "docs/README.md",
    "agent_skills/",
    "Docs index includes project-local skills.",
  );
  check(
    testInventoryMatches(
      sourceFor("docs/audit_registry/test_inventory.json") ?? "",
      buildInventory(repositoryFiles),
    ),
    "Canonical test inventory matches tracked and untracked test files.",
  );

  const toolIds = new Set((toolsManifest?.tools ?? []).map((tool) => tool.id));
  const eligibleCheckIds = collectLocalReadonlyCheckIds(toolsManifest);
  for (const id of [
    "agent:context-pack",
    "agent:readiness",
    "git:audit-merge-drops",
    "docs:version-monotonic",
  ]) {
    check(toolIds.has(id), `Tool manifest includes ${id}.`);
  }
  const dependencyDirectionBaseline = readDependencyDirectionBaselineSnapshot({
    baseline: readJson("tool/architecture/dependency_direction_baseline.json"),
    snapshot,
  });

  const checker = {check, checkPath, sourceFor};
  validateSkills(skillsManifest, eligibleCheckIds, checker);
  validateTaskScopeGuidance(
    ["AGENTS.md", "docs/agent_operating_model.md", "tool/README.md", ...skillMarkdownPaths],
    checker,
  );

  const passed = checks.filter((entry) => entry.ok).length;
  const failed = checks.length - passed;
  const score = checks.length === 0
    ? 0
    : failed === 0
      ? 100
      : Math.min(99, Math.round((passed / checks.length) * 100));

  const result = {
    score,
    passed,
    failed,
    total: checks.length,
    failures: checks.filter((entry) => !entry.ok).map((entry) => entry.message),
    warnings: [],
    architecture_baselines: {
      dependency_direction: dependencyDirectionBaseline,
    },
  };

  return result;
}

function validateSkills(manifest, eligibleCheckIds, {check, checkPath}) {
  check(Boolean(manifest && Array.isArray(manifest.skills)), "Skill manifest has a skills array.");
  const seenIds = new Set();
  for (const skill of manifest?.skills ?? []) {
    const requiredCommands = Array.isArray(skill.required_commands)
      ? skill.required_commands
      : [];
    check(Boolean(skill.skill_id), "Skill has skill_id.");
    if (skill.skill_id) {
      check(!seenIds.has(skill.skill_id), `Skill id is unique: ${skill.skill_id}.`);
      seenIds.add(skill.skill_id);
    }
    checkPath(skill.path, `${skill.skill_id} markdown file exists.`);
    check(Array.isArray(skill.source_docs) && skill.source_docs.length > 0, `${skill.skill_id} declares source docs.`);
    check(Array.isArray(skill.required_tools) && skill.required_tools.length > 0, `${skill.skill_id} declares required tools.`);
    check(requiredCommands.length > 0, `${skill.skill_id} declares required commands.`);
    check(
      !requiredCommands.some(usesRetiredTaskScopeFlag),
      `${skill.skill_id} required commands use canonical task-scope flags.`,
    );
    check(Boolean(skill.success_evidence), `${skill.skill_id} declares success evidence.`);
    for (const sourceDoc of skill.source_docs ?? []) {
      checkPath(sourceDoc, `${skill.skill_id} source doc exists: ${sourceDoc}.`);
    }
    for (const toolId of skill.required_tools ?? []) {
      check(eligibleCheckIds.has(toolId), `${skill.skill_id} required tool is eligible: ${toolId}.`);
    }
    for (const command of requiredCommands) {
      for (const commandPath of extractCommandPaths(command)) {
        checkPath(commandPath, `${skill.skill_id} command path exists: ${commandPath}.`);
      }
    }
  }
}

function validateTaskScopeGuidance(relativePaths, {check, sourceFor}) {
  for (const relativePath of [...new Set(relativePaths)].sort()) {
    check(
      !usesRetiredTaskScopeFlag(sourceFor(relativePath) ?? "", {prose: true}),
      `${relativePath} uses canonical task-scope flags.`,
    );
  }
}

export function usesRetiredTaskScopeFlag(source, {prose = false} = {}) {
  const logicalSource = String(source).replace(/\\\r?\n\s*/gu, " ");
  return logicalSource.split(/\r?\n/u).some((line) =>
    invocationUsesAmbiguousScope(line, {
      invocation: /\bnode\s+(?:\.\/)?tool\/agent\/context_pack\.mjs(?=$|[\s`.,:;\)\]}])/gu,
      retiredFlags: new Set(["--path", "--paths", "--impact-paths"]),
      valueFlags: new Set([
        "--task",
        "--mode",
        "--owned-paths",
        "--planned-impact-paths",
        "--output",
      ]),
      booleanFlags: new Set(["--json"]),
      helpFlags: new Set(["--help", "-h"]),
    }, {prose}) || invocationUsesAmbiguousScope(line, {
      invocation: /\bnode\s+(?:\.\/)?tool\/harness\.mjs\s+task\s+start(?=$|[\s`.,:;\)\]}])/gu,
      retiredFlags: new Set(["--paths"]),
      valueFlags: new Set([
        "--task-id",
        "--base-sha",
        "--stack-parent",
        "--branch",
        "--owned-paths",
        "--context-pack",
        "--budget-mib",
        "--reserve-mib",
      ]),
      booleanFlags: new Set(["--json"]),
      helpFlags: new Set(),
    }, {prose}),
  );
}

function invocationUsesAmbiguousScope(
  line,
  {invocation, retiredFlags, valueFlags, booleanFlags, helpFlags},
  {prose},
) {
  invocation.lastIndex = 0;
  for (const match of line.matchAll(invocation)) {
    const prefix = line.slice(0, match.index);
    const rawSuffix = line.slice(match.index + match[0].length);
    const inlineCode = isInlineCodeInvocation(prefix, rawSuffix);
    if (prose && !inlineCode && !isStandaloneCommandPrefix(prefix)) {
      continue;
    }

    const suffix = commandSegment(rawSuffix);
    const tokens = commandTokens(suffix);
    if (prose && tokens.length === 0 && inlineCode) {
      continue;
    }
    if (tokens.length === 1 && helpFlags.has(tokens[0])) {
      continue;
    }
    if (tokens.some((token) => retiredFlags.has(token.split("=", 1)[0]))) {
      return true;
    }
    if (!tokens.includes("--owned-paths")) return true;

    for (let index = 0; index < tokens.length; index += 1) {
      const token = tokens[index];
      if (valueFlags.has(token)) {
        const value = tokens[index + 1];
        if (value == null || value.startsWith("-")) return true;
        index += 1;
        continue;
      }
      if (booleanFlags.has(token)) continue;
      return true;
    }
  }
  return false;
}

function commandSegment(suffix) {
  const boundary = suffix.search(/(?:&&|\|\||[;|`])/u);
  return boundary === -1 ? suffix : suffix.slice(0, boundary);
}

function isInlineCodeInvocation(prefix, suffix) {
  const openingTicks = prefix.match(/`/gu)?.length ?? 0;
  return openingTicks % 2 === 1 && suffix.includes("`");
}

function isStandaloneCommandPrefix(prefix) {
  return /^\s*(?:(?:[-*+]|\d+\.)\s+)?(?:\$\s*)?$/u.test(prefix);
}

function commandTokens(source) {
  return [...String(source).matchAll(/"[^"]*"|'[^']*'|\S+/gu)]
    .map((match) => match[0].replace(/^[`"']+|[`"'.,:]+$/gu, ""))
    .filter(Boolean);
}

function readDependencyDirectionBaselineSnapshot({baseline, snapshot}) {
  const result = scanDependencyDirection({
    snapshot,
    baseline: baseline ?? {allowedFindings: []},
  });
  return {
    baseline_total: result.baselineFindings.length,
    baseline_by_rule: result.summary.baselineFindingsByRule,
    new_findings_total: result.findings.length,
    checked_files: result.checkedFiles,
  };
}

export function testInventoryMatches(currentSource, expectedInventory) {
  return currentSource === renderInventory(expectedInventory);
}

export function extractCommandPaths(command) {
  const source = String(command);
  const buildsFunctions = source.includes("npm --prefix functions run build");

  return source
    .split(/\s+/)
    .map((token) => token.replace(/^['"]|['"]$/g, "").replace(/,$/, ""))
    .flatMap((token) => token.split(","))
    .map((token) => token.replace(/^\.\//, ""))
    .map((token) => {
      if (buildsFunctions && /^functions\/lib\/.+\.js$/u.test(token)) {
        return token
          .replace(/^functions\/lib\//u, "functions/src/")
          .replace(/\.js$/u, ".ts");
      }
      return token;
    })
    .filter((token) => {
      if (!token || token.includes("*")) return false;
      return /^(AGENTS\.md|docs\/|tool\/|operations\/|lib\/|test\/|functions\/|contracts\/|widgetbook\/|website\/|packages\/web-config\/|design\/website\/|\.github\/|ios\/|android\/|firebase\.json|\.firebaserc|firestore\.rules|storage\.rules)/.test(token);
    });
}

function parseJsonSource(source) {
  if (source == null) return null;
  try {
    return JSON.parse(source);
  } catch {
    return null;
  }
}

function repositoryPathExists(snapshot, relativePath) {
  const normalized = relativePath.replace(/\/$/u, "");
  if (snapshot.exists(normalized)) return true;
  return snapshot.listPaths({prefix: normalized}).length > 0;
}

function parseArgs(argv) {
  const parsed = {json: false};
  for (const arg of argv) {
    if (arg === "--json") parsed.json = true;
    else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return parsed;
}

function printHelp() {
  console.log(`Usage: node tool/agent/check_agent_readiness.mjs [--json]

Validates AGENTS.md, project-local skills, task-scope guidance, and tool
registration without writing repository evidence.
`);
}
