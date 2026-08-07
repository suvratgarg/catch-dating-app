#!/usr/bin/env node
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo} from "./lib/repo_paths.mjs";
import {createRepositorySnapshot} from "./lib/repository_snapshot.mjs";

const allowedStages = new Set([
  "manual",
  "prose",
  "scanner-ratchet",
  "scanner-gate",
  "analyzer-info",
  "analyzer-warning",
  "retired",
]);

const allowedRoles = new Set(["gate", "ratchet", "finder", "generator", "operator"]);
const activeRuleStatuses = new Set(["active"]);
const allowedRuleKinds = new Set([
  "contract",
  "scar",
  "process",
  "product-marker",
]);
const allowedSunsetSignalTypes = new Set([
  "tool-exists",
  "baseline-empty",
  "manual",
]);
const allowedSunsetReviewDecisions = new Set(["keep", "graduate", "retire"]);
const explicitRolePathExemptions = [
  /^tool\/web\//u,
  /^tool\/marketing\//u,
  /^tool\/admin\//u,
  /^tool\/design\//u,
  /^tool\/contracts\//u,
  /^tool\/data\//u,
  /^tool\/firebase\//u,
  /^tool\/env\//u,
  /^tool\/ci\//u,
  /^tool\/agent\//u,
  /^tool\/migrations\//u,
];

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) {
  const result = checkEnforcementIntegrity({root: fromRepo()});
  if (result.errors.length > 0) {
    console.error("Enforcement integrity check failed:");
    for (const error of result.errors) console.error(`- ${error}`);
    process.exitCode = 1;
  } else {
    console.log(
      `Enforcement integrity passed: ${result.activeRules} active rules, ` +
        `${result.boundTools} bound tools.`,
    );
  }
}

export function checkEnforcementIntegrity({
  root,
  snapshot = createRepositorySnapshot({root}),
}) {
  const errors = [];
  const rulesPath = "tool/policy/rules.json";
  const manifestPath = "tool/tools_manifest.json";
  const rulesDocument = snapshot.readJson(rulesPath, {required: true});
  const manifest = snapshot.readJson(manifestPath, {required: true});

  const rules = Object.entries(rulesDocument.rules ?? {}).map(([id, value]) => ({
    id,
    ...value,
  }));
  const rulesById = new Map(rules.map((rule) => [rule.id, rule]));
  const tools = Array.isArray(manifest.tools) ? manifest.tools : [];
  const toolsById = new Map(tools.map((tool) => [tool.id, tool]));
  const toolsByPath = new Map(tools.map((tool) => [tool.path, tool]));
  const boundToolIds = new Set();

  for (const rule of rules) {
    if (!activeRuleStatuses.has(rule.status)) continue;
    validateRuleMetadata({
      rule,
      snapshot,
      toolsById,
      errors,
    });
    if (!Array.isArray(rule.enforcement) || rule.enforcement.length === 0) {
      errors.push(`${rule.id}: active rule has no enforcement entries.`);
      continue;
    }
    for (const entry of rule.enforcement) {
      validateRuleEnforcementEntry({
        entry,
        rule,
        snapshot,
        toolsById,
        toolsByPath,
        errors,
      });
      const tool = toolForEntry(entry, toolsById, toolsByPath);
      if (tool) boundToolIds.add(tool.id);
    }
  }

  for (const tool of tools) {
    if (tool.rules != null) {
      if (!Array.isArray(tool.rules) || tool.rules.length === 0) {
        errors.push(`${tool.id}: rules must be a non-empty array when present.`);
      } else {
        for (const ruleId of tool.rules) {
          const rule = rulesById.get(ruleId);
          if (!rule) {
            errors.push(`${tool.id}: references unknown rule ${ruleId}.`);
            continue;
          }
          const ruleHasReverseEntry = (rule.enforcement ?? []).some((entry) => {
            const boundTool = toolForEntry(entry, toolsById, toolsByPath);
            return boundTool?.id === tool.id;
          });
          if (!ruleHasReverseEntry) {
            errors.push(
              `${tool.id}: lists ${ruleId}, but ${ruleId} does not bind back to this tool.`,
            );
          }
        }
      }
    }
    validateToolMetadata({tool, snapshot, errors});
  }

  for (const relativePath of discoverArchitectureScripts(snapshot)) {
    const tool = toolsByPath.get(relativePath);
    if (!tool) continue;
    if (tool.status !== "active") continue;
    if (!Array.isArray(tool.rules) || tool.rules.length === 0) {
      errors.push(`${tool.id}: active architecture scanner has no rule mapping.`);
    }
  }

  return {
    activeRules: rules.filter((rule) => activeRuleStatuses.has(rule.status))
      .length,
    boundTools: boundToolIds.size,
    errors,
  };
}

