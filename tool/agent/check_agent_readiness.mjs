#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {scanDependencyDirection} from "../architecture/check_dependency_direction.mjs";
import {fromRepo} from "../lib/repo_paths.mjs";
import {buildInventory, renderInventory} from "../test_inventory.mjs";

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

const checks = [];

if (isCliEntrypoint) runCli();

function runCli() {
  const args = parseArgs(process.argv.slice(2));
  const docVersions = readJson("docs/audit_registry/doc_versions.json");
  const toolsManifest = readJson("tool/tools_manifest.json");
  const regressionLedger = readJson("docs/agent_regression_ledger.json");
  const skillsManifest = readJson("docs/agent_skills/skills_manifest.json");
  const metricsPath = "docs/audit_registry/agent_metrics.jsonl";

  checkPath("AGENTS.md", "Agent entrypoint exists.");
  checkPath("docs/agent_operating_model.md", "Agent operating model exists.");
  checkPath("docs/agent_regression_ledger.json", "Regression ledger exists.");
  checkPath("docs/agent_skills/skills_manifest.json", "Skill manifest exists.");
  checkPath(metricsPath, "Agent metrics ledger exists.");
  checkPath("tool/agent/context_pack.mjs", "Context pack tool exists.");
  checkPath("tool/agent/check_agent_readiness.mjs", "Readiness tool exists.");
  checkPath(
    "docs/audit_registry/test_inventory.json",
    "Canonical test inventory exists.",
  );
  checkPath(
    "tool/agent/record_delegation_outcome.mjs",
    "Delegation outcome recorder exists.",
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
    "AGENTS.md",
    "tool/agent/check_agent_readiness.mjs",
    "AGENTS.md names the readiness tool.",
  );
  checkContains(
    "AGENTS.md",
    "tool/agent/record_delegation_outcome.mjs",
    "AGENTS.md names the delegation recorder.",
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
    "docs/agent_operating_model.md",
    "tool/docs/check_doc_version_monotonic.mjs",
    "Operating model requires monotonic governed document versions.",
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
      readText("docs/audit_registry/test_inventory.json"),
      buildInventory(),
    ),
    "Canonical test inventory matches tracked and untracked test files.",
  );

  for (const [docId, expectedPath] of Object.entries({
    agent_entrypoint: "AGENTS.md",
    agent_operating_model: "docs/agent_operating_model.md",
    agent_regression_ledger: "docs/agent_regression_ledger.json",
    agent_skills: "docs/agent_skills/README.md",
  })) {
    const entry = docVersions?.[docId];
    check(Boolean(entry), `doc_versions includes ${docId}.`);
    if (entry) {
      check(entry.path === expectedPath, `${docId} points to ${expectedPath}.`);
    }
  }

  const toolIds = new Set((toolsManifest?.tools ?? []).map((tool) => tool.id));
  for (const id of [
    "agent:context-pack",
    "agent:readiness",
    "git:audit-merge-drops",
    "docs:version-monotonic",
  ]) {
    check(toolIds.has(id), `Tool manifest includes ${id}.`);
  }
  check(
    toolIds.has("agent:record-delegation"),
    "Tool manifest includes agent:record-delegation.",
  );

  const dependencyDirectionBaseline = readDependencyDirectionBaselineSnapshot();
  const metricsEntries = readMetricEntries(metricsPath);
  const warnings = dependencyBaselineGrowthWarnings(
    metricsEntries,
    dependencyDirectionBaseline,
  );

  validateRegressionLedger(regressionLedger);
  validateSkills(skillsManifest, toolIds);
  validateMetrics(metricsPath);

  const passed = checks.filter((entry) => entry.ok).length;
  const failed = checks.length - passed;
  const score =
    checks.length === 0 ? 0 : Math.round((passed / checks.length) * 100);

  const result = {
    score,
    passed,
    failed,
    total: checks.length,
    failures: checks.filter((entry) => !entry.ok).map((entry) => entry.message),
    warnings,
    architecture_baselines: {
      dependency_direction: dependencyDirectionBaseline,
    },
  };

  if (args.recordMetric) {
    appendMetric(result);
  }

  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(
      `Agent readiness score: ${score}/100 (${passed}/${checks.length} checks passed)`,
    );
    for (const failure of result.failures) {
      console.error(`- ${failure}`);
    }
    for (const warning of result.warnings) {
      console.error(`! ${warning}`);
    }
  }

  if (failed > 0) {
    process.exitCode = 1;
  }
}

