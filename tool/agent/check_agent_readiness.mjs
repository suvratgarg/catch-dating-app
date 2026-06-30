#!/usr/bin/env node
import fs from "node:fs";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));
const checks = [];

const docVersions = readJson("docs/audit_registry/doc_versions.json");
const toolsManifest = readJson("tool/tools_manifest.json");
const regressionLedger = readJson("docs/agent_regression_ledger.json");
const skillsManifest = readJson("docs/agent_skills/skills_manifest.json");

checkPath("AGENTS.md", "Agent entrypoint exists.");
checkPath("docs/agent_operating_model.md", "Agent operating model exists.");
checkPath("docs/agent_regression_ledger.json", "Regression ledger exists.");
checkPath("docs/agent_skills/skills_manifest.json", "Skill manifest exists.");
checkPath("docs/audit_registry/agent_metrics.jsonl", "Agent metrics ledger exists.");
checkPath("tool/agent/context_pack.mjs", "Context pack tool exists.");
checkPath("tool/agent/check_agent_readiness.mjs", "Readiness tool exists.");

checkContains("AGENTS.md", "docs/agent_operating_model.md", "AGENTS.md routes to the operating model.");
checkContains("AGENTS.md", "tool/agent/context_pack.mjs", "AGENTS.md names the context-pack tool.");
checkContains("AGENTS.md", "tool/agent/check_agent_readiness.mjs", "AGENTS.md names the readiness tool.");
checkContains("docs/README.md", "agent_operating_model.md", "Docs index includes the operating model.");
checkContains("docs/README.md", "agent_skills/", "Docs index includes project-local skills.");

for (const [docId, expectedPath] of Object.entries({
  agent_entrypoint: "AGENTS.md",
  agent_operating_model: "docs/agent_operating_model.md",
  agent_regression_ledger: "docs/agent_regression_ledger.json",
  agent_skills: "docs/agent_skills/README.md",
})) {
  const entry = docVersions?.[docId];
  check(Boolean(entry), `doc_versions includes ${docId}.`);
  if (entry) check(entry.path === expectedPath, `${docId} points to ${expectedPath}.`);
}

const toolIds = new Set((toolsManifest?.tools ?? []).map((tool) => tool.id));
for (const id of ["agent:context-pack", "agent:readiness"]) {
  check(toolIds.has(id), `Tool manifest includes ${id}.`);
}

validateRegressionLedger(regressionLedger);
validateSkills(skillsManifest, toolIds);
validateMetrics("docs/audit_registry/agent_metrics.jsonl");

const passed = checks.filter((entry) => entry.ok).length;
const failed = checks.length - passed;
const score = checks.length === 0 ? 0 : Math.round((passed / checks.length) * 100);

const result = {
  score,
  passed,
  failed,
  total: checks.length,
  failures: checks.filter((entry) => !entry.ok).map((entry) => entry.message),
};

if (args.recordMetric) {
  appendMetric(result);
}

if (args.json) {
  console.log(JSON.stringify(result, null, 2));
} else {
  console.log(`Agent readiness score: ${score}/100 (${passed}/${checks.length} checks passed)`);
  for (const failure of result.failures) {
    console.error(`- ${failure}`);
  }
}

if (failed > 0) {
  process.exitCode = 1;
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
      JSON.parse(line);
      check(true, `${relativePath}:${index + 1} is valid JSON.`);
    } catch {
      check(false, `${relativePath}:${index + 1} is valid JSON.`);
    }
  }
}

function extractCommandPaths(command) {
  return String(command)
    .split(/\s+/)
    .map((token) => token.replace(/^['"]|['"]$/g, "").replace(/,$/, ""))
    .flatMap((token) => token.split(","))
    .map((token) => token.replace(/^\.\//, ""))
    .filter((token) => {
      if (!token || token.includes("*")) return false;
      return /^(AGENTS\.md|docs\/|tool\/|lib\/|test\/|functions\/|contracts\/|widgetbook\/|\.github\/|ios\/|android\/|firebase\.json|\.firebaserc|firestore\.rules|storage\.rules)/.test(token);
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