function validateRuleEnforcementEntry({
  entry,
  rule,
  snapshot,
  toolsById,
  toolsByPath,
  errors,
}) {
  if (entry == null || typeof entry !== "object" || Array.isArray(entry)) {
    errors.push(`${rule.id}: enforcement entry must be an object.`);
    return;
  }
  if (!allowedStages.has(entry.stage)) {
    errors.push(`${rule.id}: enforcement entry has invalid stage ${entry.stage}.`);
  }
  if (!entry.docAnchor) {
    errors.push(`${rule.id}: enforcement entry is missing docAnchor.`);
  } else {
    validateDocAnchor({snapshot, docAnchor: entry.docAnchor, owner: rule.id, errors});
  }

  if (entry.stage !== "manual" && entry.stage !== "prose" && entry.stage !== "retired") {
    if (!entry.tool) {
      errors.push(`${rule.id}: ${entry.stage} enforcement requires a tool.`);
      return;
    }
    const tool = toolForEntry(entry, toolsById, toolsByPath);
    if (!tool) {
      errors.push(`${rule.id}: enforcement references unknown tool ${entry.tool}.`);
      return;
    }
    if (!Array.isArray(tool.rules) || !tool.rules.includes(rule.id)) {
      errors.push(`${rule.id}: tool ${tool.id} is missing reverse rules mapping.`);
    }
    if (entry.baseline) {
      validateRepoFile({snapshot, filePath: entry.baseline, owner: rule.id, errors});
    }
  }
}

function validateRuleMetadata({rule, snapshot, toolsById, errors}) {
  if (!allowedRuleKinds.has(rule.kind)) {
    errors.push(`${rule.id}: active rule has invalid or missing kind.`);
  }
  if (
    !Array.isArray(rule.sunset_signals) ||
    rule.sunset_signals.length === 0
  ) {
    errors.push(`${rule.id}: active rule has no sunset_signals.`);
    return;
  }

  const satisfiedSignals = [];
  for (const signal of rule.sunset_signals) {
    const result = evaluateSunsetSignal({signal, rule, snapshot, toolsById, errors});
    if (result?.satisfied) satisfiedSignals.push(result.label);
  }

  if (satisfiedSignals.length === 0) return;
  if (!isValidSunsetReview(rule.sunset_review)) {
    errors.push(
      `${rule.id}: sunset signal satisfied (${satisfiedSignals.join(", ")}) but sunset_review is missing or invalid.`,
    );
  }
}