function validateRegressionLedger(ledger) {
  check(Boolean(ledger && Array.isArray(ledger.entries)), "Regression ledger has an entries array.");
  const seenIds = new Set();
  for (const entry of ledger?.entries ?? []) {
    check(Boolean(entry.id), "Regression entry has id.");
    if (entry.id) {
      check(!seenIds.has(entry.id), `Regression id is unique: ${entry.id}.`);
      seenIds.add(entry.id);
    }
    check(["active", "watch", "archived"].includes(entry.status), `${entry.id} has valid status.`);
    check(Array.isArray(entry.applies_to) && entry.applies_to.length > 0, `${entry.id} declares applies_to.`);
    check(Boolean(entry.symptom), `${entry.id} declares symptom.`);
    check(Boolean(entry.guard?.type), `${entry.id} declares guard type.`);
    if (["active", "watch"].includes(entry.status)) {
      check(Boolean(entry.guard?.command), `${entry.id} active/watch entry declares guard command.`);
    }
    for (const ownerDoc of entry.owner_docs ?? []) {
      checkPath(ownerDoc, `${entry.id} owner doc exists: ${ownerDoc}.`);
    }
    for (const commandPath of extractCommandPaths(entry.guard?.command ?? "")) {
      checkPath(commandPath, `${entry.id} guard command path exists: ${commandPath}.`);
    }
  }
}

function validateSkills(manifest, toolIds) {
  check(Boolean(manifest && Array.isArray(manifest.skills)), "Skill manifest has a skills array.");
  const seenIds = new Set();
  for (const skill of manifest?.skills ?? []) {
    check(Boolean(skill.skill_id), "Skill has skill_id.");
    if (skill.skill_id) {
      check(!seenIds.has(skill.skill_id), `Skill id is unique: ${skill.skill_id}.`);
      seenIds.add(skill.skill_id);
    }
    checkPath(skill.path, `${skill.skill_id} markdown file exists.`);
    check(Array.isArray(skill.source_docs) && skill.source_docs.length > 0, `${skill.skill_id} declares source docs.`);
    check(Array.isArray(skill.required_tools) && skill.required_tools.length > 0, `${skill.skill_id} declares required tools.`);
    check(Array.isArray(skill.required_commands) && skill.required_commands.length > 0, `${skill.skill_id} declares required commands.`);
    check(Boolean(skill.success_receipt), `${skill.skill_id} declares success receipt.`);
    for (const sourceDoc of skill.source_docs ?? []) {
      checkPath(sourceDoc, `${skill.skill_id} source doc exists: ${sourceDoc}.`);
    }
    for (const toolId of skill.required_tools ?? []) {
      check(toolIds.has(toolId), `${skill.skill_id} required tool exists: ${toolId}.`);
    }
    for (const command of skill.required_commands ?? []) {
      for (const commandPath of extractCommandPaths(command)) {
        checkPath(commandPath, `${skill.skill_id} command path exists: ${commandPath}.`);
      }
    }
  }
}

function validateMetrics(relativePath) {
  const fullPath = fromRepo(relativePath);
  if (!fs.existsSync(fullPath)) return;
  const lines = fs.readFileSync(fullPath, "utf8").split(/\r?\n/).filter(Boolean);
  for (const [index, line] of lines.entries()) {
    try {
      const entry = JSON.parse(line);
      check(true, `${relativePath}:${index + 1} is valid JSON.`);
      validateMetricEntry(entry, `${relativePath}:${index + 1}`);
    } catch {
      check(false, `${relativePath}:${index + 1} is valid JSON.`);
    }
  }
}

function validateMetricEntry(entry, label) {
  if (entry?.event === "agent_readiness_check") {
    validateReadinessMetric(entry, label);
    return;
  }
  if (entry?.event !== "agent_delegation_outcome") return;
  for (const field of ["task_id", "mode", "status", "parent_review_outcome", "timestamp"]) {
    check(Boolean(entry[field]), `${label} delegation metric declares ${field}.`);
  }
  check(Array.isArray(entry.files_changed), `${label} delegation metric files_changed is an array.`);
  check(Array.isArray(entry.checks_run), `${label} delegation metric checks_run is an array.`);
  check(Array.isArray(entry.checks_failed), `${label} delegation metric checks_failed is an array.`);
  check(Number.isFinite(entry.conflicts_count), `${label} delegation metric conflicts_count is numeric.`);
  check(Number.isFinite(entry.parent_edits_required), `${label} delegation metric parent_edits_required is numeric.`);
}

function validateReadinessMetric(entry, label) {
  const snapshot = extractDependencyBaselineSnapshot(entry);
  if (snapshot == null) return;
  check(
    Number.isFinite(snapshot.baseline_total),
    `${label} readiness metric dependency baseline total is numeric.`,
  );
  check(
    Number.isFinite(snapshot.new_findings_total),
    `${label} readiness metric dependency new findings total is numeric.`,
  );
  check(
    Number.isFinite(snapshot.checked_files),
    `${label} readiness metric dependency checked files is numeric.`,
  );
  check(
    snapshot.baseline_by_rule &&
      Object.values(snapshot.baseline_by_rule).every(Number.isFinite),
    `${label} readiness metric dependency baseline by-rule counts are numeric.`,
  );
}