function evaluateSunsetSignal({signal, rule, snapshot, toolsById, errors}) {
  if (signal == null || typeof signal !== "object" || Array.isArray(signal)) {
    errors.push(`${rule.id}: sunset signal must be an object.`);
    return null;
  }
  if (!allowedSunsetSignalTypes.has(signal.type)) {
    errors.push(`${rule.id}: sunset signal has invalid type ${signal.type}.`);
    return null;
  }
  if (signal.type === "manual") return {satisfied: false, label: "manual"};
  if (signal.type === "tool-exists") {
    if (!signal.tool) {
      errors.push(`${rule.id}: tool-exists sunset signal is missing tool.`);
      return null;
    }
    return {
      satisfied: toolsById.has(signal.tool),
      label: `tool-exists:${signal.tool}`,
    };
  }
  if (signal.type === "baseline-empty") {
    if (!signal.baseline || !signal.countKey) {
      errors.push(
        `${rule.id}: baseline-empty sunset signal requires baseline and countKey.`,
      );
      return null;
    }
    validateRepoFile({
      snapshot,
      filePath: signal.baseline,
      owner: rule.id,
      errors,
    });
    if (!snapshot.exists(signal.baseline)) {
      return {satisfied: false, label: `baseline-empty:${signal.baseline}`};
    }
    const baseline = snapshot.readJson(signal.baseline, {required: true});
    return {
      satisfied: baselineCountForSignal(baseline, signal.countKey) === 0,
      label: `baseline-empty:${signal.baseline}:${signal.countKey}`,
    };
  }
  return null;
}

function baselineCountForSignal(baseline, countKey) {
  if (countKey === "entries") {
    return Array.isArray(baseline.entries) ? baseline.entries.length : null;
  }
  if (countKey === "allowedFindings") {
    return Array.isArray(baseline.allowedFindings)
      ? baseline.allowedFindings.length
      : null;
  }
  if (baseline.maxCounts != null && typeof baseline.maxCounts === "object") {
    return baseline.maxCounts[countKey] ?? null;
  }
  return null;
}

function isValidSunsetReview(review) {
  return (
    review != null &&
    typeof review === "object" &&
    !Array.isArray(review) &&
    /^\d{4}-\d{2}-\d{2}$/u.test(review.date ?? "") &&
    allowedSunsetReviewDecisions.has(review.decision) &&
    typeof review.note === "string" &&
    review.note.trim().length > 0
  );
}

function validateToolMetadata({tool, snapshot, errors}) {
  if (requiresExplicitRole(tool) && tool.role == null) {
    errors.push(`${tool.id}: active checked tool must declare role.`);
  }
  if (tool.role != null && !allowedRoles.has(tool.role)) {
    errors.push(`${tool.id}: invalid role ${tool.role}.`);
  }
  if (tool.role === "gate" || tool.role === "ratchet") {
    if (!hasRuntimeCheck(tool)) {
      errors.push(
        `${tool.id}: ${tool.role} tool needs a manifest check that can execute the guard, not only syntax/count/help checks.`,
      );
    }
    validateVacuityProof({tool, snapshot, errors});
  }
  if (tool.baseline) {
    validateRepoFile({snapshot, filePath: tool.baseline, owner: tool.id, errors});
  }
}

function validateVacuityProof({tool, snapshot, errors}) {
  const proof = tool.vacuityProof;
  if (proof == null) {
    errors.push(`${tool.id}: ${tool.role} tool is missing vacuityProof.`);
    return;
  }
  if (proof.type === "test") {
    validateRepoFile({snapshot, filePath: proof.path, owner: tool.id, errors});
    if (Array.isArray(proof.contains)) {
      const source = readTextIfExists(snapshot, proof.path);
      for (const text of proof.contains) {
        if (!source.includes(text)) {
          errors.push(`${tool.id}: vacuity test ${proof.path} does not contain ${text}.`);
        }
      }
    }
    return;
  }
  if (proof.type === "probe-harness") {
    validateRepoFile({snapshot, filePath: proof.path, owner: tool.id, errors});
    const source = readTextIfExists(snapshot, proof.path);
    for (const diagnostic of proof.diagnostics ?? []) {
      if (!source.includes(diagnostic)) {
        errors.push(
          `${tool.id}: probe harness ${proof.path} does not assert ${diagnostic}.`,
        );
      }
    }
    return;
  }
  if (proof.type === "self-test") {
    if (!proof.command) {
      errors.push(`${tool.id}: self-test vacuityProof requires command.`);
      return;
    }
    if (!(tool.checks ?? []).includes(proof.command)) {
      errors.push(`${tool.id}: self-test command is not listed in manifest checks.`);
    }
    return;
  }
  errors.push(`${tool.id}: unsupported vacuityProof type ${proof.type}.`);
}