function readDependencyDirectionBaselineSnapshot() {
  const baseline = readJson("tool/architecture/dependency_direction_baseline.json");
  const result = scanDependencyDirection({
    root: fromRepo(),
    baseline: baseline ?? {allowedFindings: []},
  });
  return {
    baseline_total: result.baselineFindings.length,
    baseline_by_rule: result.summary.baselineFindingsByRule,
    new_findings_total: result.findings.length,
    checked_files: result.checkedFiles,
  };
}

function readMetricEntries(relativePath) {
  const fullPath = fromRepo(relativePath);
  if (!fs.existsSync(fullPath)) return [];
  const entries = [];
  for (const line of fs.readFileSync(fullPath, "utf8").split(/\r?\n/)) {
    if (!line.trim()) continue;
    try {
      entries.push(JSON.parse(line));
    } catch {
      // validateMetrics reports malformed JSON; growth warnings ignore it.
    }
  }
  return entries;
}

export function extractDependencyBaselineSnapshot(entry) {
  if (
    entry?.event === "enforcement_baseline" &&
    entry.baseline === "tool/architecture/dependency_direction_baseline.json"
  ) {
    return {
      baseline_total: Number(
        entry.counts?.allowedFindings ?? entry.allowedFindingsCount ?? 0,
      ),
      baseline_by_rule: Object.fromEntries(
        Object.entries(entry.ruleCounts ?? {}).map(([rule, count]) => [
          rule,
          Number(count),
        ]),
      ),
      new_findings_total: 0,
      checked_files: 0,
    };
  }

  const snapshot = entry?.architecture_baselines?.dependency_direction;
  if (snapshot == null) return null;
  return {
    baseline_total: Number(snapshot.baseline_total),
    baseline_by_rule: Object.fromEntries(
      Object.entries(snapshot.baseline_by_rule ?? {}).map(([rule, count]) => [
        rule,
        Number(count),
      ]),
    ),
    new_findings_total: Number(snapshot.new_findings_total ?? 0),
    checked_files: Number(snapshot.checked_files ?? 0),
  };
}

export function testInventoryMatches(currentSource, expectedInventory) {
  return currentSource === renderInventory(expectedInventory);
}

export function dependencyBaselineGrowthWarnings(entries, currentSnapshot) {
  const previousSnapshot = entries
    .map(extractDependencyBaselineSnapshot)
    .filter(Boolean)
    .at(-1);
  if (previousSnapshot == null) return [];
  if (currentSnapshot.baseline_total <= previousSnapshot.baseline_total) {
    return [];
  }

  const ruleGrowth = [];
  const rules = new Set([
    ...Object.keys(previousSnapshot.baseline_by_rule),
    ...Object.keys(currentSnapshot.baseline_by_rule),
  ]);
  for (const rule of [...rules].sort()) {
    const previous = previousSnapshot.baseline_by_rule[rule] ?? 0;
    const current = currentSnapshot.baseline_by_rule[rule] ?? 0;
    if (current > previous) ruleGrowth.push(`${rule} ${previous}->${current}`);
  }
  const detail = ruleGrowth.length > 0 ? ` (${ruleGrowth.join(", ")})` : "";
  return [
    `Dependency direction baseline grew ${previousSnapshot.baseline_total}->${currentSnapshot.baseline_total}${detail}. Burn down or update the baseline intentionally.`,
  ];
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

function appendMetric(result) {
  const entry = {
    timestamp: new Date().toISOString(),
    event: "agent_readiness_check",
    readiness_score: result.score,
    checks_passed: result.passed,
    checks_failed: result.failed,
    checks_total: result.total,
    architecture_baselines: result.architecture_baselines,
  };
  fs.appendFileSync(fromRepo("docs/audit_registry/agent_metrics.jsonl"), `${JSON.stringify(entry)}\n`);
}

function checkPath(relativePath, message) {
  check(Boolean(relativePath) && fs.existsSync(fromRepo(relativePath)), message);
}

function checkContains(relativePath, needle, message) {
  const fullPath = fromRepo(relativePath);
  check(fs.existsSync(fullPath) && fs.readFileSync(fullPath, "utf8").includes(needle), message);
}

function check(ok, message) {
  checks.push({ok: Boolean(ok), message});
}

function readJson(relativePath) {
  try {
    return JSON.parse(fs.readFileSync(fromRepo(relativePath), "utf8"));
  } catch {
    return null;
  }
}

function readText(relativePath) {
  try {
    return fs.readFileSync(fromRepo(relativePath), "utf8");
  } catch {
    return "";
  }
}

function parseArgs(argv) {
  const parsed = {json: false, recordMetric: false};
  for (const arg of argv) {
    if (arg === "--json") parsed.json = true;
    else if (arg === "--record-metric") parsed.recordMetric = true;
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
  console.log(`Usage: node tool/agent/check_agent_readiness.mjs [--json] [--record-metric]

Validates AGENTS.md, project-local skills, regression ledger, tool manifest
registration, and parseable agent metrics.
`);
}