function hasRuntimeCheck(tool) {
  return (tool.checks ?? []).some((check) => {
    if (/\b(--check|--self-test)\b/u.test(check)) return true;
    if (check.includes("node --test")) return true;
    if (check.includes(tool.command ?? "") && !check.includes("--count")) {
      return true;
    }
    if ((tool.command ?? "").startsWith("bash ") && check === tool.command) {
      return true;
    }
    return false;
  });
}

function requiresExplicitRole(tool) {
  if (tool.status !== "active") return false;
  if (isExplicitRoleExemptPath(tool.path ?? "")) return false;
  if (isCoveredToolPath(tool.path ?? "")) return true;
  return (tool.checks ?? []).some((check) => isRealManifestRun(check));
}

function isCoveredToolPath(toolPath) {
  return (
    /^tool\/[^/]+\.sh$/u.test(toolPath) ||
    /^tool\/check_[^/]+\.mjs$/u.test(toolPath) ||
    /^tool\/(?:architecture|audit)\//u.test(toolPath)
  );
}

function isExplicitRoleExemptPath(toolPath) {
  return explicitRolePathExemptions.some((pattern) => pattern.test(toolPath));
}

function isRealManifestRun(check) {
  const trimmed = String(check).trim();
  if (trimmed.startsWith("bash -n ")) return false;
  if (trimmed.startsWith("node --check ")) return false;
  if (trimmed.startsWith("node --test ")) return false;
  if (trimmed.startsWith("dart analyze ")) return false;
  if (/^python3\b.+\bast\.parse\b/u.test(trimmed)) return false;
  return trimmed.length > 0;
}

function toolForEntry(entry, toolsById, toolsByPath) {
  if (!entry?.tool) return null;
  return toolsById.get(entry.tool) ?? toolsByPath.get(entry.tool) ?? null;
}

function validateDocAnchor({snapshot, docAnchor, owner, errors}) {
  const [filePath, fragment] = String(docAnchor).split("#");
  if (!snapshot.exists(filePath)) {
    errors.push(`${owner}: docAnchor file does not exist: ${filePath}.`);
    return;
  }
  if (!fragment) return;
  if (!filePath.endsWith(".md")) {
    errors.push(`${owner}: docAnchor fragments are supported only for markdown files.`);
    return;
  }
  const source = snapshot.readText(filePath, {required: true});
  const anchors = new Set();
  for (const line of source.split(/\r?\n/u)) {
    const match = /^(#{1,6})\s+(.+)$/u.exec(line);
    if (!match) continue;
    anchors.add(slugifyHeading(match[2]));
  }
  if (!anchors.has(fragment)) {
    errors.push(`${owner}: docAnchor heading not found: ${docAnchor}.`);
  }
}

function slugifyHeading(heading) {
  return heading
    .trim()
    .toLowerCase()
    .replace(/`([^`]+)`/gu, "$1")
    .replace(/[^\p{Letter}\p{Number}\s-]/gu, "")
    .replace(/\s+/gu, "-");
}

function validateRepoFile({snapshot, filePath, owner, errors}) {
  if (!snapshot.exists(filePath)) {
    errors.push(`${owner}: referenced file does not exist: ${filePath}.`);
  }
}

function discoverArchitectureScripts(snapshot) {
  return snapshot.listFiles({prefix: "tool/architecture/"})
    .filter((relativePath) => {
      const name = relativePath.slice("tool/architecture/".length);
      return !name.includes("/") && name.endsWith(".mjs") &&
        !name.endsWith(".test.mjs");
    });
}

function readTextIfExists(snapshot, filePath) {
  return snapshot.readText(filePath) ?? "";
}
